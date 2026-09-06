#!/usr/bin/env python3
"""madgraph_check/s02a : build several independent massless 2->4 configurations
   e-(l) g(p) -> e-(l') u(k1) ubar(k2) g(k3)  and their Hgq invariants.

   One point cannot separate a wrong overall normalisation from a wrong matrix
   element: a constant factor gives the SAME MadGraph/local ratio everywhere,
   a physics error does not.  So several genuinely different points are used.
   Invariant conventions are s02_real.wls:15-23.
"""
from __future__ import annotations
import json, math
from pathlib import Path
import numpy as np

HERE = Path(__file__).resolve().parent
G = np.diag([1.0, -1.0, -1.0, -1.0])


def dot(a, b): return float(a @ G @ b)


def direction(theta, phi):
    return np.array([math.sin(theta) * math.cos(phi),
                     math.sin(theta) * math.sin(phi), math.cos(theta)])


def build(angles, energies, ecm=1000.0):
    """three directions + three energies; the fourth momentum closes the event"""
    ns = [direction(*a) for a in angles]
    v = -sum(e * n for e, n in zip(energies, ns))
    e4 = float(np.linalg.norm(v))
    if e4 <= 0.0:
        raise RuntimeError("degenerate closure")
    n4 = v / e4
    scale = ecm / (sum(energies) + e4)
    outs = [np.array([e * scale, *(e * scale * n)]) for e, n in zip(energies, ns)]
    outs.append(np.array([e4 * scale, *(e4 * scale * n4)]))
    lin = np.array([ecm / 2, 0.0, 0.0, ecm / 2])
    gin = np.array([ecm / 2, 0.0, 0.0, -ecm / 2])
    return [lin, gin, *outs]


def invariants(mom):
    lin, p, lout, k1, k2, k3 = mom
    q = lin - lout
    Q2 = -dot(q, q)
    return {"Q2": Q2, "s": 2 * dot(p, q) - Q2, "u": -2 * dot(p, k1),
            "t": -Q2 - 2 * dot(q, k1), "u2": -2 * dot(p, k2),
            "t2": -Q2 - 2 * dot(q, k2), "xHat": Q2 / (2 * dot(p, q))}


def main() -> int:
    r3 = math.sqrt(3.0); e = 250.0
    tetra = [np.array(v, float) for v in (
        [500.0, 0, 0, 500.0], [500.0, 0, 0, -500.0],
        [e, e / r3, e / r3, e / r3], [e, e / r3, -e / r3, -e / r3],
        [e, -e / r3, e / r3, -e / r3], [e, -e / r3, -e / r3, e / r3])]
    configs = {
        "tetrahedron": tetra,
        "asym_1": build([(0.60, 0.30), (1.90, 2.10), (2.50, 4.00)], [260.0, 230.0, 210.0]),
        "asym_2": build([(1.10, 0.90), (2.20, 3.40), (0.80, 5.10)], [300.0, 190.0, 240.0]),
    }
    out = {}
    for name, mom in configs.items():
        res = max(abs((mom[0] + mom[1] - mom[2] - mom[3] - mom[4] - mom[5])[c]) for c in range(4))
        mass = max(abs(dot(m, m)) for m in mom)
        inv = invariants(mom)
        if res > 1e-9 or mass > 1e-6 or inv["Q2"] <= 0:
            raise RuntimeError(f"{name}: res={res} mass={mass} Q2={inv['Q2']}")
        out[name] = {"momenta": [m.tolist() for m in mom], "invariants": inv,
                     "ConservationResidual": res, "MaxMassSquared": mass}
        print(f"[mg-s02a] {name}: Q2={inv['Q2']:.6g} s={inv['s']:.6g} t={inv['t']:.6g} "
              f"u={inv['u']:.6g} xHat={inv['xHat']:.6g}")
    (HERE / "s02a_points.json").write_text(json.dumps(out, indent=1) + "\n")
    print(f"[mg-s02a] wrote s02a_points.json with {len(out)} points")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
