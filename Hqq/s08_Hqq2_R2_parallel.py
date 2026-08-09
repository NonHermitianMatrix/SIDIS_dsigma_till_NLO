"""Hqq rebuild R2: exact, parallel, resumable partial fractioning.

The R1 exports are already one rational function with an expanded polynomial
numerator and a common monomial denominator.  Expanding the *numerator* into
its existing monomials is therefore the natural unit of work.  Calling
``together/cancel/factor_list`` on the whole fraction (or after every split)
recreates the enormous common denominator and is deliberately forbidden here.

Each numerator monomial is first cancelled against the common ADMV powers.
The remaining denominator is represented only by its six integer exponents.
The section-6 2AR/3AR reductions then act on that six-integer signature.  A
memoized dynamic program combines identical branches, turning the old
combinatorial tree into a small polynomial-size table.

Every completed numerator chunk is written atomically.  Reruns accept only
checkpoints carrying the same version and SHA256 of the exact R1 source, so a
stopped or preempted job resumes without silently mixing inputs.
"""
from __future__ import print_function

import argparse
import hashlib
import importlib
import json
import multiprocessing as mp
import os
import pickle
import sys
import time
from functools import lru_cache

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
GEN = os.path.join(HERE, "generated")
CACHE = os.path.join(HERE, "cache", "Hqq2_R2_checkpoints")
VERSION = "sidis-r2-signature-v2"
CHUNK_SIZE = 100

sys.path.insert(0, HERE)
import Hqq2_bookkeeping as bk  # noqa: E402

s, t1, t2, t3 = bk.s, bk.t1, bk.t2, bk.t3
u1, u2, u3 = bk.u1, bk.u2, bk.u3
s12, s13, s23, Q2 = bk.s12, bk.s13, bk.s23, bk.Q2
eps, Nc, nf, ee, eq, eqp, gs = (bk.eps, bk.Nc, bk.nf, bk.ee, bk.eq,
                                bk.eqp, bk.gs)

ADMV = (t2, t3, u2, u3, s12, s13)
AI = {a: i for i, a in enumerate(ADMV)}
SYMPIFY_LOCALS = {a.name: a for a in
                  (s, t1, t2, t3, u1, u2, u3, s12, s13, s23, Q2,
                   eps, Nc, nf, ee, eq, eqp, gs)}

TARGETS = (
    ("Hqq2_R1_qgg", "MR2gQGG"),
    ("Hqq2_R1_qgg", "MR2PPQGG"),
    ("Hqq2_R1_sameflavor", "MR2gSF"),
    ("Hqq2_R1_sameflavor", "MR2PPSF"),
    ("Hqq2_R1_pairs", "MR2gDFA"),
    ("Hqq2_R1_pairs", "MR2PPDFA"),
    ("Hqq2_R1_pairs", "MR2gDFB"),
    ("Hqq2_R1_pairs", "MR2PPDFB"),
    ("Hqq2_R1_pairs", "MR2gDFC"),
    ("Hqq2_R1_pairs", "MR2PPDFC"),
    ("Hgg_R1", "M2g"),
    ("Hgg_R1", "M2PP"),
)

OUTPUT_NAMES = {
    ("Hgg_R1", "M2g"): "MR2gHGG",
    ("Hgg_R1", "M2PP"): "MR2PPHGG",
}

# Same-type 2ARs: a+b=value.  The auxiliary-denominator index is 0..2.
SAME = (
    (AI[t2], AI[t3], u1 - s23 - Q2),
    (AI[u2], AI[u3], t1 - s23),
    (AI[s12], AI[s13], s - s23),
)

# All eight 3ARs, generated from the constraint surface.  For one s-, t-,
# and u-type ADMV, c_s*svar+c_t*tvar+c_u*uvar is angle independent.
SURFACE = {
    u1: s23 - s - t1 - Q2,
    t3: -s - t1 - 2 * Q2 - t2,
    u3: t1 - u2 - s23,
    s13: s + t2 + u2 + Q2,
    s12: -s23 - t2 - u2 - Q2,
}


def _linear_vector(x):
    y = sp.expand(x.xreplace(SURFACE))
    return int(y.coeff(t2)), int(y.coeff(u2))


TRIPLES = []
for sv in (s12, s13):
    for tv in (t2, t3):
        for uv in (u2, u3):
            vs, vt, vu = _linear_vector(sv), _linear_vector(tv), _linear_vector(uv)
            ct = -vs[0] // vt[0]
            cu = -vs[1] // vu[1]
            val = sp.expand((sv + ct * tv + cu * uv).xreplace(SURFACE))
            if val.has(t2) or val.has(u2):
                raise RuntimeError("failed to construct angle-independent 3AR")
            TRIPLES.append(((AI[sv], 1), (AI[tv], ct), (AI[uv], cu), val))
TRIPLES = tuple(TRIPLES)
AUX_VALUES = tuple(x[2] for x in SAME) + tuple(x[3] for x in TRIPLES)


def _prove_local_relations():
    """Exact O(1) proof obligations used by every recursive R2 rewrite."""
    for ia, ib, value in SAME:
        relation = sp.expand((ADMV[ia] + ADMV[ib] - value).xreplace(SURFACE))
        if relation != 0:
            raise AssertionError("invalid 2AR: %s" % relation)
    for entries in TRIPLES:
        relation = sum(coefficient * ADMV[index]
                       for index, coefficient in entries[:3]) - entries[3]
        relation = sp.expand(relation.xreplace(SURFACE))
        if relation != 0:
            raise AssertionError("invalid 3AR: %s" % relation)


def _atomic_pickle(path, value):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    temporary = "%s.tmp.%d" % (path, os.getpid())
    with open(temporary, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


def _atomic_json(path, value):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    temporary = "%s.tmp.%d" % (path, os.getpid())
    with open(temporary, "w") as stream:
        json.dump(value, stream, indent=2, sort_keys=True)
        stream.write("\n")
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


@lru_cache(maxsize=None)
def reduce_signature(signature):
    """Return {(final_signature, auxiliary_powers): integer coefficient}."""
    sig = tuple(signature)
    # Rule (i) first, exactly as in reference section 6.
    for aux, (ia, ib, _value) in enumerate(SAME):
        if sig[ia] and sig[ib]:
            total = {}
            for drop in (ia, ib):
                child = list(sig)
                child[drop] -= 1
                for (final, powers), coefficient in reduce_signature(tuple(child)).items():
                    powers = list(powers)
                    powers[aux] += 1
                    key = (final, tuple(powers))
                    total[key] = total.get(key, 0) + coefficient
            return {k: v for k, v in total.items() if v}

    # With same-type pairs gone there is at most one live member of each type.
    for j, triple in enumerate(TRIPLES):
        entries = triple[:3]
        if all(sig[index] for index, _coefficient in entries):
            total = {}
            for drop, branch_coefficient in entries:
                child = list(sig)
                child[drop] -= 1
                for (final, powers), coefficient in reduce_signature(tuple(child)).items():
                    powers = list(powers)
                    powers[3 + j] += 1
                    key = (final, tuple(powers))
                    total[key] = total.get(key, 0) + branch_coefficient * coefficient
            return {k: v for k, v in total.items() if v}

    zero_aux = (0,) * len(AUX_VALUES)
    return {(sig, zero_aux): 1}


def _power(expr, symbol):
    value = sp.sympify(expr.as_powers_dict().get(symbol, 0))
    if not value.is_Integer:
        raise ValueError("non-integer power %s of %s" % (value, symbol))
    return int(value)


def _split_common_fraction(expr):
    """Return (numerator monomials, ADMV common powers, other denominator)."""
    numerator, denominator = expr.as_numer_denom()
    common = tuple(_power(denominator, a) for a in ADMV)
    other = denominator
    for a, exponent in zip(ADMV, common):
        if exponent:
            other = other / a ** exponent
    # R1 stores ``prefactor * (expanded polynomial) / common_denominator``.
    # The numerator is therefore a Mul whose one Add child contains the real
    # work; global ``expand`` would needlessly copy the full expression.
    if numerator.func is sp.Add:
        terms = tuple(numerator.args)
    elif numerator.func is sp.Mul:
        additive = [a for a in numerator.args if a.func is sp.Add]
        if additive:
            # SF/DF also carry small factored color/charge polynomials such as
            # (Nc-1)(Nc+1).  The expanded matrix-element polynomial is the
            # unique Add with by far the most summands.  Distribute only that
            # child; keep every small Add in the exact outside prefactor.
            ranked = sorted(additive, key=lambda a: len(a.args), reverse=True)
            polynomial = ranked[0]
            if len(ranked) > 1 and len(ranked[0].args) == len(ranked[1].args):
                raise ValueError("ambiguous expanded numerator polynomial")
            outside = sp.Mul(*(a for a in numerator.args if a is not polynomial))
            terms = tuple(outside * term for term in polynomial.args)
        else:
            terms = (numerator,)
    else:
        terms = (numerator,)
    return tuple(terms), common, other


def _cancel_signature(term, common):
    sig = []
    reduced = term
    for a, denominator_power in zip(ADMV, common):
        numerator_power = max(0, _power(term, a))
        cancel = min(denominator_power, numerator_power)
        sig.append(denominator_power - cancel)
        if cancel:
            reduced = reduced / a ** cancel
    return reduced, tuple(sig)


def _build_output(numerator, other_denominator, reduction):
    out = []
    for (signature, auxiliary), coefficient in reduction.items():
        denominator = other_denominator
        for a, exponent in zip(ADMV, signature):
            if exponent:
                denominator *= a ** exponent
        for value, exponent in zip(AUX_VALUES, auxiliary):
            if exponent:
                denominator *= value ** exponent
        out.append(coefficient * numerator / denominator)
    return out


def _validate_reduction(signature, reduction):
    """Check the recursively constructed, locally proven reduction."""
    lhs = sp.prod(a ** (-e) for a, e in zip(ADMV, signature))
    rhs = sp.Integer(0)
    for (final, auxiliary), coefficient in reduction.items():
        term = sp.Integer(coefficient)
        term *= sp.prod(a ** (-e) for a, e in zip(ADMV, final))
        term *= sp.prod(v ** (-e) for v, e in zip(AUX_VALUES, auxiliary))
        rhs += term
        if sum(e > 0 for e in final) > 2:
            raise AssertionError("noncanonical final signature %r" % (final,))
    # Correctness is exact by induction: reduce_signature performs only
    # multiplication by (a+b)/value or by sum(c_i*a_i)/value, and all eleven
    # such local identities are proved exactly by _prove_local_relations().
    # Independent rational points guard the output assembly and bookkeeping.
    samples = (
        {s: 11, s23: 2, t1: 11, t2: 3, u2: 5, Q2: 13},
        {s: 17, s23: 3, t1: 13, t2: 2, u2: 7, Q2: 19},
        {s: 23, s23: 5, t1: 17, t2: 7, u2: 3, Q2: 29},
    )
    for sample in samples:
        left = lhs.xreplace(SURFACE).subs(sample)
        right = rhs.xreplace(SURFACE).subs(sample)
        if left.has(sp.zoo, sp.nan) or right.has(sp.zoo, sp.nan):
            raise AssertionError("validation sample hit a pole")
        if left != right:
            raise AssertionError("R2 signature identity failed: %r" % (signature,))


def _source(target):
    module_name, expression_name = TARGETS[target - 1]
    sys.path.insert(0, GEN)
    module = importlib.import_module(module_name)
    raw = getattr(module, expression_name)
    digest = hashlib.sha256(raw.encode("utf-8")).hexdigest()
    # rational=True converts the FortranForm 0.5/0.25 literals back to exact
    # rationals at the ingestion boundary.  No Float may survive the handoff.
    expr = sp.sympify(raw, locals=SYMPIFY_LOCALS, rational=True)
    expr = bk.canon(expr, expression_name)
    output_name = OUTPUT_NAMES.get((module_name, expression_name), expression_name)
    return module_name, output_name, digest, expr


def _checkpoint_dir(name, digest, chunk_size):
    # Chunk geometry is part of the namespace, so changing parallel granularity
    # never overwrites otherwise valid completed work.
    return os.path.join(CACHE, "%s_%s_%s_c%d" %
                        (VERSION, name, digest[:16], chunk_size))


def _checkpoint_path(directory, index):
    return os.path.join(directory, "chunk_%06d.pkl" % index)


def _accepted(path, metadata):
    try:
        with open(path, "rb") as stream:
            value = pickle.load(stream)
        return all(value.get(k) == v for k, v in metadata.items())
    except (OSError, EOFError, pickle.UnpicklingError, AttributeError):
        return False


_WORK = None


def _init_worker(terms, common, other, directory, base_metadata):
    global _WORK
    _WORK = (terms, common, other, directory, base_metadata)


def _run_chunk(job):
    index, start, stop = job
    terms, common, other, directory, base = _WORK
    path = _checkpoint_path(directory, index)
    metadata = dict(base, chunk=index, start=start, stop=stop)
    if _accepted(path, metadata):
        return index, True, 0, path
    output = []
    signatures = set()
    for term in terms[start:stop]:
        numerator, signature = _cancel_signature(term, common)
        reduction = reduce_signature(signature)
        if signature not in signatures:
            _validate_reduction(signature, reduction)
            signatures.add(signature)
        output.extend(_build_output(numerator, other, reduction))
    if any(x.atoms(sp.Float) for x in output):
        raise AssertionError("Float entered R2 output")
    payload = dict(metadata, output=output,
                   input_terms=stop - start, output_terms=len(output),
                   signatures=tuple(sorted(signatures)))
    _atomic_pickle(path, payload)
    return index, False, len(output), path


def selftest():
    _prove_local_relations()
    tests = (
        (1, 1, 0, 0, 0, 0),
        (0, 0, 1, 1, 0, 0),
        (0, 0, 0, 0, 1, 1),
        (2, 3, 1, 2, 2, 3),
        (1, 0, 1, 0, 0, 1),
        (0, 1, 0, 1, 1, 0),
    )
    for signature in tests:
        _validate_reduction(signature, reduce_signature(signature))
    print("HQQ2_R2_PARALLEL_SELFTEST_PASS signatures=%d triples=%d" %
          (len(tests), len(TRIPLES)), flush=True)


def run(target, workers, chunk_size):
    started = time.time()
    module, name, digest, expr = _source(target)
    terms, common, other = _split_common_fraction(expr)
    directory = _checkpoint_dir(name, digest, chunk_size)
    os.makedirs(directory, exist_ok=True)
    base = {"version": VERSION, "source_sha256": digest, "target": target,
            "module": module, "name": name, "chunk_size": chunk_size}
    jobs = []
    for index, start in enumerate(range(0, len(terms), chunk_size)):
        jobs.append((index, start, min(start + chunk_size, len(terms))))
    pending = []
    resumed = 0
    for index, start, stop in jobs:
        metadata = dict(base, chunk=index, start=start, stop=stop)
        if _accepted(_checkpoint_path(directory, index), metadata):
            resumed += 1
        else:
            pending.append((index, start, stop))
    manifest = dict(base, input_terms=len(terms), common_admv_powers=common,
                    chunks=len(jobs), resumed=resumed, pending=len(pending),
                    state="running", started=time.time())
    _atomic_json(os.path.join(directory, "manifest.json"), manifest)
    print("R2_START name=%s terms=%d common=%s chunks=%d resumed=%d pending=%d workers=%d" %
          (name, len(terms), common, len(jobs), resumed, len(pending), workers),
          flush=True)

    if pending:
        context = mp.get_context("fork")
        pool_size = min(workers, len(pending))
        with context.Pool(pool_size, initializer=_init_worker,
                          initargs=(terms, common, other, directory, base)) as pool:
            for index, was_resumed, count, _path in pool.imap_unordered(_run_chunk, pending):
                print("R2_CHECKPOINT name=%s chunk=%d output_terms=%d resumed=%s" %
                      (name, index, count, was_resumed), flush=True)

    combined = []
    total_input = 0
    for index, start, stop in jobs:
        path = _checkpoint_path(directory, index)
        metadata = dict(base, chunk=index, start=start, stop=stop)
        if not _accepted(path, metadata):
            raise RuntimeError("missing/unaccepted checkpoint %s" % path)
        with open(path, "rb") as stream:
            payload = pickle.load(stream)
        combined.extend(payload["output"])
        total_input += payload["input_terms"]
    if total_input != len(terms):
        raise AssertionError("chunk coverage mismatch")
    if max((sum(_power(x.as_numer_denom()[1], a) > 0 for a in ADMV)
            for x in combined), default=0) > 2:
        raise AssertionError("merged R2 output is not canonical")
    output = os.path.join(HERE, "cache", "Hqq2_R2_%s.pkl" % name)
    _atomic_pickle(output, combined)
    manifest.update(state="complete", finished=time.time(), output=output,
                    output_terms=len(combined), pending=0)
    _atomic_json(os.path.join(directory, "manifest.json"), manifest)
    print("HQQ2_R2_TARGET_DONE name=%s input_terms=%d output_terms=%d seconds=%.1f output=%s" %
          (name, len(terms), len(combined), time.time() - started, output), flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("selftest", "run"))
    parser.add_argument("--target", type=int, choices=range(1, len(TARGETS) + 1))
    parser.add_argument("--workers", type=int, default=1)
    parser.add_argument("--chunk-size", type=int, default=CHUNK_SIZE)
    args = parser.parse_args()
    if args.mode == "selftest":
        selftest()
    else:
        if args.target is None:
            parser.error("run requires --target")
        selftest()
        run(args.target, max(1, args.workers), max(1, args.chunk_size))


if __name__ == "__main__":
    main()
