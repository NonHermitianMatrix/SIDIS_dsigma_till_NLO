#!/usr/bin/env python3
"""bigTMD_check/s02 : compare accepted Hgq F hats with BigTMD channel 1 case A.

Same form as Hqqbar/bigTMD_check/s02: a DIRECT signed difference
(BigTMD minus local) against a fixed tolerance, with NO fitted normalisation
constant.  Conventions are pinned on the local side (EL=1, g_s=1 so
as = 1/(4 Pi); ScaleMu = Q) and the BigTMD modules are called charge-stripped
with g=gp=1, so both sides are already in the same units and no Jacobian is
applied to either.

Hgq is BigTMD channel 1, which unlike Hqqbar's channel 5 carries ALL FOUR
distribution coefficients, so regular, plus1B, plus2B and delta are all
compared, for both projectors (Pg, Ppp) and both structure functions.
"""
from __future__ import annotations
import importlib.util, json, math, os, sys
from pathlib import Path

os.environ["NUMBA_DISABLE_JIT"] = "1"
os.environ["PYTHONDONTWRITEBYTECODE"] = "1"
sys.dont_write_bytecode = True

HERE = Path(__file__).resolve().parent
REF = HERE / "reference"
LOCAL_PATH = HERE / "local_fhat_benchmarks.json"
BIGTMD_OUTPUT = HERE / "bigtmd_fhat_benchmarks.json"
DIFFERENCE_OUTPUT = HERE / "bigtmd_minus_local.json"
REPORT_OUTPUT = HERE / "bigtmd_minus_local.md"

ABSOLUTE_TOLERANCE = 1.0e-10
RELATIVE_TOLERANCE = 1.0e-7
COMPONENTS = {"reg": "regular", "p1": "plus1B", "p2": "plus2B", "del": "delta"}


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def finite_real(value, label: str) -> float:
    n = complex(value)
    if abs(n.imag) > 1.0e-10 * max(1.0, abs(n.real)):
        raise RuntimeError(f"{label} unexpectedly complex: {n!r}")
    out = float(n.real)
    if not math.isfinite(out):
        raise RuntimeError(f"{label} not finite: {out!r}")
    return out


def fhat_from_projectors(pg: float, ppp: float, xhat: float, q2: float):
    return {"F1hat": -0.5 * pg + 2.0 * xhat**2 / q2 * ppp,
            "F2hat": -xhat * pg + 12.0 * xhat**3 / q2 * ppp}


def evaluate(module, comp: str, b: dict) -> float:
    fn = getattr(module, COMPONENTS[comp])
    q = math.sqrt(float(b["Q2"]))
    kw = dict(g=1.0, gp=1.0, s=float(b["s"]), t=float(b["t"]), Q=q,
              s23=float(b["S23Sample"]), mu=q, nf=float(b["Nf"]))
    if COMPONENTS[comp] != "regular":
        kw["B"] = float(b["B"])
    return finite_real(fn(**kw), f"BigTMD {COMPONENTS[comp]} {b['ID']}")


def main() -> int:
    if not LOCAL_PATH.exists():
        print(f"MISSING {LOCAL_PATH} - run s01 first"); return 2
    local = json.loads(LOCAL_PATH.read_text())
    conv = local["Conventions"]
    if conv.get("LocalJacobianAlreadyIncluded") is not False or \
       conv.get("DifferenceDirectionExpectedByS02") != "BigTMD minus local":
        print("ABORT: local conventions are not the ones this comparator assumes")
        return 2

    Pg  = load("bt_pg_1A",  REF / "Pg"  / "fchn1A.py")
    Ppp = load("bt_ppp_1A", REF / "Ppp" / "fchn1A.py")
    PgB = load("bt_pg_1B",  HERE.parent / "oracle" / "fchn1B.py")
    PgC = load("bt_pg_1C",  HERE.parent / "oracle" / "fchn1C.py")

    benches = {b["ID"]: b for b in local["Benchmarks"]}
    zeros_ok = True
    bigtmd, rows = {}, []
    for bid, b in benches.items():
        for mod, lbl in ((PgB, "fchn1B"), (PgC, "fchn1C")):
            for comp in COMPONENTS:
                if evaluate(mod, comp, b) != 0.0:
                    zeros_ok = False
                    print(f"NONZERO {lbl} {comp} at {bid}")
        bigtmd[bid] = {}
        for comp in COMPONENTS:
            pg, ppp = evaluate(Pg, comp, b), evaluate(Ppp, comp, b)
            vals = {"Hg": pg, "Hpp": ppp}
            vals.update(fhat_from_projectors(pg, ppp, float(b["xHat"]), float(b["Q2"])))
            bigtmd[bid][comp] = vals
            for q in ("Hg", "Hpp", "F1hat", "F2hat"):
                lv = float(local["LocalFHatByBenchmark"][bid][q][comp])
                bv = vals[q]
                diff = bv - lv
                scale = max(abs(bv), abs(lv))
                rel = abs(diff) / scale if scale > 0.0 else 0.0
                tol = ABSOLUTE_TOLERANCE + RELATIVE_TOLERANCE * scale
                rows.append({"Benchmark": bid, "Quantity": q, "Component": comp,
                             "Local": lv, "BigTMD": bv, "BigTMDMinusLocal": diff,
                             "AbsoluteDifference": abs(diff),
                             "RelativeDifference": rel, "ToleranceAtPoint": tol,
                             "NumericallyClose": abs(diff) <= tol})

    BIGTMD_OUTPUT.write_text(json.dumps(bigtmd, indent=1))
    DIFFERENCE_OUTPUT.write_text(json.dumps(rows, indent=1))

    max_abs = max(r["AbsoluteDifference"] for r in rows)
    max_rel = max(r["RelativeDifference"] for r in rows)
    all_close = all(r["NumericallyClose"] for r in rows)
    lines = ["# Hgq BigTMD channel-1A consistency check", "",
             "Signed difference: **BigTMD minus local**.", "",
             "Charge-stripped, case A, all four distribution coefficients "
             "(regular, plus1B, plus2B, delta), both projectors and both "
             "structure functions.  Conventions: EL=1, g_s=1 (as = 1/(4 Pi)), "
             "ScaleMu = Q, no Jacobian on either side.", "",
             "| Benchmark | Component | Quantity | Local | BigTMD | BigTMD-local | Relative | Close |",
             "|---|:---:|---|---:|---:|---:|---:|:---:|"]
    for r in rows:
        lines.append(
            f"| {r['Benchmark']} | {r['Component']} | {r['Quantity']} | "
            f"{r['Local']:.12e} | {r['BigTMD']:.12e} | {r['BigTMDMinusLocal']:.12e} | "
            f"{r['RelativeDifference']:.5e} | {r['NumericallyClose']} |")
    lines += ["", f"All channel-1 B/C generated functions are exact zero: `{zeros_ok}`.", "",
              f"Maximum absolute difference: `{max_abs:.12e}`.", "",
              f"Maximum relative difference: `{max_rel:.12e}`.", "",
              f"All {len(rows)} compared coefficients within tolerance: `{all_close}`.", "",
              f"Overall tested agreement: `{all_close and zeros_ok}`.", "",
              "Tolerance: `abs(diff) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local))`.", "",
              "BigTMD decimal coefficients were executed as written; the local "
              "inputs remained exact until final benchmark evaluation."]
    REPORT_OUTPUT.write_text("\n".join(lines) + "\n")
    print("\n".join(lines[-14:]))
    return 0 if (all_close and zeros_ok) else 1


if __name__ == "__main__":
    raise SystemExit(main())
