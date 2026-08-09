#!/usr/bin/env python3
"""C1 + C2 per CHANNEL: the finite delta / plus1B / plus2B coefficients.

arXiv:1903.01529 p.16: "After combining the graphs in each of the six
scattering channels in Table I, we have verified explicitly that all single
and double poles cancel.  The terms left are finite in the limit eps -> 0."

So the check is PER CHANNEL, on the combined graphs.  Luminosities are
irrelevant here (an overall factor on an already-finite hard part).

THE WHOLE PHYSICS, in four lines.  On 0 < s23 < B,

    s23^{-1-lam} = -(B^{-lam}/lam) delta(s23) + [1/s23]_+
                   - lam [Log s23/s23]_+ + O(lam^2),      lam = kappa eps,

with kappa = 1 - c/2 for an endpoint class carrying W^(-2 + c eps).  A class
with an extra Log(s23) is the derivative of that, since
Log(s23) s23^{-1-lam} = -d/dlam s23^{-1-lam}:

    l=0:  delta = -B^{-lam}/lam                 plus1 = 1     plus2 = -lam
    l=1:  delta = -B^{-lam}(1/lam^2 + Log B/lam) plus1 = 0     plus2 = 1

Then, per channel and projection,

    delta_sector = kf*Sum_{c,l} R_{c,l} deltafac(c,l) + virtual + PREF*Cdelta
    plus1_sector = kf*Sum_{c,l} R_{c,l} plus1fac(c,l) + PREF*Cplus
    plus2_sector = kf*Sum_{c,l} R_{c,l} plus2fac(c,l)

The virtual lives entirely at s23 = 0, so it enters the delta sector only
(that is C1); the Eq.(46) counterterms carry delta and plus distributions
and remove the remaining collinear poles (that is C2).  eps^-2 and eps^-1
must vanish; eps^0 is the finite answer.

CHECKPOINTS: every class contribution is cached, so a rerun resumes.
Progress is printed per class -- a silent stage is a defect.

Usage: python3 finite_hard_parts.py <channel> <projection>
"""
import os
import pickle
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
sys.path.insert(0, HERE)

import glob  # noqa: E402
import multiprocessing as mp  # noqa: E402

from Hqq_C1_from_r4mf import (  # noqa: E402
    B, Q2_inv, class_delta_factor, eps, kf, s_inv, t1_inv,
    virtual_laurent)
from Hqq_C2_exact_real_poles import (  # noqa: E402
    _eps_polynomial, _factorwise_laurent, _mask_eps_free)

CHUNK = int(os.environ.get("FHP_CHUNK", "25"))
WORKERS = int(os.environ.get("FHP_WORKERS", "15"))

nf = sp.Symbol("nf")

# Same convention bridge as Hqq_C1_from_r4mf.resolve, but WITHOUT
# `expr.replace(sp.Abs, lambda ...)`.  That call pattern-matches and
# rebuilds the whole tree, twice, and measured at 99% CPU for over four
# minutes on ONE small Hqqbar class -- hopeless for Hqq's much larger set.
# Collecting the actual Abs/sign atoms once and doing a single `xreplace`
# is the identical substitution in two linear passes.
#
# `B` IS IN THIS MAP FOR A REASON (bug found 2026-07-30).  SymPy symbols
# with different assumptions are DIFFERENT OBJECTS even when their names
# match, so `Symbol('B')` and `Symbol('B', positive=True)` never cancel.
# MEASURED on Hgq PP delta eps^-1: the real residues and the virtual carry
# Symbol('s', real=True) / Symbol('t1', real=True) / Symbol('B', positive=
# True) because both pass through `resolve`, while the COUNTERTERMS were
# added raw and carried BARE Symbol('s') / Symbol('t1') / Symbol('B').  The
# free-symbol list of virtual+CT literally showed 's' and 't1' TWICE.
# Nothing written in the bare symbols can cancel anything written in the
# canonical ones, so the eps^-1 pole could not close however correct every
# ingredient was.  It also explains why eps^-2 PASSED: the CT contributes
# identically ZERO at eps^-2, so that order only ever tested real<->virtual,
# both of which were already canonical.  The accepted `Hgq_C2_assemble.py`
# has this step as `_canonical`; this module was missing it.
_TARGETS = {"s": s_inv, "t": t1_inv, "t1": t1_inv, "Q2": Q2_inv,
            "eps": eps, "B": B}


def resolve(expression):
    """t -> t1, Abs(t1) -> -t1, sign(t1) -> -1, with names canonicalized."""
    rename = {sym: _TARGETS[sym.name] for sym in expression.free_symbols
              if sym.name in _TARGETS}
    if rename:
        expression = expression.xreplace(rename)
    substitution = {}
    for atom in expression.atoms(sp.Abs):
        if atom.args[0] == t1_inv:
            substitution[atom] = -t1_inv
    for atom in expression.atoms(sp.sign):
        if atom.args[0] == t1_inv:
            substitution[atom] = sp.Integer(-1)
    return expression.xreplace(substitution) if substitution else expression

# Table I (arXiv:1903.01529 p.17) -- the REAL graphs of each channel:
#   Hgq    <- Hgq;qbar g
#   Hqq    <- Hqq;gg + Hqq;qqbar + Hqq;q'qbar'
#   Hqg    <- Hqg;qg
#   Hgg    <- Hgg;qqbar          (completed by the Mathematica route)
#   Hqbar q<- Hqbar q;qq         (channel 5 -- NOT COMPUTED, see below)
#   Hqq'   <- Hqq';q qbar'       (completed by the Mathematica route)
#
# PIECE -> GRAPH map, read from the R1 trace-script headers:
#   QGG  = Hqq;gg              (Hqq_NLO_R1_qgg_traces.wls)
#   A    = Hqq;q'qbar' case A  (Hqq_NLO_R1_qqpqbarp_traces.wls)
#   B,C  = Hqq;q'qbar' cases B,C (Hqq_NLO_R1_qqpqbarp_BC_traces.wls)
#   E    = Hqq;qqbar EXCHANGE  (Hqq_NLO_R1_qqbar_exchange_traces.wls):
#          "SAME-flavor identical-particle interference of the real channel
#           of Hqq ... EXCH = -2 Re[A(k1) A(k2)*] (all e_q^2, feeds case A)"
#   HGQ  = Hgq;qbar g ,  HQG = Hqg;qg ,  HGG = Hgg;qqbar , Drel = Hqq';q qbar'
#
# BUG FIXED 2026-07-30: `E` had been assigned to a channel called "Hqqbar".
# It is NOT channel 5 -- it is the Hqq;qqbar term of Table I row 2.  So Hqq
# was missing a real subprocess (its virtual could never cancel), and the
# "Hqqbar" results were an isolated interference term of Hqq.
# BUG FIXED 2026-07-30 (second one): `Drel` was ALSO missing.  The R1 source
# (Hqq_NLO_R1_qqbar_exchange_traces.wls header) gives the same-flavour square as
#     |M|^2 = |A(k1)|^2 + |A(k2)|^2 - 2 Re[A(k1)A(k2)*]
#   |A(k1)|^2 = (A + B + C) at e_q' = e_q
#   |A(k2)|^2 = k1<->k2 relabel of them  <- this is `Drel`, built by
#               python/Hqq_R2_sameflavor_relabel.py lines 70-71
#   EXCH      = -2 Re[...]               <- this is `E`
# Only |A(k1)|^2 and EXCH were listed, so the direct square was absent.
# NOTE `Drel` had been recorded in STATE 0z.42 as belonging to Hqq' (channel 6).
# It does NOT; it is Hqq's.  See STATE 0z.56.
#
# WEIGHT IS UNRESOLVED -- DO NOT TREAT 1 AS VERIFIED.  A/B/C serve TWO roles:
# the different-flavour channel (summed over q' != q, whence the 2*nf on A) and,
# at e_q' = e_q, the same-flavour direct square.  A single weight cannot be
# correct for both uses, so the 2*nf on A and the 1 on Drel both need deriving
# from Eq.(46) flavour bookkeeping before any Hqq result is trusted.
# WEIGHT ON `A` MEASURED, NOT GUESSED (2026-07-31).  It was 2*nf, inherited
# with no derivation on record.  MEASURED from the Hqq PP delta eps^-1 residue:
#
#   * `A` at weight 1 contributes A_unit = -ee^2 eq^2 gs^4 (Nc^2-1)(Q2+s+t1)
#     /(12 pi Nc), which is nf-FREE, as it must be for one flavour;
#   * d(total)/d(nf) = A_unit EXACTLY (verified: the difference expands to 0);
#   * since total(w) = total(2nf) + (w - 2nf)*A_unit, the nf-proportional part
#     of the pole is A_unit*(dw/dnf - 1), so it vanishes iff **dw/dnf = 1**.
#
# So the weight is nf + const and 2*nf is REFUTED -- wrong by a factor 2 in its
# nf coefficient.  This matches the physics: `A` at e_q' = e_q also serves the
# same-flavour direct square (which `Drel` and `E` supply), so the
# different-flavour sum runs over q' != q, i.e. ONE flavour count.
#
# nf vs nf-1 is SETTLED BY THE PAPER, not by this residue (they differ by the
# single term 2 Nc t1 (Q2+s+t1), which the PP pole cannot separate).
# arXiv:1903.01529 p.15, on the Nf pole from the quark loop on the gluon leg of
# Hqq;g:
#     "This pole term is canceled after adding the real processes Hqq;qbar q
#      and Hqq;q'qbar' with all massless flavors q' (OTHER THAN q)"
# so the different-flavour sum runs over nf - 1 flavours, while the SAME-flavour
# pair is supplied separately by `E` (the exchange) and `Drel` (the direct
# square) at weight 1 each.  Total pair multiplicity 1 + (nf - 1) = nf, which is
# exactly the nf of the quark loop it must cancel.
#
# NOTE a tension worth remembering: BigTMD's sidis.py passes `nf` (not nf-1)
# into fchn2A.  We follow the PAPER, since this project derives independently
# and uses BigTMD only as a structural cross-check.  The two differ by one unit
# of A, i.e. by 2 Nc t1 (Q2+s+t1) in the residue.
#
# NOTE: setting the weight correctly kills the nf-proportional pole but leaves
# an nf-INDEPENDENT remainder, so there is a SECOND defect in Hqq.  Fixing this
# weight is necessary, not sufficient.
PIECES = {
    "Hqq": (("QGG", sp.S.One), ("A", nf - 1), ("B", sp.S.One),
            ("C", sp.S.One), ("E", sp.S.One), ("Drel", sp.S.One)),
    "Hgq": (("HGQ", sp.S.One),),
    "Hqg": (("HQG", sp.S.One),),
}
# Channel 5 (q -> (qbar->h) q qbar) has NO trace script and NO piece.  It has
# never been computed.  Do not resurrect "Hqqbar": (("E", ...),).
# Channels with a virtual partner (paper Table I).
VIRTUAL = {"Hqq", "Hgq", "Hqg"}


def plus_factors(c, l):
    """(plus1, plus2) endpoint factors for an endpoint class (c, l)."""
    lam = (1 - sp.Rational(c, 2))*eps
    if l == 0:
        return sp.S.One, -lam
    if l == 1:
        return sp.S.Zero, sp.S.One
    raise ValueError("log power %s not implemented" % l)


def _atomic(path, value):
    tmp = "%s.tmp.%d" % (path, os.getpid())
    with open(tmp, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(tmp, path)


def load_residues(channel, projection):
    """Load the INVARIANT-frame class-keyed residues, as accepted C1 does.

    FRAME BUG (fixed): this previously read `Hqq_R4prod_*`, the PRODUCTION
    frame residues that R5 consumes.  But the virtual (via `resolve`) and
    the Eq.(46) counterterms are both INVARIANT frame -- the counterterm
    cache says so explicitly: "invariant frame (s,t1,Q2,s23,B)".  Mixing
    frames means real and virtual are written in different variables and
    CANNOT cancel however correct each is individually, which is exactly
    the small stubborn eps^-2 residual that survived both earlier fixes.
    `Hqq_C1_from_r4mf` -- the run that passed `Hqq PP eps^-2 = ZERO` --
    reads `Hqq_R4mf_*`, and so do we now.

    Only the ('Residue', c, l) keys are used, matching accepted C1; the
    'Deep' classes are not part of the endpoint delta/plus construction.
    """
    prefix = "MR2g" if projection == "g" else "MR2PP"
    out = []
    # ISOLATE ONE PIECE, AT WEIGHT 1, FOR THE FLAVOUR-WEIGHT MEASUREMENT.
    # `PIECES["Hqq"]` carries ("A", 2*nf), an inherited guess, and the Hqq PP
    # delta eps^-1 residue is nf-proportional -- the signature of a wrong
    # flavour count.  The weight enters LINEARLY, so
    #     total(w) = [everything except A] + w * [A at weight 1]
    # and w is obtained by solving nf_part(total(w)) = 0 rather than guessed.
    # Running A alone at weight 1 is far cheaper than re-farming all six
    # pieces with a symbolic weight, and gives the same information.
    # The virtual and the counterterms are NOT piece-specific, so this mode
    # also suppresses them (see main): what is wanted is A's REAL
    # contribution by itself.
    only = os.environ.get("FHP_ONLY_PIECE")
    pieces = (((only, sp.S.One),) if only else PIECES[channel])
    for suffix, weight in pieces:
        path = os.path.join(CACHE, "Hqq_R4mf_%s%s.pkl" % (prefix, suffix))
        if not os.path.exists(path):
            raise SystemExit("missing %s" % path)
        data = pickle.load(open(path, "rb"))
        for key, expression in data.items():
            if not (isinstance(key, tuple) and key and key[0] == "Residue"):
                continue
            c, l = key[1], key[2]
            if expression == 0:
                continue
            out.append((suffix, c, l, weight, expression))
    return out


def counterterms(channel, projection):
    if channel == "Hqq":
        # `Hqq_CTbt.pkl`, NOT `Hqq_S12_CT.pkl`.  FRAME BUG FOUND 2026-07-30.
        # MEASURED: Hqq_S12_CT.pkl is the MEASURED/PRODUCTION-frame build --
        # every one of its pdf/ff x g/PP x Cdelta/Cplus entries carries
        # {x, xi, z, PHT} -- while Hqq's real endpoint residues
        # (cache/Hqq_R4mf_*) are INVARIANT frame {s, t1, Q2}.  Two sources in
        # different variables cannot cancel however correct each is.
        # It predicted the observed pattern exactly: the CT is identically
        # zero at eps^-2, so THAT order tests only real<->virtual (both
        # invariant) and DID cancel, while eps^-1 -- the first order the CT
        # enters -- could not.
        # `Hqq_CTbt.pkl` is the invariant-frame build of the SAME quantity;
        # its note reads "invariant frame (s,t1,Q2,s23,B)", identical to
        # Hglu_CTbt.pkl which Hgq/Hqg already use, and its structure is the
        # same pdf/ff -> proj -> Cdelta/Cplus layout.  `Hglu_CTbt.py`'s own
        # docstring says so: "chn2 was never affected: it uses Hqq_CTbt.pkl,
        # the invariant-frame build."  finite_hard_parts was simply reading
        # the wrong file.  See STATE 0z.72/0z.73.
        data = pickle.load(open(os.path.join(CACHE, "Hqq_CTbt.pkl"), "rb"))
        pref = data["PREF"]
        side = data["CT"]
        cdelta = side["pdf"][projection]["Cdelta"] + side["ff"][projection]["Cdelta"]
        cplus = side["pdf"][projection]["Cplus"] + side["ff"][projection]["Cplus"]
    else:
        data = pickle.load(open(os.path.join(CACHE, "Hglu_CTbt.pkl"), "rb"))
        pref = data["PREF"]
        cdelta = (data[(channel, "pdf")][projection]["Cdelta"]
                  + data[(channel, "ff")][projection]["Cdelta"])
        cplus = (data[(channel, "pdf")][projection]["Cplus"]
                 + data[(channel, "ff")][projection]["Cplus"])
    # CANONICALIZE BY NAME.  Without this the counterterms enter in bare
    # Symbol('s') / Symbol('t1') / Symbol('B') while the real residues and
    # the virtual are in the `real=True` / `positive=True` objects, and the
    # eps^-1 pole cannot cancel.  See the note on `_TARGETS` above.
    pref, cdelta, cplus = resolve(pref), resolve(cdelta), resolve(cplus)
    # EVALUATE THE COUNTERTERMS AT THE ENDPOINT s23 = 0 (bug found 2026-07-30).
    # The real endpoint residues R_{c,l} ARE the s23 -> 0 residues, so the
    # real plus coefficient is s23-INDEPENDENT by construction.  The stored
    # counterterms keep their full s23 dependence, so the two are coefficients
    # of the same distribution written in different conventions and cannot
    # cancel however correct each is.
    # MEASURED on Hgq PP plus1 eps^-1: with the s23 dependence kept, -real/CT
    # varied with s23 (4095/4373, 15561/17623, 49049/55989 at s23 = 1/3, 2/3,
    # 5/7), so no constant could ever fix it.  Substituting s23 -> 0 gives
    #     CT = ee^2 eq^2 gs^4 s (CF + Nc)/pi,   real + CT = 0  EXACTLY,
    # at every test point.  This is the `s23 -> 0` half of
    # `Hgq_C2_assemble._map_endpoint`; that function's OTHER half (s -> s_of,
    # t1 -> t1_of) is production-frame and must NOT be copied here -- see
    # WRONG.md Category D.
    s23_syms = [x for x in cplus.free_symbols if x.name == "s23"]
    s23_syms += [x for x in cdelta.free_symbols if x.name == "s23"]
    if s23_syms:
        zero = {x: sp.S.Zero for x in s23_syms}
        cdelta = cdelta.xreplace(zero)
        cplus = cplus.xreplace(zero)
    return pref, cdelta, cplus


def virtual_coefficients(channel, projection, lo=-2, hi=0):
    """Exact eps-Laurent coefficients of the virtual, as the ACCEPTED C1 does.

    Two things must happen and were previously missing here:
      * `virtual_laurent` multiplies by `sp.pi` INTERNALLY -- the virtual
        cache is stored without that factor;
      * `resolve` is applied to each EXTRACTED coefficient, supplying the
        convention bridge (t -> t1, Abs(t1) -> -t1, sign(t1) -> -1).
    `Hqq_C1_from_r4mf.resolve`'s docstring records what happens without the
    bridge: the C1 double pole is left with a small residual "whose stray
    symbol `t` names the bug".  Adding the raw cache, as this module did,
    reproduces exactly that failure.
    """
    if channel not in VIRTUAL:
        return {k: sp.S.Zero for k in range(lo, hi + 1)}
    tag = "G" if projection == "g" else "PP"
    path = os.path.join(CACHE, "%s_V2_virt%s_ren_inv_sym.pkl"
                        % (channel, tag))
    if not os.path.exists(path):
        raise SystemExit("missing virtual %s" % path)
    virtual = pickle.load(open(path, "rb"))
    # UNDO Feps -- THE MS-BAR CONVENTION MISMATCH (bug found 2026-07-30).
    # Every virtual in this project is built as `virt_ren = (virt0 + 2*uvct)*Feps`
    # with Feps = (exp(EulerGamma)/(4 pi))^eps ~ 1/Seps:
    #     Hgq_V2_cross.py            lines 60, 174
    #     Hqq_V2_ren_invariant_sym.py lines 29, 43   (and Hqg relabels this one)
    # Feps STRIPS the MS-bar constants.  But the other two sources KEEP them:
    #     real: kf   = (1/4) pi^-eps/(2pi)^(2-2eps) Gamma(1-eps)/Gamma(1-2eps)
    #                = Seps/(16 pi^2)
    #     CT:   PREF = gs^2 (4pi)^eps/(16 pi^2 eps Gamma(1-eps))
    #                = gs^2 Seps/(16 pi^2 eps)
    # so the virtual alone sat in the opposite convention and EulerGamma could
    # not cancel.  MEASURED on Hgq PP delta eps^-1 at two exact rational points:
    #   as cached      -34 EulerGamma + 34 log(2 pi) - 25
    #   x Seps/Feps    +34 EulerGamma - ...            (overshoots by exactly 2
    #                                                   in the exponent, as it
    #                                                   must: Seps/Feps ~
    #                                                   1 + 2 eps(log4pi - gE))
    #   / Feps         EulerGamma GONE, log pi GONE    <-- CORRECT
    # Must be applied BEFORE the Laurent expansion, since Feps is eps-dependent.
    # What remains after this is a separate log(Q2) SCALE residue -- see
    # STATE 0z.53; do not expect this alone to zero the delta sector.
    Feps = (sp.exp(sp.EulerGamma)/(4*sp.pi))**eps
    series, epsv = virtual_laurent(virtual/Feps, hi + 1)
    # `_real_part` is NOT applied here.  REMOVED 2026-07-30 after measuring
    # what it does to this very expression (fresh Hgq PP virtcoeff):
    #     eps^-2  ops 14   -> 14     (unaffected)
    #     eps^-1  ops 90   -> 0      ANNIHILATED
    #     eps^0   ops 5376 -> 0      ANNIHILATED  <-- the FINITE deliverable
    # `Hgq_V2_cross.py:170` multiplies the whole virtual by (-I/Nc), so with
    # an overall -i the physical part is Re(-i X) = Im(X); dropping terms that
    # carry an explicit I therefore deletes the CONTENT and keeps the phase.
    # Applied here it would have destroyed the virtual's entire contribution
    # to the finite hard function, silently, while leaving eps^-2 intact so
    # the gate still looked healthy.  See STATE 0z.77/0z.79.
    # The imaginary residue is REAL and still open; it must be fixed at the
    # SOURCE, taking 2 Re where the continuation is explicit and the overall
    # -i is visible (as Hqq_V2_renorm.py does), never by discarding I-terms.
    # RE-ENABLED 2026-07-30 once `_real_part` was fixed to EXPAND first (it
    # was annihilating Mul-wrapped coefficients; see its docstring).  The
    # virtual enters as 2 Re{Mtree^dagger Mloop}: the factor 2 is applied in
    # Hgq_V2_cross.py but the Re was deferred there and never taken.
    return {k: _real_part(resolve(series.coeff(epsv, k)))
            for k in range(lo, hi + 1)}


def _real_part(expression):
    """Keep only Re: the virtual enters as 2 Re{Mtree^dagger Mloop}.

    BUG FOUND 2026-07-30.  `Hgq_V2_cross.py` line 161 applies the factor 2
    for `2 Re{M0* M1}` with the comment "keep symbolic; Re at the end" -- and
    the end never came, so the FULL COMPLEX interference was being combined.
    The Hqq chain does take it (`Hqq_V2_renorm.py:118`, `e = 2*sp.re(...)`);
    the cross-built Hgq/Hqg virtuals did not.

    MEASURED on Hgq PP delta eps^-1: the virtual carried a bare `+7 I/6` and
    the total residue carried `+2 I pi` scaled identically -- the entire
    imaginary residue was the virtual's, uncancelled.  Reference check (8)
    requires no leftover imaginary part.

    Re is LINEAR and eps is real, so taking it per eps-Laurent coefficient is
    equivalent to taking it on the series.

    DO NOT USE `as_real_imag()` HERE.  Measured 2026-07-30: it ran >20 min on
    the Hgq virtual and was SIGTERM'd, because on a symbolic expression it
    cannot resolve `log(t1)` without knowing that t1 < 0 and tries ever harder
    to.  It is both a performance hazard and unreliable: the `I pi` from the
    +i0 continuation only materialises once the sign is known, so a symbolic
    `as_real_imag` silently leaves it behind.

    What this does instead is exact but DELIBERATELY LIMITED: the continuation
    in `Hgq_V2_cross.py` (continue_logs / continue_dilogs) already makes every
    branch explicit, so the imaginary part appears as top-level terms carrying
    an explicit `I`.  Dropping exactly those is correct AND linear-time.  A
    term that still mixes real and imaginary parts inside an unexpanded
    product would be missed, so the caller must VERIFY per projection rather
    than assume -- see STATE 0z.53.

    THE PROPER FIX IS UPSTREAM: take Re where the continuation happens and the
    signs are known, as `Hqq_V2_renorm.py:118` does (`e = 2*sp.re(...)`).
    `Hgq_V2_cross.py:161` instead defers it ("keep symbolic; Re at the end")
    and never takes it.

    EXPAND FIRST -- THIS IS THE WHOLE BUG (found 2026-07-30).  Without the
    expand, a coefficient of the form  prefactor * (big Add containing I)  is
    a single `Mul`, so `sp.Add.make_args` returns ONE argument, that argument
    `.has(I)`, and the ENTIRE expression is dropped.  MEASURED on the Hgq PP
    virtual before the fix:
        eps^-2  ops 14   -> 14     (an Add, so it survived)
        eps^-1  ops 90   -> 0      (a Mul -> annihilated)
        eps^0   ops 5376 -> 0      (a Mul -> annihilated)
    which I briefly mis-read as "the virtual is purely imaginary" and then as
    a phase-convention problem.  It is neither: the eps^-1 coefficient is
        pref * [ -6 Nc^2 Log(-Q2/t1) - ... - 50 Nc + 6 Log(Q2/s) + 15 - 6 I pi ]
    i.e. a genuine real part PLUS a -6 I pi.  Expanding turns it into an Add
    whose terms are individually real or purely imaginary, and dropping the
    I-carrying ones is then exactly Re.
    Do NOT use `as_real_imag()` here: Nc is not declared positive, so it
    produces re(Nc)/im(Nc)/arg(...) rubbish, and it is a measured hang on the
    larger coefficients (STATE 0z.54).
    """
    if expression == 0 or not expression.has(sp.I):
        return expression
    expanded = sp.expand(expression, log=False, power_base=False,
                         power_exp=False)
    kept = [term for term in sp.Add.make_args(expanded)
            if not term.has(sp.I)]
    return sp.Add(*kept)


def virtual(channel, projection):
    if channel not in VIRTUAL:
        return sp.S.Zero
    tag = "G" if projection == "g" else "PP"
    path = os.path.join(CACHE, "%s_V2_virt%s_ren_inv_sym.pkl"
                        % (channel, tag))
    if not os.path.exists(path):
        raise SystemExit("missing virtual %s" % path)
    return pickle.load(open(path, "rb"))


def coefficients(expression, lo=-2, hi=0):
    """Exact eps-Laurent coefficients of ONE term, factor by factor.

    This is the engine R5 used (`_eps_polynomial` / `_mask_eps_free` /
    `_factorwise_laurent`), which processed 40,000 terms in minutes on 15
    workers.  Calling `sp.series` on the ASSEMBLED SUM instead -- as the
    first version did -- makes SymPy determine leading behaviour across a
    multi-million-node `Add` at once; that step ran 8+ minutes on the
    single smallest channel with no result.

    The whole calculation is LINEAR in the terms, so expanding per term and
    summing coefficients is both exact and embarrassingly parallel.
    """
    if expression == 0:
        return {k: sp.S.Zero for k in range(lo, hi + 1)}
    direct = _eps_polynomial(expression)
    if direct is not None:
        return {k: direct.get(k, sp.S.Zero) for k in range(lo, hi + 1)}
    masked, backward = _mask_eps_free(expression)
    result = _factorwise_laurent(masked, lo, hi)
    if backward:
        result = {k: v.xreplace(backward) for k, v in result.items()}
    return {k: result.get(k, sp.S.Zero) for k in range(lo, hi + 1)}


def _worker(job):
    index, sector, factor, term = job
    return index, sector, coefficients(kf*factor*resolve(term))


def _flatten(expression):
    """One-level distribution of a prefactor over its single inner Add."""
    out = []
    for arg in sp.Add.make_args(expression):
        if arg.is_Mul:
            adds = [f for f in arg.args if f.is_Add]
            if len(adds) == 1:
                pref = sp.Mul(*[f for f in arg.args if f is not adds[0]])
                out.extend(pref*piece for piece in adds[0].args)
                continue
        out.append(arg)
    return out


def weight_signature(channel):
    """Identify the flavour weights a batch was built with.

    WHY THIS EXISTS (2026-07-31).  The weights in `PIECES` are baked into the
    stage-1 batches -- `main` computes `_flatten(weight*expression)` -- so a
    batch is only valid for the weights it was made with.  The weight on Hqq's
    `A` changed from the inherited `2*nf` to the measured `nf - 1`, and the
    launcher resumes from previously staged batches, so without this a rerun
    would SILENTLY inherit results built at the old weight and reproduce the
    very pole the change was meant to remove.  Stamping the weights into every
    batch and refusing mismatched ones makes that impossible rather than
    merely unlikely.
    """
    return repr(tuple((name, str(weight)) for name, weight in PIECES[channel]))


def accumulate(jobs, stem, label, signature=None):
    """Run jobs in parallel, checkpointing every CHUNK results.

    Batches whose recorded weight signature differs from the current one are
    REFUSED, not silently reused.
    """
    totals = {"delta": {-2: [], -1: [], 0: []},
              "plus1": {-2: [], -1: [], 0: []},
              "plus2": {-2: [], -1: [], 0: []}}
    done = set()
    for path in sorted(glob.glob("%s_%s_batch_*.pkl" % (stem, label))):
        saved = pickle.load(open(path, "rb"))
        stamped = saved.get("weights")
        if signature is not None and stamped != signature:
            raise SystemExit(
                "STALE BATCH: %s was built with weights\n    %s\nbut the "
                "current weights are\n    %s\nDelete the stale batches (and "
                "any staged copies in the base cache) and rerun; resuming "
                "across a weight change would silently reproduce the old "
                "result." % (os.path.basename(path), stamped, signature))
        done |= set(saved["indices"])
        for sector in totals:
            for power in totals[sector]:
                totals[sector][power].append(saved["sums"][sector][power])
    pending = [j for j in jobs if (j[0], j[1]) not in done]
    print("  %s: %d jobs, %d resumed, %d pending"
          % (label, len(jobs), len(jobs) - len(pending), len(pending)),
          flush=True)

    buffer_indices, buffer = [], {s: {p: [] for p in (-2, -1, 0)}
                                  for s in totals}
    batch = len(glob.glob("%s_%s_batch_*.pkl" % (stem, label)))
    started = time.time()

    def flush():
        nonlocal batch, buffer_indices, buffer
        if not buffer_indices:
            return
        payload = {"indices": buffer_indices,
                   "weights": signature,      # stale-batch guard, see above
                   "sums": {s: {p: sp.Add(*buffer[s][p]) for p in buffer[s]}
                            for s in buffer}}
        _atomic("%s_%s_batch_%04d.pkl" % (stem, label, batch), payload)
        for s in totals:
            for p in totals[s]:
                totals[s][p].append(payload["sums"][s][p])
        batch += 1
        buffer_indices, buffer = [], {s: {p: [] for p in (-2, -1, 0)}
                                      for s in totals}

    if pending:
        context = mp.get_context("fork")
        with context.Pool(WORKERS, maxtasksperchild=50) as pool:
            for count, (index, sector, coeffs) in enumerate(
                    pool.imap_unordered(_worker, pending, chunksize=1), 1):
                buffer_indices.append((index, sector))
                for power in (-2, -1, 0):
                    buffer[sector][power].append(coeffs[power])
                if len(buffer_indices) >= CHUNK:
                    flush()
                    print("    %s %d/%d (%.0f s)"
                          % (label, count, len(pending), time.time() - started),
                          flush=True)
        flush()
    return {s: {p: sp.Add(*totals[s][p]) for p in totals[s]} for s in totals}


def main():
    channel, projection = sys.argv[1], sys.argv[2]
    started = time.time()
    stem = os.path.join(CACHE, "finite_%s_%s" % (channel, projection))
    print("FINITE HARD PARTS %s %s  workers=%d chunk=%d"
          % (channel, projection, WORKERS, CHUNK), flush=True)

    residues = load_residues(channel, projection)
    print("  endpoint classes: %d" % len(residues), flush=True)

    # Build PER-TERM jobs.  The calculation is linear in the terms, so this
    # is exact and parallel; the old code expanded the assembled sum.
    jobs, index = [], 0
    for suffix, c, l, weight, expression in residues:
        d_fac = class_delta_factor(c, l)
        p1_fac, p2_fac = plus_factors(c, l)
        terms = _flatten(weight*expression)
        for term in terms:
            for sector, factor in (("delta", d_fac), ("plus1", p1_fac),
                                   ("plus2", p2_fac)):
                if factor == 0:
                    continue
                jobs.append((index, sector, factor, term))
            index += 1
        print("  class %s c=%s l=%s -> %d terms"
              % (suffix, c, l, len(terms)), flush=True)
    print("  total jobs: %d (%.0f s)" % (len(jobs), time.time() - started),
          flush=True)

    signature = weight_signature(channel)
    print("  weights: %s" % signature, flush=True)
    sums = accumulate(jobs, stem, "real", signature)

    if os.environ.get("FHP_ONLY_PIECE"):
        # Piece-isolation mode: the virtual and the counterterms belong to the
        # channel, not to any one real piece, so they are excluded.  The output
        # is that piece's REAL contribution alone, at weight 1.
        zero = {k: sp.S.Zero for k in (-2, -1, 0)}
        extra = {"delta": dict(zero), "plus1": dict(zero), "plus2": dict(zero)}
        print("  FHP_ONLY_PIECE=%s: virtual and counterterms EXCLUDED"
              % os.environ["FHP_ONLY_PIECE"], flush=True)
    else:
        pref, cdelta, cplus = counterterms(channel, projection)
        vc = virtual_coefficients(channel, projection)
        ctd = coefficients(pref*cdelta)
        extra = {
            "delta": {k: vc[k] + ctd[k] for k in (-2, -1, 0)},
            "plus1": coefficients(pref*cplus),
            "plus2": {k: sp.S.Zero for k in (-2, -1, 0)},
        }
    # Stage 2 (Mathematica) reduces the EXPORTED batches.  The virtual and
    # counterterms are NOT in those batches, so write them as an extra
    # pseudo-batch; otherwise stage 2 reduces the real part with no
    # subtraction at all, which is guaranteed nonzero -- and is exactly what
    # every stage-2 verdict so far reported.
    _atomic(os.path.join(CACHE, "finite_%s_%s_real_batch_9999.pkl"
                         % (channel, projection)),
            {"indices": [("extra", "extra")], "sums": extra})
    print("  counterterms + virtual expanded (%.0f s)"
          % (time.time() - started), flush=True)

    # DO NOT REDUCE THE MERGED SUM HERE.  Fixed 2026-07-31.
    #
    # This used to call `sp.cancel(sp.together(merged[k]))` on the eps^-2 and
    # eps^-1 sums.  That is DEAD WORK and a documented hang:
    #   * STATE 11e: "sp.cancel(sp.together(...)) on 100k+ ops does not
    #     return".  Hqq g merges 130727 per-term contributions.
    #   * Nothing downstream consumes it.  Stage 2 (mathematica/stage2_poles.wls)
    #     reduces the EXPORTED BATCHES directly and never reads the merged
    #     pickle -- see STATE 0z.67, where that bypass was introduced precisely
    #     to avoid this call.
    # MEASURED consequence: on 2026-07-31 both stage-1 parents printed
    # "counterterms + virtual expanded" and then sat in this reduction
    # indefinitely.  Their batches were already complete and safe on disk, but
    # the stage-2 jobs had been chained to job COMPLETION, so they were blocked
    # waiting on a computation nobody needed.  Releasing them by hand started
    # stage 2 immediately from batches that had been ready for a long time.
    #
    # The sums are still SAVED, unreduced, so nothing is lost -- a caller that
    # actually wants a reduced pole can reduce them itself, and stage 2 does
    # exactly that, in Mathematica, with the colour identity and the physical
    # sign assumptions imposed (which sympy here could not do anyway, so this
    # verdict was never trustworthy: it reported "zero=False" for expressions
    # that vanish once CF = (Nc^2-1)/(2Nc) is used).
    result = {}
    for sector in ("delta", "plus1", "plus2"):
        merged = {k: sums[sector][k] + extra[sector][k] for k in (-2, -1, 0)}
        result[sector] = {"pole2_unreduced": merged[-2],
                          "pole1_unreduced": merged[-1],
                          "finite": merged[0]}
        print("  %-6s eps^-2 ops=%d  eps^-1 ops=%d  eps^0 ops=%d "
              "(unreduced by design; stage 2 reduces the batches)"
              % (sector, sp.count_ops(merged[-2]), sp.count_ops(merged[-1]),
                 sp.count_ops(merged[0])), flush=True)
        _atomic("%s_%s.pkl" % (stem, sector), result[sector])

    _atomic("%s.pkl" % stem, {
        "version": "finite-hard-parts-v2",
        "channel": channel, "projection": projection,
        "delta": result["delta"], "plus1B": result["plus1"],
        "plus2B": result["plus2"],
        # `poles_vanish` REMOVED.  It was computed from the sympy reduction
        # above, which could not impose CF = (Nc^2-1)/(2 Nc) or the physical
        # sign conditions and therefore reported False for expressions that are
        # identically zero.  The authoritative pole verdict comes from stage 2.
        "poles_reduced": False,
        "weights": weight_signature(channel),
        "elapsed_seconds": time.time() - started})
    print("FINITE_HARD_PARTS_DONE %s %s %.0f s"
          % (channel, projection, time.time() - started), flush=True)


if __name__ == "__main__":
    main()
