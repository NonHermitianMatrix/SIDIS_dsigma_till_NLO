#!/usr/bin/env python3
"""Prepare the published H1 data without changing its decimal values."""
from __future__ import annotations

from datetime import datetime, timezone
from decimal import Decimal
import hashlib
import json
import os
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
REFERENCES = BASE.parent / "references"


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def progress(message: str) -> None:
    with (BASE.parent.parent / "progress.md").open("a") as stream:
        stream.write(f"\nH1 data S01 {datetime.now(timezone.utc).isoformat()}: {message}\n")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def bounds(qualifier: str) -> list[str]:
    match = re.fullmatch(r"([0-9.]+) TO ([0-9.]+)(?: GEV\*\*2)?", qualifier)
    require(match is not None, f"Unrecognized range: {qualifier}")
    low, high = match.groups()
    require(Decimal(low) < Decimal(high), f"Unordered range: {qualifier}")
    return [low, high]


def positive(value: str) -> bool:
    number = Decimal(value)
    return number.is_finite() and number > 0


def main() -> None:
    progress("Requested Fig. 3 experimental comparison inputs. Starting HEPData identity, observable, bin and uncertainty checks. Next write the exact published values to dsigmapibydpt/s01_result; no theory evaluation.")
    record_path = REFERENCES / "hepdata_ins647847.json"
    record = json.loads(record_path.read_text())
    table_metadata = {t["name"]: t for t in record["data_tables"]}
    tables = []
    files = [{"path": str(record_path.relative_to(BASE.parent)), "sha256": digest(record_path)}]
    for table_name in ("Table 7", "Table 8", "Table 9"):
        meta = table_metadata[table_name]
        number = table_name.split()[-1]
        path = REFERENCES / f"hepdata_table{number}.json"
        data = json.loads(path.read_text())
        require(data["doi"] == meta["doi"] and data["name"] == meta["name"], "Table provenance differs from the downloaded record")
        require(data["location"] == "Data from T 2,F 4", "Wrong experimental figure/table")
        require([h["name"] for h in data["headers"]] == ["PT*(P=4) [GEV]", "D(SIG)/DPT* [PB/GEV]"], "Unexpected measured observable or units")
        require(data["qualifiers"]["RE"][0]["value"] == "E+ P --> E+ PI0 X", "Wrong reaction")
        q2 = bounds(data["qualifiers"]["Q**2"][0]["value"])
        inelasticity = bounds(data["qualifiers"]["Y"][0]["value"])
        bins = []
        for row in data["values"]:
            require(len(row["x"]) == len(row["y"]) == 1, "Unexpected grouped data row")
            x, y = row["x"][0], row["y"][0]
            require(positive(x["low"]) and positive(x["high"]) and Decimal(x["low"]) < Decimal(x["high"]), "Invalid momentum bin")
            if bins:
                require(Decimal(bins[-1]["pt_high_GeV"]) == Decimal(x["low"]), "Momentum bins are not contiguous")
            require(positive(y["value"]), "Nonpositive/nonfinite cross section")
            errors = {e["label"]: e["symerror"] for e in y["errors"]}
            require(len(errors) == len(y["errors"]) and set(errors) == {"stat", "total"}, "Unrecognized or duplicate uncertainty label")
            require(all(positive(v) for v in errors.values()), "Invalid uncertainty")
            require(Decimal(errors["total"]) >= Decimal(errors["stat"]), "Total uncertainty smaller than statistical")
            bins.append({"pt_low_GeV": x["low"], "pt_high_GeV": x["high"],
                         "dsigma_dpt_pb_per_GeV": y["value"],
                         "stat_pb_per_GeV": errors["stat"],
                         "total_pb_per_GeV": errors["total"]})
        require(bool(bins), "Empty table")
        tables.append({"name": table_name, "doi": data["doi"],
                       "Q2_range_GeV2": q2, "y_range": inelasticity,
                       "raw_qualifiers": data["qualifiers"], "bins": bins})
        files.append({"path": str(path.relative_to(BASE.parent)), "sha256": digest(path),
                      "url": meta["data"]["json"].replace(" ", "%20")})
    for previous, following in zip(tables, tables[1:]):
        require(Decimal(previous["Q2_range_GeV2"][1]) == Decimal(following["Q2_range_GeV2"][0]), "Q-squared intervals are not contiguous")
        require(previous["y_range"] == following["y_range"], "Inelasticity cuts differ")
    result = {
        "schema": "H1Pi0DifferentialData-v1", "stage": "s01", "status": "Complete",
        "producer_sha256": digest(Path(__file__)), "inputs": files,
        "requested_figure": "arXiv:1808.04396 Fig. 3",
        "original_theory_figure": "hep-ph/0411212 Fig. 4",
        "experimental_source": "hep-ex/0404009 Table 2/Fig. 4",
        "tables": tables,
        "decimal_policy": "Published decimal strings preserved verbatim; no bin-center conversion or averaging applied.",
        "uncertainty_policy": "total already includes statistical uncertainty; retain both labels and do not add them again.",
        "beam_metadata_policy": "The raw SQRT(S)=0.0 qualifier is a placeholder. Use beam energies from the H1 publication and tool-derive the invariant before numerical production.",
        "checks": {"record_table_identity": True, "observable_and_units": True,
                   "finite_positive_data": True, "contiguous_momentum_bins": True,
                   "contiguous_Q2_ranges": True, "shared_y_cut": True,
                   "distinct_statistical_and_total_uncertainties": True},
        "theory_prediction_generated": False,
    }
    output = BASE / "s01_result"
    temporary = output.with_name(output.name + f".tmp.{os.getpid()}")
    try:
        temporary.write_text(json.dumps(result, indent=2) + "\n")
        require(json.loads(temporary.read_text()) == result, "Result reload failed")
        temporary.replace(output)
    finally:
        if temporary.exists():
            temporary.unlink()
    count = sum(len(t["bins"]) for t in tables)
    progress(f"Data preparation completed: {len(tables)} Q-squared intervals, {count} published cross-section bins, all embedded gates passed; s01_result SHA256={digest(output)}. Raw tables and publications retain input/provenance value; no disposable cache. Next requires the resolved six-channel theory input and PDF/FF specification before convolution, final overlays and ratios.")
    print(json.dumps({"status": "Complete", "Q2_ranges": [t["Q2_range_GeV2"] for t in tables],
                      "bins": count, "result": str(output)}, indent=2))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        progress(f"Data preparation failed: {type(error).__name__}: {error}. Next resolve the exact input failure; no prediction produced.")
        raise
