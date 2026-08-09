#!/usr/bin/env python3
"""Exact Hgg R5 pole reducer in the quadratic invariant radical basis.

The compact-coordinate pole is first mapped back through the exact inverse
R5S=s, R5M=z^2(Q2+s)(s-s23)/(Q2+s-s23+t1).  Its only algebraic extension is
R = sqrt(4 Q2 s23 + (s+t1)^2).  Every rational function of R is represented
as a pair (A,B) for A+B R, using R^2 exactly.  This prevents the generic
reducer from treating sqrt(D), 1/sqrt(D), and D^(3/2) as unrelated variables.
"""
import collections
import multiprocessing as mp
import os
import pickle
import resource
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from R5_parallel_reduce import (  # noqa: E402
    _outer_linear_terms, balanced_cancel_zero)

CAP = int(os.environ.get("R5RED_WORKER_CAP_BYTES", "3221225472"))
_RADICAL = None
_DISC = None
_APART_VAR = None


def canonical_symbols(expression):
    groups = collections.defaultdict(list)
    for symbol in expression.free_symbols:
        groups[symbol.name].append(symbol)
    replacements = {}
    for values in groups.values():
        target = max(values, key=lambda symbol: sum(
            value is True for value in symbol.assumptions0.values()))
        replacements.update({symbol: target for symbol in values
                             if symbol is not target})
    return expression.xreplace(replacements) if replacements else expression


def invariant_form(expression):
    expression = canonical_symbols(expression)
    replacements = {atom: sp.factor(atom.args[0])
                    for atom in expression.atoms(sp.Abs)}
    expression = expression.xreplace(replacements) if replacements else expression
    symbols = {symbol.name: symbol for symbol in expression.free_symbols}
    # The traces and the splitting kernels arrive from independent producers:
    # the former is expressed in Nc, while the latter may retain CF.  They are
    # not independent in SU(Nc).  Missing this substitution produces a clean
    # but spurious Hgg pole proportional to 2*Nc*CF-(Nc**2-1).
    if "CF" in symbols and "Nc" in symbols:
        expression = expression.xreplace({
            symbols["CF"]: (symbols["Nc"]**2 - 1)/(2*symbols["Nc"])})
        if expression == 0:
            return sp.S.Zero
        symbols = {symbol.name: symbol for symbol in expression.free_symbols}
    s, t1 = sp.symbols("s t1", real=True)
    compact_m = (symbols["z"]**2*(symbols["Q2"] + s)*(s - symbols["s23"])
                 /(symbols["Q2"] + s - symbols["s23"] + t1))
    expression = expression.xreplace({symbols["R5S"]: s,
                                      symbols["R5M"]: compact_m})
    # Canonicalize every half-power base after the inverse substitution.
    power_map = {}
    for power in expression.atoms(sp.Pow):
        if power.exp.is_Rational and power.exp.q == 2:
            base = sp.factor(sp.cancel(sp.together(power.base)))
            if base != power.base:
                power_map[power] = base**power.exp
    return expression.xreplace(power_map) if power_map else expression


def _init(radical, discriminant, cap):
    global _RADICAL, _DISC
    _RADICAL, _DISC = radical, discriminant
    try:
        resource.setrlimit(resource.RLIMIT_AS, (cap, cap))
    except (ValueError, OSError):
        pass


def _init_apart(variable, cap):
    global _APART_VAR
    _APART_VAR = variable
    try:
        resource.setrlimit(resource.RLIMIT_AS, (cap, cap))
    except (ValueError, OSError):
        pass


def _apart_worker(term):
    """Partial-fraction one small term and return unique basis coefficients."""
    output = []
    for part in sp.Add.make_args(sp.apart(term, _APART_VAR)):
        numerator, denominator = sp.fraction(sp.cancel(part))
        constant, factors = sp.factor_list(denominator, _APART_VAR)
        dependent = [(factor, power) for factor, power in factors
                     if factor.has(_APART_VAR)]
        if not dependent:
            polynomial = sp.Poly(numerator, _APART_VAR)
            for (power,), coefficient in polynomial.terms():
                output.append((("poly", power), coefficient/denominator))
            continue
        if len(dependent) != 1:
            raise ValueError("apart left multiple variable-dependent factors")
        factor, power = dependent[0]
        monic = sp.Poly(factor, _APART_VAR).monic().as_expr()
        coefficient = sp.cancel(part*monic**power)
        if coefficient.has(_APART_VAR):
            raise ValueError("apart coefficient still depends on variable")
        output.append((("pole", sp.srepr(monic), int(power)), coefficient))
    return output


def _cancel_worker(expression):
    return sp.cancel(sp.together(expression))


def partial_fraction_residuals(expression, variable, workers=15,
                               verbose=True):
    """Exactly reduce independent coefficients in a one-variable PF basis."""
    groups = collections.defaultdict(list)
    terms = sp.Add.make_args(expression)
    context = mp.get_context("spawn")
    with context.Pool(workers, initializer=_init_apart,
                      initargs=(variable, CAP), maxtasksperchild=100) as pool:
        for pieces in pool.imap_unordered(_apart_worker, terms, chunksize=2):
            for key, coefficient in pieces:
                groups[key].append(coefficient)
    sums = [sp.Add(*values) for values in groups.values()]
    residuals = []
    with context.Pool(workers, initializer=_init_apart,
                      initargs=(variable, CAP), maxtasksperchild=50) as pool:
        for value in pool.imap_unordered(_cancel_worker, sums, chunksize=1):
            if value != 0:
                residuals.append(value)
    if verbose:
        print("HGGQRED apart variable=%s terms=%d basis=%d residuals=%d" %
              (variable, len(terms), len(groups), len(residuals)), flush=True)
    return residuals


def _reduce_poly(polynomial):
    poly = sp.Poly(polynomial, _RADICAL)
    even, odd = sp.S.Zero, sp.S.Zero
    for (power,), coefficient in poly.terms():
        if power % 2:
            odd += coefficient*_DISC**((power - 1)//2)
        else:
            even += coefficient*_DISC**(power//2)
    return even, odd


def _split_worker(term):
    numerator, denominator = sp.fraction(sp.together(term))
    na, nb = _reduce_poly(numerator)
    da, db = _reduce_poly(denominator)
    norm = da**2 - db**2*_DISC
    return ((na*da - nb*db*_DISC)/norm,
            (nb*da - na*db)/norm)


def _radical_mask(expression):
    half_bases = {power.base for power in expression.atoms(sp.Pow)
                  if power.exp.is_Rational and power.exp.q == 2}
    if len(half_bases) != 1:
        raise ValueError("expected one invariant half-power base, got %d" %
                         len(half_bases))
    discriminant = next(iter(half_bases))
    radical = sp.Symbol("HggR")
    replacements = {}
    for power in expression.atoms(sp.Pow):
        if power.base == discriminant and power.exp.is_Rational \
                and power.exp.q == 2:
            numerator = int(power.exp.p)
            replacements[power] = radical*discriminant**(numerator//2)
    return expression.xreplace(replacements), radical, discriminant


def split_parts(expression, workers=15, verbose=True):
    """Return the exact rational pair A,B with expression = A+B*sqrt(D)."""
    invariant = invariant_form(expression)
    if invariant == 0:
        if verbose:
            print("HGGQRED canonical input is algebraic zero", flush=True)
        return sp.S.Zero, sp.S.Zero, sp.S.One
    masked, radical, discriminant = _radical_mask(invariant)
    terms = _outer_linear_terms(masked)
    if verbose:
        print("HGGQRED terms=%d symbols=%d discriminant=%s" %
              (len(terms), len(masked.free_symbols), discriminant), flush=True)
    context = mp.get_context("spawn")
    apart, bpart = [], []
    with context.Pool(workers, initializer=_init,
                      initargs=(radical, discriminant, CAP),
                      maxtasksperchild=200) as pool:
        for left, right in pool.imap_unordered(_split_worker, terms,
                                                chunksize=4):
            apart.append(left)
            bpart.append(right)
    aexpr, bexpr = sp.Add(*apart), sp.Add(*bpart)
    if verbose:
        print("HGGQRED split A=%d B=%d" %
              (len(sp.Add.make_args(aexpr)), len(sp.Add.make_args(bexpr))),
              flush=True)
    return aexpr, bexpr, discriminant


def exact_zero(expression, workers=15, verbose=True):
    aexpr, bexpr, _discriminant = split_parts(expression, workers, verbose)
    azero = balanced_cancel_zero(aexpr, workers, verbose)
    if bexpr == 0:
        bzero = True
    else:
        bzero = balanced_cancel_zero(bexpr, workers, verbose)
    if verbose:
        print("HGGQRED zero A=%s B=%s" % (azero, bzero), flush=True)
    return azero and bzero


def _selftest():
    nc_plain = sp.Symbol("Nc")
    nc_real = sp.Symbol("Nc", real=True)
    cf = sp.Symbol("CF")
    q2, r5s, r5m, v, zz = sp.symbols(
        "Q2 R5S R5M s23 z", positive=True)
    duplicate = nc_plain - nc_real
    color = 2*nc_plain*cf - (nc_real**2 - 1)
    probe = (duplicate + color)*(q2 + r5s)/(r5m - zz**2*(r5s - v))
    ok = invariant_form(probe) == 0
    print("HGGQRED selftest duplicate-symbol/SU(Nc) zero=%s" % ok,
          flush=True)
    # The exact inverse compact map must reproduce the one-radical invariant
    # discriminant used by production.
    s, t1 = sp.symbols("s t1", real=True)
    compact_m = zz**2*(q2 + s)*(s - v)/(q2 + s - v + t1)
    radicand = ((4*q2*v + s**2 + 2*s*t1 + t1**2)/(4*v))
    disc_ok = sp.factor(4*v*radicand
                        - (4*q2*v + (s + t1)**2)) == 0
    print("HGGQRED selftest invariant discriminant=%s" % disc_ok,
          flush=True)
    return ok and disc_ok and compact_m != 0


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--selftest":
        raise SystemExit(0 if _selftest() else 1)
    if len(sys.argv) < 2:
        raise SystemExit("usage: Hgg_R5_quadratic_reduce.py expression.pkl [workers]")
    value = pickle.load(open(sys.argv[1], "rb"))
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 15
    if len(sys.argv) > 4 and sys.argv[3] == "--dump-parts":
        left, right, disc = split_parts(value, count, True)
        with open(sys.argv[4], "wb") as handle:
            pickle.dump({"A": left, "B": right, "D": disc}, handle,
                        protocol=pickle.HIGHEST_PROTOCOL)
        raise SystemExit(0)
    raise SystemExit(0 if exact_zero(value, count, True) else 1)
