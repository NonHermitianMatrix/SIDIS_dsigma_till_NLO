#!/usr/bin/env python3
"""Exact Catani double pole for Hgq, requiring no unavailable full PP loop.

C1 needs only the eps^-2 coefficient of the virtual correction.  Catani's
universal double-pole operator depends on the external parton content, which
is {q, qbar, g} for both Hqq and Hgq.  We do not type its normalization from
memory: it is extracted independently from the accepted Hqq g and PP virtual
caches, divided by their independently computed eps=0 LO projections, and
the two exact ratios are required to agree before it is applied to the
independent Hgq LO projections.
"""
import os
import pickle

import sympy as sp

from Hqq_C1_from_r4mf import eps, resolve, virtual_double_pole
from generated.Hqq_L2_M2 import M2g as M2g_qq, M2PP as M2PP_qq
from generated.Hqq_S12_LO_M2 import M2g_gq, M2PP_gq


HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'cache')


def _ratio(proj):
    suffix = 'G' if proj == 'g' else 'PP'
    lo = M2g_qq if proj == 'g' else M2PP_qq
    virtual = pickle.load(open(os.path.join(
        CACHE, 'Hqq_V2_virt%s_ren_inv_sym.pkl' % suffix), 'rb'))
    pole = resolve(virtual_double_pole(virtual))
    lo0 = resolve(sp.sympify(lo)).subs(eps, 0)
    return sp.factor(sp.cancel(sp.together(pole/lo0)))


def universal_ratio():
    ratio_g = _ratio('g')
    ratio_pp = _ratio('PP')
    if sp.cancel(sp.together(ratio_g - ratio_pp)) != 0:
        raise ValueError('Catani ratio differs between Hqq projections')
    if {symbol.name for symbol in ratio_g.free_symbols} - {'Nc', 'gs'}:
        raise ValueError('Catani ratio is not invariant-independent: %s'
                         % ratio_g)
    if ratio_g.atoms(sp.Float):
        raise ValueError('Float in exact Catani ratio')
    return ratio_g


def hgq_virtual_double_pole(proj):
    """Invariant-frame eps^-2 coefficient of the Hgq virtual."""
    if proj not in ('g', 'PP'):
        raise ValueError('projection must be g or PP')
    lo = M2g_gq if proj == 'g' else M2PP_gq
    result = sp.cancel(sp.together(
        universal_ratio()*resolve(sp.sympify(lo)).subs(eps, 0)))
    if result.atoms(sp.Float):
        raise ValueError('Float in exact Hgq Catani double pole')
    if result.has(sp.zoo, sp.nan, sp.oo, -sp.oo):
        raise ValueError('non-finite Hgq Catani double pole')
    return result


if __name__ == '__main__':
    ratio = universal_ratio()
    print('HGQ_CATANI_RATIO %s' % ratio, flush=True)
    for projection in ('PP', 'g'):
        result = hgq_virtual_double_pole(projection)
        print('HGQ_CATANI_%s ops=%d Float=%s' %
              (projection, sp.count_ops(result),
               bool(result.atoms(sp.Float))), flush=True)
    print('HGQ_CATANI_EXACT_PASS', flush=True)
