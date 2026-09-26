#!/usr/bin/env python3
"""Execute the pinned rationalSeries recurrence in exact polynomial arithmetic."""
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
    assert payload["schema"] == "polarized-sidis-regulator-series-input-v1"
    assert payload["base_backend_sha256"] == digest(BASE)
    spec = importlib.util.spec_from_file_location("accepted_polynomial_backend", BASE)
    backend = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(backend)
    assert backend.flint.__version__ == "0.8.0"
    context = backend.flint.fmpq_mpoly_ctx.get(tuple(payload["variables"]), "lex")
    poly = lambda value: backend.flint.fmpq_mpoly(value, context)
    numerator, denominator = poly(payload["numerator"]), poly(payload["denominator"])
    assert denominator != 0
    regulator_index = payload["variables"].index(payload["regulator"])
    regulator = poly(payload["regulator"])
    maximum = payload["maximum_power"]
    assert isinstance(maximum, int)
    started = time.monotonic()

    def coefficients(value):
        grouped = {}
        for powers, coefficient in value.terms():
            reduced = [int(power) for power in powers]
            assert tuple(reduced) == powers
            degree = reduced[regulator_index]
            reduced[regulator_index] = 0
            assert tuple(reduced) not in grouped.setdefault(degree, {})
            grouped[degree][tuple(reduced)] = coefficient
        result = {degree: context.from_dict(terms) for degree, terms in grouped.items()}
        reconstructed = poly("0")
        for degree, coefficient in result.items():
            assert all(powers[regulator_index] == 0 for powers, unused in coefficient.terms())
            reconstructed += coefficient * regulator ** degree
        assert reconstructed == value
        return result

    n_coefficients, d_coefficients = coefficients(numerator), coefficients(denominator)
    factor_cache = {}

    def term(n, d):
        key = str(d)
        if key not in factor_cache:
            unit, factors = d.factor()
            reconstruction = poly(str(unit))
            for factor, power in factors:
                assert isinstance(power, int) and power > 0
                reconstruction *= factor ** power
            assert reconstruction == d
            factor_cache[key] = (str(unit), [[str(f), p] for f, p in factors])
        unit, factors = factor_cache[key]
        return {"numerator": str(n), "denominator": key, "unit": unit, "factors": factors}

    def exact_sum(label, pairs):
        result = backend.sum_case({"label": label, "variables": payload["variables"],
                                   "terms": [term(n, d) for n, d in pairs]})
        assert result["exact_termwise_reconstruction_passed"]
        return poly(result["numerator"]), poly(result["denominator"])

    rows = []
    residual_checks = []
    if numerator != 0:
        n_minimum, d_minimum = min(n_coefficients), min(d_coefficients)
        leading = n_minimum - d_minimum
        count = maximum - leading
        d0 = d_coefficients[d_minimum]
        quotient = []
        for order in range(count + 1):
            n_coefficient = n_coefficients.get(n_minimum + order, poly("0"))
            pairs = [(n_coefficient, d0)]
            for index in range(1, order + 1):
                qn, qd = quotient[order - index]
                pairs.append((-d_coefficients.get(d_minimum + index, poly("0")) * qn, d0 * qd))
            value = exact_sum("regulator_recurrence_" + str(order), pairs)
            quotient.append(value)
            residual = [(-n_coefficient, poly("1"))]
            for index in range(order + 1):
                qn, qd = quotient[order - index]
                residual.append((d_coefficients.get(d_minimum + index, poly("0")) * qn, qd))
            residual_numerator, unused = exact_sum("regulator_residual_" + str(order), residual)
            assert residual_numerator == 0
            residual_checks.append(True)
            rows.append({"power": leading + order, "numerator": str(value[0]), "denominator": str(value[1])})
            print("REGULATOR_SERIES_COEFFICIENT", order, count, round(time.monotonic() - started, 3), flush=True)
    else:
        leading = None
        count = -1
    assert len(rows) == max(0, count + 1) and all(residual_checks)
    answer = {"schema": "polarized-sidis-regulator-series-output-v1",
              "source_sha256": digest(Path(__file__)), "input_sha256": digest(input_path),
              "base_backend_sha256": digest(BASE), "flint_version": backend.flint.__version__,
              "exact_polynomial_reconstruction": True,
              "complete_retained_residual_reconstruction": True,
              "maximum_power": maximum, "leading_power": leading,
              "seconds": time.monotonic() - started, "coefficients": rows}
    temporary = output_path.with_suffix(output_path.suffix + ".tmp")
    temporary.write_text(json.dumps(answer))
    os.replace(temporary, output_path)
    print("PASS: exact regulator recurrence and residual reconstruction", flush=True)


if __name__ == "__main__":
    main()
