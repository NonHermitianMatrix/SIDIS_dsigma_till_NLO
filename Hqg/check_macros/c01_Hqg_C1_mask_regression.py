#!/usr/bin/env python3
"""Exact regression and measured smoke test for C1 eps-free masking."""
import os
import pickle
import time

import sympy as sp

from Hqg_C1_exact import (CACHE, eps, _factorwise_laurent,
                          _mask_eps_free)


def main():
    print('C1_MASK_REGRESSION loading PP production residue', flush=True)
    payload = pickle.load(open(os.path.join(
        CACHE, 'Hqq_R4prod_MR2PPHQG.pkl'), 'rb'))
    term = sp.Add.make_args(payload['R'][(-2, 0)])[0]
    dep = sp.Mul(*[factor for factor in sp.Mul.make_args(term)
                   if factor.has(eps)])
    masked, backward = _mask_eps_free(dep)
    if masked.xreplace(backward) != dep:
        raise ValueError('eps-free mask does not round-trip exactly')

    # Independent exact identity on the same Gamma/linear-exponent pattern.
    a, c0, c1 = sp.symbols('a c0 c1', nonzero=True)
    probe = (a**(-1 - eps)*sp.gamma(-eps)**2
             / (sp.gamma(-2*eps)*sp.gamma(1 - eps)**2)
             * (1 + sp.pi**2*eps**2/6)*(c0 + c1*eps))
    p_masked, p_backward = _mask_eps_free(probe)
    direct = sp.series(probe, eps, 0, 1).removeO()
    optimized = sp.series(p_masked, eps, 0, 1).removeO().xreplace(
        p_backward)
    if sp.expand(direct - optimized) != 0:
        raise ValueError('masked Laurent regression differs exactly')
    factorwise_probe = _factorwise_laurent(p_masked)
    for power in (-2, -1, 0):
        if sp.expand(direct.coeff(eps, power)
                     - factorwise_probe.get(power, 0)) != 0:
            raise ValueError(
                'factorwise synthetic Laurent coefficient differs exactly')

    t0 = time.time()
    direct_term0 = sp.series(masked, eps, 0, 1).removeO()
    elapsed = time.time() - t0
    print('C1_MASK_REGRESSION timed term0 seconds %.3f' % elapsed,
          flush=True)
    if elapsed > 30:
        raise ValueError('masked term0 remains unexpectedly slow')

    t0 = time.time()
    factorwise_term0 = _factorwise_laurent(masked)
    factor_elapsed = time.time() - t0
    for power in (-2, -1, 0):
        difference = (direct_term0.coeff(eps, power)
                      - factorwise_term0.get(power, 0))
        if sp.cancel(sp.together(difference)) != 0:
            raise ValueError(
                'factorwise production term0 coefficient differs exactly')
    print('C1_FACTORWISE_REGRESSION term0 seconds %.3f' % factor_elapsed,
          flush=True)

    hard_term = sp.Add.make_args(payload['R'][(-2, 0)])[210]
    hard_dep = sp.Mul(*[factor for factor in sp.Mul.make_args(hard_term)
                        if factor.has(eps)])
    hard_masked, hard_backward = _mask_eps_free(hard_dep)
    if hard_masked.xreplace(hard_backward) != hard_dep:
        raise ValueError('hard-term mask does not round-trip exactly')
    t0 = time.time()
    hard_coefficients = _factorwise_laurent(hard_masked)
    hard_elapsed = time.time() - t0
    if not hard_coefficients:
        raise ValueError('hard-term factorwise Laurent result is empty')
    if hard_elapsed > 30:
        raise ValueError('factorwise hard term remains unexpectedly slow')
    print('C1_FACTORWISE_BENCHMARK term210 seconds %.3f' % hard_elapsed,
          flush=True)
    print('HQG_C1_MASK_REGRESSION_PASS', flush=True)


if __name__ == '__main__':
    main()
