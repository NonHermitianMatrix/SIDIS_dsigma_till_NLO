# Hqq: new SIDIS versus BigTMD

Use the same pinned JeffersonLab/BigTMD commit and reference conversion as `../../../bigTMD_comparison`. The difference direction is new SIDIS minus reconstructed BigTMD. Exact-reference claims are conditional on the previous comparison's documented rational reconstruction of printed decimals, SU(3), common scale, charges, and plus-distribution convention. Literal reference files are retained.

S01 copies immutable new SIDIS S20 outputs and unchanged reference/conversion inputs, with source and destination hashes. No old agreement flag is used to establish a new agreement.

S02 reads the new F hats, reuses the accepted reference conversion and function normalizer, compares all applicable Born/delta/L0/L1/regular coefficients, and validates the original expressions at high precision. Tensor comparisons must replay the saved final projection exactly. Each symbolic difference, its domain, and numerical evidence is saved. An unevaluated equality remains unresolved; a nonzero value is reported without assigning blame. The comparison does not tune a production coefficient.

Sources, result files and caches stay local. Physics algebra runs on bounded Hoffman2 workers with a persistent monitor. Only `../../../progress.md` records live execution status.

The channel input snapshot and its hash manifest are in `s01_result/`. S02 stores coefficient definitions, exact differences, and numerical evidence in `s02_result/`. The parent channel README defines the production conventions.

## S03 finite-delta completion contract

Reuse S02 exact-zero results unchanged. For each remaining finite delta residual, require all original high-precision comparisons to pass and check its normalized value at the same points. Read an actual dilogarithm argument from that residual; use the existing, source-bound identity normalizer on its negative and positive regions, with a separately solved zero-argument boundary. Wolfram must prove the argument domain, complete region coverage, every boundary substitution, and zero residual in every region. Save the full proof, input/source hashes, and consolidated all-channel results. No production coefficient is changed.

## Accepted comparison artifacts

[Hqq report](s04_result.md): 18/18 exact and 36/36 high-precision comparisons pass. `s03_result.wl` contains the fresh final differences, physical domains and original numerical values. `s04_result.json` binds the current production file, comparison and report hashes. The source/input-bound delta proof caches are retained when this channel required S03. No production expression was altered by the comparison.
