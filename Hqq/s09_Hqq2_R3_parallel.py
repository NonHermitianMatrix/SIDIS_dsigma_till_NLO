#!/usr/bin/env python3
"""Hqq rebuild R3: exact, parallel and restartable angular integration.

WS10 (verbatim): gamma* q -> q g g (or q q qbar); |M_{2->3}|^2;
Int |M|^2 dPi3 with dPi3 = s23^{-eps}/(2Pi)^{2-2eps} * 2^{-2} Pi^{-eps}
(Gamma(1-eps)/Gamma(1-2eps)) dbeta1 dbeta2
sin^{1-2eps}beta1 sin^{-2eps}beta2.

The angular map is linear, so every accepted R2 term is an independent unit.
Each successful unit is written atomically with a version and exact R2-source
hash.  Interrupted jobs resume only compatible checkpoints.

The Appendix-F table is used as printed in Eqs. F1-F29 (PDF pages 36-40),
with the independently checked I(2,-3) correction when that master is routed.
The legacy off-table massive helper is deliberately forbidden: it truncates at
O(eps), while an R4 double pole can require O(eps^2).  Encountering that route
fails closed and reports the exact R2 indices instead of emitting a plausible
but incomplete result.
"""
import argparse
import hashlib
import json
import multiprocessing as mp
import os
import pickle
import resource
import signal
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
ROOT = os.path.join(CACHE, "Hqq2_R3_checkpoints")
VERSION = "hqq2-r3-appendixF-v1"
TIMEOUT = int(os.environ.get("HQQ2_R3_TERM_TIMEOUT", "1800"))
MEMORY = int(os.environ.get("HQQ2_R3_WORKER_BYTES", str(7 * 1024**3)))

TARGETS = (
    "MR2gQGG", "MR2PPQGG", "MR2gSF", "MR2PPSF", "MR2gDFA",
    "MR2PPDFA", "MR2gDFB", "MR2PPDFB", "MR2gDFC", "MR2PPDFC",
    "MR2gHGG", "MR2PPHGG",
)
ENGINE_FILES = (
    "Hqq_R3_engine.py", "Hqq_R3_frames.py", "Hqq_R3_angint.py",
    "Hqq_R3_appendixF.py", "Hqq_R3_baseint.py",
)


class TermTimeout(Exception):
    pass


class UnsafeMaster(Exception):
    pass


def _alarm(_signum, _frame):
    raise TermTimeout()


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


_INTEGRATE = None


def _init_worker(memory, allow_massive_o_eps, compact_rational):
    resource.setrlimit(resource.RLIMIT_AS, (memory, memory))
    signal.signal(signal.SIGALRM, _alarm)
    sys.path.insert(0, HERE)
    import Hqq_R3_engine as engine

    def unsafe(*args, **kwargs):
        raise UnsafeMaster("legacy massive off-table route is only O(eps)")

    if not allow_massive_o_eps:
        engine._term_monomial_massive = unsafe
    global _INTEGRATE
    _INTEGRATE = lambda term: engine.angular_integrate(
        term, compact_rational=compact_rational)


def _work(job):
    index, term = job
    signal.alarm(TIMEOUT)
    started = time.time()
    try:
        value = _INTEGRATE(term)
        if value.has(sp.Float):
            return index, "FLOAT", None, time.time() - started
        if value.has(sp.zoo, sp.nan, sp.oo, -sp.oo):
            return index, "NONFINITE", None, time.time() - started
        return index, "OK", value, time.time() - started
    except TermTimeout:
        return index, "TIMEOUT", None, time.time() - started
    except UnsafeMaster as exc:
        return index, "UNSAFE_MASTER:%s" % exc, None, time.time() - started
    except Exception as exc:
        return index, "ERROR:%s:%s" % (type(exc).__name__, exc), None, \
            time.time() - started
    finally:
        signal.alarm(0)


def _source(name):
    path = os.path.join(CACHE, "Hqq2_R2_%s.pkl" % name)
    raw = open(path, "rb").read()
    digest = hashlib.sha256(raw).hexdigest()
    terms = pickle.loads(raw)
    if not isinstance(terms, list):
        raise TypeError("R2 source must be the accepted ordered term list")
    if any(term.atoms(sp.Float) for term in terms):
        raise ValueError("Float in accepted R2 source")
    return path, digest, terms


def _engine_digest():
    digest = hashlib.sha256()
    for name in ENGINE_FILES:
        digest.update(name.encode("ascii"))
        digest.update(open(os.path.join(HERE, name), "rb").read())
    correction = os.path.join(CACHE, "Hqq_R3_I2m3.pkl")
    digest.update(open(correction, "rb").read())
    # The O(eps) terms of I(1,2)/I(2,2) are a GENERATED master-table input, not
    # a module in ENGINE_FILES: `Hqq_R3_appendixF.py` merely imports them.  A
    # run on 2026-08-02 changed only this file and R3 happily reported
    # `resumed=2184 pending=0`, i.e. it reused checkpoints built from the OLD
    # masters.  Hash it exactly like the I2m3 correction above.
    oeps = os.path.join(HERE, "generated", "Hqq_R3_I12_I22_oeps.py")
    if os.path.exists(oeps):
        digest.update(open(oeps, "rb").read())
    return digest.hexdigest()


def _directory(name, digest, engine_digest):
    return os.path.join(ROOT, "%s_%s_%s_%s" %
                        (VERSION, name, digest[:12], engine_digest[:12]))


def _checkpoint(directory, index):
    return os.path.join(directory, "term_%06d.pkl" % index)


def _accepted(path, metadata):
    try:
        with open(path, "rb") as stream:
            value = pickle.load(stream)
        return all(value.get(k) == v for k, v in metadata.items())
    except (OSError, EOFError, pickle.UnpicklingError, AttributeError):
        return False


def _import_compatible_checkpoint(directory, index, base, compatible_engines):
    """Import an exact result made from the same source by a licensed engine.

    The compact-rational path changes only when distributivity is applied; it
    does not change a master or its normalization.  Source and engine hashes
    are checked before an old value is copied atomically into the new engine's
    directory, so completed work survives the optimized replacement.
    """
    parent = os.path.dirname(directory)
    pattern_prefix = "%s_%s_%s_" % (VERSION, base["name"],
                                     base["source_sha256"][:12])
    for leaf in os.listdir(parent):
        if not leaf.startswith(pattern_prefix):
            continue
        candidate = os.path.join(parent, leaf, "term_%06d.pkl" % index)
        try:
            with open(candidate, "rb") as stream:
                payload = pickle.load(stream)
        except (OSError, EOFError, pickle.UnpicklingError, AttributeError):
            continue
        if (payload.get("version") != VERSION or
                payload.get("source_sha256") != base["source_sha256"] or
                payload.get("name") != base["name"] or
                payload.get("index") != index or
                payload.get("engine_sha256") not in compatible_engines or
                payload.get("status") != "accepted"):
            continue
        imported = dict(base, index=index, value=payload["value"],
                        seconds=payload.get("seconds"), status="accepted",
                        imported_engine_sha256=payload["engine_sha256"])
        _atomic_pickle(_checkpoint(directory, index), imported)
        return imported["value"]
    return None


def selftest():
    sys.path.insert(0, HERE)
    from Hqq_R3_frames import ADMV_FRAME, B2INDEP, b2
    for frame, names in B2INDEP.items():
        if any(ADMV_FRAME[frame][name].has(b2) for name in names):
            raise AssertionError("frame beta2-independence failed")
    from Hqq_R3_appendixF import I
    required = {(1, -4), (2, -4), (1, 2), (2, 2), (2, -3)}
    if not required.issubset(I):
        raise AssertionError("Appendix-F table incomplete")
    correction = os.path.join(CACHE, "Hqq_R3_I2m3.pkl")
    if not os.path.exists(correction):
        raise AssertionError("validated I(2,-3) correction is missing")
    # Exact root-ring regression: powers above two were not divided by the
    # legacy structural substitutions and caused 14 PP-Hgg terms to fail.
    from Hqq_R3_angint import (_reduce_ratio, RT, PY, QY, _pyval, _qyval,
                              _pqy, u1, s, t1, Q2, s23)
    kin = {u1: s23 - s - t1 - Q2}
    probes = ((RT**4*PY**4, s23**2*_pyval**2),
              (RT**2*PY**3*QY, s23*_pyval*_pqy),
              (RT**6*PY**2*QY**4, s23**3*_pyval*_qyval**2))
    for raw, expected in probes:
        difference = sp.cancel(sp.together(
            _reduce_ratio(raw) - expected.subs(kin)))
        if difference != 0:
            raise AssertionError("root-ring reduction regression: %s" %
                                 difference)
    print("HQQ2_R3_SELFTEST_PASS appendixF=%d frames=3" % len(I), flush=True)


def run(target, workers):
    name = TARGETS[target - 1]
    # Hgg has no s23 endpoint singularity: its unresolved q-qbar pair would
    # reduce to gamma* g -> g g, whose tree amplitude vanishes.  Its remaining
    # angular collinear pole is at most 1/eps, so the independently validated
    # massive off-table expansion through O(eps) is exactly the depth needed
    # for both its pole and finite coefficients.  R4 must assert the zero
    # endpoint and absence of a double pole before this output is accepted.
    allow_massive_o_eps = name.endswith("HGG")
    compact_rational = name.endswith("HGG")
    source, digest, terms = _source(name)
    engine_digest = _engine_digest()
    directory = _directory(name, digest, engine_digest)
    os.makedirs(directory, exist_ok=True)
    base = {"version": VERSION, "source_sha256": digest,
            "engine_sha256": engine_digest, "target": target,
            "name": name, "term_count": len(terms)}
    completed = {}
    pending = []
    # This is the exact engine running job 14207504 before the compact-rational
    # optimization.  Its accepted per-term outputs are algebraically identical
    # and may be retained.  Older digest 6d40... is deliberately excluded.
    compatible_engines = {
        "87e79ceb08da5f405fd8a03d439a2902f2269fed243d634cae327a8beb286d93",
        # Compact-rational/multinomial engine before the exact high-power
        # RT/PY/QY reducer.  Its 72 accepted PP terms passed the root-free
        # guard and are valid; only the 14 rejected terms need the new reducer.
        "cc3ab77fdb6936bef35c4a650f7e6c9b6e19aedf88ad09470a412b7f2d88ace6",
    }
    for index in range(len(terms)):
        path = _checkpoint(directory, index)
        metadata = dict(base, index=index)
        if _accepted(path, metadata):
            with open(path, "rb") as stream:
                completed[index] = pickle.load(stream)["value"]
        else:
            imported = _import_compatible_checkpoint(
                directory, index, base, compatible_engines)
            if imported is not None:
                completed[index] = imported
            else:
                pending.append(index)
    manifest = dict(base, source=source, state="running", resumed=len(completed),
                    pending=len(pending), started=time.time())
    _atomic_json(os.path.join(directory, "manifest.json"), manifest)
    print("R3_START name=%s terms=%d resumed=%d pending=%d workers=%d timeout=%d" %
          (name, len(terms), len(completed), len(pending), workers, TIMEOUT),
          flush=True)

    failures = []
    done_now = 0
    if pending:
        context = mp.get_context("fork")
        with context.Pool(min(workers, len(pending)), initializer=_init_worker,
                          initargs=(MEMORY, allow_massive_o_eps,
                                    compact_rational),
                          maxtasksperchild=50) as pool:
            jobs = ((index, terms[index]) for index in pending)
            for index, status, value, elapsed in pool.imap_unordered(
                    _work, jobs, chunksize=1):
                if status == "OK":
                    payload = dict(base, index=index, value=value,
                                   seconds=elapsed, status="accepted")
                    _atomic_pickle(_checkpoint(directory, index), payload)
                    completed[index] = value
                    done_now += 1
                    if done_now % 25 == 0 or len(completed) == len(terms):
                        print("R3_CHECKPOINT name=%s durable=%d/%d" %
                              (name, len(completed), len(terms)), flush=True)
                else:
                    failures.append((index, status, elapsed))
                    print("R3_FAIL name=%s index=%d status=%s seconds=%.1f" %
                          (name, index, status, elapsed), flush=True)

    missing = sorted(set(range(len(terms))) - set(completed))
    if failures or missing:
        manifest.update(state="incomplete", failures=failures, missing=missing,
                        durable=len(completed), finished=time.time())
        _atomic_json(os.path.join(directory, "manifest.json"), manifest)
        print("HQQ2_R3_INCOMPLETE name=%s durable=%d/%d failures=%d" %
              (name, len(completed), len(terms), len(failures)), flush=True)
        return 3

    ordered = [completed[index] for index in range(len(terms))]
    result = sp.Add(*ordered)
    if result.has(sp.Float, sp.zoo, sp.nan, sp.oo, -sp.oo):
        raise ValueError("invalid atom in merged R3 output")
    output = os.path.join(CACHE, "Hqq2_R3_%s_ang.pkl" % name)
    _atomic_pickle(output, result)
    manifest.update(state="complete", durable=len(completed), pending=0,
                    output=output, output_terms=len(sp.Add.make_args(result)),
                    finished=time.time())
    _atomic_json(os.path.join(directory, "manifest.json"), manifest)
    print("HQQ2_R3_TARGET_DONE name=%s terms=%d output_terms=%d output=%s" %
          (name, len(terms), len(sp.Add.make_args(result)), output), flush=True)
    return 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=("selftest", "run"))
    parser.add_argument("--target", type=int, choices=range(1, len(TARGETS) + 1))
    parser.add_argument("--workers", type=int, default=1)
    args = parser.parse_args()
    selftest()
    if args.mode == "run":
        if args.target is None:
            parser.error("run requires --target")
        return run(args.target, max(1, args.workers))
    return 0


if __name__ == "__main__":
    sys.exit(main())
