#!/usr/bin/env python3
"""Exact regression for recovering Hqg C1 v1 pair checkpoints."""
import os
import pickle
import tarfile
import tempfile

import sympy as sp

import Hqg_C1_staged_reduce as reducer


HERE = os.path.dirname(os.path.abspath(__file__))
ARCHIVE = os.path.join(
    HERE, 'cache', 'remote_hqg_c1_pp_checkpoints_14169545.tar.gz')


def exact_zero(expr):
    return sp.cancel(sp.together(expr)) == 0


def main():
    _, terms = reducer._load_real_terms('PP')
    completed_samples = (0, 100, 400, 800)
    failed_samples = (89, 456, 598, 724)
    with tempfile.TemporaryDirectory(prefix='hqg-c1-recovery-') as tmp:
        with tarfile.open(ARCHIVE, 'r:gz') as archive:
            archive.extractall(tmp, filter='data')
        for index in completed_samples:
            path = os.path.join(
                tmp, 'cache',
                'Hqg_C1reduce_PP_L000_I%05d.pkl' % index)
            saved = pickle.load(open(path, 'rb'))
            transported = reducer._hqg_inverse_fast(saved['value'])
            _, _, state, recomputed, elapsed = reducer._reduce_pair(
                (0, index, terms[2*index], terms[2*index + 1], 60))
            if state != 'OK' or not exact_zero(recomputed - transported):
                raise ValueError('completed-pair recovery failed at %d' %
                                 index)
            print('RECOVERY_COMPLETED_PASS pair=%d seconds=%.2f' %
                  (index, elapsed), flush=True)
        for index in failed_samples:
            _, _, state, value, elapsed = reducer._reduce_pair(
                (0, index, terms[2*index], terms[2*index + 1], 60))
            if state != 'OK' or value is None:
                raise ValueError('failed-pair optimization failed at %d' %
                                 index)
            if value.atoms(sp.Float):
                raise ValueError('Float in optimized pair %d' % index)
            print('RECOVERY_TIMEOUT_FIXED pair=%d seconds=%.2f ops=%d' %
                  (index, elapsed, sp.count_ops(value)), flush=True)
    print('HQG_C1_RECOVERY_REGRESSION_PASS', flush=True)


if __name__ == '__main__':
    main()
