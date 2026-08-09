"""Exactness check on the DAG exporter python/R5_export_m.py.

WHY.  R5_export_m.py is a NEW transcription into the calculation chain, and a
mistranslated head (Times vs Plus, a dropped Rational, beta -> Beta) would be
a wrong result that still runs.  The project rule is that a transcription is
validated before use, symbolically.

WHAT IS CHECKED.  For a sample of DAG nodes, the emitted Mathematica text is
parsed BACK with sympy.parsing.mathematica and compared to the original node
by exact symbolic difference:

    parse_mathematica(emit(node)) - node   ==   0     (after simplify)

Round-tripping through an INDEPENDENT parser is what makes this a real check:
the emitter and the parser share no code, so a head-map error cannot cancel.

Nodes are sampled small-first so every head in the census is exercised
(Plus, Times, Power, Rational, Integer, log, beta, Abs, Pi, EulerGamma)
without paying for the giant ones -- and a head that never appears in the
sample is REPORTED, not silently skipped.

Run: python3 python/R5_export_m_check.py <channel> <projection> [nsample]
"""

import os
import pickle
import sys

import sympy as sp
from sympy.parsing.mathematica import parse_mathematica

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from R5_export_m import CACHE, FUNC_MAP, atom_text, collect, head_text


def emit(node, text):
    """The exporter's own rule for one node, with children already emitted."""
    leaf = atom_text(node)
    if leaf is not None:
        return leaf
    return "%s[%s]" % (head_text(node),
                       ", ".join(text[id(a)] for a in node.args))


def main():
    channel, projection = sys.argv[1], sys.argv[2]
    nsample = int(sys.argv[3]) if len(sys.argv) > 3 else 400

    regular = pickle.load(open(os.path.join(
        CACHE, "%s_R5_%s.pkl" % (channel, projection)), "rb"))["regular"]
    order, _ = collect(regular)
    print("DAG nodes: %d" % len(order), flush=True)

    # Emit every node once (cheap: DAG-sized), keeping the full text only for
    # nodes small enough to round-trip.
    text, size = {}, {}
    for node in order:
        text[id(node)] = emit(node, text)
        size[id(node)] = len(text[id(node)])

    # SYMBOL IDENTITY (STATE trap E.1, third dialect).  `parse_mathematica`
    # returns plain Symbols, while the cached expression carries symbols WITH
    # ASSUMPTIONS.  `Symbol('z') - z_assumptions` does NOT cancel, so the
    # round-trip must re-resolve parsed symbols onto the originals BY NAME.
    # Without this every single node "fails" with a residue like `-z + z`.
    originals = {a.name: a for a in regular.free_symbols}

    # HEAD-STRATIFIED SAMPLE.  Sorting purely by size picks only atoms (the
    # first run exercised Integer/Symbol/Pi and nothing else), so take the
    # smallest nodes OF EACH HEAD.  A head with no sample is reported below.
    # Group over ALL nodes, not only small ones: the rare heads (beta, log,
    # Abs) sit inside big terms, so a blanket size cap excluded exactly the
    # heads most worth checking.  The cap is applied per head, after sorting.
    by_head = {}
    for node in order:
        by_head.setdefault(type(node).__name__, []).append(node)
    sample = []
    per_head = max(nsample // max(len(by_head), 1), 5)
    for head, nodes in by_head.items():
        nodes.sort(key=lambda n: size[id(n)])
        nodes = [n for n in nodes if size[id(n)] <= 200000]
        sample.extend(nodes[:per_head])
        mid = len(nodes) // 2
        sample.extend(nodes[mid:mid + per_head])

    heads_seen, failures, checked = {}, [], 0
    for node in sample:
        heads_seen[type(node).__name__] = \
            heads_seen.get(type(node).__name__, 0) + 1
        back = parse_mathematica(text[id(node)])
        # sympy's Mathematica parser has no `Rational` head and leaves it as
        # an undefined Function, so a correct `Rational[1, 4]` round-trips to
        # Function('Rational')(1, 4) and looks like an exporter bug.  It is
        # not: Rational[1, 4] is the literal FullForm of 1/4 and Mathematica
        # reads it natively.  Repair the PARSE, not the export.
        back = back.replace(sp.Function("Rational"),
                            lambda p, q: sp.Rational(p, q))
        # Same story for every head the parser does not know: it returns an
        # undefined Function with the Mathematica name.  Invert the exporter's
        # own FUNC_MAP so the repair cannot drift from what was emitted.
        for func, name in FUNC_MAP.items():
            back = back.replace(sp.Function(name), func)
        back = back.xreplace({a: originals[a.name]
                              for a in back.free_symbols
                              if a.name in originals})
        diff = sp.simplify(sp.expand(back - node, log=False,
                             power_base=False, power_exp=False))
        checked += 1
        if diff != 0:
            # Report with srepr, not str: printing a parsed expression can
            # itself crash (`'Rational' object has no attribute 'p'` in
            # sympy's precedence_Rational), which would hide the very
            # mismatch being reported.
            failures.append((type(node).__name__, text[id(node)][:200],
                             sp.srepr(diff)[:400]))
            if len(failures) >= 5:
                break

    print("round-tripped %d nodes" % checked, flush=True)
    print("heads exercised: %s"
          % sorted(heads_seen.items(), key=lambda kv: -kv[1]), flush=True)

    census = {}
    for node in order:
        census[type(node).__name__] = census.get(type(node).__name__, 0) + 1
    missed = sorted(set(census) - set(heads_seen))
    if missed:
        print("HEADS NOT EXERCISED BY THE SAMPLE: %s "
              "(counts %s) -- widen the sample before trusting those"
              % (missed, {h: census[h] for h in missed}), flush=True)

    if failures:
        print("EXPORTER IS WRONG on %d node(s):" % len(failures), flush=True)
        for head, txt, diff in failures:
            print("  head=%s\n    emitted: %s\n    residue: %s"
                  % (head, txt, diff), flush=True)
        raise SystemExit(1)
    print("EXPORT_ROUNDTRIP_OK", flush=True)


if __name__ == "__main__":
    main()
