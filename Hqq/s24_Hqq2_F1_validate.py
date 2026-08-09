#!/usr/bin/env python3
"""Strict structural/provenance gate for the provisional Hqq F hats.

WS14 (verbatim): after subtraction every `1/eps^2`, `1/eps` cancels, leaving
`WhatNLO_finite`; convolve with the physical PDFs and FFs for the cross
section.

This is an F1 artifact gate, not the final summed-level C1/C2 pole gate.
"""
import os
import pickle
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

import Hqq2_F1_finite as producer  # noqa: E402
import Hqq2_bookkeeping as book  # noqa: E402


def fail(message):
    print("HQQ_FHAT_GATE_FAIL", message, flush=True)
    raise SystemExit(1)


def main():
    path = os.path.join(CACHE, "F12hat_Hqq_provisional.pkl")
    data = pickle.load(open(path, "rb"))
    if data.get("version") != producer.ASSEMBLY_VERSION:
        fail("assembly version")
    if (data.get("channel") != "Hqq" or data.get("state") != "provisional"
            or not data.get("provisional_pending_summed_level_gate")
            or data.get("input_provenance_gate") != "passed"):
        fail("state/provisional/provenance flags")

    expected_sources = {
        "Hqq2_F1_real_%s_%s.pkl" % (projection, piece)
        for projection in ("g", "PP")
        for piece, _process, _charge, _weight in book.PIECES}
    expected_sources.update({"Hqq2_F1_virtual_g.pkl",
                             "Hqq2_F1_virtual_PP.pkl",
                             "Hqq_R5_g.pkl", "Hqq_R5_PP.pkl"})
    if set(data.get("sources", {})) != expected_sources:
        fail("graph/source manifest")
    for name, digest in sorted(data["sources"].items()):
        if producer.sha256(os.path.join(CACHE, name)) != digest:
            fail("source hash " + name)
    print("HQQ_FHAT_SOURCE_GATE", len(expected_sources), "of",
          len(expected_sources), flush=True)

    sectors = data.get("sectors", {})
    if set(sectors) != {"delta", "plus0", "plus1", "regular"}:
        fail("four-sector decomposition")
    charge_names = set()
    for sector in ("delta", "plus0", "plus1", "regular"):
        pair = sectors[sector]
        if set(pair) != {"F1hat", "F2hat"}:
            fail("projector pair " + sector)
        for name in ("F1hat", "F2hat"):
            expression = pair[name]
            if expression.has(sp.Float, sp.zoo, sp.nan, sp.oo, -sp.oo):
                fail("nonexact/nonfinite atom %s/%s" % (sector, name))
            symbols = {symbol.name for symbol in expression.free_symbols}
            if "eps" in symbols:
                fail("epsilon survived %s/%s" % (sector, name))
            charge_names.update(symbols.intersection({"eq", "eqp", "nf"}))
        print("HQQ_FHAT_SECTOR_GATE", sector, "PASS", flush=True)
    print("HQQ_FHAT_CHARGE_SYMBOLS", sorted(charge_names), flush=True)
    print("HQQ_FHAT_GATE_PASS", path, flush=True)


if __name__ == "__main__":
    main()
