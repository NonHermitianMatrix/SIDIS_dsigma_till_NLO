# Hqq_R4_kinmap.py -- Step R4 (WS10 sub-step): the kinematic map that takes
# the angular-integrated hard parts H(s, t1, u1, s23, Q2; eps) to the
# (xi, s23) integration variables at fixed external (x, z, Q2, PHT).
# All equations VERBATIM from the project reference (AI.md sections 4 and 6):
#   xh = x/xi,  zh = z/zeta,  k1T = PHT/zeta,
#   s  = Q2 (1/xh - 1),
#   u1 = -zh Q2/xh,
#   t1 = -Q2 + zh (Q2 - k1T^2/zh^2),
#   zeta(s23) = (xh PHT^2 + z^2 Q2 (1-xh)) / (z (Q2 (1-xh) - s23 xh)),
#   Jacobian:  Int dxi dzeta ... = Int_A^1 dxi Int_0^B ds23 J ...,
#   J = (xh^2 PHT^2 + xh z^2 Q2 (1-xh)) / (z (Q2 (1-xh) - s23 xh)^2),
#   A = x + x PHT^2/(z (1-z) Q2),
#   B = Q2 (1/xh - 1)(1-z) - PHT^2/z .
# Check 4: s + t1 + u1 + Q2 - s23 = 0 identically under the map.
import sympy as sp

x, z, Q2, PHT, xi, s23 = sp.symbols('x z Q2 PHT xi s23', positive=True)

xh = x/xi
zeta = (xh*PHT**2 + z**2*Q2*(1 - xh))/(z*(Q2*(1 - xh) - s23*xh))
zh = z/zeta
k1T = PHT/zeta

s_of = Q2*(1/xh - 1)
u1_of = -zh*Q2/xh
t1_of = -Q2 + zh*(Q2 - k1T**2/zh**2)

jac = (xh**2*PHT**2 + xh*z**2*Q2*(1 - xh))/(z*(Q2*(1 - xh) - s23*xh)**2)
A_lo = x + x*PHT**2/(z*(1 - z)*Q2)
B_up = Q2*(1/xh - 1)*(1 - z) - PHT**2/z

SUBS = {'s': s_of, 't1': t1_of, 'u1': u1_of}


def to_xi_s23(expr):
    """Substitute (s, t1, u1) [by NAME] by their (xi, s23) expressions."""
    rep = {}
    for sym in expr.free_symbols:
        if sym.name in SUBS:
            rep[sym] = SUBS[sym.name]
        elif sym.name == 'Q2':
            rep[sym] = Q2
        elif sym.name == 's23':
            rep[sym] = s23
    return expr.subs(rep)


if __name__ == '__main__':
    # check 4: momentum conservation identity under the map -> must be 0
    ident = sp.simplify(s_of + t1_of + u1_of + Q2 - s23)
    print("check 4:  s + t1 + u1 + Q2 - s23 =", ident,
          " ->", "OK" if ident == 0 else "FAIL", flush=True)
    # s23 -> 0 recovers the LO (2->2) relations: zeta0, and B at threshold
    zeta0 = sp.simplify(zeta.subs(s23, 0))
    print("zeta(s23=0) =", zeta0, flush=True)
    # B > 0 on a physical point; A < 1 (phase space open)
    pt = {x: sp.Rational(1, 10), z: sp.Rational(3, 10), Q2: 4, PHT: sp.Rational(9, 10),
          xi: sp.Rational(1, 2)}
    print("A =", float(A_lo.subs(pt)), " B =", float(B_up.subs(pt)),
          " jac =", float(jac.subs(pt).subs(s23, sp.Rational(1, 10))), flush=True)
    # zeta stays in (z, 1) over 0 < s23 < B at the physical point
    import numpy as np
    okz = True
    for f in np.linspace(0.01, 0.99, 7):
        s23v = f*float(B_up.subs(pt))
        zv = float(zeta.subs(pt).subs(s23, s23v))
        okz &= (float(pt[z]) < zv < 1.0)
    print("zeta in (z,1) over s23 in (0,B):", "OK" if okz else "FAIL",
          flush=True)
