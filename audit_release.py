#!/usr/bin/env python3
"""Structural and hash audit for the copy-only SIDIS macro release."""
from __future__ import annotations

import hashlib
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CHANNELS = ("Hgq", "Hqq", "Hqg", "Hgg", "Hqqbar", "Hqqp")
FORBIDDEN = ("/rejected/", "/OLD_", "/WRONG_", "/stale_", ".STALE")


def sha(path):
    d = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            d.update(block)
    return d.hexdigest()


def main():
    errors = []
    total = 0
    for channel in CHANNELS:
        cdir = os.path.join(HERE, channel)
        for required in ("README.md", "SOURCE_MANIFEST.json", "output", "check_macros"):
            if not os.path.exists(os.path.join(cdir, required)):
                errors.append("%s missing %s" % (channel, required))
        records = json.load(open(os.path.join(cdir, "SOURCE_MANIFEST.json")))
        steps = []
        for record in records:
            total += 1
            rel = record["copy"]
            path = os.path.join(cdir, rel)
            if not os.path.isfile(path):
                errors.append("missing copy %s/%s" % (channel, rel)); continue
            if sha(path) != record["sha256"]:
                errors.append("copy hash mismatch %s/%s" % (channel, rel))
            source = record["source"]
            decorated = "/" + source
            if any(word.lower() in decorated.lower() for word in FORBIDDEN):
                errors.append("forbidden lineage %s" % source)
            original = os.path.join(ROOT, source)
            if not os.path.isfile(original) or sha(original) != record["sha256"]:
                errors.append("original changed or missing %s" % source)
            if record["role"] == "producer_or_required_gate":
                steps.append(record["step"])
                if not re.match(r"s%02d_" % record["step"], rel):
                    errors.append("bad step prefix %s" % rel)
        if steps != list(range(1, len(steps) + 1)):
            errors.append("non-contiguous steps in %s" % channel)

    final = os.path.join(HERE, "final_finite_F_hats")
    sums = {}
    for line in open(os.path.join(final, "SHA256SUMS")):
        digest, name = line.rstrip().split("  ", 1)
        sums[name] = digest
        if sha(os.path.join(final, name)) != digest:
            errors.append("final hash mismatch " + name)
    if len(sums) != 15:
        errors.append("expected 15 final component files, found %d" % len(sums))
    for base, dirs, files in os.walk(HERE):
        for name in dirs + files:
            if os.path.islink(os.path.join(base, name)):
                errors.append("symlink present " + os.path.join(base, name))

    if errors:
        print("MACROS_AUDIT_FAIL")
        for error in errors: print(error)
        raise SystemExit(1)
    print("MACROS_AUDIT_PASS channels=6 records=%d final_components=%d" %
          (total, len(sums)))


if __name__ == "__main__":
    main()
