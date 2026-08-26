#!/usr/bin/env python3
"""Prepare byte-identical Hqg inputs for the isolated MadGraph check."""

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

STAGE_VERSION = "HqgMadGraphInputProvenance-v1"
EXPECTED_HQG_SHA256 = {
    "s01_calculate_hqg_lo_nlo.wl": (
        "8e14ab5c5e5c8ea812793cb34b1d48e9edf1e4a133a3200713cf44d4b20800f0"
    ),
    "s01_result": (
        "8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198"
    ),
    "s06_spin_color_sum_average_hqg.wl": (
        "d24ce8bf36d7e64037fbefa7c40cc299a1cff5e639339f03e6ebde17a3e2c8a6"
    ),
    "s06_result": (
        "86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55"
    ),
    "s07_contract_hqg_projectors.wl": (
        "baf695aad89fb8344772bec6c8f6f49c28c18fd842404949fdf74f98d1316e09"
    ),
    "s07_result": (
        "c4b235c611beab30db84b75d2cb36f0e63a433e6a2c08a3b280bded72f18e5b6"
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
    for name, expected_hash in EXPECTED_HQG_SHA256.items():
        source = CHANNEL_DIR / name
        destination = COPIES_DIR / name
        if not source.is_file():
            raise FileNotFoundError(source)
        observed_hash = sha256_file(source)
        if observed_hash != expected_hash:
            raise RuntimeError(f"accepted Hqg hash mismatch for {name}: {observed_hash}")
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
        "CopiedHqgArtifacts": copied,
        "ReusedDependencies": reused,
        "Channel": {
            "Name": "Hqg only",
            "HadronicProcess": "gamma* u -> g(k1) u(k2) g(k3)",
            "MadGraphProcess": "e- u -> e- g u g",
            "FragmentingMomentum": "k1",
            "LocalFinalMomentumOrder": ["g(k1)", "u(k2)", "g(k3)"],
            "CurrentRepresentative": "incoming up",
            "PhysicalFlavorChargeLuminosity": "deferred",
            "DiagramCount": "derive from copied S01 and measure in S02",
            "GeneratedPDGOrder": "measure after S02",
            "GeneratedIDEN": "derive and measure after S02",
            "FinalStateIdentityDivisor": "derive from generated identity metadata",
        },
        "InheritedStateConvention": (
            "copied S06 physical axial sums for both real gluons with reference p"
        ),
        "ComparisonBoundary": (
            "copied pre-angular S06 tensor and S07 Pg/PPP projections against "
            "a four-dimensional bare-tree MadGraph matrix element"
        ),
        "ExcludedInputs": [
            "S08 phase-space result",
            "S09 expanded-real result",
            "S10 virtual/endpoint result",
            "factorization and finite-hard-part stages",
            "BigTMD benchmark outputs",
        ],
        "Checks": {
            "AllOriginalHashesExact": True,
            "AllCopyHashesExact": True,
            "SixAcceptedArtifactsCopied": len(copied) == 6,
            "MadGraphAndSixReusedWithoutInstallation": len(reused) == 2,
            "DiagramAndIdentityValuesNotCopiedFromAnotherChannel": True,
            "ParentArtifactsRemainReadOnly": True,
        },
    }
    if not all(payload["Checks"].values()):
        raise RuntimeError("S01 embedded provenance check failed")
    atomic_json(OUTPUT_PATH, payload)

    print("HQG_MADGRAPH_S01_SUCCESS")
    print(f"HQG_MADGRAPH_S01_COPIED_ARTIFACTS={len(copied)}")
    print(f"HQG_MADGRAPH_S01_REUSED_DEPENDENCIES={len(reused)}")
    print(f"HQG_MADGRAPH_S01_OUTPUT={OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HQG_MADGRAPH_S01_FATAL: {error}", flush=True)
        raise
