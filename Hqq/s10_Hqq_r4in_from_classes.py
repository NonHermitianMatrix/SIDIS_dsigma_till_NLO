"""Bridge: the POST-FIX (08-06) R3 classes -> r4in_<piece>.m for the proven
R4/R5/F12 chain.  (STATE.md 0z.403)

WHY THIS EXISTS.  verified/_shared/Hqq_R4_mma_part2.wls consumes
    mathematica/r4in_<piece>.m   defining  angterms = { ... }
and python/Hqq_R4_export_mma.py builds those from Hqq2_R3_<piece>_ang.pkl.
** Hqq's ang caches are 08-01 and are STALE (0z.402): they were produced by the
PRE-FIX R3, before 0z.258 corrected R2's incomplete partial fractioning -- the
old R3 INFINITE-LOOPED on exactly those terms (>45 s, never returning).  The
post-fix, exactness-gated data (0z.259) is the 08-06 CLASSES. **

THE TWO R3 FAMILIES ARE DIFFERENT STAGES, not duplicates:
    Hqq2_R3_<piece>_ang.pkl          masters ALREADY applied  (08-01, stale)
    Hqq_*_R3_*_classes.pkl           (j,l,epsg) classes, masters NOT applied
                                     (08-06, post-fix, gated)
so the bridge is simply to apply the masters:
    angterm = coefficient(j,l,epsg) x master(j,l,epsg,eps) x s23^extra
which is precisely what each R4 module's _pieces() already builds.  This file
adds NO new algebra -- it reuses those modules so the master conventions cannot
drift from the pipeline that was validated.

THE eps^2 PolyLog IS RESTORED (0z.364).  Both R4 modules drop it in hyp2f1 and
say "IT MUST BE RESTORED before any finite part is quoted"; these angterms feed
R5/F12, which ARE the finite part.

PIECE NAMES follow the proven chain's convention (MR2g.../MR2PP...), so the
downstream scripts need no modification:
    MR2{g,PP}QGG   real Hqq;gg          <- Hqq_gg_R4._pieces   (6-tuples)
    MR2{g,PP}PAIR  real Hqq;qqbar       <- Hqq_pair_R4._pieces (4-tuples)
    MR2{g,PP}DFA   real Hqq;q'qbar'     <- Hqq_pair_R4._pieces on the SF classes
"""
import os
import pickle
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
MMA = os.path.join(os.path.dirname(HERE), "mathematica")
sys.path.insert(0, HERE)

import Hqq_gg_R4 as GG                                          # noqa: E402
import Hqq_pair_R4 as PR                                        # noqa: E402


def _hyp_full(mod):
    """hyp2f1 with the eps^2 PolyLog restored, bound into `mod`."""
    orig = mod.hyp2f1

    def f(j, l, x, E):
        if j <= 0 or l <= 0:
            return orig(j, l, x, E)
        if (j, l) == (1, 1):
            return (1 - x) ** (-1 - E) * (1 + E ** 2 * sp.polylog(2, x))
        raise NotImplementedError(f"2F1 ({j},{l})")
    return f


def build(mod, classes_path, ntuple):
    """angterms = [coeff * master * s23^extra] for one piece."""
    with open(classes_path, "rb") as fh:
        classes = pickle.load(fh)
    names = {}
    for v in classes.values():
        for sym in v.free_symbols:
            names[sym.name] = sym
    sub = {names[k]: v for k, v in
           (("K23", mod.K23sub), ("P23", mod.P23sub),
            ("pk1", mod.pk1sub), ("k23", mod.k23sub)) if k in names}
    E = names.get("eps", mod.eps)
    terms = []
    for item in mod._pieces(classes, sub, E):
        if ntuple == 6:
            _key, extra, coeff, sfree, mfac, regf = item
            t = sfree * coeff * mfac * regf
        else:
            _key, extra, rat, regf = item
            t = rat * regf
        # SPLIT INTO TOP-LEVEL ADDITIVE TERMS, matching the proven chain's
        # granularity.  Hqq_R4_mma_part2.wls applies a PER-TERM TimeConstrained
        # and QUARANTINES BY INDEX; with one giant term per class those
        # mechanisms are useless (a single timeout loses a whole class) and the
        # old per-term r4in files were correspondingly large (30 MB for
        # MR2gQGG).  Splitting the class COEFFICIENT -- the only large factor --
        # keeps the master and the s23 power attached to each piece.
        pref = (sfree * mfac * regf if ntuple == 6 else regf) * mod.s23 ** extra
        big = coeff if ntuple == 6 else rat
        for a_ in sp.Add.make_args(sp.expand(big, log=False,
                                             power_base=False,
                                             power_exp=False)):
            terms.append(a_ * pref)
    return terms


def main():
    jobs = [
        ("MR2PPQGG", GG, "Hqq_gg_R3_PP_classes.pkl", 6),
        ("MR2gQGG",  GG, "Hqq_gg_R3_g_classes.pkl", 6),
        ("MR2PPPAIR", PR, "Hqq_pair_R3_PP_classes.pkl", 4),
        ("MR2gPAIR",  PR, "Hqq_pair_R3_g_classes.pkl", 4),
        ("MR2PPDFA", PR, "Hqq_pair_SF_R3_PP_classes.pkl", 4),
        ("MR2gDFA",  PR, "Hqq_pair_SF_R3_g_classes.pkl", 4),
    ]
    want = sys.argv[1:]
    for piece, mod, cf, nt in jobs:
        if want and piece not in want:
            continue
        path = os.path.join(CACHE, cf)
        if not os.path.exists(path):
            print(f"  SKIP {piece}: missing {cf}", flush=True)
            continue
        mod.hyp2f1_orig = mod.hyp2f1
        mod.hyp2f1 = _hyp_full(mod)
        terms = build(mod, path, nt)
        out = os.path.join(MMA, f"r4in_{piece}.m")
        with open(out, "w") as fh:
            fh.write(f"(* angterms for {piece}, generated by "
                     f"python/Hqq_r4in_from_classes.py from {cf}\n"
                     f"   (POST-FIX 08-06 classes; the 08-01 *_ang.pkl are "
                     f"stale -- STATE.md 0z.402).\n"
                     f"   eps^2 PolyLog RESTORED (0z.364). *)\n")
            fh.write("angterms = {\n"
                     + ",\n".join(sp.mathematica_code(t) for t in terms)
                     + "\n};\n")
        print(f"  wrote r4in_{piece}.m  ({len(terms)} angular terms)",
              flush=True)
    print("HQQ_R4IN_FROM_CLASSES_DONE", flush=True)


if __name__ == "__main__":
    main()
