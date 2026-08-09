#!/usr/bin/env python3
"""chn3 (Hqg) real amplitude = chn2's QGG with the observed parton relabeled
quark->gluon (k1<->k2): {t1<->t2, u1<->u2, s13<->s23}.
Same |M|^2 for gamma* q -> q g g, different fragmenting parton.

IDENTICAL-PARTICLE FACTOR -- THE WHOLE REASON THIS FILE EXISTS
--------------------------------------------------------------
`mathematica/Hqq_NLO_R1_qgg_traces.wls` line 165 bakes a 1/2! into QGG:

    (* averages + couplings + 1/2! identical gluons; n = 4 - 2 eps *)

That is CORRECT for Hqq;gg, where the QUARK is observed and the two
UNOBSERVED partons are identical gluons.  It is WRONG for Hqg;qg: there one
of the gluons is the OBSERVED parton, so the unobserved pair is {q, g},
which is DISTINGUISHABLE -- no 1/2!.  Equivalently, either of the two
identical gluons can be the tagged one, giving a factor 2.  Net: the
relabelled amplitude must be multiplied by SYMMETRY_FIX = 2.

MEASURED (2026-07-30, scratchpad/ratio_exact.py, exact rationals at three
independent kinematic points).  At eps^-2 the counterterms vanish
identically, so that order is purely real <-> virtual:

    point 1: real=17/(3 pi)    virt=-34/(3 pi)     -real/virt = 1/2
    point 2: real=85/(27 pi)   virt=-170/(27 pi)   -real/virt = 1/2
    point 3: real=119/(45 pi)  virt=-238/(45 pi)   -real/virt = 1/2

i.e. the un-fixed real is EXACTLY HALF the virtual, so 2x makes eps^-2
cancel identically.  The physical argument and the measurement agree on the
same rational factor.

WHY IT SURVIVED SO LONG: the k1<->k2 relabel was validated by
`Hgq_LO_crossing_check.py`, an LO 2->2 check.  A 2->2 final state has NO
identical unobserved pair, so that check structurally CANNOT see this
factor.  "RELABEL CHECK g = RELABEL CHECK PP = 0 at LO" does not cover it.

NOT AFFECTED: Hgq (`Hgq_NLO_R1_traces.wls` line 121 -- "q,qbar,g distinct
(no 1/2!)") and therefore Hgg, which is Hgq's relabel.  Only the QGG-derived
channel inherits the bad factor.

Run AFTER generated/Hqq_R1_qgg.py exists.  Regenerates generated/Hqg_R1.py.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp  # noqa: E402

import generated.Hqq_R1_qgg as C2  # noqa: E402

SYMMETRY_FIX = 2  # remove QGG's 1/2! -- see the module docstring

M2g = sp.sympify(C2.M2g)
M2PP = sp.sympify(C2.M2PP)

t1, t2, u1, u2, s13, s23 = sp.symbols('t1 t2 u1 u2 s13 s23')
sw = {t1: t2, t2: t1, u1: u2, u2: u1, s13: s23, s23: s13}

M2g3 = SYMMETRY_FIX*M2g.xreplace(sw)
M2PP3 = SYMMETRY_FIX*M2PP.xreplace(sw)

hdr = ("# chn3 Hqg real: gamma* q -> q g g, GLUON fragments (k1=gluon).\n"
       "# Relabel of Hqq_R1_qgg (k1<->k2: t1<->t2,u1<->u2,s13<->s23).\n"
       "# Same |M|^2, different observed parton. "
       "Source: generated/Hqq_R1_qgg.py\n"
       "# TIMES 2: removes QGG's 1/2! identical-gluon factor, which does NOT\n"
       "# apply once a gluon is the OBSERVED parton ({q,g} unobserved pair is\n"
       "# distinguishable).  Verified: -real/virt = 1/2 at eps^-2 before the\n"
       "# fix, at three exact rational points.  See python/make_Hqg_R1.py.\n")

out = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                   'generated', 'Hqg_R1.py')
with open(out, 'w') as stream:
    stream.write(hdr + "M2g='''%s'''\nM2PP='''%s'''\n" % (str(M2g3), str(M2PP3)))
print("wrote %s  (SYMMETRY_FIX=%d)" % (out, SYMMETRY_FIX))
print("  M2g  ops=%d" % sp.count_ops(M2g3))
print("  M2PP ops=%d" % sp.count_ops(M2PP3))
