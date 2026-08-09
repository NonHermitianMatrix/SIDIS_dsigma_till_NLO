#!/usr/bin/env python3
"""Independent parser/sample and whole-file gates for verified Hgg `.m`."""
from __future__ import annotations

import hashlib
import json
import os
import pickle
import sys

import sympy as sp
from sympy.parsing.mathematica import parse_mathematica

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from R5_export_m import FUNC_MAP, atom_text, collect, head_text  # noqa: E402


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def emit(node):
    leaf = atom_text(node)
    if leaf is not None:
        return leaf
    return "%s[%s]" % (head_text(node), ", ".join(emit(a) for a in node.args))


def roundtrip_samples(expression, limit=800):
    order, _ = collect(expression)
    sizes = {}
    groups = {}
    for node in order:
        leaf = atom_text(node)
        if leaf is not None:
            size = len(leaf)
        else:
            head = head_text(node)
            size = min(100001, len(head) + 2
                       + sum(sizes[id(arg)] + 2 for arg in node.args))
        sizes[id(node)] = size
        groups.setdefault(type(node).__name__, []).append(node)
    originals = {symbol.name: symbol for symbol in expression.free_symbols}
    per_head = max(limit // max(len(groups), 1), 8)
    checked = 0
    seen = set()
    for nodes in groups.values():
        eligible = sorted((node for node in nodes if sizes[id(node)] <= 100000),
                          key=lambda node: sizes[id(node)])
        chosen = eligible[:per_head]
        if eligible:
            middle = len(eligible) // 2
            chosen += eligible[middle:middle + per_head]
        for node in chosen:
            back = parse_mathematica(emit(node))
            back = back.replace(sp.Function("Rational"),
                                lambda p, q: sp.Rational(p, q))
            for function, name in FUNC_MAP.items():
                back = back.replace(sp.Function(name), function)
            back = back.xreplace({symbol: originals[symbol.name]
                                  for symbol in back.free_symbols
                                  if symbol.name in originals})
            if sp.simplify(back - node) != 0:
                raise AssertionError("Mathematica roundtrip mismatch for %s"
                                     % type(node).__name__)
            checked += 1
            seen.add(type(node).__name__)
    missed = sorted(set(groups) - seen)
    if missed:
        raise AssertionError("unexercised Mathematica heads: %s" % missed)
    return checked, sorted(seen)


def scan_file(path):
    opens = closes = 0
    forbidden = (b"eps", b"Float", b"zoo", b"nan", b"Indeterminate",
                 b"ComplexInfinity", b"DirectedInfinity")
    tail = b""
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            opens += block.count(b"[")
            closes += block.count(b"]")
            probe = tail + block
            if any(token in probe for token in forbidden):
                raise AssertionError("forbidden token in " + path)
            tail = probe[-32:]
    if opens != closes:
        raise AssertionError("unbalanced Mathematica brackets in " + path)
    return opens


def main():
    target = os.path.abspath(sys.argv[1] if len(sys.argv) > 1
                             else "verified/Hgg")
    source = os.path.join(target, "F12hat_Hgg.pkl")
    payload = pickle.load(open(source, "rb"))
    audit = {"state": "accepted", "source_sha256": sha256(source),
             "files": {}, "roundtrip": {}}
    for key in ("F1hat", "F2hat"):
        path = os.path.join(target, key + "_Hgg.m")
        brackets = scan_file(path)
        checked, heads = roundtrip_samples(payload[key])
        audit["files"][os.path.basename(path)] = {
            "sha256": sha256(path), "bytes": os.path.getsize(path),
            "balanced_bracket_pairs": brackets,
            "eps_float_nonfinite_free": True}
        audit["roundtrip"][key] = {"nodes_checked": checked,
                                    "heads_exercised": heads}
        print("HGG_M_CHECK %s brackets=%d samples=%d heads=%s" %
              (os.path.basename(path), brackets, checked, heads), flush=True)
    output = os.path.join(target, "Hgg_F12_export_audit.json")
    temporary = output + ".tmp.%d" % os.getpid()
    with open(temporary, "w", encoding="utf-8") as stream:
        json.dump(audit, stream, indent=2, sort_keys=True)
        stream.write("\n"); stream.flush(); os.fsync(stream.fileno())
    os.replace(temporary, output)
    print("HGG_F12_M_EXPORT_AUDIT_PASS", flush=True)


if __name__ == "__main__":
    main()
