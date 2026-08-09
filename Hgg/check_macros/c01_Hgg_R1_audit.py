#!/usr/bin/env python3
"""Cheap exact audit of the Hgg R1 permutation; no trace is recomputed."""
import hashlib
import json
import os
import sys

import sympy as sp

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import generated.Hgq_R1 as parent  # noqa: E402
import generated.Hgg_R1 as child   # noqa: E402

t1, t3, u1, u3, s12, s23 = sp.symbols('t1 t3 u1 u3 s12 s23')
SWAP = {t1: t3, t3: t1, u1: u3, u3: u1, s12: s23, s23: s12}


def sha(path):
    return hashlib.sha256(open(path, 'rb').read()).hexdigest()


def main():
    parent_path = os.path.join(HERE, 'generated', 'Hgq_R1.py')
    child_path = os.path.join(HERE, 'generated', 'Hgg_R1.py')
    header = open(child_path, encoding='utf-8').read(512)
    expected = sha(parent_path)
    if 'source_sha256=%s' % expected not in header:
        raise AssertionError('Hgg R1 parent hash is absent or stale')
    log = open(os.path.join(ROOT, 'mathematica', 'Hgq_NLO_R1_traces.log'),
               encoding='utf-8').read()
    required = ('gluon-p Ward scan:', 'gluon-k3 Ward scan:',
                'check 2 (photon Ward q q, must be 0): InputForm[0]',
                '[5b] structural guard passed', 'HGQ_R1_DONE')
    if not all(item in log for item in required):
        raise AssertionError('parent R1 validation log is incomplete')
    verdict = {}
    for name in ('M2g', 'M2PP'):
        p = sp.sympify(getattr(parent, name), rational=True)
        c = sp.sympify(getattr(child, name), rational=True)
        verdict[name] = {
            'exact_forward': c == p.xreplace(SWAP),
            'exact_involution': c.xreplace(SWAP) == p,
            'float_free': not bool(c.atoms(sp.Float)),
        }
        if not all(verdict[name].values()):
            raise AssertionError('%s permutation audit failed' % name)
    result = {'state': 'accepted', 'parent_sha256': expected,
              'child_sha256': sha(child_path), 'checks': verdict,
              'physics': 'k1<->k3; q,qbar,g distinct; no final-state 1/2!'}
    out = os.path.join(HERE, 'cache', 'Hgg_R1_audit.json')
    os.makedirs(os.path.dirname(out), exist_ok=True)
    temporary = '%s.tmp.%d' % (out, os.getpid())
    with open(temporary, 'w', encoding='utf-8') as stream:
        json.dump(result, stream, indent=2, sort_keys=True)
        stream.write('\n'); stream.flush(); os.fsync(stream.fileno())
    os.replace(temporary, out)
    print('HGG_R1_AUDIT_PASS parent=%s child=%s' %
          (expected[:12], result['child_sha256'][:12]), flush=True)


if __name__ == '__main__':
    main()
