# Hgg BigTMD check ledger

This directory compares the finite Hgg structure functions saved by the
accepted parent S13 with the pinned BigTMD channel-4 reference at one common
benchmark. The only live execution/status record remains
`../../progress.md`.

## Input and convention contract

The local input is `../s13_result`, accepted as `HggS13-v2` with SHA-256
`9977c411c111d58f9e7fb4b768c165e10c0e1bfd92470afd3423f5a75dfb9e8f`.
S01 must require the complete Hgg-only status, every saved S13 check, and
current S12 and authoritative-paper provenance hashes before consuming either
saved F-hat action.

The external snapshot is `BigTMD_reference` at commit
`6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. Hgg is BigTMD channel 4, case
A. Only the `regular` functions in `NLO/Pg/fchn4A.py` and
`NLO/Ppp/fchn4A.py` are used; channel-4 endpoint and subtraction fields are
zero. The comparison direction is always `BigTMD minus local`.

## Stage contracts

1. `s01_export_local_fhat_benchmark.wl` loads the accepted parent result,
   structurally extracts `{Endpoint, IntegrandPhiS, IntegrandPhi0}` from both
   `F1Hat` and `F2Hat`, proves the two regular-only zero fields exactly, and
   atomically writes `local_fhat_benchmark.json`.
2. `s02_construct_bigtmd_fhat_compare.py` validates the S01 metadata and
   pinned reference commit, evaluates the two channel-4A projector modules,
   applies the existing projector-to-F-hat construction, and atomically
   writes `bigtmd_fhat_benchmark.json`, `bigtmd_minus_local.json`, and
   `bigtmd_minus_local.md`.

The comparison is diagnostic: successful execution means the construction,
bindings, and saved differences validated. It does not require every
coefficient to fall within the numerical comparison tolerance.

## Regeneration boundary

The five generated files from the former S13-v1 lineage were deleted before
regeneration. The two stage sources and pinned reference checkout were
retained.

## Accepted S13-v2 regeneration

S01 completed under Engine 15 and independently passed exact current-S13
path/byte/hash/version binding, complete field-schema, finite-value,
regular-only-zero, channel-mapping, and convention gates. S02 then completed
against the pinned reference. A separate validator rebuilt the projector and
case F hats, all six signed differences and their absolute/relative fields,
the summary maxima, and the report; all 15 terminal gates passed. No temporary,
Python bytecode, or Numba cache remains.

Exact identities are:

| Artifact | SHA-256 |
|---|---|
| `s01_export_local_fhat_benchmark.wl` | `41ca589eec8e69121a1509c839aedc336126151354411f0cfdf49a20d6a99a08` |
| `s02_construct_bigtmd_fhat_compare.py` | `a5da8e6b57b2d26b968bdbb365168cd12b2c714188eee97f45f4bb62fef30280` |
| `s01_production.log` | `6139bdb6f0784334488ae896811b2773bd20cda50553643867c0815fbb98d6fa` |
| `local_fhat_benchmark.json` | `8f7c0b9a7a75c78046d6c31e3cb333353b2f077935054f96146884a18a2569e0` |
| `bigtmd_fhat_benchmark.json` | `4afc688c31d3779b6c865577a87a1b710168bd2edff238f6369bfc865712e212` |
| `bigtmd_minus_local.json` | `2c163a855e8ccb53fde1a302ad054b9a065a7d246443a5cf943d46f3c25fa087` |
| `bigtmd_minus_local.md` | `03cf16f794973be6e93d3c3a9248f119864232858510c093a67160715c9ac421` |

The four endpoint/subtraction F-hat coefficients agree exactly at zero. The
regular-field signed differences are `-7.821163069710413e-06` for F1Hat and
`-6.381900732032689e-06` for F2Hat. The maximum absolute and relative
differences are `7.8211630697104128e-06` and `1.9916820900540568`;
`AllWithinTolerance=False`. This is an accepted diagnostic output, not an
equality claim.
