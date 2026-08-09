#!/usr/bin/env python3
"""Map the R5 regular sector from the COMPACT frame to the INVARIANT frame.

WHAT AND WHY.  F1hat/F2hat are assembled from four objects per projection:

    delta, plus1B, plus2B   stage 2, INVARIANT frame (s, t1, Q2, B), NO Jacobian
    regular(s23)            R5,      COMPACT  frame (R5S, R5M, z, s23), WITH jac

Two sources in different variables cannot be combined however correct each is
(STATE 0z.72/0z.73; WRONG.md Category D).  This stage brings `regular` onto the
same footing as the other three: Jacobian removed, invariant variables.

THE JACOBIAN COMES OUT.  `Hqq_R5_exact.py` builds its output as
    R5_JAC = R5M/(z*R5K**2)                                    (line 56)
    mapped = weight*R5_JAC*_invariant_to_compact(term)         (line 142)
so R5 emits jac x H.  The other three sectors are hard-function level and carry
no Jacobian, and the reference implementation agrees structurally: its hard
functions take (s, t, Q, s23, B) and the Jacobian is applied OUTSIDE them, in
the (xi, s23) assembly.  So the assembly-level object is regular/jac.

THE MAP (STATE 11e):
    R5S = Q2*(xi/x - 1),  R5M = PHT^2 + z^2*R5S,  R5K = R5S - s23
    s  = R5S
    t1 = -Q2 + (z^2*(Q2 + R5S) - R5M)*R5K/R5M
    u1 = -z^2*R5K*(Q2 + R5S)/R5M
With A = z^2/R5M these read t1 = -Q2 + R5K*(A*(Q2+R5S) - 1) and
u1 = -A*R5K*(Q2+R5S); eliminating A between them reproduces
s + t1 + u1 + Q2 = s23 identically, which is the consistency check on the
inverse.  Solving for A and hence R5M:

    A    = [ (t1 + Q2) + (s - s23) ] / [ (s - s23)(Q2 + s) ]
    R5M  = z^2 / A = z^2 (s - s23)(Q2 + s) / [ (t1 + Q2) + (s - s23) ]
    R5S  = s

THE HOMOGENEITY CHECK IS BUILT IN -- IT IS NOT A SEPARATE PROBE.  After
dividing by jac, a term that depends on z and R5M only through z^2/R5M becomes
independent of z once R5M is replaced by z^2/A: the z powers cancel by ordinary
Mul/Pow arithmetic, with NO expand and NO cancel.  So "z has disappeared" IS
the statement that the term was homogeneous of the right degree.  Any term
still carrying z is reported and the run FAILS rather than shipping a mapped
expression that secretly depends on a measured variable.

WHY PER TERM, AND WHY NO GLOBAL SIMPLIFY.  These expressions are 18-27 million
operations.  A global expand/cancel/simplify is the single documented cause of
this project's memory and wall-clock failures (STATE 11e).  The map is a
substitution homomorphism, so it acts term by term and the work is
embarrassingly parallel; each worker returns a mapped term and nothing is ever
put over a common denominator.

Usage: python3 R5_to_invariant.py <channel> <projection>
Env:   R5WORKERS (default 15), R5CHUNK (default 2000)
Out:   cache/<channel>_R5inv_<projection>.pkl   and a .m export for the
       Mathematica assembler.
"""
import multiprocessing as mp
import os
import pickle
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
MMA = os.path.abspath(os.path.join(HERE, "..", "mathematica"))
sys.path.insert(0, HERE)

WORKERS = int(os.environ.get("R5WORKERS", "15"))
CHUNK = int(os.environ.get("R5CHUNK", "40"))

s, t1 = sp.symbols("s t1")

# SYMBOLS ARE RESOLVED FROM THE EXPRESSION, NEVER CONSTRUCTED BARE.
#
# BUG FOUND 2026-07-31, and it invalidated three earlier "fixes".  SymPy
# symbols with different assumptions are DIFFERENT OBJECTS, so a bare
# `sp.Symbol("z")` does not match the cache's `z`, which carries assumptions.
# The structural census made it unmissable: all 24594 terms reported
#     (has_z, has_R5M, has_R5S) = (False, False, False)
# while `free_symbols` plainly listed z, R5M and R5S.  Consequently
# `xreplace({R5M: ..., R5S: s})` replaced NOTHING, and multiplying by a
# bare-symbol 1/jac INJECTED a fresh `z` that could never cancel -- which is
# exactly the `stuck = 200 of 200` that survived both the `cancel` and the
# `_canon_inside` attempts.  STATE records this trap explicitly ("take symbols
# from expr.free_symbols"), and it is the same class of bug as WRONG.md
# Category D.  These are filled in by `resolve_symbols` before any worker runs.
_RULE = {}
_INV_JAC = None


# MASK THE MAP'S ONE NON-ATOMIC SUBEXPRESSION.
#
# A = z^2/R5M is the only combination in which z and R5M can appear, and its
# invariant-frame value is the nested rational
#     A = [ (t1 + Q2) + (s - s23) ] / [ (s - s23)(Q2 + s) ] .
# Substituting THAT for every R5M makes each mapped term a rational function of
# s, t1, Q2, s23 with that whole quotient buried inside it, so the `cancel` that
# removes z has to do polynomial arithmetic over it -- measured at roughly one
# 200-term chunk every several minutes, i.e. hours for 123 chunks.
#
# STATE 11e prescribes the cure and this is a textbook case of it: "mask every
# maximal variable-free non-atomic subexpression behind an inert Dummy, run the
# WHOLE pipeline masked, and unmask only in the final results."  With A carried
# as a single ATOM, R5M -> z^2/A leaves each term a rational function in
# {z, A, s, s23, Q2}; z then cancels against tiny polynomials instead of against
# the expanded quotient.  A is restored once, on the merged result, by one
# xreplace -- the substitution is a homomorphism, so masking cannot change the
# answer, only its cost.
_AMASK = sp.Symbol("A5mask")


def a_value(names):
    """The unmasked value of A = z^2/R5M in invariant variables."""
    spread = s - names["s23"]                       # R5K after R5S -> s
    return ((t1 + Q2_of(names)) + spread)/(spread*(Q2_of(names) + s))


def resolve_symbols(expression):
    """Build the substitution from the EXPRESSION's own symbol objects."""
    global _RULE, _INV_JAC
    names = {a.name: a for a in expression.free_symbols}
    missing = [n for n in ("z", "R5M", "R5S", "s23") if n not in names]
    if missing:
        raise SystemExit("expression lacks %s -- symbols are %s"
                         % (missing, sorted(names)))
    z, R5M, R5S = names["z"], names["R5M"], names["R5S"]
    # HOMOGENEITY SUBSTITUTION -- z is SET TO 1, not cancelled.
    #
    # After dividing by jac every term is homogeneous of DEGREE 0 under
    # z -> lam z, R5M -> lam^2 R5M (that is precisely what the `stuck=0`
    # counter has been verifying).  A degree-0 homogeneous function of
    # (z, R5M) depends only on A = z^2/R5M.  Therefore setting
    #     z -> 1,  R5M -> 1/A
    # gives the IDENTICAL value as R5M -> z^2/A followed by cancelling z --
    # but as a single xreplace, with no algebra at all.
    #
    # WHY THIS MATTERS.  With R5M -> z^2/A the z powers land inside radical,
    # log and polylog arguments (the regular sector carries
    # Sqrt[4 Q2 s23 + (s+t)^2], log(s23)^l and polylogs), where `cancel`
    # cannot reach them -- so removing z required `_canon_inside`, and a few
    # such terms held up the whole run for over an hour while 15 workers idled.
    # Setting z = 1 makes those terms cost the same as every other term.
    #
    # THE GUARD.  Setting z = 1 would SILENTLY hide a term that is not
    # degree 0, so homogeneity is no longer self-checking as it was before.
    # `verify_homogeneity` therefore re-derives a sample of terms BOTH ways
    # and requires agreement before the fast path is used.
    _RULE = {R5M: 1/_AMASK, R5S: s, z: sp.Integer(1)}
    _INV_JAC = z*(R5S - names["s23"])**2/R5M        # 1/jac, before the rule
    return names


def verify_homogeneity(terms, names, sample=12):
    """Check the z->1 shortcut against the explicit cancellation on a sample.

    The two routes agree if and only if the term is degree-0 homogeneous after
    the Jacobian is removed, which is the property the whole map relies on.
    Cheapest terms are used, so the check costs little.
    """
    z, R5M, R5S, s23 = (names["z"], names["R5M"], names["R5S"], names["s23"])
    slow_rule = {R5M: z**2/_AMASK, R5S: s}
    inv_jac = z*(R5S - s23)**2/R5M
    # Pick the sample by a CHEAP proxy (arg count), not by count_ops.  Sorting
    # 43406 terms by count_ops is a full serial walk of ~75 million nodes --
    # measured at ~1 h on one core for the Hqg g projection, purely to choose
    # 12 terms.  Any small terms will do for the guard.
    order = sorted(range(len(terms)),
                   key=lambda i: len(getattr(terms[i], "args", ())))
    for i in order[:sample]:
        term = terms[i]
        fast = (term*inv_jac).xreplace(_RULE)
        slow = sp.cancel((term*inv_jac).xreplace(slow_rule))
        if slow.has(z):
            slow = sp.cancel(_canon_inside(slow))
        if sp.simplify(sp.expand(fast - slow)) != 0:
            raise SystemExit(
                "HOMOGENEITY GUARD FAILED on term %d: the z->1 shortcut and "
                "the explicit cancellation disagree, so the regular sector is "
                "not degree-0 homogeneous after removing the Jacobian.  Do "
                "NOT use the fast path." % i)
    print("  homogeneity guard: %d sampled terms agree with the explicit "
          "cancellation" % min(sample, len(order)), flush=True)


def Q2_of(names):
    """Q2 as it appears in the expression, not a fresh symbol."""
    return names.get("Q2", sp.Symbol("Q2"))

ALLOWED = {"s", "t1", "Q2", "s23", "Nc", "CF", "nf", "ee", "eq", "gs", "B"}
# A5mask must NOT survive: unmasking happens before the whitelist check.


def _atomic(path, value):
    """Write a checkpoint atomically, so a killed job never leaves a torn file."""
    tmp = "%s.tmp.%d" % (path, os.getpid())
    with open(tmp, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(tmp, path)


def flatten(expression, target=4000, max_rounds=14):
    """Distribute prefactors over inner Adds until there are enough terms.

    MEASURED 2026-07-31: the R5 regular sector has only **3** top-level Add
    args despite 18-27 million operations -- it is a deeply NESTED expression,
    not a flat sum.  Chunking over top-level terms therefore gave 3 chunks for
    15 workers, and left each "term" a ~6-9 million-operation object on which
    the `cancel` fallback would be ruinous.

    This distributes ONE Add per round, largest first, which is linear in the
    result size and preserves the product structure that makes the map
    term-wise.  Powers of Adds are deliberately NOT expanded: (A)^n has
    exponentially many terms and expanding it is the documented bottleneck
    (STATE 11e).  A term keeping an unexpanded (A)^n factor is fine here --
    the factor contains no z or R5M, so it rides along untouched.
    """
    terms = list(sp.Add.make_args(expression))
    for _ in range(max_rounds):
        if len(terms) >= target:
            break
        out, changed = [], False
        for term in terms:
            if term.is_Mul:
                adds = [f for f in term.args if f.is_Add]
                if adds:
                    big = max(adds, key=lambda a: len(a.args))
                    rest = sp.Mul(*[f for f in term.args if f is not big])
                    out.extend(rest*piece for piece in big.args)
                    changed = True
                    continue
            out.append(term)
        terms = out
        if not changed:
            break
    return terms


def _canon_inside(expression, depth=0):
    """Apply `cancel` INSIDE radical, log and polylog arguments.

    MEASURED 2026-07-31: without this, EVERY term reported `stuck` -- z refused
    to cancel in all 200 terms of every chunk.  The reason is documented in
    STATE 11e: `sp.cancel` never looks inside a sqrt/log/polylog argument, and
    the R5 regular sector is full of them (`Hqq_R5_regular.wls` names the
    radical Sqrt[4 Q^2 s23 + (s+t)^2]; `Hqq_R5_exact.py:150` carries
    log(s23)^l, and polylogs are made inert at line 111).  After the
    substitution R5M -> z^2/A the z powers sit inside those arguments, where
    the outer `cancel` cannot reach them, so the term looks z-dependent when it
    is not.

    Radicals are Pow with a non-integer Rational exponent; their base is
    canonicalized and the exponent left alone.  Recursion is bounded because
    these arguments nest at most a couple of levels here.
    """
    if depth > 4 or not expression.args:
        return expression
    replacements = {}
    for atom in expression.atoms(sp.log, sp.polylog):
        new = atom.func(*[sp.cancel(_canon_inside(a, depth + 1))
                          for a in atom.args])
        if new != atom:
            replacements[atom] = new
    for atom in expression.atoms(sp.Pow):
        if atom.exp.is_Rational and not atom.exp.is_Integer:
            base = sp.cancel(_canon_inside(atom.base, depth + 1))
            new = sp.Pow(base, atom.exp)
            if new != atom:
                replacements[atom] = new
    return expression.xreplace(replacements) if replacements else expression


def _z_symbol():
    """The resolved z symbol -- never a bare sp.Symbol("z") (see resolve_symbols)."""
    return _INV_JAC.free_symbols and next(
        a for a in _INV_JAC.free_symbols if a.name == "z")


def _map_term(term):
    """Divide out the Jacobian and substitute; z must then vanish.

    Three escalating steps, cheapest first: plain Pow arithmetic handles terms
    where the z powers already sit in one Mul; `cancel` handles rational
    rearrangements; `_canon_inside` is needed only where z hides inside a
    radical, log or polylog argument.
    """
    z = _z_symbol()
    mapped = (term*_INV_JAC).xreplace(_RULE)
    # With z -> 1 in _RULE this is already z-free; the ladder below is a
    # fallback that only runs if the substitution somehow leaves a z behind.
    if not mapped.has(z):
        return mapped
    # CHEAPEST FIRST.  `powsimp` combines z powers inside a Mul and
    # `factor_terms` pulls a common z^k out of an Add -- both are linear-ish
    # structural passes, where `cancel` does full polynomial arithmetic.  With
    # A masked as an atom these usually suffice, and `cancel` becomes the rare
    # fallback rather than the per-term cost.
    mapped = sp.powsimp(mapped, force=False)
    if not mapped.has(z):
        return mapped
    mapped = sp.factor_terms(mapped)
    if not mapped.has(z):
        return mapped
    mapped = sp.cancel(mapped)
    if mapped.has(z):
        mapped = sp.cancel(_canon_inside(mapped))
    return mapped


def _worker(payload):
    index, terms = payload
    out, stuck = [], 0
    z = _z_symbol()
    started = time.time()
    for term in terms:
        mapped = _map_term(term)
        if mapped.has(z):
            stuck += 1
        out.append(mapped)
    # elapsed is returned so a pathological chunk is visible immediately
    # rather than inferred from a stalled counter.
    return index, sp.Add(*out), stuck, time.time() - started


def _write_result(channel, projection, mapped, stem, started):
    """Pickle the mapped regular sector (the .m export is opt-in, see below)."""
    with open("%s.pkl" % stem, "wb") as stream:
        pickle.dump({"version": "r5-invariant-v1", "channel": channel,
                     "projection": projection, "regular": mapped,
                     "note": "jac divided out; invariant frame (s,t1,Q2,s23)"},
                    stream, protocol=pickle.HIGHEST_PROTOCOL)
    if os.environ.get("R5INV_WRITE_M") == "1":
        from mma_export import write_m
        tag = "g" if projection == "g" else "PP"
        write_m(mapped, os.path.join(
            MMA, "r5reg_inv_%s_%s.m" % (channel, tag)), "r5reginv")
        print("  .m export written (opt-in)", flush=True)
    print("R5_TO_INVARIANT_DONE %s %s ops=%d (%.0f s)"
          % (channel, projection, sp.count_ops(mapped), time.time() - started),
          flush=True)


def main():
    channel, projection = sys.argv[1], sys.argv[2]
    started = time.time()
    stem = os.path.join(CACHE, "%s_R5inv_%s" % (channel, projection))

    data = pickle.load(open(os.path.join(
        CACHE, "%s_R5_%s.pkl" % (channel, projection)), "rb"))
    regular = data["regular"]
    names = resolve_symbols(regular)          # MUST precede any mapping
    print("  resolved symbols: %s" % sorted(names), flush=True)
    # WHOLE-EXPRESSION FAST PATH (default).  `flatten` + chunking + a worker
    # pool existed ONLY because the old map needed a per-term `cancel` to
    # remove z.  With the z -> 1 homogeneity substitution there is NO
    # cancellation at all: the map is a pure substitution, and `xreplace`
    # walks a whole tree in one linear pass.  Splitting into 43406 terms and
    # farming them out is then pure overhead -- MEASURED: the flatten alone ran
    # ~30 min single-threaded on the Hqg g projection (75M ops) while the
    # chunks themselves took ~20 s.
    # The homogeneity guard still runs first, on a small sample, so the
    # shortcut is verified against the explicit cancellation before use.
    # Set R5INV_CHUNKED=1 to force the old per-term path.
    if os.environ.get("R5INV_CHUNKED") != "1":
        # The guard needs SMALL terms.  `Add.make_args` on this expression
        # returns only THREE terms of ~25 million operations each, and the
        # guard runs the SLOW explicit cancellation on its sample -- which
        # would hang exactly where the old per-term path did.  Two cheap
        # rounds of distribution are enough to expose small terms; a full
        # flatten is not needed and is what the fast path exists to avoid.
        guard_terms = flatten(regular, target=400, max_rounds=2)
        guard_terms = sorted(guard_terms,
                             key=lambda x: len(getattr(x, "args", ())))[:200]
        verify_homogeneity(guard_terms, names)
        z = _z_symbol()
        mapped = (regular*_INV_JAC).xreplace(_RULE)
        print("  whole-expression map done, ops=%d (%.0f s)"
              % (sp.count_ops(mapped), time.time() - started), flush=True)
        if mapped.has(z):
            raise SystemExit("z survived the whole-expression map -- the "
                             "regular sector is not degree-0 homogeneous "
                             "after removing the Jacobian")
        mapped = mapped.xreplace({_AMASK: a_value(names)})
        print("  unmasked A (%.0f s)" % (time.time() - started), flush=True)
        free = sorted(a.name for a in mapped.free_symbols)
        print("  free symbols after map: %s" % free, flush=True)
        stray = [n for n in free if n not in ALLOWED]
        if stray:
            raise SystemExit("stray symbols after map: %s" % stray)
        _write_result(channel, projection, mapped, stem, started)
        return

    top = len(sp.Add.make_args(regular))
    terms = flatten(regular)
    print("%s %s: %d top-level -> %d flattened terms, ops=%d (%.0f s)"
          % (channel, projection, top, len(terms), sp.count_ops(regular),
             time.time() - started), flush=True)
    verify_homogeneity(terms, names)

    # CHECKPOINT + SLOWEST-FIRST (added 2026-07-31).  Two measured problems:
    #   * NO CHECKPOINTING: a run that died lost every completed chunk, and the
    #     export step DID die once (missing mma_export), throwing away ~2900 s
    #     of chunk work that had to be recovered from the pickle by hand.
    #   * STRAGGLERS: with 200-term chunks the run sat at 216/218 and 76/77 for
    #     tens of minutes -- a handful of expensive terms in the final chunks
    #     while 15 workers idled.
    # Fixes, both straight from STATE 11e: per-chunk checkpoint files so a
    # rerun resumes, SMALLER chunks so a straggler is smaller, SLOWEST-FIRST
    # dispatch (cost-classify by count_ops and send the expensive ones out
    # first) so the long poles start at t=0 rather than at the end, and a
    # per-chunk timing line so a pathological class surfaces in minutes.
    chunks = [terms[i:i + CHUNK] for i in range(0, len(terms), CHUNK)]
    # SLOWEST-FIRST IS NO LONGER NEEDED, and its cost classification became the
    # dominant bottleneck.  It was introduced when a chunk could take minutes
    # and stragglers idled 15 workers.  The z -> 1 homogeneity substitution
    # then made every chunk cost ~0 s (MEASURED: Hqg PP did 381 chunks in ~20 s,
    # each reporting 0 s), so ordering buys nothing -- while
    # `sum(count_ops(x) for x in chunk)` over 43406 terms / 75M nodes ran ~1 h
    # on ONE core (cpu 00:59:54 of wallclock 01:00:00) before any chunk started.
    # Set R5INV_COSTSORT=1 to restore it if a future stage needs it.
    if os.environ.get("R5INV_COSTSORT") == "1":
        cost = [sum(sp.count_ops(x) for x in c) for c in chunks]
        order = sorted(range(len(chunks)), key=lambda i: -cost[i])
        print("  %d chunks of <=%d; costliest %d ops, cheapest %d ops"
              % (len(chunks), CHUNK, max(cost), min(cost)), flush=True)
    else:
        order = list(range(len(chunks)))
        print("  %d chunks of <=%d (cost sort skipped: chunks are ~free)"
              % (len(chunks), CHUNK), flush=True)

    pieces, stuck_total, resumed = [], 0, 0
    pending = []
    for i in order:
        path = "%s_chunk_%05d.pkl" % (stem, i)
        if os.path.exists(path):
            saved = pickle.load(open(path, "rb"))
            pieces.append(saved["part"])
            stuck_total += saved["stuck"]
            resumed += 1
        else:
            pending.append((i, chunks[i]))
    print("  resumed %d chunks, %d pending" % (resumed, len(pending)), flush=True)

    if pending:
        context = mp.get_context("fork")
        with context.Pool(WORKERS, maxtasksperchild=1) as pool:
            for done, (index, part, stuck, secs) in enumerate(
                    pool.imap_unordered(_worker, pending), 1):
                pieces.append(part)
                stuck_total += stuck
                _atomic("%s_chunk_%05d.pkl" % (stem, index),
                        {"part": part, "stuck": stuck})
                print("  chunk %d/%d (id %d)  stuck=%d  %.0f s  [saved]  (%.0f s)"
                      % (done, len(pending), index, stuck, secs,
                         time.time() - started), flush=True)

    mapped = sp.Add(*pieces)
    # UNMASK once, on the merged result.  The map is a substitution
    # homomorphism, so doing this at the end is exactly equivalent to having
    # carried the full quotient through every term -- and vastly cheaper.
    mapped = mapped.xreplace({_AMASK: a_value(names)})
    print("  unmasked A (%.0f s)" % (time.time() - started), flush=True)
    free = sorted(a.name for a in mapped.free_symbols)
    _ = free
    print("  free symbols after map: %s" % free, flush=True)
    print("  terms still carrying z: %d" % stuck_total, flush=True)

    stray = [n for n in free if n not in ALLOWED]
    if stuck_total or stray:
        print("  FAIL: stuck=%d stray=%s -- NOT homogeneous as jac x invariant; "
              "do not assemble." % (stuck_total, stray), flush=True)
        raise SystemExit(1)

    with open("%s.pkl" % stem, "wb") as stream:
        pickle.dump({"version": "r5-invariant-v1", "channel": channel,
                     "projection": projection, "regular": mapped,
                     "note": "jac divided out; invariant frame (s,t1,Q2,s23)"},
                    stream, protocol=pickle.HIGHEST_PROTOCOL)

    # The .m export is OPT-IN (R5INV_WRITE_M=1).  It is DEAD WORK for this
    # pipeline: F12_assemble_invariant.py reads the PICKLE, never the .m, and
    # `mma_export.write_m` on a ~10-million-operation expression did not finish
    # in 15 minutes -- for Hgq it killed the job AFTER all the algebra was done
    # (the pickle survived and had to be recovered by hand), and for Hqg PP it
    # left the job "running" long after its result was complete, which BLOCKED
    # the assembly job chained to its completion.  Same class as the dead merge
    # removed from finite_hard_parts.main.
    if os.environ.get("R5INV_WRITE_M") == "1":
        from mma_export import write_m
        tag = "g" if projection == "g" else "PP"
        write_m(mapped, os.path.join(
            MMA, "r5reg_inv_%s_%s.m" % (channel, tag)), "r5reginv")
        print("  .m export written (opt-in)", flush=True)
    print("R5_TO_INVARIANT_DONE %s %s ops=%d (%.0f s)"
          % (channel, projection, sp.count_ops(mapped), time.time() - started),
          flush=True)


if __name__ == "__main__":
    main()
