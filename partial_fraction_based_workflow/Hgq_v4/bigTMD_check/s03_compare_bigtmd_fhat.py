"""Compare Hgq F hats with the pinned BigTMD channel-1A functions."""
import os
import sys

os.environ["NUMBA_DISABLE_JIT"] = "1"
for variable in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS"):
    os.environ[variable] = "1"
sys.dont_write_bytecode = True

import hashlib
import importlib.util
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CHANNEL = ROOT.parent
AUTHOR = ROOT
PARTS = ("Born", "Delta", "L0", "L1", "Regular")
FUNCTIONS = ("F1", "F2")
ABS_TOL = 1e-10
REL_TOL = 1e-7


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(test, label):
    if not test:
        raise RuntimeError(label)
    print("PASS:", label, flush=True)


def finite(value, label):
    value = complex(value)
    require(math.isfinite(value.real) and math.isfinite(value.imag), label + " finite")
    require(abs(value.imag) <= 1e-18 * max(abs(value.real), 1e-30), label + " real")
    return value.real


def atomic(path, content):
    require(not path.exists(), "new output " + path.name)
    temporary = path.with_name(path.name + ".tmp")
    with temporary.open("x") as stream:
        stream.write(content)
    if path.suffix == ".json":
        json.loads(temporary.read_text())
    temporary.rename(path)


def compare(local, reference):
    difference = reference - local
    scale = max(abs(local), abs(reference))
    tolerance = ABS_TOL + REL_TOL * scale
    return {"Local": local, "BigTMD": reference, "Difference": difference,
            "RelativeDifference": abs(difference) / scale if scale else 0.0,
            "Tolerance": tolerance, "WithinTolerance": abs(difference) <= tolerance}


def check_inputs(data):
    require(data["Status"] == "Complete" and data["Channel"] == "Hgq", "completed Hgq export")
    require(sha(ROOT / "s02_export_fhat_benchmarks.wl") == data["SourceSHA256"], "S02 source")
    for name, record in data["IndependentInputs"]["files"].items():
        require(sha(CHANNEL / name) == record["sha256"], "frozen " + name)
    require(sha(ROOT / "s01_result.wl") == data["AuthorResultSHA256"], "pinned symbolic reference")
    require(sha(ROOT / "s01_result.json") == data["AuthorMetadataSHA256"], "reference metadata")


def table(rows, with_part):
    columns = "Benchmark | F hat | " + ("Coefficient | " if with_part else "")
    result = ["| " + columns + "Local | BigTMD | BigTMD − local | Relative difference | Close |",
              "| " + " | ".join(["---"] * (8 if with_part else 7)) + " |"]
    for row in rows:
        label = f"{row['Benchmark']} | {row['Function']} | "
        if with_part:
            label += row["Part"] + " | "
        result.append("| " + label +
                      f"{row['Local']:.12e} | {row['BigTMD']:.12e} | "
                      f"{row['Difference']:.12e} | {row['RelativeDifference']:.5e} | "
                      f"{row['WithinTolerance']} |")
    return "\n".join(result)


def main():
    import subprocess
    if importlib.util.find_spec("numba") is None:
        subprocess.run([sys.executable,"-m","pip","install","--only-binary=:all:",
            "--target",str(ROOT/"software"),"numpy==1.26.4","scipy==1.13.1",
            "numba==0.60.0","mpmath==1.3.0"],check=True)
        importlib.invalidate_caches()
    data = json.loads((ROOT / "s02_result.json").read_text())
    check_inputs(data)
    metadata = json.loads((AUTHOR / "s01_result.json").read_text())
    require(metadata["tree"] == data["AuthorTree"], "pinned BigTMD commit")
    source_records = {item["path"]: item for item in metadata["sources"]}
    driver = AUTHOR / "published" / "sidis.py"
    require(sha(driver) == source_records["sidis.py"]["sha256"], "published driver")
    modules = {}
    source_hashes = {"sidis.py": sha(driver)}
    for projector in ("Pg", "Ppp"):
        path = AUTHOR / "published" / (projector + "_fchn1A.py")
        record = source_records[f"NLO/{projector}/fchn1A.py"]
        require(sha(path) == record["sha256"], "Hgq channel-1A " + projector)
        source_hashes[projector] = sha(path)
        spec = importlib.util.spec_from_file_location("hgq_bigtmd_" + projector, path)
        module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = module
        spec.loader.exec_module(module)
        modules[projector] = module

    points = data["Benchmarks"]
    expected_interior = {(p["ID"], name) for p in points for name in FUNCTIONS}
    expected_coefficients = {(p["ID"], name, part)
                             for p in points for name in FUNCTIONS for part in PARTS}
    local = {(row["Benchmark"], row["Function"]): row for row in data["InteriorRows"]}
    require(set(local) == expected_interior, "complete Hgq interior inputs")
    require({(row["Benchmark"], row["Function"], row["Part"])
             for row in data["CoefficientRows"]} == expected_coefficients,
            "complete Hgq coefficient inputs")
    raw_records, direct_rows, reconstruction_rows = [], [], []
    for point in points:
        print("EVALUATE published Hgq:", point["ID"], flush=True)
        require(0 < point["S23Sample"] < point["S23UpperB"], "strictly interior recoil")
        densities = []
        for projector, module in modules.items():
            common = {"g": 1, "gp": 1, "s": point["s"], "t": point["t"],
                      "Q": point["Q"], "s23": point["S23Sample"],
                      "mu": point["Q"], "nf": point["Nf"]}
            values = [finite(module.regular(**common), projector + " regular")]
            for function in ("plus1B", "plus2B"):
                values.append(finite(getattr(module, function)(**common, B=point["S23UpperB"]),
                                     projector + " " + function))
            density = finite(sum(weight * value for weight, value in
                                 zip(point["RawInteriorWeights"], values)), projector + " density")
            densities.append(density)
            raw_records.append({"Benchmark": point["ID"], "Projector": projector,
                                "Regular": values[0], "Plus1B": values[1], "Plus2B": values[2],
                                "OrdinaryDensityBeforeJacobian": density})
        for name, weights in zip(FUNCTIONS, point["ProjectorWeights"]):
            value = finite(point["Jacobian"] * sum(w * v for w, v in zip(weights, densities)),
                           point["ID"] + " " + name)
            saved = local[(point["ID"], name)]
            direct_rows.append({"Benchmark": point["ID"], "Function": name,
                                **compare(saved["Local"], value)})
            reconstruction_rows.append({"Benchmark": point["ID"], "Function": name,
                                        **compare(saved["BigTMDReconstructed"], value)})

    coefficient_rows = [{"Benchmark": row["Benchmark"], "Function": row["Function"],
                         "Part": row["Part"], **compare(row["Local"], row["BigTMDReconstructed"])}
                        for row in data["CoefficientRows"]]
    require(len(direct_rows) == len(expected_interior), "direct comparison coverage")
    require(len(coefficient_rows) == len(expected_coefficients), "coefficient comparison coverage")
    require(all(math.isfinite(row[key]) for row in direct_rows + coefficient_rows
                for key in ("Local", "BigTMD", "Difference", "RelativeDifference")),
            "all reported comparisons finite")
    check_inputs(data)
    for projector in modules:
        require(sha(AUTHOR / "published" / (projector + "_fchn1A.py")) == source_hashes[projector],
                "published " + projector + " unchanged")
    by_part = {part: all(row["WithinTolerance"] for row in coefficient_rows if row["Part"] == part)
               for part in PARTS}
    summary = {
        "DirectInteriorCount": len(direct_rows), "CanonicalCoefficientCount": len(coefficient_rows),
        "AllDirectInteriorWithinTolerance": all(row["WithinTolerance"] for row in direct_rows),
        "AllCanonicalCoefficientsWithinTolerance": all(row["WithinTolerance"] for row in coefficient_rows),
        "CanonicalAgreementByPart": by_part,
        "PublishedPythonVsReconstructionWithinTolerance": all(row["WithinTolerance"] for row in reconstruction_rows),
        "MaximumDirectInteriorRelativeDifference": max(row["RelativeDifference"] for row in direct_rows),
        "MaximumCanonicalAbsoluteDifference": max(abs(row["Difference"]) for row in coefficient_rows),
        "MaximumCanonicalRelativeDifference": max(row["RelativeDifference"] for row in coefficient_rows),
    }
    report = {"Status": "Complete", "Channel": "Hgq", "BigTMDChannel": "1A",
              "DifferenceDirection": "BigTMD minus local", "S02SHA256": sha(ROOT / "s02_result.json"),
              "S03SourceSHA256": sha(Path(__file__)), "AuthorTree": metadata["tree"],
              "PublishedSourceHashes": source_hashes, "Conventions": data["Conventions"],
              "CanonicalAuthorAssumption": data["AuthorReconstructionAssumption"],
              "DirectPythonPolicy": "Pinned decimal expressions executed as written; JIT disabled",
              "Tolerance": {"Absolute": ABS_TOL, "Relative": REL_TOL}, "Benchmarks": points, "RawProjectors": raw_records,
              "DirectInteriorRows": direct_rows, "CanonicalCoefficientRows": coefficient_rows,
              "PublishedPythonVsReconstruction": reconstruction_rows, "Summary": summary}
    markdown = "\n\n".join([
        "# Hgq F-hat numerical comparison",
        "Incoming gluon, observed quark; BigTMD channel **1A**. Signed difference: **BigTMD − local**.",
        "Three deterministic benchmarks evaluate the accepted Hgq inputs. "
        "Settings: g_s=1, eq=1, SU(3), mu=Q, nf=4. All dependent kinematics and weights "
        "were calculated by Wolfram from the defining relations and accepted Hgq projectors.",
        "## Direct published-Python comparison",
        "These are ordinary NLO densities at s23>0: regular plus both ordinary plus kernels, "
        "including the zeta-to-s23 Jacobian on both sides. The pinned Python decimal functions "
        "are executed as written. Endpoint distributions are not evaluated pointwise.",
        table(direct_rows, False),
        "## Canonical coefficient comparison",
        "These coefficients use delta(s23), L0=[1/s23]_+, L1=[Log(s23/B)/s23]_+, and Regular "
        "on [0,B], at fixed xhat,Q,qT2,zH. Born is the LO delta coefficient; Delta is NLO only. "
        "Both t(s23) and the Jacobian are transported through the plus action. "
        "The author column uses tool-evaluated endpoints and rational reconstruction "
        "of long decimals with denominator at most 10^6. It is distinct from direct execution above.",
        table(coefficient_rows, True),
        "## Result",
        "```json\n" + json.dumps(summary, indent=2) + "\n```",
        "Tolerance: abs(difference) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local)). "
        "A mismatch is reported without changing either input. PDFs/FFs, luminosity, "
        "zh/(xi*zeta), and outer convolution are deferred identically. "
        "This benchmark does not establish which calculation causes a discrepancy.",
        "Kinematics, 60-digit evaluations, source hashes and all numerical rows are saved in "
        "s01_result.json, s02_result.json and s03_result.json.",
    ]) + "\n"
    atomic(ROOT / "s03_result.json", json.dumps(report, indent=2) + "\n")
    atomic(ROOT / "bigtmd_minus_local.md", markdown)
    print(json.dumps(summary, indent=2), flush=True)
    print("HGQ_BIGTMD_S03_SUCCESS", flush=True)


if __name__ == "__main__":
    main()
