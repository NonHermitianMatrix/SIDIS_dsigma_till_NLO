#!/usr/bin/env python3
"""Corrected, source-bound Hqq V2 virtual renormalization.

WS11 (verbatim): one loop on `gamma* q -> q g`; contains `1/eps^2`,
`1/eps`.

Working equation (projected independently for Gamma in {g,PP}):

  virtGamma = Re[2 (-I/Nc) ee^2 eq^2 gs^4 M1Gamma]
  UVCTGamma = -(beta0/eps) Seps gs^2/(16 Pi^2) (2 M2Gamma_LO)
  virtGamma_ren = virtGamma + UVCTGamma,   (no Feps: see build())
  beta0 = (11 Nc - 2 nf)/3,  ScaleMu -> 1.

The accepted V1 input is already Package-X reduced.  This Python-only V2
stage performs the physical analytic continuation, takes the real
interference, unifies EpsilonUV/EpsilonIR only afterwards, adds the symbolic
MS-bar coupling counterterm, and writes an atomic, provenance-bound artifact.
No R5 artifact is read or modified.
"""
import hashlib
import os
import pickle
import re
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache")
GENERATED = os.path.join(HERE, "generated")
V1 = os.path.join(GENERATED, "Hqq2_V1_raw.py")
LO_SOURCE = os.path.join(GENERATED, "Hqq_L2_M2.py")
ACCEPTED_V1_SHA256 = (
    "77c2685ebc19cd20fdd44a485dd805cfd2e9b7a6a523198776a9da7dc61ce073")
# v2 = the virtual is left in the common MS-bar normalization
# (4 Pi)^eps e^{-gamma eps} that the real and the counterterms carry.
VERSION = "hqq2-v2-renorm-exact-v2-common-scheme"

s = sp.Symbol("s", positive=True)
t = sp.Symbol("t", real=True)
Q2 = sp.Symbol("Q2", positive=True)
eps = sp.Symbol("eps", real=True)
Nc = sp.Symbol("Nc", positive=True)
nf = sp.Symbol("nf", real=True)
ee, eq, gs = sp.symbols("ee eq gs", real=True)
ScaleMu = sp.Symbol("ScaleMu", positive=True)
EpsUV, EpsIR = sp.symbols("EpsilonUV EpsilonIR", real=True)

beta0 = (11*Nc - 2*nf)/3
Seps = (4*sp.pi)**eps/sp.gamma(1 - eps)
Feps = (sp.exp(sp.EulerGamma)/(4*sp.pi))**eps
COUP = ee**2*eq**2*gs**4


class PaXDiLog(sp.Function):
    nargs = 2


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def atomic_pickle(value, path):
    temporary = "%s.tmp.%d" % (path, os.getpid())
    with open(temporary, "wb") as stream:
        pickle.dump(value, stream, protocol=pickle.HIGHEST_PROTOCOL)
        stream.flush()
        os.fsync(stream.fileno())
    os.replace(temporary, path)


def load_raw(projection):
    if sha256(V1) != ACCEPTED_V1_SHA256:
        raise ValueError("Hqq2 V1 source hash is not the accepted hash")
    variable = "virtGraw" if projection == "g" else "virtPPraw"
    with open(V1) as stream:
        text = stream.read()
    match = re.search(variable + r"\s*=\s*sympify\('(.*)'\)", text)
    if match is None:
        raise KeyError("%s absent from Hqq2 V1" % variable)
    source = match.group(1).replace("SUNT[SUNIndex[a]]", "1")
    source = source.replace("[", "(").replace("]", ")")
    locals_ = {
        "Log": sp.log, "PolyLog": lambda n, x: sp.polylog(n, x),
        "Pi": sp.pi, "EulerGamma": sp.EulerGamma, "Sqrt": sp.sqrt,
        "I": sp.I, "PaXDiLog": PaXDiLog,
    }
    return canonical(sp.sympify(source, locals=locals_))


def canonical(expression):
    targets = {symbol.name: symbol for symbol in (
        s, t, Q2, eps, Nc, nf, ee, eq, gs, ScaleMu, EpsUV, EpsIR)}
    replacements = {}
    for symbol in expression.free_symbols:
        name = "Nc" if symbol.name == "SUNN" else symbol.name
        if name in targets and symbol is not targets[name]:
            replacements[symbol] = targets[name]
    return expression.xreplace(replacements) if replacements else expression


def sign_in_region(expression):
    """Prove a sign using s,Q2>0, t<0 and Q2+s+t>0."""
    tp = sp.Symbol("HqqT", positive=True)
    t_value = sp.factor(sp.cancel(sp.together(expression)).subs(t, -tp))
    if t_value.is_positive:
        return 1
    if t_value.is_negative:
        return -1
    up = sp.Symbol("HqqU", positive=True)
    value = sp.factor(sp.cancel(sp.together(expression)).subs(
        t, -s - Q2 + up))
    if value.is_positive:
        return 1
    if value.is_negative:
        return -1
    numerator, denominator = sp.fraction(value)
    sn, sd = sp.ask(sp.Q.positive(numerator)), sp.ask(sp.Q.positive(denominator))
    if sn is not None and sd is not None:
        return 1 if sn == sd else -1
    nn, nd = sp.ask(sp.Q.negative(numerator)), sp.ask(sp.Q.negative(denominator))
    if nn is not None and sd is not None:
        return -1 if nn == sd else 1
    if sn is not None and nd is not None:
        return -1 if sn == nd else 1
    return None


def continue_dilogs(expression):
    replacements = {}
    for dilog in expression.atoms(PaXDiLog):
        argument = sp.cancel(dilog.args[0])
        if sp.cancel(argument - (Q2 + s)/s) == 0:
            x = (Q2 + s)/s
            replacements[dilog] = (sp.pi**2/3 - sp.polylog(2, 1/x)
                                   - sp.log(x)**2/2
                                   - sp.I*sp.pi*sp.log(x))
        else:
            if sign_in_region(argument - 1) == 1:
                raise ValueError("unhandled Hqq dilog above its physical cut")
            replacements[dilog] = sp.polylog(2, argument)
    return expression.xreplace(replacements)


def continue_logs(expression):
    replacements, unknown = {}, []
    for logarithm in expression.atoms(sp.log):
        argument = sp.factor(logarithm.args[0])
        sign = sign_in_region(argument)
        if sign == -1:
            replacements[logarithm] = sp.log(-argument) - sp.I*sp.pi
        elif sign is None:
            unknown.append(argument)
    if unknown:
        raise ValueError("unproved physical log signs: %s" %
                         [sp.sstr(value) for value in unknown])
    return expression.xreplace(replacements)


def real_part(expression):
    expanded = sp.expand(expression)
    real_terms = [term for term in sp.Add.make_args(expanded)
                  if not term.has(sp.I)]
    result = sp.Add(*real_terms)
    if result.has(sp.I):
        raise ValueError("explicit imaginary unit survived real interference")
    return result


def load_lo(projection):
    sys.path.insert(0, HERE)
    from generated.Hqq_L2_M2 import M2g, M2PP
    return canonical(sp.sympify(M2g if projection == "g" else M2PP))


def negative_log_gate(expression):
    points = ((7, 13, -5), (11, 5, -7), (3, 17, -8))
    for sv, qv, tv in points:
        if not (sv > 0 and qv > 0 and tv < 0 and sv + qv + tv > 0):
            raise AssertionError("invalid physical validation point")
        for logarithm in expression.atoms(sp.log):
            value = sp.N(logarithm.args[0].subs({s: sv, Q2: qv, t: tv}), 50)
            if value.is_real is not True or value <= 0:
                raise ValueError("uncontinued/nonpositive log argument at %s: %s"
                                 % ((sv, qv, tv), logarithm.args[0]))


def build(projection):
    started = time.monotonic()
    raw = load_raw(projection)
    lo = load_lo(projection)
    continued = continue_logs(continue_dilogs(raw))
    # ScaleMu=1 is the convention already validated by the 2026-07-31
    # all-channel pole closure.  Unify Package-X regulators only now.
    loop = 2*(-sp.I/Nc)*COUP*continued
    loop = real_part(loop).xreplace({ScaleMu: sp.S.One})
    loop = loop.xreplace({EpsUV: eps, EpsIR: eps})
    uvct = -(beta0/eps)*Seps*(gs**2/(16*sp.pi**2))*lo*2
    # NO Feps HERE (v2 correction).  Package-X with
    # PaXImplicitPrefactor -> 1/(2 Pi)^D returns the loop with EulerGamma and
    # Log[4 Pi] STILL EXPLICIT, i.e. the loop already carries the MS-bar
    # factor (4 Pi)^eps e^{-gamma eps}; UVCT carries it through Seps.  The
    # real prefactor kf = (1/(16 Pi^2))(4 Pi)^eps Gamma(1-eps)/Gamma(1-2eps)
    # and the Eq.(46) counterterm PREF = (gs^2/16 Pi^2) Seps/eps carry the
    # SAME factor.  Multiplying by Feps = (e^gamma/(4 Pi))^eps stripped it
    # from the virtual ALONE.  That is invisible at eps^-2 (no logarithm
    # there) and appears at eps^-1 as [log(4 Pi) - EulerGamma] x (double
    # pole) -- exactly the measured residual
    #     K (Nc^2-1)(2Nc^2-1) [log(4 Pi) - EulerGamma].
    # Removing the multiplication restores the loop's own normalization; it
    # does not choose a convention.
    virtual = loop + uvct
    negative_log_gate(virtual)
    if virtual.has(EpsUV, EpsIR, sp.I, sp.Float, sp.zoo, sp.nan,
                   sp.oo, -sp.oo):
        raise ValueError("V2 exactness/reality/regulator gate failed")
    names = {symbol.name for symbol in virtual.free_symbols}
    if "nf" not in names or not {"eps", "Nc", "ee", "eq", "gs"} <= names:
        raise ValueError("V2 symbolic colour/coupling/flavour gate failed")
    fingerprint = hashlib.sha256()
    for path in (V1, LO_SOURCE, __file__):
        fingerprint.update(os.path.basename(path).encode("utf-8"))
        fingerprint.update(sha256(path).encode("ascii"))
    payload = {
        "version": VERSION,
        "projection": projection,
        "source_v1_sha256": sha256(V1),
        "source_lo_sha256": sha256(LO_SOURCE),
        "provenance_sha256": fingerprint.hexdigest(),
        "working_equation": "virt_ren=Re[2(-I/Nc)COUP*M1]+UVCT",
        "beta0": beta0,
        "ScaleMu_value": 1,
        "negative_log_points_passed": 3,
        "virtual": virtual,
        "elapsed_seconds": time.monotonic() - started,
    }
    suffix = "G" if projection == "g" else "PP"
    output = os.path.join(CACHE, "Hqq2_V2_virt%s_ren_inv_sym.pkl" % suffix)
    atomic_pickle(payload, output)
    print("HQQ2_V2_DONE projection=%s ops=%d elapsed=%.3f output=%s" %
          (projection, sp.count_ops(virtual), time.monotonic() - started,
           output), flush=True)
    return payload


def main():
    projection = sys.argv[1] if len(sys.argv) > 1 else "g"
    if projection not in ("g", "PP"):
        raise SystemExit("projection must be g or PP")
    build(projection)


if __name__ == "__main__":
    main()
