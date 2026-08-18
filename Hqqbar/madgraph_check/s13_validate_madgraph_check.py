#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
import json
import math
import os
from pathlib import Path


ROOT = Path(__file__).resolve().parent
HQQBAR = ROOT.parent
OUTPUT = ROOT / "s13_final_validation.json"

EXPECTED_ARTIFACT_SHA256 = {
    "README.md": "4a817f8108047a75132a4b803ea18839145a561c69e0623c538fff1d5624b1f5",
    "../README.md": "6a600e52a441128cef8b584834b6e29f40c050faa83fa9fe7c2310a19f8e8c48",
    "s01_install_madgraph.sh": "58ee26869039612e60e75b412b1349ba6d847416b6dba22fd6b99c0c5fd54660",
    "s01_install_madgraph.log": "11dbddf4b747ae20aec86ebff9fbfb18f17545744f9483880052c63720aab72b",
    "s01_install_manifest.txt": "ffb2f66933097f3103c096c369c94963cddea5cbcc32c73932c7519f832f615c",
    "s02_generate_hqqbar_standalone.mg5": "9f724cae87ad1cfac486ac87567722de1acc7bca3586eef85dab4d9e4f095240",
    "generated_process/Cards/proc_card_mg5.dat": "78794575e5135d42f62eeb3cab0f1f2c8be83022950d3d1a951cd55a739ff3b6",
    "generated_process/Cards/param_card.dat": "55bb009a781370ab3fdfb523be00d0c8f68ffec442d12eb41b8d2da50307cf64",
    "generated_process/SubProcesses/P1_emu_emuuux_no_zh/matrix.f": "4a1f3bc0da60ff3f9ed7f4eaaa9f920b6c0da20cb8a76504734e4a8295e471f0",
    "s03_madgraph_c_bridge.f90": "410416b327cb5aa922efb43e4c017efdf6634d82405840dad15a8b344a0a36f9",
    "s03_libhqqbar_madgraph_bridge.so": "0d1e52d791fb03a9a1776a1a188a9ad683b66daf202ad209a3ffdb0b8fa66a08",
    "s04_direct_madgraph_reference.f90": "6faafb9942f2b28ec396b6d3376cee02d5b7744ebaa213983411d2e9269db9f3",
    "s04_direct_madgraph_reference": "6d90113f1359e55ae7eba370a03c61e2f9478d068552b4cab629a567711d4275",
    "s04_direct_madgraph_reference.log": "6175ee63cee875d87a9cb95ed299411a7e5735a6f5fcf80ad6f1f3dbe19cea52",
    "s05_validate_madgraph_bridge.py": "a74f914f50b18af64d9c02137fdadbcd303f0ac55730d283c43b78096f1a74a2",
    "s05_validate_madgraph_bridge.log": "21fadb7c4828fcaf6e5435ccf50c4afab9b116ed6d224a04af9814f7723880e7",
    "s05_bridge_validation.json": "0ca2814c65b2d30aa1a0844258f30ee09d80b6fd0d4f1f5e7307320853453dc5",
    "s06_inspect_copied_s07_schema.wl": "29c26f75a9a1254c3dfde151ff4c56c83d1f882237fefb36e7ac7dd5a1075d55",
    "s06_inspect_copied_s07_schema.log": "e0271e543af2246b572e5191205168c56a00614d1c4a2f88a82fec4e05927069",
    "s07_validate_local_matrix_element.wl": "0dc26312e13b0c87913dce9426318c75b8047b34ab82b5c0535435cc95ed00ab",
    "s07_validate_local_matrix_element.log": "83837d4964e9ec2d4a6d5d510e8e072d4087b979665a9e8374bd28cb1e3dcd44",
    "s07_projected_local_point.json": "8f8e8319301efb68cadf8226907ed4cce71df51660e5abe9e27e47142d754ca5",
    "s08_validate_azimuthal_average.py": "e440364f25b6ab367fc9ca94a8f256216ea215233da3a350769fd11af3fd7c18",
    "s08_validate_azimuthal_average.log": "891c0b61b4fb337a6170edeb242c678a6def6bbe5bd003f197969fe6e937c860",
    "s08_azimuthal_average_validation.json": "89da37951365e34cc6aec688dc163fd6e2563b1bfbbd5560d7d5c135644e7a43",
    "s09_build_four_dimensional_evaluator.wl": "56eed1e44ee274017ebbe725e286373a2d4b1d6fc15e6737c81db3fcd92606bc",
    "s09_build_four_dimensional_evaluator.log": "5b773258985c669f635a3a3c8328b94d3d8177246088346553a7c0d24c952beb",
    "s09_four_dimensional_unit_projections": "bb6b23a17ab97f6db9cd511c197344a715f415c125700fa95e74c5470dc93a6a",
    "s10_generate_cut_bin_madgraph.py": "4d156c67daa64e08d6e09deab3b325391c12aa4597282888c329519d1aba2bec",
    "s10_generate_cut_bin_madgraph.log": "6d2a73f3e93f83803a76f8241a7ab723f14a9248ca39f6611ee2bbe9c3c88118",
    "s10_cut_phase_space_points.csv": "7b83e42e960649402b03a26e7dd768737d0a6cb7d724acf7aee2a7602f5d0441",
    "s10_cut_phase_space_metadata.json": "086a3809c90d24f66aea6f29648c950a37fd9955fe9987f3e9368c6f6020c824",
    "s11_evaluate_local_cut_bin.wl": "9d5d61f74ecbf040d88d9526ba3f9f4794d2b99a802ade0921770265b34f17bc",
    "s11_evaluate_local_cut_bin.log": "6d946d8fbcfd1715dd59323c4a7c5f0eb949fb7e05e74733abced891fed6b8fb",
    "s11_local_vs_madgraph_points.csv": "0afe3400b01ea9e7598f4507727d1d15b5a5ee4d9649482c2e13d1893845e34f",
    "s11_pointwise_comparison.json": "4e157028c67ac86c34ac53f81dda15c9b30a8a4f90806862ded4c916b101224b",
    "s12_integrate_common_cut_bin.py": "856486c40601ade95f8eb896f9597b1ef61aa4e7b9c14e3393e3a8e7abe77d4e",
    "s12_integrate_common_cut_bin.log": "1ace9aac64f2702224377b6c7f3d3657c3fd453de84a2999485cec69bcbe891f",
    "s12_integrated_comparison.json": "b41e7a13e0774919209d825b6472d0797f84ef65d563601778e303217c787b63",
}

UPSTREAM_PAIRS = {
    "s06_spin_color_sum_average_hqqbar.wl": "787d001e6d285d1e74cfe9654ca8f61fe9a66d3b2e5972b20291bf39a02014fe",
    "s06_result": "fd6499e32ce65273381e5350131fe06e8ed3b9a05083b446189b0d7d7323f9ef",
    "s07_contract_hqqbar_projectors.wl": "4631639ae9e06a266e507d8854ee0cadf55d9106faff5ab13fe616f33fb50db4",
    "s07_result": "a0bcb6faac5ee4d2e8e5ffdff33bad91f2333424f486e101c9c62d1a49318f50",
    "s08_phase_space_integrate_hqqbar.wl": "2947bef60f303969ba451fc69cf1af76b0550a4f0d18bc2632d43568bf95bda6",
    "s08_result": "163eea0d42febe7642abb106599aa7d8c594eed2e6888a62cc1dde7985ec0dec",
    "s10_resolve_endpoints_hqqbar.wl": "793f9aaafbda74c605c3885915eabf9323e8b5761c84e9954d0759a5f890ac20",
    "s10_result": "57e637d3eca490dfe08e341d866e5fa08ec1d69b14c7c476cf17c51890a65cb6",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def load_json(name: str) -> dict:
    with (ROOT / name).open(encoding="utf-8") as stream:
        value = json.load(stream)
    if not isinstance(value, dict):
        raise RuntimeError(f"{name} is not a JSON object")
    return value


def all_checks_true(value: dict, label: str) -> None:
    checks = value.get("checks")
    if not isinstance(checks, dict) or not checks or not all(checks.values()):
        raise RuntimeError(f"{label} does not have all checks true")


def csv_data_rows(path: Path) -> int:
    with path.open(newline="", encoding="utf-8") as stream:
        return sum(1 for _ in csv.reader(stream)) - 1


def main() -> None:
    if OUTPUT.exists():
        raise FileExistsError(OUTPUT)

    observed_artifact_hashes: dict[str, str] = {}
    for relative, expected in EXPECTED_ARTIFACT_SHA256.items():
        path = (ROOT / relative).resolve()
        observed = sha256(path)
        if observed != expected:
            raise RuntimeError(f"artifact hash mismatch for {relative}: {observed}")
        observed_artifact_hashes[relative] = observed

    upstream_copy_audit: dict[str, dict[str, str | bool]] = {}
    for name, expected in UPSTREAM_PAIRS.items():
        original = HQQBAR / name
        copied = ROOT / "upstream_copies" / name
        original_hash = sha256(original)
        copied_hash = sha256(copied)
        if original_hash != expected or copied_hash != expected:
            raise RuntimeError(
                f"original/copy hash mismatch for {name}: "
                f"original={original_hash}, copy={copied_hash}"
            )
        upstream_copy_audit[name] = {
            "expected_sha256": expected,
            "original_sha256": original_hash,
            "copy_sha256": copied_hash,
            "byte_identical": True,
        }

    matrix_text = (
        ROOT / "generated_process" / "SubProcesses" /
        "P1_emu_emuuux_no_zh" / "matrix.f"
    ).read_text(encoding="utf-8")
    process_card_text = (
        ROOT / "generated_process" / "Cards" / "proc_card_mg5.dat"
    ).read_text(encoding="utf-8")
    process_metadata_exact = (
        "PARAMETER (NGRAPHS=8)" in matrix_text
        and "DATA IDEN/24/" in matrix_text
        and "Process: e- u > e- u u u~" in matrix_text
        and "generate e- u > e- u u u~ / z h" in process_card_text
    )
    if not process_metadata_exact:
        raise RuntimeError("generated MadGraph process metadata is not exact")

    bridge = load_json("s05_bridge_validation.json")
    azimuth = load_json("s08_azimuthal_average_validation.json")
    s10 = load_json("s10_cut_phase_space_metadata.json")
    s11 = load_json("s11_pointwise_comparison.json")
    s12 = load_json("s12_integrated_comparison.json")
    for value, label in [
        (bridge, "S05"), (azimuth, "S08"), (s11, "S11"), (s12, "S12")
    ]:
        if value.get("status") != "complete":
            raise RuntimeError(f"{label} status is not complete")
        all_checks_true(value, label)
    if s10.get("status") != "complete":
        raise RuntimeError("S10 status is not complete")

    s10_rows = csv_data_rows(ROOT / "s10_cut_phase_space_points.csv")
    s11_rows = csv_data_rows(ROOT / "s11_local_vs_madgraph_points.csv")
    row_counts_exact = (
        s10_rows == s11_rows == s10["accepted_events"] == s11["common_bin_rows"]
        == s12["accepted_events"] == 27851
    )
    if not row_counts_exact:
        raise RuntimeError("S10/S11/S12 row counts disagree")

    expected_madgraph_pb = 3.66827994997779932e-4
    expected_local_pb = 3.66827994997779769e-4
    numerical_result_exact = (
        math.isclose(
            s12["madgraph_cross_section_pb"], expected_madgraph_pb,
            rel_tol=2.0e-15, abs_tol=0.0,
        )
        and math.isclose(
            s12["local_copied_s07_cross_section_pb"], expected_local_pb,
            rel_tol=2.0e-15, abs_tol=0.0,
        )
        and s12["integrated_relative_difference"] < 5.0e-12
        and s11["maximum_relative_difference"] < 2.0e-9
        and azimuth["relative_difference"] < 2.0e-10
    )
    if not numerical_result_exact:
        raise RuntimeError("the final numerical result or tolerance is invalid")

    disposable_patterns = ["*.tmp.*", "*.pyc", "param.log", "s07_paper_page*.png"]
    disposable_paths = [
        str(path.relative_to(ROOT))
        for pattern in disposable_patterns
        for path in ROOT.rglob(pattern)
    ]
    disposable_paths.extend(
        str(path.relative_to(ROOT)) for path in ROOT.rglob("__pycache__")
    )
    if disposable_paths:
        raise RuntimeError(f"disposable artifacts remain: {sorted(disposable_paths)}")

    checks = {
        "all_pinned_artifact_hashes_exact": True,
        "all_upstream_original_copy_pairs_byte_identical": True,
        "accepted_hqqbar_s06_s07_s08_s10_hashes_unchanged": True,
        "madgraph_eight_diagrams_and_iden_24_exact": True,
        "bridge_direct_and_identical_u_checks_true": True,
        "azimuthal_average_point_check_true": True,
        "s10_s11_s12_row_counts_exact": True,
        "all_pointwise_comparison_checks_true": True,
        "all_integrated_comparison_checks_true": True,
        "final_numerical_result_and_tolerances_exact": True,
        "no_disposable_temp_bytecode_paramlog_or_rendered_page_remains": True,
        "accepted_results_and_macros_not_modified": True,
    }
    output = {
        "stage": "HqqbarMadGraphFinalValidation-v1",
        "status": "complete",
        "top_level_steps_complete": 6,
        "artifact_sha256": observed_artifact_hashes,
        "upstream_original_copy_audit": upstream_copy_audit,
        "finite_bin_result": {
            "total_trials": s12["total_rambo_trials"],
            "accepted_events": s12["accepted_events"],
            "madgraph_cross_section_pb": s12["madgraph_cross_section_pb"],
            "local_copied_s07_cross_section_pb": s12[
                "local_copied_s07_cross_section_pb"
            ],
            "madgraph_standard_error_pb": s12["madgraph_standard_error_pb"],
            "local_minus_madgraph_pb": s12[
                "local_minus_madgraph_cross_section_pb"
            ],
            "integrated_relative_difference": s12[
                "integrated_relative_difference"
            ],
            "pointwise_maximum_relative_difference": s11[
                "maximum_relative_difference"
            ],
            "pointwise_99th_percentile_relative_difference": s11[
                "relative_difference_99th_percentile"
            ],
            "reference_azimuthal_average_relative_difference": azimuth[
                "relative_difference"
            ],
        },
        "raw_s08_s10_scope": (
            "The unrestricted raw S08/S10 four-dimensional integral is not "
            "finite because copied S10 retains nonzero simple collinear poles; "
            "the accepted check is the matched invariant-cut pre-angular real matrix."
        ),
        "source_sha256": sha256(Path(__file__)),
        "checks": checks,
    }
    temporary = OUTPUT.with_name(OUTPUT.name + f".tmp.{os.getpid()}")
    with temporary.open("x", encoding="utf-8") as stream:
        json.dump(output, stream, indent=2, sort_keys=True)
        stream.write("\n")
    os.replace(temporary, OUTPUT)

    print(f"S13_PINNED_ARTIFACTS={len(observed_artifact_hashes)}")
    print(f"S13_UPSTREAM_COPY_PAIRS={len(upstream_copy_audit)}")
    print(f"S13_COMMON_ROWS={s10_rows}")
    print(f"S13_INTEGRATED_RELATIVE_DIFFERENCE={s12['integrated_relative_difference']:.17e}")
    print("S13_SUCCESS")


if __name__ == "__main__":
    main()
