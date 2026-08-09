# Hqq_R4_expand.py -- Step R4 (WS10): endpoint expansion of the
# angular-integrated real-emission pieces, IN THE (xi, s23) MAP FRAME
# (fixed x, z, Q2, PHT, xi; t1 and u1 are functions of s23 through
# zeta(s23) -- Hqq_R4_kinmap, verbatim reference formulas).  The full ds23
# integrand of one piece is
#   G(s23) = jac(s23) * H(s(xi), t1(s23), u1(s23), Q2, s23)
# and with the s23^{-eps} of dPi3 the distribution identity (paper Eq.
# (B22), on [0,B]) applies:
#   s23^{-1-eps} = -(1/eps) delta(s23) B^{-eps} + [1/s23]_+
#                  - eps [ln(s23)/s23]_+ + O(eps^2),
# giving, with the endpoint residue R(xi;eps) = lim_{s23->0} s23*G,
#   Cdelta = -(1/eps) B^{-eps} R,   Cplus1 = R,   Cplus2 = -eps R,
#   regular = s23^{-eps} (G - R/s23).
import sys, os, pickle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp
from Hqq_R4_kinmap import (s_of, t1_of, u1_of, jac, B_up,
                           x, z, Q2, PHT, xi, s23)

eps = sp.Symbol('eps')


def to_map(H):
    """Replace ALL symbol variants by name with the map expressions."""
    rep = {}
    for sym in H.free_symbols:
        if sym.name == 's':
            rep[sym] = s_of
        elif sym.name == 't1':
            rep[sym] = t1_of
        elif sym.name == 'u1':
            rep[sym] = u1_of
        elif sym.name == 'Q2':
            rep[sym] = Q2
        elif sym.name == 's23':
            rep[sym] = s23
        elif sym.name == 'eps':
            rep[sym] = eps
    return H.xreplace(rep)


def residue_cancel(H):
    """Reference (SLOW, exact): R = lim s23*jac*to_map(H) via
    together/cancel per term.  Verified against the direct numeric limit of
    the mapped integrand on the A pieces."""
    R = sp.Integer(0)
    for term in sp.Add.make_args(H):
        t = sp.cancel(sp.together(jac*to_map(term)*s23))
        num, den = sp.fraction(t)
        if den.subs(s23, 0) == 0:
            raise ValueError("stronger than 1/s23 endpoint: %s" % term)
        val = t.subs(s23, 0)
        if val != 0:
            R += val
    return R


_LAU_CACHE = {}


def _poly_laurent(num, den, nord, var):
    """Laurent of num/den (polys in s23) via pure Poly arithmetic."""
    pn = sp.Poly(num, var)
    pd = sp.Poly(den, var)
    cn = pn.all_coeffs()[::-1]      # ascending
    cd = pd.all_coeffs()[::-1]
    vn = next(i for i, c in enumerate(cn) if c != 0)
    vd = next(i for i, c in enumerate(cd) if c != 0)
    an = cn[vn:vn + nord] + [sp.Integer(0)]*nord
    ad = cd[vd:vd + nord] + [sp.Integer(0)]*nord
    inv = [sp.Integer(0)]*nord      # series inverse of ad
    inv[0] = 1/ad[0]
    for k in range(1, nord):
        acc = sp.Integer(0)
        for jx in range(1, k + 1):
            if ad[jx] != 0 and inv[k - jx] != 0:
                acc += ad[jx]*inv[k - jx]
        inv[k] = -acc/ad[0]
    out = [sp.Integer(0)]*nord
    for i in range(nord):
        if an[i] == 0:
            continue
        for jx in range(nord - i):
            if inv[jx] != 0:
                out[i + jx] += an[i]*inv[jx]
    return vn - vd, [sp.cancel(c) for c in out]


def _laurent(g, nord, var=None):
    """Laurent data (v, coeffs[0..nord-1]) of g at s23=0, cached; rational
    factors via fast Poly arithmetic, others via sympy series."""
    var = var if var is not None else _w
    key = (g, nord, var)
    if key in _LAU_CACHE:
        return _LAU_CACHE[key]
    if g.is_rational_function(var):
        num, den = sp.fraction(sp.together(g))
        res = _poly_laurent(num, den, nord, var)
        _LAU_CACHE[key] = res
        return res
    ser = sp.expand(sp.series(g, var, 0, nord + 2).removeO())
    if ser == 0:
        res = (0, [sp.Integer(0)]*nord)
        _LAU_CACHE[key] = res
        return res
    v = min(int(sp.degree(t.as_independent(var, as_Add=False)[1], var))
            if t.has(var) else 0 for t in sp.Add.make_args(ser))
    p = sp.Poly(sp.expand(sp.cancel(ser/var**v)), var)
    res = (v, [p.coeff_monomial(var**k if k else 1) for k in range(nord)])
    _LAU_CACHE[key] = res
    return res


_w = sp.Symbol('_wS23', positive=True)


def residue_terms(H):
    """FAST residue R = lim s23*jac*to_map(H), computed in w = sqrt(s23)
    (E-type pieces carry half-integer s23 powers): every factor becomes
    meromorphic in w; R = total coefficient of w^{-2}.  Odd singular
    w-powers (w^{-1}, w^{-3}, ...) cannot contribute a 1/s23 pole and must
    cancel in the sum (asserted numerically)."""
    R = sp.Integer(0)
    odd = sp.Integer(0)
    for term in sp.Add.make_args(H):
        G = (jac*to_map(term)).xreplace({s23: _w**2})
        V0 = 0
        facs = []
        for f in sp.Mul.make_args(G):
            b, e = f.as_base_exp()
            if b == _w and e.is_Integer:
                V0 += int(e)
            else:
                facs.append(f)
        data = [_laurent(f, 1) for f in facs]
        V = V0 + sum(v for v, _ in data)
        if V >= -1:
            continue                  # no w^{-2} (nor deeper) => no residue
        need = -V - 1                 # coefficients needed to reach w^{-2}
        data = [_laurent(f, need) for f in facs]
        V = V0 + sum(v for v, _ in data)
        if V >= -1:
            continue
        cs = [sp.Integer(1)] + [sp.Integer(0)]*(need - 1)
        for _, c in data:
            new = [sp.Integer(0)]*need
            for i in range(need):
                if cs[i] == 0:
                    continue
                for jx in range(need - i):
                    if c[jx] != 0:
                        new[i + jx] += cs[i]*c[jx]
            cs = new
        # collect all w^k, k<=-2 must not appear below -2: assert; k=-2 -> R
        for k in range(V, min(0, V + need)):
            idx = k - V
            if idx < 0 or idx >= need or cs[idx] == 0:
                continue
            if k == -2:
                R += cs[idx]
            elif k < -1 and k % 2 == 0:
                raise ValueError("w^%d endpoint (s23^%s): %s"
                                 % (k, sp.Rational(k, 2), term))
            elif k < 0 and k % 2 == 1:
                odd += cs[idx]*_w**k        # tracked, must cancel
    if odd != 0:
        pt = {sym: 0.37 + 0.11*i for i, sym in enumerate(
            sorted(odd.free_symbols - {_w}, key=lambda x: x.name))}
        for wv in (1e-3, 1e-4):
            dv = complex(sp.N(odd.xreplace(pt).xreplace({_w: wv})))
            assert abs(dv)*wv**3 < 1e-6, \
                "uncancelled half-integer endpoint: %s at w=%s" % (dv, wv)
    return R


def expand_piece(H):
    """H = cached angular-integrated piece -> dict of the distribution
    decomposition (map frame; jac included)."""
    G = jac*to_map(H)
    R = residue_terms(H)
    return {'R': R,
            'Cdelta': -R*B_up**(-eps)/eps,
            'Cplus1': R,
            'Cplus2': -eps*R,
            'regular': s23**(-eps)*(G - R/s23)}


if __name__ == '__main__':
    import mpmath as mp
    mp.mp.dps = 15
    CONSTS = {'ee': 1.0, 'gs': 1.0, 'eq': 1.0, 'eqp': 1.0,
              'Nc': 3.0, 'CF': 4.0/3.0, 'TF': 0.5}
    PT = {x: sp.Rational(1, 10), z: sp.Rational(3, 10), Q2: 4,
          PHT: sp.Rational(9, 10), xi: sp.Rational(1, 2)}
    for nm in ['Hqq_R3_MR2gA', 'Hqq_R3_MR2PPA',
               'Hqq_R3_MR2gC_ang', 'Hqq_R3_MR2PPC_ang']:
        Hraw = pickle.load(open('cache/%s.pkl' % nm, 'rb'))
        Hraw = Hraw.xreplace({sym: sp.Float(CONSTS[sym.name])
                              for sym in Hraw.free_symbols
                              if sym.name in CONSTS})
        pieces = expand_piece(Hraw)
        R = pieces['R']
        print("%s: residue R ops %d  (R==0: %s)"
              % (nm, sp.count_ops(R), R == 0), flush=True)
        # numeric split identity at eps=-0.05, over [0, b]:
        #   Int_0^b s23^{-eps} G  ==  -R/eps b^{-eps} + Int_0^b regular
        ev = sp.Float(-0.05)
        bv = 0.5*float(B_up.subs(PT))
        Gm = (jac*to_map(Hraw)).subs(PT).xreplace({eps: ev})
        Rn = complex(sp.N(R.subs(PT).xreplace({eps: ev}))).real
        reg = pieces['regular'].subs(PT).xreplace({eps: ev})
        fG = sp.lambdify(s23, Gm, 'mpmath')
        fr = sp.lambdify(s23, reg, 'mpmath')
        lhs = mp.quad(lambda v: v**(-float(ev))*mp.re(fG(v)), [0, bv])
        rhs = -Rn/float(ev)*bv**(-float(ev)) \
            + mp.quad(lambda v: mp.re(fr(v)), [0, bv])
        rel = abs(float(lhs)/float(rhs) - 1) if rhs != 0 else abs(float(lhs))
        print("  split identity: lhs %.8e rhs %.8e rel %.2e  %s"
              % (float(lhs), float(rhs), rel,
                 'OK' if rel < 1e-6 else 'FAIL'), flush=True)
        pickle.dump(pieces, open('cache/Hqq_R4_%s.pkl'
                                 % nm.replace('Hqq_R3_', ''), 'wb'))
    print("R4 endpoint split: DONE for A and C pieces", flush=True)
