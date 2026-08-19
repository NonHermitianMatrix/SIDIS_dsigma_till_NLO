#!/usr/bin/env python3
"""Prepare byte-identical Hqqprime inputs for the isolated MadGraph check."""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
from typing import Any


CHECK_DIR = Path(__file__).resolve().parent
CHANNEL_DIR = CHECK_DIR.parent
SCRIPTS_DIR = CHANNEL_DIR.parent
COPIES_DIR = CHECK_DIR / "upstream_copies"
OUTPUT_PATH = CHECK_DIR / "s01_input_manifest.json"

STAGE_VERSION = "HqqprimeMadGraphInputProvenance-v1"
EXPECTED_HQQPRIME_SHA256 = {
    "s01_calculate_hqqprime_tree.wl": (
        "17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4"
    ),
    "s01_result": (
        "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b"
    ),
    "s06_spin_color_sum_average_hqqprime.wl": (
        "eef94883991b5fb6d10345f29943234f90c2da695879c4ca6f2ee99a4a970adc"
    ),
    "s06_result": (
        "92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607"
    ),
    "s07_contract_hqqprime_projectors.wl": (
        "4ac73e5b846e088c7c92acfed2bb935ba969e9049d778f83e5f8cfa34fcab1e7"
    ),
    "s07_result": (
        "b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026"
    ),
}

MADGRAPH_PATH = (
    SCRIPTS_DIR
    / "Hqqbar"
    / "madgraph_check"
    / "software"
    / "MG5_aMC_v3_7_0"
    / "bin"
    / "mg5_aMC"
)
SIX_PATH = (
    SCRIPTS_DIR
    / "Hqqbar"
    / "madgraph_check"
    / "python_deps"
    / "six.py"
)
EXPECTED_REUSED_SHA256 = {
    MADGRAPH_PATH: (
        "d51e70db5c95fb72df985760819a0733c9bdb2401de3b27995d53788d2050a74"
    ),
    SIX_PATH: (
        "c51c91f703d3d4b3696c923cb5fec213e05e75d9215393befac7f2fa6a3904df"
    ),
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def atomic_copy(source: Path, destination: Path) -> None:
    temporary = destination.with_name(f"{destination.name}.tmp.{os.getpid()}")
    if destination.exists() or temporary.exists():
        raise FileExistsError(destination)
    try:
        shutil.copyfile(source, temporary)
        os.replace(temporary, destination)
    except Exception:
        if temporary.exists():
            temporary.unlink()
        raise


def atomic_json(path: Path, payload: dict[str, Any]) -> None:
    temporary = path.with_name(f"{path.name}.tmp.{os.getpid()}")
    if path.exists() or temporary.exists():
        raise FileExistsError(path)
    try:
        with temporary.open("x", encoding="utf-8") as stream:
            json.dump(payload, stream, indent=2, sort_keys=True, allow_nan=False)
            stream.write("\n")
        os.replace(temporary, path)
    except Exception:
        if temporary.exists():
            temporary.unlink()
        raise


def main() -> int:
    if OUTPUT_PATH.exists() or COPIES_DIR.exists():
        raise FileExistsError("S01 output or upstream_copies already exists")
    COPIES_DIR.mkdir()

    copied: dict[str, dict[str, int | str]] = {}
    for name, expected_hash in EXPECTED_HQQPRIME_SHA256.items():
        source = CHANNEL_DIR / name
        destination = COPIES_DIR / name
        if not source.is_file():
            raise FileNotFoundError(source)
        observed_hash = sha256_file(source)
        if observed_hash != expected_hash:
            raise RuntimeError(
                f"accepted Hqqprime hash mismatch for {name}: {observed_hash}"
            )
        atomic_copy(source, destination)
        copied_hash = sha256_file(destination)
        if copied_hash != expected_hash:
            raise RuntimeError(f"copy hash mismatch for {name}: {copied_hash}")
        copied[name] = {
            "source_path": str(source),
            "copy_path": str(destination),
            "sha256": copied_hash,
            "bytes": destination.stat().st_size,
        }

    reused: dict[str, dict[str, int | str]] = {}
    for path, expected_hash in EXPECTED_REUSED_SHA256.items():
        if not path.is_file():
            raise FileNotFoundError(path)
        observed_hash = sha256_file(path)
        if observed_hash != expected_hash:
            raise RuntimeError(f"reused dependency hash mismatch for {path}")
        reused[str(path.relative_to(SCRIPTS_DIR))] = {
            "path": str(path),
            "sha256": observed_hash,
            "bytes": path.stat().st_size,
            "mode": "read-only reuse without installation",
        }

    payload: dict[str, Any] = {
        "StageVersion": STAGE_VERSION,
        "Status": "Complete",
        "Program": {
            "Path": str(Path(__file__).resolve()),
            "SHA256": sha256_file(Path(__file__).resolve()),
        },
        "CopiedHqqprimeArtifacts": copied,
        "ReusedDependencies": reused,
        "Channel": {
            "Name": "Hqqprime only",
            "HadronicProcess": "gamma* u -> c(k1) u(k2) cbar(k3)",
            "MadGraphProcess": "e- u -> e- c u c~",
            "FragmentingMomentum": "k1",
            "LocalFinalMomentumOrder": ["c(k1)", "u(k2)", "cbar(k3)"],
            "CurrentRepresentative": "incoming up / prime up type",
            "PhysicalOrderedFlavorAssembly": "deferred",
            "DiagramCount": "derive from copied S01 and measure in S02",
            "GeneratedPDGOrder": "measure after S02",
            "GeneratedIDEN": "derive and measure after S02",
            "FinalStateSymmetryFactor": "derive from current external identities",
        },
        "ComparisonBoundary": (
            "copied pre-angular S06 open tensor and S07 Pg/PPP projections "
            "against a four-dimensional bare-tree MadGraph matrix element"
        ),
        "ExcludedInputs": [
            "S08 phase-space result",
            "S10 endpoint-distribution result",
            "S11 factorization counterterm",
            "S12 finite factorized coefficient",
            "S13 F-hat action",
            "BigTMD benchmark outputs",
        ],
        "Checks": {
            "AllOriginalHashesExact": True,
            "AllCopyHashesExact": True,
            "SixAcceptedArtifactsCopied": len(copied) == 6,
            "MadGraphAndSixReusedWithoutInstallation": len(reused) == 2,
            "DiagramAndIDENValuesNotCopiedFromAnotherChannel": True,
            "ParentArtifactsRemainReadOnly": True,
        },
    }
    if not all(payload["Checks"].values()):
        raise RuntimeError("S01 embedded provenance check failed")
    atomic_json(OUTPUT_PATH, payload)

    print("HQQPRIME_MADGRAPH_S01_SUCCESS")
    print(f"HQQPRIME_MADGRAPH_S01_COPIED_ARTIFACTS={len(copied)}")
    print(f"HQQPRIME_MADGRAPH_S01_REUSED_DEPENDENCIES={len(reused)}")
    print(f"HQQPRIME_MADGRAPH_S01_OUTPUT={OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HQQPRIME_MADGRAPH_S01_FATAL: {error}", flush=True)
        raise
