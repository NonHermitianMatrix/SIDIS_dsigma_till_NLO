#!/usr/bin/env python3
"""Freeze the six requested F-hat payloads; copying is not physics acceptance."""
from __future__ import annotations

import hashlib
import argparse
import json
import os
from pathlib import Path
import shutil
from datetime import datetime, timezone

BASE = Path(__file__).resolve().parent
SCRIPTS = BASE.parent
CHANNELS = {
    "Hqq_v2": {
        "producer": "s08_extract_hqq_fhats.wl",
        "payloads": {"s08_result.wl": "0b69a0db7740127ab16c53d181317b7defbd17af846e55582213ca28d1d35741"},
        "ledger_status": "Accepted in channel README; BigTMD benchmark mismatch remains documented.",
    },
    "Hgg": {
        "producer": "s13_extract_fhat_hgg.wl",
        "payloads": {"s13_result": "9977c411c111d58f9e7fb4b768c165e10c0e1bfd92470afd3423f5a75dfb9e8f"},
        "ledger_status": "Corrected S13-v2 accepted in channel README; physical flavor-charge sum remains symbolic.",
    },
    "Hqqbar": {
        "producer": "s13_extract_fhat_hqqbar.wl",
        "payloads": {"s13_result": "4224b46a064087ed3b20e36a049dd1929019f66583263fcb2c28c9b69614c64f"},
        "ledger_status": "Charge-stripped S13 accepted in channel README; physical luminosity remains deferred.",
    },
    "Hqqprime": {
        "producer": "s13_extract_fhat_hqqprime.wl",
        "payloads": {
            "s13_result": "351f1cbb6995d479cac0087e1cfefb92885c1e1f7dfb362386ba7dfe5c7d4365",
            "s13_cache_hqqprime_incoming_charge_squared_f1hat": "59cbf25b48e596d74b0541a1887f74a4256076002322cb4b110f078e3463adf0",
            "s13_cache_hqqprime_prime_charge_squared_f1hat": "a755f32e6319c798fd24bdfdd2265b1d7adf88c7e203ca0d6c88995ae27f0d07",
            "s13_cache_hqqprime_mixed_incoming_prime_charge_f1hat": "24caef792f819725d9d607e21d0528a77164a2d64dd04337fcedf493f2ac1682",
            "s13_cache_hqqprime_incoming_charge_squared_f2hat": "6e07c2d9f20fbca5e038e127c932ba8e0f0c32e6c113ddadb430b22bb7a847d7",
            "s13_cache_hqqprime_prime_charge_squared_f2hat": "716be770e25f9bec27127c1815c0ee4653b40b46b74c74753c95ef8a95445891",
            "s13_cache_hqqprime_mixed_incoming_prime_charge_f2hat": "babc7fbc0692727e7f57a9d0cfd437ae5ed4cbb1f7e495a30321be4060a08f1d",
        },
        "ledger_status": "S13 and all six charge-resolved caches accepted in channel README.",
    },
    "Hgq_v4": {
        "producer": "s10_final_hats.wl",
        "payloads": {"s10_result.wl": "575ea96993eb9a86cfeddb6e10d61c0147e3bf74d35bc25eaf3dbb03fceb9bfe"},
        "acceptance_files": {"s10_poles.wl": "43edde6d88a5ba15567a8fc09a626867596a46e6e78f22f981a2914592cca1ed"},
        "ledger_status": "Independent S10 accepted; BigTMD positive-branch comparisons agree; unresolved MadGraph real-emission comparison remains documented.",
    },
    "Hqg_v3": {
        "producer": "s12_final_hats.wl",
        "payloads": {"s12_result.wl": "0c31db0e92387801fe41300d055bcf793ddbf231ff94624fd88f6153d12c958c"},
        "ledger_status": "Independent LO+NLO S12 accepted in channel README; finite Delta comparison discrepancy documented separately.",
    },
}


def sha256(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def progress(message: str) -> None:
    with (SCRIPTS / "progress.md").open("a") as stream:
        stream.write(f"\nNumerics S01 {datetime.now(timezone.utc).isoformat()}: {message}\n")


def freeze(source: Path, target: Path, expected: str | None, role: str) -> dict:
    if source.is_symlink() or not source.is_file():
        raise RuntimeError(f"Missing or nonregular input: {source}")
    source_hash = sha256(source)
    if expected is not None and source_hash != expected:
        raise RuntimeError(f"Accepted input hash changed: {source}")
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        if target.is_symlink() or sha256(target) != source_hash:
            raise RuntimeError(f"Refusing to replace a different frozen input: {target}")
    else:
        temporary = target.with_name(target.name + f".tmp.{os.getpid()}")
        try:
            shutil.copyfile(source, temporary)
            if sha256(temporary) != source_hash:
                raise RuntimeError(f"Copy integrity failed: {source}")
            temporary.rename(target)
        finally:
            if temporary.exists():
                temporary.unlink()
    if sha256(source) != source_hash or sha256(target) != source_hash:
        raise RuntimeError(f"Input changed during import: {source}")
    return {
        "source": str(source.relative_to(SCRIPTS)),
        "copy": str(target.relative_to(BASE)),
        "sha256": source_hash,
        "bytes": target.stat().st_size,
        "role": role,
        "prior_accepted_sha256_checked": expected is not None,
        "source_copy_equal": True,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--reuse-manifest', type=Path)
    options = parser.parse_args()
    previous = {}
    reused = []
    reuse_provenance = None
    if options.reuse_manifest:
        path = options.reuse_manifest.resolve()
        if not path.is_relative_to(BASE):
            raise RuntimeError('Reuse manifest must stay inside numerics')
        saved = json.loads(path.read_text())
        if saved['status'] != 'Complete':
            raise RuntimeError('Reuse manifest is not complete')
        previous = {row['channel']: row for row in saved['channels']}
        reuse_provenance = dict(path=str(path.relative_to(BASE)), sha256=sha256(path))
    progress("Requested six-channel F-hat import. Starting immutable source/copy checks and copies; no mathematical transformation. Next write s01_result only after complete payload integrity checks.")
    rows = []
    for channel, specification in CHANNELS.items():
        folder = SCRIPTS / channel
        destination = BASE / "Fhats" / channel
        if channel in previous:
            row = previous[channel]
            expected_payloads = specification['payloads']
            observed_payloads = {}
            for record in row['files']:
                path = BASE / record['copy']
                if not path.resolve().is_relative_to(destination) or sha256(path) != record['sha256'] or path.stat().st_size != record['bytes']:
                    raise RuntimeError('Changed frozen reuse input: '+str(path))
                if record['role'] == 'terminal_fhat_payload':
                    relative = str(path.relative_to(destination))
                    observed_payloads[relative] = record['sha256']
                    if sha256(SCRIPTS / record['source']) != record['sha256']:
                        raise RuntimeError('Unchanged-channel source payload changed: '+record['source'])
            if observed_payloads != expected_payloads:
                raise RuntimeError('Reuse payload set or accepted hashes changed: '+channel)
            rows.append(dict(row, snapshot_reused_from=reuse_provenance))
            reused.append(channel)
            print('S01_REUSED', channel, flush=True)
            continue
        records = []
        for relative, expected in specification["payloads"].items():
            records.append(freeze(folder / relative, destination / relative,
                                  expected, "terminal_fhat_payload"))
        for relative, expected in specification.get('acceptance_files', {}).items():
            records.append(freeze(folder / relative, destination / relative,
                                  expected, 'acceptance_provenance'))
        for relative, role in (("README.md", "convention_ledger_snapshot"),
                               (specification["producer"], "producer_provenance_only")):
            records.append(freeze(folder / relative, destination / relative, None, role))
        rows.append({"channel": channel, "ledger_status": specification["ledger_status"],
                     "files": records})
        print(f"S01_IMPORTED {channel} payloads={len(specification['payloads'])}", flush=True)
    result = {
        "schema": "SIDISNumericsImport-v2",
        "stage": "s01",
        "status": "Complete",
        "operation": "Byte-preserving import, not a physics validation",
        "producer_sha256": sha256(Path(__file__)),
        "channels": rows,
        "reused_channels": reused,
        "reuse_manifest": reuse_provenance,
        "checks": {
            "all_requested_channels_imported": set(r["channel"] for r in rows) == set(CHANNELS),
            "all_copies_match_recorded_source_snapshots": all(sha256(BASE/f["copy"]) == f["sha256"] for r in rows for f in r["files"]),
            "all_documented_accepted_payload_hashes_checked": True,
            "mathematical_payloads_modified": False,
            "numerical_convolution_performed": False,
        },
    }
    output = BASE / "s01_result"
    temporary = output.with_name(output.name + f".tmp.{os.getpid()}")
    try:
        temporary.write_text(json.dumps(result, indent=2) + "\n")
        if json.loads(temporary.read_text()) != result:
            raise RuntimeError("Manifest reload failed")
        temporary.replace(output)
    finally:
        if temporary.exists():
            temporary.unlink()
    total = sum(f["bytes"] for r in rows for f in r["files"] if f["role"] == "terminal_fhat_payload")
    progress(f"Six-channel v4 import completed: {sum(len(s['payloads']) for s in CHANNELS.values())} terminal payload files, {total} bytes; every frozen hash matches its recorded source snapshot and every accepted payload hash passed. Reused unchanged snapshots: {reused}. s01_result SHA256={sha256(output)}. Next recover v4 schemas and gate its own distribution/convention compatibility before convolution; its comparison limitations remain explicit.")
    print(f"S01_SUCCESS {output} payload_bytes={total}", flush=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        progress(f"Import failed: {type(error).__name__}: {error}. No numerical result produced. Next resolve the exact input/integrity failure; intact frozen copies retain resume value.")
        raise
