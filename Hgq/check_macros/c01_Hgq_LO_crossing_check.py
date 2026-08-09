# Hgq_LO_crossing_check.py -- can the gluon-initiated channel be obtained from
# the quark-initiated one by CROSSING?  Tested at LO, where BOTH sides already
# exist as independent Mathematica exports, so the test is a genuine
# prediction-vs-computation comparison and not a definition.
#
# Processes (AI.md sec. 5):
#   qq channel : gamma*(q) + q(p)  -> q(k1) + g(k2)
#                s = (p+q)^2, t = (q-k1)^2, u = (p-k1)^2,  s+t+u = -Q2
#   gq channel : gamma*(q) + g(P)  -> q(k1) + qbar(K2)
#                S = (P+q)^2, T = (q-k1)^2, U = (P-k1)^2,  S+T+U = -Q2
# Crossing the outgoing gluon to an incoming one and the incoming quark to an
# outgoing antiquark is P = -k2, K2 = -p, which maps
#   S = (q-k2)^2 = (k1-p)^2 = u,   T = (q-k1)^2 = t,   U = (k1+k2)^2 = s,
# i.e. the plain exchange s <-> u at fixed t.
#
# The exported M2's are already spin/colour AVERAGED, so the averages must be
# converted as well:
#   qq: (1/2)(1/Nc)                 [incoming quark spin x colour]
#   gq: (1/(2-2 eps))(1/(Nc^2-1))   [incoming gluon polarizations x colour]
# and crossing a fermion line carries the usual (-1).  Prediction:
#   M2g_gq(S,T) = - Nc/((1-eps)(Nc^2-1)) * M2g_qq(s -> -S-T-Q2, t -> T)
#
# ONLY the g projection is testable this way: the PP projection contracts the
# photon indices with p^mu p^nu built from the INCOMING PARTON, and crossing
# changes which momentum that is (p -> -k2), so M2PP_qq is simply not the
# object that crosses into M2PP_gq.  That is recorded, not worked around.
#
# Inputs (both from python/generated/, no formula typed from memory):
#   Hqq_L2_M2.py        -- M2g, M2PP for gamma* q -> q g   (Hqq_LO_traces.wls)
#   Hqq_S12_LO_M2.py    -- M2g_gq, M2PP_gq                 (Hqq_S12_LO_traces.wls)
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp

from generated.Hqq_L2_M2 import M2g as M2g_qq
from generated.Hqq_S12_LO_M2 import M2g_gq

s, t, Q2, eps, Nc = sp.symbols('s t Q2 eps Nc')

# s <-> u at fixed t, with u = -s-t-Q2 written in the gq variables (S,T) = (s,t)
crossed = M2g_qq.xreplace({s: -s - t - Q2})

# average conversion x fermion-crossing sign
Cfac = -Nc/((1 - eps)*(Nc**2 - 1))

pred = sp.simplify(Cfac*crossed)
diff = sp.simplify(sp.together(pred - M2g_gq))

print("M2g_qq        :", M2g_qq)
print("crossed x Cfac:", sp.simplify(pred))
print("M2g_gq (indep):", M2g_gq)
print("CROSSING CHECK (must be 0):", diff)
print("CROSSING_HOLDS", diff == 0)

# If it fails, the ratio names what is off (a constant => an average/sign slip;
# an s,t-dependent ratio => crossing is not the relation and must be abandoned).
if diff != 0:
    print("ratio pred/indep:", sp.simplify(pred/M2g_gq))

# ----------------------------------------------------------------------------
# Second relation: the qg channel (gamma* q -> g q, the GLUON fragmenting) is
# the SAME amplitude as qq with the roles of the two outgoing partons swapped.
# With the observed parton k1 = gluon = p+q-k1_old:
#   t' = (q-k2)^2 = (k1-p)^2 = u,     u' = (p-k2)^2 = (k1-q)^2 = t,
# i.e. the plain exchange t <-> u at fixed s.  The incoming parton is still the
# quark p, so BOTH the spin/colour average AND the p^mu p^nu projector are
# unchanged: no sign, no average factor, and the PP projection is testable too.
#   M2X_qg(s,t) = M2X_qq(t -> -s-t-Q2)   for X in {g, PP}
from generated.Hqq_L2_M2 import M2PP as M2PP_qq
from generated.Hqq_S12_LO_M2 import M2PP_qg, M2g_qg

swap = {t: -s - t - Q2}
dg = sp.simplify(sp.together(M2g_qq.xreplace(swap) - M2g_qg))
dpp = sp.simplify(sp.together(M2PP_qq.xreplace(swap) - M2PP_qg))
print("RELABEL CHECK g  (must be 0):", dg)
print("RELABEL CHECK PP (must be 0):", dpp)
print("RELABEL_HOLDS", dg == 0 and dpp == 0)
if dg != 0:
    print("ratio g :", sp.simplify(M2g_qq.xreplace(swap)/M2g_qg))
if dpp != 0:
    print("ratio PP:", sp.simplify(M2PP_qq.xreplace(swap)/M2PP_qg))
