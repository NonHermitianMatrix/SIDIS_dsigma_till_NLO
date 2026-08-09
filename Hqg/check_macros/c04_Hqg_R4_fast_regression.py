#!/usr/bin/env python3
"""Exact known-answer regression for the optimized Hqg R4 dispatcher.

Recompute accepted PP-HQG chunk 2 (R3 terms 100:150) with the same exact
kernel and require class-by-class symbolic equality.
"""
import os
import pickle
import sys

import sympy as sp

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from Hqq_R4_mmaframe import residue_mma  # noqa: E402

print('WS10 optimized R4 exact PP-HQG regression', flush=True)
angular = pickle.load(open('cache/Hqq_R3_MR2PPHQG_ang.pkl', 'rb'))
terms = sp.Add.make_args(angular)
got = residue_mma(sp.Add(*terms[100:150]))
reference = pickle.load(open('cache/r4mf_MR2PPHQG_0002.pkl', 'rb'))
if set(got) != set(reference):
    raise ValueError('R4 regression class mismatch')
for key in sorted(got, key=str):
    difference = sp.cancel(sp.together(got[key] - reference[key]))
    if difference != 0:
        raise ValueError('R4 exact regression failed at %s' % (key,))
    print('  %s: EXACT' % (key,), flush=True)
print('HQG_R4_FAST_REGRESSION_PASS', flush=True)
