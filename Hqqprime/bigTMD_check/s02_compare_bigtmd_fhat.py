#!/usr/bin/env python3
"""Compare accepted Hqqprime S13 F hats with pinned BigTMD channel 6 A/B/C."""

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


# BigTMD's generated files use @jit(cache=True).  Execute the pinned decimal
# Python formulas as written without producing compiler or bytecode caches.
os.environ["NUMBA_DISABLE_JIT"] = "1"
os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
sys.dont_write_bytecode = True

CHECK_DIR = Path(__file__).resolve().parent
CHANNEL_DIR = CHECK_DIR.parent
REFERENCE_DIR = CHECK_DIR / "BigTMD_reference"
LOCAL_PATH = CHECK_DIR / "local_fhat_benchmarks.json"
BIGTMD_OUTPUT = CHECK_DIR / "bigtmd_fhat_benchmarks.json"
DIFFERENCE_OUTPUT = CHECK_DIR / "bigtmd_minus_local.json"
REPORT_OUTPUT = CHECK_DIR / "bigtmd_minus_local.md"

STAGE_VERSION = "HqqprimeBigTMDCheckS02-v1"
EXPECTED_COMMIT = "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c"
EXPECTED_S13_SHA256 = (
    "351f1cbb6995d479cac0087e1cfefb92885c1e1f7dfb362386ba7dfe5c7d4365"
)
EXPECTED_S13_PROGRAM_SHA256 = (
    "80141cec99769c0e32324fffcfc1322b5751554bc5f73172d7801bfa6041789e"
)
EXPECTED_DRIVER_SHA256 = (
    "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d"
)

EXPECTED_CACHE_SHA256 = {
    "F1Hat": {
        "IncomingChargeSquared": (
            "59cbf25b48e596d74b0541a1887f74a4256076002322cb4b110f078e3463adf0"
        ),
        "PrimeChargeSquared": (
            "a755f32e6319c798fd24bdfdd2265b1d7adf88c7e203ca0d6c88995ae27f0d07"
        ),
        "MixedIncomingPrimeCharge": (
            "24caef792f819725d9d607e21d0528a77164a2d64dd04337fcedf493f2ac1682"
        ),
    },
    "F2Hat": {
        "IncomingChargeSquared": (
            "6e07c2d9f20fbca5e038e127c932ba8e0f0c32e6c113ddadb430b22bb7a847d7"
        ),
        "PrimeChargeSquared": (
            "716be770e25f9bec27127c1815c0ee4653b40b46b74c74753c95ef8a95445891"
        ),
        "MixedIncomingPrimeCharge": (
            "babc7fbc0692727e7f57a9d0cfd437ae5ed4cbb1f7e495a30321be4060a08f1d"
        ),
    },
}

EXPECTED_CACHE_PATHS = {
    "F1Hat": {
        "IncomingChargeSquared": str(
            CHANNEL_DIR / "s13_cache_hqqprime_incoming_charge_squared_f1hat"
        ),
        "PrimeChargeSquared": str(
            CHANNEL_DIR / "s13_cache_hqqprime_prime_charge_squared_f1hat"
        ),
        "MixedIncomingPrimeCharge": str(
            CHANNEL_DIR / "s13_cache_hqqprime_mixed_incoming_prime_charge_f1hat"
        ),
    },
    "F2Hat": {
        "IncomingChargeSquared": str(
            CHANNEL_DIR / "s13_cache_hqqprime_incoming_charge_squared_f2hat"
        ),
        "PrimeChargeSquared": str(
            CHANNEL_DIR / "s13_cache_hqqprime_prime_charge_squared_f2hat"
        ),
        "MixedIncomingPrimeCharge": str(
            CHANNEL_DIR / "s13_cache_hqqprime_mixed_incoming_prime_charge_f2hat"
        ),
    },
}

EXPECTED_MODULE_SHA256 = {
    "Pg6A": "502dbfb704a85356d004dcc290604a85cbe6379d664d47e27968aea795e1f3dd",
    "PPP6A": "2a3c88860a52be0946cd824cbb31fbc959d4384706cd9ac790a44f752d54dbd4",
    "Pg6B": "ce3bd5d92a0be6da8559f8c4daf629741dd52277cb0c1166b6b3286484a72fb9",
    "PPP6B": "bd522acf18af68129a125ce69405ab8283d4a7f718d1ee1be6e068cc6ae9e761",
    "Pg6C": "81fe1c6c909148aef8cdfafff86552645a5df68049d088b1ff6a931eafae2326",
    "PPP6C": "48bbba2e8c407665ed98824867a9e0f6429746803aaa8f9f59b8a4ab24ac6245",
}
MODULE_RELATIVE_PATHS = {
    "Pg6A": Path("NLO/Pg/fchn6A.py"),
    "PPP6A": Path("NLO/Ppp/fchn6A.py"),
    "Pg6B": Path("NLO/Pg/fchn6B.py"),
    "PPP6B": Path("NLO/Ppp/fchn6B.py"),
    "Pg6C": Path("NLO/Pg/fchn6C.py"),
    "PPP6C": Path("NLO/Ppp/fchn6C.py"),
}

CHANNEL = 6
CASE_ORDER = ("A", "B", "C")
CASE_TO_CHARGE = {
    "A": "IncomingChargeSquared",
    "B": "MixedIncomingPrimeCharge",
    "C": "PrimeChargeSquared",
}
CHARGE_ORDER = (
    "IncomingChargeSquared",
    "PrimeChargeSquared",
    "MixedIncomingPrimeCharge",
)
PARTONIC_MODULE_WEIGHT = 1.0
FIELDS = ("Endpoint", "IntegrandPhiS", "IntegrandPhi0")
STRUCTURE_FUNCTIONS = ("F1Hat", "F2Hat")
EXPECTED_COMPARISON_COUNT = 18
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
    if not callable(getattr(module, "regular", None)):
        raise RuntimeError(f"{path} has no callable regular function")
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


def evaluate_regular(module: Any, parameters: dict[str, Any], label: str) -> float:
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
        raw, f"BigTMD regular {label}/{parameters['ID']}"
    )


def refuse_existing_outputs() -> None:
    for path in (BIGTMD_OUTPUT, DIFFERENCE_OUTPUT, REPORT_OUTPUT):
        temporary = path.with_suffix(path.suffix + ".tmp")
        if path.exists() or temporary.exists():
            raise RuntimeError(f"refusing to overwrite output or temporary {path}")


def atomic_json(path: Path, data: dict[str, Any]) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    if path.exists() or temporary.exists():
        raise RuntimeError(f"refusing to overwrite {path}")
    try:
        with temporary.open("x", encoding="utf-8") as stream:
            json.dump(data, stream, indent=2, sort_keys=True, allow_nan=False)
            stream.write("\n")
        os.replace(temporary, path)
    except Exception:
        if temporary.exists():
            temporary.unlink()
        raise


def atomic_text(path: Path, content: str) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    if path.exists() or temporary.exists():
        raise RuntimeError(f"refusing to overwrite {path}")
    try:
        with temporary.open("x", encoding="utf-8") as stream:
            stream.write(content)
        os.replace(temporary, path)
    except Exception:
        if temporary.exists():
            temporary.unlink()
        raise


def main() -> int:
    print("HQQPRIME_BIGTMD_S02_STAGE: validating local and reference provenance")
    refuse_existing_outputs()
    local = json.loads(LOCAL_PATH.read_text(encoding="utf-8"))
    if (
        local.get("Status") != "CompleteLocalHqqprimeFHatBenchmarks"
        or local.get("StageVersion") != "HqqprimeBigTMDCheckS01-v1"
    ):
        raise RuntimeError("local Hqqprime S01 benchmark is absent or incomplete")

    source = local["Source"]
    source_path = Path(source["Path"])
    source_program_path = Path(source["ProgramPath"])
    if (
        source.get("Status") != "Complete"
        or source.get("StageVersion") != "HqqprimeS13-v1"
        or source.get("Channel") != "Hqqprime only"
        or source.get("SHA256") != EXPECTED_S13_SHA256
        or source.get("ProgramSHA256") != EXPECTED_S13_PROGRAM_SHA256
        or source.get("CachePaths") != EXPECTED_CACHE_PATHS
        or source.get("CacheSHA256") != EXPECTED_CACHE_SHA256
        or not source_path.is_file()
        or source_path.stat().st_size != int(source["ByteCount"])
        or sha256_file(source_path) != EXPECTED_S13_SHA256
        or not source_program_path.is_file()
        or sha256_file(source_program_path) != EXPECTED_S13_PROGRAM_SHA256
    ):
        raise RuntimeError("local benchmark has a stale accepted S13 binding")

    for structure_function in STRUCTURE_FUNCTIONS:
        for charge_key in CHARGE_ORDER:
            cache_path = Path(EXPECTED_CACHE_PATHS[structure_function][charge_key])
            if (
                not cache_path.is_file()
                or sha256_file(cache_path)
                != EXPECTED_CACHE_SHA256[structure_function][charge_key]
            ):
                raise RuntimeError(f"stale accepted S13 cache {cache_path}")

    s01_program = local["Program"]
    s01_program_path = Path(s01_program["Path"])
    if (
        not s01_program_path.is_file()
        or sha256_file(s01_program_path) != s01_program["SHA256"]
    ):
        raise RuntimeError("local benchmark has a stale S01 program binding")

    conventions = local["Conventions"]
    if (
        conventions.get("PhysicalOrderedFlavorChargeAssembly") != "deferred"
        or int(conventions.get("BigTMDChannel", 0)) != CHANNEL
        or conventions.get("BigTMDCaseOrder") != list(CASE_ORDER)
        or conventions.get("BigTMDCaseToLocalChargeKey") != CASE_TO_CHARGE
        or conventions.get("BigTMDDistributionContent") != "regular only"
        or float(conventions.get("BigTMDPartonicModuleWeight", 0.0))
        != PARTONIC_MODULE_WEIGHT
        or conventions.get("LocalJacobianAlreadyIncluded") is not True
        or float(conventions.get("AdditionalSymmetryOrFlavorFactor", 0.0))
        != 1.0
        or local.get("Construction", {}).get("EndpointAndPhi0ExactZero")
        is not True
        or int(local.get("Construction", {}).get("ExpectedComparisonCount", 0))
        != EXPECTED_COMPARISON_COUNT
    ):
        raise RuntimeError("local benchmark conventions do not match channel 6")

    reference_binding = local["ReferenceBinding"]
    expected_module_paths = {
        key: str(REFERENCE_DIR / relative_path)
        for key, relative_path in MODULE_RELATIVE_PATHS.items()
    }
    if (
        reference_binding.get("Directory") != str(REFERENCE_DIR)
        or reference_binding.get("Commit") != EXPECTED_COMMIT
        or reference_binding.get("DriverPath") != str(REFERENCE_DIR / "sidis.py")
        or reference_binding.get("DriverSHA256") != EXPECTED_DRIVER_SHA256
        or reference_binding.get("ModulePaths") != expected_module_paths
        or reference_binding.get("ModuleSHA256") != EXPECTED_MODULE_SHA256
    ):
        raise RuntimeError("local benchmark has a stale BigTMD reference binding")

    driver_path = REFERENCE_DIR / "sidis.py"
    if not driver_path.is_file() or sha256_file(driver_path) != EXPECTED_DRIVER_SHA256:
        raise RuntimeError("pinned BigTMD sidis.py hash changed")
    driver_text = driver_path.read_text(encoding="utf-8")
    required_driver_fragments = (
        "for chn in [1,2,3,4,6]:",
        "elif chn==6:",
        "if   case=='A':",
        "elif   case=='B':",
        "elif   case=='C':",
        "eq[1:]*eq[1:]*f[1:],d[1:],qqp",
        "eq[1:]*f[1:],eq[1:]*d[1:],qqp",
        "f[1:],eq[1:]*eq[1:]*d[1:],qqp",
        "elif chn==6 and case=='A': _Pg,_Ppp=Pg.fchn6A,Ppp.fchn6A",
        "elif chn==6 and case=='B': _Pg,_Ppp=Pg.fchn6B,Ppp.fchn6B",
        "elif chn==6 and case=='C': _Pg,_Ppp=Pg.fchn6C,Ppp.fchn6C",
        "if part=='regular':",
        "if chn<4:",
    )
    if any(fragment not in driver_text for fragment in required_driver_fragments):
        raise RuntimeError("BigTMD channel-6 routing/distribution convention changed")

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
        if not path.is_file() or sha256_file(path) != EXPECTED_MODULE_SHA256[key]:
            raise RuntimeError(f"stale BigTMD module {path}")
        module_paths[key] = path

    benchmarks = local["Benchmarks"]
    if len(benchmarks) != 3 or len({p["ID"] for p in benchmarks}) != 3:
        raise RuntimeError("local benchmark set does not contain three unique points")
    local_values = local["LocalFHatByBenchmark"]
    if set(local_values) != {p["ID"] for p in benchmarks}:
        raise RuntimeError("local benchmark-value keys do not match benchmark IDs")
    for parameters in benchmarks:
        identifier = parameters["ID"]
        kinematics(parameters)
        if set(local_values[identifier]) != set(CHARGE_ORDER):
            raise RuntimeError(f"local charge coverage changed for {identifier}")
        for charge_key in CHARGE_ORDER:
            fields = local_values[identifier][charge_key]
            if set(fields) != set(FIELDS):
                raise RuntimeError(f"local field coverage changed for {identifier}")
            for structure_function in STRUCTURE_FUNCTIONS:
                if (
                    finite_real(
                        fields["Endpoint"][structure_function],
                        f"local {identifier}/{charge_key} Endpoint/{structure_function}",
                    )
                    != 0.0
                    or finite_real(
                        fields["IntegrandPhi0"][structure_function],
                        f"local {identifier}/{charge_key} IntegrandPhi0/{structure_function}",
                    )
                    != 0.0
                ):
                    raise RuntimeError("local channel-6 endpoint/subtraction is not zero")
                finite_real(
                    fields["IntegrandPhiS"][structure_function],
                    f"local {identifier}/{charge_key}/{structure_function}",
                )

    print("HQQPRIME_BIGTMD_S02_STAGE: evaluating channel-6 A/B/C regular modules")
    projectors_by_benchmark: dict[str, dict[str, dict[str, float]]] = {
        p["ID"]: {case: {} for case in CASE_ORDER} for p in benchmarks
    }
    for case in CASE_ORDER:
        for projector, key_prefix in (("Pg", "Pg"), ("Ppp", "PPP")):
            key = f"{key_prefix}6{case}"
            print(f"HQQPRIME_BIGTMD_S02_MODULE: {projector} fchn6{case} regular")
            module = load_generated_module(module_paths[key], f"hqqprime_{key}")
            for parameters in benchmarks:
                projectors_by_benchmark[parameters["ID"]][case][projector] = (
                    PARTONIC_MODULE_WEIGHT
                    * evaluate_regular(module, parameters, key)
                )
            del module
            gc.collect()

    fhat_by_benchmark: dict[str, dict[str, dict[str, dict[str, float]]]] = {}
    for parameters in benchmarks:
        identifier = parameters["ID"]
        fhat_by_benchmark[identifier] = {}
        for case in CASE_ORDER:
            projectors = projectors_by_benchmark[identifier][case]
            regular_fhats = fhat_from_projectors(
                projectors["Pg"],
                projectors["Ppp"],
                float(parameters["xHat"]),
                float(parameters["Q2"]),
            )
            fhat_by_benchmark[identifier][case] = {
                "Endpoint": {name: 0.0 for name in STRUCTURE_FUNCTIONS},
                "IntegrandPhiS": regular_fhats,
                "IntegrandPhi0": {name: 0.0 for name in STRUCTURE_FUNCTIONS},
            }

    bigtmd_payload: dict[str, Any] = {
        "Status": "CompleteBigTMDHqqprimeFHatBenchmarks",
        "StageVersion": STAGE_VERSION,
        "Program": {
            "Path": str(Path(__file__).resolve()),
            "SHA256": sha256_file(Path(__file__).resolve()),
        },
        "Reference": {
            "Repository": "https://github.com/JeffersonLab/BigTMD",
            "LocalSnapshot": str(REFERENCE_DIR),
            "Commit": commit,
            "Driver": str(driver_path),
            "DriverSHA256": EXPECTED_DRIVER_SHA256,
            "Channel": CHANNEL,
            "Process": "gamma* q -> (qPrime->h) q qbarPrime",
            "ChargeCases": list(CASE_ORDER),
            "CaseToLocalChargeKey": CASE_TO_CHARGE,
            "Projectors": ["Pg", "Ppp"],
            "ModulePaths": {key: str(path) for key, path in module_paths.items()},
            "ModuleSHA256": EXPECTED_MODULE_SHA256,
        },
        "Conventions": {
            "DistributionContent": "channel-6 A/B/C regular only",
            "DriverCaveat": (
                "sidis.py includes channel 6 in its active loop and applies "
                "delta/plus only for channels below 4"
            ),
            "FunctionsNotSelected": ["delta", "plus1B", "plus2B"],
            "PartonicModuleWeight": PARTONIC_MODULE_WEIGHT,
            "Couplings": "BigTMD generated module arguments g=gp=1",
            "Scale": "mu=Q",
            "Nf": 4,
            "Jacobian": "BigTMD sidis.py zeta-to-s23 Jacobian applied",
            "PhysicalOrderedFlavorChargeAssembly": "deferred",
            "Excluded": (
                "PDFs, fragmentation functions, physical ordered-flavour/charge "
                "luminosity, alpha_s running, remaining zh/(xi zeta) driver "
                "test factor, xi convolution, and leptonic prefactors"
            ),
            "DecimalPolicy": "pinned Python decimal expressions executed as written",
        },
        "Benchmarks": benchmarks,
        "ProjectorsByBenchmarkAndCase": projectors_by_benchmark,
        "FHatByBenchmarkAndCase": fhat_by_benchmark,
    }

    rows: list[dict[str, Any]] = []
    differences_by_benchmark: dict[str, dict[str, dict[str, Any]]] = {}
    for parameters in benchmarks:
        identifier = parameters["ID"]
        differences_by_benchmark[identifier] = {}
        for case in CASE_ORDER:
            charge_key = CASE_TO_CHARGE[case]
            differences_by_benchmark[identifier][case] = {}
            for structure_function in STRUCTURE_FUNCTIONS:
                local_value = finite_real(
                    local_values[identifier][charge_key]["IntegrandPhiS"][
                        structure_function
                    ],
                    f"local {identifier}/{charge_key}/{structure_function}",
                )
                bigtmd_value = finite_real(
                    fhat_by_benchmark[identifier][case]["IntegrandPhiS"][
                        structure_function
                    ],
                    f"BigTMD {identifier}/{case}/{structure_function}",
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
                differences_by_benchmark[identifier][case][structure_function] = item
                rows.append(
                    {
                        "Benchmark": identifier,
                        "Case": case,
                        "ChargeKey": charge_key,
                        "Field": "IntegrandPhiS",
                        "Function": structure_function,
                        **item,
                    }
                )

    if (
        len(rows) != EXPECTED_COMPARISON_COUNT
        or len(
            {
                (row["Benchmark"], row["Case"], row["Function"])
                for row in rows
            }
        )
        != EXPECTED_COMPARISON_COUNT
    ):
        raise RuntimeError("comparison coverage is incomplete or duplicated")

    structural_zero_agreement = all(
        local_values[p["ID"]][CASE_TO_CHARGE[case]][field][name] == 0
        and fhat_by_benchmark[p["ID"]][case][field][name] == 0.0
        for p in benchmarks
        for case in CASE_ORDER
        for field in ("Endpoint", "IntegrandPhi0")
        for name in STRUCTURE_FUNCTIONS
    )
    max_abs = max(row["AbsoluteDifference"] for row in rows)
    max_rel = max(row["RelativeDifference"] for row in rows)
    all_regular_close = all(row["NumericallyClose"] for row in rows)
    all_close = all_regular_close and structural_zero_agreement

    difference_payload: dict[str, Any] = {
        "Status": "CompleteHqqprimeBigTMDMinusLocalComparison",
        "StageVersion": STAGE_VERSION,
        "DifferenceDirection": "BigTMD minus local",
        "LocalSource": source,
        "BigTMDSource": bigtmd_payload["Reference"],
        "ComparisonLevel": local["ComparisonLevel"],
        "CaseToLocalChargeKey": CASE_TO_CHARGE,
        "Benchmarks": benchmarks,
        "DifferencesByBenchmarkAndCase": differences_by_benchmark,
        "Rows": rows,
        "StructuralChecks": {
            "LocalEndpointAndPhi0ExactZero": True,
            "BigTMDEndpointAndPhi0ZeroUnderDriverSelection": True,
            "EndpointAndPhi0Agreement": structural_zero_agreement,
            "Channel6ActiveInDriver": True,
            "DeltaAndPlusExcludedByDriverForChannel6": True,
            "AllThreeChargeCasesKeptSeparate": True,
            "NoPhysicalChargeOrFlavorAssembly": True,
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

    report = [
        "# Hqqprime BigTMD channel-6 A/B/C consistency check",
        "",
        "Signed difference: **BigTMD minus local**.",
        "",
        (
            "The comparison keeps channel-6 charge cases A, B, and C separate "
            "and selects only their regular coefficients. The pinned driver "
            "includes channel 6 in its active loop and restricts delta/plus "
            "assembly to channels below 4."
        ),
        "",
        "| Benchmark | Case | Local charge key | F hat | Local | BigTMD | BigTMD-local | Relative | Close |",
        "|---|:---:|---|---|---:|---:|---:|---:|:---:|",
    ]
    for row in rows:
        report.append(
            "| {Benchmark} | {Case} | {ChargeKey} | {Function} | "
            "{Local:.12e} | {BigTMD:.12e} | {BigTMDMinusLocal:.12e} | "
            "{RelativeDifference:.5e} | {NumericallyClose} |".format(**row)
        )
    report.extend(
        [
            "",
            (
                "Endpoint and phi-zero fields are exactly zero locally and "
                f"zero under the channel-6 driver selection: `{structural_zero_agreement}`."
            ),
            "",
            f"Maximum absolute difference: `{max_abs:.12e}`.",
            "",
            f"Maximum relative difference: `{max_rel:.12e}`.",
            "",
            (
                "All 18 nontrivial regular coefficients within tolerance: "
                f"`{all_regular_close}`."
            ),
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
                "local expressions remained exact until final benchmark evaluation."
            ),
            "",
        ]
    )

    atomic_json(BIGTMD_OUTPUT, bigtmd_payload)
    atomic_json(DIFFERENCE_OUTPUT, difference_payload)
    atomic_text(REPORT_OUTPUT, "\n".join(report))

    print(f"HQQPRIME_BIGTMD_S02_ALL_CLOSE={all_close}")
    print(f"HQQPRIME_BIGTMD_S02_COMPARISON_COUNT={len(rows)}")
    print(f"HQQPRIME_BIGTMD_S02_MAX_ABS={max_abs:.17g}")
    print(f"HQQPRIME_BIGTMD_S02_MAX_REL={max_rel:.17g}")
    print(f"HQQPRIME_BIGTMD_S02_BIGTMD_OUTPUT={BIGTMD_OUTPUT}")
    print(f"HQQPRIME_BIGTMD_S02_DIFFERENCE_OUTPUT={DIFFERENCE_OUTPUT}")
    print(f"HQQPRIME_BIGTMD_S02_REPORT_OUTPUT={REPORT_OUTPUT}")
    print("HQQPRIME_BIGTMD_S02_SUCCESS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HQQPRIME_BIGTMD_S02_FATAL: {error}", file=sys.stderr, flush=True)
        raise
