#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
import json
import math
import os
from pathlib import Path


ROOT = Path(__file__).resolve().parent
S10_METADATA = ROOT / "s10_cut_phase_space_metadata.json"
S11_POINTS = ROOT / "s11_local_vs_madgraph_points.csv"
S11_SUMMARY = ROOT / "s11_pointwise_comparison.json"
OUTPUT = ROOT / "s12_integrated_comparison.json"

EXPECTED_SHA256 = {
    S10_METADATA: "ac6a208789613ffc39a2eca5a9c7a6ee3017d75e1388a6ca68252aeb30721350",
    S11_POINTS: "15d1fc2fa1bad06ddeaccecaed55d7627b3915e2bbe8140fc6e48e32c1e91f28",
    S11_SUMMARY: "27bd819e827041825c440449231f784797c8ac716c676d32561702beaf080ceb",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def mean_variance_standard_error_with_rejected_zeros(
    values: list[float], total_trials: int
) -> tuple[float, float, float]:
    total = math.fsum(values)
    sum_squares = math.fsum(value * value for value in values)
    mean = total / total_trials
    second_moment = sum_squares / total_trials
    variance = total_trials / (total_trials - 1.0) * (
        second_moment - mean * mean
    )
    variance = max(0.0, variance)
    return mean, variance, math.sqrt(variance / total_trials)


def main() -> None:
    if OUTPUT.exists():
        raise FileExistsError(OUTPUT)
    for path, expected in EXPECTED_SHA256.items():
        observed = sha256(path)
        if observed != expected:
            raise RuntimeError(f"hash mismatch for {path.name}: {observed}")

    with S10_METADATA.open(encoding="utf-8") as stream:
        metadata = json.load(stream)
    with S11_SUMMARY.open(encoding="utf-8") as stream:
        pointwise_summary = json.load(stream)
    if (
        metadata.get("status") != "complete"
        or metadata.get("stage") != "HqqprimeFiniteCutMadGraphSample-v1"
        or pointwise_summary.get("status") != "complete"
        or pointwise_summary.get("stage")
        != "HqqprimeFiniteCutPointwiseComparison-v1"
        or not all(pointwise_summary.get("checks", {}).values())
    ):
        raise RuntimeError("an input stage is not accepted and complete")

    madgraph_values: list[float] = []
    local_values: list[float] = []
    stored_signed_differences: list[float] = []
    with S11_POINTS.open(newline="", encoding="utf-8") as stream:
        reader = csv.DictReader(stream)
        expected_columns = {
            "s12",
            "s13",
            "s23",
            "u1",
            "u2",
            "u3",
            "Q2",
            "madgraph_azimuthal_average",
            "local_projected_matrix_element",
            "signed_difference",
            "relative_difference",
        }
        if set(reader.fieldnames or []) != expected_columns:
            raise RuntimeError(f"unexpected S11 columns: {reader.fieldnames}")
        for row in reader:
            madgraph_values.append(float(row["madgraph_azimuthal_average"]))
            local_values.append(float(row["local_projected_matrix_element"]))
            stored_signed_differences.append(float(row["signed_difference"]))

    accepted_events = int(metadata["accepted_events"])
    total_trials = int(metadata["total_rambo_trials"])
    if not (
        len(madgraph_values)
        == len(local_values)
        == len(stored_signed_differences)
        == accepted_events
        == int(pointwise_summary["common_bin_rows"])
    ):
        raise RuntimeError("the accepted-event row counts disagree")

    recomputed_differences = [
        local - madgraph
        for local, madgraph in zip(local_values, madgraph_values)
    ]
    maximum_difference_reconstruction_residual = max(
        abs(recomputed - stored)
        for recomputed, stored in zip(
            recomputed_differences,
            stored_signed_differences,
        )
    )
    if maximum_difference_reconstruction_residual > 2.0e-28:
        raise RuntimeError("the stored signed differences do not reconstruct")

    mg_mean, mg_variance, mg_mean_error = (
        mean_variance_standard_error_with_rejected_zeros(
            madgraph_values,
            total_trials,
        )
    )
    local_mean, local_variance, local_mean_error = (
        mean_variance_standard_error_with_rejected_zeros(
            local_values,
            total_trials,
        )
    )
    difference_mean, difference_variance, difference_mean_error = (
        mean_variance_standard_error_with_rejected_zeros(
            recomputed_differences,
            total_trials,
        )
    )

    cross_moment = math.fsum(
        madgraph * local
        for madgraph, local in zip(madgraph_values, local_values)
    ) / total_trials
    covariance = total_trials / (total_trials - 1.0) * (
        cross_moment - mg_mean * local_mean
    )
    correlation = covariance / math.sqrt(mg_variance * local_variance)

    common_factor = float(metadata["cross_section_common_factor_gev2"])
    gev2_to_pb = float(metadata["gev_minus2_to_pb"])
    pb_factor = common_factor * gev2_to_pb

    mg_cross_section_pb = pb_factor * mg_mean
    local_cross_section_pb = pb_factor * local_mean
    difference_cross_section_pb = pb_factor * difference_mean
    mg_standard_error_pb = pb_factor * mg_mean_error
    local_standard_error_pb = pb_factor * local_mean_error
    difference_standard_error_pb = pb_factor * difference_mean_error

    integrated_relative_difference = abs(difference_cross_section_pb) / max(
        abs(mg_cross_section_pb),
        abs(local_cross_section_pb),
    )
    ratio_local_to_madgraph = local_cross_section_pb / mg_cross_section_pb
    metadata_mg_relative_difference = abs(
        mg_cross_section_pb - float(metadata["madgraph_cross_section_pb"])
    ) / abs(mg_cross_section_pb)
    difference_in_correlated_standard_errors = (
        abs(difference_cross_section_pb) / difference_standard_error_pb
        if difference_standard_error_pb > 0.0
        else 0.0
    )
    difference_relative_to_mg_mc_error = abs(difference_cross_section_pb) / (
        mg_standard_error_pb
    )

    checks = {
        "input_hashes_exact": True,
        "accepted_and_total_counts_exact": True,
        "stored_signed_differences_reconstruct": (
            maximum_difference_reconstruction_residual <= 2.0e-28
        ),
        "madgraph_integral_reproduces_s10_metadata": (
            metadata_mg_relative_difference < 2.0e-14
        ),
        "integrated_relative_difference_below_5e-12": (
            integrated_relative_difference < 5.0e-12
        ),
        "difference_below_one_millionth_of_mg_mc_error": (
            difference_relative_to_mg_mc_error < 1.0e-6
        ),
        "correlation_above_0p999999999": correlation > 0.999999999,
    }
    if not all(checks.values()):
        raise RuntimeError("integrated comparison failed: " + json.dumps(checks))

    output = {
        "stage": "HqqprimeFiniteCutIntegratedComparison-v1",
        "status": "complete",
        "sqrt_s_gev": metadata["sqrt_s_gev"],
        "total_rambo_trials": total_trials,
        "accepted_events": accepted_events,
        "acceptance_fraction": metadata["acceptance_fraction"],
        "cuts": metadata["cuts"],
        "phase_space_and_flux_normalization": {
            "massless_four_body_phase_space_volume_gev4": metadata[
                "rambo_phase_space_volume_gev4"
            ],
            "incoming_flux_inverse_gev_minus2": metadata[
                "massless_flux_factor_inverse_gev_minus2"
            ],
            "common_factor_gev2": common_factor,
            "gev_minus2_to_pb": gev2_to_pb,
            "estimator": (
                "sigma = Phi_4(s)/(2s) * (1/N_trials) * "
                "sum_{accepted} matrix_element_squared"
            ),
        },
        "madgraph_cross_section_pb": mg_cross_section_pb,
        "madgraph_standard_error_pb": mg_standard_error_pb,
        "local_projected_cross_section_pb": local_cross_section_pb,
        "local_standard_error_pb": local_standard_error_pb,
        "local_minus_madgraph_cross_section_pb": difference_cross_section_pb,
        "correlated_difference_standard_error_pb": difference_standard_error_pb,
        "difference_in_correlated_standard_errors": (
            difference_in_correlated_standard_errors
        ),
        "difference_relative_to_madgraph_mc_error": (
            difference_relative_to_mg_mc_error
        ),
        "ratio_local_to_madgraph": ratio_local_to_madgraph,
        "integrated_relative_difference": integrated_relative_difference,
        "sample_correlation": correlation,
        "maximum_stored_difference_reconstruction_residual": (
            maximum_difference_reconstruction_residual
        ),
        "madgraph_metadata_reproduction_relative_difference": (
            metadata_mg_relative_difference
        ),
        "pointwise_summary": {
            "maximum_relative_difference": pointwise_summary[
                "maximum_relative_difference"
            ],
            "relative_difference_99th_percentile": pointwise_summary[
                "relative_difference_99th_percentile"
            ],
            "median_relative_difference": pointwise_summary[
                "median_relative_difference"
            ],
        },
        "input_sha256": {
            path.name: value for path, value in EXPECTED_SHA256.items()
        },
        "source_sha256": sha256(Path(__file__)),
        "checks": checks,
    }
    temporary = OUTPUT.with_name(OUTPUT.name + f".tmp.{os.getpid()}")
    if temporary.exists():
        raise FileExistsError(temporary)
    with temporary.open("x", encoding="utf-8") as stream:
        json.dump(output, stream, indent=2, sort_keys=True)
        stream.write("\n")
    with temporary.open(encoding="utf-8") as stream:
        reloaded = json.load(stream)
    if (
        reloaded.get("status") != "complete"
        or reloaded.get("stage")
        != "HqqprimeFiniteCutIntegratedComparison-v1"
        or not all(reloaded.get("checks", {}).values())
    ):
        raise RuntimeError("temporary S12 result failed reload validation")
    os.replace(temporary, OUTPUT)

    print(f"S12_MADGRAPH_CROSS_SECTION_PB={mg_cross_section_pb:.17e}")
    print(f"S12_LOCAL_CROSS_SECTION_PB={local_cross_section_pb:.17e}")
    print(f"S12_MADGRAPH_STANDARD_ERROR_PB={mg_standard_error_pb:.17e}")
    print(f"S12_LOCAL_MINUS_MADGRAPH_PB={difference_cross_section_pb:.17e}")
    print(
        f"S12_INTEGRATED_RELATIVE_DIFFERENCE="
        f"{integrated_relative_difference:.17e}"
    )
    print(f"S12_SAMPLE_CORRELATION={correlation:.17e}")
    print("S12_SUCCESS")


if __name__ == "__main__":
    main()
