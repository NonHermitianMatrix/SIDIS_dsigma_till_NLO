#!/usr/bin/env python3
from __future__ import annotations

import ctypes
import hashlib
import json
import math
import os
from pathlib import Path


ROOT = Path(__file__).resolve().parent
BRIDGE = ROOT / "s03_libhqqbar_madgraph_bridge.so"
PARAM_CARD = ROOT / "generated_process" / "Cards" / "param_card.dat"
DIRECT_LOG = ROOT / "s04_direct_madgraph_reference.log"
OUTPUT = ROOT / "s05_bridge_validation.json"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_direct_value() -> float:
    marker = "HQQBAR_DIRECT_MATRIX="
    values = [
        float(line.split("=", 1)[1])
        for line in DIRECT_LOG.read_text(encoding="utf-8").splitlines()
        if line.startswith(marker)
    ]
    if len(values) != 1:
        raise RuntimeError("direct reference log has no unique matrix value")
    return values[0]


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
    flat_particle_major = [component for particle in momenta for component in particle]
    momentum_array = (ctypes.c_double * 24)(*flat_particle_major)
    answer = ctypes.c_double(0.0)
    library.hqqbar_mg_eval(momentum_array, alpha_s, ctypes.byref(answer))
    return answer.value


def main() -> None:
    for required in (BRIDGE, PARAM_CARD, DIRECT_LOG):
        if not required.is_file():
            raise FileNotFoundError(required)
    if OUTPUT.exists():
        raise FileExistsError(OUTPUT)

    os.chdir(ROOT)
    library = ctypes.CDLL(str(BRIDGE))
    library.hqqbar_mg_init.argtypes = [ctypes.c_char_p]
    library.hqqbar_mg_init.restype = None
    library.hqqbar_mg_eval.argtypes = [
        ctypes.POINTER(ctypes.c_double),
        ctypes.c_double,
        ctypes.POINTER(ctypes.c_double),
    ]
    library.hqqbar_mg_eval.restype = None
    library.hqqbar_mg_metadata.argtypes = [
        ctypes.POINTER(ctypes.c_int),
        ctypes.POINTER(ctypes.c_int),
    ]
    library.hqqbar_mg_metadata.restype = None

    pdgs = (ctypes.c_int * 6)()
    identity_factor = ctypes.c_int(0)
    library.hqqbar_mg_metadata(pdgs, ctypes.byref(identity_factor))
    observed_pdgs = list(pdgs)
    if observed_pdgs != [11, 2, 11, 2, 2, -2]:
        raise RuntimeError(f"unexpected PDG ordering: {observed_pdgs}")
    if identity_factor.value != 24:
        raise RuntimeError(f"unexpected IDEN: {identity_factor.value}")

    library.hqqbar_mg_init(b"generated_process/Cards/param_card.dat")
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
    if not photon_virtuality < 0.0:
        raise RuntimeError("fixed point does not have a spacelike photon")

    alpha_s = 0.118
    bridge_value = evaluate(library, momenta, alpha_s)
    exchanged_momenta = [list(momentum) for momentum in momenta]
    exchanged_momenta[3], exchanged_momenta[4] = (
        exchanged_momenta[4],
        exchanged_momenta[3],
    )
    exchanged_value = evaluate(library, exchanged_momenta, alpha_s)
    direct_value = read_direct_value()

    relative_difference = abs(bridge_value - direct_value) / max(
        abs(bridge_value), abs(direct_value)
    )
    exchange_relative_difference = abs(bridge_value - exchanged_value) / max(
        abs(bridge_value), abs(exchanged_value)
    )
    if not all(math.isfinite(value) and value > 0.0 for value in (bridge_value, direct_value)):
        raise RuntimeError("matrix value is not positive and finite")
    if relative_difference > 5.0e-14:
        raise RuntimeError(
            f"bridge/direct mismatch: relative difference {relative_difference:.17g}"
        )
    if exchange_relative_difference > 5.0e-14:
        raise RuntimeError(
            "identical-u exchange mismatch: relative difference "
            f"{exchange_relative_difference:.17g}"
        )

    payload = {
        "stage": "HqqbarMadGraphBridgeValidation-v1",
        "status": "complete",
        "process_pdgs": observed_pdgs,
        "identity_factor": identity_factor.value,
        "alpha_s": alpha_s,
        "photon_q2": photon_virtuality,
        "maximum_conservation_residual": maximum_conservation_residual,
        "maximum_external_mass_squared": maximum_mass_squared,
        "direct_matrix_element": direct_value,
        "bridge_matrix_element": bridge_value,
        "exchanged_u_matrix_element": exchanged_value,
        "bridge_direct_relative_difference": relative_difference,
        "identical_u_exchange_relative_difference": exchange_relative_difference,
        "checks": {
            "pdg_order_exact": True,
            "identity_factor_24": True,
            "spacelike_photon": True,
            "four_momentum_conserved": True,
            "all_external_states_massless": True,
            "bridge_matches_direct_generated_routine": True,
            "identical_u_exchange_invariant": True,
        },
        "sha256": {
            "bridge": sha256(BRIDGE),
            "parameter_card": sha256(PARAM_CARD),
            "direct_log": sha256(DIRECT_LOG),
            "generated_matrix": sha256(
                ROOT
                / "generated_process"
                / "SubProcesses"
                / "P1_emu_emuuux_no_zh"
                / "matrix.f"
            ),
        },
    }
    temporary = OUTPUT.with_name(f"{OUTPUT.name}.tmp")
    temporary.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    temporary.replace(OUTPUT)
    print("HQQBAR_MADGRAPH_S05_SUCCESS")
    print(f"BRIDGE_DIRECT_RELATIVE_DIFFERENCE={relative_difference:.17g}")
    print(f"IDENTICAL_U_EXCHANGE_RELATIVE_DIFFERENCE={exchange_relative_difference:.17g}")


if __name__ == "__main__":
    main()
