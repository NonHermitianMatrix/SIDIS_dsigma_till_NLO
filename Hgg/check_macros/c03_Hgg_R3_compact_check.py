#!/usr/bin/env python3
"""Exact regression check for the Hgg compact-rational R3 path."""
import os
import pickle
import time

import sympy as sp

from Hqq_R3_engine import angular_integrate


def main():
    root = os.environ.get("HGG_R2_ROOT", "/tmp")
    # One term from each projection, chosen from distinct denominator routes.
    # Large terms are exercised by the production smoke run below; evaluating
    # them twice here would merely reproduce the legacy bottleneck.
    cases = (("MR2gHGG", 100), ("MR2PPHGG", 72))
    for name, index in cases:
        path = os.path.join(root, "Hqq2_R2_%s.pkl" % name)
        with open(path, "rb") as stream:
            term = pickle.load(stream)[index]
        started = time.time()
        legacy = angular_integrate(term, compact_rational=False)
        legacy_seconds = time.time() - started
        started = time.time()
        compact = angular_integrate(term, compact_rational=True)
        compact_seconds = time.time() - started
        difference = sp.cancel(sp.together(legacy - compact))
        print("HGG_R3_COMPACT_CHECK name=%s index=%d exact=%s legacy=%.3f compact=%.3f" %
              (name, index, difference == 0, legacy_seconds, compact_seconds),
              flush=True)
        if difference != 0:
            return 1
    print("HGG_R3_COMPACT_CHECK_PASS", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
