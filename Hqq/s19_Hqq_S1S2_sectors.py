"""S1/S2 (CTpdf + CTff) plus/regular sectors: the FULL s23 dependence.
(STATE.md 0z.376)

WHY THIS IS NEEDED, and it is the same story as the R4 modules.
python/Hqq_S1S2.py says in its own docstring that it emits "the delta(s23)
coefficient of CTpdf + CTff, per projection, at order 1/eps -- which is what C2
needs, together with the [1/s23]_+ coefficients, which R5/F1 will need later."
But what it actually caches is EVALUATED AT THE ENDPOINT:
    out["plus"] = limit(dens * s23, s23 -> 0)          -- the RESIDUE N(0)
    out["reg0"] = (r k/Jp)(v*).subs(s23, 0)            -- the VALUE at s23 = 0
i.e. constants, not functions of s23.  That is exactly right for C2 and exactly
insufficient for F1.

THE ASYMMETRY THAT WOULD OTHERWISE BITE.  The real groups' plus1B is a FUNCTION
H(s23) (python/Hqq_{gg,pair}_R5.py, mathematica/Hqq_SF_R5.wls), while the CT's
cached "plus" is the single number N(0).  A plus distribution acts as
    Int_0^B ds23 [1/s23]_+ F = Int_0^B ds23 (F(s23) - F(0))/s23,
so it needs the whole F; using N(0) in its place silently drops
(N(s23) - N(0))/s23 entirely.  Both sides must be functions.

WHAT THIS SCRIPT PRODUCES, per (projection, side, channel):
    plus1B(s23) = N(s23)   with  dens = N(s23)/s23   [the [1/(1-v)]_+ piece]
    regular(s23)           = (r k / Jp)(v*(s23))     [the regular piece of P0]
both as functions, WITHOUT the .subs(s23, 0) / limit that Hqq_S1S2.py applies.

THE GATE.  Evaluating the new functions at s23 -> 0 must reproduce the cached
constants EXACTLY:
    plus1B(0) == cached["plus"],    regular(0) == cached["reg0"]
That anchors these functions to the objects C2 already validated, and it is the
same anchoring gate the gg/pair R5 stages use (H(0) reproduces the cached
delta).  A failed gate EXITS NONZERO so it blocks F1.

EVERY CONVENTION IS TAKEN FROM Hqq_S1S2.py UNCHANGED -- the same k, Jp, v*,
to_s23, WEIGHT and SHIFT -- by importing it, so the two cannot drift.  In
particular the delta(1-v) piece still carries NO 1/|G'| (STATE.md 0z.344a) and
is untouched here: it is a pure delta(s23) term with no plus/regular part.
"""
import os
import pickle
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

import Hqq_S1S2 as S                                            # noqa: E402

v, s, t1, u1, Q2, s23 = S.v, S.s, S.t1, S.u1, S.Q2, S.s23


def sectors(side, chan, proj, vstar, Gp):
    """plus1B(s23) and regular(s23) as FUNCTIONS -- no endpoint substitution."""
    k = S._inv(S.LO[(chan, proj)]).subs(
        S.SHIFT_pdf if side == "pdf" else S.SHIFT_ff, simultaneous=True)
    k = k * S.WEIGHT[(side, proj)]
    Jp = sp.diff(Gp, v)
    to_s23 = {u1: s23 - s - t1 - Q2}

    out = {}
    # [1/(1-v)]_+ piece: dens carries a 1/s23 pole, so N(s23) = s23 * dens is
    # the plus1B FUNCTION.  Hqq_S1S2.py keeps only N(0).
    p = S.P0[chan]["plus"]
    if p != 0:
        dens = sp.cancel((p * k / (Jp * (1 - v))).subs(v, vstar).subs(to_s23))
        out["plus1B"] = sp.cancel(dens * s23)
    else:
        out["plus1B"] = sp.Integer(0)

    # regular piece of P0, kept as a function of s23
    r = S.P0[chan]["reg"]
    out["regular"] = sp.cancel((r * k / Jp).subs(v, vstar).subs(to_s23))
    return out


def main():
    ok, xs, zs = S.gates()
    if not ok:
        print("HQQ_S1S2_SECTORS_FAIL_GATES", flush=True)
        sys.exit(1)
    with open(os.path.join(CACHE, "Hqq_S1S2.pkl"), "rb") as fh:
        cached = pickle.load(fh)

    res, allok = {}, True
    for proj in ("PP", "g"):
        for side, chans, vstar, Gp in (
                ("pdf", ("qq", "gq"), xs, S.G_pdf),
                ("ff", ("qq", "qg"), zs, S.G_ff)):
            for chan in chans:
                key = (proj, side, chan)
                r = sectors(side, chan, proj, vstar, Gp)
                res[key] = r
                c = cached[key]
                # GATE: the functions must reduce to the validated constants
                p0 = sp.cancel(sp.limit(r["plus1B"], s23, 0))
                g0 = sp.cancel(r["regular"].subs(s23, 0))
                dp = sp.simplify(p0 - c["plus"])
                dg = sp.simplify(g0 - c["reg0"])
                print(f"  {key}: plus1B(0) == cached plus : {dp == 0}"
                      f"   regular(0) == cached reg0 : {dg == 0}", flush=True)
                if dp != 0 or dg != 0:
                    print(f"      plus1B(0)-cached  = {dp}", flush=True)
                    print(f"      regular(0)-cached = {dg}", flush=True)
                    allok = False
                print(f"      s23-dependent: plus1B {s23 in r['plus1B'].free_symbols}"
                      f", regular {s23 in r['regular'].free_symbols}", flush=True)
    with open(os.path.join(CACHE, "Hqq_S1S2_sectors.pkl"), "wb") as fh:
        pickle.dump(res, fh)
    print(f"  wrote cache/Hqq_S1S2_sectors.pkl ({len(res)} entries)", flush=True)
    print("HQQ_S1S2_SECTORS_DONE" if allok
          else "HQQ_S1S2_SECTORS_GATE_FAILED", flush=True)
    if not allok:
        sys.exit(1)


if __name__ == "__main__":
    main()
