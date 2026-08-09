#!/usr/bin/env python3
"""C1/WS12: exact Hqg real+virtual double-pole gate.

Consumes production-frame R4 residues, so every invariant-frame Deep class
has already contributed its exact Taylor coefficient to the physical
1/s23 residue.  Only the eps^-2 coefficient is extracted.  Work is linear,
per-term, atomically checkpointed, and entirely symbolic.
"""
import glob
import multiprocessing as mp
import os
import pickle
import re
import signal
import sys
import time

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'cache')
sys.path.insert(0, HERE)


def _polylog_eval_inert(cls, order, argument):
    if argument is sp.S.Zero:
        return sp.S.Zero
    return None


sp.polylog.eval = classmethod(_polylog_eval_inert)

from Hqq_C1_from_r4mf import (eps, kf, class_delta_factor, resolve,
                              virtual_double_pole, s_inv, t1_inv,
                              Q2_inv)  # noqa: E402
from Hqq_R4mf_to_prod import (JAC0, _map_by_name_at_zero)  # noqa: E402
from Hqq_R4_kinmap import (x as kin_x, z as kin_z, Q2 as kin_Q2,
                           PHT as kin_PHT, xi as kin_xi)  # noqa: E402

CHANNEL = os.environ.get('C1_CHANNEL', 'Hqg')
if CHANNEL not in ('Hqg', 'Hgq'):
    raise ValueError('C1_CHANNEL must be Hqg or Hgq')
PIECE = {'Hqg': 'HQG', 'Hgq': 'HGQ'}[CHANNEL]
VERSION = {'Hqg': 'hqg-c1-exact-v3',
           'Hgq': 'hgq-c1-exact-v2'}[CHANNEL]
WORKER_CAP_BYTES = int(os.environ.get(
    'HQG_C1_WORKER_CAP_BYTES', 1073741824))
TERM_TIMEOUT = int(os.environ.get('HQG_C1_TERM_TIMEOUT', 180))
CHECKPOINT_SIZE = int(os.environ.get('HQG_C1_CHECKPOINT_SIZE', 100))


class TermTimeout(Exception):
    pass


def _alarm(_signum, _frame):
    raise TermTimeout()


def _init_worker(cap_bytes):
    import resource
    resource.setrlimit(resource.RLIMIT_AS, (cap_bytes, cap_bytes))
    signal.signal(signal.SIGALRM, _alarm)


def _mask_eps_free(expr):
    """Replace maximal non-atomic eps-free subtrees by exact Dummies.

    Generic series was measured spending >180 s rebuilding large kinematic
    rational functions which are constants with respect to eps.  The masked
    series contains the identical eps algebra, and xreplace restores every
    coefficient exactly afterward.
    """
    forward, backward = {}, {}

    def scalar(node):
        dummy = forward.get(node)
        if dummy is None:
            dummy = sp.Dummy('EC%d' % len(forward))
            forward[node] = dummy
            backward[dummy] = node
        return dummy

    def rec(node):
        if not node.has(eps):
            return node if node.is_Atom else scalar(node)
        if node.is_Atom:
            return node
        return node.func(*[rec(arg) for arg in node.args])

    return rec(expr), backward


def _eps_power(term):
    """Return the exact integer eps power of one expanded Laurent monomial."""
    power = term.as_powers_dict().get(eps, sp.Integer(0))
    if power.is_Integer is not True:
        raise ValueError('non-integer eps power in Laurent monomial: %s'
                         % power)
    coefficient = term/eps**power
    if coefficient.has(eps):
        raise ValueError('unexpanded eps dependence in Laurent monomial')
    return int(power), coefficient


def _parse_laurent(expr):
    """Parse an exact finite Laurent polynomial without using Poly.degree."""
    result = {}
    for monomial in sp.Add.make_args(sp.expand(expr)):
        if monomial == 0:
            continue
        power, coefficient = _eps_power(monomial)
        result[power] = result.get(power, sp.Integer(0)) + coefficient
    return {power: coefficient for power, coefficient in result.items()
            if coefficient != 0}


def _factor_valuation(factor):
    """Exact leading eps power; handles Gamma poles and their reciprocals."""
    if not factor.has(eps):
        return 0
    # A direct as_leading_term call raises PoleError for exact factors such
    # as C**(-1-eps).  Small one-factor series are both faster and more
    # robust.  The loop is needed for reciprocal Gamma poles, whose first
    # nonzero term can be eps or eps**2.
    for order in range(1, 7):
        coefficients = _parse_laurent(
            sp.series(factor, eps, 0, order).removeO())
        if coefficients:
            return min(coefficients)
    raise ValueError('factor valuation exceeds supported exact probe order')


def _factorwise_laurent(expr, target_min=-2, target_max=0):
    """Selected Laurent coefficients via bounded factor convolution.

    ``factor_terms`` exposes repeated Gamma and power factors without
    distributing their kinematic coefficients.  Each factor is expanded
    only far enough to contribute through ``target_max`` after the known
    valuations of all other factors.  Intermediate products are truncated
    using the remaining minimum valuation, so a global expanded product is
    never constructed.
    """
    factored = sp.factor_terms(expr, clear=True)
    factors = sp.Mul.make_args(factored)
    valuations = [_factor_valuation(factor) for factor in factors]
    total_min = sum(valuations)
    if total_min > target_max:
        return {}

    series_dicts = []
    for factor, valuation in zip(factors, valuations):
        maximum = target_max - (total_min - valuation)
        if not factor.has(eps):
            coefficients = {0: factor}
        else:
            finite_series = sp.series(
                factor, eps, 0, maximum + 1).removeO()
            coefficients = _parse_laurent(finite_series)
        series_dicts.append(coefficients)

    suffix_min = [0]*(len(factors) + 1)
    for index in range(len(factors) - 1, -1, -1):
        suffix_min[index] = suffix_min[index + 1] + valuations[index]

    accumulated = {0: sp.Integer(1)}
    for index, coefficients in enumerate(series_dicts):
        upper = target_max - suffix_min[index + 1]
        combined = {}
        for left_power, left_coefficient in accumulated.items():
            for right_power, right_coefficient in coefficients.items():
                power = left_power + right_power
                if power <= upper:
                    combined[power] = (
                        combined.get(power, sp.Integer(0))
                        + left_coefficient*right_coefficient)
        accumulated = combined
    return {power: coefficient for power, coefficient in accumulated.items()
            if target_min <= power <= target_max and coefficient != 0}


def hgq_inverse_endpoint(expr):
    """Return an Hgq endpoint expression to compact (s,t1,Q2) invariants.

    The production bridge uses the exact endpoint map
      s = Q2 (xi/x - 1),
      t1 = -PHT^2 (Q2+s)/(PHT^2+s z^2).
    Its exact inverse is
      xi = x (Q2+s)/Q2,
      PHT^2 = -s t1 z^2/(Q2+s+t1).
    Applying this one-to-one reparametrization to each small extracted term
    before summation prevents the measured-frame rational explosion seen in
    PP reduction pair 115 (124,635 operations).  No approximation or
    kinematic specialization is made.
    """
    xi_inverse = kin_x*(kin_Q2 + s_inv)/kin_Q2
    pht2_inverse = (-s_inv*t1_inv*kin_z**2
                    / (kin_Q2 + s_inv + t1_inv))
    mapped = expr.subs(kin_xi, xi_inverse)
    mapped = mapped.subs(kin_PHT**2, pht2_inverse)
    mapped = resolve(mapped)
    return sp.factor(sp.cancel(sp.together(mapped)))


def _eps_m2(arg):
    """Exact eps^-2 coefficient of one prefactor times one residue term."""
    proj, key, index, pref_coeffs, term, timeout = arg
    signal.alarm(timeout)
    t0 = time.time()
    try:
        if term.atoms(sp.Float):
            raise ValueError('Float atom in exact C1 input')
        free, dep = sp.Integer(1), sp.Integer(1)
        for factor in sp.Mul.make_args(term):
            if factor.has(eps):
                dep *= factor
            else:
                free *= factor

        masked, backward = _mask_eps_free(dep)
        dcoeffs = (_factorwise_laurent(masked)
                   if masked != 1 else {0: sp.Integer(1)})
        contributions = []
        for kp, cp in pref_coeffs:
            kd = -2 - kp
            cd = dcoeffs.get(kd, sp.Integer(0))
            if cd != 0:
                contributions.append(
                    free*cp*(cd.xreplace(backward) if backward else cd))
        value = sp.Add(*contributions)
        if CHANNEL == 'Hgq' and value != 0:
            value = hgq_inverse_endpoint(value)
        if value.atoms(sp.Float):
            raise ValueError('Float atom in exact C1 output')
        if value.has(sp.zoo, sp.nan, sp.oo, -sp.oo):
            raise ValueError('non-finite atom in exact C1 output')
        return index, 'OK', value, len(backward), time.time() - t0
    except TermTimeout:
        return index, 'TIMEOUT', None, 0, time.time() - t0
    except Exception as exc:
        return (index, 'ERROR:%s:%s' % (type(exc).__name__, exc),
                None, 0, time.time() - t0)
    finally:
        signal.alarm(0)
        sp.core.cache.clear_cache()


def _accepted_batches(proj, key, term_count):
    c, l = key
    pattern = os.path.join(
        CACHE, '%s_C1batch_%s_c%s_l%s_*.pkl' %
        (CHANNEL, proj, c, l))
    files = sorted(glob.glob(pattern))
    done, sums = set(), []
    for filename in files:
        saved = pickle.load(open(filename, 'rb'))
        if (saved.get('version') != VERSION
                or saved.get('projection') != proj
                or saved.get('class') != key
                or saved.get('term_count') != term_count):
            continue
        done.update(saved['indices'])
        sums.append(saved['value'])
    return files, done, sums


def main():
    proj = sys.argv[1]
    workers = int(sys.argv[2]) if len(sys.argv) > 2 else 8
    if proj not in ('g', 'PP'):
        raise SystemExit('projection must be g or PP')
    print('WS12: WNLOunsub = Wreal + Wvirtual; IR poles cancel, '
          'collinear poles remain.', flush=True)
    source = os.path.join(
        CACHE, 'Hqq_R4prod_MR2%s%s.pkl' %
        ('g' if proj == 'g' else 'PP', PIECE))
    payload = pickle.load(open(source, 'rb'))
    if payload.get('version') != 'r4mf-prod-bridge-v1':
        raise ValueError('unaccepted production R4 version')
    residues = payload['R']
    class_sums = []
    pending, errors = [], []
    progress_file = os.path.join(
        CACHE, '%s_C1_%s_progress.pkl' % (CHANNEL, proj))
    ctx = mp.get_context('spawn')

    with ctx.Pool(workers, initializer=_init_worker,
                  initargs=(WORKER_CAP_BYTES,), maxtasksperchild=100) as pool:
        for key in sorted(residues, key=str):
            c, l = key
            terms = sp.Add.make_args(residues[key])
            pref = kf*class_delta_factor(c, l)
            pseries = sp.series(pref, eps, 0, 1).removeO()
            pref_coeffs = tuple(
                (k, pseries.coeff(eps, k))
                for k in range(-4, 1)
                if pseries.coeff(eps, k) != 0)
            files, done, sums = _accepted_batches(
                proj, key, len(terms))
            print('C1 %s class %s: %d terms, %d resumed' %
                  (proj, key, len(terms), len(done)), flush=True)
            next_batch = len(files)
            values, indices = [], []
            t0 = time.time()

            def write_progress(state):
                data = {'version': VERSION, 'projection': proj,
                        'state': state, 'class': key,
                        'completed': len(done), 'total': len(terms),
                        'pending': list(pending), 'errors': list(errors)}
                pickle.dump(data, open(progress_file + '.tmp', 'wb'))
                os.replace(progress_file + '.tmp', progress_file)

            def flush():
                nonlocal next_batch
                if not values:
                    return
                filename = os.path.join(
                    CACHE, '%s_C1batch_%s_c%s_l%s_%04d.pkl'
                    % (CHANNEL, proj, c, l, next_batch))
                data = {'version': VERSION, 'projection': proj,
                        'class': key, 'term_count': len(terms),
                        'indices': tuple(indices),
                        'value': sp.Add(*values)}
                pickle.dump(data, open(filename + '.tmp', 'wb'))
                os.replace(filename + '.tmp', filename)
                sums.append(data['value'])
                values.clear()
                indices.clear()
                next_batch += 1
                print('  checkpoint %04d durable=%d/%d' %
                      (next_batch - 1, len(done), len(terms)), flush=True)

            def jobs():
                for index, term in enumerate(terms):
                    if index in done:
                        continue
                    yield (proj, key, index, pref_coeffs, term,
                           TERM_TIMEOUT)

            write_progress('RUNNING')
            returned = 0
            for index, status, value, nsplit, elapsed in pool.imap_unordered(
                    _eps_m2, jobs(), chunksize=1):
                returned += 1
                if status == 'OK':
                    done.add(index)
                    values.append(value)
                    indices.append(index)
                elif status == 'TIMEOUT':
                    pending.append((key, index))
                    print('  TIMEOUT class %s term %d' % (key, index),
                          flush=True)
                else:
                    errors.append((key, index, status))
                    print('  %s class %s term %d' % (status, key, index),
                          flush=True)
                if len(values) >= CHECKPOINT_SIZE:
                    flush()
                if returned % 50 == 0:
                    write_progress('RUNNING')
                    print('  progress %d/%d pending=%d errors=%d %ds' %
                          (len(done), len(terms), len(pending),
                           len(errors), int(time.time() - t0)), flush=True)
            flush()
            write_progress('RUNNING')
            class_sums.extend(sums)

    if pending or errors:
        data = {'version': VERSION, 'projection': proj,
                'state': 'INCOMPLETE', 'pending': pending,
                'errors': errors}
        pickle.dump(data, open(progress_file + '.tmp', 'wb'))
        os.replace(progress_file + '.tmp', progress_file)
        print('%s_C1_INCOMPLETE pending=%s errors=%s' %
              (CHANNEL.upper(), pending, errors), flush=True)
        raise SystemExit(3)

    if os.environ.get('HQG_C1_SKIP_FINAL') == '1':
        data = {'version': VERSION, 'projection': proj,
                'state': 'EXTRACTED', 'pending': [], 'errors': []}
        pickle.dump(data, open(progress_file + '.tmp', 'wb'))
        os.replace(progress_file + '.tmp', progress_file)
        print('%s_C1_%s_EXTRACTED' % (CHANNEL.upper(), proj), flush=True)
        return

    real = resolve(sp.Add(*class_sums))
    if CHANNEL == 'Hqg':
        vfile = os.path.join(
            CACHE, 'Hqg_V2_virt%s_ren_inv_sym.pkl'
            % ('G' if proj == 'g' else 'PP'))
        virtual_inv = pickle.load(open(vfile, 'rb'))
        virtual_inv_m2 = resolve(virtual_double_pole(virtual_inv))
    else:
        from Hgq_C1_catani import hgq_virtual_double_pole
        virtual_inv_m2 = hgq_virtual_double_pole(proj)
    # virtual_double_pole() already extracts the coefficient of Pi*virt,
    # matching the project statement "the virtual enters as Pi*virt".
    # Multiplying by Pi again leaves the exact diagnostic real/virtual=-1/Pi.
    if CHANNEL == 'Hqg':
        virtual = JAC0*_map_by_name_at_zero(virtual_inv_m2)
    else:
        jac_inverse = (kin_z*(Q2_inv + s_inv)
                       / (s_inv*(Q2_inv + s_inv + t1_inv)))
        virtual = sp.factor(sp.cancel(sp.together(
            jac_inverse*virtual_inv_m2)))
    if real.atoms(sp.Float) or virtual.atoms(sp.Float):
        raise ValueError('Float atom at final Hqg C1 gate')

    print('C1 %s exact source reduction' % proj, flush=True)
    real_reduced = sp.cancel(sp.together(real))
    virtual_reduced = sp.cancel(sp.together(virtual))
    remainder = sp.cancel(sp.together(real_reduced + virtual_reduced))
    output = os.path.join(
        CACHE, '%s_C1_%s.pkl' % (CHANNEL, proj))
    result = {'version': VERSION, 'projection': proj,
              'real_eps_m2': real_reduced,
              'virtual_eps_m2': virtual_reduced,
              'remainder_eps_m2': remainder}
    pickle.dump(result, open(output + '.tmp', 'wb'))
    os.replace(output + '.tmp', output)
    state = 'PASS' if remainder == 0 else 'FAIL'
    data = {'version': VERSION, 'projection': proj, 'state': state,
            'pending': [], 'errors': []}
    pickle.dump(data, open(progress_file + '.tmp', 'wb'))
    os.replace(progress_file + '.tmp', progress_file)
    print('%s_C1_%s %s' % (CHANNEL.upper(), proj, state), flush=True)
    if remainder != 0:
        print(remainder, flush=True)
        raise SystemExit(1)


if __name__ == '__main__':
    main()
