#!/usr/bin/env python3
"""madgraph_check/s03 : Hgq_v3 real matrix element vs MadGraph, several points.

local = e^4 * e_u^2 * (L.W)/Q2^2 , averaged over 4 lepton-plane azimuths.
W is rebuilt from Mg, Mpp in the basis {-g+qq/q^2, Pt Pt} by a numeric 2x2
solve and verified against both projections.
A constant MadGraph/local ratio across points = normalisation; a varying one =
physics.
"""
import ctypes, json, math, os
from pathlib import Path
import numpy as np

HERE = Path(__file__).resolve().parent
os.chdir(HERE)
G = np.diag([1.0, -1.0, -1.0, -1.0])
E_U = 2.0 / 3.0
dot = lambda a, b: float(a @ G @ b)
contract = lambda A, B: float(np.sum(A * (G @ B @ G)))

pts = json.loads((HERE / "s02a_points.json").read_text())
loc = json.loads((HERE / "s02b_local_projections.json").read_text())
pin = json.loads((HERE / "upstream_copies" / "s05_bridge_validation.json").read_text())
alpha_s = float(loc["AlphaS"])
divisor = float(pin["GeneratedFinalIdentityDivisor"])
aewm1 = float([l.split()[1] for l in (HERE / "generated_process" / "Cards" /
               "param_card.dat").read_text().splitlines() if "# aEWM1" in l][0])
e2 = 4.0 * math.pi / aewm1

lib = ctypes.CDLL(str(HERE / "upstream_copies" / "s03_libhgq_madgraph_bridge.so"))
lib.hgq_mg_init.argtypes = [ctypes.c_char_p]; lib.hgq_mg_init.restype = None
lib.hgq_mg_eval.argtypes = [ctypes.POINTER(ctypes.c_double), ctypes.c_double,
                            ctypes.POINTER(ctypes.c_double)]
lib.hgq_mg_eval.restype = None
lib.hgq_mg_init(b"generated_process/Cards/param_card.dat")


def boost_to_rest(P, v):
    """boost v into the rest frame of P"""
    M = math.sqrt(dot(P, P)); b = P[1:] / P[0]; b2 = float(b @ b)
    if b2 < 1e-30:
        return v.copy()
    g = P[0] / M; bp = float(b @ v[1:])
    return np.array([g * (v[0] - bp),
                     *(v[1:] + ((g - 1.0) * bp / b2 - g * v[0]) * b)])


def align_z(ref, v):
    """rotate so that ref's spatial part lies along +z"""
    n = ref[1:] / np.linalg.norm(ref[1:]); z = np.array([0.0, 0.0, 1.0])
    ax = np.cross(n, z); s_ = np.linalg.norm(ax); c = float(n @ z)
    if s_ < 1e-14:
        R = np.eye(3) if c > 0 else np.diag([1.0, -1.0, -1.0])
    else:
        ax = ax / s_; th = math.atan2(s_, c)
        K = np.array([[0, -ax[2], ax[1]], [ax[2], 0, -ax[0]], [-ax[1], ax[0], 0]])
        R = np.eye(3) + math.sin(th) * K + (1 - math.cos(th)) * (K @ K)
    return np.array([v[0], *(R @ v[1:])])


def to_sidis_frame(mom):
    """p+q rest frame with q along +z: there p and q are collinear, so the
       frame time direction lies in span{p,q} and <L>.W closes on F1,F2."""
    p_, q_ = mom[1], mom[0] - mom[2]
    P = p_ + q_
    m = [boost_to_rest(P, v) for v in mom]
    qb = boost_to_rest(P, q_)
    return [align_z(qb, v) for v in m]


def rot(axis, phi, v):
    n = axis / np.linalg.norm(axis); sp = v[1:]
    out = (sp * math.cos(phi) + np.cross(n, sp) * math.sin(phi)
           + n * np.dot(n, sp) * (1 - math.cos(phi)))
    return np.array([v[0], *out])


rows_out = []
for name in pts:
    mom = [np.array(m, float) for m in pts[name]["momenta"]]
    mom = to_sidis_frame(mom)          # <- average must be done in this frame
    p, k1, k2, k3 = mom[1], mom[3], mom[4], mom[5]
    q = mom[0] - mom[2]; q2 = dot(q, q); Q2 = -q2
    Mg, Mpp = float(loc["Local"][name]["Mg"]), float(loc["Local"][name]["Mpp"])

    Pt = p - (dot(p, q) / q2) * q
    T1 = -G + np.outer(q, q) / q2
    T2 = np.outer(Pt, Pt)
    pd = G @ p
    M = np.array([[contract(G, T1), contract(G, T2)],
                  [float(pd @ T1 @ pd), float(pd @ T2 @ pd)]])
    A, B = np.linalg.solve(M, np.array([Mg, Mpp]))
    W = A * T1 + B * T2
    ok = (abs(contract(G, W) - Mg) <= 1e-10 * max(1, abs(Mg)) and
          abs(float(pd @ W @ pd) - Mpp) <= 1e-10 * max(1, abs(Mpp)))

    mgs, locs = [], []
    for i in range(4):
        phi = 2 * math.pi * i / 4
        lin, lout = rot(q[1:], phi, mom[0]), rot(q[1:], phi, mom[2])
        cfg = [lin, p, lout, k1, k2, k3]
        arr = (ctypes.c_double * 24)(*[float(c) for v in cfg for c in v])
        o = ctypes.c_double(0.0)
        lib.hgq_mg_eval(arr, ctypes.c_double(alpha_s), ctypes.byref(o))
        mgs.append(o.value)
        L = 2.0 * (np.outer(lin, lout) + np.outer(lout, lin) - G * dot(lin, lout))
        locs.append(e2 * e2 * E_U**2 * contract(L, W) / Q2**2)

    mg_avg, loc_avg = divisor * sum(mgs) / 4, sum(locs) / 4
    ratio = mg_avg / loc_avg
    rows_out.append({"point": name, "Q2": Q2, "reconstruction_ok": ok,
                     "madgraph": mg_avg, "local": loc_avg, "ratio": ratio,
                     "relative_difference": abs(mg_avg - loc_avg) / max(abs(mg_avg), abs(loc_avg))})
    print(f"[mg-s03] {name:<12} recon={ok}  MadGraph={mg_avg: .10e}  "
          f"local={loc_avg: .10e}  MG/local={ratio:.10f}")

rs = [r["ratio"] for r in rows_out]
spread = max(rs) / min(rs) - 1.0
print(f"\n[mg-s03] ratios: {['%.10f' % r for r in rs]}")
print(f"[mg-s03] max/min - 1 = {spread:.3e}  -> "
      f"{'CONSTANT (normalisation)' if spread < 1e-6 else 'VARIES (physics disagreement)'}")
agree = all(r["relative_difference"] < 1e-10 for r in rows_out)
print(f"[mg-s03] all points agree within 1e-10: {agree}")
(HERE / "s03_madgraph_comparison.json").write_text(
    json.dumps({"AlphaS": alpha_s, "AlphaEMInverse": aewm1, "e2": e2,
                "Points": rows_out, "RatioSpread": spread,
                "OverallAgreement": agree}, indent=1) + "\n")
raise SystemExit(0 if agree else 1)
