#!/usr/bin/env python3
"""Steps S1 (CTpdf, WS13a) + S2 (CTff, WS13b) for the GLUON channels, in the
PARTONIC INVARIANTS (s, t1, Q2, s23; B a free symbol) -- the frame the C2
assembly, the real endpoint residues and BigTMD's hard functions all use.

WHY THIS FILE EXISTS (found 2026-07-26 08:45).  `Hglu_S12_CT.py` builds the same
counterterms in the MEASURED-variable frame: it imports s_of, t1_of, u1_of, B_up
from Hqq_R4_kinmap, which are expressions in (x, z, Q2, PHT, xi, s23).  Step R5
then adds that `Creg` straight onto the real-emission integrand, which is in the
INVARIANT frame -- so the chn4 regular parts came out carrying x, z, PHT, xi and
FAILED the frame gate:
    r5reg_MR2gHGG.m  / r5reg_MR2PPHGG.m : frame gate stray {x, z, PHT, xi}
(the gate lines were absent from the R5 logs because `wolframscript` stdout is
block-buffered and the buffer was lost at exit; `Hqq_R5_verify.wls` found it).
chn2 was never affected: it uses `Hqq_CTbt.pkl`, the invariant-frame build.

WHAT CHANGES AND WHAT DOES NOT.  The FLAVOUR CONTENT -- which P0 (x) LO terms
survive per channel -- is taken UNCHANGED from `Hglu_S12_CT.py` (validated:
chn4/5/6 come out regular-only, chn5 and chn6 have equal operation counts).
Only the KINEMATIC INPUTS are replaced, by the invariant-frame forms that
`Hqq_CTbt.py` documents and uses, which follow from s + t1 + u1 + Q2 = s23:
  PDF side:  J = s + Q2 + u1 = s23 - t1;  xit*  = -t1/(s23 - t1);
             c = (1 - xit*)/s23 = 1/(s23 - t1);  s' = xit(s + Q2) - Q2, t' = t1.
  FF  side:  zetat* = (s - s23)/s;  c = (1 - zetat*)/s23 = 1/s;
             J = (s - s23)/zetat^2 at zetat*;   s' = s, t' = -Q2 + (t1+Q2)/zetat.
  B is a FREE symbol (the C2 assembly supplies it), not B_up.

WHICH FRAME IS RIGHT, SETTLED BY BigTMD (read 2026-07-26, directive 7 allows
reading their formulas to check ours).  Their hard functions take s, t, Q, s23
and B as INDEPENDENT arguments,
    regular(g,gp,s,t,Q,s23,mu,nf),  delta(g,gp,s,t,Q,s23,mu,B,nf)
and the s23 -> 0 evaluation happens in the ASSEMBLY, not inside the hard part:
    Fg += _Pg.delta(1,1,s,t0,Q,zero,Q,B,nf)*factor0        (sidis.py)
with t0, zeta0, jac0, factor0 the s23 -> 0 versions supplied from outside.  So at
the HARD-FUNCTION level s and t1 do not depend on s23, and `.subs(s23, 0)` at the
delta locus must act on the EXPLICIT s23 only.  The measured-frame build
conflates the two -- its s_of/t1_of carry s23 through zeta -- so its Cdelta is
not the hard-function-level object.  That is a second, independent reason to
replace it, beyond the frame contamination of the R5 regular parts.

EXACTNESS GATE (STATE 10a rule 1 -- validate against an independent path).
The gate is NOT against the measured-frame build (which differs at the delta
locus for the reason just given), but against `cache/Hqq_CTbt.pkl`: the
INVARIANT-FRAME counterterms for chn2, written by the separate, already-validated
`Hqq_CTbt.py`.  Adding the channel ('q','q') to this script's flavour map makes
it produce exactly the chn2 counterterms, so
    simplify(ours['Hqq'][side][proj][key] - Hqq_CTbt[side][proj][key]) == 0
for all 12 (side, proj, key) combinations is a genuine cross-check of the whole
machinery -- splitting functions, endpoint loci, Jacobians, the log(B c0) delta
term -- against an independent implementation.  A SECOND, informational check
maps back to the measured frame and reports which pieces agree with
`Hglu_S12_CT.pkl`: Creg and Cplus should, Cdelta should NOT.
The pickle is written only if the primary gate passes.

Output: cache/Hglu_CTbt.pkl, same layout as Hglu_S12_CT.pkl:
        {(chan, side): {proj: {'Cdelta':, 'Cplus':, 'Creg':}}} plus 'PREF'.
"""
import os
import pickle
import sys
import time
import hashlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp

from Hqq_R4_kinmap import s_of, t1_of, B_up
from generated.Hqq_L2_M2 import M2g as M2g_qq, M2PP as M2PP_qq
from generated.Hqq_S12_LO_M2 import M2g_gq, M2PP_gq, M2g_qg, M2PP_qg

eps = sp.Symbol('eps')
s, t1, Q2, s23, B = sp.symbols('s t1 Q2 s23 B')
eqp = sp.Symbol('eqp')
xit, zetat = sp.symbols('xit zetat', positive=True)
CF, TF, Nc, nf, gs = (sp.Symbol('CF'), sp.Rational(1, 2), sp.Symbol('Nc'),
                      sp.Symbol('nf'), sp.Symbol('gs'))
PREF = (gs**2/(16*sp.pi**2))*(4*sp.pi)**eps/sp.gamma(1 - eps)/eps
HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'cache')
VERSION = 'hglu-ctbt-invariant-v2'


def file_sha256(path):
    value = hashlib.sha256()
    with open(path, 'rb') as stream:
        for block in iter(lambda: stream.read(1 << 20), b''):
            value.update(block)
    return value.hexdigest()


def by_name(expr, mapping):
    return expr.xreplace({symbol: mapping[symbol.name]
                          for symbol in expr.free_symbols
                          if symbol.name in mapping})


P0qq = {'reg': 2*CF*(-1 - xit), 'plus': 4*CF, 'delta': 3*CF}
P0qg = {'reg': 2*TF*(xit**2 + (1 - xit)**2), 'plus': 0, 'delta': 0}
P0gq = {'reg': 2*CF*(1 + (1 - xit)**2)/xit, 'plus': 0, 'delta': 0}
_gg = pickle.load(open(os.path.join(CACHE, 'P0gg.pkl'), 'rb'))
P0gg = {'reg': _gg['reg'].subs(_gg['var'], xit).subs(sp.Symbol('nf'), nf),
        'plus': _gg['plus'].subs(_gg['var'], xit),
        'delta': _gg['delta'].subs(sp.Symbol('nf'), nf)}


def in_z(P0):
    return {key: (value.subs(xit, zetat) if value != 0 else 0)
            for key, value in P0.items()}


LO = {('q', 'q'): (M2g_qq, M2PP_qq), ('q', 'g'): (M2g_qg, M2PP_qg),
      ('g', 'q'): (M2g_gq, M2PP_gq), ('g', 'g'): None,
      ('g', 'qb'): (M2g_gq, M2PP_gq), ('g', 'qp'): (M2g_gq, M2PP_gq),
      ('q', 'qb'): None, ('q', 'qp'): None}
SPLIT = {('q', 'q'): P0qq, ('q', 'g'): P0qg, ('g', 'q'): P0gq,
         ('g', 'g'): P0gg, ('qb', 'q'): None, ('qp', 'q'): None,
         ('q', 'qb'): None, ('q', 'qp'): None, ('qb', 'g'): P0qg,
         ('qp', 'g'): P0qg, ('g', 'qb'): P0gq, ('g', 'qp'): P0gq}
BASE_CHANNELS = {'Hgq': ('g', 'q'), 'Hqg': ('q', 'g'), 'Hgg': ('g', 'g'),
                 'Hqqbar': ('q', 'qb'), 'Hqqp': ('q', 'qp')}

# ---------- invariant-frame kinematics (channel independent) ----------
sP = xit*(s + Q2) - Q2                        # shifted incoming invariant
J_pdf = s23 - t1                              # |dG/dxit| = s + Q2 + u1
xit_star = -t1/(s23 - t1)
c_pdf = 1/(s23 - t1)                           # (1 - xit*)/s23

tF = -Q2 + (t1 + Q2)/zetat                     # shifted observed invariant
zetat_star = (s - s23)/s
c_ff = 1/s                                     # (1 - zetat*)/s23
J_ff = (s - s23)/zetat**2


def k_pdf(M2, proj):
    e = by_name(M2, {'s': sP, 't': t1, 'Q2': Q2, 'eps': eps})
    return e*(1/xit if proj == 'g' else 1/xit**3)   # 1/xit (+1/xit^2 for PP)


def k_ff(M2, proj):
    e = by_name(M2, {'s': s, 't': tF, 'Q2': Q2, 'eps': eps})
    return e/zetat**2


# The gluon channels, PLUS ('q','q') = chn2.  chn2 is not a gluon channel; it is
# included ONLY so this script can be gated against the independently written
# invariant-frame Hqq_CTbt.py (see the EXACTNESS GATE note above).
CHANNELS = dict(BASE_CHANNELS, Hqq=('q', 'q'))


def chans_for(chan, side):
    """The (splitting function, LO kernel) pairs of Eq. (46) for this channel --
    the SAME flavour bookkeeping as Hglu_S12_CT.chans_for, with the
    invariant-frame kernels substituted in."""
    i, j = CHANNELS[chan]
    out = []
    for other in ('q', 'g'):
        if side == 'pdf':
            lo, P0 = LO.get((other, j)), SPLIT.get((other, i))
            kf = k_pdf
        else:
            lo, P0 = LO.get((i, other)), SPLIT.get((j, other))
            kf = k_ff
        if lo is None or P0 is None:
            continue
        # Hqq' PDF subtraction: i''=g and the tagged LO quark is q', so the
        # photon couples with eqp, not the generic eq carried by M2_gq.
        # The FF subtraction remains gamma* q -> g q and therefore keeps eq.
        if chan == 'Hqqp' and side == 'pdf':
            lo = tuple(by_name(m, {'eq': eqp}) for m in lo)
        if side == 'ff':
            P0 = in_z(P0)
        out.append((other, P0,
                    {p: kf(m, p) for p, m in zip(('g', 'PP'), lo)}))
    if chan == 'Hgg':
        # Eq. (46) has two distinct lower-order intermediate species here:
        # i''/j'' = q and qbar.  Charge conjugation makes their kernels equal,
        # but keeping both entries explicit prevents an adjustable, opaque
        # channel multiplier from entering the pole check.
        out += [('qbar', P0, kernels) for species, P0, kernels in out
                if species == 'q']
    return out


def assemble(chan, side):
    """-> {proj: {'Cdelta':, 'Cplus':, 'Creg':}}; multiply by PREF at the end.
    IDENTICAL endpoint logic to the validated Hglu_S12_CT.assemble."""
    if side == 'pdf':
        v, star, J, c = xit, xit_star, J_pdf, c_pdf
    else:
        v, star, J, c = zetat, zetat_star, J_ff.subs(zetat, zetat_star), c_ff
    out = {}
    for proj in ('g', 'PP'):
        Cdelta = Cplus = Creg = sp.Integer(0)
        for _species, P0, kk in chans_for(chan, side):
            k = kk[proj]
            kstar = k.subs(v, star)
            k1v = k.subs(v, 1).subs(s23, 0)          # delta(s23) locus
            if P0['reg'] != 0:
                Creg += 2*sp.pi*P0['reg'].subs(v, star)*kstar/J
            if P0['delta'] != 0:
                Cdelta += 2*sp.pi*P0['delta']*k1v
            if P0['plus'] != 0:
                w = P0['plus'].subs(v, star) if P0['plus'].has(v) else P0['plus']
                n = 2*sp.pi*w*kstar/(c*J)
                Cplus += n
                n0 = sp.simplify(n.subs(s23, 0))
                c0 = sp.simplify(c.subs(s23, 0))
                Cdelta += n0*sp.log(B*c0)
        out[proj] = {'Cdelta': Cdelta, 'Cplus': Cplus, 'Creg': Creg}
    return out


TO_MAP = {s: s_of, t1: t1_of, B: B_up}
WHITELIST = {'s', 't1', 'Q2', 's23', 'B', 'eps', 'CF', 'ee', 'eq', 'eqp', 'gs', 'Nc',
             'nf', 'xit', 'zetat'}


def main():
    started = time.monotonic()
    res, bad, floats, nonfinite = {}, set(), set(), set()
    channels = ('Hgq', 'Hqg', 'Hgg', 'Hqqbar', 'Hqqp', 'Hqq')
    total = len(channels)*2*2*3
    checked = 0
    for chan in channels:
        for side in ('pdf', 'ff'):
            res[(chan, side)] = assemble(chan, side)
            for proj in ('g', 'PP'):
                d = res[(chan, side)][proj]
                for key in ('Cdelta', 'Cplus', 'Creg'):
                    expr = d[key]
                    bad |= {sy.name for sy in expr.free_symbols} - WHITELIST
                    if expr.atoms(sp.Float):
                        floats.add((chan, side, proj, key))
                    if (expr.has(sp.zoo) or expr.has(sp.nan)
                            or expr.has(sp.oo) or expr.has(-sp.oo)):
                        nonfinite.add((chan, side, proj, key))
                    checked += 1
                print('%s %s %s: ops Cdelta=%d Cplus=%d Creg=%d'
                      % (chan, side, proj, sp.count_ops(d['Cdelta']),
                         sp.count_ops(d['Cplus']), sp.count_ops(d['Creg'])),
                      flush=True)
                print('PROGRESS %d/%d elapsed=%.1fs'
                      % (checked, total, time.monotonic() - started), flush=True)
    print('frame gate: stray symbols %s (must be empty)' % sorted(bad),
          flush=True)
    assert not bad, 'stray symbols %s' % sorted(bad)
    print('exactness gate: Float pieces %s; nonfinite pieces %s'
          % (sorted(floats), sorted(nonfinite)), flush=True)
    assert not floats, 'Float atoms in %s' % sorted(floats)
    assert not nonfinite, 'non-finite atoms in %s' % sorted(nonfinite)

    # ---- PRIMARY GATE: chn2 against the independent invariant-frame build ----
    ref = pickle.load(open(os.path.join(CACHE, 'Hqq_CTbt.pkl'), 'rb'))['CT']
    nchk = nfail = 0
    for side in ('pdf', 'ff'):
        for proj in ('g', 'PP'):
            for key in ('Cdelta', 'Cplus', 'Creg'):
                nchk += 1
                diff = sp.simplify(res[('Hqq', side)][proj][key]
                                   - ref[side][proj][key])
                if diff != 0:
                    nfail += 1
                    print('  GATE MISMATCH %s %s %s: %s'
                          % (side, proj, key, str(diff)[:220]), flush=True)
    print('PRIMARY GATE (vs Hqq_CTbt.pkl, invariant frame): %d/%d exact'
          % (nchk - nfail, nchk), flush=True)

    assert nfail == 0, '%d chn2 pieces disagree with Hqq_CTbt.pkl' % nfail
    res['PREF'] = PREF
    res['note'] = ('invariant frame (s,t1,Q2,s23,B); hard-part level, multiply '
                   'by jac (jac(0) for Cdelta) in C2; total CT = '
                   'PREF*(Cdelta delta(s23) + [Cplus]_+ + Creg)')
    res['gate'] = {'frame_symbols': (), 'float_pieces': (),
                   'nonfinite_pieces': (), 'hqq_reference_checks': nchk,
                   'hqq_reference_failures': nfail}
    # Bind the accepted counterterm to every independent input used by its
    # 12/12 exact gate.  R5 also hashes the resulting pickle, so a changed LO,
    # splitting function, reference CT, or producer automatically creates a
    # new checkpoint namespace rather than silently resuming stale batches.
    provenance = [__file__, os.path.join(CACHE, 'P0gg.pkl'),
                  os.path.join(CACHE, 'Hqq_CTbt.pkl'),
                  os.path.join(HERE, 'generated', 'Hqq_L2_M2.py'),
                  os.path.join(HERE, 'generated', 'Hqq_S12_LO_M2.py')]
    res['version'] = VERSION
    res['provenance'] = {os.path.basename(path): file_sha256(path)
                         for path in provenance}
    out = os.path.join(CACHE, 'Hglu_CTbt.pkl')
    tmp = '%s.tmp.%d' % (out, os.getpid())
    with open(tmp, 'wb') as stream:
        pickle.dump(res, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(tmp, out)
    print('HGLU_CTBT_DONE elapsed=%.1fs output=%s'
          % (time.monotonic() - started, out), flush=True)

    # ---- SECONDARY, INFORMATIONAL, OPT-IN (CTBT_MAPBACK=1) ----
    # Creg and Cplus are expected to agree; Cdelta is expected NOT to, because
    # the measured-frame build lets .subs(s23, 0) also move s_of and t1_of.
    # It is 60 sp.simplify calls on measured-frame expressions and can outlast
    # the job wall -- so it runs AFTER the pickle is written, and only on request.
    if os.environ.get('CTBT_MAPBACK') != '1':
        print('mapback comparison skipped (set CTBT_MAPBACK=1 to run it)',
              flush=True)
        return
    old = pickle.load(open(os.path.join(CACHE, 'Hglu_S12_CT.pkl'), 'rb'))
    agree = {}
    for chan in ('Hgq', 'Hqg', 'Hgg', 'Hqqbar', 'Hqqp'):
        for side in ('pdf', 'ff'):
            for proj in ('g', 'PP'):
                for key in ('Cdelta', 'Cplus', 'Creg'):
                    d = sp.simplify(res[(chan, side)][proj][key].xreplace(TO_MAP)
                                    - old[(chan, side)][proj][key])
                    agree.setdefault(key, [0, 0])[0 if d == 0 else 1] += 1
    for key in ('Creg', 'Cplus', 'Cdelta'):
        a, b = agree.get(key, (0, 0))
        print('  measured-frame mapback %s: %d agree, %d differ' % (key, a, b),
              flush=True)


if __name__ == '__main__':
    main()
