# SIDIS NLO reproduction macros


## Layout

| Folder | Physical channel |
|---|---|
| `Hgq/` | incoming gluon, fragmenting quark |
| `Hqq/` | incoming quark, fragmenting quark |
| `Hqg/` | incoming quark, fragmenting gluon |
| `Hgg/` | incoming gluon, fragmenting gluon |
| `Hqqbar/` | incoming quark, fragmenting antiquark |
| `Hqqp/` | incoming quark, different-flavour fragmenting quark |
| `final_finite_F_hats/` | accepted finite F-hats collected by channel |

Each channel contains sequential `sNN_<original-name>` producer files,
`output/` for accepted outputs, `check_macros/` for useful non-producing
cross-checks, a concise `README.md`, and `SOURCE_MANIFEST.json`. The manifest
records every original path and SHA-256 hash.

## Reproducing a channel

1. Work in a disposable copy of the full repository. The macros are frozen
   source snapshots, not replacements for the working tree.
2. Follow the channel README and execute `s01`, `s02`, ... in order. Restore
   each file to the `source` path recorded in `SOURCE_MANIFEST.json` before
   running it; the original scripts intentionally retain their established
   relative paths and cache names.
3. Mathematica/FeynCalc is required only for `.wls` trace, loop-reduction, or
   accepted Wolfram stages. Python/SymPy performs the remaining algebra.
4. C1 and C2 are required gates and stay in the numbered chain. Auxiliary
   regression, export, and promotion checks are isolated in `check_macros/`.
5. Compare each generated result against the same-step accepted artifact in
   `output/`, using `SOURCE_MANIFEST.json` hashes. Final results must also
   match `final_finite_F_hats/SHA256SUMS` where the accepted format is copied
   byte-for-byte.

The large distribution sectors and regular sectors are deliberately kept
separate where the accepted calculation did so: they multiply different
distributions and sometimes live in different exact algebra systems. Do not
sum or convert them merely to obtain one file.

Explicitly rejected/superseded trees (`rejected/`, `OLD_*`, `WRONG_*`, stale
cache backups, failed pole gates, and diagnostic F-hat attempts) are absent.

