#!/usr/bin/env python3
"""Assemble F1hat and F2hat for a channel, per distribution sector.

WHY IN PYTHON RATHER THAN MATHEMATICA.  The four objects live in two places:
the three distribution sectors are Mathematica stage-2 output, the regular
sector is a sympy pickle.  They must meet in one language, and the cheap
direction is to move the SMALL ones: the stage-2 sector files are under a
megabyte, while the mapped regular sector is ~9.6 million operations and
`mma_export.write_m` on it did not finish in 15 minutes.  So the sectors are
exported as bare .m files (`mathematica/export_stage2_sectors.wls`), read here,
and combined with the pickle.

WHY PER SECTOR.  A finished channel is FOUR objects in each photon projection:

    delta      coefficient of  delta(s23)
    plus1B     coefficient of  [1/s23]_+        on [0, B]
    plus2B     coefficient of  [Log s23/s23]_+  on [0, B]
    regular    an ordinary function of s23

They multiply DIFFERENT distributions, so they cannot be summed into a single
expression -- only coefficients of the same distribution may be combined.  The
extraction projectors are linear, so they act sector by sector:

    F1hat = -(1/2) Fg + (2 xh^2/Q2) Fpp
    F2hat = -xh Fg + (12 xh^3/Q2) Fpp

with Fg, Fpp the SAME sector in the two projections.  Keeping the four
separate is also what makes the result map one-to-one onto the reference
implementation's delta / plus1B / plus2B / regular structure.

GATES, enforced not assumed:
  * FRAME -- no compact-frame symbol (R5S, R5M, R5K, z, x, xi, PHT) may reach
    the assembly.  Mixing frames is the failure mode of STATE 0z.72/0z.73 and
    WRONG.md Category D.
  * EXACTNESS -- no Float may appear.  A single 0.5 in one residue cache
    produced a spurious 32381-leaf "pole" that was pure 1e-16 roundoff
    (STATE 0z.87).
  * eps-FREE -- these are eps^0 coefficients of a pole-free combination.

Symbols are resolved from each expression's own free_symbols BY NAME; a bare
sp.Symbol does not match a cached symbol carrying assumptions (STATE 0z.86).

Usage: python3 F12_assemble_invariant.py <channel>
"""
import os
import pickle
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

COMPACT = {"R5S", "R5M", "R5K", "z", "x", "xi", "PHT", "A5mask"}

# REGULAR SECTOR ONLY.  The four sectors are SEPARATE objects that multiply
# different distributions, and the extraction projectors are linear, so each
# sector can be assembled independently -- and therefore in whichever language
# already holds it.  The three distribution sectors stay in Mathematica
# (`mathematica/F12_distribution_assemble.wls`); the regular sector is a sympy
# pickle and is assembled here.  Nothing is converted between languages.
#
# WHY NOT CONVERT.  Both directions were measured and both fail:
#   * pickle -> .m : `mma_export.write_m` on the 9.6M-operation mapped regular
#     sector did not finish in 15 minutes;
#   * .m -> pickle : `sympify` goes through Python's `eval`, and the 428907-leaf
#     `delta` sector raises RecursionError during compilation.
# Splitting by sector removes the need for either.
SECTORS = ("regular",)

xh = sp.Symbol("xh")


def _canonical(expression, target):
    """Map free symbols onto `target`'s objects BY NAME (STATE 0z.86)."""
    names = {a.name: a for a in expression.free_symbols}
    rename = {names[n]: target[n] for n in names if n in target
              and names[n] is not target[n]}
    return expression.xreplace(rename) if rename else expression


def load_sector(channel, projection, sector):
    path = os.path.join(CACHE, "%s_R5inv_%s.pkl" % (channel, projection))
    return pickle.load(open(path, "rb"))["regular"]


def main():
    channel = sys.argv[1]
    started = time.time()
    Fg, Fpp = {}, {}

    for sector in SECTORS:
        Fg[sector] = load_sector(channel, "g", sector)
        Fpp[sector] = load_sector(channel, "PP", sector)
        print("  %-8s g: %8d ops   PP: %8d ops  (%.0f s)"
              % (sector, sp.count_ops(Fg[sector]), sp.count_ops(Fpp[sector]),
                 time.time() - started), flush=True)

    # one symbol table, taken from the largest expression, then applied to all
    table = {a.name: a for a in Fg["regular"].free_symbols}
    for side in (Fg, Fpp):
        for sector in SECTORS:
            side[sector] = _canonical(side[sector], table)
    Q2 = table.get("Q2", sp.Symbol("Q2"))

    for label, side in (("g", Fg), ("PP", Fpp)):
        for sector in SECTORS:
            expression = side[sector]
            stray = {a.name for a in expression.free_symbols} & COMPACT
            if stray:
                raise SystemExit("FRAME GATE: %s %s carries %s"
                                 % (label, sector, sorted(stray)))
            if expression.atoms(sp.Float):
                raise SystemExit("EXACTNESS GATE: %s %s carries Float %s"
                                 % (label, sector,
                                    sorted(expression.atoms(sp.Float))[:4]))
            if any(a.name == "eps" for a in expression.free_symbols):
                raise SystemExit("EPS GATE: %s %s still carries eps"
                                 % (label, sector))
    print("  frame / exactness / eps gates: PASSED", flush=True)

    F1hat, F2hat = {}, {}
    for sector in SECTORS:
        g, pp = Fg[sector], Fpp[sector]
        F1hat[sector] = -g/2 + 2*xh**2*pp/Q2
        F2hat[sector] = -xh*g + 12*xh**3*pp/Q2
        print("  %-8s -> F1hat %8d ops   F2hat %8d ops"
              % (sector, sp.count_ops(F1hat[sector]),
                 sp.count_ops(F2hat[sector])), flush=True)

    payload = {"version": "f12hat-sector-v1", "channel": channel,
               "F1hat": F1hat, "F2hat": F2hat,
               "note": "REGULAR sector only; the three distribution sectors are "
                       "assembled in mathematica/F12_distribution_assemble.wls. "
                       "Invariant frame (s,t1,Q2,s23), Jacobian NOT included"}
    out = os.path.join(CACHE, "F12hat_regular_%s.pkl" % channel)
    tmp = out + ".tmp.%d" % os.getpid()
    with open(tmp, "wb") as stream:
        pickle.dump(payload, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(tmp, out)
    print("F12_ASSEMBLE_DONE %s -> %s (%.0f s)"
          % (channel, os.path.basename(out), time.time() - started), flush=True)


if __name__ == "__main__":
    main()
