#!/usr/bin/env python3
"""Execute one reviewed stage with process-tree resource and progress guards."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import resource
import shutil
import signal
import socket
import subprocess
import tempfile
import time
from datetime import datetime, timezone


def digest(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


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


def owned(root, relative):
    path = Path(relative)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError("unsafe relative path")
    path = (root / path).resolve()
    if root not in path.parents:
        raise ValueError("path escapes this calculation")
    return path


def tree_rss(pid):
    output = subprocess.check_output(["ps", "-eo", "pid=,ppid=,rss="],
                                     universal_newlines=True, timeout=20)
    rows = [tuple(map(int, line.split())) for line in output.splitlines()
            if len(line.split()) == 3]
    descendants = {pid}
    while True:
        expanded = descendants | {p for p, parent, _ in rows if parent in descendants}
        if expanded == descendants:
            break
        descendants = expanded
    return sum(rss for p, _, rss in rows if p in descendants) * 1024


def disk_bytes(root):
    size = 0
    for directory, _, names in os.walk(str(root), followlinks=False):
        for name in names:
            path = Path(directory) / name
            try:
                if not path.is_symlink():
                    size += path.stat().st_size
            except FileNotFoundError:
                pass
    return size


def stop(child):
    if child.poll() is not None:
        return
    try:
        os.killpg(child.pid, signal.SIGTERM)
        child.wait(timeout=15)
    except subprocess.TimeoutExpired:
        os.killpg(child.pid, signal.SIGKILL)
        child.wait(timeout=15)
    except ProcessLookupError:
        child.wait(timeout=15)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--job", required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    if not os.environ.get("JOB_ID") or socket.gethostname().startswith("login"):
        raise RuntimeError("compute allocation required")
    job_path = owned(root, args.job)
    job = json.loads(job_path.read_text())
    for relative, expected in job["reviewed_sha256"].items():
        if digest(owned(root, relative)) != expected:
            raise RuntimeError("reviewed source/input changed: " + relative)
    result_path = owned(root, job["execution_result"])
    if result_path.exists():
        raise RuntimeError("execution receipt exists; use a new job generation")
    log_path = owned(root, job["log"])
    log_path.parent.mkdir(parents=True, exist_ok=True)
    heartbeat = owned(root, job["heartbeat"])
    command = [token.replace("{root}", str(root)) for token in job["command"]]
    env = dict(os.environ)
    env.update({"OMP_NUM_THREADS": "1", "MKL_NUM_THREADS": "1",
                "OPENBLAS_NUM_THREADS": "1", "PYTHONIOENCODING": "utf-8"})
    env.update({key: value.replace("{root}", str(root))
                for key, value in job.get("environment", {}).items()})
    limits = job["limits"]
    started = time.monotonic()
    last_progress = started
    last_size = 0
    peak_rss = 0
    reason = "normal_exit"
    requested_limits = {
        resource.RLIMIT_AS: limits["per_process_address_bytes"],
        resource.RLIMIT_FSIZE: limits["per_file_bytes"],
        resource.RLIMIT_CORE: 0,
    }
    effective_limits = {}
    inherited_limits = {}
    for kind, requested in requested_limits.items():
        soft, hard = resource.getrlimit(kind)
        inherited_limits[kind] = [soft, hard]
        effective_limits[kind] = requested if hard == resource.RLIM_INFINITY else min(requested, hard)

    def set_limits():
        for kind, maximum in effective_limits.items():
            resource.setrlimit(kind, (maximum, maximum))

    with log_path.open("w") as output:
        try:
            child = subprocess.Popen(command, cwd=str(root), env=env, stdout=output,
                                     stderr=subprocess.STDOUT, start_new_session=True,
                                     preexec_fn=set_limits)
        except (OSError, subprocess.SubprocessError) as error:
            receipt = {"schema": "polarized-sidis-execution-v1", "passed": False,
                       "reason": "program_start_failed", "error": str(error),
                       "command": command, "job_id": os.environ["JOB_ID"],
                       "node": socket.gethostname(), "reviewed_sha256": job["reviewed_sha256"],
                       "job_configuration_sha256": digest(job_path),
                       "inherited_resource_limits": inherited_limits,
                       "effective_resource_limits": effective_limits,
                       "completed_utc": datetime.now(timezone.utc).isoformat()}
            atomic_json(result_path, receipt)
            print("FAIL: program_start", json.dumps(receipt), flush=True)
            raise SystemExit(2)
        print("PROCESS_STARTED", child.pid, flush=True)
        try:
            while child.poll() is None:
                now = time.monotonic()
                rss = tree_rss(child.pid)
                peak_rss = max(peak_rss, rss)
                size = log_path.stat().st_size
                if size != last_size:
                    last_progress, last_size = now, size
                scratch_bytes = disk_bytes(root)
                state = {"pid": child.pid, "rss_bytes": rss,
                         "peak_tree_rss_bytes": peak_rss,
                         "elapsed_seconds": now - started,
                         "inactive_seconds": now - last_progress,
                         "scratch_bytes": scratch_bytes,
                         "job_id": os.environ["JOB_ID"], "log_bytes": size}
                atomic_json(heartbeat, state)
                if rss > limits["tree_rss_bytes"]:
                    reason = "tree_rss_limit"
                elif now - started > limits["wall_seconds"]:
                    reason = "wall_limit"
                elif now - last_progress > limits["inactivity_seconds"]:
                    reason = "inactivity_limit"
                elif scratch_bytes > limits["scratch_bytes"]:
                    reason = "scratch_limit"
                elif shutil.disk_usage(str(root)).free < limits["disk_reserve_bytes"]:
                    reason = "disk_reserve"
                if reason != "normal_exit":
                    stop(child)
                    break
                time.sleep(limits["poll_seconds"])
        except BaseException:
            stop(child)
            raise
        code = child.wait()
    passed_marker = False
    failed_marker = False
    with log_path.open(errors="replace") as stream:
        for line in stream:
            passed_marker = passed_marker or job["success_marker"] in line
            failed_marker = failed_marker or "FAIL:" in line
    expected = [owned(root, path) for path in job["expected_results"]]
    passed = (code == 0 and reason == "normal_exit" and passed_marker
              and not failed_marker and all(path.is_file() for path in expected))
    receipt = {"schema": "polarized-sidis-execution-v1", "passed": passed,
               "exit_code": code, "reason": reason, "command": command,
               "job_id": os.environ["JOB_ID"], "node": socket.gethostname(),
               "wall_seconds": time.monotonic() - started,
               "peak_observed_tree_rss_bytes": peak_rss,
               "child_maxrss_bytes": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss * 1024,
               "reviewed_sha256": job["reviewed_sha256"],
               "inherited_resource_limits": inherited_limits,
               "effective_resource_limits": effective_limits,
               "job_configuration_sha256": digest(job_path),
               "result_sha256": {str(path.relative_to(root)): digest(path)
                                 for path in expected if path.is_file()},
               "completed_utc": datetime.now(timezone.utc).isoformat()}
    atomic_json(result_path, receipt)
    print("JOB_FINISHED", json.dumps(receipt, sort_keys=True), flush=True)
    raise SystemExit(0 if passed else 1)


if __name__ == "__main__":
    main()
