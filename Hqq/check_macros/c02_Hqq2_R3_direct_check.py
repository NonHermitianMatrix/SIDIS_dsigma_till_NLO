#!/usr/bin/env python3
"""Does R3's angular result equal the integral it claims to compute?

WS10 (verbatim):
gamma* q -> q g g (or q q qbar); |M_{2->3}|^2; Int |M|^2 dPi3 with
dPi3 = s23^{-eps}/(2Pi)^{2-2eps} * 2^{-2} Pi^{-eps}
(Gamma(1-eps)/Gamma(1-2eps)) dbeta1 dbeta2 sin^{1-2eps}beta1 sin^{-2eps}beta2.

The (delta,-1) pole failure has been localized to the O(eps^0) part of the
endpoint residue, and R4 was shown to propagate its input faithfully.  So the
question is whether `Hqq_R3_engine.angular_integrate` reproduces

    Int_0^pi db1 Int_0^pi db2 sin^{1-2eps}b1 sin^{-2eps}b2 * <integrand>

for the REAL R2 terms of this channel.  This is the same check the engine
ships for its regular route, applied to actual production terms and to the
singular route.

eps is set to a small NEGATIVE rational: negative eps makes the endpoint
behaviour of the singular masters integrable, so the 2D quadrature converges
and compares directly against the analytic continuation the masters encode.
The comparison is done at exact rational kinematics; only the final numeric
comparison uses mpmath, because a 2D quadrature has no symbolic counterpart.

Usage:  Hqq2_R3_direct_check.py <R2 cache name> [n_terms] [eps_num]
        e.g.  Hqq2_R3_direct_check.py MR2PPDFA 6 -0.08
"""
from __future__ import annotations

import os
import pickle
import sys

import mpmath as mp
import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

import Hqq_R3_engine as engine                                  # noqa: E402
from Hqq_R3_angint import ADMV_FRAME, ADMV_SYMS, b1, b2         # noqa: E402

# USE THE ENGINE'S OWN REFERENCE POINT.  The analytic master forms assume
# D > 1; that is a statement about the PHYSICAL region, and the engine only
# asserts it at `REF`, whose points are built from genuine momenta
# (p, q, k1).  An arbitrary AIMV point can put a denominator zero INSIDE the
# beta1 range, in which case the direct quadrature hits a pole while the
# engine returns the analytic continuation -- a mismatch that says nothing
# about R3.
POINT = {sym.name: value for sym, value in engine.REF[0].items()}
# colour and couplings are overall factors; fix them to exact rationals so
# nothing symbolic survives into the quadrature.
EXTRA = {"Nc": sp.Integer(3), "ee": sp.Integer(1), "eq": sp.Integer(1),
         "gs": sp.Integer(1), "CF": sp.Rational(4, 3), "nf": sp.Integer(5)}


def main():
    name = sys.argv[1]
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 6
    epsv = mp.mpf(sys.argv[3]) if len(sys.argv) > 3 else mp.mpf("-0.08")
    mp.mp.dps = 30

    terms = pickle.load(open(os.path.join(
        CACHE, "Hqq2_R2_%s.pkl" % name), "rb"))
    if isinstance(terms, dict):
        terms = terms.get("terms", list(terms.values())[0])
    print("R2 terms available:", len(terms), flush=True)

    eps_engine = next(s for s in engine.angular_integrate(
        sp.Integer(1)).free_symbols | {sp.Symbol("eps")}
        if s.name == "eps")

    bad = 0
    for index, term in enumerate(terms[:count]):
        analytic = engine.angular_integrate(term)
        values = {sp.Symbol(k): v for k, v in POINT.items()}
        values.update({sp.Symbol(k): v for k, v in EXTRA.items()})
        analytic = analytic.xreplace(
            {sym: values[sp.Symbol(sym.name)] for sym in analytic.free_symbols
             if sp.Symbol(sym.name) in values})
        analytic = analytic.xreplace(
            {sym: sp.Rational(str(epsv)) for sym in analytic.free_symbols
             if sym.name == "eps"})
        left = [sym for sym in analytic.free_symbols]
        if left:
            raise ValueError("unsubstituted in analytic: %s" % left)
        analytic = complex(sp.N(analytic)).real

        frame = ADMV_FRAME["k1"]
        # map the ADMVs to their angular forms BY NAME: the R2 caches carry
        # Symbol objects whose assumptions differ from ADMV_SYMS, so an
        # object-keyed xreplace silently leaves them behind.
        direct_expr = term.xreplace(
            {sym: frame[sym.name] for sym in term.free_symbols
             if sym.name in frame})
        direct_expr = direct_expr.xreplace(
            {sym: values[sp.Symbol(sym.name)]
             for sym in direct_expr.free_symbols
             if sp.Symbol(sym.name) in values})
        direct_expr = direct_expr.xreplace(
            {sym: sp.Rational(str(epsv)) for sym in direct_expr.free_symbols
             if sym.name == "eps"})
        left = [sym for sym in direct_expr.free_symbols
                if sym not in (b1, b2)]
        if left:
            raise ValueError("unsubstituted in integrand: %s" % left)
        f = sp.lambdify((b1, b2), direct_expr, "mpmath")

        def integrand(B1, B2):
            return (mp.sin(B1)**(1 - 2*epsv)*mp.sin(B2)**(-2*epsv)*f(B1, B2))

        direct = mp.quad(integrand, [0, mp.pi], [0, mp.pi])
        direct = float(mp.re(direct))
        rel = abs(analytic/direct - 1) if direct else abs(analytic)
        flag = "OK" if rel < 1e-8 else "MISMATCH"
        if flag == "MISMATCH":
            bad += 1
        print("term %-4d engine % .12e  direct % .12e  rel %.2e  %s"
              % (index, analytic, direct, rel, flag), flush=True)

    print("R3_DIRECT_CHECK %s  mismatches=%d/%d"
          % ("FAIL" if bad else "PASS", bad, min(count, len(terms))),
          flush=True)


if __name__ == "__main__":
    main()
