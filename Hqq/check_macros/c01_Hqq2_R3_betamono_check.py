#!/usr/bin/env python3
"""Symbolic check of the R3 regular route's angular monomial integral.

WS10 (verbatim):
gamma* q -> q g g (or q q qbar); |M_{2->3}|^2; Int |M|^2 dPi3 with
dPi3 = s23^{-eps}/(2Pi)^{2-2eps} * 2^{-2} Pi^{-eps}
(Gamma(1-eps)/Gamma(1-2eps)) dbeta1 dbeta2 sin^{1-2eps}beta1 sin^{-2eps}beta2.

`Hqq_R3_angint._beta_monomial(m,n)` claims

  Int dbeta1 dbeta2 sin^{1-2eps}b1 sin^{-2eps}b2 (cos b1)^m (sin b1 cos b2)^n
    = B((m+1)/2, (2-2eps+n)/2) * B((n+1)/2, (1-2eps)/2)

for even m,n.  This verifies it against direct symbolic integration at an
EXACT RATIONAL eps (so the test stays symbolic -- no floating point, no
quadrature), which is what the (delta,-1) hunt needs to exclude the regular
route.
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp
from Hqq_R3_angint import _beta_monomial, eps

b1, b2 = sp.symbols('b1 b2')
for e in (sp.Rational(1, 7), sp.Rational(2, 9)):
    for m, n in ((0, 0), (2, 0), (0, 2), (2, 2), (4, 2)):
        direct = (sp.integrate(sp.sin(b1)**(1 - 2*e + n)*sp.cos(b1)**m,
                               (b1, 0, sp.pi))
                  * sp.integrate(sp.sin(b2)**(-2*e)*sp.cos(b2)**n,
                                 (b2, 0, sp.pi)))
        engine = _beta_monomial(m, n).subs(eps, e)
        ok = sp.simplify(sp.expand_func(engine) - sp.expand_func(direct)) == 0
        print("eps=%s m=%d n=%d  EXACT_MATCH=%s" % (e, m, n, ok), flush=True)
print("BETAMONO_CHECK_DONE", flush=True)
