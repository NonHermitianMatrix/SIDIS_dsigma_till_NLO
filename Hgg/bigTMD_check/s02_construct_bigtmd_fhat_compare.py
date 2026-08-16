#!/usr/bin/env python3
"""Construct BigTMD channel-4 F hats and subtract the local Hgg benchmark."""

from __future__ import annotations

import gc
import importlib.util
import json
import math
import os
from pathlib import Path
import subprocess
import sys
from typing import Any


# BigTMD's generated modules use @jit(cache=True).  Compilation and caches are
# unnecessary for one benchmark, so run their Python expressions directly.
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
ENDPOINT_REGULATOR = 1.0e-7  # BigTMD/sidis.py line 32
FLAVOR_CHARGE_SUM = 10.0 / 9.0
FIELDS = ("Endpoint", "IntegrandPhiS", "IntegrandPhi0")
STRUCTURE_FUNCTIONS = ("F1Hat", "F2Hat")


def load_generated_module(path: Path, unique_name: str) -> Any:
    spec = importlib.util.spec_from_file_location(unique_name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load generated BigTMD module {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    if not callable(getattr(module, "regular", None)):
        raise RuntimeError(f"{path} has no callable regular")
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
    sample = p["S23Sample"]
    current = kinematics(p, sample)

    regular = module.regular(
        1.0, 1.0, current["s"], current["t"], q, sample, q, nf
    )
    phi_s = current["Jacobian"] * finite_real(regular, "regular")

    return {
        "Endpoint": 0.0,
        "IntegrandPhiS": phi_s,
        "IntegrandPhi0": 0.0,
    }


def atomic_json(path: Path, data: dict[str, Any]) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    with temporary.open("w", encoding="utf-8") as stream:
        json.dump(data, stream, indent=2, sort_keys=True, allow_nan=False)
        stream.write("\n")
    os.replace(temporary, path)


def atomic_text(path: Path, text: str) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(text, encoding="utf-8")
    os.replace(temporary, path)


def main() -> int:
    print("BIGTMD_CHECK_S02_STAGE: validating local benchmark and reference")
    local = json.loads(LOCAL_PATH.read_text(encoding="utf-8"))
    if local.get("Status") != "CompleteLocalFHatBenchmark":
        raise RuntimeError("local benchmark JSON is absent or incomplete")
    p = local["Benchmark"]
    conventions = local.get("Conventions", {})
    source = local.get("Source", {})
    if (
        source.get("Status")
        != "CompleteFinitePartonicStructureFunctionsHgg"
        or source.get("StageVersion") != "HggS13-v1"
        or source.get("Channel") != "Hgg only"
    ):
        raise RuntimeError("local benchmark is not bound to validated Hgg S13")
    if (
        conventions.get("BigTMDChannel") != 4
        or conventions.get("BigTMDChargeCases") != ["A"]
        or conventions.get("BigTMDDistributionContent") != "regular only"
    ):
        raise RuntimeError("local benchmark has incompatible BigTMD mapping")
    if not math.isclose(
        float(conventions.get("FlavorChargeSum", math.nan)),
        FLAVOR_CHARGE_SUM,
        rel_tol=0.0,
        abs_tol=1.0e-15,
    ):
        raise RuntimeError("local and BigTMD flavor-charge sums differ")
    local_regulator = float(local["Conventions"]["EndpointRegulator"])
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

    # Load and release one generated module at a time to bound Python memory.
    raw_by_projector: dict[str, dict[str, float]] = {}
    for projector in ("Pg", "Ppp"):
        print(f"BIGTMD_CHECK_S02_MODULE: {projector} fchn4A")
        path = REFERENCE_DIR / "NLO" / projector / "fchn4A.py"
        module = load_generated_module(path, f"bigtmd_{projector}_4A")
        raw_by_projector[projector] = evaluate_module_fields(module, p)
        del module
        gc.collect()

    projectors_by_field: dict[str, dict[str, float]] = {}
    fhat_by_field: dict[str, dict[str, float]] = {}
    cases_by_field: dict[str, dict[str, dict[str, float]]] = {}
    for field in FIELDS:
        totals = {
            "Pg": FLAVOR_CHARGE_SUM * raw_by_projector["Pg"][field],
            "Ppp": FLAVOR_CHARGE_SUM * raw_by_projector["Ppp"][field],
        }
        cases_by_field[field] = {
            "A": {
                "Pg": totals["Pg"],
                "Ppp": totals["Ppp"],
                **fhat_from_projectors(
                    totals["Pg"], totals["Ppp"], p["xHat"], p["Q2"]
                ),
            }
        }
        projectors_by_field[field] = totals
        fhat_by_field[field] = fhat_from_projectors(
            totals["Pg"], totals["Ppp"], p["xHat"], p["Q2"]
        )

    bigtmd_payload: dict[str, Any] = {
        "Status": "CompleteBigTMDFHatBenchmark",
        "Reference": {
            "Repository": "https://github.com/JeffersonLab/BigTMD",
            "Commit": commit,
            "Channel": 4,
            "Process": "A g -> (g->h) q qbar",
            "Projectors": ["Pg", "Ppp"],
            "ChargeCases": ["A"],
            "DistributionContent": "regular only",
        },
        "Benchmark": p,
        "Conventions": {
            "EndpointRegulator": ENDPOINT_REGULATOR,
            "FlavorChargeSum": FLAVOR_CHARGE_SUM,
            "ChargeInterpretation": (
                "sum_f Q_f^2 for active u,d,s,c; BigTMD channel-4 "
                "quark-plus-antiquark luminosity divides by two"
            ),
            "Excluded": "PDFs, FFs, alpha_s running, and leptonic prefactors",
        },
        "ChargeWeightedCasesByField": cases_by_field,
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
        "BigTMDSource": bigtmd_payload["Reference"],
        "ComparisonLevel": local["ComparisonLevel"],
        "DifferencesByField": differences,
        "Rows": rows,
        "Summary": {
            "ComparisonCount": len(rows),
            "MaximumAbsoluteDifference": max_abs,
            "MaximumRelativeDifference": max_rel,
            "AllWithinTolerance": all_close,
            "Tolerance": "abs(diff) <= 1e-8 + 1e-6*max(abs(BigTMD),abs(local))",
        },
    }
    atomic_json(DIFFERENCE_OUTPUT, difference_payload)

    report = [
        "# Hgg BigTMD consistency check",
        "",
        "Signed difference: **BigTMD minus local**.",
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
