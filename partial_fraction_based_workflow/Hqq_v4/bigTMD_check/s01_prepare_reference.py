"""Freeze only the authors' Hqq reference and translate its defining expressions."""
import argparse
import ast
import copy
from fractions import Fraction
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import sys
import urllib.request

ROOT = Path(__file__).resolve().parent
COMMIT = "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c"
FILES = ["sidis.py", "LO.py"] + [
    f"NLO/{mode}/fchn2{case}.py" for mode in ("Pg", "Ppp") for case in "ABC"
]
FUNCTIONS = ("regular", "delta", "plus1B", "plus2B")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fetch():
    for name in FILES:
        path = ROOT / "reference" / name
        if not path.exists():
            url = f"https://raw.githubusercontent.com/JeffersonLab/BigTMD/{COMMIT}/{name}"
            data = urllib.request.urlopen(url, timeout=60).read()
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        print("Reference", name, digest(path), flush=True)


def wl(value):
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, dict):
        return "<|" + ",".join(wl(k) + "->" + wl(v) for k, v in value.items()) + "|>"
    if isinstance(value, (tuple, list)):
        return "{" + ",".join(map(wl, value)) + "}"
    if isinstance(value, bool):
        return str(value)
    if isinstance(value, Fraction):
        return f"({value.numerator}/{value.denominator})"
    if isinstance(value, int):
        return str(value)
    raise TypeError(type(value))


class Expression:
    """Linear-size AST translation; source decimals never pass through a float."""
    def __init__(self, source):
        self.lines = source.splitlines(keepends=True)
        self.literals = {}

    def token(self, node):
        assert node.lineno == node.end_lineno
        return self.lines[node.lineno - 1][node.col_offset:node.end_col_offset]

    @lru_cache(maxsize=None)
    def number(self, token):
        exact = Fraction(token)
        recovered = exact.limit_denominator(1000000)
        error = abs(recovered - exact) / max(1, abs(exact))
        assert error <= Fraction("5e-15"), (token, recovered, error)
        self.literals[token] = {"exact_decimal": str(exact), "reconstructed": str(recovered),
                                "scaled_error": str(error)}
        return wl(recovered)

    def __call__(self, node):
        if isinstance(node, ast.Constant):
            if isinstance(node.value, (int, float)):
                return self.number(self.token(node))
            raise ValueError(ast.dump(node))
        if isinstance(node, ast.Name):
            return {"EulerGamma": "EulerGamma"}.get(node.id, node.id)
        if isinstance(node, ast.Attribute):
            assert ast.unparse(node) == "np.pi", ast.dump(node)
            return "Pi"
        if isinstance(node, ast.UnaryOp):
            op = {ast.USub: "-", ast.UAdd: "+"}[type(node.op)]
            return "(" + op + self(node.operand) + ")"
        if isinstance(node, ast.BinOp):
            op = {ast.Add: "+", ast.Sub: "-", ast.Mult: "*", ast.Div: "/", ast.Pow: "^"}[type(node.op)]
            return "(" + self(node.left) + op + self(node.right) + ")"
        if isinstance(node, ast.Call):
            name = {"np.log": "Log", "np.sqrt": "Sqrt", "PolyLOG": "PolyLog",
                    "pdf.alphasQ2": "sourceAlphaS", "_Pg": "referenceBorn"}.get(ast.unparse(node.func))
            assert name is not None, ast.dump(node)
            return name + "[" + ",".join(self(x) for x in node.args) + "]"
        raise ValueError(ast.dump(node))


def assignment_nodes(tree, name):
    return [node for node in ast.walk(tree) if isinstance(node, ast.Assign)
            and any(isinstance(t, ast.Name) and t.id == name for t in node.targets)]


def condition(node, name, value):
    return (isinstance(node, ast.If) and isinstance(node.test, ast.Compare)
            and isinstance(node.test.left, ast.Name) and node.test.left.id == name
            and len(node.test.ops) == 1 and isinstance(node.test.ops[0], ast.Eq)
            and isinstance(node.test.comparators[0], ast.Constant)
            and node.test.comparators[0].value == value)


def exact_flavors(source, tree):
    import numpy as np

    class ExactNumpy:
        array = staticmethod(lambda value: np.array(value, dtype=object))
        ones = staticmethod(lambda shape: np.ones(shape, dtype=object))
        sum = staticmethod(lambda value: sum(value))

        @staticmethod
        def einsum(pattern, left, right, matrix):
            assert pattern == "i,j,ij"
            return sum(left[i] * right[j] * matrix[i, j]
                       for i in range(len(left)) for j in range(len(right)))

    class ExactNumbers(ast.NodeTransformer):
        def visit_Constant(self, node):
            if isinstance(node.value, float):
                token = Expression(source).token(node)
                return ast.copy_location(ast.Call(ast.Name("Fraction", ast.Load()),
                                                 [ast.Constant(token)], []), node)
            return node

    wanted = {"eU", "eD", "eq3", "eq4", "eq5", "iflav", "qqp"}
    statements = [copy.deepcopy(n) for n in tree.body if
                  (isinstance(n, ast.Assign) and any(isinstance(t, ast.Name) and t.id in wanted for t in n.targets))
                  or (isinstance(n, ast.For) and any(isinstance(x, ast.Name) and x.id == "qqp" for x in ast.walk(n)))]
    lum = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == "get_parton_lum")
    selected = copy.deepcopy(next(n for n in ast.walk(lum) if condition(n, "chn", 2)))
    selected.orelse = []
    function = copy.deepcopy(lum)
    function.body = [selected, ast.Return(ast.Name("lum", ast.Load()))]
    module = ExactNumbers().visit(ast.Module(body=statements + [function], type_ignores=[]))
    ast.fix_missing_locations(module)
    env = {"np": ExactNumpy, "Fraction": Fraction}
    exec(compile(module, "authors_selected_charge_definitions", "exec"), env)
    nfnode = assignment_nodes(tree, "nf")
    assert len(nfnode) == 1
    nf = Fraction(Expression(source).token(nfnode[0].value))
    assert nf.denominator == 1
    charges = env["eq" + str(nf.numerator)]
    active = [i for i, pdg in enumerate(env["iflav"]) if i and pdg > 0 and charges[i] != 0]
    assert len(active) == nf
    values = {}
    for label, pdg in [("up", 2), ("down", 1)]:
        index = env["iflav"].index(pdg)
        assert index in active
        basis = ExactNumpy.array([int(i == index) for i in range(len(charges))])
        weights = {case: env["get_parton_lum"](1, 1, 1, 2, case, basis, basis, charges) for case in "ABC"}
        values[label] = {"ObservedPDG": pdg, "Charge": charges[index], "Nf": nf.numerator,
                         "OtherCharges": [charges[i] for i in active if i != index], "Weights": weights}
    return values


def prepare():
    manifest = {"Commit": COMMIT, "Files": {n: digest(ROOT / "reference" / n) for n in FILES},
                "SourceSHA256": digest(Path(__file__)), "DecimalLiterals": {}}
    source = (ROOT / "reference/sidis.py").read_text()
    tree = ast.parse(source)
    translate = Expression(source)
    driver = {}
    for name in ["xh", "zh", "zh0", "zeta", "zeta0", "jac", "jac0", "gs2", "s", "t", "t0", "B", "nf", "F1h", "F2h"]:
        nodes = assignment_nodes(tree, name)
        assert len(nodes) == 1, (name, len(nodes))
        driver[name] = translate(nodes[0].value)
    for order in [0, 1]:
        block = next(n for n in ast.walk(tree) if condition(n, "order", order))
        for name in (["factor0"] if order == 0 else ["factor", "factor0"]):
            nodes = assignment_nodes(block, name)
            assert len(nodes) == 1
            driver[name + str(order)] = translate(nodes[0].value)
        if order == 0:
            choice = next(n for n in ast.walk(block) if condition(n, "chn", 2))
            selected = choice.body[0].value
            assert isinstance(selected, ast.Tuple)
            born_names = [v.attr for v in selected.elts]
            addition = next(n for n in ast.walk(block) if isinstance(n, ast.AugAssign)
                            and isinstance(n.target, ast.Name) and n.target.id == "Fg")
            driver["BornAddition"] = translate(addition.value)
    flavors = exact_flavors(source, tree)
    lo_source = (ROOT / "reference/LO.py").read_text()
    lo_tree = ast.parse(lo_source)
    lo = {}
    for mode, name in zip(["Pg", "Ppp"], born_names):
        fn = next(n for n in lo_tree.body if isinstance(n, ast.FunctionDef) and n.name == name)
        assert len(fn.body) == 1 and isinstance(fn.body[0], ast.Return)
        lo[mode] = Expression(lo_source)(fn.body[0].value)
    nlo = {}
    for mode in ["Pg", "Ppp"]:
        nlo[mode] = {}
        for case in "ABC":
            name = f"NLO/{mode}/fchn2{case}.py"
            source = (ROOT / "reference" / name).read_text()
            tree = ast.parse(source)
            translate = Expression(source)
            nlo[mode][case] = {}
            for key in FUNCTIONS:
                fn = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == key)
                assert len(fn.body) == 1 and isinstance(fn.body[0], ast.Return)
                nlo[mode][case][key] = translate(fn.body[0].value)
            manifest["DecimalLiterals"][name] = translate.literals
            print("Parsed", mode, case, "distinct numeric tokens", len(translate.literals), flush=True)
    def expression_association(values):
        return "<|" + ",".join(wl(k) + "->" + (expression_association(v) if isinstance(v, dict) else v)
                              for k, v in values.items()) + "|>"
    result = "<|\"Driver\"->" + expression_association(driver) + ",\"LO\"->" + expression_association(lo)
    result += ",\"NLO\"->" + expression_association(nlo) + ",\"Flavors\"->" + wl(flavors)
    result += ",\"SourceSHA256\"->" + wl(manifest["SourceSHA256"]) + ",\"Commit\"->" + wl(COMMIT) + "|>\n"
    (ROOT / "s01_result.wl").write_text(result)
    manifest["ResultSHA256"] = digest(ROOT / "s01_result.wl")
    (ROOT / "s01_result.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print("S01_SUCCESS", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--fetch-only", action="store_true")
    args = parser.parse_args()
    fetch()
    if not args.fetch_only:
        prepare()
