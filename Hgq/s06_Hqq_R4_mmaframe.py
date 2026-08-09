# Hqq_R4_mmaframe.py -- Step R4 (WS10 sub-step): KNOWN-ANSWER FRAME.
#
# The production Python engine (Hqq_R4_fastlaurent.residue_fast) takes the
# endpoint residue of jac*to_map(H) in the (xi, s23) integration frame.
# The accepted Mathematica artifact
#   mathematica/r4out2_MR2PPQGG_groupfixv3merged.m
# instead expands in the INVARIANT frame of Hqq_R4_mma_part2.wls,
#   prepRaw[t] = t /. u1 -> s23 - s - t1 - Q2 /. s23 -> W^2 ,
# with no Jacobian and with s, t1, Q2 held fixed, and keys every endpoint
# class exactly as
#   Residue: Class[c,l]     coefficient of W^(-2+c eps) Log[s23]^l ,
#   Deep:    Class[c,k,l]   even k < -2,
#   Odd:     Class[c,k,l]   odd  k < 0 .
# This module runs the SAME Python series engine in that same invariant
# frame, so the two calculations become directly comparable class by
# class.  It is the known-answer test that licenses the Python engine; it
# is not itself a production output.
#
# Everything here is exact: no floating point, no random sampling, no
# decimal expansion of irrational constants (pi, radicals and polylogs
# stay symbolic).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp
from Hqq_R4_fastlaurent import (_expr_laurent, _w, LW, abs_free, unmask,
                                _num_zero, INV)


def to_invariant_frame(term):
    """Exact frame map of one raw R3 angular term:
        u1 -> s23 - s - t1 - Q2 ,   s23 -> W^2 ,
    the Abs having been removed beforehand by the exact physical-region
    identity Abs((Q2+s+u1)/2) = (s23-t1)/2 of `abs_free`."""
    S, T1, U1, QQ, S23 = INV
    out = term.xreplace({U1: S23 - S - T1 - QQ})
    return out.xreplace({S23: _w**2})


def _split_mixed(term):
    """Exact distributive split for a term containing an Add whose summands
    belong to DIFFERENT eps-exponent classes (some carry an extra
    s23^(-eps), some do not).  Such an Add has no single class
    W^(V + c eps), so it must be distributed until every resulting product
    has one.  `expand` is an exact identity, so nothing is approximated;
    it is applied only on this exception path."""
    parts = sp.Add.make_args(sp.expand(term))
    if len(parts) < 2:
        raise ValueError("mixed eps-exponent classes and not splittable: %s"
                         % str(term)[:160])
    return parts


def _accumulate_mapped(G, term, out):
    """Accumulate an already mapped term, splitting only a mixed Add.

    The former exception path expanded the complete raw product.  A typical
    hot Hgq term has fifteen harmless common factors and one Add whose
    summands carry different eps-exponent classes; global expansion throws
    away that useful factorization and makes the later Poly construction
    enormous.  Distributing just that Add is the same exact algebraic
    identity while retaining every common factor.
    """
    try:
        _accumulate(G, term, out)
        return
    except ValueError as e:
        if 'Add mixes eps-exponent classes' not in str(e):
            raise

    # A mapped term is normally a Mul with one mixed Add factor.  Remove
    # that factor by position (not by division/cancellation), then recurse
    # over its exact summands.
    factors = list(sp.Mul.make_args(G))
    for pos, factor in enumerate(factors):
        if not factor.is_Add:
            continue
        try:
            _expr_laurent(factor, 1)
        except ValueError as e:
            if 'Add mixes eps-exponent classes' not in str(e):
                raise
            common = sp.Mul(*(factors[:pos] + factors[pos + 1:]))
            for summand in sp.Add.make_args(factor):
                _accumulate_mapped(common*summand, term, out)
            return

    # Rare top-level Add case.  It cannot normally enter here because H is
    # split into Add terms first, but retaining this exact path makes the
    # helper safe for mapped substitutions that expose an addition.
    if G.is_Add:
        for summand in sp.Add.make_args(G):
            _accumulate_mapped(summand, term, out)
        return

    # Preserve a diagnostic fallback for an unforeseen nested expression;
    # production hot terms should never reach it.
    raise ValueError("mixed eps-exponent classes not localized: %s"
                     % str(term)[:160])


def residue_mma(H):
    """Endpoint classes of H in the invariant frame.

    Returns {('Residue', c, l): expr, ('Deep', c, k, l): expr,
             ('Odd', c, k, l): expr}, where a term whose W-exponent class
    is W^{V + c*eps} contributes its coefficient of W^k for every k < -1
    (k = -2 is the residue proper), and l counts powers of Log[s23]
    (the engine's inert LW = Log[W] = Log[s23]/2, so the l=1 coefficient
    carries the factor 1/2, exactly as splitLW does in the .wls)."""
    out = {}
    for term0 in sp.Add.make_args(H):
        term = abs_free(term0)
        G = to_invariant_frame(term)
        _accumulate_mapped(G, term, out)
    return {k: unmask(v) for k, v in out.items()}


def _accumulate(G, term, out):
    """Add one frame-mapped term's endpoint classes into `out`."""
    for _once in (0,):
        V0 = 0
        facs = []
        for f in sp.Mul.make_args(G):
            b, e = f.as_base_exp()
            if b == _w and e.is_Integer:
                V0 += int(e)
            else:
                facs.append(f)
        data = [_expr_laurent(f, 1) for f in facs]
        V = V0 + sum(d[0] for d in data)
        if V >= -1:
            continue
        need = -V - 1
        data = [_expr_laurent(f, need) for f in facs]
        V = V0 + sum(d[0] for d in data)
        AW = sum((d[1] for d in data), sp.Rational(0))
        if V >= -1:
            continue
        cs = [sp.Integer(1)] + [sp.Integer(0)]*(need - 1)
        for _, _, c in data:
            new = [sp.Integer(0)]*need
            for i in range(need):
                if cs[i] == 0:
                    continue
                for jx in range(need - i):
                    if c[jx] != 0:
                        new[i + jx] += cs[i]*c[jx]
            cs = new
        for k in range(V, min(0, V + need)):
            idx = k - V
            if idx < 0 or idx >= need or cs[idx] == 0:
                continue
            coeff = cs[idx]
            if coeff.has(LW):
                c1 = sp.diff(coeff, LW).xreplace({LW: sp.S(0)})
                d2 = sp.diff(coeff, LW, 2)
                if d2 != 0 and not _num_zero(d2):
                    raise ValueError("ln^2(s23) endpoint class: %s"
                                     % str(term)[:120])
            else:
                c1 = sp.Integer(0)
            c0 = coeff.xreplace({LW: sp.S(0)})
            if k == -2:
                keys = [(('Residue', AW, 0), c0), (('Residue', AW, 1), c1/2)]
            elif k % 2 == 0:
                keys = [(('Deep', AW, k, 0), c0), (('Deep', AW, k, 1), c1/2)]
            else:
                keys = [(('Odd', AW, k, 0), c0), (('Odd', AW, k, 1), c1/2)]
            for key, val in keys:
                if val != 0:
                    out[key] = out.get(key, sp.Integer(0)) + val
