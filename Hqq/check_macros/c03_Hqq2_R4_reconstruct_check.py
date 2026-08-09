#!/usr/bin/env python3
"""Is R4's endpoint extraction FAITHFUL to its R3 input?

WS10 (verbatim):
gamma* q -> q g g (or q q qbar); |M_{2->3}|^2; Int |M|^2 dPi3 with
dPi3 = s23^{-eps}/(2Pi)^{2-2eps} * 2^{-2} Pi^{-eps}
(Gamma(1-eps)/Gamma(1-2eps)) dbeta1 dbeta2 sin^{1-2eps}beta1 sin^{-2eps}beta2.

R4 classifies its R3 input by the W-exponent (W^2 = s23):
    Residue: coefficient of W^(-2 + c eps) Log[s23]^l   -> 1/s23
    Deep:    even k < -2                                -> 1/s23^2, 1/s23^3
Everything else is regular at s23 -> 0 and belongs to the R5 regular sector.

Therefore, for the accepted classes,

    R3_expr  -  [ Residue/s23 + Deep/s23^2 + ... ]

must be REGULAR at s23 -> 0.  If R4 lost or mis-extracted any part of the
residue, the difference keeps a 1/s23 (or deeper) pole, and s23*diff will not
vanish at s23 = 0.  This is a complete test of the extraction that needs no
re-derivation of the angular integrals.

The check is done at an exact RATIONAL kinematic point in the AIMVs, with
s23 kept symbolic, so it is an exact statement about the s23 structure.

Usage:  Hqq2_R4_reconstruct_check.py <target>       e.g. MR2PPDFA
"""
from __future__ import annotations

import os
import pickle
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

# Exact rational AIMV point (s23 stays symbolic).  u1 is fixed by
# s + t1 + u1 = -Q2 + s23 so the point stays ON the constraint surface.
POINT = {"s": sp.Integer(3), "t1": sp.Integer(-1), "Q2": sp.Integer(1)}


def main():
    target = sys.argv[1]
    angular = pickle.load(open(os.path.join(
        CACHE, "Hqq2_R3_%s_ang.pkl" % target), "rb"))
    classes = pickle.load(open(os.path.join(
        CACHE, "Hqq2_R4_%s.pkl" % target), "rb"))["classes"]

    symbols = {symbol.name: symbol for symbol in angular.free_symbols}
    s23 = symbols["s23"]
    substitutions = {symbols[name]: value for name, value in POINT.items()
                     if name in symbols}
    if "u1" in symbols:            # on-shell: u1 = -Q2 - s - t1 + s23
        substitutions[symbols["u1"]] = (-POINT["Q2"] - POINT["s"]
                                        - POINT["t1"] + s23)

    reconstructed = sp.S.Zero
    for key, expression in classes.items():
        power = -1 if key[0] == "Residue" else (int(key[2]) // 2)
        logs = key[-1]
        piece = expression.xreplace(
            {symbol: substitutions[symbol] for symbol in expression.free_symbols
             if symbol in substitutions})
        reconstructed += piece*s23**power*sp.log(s23)**logs
        print("class %-22s -> s23^%d log^%d" % (str(key), power, logs),
              flush=True)

    original = angular.xreplace(substitutions)
    difference = sp.cancel(sp.together(original - reconstructed))
    print("difference ops", sp.count_ops(difference), flush=True)

    for power in (1, 2, 3):
        probe = sp.cancel(sp.together(difference*s23**power))
        limit = sp.simplify(probe.subs(s23, 0))
        print("  s23^%d * difference at s23=0 : %s" %
              (power, "0" if limit == 0 else sp.factor(limit)), flush=True)
        if power == 1:
            verdict = limit == 0
    print("RECONSTRUCT_VERDICT",
          "FAITHFUL (difference regular at s23=0)" if verdict
          else "LOST_RESIDUE (a 1/s23 pole survives R4's classification)",
          flush=True)


if __name__ == "__main__":
    main()
