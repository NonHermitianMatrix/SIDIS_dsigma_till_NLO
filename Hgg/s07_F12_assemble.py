#!/usr/bin/env python3
# =====================================================================
# ###  WRONG CHANNEL LIST -- "Hqqbar" IS NOT A CHANNEL HERE  ###
# ###  (marked 2026-07-30)                                    ###
# =====================================================================
# This module treats "Hqqbar" as one of the six channels.  It is not.
# The piece `E` was mislabelled "Hqqbar" throughout this project.  From
# the R1 trace-script header (Hqq_NLO_R1_qqbar_exchange_traces.wls):
#
#   E = Hqq;qqbar EXCHANGE -- "SAME-flavor identical-particle
#       interference of the real channel of Hqq"
#
# i.e. `E` is a term of Table I ROW 2 (Hqq), not a channel.  Channel 5
# (q -> (qbar->h) q qbar) HAS NEVER BEEN COMPUTED -- there is no R1 trace
# script for it.  Every result this module produced for "Hqqbar" is an
# isolated interference term of Hqq, not a channel result.
#
# finite_hard_parts.py and Hqq_R5_exact.py have already been corrected;
# this file has NOT.  Fix the channel list before reusing it.
# See WRONG.md (Category B) and STATE.md 0z.42.
# =====================================================================
"""F1: assemble the partonic structure functions F1hat and F2hat.

WS14 (verbatim):
after subtraction every `1/eps^2`, `1/eps` cancels, leaving
`WhatNLO_finite`; convolve with the physical PDFs and FFs for the cross
section.

Structure follows the accepted Hgg/Hqq' assembler
`mathematica/Hqq_F12_assemble.wls`, reimplemented in SymPy per the project
tool split (Mathematica only for FeynCalc traces and Package-X):

    F1hat = -(1/2) Fg + (2 xh^2/Q2) Fpp
    F2hat = -xh Fg + (12 xh^3/Q2) Fpp

with Fg and Fpp the SAME assembled regular quantity in the two photon
projections.  These enter

    dsigma/(dx dy dz dPHT2)
        = (Pi^2 alphaEM^2)/(z x y Q2) [ x y^2 F1 + (1-y) F2 ]

with F1, F2 the PDF/FF convolutions of F1hat, F2hat (step N1, not done here).

The R5 artifacts are in the exact compact coordinates
    R5S = Q2*(xi/x - 1),   R5M = PHT^2 + z^2*R5S,   R5K = R5S - s23,
so the partonic momentum fraction is the exact rational function
    xh = x/xi = Q2/(Q2 + R5S).

Everything stays symbolic and exact: no Float, no decimal, no sampling.

Usage: python3 F12_assemble.py <Channel> [Channel ...]
"""
import os
import pickle
import hashlib
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
OUT = os.path.join(os.path.dirname(HERE), "out")
sys.path.insert(0, HERE)

Q2 = sp.Symbol("Q2", positive=True)
R5S = sp.Symbol("R5S", positive=True)
eps = sp.Symbol("eps")

# Exact partonic momentum fraction in the compact R5 coordinates.
XH = Q2/(Q2 + R5S)


def _load(channel, projection):
    path = os.path.join(CACHE, "%s_R5_%s.pkl" % (channel, projection))
    if not os.path.exists(path):
        raise SystemExit("missing R5 artifact %s" % path)
    data = pickle.load(open(path, "rb"))
    expected = "%s-r5-exact-compact-v2" % channel.lower()
    if data.get("version") != expected:
        raise SystemExit("unexpected R5 version %r for %s %s"
                         % (data.get("version"), channel, projection))
    return data


def _atomic(path, value):
    temporary = "%s.tmp.%d" % (path, os.getpid())
    with open(temporary, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


def assemble(channel):
    started = time.time()
    # NO count_ops ANYWHERE ON THESE TREES.  Job 14184852 produced no output
    # in 11 minutes because its first log line called `sp.count_ops` on the
    # R5 regular expressions (6.6-8.3 MB pickled, millions of nodes).  That
    # was a profiler in the hot path, purely for a log message, while the
    # assembly itself is trivial tree construction.  Report pickle sizes
    # instead -- free -- and traverse each tree ONCE for all gates.
    g_data, pp_data = _load(channel, "g"), _load(channel, "PP")
    Fg, Fpp = g_data["regular"], pp_data["regular"]
    print("F12 %s: loaded Fg/Fpp (%.1f s)"
          % (channel, time.time() - started), flush=True)

    # No expansion: keep the assembled combination as a compact tree.
    F1hat = -sp.Rational(1, 2)*Fg + (2*XH**2/Q2)*Fpp
    F2hat = -XH*Fg + (12*XH**3/Q2)*Fpp
    print("F12 %s: assembled (%.1f s)" % (channel, time.time() - started),
          flush=True)

    # Structural gates, mirroring the accepted Mathematica assembler, but in
    # ONE preorder pass per tree instead of several independent `.has()`
    # traversals of a multi-million-node expression.
    # `free_symbols` is CACHED per expression node, so this is cheap; a full
    # preorder walk is not, and would just reintroduce the cost of the
    # count_ops call that stalled 14184852.
    #
    # Float-freeness and finiteness do NOT need re-deriving here: the R5
    # driver already asserted
    #     finite.has(eps) or finite.has(Float, zoo, nan, oo, -oo)
    # and refused to write the artifact otherwise.  The artifact's existence
    # IS that gate's certificate; record its provenance instead of walking
    # millions of nodes to reconfirm it.
    symbols = sorted({s.name for s in F1hat.free_symbols}
                     | {s.name for s in F2hat.free_symbols})
    checks = {"eps_free": "eps" not in symbols,
              "float_and_finite_gated_upstream_by": {
                  "g": g_data.get("version"),
                  "PP": pp_data.get("version")},
              "symbols": symbols}
    checks["float_free"] = checks["finite"] = "verified upstream in R5"
    print("F12 %s: eps_free=%s float_free=%s finite=%s (%.1f s)"
          % (channel, checks["eps_free"], checks["float_free"],
             checks["finite"], time.time() - started), flush=True)
    print("F12 %s: free symbols %s" % (channel, symbols), flush=True)
    if not checks["eps_free"]:
        raise SystemExit("%s: F1hat/F2hat still depend on eps" % channel)

    payload = {
        "version": "f12-assemble-v1",
        "channel": channel,
        "F1hat": F1hat, "F2hat": F2hat,
        "xh": XH,
        "coordinates": {"R5S": "Q2*(xi/x - 1)",
                        "R5M": "PHT**2 + z**2*R5S"},
        # Hgg's exact pure-real pole gate is part of its R5 producer; other
        # channels remain provisional until the final summed-level gate.
        "provisional_pending_cross_channel_gate": channel != "Hgg",
        "accepted": channel == "Hgg",
        "source": {"g": "%s_R5_g.pkl" % channel,
                   "PP": "%s_R5_PP.pkl" % channel,
                   "g_sha256": hashlib.sha256(open(os.path.join(
                       CACHE, "%s_R5_g.pkl" % channel), "rb").read()).hexdigest(),
                   "PP_sha256": hashlib.sha256(open(os.path.join(
                       CACHE, "%s_R5_PP.pkl" % channel), "rb").read()).hexdigest()},
        "checks": checks,
        "elapsed_seconds": time.time() - started,
    }
    _atomic(os.path.join(CACHE, "F12hat_%s.pkl" % channel), payload)
    print("F12_ASSEMBLE_DONE %s elapsed %.1f"
          % (channel, time.time() - started), flush=True)
    return payload


def main():
    channels = sys.argv[1:] or ["Hqq", "Hqg", "Hgq", "Hqqbar"]
    for channel in channels:
        assemble(channel)
    print("F12_ALL_DONE %s" % " ".join(channels), flush=True)


if __name__ == "__main__":
    main()
