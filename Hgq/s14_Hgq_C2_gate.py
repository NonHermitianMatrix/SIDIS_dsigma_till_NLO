#!/usr/bin/env python3
"""C2/WS14: exact checkpointed Hgq pole-cancellation gate."""
import os
import pickle
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

import Hqq_C2_exact_gate as gate  # noqa: E402

VERSION = "hgq-c2-gate-v1"


def _atomic(path, value):
    temporary = path + ".tmp"
    with open(temporary, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
    os.replace(temporary, path)


def _c1_gate(proj):
    data = pickle.load(open(os.path.join(
        CACHE, "Hgq_C1_%s.pkl" % proj), "rb"))
    if data.get("remainder_eps_m2") != 0:
        raise ValueError("Hgq C1 prerequisite is not exact zero")


def main():
    proj = sys.argv[1]
    workers = int(sys.argv[2]) if len(sys.argv) > 2 else 15
    _c1_gate(proj)
    data = pickle.load(open(os.path.join(
        CACHE, "Hgq_C2exact_%s_components.pkl" % proj), "rb"))
    if data.get("version") != "hgq-c2-assembly-v1":
        raise ValueError("unaccepted Hgq C2 assembly")

    verdicts = {}
    for key in sorted(data["totals"], key=str):
        expression = data["totals"][key]
        terms = sp.Add.make_args(expression)
        chunks = [sp.Add(*terms[start:start + gate.CHUNK_SIZE])
                  for start in range(0, len(terms), gate.CHUNK_SIZE)]
        value, levels = gate._reduce(
            "Hgq_%s" % proj, key, chunks, workers)
        sparse = value != 0 and gate._sparse_exact_zero(value)
        if sparse:
            value = sp.S.Zero
        verdicts[key] = {
            "zero": value == 0, "remainder": value,
            "levels": levels, "sparse_proof": sparse}
        print("HGQ_C2_COMPONENT", proj, key,
              "zero", value == 0, flush=True)
        if value != 0:
            raise AssertionError("Hgq C2 pole survives at %s" % (key,))

    output = os.path.join(CACHE, "Hgq_C2_%s_gate.pkl" % proj)
    _atomic(output, {
        "version": VERSION, "projection": proj,
        "radical_branch": gate.RADICAL_BRANCH,
        "passed": True, "verdicts": verdicts})
    print("HGQ_C2_EXACT_PASS", proj,
          "branch", gate.RADICAL_BRANCH, flush=True)


if __name__ == "__main__":
    main()
