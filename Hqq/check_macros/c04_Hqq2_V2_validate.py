#!/usr/bin/env python3
"""Final exact acceptance gate for the corrected Hqq2 V2 projections."""
import hashlib
import os
import pickle
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)
from generated.Hqq_L2_M2 import M2g, M2PP  # noqa: E402

VERSION = "hqq2-v2-validation-v1"


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def atomic_pickle(value, path):
    temporary = "%s.tmp.%d" % (path, os.getpid())
    with open(temporary, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush(); os.fsync(stream.fileno())
    os.replace(temporary, path)


def ratios(suffix, lo):
    path = os.path.join(CACHE, "Hqq2_V2_poles_%s.pkl" % suffix)
    payload = pickle.load(open(path, "rb"))
    if payload.get("version") != "hqq2-v2-poles-exact-v2-common-scheme":
        raise ValueError("unaccepted pole artifact " + suffix)
    p2, p1 = payload["minus2"], payload["minus1"]
    symbols = {symbol.name: symbol for symbol in p2.free_symbols | p1.free_symbols}
    lo = sp.sympify(lo).xreplace({symbol: symbols[symbol.name]
                                  for symbol in lo.free_symbols
                                  if symbol.name in symbols})
    eps = next(symbol for symbol in lo.free_symbols if symbol.name == "eps")
    lo0, lo1 = lo.subs(eps, 0), sp.diff(lo, eps).subs(eps, 0)
    double = sp.factor(sp.cancel(sp.together(p2/lo0)))
    single = sp.factor(sp.cancel(sp.together((p1 - double*lo1)/lo0)))
    return path, payload, double, single


def main():
    gpath, gp, g2, g1 = ratios("G", M2g)
    ppath, pp, p2, p1 = ratios("PP", M2PP)
    names = {symbol.name: symbol for symbol in g2.free_symbols | g1.free_symbols}
    expected = -names["gs"]**2*(2*names["Nc"]**2 - 1)/(4*sp.pi*names["Nc"])
    gates = {
        "g_catani_double": sp.cancel(sp.together(g2 - expected)) == 0,
        "PP_catani_double": sp.cancel(sp.together(p2 - expected)) == 0,
        "double_projection_independent": sp.cancel(sp.together(g2 - p2)) == 0,
        "single_projection_independent": sp.cancel(sp.together(g1 - p1)) == 0,
        "single_retains_nf": any(symbol.name == "nf" for symbol in g1.free_symbols),
    }
    if not all(gates.values()):
        raise AssertionError("Hqq2 V2 validation failure: %s" % gates)
    source_g = os.path.join(CACHE, "Hqq2_V2_virtG_ren_inv_sym.pkl")
    source_pp = os.path.join(CACHE, "Hqq2_V2_virtPP_ren_inv_sym.pkl")
    summary = {
        "version": VERSION, "state": "accepted", "gates": gates,
        "double_pole_over_lo": g2,
        "intrinsic_single_pole_over_lo": g1,
        "sources": {os.path.basename(path): sha256(path)
                    for path in (source_g, source_pp, gpath, ppath)},
        "r5_rerun": False,
    }
    atomic_pickle(summary, os.path.join(CACHE, "Hqq2_V2_validation.pkl"))
    status = os.path.join(CACHE, "hqq2_v2.status")
    temporary = "%s.tmp.%d" % (status, os.getpid())
    with open(temporary, "w") as stream:
        stream.write("DONE HQQ2_V2_BOTH_PROJECTIONS_ACCEPTED R5_NOT_RERUN\n")
        stream.flush(); os.fsync(stream.fileno())
    os.replace(temporary, status)
    print("HQQ2_V2_CATANI_DOUBLE", g2, flush=True)
    print("HQQ2_V2_INTRINSIC_SINGLE", g1, flush=True)
    print("HQQ2_V2_VALIDATION_DONE gates=%s" % gates, flush=True)


if __name__ == "__main__":
    main()
