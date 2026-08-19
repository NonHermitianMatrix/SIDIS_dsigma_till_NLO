#!/usr/bin/env python3
from __future__ import annotations

import ctypes
import hashlib
import json
import math
import os
from pathlib import Path


ROOT = Path(__file__).resolve().parent
BRIDGE = ROOT / "s03_libhqqprime_madgraph_bridge.so"
PARAM_CARD = ROOT / "generated_process" / "Cards" / "param_card.dat"
LOCAL_POINT = ROOT / "s07_local_tensor_and_projections.json"
OUTPUT = ROOT / "s08_azimuthal_average_validation.json"

EXPECTED_SHA256 = {
    BRIDGE: "847bfb7a3ef4498cdf7040e01e0e51ed7b38864025be646f0cfd7f1a580e8b5d",
    PARAM_CARD: "55bb009a781370ab3fdfb523be00d0c8f68ffec442d12eb41b8d2da50307cf64",
    LOCAL_POINT: "79cf7e55218025f35c601c5e08a688644347f227ecd3061aa9d95b03608b9b00",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def minkowski_dot(first: list[float], second: list[float]) -> float:
    return first[0] * second[0] - sum(
        first[index] * second[index] for index in range(1, 4)
    )


def add(first: list[float], second: list[float]) -> list[float]:
    return [first[index] + second[index] for index in range(4)]


def subtract(first: list[float], second: list[float]) -> list[float]:
    return [first[index] - second[index] for index in range(4)]


def boost_to_rest(momentum: list[float], beta: list[float]) -> list[float]:
    beta_squared = sum(component * component for component in beta)
    if not 0.0 < beta_squared < 1.0:
        raise ValueError(f"invalid rest-frame beta squared: {beta_squared}")
    gamma = 1.0 / math.sqrt(1.0 - beta_squared)
    beta_dot_p = sum(beta[index] * momentum[index + 1] for index in range(3))
    energy = gamma * (momentum[0] - beta_dot_p)
    coefficient = (gamma - 1.0) * beta_dot_p / beta_squared - gamma * momentum[0]
    spatial = [
        momentum[index + 1] + coefficient * beta[index] for index in range(3)
    ]
    return [energy, *spatial]


def rotate_spatial(
    momentum: list[float], axis: list[float], angle: float
) -> list[float]:
    vector = momentum[1:]
    cosine = math.cos(angle)
    sine = math.sin(angle)
    axis_dot_vector = sum(axis[index] * vector[index] for index in range(3))
    cross = [
        axis[1] * vector[2] - axis[2] * vector[1],
        axis[2] * vector[0] - axis[0] * vector[2],
        axis[0] * vector[1] - axis[1] * vector[0],
    ]
    rotated = [
        vector[index] * cosine
        + cross[index] * sine
        + axis[index] * axis_dot_vector * (1.0 - cosine)
        for index in range(3)
    ]
    return [momentum[0], *rotated]


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


def evaluate(
    library: ctypes.CDLL, momenta: list[list[float]], alpha_s: float
) -> float:
    flat_particle_major = [component for momentum in momenta for component in momentum]
    momentum_array = (ctypes.c_double * 24)(*flat_particle_major)
    answer = ctypes.c_double(0.0)
    library.hqqprime_mg_eval(momentum_array, alpha_s, ctypes.byref(answer))
    return answer.value


def maximum_conservation_residual(momenta: list[list[float]]) -> float:
    residual = [
        momenta[0][component]
        + momenta[1][component]
        - sum(momenta[index][component] for index in range(2, 6))
        for component in range(4)
    ]
    return max(abs(component) for component in residual)


def maximum_mass_squared(momenta: list[list[float]]) -> float:
    return max(abs(minkowski_dot(momentum, momentum)) for momentum in momenta)


def relative_difference(first: float, second: float) -> float:
    if first == second:
        return 0.0
    return abs(first - second) / max(abs(first), abs(second))


def main() -> None:
    if OUTPUT.exists():
        raise FileExistsError(OUTPUT)
    for path, expected in EXPECTED_SHA256.items():
        observed = sha256(path)
        if observed != expected:
            raise RuntimeError(f"hash mismatch for {path.name}: {observed}")

    with LOCAL_POINT.open(encoding="utf-8") as stream:
        local_point = json.load(stream)
    if (
        local_point.get("stage")
        != "HqqprimeLocalTensorAndProjectionValidation-v1"
        or local_point.get("status") != "complete"
        or not all(local_point.get("checks", {}).values())
    ):
        raise RuntimeError("unexpected or incomplete projected-local result")

    os.chdir(ROOT)
    library = ctypes.CDLL(str(BRIDGE))
    library.hqqprime_mg_init.argtypes = [ctypes.c_char_p]
    library.hqqprime_mg_init.restype = None
    library.hqqprime_mg_eval.argtypes = [
        ctypes.POINTER(ctypes.c_double),
        ctypes.c_double,
        ctypes.POINTER(ctypes.c_double),
    ]
    library.hqqprime_mg_eval.restype = None
    library.hqqprime_mg_init(b"generated_process/Cards/param_card.dat")

    lab_momenta = tetrahedron_momenta()
    photon_lab = subtract(lab_momenta[0], lab_momenta[2])
    hadronic_total_lab = add(lab_momenta[1], photon_lab)
    beta = [component / hadronic_total_lab[0] for component in hadronic_total_lab[1:]]
    rest_momenta = [boost_to_rest(momentum, beta) for momentum in lab_momenta]

    photon_rest = subtract(rest_momenta[0], rest_momenta[2])
    hadronic_total_rest = add(rest_momenta[1], photon_rest)
    incoming_quark_spatial = rest_momenta[1][1:]
    quark_norm = math.sqrt(sum(component * component for component in incoming_quark_spatial))
    axis = [component / quark_norm for component in incoming_quark_spatial]

    alpha_s = float(local_point["parameter_card"]["alpha_s"])
    identity_correction = int(
        local_point["fixed_orientation"]["madgraph_final_identity_correction"]
    )
    angles = [0.5 * math.pi * index for index in range(4)]
    raw_values: list[float] = []
    labeled_values: list[float] = []
    conservation_residuals: list[float] = []
    mass_residuals: list[float] = []
    photon_shifts: list[float] = []
    q2_shifts: list[float] = []

    reference_q2 = -minkowski_dot(photon_rest, photon_rest)
    for angle in angles:
        rotated = [list(momentum) for momentum in rest_momenta]
        rotated[0] = rotate_spatial(rest_momenta[0], axis, angle)
        rotated[2] = rotate_spatial(rest_momenta[2], axis, angle)
        rotated_photon = subtract(rotated[0], rotated[2])

        raw_value = evaluate(library, rotated, alpha_s)
        raw_values.append(raw_value)
        labeled_values.append(identity_correction * raw_value)
        conservation_residuals.append(maximum_conservation_residual(rotated))
        mass_residuals.append(maximum_mass_squared(rotated))
        photon_shifts.append(
            max(abs(rotated_photon[index] - photon_rest[index]) for index in range(4))
        )
        q2_shifts.append(
            abs(-minkowski_dot(rotated_photon, rotated_photon) - reference_q2)
        )

    madgraph_average = math.fsum(labeled_values) / len(labeled_values)
    local_value = float(
        local_point["projected"]["copied_s07_projected_local_matrix"]
    )
    average_relative_difference = relative_difference(madgraph_average, local_value)
    first_angle_reference = float(
        local_point["fixed_orientation"]["madgraph_labeled_matrix"]
    )
    first_angle_relative_difference = relative_difference(
        labeled_values[0], first_angle_reference
    )

    scale = max(momentum[0] for momentum in rest_momenta)
    checks = {
        "input_hashes_exact": True,
        "hadronic_system_in_rest_frame": max(
            abs(component) for component in hadronic_total_rest[1:]
        )
        < 2.0e-12 * scale,
        "all_rotated_points_conserve_four_momentum": max(conservation_residuals)
        < 2.0e-12 * scale,
        "all_rotated_external_states_massless": max(mass_residuals)
        < 2.0e-9 * scale * scale,
        "photon_four_momentum_fixed": max(photon_shifts) < 2.0e-12 * scale,
        "photon_virtuality_fixed": max(q2_shifts) < 2.0e-9 * reference_q2,
        "zero_angle_reproduces_accepted_madgraph_point": first_angle_relative_difference
        < 2.0e-13,
        "four_angle_average_matches_projected_local_s07": average_relative_difference
        < 2.0e-10,
    }
    if not all(checks.values()):
        raise RuntimeError(
            "azimuthal-average validation failed: "
            + json.dumps(
                {
                    "raw_values": raw_values,
                    "labeled_values": labeled_values,
                    "average": madgraph_average,
                    "local": local_value,
                    "relative_difference": average_relative_difference,
                    "checks": checks,
                },
                sort_keys=True,
            )
        )

    output = {
        "stage": "HqqprimeMadGraphAzimuthalAverageValidation-v1",
        "status": "complete",
        "azimuth_angles_radians": angles,
        "madgraph_raw_matrix_elements": raw_values,
        "madgraph_final_identity_correction": identity_correction,
        "madgraph_labeled_matrix_elements": labeled_values,
        "madgraph_azimuthal_average": madgraph_average,
        "copied_s07_projected_local_matrix_element": local_value,
        "relative_difference": average_relative_difference,
        "zero_angle_reference_relative_difference": first_angle_relative_difference,
        "maximum_conservation_residual": max(conservation_residuals),
        "maximum_external_mass_squared": max(mass_residuals),
        "maximum_photon_momentum_shift": max(photon_shifts),
        "maximum_q2_shift": max(q2_shifts),
        "alpha_s": alpha_s,
        "checks": checks,
        "sha256": {path.name: expected for path, expected in EXPECTED_SHA256.items()},
        "interpretation": (
            "The four-angle quadrature removes rank-two lepton-hadron azimuthal "
            "harmonics while holding q, p, and all hadronic invariants fixed."
        ),
    }
    temporary = OUTPUT.with_name(f"{OUTPUT.name}.tmp.{os.getpid()}")
    if temporary.exists():
        raise FileExistsError(temporary)
    with temporary.open("x", encoding="utf-8") as stream:
        json.dump(output, stream, indent=2, sort_keys=True)
        stream.write("\n")
    with temporary.open(encoding="utf-8") as stream:
        reloaded = json.load(stream)
    if reloaded.get("status") != "complete" or not all(
        reloaded.get("checks", {}).values()
    ):
        raise RuntimeError("temporary S08 output failed reload validation")
    os.replace(temporary, OUTPUT)

    print(f"S08_MADGRAPH_LABELED_VALUES={labeled_values}")
    print(f"S08_MADGRAPH_AZIMUTHAL_AVERAGE={madgraph_average:.17e}")
    print(f"S08_PROJECTED_LOCAL={local_value:.17e}")
    print(f"S08_RELATIVE_DIFFERENCE={average_relative_difference:.17e}")
    print("S08_SUCCESS")


if __name__ == "__main__":
    main()
