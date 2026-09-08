#!/usr/bin/env python3
"""Verify frozen input integrity and enforce explicit producer restrictions."""
from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def progress(message):
    line = "SIDIS numerics S02 " + datetime.now(timezone.utc).isoformat() + ": " + message
    if os.environ.get("SIDIS_CLUSTER_RUN") == "1":
        print("PROGRESS " + line, flush=True)
        return
    with (Path(__file__).resolve().parents[2] / "progress.md").open("a") as stream:
        stream.write("\n" + line + "\n")

def main() -> int:
    progress("Requested readiness gate for the imported six-channel prediction. Starting frozen-file integrity and producer-restriction checks; no physics evaluation or convolution. Next publish the measured readiness disposition.")
    manifest_path = BASE / "s01_result"
    manifest = json.loads(manifest_path.read_text())
    if manifest["schema"] != "SIDISNumericsImport-v2" or manifest["status"] != "Complete":
        raise RuntimeError("S01 is not a completed import")
    expected_channels = {"Hqq", "Hgg", "Hqqbar", "Hqqprime", "Hgq", "Hqg"}
    if {r["channel"] for r in manifest["channels"]} != expected_channels:
        raise RuntimeError("Incomplete channel inventory")
    integrity = []
    blockers = []
    retained_limitations = []
    for channel in manifest["channels"]:
        for record in channel["files"]:
            path = BASE / record["copy"]
            if not path.resolve().is_relative_to(BASE / "Fhats"):
                raise RuntimeError(f"Frozen input leaves Fhats: {path}")
            actual = digest(path)
            matches = actual == record["sha256"] and path.stat().st_size == record["bytes"]
            integrity.append({"copy": record["copy"], "sha256": actual, "matches_s01": matches})
            if not matches:
                blockers.append({"code": "FROZEN_INPUT_CHANGED", "file": record["copy"]})
            if channel["channel"] == "Hgq" and record["role"] == "convention_ledger_snapshot":
                lines = path.read_text().splitlines()
                for line_index in [i for i, line in enumerate(lines) if 'unresolved real-emission sign discrepancy' in line]:
                    retained_limitations.append({
                        "code": "HGQ_V4_REAL_TREE_COMPARISON_UNRESOLVED",
                        "channel": channel["channel"],
                        "ledger": record["copy"],
                        "ledger_sha256": actual,
                        "line": line_index + 1,
                        "evidence": "\n".join(lines[max(0, line_index-1):line_index+1]),
                        "effect": "Retained comparison limitation of the supplied accepted S10 input requested by the user; no reference-derived production correction.",
                    })
    result = {
        "schema": "SIDISNumericsInputReadiness-v1",
        "stage": "s02",
        "producer_sha256": digest(Path(__file__)),
        "s01_result_sha256": digest(manifest_path),
        "status": "BlockedByInputIntegrity" if blockers else "InputIntegrityChecked",
        "frozen_integrity": integrity,
        "blockers": blockers,
        "retained_limitations": retained_limitations,
        "replacement_authorization": {
            "instruction": "Replace all active imports with Hqq, Hgg, Hqqbar, Hqqprime, Hgq and Hqg.",
            "scope": "Use the six specified current payloads and preserve the original PDF/FF/observable setup.",
        },
        "scope": "Input transport and explicit producer restrictions only; no independent mathematical acceptance.",
        "convolution_authorized_by_this_gate": not blockers,
        "cross_section_evaluated": False,
        "remaining_consumer_requirements": [
            "Resolve every integrity blocker before consuming a dependent coefficient; preserve the v4 comparison limitations in the result provenance.",
            "Use the original Fig. 3 MRST02 NLO PDF and both KKP/Kretzer NLO fragmentation choices with the documented common scale prescription.",
            "Derive and check each channel's order coverage, flavor/charge weights, normalized distribution action and observable maps inside the calculation tool.",
            "Include required Born contributions for the complete NLO observable.",
            "Implement the documented H1 cuts and bin integration; verify numerical convergence before final plots.",
        ],
    }
    output = BASE / "s02_result"
    temporary = output.with_name(output.name + f".tmp.{os.getpid()}")
    try:
        temporary.write_text(json.dumps(result, indent=2) + "\n")
        if json.loads(temporary.read_text()) != result:
            raise RuntimeError("S02 result reload failed")
        temporary.replace(output)
    finally:
        if temporary.exists():
            temporary.unlink()
    progress(f"Readiness inspection complete: {len(integrity)} frozen files checked, status={result['status']}, integrity blockers={[b['code'] for b in blockers]}; v4 comparison limitations retained. No convolution ran in this inspection. Next derive the v4 consumer contract and execute the requested replacement using the unchanged PDF/FF setup.")
    print(json.dumps({"status": result["status"], "frozen_files_checked": len(integrity),
                      "blockers": blockers}, indent=2))
    return 2 if blockers else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        progress(f"Readiness inspection failed: {type(error).__name__}: {error}. Next resolve this exact integrity/schema failure; no dependent run.")
        raise
