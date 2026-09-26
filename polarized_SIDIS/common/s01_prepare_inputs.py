#!/usr/bin/env python3
"""Validate the pinned, selected open-amplitude inputs on a compute node."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import socket
import tempfile
from datetime import datetime, timezone


def atomic_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=path.name + ".", dir=str(path.parent))
    try:
        with os.fdopen(fd, "w") as stream:
            json.dump(value, stream, indent=2, sort_keys=True)
            stream.write("\n")
        os.replace(name, str(path))
    finally:
        if os.path.exists(name):
            os.unlink(name)


def identities(path):
    size = path.stat().st_size
    sha256 = hashlib.sha256()
    blob = hashlib.sha1(("blob %d\0" % size).encode("ascii"))
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            sha256.update(chunk)
            blob.update(chunk)
    return {"bytes": size, "sha256": sha256.hexdigest(), "git_blob": blob.hexdigest()}


def inside(root, relative):
    relative = Path(relative)
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError("unsafe relative path: %s" % relative)
    resolved = (root / relative).resolve()
    if root.resolve() not in resolved.parents:
        raise ValueError("path escapes stage root: %s" % relative)
    return resolved


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, type=Path)
    args = parser.parse_args()
    root = args.root.resolve()
    if not os.environ.get("JOB_ID") or socket.gethostname().startswith("login"):
        raise RuntimeError("stage execution requires a Hoffman2 compute allocation")
    config_path = root / "common/s01_inputs.json"
    config = json.loads(config_path.read_text())
    if config["schema"] != "polarized-sidis-inputs-v1":
        raise ValueError("unsupported input manifest")
    if config["scope"]["measurement"] != "reference-large-transverse-momentum-SIDIS":
        raise ValueError("measurement contract mismatch")
    if config["scope"]["spin"] != "all-incoming-and-tagged-outgoing-components":
        raise ValueError("spin contract mismatch")
    total_bytes = sum(row["bytes"] for row in config["files"])
    if total_bytes > config["maximum_import_bytes"]:
        raise RuntimeError("selected inputs exceed the import bound")
    if shutil.disk_usage(str(root)).free < 2 * total_bytes + config["disk_reserve_bytes"]:
        raise RuntimeError("insufficient scratch reserve")
    destinations = [row["destination"] for row in config["files"]]
    if len(destinations) != len(set(destinations)):
        raise ValueError("duplicate input destinations")
    results = {channel: [] for channel in config["channels"]}
    for row in config["files"]:
        channel = row["channel"]
        if channel not in results:
            raise ValueError("unknown channel")
        if not row["destination"].startswith(channel + "/s01_result/reference/"):
            raise ValueError("input destination is outside the owning channel result")
        src = inside(root / "cache/s01_staging", row["upstream_path"])
        dst = inside(root, row["destination"])
        expected = {key: row[key] for key in ("bytes", "sha256", "git_blob")}
        if identities(src) != expected:
            raise RuntimeError("pinned input mismatch: " + row["upstream_path"])
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists():
            if identities(dst) != expected:
                raise RuntimeError("refusing to overwrite a different saved input: " + str(dst))
        else:
            fd, tmp = tempfile.mkstemp(prefix=dst.name + ".", dir=str(dst.parent))
            try:
                with os.fdopen(fd, "wb") as output, src.open("rb") as source:
                    shutil.copyfileobj(source, output, 1024 * 1024)
                if identities(Path(tmp)) != expected:
                    raise RuntimeError("copied input failed its identity check")
                os.replace(tmp, str(dst))
            finally:
                if os.path.exists(tmp):
                    os.unlink(tmp)
        results[channel].append(dict(row))
        print("PASS: input", row["destination"], flush=True)
    source = Path(__file__).resolve()
    common = {
        "schema": "polarized-sidis-input-receipt-v1",
        "repository": config["repository"], "commit": config["commit"],
        "tree": config["tree"], "scope": config["scope"],
        "source_sha256": identities(source)["sha256"],
        "configuration_sha256": identities(config_path)["sha256"],
        "job_id": os.environ["JOB_ID"], "node": socket.gethostname(),
        "completed_utc": datetime.now(timezone.utc).isoformat(),
        "input_identity_checks_passed": True, "physics_executed": False,
        "finite_fhats_computed": False,
        "limitation": "Input provenance is verified; polarized contractions and finite assembly are separate stages."
    }
    for channel, rows in results.items():
        receipt = dict(common, channel=channel, files=rows)
        atomic_json(root / channel / "s01_result/s01_result.json", receipt)
    atomic_json(root / "common/s01_result/s01_result.json",
                dict(common, channels=list(results), file_count=len(config["files"]),
                     imported_bytes=total_bytes))
    print("PASS: s01_prepare_inputs", flush=True)


if __name__ == "__main__":
    main()
