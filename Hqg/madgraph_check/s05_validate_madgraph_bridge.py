#!/usr/bin/env python3
"""Validate the Hqg ISO-C bridge against current generated MadGraph code."""

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
BRIDGE_PATH = CHECK_DIR / "s03_libhqg_madgraph_bridge.so"
PARAM_CARD_PATH = CHECK_DIR / "generated_process" / "Cards" / "param_card.dat"
DIRECT_LOG_PATH = CHECK_DIR / "s04_direct_madgraph_reference.log"
MATRIX_PATH = (
    CHECK_DIR
    / "generated_process"
    / "SubProcesses"
    / "P1_emu_emgug_no_zh"
    / "matrix.f"
)
ALL_MATRIX_PATH = CHECK_DIR / "generated_process" / "SubProcesses" / "all_matrix.f"
PROCESS_CARD_PATH = CHECK_DIR / "generated_process" / "Cards" / "proc_card_mg5.dat"
OUTPUT_PATH = CHECK_DIR / "s05_bridge_validation.json"
WOLFRAM_KERNEL = Path(
    "/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/"
    "Executables/WolframKernel"
)

STAGE_VERSION = "HqgMadGraphBridgeValidation-v1"
EXPECTED_MANIFEST_SHA256 = (
    "71411ec19a5354c74cb58902c2da6afcaa2d66ecda7a1065e71ef3a5a38a0879"
)
EXPECTED_S01_RESULT_SHA256 = (
    "8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198"
)
EXPECTED_S06_RESULT_SHA256 = (
    "86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55"
)
EXPECTED_S02_CARD_SHA256 = (
    "1172a9cdbb722f151de2fc16e18934881e3316416f90699f9494edd5e64ccc67"
)
EXPECTED_PROCESS_CARD_SHA256 = (
    "126f178aa4bb94ab7be45db8c3c9148d4cd9257403237d9c9c79c063e75f0b58"
)
EXPECTED_ALL_MATRIX_SHA256 = (
    "ac4433fd1097a20f088f0aeb6e51541f68ba861a05ca94649d32b8d5945d2b10"
)
EXPECTED_MATRIX_SHA256 = (
    "89a3a87f012ded8cf550a9242a5536334a4ae343065b40fedd2301e813b52e26"
)
EXPECTED_PDGS = [11, 2, 11, 21, 2, 21]


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
    repeated_final_pdgs = sorted(
        pdg for pdg, count in final_counts.items() if count > 1
    )
    return {
        "diagram_count": diagram_count,
        "identity_factor": identity_factor,
        "beam_helicity_average_factors": beam_factors,
        "pdgs": pdgs,
        "final_identity_divisor": final_identity_divisor,
        "repeated_final_pdgs": repeated_final_pdgs,
    }


def derive_local_metadata() -> dict[str, Any]:
    s01_path = (COPIES_DIR / "s01_result").resolve()
    s06_path = (COPIES_DIR / "s06_result").resolve()
    wolfram_code = (
        'Needs["FeynCalc`"]; $PrePrint=.; '
        f's01=Get["{s01_path}"]; s06=Get["{s06_path}"]; '
        'charge=Together[s01["ElectricChargeNormalization","ReferenceCharge"]]; '
        'strip=Together[s01["ElectricChargeNormalization","AmplitudeStripFactor"]]; '
        'average=Together[s06["InitialStateAverage"]/.FeynCalc`SUNN->3]; '
        'momenta=ToString[#,InputForm]& /@ s06["RealFinalStateMomenta"]; '
        'polarizations=Map[ToString[#,InputForm]&, '
        's06["PolarizationSumSpecifications","RealQG"],{2}]; '
        'payload=<|"diagram_count"->s01["DiagramCounts",'
        '"NLOReal_gammaStar_q_to_g_q_g"],'
        '"incoming_quark_average_numerator_su3"->Numerator[average],'
        '"incoming_quark_average_denominator_su3"->Denominator[average],'
        '"reference_charge_numerator"->Numerator[charge],'
        '"reference_charge_denominator"->Denominator[charge],'
        '"strip_factor_numerator"->Numerator[strip],'
        '"strip_factor_denominator"->Denominator[strip],'
        '"real_coherent_row_count"->s06["RealCoherentRowCount"],'
        '"real_final_state_momenta"->momenta,'
        '"real_polarization_pairs"->polarizations|>; '
        'WriteString[First[$Output],"HQG_S05_LOCAL_METADATA="<>'
        'ExportString[payload,"RawJSON"],"\n"]; Exit[0]'
    )
    completed = subprocess.run(
        [str(WOLFRAM_KERNEL), "-noinit", "-noprompt", "-run", wolfram_code],
        check=True,
        capture_output=True,
        text=True,
        timeout=180,
    )
    marker = "HQG_S05_LOCAL_METADATA="
    if completed.stdout.count(marker) != 1:
        raise RuntimeError("Wolfram local-metadata derivation has no unique marker")
    marker_tail = completed.stdout.split(marker, 1)[1]
    json_start = marker_tail.find("{")
    if json_start < 0:
        raise RuntimeError("Wolfram local-metadata marker has no JSON object")
    metadata, _ = json.JSONDecoder().raw_decode(marker_tail[json_start:])
    return metadata


def read_direct_markers() -> dict[str, Any]:
    lines = DIRECT_LOG_PATH.read_text(encoding="utf-8").splitlines()
    matrix_values: list[float] = []
    for point in range(1, 4):
        marker = f"HQG_DIRECT_MATRIX_{point}="
        matches = [
            float(line.split("=", 1)[1])
            for line in lines
            if line.startswith(marker)
        ]
        if len(matches) != 1:
            raise RuntimeError(f"direct log has no unique matrix marker {point}")
        matrix_values.append(matches[0])
    scalar_markers = {
        "maximum_conservation_residual": "HQG_DIRECT_MAX_CONSERVATION=",
        "maximum_mass_squared": "HQG_DIRECT_MAX_MASS2=",
    }
    output: dict[str, Any] = {"matrix_values": matrix_values}
    for key, marker in scalar_markers.items():
        matches = [
            float(line.split("=", 1)[1])
            for line in lines
            if line.startswith(marker)
        ]
        if len(matches) != 1:
            raise RuntimeError(f"direct log has no unique {key} marker")
        output[key] = matches[0]
    return output


def deterministic_momenta() -> list[list[list[float]]]:
    root_three = math.sqrt(3.0)
    energy = 250.0
    base = [
        [500.0, 0.0, 0.0, 500.0],
        [500.0, 0.0, 0.0, -500.0],
        [energy, energy / root_three, energy / root_three, energy / root_three],
        [energy, energy / root_three, -energy / root_three, -energy / root_three],
        [energy, -energy / root_three, energy / root_three, -energy / root_three],
        [energy, -energy / root_three, -energy / root_three, energy / root_three],
    ]
    points = [[list(momentum) for momentum in base] for _ in range(3)]
    points[1][2], points[1][4] = points[1][4], points[1][2]
    points[2][2], points[2][3] = points[2][3], points[2][2]
    return points


def minkowski_square(momentum: list[float]) -> float:
    return momentum[0] ** 2 - sum(component**2 for component in momentum[1:])


def evaluate(library: ctypes.CDLL, momenta: list[list[float]], alpha_s: float) -> float:
    flat_particle_major = [
        component for particle in momenta for component in particle
    ]
    momentum_array = (ctypes.c_double * 24)(*flat_particle_major)
    answer = ctypes.c_double(0.0)
    library.hqg_mg_eval(momentum_array, alpha_s, ctypes.byref(answer))
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
        or manifest.get("StageVersion") != "HqgMadGraphInputProvenance-v1"
        or manifest.get("Status") != "Complete"
        or not all(manifest.get("Checks", {}).values())
        or sha256_file(COPIES_DIR / "s01_result") != EXPECTED_S01_RESULT_SHA256
        or sha256_file(COPIES_DIR / "s06_result") != EXPECTED_S06_RESULT_SHA256
    ):
        raise RuntimeError("S01/copy provenance is stale")

    if (
        sha256_file(CHECK_DIR / "s02_generate_hqg_standalone.mg5")
        != EXPECTED_S02_CARD_SHA256
        or sha256_file(PROCESS_CARD_PATH) != EXPECTED_PROCESS_CARD_SHA256
        or sha256_file(ALL_MATRIX_PATH) != EXPECTED_ALL_MATRIX_SHA256
        or sha256_file(MATRIX_PATH) != EXPECTED_MATRIX_SHA256
        or "generate e- u > e- g u g / z h QED=2 QCD=2 @1"
        not in PROCESS_CARD_PATH.read_text(encoding="utf-8")
    ):
        raise RuntimeError("generated source provenance or process changed")

    generated = parse_generated_metadata()
    local = derive_local_metadata()
    if int(local["incoming_quark_average_numerator_su3"]) != 1:
        raise RuntimeError("copied initial-state average numerator is not unity")
    electron_beam_positions = [
        index for index, pdg in enumerate(generated["pdgs"][:2]) if pdg == 11
    ]
    if len(electron_beam_positions) != 1:
        raise RuntimeError("generated incoming electron position is not unique")
    electron_average = generated["beam_helicity_average_factors"][
        electron_beam_positions[0]
    ]
    derived_identity_factor = (
        int(local["incoming_quark_average_denominator_su3"])
        * int(electron_average)
        * int(generated["final_identity_divisor"])
    )
    if (
        generated["pdgs"] != EXPECTED_PDGS
        or generated["diagram_count"] != int(local["diagram_count"])
        or len(generated["repeated_final_pdgs"]) != 1
        or generated["final_identity_divisor"] <= 1
        or generated["identity_factor"] != derived_identity_factor
    ):
        raise RuntimeError("generated count, routing, or IDEN derivation failed")

    os.chdir(CHECK_DIR)
    library = ctypes.CDLL(str(BRIDGE_PATH))
    library.hqg_mg_init.argtypes = [ctypes.c_char_p]
    library.hqg_mg_init.restype = None
    library.hqg_mg_eval.argtypes = [
        ctypes.POINTER(ctypes.c_double),
        ctypes.c_double,
        ctypes.POINTER(ctypes.c_double),
    ]
    library.hqg_mg_eval.restype = None
    library.hqg_mg_metadata.argtypes = [
        ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int),
    ]
    library.hqg_mg_metadata.restype = None

    bridge_pdgs = (ctypes.c_int * 6)()
    bridge_identity = ctypes.c_int(0)
    library.hqg_mg_metadata(bridge_pdgs, ctypes.byref(bridge_identity))
    if list(bridge_pdgs) != generated["pdgs"]:
        raise RuntimeError("bridge PDG metadata differs from generated source")
    if bridge_identity.value != generated["identity_factor"]:
        raise RuntimeError("bridge IDEN metadata differs from generated source")

    library.hqg_mg_init(b"generated_process/Cards/param_card.dat")
    points = deterministic_momenta()
    duplicate_pdg = generated["repeated_final_pdgs"][0]
    duplicate_positions = [
        index
        for index, pdg in enumerate(generated["pdgs"])
        if index >= 2 and pdg == duplicate_pdg
    ]
    if len(duplicate_positions) != 2:
        raise RuntimeError("generated repeated-final-state positions are not a pair")

    maximum_conservation_residual = 0.0
    maximum_mass_squared = 0.0
    photon_virtualities: list[float] = []
    bridge_values: list[float] = []
    exchanged_values: list[float] = []
    for momenta in points:
        conservation = [
            momenta[0][component]
            + momenta[1][component]
            - sum(momentum[component] for momentum in momenta[2:])
            for component in range(4)
        ]
        maximum_conservation_residual = max(
            maximum_conservation_residual, max(abs(value) for value in conservation)
        )
        maximum_mass_squared = max(
            maximum_mass_squared,
            max(abs(minkowski_square(momentum)) for momentum in momenta),
        )
        photon = [
            momenta[0][component] - momenta[2][component]
            for component in range(4)
        ]
        photon_virtualities.append(minkowski_square(photon))
        bridge_values.append(evaluate(library, momenta, 0.118))
        exchanged = [list(momentum) for momentum in momenta]
        first, second = duplicate_positions
        exchanged[first], exchanged[second] = exchanged[second], exchanged[first]
        exchanged_values.append(evaluate(library, exchanged, 0.118))

    direct = read_direct_markers()
    direct_values = direct["matrix_values"]
    relative_differences = [
        abs(bridge - direct_value) / max(abs(bridge), abs(direct_value))
        for bridge, direct_value in zip(bridge_values, direct_values, strict=True)
    ]
    exchange_relative_differences = [
        abs(bridge - exchanged) / max(abs(bridge), abs(exchanged))
        for bridge, exchanged in zip(bridge_values, exchanged_values, strict=True)
    ]
    if maximum_conservation_residual > 1.0e-12:
        raise RuntimeError("deterministic points violate four-momentum conservation")
    if maximum_mass_squared > 1.0e-9:
        raise RuntimeError("deterministic points are not massless")
    if not all(value < 0.0 for value in photon_virtualities):
        raise RuntimeError("a deterministic point lacks a spacelike photon")
    if not all(
        math.isfinite(value) and value > 0.0
        for value in bridge_values + direct_values + exchanged_values
    ):
        raise RuntimeError("a matrix value is not positive and finite")
    if max(relative_differences) > 5.0e-14:
        raise RuntimeError("bridge/direct mismatch at a deterministic point")
    if max(exchange_relative_differences) > 5.0e-14:
        raise RuntimeError("identical-final-state exchange mismatch")
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
        "FinalIdentityDivisorDerivedFromGeneratedPDGs": True,
        "GeneratedIDENMatchesDerivedAverages": True,
        "BridgeMetadataMatchesGeneratedSource": True,
        "ThreeSpacelikeMasslessConservedPoints": True,
        "BridgeMatchesDirectGeneratedRoutineAtAllPoints": True,
        "IdenticalFinalGluonExchangeInvariantAtAllPoints": True,
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
        "RepeatedFinalPDGs": generated["repeated_final_pdgs"],
        "RepeatedFinalPositionsZeroBased": duplicate_positions,
        "CopiedLocalMetadata": local,
        "AlphaS": 0.118,
        "PhotonQ2Values": photon_virtualities,
        "MaximumConservationResidual": maximum_conservation_residual,
        "MaximumExternalMassSquared": maximum_mass_squared,
        "DirectMatrixElements": direct_values,
        "BridgeMatrixElements": bridge_values,
        "ExchangedFinalMatrixElements": exchanged_values,
        "BridgeDirectRelativeDifferences": relative_differences,
        "IdenticalFinalExchangeRelativeDifferences": exchange_relative_differences,
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

    print("HQG_MADGRAPH_S05_SUCCESS")
    print(f"HQG_MADGRAPH_S05_DIAGRAMS={generated['diagram_count']}")
    print(f"HQG_MADGRAPH_S05_IDEN={generated['identity_factor']}")
    print(f"MAX_BRIDGE_DIRECT_RELATIVE_DIFFERENCE={max(relative_differences):.17g}")
    print(
        "MAX_IDENTICAL_FINAL_EXCHANGE_RELATIVE_DIFFERENCE="
        f"{max(exchange_relative_differences):.17g}"
    )
    print(f"HQG_MADGRAPH_S05_OUTPUT={OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HQG_MADGRAPH_S05_FATAL: {error}", flush=True)
        raise
