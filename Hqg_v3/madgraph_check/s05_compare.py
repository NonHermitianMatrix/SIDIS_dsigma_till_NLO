"""Report the executed Hqg Born/real MadGraph projector comparison."""
from pathlib import Path
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parent


def sha(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


reference = json.loads((ROOT / "s03_result.json").read_text())
local = json.loads((ROOT / "s04_result.json").read_text())
assert reference["Channel"] == local["Channel"] == "Hqg"
assert reference["SourceSHA256"] == sha(ROOT / "s03_sample_madgraph.py")
assert local["SourceSHA256"] == sha(ROOT / "s04_evaluate_local.wl")
assert local["SampleSHA256"] == sha(ROOT / "s03_result.json")
for process in reference["Processes"].values():
    for name, digest in process["Files"].items():
        assert sha(ROOT / name) == digest, name
by_id = {row["ID"]: row for row in local["Rows"]}
assert list(by_id) == [row["ID"] for row in reference["Rows"]]
rows, average_rows = [], []


def compare(identifier, kind, label, own, external):
    assert all(math.isfinite(value) for value in [own, external])
    difference = external-own
    scale = max(abs(own), abs(external))
    tolerance = 1e-25 + 1e-8*scale
    return {"ID": identifier, "Kind": kind, "Projection": label, "Local": own,
            "MadGraph": external, "Difference": difference,
            "RelativeDifference": abs(difference)/scale if scale else 0.,
            "Tolerance": tolerance, "WithinTolerance": abs(difference) <= tolerance}


for point in reference["Rows"]:
    own = by_id[point["ID"]]
    for projector in ["Pg", "Ppp"]:
        rows.append(compare(point["ID"], point["Kind"], projector,
                            own["LocalScaled"+projector], point["MadGraphScaled"+projector]))
    for index, (lv, mv) in enumerate(zip(own["LocalTaggedAzimuthAverages"], point["TaggedAzimuthAverages"])):
        average_rows.append(compare(point["ID"], point["Kind"], "lepton_setting_"+str(index+1), lv, mv))
summary = {"PhysicalPoints": len(reference["Rows"]), "ProjectionComparisons": len(rows),
    "AllProjectorsWithinTolerance": all(row["WithinTolerance"] for row in rows),
    "AllAzimuthAveragesWithinTolerance": all(row["WithinTolerance"] for row in average_rows),
    "MaximumProjectorRelativeDifference": max(row["RelativeDifference"] for row in rows),
    "MaximumAzimuthAverageRelativeDifference": max(row["RelativeDifference"] for row in average_rows),
    "MaximumGluonExchangeRelativeDifference": max(row["GluonExchangeRelativeDifference"] for row in local["Rows"]),
    "ByProcess": {kind: {"Count": sum(row["Kind"] == kind for row in rows),
        "AllWithinTolerance": all(row["WithinTolerance"] for row in rows if row["Kind"] == kind),
        "MaximumRelativeDifference": max(row["RelativeDifference"] for row in rows if row["Kind"] == kind)}
        for kind in reference["Processes"]}}
result = {"Status": "Complete", "Channel": "Hqg", "DifferenceDirection": "MadGraph minus local",
    "SourceSHA256": sha(Path(__file__)), "LocalSHA256": sha(ROOT / "s04_result.json"),
    "ReferenceSHA256": sha(ROOT / "s03_result.json"), "Summary": summary,
    "Processes": reference["Processes"], "ProjectorRows": rows, "AzimuthAverageRows": average_rows}
lines = ["# Hqg MadGraph tree comparison", "",
    "Incoming quark, observed gluon. Fresh photon-only Born `e- u -> e- u g` and real "
    "`e- u -> e- u g g` processes are compared with accepted Hqg_v3 S02/S05.", "",
    "This directly tests the projector boundary corresponding to Hqqbar S07, with spin/color sums "
    "already included. It is not a separate full open-tensor S06 check. No loop, phase-space "
    "integration, factorization or finite NLO delta coefficient is tested.", "",
    "MadGraph's own RAMBO supplies eight accepted deterministic points per process. "
    "The exact lepton mass-shell map and azimuth quadrature are derived by SymPy. "
    "Two lepton kinematics reconstruct both Pg and Ppp. Columns include the same photon "
    "propagator and measured coupling/charge normalization. The generated identical-gluon "
    "factor is converted to the accepted tagged-gluon convention.", "",
    "The numerical interface also passed a direct Fortran-driver comparison for each process. "
    "Generator workflow: [official MadGraph standalone documentation]"
    "(https://cp3.irmp.ucl.ac.be/projects/madgraph/wiki/FAQ-General-4).", "",
    "| Point | Projection | Local | MadGraph | MadGraph − local | Relative difference | Close |",
    "|---|---|---:|---:|---:|---:|:---:|"]
for row in rows:
    lines.append(f"| {row['ID']} | {row['Projection']} | {row['Local']:.12e} | {row['MadGraph']:.12e} | "
                 f"{row['Difference']:.12e} | {row['RelativeDifference']:.5e} | {row['WithinTolerance']} |")
lines += ["", "```json", json.dumps(summary, indent=2), "```", "",
    "Tolerance: abs(difference) <= 1e-25 + 1e-8*max(abs(MadGraph),abs(local)). "
    "All per-orientation values, normalization factors, input hashes and projector solves are "
    "retained in s03_result.json and s04_result.json. A mismatch is reported without tuning either input.", ""]
for name, content in [("s05_result.json", json.dumps(result, indent=2)+"\n"),
                       ("madgraph_minus_local.md", "\n".join(lines))]:
    path = ROOT / name
    assert not path.exists(), "Refusing to overwrite " + name
    temporary = path.with_name(path.name+".tmp")
    temporary.write_text(content)
    if path.suffix == ".json":
        assert json.loads(temporary.read_text())["Status"] == "Complete"
    temporary.rename(path)
print(json.dumps(summary, indent=2))
print("HQG_MADGRAPH_S05_SUCCESS")
