#!/usr/bin/env python3
"""Exactly sum the native-exported polynomial packets; never infer coefficients."""
import hashlib
import json
import os
from pathlib import Path
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "common/native/python_flint"))
import flint


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sum_case(case):
    start = time.monotonic()
    context = flint.fmpq_mpoly_ctx.get(tuple(case["variables"]), "lex")
    poly = lambda value: flint.fmpq_mpoly(value, context)
    factors = {}
    common = {}
    packets = []
    for row in case["terms"]:
        numerator, denominator = poly(row["numerator"]), poly(row["denominator"])
        assert str(poly(str(numerator))) == str(numerator)
        unit = flint.fmpq(row["unit"])
        powers = {}
        reconstructed = poly(str(unit))
        for text, power in row["factors"]:
            assert isinstance(power, int) and power > 0
            factor = poly(text)
            reconstructed *= factor ** power
            leading = factor.leading_coefficient()
            canonical = factor / leading
            assert canonical * leading == factor
            unit *= leading ** power
            key = str(canonical)
            factors[key] = canonical
            powers[key] = powers.get(key, 0) + power
        assert reconstructed == denominator and denominator != 0
        for key, power in powers.items():
            common[key] = max(common.get(key, 0), power)
        packets.append((numerator, denominator, unit, powers))
    keys = sorted(common)
    denominator = poly("1")
    for key in keys:
        denominator *= factors[key] ** common[key]
    total = poly("0")
    multipliers = {}
    for index, (numerator, original_denominator, unit, powers) in enumerate(packets, 1):
        support = tuple(common[key] - powers.get(key, 0) for key in keys)
        if support not in multipliers:
            multiplier = poly("1")
            for key, power in zip(keys, support):
                multiplier *= factors[key] ** power
            multipliers[support] = multiplier
        multiplier = multipliers[support] / unit
        assert original_denominator * multiplier == denominator
        term = numerator * multiplier
        following = total + term
        assert following - total == term
        total = following
        if index % 16 == 0 or index == len(packets):
            print("EXACT_POLYNOMIAL_SUM", case["label"], index, len(packets),
                  round(time.monotonic() - start, 3), flush=True)
    original_total = total
    remaining = dict(common)
    extracted = poly("1")
    for key in keys:
        for unused in range(common[key]):
            quotient, remainder = divmod(total, factors[key])
            assert quotient * factors[key] + remainder == total
            if remainder != 0:
                break
            total = quotient
            extracted *= factors[key]
            remaining[key] -= 1
    assert total * extracted == original_total
    reduced_denominator = poly("1")
    for key in keys:
        reduced_denominator *= factors[key] ** remaining[key]
    assert reduced_denominator * extracted == denominator
    if "expected" in case:
        expected = case["expected"]
        assert total * poly(expected["denominator"]) == poly(expected["numerator"]) * reduced_denominator
    result = {"label": case["label"], "numerator": str(total),
              "denominator": str(reduced_denominator), "seconds": time.monotonic() - start,
              "term_count": len(packets), "factor_count": len(keys),
              "exact_termwise_reconstruction_passed": True,
              "expected_comparison_passed": "expected" in case}
    assert poly(result["numerator"]) == total
    assert poly(result["denominator"]) == reduced_denominator
    return result


def main():
    input_path, output_path = map(Path, sys.argv[1:])
    assert flint.__version__ == "0.8.0"
    payload = json.loads(input_path.read_text())
    assert payload["schema"] == "polarized-sidis-exact-polynomial-input-v1"
    answer = {"schema": "polarized-sidis-exact-polynomial-output-v1",
              "input_sha256": digest(input_path), "source_sha256": digest(Path(__file__)),
              "flint_version": flint.__version__, "cases": []}
    for case in payload["cases"]:
        answer["cases"].append(sum_case(case))
    temporary = output_path.with_suffix(output_path.suffix + ".tmp")
    temporary.write_text(json.dumps(answer))
    os.replace(temporary, output_path)
    print("PASS: exact polynomial comparison backend", flush=True)


if __name__ == "__main__":
    main()
