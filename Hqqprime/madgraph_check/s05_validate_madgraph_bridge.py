#!/usr/bin/env python3
"""Validate the Hqqprime ISO-C bridge against the generated MadGraph routine."""

from __future__ import annotations

from collections import Counter
import ctypes
import hashlib
import json
import math
import os
from pathlib import Path
import re
import subprocess
from typing import Any


CHECK_DIR = Path(__file__).resolve().parent
COPIES_DIR = CHECK_DIR / "upstream_copies"
MANIFEST_PATH = CHECK_DIR / "s01_input_manifest.json"
BRIDGE_PATH = CHECK_DIR / "s03_libhqqprime_madgraph_bridge.so"
PARAM_CARD_PATH = CHECK_DIR / "generated_process" / "Cards" / "param_card.dat"
DIRECT_LOG_PATH = CHECK_DIR / "s04_direct_madgraph_reference.log"
MATRIX_PATH = (
    CHECK_DIR
    / "generated_process"
    / "SubProcesses"
    / "P1_emu_emcucx_no_zh"
    / "matrix.f"
)
ALL_MATRIX_PATH = (
    CHECK_DIR / "generated_process" / "SubProcesses" / "all_matrix.f"
)
PROCESS_CARD_PATH = (
    CHECK_DIR / "generated_process" / "Cards" / "proc_card_mg5.dat"
)
OUTPUT_PATH = CHECK_DIR / "s05_bridge_validation.json"
WOLFRAM_KERNEL = Path(
    "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/"
    "Executables/WolframKernel"
)

STAGE_VERSION = "HqqprimeMadGraphBridgeValidation-v1"
EXPECTED_MANIFEST_SHA256 = (
    "6addb9b9c330e0a2bc60abfb84f12fbf19aef0c5fb0bd582ed2666ea880f6dc1"
)
EXPECTED_S01_RESULT_SHA256 = (
    "842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b"
)
EXPECTED_S06_RESULT_SHA256 = (
    "92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607"
)
EXPECTED_S02_CARD_SHA256 = (
    "42ed29707ec12ade4466a6130676cc0fc924f5557ab847bf5cf0e31629be794f"
)
EXPECTED_PROCESS_CARD_SHA256 = (
    "75be20bdcfc89b4ff655627f0466187e1f225f04ee8c7da6d754cc992c88fb59"
)
EXPECTED_ALL_MATRIX_SHA256 = (
    "0a7ed053e605f861bb8a61df21c28c31cd5194e37df80531d7e5140d12c1df9b"
)
EXPECTED_MATRIX_SHA256 = (
    "bb29686e959a0f24fa0021f3e6efce4d2d0f5e6c8b9497d84ca95f0e7f3c2cf3"
)
EXPECTED_PDGS = [11, 2, 11, 4, 2, -4]


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def unique_integer(pattern: str, text: str, label: str) -> int:
    matches = re.findall(pattern, text, flags=re.MULTILINE)
    if len(matches) != 1:
        raise RuntimeError(f"{label} is absent or nonunique")
    return int(matches[0])


def parse_generated_metadata() -> dict[str, Any]:
    matrix_text = MATRIX_PATH.read_text(encoding="utf-8")
    all_matrix_text = ALL_MATRIX_PATH.read_text(encoding="utf-8")
    diagram_count = unique_integer(r"NGRAPHS\s*=\s*([0-9]+)", matrix_text, "NGRAPHS")
    identity_factor = unique_integer(r"DATA\s+IDEN/([0-9]+)/", matrix_text, "IDEN")
    beam_match = re.findall(
        r"DATA\s+\(BEAMS_HELAVGFACTOR\(I\),I=1,2\)/([0-9]+),([0-9]+)/",
        matrix_text,
    )
    if len(beam_match) != 1:
        raise RuntimeError("generated beam-helicity factors are absent or nonunique")
    beam_factors = [int(value) for value in beam_match[0]]
    pdg_matches = re.findall(r"DATA\s+PDGS/\s*([^/]*)/", all_matrix_text)
    if len(pdg_matches) != 1:
        raise RuntimeError("generated PDG order is absent or nonunique")
    pdgs = [int(value.strip()) for value in pdg_matches[0].split(",")]
    final_counts = Counter(pdgs[2:])
    final_identity_divisor = math.prod(
        math.factorial(count) for count in final_counts.values()
    )
    return {
        "diagram_count": diagram_count,
        "identity_factor": identity_factor,
        "beam_helicity_average_factors": beam_factors,
        "pdgs": pdgs,
        "final_identity_divisor": final_identity_divisor,
    }


def derive_local_metadata() -> dict[str, Any]:
    s01_path = (COPIES_DIR / "s01_result").resolve()
    s06_path = (COPIES_DIR / "s06_result").resolve()
    wolfram_code = (
        'Needs["FeynCalc`"]; $PrePrint=.; '
        f's01=Get["{s01_path}"]; s06=Get["{s06_path}"]; '
        'upCharge=s01["ModelChargeCoefficients","UpType"]; '
        'downCharge=s01["ModelChargeCoefficients","DownType"]; '
        'denominator=Together[s06["ExternalStateBookkeeping",'
        '"InitialStateAverageDenominator"]/.FeynCalc`SUNN->3]; '
        'symmetry=Values[s06["SymmetryBookkeeping",'
        '"DerivedFinalStateSymmetryFactors"]]; '
        'payload=<|"diagram_count"->s01["MeasuredSelectedDiagramCounts",'
        '"up_up"],"incoming_quark_average_denominator_su3"->denominator,'
        '"final_symmetry_factors"->symmetry,'
        '"up_charge_numerator"->Numerator[upCharge],'
        '"up_charge_denominator"->Denominator[upCharge],'
        '"down_charge_numerator"->Numerator[downCharge],'
        '"down_charge_denominator"->Denominator[downCharge]|>; '
        'WriteString[First[$Output],"HQQPRIME_S05_LOCAL_METADATA="<>'
        'ExportString[payload,"RawJSON"],"\\n"]; '
        'Exit[0]'
    )
    completed = subprocess.run(
        [str(WOLFRAM_KERNEL), "-noinit", "-noprompt", "-run", wolfram_code],
        check=True,
        capture_output=True,
        text=True,
        timeout=180,
    )
    marker = "HQQPRIME_S05_LOCAL_METADATA="
    if completed.stdout.count(marker) != 1:
        raise RuntimeError("Wolfram local-metadata derivation has no unique marker")
    marker_tail = completed.stdout.split(marker, 1)[1]
    json_start = marker_tail.find("{")
    if json_start < 0:
        raise RuntimeError("Wolfram local-metadata marker has no JSON object")
    metadata, _ = json.JSONDecoder().raw_decode(marker_tail[json_start:])
    return metadata


def read_direct_markers() -> dict[str, float]:
    marker_map = {
        "matrix": "HQQPRIME_DIRECT_MATRIX=",
        "maximum_conservation_residual": "HQQPRIME_DIRECT_MAX_CONSERVATION=",
        "maximum_mass_squared": "HQQPRIME_DIRECT_MAX_MASS2=",
    }
    lines = DIRECT_LOG_PATH.read_text(encoding="utf-8").splitlines()
    values: dict[str, float] = {}
    for key, marker in marker_map.items():
        matches = [float(line.split("=", 1)[1]) for line in lines if line.startswith(marker)]
        if len(matches) != 1:
            raise RuntimeError(f"direct reference log has no unique {key} marker")
        values[key] = matches[0]
    return values


def tetrahedron_momenta() -> list[list[float]]:
    root_three = math.sqrt(3.0)
    energy = 250.0
    return [
        [500.0, 0.0, 0.0, 500.0],
        [500.0, 0.0, 0.0, -500.0],
        [energy, energy / root_three, energy / root_three, energy / root_three],
        [energy, energy / root_three, -energy / root_three, -energy / root_three],
        [energy, -energy / root_three, energy / root_three, -energy / root_three],
        [energy, -energy / root_three, -energy / root_three, energy / root_three],
    ]


def minkowski_square(momentum: list[float]) -> float:
    return momentum[0] ** 2 - sum(component**2 for component in momentum[1:])


def evaluate(
    library: ctypes.CDLL, momenta: list[list[float]], alpha_s: float
) -> float:
    flat_particle_major = [
        component for particle in momenta for component in particle
    ]
    momentum_array = (ctypes.c_double * 24)(*flat_particle_major)
    answer = ctypes.c_double(0.0)
    library.hqqprime_mg_eval(momentum_array, alpha_s, ctypes.byref(answer))
    return answer.value


def atomic_json(path: Path, payload: dict[str, Any]) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
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
    required_paths = (
        MANIFEST_PATH,
        BRIDGE_PATH,
        PARAM_CARD_PATH,
        DIRECT_LOG_PATH,
        MATRIX_PATH,
        ALL_MATRIX_PATH,
        PROCESS_CARD_PATH,
        COPIES_DIR / "s01_result",
        COPIES_DIR / "s06_result",
    )
    for required in required_paths:
        if not required.is_file():
            raise FileNotFoundError(required)
    if OUTPUT_PATH.exists() or OUTPUT_PATH.with_suffix(".json.tmp").exists():
        raise FileExistsError(OUTPUT_PATH)

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    if (
        sha256_file(MANIFEST_PATH) != EXPECTED_MANIFEST_SHA256
        or manifest.get("StageVersion") != "HqqprimeMadGraphInputProvenance-v1"
        or manifest.get("Status") != "Complete"
        or not all(manifest.get("Checks", {}).values())
        or sha256_file(COPIES_DIR / "s01_result") != EXPECTED_S01_RESULT_SHA256
        or sha256_file(COPIES_DIR / "s06_result") != EXPECTED_S06_RESULT_SHA256
    ):
        raise RuntimeError("S01/copy provenance is stale")

    if (
        sha256_file(CHECK_DIR / "s02_generate_hqqprime_standalone.mg5")
        != EXPECTED_S02_CARD_SHA256
        or sha256_file(PROCESS_CARD_PATH) != EXPECTED_PROCESS_CARD_SHA256
        or sha256_file(ALL_MATRIX_PATH) != EXPECTED_ALL_MATRIX_SHA256
        or sha256_file(MATRIX_PATH) != EXPECTED_MATRIX_SHA256
        or "generate e- u > e- c u c~ / z h QED=2 QCD=2 @1"
        not in PROCESS_CARD_PATH.read_text(encoding="utf-8")
    ):
        raise RuntimeError("generated source provenance or process changed")

    generated = parse_generated_metadata()
    local = derive_local_metadata()
    derived_identity_factor = (
        int(local["incoming_quark_average_denominator_su3"])
        * int(generated["beam_helicity_average_factors"][0])
        * int(generated["final_identity_divisor"])
    )
    if (
        generated["pdgs"] != EXPECTED_PDGS
        or generated["diagram_count"] != int(local["diagram_count"])
        or generated["final_identity_divisor"] != 1
        or set(local["final_symmetry_factors"]) != {1}
        or generated["identity_factor"] != derived_identity_factor
    ):
        raise RuntimeError("generated process count, routing, or IDEN derivation failed")

    os.chdir(CHECK_DIR)
    library = ctypes.CDLL(str(BRIDGE_PATH))
    library.hqqprime_mg_init.argtypes = [ctypes.c_char_p]
    library.hqqprime_mg_init.restype = None
    library.hqqprime_mg_eval.argtypes = [
        ctypes.POINTER(ctypes.c_double),
        ctypes.c_double,
        ctypes.POINTER(ctypes.c_double),
    ]
    library.hqqprime_mg_eval.restype = None
    library.hqqprime_mg_metadata.argtypes = [
        ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int),
    ]
    library.hqqprime_mg_metadata.restype = None

    bridge_pdgs = (ctypes.c_int * 6)()
    bridge_identity = ctypes.c_int(0)
    library.hqqprime_mg_metadata(bridge_pdgs, ctypes.byref(bridge_identity))
    if list(bridge_pdgs) != generated["pdgs"]:
        raise RuntimeError("bridge PDG metadata differs from generated source")
    if bridge_identity.value != generated["identity_factor"]:
        raise RuntimeError("bridge IDEN metadata differs from generated source")

    library.hqqprime_mg_init(b"generated_process/Cards/param_card.dat")
    momenta = tetrahedron_momenta()
    conservation = [
        momenta[0][component]
        + momenta[1][component]
        - sum(momentum[component] for momentum in momenta[2:])
        for component in range(4)
    ]
    maximum_conservation_residual = max(abs(value) for value in conservation)
    maximum_mass_squared = max(abs(minkowski_square(momentum)) for momentum in momenta)
    photon = [momenta[0][component] - momenta[2][component] for component in range(4)]
    photon_virtuality = minkowski_square(photon)
    if maximum_conservation_residual > 1.0e-12:
        raise RuntimeError("fixed point violates four-momentum conservation")
    if maximum_mass_squared > 1.0e-9:
        raise RuntimeError("fixed point is not massless within double precision")
    if photon_virtuality >= 0.0:
        raise RuntimeError("fixed point does not have a spacelike photon")

    alpha_s = 0.118
    bridge_value = evaluate(library, momenta, alpha_s)
    direct = read_direct_markers()
    direct_value = direct["matrix"]
    relative_difference = abs(bridge_value - direct_value) / max(
        abs(bridge_value), abs(direct_value)
    )
    if not all(
        math.isfinite(value) and value > 0.0
        for value in (bridge_value, direct_value)
    ):
        raise RuntimeError("matrix value is not positive and finite")
    if relative_difference > 5.0e-14:
        raise RuntimeError(
            f"bridge/direct mismatch: relative difference {relative_difference:.17g}"
        )
    if (
        direct["maximum_conservation_residual"] > 1.0e-12
        or direct["maximum_mass_squared"] > 1.0e-9
    ):
        raise RuntimeError("direct reference kinematic self-check failed")

    checks = {
        "S01AndCopiedInputsHashBound": True,
        "GeneratedSourceHashBound": True,
        "CurrentDiagramCountMatchesCopiedS01": True,
        "PDGOrderMatchesGeneratedSource": True,
        "FinalIdentityDivisorDerivedUnit": True,
        "GeneratedIDENMatchesDerivedAverages": True,
        "BridgeMetadataMatchesGeneratedSource": True,
        "SpacelikePhoton": True,
        "FourMomentumConserved": True,
        "AllExternalStatesMassless": True,
        "BridgeMatchesDirectGeneratedRoutine": True,
    }
    payload: dict[str, Any] = {
        "StageVersion": STAGE_VERSION,
        "Status": "Complete",
        "ProcessPDGs": generated["pdgs"],
        "GeneratedDiagramCount": generated["diagram_count"],
        "GeneratedIDEN": generated["identity_factor"],
        "DerivedIDEN": derived_identity_factor,
        "GeneratedBeamHelicityAverageFactors": generated[
            "beam_helicity_average_factors"
        ],
        "GeneratedFinalIdentityDivisor": generated["final_identity_divisor"],
        "CopiedLocalMetadata": local,
        "AlphaS": alpha_s,
        "PhotonQ2": photon_virtuality,
        "MaximumConservationResidual": maximum_conservation_residual,
        "MaximumExternalMassSquared": maximum_mass_squared,
        "DirectMatrixElement": direct_value,
        "BridgeMatrixElement": bridge_value,
        "BridgeDirectRelativeDifference": relative_difference,
        "Checks": checks,
        "SHA256": {
            "Program": sha256_file(Path(__file__).resolve()),
            "Manifest": EXPECTED_MANIFEST_SHA256,
            "Bridge": sha256_file(BRIDGE_PATH),
            "ParameterCard": sha256_file(PARAM_CARD_PATH),
            "DirectLog": sha256_file(DIRECT_LOG_PATH),
            "GeneratedAllMatrix": EXPECTED_ALL_MATRIX_SHA256,
            "GeneratedMatrix": EXPECTED_MATRIX_SHA256,
        },
    }
    if not all(checks.values()):
        raise RuntimeError("S05 embedded check failed")
    atomic_json(OUTPUT_PATH, payload)

    print("HQQPRIME_MADGRAPH_S05_SUCCESS")
    print(f"HQQPRIME_MADGRAPH_S05_DIAGRAMS={generated['diagram_count']}")
    print(f"HQQPRIME_MADGRAPH_S05_IDEN={generated['identity_factor']}")
    print(f"BRIDGE_DIRECT_RELATIVE_DIFFERENCE={relative_difference:.17g}")
    print(f"HQQPRIME_MADGRAPH_S05_OUTPUT={OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HQQPRIME_MADGRAPH_S05_FATAL: {error}", flush=True)
        raise
