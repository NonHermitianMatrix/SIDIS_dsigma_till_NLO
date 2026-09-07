from pathlib import Path
import ast
import hashlib
import json
import urllib.request
from fractions import Fraction

BASE = Path(__file__).resolve().parent
COMMIT = "6e97635d21a63b7975b2e7f5891edc0c35c4dc0c"
production = BASE.parent / "s05_result/Fhats.wl"
assert production.is_file(), "Run the production calculation first."
digest = lambda data: hashlib.sha256(data).hexdigest()
manifest = {"repository": "https://github.com/JeffersonLab/BigTMD",
            "commit": COMMIT, "production_sha256": digest(production.read_bytes()),
            "files": {}}
paths = ["sidis.py"] + [f"NLO/{p}/fchn4{c}.py" for p in ["Pg", "Ppp"] for c in "ABC"]
for name in paths:
    url = f"https://raw.githubusercontent.com/JeffersonLab/BigTMD/{COMMIT}/{name}"
    data = urllib.request.urlopen(url, timeout=60).read()
    dest = BASE / "reference" / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(data)
    manifest["files"][name] = {"url": url, "sha256": digest(data), "bytes": len(data)}
    print(name, len(data), flush=True)
    if name.startswith("NLO"):
        tree = ast.parse(data)
        for node in tree.body:
            if isinstance(node, ast.FunctionDef):
                print(" ", node.name, [a.arg for a in node.args.args], flush=True)

def wolfram(node, source):
    if isinstance(node, ast.Constant):
        value = Fraction(ast.get_source_segment(source, node))
        return str(value.numerator) if value.denominator == 1 else f"({value.numerator}/{value.denominator})"
    if isinstance(node, ast.Name):
        return {"s23": "w"}.get(node.id, node.id)
    if isinstance(node, ast.UnaryOp):
        value = wolfram(node.operand, source)
        return "(-" + value + ")" if isinstance(node.op, ast.USub) else value
    if isinstance(node, ast.BinOp):
        operator = {ast.Add: "+", ast.Sub: "-", ast.Mult: "*", ast.Div: "/", ast.Pow: "^"}[type(node.op)]
        return "(" + wolfram(node.left, source) + operator + wolfram(node.right, source) + ")"
    if isinstance(node, ast.Attribute):
        assert isinstance(node.value, ast.Name) and node.value.id == "np" and node.attr == "pi"
        return "Pi"
    if isinstance(node, ast.Call):
        assert isinstance(node.func, ast.Attribute) and node.func.value.id == "np"
        return {"log": "Log", "sqrt": "Sqrt"}[node.func.attr] + "[" + ",".join(wolfram(a, source) for a in node.args) + "]"
    raise TypeError(ast.dump(node))

entries = []
for projection in ["Pg", "Ppp"]:
    source = (BASE / f"reference/NLO/{projection}/fchn4A.py").read_text()
    tree = ast.parse(source)
    values = []
    for name in ["plus1B", "plus2B"]:
        function = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == name)
        assert len(function.body) == 1 and isinstance(function.body[0], ast.Return)
        values.append(wolfram(function.body[0].value, source))
    entries.append('"' + projection + '" -> {' + ",".join(values) + "}")
auxiliary = ("<|" + ",".join(entries) + "|>\n").encode()
(BASE / "s01_auxiliary.wl").write_bytes(auxiliary)
manifest["auxiliary_sha256"] = digest(auxiliary)
(BASE / "s01_result.json").write_text(json.dumps(manifest, indent=2) + "\n")
print("PASS: production frozen; published Hgg reference downloaded and hashed", flush=True)
