#!/usr/bin/env python3
"""Exact, checkpointed Hgg R4 endpoint gate in the invariant hard frame.

For Hgg the s23 -> 0 reduced process is gamma* g -> g g, absent at tree
level.  Consequently every Residue/Deep/Odd endpoint class must cancel exactly.
The licensed Laurent engine extracts the classes term-linearly; only the small
class merge is rationally reduced at the end.
"""
import argparse
import hashlib
import json
import multiprocessing as mp
import os
import pickle
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'cache')
VERSION = 'hgg-r4-endpoint-v1'
ENGINE = ('Hqq_R4_mmaframe.py', 'Hqq_R4_fastlaurent.py',
          'Hqq_R4_expand.py', 'Hqq_R4_kinmap.py')


def digest_files(paths):
    value = hashlib.sha256()
    for path in paths:
        value.update(os.path.basename(path).encode('ascii'))
        value.update(open(path, 'rb').read())
    return value.hexdigest()


def atomic_pickle(path, value):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    temporary = '%s.tmp.%d' % (path, os.getpid())
    with open(temporary, 'wb') as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush(); os.fsync(stream.fileno())
    os.replace(temporary, path)


def atomic_json(path, value):
    temporary = '%s.tmp.%d' % (path, os.getpid())
    with open(temporary, 'w') as stream:
        json.dump(value, stream, indent=2, sort_keys=True)
        stream.write('\n'); stream.flush(); os.fsync(stream.fileno())
    os.replace(temporary, path)


_RESIDUE = None
_FRAME_MODULE = None


def init_worker():
    global _RESIDUE, _FRAME_MODULE
    sys.path.insert(0, HERE)
    import Hqq_R4_mmaframe as frame
    _FRAME_MODULE = frame
    _RESIDUE = frame.residue_mma


def work(job):
    index, terms, path, metadata = job
    if os.path.exists(path):
        try:
            old = pickle.load(open(path, 'rb'))
            if all(old.get(key) == value for key, value in metadata.items()):
                return index, True, path
        except (OSError, EOFError, pickle.UnpicklingError, AttributeError):
            pass
    # Run term-linearly, exactly as residue_mma itself does, so a mapped-zero
    # term cannot abort its seven neighbours.  The engine's masked polynomial
    # pivot raises StopIteration precisely when a rational factor's numerator
    # has no nonzero coefficient.  Before dropping such a term, prove the
    # complete mapped term is exactly zero by rational normalization.
    result = {}
    mapped_zeros = 0
    for term in terms:
        try:
            partial = _RESIDUE(term)
        except StopIteration:
            mapped = _FRAME_MODULE.to_invariant_frame(
                _FRAME_MODULE.abs_free(term))
            if sp.cancel(sp.together(mapped)) != 0:
                raise
            partial = {}
            mapped_zeros += 1
        for key, value in partial.items():
            result[key] = result.get(key, sp.Integer(0)) + value
    atomic_pickle(path, dict(metadata, classes=result, state='accepted',
                             mapped_zero_terms=mapped_zeros))
    return index, False, path


def work_shard(jobs):
    """Run one explicit checkpoint shard without multiprocessing IPC.

    Hoffman2's ``Pool`` result collector twice returned truncated/``None``
    payloads after the workers had performed valid writes.  R4 is term-linear
    and the files are already the durable interface, so transporting SymPy
    results (or even completion tuples) back through a shared result queue is
    unnecessary.  Each child loads the Laurent engine once, writes its own
    disjoint atomic files, and communicates success only through its exit
    status plus the parent's metadata validation.
    """
    init_worker()
    for job in jobs:
        work(job)


def accepted(path, metadata):
    try:
        with open(path, 'rb') as stream:
            payload = pickle.load(stream)
        return (payload.get('state') == 'accepted' and
                all(payload.get(key) == value
                    for key, value in metadata.items()))
    except (OSError, EOFError, pickle.UnpicklingError, AttributeError):
        return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('piece', choices=('MR2gHGG', 'MR2PPHGG'))
    parser.add_argument('--workers', type=int, default=16)
    parser.add_argument('--chunk-size', type=int, default=8)
    args = parser.parse_args()
    source = os.path.join(CACHE, 'Hqq2_R3_%s_ang.pkl' % args.piece)
    source_sha = hashlib.sha256(open(source, 'rb').read()).hexdigest()
    engine_sha = digest_files([os.path.join(HERE, name) for name in ENGINE])
    expression = pickle.load(open(source, 'rb'))
    terms = list(sp.Add.make_args(expression))
    root = os.path.join(CACHE, 'Hgg_R4_checkpoints',
                        '%s_%s_%s_%s_c%d' %
                        (VERSION, args.piece, source_sha[:12], engine_sha[:12],
                         args.chunk_size))
    os.makedirs(root, exist_ok=True)
    base = {'version': VERSION, 'piece': args.piece,
            'source_sha256': source_sha, 'engine_sha256': engine_sha,
            'chunk_size': args.chunk_size}
    jobs = []
    for index, start in enumerate(range(0, len(terms), args.chunk_size)):
        stop = min(start + args.chunk_size, len(terms))
        path = os.path.join(root, 'chunk_%05d.pkl' % index)
        meta = dict(base, index=index, start=start, stop=stop)
        jobs.append((index, terms[start:stop], path, meta))
    atomic_json(os.path.join(root, 'manifest.json'),
                dict(base, state='running', terms=len(terms), chunks=len(jobs),
                     started=time.time()))
    print('HGG_R4_START piece=%s terms=%d chunks=%d workers=%d' %
          (args.piece, len(terms), len(jobs), args.workers), flush=True)
    pending = [job for job in jobs if not accepted(job[2], job[3])]
    print('HGG_R4_PENDING piece=%s durable=%d/%d' %
          (args.piece, len(jobs) - len(pending), len(jobs)), flush=True)
    if pending:
        nproc = min(args.workers, len(pending))
        shards = [pending[offset::nproc] for offset in range(nproc)]
        ctx = mp.get_context('fork')
        processes = [ctx.Process(target=work_shard, args=(shard,))
                     for shard in shards]
        for process in processes:
            process.start()
        for process in processes:
            process.join()
        exits = [process.exitcode for process in processes]
        print('HGG_R4_SHARDS piece=%s workers=%d exits=%s' %
              (args.piece, nproc, exits), flush=True)
        if any(code != 0 for code in exits):
            print('HGG_R4_WORKER_FAIL piece=%s exits=%s' %
                  (args.piece, exits), flush=True)
    missing = [path for _index, _terms, path, meta in jobs
               if not accepted(path, meta)]
    if missing:
        print('HGG_R4_INCOMPLETE piece=%s durable=%d/%d missing=%d' %
              (args.piece, len(jobs) - len(missing), len(jobs), len(missing)),
              flush=True)
        return 3
    merged = {}
    for _index, _terms, path, meta in jobs:
        payload = pickle.load(open(path, 'rb'))
        if not all(payload.get(key) == value for key, value in meta.items()):
            raise AssertionError('unaccepted checkpoint %s' % path)
        for key, value in payload['classes'].items():
            merged[key] = merged.get(key, sp.Integer(0)) + value
    nonzero = {}
    for key, value in merged.items():
        reduced = sp.cancel(sp.together(value))
        if reduced != 0:
            nonzero[key] = reduced
    output = os.path.join(CACHE, 'Hgg_R4_%s.pkl' % args.piece)
    payload = dict(base, state='accepted' if not nonzero else 'rejected',
                   endpoint_classes=merged, nonzero_classes=nonzero,
                   algebra='s23->0 reduced tree gamma*g->gg = 0')
    atomic_pickle(output, payload)
    atomic_json(os.path.join(root, 'manifest.json'),
                dict(base, state=payload['state'], terms=len(terms),
                     chunks=len(jobs), output=output, finished=time.time(),
                     nonzero_classes=[str(key) for key in nonzero]))
    if nonzero:
        print('HGG_R4_ENDPOINT_FAIL piece=%s classes=%s' %
              (args.piece, sorted(map(str, nonzero))), flush=True)
        return 2
    print('HGG_R4_ENDPOINT_ZERO piece=%s classes=%d output=%s' %
          (args.piece, len(merged), output), flush=True)
    return 0


if __name__ == '__main__':
    sys.exit(main())
