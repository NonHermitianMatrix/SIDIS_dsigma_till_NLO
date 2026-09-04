#!/usr/bin/env python3
"""Evaluate and validate the generated Hqq_v2 MadGraph reference."""

from __future__ import annotations

import ctypes
from collections import Counter
from decimal import Decimal
import hashlib
import json
import math
import os
from pathlib import Path
import re
import sys
from typing import Any


sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parent
GENERATED = ROOT / "generated_process"
SUBPROCESSES = GENERATED / "SubProcesses"
BRIDGE = ROOT / "s02_libhqq_v2_madgraph_bridge.so"
MATRIX_LIBRARY = SUBPROCESSES / "liball_2me.so"
PARAM_CARD = GENERATED / "Cards" / "param_card.dat"
ALL_MATRIX = SUBPROCESSES / "all_matrix.f"
GENERATION_CARD = ROOT / "s01_generate_hqq_v2_standalone.mg5"
GENERATION_LOG = ROOT / "s01_generate_hqq_v2_standalone.log"
OUTPUT = ROOT / "s03_madgraph_reference.json"

STAGE_VERSION = "HqqV2MadGraphS03-v1"
EXPECTED_HASHES = {
    GENERATION_CARD: "4b285a44cd7c2a7951c5c7e8a6c54b772407e27c88835637cf835d12b1d3e016",
    GENERATION_LOG: "74a21bb432a3926af08a3d5a3662c8513ba8ff8f912dd1e6f23cb2acddf69199",
    GENERATED / "MGMEVersion.txt": "78f751fdc6ec75262557675ab2349c82a3b3c161fcf4ed81d4b1a3f6d9d5df47",
    PARAM_CARD: "55bb009a781370ab3fdfb523be00d0c8f68ffec442d12eb41b8d2da50307cf64",
    ALL_MATRIX: "13764a16588bce5678cf4866aef9434e8abe4fde437e30c411ed50f2b274d56e",
    SUBPROCESSES / "P1_emu_emugg_no_zh" / "matrix.f":
        "0120dfd14d7743c02ec36fafa9bc0f06d602ff0c896af83e5deafcae6b6a1962",
    SUBPROCESSES / "P2_emu_emuuux_no_zh" / "matrix.f":
        "aceeb6caaed7ea57aafd34348a36ceafaffdd1b2cbeb230ced19417d1f49bd77",
    SUBPROCESSES / "P3_emu_emuddx_no_zh" / "matrix.f":
        "76baa973586f9b2d90e45ed9e9dff57e0dbc2f966f79fc6f91d4fbb86bb849c8",
    ROOT / "s02_madgraph_c_bridge.f90":
        "35b3262b79f301dce3342e46a89eb0fafa171fa9be9c1bb46a782ec3b8e9db01",
    ROOT / "s02_build_generated_library.log":
        "07db20d5eacab83b1282d8a7d6b721f96fe7c50965f66b99a3390b6289a5c42e",
    ROOT / "s02_compile_bridge.log":
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    MATRIX_LIBRARY: "1295bb0b67009747184d329706b5e7e67030fc0cd1f673f2f54e9c0d54cb3491",
    BRIDGE: "7004a082805d69e4a3ac751530d8f1f15fea74eacd1d7c7e88ca47a79edb3b30",
}

PROCESS_LAYOUT = {
    1: {
        "family": "Hqq;gg",
        "directory": "P1_emu_emugg_no_zh",
        "command": "e- u > e- u g g QCD<=2 QED<=2 / z h @1",
    },
    2: {
        "family": "Hqq;q_qbar_sameFlavor",
        "directory": "P2_emu_emuuux_no_zh",
        "command": "e- u > e- u u u~ QCD<=2 QED<=2 / z h @2",
    },
    3: {
        "family": "Hqq;qPrime_qbarPrime",
        "directory": "P3_emu_emuddx_no_zh",
        "command": "e- u > e- u d d~ QCD<=2 QED<=2 / z h @3",
    },
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def relative_difference(left: float, right: float) -> float:
    scale = max(abs(left), abs(right))
    return abs(left - right) / scale if scale else 0.0


def parse_dispatcher_pdgs() -> dict[int, list[int]]:
    pattern = re.compile(
        r":\s*\(([-+0-9, ]+)\)\s*#\s*M(\d+)_\s+(\d+)\s*$"
    )
    parsed: dict[int, list[int]] = {}
    for line in ALL_MATRIX.read_text(encoding="utf-8").splitlines():
        match = pattern.search(line)
        if match is None:
            continue
        matrix_index = int(match.group(2))
        process_id = int(match.group(3))
        pdgs = [int(value.strip()) for value in match.group(1).split(",")]
        require(matrix_index == process_id - 1, "dispatcher matrix/process order changed")
        require(len(pdgs) == 6, "dispatcher external-state count changed")
        require(process_id not in parsed, "duplicate dispatcher process ID")
        parsed[process_id] = pdgs
    require(set(parsed) == set(PROCESS_LAYOUT), "dispatcher process set changed")
    return parsed


def parse_process_metadata(
    process_id: int, definition: dict[str, str]
) -> dict[str, Any]:
    path = SUBPROCESSES / definition["directory"] / "matrix.f"
    text = path.read_text(encoding="utf-8")
    iden_match = re.search(r"^\s*DATA\s+IDEN/(\d+)/\s*$", text, re.MULTILINE)
    graph_match = re.search(
        r"^\s*PARAMETER\s*\(NGRAPHS=(\d+)\)\s*$", text, re.MULTILINE
    )
    beam_match = re.search(
        r"DATA\s*\(BEAMS_HELAVGFACTOR\(I\),I=1,2\)/(\d+),(\d+)/",
        text,
    )
    require(iden_match is not None, f"process {process_id} has no IDEN record")
    require(graph_match is not None, f"process {process_id} has no NGRAPHS record")
    require(
        beam_match is not None,
        f"process {process_id} has no beam-helicity-average record",
    )
    require(
        f"Process: {definition['command']}" in text,
        f"process {process_id} command changed",
    )
    return {
        "identity_denominator": int(iden_match.group(1)),
        "diagram_count": int(graph_match.group(1)),
        "beam_helicity_average_factors": [
            int(beam_match.group(1)),
            int(beam_match.group(2)),
        ],
        "matrix_path": str(path),
        "matrix_sha256": sha256(path),
    }


def parse_generation_counts() -> dict[int, int]:
    counts = [
        int(value)
        for value in re.findall(
            r"Process has\s+(\d+)\s+diagrams", GENERATION_LOG.read_text(encoding="utf-8")
        )
    ]
    require(len(counts) == len(PROCESS_LAYOUT), "generation-log process count changed")
    return {process_id: counts[process_id - 1] for process_id in PROCESS_LAYOUT}


def parse_sminputs() -> dict[int, Decimal]:
    values: dict[int, Decimal] = {}
    in_block = False
    for raw_line in PARAM_CARD.read_text(encoding="utf-8").splitlines():
        stripped = raw_line.strip()
        if stripped.lower().startswith("block "):
            in_block = stripped.lower().startswith("block sminputs")
            continue
        if not in_block or not stripped or stripped.startswith("#"):
            continue
        data = stripped.split("#", 1)[0].split()
        if len(data) >= 2:
            values[int(data[0])] = Decimal(data[1])
    require(1 in values and 3 in values, "parameter card lacks aEWM1 or aS")
    require(values[1] > 0 and values[3] > 0, "parameter-card couplings are not positive")
    return values


def decimal_record(value: Decimal) -> dict[str, Any]:
    numerator, denominator = value.as_integer_ratio()
    return {
        "decimal": format(value, "f"),
        "numerator": numerator,
        "denominator": denominator,
        "float": float(value),
    }


def minkowski_dot(first: list[float], second: list[float]) -> float:
    return first[0] * second[0] - sum(
        left * right for left, right in zip(first[1:], second[1:])
    )


def benchmark() -> tuple[dict[str, float], list[list[float]]]:
    incoming_energy = 500.0
    outgoing_count = 4
    outgoing_energy = 2.0 * incoming_energy / outgoing_count
    root_three = math.sqrt(3.0)
    momenta = [
        [incoming_energy, 0.0, 0.0, incoming_energy],
        [incoming_energy, 0.0, 0.0, -incoming_energy],
        [outgoing_energy] + [outgoing_energy / root_three] * 3,
        [
            outgoing_energy,
            outgoing_energy / root_three,
            -outgoing_energy / root_three,
            -outgoing_energy / root_three,
        ],
        [
            outgoing_energy,
            -outgoing_energy / root_three,
            outgoing_energy / root_three,
            -outgoing_energy / root_three,
        ],
        [
            outgoing_energy,
            -outgoing_energy / root_three,
            -outgoing_energy / root_three,
            outgoing_energy / root_three,
        ],
    ]
    conservation = [
        momenta[0][component]
        + momenta[1][component]
        - sum(momentum[component] for momentum in momenta[2:])
        for component in range(4)
    ]
    mass_squares = [minkowski_dot(momentum, momentum) for momentum in momenta]
    photon = [
        momenta[0][component] - momenta[2][component] for component in range(4)
    ]
    photon_square = minkowski_dot(photon, photon)
    maximum_conservation = max(abs(value) for value in conservation)
    maximum_mass_square = max(abs(value) for value in mass_squares)
    require(maximum_conservation <= 1.0e-12, "benchmark violates momentum conservation")
    require(maximum_mass_square <= 1.0e-9, "benchmark external state is not massless")
    require(photon_square < 0.0, "benchmark photon is not spacelike")
    construction = {
        "incoming_energy": incoming_energy,
        "outgoing_count": outgoing_count,
        "outgoing_energy": outgoing_energy,
        "maximum_conservation_residual": maximum_conservation,
        "maximum_external_mass_squared": maximum_mass_square,
        "photon_q2": photon_square,
    }
    return construction, momenta


def identical_final_state_factor(pdgs: list[int]) -> int:
    multiplicities = Counter(pdgs[2:])
    return math.prod(math.factorial(count) for count in multiplicities.values())


def configure_libraries() -> tuple[ctypes.CDLL, ctypes.CDLL]:
    os.chdir(ROOT)
    generated = ctypes.CDLL(str(MATRIX_LIBRARY), mode=ctypes.RTLD_GLOBAL)
    bridge = ctypes.CDLL(str(BRIDGE))
    bridge.hqq_v2_mg_init.argtypes = [ctypes.c_char_p, ctypes.POINTER(ctypes.c_int)]
    bridge.hqq_v2_mg_init.restype = None
    bridge.hqq_v2_mg_eval.argtypes = [
        ctypes.POINTER(ctypes.c_int),
        ctypes.c_int,
        ctypes.POINTER(ctypes.c_double),
        ctypes.c_double,
        ctypes.POINTER(ctypes.c_double),
        ctypes.POINTER(ctypes.c_int),
    ]
    bridge.hqq_v2_mg_eval.restype = None
    status = ctypes.c_int(-1)
    bridge.hqq_v2_mg_init(
        b"generated_process/Cards/param_card.dat", ctypes.byref(status)
    )
    require(status.value == 0, "bridge rejected generated parameter card")
    return generated, bridge


def momentum_array(momenta: list[list[float]]) -> Any:
    return (ctypes.c_double * 24)(
        *(component for momentum in momenta for component in momentum)
    )


def evaluate_bridge(
    bridge: ctypes.CDLL,
    process_id: int,
    pdgs: list[int],
    momenta: list[list[float]],
    alpha_s: float,
) -> float:
    pdg_array = (ctypes.c_int * 6)(*pdgs)
    answer = ctypes.c_double(0.0)
    status = ctypes.c_int(-1)
    bridge.hqq_v2_mg_eval(
        pdg_array,
        process_id,
        momentum_array(momenta),
        alpha_s,
        ctypes.byref(answer),
        ctypes.byref(status),
    )
    require(status.value == 0, f"bridge rejected process {process_id}")
    require(math.isfinite(answer.value) and answer.value > 0.0,
            f"bridge result for process {process_id} is not positive and finite")
    return answer.value


def evaluate_direct(
    generated: ctypes.CDLL, matrix_index: int, momenta: list[list[float]]
) -> float:
    routine = getattr(generated, f"m{matrix_index}_smatrix_")
    routine.argtypes = [ctypes.POINTER(ctypes.c_double), ctypes.POINTER(ctypes.c_double)]
    routine.restype = None
    answer = ctypes.c_double(0.0)
    routine(momentum_array(momenta), ctypes.byref(answer))
    require(math.isfinite(answer.value) and answer.value > 0.0,
            f"direct M{matrix_index} result is not positive and finite")
    return answer.value


def atomic_json(path: Path, payload: dict[str, Any]) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    require(not path.exists() and not temporary.exists(), f"refusing to overwrite {path}")
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
    print("HQQV2_MADGRAPH_S03_STAGE=validate generated provenance")
    for path, expected in EXPECTED_HASHES.items():
        require(path.is_file(), f"required input is missing: {path}")
        require(sha256(path) == expected, f"input hash changed: {path}")
    require(
        (GENERATED / "MGMEVersion.txt").read_text(encoding="utf-8").strip() == "5.3.7.0",
        "generated MadGraph version changed",
    )

    dispatcher_pdgs = parse_dispatcher_pdgs()
    generation_counts = parse_generation_counts()
    metadata: dict[int, dict[str, Any]] = {}
    for process_id, definition in PROCESS_LAYOUT.items():
        item = parse_process_metadata(process_id, definition)
        item["pdgs"] = dispatcher_pdgs[process_id]
        item["labeled_final_state_factor"] = identical_final_state_factor(
            dispatcher_pdgs[process_id]
        )
        require(
            item["diagram_count"] == generation_counts[process_id],
            f"process {process_id} generated/logged diagram counts differ",
        )
        require(
            item["identity_denominator"] % item["labeled_final_state_factor"] == 0,
            f"process {process_id} IDEN is incompatible with final-state multiplicities",
        )
        metadata[process_id] = item
    initial_state_denominators = {
        item["identity_denominator"] // item["labeled_final_state_factor"]
        for item in metadata.values()
    }
    require(
        len(initial_state_denominators) == 1,
        "generated processes do not share one initial-state averaging denominator",
    )
    initial_color_states = set()
    for process_id, item in metadata.items():
        spin_denominator = math.prod(item["beam_helicity_average_factors"])
        full_known_denominator = spin_denominator * item["labeled_final_state_factor"]
        require(
            item["identity_denominator"] % full_known_denominator == 0,
            f"process {process_id} IDEN does not factor into spin/color/identity pieces",
        )
        initial_color_states.add(
            item["identity_denominator"] // full_known_denominator
        )
    require(
        len(initial_color_states) == 1,
        "generated processes do not share one incoming color-state count",
    )

    sminputs = parse_sminputs()
    alpha_em_inverse = decimal_record(sminputs[1])
    alpha_s = decimal_record(sminputs[3])
    construction, momenta = benchmark()
    generated, bridge = configure_libraries()

    print("HQQV2_MADGRAPH_S03_STAGE=evaluate direct and bridge routines")
    processes: dict[str, Any] = {}
    for process_id, definition in PROCESS_LAYOUT.items():
        pdgs = dispatcher_pdgs[process_id]
        direct = evaluate_direct(generated, process_id - 1, momenta)
        bridged = evaluate_bridge(
            bridge, process_id, pdgs, momenta, alpha_s["float"]
        )
        bridge_direct_relative = relative_difference(bridged, direct)
        require(
            bridge_direct_relative <= 5.0e-14,
            f"process {process_id} bridge/direct closure failed",
        )
        result: dict[str, Any] = {
            "family": definition["family"],
            "process_command": definition["command"],
            "metadata": metadata[process_id],
            "direct_matrix_element": direct,
            "bridge_matrix_element": bridged,
            "bridge_direct_relative_difference": bridge_direct_relative,
            "labeled_madgraph_matrix_element": (
                metadata[process_id]["labeled_final_state_factor"] * bridged
            ),
        }
        if process_id in (1, 2):
            exchanged = [list(momentum) for momentum in momenta]
            first, second = ((4, 5) if process_id == 1 else (3, 4))
            exchanged[first], exchanged[second] = exchanged[second], exchanged[first]
            exchanged_value = evaluate_bridge(
                bridge, process_id, pdgs, exchanged, alpha_s["float"]
            )
            exchange_relative = relative_difference(bridged, exchanged_value)
            require(
                exchange_relative <= 5.0e-14,
                f"process {process_id} identical-particle exchange gate failed",
            )
            result["exchanged_matrix_element"] = exchanged_value
            result["identical_exchange_relative_difference"] = exchange_relative
        processes[str(process_id)] = result

    invalid_answer = ctypes.c_double(-1.0)
    invalid_status = ctypes.c_int(-1)
    bridge.hqq_v2_mg_eval(
        (ctypes.c_int * 6)(*dispatcher_pdgs[1]),
        99,
        momentum_array(momenta),
        alpha_s["float"],
        ctypes.byref(invalid_answer),
        ctypes.byref(invalid_status),
    )
    require(invalid_status.value == 1, "invalid process ID was not rejected")

    payload = {
        "Stage": STAGE_VERSION,
        "Status": "CompleteMadGraphReference",
        "Program": {
            "Path": str(Path(__file__).resolve()),
            "SHA256": sha256(Path(__file__).resolve()),
        },
        "Generator": {
            "Name": "MadGraph5_aMC@NLO",
            "Version": "3.7.0",
            "GeneratedVersionRecord": "5.3.7.0",
        },
        "GeneratedInputs": {
            str(path): digest for path, digest in EXPECTED_HASHES.items()
        },
        "CouplingsFromParameterCard": {
            "AlphaS": alpha_s,
            "AlphaEMInverse": alpha_em_inverse,
        },
        "BenchmarkConstruction": construction,
        "MomentaParticleMajor": momenta,
        "InitialStateAveragingDenominatorFromIDEN": next(
            iter(initial_state_denominators)
        ),
        "InitialColorStatesFromIDEN": next(iter(initial_color_states)),
        "Processes": processes,
        "Checks": {
            "GeneratedHashesExact": True,
            "GeneratedVersionExact": True,
            "DispatcherPDGsParsed": True,
            "DiagramCountsAgreeWithGenerationLog": True,
            "ProcessCommandsExact": True,
            "IdentityFactorsDerivedFromFinalPDGs": True,
            "BeamHelicityFactorsParsed": True,
            "InitialStateAveragingCommon": True,
            "InitialColorStatesDerivedFromIDEN": True,
            "CouplingsParsedFromParameterCard": True,
            "MomentumConservation": True,
            "AllExternalStatesMassless": True,
            "PhotonSpacelike": True,
            "AllBridgeValuesMatchDirectGeneratedRoutines": True,
            "IdenticalParticleExchangesInvariant": True,
            "InvalidProcessIDRejected": True,
        },
    }
    atomic_json(OUTPUT, payload)
    print("HQQV2_MADGRAPH_S03_PROCESS_COUNT=3")
    print(f"HQQV2_MADGRAPH_S03_OUTPUT={OUTPUT}")
    print("HQQV2_MADGRAPH_S03_SUCCESS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
