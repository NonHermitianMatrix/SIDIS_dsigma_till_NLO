# Hqg_V2_relabel.py -- Step V1/V2 for channel Hqg (chn3, gamma* q -> g q with the
# GLUON fragmenting) obtained from the already-renormalized Hqq virtual by the
# relabel proven exactly at LO in python/Hgq_LO_crossing_check.py:
#
#   observed parton k1 -> k2 = p+q-k1   =>   t -> u = -s-t-Q2 at fixed s,
#   incoming parton unchanged => same 1/(2 Nc) average, same p^mu p^nu projector,
#   no crossing sign.  RELABEL CHECK g = RELABEL CHECK PP = 0 at LO.
#
# WHY THE RELABEL MAY BE APPLIED TO THE ALREADY-CONTINUED VIRTUAL.  The +i0
# analytic continuation performed in Hqq_V2_renorm.py is for the physical region
#   s > 0 (timelike, ON the cut),   t < 0 and u < 0 (both spacelike, off it).
# The relabel exchanges t and u -- it maps that region to ITSELF and leaves s
# untouched, so no branch cut is crossed and the continued expression may simply
# be evaluated at the swapped point.  (This is NOT true of the s <-> u crossing
# that produces channel Hgq: that one moves s off the cut, so its continuation
# must be redone from the raw PaVe-reduced form.)
#
# VALIDATION (symbolic, exact in eps): Catani's prediction for the double pole,
#   virt = -(alphas/2pi) (2 CF + CA) |M0|^2 / eps^2 + ...,
# is a statement about the partons' colour charges.  Hqg has the SAME three
# partons as Hqq (incoming quark, outgoing quark, outgoing gluon), so the ratio
#   [eps^-2 coefficient of virt] / [LO hard part]
# must come out the SAME CONSTANT for the relabelled pair as for the original
# pair -- that constant is what the relabel is required to preserve.  A relabel
# that damaged the continuation or the invariant assignment would not.
#
# Inputs : cache/Hqq_V2_virt{G,PP}_ren_inv_sym.pkl  (Hqq_V2_ren_invariant_sym.py)
#          python/generated/Hqq_L2_M2.py            (LO, Hqq_LO_traces.wls)
# Outputs: cache/Hqg_V2_virt{G,PP}_ren_inv_sym.pkl
import os, pickle, sys
HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'cache')
MMA = os.path.join(os.path.dirname(HERE), 'mathematica')
sys.path.insert(0, HERE)
import sympy as sp
from generated.Hqq_L2_M2 import M2g as M2g_qq, M2PP as M2PP_qq


def _polylog_eval_inert(cls, order, argument):
    if argument is sp.S.Zero:
        return sp.S.Zero
    return None


sp.polylog.eval = classmethod(_polylog_eval_inert)

s, t, Q2 = sp.symbols('s t Q2', positive=True)
eps, Nc = sp.symbols('eps Nc')

RELABEL = {t: -s - t - Q2}          # t <-> u at fixed s


def canon(e):
    """Map free symbols onto THIS module's symbol objects, BY NAME.

    Necessary, not cosmetic: sympy symbols with different assumptions are
    DIFFERENT objects.  python/generated/Hqq_L2_M2.py carries assumption-free
    s, t, Q2, while the virtual's pickle (and RELABEL) use positive ones, so
    M2g.xreplace({t: -s-t-Q2}) with a positive `t` is a SILENT NO-OP.  That is
    exactly what happened in job 14144147: the virtual got relabelled, the LO did
    not, and the Catani eps^-2 ratio came out s,t-dependent instead of constant.
    """
    bn = {sym.name: sym for sym in e.free_symbols}
    rep = {}
    for nm, target in (('s', s), ('t', t), ('Q2', Q2), ('eps', eps), ('Nc', Nc)):
        if nm in bn and bn[nm] is not target:
            rep[bn[nm]] = target
    return e.xreplace(rep)


# NOTE (2026-07-25): the eps^-2 extraction is NOT done here.  sympy's series()
# on the renormalized virtual never returned (job 14143139 was killed by its
# 2 h wall with no output).  This stage now only performs the relabel, which is
# a substitution, and exports virt and LO for mathematica/catani_check.wls to
# take the SeriesCoefficient of.
from mma_export import write_m


def main():
    out = {}
    for proj, lo_qq in (('G', M2g_qq), ('PP', M2PP_qq)):
        virt_qq = pickle.load(
            open(os.path.join(
                CACHE, 'Hqq_V2_virt%s_ren_inv_sym.pkl' % proj), 'rb'))
        lo_qq = canon(sp.sympify(lo_qq))
        virt_qq = canon(virt_qq)

        virt_qg = virt_qq.xreplace(RELABEL)
        lo_qg = lo_qq.xreplace(RELABEL)
        # guard against the silent no-op the assumption mismatch caused before
        assert lo_qg != lo_qq, 'RELABEL was a no-op on the LO (symbol mismatch)'
        assert virt_qg != virt_qq, 'RELABEL was a no-op on the virtual'
        if virt_qg.atoms(sp.Float) or lo_qg.atoms(sp.Float):
            raise ValueError('Float atom in exact Hqg V2 relabel')
        if virt_qg.has(sp.zoo, sp.nan, sp.oo, -sp.oo):
            raise ValueError('non-finite atom in exact Hqg virtual')

        output = os.path.join(
            CACHE, 'Hqg_V2_virt%s_ren_inv_sym.pkl' % proj)
        pickle.dump(virt_qg, open(output + '.tmp', 'wb'))
        os.replace(output + '.tmp', output)
        for nm, e in (('virtqq', virt_qq), ('loqq', lo_qq),
                      ('virtqg', virt_qg), ('loqg', lo_qg)):
            write_m(e, os.path.join(
                MMA, 'catani_Hqg%s_%s.m' % (proj, nm)), nm)
        print('%s: exact Hqg virtual/LO relabel exported' % proj,
              flush=True)
        out[proj] = 0
    print('HQG_V2_RELABEL_DONE', flush=True)


if __name__ == '__main__':
    main()
