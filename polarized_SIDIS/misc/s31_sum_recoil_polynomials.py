#!/usr/bin/env python3
"""Reduce native derivative terms using the accepted exact polynomial sum."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import time

BASE = Path(__file__).with_name("s18_sum_exact_polynomials.py")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    input_path, output_path = map(Path, sys.argv[1:])
    payload = json.loads(input_path.read_text())
    assert payload["schema"] == "polarized-sidis-recoil-polynomial-input-v1"
    assert payload["base_backend_sha256"] == digest(BASE)
    spec = importlib.util.spec_from_file_location("accepted_polynomial_backend", BASE)
    backend = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(backend)
    assert backend.flint.__version__ == "0.8.0"
    context = backend.flint.fmpq_mpoly_ctx.get(tuple(payload["variables"]), "lex")
    poly = lambda text: backend.flint.fmpq_mpoly(text, context)
    started = time.monotonic()
    factor_cache = {}

    def factor(value):
        key = str(value)
        if key not in factor_cache:
            unit, factors = value.factor()
            reconstructed = poly(str(unit))
            for atom, power in factors:
                assert isinstance(power, int) and power > 0
                reconstructed *= atom ** power
            assert reconstructed == value
            factor_cache[key] = (str(unit), [[str(p), n] for p, n in factors])
        return factor_cache[key]

    terms = []
    for row in payload["terms"]:
        numerator, denominator = poly(row["numerator"]), poly(row["denominator"])
        assert denominator != 0
        unit, factors = factor(denominator)
        terms.append({"numerator": str(numerator), "denominator": str(denominator),
                      "unit": unit, "factors": factors})
    result = backend.sum_case({"label": "recoil_derivative", "variables": payload["variables"], "terms": terms})
    assert result["exact_termwise_reconstruction_passed"]
    factored = {}
    for name in ("numerator", "denominator"):
        value = poly(result[name])
        if value == 0:
            factored[name] = "0"
        else:
            unit, factors = factor(value)
            factored[name] = "(" + unit + ")" + "".join("*(" + p + ")^" + str(n) for p, n in factors)
        assert poly(factored[name]) == value
    answer = {"schema": "polarized-sidis-recoil-polynomial-output-v1",
              "source_sha256": digest(Path(__file__)), "input_sha256": digest(input_path),
              "base_backend_sha256": digest(BASE), "flint_version": backend.flint.__version__,
              "factored_output_reconstruction": True, "result": result,
              "factored": factored, "seconds": time.monotonic() - started}
    temporary = output_path.with_suffix(output_path.suffix + ".tmp")
    temporary.write_text(json.dumps(answer))
    os.replace(temporary, output_path)
    print("PASS: exact recoil derivative polynomial sum", flush=True)


if __name__ == "__main__":
    main()
