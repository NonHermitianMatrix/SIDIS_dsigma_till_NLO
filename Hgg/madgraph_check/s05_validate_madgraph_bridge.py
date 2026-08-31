#!/usr/bin/env python3
"""Validate the Hgg ISO-C bridge against the generated MadGraph routine."""

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
BRIDGE_PATH = CHECK_DIR / "s03_libhgg_madgraph_bridge.so"
PARAM_CARD_PATH = CHECK_DIR / "generated_process" / "Cards" / "param_card.dat"
DIRECT_LOG_PATH = CHECK_DIR / "s04_direct_madgraph_reference.log"
MATRIX_PATH = (
    CHECK_DIR
    / "generated_process"
    / "SubProcesses"
    / "P1_emg_emguux_no_zh"
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

STAGE_VERSION = "HggMadGraphBridgeValidation-v1"
EXPECTED_MANIFEST_SHA256 = (
    "975d0676c3bdcebb4ab5fff260289f3e4296d8ec7c6e351785f2a5852df1bb82"
)
EXPECTED_S01_RESULT_SHA256 = (
    "f9dc6222b793830691c2a82db1d2ce045b2cb92ebd2dacc21948382adf3fa4be"
)
EXPECTED_S06_RESULT_SHA256 = (
    "dd1ccc91960f3a37b4acc397acc90f91da64340a79dd89132cdf4fcd9f5616e3"
)
EXPECTED_S02_CARD_SHA256 = (
    "67f1fe219f3760b150cc2727994d525f53261fdbc538399cd6b721cf34418794"
)
EXPECTED_PROCESS_CARD_SHA256 = (
    "d5c81ac3cb79f3493d0930ab435515335ea07a4f79b3d0aed0276d7ee70aa53b"
)
EXPECTED_ALL_MATRIX_SHA256 = (
    "199bc302f70bc4e8c1b93475ea0073918a865843db421eac2624d12ffa733821"
)
EXPECTED_MATRIX_SHA256 = (
    "1a3e574c133c86dcf98fd5184f1670c90bfd47be0f80b1c3eb92e504427fedc8"
)
EXPECTED_PDGS = [11, 21, 11, 21, 2, -2]


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
        '$LoadFeynArts=True; Needs["FeynCalc`"]; $PrePrint=.; '
        f's01=Get["{s01_path}"]; s06=Get["{s06_path}"]; '
        'tops=FeynArts`CreateTopologies[0,2->3]; '
        'ins=FeynArts`InsertFields[tops,{FeynArts`V[1],FeynArts`V[5]}->'
        '{FeynArts`V[5],FeynArts`F[3,{1}],-FeynArts`F[3,{1}]},'
        'FeynArts`InsertionLevel->{FeynArts`Particles},FeynArts`Model->"SMQCD"]; '
        'names=Names["*M$ClassesDescription*"]; '
        'If[Length[names]=!=1,Exit[2]]; cls=ToExpression[First[names]]; '
        'ce[c_]:=FirstCase[cls,HoldPattern[FeynArts`F[c]==rhs_]:>rhs,'
        'Missing["NotFound"]]; '
        'qn[c_]:=FirstCase[ce[c],Rule[k_,v_]/;'
        'SymbolName[Unevaluated[k]]==="QuantumNumbers":>v,'
        'Missing["NotFound"],Infinity]; eq[c_]:=First[qn[c]]; '
        'markers=DeleteDuplicates[Cases[{eq[3],eq[4]},s_Symbol/;'
        'SymbolName[Unevaluated[s]]==="Charge",Infinity]]; '
        'If[Length[markers]=!=1,Exit[3]]; marker=First[markers]; '
        'upCharge=Simplify[eq[3]/.marker->1]; '
        'downCharge=Simplify[eq[4]/.marker->1]; '
        'average=ReleaseHold[s06["InitialStateAverage"]]; '
        'denominator=Together[1/(average/.{D->4,FeynCalc`SUNN->3})]; '
        'outgoing=s01["Conventions","OutgoingFields"]; '
        'symmetry=Times@@(Factorial/@Values[Counts[outgoing]]); '
        'payload=<|"diagram_count"->s01["DiagramCounts",'
        '"TotalQCDDiagramsAtThisStage"],'
        '"incoming_gluon_average_denominator_su3_d4"->denominator,'
        '"final_identity_divisor"->symmetry,'
        '"f3_charge_numerator"->Numerator[upCharge],'
        '"f3_charge_denominator"->Denominator[upCharge],'
        '"f4_charge_numerator"->Numerator[downCharge],'
        '"f4_charge_denominator"->Denominator[downCharge]|>; '
        'WriteString[First[$Output],"HGG_S05_LOCAL_METADATA="<>'
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
    marker = "HGG_S05_LOCAL_METADATA="
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
        "matrix": "HGG_DIRECT_MATRIX=",
        "maximum_conservation_residual": "HGG_DIRECT_MAX_CONSERVATION=",
        "maximum_mass_squared": "HGG_DIRECT_MAX_MASS2=",
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
    library.hgg_mg_eval(momentum_array, alpha_s, ctypes.byref(answer))
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
        or manifest.get("StageVersion") != "HggMadGraphInputProvenance-v1"
        or manifest.get("Status") != "Complete"
        or not all(manifest.get("Checks", {}).values())
        or sha256_file(COPIES_DIR / "s01_result") != EXPECTED_S01_RESULT_SHA256
        or sha256_file(COPIES_DIR / "s06_result") != EXPECTED_S06_RESULT_SHA256
    ):
        raise RuntimeError("S01/copy provenance is stale")

    if (
        sha256_file(CHECK_DIR / "s02_generate_hgg_standalone.mg5")
        != EXPECTED_S02_CARD_SHA256
        or sha256_file(PROCESS_CARD_PATH) != EXPECTED_PROCESS_CARD_SHA256
        or sha256_file(ALL_MATRIX_PATH) != EXPECTED_ALL_MATRIX_SHA256
        or sha256_file(MATRIX_PATH) != EXPECTED_MATRIX_SHA256
        or "generate e- g > e- g u u~ / z h QED=2 QCD=2 @1"
        not in PROCESS_CARD_PATH.read_text(encoding="utf-8")
    ):
        raise RuntimeError("generated source provenance or process changed")

    generated = parse_generated_metadata()
    local = derive_local_metadata()
    derived_identity_factor = (
        int(local["incoming_gluon_average_denominator_su3_d4"])
        * int(generated["beam_helicity_average_factors"][0])
        * int(generated["final_identity_divisor"])
    )
    if (
        generated["pdgs"] != EXPECTED_PDGS
        or generated["diagram_count"] != int(local["diagram_count"])
        or generated["final_identity_divisor"] != 1
        or int(local["final_identity_divisor"]) != 1
        or int(local["f3_charge_numerator"]) != 2
        or int(local["f3_charge_denominator"]) != 3
        or generated["identity_factor"] != derived_identity_factor
    ):
        raise RuntimeError("generated process count, routing, or IDEN derivation failed")

    os.chdir(CHECK_DIR)
    library = ctypes.CDLL(str(BRIDGE_PATH))
    library.hgg_mg_init.argtypes = [ctypes.c_char_p]
    library.hgg_mg_init.restype = None
    library.hgg_mg_eval.argtypes = [
        ctypes.POINTER(ctypes.c_double),
        ctypes.c_double,
        ctypes.POINTER(ctypes.c_double),
    ]
    library.hgg_mg_eval.restype = None
    library.hgg_mg_metadata.argtypes = [
        ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int),
    ]
    library.hgg_mg_metadata.restype = None

    bridge_pdgs = (ctypes.c_int * 6)()
    bridge_identity = ctypes.c_int(0)
    library.hgg_mg_metadata(bridge_pdgs, ctypes.byref(bridge_identity))
    if list(bridge_pdgs) != generated["pdgs"]:
        raise RuntimeError("bridge PDG metadata differs from generated source")
    if bridge_identity.value != generated["identity_factor"]:
        raise RuntimeError("bridge IDEN metadata differs from generated source")

    library.hgg_mg_init(b"generated_process/Cards/param_card.dat")
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

    print("HGG_MADGRAPH_S05_SUCCESS")
    print(f"HGG_MADGRAPH_S05_DIAGRAMS={generated['diagram_count']}")
    print(f"HGG_MADGRAPH_S05_IDEN={generated['identity_factor']}")
    print(f"BRIDGE_DIRECT_RELATIVE_DIFFERENCE={relative_difference:.17g}")
    print(f"HGG_MADGRAPH_S05_OUTPUT={OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as error:
        print(f"HGG_MADGRAPH_S05_FATAL: {error}", flush=True)
        raise
