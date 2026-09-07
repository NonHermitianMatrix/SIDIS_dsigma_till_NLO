from pathlib import Path
import ast
import hashlib
import json
import math
from types import SimpleNamespace

BASE = Path(__file__).resolve().parent
manifest = json.loads((BASE / "s01_result.json").read_text())
data = json.loads((BASE / "s02_result.json").read_text())
sha256 = lambda b: hashlib.sha256(b).hexdigest()
assert sha256((BASE.parent / "s05_result/Fhats.wl").read_bytes()) == manifest["production_sha256"]
functions = {}
endpoint_check = json.loads((BASE / "s02_endpoint_result.json").read_text())
assert endpoint_check["all_endpoints_zero"]
assert sha256((BASE / "s01_auxiliary.wl").read_bytes()) == endpoint_check["auxiliary_sha256"] == manifest["auxiliary_sha256"]
assert sha256((BASE / "reference/sidis.py").read_bytes()) == manifest["files"]["sidis.py"]["sha256"]
for projection in ["Pg", "Ppp"]:
    for case in "ABC":
        name = f"NLO/{projection}/fchn5{case}.py"
        source = (BASE / "reference" / name).read_bytes()
        assert sha256(source) == manifest["files"][name]["sha256"]
        for function_name in ["regular", "plus1B", "plus2B"]:
            node = next(n for n in ast.parse(source).body
                        if isinstance(n, ast.FunctionDef) and n.name == function_name)
            assert len(node.body) == 1 and isinstance(node.body[0], ast.Return)
            node.decorator_list = []
            for call in [n for n in ast.walk(node) if isinstance(n, ast.Call)]:
                assert isinstance(call.func, ast.Attribute) and isinstance(call.func.value, ast.Name)
                assert call.func.value.id == "np" and call.func.attr in {"log", "sqrt"}
            environment = {"np": SimpleNamespace(pi=math.pi, log=math.log, sqrt=math.sqrt),
                           "EulerGamma": data["euler_gamma"]}
            module = ast.fix_missing_locations(ast.Module(body=[node], type_ignores=[]))
            exec(compile(module, name, "exec"), environment)
            functions[projection, case, function_name] = environment[function_name]

rows = []
for point in data["points"]:
    p = point["parameters"]
    args = dict(g=1, gp=1, s=p["s"], t=p["t"], Q=math.sqrt(p["Q2"]),
                s23=p["s23"], mu=math.sqrt(p["mu2"]), nf=3)
    raw = [functions[projection, "A", "regular"](**args) for projection in ["Pg", "Ppp"]]
    assert all(functions[projection, case, "regular"](**args) == 0
               for projection in ["Pg", "Ppp"] for case in "BC")
    contractions = [point["published_weight"] * v for v in raw]
    hats = [sum(a*b for a, b in zip(row, contractions)) for row in point["projector_matrix"]]
    augmented_raw = [v + functions[projection, "A", "plus1B"](**args, B=p["s"])/p["s23"]
                     + functions[projection, "A", "plus2B"](**args, B=p["s"])*math.log(p["s23"])/p["s23"]
                     for projection, v in zip(["Pg", "Ppp"], raw)]
    augmented = [point["published_weight"]*v for v in augmented_raw]
    augmented_hats = [sum(a*b for a, b in zip(row, augmented)) for row in point["projector_matrix"]]
    for representation, values in [("regular_only", hats), ("all_supplied_coefficients", augmented_hats)]:
        for label, published, local in zip(["F1hat", "F2hat"], values, point["local_hats"]):
            difference = published - local
            scale = max(abs(published), abs(local))
            tolerance = 1e-10 + 1e-7 * scale
            rows.append({"parameters": p, "branch_s_plus_t": point["branch_s_plus_t"],
                         "representation": representation, "hat": label, "local": local, "BigTMD": published,
                         "BigTMD_minus_local": difference,
                         "relative_difference": abs(difference)/scale if scale else 0,
                         "tolerance": tolerance, "pass": abs(difference) <= tolerance})
    print(p, "all-coefficient relative differences", [r["relative_difference"] for r in rows[-2:]], flush=True)

report = {"reference_commit": manifest["commit"], "production_sha256": manifest["production_sha256"],
          "comparisons": rows, "all_pass": all(r["pass"] for r in rows),
          "maximum_relative_difference": max(r["relative_difference"] for r in rows),
          "coefficient_agreement": all(r["pass"] for r in rows if r["representation"] == "all_supplied_coefficients"),
          "maximum_coefficient_relative_difference": max(r["relative_difference"] for r in rows if r["representation"] == "all_supplied_coefficients"),
          "maximum_regular_only_mu_equals_Q_relative_difference": max(r["relative_difference"] for r in rows if r["representation"] == "regular_only" and r["parameters"]["mu2"] == r["parameters"]["Q2"]),
          "branch_coverage": sorted({r["branch_s_plus_t"] for r in rows}),
          "policy": "Direct published Python decimal arithmetic; no rational reconstruction or coefficient fitting. JIT decorators removed; scalar numpy log/sqrt/pi use Python math equivalents.",
          "driver_includes_channel": manifest["driver_includes_channel"],
          "distribution_policy": "The pinned driver excludes channel 5 from its NLO loop. This check calls its channel-5 coefficient functions directly. Wolfram verifies their plus-coefficient endpoints before the complete ordinary density is assembled. The production result is unchanged."}
(BASE / "s03_result.json").write_text(json.dumps(report, indent=2, allow_nan=False) + "\n")
lines = ["# Hqqbar BigTMD comparison", "", "This check compares the supplied Hqqbar coefficient functions directly. The pinned public driver excludes channel 5 from its NLO loop.",
         f"All-coefficient comparisons passed: {sum(r['pass'] for r in rows if r['representation']=='all_supplied_coefficients')}/{sum(r['representation']=='all_supplied_coefficients' for r in rows)}.",
         f"Maximum all-coefficient relative difference: {report['maximum_coefficient_relative_difference']:.6g}.",
         f"Maximum regular-only relative difference at its mu=Q choice: {report['maximum_regular_only_mu_equals_Q_relative_difference']:.6g}.",
         "", "Signed differences are BigTMD minus local. Tolerance: 1e-10 + 1e-7 times the larger magnitude.",
         "Production remains symbolic. Only this check evaluates numerical points, with local hats first evaluated at 60 digits.",
         "This establishes numerical agreement at the listed points, not a general symbolic equality proof against the published decimal functions.",
         "The points cover positive, negative, and zero s+t, three positive scale choices, and both unit and nonunit recoil mass squared.",
         "The regular_only rows test the regular coefficient in isolation. The literal driver supplies mu=Q to the coefficient functions; the other two scales exercise the published functions directly.",
         "", report["policy"], "", report["distribution_policy"], "",
         f"Reference: [pinned BigTMD source](https://github.com/JeffersonLab/BigTMD/tree/{manifest['commit']}); [driver selection](https://github.com/JeffersonLab/BigTMD/blob/{manifest['commit']}/sidis.py#L231).",
         f"Production SHA256: {manifest['production_sha256']}", "",
         "| Q2 | s | s23 | t | mu2 | Representation | Hat | BigTMD minus local | Pass |", "|---|---|---|---|---|---|---|---|---|"]
for row in rows:
    p = row["parameters"]
    lines.append(f"| {p['Q2']} | {p['s']} | {p['s23']} | {p['t']} | {p['mu2']} | {row['representation']} | {row['hat']} | {row['BigTMD_minus_local']:.9g} | {row['pass']} |")
(BASE / "bigtmd_minus_local.md").write_text("\n".join(lines) + "\n")
print("All-coefficient agreement:", report["coefficient_agreement"], report["maximum_coefficient_relative_difference"], flush=True)
print("Regular-only discrepancy retained:", not report["all_pass"], flush=True)
raise SystemExit(0 if report["coefficient_agreement"] else 1)
