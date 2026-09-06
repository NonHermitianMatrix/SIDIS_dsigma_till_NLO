"""Read the paper authors' channel-3 coefficients as exact symbolic expressions.

No published Python code is executed. Long rounded decimal literals are
reconstructed as the unique rational with denominator <= 10**6 inside the
literal's rounding interval. Short terminating decimals are read exactly.
"""
import ast
from decimal import Decimal
from fractions import Fraction
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
TREE = json.loads((ROOT / "bigtmd_tree.json").read_text())
BLOBS = {item["path"]: item for item in TREE["tree"]}
DENOMINATOR_BOUND = 10**6
reconstructions = {}


def exact_number(token):
    decimal = Decimal(token)
    exact = Fraction(decimal)
    if len(decimal.as_tuple().digits) >= 12:
        half_unit = Fraction(Decimal(10) ** decimal.as_tuple().exponent) / 2
        candidate = exact.limit_denominator(DENOMINATOR_BOUND)
        assert abs(candidate - exact) <= half_unit, token
        # Distinct fractions with bounded denominators are >= 1/bound**2 apart.
        assert 2 * half_unit < Fraction(1, DENOMINATOR_BOUND**2), token
        reconstructions[token] = str(candidate)
        exact = candidate
    return str(exact.numerator) if exact.denominator == 1 else f"({exact.numerator}/{exact.denominator})"


def to_wl(node, source):
    if isinstance(node, ast.Constant) and type(node.value) in (int, float):
        return exact_number(ast.get_source_segment(source, node))
    if isinstance(node, ast.Name):
        assert node.id in {"s", "t", "Q", "s23", "mu", "nf", "B", "g", "gp",
                           "EulerGamma", "xh", "zh", "qT2", "Q2"}, node.id
        return node.id
    if isinstance(node, ast.Attribute):
        assert ast.unparse(node) == "np.pi"
        return "Pi"
    if isinstance(node, ast.UnaryOp):
        assert isinstance(node.op, (ast.UAdd, ast.USub))
        return "(" + ("-" if isinstance(node.op, ast.USub) else "+") + to_wl(node.operand, source) + ")"
    if isinstance(node, ast.BinOp):
        op = {ast.Add: "+", ast.Sub: "-", ast.Mult: "*", ast.Div: "/", ast.Pow: "^"}[type(node.op)]
        return "(" + to_wl(node.left, source) + op + to_wl(node.right, source) + ")"
    if isinstance(node, ast.Call):
        name = {"np.log": "Log", "np.sqrt": "Sqrt", "PolyLOG": "PolyLog"}[ast.unparse(node.func)]
        assert not node.keywords
        return name + "[" + ",".join(to_wl(arg, source) for arg in node.args) + "]"
    raise ValueError(ast.dump(node))


def source_file(local_name, remote_name):
    data = (ROOT / "published" / local_name).read_bytes()
    blob_hash = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
    assert blob_hash == BLOBS[remote_name]["sha"], local_name
    return data.decode(), {"path": remote_name, "git_blob": blob_hash,
                           "sha256": hashlib.sha256(data).hexdigest()}


def expressions(source, names):
    functions = {n.name: n for n in ast.parse(source).body if isinstance(n, ast.FunctionDef)}
    result = {}
    for name in names:
        body = functions[name].body
        assert len(body) == 1 and isinstance(body[0], ast.Return), name
        result[name] = to_wl(body[0].value, source)
    return "<|" + ",\n".join(f'"{name}" -> {value}' for name, value in result.items()) + "|>"


def main():
    output, sources = {}, []
    for contraction in ("Pg", "Ppp"):
        source, identity = source_file(f"{contraction}_fchn3A.py", f"NLO/{contraction}/fchn3A.py")
        sources.append(identity)
        output[contraction] = expressions(source, ("regular", "delta", "plus1B", "plus2B"))
    source, identity = source_file("LO.py", "LO.py")
    sources.append(identity)
    output["Born"] = expressions(source, ("PgB", "PppB"))
    for name in ("sidis.py", "tutorial.rst"):
        _, identity = source_file(name, "docs/tutorial.rst" if name.endswith("rst") else name)
        sources.append(identity)
    result = "<|" + ",\n".join(f'"{key}" -> {value}' for key, value in output.items()) + "|>\n"
    (ROOT / "s01_result.wl").write_text(result)
    report = {"source": "https://github.com/JeffersonLab/BigTMD", "tree": TREE["sha"],
              "sources": sources, "rational_denominator_bound": DENOMINATOR_BOUND,
              "rounded_literal_reconstructions": dict(sorted(reconstructions.items())),
              "interpretation": "Published finite SU(3) coefficients; rational reconstruction assumes the stated denominator bound.",
              "checks": {"all_git_blob_hashes_match": True,
                         "all_long_decimal_reconstructions_unique_within_bound": True,
                         "numerical_polylog_code_not_executed": True}}
    (ROOT / "s01_result.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"PASS: {len(sources)} source hashes; {len(reconstructions)} unique rational reconstructions.")
    print(f"Wrote {ROOT / 's01_result.wl'} ({len(result)} bytes).")


if __name__ == "__main__":
    main()
