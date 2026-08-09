#!/usr/bin/env python3
"""Optimized provisional Hqq finite distribution sectors and F1/F2 assembly.

WS14 (verbatim): after subtraction every `1/eps^2`, `1/eps` cancels, leaving
`WhatNLO_finite`; convolve with the physical PDFs and FFs for the cross
section.

Results-first policy: this producer does not impose a per-channel pole gate.
It combines the finite endpoint, virtual and Eq.(46) counterterm coefficients
with the already completed R5 regular sector.  Acceptance remains provisional
until the one final summed-level physical pole gate.

Usage:
  Hqq2_F1_finite.py real <g|PP> <QGG|SF|DFA|DFB|DFC> [workers]
  Hqq2_F1_finite.py virtual <g|PP> [workers]
  Hqq2_F1_finite.py assemble
"""
from __future__ import annotations

import glob
import hashlib
import json
import multiprocessing as mp
import os
import pickle
import resource
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.environ.get("HQQ2_F1_CACHE", os.path.join(HERE, "cache"))
sys.path.insert(0, HERE)

import Hqq2_bookkeeping as book  # noqa: E402
from Hqq_C1_from_r4mf import (B, Q2_inv, class_delta_factor, eps, kf,
                              resolve, s_inv, t1_inv)  # noqa: E402
from Hqq_C2_exact_real_poles import (  # noqa: E402
    _eps_polynomial, _factorwise_laurent, _mask_eps_free)
from Hqq_R4_kinmap import (Q2, jac, s23, s_of, t1_of, x, xi)  # noqa: E402
from Hqq2_endpoint_measure import unify_symbols, zero_s23  # noqa: E402
from R5_parallel_reduce import _outer_linear_terms  # noqa: E402

# PRODUCER version.  The per-piece real/virtual coefficient caches are
# unaffected by the endpoint-measure correction -- the defect was entirely in
# `assemble` -- so this stays v1 and those (expensive) caches remain valid.
VERSION = "hqq2-f1-finite-exact-v1"
# ASSEMBLY version.  v2 = jac|_{s23=0} and the measured-frame bridge applied
# to the real endpoint residues, plus one global Symbol object per name.
ASSEMBLY_VERSION = "hqq2-f1-assembly-v3-strict-provenance"
MAP_VERSION = "hqq2-f1-endpoint-map-v1"
CHUNK = int(os.environ.get("HQQ2_F1_CHUNK", "100"))
CAP = int(os.environ.get("HQQ2_F1_WORKER_CAP_BYTES", "2147483648"))
BAD = (sp.Float, sp.zoo, sp.nan, sp.oo, -sp.oo)
STRUCTURES = ("delta", "plus0", "plus1")
T1_ENDPOINT = t1_of.xreplace({s23: sp.S.Zero})
JAC_ENDPOINT = jac.xreplace({s23: sp.S.Zero})


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def atomic(value, path):
    temporary = "%s.tmp.%d" % (path, os.getpid())
    with open(temporary, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush(); os.fsync(stream.fileno())
    os.replace(temporary, path)


def init_worker():
    resource.setrlimit(resource.RLIMIT_AS, (CAP, CAP))


def coeff0(expression):
    """Exact eps^0 coefficient with eps-free subtrees kept inert."""
    direct = _eps_polynomial(expression)
    if direct is not None:
        return direct.get(0, sp.S.Zero)
    masked, backward = _mask_eps_free(expression)
    values = _factorwise_laurent(masked, 0, 0)
    value = values.get(0, sp.S.Zero)
    return value.xreplace(backward) if backward else value


def pref_series(c, l):
    lam = (1 - sp.Rational(c, 2))*eps
    pref = {"delta": kf*class_delta_factor(c, l)}
    if l == 0:
        pref["plus0"] = kf
        pref["plus1"] = -lam*kf
    elif l == 1:
        pref["plus1"] = kf
    else:
        raise ValueError("unsupported endpoint log power %s" % l)
    out = {}
    for structure, expression in pref.items():
        masked, backward = _mask_eps_free(expression)
        series = _factorwise_laurent(masked, -4, 2)
        out[structure] = {power: (value.xreplace(backward)
                                  if backward else value)
                          for power, value in series.items()}
    return out


def residue_coefficients(term, minimum, maximum):
    free, dependent = sp.S.One, sp.S.One
    for factor in sp.Mul.make_args(term):
        if factor.has(eps):
            dependent *= factor
        else:
            free *= factor
    direct = _eps_polynomial(dependent)
    if direct is not None:
        return free, direct
    masked, backward = _mask_eps_free(dependent)
    values = _factorwise_laurent(masked, minimum, maximum)
    if backward:
        values = {power: value.xreplace(backward)
                  for power, value in values.items()}
    return free, values


def real_worker(job):
    index, c, l, term, pref = job
    if term.has(*BAD):
        raise ValueError("invalid atom in Hqq endpoint term %d" % index)
    powers = [power for series in pref.values() for power in series]
    free, residue = residue_coefficients(
        term, -max(powers), -min(powers))
    result = {}
    for structure, series in pref.items():
        value = sp.Add(*[coefficient*residue.get(-power, sp.S.Zero)
                         for power, coefficient in series.items()])
        result[structure] = free*value
    if any(value.has(*BAD) for value in result.values()):
        raise ValueError("invalid finite real coefficient at term %d" % index)
    return index, result


def virtual_worker(job):
    index, term = job
    old = next((symbol for symbol in term.free_symbols
                if symbol.name == "eps"), None)
    if old is not None and old is not eps:
        term = term.xreplace({old: eps})
    value = coeff0(term)
    if value.has(*BAD):
        raise ValueError("invalid finite virtual coefficient at term %d" % index)
    return index, value


def producer_fingerprint(kind, paths):
    """Hash coefficient inputs without coupling them to assembler-only edits.

    ``VERSION`` is the explicit contract for the coefficient algorithm and
    must be bumped when that algorithm changes.  Hashing this whole mixed
    producer/assembler file made a provenance-check-only edit invalidate every
    expensive coefficient cache even though no produced coefficient changed.
    """
    digest = hashlib.sha256()
    digest.update(VERSION.encode("ascii"))
    digest.update(kind.encode("ascii"))
    for path in paths:
        digest.update(os.path.basename(path).encode("utf-8"))
        digest.update(sha256(path).encode("ascii"))
    return digest.hexdigest()


def checkpointed(stem, run_hash, jobs, worker, workers, value_keys):
    existing = sorted(glob.glob(stem + "_batch_*.pkl"))
    completed = set()
    sums = {key: [] for key in value_keys}
    for path in existing:
        saved = pickle.load(open(path, "rb"))
        if (saved.get("version") != VERSION
                or saved.get("input_sha256") != run_hash):
            continue
        completed.update(saved["indices"])
        for key in value_keys:
            sums[key].append(saved["values"].get(key, sp.S.Zero))
    pending = [job for job in jobs if job[0] not in completed]
    print("HQQ2_F1_SOURCE total=%d resumed=%d pending=%d hash=%s" %
          (len(jobs), len(completed), len(pending), run_hash), flush=True)
    batch = len(existing)
    indices = []
    values = {key: [] for key in value_keys}

    def flush():
        nonlocal batch
        if not indices:
            return
        merged = {key: sp.Add(*parts) for key, parts in values.items()}
        path = stem + "_batch_%04d.pkl" % batch
        atomic({"version": VERSION, "input_sha256": run_hash,
                "indices": tuple(indices), "values": merged}, path)
        for key in value_keys:
            sums[key].append(merged[key]); values[key].clear()
        print("HQQ2_F1_CHECKPOINT", batch, len(indices), flush=True)
        indices.clear(); batch += 1

    if pending:
        with mp.get_context("spawn").Pool(
                workers, initializer=init_worker, maxtasksperchild=250) as pool:
            for index, result in pool.imap_unordered(worker, pending, 2):
                indices.append(index)
                if isinstance(result, dict):
                    for key in value_keys:
                        values[key].append(result.get(key, sp.S.Zero))
                else:
                    values[value_keys[0]].append(result)
                if len(indices) >= CHUNK:
                    flush()
            flush()
    return {key: sp.Add(*parts) for key, parts in sums.items()}


def validate_r4(projection, piece):
    prefix = "MR2g" if projection == "g" else "MR2PP"
    angular = os.path.join(CACHE, "Hqq2_R3_%s%s_ang.pkl" % (prefix, piece))
    source = os.path.join(CACHE, "Hqq2_R4_%s%s.pkl" % (prefix, piece))
    payload = pickle.load(open(source, "rb"))
    if (payload.get("version") != "hqq2-r4-exact-laurent-v1"
            or payload.get("state") != "complete"
            or payload.get("target") != prefix + piece
            or payload.get("source_sha256") != sha256(angular)):
        raise ValueError("unaccepted Hqq2 R4 endpoint " + prefix + piece)
    classes = {(key[1], key[2]): value
               for key, value in payload["classes"].items()
               if key[0] == "Residue"}
    return source, angular, classes


def real_input_hash(projection, piece):
    """Current producer hash and source hash for one real finite artifact."""
    prefix = "MR2g" if projection == "g" else "MR2PP"
    source = os.path.join(CACHE, "Hqq2_R4_%s%s.pkl" % (prefix, piece))
    angular = os.path.join(CACHE, "Hqq2_R3_%s%s_ang.pkl" % (prefix, piece))
    # The producer itself calls validate_r4 before it can write an artifact.
    # Assembly only needs byte-level freshness here; re-unpickling the large
    # QGG R4 payload merely to reread its metadata wastes memory.
    run_hash = producer_fingerprint("real", [
        source, angular,
        os.path.join(CACHE, "Hqq2_R4_physical_manifest.json"),
        os.path.join(HERE, "Hqq_C2_exact_real_poles.py")])
    return source, run_hash


def virtual_input_hash(projection):
    """Current producer hash and source hash for one virtual finite artifact."""
    suffix = "G" if projection == "g" else "PP"
    source = os.path.join(CACHE, "Hqq2_V2_virt%s_ren_inv_sym.pkl" % suffix)
    validation = os.path.join(CACHE, "Hqq2_V2_validation.pkl")
    run_hash = producer_fingerprint("virtual", [
        source, validation,
        os.path.join(HERE, "Hqq_C2_exact_real_poles.py")])
    return source, run_hash


def run_real(projection, piece, workers):
    if piece not in {entry[0] for entry in book.PIECES}:
        raise ValueError("unknown Hqq2 real piece " + piece)
    source, angular, classes = validate_r4(projection, piece)
    manifest = os.path.join(CACHE, "Hqq2_R4_physical_manifest.json")
    run_hash = producer_fingerprint("real", [
        source, angular, manifest,
        os.path.join(HERE, "Hqq_C2_exact_real_poles.py")])
    jobs = []
    index = 0
    for c, l in sorted(classes, key=str):
        pref = pref_series(c, l)
        for term in sp.Add.make_args(classes[(c, l)]):
            jobs.append((index, c, l, term, pref)); index += 1
    stem = os.path.join(CACHE, "Hqq2_F1_real_%s_%s_%s" %
                        (projection, piece, run_hash[:16]))
    values = checkpointed(stem, run_hash, jobs, real_worker, workers,
                          STRUCTURES)
    output = os.path.join(CACHE, "Hqq2_F1_real_%s_%s.pkl" %
                          (projection, piece))
    atomic({"version": VERSION, "kind": "real", "projection": projection,
            "piece": piece, "input_sha256": run_hash,
            "source_sha256": sha256(source), "terms": len(jobs),
            "finite": values}, output)
    print("HQQ2_F1_REAL_DONE", projection, piece, len(jobs), output, flush=True)


def run_virtual(projection, workers):
    suffix = "G" if projection == "g" else "PP"
    source = os.path.join(CACHE, "Hqq2_V2_virt%s_ren_inv_sym.pkl" % suffix)
    validation = os.path.join(CACHE, "Hqq2_V2_validation.pkl")
    status = os.path.join(CACHE, "hqq2_v2.status")
    accepted = pickle.load(open(validation, "rb"))
    if (accepted.get("version") != "hqq2-v2-validation-v1"
            or accepted.get("state") != "accepted"
            or "DONE HQQ2_V2_BOTH_PROJECTIONS_ACCEPTED" not in
            open(status, encoding="utf-8").read()):
        raise ValueError("corrected Hqq2 V2 is not accepted")
    payload = pickle.load(open(source, "rb"))
    if (payload.get("version") != "hqq2-v2-renorm-exact-v2-common-scheme"
            or payload.get("projection") != projection):
        raise ValueError("unaccepted Hqq2 virtual source")
    run_hash = producer_fingerprint("virtual", [
        source, validation,
        os.path.join(HERE, "Hqq_C2_exact_real_poles.py")])
    terms = _outer_linear_terms(sp.pi*payload["virtual"])
    jobs = list(enumerate(terms))
    stem = os.path.join(CACHE, "Hqq2_F1_virtual_%s_%s" %
                        (projection, run_hash[:16]))
    values = checkpointed(stem, run_hash, jobs, virtual_worker, workers,
                          ("finite",))
    output = os.path.join(CACHE, "Hqq2_F1_virtual_%s.pkl" % projection)
    atomic({"version": VERSION, "kind": "virtual",
            "projection": projection, "input_sha256": run_hash,
            "source_sha256": sha256(source), "terms": len(terms),
            "finite_invariant": values["finite"]}, output)
    print("HQQ2_F1_VIRTUAL_DONE", projection, len(terms), output, flush=True)


def canonical(expression):
    named = {symbol.name: symbol for symbol in (x, xi, Q2, s23, eps)}
    replacements = {symbol: named[symbol.name]
                    for symbol in expression.free_symbols
                    if symbol.name in named and symbol is not named[symbol.name]}
    return expression.xreplace(replacements) if replacements else expression


def resolve_for_assembly(expression):
    """Fast exact form of ``resolve`` for already-produced finite caches.

    Assembly needs only atom-by-name canonicalization plus the physical
    ``Abs(t1)``/``sign(t1)`` convention.  Avoiding two unconditional generic
    ``replace`` tree walks matters for the large QGG coefficient, while the
    conditional operations below are algebraically identical to ``resolve``.
    """
    targets = {"s": s_inv, "t": t1_inv, "t1": t1_inv, "Q2": Q2_inv,
               "eps": eps}
    replacements = {symbol: targets[symbol.name]
                    for symbol in expression.free_symbols
                    if symbol.name in targets}
    expression = (expression.xreplace(replacements)
                  if replacements else expression)
    if expression.has(sp.Abs):
        expression = expression.replace(
            sp.Abs, lambda argument: (-argument if argument == t1_inv
                                      else sp.Abs(argument)))
    if expression.has(sp.sign):
        expression = expression.replace(
            sp.sign, lambda argument: (sp.Integer(-1)
                                       if argument == t1_inv
                                       else sp.sign(argument)))
    return expression


def invariant_endpoint(expression):
    substitutions = {s_inv: s_of, t1_inv: T1_ENDPOINT, Q2_inv: Q2}
    # These keys are atomic Symbols, so simultaneous exact replacement is the
    # intended kinematic map and is substantially cheaper than general subs.
    mapped = resolve_for_assembly(expression).xreplace(substitutions)
    return canonical(JAC_ENDPOINT*mapped)


def checkpointed_endpoint_map(label, identity, expressions):
    """Map finite invariant coefficients with exact resumable checkpoints.

    Each completed distribution structure is written atomically.  A rerun
    accepts it only when the mapping version and every supplied provenance
    field match, so partial assembly work is reusable without admitting a
    stale coefficient.
    """
    token = hashlib.sha256(repr(sorted(identity.items())).encode("utf-8"))
    token = token.hexdigest()[:16]
    path = os.path.join(CACHE, "Hqq2_F1_mapped_%s_%s.pkl" % (label, token))
    mapped = {}
    if os.path.exists(path):
        saved = pickle.load(open(path, "rb"))
        if (saved.get("version") == MAP_VERSION
                and saved.get("identity") == identity):
            mapped = saved.get("mapped", {})
    for structure, expression in expressions.items():
        if structure in mapped:
            print("HQQ2_F1_MAP_RESUME", label, structure, path, flush=True)
            continue
        print("HQQ2_F1_MAP_START", label, structure, flush=True)
        mapped[structure] = invariant_endpoint(expression)
        atomic({"version": MAP_VERSION, "identity": identity,
                "mapped": mapped}, path)
        print("HQQ2_F1_MAP_CHECKPOINT", label, structure, path, flush=True)
    return mapped


def counterterm_finite(projection):
    data = pickle.load(open(os.path.join(CACHE, "Hqq_CTbt.pkl"), "rb"))
    ct = data["CT"]
    label = projection
    delta = data["PREF"]*(ct["pdf"][label]["Cdelta"]
                           + ct["ff"][label]["Cdelta"])
    plus0 = data["PREF"]*(ct["pdf"][label]["Cplus"]
                           + ct["ff"][label]["Cplus"])
    return {"delta": invariant_endpoint(coeff0(delta)),
            # by NAME -- `.subs(s23, 0)` here was a silent no-op because the
            # counterterm cache's s23 carries different assumptions.
            "plus0": invariant_endpoint(coeff0(zero_s23(plus0))),
            "plus1": sp.S.Zero}


def assemble():
    validation = pickle.load(open(os.path.join(
        CACHE, "Hqq2_V2_validation.pkl"), "rb"))
    if validation.get("state") != "accepted":
        raise ValueError("Hqq V2 acceptance absent")
    projected = {}
    sources = {}
    # One global Symbol object per NAME across every producer cache: the real
    # and virtual caches carry distinct `Nc` objects (same name, different
    # assumptions), so equal colour factors would never cancel.
    symbol_table = {}
    for projection in ("g", "PP"):
        total = {name: sp.S.Zero for name in STRUCTURES}
        for piece, _process, _charge, _weight in book.PIECES:
            path = os.path.join(CACHE, "Hqq2_F1_real_%s_%s.pkl" %
                                (projection, piece))
            payload = pickle.load(open(path, "rb"))
            source, expected_hash = real_input_hash(projection, piece)
            if (payload.get("version") != VERSION
                    or payload.get("projection") != projection
                    or payload.get("piece") != piece
                    or payload.get("input_sha256") != expected_hash
                    or payload.get("source_sha256") != sha256(source)):
                raise ValueError("unaccepted finite real input " + path)
            weight = book.weight(piece)
            identity = {"kind": "real", "projection": projection,
                        "piece": piece, "aggregate_sha256": sha256(path),
                        "input_sha256": expected_hash,
                        "source_sha256": sha256(source)}
            mapped = checkpointed_endpoint_map(
                "%s_%s" % (projection, piece), identity,
                {structure: weight*payload["finite"].get(
                    structure, sp.S.Zero) for structure in STRUCTURES})
            for structure in STRUCTURES:
                # The real delta/plus residues were the only sources not
                # routed through `invariant_endpoint`.  That bridge does TWO
                # things the real side also needs: it supplies the dxi ds23
                # measure factor jac|_{s23=0} (whose omission left the exact
                # (delta,-2) ratio real/virtual at -1/jac instead of -1) and
                # it maps the compact invariants onto the measured frame the
                # virtual and the Eq.(46) counterterms are already written
                # in.  Adding the raw invariant-frame real term to a
                # measured-frame virtual term also mixed two coordinate
                # systems that SymPy has no way to reconcile.
                total[structure] += unify_symbols(mapped[structure],
                                                  symbol_table)
            sources[os.path.basename(path)] = sha256(path)
        vpath = os.path.join(CACHE, "Hqq2_F1_virtual_%s.pkl" % projection)
        virtual = pickle.load(open(vpath, "rb"))
        vsource, expected_hash = virtual_input_hash(projection)
        if (virtual.get("version") != VERSION
                or virtual.get("projection") != projection
                or virtual.get("input_sha256") != expected_hash
                or virtual.get("source_sha256") != sha256(vsource)):
            raise ValueError("unaccepted finite virtual input " + vpath)
        identity = {"kind": "virtual", "projection": projection,
                    "aggregate_sha256": sha256(vpath),
                    "input_sha256": expected_hash,
                    "source_sha256": sha256(vsource)}
        mapped_virtual = checkpointed_endpoint_map(
            "%s_virtual" % projection, identity,
            {"delta": virtual["finite_invariant"]})
        total["delta"] += unify_symbols(mapped_virtual["delta"], symbol_table)
        ct = counterterm_finite(projection)
        for structure in STRUCTURES:
            total[structure] += unify_symbols(ct[structure], symbol_table)
            if total[structure].has(*BAD) or any(
                    symbol.name == "eps" for symbol in
                    total[structure].free_symbols):
                raise ValueError("invalid Hqq finite %s %s" %
                                 (projection, structure))
        projected[projection] = total
        sources[os.path.basename(vpath)] = sha256(vpath)

    xh = x/xi
    sectors = {}
    for structure in STRUCTURES:
        fg, fpp = projected["g"][structure], projected["PP"][structure]
        sectors[structure] = {
            "F1hat": -sp.Rational(1, 2)*fg + 2*xh**2*fpp/Q2,
            "F2hat": -xh*fg + 12*xh**3*fpp/Q2}

    r5 = {}
    for projection in ("g", "PP"):
        path = os.path.join(CACHE, "Hqq_R5_%s.pkl" % projection)
        payload = pickle.load(open(path, "rb"))
        if (payload.get("version") != "hqq-r5-exact-compact-v3"
                or payload.get("projection") != projection
                or payload.get("input_sha256") !=
                   payload.get("current_provenance_sha256")
                or not payload.get(
                    "provisional_pending_cross_channel_gate", False)):
            raise ValueError("unaccepted Hqq R5 input")
        r5[projection] = payload["regular"]
        sources[os.path.basename(path)] = sha256(path)
    symbols = {symbol.name: symbol for expression in r5.values()
               for symbol in expression.free_symbols}
    xh_regular = symbols["Q2"]/(symbols["Q2"] + symbols["R5S"])
    sectors["regular"] = {
        "F1hat": -sp.Rational(1, 2)*r5["g"]
                  + 2*xh_regular**2*r5["PP"]/symbols["Q2"],
        "F2hat": -xh_regular*r5["g"]
                  + 12*xh_regular**3*r5["PP"]/symbols["Q2"]}
    for structure, pair in sectors.items():
        for name, expression in pair.items():
            if expression.has(*BAD) or any(symbol.name == "eps"
                                           for symbol in expression.free_symbols):
                raise ValueError("invalid assembled Hqq %s %s" %
                                 (structure, name))
    output = os.path.join(CACHE, "F12hat_Hqq_provisional.pkl")
    atomic({"version": ASSEMBLY_VERSION, "producer_version": VERSION,
            "channel": "Hqq", "state": "provisional",
            "provisional_pending_summed_level_gate": True,
            "input_provenance_gate": "passed",
            "sectors": sectors, "sources": sources,
            "working_projectors": {
                "F1hat": "-Fg/2 + 2*xh**2*FPP/Q2",
                "F2hat": "-xh*Fg + 12*xh**3*FPP/Q2"}}, output)
    print("HQQ2_F1_ASSEMBLE_DONE", output, flush=True)


def main():
    mode = sys.argv[1]
    if mode == "real":
        run_real(sys.argv[2], sys.argv[3],
                 int(sys.argv[4]) if len(sys.argv) > 4 else 15)
    elif mode == "virtual":
        run_virtual(sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 15)
    elif mode == "assemble":
        assemble()
    else:
        raise SystemExit("mode must be real, virtual, or assemble")


if __name__ == "__main__":
    main()
