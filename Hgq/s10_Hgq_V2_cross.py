# Hgq_V2_cross.py -- Step V1/V2 for channel Hgq (chn1, gamma* g -> q qbar with the
# QUARK fragmenting), obtained by CROSSING the gamma* q -> q g one-loop x tree
# interference.  The crossing was proven exactly at LO in
# python/Hgq_LO_crossing_check.py (CROSSING_HOLDS True):
#
#   P = -k2, K2 = -p  =>  s <-> u at fixed t, i.e. s -> -s-t-Q2,
#   average conversion (1/(2-2eps))(1/(Nc^2-1)) / [(1/2)(1/Nc)] = Nc/((1-eps)(Nc^2-1)),
#   times (-1) for crossing a fermion line.
#
# WHY THIS ACTS ON THE *RAW* EXPORT, NOT THE CONTINUED VIRTUAL.  Unlike the
# t <-> u relabel used for channel Hqg, this crossing MOVES s OFF THE CUT: the
# old s (timelike, on the cut) becomes the new u (spacelike), and the new s
# appears where the old u was.  Continuing first and substituting afterwards
# would evaluate a function on the wrong sheet.  So the substitution is applied
# to python/generated/Hqq_V1_raw.py (and Hqq_V1_raw_k2k2.py) BEFORE any
# continuation, and the +i0 continuation is then redone for the crossed region.
#
# THE CROSSED REGION AND WHAT IT IMPLIES (derived, not assumed).  In the new
# variables s>0, t<0, Q2>0 and u = -s-t-Q2 < 0, hence s+t+Q2 > 0.  Substituting
# s -> -s-t-Q2 into the structures that actually occur in the raw export:
#   Log[-c/s_old]          -> Log[+c/(s+t+Q2)]              REAL (was on the cut)
#   Log[-c/t]              -> unchanged, t<0 so -c/t > 0    REAL
#   Log[ c/(Q2+s_old+t)]   -> Log[-c/s]                     ON THE CUT (new)
#   DiLog[(Q2+s_old)/s_old] -> 1 + Q2/u  with u<0  => < 1   REAL (was on the cut)
#   DiLog[(Q2+t)/t]         -> 1 + Q2/t  with t<0  => < 1   REAL
#   DiLog[(s_old+t)/(Q2+s_old+t)] -> (s+Q2)/s > 1           ON THE CUT (new)
# so exactly one log structure and one dilog structure need continuation, and
# they are the images of the two that needed it before -- the cut has moved, as
# it must.  Every invariant carries the Feynman prescription X + i0, giving
#   log(-c/s) = log(c/s) - I pi,
#   Li2(x - i0) = pi^2/3 - Li2(1/x) - (1/2) log^2 x + I pi log x   for x > 1.
#
# VALIDATION (symbolic, exact in eps): Catani's double pole
#   virt = -(alphas/2pi)(sum of the three partons' colour charges)|M0|^2/eps^2
# involves C_A + C_F + C_F for gamma* g -> q qbar, the SAME combination
# 2C_F + C_A as for gamma* q -> q g (the parton content {q, q, g} is identical,
# only which leg is incoming changed).  So the eps^-2 coefficient of virt/LO
# must come out as the SAME CONSTANT as the Hqq one -- that is the check the
# crossing plus its continuation must pass.
#
# Inputs : python/generated/Hqq_V1_raw.py       (Hqq_V1_loop_traces.wls)
#          python/generated/Hqq_V1_raw_k2k2.py  (Hqq_V1_k2k2_projection.wls)
#          python/generated/Hqq_S12_LO_M2.py    (LO of the crossed channel)
# Outputs: cache/Hgq_V2_virt{G,PP}_ren_inv_sym.pkl
import os, pickle, re, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CACHE = os.path.join(HERE, 'cache')
MMA = os.path.join(ROOT, 'mathematica')
s, t, Q2 = sp.symbols('s t Q2', positive=True)
eps, Nc = sp.symbols('eps Nc')
# ScaleMu MUST be positive=True.  BUG FOUND 2026-07-30: it was declared with
# NO assumptions, and `continue_logs` runs BEFORE the
# `ScaleMu -> sqrt(Q2)` substitution (see build()).  At continuation time the
# Package-X log is  log(-4 pi ScaleMu^2/s)  -- CLAUDE.md section 7 pins that
# 4 pi convention -- and with ScaleMu unconstrained SymPy cannot sign
# ScaleMu^2, so `_sign_in_region` returns None and the log is NEVER
# continued.  The substitution then happens afterwards, freezing
# log(-4 pi Q2/s) into the result permanently.
# MEASURED consequence (Hgq PP delta eps^-1): the virtual carried exactly one
# negative-argument log, log(-4*pi*Q2/s), with hasI=False -- real and CT had
# NONE.  Mathematica's FullSimplify then auto-continued it under {s>0,Q2>0},
# manufacturing BOTH leftover structures at once:
#     log(4 pi Q2/s) + I pi  =  log(4pi) + log(Q2) - log(s) + I pi
# i.e. the unpaired bare log(Q2) AND the 6 I pi of STATE 0z.66.
ScaleMu, EpsUV, EpsIR = sp.symbols('ScaleMu EpsilonUV EpsilonIR')
ScaleMu = sp.Symbol('ScaleMu', positive=True)
ee, eq, gs = sp.symbols('ee eq gs')
# Nc AND nf SYMBOLIC (fixed 2026-07-31).  This read
#     NF = 4;  beta0 = Rational(11,3)*3 - Rational(2,3)*NF     # = 25/3
# i.e. BOTH colour and flavour evaluated to numbers, so the UV coupling
# counterterm entered as the pure rational 25/3 while the mass-factorization
# counterterm carries the symbolic (11 Nc - 2 nf)/3 from P0gg's delta term
# (cache/P0gg.pkl).  A number cannot cancel a polynomial in Nc and nf, and the
# surviving Hgq delta eps^-1 residue showed exactly that shape:
#     -(1/12) ee^2 eq^2 gs^4 s (Nc(50 - 11 Nc + 2 nf) + ...)/(Nc Pi)
# whose rational part is Nc(50 - 3 beta0_sym) -- the symbolic beta0 from the
# CT standing alone against the numeric one from here.  The virtual carried NO
# nf dependence at all, which is impossible for a UV-renormalized one-loop
# amplitude, and that is what named this line.
NF = sp.Symbol('nf')
beta0 = sp.Rational(11, 3)*Nc - sp.Rational(2, 3)*NF
Seps = (4*sp.pi)**eps/sp.gamma(1 - eps)
Feps = (sp.exp(sp.EulerGamma)/(4*sp.pi))**eps
COUP = ee**2*eq**2*gs**4

CROSS = {s: -s - t - Q2}                       # s <-> u at fixed t
CFAC = -Nc/((1 - eps)*(Nc**2 - 1))             # average conversion x (-1)


class PaXDiLog(sp.Function):
    """Package-X DiLog[x, a] = Li2(x + I a 0)."""
    nargs = 2


def load_raw(fname, varname):
    txt = open(os.path.join(HERE, 'generated', fname)).read()
    m = re.search(varname + r"\s*=\s*sympify\('(.*)'\)", txt)
    if m is None:
        raise KeyError('%s not found in %s' % (varname, fname))
    sN = m.group(1).replace('SUNT[SUNIndex[a]]', '1')
    sN = sN.replace('[', '(').replace(']', ')')
    loc = {'Log': sp.log, 'PolyLog': lambda n, x: sp.polylog(n, x),
           'Pi': sp.pi, 'EulerGamma': sp.EulerGamma, 'Sqrt': sp.sqrt,
           'I': sp.I, 'PaXDiLog': PaXDiLog}
    return sp.sympify(sN, locals=loc)


def canon(e):
    bn = {sym.name: sym for sym in e.free_symbols}
    rep = {}
    for nm, target in (('s', s), ('t', t), ('Q2', Q2), ('eps', eps),
                       ('Nc', Nc), ('SUNN', Nc), ('EpsilonUV', EpsUV),
                       ('EpsilonIR', EpsIR), ('ScaleMu', ScaleMu)):
        if nm in bn and bn[nm] is not target:
            rep[bn[nm]] = target
    return e.xreplace(rep)


# --------------------------------------------------------------------------
# continuation for the CROSSED region:  s > 0 (on the cut), t < 0,
# u = -s-t-Q2 < 0  (equivalently s+t+Q2 > 0)
# --------------------------------------------------------------------------
POS = (s, Q2, s + t + Q2, -t, -(-s - t - Q2))     # manifestly positive there


def _sign_in_region(x):
    """+1 / -1 / None for the sign of x in the crossed physical region."""
    x = sp.cancel(sp.together(x))
    # substitute t = -tp (tp>0) and u = -up (up>0) via t = -s-Q2-u:
    tp, up = sp.symbols('tp up', positive=True)
    # REGION SIGN BUG, FOUND 2026-07-30.  This read
    #     x.xreplace({t: -s - Q2 + (-up)})      # i.e. t = -s - Q2 - up
    # which gives  s + t + Q2 = -up < 0 -- the OPPOSITE of the region this
    # very module documents four lines above ("u = -s-t-Q2 < 0, equivalently
    # s+t+Q2 > 0").  So every sign test was evaluated OUTSIDE the physical
    # region and mis-classified the logs whose arguments depend on (s+t+Q2).
    # Correct: u = -up < 0  =>  t = -s - Q2 - u = -s - Q2 + up, and then
    # s + t + Q2 = up > 0 as required.
    # MEASURED at three genuinely physical points (s>0, t<0, u<0, s+t+Q2>0):
    # before this fix the Hgq virtual still carried 4 uncontinued
    # negative-argument logs in BOTH projections even after ScaleMu was made
    # positive, while Hqq/Hqg -- whose continue_logs uses the weaker but
    # CORRECT t -> -tp test -- went cleanly to 0.  That is why Hgq's
    # delta eps^-1 never moved (47 -> 47) while the others did.
    xr = sp.cancel(x.xreplace({t: -s - Q2 + up}))      # u = -up < 0
    xr = sp.simplify(xr)
    if xr.is_positive:
        return 1
    if xr.is_negative:
        return -1
    num, den = sp.fraction(sp.cancel(xr))
    sn, sd = sp.simplify(num).is_positive, sp.simplify(den).is_positive
    if sn is not None and sd is not None:
        return 1 if sn == sd else -1
    return None


def continue_logs(e):
    """log(A) with A<0 in the region -> log(-A) - I pi  (Feynman s + i0)."""
    rep = {}
    for lg in e.atoms(sp.log):
        arg = lg.args[0]
        if arg.is_number:
            continue
        if _sign_in_region(arg) == -1:
            rep[lg] = sp.log(-arg) - sp.I*sp.pi
    return e.xreplace(rep)


def continue_dilogs(e):
    """Li2(x + I a 0).  x < 1 in the region -> plain Li2(x).
       x > 1 with the -i0 prescription ->
         pi^2/3 - Li2(1/x) - (1/2) log^2 x + I pi log x."""
    rep = {}
    for dl in e.atoms(PaXDiLog):
        x = sp.cancel(sp.together(dl.args[0]))
        if _sign_in_region(x - 1) == 1:            # x > 1: on the cut
            rep[dl] = (sp.pi**2/3 - sp.polylog(2, 1/x)
                       - sp.log(x)**2/2 + sp.I*sp.pi*sp.log(x))
        else:                                      # x < 1: real
            rep[dl] = sp.polylog(2, x)
    return e.xreplace(rep)


# NOTE (2026-07-25): the eps^-2 extraction moved to Mathematica -- sympy's
# series() on the renormalized virtual never returned (job 14143162 spent 5 h
# inside the FIRST such call, on the Hqq reference, before any crossing work).
# This stage does the crossing + continuation (substitutions, fast) and exports.
from mma_export import write_m


def build(raw, lo_crossed, label):
    started = time.monotonic()
    e = canon(raw).xreplace(CROSS)          # cross FIRST, continue after
    e = continue_dilogs(e)
    e = continue_logs(e)
    e = CFAC*e
    # FACTOR 2 for 2 Re{M0* M1}.  The reference chain applies it in
    # Hqq_V2_renorm.py ("e = ... 2*e   # keep symbolic; Re at the end") between
    # the continuation and the pre-CT cache, so a build that starts from the RAW
    # export must supply it explicitly.  Omitting it made the Catani eps^-2 come
    # out at exactly HALF the reference value (job 14144147, tag HgqG:
    # gs^2(1-2Nc^2)/(8 Nc Pi^2) against the reference gs^2(1-2Nc^2)/(4 Nc Pi^2))
    # -- a clean factor of 2, which is what pointed at this line.
    e = 2*e
    # same normalization chain as Hqq_V2_ren_invariant_sym.py
    e = (-sp.I/Nc)*e*COUP
    # ScaleMu -> 1, NOT sqrt(Q2) (fixed 2026-07-31).  Package-X's ScaleMu^(2eps)
    # is ONE of the four powers of mu^eps carried by gs^4; the other two sit in
    # the couplings.  The real emission (kf = Seps/(16 pi^2)) and the
    # mass-factorization counterterm (PREF = gs^2 Seps/(16 pi^2 eps)) carry NO
    # mu at all, i.e. the whole project drops mu^(4eps) as an overall factor --
    # legitimate once the poles cancel, since it then multiplies a finite
    # quantity.  Substituting sqrt(Q2) here left the virtual with ONE
    # unbalanced power of (mu^2)^eps and hence a bare Log Q2 in the delta
    # eps^-1 slot, with coefficient exactly the virtual's own eps^-2
    # coefficient V(-2).  MEASURED, not assumed: the CT eps^-1 contains
    # log(B), log(1/s), log(-1/t1) and NO log(Q2); and since the total's
    # log(Q2) coefficient equals the virtual's, the real's is exactly zero too.
    # eps^-2 is untouched by this (an overall eps-dependent factor first acts
    # at eps^-1), so the validated double-pole cancellation is preserved.
    e = e.xreplace({ScaleMu: sp.Integer(1)})
    e = e.xreplace({EpsUV: eps, EpsIR: eps})
    # WEIGHT 2, NOT 4 (fixed 2026-07-31).  `uvct` already carries its own *2 for
    # the 2 Re{M0^dagger M1} normalization that `e = 2*e` above applies to the
    # loop; the outer `2*uvct` double-counted it, so the coupling counterterm
    # entered at twice its correct magnitude.  SOLVED, not guessed: the residue
    # is linear in the weight, and with beta0 symbolic the weight closing the
    # rational part came out to exactly 2 in BOTH projections
    # (python/Hgq_V2_beta0_check.py).  eps^-2 cannot see this -- uvct is a
    # single pole -- which is why the double pole cancelled correctly all along
    # and only eps^-1 exposed it.
    uvct = -(beta0/eps)*Seps*(gs**2/(16*sp.pi**2))*lo_crossed*2
    virt_ren = (e + uvct)*Feps
    floats = virt_ren.atoms(sp.Float)
    nonfinite = (virt_ren.has(sp.zoo) or virt_ren.has(sp.nan)
                 or virt_ren.has(sp.oo) or virt_ren.has(-sp.oo))
    if floats or nonfinite:
        raise ValueError('%s exactness gate failed: Float=%d nonfinite=%s'
                         % (label, len(floats), nonfinite))
    print('%s: built, ops=%d Float=0 nonfinite=False seconds=%.1f'
          % (label, sp.count_ops(virt_ren), time.monotonic() - started),
          flush=True)
    return virt_ren, None


def atomic_pickle(value, path):
    tmp = '%s.tmp.%d' % (path, os.getpid())
    with open(tmp, 'wb') as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(tmp, path)


def main():
    from generated.Hqq_L2_M2 import M2g as M2g_qq, M2PP as M2PP_qq
    from generated.Hqq_S12_LO_M2 import M2g_gq, M2PP_gq

    # reference pair (uncrossed channel), exported for the same comparison
    for proj, lo in (('G', M2g_qq), ('PP', M2PP_qq)):
        v = pickle.load(open(os.path.join(
            CACHE, 'Hqq_V2_virt%s_ren_inv_sym.pkl' % proj), 'rb'))
        write_m(v, os.path.join(
            MMA, 'catani_Hgq%s_virtqq.m' % proj), 'virtqq')
        write_m(canon(sp.sympify(lo)),
                os.path.join(MMA, 'catani_Hgq%s_loqq.m' % proj), 'loqq')
        print('reference (Hqq) %s exported' % proj, flush=True)

    jobs = [('G', 'Hqq_V1_raw.py', 'virtGraw', M2g_gq)]
    kk = os.path.join(HERE, 'generated', 'Hqq_V1_raw_k2k2.py')
    if os.path.exists(kk):
        jobs.append(('PP', 'Hqq_V1_raw_k2k2.py', 'virtKKraw', M2PP_gq))
    else:
        print('NOTE: Hqq_V1_raw_k2k2.py absent -- PP projection skipped '
              '(job v1kk still running)', flush=True)

    ok = True
    for proj, fname, varname, lo in jobs:
        raw = load_raw(fname, varname)
        lo_c = canon(sp.sympify(lo))
        virt, _ = build(raw, lo_c, 'Hgq %s' % proj)
        atomic_pickle(virt, os.path.join(
            CACHE, 'Hgq_V2_virt%s_ren_inv_sym.pkl' % proj))
        write_m(virt, os.path.join(
            MMA, 'catani_Hgq%s_virtgq.m' % proj), 'virtgq')
        write_m(lo_c, os.path.join(
            MMA, 'catani_Hgq%s_logq.m' % proj), 'logq')
        print('Hgq %s: exported catani_Hgq%s_*.m' % (proj, proj), flush=True)
    print('HGQ_V2_CROSS_DONE', flush=True)


if __name__ == '__main__':
    main()
