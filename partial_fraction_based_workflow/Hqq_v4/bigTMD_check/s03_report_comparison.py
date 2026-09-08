"""Evaluate the printed Hqq expressions and report signed BigTMD-minus-local values."""
import ast
import copy
import hashlib
import json
from pathlib import Path
import re
import resource
from types import SimpleNamespace

import mpmath as mp

ROOT = Path(__file__).resolve().parent
mp.mp.dps = 80
REL_TOL = mp.mpf("1e-9")
ABS_TOL = mp.mpf("1e-14")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def real(value):
    assert mp.isfinite(value) and abs(mp.im(value)) < mp.mpf("1e-45"), value
    return mp.re(value)


def parse(value):
    if isinstance(value, int):
        return mp.mpf(value)
    if "/" in value:
        a, b = value.split("/")
        return mp.mpf(a) / mp.mpf(b)
    return mp.mpf(re.sub(r"`{1,2}[+-]?(?:\d+(?:\.\d*)?|\.\d+)", "", value).replace("*^", "e"))


class PrintedExpression:
    """Compile only a selected return expression; every literal retains its source token."""
    def __init__(self, source):
        self.lines = source.splitlines(keepends=True)
        self.constants = {}
        self.environment = {"np": SimpleNamespace(log=mp.log, sqrt=mp.sqrt, pi=mp.pi),
                            "EulerGamma": mp.euler, "PolyLOG": mp.polylog}

    def compile(self, expression):
        owner = self

        class ReplaceNumbers(ast.NodeTransformer):
            def visit_Constant(self, node):
                if isinstance(node.value, (int, float)):
                    assert node.lineno == node.end_lineno
                    token = owner.lines[node.lineno - 1][node.col_offset:node.end_col_offset]
                    if token not in owner.constants:
                        key = "literal_" + str(len(owner.constants))
                        owner.constants[token] = key
                        owner.environment[key] = mp.mpf(token)
                    return ast.copy_location(ast.Name(owner.constants[token], ast.Load()), node)
                return node

        tree = ReplaceNumbers().visit(ast.Expression(copy.deepcopy(expression)))
        ast.fix_missing_locations(tree)
        code = compile(tree, "pinned_authors_expression", "eval")

        def evaluate(parameters):
            return eval(code, {"__builtins__": {}, **owner.environment}, parameters)

        return evaluate


def assignment(tree, name):
    nodes = [n.value for n in ast.walk(tree) if isinstance(n, ast.Assign)
             and any(isinstance(t, ast.Name) and t.id == name for t in n.targets)]
    assert len(nodes) == 1, (name, len(nodes))
    return nodes[0]


def difference(local, reference):
    local, reference = real(local), real(reference)
    delta = reference - local
    scale = max(abs(local), abs(reference))
    relative = abs(delta) / scale if scale else mp.mpf(0)
    passed = abs(delta) <= ABS_TOL + REL_TOL * scale
    return {"Local": float(local), "BigTMD": float(reference), "BigTMDMinusLocal": float(delta),
            "RelativeDifference": float(relative), "Pass": bool(passed),
            "HighPrecision": {"Local": mp.nstr(local, 65), "BigTMD": mp.nstr(reference, 65),
                              "BigTMDMinusLocal": mp.nstr(delta, 65)}}


def summarize(rows):
    return {"Total": len(rows), "Passed": sum(row["Pass"] for row in rows),
            "MaxAbsoluteDifference": max(abs(row["BigTMDMinusLocal"]) for row in rows),
            "MaxRelativeDifference": max(row["RelativeDifference"] for row in rows)}


def main():
    manifest = json.loads((ROOT / "s01_result.json").read_text())
    output = json.loads((ROOT / "s02_result.json").read_text())
    receipt = json.loads((ROOT / "s02_execution.json").read_text())
    assert receipt["accepted_execution"]
    assert output["ResultSHA256"] == sha(ROOT / "s02_result.wl")
    assert output["SourceSHA256"] == receipt["source_sha256"] == sha(ROOT / "s02_compare_coefficients.wl")
    assert manifest["SourceSHA256"] == sha(ROOT / "s01_prepare_reference.py")
    assert manifest["ResultSHA256"] == sha(ROOT / "s01_result.wl")
    for name, expected in output["FrozenInputs"].items():
        assert sha(ROOT.parent / name) == expected, name
    for name, expected in manifest["Files"].items():
        assert sha(ROOT / "reference" / name) == expected, name

    driver_source = (ROOT / "reference/sidis.py").read_text()
    driver_tree = ast.parse(driver_source)
    printed_driver = PrintedExpression(driver_source)
    coupling = printed_driver.compile(assignment(driver_tree, "gs2"))
    factors = [n for n in ast.walk(driver_tree) if isinstance(n, ast.Assign)
               and any(isinstance(t, ast.Name) and t.id == "factor" for t in n.targets)]
    assert len(factors) == 1
    normalization = printed_driver.compile(factors[0].value)
    projectors = {name: printed_driver.compile(assignment(driver_tree, name + "h")) for name in ["F1", "F2"]}
    reference = {}
    for mode in ["Pg", "Ppp"]:
        reference[mode] = {}
        for case in "AC":
            source = (ROOT / f"reference/NLO/{mode}/fchn2{case}.py").read_text()
            tree = ast.parse(source)
            translator = PrintedExpression(source)
            reference[mode][case] = {}
            for name in ["regular", "plus1B", "plus2B"]:
                fn = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == name)
                assert len(fn.body) == 1 and isinstance(fn.body[0], ast.Return)
                reference[mode][case][name] = translator.compile(fn.body[0].value)

    coefficients, direct_reconstructed, direct_printed, rounding = [], [], [], []
    for point_result in output["Results"]:
        point = point_result["Point"]
        parameters = {key: parse(value) for key, value in point["Input"].items()}
        parameters.update({"g": mp.mpf(1), "gp": mp.mpf(1)})
        raw = {mode: {case: {key: real(fn(parameters)) for key, fn in functions.items()}
                       for case, functions in cases.items()} for mode, cases in reference.items()}
        alpha = parameters["alphaS"]
        gs2 = coupling({"pdf": SimpleNamespace(alphasQ2=lambda _: alpha), "mu2": parameters["mu"]**2})
        norm = normalization({"gs2": gs2, **{key: mp.mpf(1) for key in ["jac", "lum", "xi", "zeta", "zh"]}})
        for row in point_result["Coefficients"]:
            identifiers = {key: row[key] for key in ["Point", "Flavor", "Hat", "Distribution"]}
            coefficients.append({**identifiers, **difference(parse(row["Local"]["HighPrecision"]),
                                                             parse(row["Reference"]["HighPrecision"]))})
        for row in point_result["Direct"]:
            weights = {key: parse(value) for key, value in output["Flavors"][row["Flavor"]]["Weights"].items()}
            assert weights["B"] == 0
            tensors = {}
            for mode in ["Pg", "Ppp"]:
                tensors[mode] = norm * sum(weights[case] * (
                    raw[mode][case]["regular"] + (raw[mode][case]["plus1B"] +
                    raw[mode][case]["plus2B"] * mp.log(parameters["s23"])) / parameters["s23"])
                    for case in "AC")
            printed = real(projectors[row["Hat"]]({**parameters, "Fg": tensors["Pg"], "Fpp": tensors["Ppp"]}))
            local = parse(row["Local"]["HighPrecision"])
            recovered = parse(row["Reference"]["HighPrecision"])
            identifiers = {key: row[key] for key in ["Point", "Flavor", "Hat"]}
            direct_reconstructed.append({**identifiers, **difference(local, recovered)})
            direct_printed.append({**identifiers, **difference(local, printed)})
            rounding.append({**identifiers, **difference(recovered, printed)})
        print("Compared", point["ID"], flush=True)

    groups = {"Coefficients": coefficients, "DirectReconstructed": direct_reconstructed,
              "DirectPublishedDecimals": direct_printed, "PublishedMinusReconstructed": rounding}
    summary = {name: summarize(rows) for name, rows in groups.items()}
    agreement = all(row["Pass"] for rows in groups.values() for row in rows)
    memory = {stage: json.loads((ROOT / (stage + "_execution.json")).read_text())["peak_rss_bytes"]
              for stage in ["s01", "s02"]}
    if output.get("NumericalSnapshot"):
        memory["s02_numerical_job_" + output["NumericalSnapshot"]["JobID"]] = output["NumericalSnapshot"]["PeakRSSBytes"]
    memory["s03_process_before_export"] = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss * 1024
    result = {"ExecutionComplete": True, "Agreement": agreement,
              "Tolerance": {"Absolute": str(ABS_TOL), "Relative": str(REL_TOL)},
              "ReferenceCommit": manifest["Commit"], "SourceSHA256": sha(Path(__file__)),
              "InputSHA256": {name: sha(ROOT / name) for name in
                              ["s01_result.wl", "s01_result.json", "s02_result.wl", "s02_result.json"]},
              "FrozenInputs": output["FrozenInputs"], "Points": [x["Point"] for x in output["Results"]],
              "Summary": summary, "PeakRSSBytes": memory, **groups}
    (ROOT / "s03_result.json").write_text(json.dumps(result, indent=2, allow_nan=False) + "\n")
    lines = ["# Hqq_v4 BigTMD check", "", "The numerical comparison completed.", "",
             "Overall agreement: **" + ("PASS" if agreement else "FAIL") + "**.", "",
             "Tolerance: abs(BigTMD - local) <= 1e-14 + 1e-9 * max(abs(BigTMD), abs(local)).", "",
             "| Comparison | Passed / total | Largest absolute difference | Largest relative difference |",
             "|---|---:|---:|---:|"]
    for name, values in summary.items():
        lines.append(f"| {name} | {values['Passed']} / {values['Total']} | "
                     f"{values['MaxAbsoluteDifference']:.8g} | {values['MaxRelativeDifference']:.8g} |")
    lines += ["", "The coefficient comparison includes LO delta and NLO delta, L0, L1 and regular terms.",
              "Both F hats, both signs of s+t, and the driver's active up/down flavor weights are covered.",
              "Tests use the driver's nf=4, SU(3), mu=Q and alphaS=1/5. They do not test the coordinate boundary.",
              "The coefficients use the saved [Log[s23/B]^n/s23]+ convention at fixed s and t on [0,B].", "",
              "Endpoint limits use the declared short-rational reconstruction of the authors' printed constants.",
              "The separate published-decimal comparison evaluates the unrounded source tokens at 80-digit precision",
              "for ordinary interior values. It uses mpmath log/sqrt/polylog, not the repository's truncated polylog series.",
              "No normalization was fitted and no production result was changed.", "",
              "Measured peak RSS in bytes: " + json.dumps(memory) + ". No memory guard was triggered.", "",
              "Reference: [JeffersonLab/BigTMD, pinned source](https://github.com/JeffersonLab/BigTMD/tree/" + manifest["Commit"] + ").",
              "The complete numbers, signed differences, exact benchmark inputs and input hashes are in s03_result.json.", "",
              "| Point | Branch | Q | s | t | s23 | B |", "|---|---:|---:|---:|---:|---:|---:|"]
    for point in result["Points"]:
        values = point["Input"]
        lines.append("| " + " | ".join([point["ID"], str(point["Branch"])] +
                    [str(values[key]) for key in ["Q", "s", "t", "s23", "B"]]) + " |")
    failures = [row for row in coefficients if not row["Pass"]]
    if failures:
        lines += ["", "## Coefficient disagreements", "",
                  "| Point | Flavor | Hat | Term | Local | BigTMD | BigTMD - local |", "|---|---|---|---|---:|---:|---:|"]
        for row in failures:
            lines.append(f"| {row['Point']} | {row['Flavor']} | {row['Hat']} | {row['Distribution']} | "
                         f"{row['Local']:.12g} | {row['BigTMD']:.12g} | {row['BigTMDMinusLocal']:.12g} |")
    (ROOT / "s03_result.md").write_text("\n".join(lines) + "\n")
    (ROOT / "s03_result.wl").write_text('<|"ExecutionComplete"->True,"Agreement"->' + str(agreement) +
        ',"JSONSHA256"->"' + sha(ROOT / "s03_result.json") + '","SourceSHA256"->"' + sha(Path(__file__)) + '"|>\n')
    print(json.dumps(summary, indent=2), flush=True)
    print("S03_SUCCESS; agreement=" + str(agreement), flush=True)


if __name__ == "__main__":
    main()
