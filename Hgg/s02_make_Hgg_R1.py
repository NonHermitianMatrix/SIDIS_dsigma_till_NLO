#!/usr/bin/env python3
"""chn4 (Hgg) real amplitude = chn1 (Hgq) with the observed parton
relabeled quark->gluon (k1<->k3): {t1<->t3, u1<->u3, s12<->s23}.
Same |M|^2 for gamma* g -> q qbar g, different fragmenting parton.
Run AFTER chn1's Hgq_R1.py is validated (gauge check passed)."""
import hashlib
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp
import generated.Hgq_R1 as C1
M2g = sp.sympify(C1.M2g); M2PP = sp.sympify(C1.M2PP)
t1, t3, u1, u3, s12, s23 = sp.symbols('t1 t3 u1 u3 s12 s23')
sw = {t1: t3, t3: t1, u1: u3, u3: u1, s12: s23, s23: s12}
M2g4 = M2g.xreplace(sw); M2PP4 = M2PP.xreplace(sw)
source_path = os.path.join(os.path.dirname(__file__), 'generated', 'Hgq_R1.py')
source_sha256 = hashlib.sha256(open(source_path, 'rb').read()).hexdigest()
hdr = ("# chn4 Hgg real: gamma* g -> g q qbar, GLUON fragments (k1=gluon).\n"
       "# Relabel of Hgq_R1 (chn1) k1<->k3: {t1<->t3,u1<->u3,s12<->s23}.\n"
       "# Same |M|^2, different observed parton. Source: generated/Hgq_R1.py\n"
       "# source_sha256=%s\n" % source_sha256)
target = os.path.join(os.path.dirname(__file__), 'generated', 'Hgg_R1.py')
temporary = "%s.tmp.%d" % (target, os.getpid())
with open(temporary, 'w') as stream:
    stream.write(hdr + "M2g='''%s'''\nM2PP='''%s'''\n" %
                 (str(M2g4), str(M2PP4)))
    stream.flush()
    os.fsync(stream.fileno())
os.replace(temporary, target)
print("chn4 Hgg: M2g leaves=%d M2PP leaves=%d -> generated/Hgg_R1.py"
      % (sp.count_ops(M2g4), sp.count_ops(M2PP4)))
