#!/usr/bin/env python3
"""Compare accepted Hqqbar S13 F hats with pinned BigTMD channel 5A."""

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


# BigTMD's generated files use @jit(cache=True).  The check must execute the
# decimal Python formulas as written but does not need compilation or caches.
os.environ["NUMBA_DISABLE_JIT"] = "1"
os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
sys.dont_write_bytecode = True

CHECK_DIR = Path(__file__).resolve().parent
CHANNEL_DIR = CHECK_DIR.parent
SCRIPTS_DIR = CHANNEL_DIR.parent
REFERENCE_DIR = (
    SCRIPTS_DIR / "Hqq" / "bigTMD_check" / "BigTMD_reference"
)
LOCAL_PATH = CHECK_DIR / "local_fhat_benchmarks.json"
BIGTMD_OUTPUT = CHECK_DIR / "bigtmd_fhat_benchmarks.json"
DIFFERENCE_OUTPUT = CHECK_DIR / "bigtmd_minus_local.json"
REPORT_OUTPUT = CHECK_DIR / "bigtmd_minus_local.md"

STAGE_VERSION = "HqqbarBigTMDCheckS02-v1"
EXPECTED_COMMIT = "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c"
EXPECTED_S13_SHA256 = (
    "4224b46a064087ed3b20e36a049dd1929019f66583263fcb2c28c9b69614c64f"
)
EXPECTED_S13_PROGRAM_SHA256 = (
    "760cad942ee628c0e3de3b76362cbbb103bf6c8d9c920983b84f717b5adf1f13"
)
EXPECTED_DRIVER_SHA256 = (
    "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d"
)
EXPECTED_MODULE_SHA256 = {
    "Pg5A": "9314f660d6ba9e37c203cf010da2f9aee84e993958e5dd3ad7896fb33ac5b48b",
    "PPP5A": "5c275d8ee0e01fa23e47e3ddef6d84150babc71ef01e391d75e3ed9f12f09a5e",
    "Pg5B": "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
    "PPP5B": "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
    "Pg5C": "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
    "PPP5C": "d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b",
}
MODULE_RELATIVE_PATHS = {
    "Pg5A": Path("NLO/Pg/fchn5A.py"),
    "PPP5A": Path("NLO/Ppp/fchn5A.py"),
    "Pg5B": Path("NLO/Pg/fchn5B.py"),
    "PPP5B": Path("NLO/Ppp/fchn5B.py"),
    "Pg5C": Path("NLO/Pg/fchn5C.py"),
    "PPP5C": Path("NLO/Ppp/fchn5C.py"),
}

CHANNEL = 5
CHARGE_CASE = "A"
PARTONIC_MODULE_WEIGHT = 1.0
FIELDS = ("Endpoint", "IntegrandPhiS", "IntegrandPhi0")
STRUCTURE_FUNCTIONS = ("F1Hat", "F2Hat")
ABSOLUTE_TOLERANCE = 1.0e-10
RELATIVE_TOLERANCE = 1.0e-7


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
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


def kinematics(parameters: dict[str, Any]) -> dict[str, float]:
    xhat = float(parameters["xHat"])
    z = float(parameters["zH"])
    q2 = float(parameters["Q2"])
    qt2 = float(parameters["qT2"])
    s23 = float(parameters["S23Sample"])
    denominator = (1.0 - xhat) - xhat * s23 / q2
    common = (1.0 - xhat) + xhat * qt2 / q2
    zhat = denominator / common
    zeta = z / zhat
    jacobian = zeta * xhat / q2 / denominator
    result = {
        "s": (1.0 - xhat) / xhat * q2,
        "t": -(1.0 - zhat) * q2 - zhat * qt2,
        "zHat": zhat,
        "zeta": zeta,
        "Jacobian": jacobian,
    }
    for key, expected in (
        ("s", parameters["s"]),
        ("t", parameters["t"]),
        ("zHat", parameters["zHat"]),
        ("zeta", parameters["zeta"]),
        ("Jacobian", parameters["Jacobian"]),
    ):
        if not math.isclose(
            result[key], float(expected), rel_tol=2.0e-14, abs_tol=2.0e-14
        ):
            raise RuntimeError(
                f"BigTMD kinematic map differs for {parameters['ID']} {key}"
            )
    if not (
        0.0 < xhat < 1.0
        and 0.0 < s23 < float(parameters["S23UpperB"])
        and 0.0 < zhat < 1.0
        and 0.0 < zeta < 1.0
        and jacobian > 0.0
    ):
        raise RuntimeError(f"unphysical benchmark {parameters['ID']}")
    return result


def fhat_from_projectors(
    pg: float, ppp: float, xhat: float, q2: float
) -> dict[str, float]:
    return {
        "F1Hat": -0.5 * pg + 2.0 * xhat**2 / q2 * ppp,
        "F2Hat": -xhat * pg + 12.0 * xhat**3 / q2 * ppp,
    }


def evaluate_regular(module: Any, parameters: dict[str, Any]) -> float:
    current = kinematics(parameters)
    raw = module.regular(
        1.0,
        1.0,
        current["s"],
        current["t"],
        float(parameters["Q"]),
        float(parameters["S23Sample"]),
        float(parameters["Q"]),
        float(parameters["Nf"]),
    )
    return current["Jacobian"] * finite_real(
        raw, f"BigTMD regular {parameters['ID']}"
    )


def validate_zero_module(
    module: Any, parameters: dict[str, Any], label: str
) -> None:
    current = kinematics(parameters)
    common = (
        1.0,
        1.0,
        current["s"],
        current["t"],
        float(parameters["Q"]),
    )
    s23 = float(parameters["S23Sample"])
    mu = float(parameters["Q"])
    nf = float(parameters["Nf"])
    upper = float(parameters["S23UpperB"])
    values = {
        "regular": module.regular(*common, s23, mu, nf),
        "delta": module.delta(*common, s23, mu, upper, nf),
        "plus1B": module.plus1B(*common, s23, mu, upper, nf),
        "plus2B": module.plus2B(*common, s23, mu, upper, nf),
    }
    for function_name, value in values.items():
        if finite_real(value, f"{label} {function_name}") != 0.0:
            raise RuntimeError(f"{label} {function_name} is not exact zero")


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
    print("HQQBAR_BIGTMD_S02_STAGE: validating local and reference provenance")
    local = json.loads(LOCAL_PATH.read_text(encoding="utf-8"))
    if (
        local.get("Status") != "CompleteLocalHqqbarFHatBenchmarks"
        or local.get("StageVersion") != "HqqbarBigTMDCheckS01-v1"
    ):
        raise RuntimeError("local Hqqbar S01 benchmark is absent or incomplete")

    source = local["Source"]
    source_path = Path(source["Path"])
    source_program_path = Path(source["ProgramPath"])
    if (
        source.get("Status")
        != "CompleteFinitePartonicStructureFunctionsHqqbar"
        or source.get("StageVersion") != "HqqbarS13-v1"
        or source.get("Channel") != "Hqqbar only"
        or source.get("SHA256") != EXPECTED_S13_SHA256
        or source.get("ProgramSHA256") != EXPECTED_S13_PROGRAM_SHA256
        or not source_path.is_file()
        or source_path.stat().st_size != int(source["ByteCount"])
        or sha256_file(source_path) != EXPECTED_S13_SHA256
        or not source_program_path.is_file()
        or sha256_file(source_program_path) != EXPECTED_S13_PROGRAM_SHA256
    ):
        raise RuntimeError("local benchmark has a stale accepted S13 binding")

    s01_program = local["Program"]
    s01_program_path = Path(s01_program["Path"])
    if (
        not s01_program_path.is_file()
        or sha256_file(s01_program_path) != s01_program["SHA256"]
    ):
        raise RuntimeError("local benchmark has a stale S01 program binding")

    conventions = local["Conventions"]
    if (
        conventions.get("PhysicalLuminosity")
        != "Sum_q e_q^2 f_q D_qbar deferred"
        or int(conventions.get("BigTMDChannel", 0)) != CHANNEL
        or conventions.get("BigTMDChargeCases") != [CHARGE_CASE]
        or conventions.get("BigTMDDistributionContent") != "regular only"
        or float(conventions.get("BigTMDPartonicModuleWeight", 0.0))
        != PARTONIC_MODULE_WEIGHT
        or conventions.get("LocalJacobianAlreadyIncluded") is not True
        or float(conventions.get("AdditionalSymmetryFactor", 0.0)) != 1.0
    ):
        raise RuntimeError("local benchmark conventions do not match channel 5A")

    driver_path = REFERENCE_DIR / "sidis.py"
    if sha256_file(driver_path) != EXPECTED_DRIVER_SHA256:
        raise RuntimeError("pinned BigTMD sidis.py hash changed")
    driver_text = driver_path.read_text(encoding="utf-8")
    if (
        "for chn in [1,2,3,4,6]:" not in driver_text
        or "if chn<4:" not in driver_text
    ):
        raise RuntimeError("BigTMD channel-loop/distribution caveat changed")

    commit = subprocess.run(
        ["git", "-C", str(REFERENCE_DIR), "rev-parse", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if commit != EXPECTED_COMMIT:
        raise RuntimeError(f"unexpected BigTMD commit {commit}")

    module_paths: dict[str, Path] = {}
    for key, relative_path in MODULE_RELATIVE_PATHS.items():
        path = REFERENCE_DIR / relative_path
        if sha256_file(path) != EXPECTED_MODULE_SHA256[key]:
            raise RuntimeError(f"stale BigTMD module {path}")
        module_paths[key] = path

    benchmarks = local["Benchmarks"]
    if len(benchmarks) != 3 or len({p["ID"] for p in benchmarks}) != 3:
        raise RuntimeError("local benchmark set does not contain three unique points")
    local_values = local["LocalFHatByBenchmark"]
    for parameters in benchmarks:
        identifier = parameters["ID"]
        kinematics(parameters)
        fields = local_values[identifier]
        for structure_function in STRUCTURE_FUNCTIONS:
            if (
                finite_real(
                    fields["Endpoint"][structure_function],
                    f"local {identifier} Endpoint {structure_function}",
                )
                != 0.0
                or finite_real(
                    fields["IntegrandPhi0"][structure_function],
                    f"local {identifier} IntegrandPhi0 {structure_function}",
                )
                != 0.0
            ):
                raise RuntimeError("local channel-5 endpoint/subtraction is not zero")

    print("HQQBAR_BIGTMD_S02_STAGE: validating exact-zero B/C modules")
    zero_modules_validated: list[str] = []
    for key in ("Pg5B", "PPP5B", "Pg5C", "PPP5C"):
        module = load_generated_module(module_paths[key], f"hqqbar_{key}")
        validate_zero_module(module, benchmarks[0], key)
        zero_modules_validated.append(key)
        del module
        gc.collect()

    print("HQQBAR_BIGTMD_S02_STAGE: evaluating decimal channel-5A regular modules")
    raw_projectors_by_benchmark: dict[str, dict[str, float]] = {
        p["ID"]: {} for p in benchmarks
    }
    for projector, key in (("Pg", "Pg5A"), ("Ppp", "PPP5A")):
        print(f"HQQBAR_BIGTMD_S02_MODULE: {projector} fchn5A regular")
        module = load_generated_module(module_paths[key], f"hqqbar_{key}")
        for parameters in benchmarks:
            raw_projectors_by_benchmark[parameters["ID"]][projector] = (
                PARTONIC_MODULE_WEIGHT * evaluate_regular(module, parameters)
            )
        del module
        gc.collect()

    fhat_by_benchmark: dict[str, dict[str, dict[str, float]]] = {}
    for parameters in benchmarks:
        identifier = parameters["ID"]
        projectors = raw_projectors_by_benchmark[identifier]
        regular_fhats = fhat_from_projectors(
            projectors["Pg"],
            projectors["Ppp"],
            float(parameters["xHat"]),
            float(parameters["Q2"]),
        )
        fhat_by_benchmark[identifier] = {
            "Endpoint": {name: 0.0 for name in STRUCTURE_FUNCTIONS},
            "IntegrandPhiS": regular_fhats,
            "IntegrandPhi0": {name: 0.0 for name in STRUCTURE_FUNCTIONS},
        }

    bigtmd_payload: dict[str, Any] = {
        "Status": "CompleteBigTMDHqqbarFHatBenchmarks",
        "StageVersion": STAGE_VERSION,
        "Program": {
            "Path": str(Path(__file__).resolve()),
            "SHA256": sha256_file(Path(__file__).resolve()),
        },
        "Reference": {
            "Repository": "https://github.com/JeffersonLab/BigTMD",
            "Commit": commit,
            "Driver": str(driver_path),
            "DriverSHA256": EXPECTED_DRIVER_SHA256,
            "Channel": CHANNEL,
            "Process": "gamma* q -> (qbar->h) q q",
            "ChargeCases": [CHARGE_CASE],
            "Projectors": ["Pg", "Ppp"],
            "ModulePaths": {
                key: str(path) for key, path in module_paths.items()
            },
            "ModuleSHA256": EXPECTED_MODULE_SHA256,
            "ZeroModulesValidated": zero_modules_validated,
        },
        "Conventions": {
            "DistributionContent": "channel-5A regular only",
            "DriverCaveat": (
                "sidis.py omits channel 5 from its active loop and applies "
                "delta/plus only for channels below 4"
            ),
            "AFunctionsNotSelected": ["delta", "plus1B", "plus2B"],
            "PartonicModuleWeight": PARTONIC_MODULE_WEIGHT,
            "Couplings": "BigTMD generated module arguments g=gp=1",
            "Scale": "mu=Q",
            "Jacobian": "BigTMD sidis.py zeta-to-s23 Jacobian applied",
            "PhysicalLuminosity": "Sum_q e_q^2 f_q D_qbar deferred",
            "Excluded": (
                "PDFs, antiquark FF, physical flavor-charge sum, alpha_s "
                "running, remaining zh/(xi zeta) test-function weight, xi "
                "convolution, and leptonic prefactors"
            ),
            "DecimalPolicy": "pinned Python decimal expressions executed as written",
        },
        "Benchmarks": benchmarks,
        "ProjectorsByBenchmark": raw_projectors_by_benchmark,
        "FHatByBenchmark": fhat_by_benchmark,
    }
    atomic_json(BIGTMD_OUTPUT, bigtmd_payload)

    rows: list[dict[str, Any]] = []
    differences_by_benchmark: dict[str, dict[str, Any]] = {}
    for parameters in benchmarks:
        identifier = parameters["ID"]
        differences_by_benchmark[identifier] = {}
        for structure_function in STRUCTURE_FUNCTIONS:
            local_value = finite_real(
                local_values[identifier]["IntegrandPhiS"][structure_function],
                f"local {identifier} {structure_function}",
            )
            bigtmd_value = finite_real(
                fhat_by_benchmark[identifier]["IntegrandPhiS"][
                    structure_function
                ],
                f"BigTMD {identifier} {structure_function}",
            )
            difference = bigtmd_value - local_value
            scale = max(abs(bigtmd_value), abs(local_value))
            relative = abs(difference) / scale if scale > 0.0 else 0.0
            tolerance = ABSOLUTE_TOLERANCE + RELATIVE_TOLERANCE * scale
            close = abs(difference) <= tolerance
            ratio = bigtmd_value / local_value if local_value != 0.0 else None
            item = {
                "Local": local_value,
                "BigTMD": bigtmd_value,
                "BigTMDMinusLocal": difference,
                "AbsoluteDifference": abs(difference),
                "RelativeDifference": relative,
                "BigTMDDividedByLocal": ratio,
                "ToleranceAtPoint": tolerance,
                "NumericallyClose": close,
            }
            differences_by_benchmark[identifier][structure_function] = item
            rows.append(
                {
                    "Benchmark": identifier,
                    "Field": "IntegrandPhiS",
                    "Function": structure_function,
                    **item,
                }
            )

    structural_zero_agreement = all(
        local_values[p["ID"]][field][name] == 0
        and fhat_by_benchmark[p["ID"]][field][name] == 0.0
        for p in benchmarks
        for field in ("Endpoint", "IntegrandPhi0")
        for name in STRUCTURE_FUNCTIONS
    )
    max_abs = max(row["AbsoluteDifference"] for row in rows)
    max_rel = max(row["RelativeDifference"] for row in rows)
    all_regular_close = all(row["NumericallyClose"] for row in rows)
    all_close = all_regular_close and structural_zero_agreement

    difference_payload: dict[str, Any] = {
        "Status": "CompleteHqqbarBigTMDMinusLocalComparison",
        "StageVersion": STAGE_VERSION,
        "DifferenceDirection": "BigTMD minus local",
        "LocalSource": source,
        "BigTMDSource": bigtmd_payload["Reference"],
        "ComparisonLevel": local["ComparisonLevel"],
        "Benchmarks": benchmarks,
        "DifferencesByBenchmark": differences_by_benchmark,
        "Rows": rows,
        "StructuralChecks": {
            "LocalEndpointAndPhi0ExactZero": True,
            "BigTMDEndpointAndPhi0ZeroUnderDriverSelection": True,
            "EndpointAndPhi0Agreement": structural_zero_agreement,
            "BCasesExactZero": True,
            "OnlyChannel5ARegularSelected": True,
        },
        "Summary": {
            "NontrivialComparisonCount": len(rows),
            "MaximumAbsoluteDifference": max_abs,
            "MaximumRelativeDifference": max_rel,
            "AllRegularCoefficientsWithinTolerance": all_regular_close,
            "AllTestedCoefficientsWithinTolerance": all_close,
            "AbsoluteTolerance": ABSOLUTE_TOLERANCE,
            "RelativeTolerance": RELATIVE_TOLERANCE,
            "ToleranceRule": (
                "abs(diff) <= 1e-10 + "
                "1e-7*max(abs(BigTMD),abs(local))"
            ),
        },
    }
    atomic_json(DIFFERENCE_OUTPUT, difference_payload)

    report = [
        "# Hqqbar BigTMD channel-5A consistency check",
        "",
        "Signed difference: **BigTMD minus local**.",
        "",
        (
            "The comparison is charge-stripped, case A, and regular-only. "
            "The pinned driver excludes channel 5 from its active loop and "
            "applies delta/plus terms only for channels below 4."
        ),
        "",
        "| Benchmark | F hat | Local | BigTMD | BigTMD-local | Relative | Close |",
        "|---|---|---:|---:|---:|---:|:---:|",
    ]
    for row in rows:
        report.append(
            "| {Benchmark} | {Function} | {Local:.12e} | "
            "{BigTMD:.12e} | {BigTMDMinusLocal:.12e} | "
            "{RelativeDifference:.5e} | {NumericallyClose} |".format(**row)
        )
    report.extend(
        [
            "",
            (
                "Endpoint and subtraction fields are exactly zero locally "
                f"and zero under the driver selection: `{structural_zero_agreement}`."
            ),
            "",
            "All channel-5 B/C generated functions are exact zero: `True`.",
            "",
            f"Maximum absolute difference: `{max_abs:.12e}`.",
            "",
            f"Maximum relative difference: `{max_rel:.12e}`.",
            "",
            f"All six nontrivial regular coefficients within tolerance: `{all_regular_close}`.",
            "",
            f"Overall tested agreement: `{all_close}`.",
            "",
            (
                "Tolerance: `abs(diff) <= 1e-10 + "
                "1e-7*max(abs(BigTMD),abs(local))`."
            ),
            "",
            (
                "BigTMD decimal coefficients were executed as written; the "
                "local inputs remained exact until final benchmark evaluation."
            ),
            "",
        ]
    )
    atomic_text(REPORT_OUTPUT, "\n".join(report))

    print(f"HQQBAR_BIGTMD_S02_ALL_CLOSE={all_close}")
    print(f"HQQBAR_BIGTMD_S02_MAX_ABS={max_abs:.17g}")
    print(f"HQQBAR_BIGTMD_S02_MAX_REL={max_rel:.17g}")
    print(f"HQQBAR_BIGTMD_S02_BIGTMD_OUTPUT={BIGTMD_OUTPUT}")
    print(f"HQQBAR_BIGTMD_S02_DIFFERENCE_OUTPUT={DIFFERENCE_OUTPUT}")
    print(f"HQQBAR_BIGTMD_S02_REPORT_OUTPUT={REPORT_OUTPUT}")
    print("HQQBAR_BIGTMD_S02_SUCCESS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HQQBAR_BIGTMD_S02_FATAL: {error}", file=sys.stderr, flush=True)
        raise
