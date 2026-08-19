#!/usr/bin/env python3
from __future__ import annotations

import ctypes
import hashlib
import json
import math
import os
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parent
BRIDGE = ROOT / "s03_libhqqprime_madgraph_bridge.so"
PARAM_CARD = ROOT / "generated_process" / "Cards" / "param_card.dat"
POINT_VALIDATION = ROOT / "s08_azimuthal_average_validation.json"
LOCAL_EVALUATOR = ROOT / "s09_four_dimensional_physical_projections"
CSV_OUTPUT = ROOT / "s10_cut_phase_space_points.csv"
METADATA_OUTPUT = ROOT / "s10_cut_phase_space_metadata.json"

EXPECTED_SHA256 = {
    BRIDGE: "847bfb7a3ef4498cdf7040e01e0e51ed7b38864025be646f0cfd7f1a580e8b5d",
    PARAM_CARD: "55bb009a781370ab3fdfb523be00d0c8f68ffec442d12eb41b8d2da50307cf64",
    POINT_VALIDATION: "c869f3fa105253fb7aa6994fc21c29d696260e5087cbf322a767f00083670cfe",
    LOCAL_EVALUATOR: "51cb470c5309e06a8122dc48612078967a13b06710ff2b0784e553f755165722",
}

SQRT_S = 1000.0
S = SQRT_S * SQRT_S
TOTAL_TRIALS = 120_000
RANDOM_SEED = 2026081801

CUTS = {
    "q2_over_s_min": 0.08,
    "q2_over_s_max": 0.40,
    "shat_over_s_min": 0.25,
    "shat_over_s_max": 0.75,
    "min_sij_over_shat": 0.05,
    "min_minus_ui_over_shat_plus_q2": 0.05,
    "min_minus_ti_over_shat_plus_2q2": 0.03,
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def minkowski_dot(first: np.ndarray, second: np.ndarray) -> np.ndarray:
    return first[..., 0] * second[..., 0] - np.sum(
        first[..., 1:] * second[..., 1:], axis=-1
    )


def boost_to_rest(momentum: np.ndarray, beta: np.ndarray) -> np.ndarray:
    beta_squared = float(np.dot(beta, beta))
    if beta_squared < 1.0e-28:
        return momentum.copy()
    if not beta_squared < 1.0:
        raise ValueError(f"invalid beta squared: {beta_squared}")
    gamma = 1.0 / math.sqrt(1.0 - beta_squared)
    beta_dot_p = float(np.dot(beta, momentum[1:]))
    answer = np.empty(4, dtype=np.float64)
    answer[0] = gamma * (momentum[0] - beta_dot_p)
    coefficient = (
        (gamma - 1.0) * beta_dot_p / beta_squared - gamma * momentum[0]
    )
    answer[1:] = momentum[1:] + coefficient * beta
    return answer


def rotate_spatial(momentum: np.ndarray, axis: np.ndarray, angle: float) -> np.ndarray:
    answer = momentum.copy()
    vector = momentum[1:]
    cosine = math.cos(angle)
    sine = math.sin(angle)
    answer[1:] = (
        vector * cosine
        + np.cross(axis, vector) * sine
        + axis * float(np.dot(axis, vector)) * (1.0 - cosine)
    )
    return answer


def rambo_massless_four_body(
    trials: int, center_of_mass_energy: float, seed: int
) -> np.ndarray:
    rng = np.random.Generator(np.random.PCG64(seed))
    randoms = rng.random((trials, 4, 4), dtype=np.float64)
    cosine = 2.0 * randoms[..., 0] - 1.0
    azimuth = 2.0 * math.pi * randoms[..., 1]
    energy = -np.log(randoms[..., 2] * randoms[..., 3])
    sine = np.sqrt(np.maximum(0.0, 1.0 - cosine * cosine))

    auxiliary = np.empty((trials, 4, 4), dtype=np.float64)
    auxiliary[..., 0] = energy
    auxiliary[..., 1] = energy * sine * np.cos(azimuth)
    auxiliary[..., 2] = energy * sine * np.sin(azimuth)
    auxiliary[..., 3] = energy * cosine

    total = np.sum(auxiliary, axis=1)
    beta = total[:, 1:] / total[:, :1]
    beta_squared = np.sum(beta * beta, axis=1)
    gamma = 1.0 / np.sqrt(1.0 - beta_squared)
    beta_dot_p = np.sum(auxiliary[..., 1:] * beta[:, None, :], axis=2)
    rest_energy = gamma[:, None] * (auxiliary[..., 0] - beta_dot_p)
    coefficient = (
        ((gamma - 1.0) / beta_squared)[:, None] * beta_dot_p
        - gamma[:, None] * auxiliary[..., 0]
    )
    rest_spatial = auxiliary[..., 1:] + coefficient[..., None] * beta[:, None, :]
    invariant_mass = np.sqrt(
        np.maximum(
            0.0,
            total[:, 0] * total[:, 0] - np.sum(total[:, 1:] ** 2, axis=1),
        )
    )
    scale = center_of_mass_energy / invariant_mass

    momenta = np.empty_like(auxiliary)
    momenta[..., 0] = rest_energy * scale[:, None]
    momenta[..., 1:] = rest_spatial * scale[:, None, None]
    return momenta


def evaluate(
    library: ctypes.CDLL, momenta: np.ndarray, alpha_s: float
) -> float:
    contiguous = np.ascontiguousarray(momenta, dtype=np.float64)
    momentum_array = (ctypes.c_double * 24)(*contiguous.reshape(-1).tolist())
    answer = ctypes.c_double(0.0)
    library.hqqprime_mg_eval(momentum_array, alpha_s, ctypes.byref(answer))
    return answer.value


def conservation_residual(momenta: np.ndarray) -> float:
    residual = momenta[0] + momenta[1] - np.sum(momenta[2:], axis=0)
    return float(np.max(np.abs(residual)))


def maximum_mass_squared(momenta: np.ndarray) -> float:
    return float(np.max(np.abs(minkowski_dot(momenta, momenta))))


def four_angle_average(
    library: ctypes.CDLL,
    lab_momenta: np.ndarray,
    alpha_s: float,
    identity_correction: int,
) -> tuple[float, dict[str, float]]:
    photon_lab = lab_momenta[0] - lab_momenta[2]
    hadronic_total_lab = lab_momenta[1] + photon_lab
    beta = hadronic_total_lab[1:] / hadronic_total_lab[0]
    rest = np.stack([boost_to_rest(momentum, beta) for momentum in lab_momenta])

    photon_rest = rest[0] - rest[2]
    axis = rest[1, 1:] / np.linalg.norm(rest[1, 1:])
    hadronic_total_rest = rest[1] + photon_rest
    values: list[float] = []
    max_conservation = 0.0
    max_mass_squared = 0.0
    max_photon_shift = 0.0
    for index in range(4):
        angle = 0.5 * math.pi * index
        rotated = rest.copy()
        rotated[0] = rotate_spatial(rest[0], axis, angle)
        rotated[2] = rotate_spatial(rest[2], axis, angle)
        rotated_photon = rotated[0] - rotated[2]
        max_conservation = max(max_conservation, conservation_residual(rotated))
        max_mass_squared = max(max_mass_squared, maximum_mass_squared(rotated))
        max_photon_shift = max(
            max_photon_shift, float(np.max(np.abs(rotated_photon - photon_rest)))
        )
        values.append(
            identity_correction * evaluate(library, rotated, alpha_s)
        )

    diagnostics = {
        "max_conservation_residual": max_conservation,
        "max_external_mass_squared": max_mass_squared,
        "max_photon_momentum_shift": max_photon_shift,
        "hadronic_rest_spatial_residual": float(
            np.max(np.abs(hadronic_total_rest[1:]))
        ),
    }
    return math.fsum(values) / 4.0, diagnostics


def main() -> None:
    if CSV_OUTPUT.exists() or METADATA_OUTPUT.exists():
        raise FileExistsError("S10 output already exists")
    for path, expected in EXPECTED_SHA256.items():
        observed = sha256(path)
        if observed != expected:
            raise RuntimeError(f"hash mismatch for {path.name}: {observed}")

    with POINT_VALIDATION.open(encoding="utf-8") as stream:
        point_validation = json.load(stream)
    if (
        point_validation.get("stage")
        != "HqqprimeMadGraphAzimuthalAverageValidation-v1"
        or point_validation.get("status") != "complete"
        or not all(point_validation.get("checks", {}).values())
    ):
        raise RuntimeError("accepted S08 point validation is incomplete")
    alpha_s = float(point_validation["alpha_s"])
    identity_correction = int(
        point_validation["madgraph_final_identity_correction"]
    )

    print("S10_STAGE: generating deterministic massless four-body RAMBO trials", flush=True)
    final_momenta = rambo_massless_four_body(TOTAL_TRIALS, SQRT_S, RANDOM_SEED)
    incoming_electron = np.array([SQRT_S / 2.0, 0.0, 0.0, SQRT_S / 2.0])
    incoming_quark = np.array([SQRT_S / 2.0, 0.0, 0.0, -SQRT_S / 2.0])

    total_final = np.sum(final_momenta, axis=1)
    max_rambo_conservation = float(
        np.max(np.abs(total_final - np.array([SQRT_S, 0.0, 0.0, 0.0])))
    )
    max_rambo_mass_squared = float(
        np.max(np.abs(minkowski_dot(final_momenta, final_momenta)))
    )
    if max_rambo_conservation > 5.0e-9 or max_rambo_mass_squared > 5.0e-7:
        raise RuntimeError("RAMBO masslessness or conservation gate failed")

    outgoing_electron = final_momenta[:, 0]
    outgoing_k1_charm = final_momenta[:, 1]
    outgoing_k2_up = final_momenta[:, 2]
    outgoing_k3_anticharm = final_momenta[:, 3]
    photon = incoming_electron[None, :] - outgoing_electron

    q2 = -minkowski_dot(photon, photon)
    s12 = minkowski_dot(
        outgoing_k1_charm + outgoing_k2_up,
        outgoing_k1_charm + outgoing_k2_up,
    )
    s13 = minkowski_dot(
        outgoing_k1_charm + outgoing_k3_anticharm,
        outgoing_k1_charm + outgoing_k3_anticharm,
    )
    s23 = minkowski_dot(
        outgoing_k2_up + outgoing_k3_anticharm,
        outgoing_k2_up + outgoing_k3_anticharm,
    )
    shat = s12 + s13 + s23
    u1 = minkowski_dot(
        incoming_quark[None, :] - outgoing_k1_charm,
        incoming_quark[None, :] - outgoing_k1_charm,
    )
    u2 = minkowski_dot(
        incoming_quark[None, :] - outgoing_k2_up,
        incoming_quark[None, :] - outgoing_k2_up,
    )
    u3 = minkowski_dot(
        incoming_quark[None, :] - outgoing_k3_anticharm,
        incoming_quark[None, :] - outgoing_k3_anticharm,
    )
    t1 = minkowski_dot(photon - outgoing_k1_charm, photon - outgoing_k1_charm)
    t2 = minkowski_dot(photon - outgoing_k2_up, photon - outgoing_k2_up)
    t3 = minkowski_dot(
        photon - outgoing_k3_anticharm,
        photon - outgoing_k3_anticharm,
    )

    sij_fraction_minimum = np.min(np.stack([s12, s13, s23]), axis=0) / shat
    minus_ui_fraction_minimum = np.min(np.stack([-u1, -u2, -u3]), axis=0) / (
        shat + q2
    )
    minus_ti_fraction_minimum = np.min(np.stack([-t1, -t2, -t3]), axis=0) / (
        shat + 2.0 * q2
    )

    selected = (
        (q2 / S >= CUTS["q2_over_s_min"])
        & (q2 / S <= CUTS["q2_over_s_max"])
        & (shat / S >= CUTS["shat_over_s_min"])
        & (shat / S <= CUTS["shat_over_s_max"])
        & (sij_fraction_minimum >= CUTS["min_sij_over_shat"])
        & (
            minus_ui_fraction_minimum
            >= CUTS["min_minus_ui_over_shat_plus_q2"]
        )
        & (
            minus_ti_fraction_minimum
            >= CUTS["min_minus_ti_over_shat_plus_2q2"]
        )
    )
    selected_indices = np.flatnonzero(selected)
    accepted_count = int(selected_indices.size)
    acceptance_fraction = accepted_count / TOTAL_TRIALS
    print(
        f"S10_STAGE: accepted {accepted_count}/{TOTAL_TRIALS} "
        f"events ({acceptance_fraction:.6f})",
        flush=True,
    )
    if accepted_count < 2000:
        raise RuntimeError("fewer than 2000 events passed the fixed finite cuts")

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

    invariant_columns = np.column_stack([s12, s13, s23, u1, u2, u3, q2])[
        selected_indices
    ]
    madgraph_values = np.empty(accepted_count, dtype=np.float64)
    maximum_diagnostics = {
        "max_conservation_residual": 0.0,
        "max_external_mass_squared": 0.0,
        "max_photon_momentum_shift": 0.0,
        "hadronic_rest_spatial_residual": 0.0,
    }
    maximum_lorentz_relative_difference = 0.0

    print("S10_STAGE: evaluating four-angle MadGraph averages", flush=True)
    for accepted_position, trial_index in enumerate(selected_indices):
        lab_momenta = np.vstack(
            [incoming_electron, incoming_quark, final_momenta[trial_index]]
        )
        average, diagnostics = four_angle_average(
            library,
            lab_momenta,
            alpha_s,
            identity_correction,
        )
        if not math.isfinite(average) or average <= 0.0:
            raise RuntimeError(
                f"nonpositive/nonfinite MadGraph average at trial {trial_index}"
            )
        madgraph_values[accepted_position] = average
        for key, value in diagnostics.items():
            maximum_diagnostics[key] = max(maximum_diagnostics[key], value)

        if accepted_position < 8:
            lab_value = evaluate(library, lab_momenta, alpha_s)
            spot_photon = incoming_electron - final_momenta[trial_index, 0]
            spot_hadronic_total = incoming_quark + spot_photon
            spot_beta = spot_hadronic_total[1:] / spot_hadronic_total[0]
            spot_rest_momenta = np.stack(
                [boost_to_rest(momentum, spot_beta) for momentum in lab_momenta]
            )
            rest_value = evaluate(library, spot_rest_momenta, alpha_s)
            denominator = max(abs(lab_value), abs(rest_value))
            maximum_lorentz_relative_difference = max(
                maximum_lorentz_relative_difference,
                abs(lab_value - rest_value) / denominator,
            )

        if (accepted_position + 1) % 2000 == 0:
            print(
                f"S10_PROGRESS: {accepted_position + 1}/{accepted_count} accepted events",
                flush=True,
            )

    if maximum_diagnostics["max_conservation_residual"] > 2.0e-9:
        raise RuntimeError("rotated-event conservation residual is too large")
    if maximum_diagnostics["max_external_mass_squared"] > 2.0e-6:
        raise RuntimeError("rotated-event mass residual is too large")
    if maximum_diagnostics["max_photon_momentum_shift"] > 2.0e-9:
        raise RuntimeError("the azimuthal rotation changed the photon momentum")
    if maximum_lorentz_relative_difference > 2.0e-11:
        raise RuntimeError("MadGraph failed the lab/rest Lorentz spot check")

    table = np.column_stack([invariant_columns, madgraph_values])
    csv_temporary = CSV_OUTPUT.with_name(CSV_OUTPUT.name + f".tmp.{os.getpid()}")
    np.savetxt(
        csv_temporary,
        table,
        delimiter=",",
        header="s12,s13,s23,u1,u2,u3,Q2,madgraph_azimuthal_average",
        comments="",
        fmt="%.17e",
    )
    os.replace(csv_temporary, CSV_OUTPUT)

    phase_space_volume = S * S / (24.0 * (4.0 * math.pi) ** 5)
    cross_section_common_factor = phase_space_volume / (2.0 * S)
    mean_with_rejected_zeros = math.fsum(madgraph_values.tolist()) / TOTAL_TRIALS
    second_moment_with_rejected_zeros = math.fsum(
        (madgraph_values * madgraph_values).tolist()
    ) / TOTAL_TRIALS
    sample_variance = (
        TOTAL_TRIALS
        / (TOTAL_TRIALS - 1.0)
        * (second_moment_with_rejected_zeros - mean_with_rejected_zeros**2)
    )
    standard_error_mean = math.sqrt(max(0.0, sample_variance) / TOTAL_TRIALS)
    gev2_to_pb = 0.389379338e9

    metadata = {
        "stage": "HqqprimeFiniteCutMadGraphSample-v1",
        "status": "complete",
        "sqrt_s_gev": SQRT_S,
        "s_gev2": S,
        "total_rambo_trials": TOTAL_TRIALS,
        "accepted_events": accepted_count,
        "acceptance_fraction": acceptance_fraction,
        "random_generator": "NumPy PCG64",
        "random_seed": RANDOM_SEED,
        "alpha_s": alpha_s,
        "madgraph_final_identity_correction": identity_correction,
        "local_and_generated_final_order": ["c(k1)", "u(k2)", "cbar(k3)"],
        "cuts": CUTS,
        "rambo_phase_space_volume_gev4": phase_space_volume,
        "massless_flux_factor_inverse_gev_minus2": 1.0 / (2.0 * S),
        "cross_section_common_factor_gev2": cross_section_common_factor,
        "gev_minus2_to_pb": gev2_to_pb,
        "madgraph_cross_section_gev_minus2": (
            cross_section_common_factor * mean_with_rejected_zeros
        ),
        "madgraph_cross_section_pb": (
            cross_section_common_factor * mean_with_rejected_zeros * gev2_to_pb
        ),
        "madgraph_standard_error_gev_minus2": (
            cross_section_common_factor * standard_error_mean
        ),
        "madgraph_standard_error_pb": (
            cross_section_common_factor * standard_error_mean * gev2_to_pb
        ),
        "rambo_maximum_conservation_residual": max_rambo_conservation,
        "rambo_maximum_external_mass_squared": max_rambo_mass_squared,
        "rotated_event_diagnostics": maximum_diagnostics,
        "maximum_lab_rest_madgraph_relative_difference": (
            maximum_lorentz_relative_difference
        ),
        "input_sha256": {
            path.name: value for path, value in EXPECTED_SHA256.items()
        },
        "source_sha256": sha256(Path(__file__)),
        "csv_sha256": sha256(CSV_OUTPUT),
        "csv_columns": [
            "s12",
            "s13",
            "s23",
            "u1",
            "u2",
            "u3",
            "Q2",
            "madgraph_azimuthal_average",
        ],
    }
    metadata_temporary = METADATA_OUTPUT.with_name(
        METADATA_OUTPUT.name + f".tmp.{os.getpid()}"
    )
    with metadata_temporary.open("x", encoding="utf-8") as stream:
        json.dump(metadata, stream, indent=2, sort_keys=True)
        stream.write("\n")
    with metadata_temporary.open(encoding="utf-8") as stream:
        reloaded = json.load(stream)
    if (
        reloaded.get("status") != "complete"
        or reloaded.get("csv_sha256") != sha256(CSV_OUTPUT)
        or reloaded.get("accepted_events") != accepted_count
    ):
        raise RuntimeError("temporary S10 metadata failed reload validation")
    os.replace(metadata_temporary, METADATA_OUTPUT)

    print(f"S10_CSV_SHA256={metadata['csv_sha256']}")
    print(
        f"S10_MADGRAPH_CROSS_SECTION_PB="
        f"{metadata['madgraph_cross_section_pb']:.17e}"
    )
    print(
        f"S10_MADGRAPH_STANDARD_ERROR_PB="
        f"{metadata['madgraph_standard_error_pb']:.17e}"
    )
    print("S10_SUCCESS")


if __name__ == "__main__":
    main()
