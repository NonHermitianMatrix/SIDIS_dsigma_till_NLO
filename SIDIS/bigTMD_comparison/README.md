# SIDIS comparison with BigTMD

**All six channels agree: 60/60 exact comparisons and 120/120 high-precision checks passed.** See the [overall report](s04_result.md) and its linked per-channel reports. The claim is conditional on the documented reconstruction of printed reference decimals.

| Step | Source | Result |
|---|---|---|
| S01 | [Freeze or verify inputs](s01_import_inputs.py) | `s01_result.json`, each channel's `s01_result/` |
| S02 | [Compare all coefficients](s02_compare_coefficients.wl) | `s02_result.wl/json`, per-channel definitions, differences and proof caches |
| S03 | [Complete finite-delta identities](s03_complete_delta_identities.wl) | `s03_result.wl/json`, exact sign-region and boundary proofs |
| S04 | [Export reports](s04_export_reports.py) | `s04_result.md/json` overall and per channel |

S02/S03 ran on Hoffman2; sources, result packets, caches, logs and resource receipts are local. S01 and S04 only copy/verify files and format executed results, so they run locally. S01's executed source is retained in `s01_result/`; the current importer also resolves the organized production paths and verifies immutable snapshots on a repeat run.

Use the same pinned JeffersonLab/BigTMD commit and reference conversion as `../../bigTMD_comparison`. The difference direction is new SIDIS minus reconstructed BigTMD. Exact-reference claims are conditional on the previous comparison's documented rational reconstruction of printed decimals, SU(3), common scale, charges, and plus-distribution convention. Literal reference files are retained.

S01 copies immutable new SIDIS S20 outputs and unchanged reference/conversion inputs, with source and destination hashes. No old agreement flag is used to establish a new agreement.

S02 reads the new F hats, reuses the accepted reference conversion and function normalizer, compares all applicable Born/delta/L0/L1/regular coefficients, and validates the original expressions at high precision. Tensor comparisons must replay the saved final projection exactly. Each symbolic difference, its domain, and numerical evidence is saved. An unevaluated equality remains unresolved; a nonzero value is reported without assigning blame. The comparison does not tune a production coefficient.

Sources, result files and caches stay local. Physics algebra runs on bounded Hoffman2 workers with a persistent monitor. Only `../../progress.md` records live execution status.

## S03 finite-delta completion contract

Reuse S02 exact-zero results unchanged. For each remaining finite delta residual, require all original high-precision comparisons to pass and check its normalized value at the same points. Read an actual dilogarithm argument from that residual; use the existing, source-bound identity normalizer on its negative and positive regions, with a separately solved zero-argument boundary. Wolfram must prove the argument domain, complete region coverage, every boundary substitution, and zero residual in every region. Save the full proof, input/source hashes, and consolidated all-channel results. No production coefficient is changed.

## S04 report contract

Read only the executed S03 summary and source-bound receipts. Verify the final local production files against the frozen comparison hashes and export the per-channel and overall reports. Report exact reconstructed-reference agreement separately from inherited public-driver omissions and the existing Hgq MadGraph caveat. Report generation performs no new physics calculation.