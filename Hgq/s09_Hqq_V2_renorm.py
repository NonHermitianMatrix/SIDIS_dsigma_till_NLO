# Hqq_V2_renorm.py -- Step V2 (WS11): renormalize the raw one-loop x tree
# interference of gamma* q -> q g (python/generated/Hqq_V1_raw.py).
# Chain (AI.md sec. 7):
#  (1) analytic continuation: the Package-X logs arrive as log(-mu^2/x)
#      etc. for x in {s, t, u}; physical region s>0, t<0, u<0, Q2>0:
#      log(-mu^2/s) -> log(mu^2/s) - I pi (from s + i0); t,u spacelike:
#      log(-mu^2/t) real.  Only the REAL part of 2 Re{tree x loop} counts.
#  (2) unify EpsilonUV -> eps, EpsilonIR -> eps AFTER separating the UV
#      pole for the coupling counterterm (poles live in EpsilonUV/IR, NOT
#      eps -- substituting late is the documented trap).
#  (3) MS-bar coupling renormalization: the O(gs^4) interference needs
#      delta(gs^2): CT = -(alphas/(4 pi)) (beta0/epsUV) Seps * M2LO_gamma
#      with beta0 = 11 CA/3 - 2 Nf/3, applied per projection.
#  (4) checks: (7) FreeQ EpsilonUV after CT; 1/eps^2 coefficient NONZERO
#      and equal to the Catani prediction -(alphas/2pi)(CF + CA/2) |M0|^2
#      per projection (pins the overall normalization/phases dropped in
#      the diagram transcriptions).
import sys, os, pickle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp

s, t, Q2 = sp.symbols('s t Q2', positive=True)
eps, Nc, Nf = sp.symbols('eps Nc Nf')
# ScaleMu MUST be positive=True -- SAME BUG AS Hgq_V2_cross.py (2026-07-30).
# `continue_logs` runs at line ~117, but ScaleMu -> sqrt(Q2) is substituted
# LATER (in Hqq_V2_ren_invariant_sym.py).  At continuation time the Package-X
# logs are log(-4 pi ScaleMu^2/X); with ScaleMu unconstrained SymPy cannot
# sign ScaleMu^2, the sign test returns None, and they are NEVER continued.
# Taking 2*sp.re() afterwards does NOT rescue it: sympy cannot evaluate the
# real part of a log whose argument it cannot sign either.
# MEASURED at a REGION-CONSISTENT point (s=7, Q2=13, up=5 => t=-s-Q2-up=-25):
#     Hqq virtual G  : 6 uncontinued negative-argument logs
#     Hqq virtual PP : 4
#     Hqg (t<->u relabel of Hqq): 6 and 4, e.g. log(-4*pi*Q2/(-Q2-s-t))
# Hgq had the identical defect and the same one-word fix removed all of them
# (5->0 and 6->0); see STATE 0z.68/0z.71.  Hqg inherits this through the
# relabel, so fixing it HERE fixes both Hqq and Hqg.
ScaleMu, EpsUV, EpsIR = sp.symbols('ScaleMu EpsilonUV EpsilonIR')
ScaleMu = sp.Symbol('ScaleMu', positive=True)
CF = (Nc**2 - 1)/(2*Nc)
CA = Nc

class PaXDiLog(sp.Function):
    """Package-X DiLog[x, a] = Li2(x + I a 0) placeholder (picklable)."""
    nargs = 2


def continue_dilogs(e):
    """Physical-region continuation of the three DiLog structures present
    (s>0 timelike; t,u<0 spacelike; Q2>0):
      DiLog[(Q2+s)/s, -(Q2+s)]: x=1+Q2/s>1 ON the cut, prescription -i0:
        Li2(x - i0) = pi^2/3 - Li2(1/x) - (1/2)ln^2 x - I pi ln x
      DiLog[(Q2+t)/t, .] and DiLog[(s+t)/(Q2+s+t), .]: arguments < 1,
        real: plain polylog(2, x)."""
    rep = {}
    for dl in e.atoms(PaXDiLog):
        xarg = sp.cancel(dl.args[0])
        if sp.cancel(xarg - (Q2 + s)/s) == 0:
            xx = (Q2 + s)/s
            rep[dl] = (sp.pi**2/3 - sp.polylog(2, 1/xx)
                       - sp.log(xx)**2/2 - sp.I*sp.pi*sp.log(xx))
        else:
            rep[dl] = sp.polylog(2, xarg)
    return e.xreplace(rep)


def load_v1_raw():
    """Parse generated/Hqq_V1_raw.py, converting the Mathematica syntax
    (Log[..], PolyLog[..], Pi, EulerGamma) and stripping the duplicated
    tree colour factor SUNT[SUNIndex[a]] (the colour trace colf already
    contains the tree's T^a; the stray factor is an overall duplicate)."""
    import re
    txt = open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            'generated', 'Hqq_V1_raw.py')).read()
    out = {}
    for name in ('virtGraw', 'virtPPraw'):
        m = re.search(name + r"\s*=\s*sympify\('(.*)'\)", txt)
        sN = m.group(1)
        sN = sN.replace('SUNT[SUNIndex[a]]', '1')
        sN = sN.replace('[', '(').replace(']', ')')
        loc = {'Log': sp.log, 'PolyLog': lambda n, x: sp.polylog(n, x),
               'Pi': sp.pi, 'EulerGamma': sp.EulerGamma, 'Sqrt': sp.sqrt,
               'I': sp.I, 'PaXDiLog': PaXDiLog}
        out[name] = sp.sympify(sN, locals=loc)
    return out['virtGraw'], out['virtPPraw']


virtGraw, virtPPraw = load_v1_raw()
from generated.Hqq_L2_M2 import M2g, M2PP     # LO squared (for CT + Catani)


def byname(e):
    return {sym.name: sym for sym in e.free_symbols}


def canon(e):
    bn = byname(e)
    rep = {}
    for nm, target in (('s', s), ('t', t), ('Q2', Q2), ('eps', eps),
                       ('Nc', Nc), ('SUNN', Nc), ('EpsilonUV', EpsUV),
                       ('EpsilonIR', EpsIR), ('ScaleMu', ScaleMu)):
        if nm in bn and bn[nm] is not target:
            rep[bn[nm]] = target
    return e.xreplace(rep)


def continue_logs(e):
    """+i0 continuation: log(-X/s) -> log(X/s) - I pi for s>0 (timelike),
    applied to any log with argument manifestly negative for s>0,t<0."""
    repl = {}
    for lg in e.atoms(sp.log):
        arg = sp.simplify(lg.args[0])
        # detect overall -1/s or -s structure (timelike): arg < 0 for s>0
        a2 = sp.together(arg.subs({t: -sp.Symbol('tp', positive=True)}))
        if sp.ask(sp.Q.negative(a2), sp.Q.positive(sp.Symbol('tp'))):
            repl[lg] = sp.log(-arg) - sp.I*sp.pi
    return e.xreplace(repl)


if __name__ == '__main__':
    virtG = canon(virtGraw)
    virtPP = canon(virtPPraw)
    lo_g = canon(M2g)
    lo_pp = canon(M2PP)
    print("[1] loaded: virtG/virtPP + LO; EpsUV present:",
          virtG.has(EpsUV), flush=True)

    out = {}
    for name, raw, lo in [('G', virtG, lo_g), ('PP', virtPP, lo_pp)]:
        # (1) continuation + 2 Re
        e = continue_dilogs(raw)
        e = continue_logs(e)
        e = 2*sp.re(sp.expand(e).rewrite(sp.re, evaluate=False)
                    ) if False else 2*e   # keep symbolic; Re at the end
        # (2) split off UV pole, then unify
        uvpole = sp.limit(sp.expand(e*EpsUV), EpsUV, 0) if e.has(EpsUV) else 0
        print("[2] %s: UV 1/eps pole coefficient ops %s" %
              (name, sp.count_ops(uvpole)), flush=True)
        e = e.xreplace({EpsUV: eps, EpsIR: eps})
        out[name] = e
        pickle.dump(e, open('cache/Hqq_V2_virt%s_preCT.pkl' % name, 'wb'))
    print("[3] cached pre-CT virtG/virtPP (eps unified);"
          " CT and Catani check in the next micro-step", flush=True)
