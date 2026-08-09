#!/usr/bin/env python3
"""Does symbolising beta0 close the surviving delta eps^-1 pole?  And if not,
what weight does the UV counterterm require?  MEASURE, do not argue.

CONTEXT.  After every 0z.80 fix, stage 2 left exactly ONE nonzero pole slot in
the whole calculation, `delta eps^-1`, and job 14196220 showed it is
V(-2) x [Log Q2 + rational] in every channel and projection measured.  The
rational part traced to beta0 being HARDCODED (`Hgq_V2_cross.py:72` had both
Nc and nf as numbers; `Hqq_V2_ren_invariant_sym.py:27` had Nc as a number)
while the mass-factorization counterterm carries the symbolic (11Nc - 2nf)/3
from P0gg's delta term.  Both are now symbolic and the six virtual Laurents
were regenerated on the cluster (jobs 14196386-91).

WHY NO RECOMPUTE OF THE REAL EMISSION.  Only the virtual changed and the three
sources enter the delta sector additively, so

    total_new(eps^-1) = residue_old(eps^-1) + [ virt_new - virt_old ](eps^-1)

with `residue_old` transcribed from `reduce_stage2.wls` (job 14196215) and the
two virtuals read from the Mathematica coefficient files -- the NEW ones from
cache/, the OLD ones from cache/STALE_virtcoeff_beta0/.  This is exact and
takes seconds.  It must NOT be done with sympy's `virtual_laurent`: that is
the measured never-returns path which is exactly why the Laurent step was
ported to Mathematica (STATE: ">30 min in sympy -> 1 s in Mathematica").

THE WEIGHT.  The UV counterterm enters the virtual linearly,

    uvct     = -(beta0/eps) Seps (gs^2/(16 pi^2)) lo * 2
    virt_ren = (e + 2*uvct) * Feps

so it contributes -4 beta0 (gs^2/16 pi^2) lo to virt(eps^-1) exactly, since
Seps*Feps = exp(gammaE eps)/Gamma(1-eps) = 1 + O(eps^2) contributes nothing at
this order.  Writing the total weight as `w` (the shipped value is w = 4), the
residue is linear in w and this script SOLVES for the w that closes the pole.

The eps^-2 slot already cancels exactly and `uvct` is a single pole that
cannot reach eps^-2, so eps^-2 independently validates the normalization of
`e` -- the loop part, its 2 Re factor and the (-I/Nc)*COUP chain -- against
the real emission.  The counterterm weight is therefore the only unvalidated
number in the virtual, which is what makes solving for it meaningful.

The Log Q2 term is a SEPARATE defect (one unbalanced power of (ScaleMu^2)^eps)
and is expected NOT to move here; it is reported apart so the two never get
conflated.

Usage: python3 Hgq_V2_beta0_check.py <path-to-fetched-coefficient-dump>
"""
import os
import re
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
os.chdir(HERE)

Nc, nf, CF = sp.Symbol("Nc"), sp.Symbol("nf"), sp.Symbol("CF")
ee, eq, gs = sp.symbols("ee eq gs")
s, t1, Q2 = sp.symbols("s t1 Q2")
w = sp.Symbol("w")

BETA0 = sp.Rational(11, 3)*Nc - sp.Rational(2, 3)*nf
SHIPPED_WEIGHT = 4          # uvct's own *2, times the outer 2*uvct

# residue_old, transcribed from reduce_stage2.wls on cache/stage2_*.m (14196215)
_BRK = Nc*(50 - 11*Nc + 2*nf) + 6*(2*Nc**2 - 1)*sp.log(Q2)
_KIN = {
    "Hgq_PP": s,
    "Hgq_g": (Q2**2 + s**2 + 2*Q2*t1 + 2*t1*(s + t1))/(t1*(Q2 + s + t1)),
}
RESIDUE_OLD = {k: -sp.Rational(1, 12)*ee**2*eq**2*gs**4*v*_BRK/(Nc*sp.pi)
               for k, v in _KIN.items()}
LOGQ2_PART = {k: -sp.Rational(1, 12)*ee**2*eq**2*gs**4*v
              * 6*(2*Nc**2 - 1)*sp.log(Q2)/(Nc*sp.pi)
              for k, v in _KIN.items()}


def parse_dump(path):
    """Split the @@@NEW_<tag> / @@@OLD_<tag> dump into sympy expressions."""
    blocks, tag, buf = {}, None, []
    for line in open(path):
        marker = re.match(r"@@@(NEW|OLD)_(\S+)", line.strip())
        if marker:
            if tag:
                blocks[tag] = "".join(buf)
            tag, buf = (marker.group(1), marker.group(2)), []
        elif tag:
            buf.append(line)
    if tag:
        blocks[tag] = "".join(buf)

    out = {}
    for key, text in blocks.items():
        text = text.strip()
        if not text:
            continue
        text = (text.replace("^", "**").replace("[", "(").replace("]", ")")
                    .replace("Log", "log").replace("Pi", "pi")
                    .replace("EulerGamma", "EulerGamma"))
        expression = sp.sympify(text, locals={"EulerGamma": sp.EulerGamma,
                                              "I": sp.I})
        # t -> t1, exactly as `finite_hard_parts.resolve` does via its
        # _TARGETS map.  The Mathematica coefficient files are written in the
        # build variable `t` while the reduced stage-2 residues are in `t1`.
        # Without this the two enter as INDEPENDENT symbols and nothing
        # cancels -- the same symbol-identity class of bug as WRONG.md
        # Category D.  It is invisible in the PP projection (whose kinematic
        # factor is just `s`) and only bites the g projection.
        out[key] = expression.xreplace(
            {a: t1 for a in expression.free_symbols if a.name == "t"})
    return out


def real_part(expression):
    """Keep Re.  EXPAND FIRST -- a Mul-wrapped coefficient is one Add arg and
    would otherwise be dropped whole (STATE 0z.79)."""
    if expression == 0 or not expression.has(sp.I):
        return expression
    expanded = sp.expand(expression, log=False, power_base=False,
                         power_exp=False)
    return sp.Add(*[t for t in sp.Add.make_args(expanded) if not t.has(sp.I)])


def main():
    dump = sys.argv[1]
    coeffs = parse_dump(dump)
    sub = {CF: (Nc**2 - 1)/(2*Nc)}

    for tag in ("Hgq_PP", "Hgq_g"):
        if ("NEW", tag) not in coeffs or ("OLD", tag) not in coeffs:
            print("=== %s : coefficient file not present, skipped" % tag)
            continue
        new, old = coeffs[("NEW", tag)], coeffs[("OLD", tag)]
        delta = real_part(new) - real_part(old)

        # expand_log(force=True) BEFORE combining.  Package-X emits ratios --
        # log(-Q2/t1), log(Q2/(Q2+s+t1)), log(Q2/s) -- and with ScaleMu -> 1
        # their partners log(-1/t1), log(1/(Q2+s+t1)), log(1/s) appear
        # separately.  Each pair differs by exactly log(Q2), but sympy will not
        # combine them without sign knowledge (t1 < 0, and Nc is not declared
        # positive), so the cancellation stays hidden and a leftover looks real.
        # `force=True` applies the formal identity, which is what is wanted
        # here: the branch phases were already fixed by continue_logs upstream.
        # This is the same service `mathematica/reduce_stage2.wls` performs with
        # its explicit region assumptions.
        total = sp.simplify(sp.expand_log(sp.expand(
            (RESIDUE_OLD[tag] + delta).xreplace(sub),
            log=False, power_base=False, power_exp=False), force=True))
        rational = sp.simplify(sp.expand_log(total - LOGQ2_PART[tag].xreplace(sub), force=True))

        print("=== %s" % tag)
        print("  total eps^-1 after symbolic beta0 : %s" % sp.factor(total))
        print("  its non-log(Q2) part              : %s" % sp.factor(rational))
        print("  log(Q2) part unchanged            : %s"
              % (sp.simplify(total - rational
                             - LOGQ2_PART[tag].xreplace(sub)) == 0))

        # The counterterm contributes -w*beta0*(gs^2/16 pi^2)*lo to virt(eps^-1).
        # `lo` is fixed by the shipped weight: the nf-dependence of the virtual
        # comes ONLY through beta0, so read it off rather than re-deriving lo.
        lo_term = sp.simplify(sp.diff(delta, nf)/sp.diff(-SHIPPED_WEIGHT*BETA0
                                                         + 0*nf, nf))
        # residue as a function of the weight w (shipped w = SHIPPED_WEIGHT)
        as_w = sp.simplify(rational
                           + (SHIPPED_WEIGHT - w)*BETA0*lo_term)
        solution = sp.solve(sp.Eq(sp.simplify(as_w.xreplace(sub)), 0), w)
        print("  weight w closing the rational part: %s  (shipped %d)"
              % (solution, SHIPPED_WEIGHT))
        print()


if __name__ == "__main__":
    main()
