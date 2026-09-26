#!/usr/bin/env python3
"""Factor native polynomial denominators and reuse the accepted exact sum backend."""
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
    assert payload["schema"] == "polarized-sidis-regulator-polynomial-input-v1"
    assert payload["base_backend_sha256"] == digest(BASE)
    spec = importlib.util.spec_from_file_location("accepted_polynomial_backend", BASE)
    backend = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(backend)
    assert backend.flint.__version__ == "0.8.0"
    context = backend.flint.fmpq_mpoly_ctx.get(tuple(payload["variables"]), "lex")
    numerator = backend.flint.fmpq_mpoly(payload["numerator"], context)
    denominator = backend.flint.fmpq_mpoly(payload["denominator"], context)
    assert denominator != 0
    started = time.monotonic()
    unit, factors = denominator.factor()
    reconstructed = backend.flint.fmpq_mpoly(str(unit), context)
    for factor, power in factors:
        assert isinstance(power, int) and power > 0
        reconstructed *= factor ** power
    assert reconstructed == denominator
    factor_seconds = time.monotonic() - started
    print("REGULATOR_DENOMINATOR_FACTORED", len(factors), factor_seconds, flush=True)
    case = {"label": "regulator_normalization", "variables": payload["variables"],
            "terms": [{"numerator": str(numerator), "denominator": str(denominator),
                       "unit": str(unit), "factors": [[str(p), n] for p, n in factors]}]}
    result = backend.sum_case(case)
    answer = {"schema": "polarized-sidis-regulator-polynomial-output-v1",
              "source_sha256": digest(Path(__file__)), "input_sha256": digest(input_path),
              "base_backend_sha256": digest(BASE), "flint_version": backend.flint.__version__,
              "denominator_factorization_reconstructed": True,
              "factor_seconds": factor_seconds, "result": result}
    temporary = output_path.with_suffix(output_path.suffix + ".tmp")
    temporary.write_text(json.dumps(answer))
    os.replace(temporary, output_path)
    print("PASS: exact regulator polynomial normalization", flush=True)


if __name__ == "__main__":
    main()
