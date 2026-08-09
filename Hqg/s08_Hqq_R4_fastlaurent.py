# Hqq_R4_fastlaurent.py -- Step R4 (WS10 sub-step): fast pure-poly Laurent
# engine for the endpoint residues of jac*to_map(H) at s23 -> 0.
#
# SERIES REPRESENTATION: (v, aw, coeffs) means
#     w^{v + aw*eps} * sum_k coeffs[k] w^k,   w = sqrt(s23),
# with integer v and Rational aw.  The aw*eps exponent class is REQUIRED
# by the QGG piece: its case-1 masters carry (1-w)^{-1-eps} whose base
# VANISHES at the endpoint (the FF-collinear pinch), i.e. genuine
# s23^{-eps}-type factors inside H (aw = -2 <=> one extra s23^{-eps}).
# The E/C/A pieces have aw = 0 everywhere.
#
# WHY hand-rolled series (profiled 2026-07-16):
#  (1) sympy polylog.eval runs equals->simplify on its argument at every
#      rebuild (~19 s per polylog after the map): patched inert below;
#  (2) generic series() on composite Add factors lands in powsimp (1.1e6
#      calls / 55 s on one term);
#  (3) cancel() = multivariate heuristic GCD (~6 s per coefficient):
#      coefficients stay RAW; zero tests are numeric (exact fallback).
# sympy series() is NEVER called; unknown structures raise immediately.
#
# GATES: (1) reproduces the validated A-piece residues exactly (0.0 rel
# dev); (2) endpoint limits v*G(v) on real E/QGG terms; (3) acceptance
# checks at every production merge (Hqq_R4_run2.py).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy as sp


def _polylog_eval_inert(cls, s, z):
    if z is sp.S.Zero:
        return sp.S.Zero
    return None


sp.polylog.eval = classmethod(_polylog_eval_inert)

from Hqq_R4_expand import to_map, _poly_laurent, _w, eps  # noqa: E402
from Hqq_R4_kinmap import jac, s23                        # noqa: E402

_EPS = sp.Symbol('eps')


def _maybe_cancel(c):
    """NO-OP by design: cancel() = multivariate GCD, ~6 s per swollen
    coefficient.  Consumers are numeric or per-factor in eps."""
    return c


_ZERO_CACHE = {}


def _num_zero(c):
    """EXACT zero test (user directive 2026-07-23: symbolic only).

    The former implementation sampled two random FLOATING-POINT points and
    declared `nonzero` on |value| > 1e-10.  That is a probabilistic
    decision on the valuation of a series head, so it is not admissible.
    Here the coefficient is unmasked (the Dummy mask hides cancellations
    between distinct w-free subtrees) and reduced with the exact rational
    normal form `cancel(together(.))`; the verdict `zero` is then an exact
    algebraic identity, and `nonzero` is exact for rational functions of
    the kinematic symbols (transcendental atoms are treated as
    independent generators, which is conservative in the safe direction:
    a head is never wrongly stripped)."""
    if c == 0:
        return True
    if c in _ZERO_CACHE:
        return _ZERO_CACHE[c]
    cu = unmask(c)
    r = sp.cancel(sp.together(cu))
    val = (r == 0)
    _ZERO_CACHE[c] = val
    return val


def _guard_c0(c, who):
    c0 = c[0]
    if c0 == 0 or (not c0.is_number and _num_zero(c0)):
        raise ValueError("%s: leading series coefficient is 0 "
                         "(valuation shift)" % who)
    return c0


def _series_stripped(b, nord, who):
    """(v, aw, coeffs[:nord]) of b with a VERIFIED nonzero head: when
    leading coefficients cancel only mathematically (unsimplified Adds),
    re-expand b at higher order until nord valid coefficients remain
    after stripping the zero head."""
    extra = 0
    while extra <= 32:
        bv, baw, bc = _expr_laurent(b, nord + extra)
        c = list(bc)
        s = 0
        while c:
            # Coefficients may be masked Dummies at this point.  Testing the
            # Dummy itself accepts a mathematically zero head as nonzero, and
            # QGG then emits literal 0^(-1-eps) endpoint residues.
            head = unmask(c[0]) if 'unmask' in globals() else c[0]
            if not (head == 0 or (not head.is_number and _num_zero(head))):
                break
            c.pop(0)
            s += 1
        if len(c) >= nord:
            return bv + s, baw, c[:nord]
        extra = max(2, 2*s, 2*extra)
    raise ValueError("%s: series identically zero (or head cancellation "
                     "deeper than 32 orders)" % who)


# ---- series primitives on coefficient lists ----
def _ser_mul(a, b, nord):
    out = [sp.Integer(0)]*nord
    for i in range(nord):
        if a[i] == 0:
            continue
        for j in range(nord - i):
            if b[j] != 0:
                out[i + j] += a[i]*b[j]
    return out


def _ser_inv(c, nord):
    inv = [sp.Integer(0)]*nord
    inv[0] = 1/_guard_c0(c, '_ser_inv')
    for k in range(1, nord):
        acc = sp.Integer(0)
        for j in range(1, k + 1):
            if c[j] != 0 and inv[k - j] != 0:
                acc += c[j]*inv[k - j]
        inv[k] = -acc*inv[0]
    return inv


def _ser_pow_binom(c, Q, nord):
    """(c0 + c1 w + ...)^Q = c0^Q (1+u)^Q with u = c/c0 - 1, for ANY
    exponent Q (Rational or Rational-linear in eps): the binomial
    coefficients binom(Q, m) are polynomials in eps -- exact."""
    c0 = _guard_c0(c, '_ser_pow_binom')
    u = [sp.Integer(0)] + [x/c0 for x in c[1:]]
    out = [sp.Integer(1)] + [sp.Integer(0)]*(nord - 1)
    upow = [sp.Integer(1)] + [sp.Integer(0)]*(nord - 1)
    binom = sp.Integer(1)
    for m in range(1, nord):
        upow = _ser_mul(upow, u, nord)
        binom = binom*(Q - (m - 1))/m
        if all(x == 0 for x in upow):
            break
        for i in range(nord):
            if upow[i] != 0:
                out[i] += binom*upow[i]
    pref = c0**Q
    return [pref*x for x in out]


def _ser_log_list(c, nord, who='_ser_log'):
    """log(c0 + c1 w + ...) = log(c0) + log(1+u); head must be nonzero."""
    c0 = _guard_c0(c, who)
    u = [sp.Integer(0)] + [x/c0 for x in c[1:]]
    out = [sp.log(c0)] + [sp.Integer(0)]*(nord - 1)
    upow = [sp.Integer(1)] + [sp.Integer(0)]*(nord - 1)
    for m in range(1, nord):
        upow = _ser_mul(upow, u, nord)
        if all(x == 0 for x in upow):
            break
        sgn = sp.Integer(1) if m % 2 == 1 else sp.Integer(-1)
        for i in range(nord):
            if upow[i] != 0:
                out[i] += sgn*upow[i]/m
    return out


LW = sp.Symbol('_LnW')      # inert log(w) = (1/2) ln(s23); must NEVER
#                             survive into a residue (raise if it does)


def _ser_li2_list(a, nord):
    """polylog(2, a0 + a1 w + ...) via d/dw Li2(A) = -log(1-A)/A * A';
    at the branch point A(0) = 1, via the inversion identity
    Li2(A) = pi^2/6 - log(A) log(1-A) - Li2(1-A), with the endpoint
    log(w) kept as the inert symbol LW."""
    a0 = a[0]
    if a0 != 0 and not a0.is_number and _num_zero(a0):
        a0 = sp.Integer(0)
        a = [sp.Integer(0)] + list(a[1:])
    if a0 != 0 and (a0 == 1 or (not (a0 - 1).is_number
                                and _num_zero(a0 - 1))):
        onemA = [sp.Integer(0)] + [-x for x in a[1:]]
        # strip verified zeros of 1-A -> valuation m >= 1
        m = 0
        T = list(onemA)
        while T and (T[0] == 0 or (not T[0].is_number and _num_zero(T[0]))):
            T.pop(0)
            T.append(sp.Integer(0))
            m += 1
            if m > nord:
                # 1-A = 0 beyond our order: Li2(A) = pi^2/6 exactly here
                return [sp.pi**2/6] + [sp.Integer(0)]*(nord - 1)
        # log(1-A) = log(w^m T(w)) = m*LW + log-series of T
        lt = _ser_log_list(T, nord)
        log1mA = [m*LW + lt[0]] + lt[1:]
        logA = _ser_log_list(a, nord)
        # 1-A as a plain series list (head exact 0 -> composition branch)
        onemA_ser = [sp.Integer(0)]*min(m, nord) + T[:nord - min(m, nord)]
        li2small = _ser_li2_list(onemA_ser, nord)
        cross = _ser_mul(logA, log1mA, nord)
        out = [sp.pi**2/6 - cross[0] - li2small[0]]
        out += [-cross[k] - li2small[k] for k in range(1, nord)]
        return out
    if a0 == 0:
        out = [sp.Integer(0)]*nord
        apow = [sp.Integer(1)] + [sp.Integer(0)]*(nord - 1)
        for k in range(1, nord):
            apow = _ser_mul(apow, a, nord)
            for i in range(nord):
                if apow[i] != 0:
                    out[i] += apow[i]/k**2
        return out
    onemA = [1 - a0] + [-x for x in a[1:]]
    lg = _ser_log_list(onemA, nord, who='_ser_li2:log(1-A)')
    ainv = _ser_inv(a, nord)
    da = [(k + 1)*a[k + 1] if k + 1 < len(a) else sp.Integer(0)
          for k in range(nord)]
    dg = _ser_mul(_ser_mul([-x for x in lg], ainv, nord), da, nord)
    return [sp.polylog(2, a0)] + [dg[k - 1]/k for k in range(1, nord)]


# ---- expression -> (v, aw, coeffs) ----
_FLAU_CACHE = {}

# Canonical invariants, with the SAME assumptions the cached R3 angular
# pieces carry (real, not positive: t1 and u1 are negative).
INV = sp.symbols('s t1 u1 Q2 s23', real=True)


def abs_free(term):
    """EXACT removal of every Abs() from a RAW angular term, i.e. before
    any frame substitution (user directive 2026-07-23: symbolic only;
    replaces the old floating-point sign sampling `_abs_sign`).

    The audit `Hqq_R4_absaudit.py` shows the R3 angular pieces contain
    exactly ONE Abs argument,
        Q2/2 + s/2 + u1/2 ,
    and momentum conservation for gamma*(q) + p -> k1 + k2 + k3,
        s + t1 + u1 = -Q2 + s23 ,
    turns it into
        (Q2 + s + u1)/2 = (s23 - t1)/2 ,
    which is strictly POSITIVE in the physical region because s23 > 0 and
        t1 = -Q2(1 - zh) - k1T^2/zh < 0   for 0 < zh < 1, Q2 > 0.
    The rewrite Abs(arg) -> (s23 - t1)/2 is therefore an exact identity;
    it is applied only after `cancel` proves arg - (s23-t1)/2 = 0 under
    the momentum-conservation relation, and any other Abs argument is a
    hard error (never a sampled sign)."""
    if not term.has(sp.Abs):
        return term
    S, T1, U1, QQ, S23 = INV
    ar = {U1: -QQ - S - T1 + S23}          # s + t1 + u1 = -Q2 + s23
    target = (S23 - T1)/2
    rep = {}
    for a in term.atoms(sp.Abs):
        arg = a.args[0]
        if sp.cancel(sp.together(arg.xreplace(ar) - target)) != 0:
            raise ValueError("abs_free: unproved Abs argument %s" % arg)
        rep[a] = target
    return term.xreplace(rep)


def _expr_laurent(g, nord):
    key = (g, nord)
    if key in _FLAU_CACHE:
        return _FLAU_CACHE[key]
    res = _expr_laurent_raw(g, nord)
    _FLAU_CACHE[key] = res
    return res


# GLOBAL coefficient mask (2026-07-17, the R4 stall root cause):
# sp.Poly(expr, w) force-expands ALL coefficients (measured: one front
# QGG term = 600+ s, GBs).  Every maximal w-free non-atomic
# subexpression is replaced by an inert Dummy, SHARED across factors
# and terms, and the WHOLE series pipeline (Poly, _ser_*, the LW
# bookkeeping) runs on tiny dummy-polynomials; residues/sinks are
# unmasked once, at the very end of residue_fast.
_MASK_FWD = {}
_MASK_BACK = {}


def _mask_scalar(e):
    if e.is_Atom:
        return e
    d = _MASK_FWD.get(e)
    if d is None:
        d = sp.Dummy('C%d' % len(_MASK_FWD))
        _MASK_FWD[e] = d
        _MASK_BACK[d] = e
    return d


def _mask_wfree(g):
    def rec(e):
        if not e.has(_w):
            return _mask_scalar(e)
        if e.is_Atom:
            return e
        return e.func(*[rec(a) for a in e.args])
    return rec(g)


def unmask(e):
    return e.xreplace(_MASK_BACK) if e.free_symbols & set(_MASK_BACK) \
        else e


def _poly_laurent_m(num, den, nord, var):
    """_poly_laurent minus the per-coefficient sp.cancel (cancel
    expands the masked coefficients; raw dummy expressions are fine —
    they are unmasked only at the very end)."""
    pn = sp.Poly(num, var)
    pd = sp.Poly(den, var)
    cn = pn.all_coeffs()[::-1]
    cd = pd.all_coeffs()[::-1]
    # EXACT pivot search.  A masked coefficient can be STRUCTURALLY nonzero
    # (a Dummy or a sum of Dummies) yet identically zero, because the mask
    # hides cancellations between distinct w-free subtrees.  Taking such a
    # coefficient as the pivot gives the wrong valuation, and on the
    # DENOMINATOR side it puts 1/(that coefficient) into every output
    # coefficient, which unmasks to zoo (measured: MR2PPHQG term 12174).
    # Skipping the identically-zero heads here is exact and fixes both.
    vn = next(i for i, c in enumerate(cn) if c != 0 and not _num_zero(c))
    vd = next(i for i, c in enumerate(cd) if c != 0 and not _num_zero(c))
    an = cn[vn:vn + nord] + [sp.Integer(0)]*nord
    ad = cd[vd:vd + nord] + [sp.Integer(0)]*nord
    inv = [sp.Integer(0)]*nord
    inv[0] = 1/ad[0]
    for k in range(1, nord):
        acc = sp.Integer(0)
        for jx in range(1, k + 1):
            if ad[jx] != 0 and inv[k - jx] != 0:
                acc += ad[jx]*inv[k - jx]
        inv[k] = -acc/ad[0]
    out = [sp.Integer(0)]*nord
    for i in range(nord):
        if an[i] == 0:
            continue
        for jx in range(nord - i):
            if inv[jx] != 0:
                out[i + jx] += an[i]*inv[jx]
    return vn - vd, out


def _expr_laurent_raw(g, nord):
    Z = sp.Rational(0)
    if not g.has(_w):
        return 0, Z, [_mask_scalar(g)] + [sp.Integer(0)]*(nord - 1)
    if g is _w:
        return 1, Z, [sp.Integer(1)] + [sp.Integer(0)]*(nord - 1)
    if g.is_rational_function(_w):
        gm = _mask_wfree(g)
        num, den = sp.fraction(sp.together(gm))
        v, c = _poly_laurent_m(num, den, nord, _w)
        # zero-guard: masking hides cancellations BETWEEN distinct
        # w-free subtrees; if the pivot coefficient is numerically 0
        # the valuation v is wrong -> redo this factor unmasked
        c0 = next((ci for ci in c if ci != 0), None)
        if c0 is not None and _num_zero(c0):
            # EXACT pivot guard: masking hides cancellations BETWEEN
            # distinct w-free subtrees, so a syntactically nonzero pivot
            # coefficient can vanish identically and the valuation v be
            # wrong -> redo this factor unmasked.
            num, den = sp.fraction(sp.together(g))
            v, c = _poly_laurent(num, den, nord, _w)
        return v, Z, c
    if isinstance(g, sp.Abs):
        raise ValueError("Abs survived abs_free (exact rewrite): %s"
                         % str(g)[:160])
    if isinstance(g, sp.Add):
        parts = [_expr_laurent(a, nord) for a in g.args]
        aws = {p[1] for p in parts}
        if len(aws) != 1:
            raise ValueError("Add mixes eps-exponent classes %s" % aws)
        v = min(p[0] for p in parts)
        out = [sp.Integer(0)]*nord
        for pv, _, pc in parts:
            sh = pv - v
            for k in range(nord - sh):
                if pc[k] != 0:
                    out[k + sh] += pc[k]
        return v, aws.pop(), out
    if isinstance(g, sp.Mul):
        v = 0
        aw = Z
        cur = None
        for f in g.args:
            fv, faw, fc = _expr_laurent(f, nord)
            v += fv
            aw += faw
            cur = fc if cur is None else _ser_mul(cur, fc, nord)
        return v, aw, cur
    if isinstance(g, sp.Pow):
        b, q = g.as_base_exp()
        if b is _w and q.is_Integer:
            return int(q), Z, [sp.Integer(1)] + [sp.Integer(0)]*(nord - 1)
        if q.is_Rational:
            bv, baw, bc = _series_stripped(b, nord, 'Pow-base')
            qv = q*bv
            if not qv.is_Integer:
                raise ValueError("non-integer valuation %s in %s^%s"
                                 % (qv, b, q))
            if not (q*baw).is_Rational:
                raise ValueError("bad aw in power")
            return int(qv), q*baw, _ser_pow_binom(bc, q, nord)
        epss = [sy for sy in q.free_symbols if sy.name == 'eps']
        qp = sp.Poly(q, epss[0]) if len(epss) == 1 else None
        if qp is not None and qp.degree() <= 1:
            cfs = qp.all_coeffs()
            q1, q0 = (cfs[0], cfs[1]) if len(cfs) == 2 \
                else (sp.Integer(0), cfs[0])
            if q0.is_Rational and q1.is_Rational:
                bv, baw, bc = _series_stripped(b, nord, 'Pow-eps-base')
                if baw != 0:
                    raise ValueError("eps-power of an eps-power base")
                qv = q0*bv
                if not qv.is_Integer:
                    raise ValueError("non-integer valuation %s" % qv)
                # (w^bv c)^ {q0+q1 eps} = w^{q0 bv} w^{q1 bv eps}
                #                          * c^{q0+q1 eps}
                cs = _ser_pow_binom(bc, q0 + q1*_EPS, nord)
                return int(qv), q1*bv, cs
        raise ValueError("unsupported exponent %s in Pow" % q)
    if isinstance(g, sp.log):
        av, aaw, ac = _series_stripped(g.args[0], nord, 'log-arg')
        if aaw != 0:
            raise ValueError("log of eps-power argument")
        if av == 0:
            return 0, Z, _ser_log_list(ac, nord)
        # log(w^av * c) = av*log(w) + log(c): log(w) = (1/2) log(s23)
        # endpoint log -- NOT expected in the hard factors
        raise ValueError("log with vanishing argument (valuation %d)" % av)
    if isinstance(g, sp.polylog) and g.args[0] == 2:
        av, aaw, ac = _expr_laurent(g.args[1], nord)
        if aaw != 0:
            raise ValueError("Li2 of eps-power argument")
        if av < 0:
            raise ValueError("Li2 of singular argument")
        if av > 0:  # argument vanishes like w^av: compose Li2(x)=sum x^k/k^2
            ac = [sp.Integer(0)]*min(av, nord) + ac[:nord - min(av, nord)]
        return 0, Z, _ser_li2_list(ac, nord)
    raise ValueError("no series rule for %s node: %s"
                     % (type(g).__name__, sp.srepr(g)[:160]))


def residue_fast(H, odd_sink=None, deep_sink=None):
    """Endpoint residues of jac*to_map(H), per eps-exponent class:
    returns {aw: R_aw} where the term class w^{V+aw*eps} contributes
    R_aw = total coefficient of w^{-2} (= 1/s23) in class aw.
    Odd singular w-powers -> odd_sink as (aw, expr); DEEPER EVEN powers
    (w^{-4} = s23^{-2}, ...) -> deep_sink as (aw, expr): individual
    terms may carry them but they MUST cancel in the full piece
    (non-integrable) -- pooled per-class check by the caller."""
    R = {}
    for term0 in sp.Add.make_args(H):
        term = abs_free(term0)
        G = (jac*to_map(term)).xreplace({s23: _w**2})
        V0 = 0
        facs = []
        for f in sp.Mul.make_args(G):
            b, e = f.as_base_exp()
            if b == _w and e.is_Integer:
                V0 += int(e)
            else:
                facs.append(f)
        data = [_expr_laurent(f, 1) for f in facs]
        V = V0 + sum(d[0] for d in data)
        if V >= -1:
            continue
        need = -V - 1
        data = [_expr_laurent(f, need) for f in facs]
        V = V0 + sum(d[0] for d in data)
        AW = sum((d[1] for d in data), sp.Rational(0))
        if V >= -1:
            continue
        cs = [sp.Integer(1)] + [sp.Integer(0)]*(need - 1)
        for _, _, c in data:
            new = [sp.Integer(0)]*need
            for i in range(need):
                if cs[i] == 0:
                    continue
                for jx in range(need - i):
                    if c[jx] != 0:
                        new[i + jx] += cs[i]*c[jx]
            cs = new
        for k in range(V, min(0, V + need)):
            idx = k - V
            if idx < 0 or idx >= need or cs[idx] == 0:
                continue
            if k == -2:
                # structural LW split (NO sp.Poly: Poly's domain
                # construction expands the masked coefficients — one
                # call measured at 595 s): cs is linear in LW, so
                # c0 = cs|_{LW=0}, c1 = d cs/d LW|_{LW=0}; quadratic
                # guard by second derivative (numeric spot check)
                if cs[idx].has(LW):
                    c1 = sp.diff(cs[idx], LW).xreplace({LW: sp.S(0)})
                    d2 = sp.diff(cs[idx], LW, 2)
                    if d2 != 0 and not _num_zero(d2):
                        raise ValueError("ln^2(s23) endpoint class:"
                                         " %s" % str(term)[:120])
                else:
                    c1 = sp.Integer(0)
                c0 = cs[idx].xreplace({LW: sp.S(0)})
                # key (aw, l): l = power of ln(s23); LW = ln(w) =
                # (1/2) ln(s23), so the l=1 coefficient converts by 1/2
                if c0 != 0:
                    R[(AW, 0)] = R.get((AW, 0), sp.Integer(0)) + c0
                if c1 != 0:
                    R[(AW, 1)] = R.get((AW, 1), sp.Integer(0)) + c1/2
            elif k < -1 and k % 2 == 0:
                if deep_sink is None:
                    raise ValueError("w^%d endpoint (s23^%s): %s"
                                     % (k, sp.Rational(k, 2), term))
                deep_sink.append((AW, unmask(cs[idx])*_w**k))
            elif k < 0 and k % 2 == 1:
                if odd_sink is not None:
                    odd_sink.append((AW, unmask(cs[idx])*_w**k))
    return {key: unmask(v) for key, v in R.items()}
