#!/usr/bin/env python3
"""Export accepted Hgg F1hat/F2hat as bare Mathematica InputForm files.

The verified-channel convention is a `.m` file whose value under Mathematica
`Get[...]` is the hard-function expression itself.  This exporter therefore
writes a bare expression, not an assignment and not a private DAG program.

WS14 (verbatim): after subtraction every `1/eps^2`, `1/eps` cancels, leaving
`WhatNLO_finite`; convolve with the physical PDFs and FFs for the cross
section.
"""
from __future__ import annotations

import hashlib
import os
import pickle
import sys

import sympy as sp

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from R5_export_m import atom_text, collect, head_text  # noqa: E402


BAD = (sp.Float, sp.zoo, sp.nan, sp.oo, -sp.oo)


def sha256(path: str) -> str:
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def write_node(stream, node: sp.Expr) -> None:
    """Stream exact Mathematica FullForm without materializing a giant string."""
    leaf = atom_text(node)
    if leaf is not None:
        stream.write(leaf)
        return
    stream.write(head_text(node))
    stream.write("[")
    for index, argument in enumerate(node.args):
        if index:
            stream.write(", ")
        write_node(stream, argument)
    stream.write("]")


def atomic_expression(path: str, expression: sp.Expr) -> None:
    temporary = "%s.tmp.%d" % (path, os.getpid())
    with open(temporary, "w", encoding="utf-8") as stream:
        write_node(stream, expression)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


def main() -> None:
    target = os.path.abspath(sys.argv[1] if len(sys.argv) > 1
                             else "verified/Hgg")
    source = os.path.join(target, "F12hat_Hgg.pkl")
    payload = pickle.load(open(source, "rb"))
    if (payload.get("version") != "f12-assemble-v1"
            or payload.get("channel") != "Hgg"
            or payload.get("accepted") is not True
            or payload.get("provisional_pending_cross_channel_gate") is not False
            or payload.get("checks", {}).get("eps_free") is not True):
        raise ValueError("Hgg F12 payload is not accepted")
    for projection, name in (("g", "Hgg_R5_g.pkl"),
                             ("PP", "Hgg_R5_PP.pkl")):
        recorded = payload["source"][projection + "_sha256"]
        if recorded != sha256(os.path.join(target, name)):
            raise ValueError("Hgg F12 source hash mismatch for " + projection)

    for key in ("F1hat", "F2hat"):
        expression = payload[key]
        if any(symbol.name == "eps" for symbol in expression.free_symbols):
            raise ValueError(key + " still contains eps")
        if expression.has(*BAD):
            raise ValueError(key + " contains an inexact/nonfinite atom")
        # Census every distinct node before opening the output.  Unknown
        # SymPy heads fail here, before a partial temporary export is made.
        order, _ = collect(expression)
        for node in order:
            if atom_text(node) is None:
                head_text(node)
        output = os.path.join(target, key + "_Hgg.m")
        atomic_expression(output, expression)
        print("HGG_M_EXPORT %s bytes=%d sha256=%s" %
              (os.path.basename(output), os.path.getsize(output), sha256(output)),
              flush=True)
    print("HGG_F12_M_EXPORT_DONE source_sha256=%s" % sha256(source),
          flush=True)


if __name__ == "__main__":
    main()
