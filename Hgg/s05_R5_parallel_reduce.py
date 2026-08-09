#!/usr/bin/env python3
"""Parallel fixed-denominator-basis reducer for large exact rational sums.

MOTIVATION (measured, not assumed).  The R5 final stage was one monolithic
``sp.cancel(sp.together(expr))``.  Scheduler accounting on job 14184483
showed CPU/wallclock = 1.1, i.e. ONE core busy and fifteen idle, while the
sweeps that precede it run at 8-13x.  The final stage therefore wasted 15
of 16 cores.

ALGORITHM.  Probing real operands showed the denominators are products of a
TINY fixed set of irreducible physical factors (about 5-6: ``Nc``, ``pi``,
``s``, ``t1``, ``(Q2+s+t1)``, integers, or channel composites).  So:

  1. mask every non-polynomial atom (log, polylog, radical) behind a Dummy,
     giving a rational function in a purely polynomial symbol set;
  2. per term, split into numerator/denominator and FACTOR the denominator
     into irreducibles  -- parallel, independent per term;
  3. take the elementwise MAXIMUM power of each irreducible over all terms.
     That product is the common denominator ``D``, built once and never
     expanded;
  4. per term, expand ``numerator * (D / D_i)`` into a sparse polynomial
     dict -- parallel, independent per term;
  5. merge the dicts by ADDING coefficients.  Merging is cheap.

The sum is exactly zero iff the merged numerator dict is empty after
dropping zero coefficients.  This is linear in the number of terms, uses
every core, and never forms a denominator cross-product.

Everything is exact: no Float, no sampling, no tolerance.  Radicals and
logs are preserved symbolically by masking, never approximated.
"""
import multiprocessing as mp
import os
import pickle
import resource
import sys

import sympy as sp

WORKER_CAP = int(os.environ.get("R5RED_WORKER_CAP_BYTES", "3221225472"))

_MASK = {}          # masked Dummy -> original atom (worker-local copy)
_GENS = ()


def _init_worker(mask, gens, cap):
    global _MASK, _GENS
    _MASK, _GENS = mask, gens
    try:
        resource.setrlimit(resource.RLIMIT_AS, (cap, cap))
    except (ValueError, OSError):
        pass


def _nonpolynomial_atoms(expr):
    """Atoms that cannot be polynomial generators: logs, polylogs, radicals.

    The first version then filtered these to "maximal" atoms with a nested
    `any(... other.has(atom) ...)` loop -- O(k^2) in the number of atoms,
    each step an expensive `.has()`.  That hung for over 20 minutes on a
    176k-op node before printing anything.  The filter is unnecessary:
    `xreplace` substitutes simultaneously, so when an inner atom sits
    inside an outer masked atom the outer replacement wins and the inner
    never appears on its own.  One linear traversal is enough.
    """
    atoms = set()
    for node in sp.preorder_traversal(expr):
        if isinstance(node, (sp.log, sp.polylog, sp.Abs)):
            atoms.add(node)
        elif node.is_Pow and not node.exp.is_Integer:
            atoms.add(node)
    return atoms


def build_mask(expr):
    """Mask transcendental/algebraic atoms with a minimal exact basis.

    Half-integer powers of the same positive physical radicand are NOT
    independent generators: ``A**(-1/2)=sqrt(A)/A`` and
    ``A**(3/2)=A*sqrt(A)``.  The former implementation masked each as a new
    symbol, hiding these exact relations and inflating Hgg from two radical
    bases to five/six unrelated generators.  Use one symbol per base and
    reduce every half-power modulo its rational square.
    """
    mask, backward = {}, {}
    half_powers = {}
    for atom in expr.atoms(sp.Pow):
        exponent = atom.exp
        if exponent.is_Rational and exponent.q == 2:
            half_powers.setdefault(atom.base, []).append(atom)

    index = 0
    covered = set()
    for base in sorted(half_powers, key=sp.srepr):
        symbol = sp.Symbol("R5MASK%d" % index)
        index += 1
        backward[symbol] = sp.sqrt(base)
        for atom in half_powers[base]:
            numerator = int(atom.exp.p)
            integer_power = numerator // 2
            replacement = symbol*base**integer_power
            mask[atom] = replacement
            covered.add(atom)

    for atom in sorted(_nonpolynomial_atoms(expr) - covered, key=sp.srepr):
        symbol = sp.Symbol("R5MASK%d" % index)
        index += 1
        mask[atom] = symbol
        backward[symbol] = atom
    return mask, backward


def _outer_linear_terms(expression, minimum=8):
    """Expose a large Add directly inside a multiplicative prefactor.

    Hgg's pole has the measured shape ``K*Add(real batches) + CT``.  Treating
    that as two terms sends one enormous numerator to one worker and defeats
    the fixed-basis algorithm.  Linearity licenses distributing only the
    largest direct Add factor.  We deliberately do not call ``expand`` and do
    not distribute products of Adds, so numerator polynomials stay compact.
    """
    output = []
    for term in sp.Add.make_args(expression):
        if not term.is_Mul:
            output.append(term)
            continue
        additions = [factor for factor in term.args
                     if factor.is_Add and len(factor.args) >= minimum]
        if not additions:
            output.append(term)
            continue
        largest = max(additions, key=lambda factor: len(factor.args))
        prefactor = sp.Mul(*(factor for factor in term.args
                             if factor is not largest))
        output.extend(prefactor*part for part in largest.args)
    return tuple(output)


def _denominator_signature(term):
    """Factor one term's denominator into irreducibles.  Independent work."""
    numerator, denominator = sp.fraction(sp.together(term))
    powers = {}
    if denominator != 1:
        for factor, power in sp.factor(denominator).as_powers_dict().items():
            if factor.is_Number:
                # Numeric factors need no basis slot; fold them into the
                # numerator instead so D stays purely symbolic.
                numerator = numerator/factor**power
                continue
            powers[sp.srepr(factor)] = int(power)
    return numerator, powers


def _signature_worker(item):
    index, term = item
    numerator, powers = _denominator_signature(term)
    return index, sp.srepr(numerator), powers


def _numerator_worker(item):
    """Multiply numerator*cofactor directly as sparse polynomials.

    Calling ``expand`` first materializes the entire expression tree before
    SymPy can discover its sparse polynomial structure.  Hgg PP measured
    minutes in that avoidable expansion.  Construct each Poly separately and
    let the polynomial backend multiply sparse dictionaries directly.
    """
    numerator_repr, cofactor_repr = item
    numerator = sp.sympify(numerator_repr)
    cofactor = sp.sympify(cofactor_repr)
    if numerator == 0 or cofactor == 0:
        return []
    polynomial = sp.Poly(numerator, *_GENS)*sp.Poly(cofactor, *_GENS)
    return [(monomial, sp.srepr(coefficient))
            for monomial, coefficient in polynomial.terms()]


def _compress_signature_worker(item):
    """Sum numerators that already have the identical exact denominator."""
    powers, numerator_reprs = item
    value = sp.Add(*[sp.sympify(part) for part in numerator_reprs])
    if value == 0:
        return powers, None
    # Do not expand.  factor_terms exposes cheap common scalar/factor content
    # while preserving compact polynomial products inside each group.
    value = sp.factor_terms(value)
    return powers, sp.srepr(value)


def _cancel_pair_worker(pair):
    value = sp.cancel(sp.together(pair[0] + pair[1]))
    return sp.srepr(value), pair[2]


def _signature_value_worker(item):
    index, value = item
    _numerator, powers = _denominator_signature(value)
    return index, sp.srepr(value), powers


def balanced_cancel_zero(expr, workers=15, verbose=True):
    """Exact balanced rational addition with cancellation at every level.

    This is a fallback for identities whose global LCM is much larger than
    any useful intermediate.  Terms are ordered by denominator signature so
    neighboring additions share as many physical factors as possible.
    """
    raw_values = list(sp.Add.make_args(sp.sympify(expr)))
    context = mp.get_context("spawn")
    values = [None]*len(raw_values)
    with context.Pool(workers, initializer=_init_worker,
                      initargs=({}, (), WORKER_CAP),
                      maxtasksperchild=100) as pool:
        for index, value_repr, powers in pool.imap_unordered(
                _signature_value_worker, enumerate(raw_values), chunksize=4):
            values[index] = (sp.sympify(value_repr), powers)
    level = 0
    while len(values) > 1:
        # Pair terms with similar factored denominator bases.  Carry the union
        # signature upward as a safe ordering key; exact cancellation itself
        # never depends on this heuristic.
        ordered = sorted(values, key=lambda item: tuple(sorted(item[1].items())))
        carry = ordered.pop() if len(ordered) % 2 else None
        pairs = []
        for left, right in zip(ordered[::2], ordered[1::2]):
            union = dict(left[1])
            for factor, power in right[1].items():
                union[factor] = max(power, union.get(factor, 0))
            pairs.append((left[0], right[0], union))
        next_values = []
        with context.Pool(workers, initializer=_init_worker,
                          initargs=({}, (), WORKER_CAP),
                          maxtasksperchild=50) as pool:
            for result, signature in pool.imap_unordered(
                    _cancel_pair_worker, pairs, chunksize=1):
                value = sp.sympify(result)
                if value != 0:
                    next_values.append((value, signature))
        if carry is not None:
            next_values.append(carry)
        level += 1
        if verbose:
            print("R5RED balanced level=%d input=%d surviving=%d" %
                  (level, len(values), len(next_values)), flush=True)
        values = next_values
        if not values:
            return True
    return not values or values[0][0] == 0


def reduce_sum(expr, workers=15, verbose=True, linearize=True):
    """Reduce a large exact rational sum to ``(numerator, denominator, zero)``.

    ``zero`` is True only when every merged coefficient is exactly zero.
    """
    expr = sp.sympify(expr)
    if expr == 0:
        return sp.S.Zero, sp.S.One, True
    if expr.has(sp.Float):
        raise ValueError("Float atom in exact reduction input")

    mask, backward = build_mask(expr)
    masked = expr.xreplace(mask) if mask else expr
    # The generic R5 input is K*Add(...)+CT and benefits from exposing the
    # inner Add.  Algebraic-extension callers have already performed that
    # split term by term; distributing their newly combined rational pieces
    # can instead turn a few hundred terms into many thousands.
    terms = (_outer_linear_terms(masked) if linearize
             else sp.Add.make_args(masked))
    gens = tuple(sorted(masked.free_symbols, key=lambda s: s.name))
    if verbose:
        print("R5RED terms=%d masked_nodes=%d algebraic_gens=%d gens=%d"
              % (len(terms), len(mask), len(backward), len(gens)), flush=True)

    context = mp.get_context("spawn")
    # Pass 1: denominator signatures, fully parallel.
    numerators, signatures = [None]*len(terms), [None]*len(terms)
    with context.Pool(workers, initializer=_init_worker,
                      initargs=({}, gens, WORKER_CAP),
                      maxtasksperchild=200) as pool:
        for index, numerator_repr, powers in pool.imap_unordered(
                _signature_worker, enumerate(terms), chunksize=8):
            numerators[index] = numerator_repr
            signatures[index] = powers

    basis = {}
    for powers in signatures:
        for key, power in powers.items():
            if power > basis.get(key, 0):
                basis[key] = power
    denominator = sp.Mul(*[sp.sympify(key)**power
                           for key, power in sorted(basis.items())])
    if verbose:
        print("R5RED denominator basis: %d irreducible factors"
              % len(basis), flush=True)

    # Compress identical denominators before multiplying by any common-
    # denominator cofactor.  Hgg PP has 594 terms but only 183 signatures;
    # doing this first avoids expanding the same large cofactor dozens of
    # times and often cancels whole groups structurally.
    grouped = {}
    for numerator_repr, powers in zip(numerators, signatures):
        key = tuple(sorted(powers.items()))
        grouped.setdefault(key, []).append(numerator_repr)
    compressed = []
    group_jobs = [(key, values) for key, values in grouped.items()]
    with context.Pool(workers, initializer=_init_worker,
                      initargs=({}, gens, WORKER_CAP),
                      maxtasksperchild=100) as pool:
        for powers, numerator_repr in pool.imap_unordered(
                _compress_signature_worker, group_jobs, chunksize=1):
            if numerator_repr is not None:
                compressed.append((numerator_repr, dict(powers)))
    numerators = [item[0] for item in compressed]
    signatures = [item[1] for item in compressed]
    if verbose:
        print("R5RED signature groups=%d surviving=%d"
              % (len(grouped), len(compressed)), flush=True)

    # Pass 2: numerator*cofactor -> sparse polynomial dicts, fully parallel.
    jobs = []
    for numerator_repr, powers in zip(numerators, signatures):
        cofactor = sp.Mul(*[sp.sympify(key)**(power - powers.get(key, 0))
                            for key, power in sorted(basis.items())])
        jobs.append((numerator_repr, sp.srepr(cofactor)))

    merged = {}
    with context.Pool(workers, initializer=_init_worker,
                      initargs=({}, gens, WORKER_CAP),
                      maxtasksperchild=200) as pool:
        for contribution in pool.imap_unordered(
                _numerator_worker, jobs, chunksize=4):
            for monomial, coefficient_repr in contribution:
                coefficient = sp.sympify(coefficient_repr)
                if monomial in merged:
                    merged[monomial] = merged[monomial] + coefficient
                else:
                    merged[monomial] = coefficient

    surviving = {}
    for monomial, coefficient in merged.items():
        value = sp.expand(coefficient)
        if value != 0:
            surviving[monomial] = value
    if verbose:
        print("R5RED monomials merged=%d surviving=%d"
              % (len(merged), len(surviving)), flush=True)

    if not surviving:
        return sp.S.Zero, denominator, True
    numerator = sp.Add(*[coefficient*sp.Mul(*[
        generator**power for generator, power in zip(gens, monomial)])
        for monomial, coefficient in surviving.items()])
    if backward:
        numerator = numerator.xreplace(backward)
        denominator = denominator.xreplace(backward)
    return numerator, denominator, False


def exact_zero(expr, workers=15, verbose=True):
    """True iff ``expr`` is exactly zero, computed in parallel."""
    return reduce_sum(expr, workers, verbose)[2]


def signature_stats(expr, workers=15, linearize=True):
    """Print exact denominator-group occupancy without expanding cofactors."""
    expr = sp.sympify(expr)
    mask, _backward = build_mask(expr)
    masked = expr.xreplace(mask) if mask else expr
    terms = (_outer_linear_terms(masked) if linearize
             else sp.Add.make_args(masked))
    gens = tuple(sorted(masked.free_symbols, key=lambda s: s.name))
    context = mp.get_context("spawn")
    groups = {}
    with context.Pool(workers, initializer=_init_worker,
                      initargs=({}, gens, WORKER_CAP),
                      maxtasksperchild=200) as pool:
        for _index, _numerator, powers in pool.imap_unordered(
                _signature_worker, enumerate(terms), chunksize=8):
            key = tuple(sorted(powers.items()))
            groups[key] = groups.get(key, 0) + 1
    counts = sorted(groups.values(), reverse=True)
    basis = {}
    for powers in groups:
        for factor, power in powers:
            basis[factor] = max(power, basis.get(factor, 0))
    missing = []
    for powers, occupancy in groups.items():
        have = dict(powers)
        missing.append((sum(power - have.get(factor, 0)
                            for factor, power in basis.items()), occupancy))
    print("R5RED_SIGNATURE_STATS terms=%d groups=%d largest=%s"
          % (len(terms), len(groups), counts[:30]), flush=True)
    print("R5RED_SIGNATURE_BASIS %s" % [
        (sp.sstr(sp.sympify(factor)), power)
        for factor, power in sorted(basis.items())], flush=True)
    print("R5RED_SIGNATURE_MISSING %s" % sorted(missing)[:40], flush=True)
    return groups


def _selftest():
    a, b, c, Q = sp.symbols("a b c Q", positive=True)
    ok = True

    # 1. A large unevaluated sum over the FIXED denominator basis this
    # reducer is designed for.  The former self-test used 118 unrelated
    # factors (b+i)(c-i), forcing an irrelevant exponential common
    # denominator and testing a workload R5 never has.
    terms = [a**i/(b*c) for i in range(1, 60)]
    cancelling = sp.Add(*(terms + [-term for term in reversed(terms)]),
                         evaluate=False)
    num, den, zero = reduce_sum(cancelling, workers=4, verbose=False)
    print("selftest large cancelling sum zero=%s" % zero, flush=True)
    ok &= zero

    # 2. A genuinely nonzero sum must NOT be reported zero.
    nonzero = sp.Add(cancelling, a/(b*c), evaluate=False)
    num, den, zero = reduce_sum(nonzero, workers=4, verbose=False)
    print("selftest nonzero rejected=%s" % (not zero), flush=True)
    ok &= not zero

    # Hgg production shape: two giant factored summands.  The reducer must
    # expose the inner linear sum instead of assigning one huge numerator to
    # one worker.
    inner = sp.Add(*[a**i/(b*c) for i in range(1, 40)], evaluate=False)
    factored = sp.Add(Q*inner, -Q*inner, evaluate=False)
    linear = _outer_linear_terms(factored)
    num, den, zero = reduce_sum(factored, workers=4, verbose=False)
    exposed = len(linear) > len(sp.Add.make_args(factored))
    print("selftest factored linearization exposed=%s zero=%s" %
          (exposed, zero), flush=True)
    ok &= exposed and zero

    # 3. Exactness: the reduced form must equal the input.
    small = a/(b*(a - b)) - 1/(a - b) + 1/b
    num, den, zero = reduce_sum(small, workers=2, verbose=False)
    residual = sp.cancel(sp.together(num/den - small))
    print("selftest reduced form equals input=%s (zero=%s)"
          % (residual == 0, zero), flush=True)
    ok &= residual == 0

    # 4. Logs and radicals survive masking, and a log identity cancels.
    withlog = (sp.log(a/b)*a/(a - b) - sp.log(a/b)*a/(a - b)
               + sp.sqrt(Q)/b - sp.sqrt(Q)/b)
    num, den, zero = reduce_sum(withlog, workers=2, verbose=False)
    print("selftest log/radical cancellation zero=%s" % zero, flush=True)
    ok &= zero

    # 5. A nonzero expression carrying a radical is preserved exactly.
    withrad = sp.sqrt(Q)*a/(a - b) + 1/b
    num, den, zero = reduce_sum(withrad, workers=2, verbose=False)
    residual = sp.cancel(sp.together(num/den - withrad))
    print("selftest radical preserved exactly=%s" % (residual == 0),
          flush=True)
    ok &= residual == 0 and not zero

    print("R5RED_SELFTEST %s" % ("PASS" if ok else "FAIL"), flush=True)
    return ok


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--selftest":
        raise SystemExit(0 if _selftest() else 1)
    if len(sys.argv) > 2 and sys.argv[1] == "--check-pickle":
        expression = pickle.load(open(sys.argv[2], "rb"))
        count = int(sys.argv[3]) if len(sys.argv) > 3 else 15
        raise SystemExit(0 if exact_zero(expression, count, True) else 1)
    if len(sys.argv) > 2 and sys.argv[1] == "--signature-stats":
        expression = pickle.load(open(sys.argv[2], "rb"))
        count = int(sys.argv[3]) if len(sys.argv) > 3 else 15
        signature_stats(expression, count,
                        linearize="--no-linearize" not in sys.argv[4:])
        raise SystemExit(0)
    if len(sys.argv) > 2 and sys.argv[1] == "--balanced-check":
        expression = pickle.load(open(sys.argv[2], "rb"))
        count = int(sys.argv[3]) if len(sys.argv) > 3 else 15
        raise SystemExit(0 if balanced_cancel_zero(expression, count, True)
                         else 1)
    raise SystemExit(__doc__)
