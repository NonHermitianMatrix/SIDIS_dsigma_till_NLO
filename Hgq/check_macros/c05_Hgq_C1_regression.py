#!/usr/bin/env python3
"""Exact regression and timing gate for optimized local Hgq C1."""
import os
import pickle
import time

os.environ['C1_CHANNEL'] = 'Hgq'

import sympy as sp

from Hgq_C1_catani import universal_ratio, hgq_virtual_double_pole
from Hqg_C1_exact import (CACHE, eps, _factorwise_laurent,
                          _mask_eps_free, hgq_inverse_endpoint,
                          s_inv, t1_inv)
from Hqq_R4_kinmap import (x, z, Q2, PHT, xi, s23, s_of, t1_of, jac)


STATUS = os.path.join(CACHE, 'Hgq_C1_regression.status')


def status(text):
    with open(STATUS + '.tmp', 'w', encoding='ascii') as handle:
        handle.write(text + '\n')
    os.replace(STATUS + '.tmp', STATUS)
    print(text, flush=True)


def dependent(term):
    return sp.Mul(*[factor for factor in sp.Mul.make_args(term)
                    if factor.has(eps)])


def main():
    status('RUNNING exact Catani projection-independence gate')
    ratio = universal_ratio()
    if {symbol.name for symbol in ratio.free_symbols} - {'Nc', 'gs'}:
        raise ValueError('non-universal Catani ratio')
    if not ratio.has(sp.pi):
        raise ValueError('Catani ratio lost the Pi*virt normalization')
    for projection in ('PP', 'g'):
        pole = hgq_virtual_double_pole(projection)
        if pole.atoms(sp.Float):
            raise ValueError('Float in Hgq virtual double pole')

    status('RUNNING exact inverse endpoint-map gate')
    xi_inverse = x*(Q2 + s_inv)/Q2
    pht2_inverse = -s_inv*t1_inv*z**2/(Q2 + s_inv + t1_inv)
    s_roundtrip = sp.cancel(sp.together(
        s_of.subs(xi, xi_inverse) - s_inv))
    t_roundtrip = sp.cancel(sp.together(
        t1_of.subs(s23, 0).subs(xi, xi_inverse)
        .subs(PHT**2, pht2_inverse) - t1_inv))
    if s_roundtrip != 0 or t_roundtrip != 0:
        raise ValueError('inverse endpoint map does not round-trip exactly')

    for projection in ('PP', 'g'):
        status('RUNNING %s production term regression' % projection)
        payload = pickle.load(open(os.path.join(
            CACHE, 'Hqq_R4prod_MR2%sHGQ.pkl' % projection), 'rb'))
        terms = sp.Add.make_args(payload['R'][(-2, 0)])
        term0 = dependent(terms[0])
        masked, backward = _mask_eps_free(term0)
        if masked.xreplace(backward) != term0:
            raise ValueError('%s mask round trip failed' % projection)
        direct = sp.series(masked, eps, 0, 1).removeO()
        optimized = _factorwise_laurent(masked)
        for power in (-2, -1, 0):
            difference = (direct.coeff(eps, power)
                          - optimized.get(power, 0))
            if sp.cancel(sp.together(difference)) != 0:
                raise ValueError(
                    '%s factorwise coefficient differs at eps^%d'
                    % (projection, power))

        probe = dependent(terms[min(210, len(terms) - 1)])
        probe_masked, probe_backward = _mask_eps_free(probe)
        if probe_masked.xreplace(probe_backward) != probe:
            raise ValueError('%s benchmark mask round trip failed'
                             % projection)
        started = time.time()
        result = _factorwise_laurent(probe_masked)
        elapsed = time.time() - started
        if not result:
            raise ValueError('%s benchmark Laurent result empty'
                             % projection)
        if elapsed > 30:
            raise ValueError('%s benchmark unexpectedly slow: %.3fs'
                             % (projection, elapsed))
        status('PASS %s exact term210 benchmark=%.3fs' %
               (projection, elapsed))

        # The optimized frame change must retain exact symbolic values and
        # remove the measured convolution variable xi.
        sample = hgq_inverse_endpoint(terms[0])
        if sample.atoms(sp.Float) or any(symbol.name == 'xi'
                                        for symbol in sample.free_symbols):
            raise ValueError('%s inverse-frame exactness gate failed'
                             % projection)
    status('HGQ_C1_REGRESSION_PASS')


if __name__ == '__main__':
    main()
