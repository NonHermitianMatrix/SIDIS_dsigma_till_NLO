# Shared SIDIS programs and integrals

The six channels share the actual programs in this directory. Their consecutive channel-level program names are symbolic links here. Run a shared program once for its applicable channel group; it writes each channel's own outputs through the recorded path adapter.

| Location | Contents |
|---|---|
| `s01_import_inputs.py` and `s01_result/` | Unchanged-input import and shared manifest |
| `s02_*`–`s20_*` programs and matching `sNN_result/` | Definitions, family mappings, Kira reduction, SubTropica inputs/evaluations, regulated soft regions, collinear inputs, UV/IR assembly and final manifest |
| `software/` | Pinned SubTropica/HyperIntica installation, dependencies and installation receipts |
| `previous_runs/` | Shared superseded sources, results and caches, including the excluded Package-X-input attempt |
| `previous_runs/layout_sources/` | Exact original sources that produced accepted physics artifacts |
| `s21_organize_layout.py`, `s21_result/layout.json` | One-time file relocation program, channel stage maps, old/new paths and source identities |
| `s22_paths.wl`, `s22_result/` | Runtime path adapter and structural validation of moved files, preserved results and sources |

Kira configurations, target inventories, rules, logs and resumable databases are under the owning shared reduction result directory. Raw SubTropica engine output and normalization/continuation metadata are kept separately inside its owning evaluation result directory. Channel-specific inputs, coefficients and final hats are in the six channel folders.

The original S06/S07 uncut-parent route is retained for provenance; it is not a required source of the accepted physical cut masters. The physical real route uses shared S08/S10/S15 with the S04 Kira reduction. Virtual masters use S09/S12/S13; self-energy masters and UV residues use S14. Final assembly uses S17/S18/S19/S20. The channel READMEs retain the detailed contracts and all corrections.

The current programs contain only documented I/O changes relative to their preserved executed sources. `s22_paths.wl` verifies each current source's recorded hash before using an original source identity for an accepted checkpoint. It leaves physics expressions unchanged. Preserve both source generations and the layout manifest together; a physics edit requires new source/input identities and fresh gates.

The accepted overall final manifest and cluster receipt are `s20_result/s20_result.wl` and `s20_result/s20_execution.json`. The only live progress record is `../../progress.md`.
