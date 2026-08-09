#!/usr/bin/env python3
"""C2/WS13: assemble exact Hgq distribution-pole components."""
import os
import pickle
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

from Hqq_C1_from_r4mf import B, Q2_inv, resolve, s_inv, t1_inv  # noqa: E402
from Hqq_R4_kinmap import B_up, Q2, jac, s23, s_of, t1_of  # noqa: E402

VERSION = "hgq-c2-assembly-v1"
TARGETS = (-2, -1)
STRUCTURES = ("delta", "plus0", "plus1")


def _canonical(expr):
    from Hqq_R4_kinmap import PHT, x, xi, z
    named = {symbol.name: symbol for symbol in
             (x, z, Q2, PHT, xi, s23)}
    replacement = {symbol: named[symbol.name]
                   for symbol in expr.free_symbols
                   if symbol.name in named and symbol != named[symbol.name]}
    value = expr.xreplace(replacement) if replacement else expr
    if value.has(sp.Float, sp.zoo, sp.nan, sp.oo, -sp.oo):
        raise ValueError("non-exact/non-finite Hgq C2 component")
    return value


def _map_endpoint(expr):
    replacement = {}
    for symbol in expr.free_symbols:
        if symbol.name == "s":
            replacement[symbol] = s_of
        elif symbol.name == "t1":
            replacement[symbol] = t1_of.subs(s23, 0)
        elif symbol.name == "Q2":
            replacement[symbol] = Q2
        elif symbol.name == "B":
            replacement[symbol] = B_up
        elif symbol.name == "s23":
            replacement[symbol] = sp.S.Zero
    return _canonical(expr.xreplace(replacement))


def _virtual(proj):
    suffix = "G" if proj == "g" else "PP"
    data = pickle.load(open(os.path.join(
        CACHE, "Hgq_V2_poles_%s.pkl" % suffix), "rb"))
    if data.get("version") != "hgq-v2-poles-exact-v1":
        raise ValueError("unaccepted Hgq V2 pole cache")
    j0 = jac.subs(s23, 0)
    substitution = {
        s_inv: s_of, t1_inv: t1_of.subs(s23, 0), Q2_inv: Q2}
    return {
        -2: _canonical(j0*resolve(data["minus2"]).subs(substitution)),
        -1: _canonical(j0*resolve(data["minus1"]).subs(substitution)),
    }


def _counterterms(proj):
    data = pickle.load(open(os.path.join(CACHE, "Hglu_CTbt.pkl"), "rb"))
    if data.get("gate", {}).get("hqq_reference_failures") != 0:
        raise ValueError("Hglu invariant counterterm reference gate failed")
    j0 = jac.subs(s23, 0)
    pdf = data[("Hgq", "pdf")][proj]
    ff = data[("Hgq", "ff")][proj]
    # PREF has one explicit 1/eps and its remaining factor starts at eps^0.
    # Only its eps^-1 coefficient contributes to C2.
    eps = next(symbol for symbol in data["PREF"].free_symbols
               if symbol.name == "eps")
    pref_m1 = sp.limit(eps*data["PREF"], eps, 0)
    delta = _map_endpoint(pdf["Cdelta"] + ff["Cdelta"])
    plus0 = _map_endpoint(pdf["Cplus"] + ff["Cplus"])
    return {
        ("delta", -1): _canonical(pref_m1*j0*delta),
        ("plus0", -1): _canonical(pref_m1*j0*plus0),
    }


def main():
    proj = sys.argv[1]
    if proj not in ("g", "PP"):
        raise SystemExit("projection must be g or PP")
    real = pickle.load(open(os.path.join(
        CACHE, "Hgq_C2realpole_%s_HGQ.pkl" % proj), "rb"))
    if real.get("version") != "c2-exact-real-poles-v1":
        raise ValueError("unaccepted Hgq real-pole cache")

    components = {(structure, target): {}
                  for structure in STRUCTURES for target in TARGETS}
    for key, expression in real["poles"].items():
        components[key]["real"] = _canonical(expression)
    for target, expression in _virtual(proj).items():
        components[("delta", target)]["virtual"] = expression
    for key, expression in _counterterms(proj).items():
        components[key]["CTpdf_plus_CTff"] = expression

    totals = {key: sp.Add(*sources.values())
              for key, sources in components.items()}
    output = os.path.join(CACHE, "Hgq_C2exact_%s_components.pkl" % proj)
    temporary = output + ".tmp"
    with open(temporary, "wb") as stream:
        pickle.dump({"version": VERSION, "projection": proj,
                     "components": components, "totals": totals},
                    stream, protocol=pickle.HIGHEST_PROTOCOL)
    os.replace(temporary, output)
    print("HGQ_C2_ASSEMBLY_DONE", proj, flush=True)
    for key in sorted(components, key=str):
        print(key, sorted(components[key]), flush=True)


if __name__ == "__main__":
    main()
