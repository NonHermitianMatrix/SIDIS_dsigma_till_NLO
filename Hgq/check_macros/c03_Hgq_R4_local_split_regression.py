#!/usr/bin/env python3
"""Exact regression for the localized mixed-Add R4 optimization.

Compares the optimized endpoint map with a result previously produced by
the original global-expansion algorithm.  Both the checkpoint and status
file are exact/pickle based; no numerical sampling or floating arithmetic
is used.
"""
import os
import pickle
import time

import sympy as sp

from Hqq_R4_mmaframe import residue_mma


HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'cache')
PIECE = 'MR2PPHGQ'
TERM_INDEX = 16060
STATUS = os.path.join(CACHE, 'Hgq_R4_local_split_regression.status')


def status(text):
    with open(STATUS + '.tmp', 'w', encoding='ascii') as handle:
        handle.write(text + '\n')
    os.replace(STATUS + '.tmp', STATUS)
    print(text, flush=True)


def exact_zero(expr):
    if expr == 0:
        return True
    return sp.cancel(sp.together(expr)) == 0


def main():
    status('RUNNING load exact term and accepted checkpoint')
    angular = pickle.load(open(os.path.join(
        CACHE, 'Hqq_R3_%s_ang.pkl' % PIECE), 'rb'))
    term = sp.Add.make_args(angular)[TERM_INDEX]
    accepted = pickle.load(open(os.path.join(
        CACHE, 'Hqg_R4hot_%s_term_%05d.pkl' %
        (PIECE, TERM_INDEX)), 'rb'))['value']

    status('RUNNING optimized exact endpoint map term=%d' % TERM_INDEX)
    started = time.time()
    candidate = residue_mma(term)
    elapsed = time.time() - started

    status('RUNNING exact class-by-class comparison classes=%d' %
           len(set(accepted) | set(candidate)))
    for key in set(accepted) | set(candidate):
        if not exact_zero(candidate.get(key, 0) - accepted.get(key, 0)):
            status('FAILED class=%r elapsed=%.3fs' % (key, elapsed))
            raise SystemExit(1)
    if any(value.has(sp.Float) for value in candidate.values()):
        status('FAILED Float detected')
        raise SystemExit(1)
    status('PASS exact old-vs-optimized term=%d elapsed=%.3fs' %
           (TERM_INDEX, elapsed))


if __name__ == '__main__':
    main()
