# Validation oracle

`fchn1{A,B,C}.py` are the Hgq (channel 1 of Table I), Pg-projector hard parts
from the paper's own public code, JeffersonLab/BigTMD, NLO/Pg/.
Downloaded read-only and used ONLY as a numerical comparison target for the
independently computed s07 result.  Nothing in the pipeline reads them.

Structure of every channel (this is what fixes the convention of the answer):
    H = regular(s,t,Q,s23,mu,nf)
      + delta(...,B,...)  * DiracDelta[s23]
      + plus1B(...,B,...) * [1/s23]_+^B
      + plus2B(...,B,...) * [Log[s23]/s23]_+^B
i.e. the hard part is a distribution in s23 with plus-prescriptions on [0,B].
For Hgq only the A (charge e_q^2) structure is non-zero; B and C return 0.
