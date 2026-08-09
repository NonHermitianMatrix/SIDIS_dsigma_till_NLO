#!/usr/bin/env python3
"""Exact regression for the optimized k=-2 production endpoint map."""
import os
import pickle

import sympy as sp

from Hqq_R4_kinmap import jac, s23
from Hqq_R4mf_to_prod import (
    JAC0, _exact_rationals, _map_by_name, _map_by_name_at_zero)

CACHE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'cache')


def main():
    source = os.path.join(CACHE, 'Hqq_R4mf_MR2gHQG.pkl')
    print('BRIDGE_REGRESSION loading validated R4mf', flush=True)
    data = pickle.load(open(source, 'rb'))
    terms = sp.Add.make_args(data[('Residue', 0, 0)])
    # Exercise both a light front term and a term adjacent to the measured
    # heavy interval.  This is an identity check, never a numerical sample.
    for index in (0, 2361):
        print('BRIDGE_REGRESSION exact term %d' % index, flush=True)
        term = _exact_rationals(terms[index])
        former = (jac*_map_by_name(term)).subs(s23, 0)
        optimized = JAC0*_map_by_name_at_zero(term)
        if former != optimized:
            delta = sp.cancel(sp.together(former - optimized))
            if delta != 0:
                raise ValueError(
                    'optimized endpoint map differs at term %d' % index)
        _exact_rationals(optimized)
    print('HQG_R4_BRIDGE_ENDPOINT_REGRESSION_PASS', flush=True)


if __name__ == '__main__':
    main()
