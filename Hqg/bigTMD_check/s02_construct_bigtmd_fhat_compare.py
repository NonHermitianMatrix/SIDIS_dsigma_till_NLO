#!/usr/bin/env python3
"""Construct BigTMD channel-3A F hats and subtract local Hqg F hats."""

from __future__ import annotations

import gc
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import subprocess
import sys
from typing import Any


# BigTMD's generated modules use @jit(cache=True). Compilation and cache files
# are unnecessary for one benchmark, so execute their Python expressions.
os.environ["NUMBA_DISABLE_JIT"] = "1"
os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
sys.dont_write_bytecode = True

CHECK_DIR = Path(__file__).resolve().parent
REFERENCE_DIR = CHECK_DIR / "BigTMD_reference"
LOCAL_PATH = CHECK_DIR / "local_fhat_benchmark.json"
BIGTMD_OUTPUT = CHECK_DIR / "bigtmd_fhat_benchmark.json"
DIFFERENCE_OUTPUT = CHECK_DIR / "bigtmd_minus_local.json"
REPORT_OUTPUT = CHECK_DIR / "bigtmd_minus_local.md"

EXPECTED_COMMIT = "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c"
EXPECTED_MODULE_SHA256 = {
    "Pg": "ad094998332145c636303e1694bd69b3414ecce5405afd5031a6c4931aec7329",
    "Ppp": "cc1519c415f0540207c86512581d35af005c1a861d233817163b3cf6f81fe1d9",
}
CHANNEL = 3
CHARGE_CASE = "A"
PARTONIC_MODULE_WEIGHT = 1.0
ENDPOINT_REGULATOR = 1.0e-7  # BigTMD/sidis.py line 32
FIELDS = ("Endpoint", "IntegrandPhiS", "IntegrandPhi0")
STRUCTURE_FUNCTIONS = ("F1Hat", "F2Hat")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def load_generated_module(path: Path, unique_name: str) -> Any:
    spec = importlib.util.spec_from_file_location(unique_name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load generated BigTMD module {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    for name in ("regular", "delta", "plus1B", "plus2B"):
        if not callable(getattr(module, name, None)):
            raise RuntimeError(f"{path} has no callable {name}")
    return module


def finite_real(value: Any, label: str) -> float:
    number = complex(value)
    if abs(number.imag) > 1.0e-10 * max(1.0, abs(number.real)):
        raise RuntimeError(f"{label} is unexpectedly complex: {number!r}")
    answer = float(number.real)
    if not math.isfinite(answer):
        raise RuntimeError(f"{label} is not finite: {answer!r}")
    return answer


def kinematics(parameters: dict[str, float], s23: float) -> dict[str, float]:
    xh = parameters["xHat"]
    z = parameters["zH"]
    q2 = parameters["Q2"]
    qt2 = parameters["qT2"]
    denominator = (1.0 - xh) - xh * s23 / q2
    common = (1.0 - xh) + xh * qt2 / q2
    zhat = denominator / common
    zeta = z / zhat
    jacobian = zeta * xh / q2 / denominator
    return {
        "s": (1.0 - xh) / xh * q2,
        "t": -(1.0 - zhat) * q2 - zhat * qt2,
        "Jacobian": jacobian,
    }


def fhat_from_projectors(
    pg: float, ppp: float, xhat: float, q2: float
) -> dict[str, float]:
    return {
        "F1Hat": -0.5 * pg + 2.0 * xhat**2 / q2 * ppp,
        "F2Hat": -xhat * pg + 12.0 * xhat**3 / q2 * ppp,
    }


def evaluate_module_fields(module: Any, p: dict[str, float]) -> dict[str, float]:
    q = p["Q"]
    nf = float(p["Nf"])
    upper = p["S23UpperB"]
    sample = p["S23Sample"]
    endpoint = kinematics(p, 0.0)
    current = kinematics(p, sample)

    delta = module.delta(
        1.0,
        1.0,
        endpoint["s"],
        endpoint["t"],
        q,
        ENDPOINT_REGULATOR,
        q,
        upper,
        nf,
    )
    endpoint_value = endpoint["Jacobian"] * finite_real(delta, "delta")

    regular = module.regular(
        1.0, 1.0, current["s"], current["t"], q, sample, q, nf
    )
    plus1_running = module.plus1B(
        1.0,
        1.0,
        current["s"],
        current["t"],
        q,
        sample,
        q,
        upper,
        nf,
    )
    plus2_running = module.plus2B(
        1.0,
        1.0,
        current["s"],
        current["t"],
        q,
        sample,
        q,
        upper,
        nf,
    )
    phi_s = current["Jacobian"] * (
        finite_real(regular, "regular")
        + finite_real(plus1_running, "plus1 running") / sample
        + finite_real(plus2_running, "plus2 running")
        * math.log(sample)
        / sample
    )

    plus1_endpoint = module.plus1B(
        1.0,
        1.0,
        endpoint["s"],
        endpoint["t"],
        q,
        ENDPOINT_REGULATOR,
        q,
        upper,
        nf,
    )
    plus2_endpoint = module.plus2B(
        1.0,
        1.0,
        endpoint["s"],
        endpoint["t"],
        q,
        ENDPOINT_REGULATOR,
        q,
        upper,
        nf,
    )
    phi_0 = -endpoint["Jacobian"] * (
        finite_real(plus1_endpoint, "plus1 endpoint")
        + finite_real(plus2_endpoint, "plus2 endpoint") * math.log(sample)
    ) / sample

    return {
        "Endpoint": endpoint_value,
        "IntegrandPhiS": phi_s,
        "IntegrandPhi0": phi_0,
    }


def atomic_json(path: Path, data: dict[str, Any]) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8") as stream:
        json.dump(data, stream, indent=2, sort_keys=True, allow_nan=False)
        stream.write("\n")
    os.replace(temporary, path)


def atomic_text(path: Path, content: str) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(content, encoding="utf-8")
    os.replace(temporary, path)


def main() -> int:
    print("BIGTMD_CHECK_S02_STAGE: validating Hqg benchmark and reference")
    local = json.loads(LOCAL_PATH.read_text(encoding="utf-8"))
    if local.get("Status") != "CompleteLocalFHatBenchmark":
        raise RuntimeError("local benchmark JSON is absent or incomplete")
    if local.get("StageVersion") != "HqgBigTMDCheckS01-v1":
        raise RuntimeError("local benchmark has the wrong S01 stage version")

    source = local["Source"]
    source_path = Path(source["Path"])
    if (
        source.get("Status")
        != "CompleteFinitePartonicStructureFunctionsHqg"
        or source.get("StageVersion") != "HqgS13-v1"
        or source.get("Channel") != "Hqg only"
        or not source_path.is_file()
        or source_path.stat().st_size != int(source["ByteCount"])
        or sha256_file(source_path) != source["SHA256"]
    ):
        raise RuntimeError("local benchmark has a stale Hqg S13 binding")

    conventions = local["Conventions"]
    expected_distribution = "regular, delta, plus1B, and plus2B"
    if (
        int(conventions.get("DirectBornNormalizationFactor", 0)) != 9
        or conventions.get("PhysicalLuminosity")
        != "Sum_q e_q^2 f_q D_g deferred"
        or int(conventions.get("BigTMDChannel", 0)) != CHANNEL
        or conventions.get("BigTMDChargeCases") != [CHARGE_CASE]
        or conventions.get("BigTMDDistributionContent")
        != expected_distribution
        or not math.isclose(
            float(conventions.get("BigTMDPartonicModuleWeight", 0.0)),
            PARTONIC_MODULE_WEIGHT,
            rel_tol=0.0,
            abs_tol=0.0,
        )
    ):
        raise RuntimeError("local Hqg channel/normalization metadata is invalid")

    local_regulator = float(conventions["EndpointRegulator"])
    if not math.isclose(
        local_regulator, ENDPOINT_REGULATOR, rel_tol=0.0, abs_tol=1.0e-18
    ):
        raise RuntimeError("local and BigTMD endpoint regulators differ")

    commit = subprocess.run(
        ["git", "-C", str(REFERENCE_DIR), "rev-parse", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if commit != EXPECTED_COMMIT:
        raise RuntimeError(f"unexpected BigTMD commit {commit}")

    p = local["Benchmark"]
    raw_by_projector: dict[str, dict[str, float]] = {}
    for projector in ("Pg", "Ppp"):
        print(f"BIGTMD_CHECK_S02_MODULE: {projector} fchn3A")
        path = REFERENCE_DIR / "NLO" / projector / "fchn3A.py"
        if sha256_file(path) != EXPECTED_MODULE_SHA256[projector]:
            raise RuntimeError(f"stale BigTMD module {path}")
        module = load_generated_module(path, f"bigtmd_{projector}_3A")
        raw_by_projector[projector] = evaluate_module_fields(module, p)
        del module
        gc.collect()

    projectors_by_field: dict[str, dict[str, float]] = {}
    fhat_by_field: dict[str, dict[str, float]] = {}
    for field in FIELDS:
        weighted = {
            "Pg": PARTONIC_MODULE_WEIGHT * raw_by_projector["Pg"][field],
            "Ppp": PARTONIC_MODULE_WEIGHT * raw_by_projector["Ppp"][field],
        }
        projectors_by_field[field] = weighted
        fhat_by_field[field] = fhat_from_projectors(
            weighted["Pg"], weighted["Ppp"], p["xHat"], p["Q2"]
        )

    bigtmd_payload: dict[str, Any] = {
        "Status": "CompleteBigTMDFHatBenchmark",
        "Reference": {
            "Repository": "https://github.com/JeffersonLab/BigTMD",
            "Commit": commit,
            "Channel": CHANNEL,
            "ChargeCases": [CHARGE_CASE],
            "Projectors": ["Pg", "Ppp"],
            "Modules": {
                "Pg": "NLO/Pg/fchn3A.py",
                "Ppp": "NLO/Ppp/fchn3A.py",
            },
            "ModuleSHA256": EXPECTED_MODULE_SHA256,
        },
        "Benchmark": p,
        "Conventions": {
            "EndpointRegulator": ENDPOINT_REGULATOR,
            "PartonicModuleWeight": PARTONIC_MODULE_WEIGHT,
            "ChargeInterpretation": (
                "unit-charge Hqg hard coefficient; physical "
                "Sum_q e_q^2 f_q D_g is deferred on both sides"
            ),
            "DistributionContent": expected_distribution,
            "Excluded": (
                "PDFs, gluon FF, physical flavor-charge sum, alpha_s "
                "running, xi convolution, and leptonic prefactors"
            ),
        },
        "RawProjectorsByField": raw_by_projector,
        "ProjectorsByField": projectors_by_field,
        "FHatByField": fhat_by_field,
    }
    atomic_json(BIGTMD_OUTPUT, bigtmd_payload)

    rows: list[dict[str, Any]] = []
    differences: dict[str, dict[str, Any]] = {}
    for field in FIELDS:
        differences[field] = {}
        for function in STRUCTURE_FUNCTIONS:
            local_value = finite_real(
                local["LocalFHatByField"][field][function],
                f"local {field} {function}",
            )
            bigtmd_value = finite_real(
                fhat_by_field[field][function],
                f"BigTMD {field} {function}",
            )
            difference = bigtmd_value - local_value
            scale = max(abs(bigtmd_value), abs(local_value), 1.0e-300)
            relative = abs(difference) / scale
            close = abs(difference) <= 1.0e-8 + 1.0e-6 * scale
            item = {
                "Local": local_value,
                "BigTMD": bigtmd_value,
                "BigTMDMinusLocal": difference,
                "AbsoluteDifference": abs(difference),
                "RelativeDifference": relative,
                "NumericallyClose": close,
            }
            differences[field][function] = item
            rows.append({"Field": field, "Function": function, **item})

    max_abs = max(row["AbsoluteDifference"] for row in rows)
    max_rel = max(row["RelativeDifference"] for row in rows)
    all_close = all(row["NumericallyClose"] for row in rows)
    difference_payload: dict[str, Any] = {
        "Status": "CompleteBigTMDMinusLocalBenchmark",
        "DifferenceDirection": "BigTMD minus local",
        "Benchmark": p,
        "LocalSource": source,
        "BigTMDSource": bigtmd_payload["Reference"],
        "ComparisonLevel": local["ComparisonLevel"],
        "DifferencesByField": differences,
        "Rows": rows,
        "Summary": {
            "ComparisonCount": len(rows),
            "MaximumAbsoluteDifference": max_abs,
            "MaximumRelativeDifference": max_rel,
            "AllWithinTolerance": all_close,
            "Tolerance": (
                "abs(diff) <= 1e-8 + "
                "1e-6*max(abs(BigTMD),abs(local))"
            ),
        },
    }
    atomic_json(DIFFERENCE_OUTPUT, difference_payload)

    report = [
        "# Hqg BigTMD consistency check",
        "",
        "Signed difference: **BigTMD minus local**.",
        "",
        "Channel 3, case A, unit-charge partonic hard coefficient; "
        "the physical flavor/PDF/gluon-FF luminosity is excluded.",
        "",
        "| Field | F hat | Local | BigTMD | BigTMD-local | Relative |",
        "|---|---|---:|---:|---:|---:|",
    ]
    for row in rows:
        report.append(
            "| {Field} | {Function} | {Local:.12e} | {BigTMD:.12e} | "
            "{BigTMDMinusLocal:.12e} | {RelativeDifference:.5e} |".format(
                **row
            )
        )
    report.extend(
        [
            "",
            f"Maximum absolute difference: `{max_abs:.12e}`.",
            "",
            f"Maximum relative difference: `{max_rel:.12e}`.",
            "",
            f"All six coefficients within tolerance: `{all_close}`.",
            "",
        ]
    )
    atomic_text(REPORT_OUTPUT, "\n".join(report))

    print(f"BIGTMD_CHECK_S02_ALL_CLOSE={all_close}")
    print(f"BIGTMD_CHECK_S02_MAX_ABS={max_abs:.17g}")
    print(f"BIGTMD_CHECK_S02_MAX_REL={max_rel:.17g}")
    print(f"BIGTMD_CHECK_S02_BIGTMD_OUTPUT={BIGTMD_OUTPUT}")
    print(f"BIGTMD_CHECK_S02_DIFFERENCE_OUTPUT={DIFFERENCE_OUTPUT}")
    print(f"BIGTMD_CHECK_S02_REPORT_OUTPUT={REPORT_OUTPUT}")
    print("BIGTMD_CHECK_S02_SUCCESS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"BIGTMD_CHECK_S02_FATAL: {error}", file=sys.stderr, flush=True)
        raise
