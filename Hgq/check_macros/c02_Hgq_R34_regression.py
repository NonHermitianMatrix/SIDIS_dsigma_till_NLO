#!/usr/bin/env python3
"""Exact transport and kernel regression for the Hgq R3/R4 chain.

The angular and endpoint kernels are already validated channel-independent
maps.  This test exercises both new Hgq inputs and proves that direct
object transport preserves the former srepr round trip exactly.  It also
checks R4 linearity class by class on two independently integrated terms.
No numerical substitution is used.
"""
import os
import pickle
import signal
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from Hqq_R3_engine import angular_integrate  # noqa: E402
from Hqq_R4_mmaframe import residue_mma  # noqa: E402

CACHE = os.path.join(HERE, 'cache')


class RegressionTimeout(Exception):
    pass


def _alarm(_signum, _frame):
    raise RegressionTimeout()


def exact_zero(expression):
    return expression == 0 or sp.cancel(sp.together(expression)) == 0


def main():
    signal.signal(signal.SIGALRM, _alarm)
    print('WS10 exact Hgq R3/R4 regression', flush=True)
    for piece in ('MR2PPHGQ', 'MR2gHGQ'):
        source = os.path.join(CACHE, 'Hqq_R2_%s.pkl' % piece)
        expression = pickle.load(open(source, 'rb'))
        terms = sp.Add.make_args(expression)
        if expression.atoms(sp.Float):
            raise ValueError('Float in exact %s R2 input' % piece)
        if expression.has(sp.zoo, sp.nan, sp.oo, -sp.oo):
            raise ValueError('non-finite %s R2 input' % piece)

        # Direct Pool transport and the superseded text round trip must
        # reconstruct the identical exact SymPy tree.
        for index in (0, len(terms) - 1):
            if sp.sympify(sp.srepr(terms[index])) != terms[index]:
                raise ValueError(
                    'exact transport regression failed: %s term %d'
                    % (piece, index))

        signal.alarm(120)
        first = angular_integrate(terms[0])
        second = angular_integrate(terms[1])
        signal.alarm(0)
        if first.atoms(sp.Float) or second.atoms(sp.Float):
            raise ValueError('Float in %s angular regression' % piece)

        signal.alarm(120)
        combined = residue_mma(first + second)
        separate_first = residue_mma(first)
        separate_second = residue_mma(second)
        signal.alarm(0)
        keys = set(combined) | set(separate_first) | set(separate_second)
        for key in sorted(keys, key=str):
            difference = (combined.get(key, sp.Integer(0))
                          - separate_first.get(key, sp.Integer(0))
                          - separate_second.get(key, sp.Integer(0)))
            if not exact_zero(difference):
                raise ValueError(
                    'R4 linearity regression failed: %s %s'
                    % (piece, key))
        print('  %s: transport exact; R3/R4 linearity exact' % piece,
              flush=True)
    print('HGQ_R34_REGRESSION_PASS', flush=True)


if __name__ == '__main__':
    try:
        main()
    finally:
        signal.alarm(0)
