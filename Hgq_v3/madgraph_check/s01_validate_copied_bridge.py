#!/usr/bin/env python3
"""madgraph_check/s01 : validate the copied MadGraph bridge for Hgq_v3.

The bridge, its Fortran source, the pinned parameter card and the accepted
validation JSON are byte copies from scripts/Hgq/madgraph_check, whose S05
accepted the bridge and whose S18 established that the corrected Hgq real
matrix element agrees with MadGraph to 8.2e-16.  The generated process there is
`e- g -> e- u u~ g / z h QED=2 QCD=2`, i.e. exactly this channel's real
emission, so the bridge is reusable as-is and is NOT regenerated here.

This stage only proves the copy still works: load it, evaluate at the same
symmetric tetrahedron point with the same alpha_s, and require the pinned
matrix element back.  Nothing local is compared yet.
"""
from __future__ import annotations
import ctypes, hashlib, json, math
from pathlib import Path

HERE = Path(__file__).resolve().parent
COPIES = HERE / "upstream_copies"
LIB = COPIES / "s03_libhgq_madgraph_bridge.so"
CARD_RELATIVE = b"generated_process/Cards/param_card.dat"  # relative: lha_read walks parents from it
CARD = HERE / "generated_process" / "Cards" / "param_card.dat"
PINNED = COPIES / "s05_bridge_validation.json"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tetrahedron_momenta() -> list[list[float]]:
    r3 = math.sqrt(3.0)
    e = 250.0
    return [
        [500.0, 0.0, 0.0, 500.0],
        [500.0, 0.0, 0.0, -500.0],
        [e, e / r3, e / r3, e / r3],
        [e, e / r3, -e / r3, -e / r3],
        [e, -e / r3, e / r3, -e / r3],
        [e, -e / r3, -e / r3, e / r3],
    ]


def mink2(p: list[float]) -> float:
    return p[0] ** 2 - sum(c * c for c in p[1:])


def main() -> int:
    import os
    os.chdir(HERE)   # lha_read searches parent dirs from the CWD
    pinned = json.loads(PINNED.read_text())
    expected = float(pinned["BridgeMatrixElement"])
    alpha_s = float(pinned["AlphaS"])

    momenta = tetrahedron_momenta()
    residual = max(
        abs(momenta[0][c] + momenta[1][c] - sum(m[c] for m in momenta[2:]))
        for c in range(4))
    max_mass2 = max(abs(mink2(m)) for m in momenta)
    photon = [momenta[0][c] - momenta[2][c] for c in range(4)]
    q2 = mink2(photon)

    lib = ctypes.CDLL(str(LIB))
    lib.hgq_mg_init.argtypes = [ctypes.c_char_p]
    lib.hgq_mg_init.restype = None
    lib.hgq_mg_eval.argtypes = [ctypes.POINTER(ctypes.c_double), ctypes.c_double,
                                ctypes.POINTER(ctypes.c_double)]
    lib.hgq_mg_eval.restype = None
    lib.hgq_mg_init(CARD_RELATIVE)
    flat = [c for p in momenta for c in p]
    arr = (ctypes.c_double * 24)(*flat)
    out = ctypes.c_double(0.0)
    lib.hgq_mg_eval(arr, ctypes.c_double(alpha_s), ctypes.byref(out))
    value = out.value

    rel = abs(value - expected) / max(abs(value), abs(expected))
    checks = {
        "FourMomentumConserved": residual < 1e-9,
        "AllExternalStatesMassless": max_mass2 < 1e-6,
        "SpacelikePhoton": q2 < 0.0,
        "ReproducesPinnedMatrixElement": rel < 1e-12,
    }
    payload = {
        "Status": "CompleteHgqV3CopiedBridgeValidation",
        "AlphaS": alpha_s,
        "PinnedMatrixElement": expected,
        "BridgeMatrixElement": value,
        "RelativeDifference": rel,
        "PhotonQ2": q2,
        "MaximumConservationResidual": residual,
        "MaximumExternalMassSquared": max_mass2,
        "UpstreamSource": "scripts/Hgq/madgraph_check (S05 accepted, S18 agreed 8.2e-16)",
        "SHA256": {p.name: sha256(p) for p in sorted(COPIES.iterdir()) if p.is_file()},
        "Checks": checks,
    }
    (HERE / "s01_bridge_validation.json").write_text(json.dumps(payload, indent=1) + "\n")
    for k, v in checks.items():
        print(f"[mg-s01] {k}: {v}")
    print(f"[mg-s01] pinned  = {expected!r}")
    print(f"[mg-s01] bridge  = {value!r}")
    print(f"[mg-s01] relative difference = {rel:.6e}")
    ok = all(checks.values())
    print(f"[mg-s01] ALL CHECKS PASS: {ok}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
