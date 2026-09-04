#!/usr/bin/env python3
"""Compare accepted Hqq_v2 hats with pinned BigTMD channel 2 A/B/C."""

from __future__ import annotations

import ast
import gc
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import subprocess
import sys
from typing import Any, Callable

import numpy as np


os.environ["NUMBA_DISABLE_JIT"] = "1"
os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
sys.dont_write_bytecode = True

CHECK_DIR = Path(__file__).resolve().parent
CHANNEL_DIR = CHECK_DIR.parent
SCRIPTS_DIR = CHANNEL_DIR.parent
REFERENCE_DIR = SCRIPTS_DIR / "Hqqprime" / "bigTMD_check" / "BigTMD_reference"
LOCAL_PATH = CHECK_DIR / "local_fhat_benchmarks.json"
BIGTMD_OUTPUT = CHECK_DIR / "bigtmd_fhat_benchmarks.json"
DIFFERENCE_OUTPUT = CHECK_DIR / "bigtmd_minus_local.json"
REPORT_OUTPUT = CHECK_DIR / "bigtmd_minus_local.md"

STAGE_VERSION = "HqqV2BigTMDCheckS02-v1"
EXPECTED_COMMIT = "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c"
EXPECTED_S08_SHA256 = (
    "0b69a0db7740127ab16c53d181317b7defbd17af846e55582213ca28d1d35741"
)
EXPECTED_S08_PROGRAM_SHA256 = (
    "f426373c24143950cb8cdb09a6410e7ec76e0d4f960293f6380021cf54c211b7"
)
EXPECTED_HAT_SHA256 = {
    "F1Hat": "24010c0ba80c1da601d39fcad6684a986024773cd84beafcbc09e956d6da4823",
    "F2Hat": "54aa977540c56796b7c5b03aead322022788455caa110b9fe285373fec139b36",
}
EXPECTED_DRIVER_SHA256 = (
    "150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d"
)
EXPECTED_MODULE_SHA256 = {
    "Pg2A": "9d24bb4b02ef7b69b125059b7b8fe4ba993c4fb1d3c3972dd826f221d3e64c23",
    "PPP2A": "f1a04d5fb041b174e61f82e5290dc81a01c1583c741a754de8a76d17e0d75e72",
    "Pg2B": "48d5e92a0b33abee65d000327d4bc1c6edb30dab97b396d237541e53291f07b3",
    "PPP2B": "59746b925caa9e016f7548836c443aa158a5521d32a9df4d9e22b3f8d5ffe586",
    "Pg2C": "c5da8f58bad64c6738b88f7d8acb0872bdbc5153444a1c7fc489af53872fd3c2",
    "PPP2C": "38cf2594a02e35ee51d7d5c83e94167d24cf65fbc864aac6df8fa4742a71050e",
}
MODULE_RELATIVE_PATHS = {
    "Pg2A": Path("NLO/Pg/fchn2A.py"),
    "PPP2A": Path("NLO/Ppp/fchn2A.py"),
    "Pg2B": Path("NLO/Pg/fchn2B.py"),
    "PPP2B": Path("NLO/Ppp/fchn2B.py"),
    "Pg2C": Path("NLO/Pg/fchn2C.py"),
    "PPP2C": Path("NLO/Ppp/fchn2C.py"),
}

CHANNEL = 2
CASE_ORDER = ("A", "B", "C")
PROJECTORS = ("Pg", "Ppp")
OBSERVABLES = ("Delta", "Plus0", "Plus1", "Ordinary")
STRUCTURE_FUNCTIONS = ("F1Hat", "F2Hat")
EXPECTED_COMPARISON_COUNT = 24
ABSOLUTE_TOLERANCE = 1.0e-10
RELATIVE_TOLERANCE = 1.0e-7


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def finite_real(value: Any, label: str) -> float:
    number = complex(value)
    if abs(number.imag) > 1.0e-10 * max(1.0, abs(number.real)):
        raise RuntimeError(f"{label} is unexpectedly complex: {number!r}")
    answer = float(number.real)
    if not math.isfinite(answer):
        raise RuntimeError(f"{label} is not finite: {answer!r}")
    return answer


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


def driver_luminosity_function(
    driver_path: Path,
) -> tuple[Callable[..., Any], np.ndarray, float]:
    """Execute only the pinned driver's endpoint and luminosity definitions."""
    tree = ast.parse(driver_path.read_text(encoding="utf-8"), filename=str(driver_path))
    selected: list[ast.stmt] = []
    accepted_assignments = {"zero", "eU", "eD", "eq3", "eq4", "eq5", "qqp"}
    for node in tree.body:
        if isinstance(node, ast.Assign):
            targets = {
                target.id
                for target in node.targets
                if isinstance(target, ast.Name)
            }
            if targets & accepted_assignments:
                selected.append(node)
        elif isinstance(node, ast.For):
            if any(
                isinstance(item, ast.Name) and item.id == "qqp"
                for item in ast.walk(node)
            ):
                selected.append(node)
        elif isinstance(node, ast.FunctionDef) and node.name == "get_parton_lum":
            selected.append(node)
    namespace: dict[str, Any] = {"np": np}
    compiled = compile(ast.Module(body=selected, type_ignores=[]), str(driver_path), "exec")
    exec(compiled, namespace)
    function = namespace.get("get_parton_lum")
    eq4 = namespace.get("eq4")
    if not callable(function) or not isinstance(eq4, np.ndarray) or eq4.shape != (11,):
        raise RuntimeError("could not recover channel luminosity from pinned driver")
    endpoint_regulator = finite_real(
        namespace.get("zero"), "pinned driver endpoint regulator"
    )
    if endpoint_regulator <= 0.0:
        raise RuntimeError("pinned driver endpoint regulator is not positive")
    return function, eq4, endpoint_regulator


def channel_case_weights(
    get_parton_lum: Callable[..., Any], eq4: np.ndarray
) -> dict[str, float]:
    incoming = np.zeros(11, dtype=float)
    fragmenting = np.zeros(11, dtype=float)
    incoming[1] = 1.0
    fragmenting[1] = 1.0
    weights = {
        case: finite_real(
            get_parton_lum(
                0.5, 0.5, 1.0, CHANNEL, case,
                incoming, fragmenting, eq4,
            ),
            f"driver channel-2 case-{case} luminosity weight",
        )
        for case in CASE_ORDER
    }
    if not any(weight != 0.0 for weight in weights.values()):
        raise RuntimeError("all channel-2 case weights are zero")
    return weights


def kinematics(parameters: dict[str, Any]) -> dict[str, float]:
    xhat = float(parameters["xHat"])
    z = float(parameters["zH"])
    q2 = float(parameters["Q2"])
    qt2 = float(parameters["qT2"])
    s23 = float(parameters["S23Sample"])
    denominator = (1.0 - xhat) - xhat * s23 / q2
    endpoint_denominator = 1.0 - xhat
    common = (1.0 - xhat) + xhat * qt2 / q2
    zhat = denominator / common
    zhat0 = endpoint_denominator / common
    zeta = z / zhat
    zeta0 = z / zhat0
    result = {
        "s": (1.0 - xhat) / xhat * q2,
        "t": -(1.0 - zhat) * q2 - zhat * qt2,
        "t0": -(1.0 - zhat0) * q2 - zhat0 * qt2,
        "zHat": zhat,
        "zHat0": zhat0,
        "zeta": zeta,
        "zeta0": zeta0,
        "Jacobian": zeta * xhat / q2 / denominator,
        "Jacobian0": zeta0 * xhat / q2 / endpoint_denominator,
    }
    for key in result:
        if not math.isclose(
            result[key], float(parameters[key]), rel_tol=2.0e-14, abs_tol=2.0e-14
        ):
            raise RuntimeError(f"kinematic map differs for {parameters['ID']} {key}")
    if not (
        0.0 < xhat < 1.0
        and 0.0 < s23 < float(parameters["S23UpperB"])
        and 0.0 < zhat < 1.0
        and 0.0 < zeta < 1.0
        and result["Jacobian"] > 0.0
        and result["Jacobian0"] > 0.0
    ):
        raise RuntimeError(f"unphysical benchmark {parameters['ID']}")
    return result


def evaluate_projector_observables(
    module: Any,
    parameters: dict[str, Any],
    label: str,
    endpoint_regulator: float,
) -> dict[str, float]:
    current = kinematics(parameters)
    q = float(parameters["Q"])
    s = current["s"]
    t = current["t"]
    t0 = current["t0"]
    s23 = float(parameters["S23Sample"])
    bound = float(parameters["S23UpperB"])
    nf = float(parameters["Nf"])
    regular = finite_real(
        module.regular(1.0, 1.0, s, t, q, s23, q, nf),
        f"{label} regular/{parameters['ID']}",
    )
    delta = finite_real(
        module.delta(1.0, 1.0, s, t0, q, endpoint_regulator, q, bound, nf),
        f"{label} delta/{parameters['ID']}",
    )
    plus0 = finite_real(
        module.plus1B(1.0, 1.0, s, t, q, s23, q, bound, nf),
        f"{label} plus1B/{parameters['ID']}",
    )
    plus0_endpoint = finite_real(
        module.plus1B(
            1.0, 1.0, s, t0, q, endpoint_regulator, q, bound, nf
        ),
        f"{label} plus1B endpoint/{parameters['ID']}",
    )
    plus1 = finite_real(
        module.plus2B(1.0, 1.0, s, t, q, s23, q, bound, nf),
        f"{label} plus2B/{parameters['ID']}",
    )
    plus1_endpoint = finite_real(
        module.plus2B(
            1.0, 1.0, s, t0, q, endpoint_regulator, q, bound, nf
        ),
        f"{label} plus2B endpoint/{parameters['ID']}",
    )
    jacobian = current["Jacobian"]
    jacobian0 = current["Jacobian0"]
    ordinary = (
        jacobian * regular
        + (jacobian * plus0 - jacobian0 * plus0_endpoint) / s23
        + (
            (jacobian * plus1 - jacobian0 * plus1_endpoint)
            * math.log(s23)
            / s23
        )
    )
    return {
        "Delta": jacobian0 * delta,
        "Plus0": jacobian0 * plus0_endpoint,
        "Plus1": jacobian0 * plus1_endpoint,
        "Ordinary": ordinary,
    }


def fhat_from_projectors(
    pg: float, ppp: float, xhat: float, q2: float
) -> dict[str, float]:
    return {
        "F1Hat": -0.5 * pg + 2.0 * xhat**2 / q2 * ppp,
        "F2Hat": -xhat * pg + 12.0 * xhat**3 / q2 * ppp,
    }


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
    print("HQQV2_BIGTMD_S02_STAGE=validate local and reference provenance")
    refuse_existing_outputs()
    local = json.loads(LOCAL_PATH.read_text(encoding="utf-8"))
    if (
        local.get("Status") != "CompleteLocalHqqV2FHatBenchmarks"
        or local.get("StageVersion") != "HqqV2BigTMDCheckS01-v1"
    ):
        raise RuntimeError("local Hqq_v2 S01 benchmark is absent or incomplete")

    source = local["Source"]
    source_path = Path(source["Path"])
    source_program_path = Path(source["ProgramPath"])
    if (
        source.get("Stage") != "HqqV2S08-v1"
        or source.get("SHA256") != EXPECTED_S08_SHA256
        or source.get("ProgramSHA256") != EXPECTED_S08_PROGRAM_SHA256
        or source.get("FHatSHA256") != EXPECTED_HAT_SHA256
        or not source_path.is_file()
        or source_path.stat().st_size != int(source["ByteCount"])
        or sha256_file(source_path) != EXPECTED_S08_SHA256
        or not source_program_path.is_file()
        or sha256_file(source_program_path) != EXPECTED_S08_PROGRAM_SHA256
    ):
        raise RuntimeError("local benchmark has a stale accepted S08 binding")
    s01_program_path = Path(local["Program"]["Path"])
    if (
        not s01_program_path.is_file()
        or sha256_file(s01_program_path) != local["Program"]["SHA256"]
    ):
        raise RuntimeError("local benchmark has a stale S01 program binding")

    conventions = local["Conventions"]
    construction = local["Construction"]
    if (
        int(conventions.get("BigTMDChannel", 0)) != CHANNEL
        or conventions.get("BigTMDCaseOrder") != list(CASE_ORDER)
        or conventions.get("IncomingAndFragmentingType") != "UpType"
        or int(conventions.get("Nf", 0)) != 4
        or conventions.get("ActiveFlavorTypes")
        != ["UpType", "DownType", "DownType", "UpType"]
        or conventions.get("FlavorMultiplicities") != {"UpType": 2, "DownType": 2}
        or conventions.get("ChargeAssignment")
        != {"UpType": "2/3", "DownType": "-1/3"}
        or conventions.get("LocalJacobianAlreadyIncluded") is not True
        or construction.get("BoundedPlusOrders") != [0, 1]
        or construction.get("ObservableOrder") != list(OBSERVABLES)
        or int(construction.get("ExpectedComparisonCount", 0))
        != EXPECTED_COMPARISON_COUNT
    ):
        raise RuntimeError("local benchmark conventions changed")

    reference_binding = local["ReferenceBinding"]
    expected_module_paths = {
        key: str(REFERENCE_DIR / relative)
        for key, relative in MODULE_RELATIVE_PATHS.items()
    }
    driver_path = REFERENCE_DIR / "sidis.py"
    if (
        reference_binding.get("Directory") != str(REFERENCE_DIR)
        or reference_binding.get("Commit") != EXPECTED_COMMIT
        or reference_binding.get("DriverPath") != str(driver_path)
        or reference_binding.get("DriverSHA256") != EXPECTED_DRIVER_SHA256
        or reference_binding.get("ModulePaths") != expected_module_paths
        or reference_binding.get("ModuleSHA256") != EXPECTED_MODULE_SHA256
        or not driver_path.is_file()
        or sha256_file(driver_path) != EXPECTED_DRIVER_SHA256
    ):
        raise RuntimeError("local benchmark has a stale BigTMD binding")

    driver_text = driver_path.read_text(encoding="utf-8")
    required_driver_fragments = (
        "elif chn==2:",
        "elif chn==2 and case=='A': _Pg,_Ppp=Pg.fchn2A,Ppp.fchn2A",
        "elif chn==2 and case=='B': _Pg,_Ppp=Pg.fchn2B,Ppp.fchn2B",
        "elif chn==2 and case=='C': _Pg,_Ppp=Pg.fchn2C,Ppp.fchn2C",
        "if part=='regular':",
        "if chn<4:",
        "if part=='delta':",
        "_Pg.plus1B",
        "_Pg.plus2B",
    )
    if any(fragment not in driver_text for fragment in required_driver_fragments):
        raise RuntimeError("BigTMD channel-2 distribution assembly changed")
    commit = subprocess.run(
        ["git", "-C", str(REFERENCE_DIR), "rev-parse", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if commit != EXPECTED_COMMIT:
        raise RuntimeError(f"unexpected BigTMD commit {commit}")

    module_paths: dict[str, Path] = {}
    for key, relative in MODULE_RELATIVE_PATHS.items():
        path = REFERENCE_DIR / relative
        if not path.is_file() or sha256_file(path) != EXPECTED_MODULE_SHA256[key]:
            raise RuntimeError(f"stale BigTMD module {path}")
        module_paths[key] = path

    benchmarks = local["Benchmarks"]
    local_values = local["LocalFHatByBenchmark"]
    if len(benchmarks) != 3 or len({item["ID"] for item in benchmarks}) != 3:
        raise RuntimeError("local benchmark set is incomplete")
    if set(local_values) != {item["ID"] for item in benchmarks}:
        raise RuntimeError("local benchmark-value keys do not match")
    for parameters in benchmarks:
        identifier = parameters["ID"]
        kinematics(parameters)
        if list(local_values[identifier]) != list(OBSERVABLES):
            raise RuntimeError(f"local observable order changed for {identifier}")
        for observable in OBSERVABLES:
            if set(local_values[identifier][observable]) != set(STRUCTURE_FUNCTIONS):
                raise RuntimeError(f"local F-hat coverage changed for {identifier}")
            for function in STRUCTURE_FUNCTIONS:
                finite_real(
                    local_values[identifier][observable][function],
                    f"local {identifier}/{observable}/{function}",
                )

    get_parton_lum, eq4, endpoint_regulator = driver_luminosity_function(
        driver_path
    )
    case_weights = channel_case_weights(get_parton_lum, eq4)
    for parameters in benchmarks:
        repeated = channel_case_weights(get_parton_lum, eq4)
        if repeated != case_weights:
            raise RuntimeError("driver channel-2 case weights are not stable")

    print("HQQV2_BIGTMD_S02_CASE_WEIGHTS=" + json.dumps(case_weights, sort_keys=True))
    print(f"HQQV2_BIGTMD_S02_ENDPOINT_REGULATOR={endpoint_regulator!r}")
    print("HQQV2_BIGTMD_S02_STAGE=evaluate channel-2 A/B/C modules")
    case_projectors: dict[str, dict[str, dict[str, dict[str, float]]]] = {
        item["ID"]: {case: {} for case in CASE_ORDER} for item in benchmarks
    }
    for case in CASE_ORDER:
        for projector, prefix in (("Pg", "Pg"), ("Ppp", "PPP")):
            key = f"{prefix}2{case}"
            print(f"HQQV2_BIGTMD_S02_MODULE={projector}/fchn2{case}")
            module = load_generated_module(module_paths[key], f"hqqv2_{key}")
            for parameters in benchmarks:
                case_projectors[parameters["ID"]][case][projector] = (
                    evaluate_projector_observables(
                        module, parameters, key, endpoint_regulator
                    )
                )
            del module
            gc.collect()

    total_projectors: dict[str, dict[str, dict[str, float]]] = {}
    fhat_by_benchmark: dict[str, dict[str, dict[str, float]]] = {}
    weighted_case_projectors: dict[str, dict[str, dict[str, dict[str, float]]]] = {}
    for parameters in benchmarks:
        identifier = parameters["ID"]
        weighted_case_projectors[identifier] = {}
        for case in CASE_ORDER:
            weighted_case_projectors[identifier][case] = {
                projector: {
                    observable: case_weights[case]
                    * case_projectors[identifier][case][projector][observable]
                    for observable in OBSERVABLES
                }
                for projector in PROJECTORS
            }
        total_projectors[identifier] = {
            projector: {
                observable: sum(
                    weighted_case_projectors[identifier][case][projector][observable]
                    for case in CASE_ORDER
                )
                for observable in OBSERVABLES
            }
            for projector in PROJECTORS
        }
        fhat_by_benchmark[identifier] = {
            observable: fhat_from_projectors(
                total_projectors[identifier]["Pg"][observable],
                total_projectors[identifier]["Ppp"][observable],
                float(parameters["xHat"]),
                float(parameters["Q2"]),
            )
            for observable in OBSERVABLES
        }

    reference_payload: dict[str, Any] = {
        "Status": "CompleteBigTMDHqqV2FHatBenchmarks",
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
            "ChargeCases": list(CASE_ORDER),
            "Projectors": list(PROJECTORS),
            "ModulePaths": {key: str(path) for key, path in module_paths.items()},
            "ModuleSHA256": EXPECTED_MODULE_SHA256,
        },
        "Conventions": {
            "DistributionObservables": list(OBSERVABLES),
            "CaseWeightsFromPinnedDriver": case_weights,
            "EndpointRegulatorFromPinnedDriver": endpoint_regulator,
            "FixedIncomingAndFragmentingParton": "up quark",
            "Couplings": "g=gp=1",
            "Scale": "mu=Q",
            "Nf": 4,
            "Jacobian": "pinned sidis.py zeta-to-s23 Jacobian applied",
            "OrdinaryAssembly": (
                "regular plus endpoint-subtracted plus1B and plus2B densities"
            ),
            "Excluded": (
                "PDFs, FFs, remaining zh/(xi zeta) test factor, outer xi "
                "convolution, and leptonic prefactors"
            ),
            "DecimalPolicy": "pinned Python decimal expressions executed as written",
        },
        "Benchmarks": benchmarks,
        "RawProjectorsByBenchmarkAndCase": case_projectors,
        "WeightedProjectorsByBenchmarkAndCase": weighted_case_projectors,
        "TotalProjectorsByBenchmark": total_projectors,
        "FHatByBenchmark": fhat_by_benchmark,
    }

    rows: list[dict[str, Any]] = []
    differences: dict[str, dict[str, dict[str, Any]]] = {}
    for parameters in benchmarks:
        identifier = parameters["ID"]
        differences[identifier] = {}
        for observable in OBSERVABLES:
            differences[identifier][observable] = {}
            for function in STRUCTURE_FUNCTIONS:
                local_value = finite_real(
                    local_values[identifier][observable][function],
                    f"local {identifier}/{observable}/{function}",
                )
                bigtmd_value = finite_real(
                    fhat_by_benchmark[identifier][observable][function],
                    f"BigTMD {identifier}/{observable}/{function}",
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
                differences[identifier][observable][function] = item
                rows.append(
                    {
                        "Benchmark": identifier,
                        "Observable": observable,
                        "Function": function,
                        **item,
                    }
                )

    coverage = {
        (row["Benchmark"], row["Observable"], row["Function"])
        for row in rows
    }
    if len(rows) != EXPECTED_COMPARISON_COUNT or len(coverage) != len(rows):
        raise RuntimeError("comparison coverage is incomplete or duplicated")
    max_abs = max(row["AbsoluteDifference"] for row in rows)
    max_rel = max(row["RelativeDifference"] for row in rows)
    all_close = all(row["NumericallyClose"] for row in rows)

    difference_payload: dict[str, Any] = {
        "Status": "CompleteHqqV2BigTMDMinusLocalComparison",
        "StageVersion": STAGE_VERSION,
        "DifferenceDirection": "BigTMD minus local",
        "LocalSource": source,
        "BigTMDSource": reference_payload["Reference"],
        "ComparisonLevel": local["ComparisonLevel"],
        "CaseWeightsFromPinnedDriver": case_weights,
        "Benchmarks": benchmarks,
        "DifferencesByBenchmark": differences,
        "Rows": rows,
        "StructuralChecks": {
            "Channel2Selected": True,
            "AllABCModulesEvaluated": True,
            "DriverCaseWeightsUsed": True,
            "DriverEndpointRegulatorUsed": True,
            "DeltaAndBothPlusOrdersCompared": True,
            "OrdinaryIncludesDriverPlusRemainders": True,
            "MatchedJacobianAppliedOnlyToReference": True,
            "LocalExactUntilFinalEvaluation": True,
        },
        "Summary": {
            "ComparisonCount": len(rows),
            "MaximumAbsoluteDifference": max_abs,
            "MaximumRelativeDifference": max_rel,
            "AllTestedCoefficientsWithinTolerance": all_close,
            "AbsoluteTolerance": ABSOLUTE_TOLERANCE,
            "RelativeTolerance": RELATIVE_TOLERANCE,
            "ToleranceRule": (
                "abs(diff) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local))"
            ),
        },
    }

    report = [
        "# Hqq_v2 BigTMD channel-2 consistency check",
        "",
        "Signed difference: **BigTMD minus local**.",
        "",
        (
            "Channel-2 cases A, B, and C are combined with the weights "
            "produced by the pinned driver for one incoming/fragmenting up "
            "quark and four active flavors."
        ),
        "",
        f"Driver-derived case weights: `{json.dumps(case_weights, sort_keys=True)}`.",
        "",
        "| Benchmark | Observable | F hat | Local | BigTMD | BigTMD-local | Relative | Close |",
        "|---|---|---|---:|---:|---:|---:|:---:|",
    ]
    for row in rows:
        report.append(
            "| {Benchmark} | {Observable} | {Function} | {Local:.12e} | "
            "{BigTMD:.12e} | {BigTMDMinusLocal:.12e} | "
            "{RelativeDifference:.5e} | {NumericallyClose} |".format(**row)
        )
    report.extend(
        [
            "",
            f"Maximum absolute difference: `{max_abs:.12e}`.",
            "",
            f"Maximum relative difference: `{max_rel:.12e}`.",
            "",
            f"All 24 coefficients within tolerance: `{all_close}`.",
            "",
            (
                "Tolerance: `abs(diff) <= 1e-10 + "
                "1e-7*max(abs(BigTMD),abs(local))`."
            ),
            "",
            (
                "The local expressions remained exact through rational "
                "substitution; BigTMD decimal expressions were executed as written."
            ),
            "",
        ]
    )

    atomic_json(BIGTMD_OUTPUT, reference_payload)
    atomic_json(DIFFERENCE_OUTPUT, difference_payload)
    atomic_text(REPORT_OUTPUT, "\n".join(report))

    print(f"HQQV2_BIGTMD_S02_ALL_CLOSE={all_close}")
    print(f"HQQV2_BIGTMD_S02_COMPARISON_COUNT={len(rows)}")
    print(f"HQQV2_BIGTMD_S02_MAX_ABS={max_abs:.17g}")
    print(f"HQQV2_BIGTMD_S02_MAX_REL={max_rel:.17g}")
    print(f"HQQV2_BIGTMD_S02_BIGTMD_OUTPUT={BIGTMD_OUTPUT}")
    print(f"HQQV2_BIGTMD_S02_DIFFERENCE_OUTPUT={DIFFERENCE_OUTPUT}")
    print(f"HQQV2_BIGTMD_S02_REPORT_OUTPUT={REPORT_OUTPUT}")
    print("HQQV2_BIGTMD_S02_SUCCESS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HQQV2_BIGTMD_S02_FATAL: {error}", file=sys.stderr, flush=True)
        raise
