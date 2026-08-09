"""Hqq (channel 2) REBUILD -- step R2: partial-fraction to canonical form.

NEW rebuild code.  Consumes ONLY python/generated/Hqq2_R1_*.py; never the
quarantined old chain (python/cache/OLD_Hqq_20260801_SUPERSEDED/).

GOAL (reference section 6).  The angular integration of step R3 uses the
universal master

    I(j,l) = Int dbeta1 dbeta2 sin^{1-2eps}b1 sin^{-2eps}b2
             / ((a + b cos b1)^j (A + B cos b1 + C sin b1 cos b2)^l)

which exists only when a term carries AT MOST TWO distinct angle-dependent
invariants in its denominator.  R2 rewrites every term into that form.

CLASSIFICATION (reference section 6, verbatim):
    AIMV (angle-INdependent) = {t1, u1, s, s23}
    ADMV (angle-dependent)   = {t2, t3, u2, u3, s12, s13}
each ADMV being linear in cos(beta1) and sin(beta1) cos(beta2).

THE RELATIONS (reference section 6, from p + q - k1 = k2 + k3):
    2ARs : t1 = u2 + u3 + s23
           u1 = t2 + t3 + s23 + Q2
           s  = s12 + s13 + s23
    3AR  : s13 = s + t2 + u2 + Q2

THE ALGORITHM, as two splitting rules:
 (i)  TWO SAME-TYPE ADMVs in one denominator.  Multiply by 1 written with the
      matching 2AR and split.  For the t-type pair, u1 = t2 + t3 + s23 + Q2
      gives t2 + t3 = u1 - s23 - Q2, hence

          1/(t2 t3) = (t2 + t3)/((u1 - s23 - Q2) t2 t3)
                    = [ 1/t3 + 1/t2 ] / (u1 - s23 - Q2)

      and identically for u-type (u2 + u3 = t1 - s23) and s-type
      (s12 + s13 = s - s23).
 (ii) THREE DIFFERENT-TYPE ADMVs in one denominator.  From
      s13 = s + t2 + u2 + Q2, i.e. s13 - t2 - u2 = s + Q2,

          1/(s13 t2 u2) = (s13 - t2 - u2)/((s + Q2) s13 t2 u2)
                        = [ 1/(t2 u2) - 1/(s13 u2) - 1/(s13 t2) ] / (s + Q2)

RULE (iii) OF THE REFERENCE -- NUMERATORS -- IS **NOT** IMPLEMENTED HERE, and
this file does not pretend otherwise.  Rewriting a numerator ADMV requires a
basis, and the right basis is "the <= 2 ADMVs in THIS term's denominator plus
the AIMVs" -- which is fixed by the master I(j,l) that R3 will actually look
up, not by R2.  Doing it blind here (e.g. via AR_SUB) would rewrite numerators
onto the WRONG basis: a term whose denominator carries t3 needs its numerator
in terms of t3, while AR_SUB eliminates t3 in favour of t2.  So R2 reports how
many output terms still carry a numerator ADMV (`node_has_num_admv`) and leaves
the rewriting to R3.

EXACTNESS AND THE CONSTRAINT SURFACE.  Every rule is multiplication by 1
followed by a split, so each rewrite is an identity -- but ONLY ON THE
CONSTRAINT SURFACE, because the ARs are RELATIONS, not definitions.  The
eleven invariants are over-complete: momentum conservation leaves six
independent, {s, s23, t1, t2, u2, Q2}.  sympy treats the symbols as
independent and will report a nonzero difference for a perfectly correct
rewrite, so every zero test MUST project through AR_SUB first.  The first
version of this file failed its own self-test for exactly this reason (8 of 9
cases produced the correct canonical form but "failed" exactness).
THIS GENERALISES TO R3 AND R4: any identity in these invariants holds only
modulo the ARs.

PERFORMANCE (reference section 11e) -- WHY THE HOT LOOP TOUCHES NO SYMPY
NORMALISATION.  The first version called together + fraction + factor_list on
EVERY intermediate term at EVERY pass, and sp.cancel on every child.  Since a
single input term can split into many children, and each child was re-parsed
from scratch, the normalisation cost dominated everything.

  FIX: parse each input term ONCE into the structured triple

      (num, rest, dfac)   representing   num / (rest * prod_a a**dfac[a])

  where `rest` collects every non-ADMV denominator factor.  Both splitting
  rules are then pure BOOKKEEPING on `dfac`: a split decrements one exponent
  and multiplies `rest` by an AIMV polynomial.  No together, no factor_list,
  no cancel inside the loop -- those run once on input and once on output.
  Termination is manifest: every split lowers sum(dfac.values()) by one.
"""
import sys
import os
import sympy as sp

# ---- symbols -------------------------------------------------------------
s, s23, t1, u1, Q2 = sp.symbols('s s23 t1 u1 Q2')
t2, t3, u2, u3, s12, s13 = sp.symbols('t2 t3 u2 u3 s12 s13')

AIMV = {s, s23, t1, u1, Q2}
ADMV = {t2, t3, u2, u3, s12, s13}

# same-type pair -> the AIMV value of (a + b), from the matching 2AR
SAME_TYPE = [
    ((t2, t3), u1 - s23 - Q2),
    ((u2, u3), t1 - s23),
    ((s12, s13), s - s23),
]

# the 3AR: s13 - t2 - u2 = s + Q2
THREE_AR = (((s13, sp.Integer(1)), (t2, sp.Integer(-1)), (u2, sp.Integer(-1))),
            s + Q2)

# THE CONSTRAINT SURFACE.  Independent set {s, s23, t1, t2, u2, Q2}; derived
# from the section-6 relations plus s + t1 + u1 + Q2 - s23 = 0.  This is the
# same substitution the R1 Ward checks use.
AR_SUB = {
    u1: s23 - s - t1 - Q2,
    t3: (s23 - s - t1 - Q2) - t2 - s23 - Q2,
    u3: t1 - u2 - s23,
    s13: s + t2 + u2 + Q2,
    s12: s - s23 - (s + t2 + u2 + Q2),
}


def on_shell(expr):
    """Project onto the constraint surface -- required before ANY zero test."""
    return sp.together(sp.expand(sp.sympify(expr).subs(AR_SUB)))


# ---- structured term representation --------------------------------------
def parse_term(term):
    """term -> (num, rest, dfac).  Called ONCE per input term."""
    num, den = sp.fraction(sp.together(term))
    coeff, facs = sp.factor_list(den)
    rest = coeff
    dfac = {}
    for base, exp in facs:
        if base in ADMV:
            dfac[base] = dfac.get(base, 0) + exp
        else:
            rest = rest * base ** exp
    return num, rest, dfac


def build_term(num, rest, dfac):
    den = rest
    for a, e in dfac.items():
        if e:
            den = den * a ** e
    return num / den


def _split(node):
    """One splitting rule applied to (num, rest, dfac); None if canonical.

    Pure bookkeeping: decrement an exponent, multiply rest by an AIMV value.
    """
    num, rest, dfac = node
    live = {a: e for a, e in dfac.items() if e > 0}
    # rule (i): a same-type pair
    for (a, b), val in SAME_TYPE:
        if live.get(a, 0) >= 1 and live.get(b, 0) >= 1:
            out = []
            for drop in (a, b):
                nd = dict(dfac)
                nd[drop] = nd[drop] - 1
                out.append((num, rest * val, nd))
            return out
    # rule (ii): the three-different-type triple
    triple, val = THREE_AR
    if all(live.get(x, 0) >= 1 for x, _ in triple):
        out = []
        for x, c in triple:
            nd = dict(dfac)
            nd[x] = nd[x] - 1
            out.append((num * c, rest * val, nd))
        return out
    return None


def reduce_term(term, max_nodes=200000):
    """Reduce ONE input term to at-most-two distinct ADMVs per denominator."""
    work = [parse_term(term)]
    out = []
    seen = 0
    while work:
        seen += 1
        if seen > max_nodes:
            raise RuntimeError(f'R2 exceeded {max_nodes} nodes on one term')
        node = work.pop()
        got = _split(node)
        if got is None:
            out.append(node)          # keep the STRUCTURED form
        else:
            work.extend(got)
    return out


def node_admv(node):
    """Distinct ADMVs in a NODE's denominator -- read straight off dfac.

    The first optimisation pass fixed the reduction loop but left this
    re-parsing every output term (together + factor_list), and run_piece
    called it twice per term.  The structured form already knows the answer.
    """
    return len([a for a, e in node[2].items() if e > 0])


def node_has_num_admv(node):
    """Does this node carry an ADMV in its NUMERATOR? (rule iii -> R3)"""
    num = node[0]
    return any(num.has(a) for a in ADMV)


def partial_fraction(expr, progress=None):
    """Returns STRUCTURED nodes (num, rest, dfac).  Use assemble() for exprs."""
    terms = list(expr.args) if expr.func is sp.Add else [expr]
    out = []
    for i, t in enumerate(terms):
        out.extend(reduce_term(t))
        if progress and (i + 1) % progress == 0:
            print(f'    R2 {i+1}/{len(terms)} in, {len(out)} out', flush=True)
    return out


def assemble(nodes):
    return [build_term(*n) for n in nodes]


# ---- self-test -----------------------------------------------------------
def selftest():
    chk4 = sp.simplify(on_shell(s + t1 + u1 + Q2 - s23))
    print(f'  [{"OK " if chk4 == 0 else "FAIL"}] check 4: '
          f's+t1+u1+Q2-s23 on the surface = {chk4}')
    ok = (chk4 == 0)
    cases = {
        'same-type t2 t3': 1 / (t2 * t3),
        'same-type u2 u3': 1 / (u2 * u3),
        'same-type s12 s13': 1 / (s12 * s13),
        'three-type s13 t2 u2': 1 / (s13 * t2 * u2),
        'with numerator': (t3 + 2 * s) / (t2 * t3 * u2),
        'higher power': 1 / (t2 ** 2 * t3),
        'already canonical': 1 / (t2 * u2),
        'mixed sum': 1 / (t2 * t3) + 1 / (s13 * t2 * u2),
        'AIMV factors kept': s23 / (s * t2 * t3 * (Q2 + s)),
        'all six ADMVs': 1 / (t2 * t3 * u2 * u3 * s12 * s13),
        'deep powers': 1 / (t2 ** 3 * t3 ** 2 * u2 * u3),
    }
    for name, expr in cases.items():
        red = partial_fraction(expr)
        # cancel, not simplify: these are RATIONAL functions once projected
        diff = sp.cancel(on_shell(sp.Add(*assemble(red))) - on_shell(expr))
        exact = (diff == 0)
        worst = max((node_admv(n) for n in red), default=0)
        good = exact and worst <= 2
        print(f'  [{"OK " if good else "FAIL"}] {name:<24} '
              f'terms={len(red):<4} maxADMV={worst}  exact={exact}')
        ok = ok and good
    return ok


# ---- driver --------------------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))
GEN = os.path.join(HERE, 'generated')

PIECES = {
    'qgg': ('Hqq2_R1_qgg', ['MR2gQGG', 'MR2PPQGG']),
    'sf': ('Hqq2_R1_sameflavor', ['MR2gSF', 'MR2PPSF']),
    'df': ('Hqq2_R1_pairs', None),   # names discovered from the module
}


def run_piece(key):
    import pickle
    import time
    mod, names = PIECES[key]
    sys.path.insert(0, GEN)
    m = __import__(mod)
    if names is None:
        names = [n for n in dir(m) if n.startswith('MR2')]
        print(f'  discovered names in {mod}: {names}', flush=True)
    for nm in names:
        raw = getattr(m, nm, None)
        if raw is None:
            print(f'  SKIP {nm} (not in {mod})', flush=True)
            continue
        t0 = time.time()
        expr = sp.sympify(raw) if isinstance(raw, str) else raw
        nin = len(expr.args) if expr.func is sp.Add else 1
        print(f'  {nm}: {nin} top-level terms, {sp.count_ops(expr)} ops '
              f'(sympify {time.time()-t0:.1f}s)', flush=True)
        t1_ = time.time()
        red = partial_fraction(expr, progress=500)
        worst = max((node_admv(n) for n in red), default=0)
        nnum = sum(1 for n in red if node_has_num_admv(n))
        print(f'  {nm}: {len(red)} terms out, maxADMV={worst}, '
              f'{nnum} with numerator ADMVs (rule iii -> R3), '
              f'{time.time()-t1_:.1f}s', flush=True)
        if worst > 2:
            raise RuntimeError(f'{nm}: R2 left {worst} ADMVs in a denominator')
        out = os.path.join(HERE, 'cache', f'Hqq2_R2_{nm}.pkl')
        with open(out, 'wb') as fh:
            pickle.dump(assemble(red), fh)
        print(f'  {nm}: wrote {out}', flush=True)


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'selftest':
        print('R2 self-test (reference section 6 algorithm):')
        good = selftest()
        print('R2_SELFTEST_' + ('PASS' if good else 'FAIL'))
        sys.exit(0 if good else 1)
    for key in (sys.argv[1:] or ['qgg', 'sf', 'df']):
        print(f'=== R2 piece {key} ===', flush=True)
        run_piece(key)
    print('HQQ2_R2_DONE')
