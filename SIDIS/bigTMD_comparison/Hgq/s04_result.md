# Hgq: new SIDIS F hats versus BigTMD

**Both F hats agree: 18/18 exact comparisons and 36/36 90-digit physical-point checks passed.**

The two Born hats and all delta/L0/L1/regular tensor coefficients on both open coordinate branches agree. S02 exactly replays the saved F-hat projections and checks the reference projector matrix, so these tensor comparisons cover both final hats.

The exact claim uses the same declared rational reconstruction of printed BigTMD decimals as the existing all-channel comparison. It is conditional on that reconstruction; it does not recover the unavailable original exact coefficients. Literal imports are preserved. The comparison fixes SU(3), matches the common scale and charges, and transports the same delta and plus-distribution convention. Production F hats retain their symbolic color, flavor, charge and scale dependence.

Reference commit: `6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. Difference direction: new SIDIS minus reconstructed BigTMD.

S02 uses the existing checked reference conversion and normalizer. S03 completes the twelve finite-delta identities across the actual dilogarithm argument sign regions and their separating boundary. The S02 residuals required further simplification; no production coefficient was changed. The 90-digit checks evaluate the original expressions at two exact physical points per comparison with the stored relative/absolute tolerance of 10^-60.

The existing comparison records this channel and all coefficient classes in the pinned driver. See the [existing driver finding](../../../bigTMD_comparison/Hgq_v4/s04_result.md).

The inherited independent MadGraph real-emission sign comparison remains unresolved. This coefficient comparison does not close that separate check.

- [Current production result](../../Hgq/s17_result/s17_result.wl).
- [Frozen input manifest](s01_result/manifest.json).
- [Exact differences and numerical evidence](s03_result.wl).
- [S02 proof caches](s02_result/).
- [S03 delta proofs](s03_result/).

Production SHA256: `7bff33cc4332bc639d13fbcd86ccd964973ca1a0b0fec06c6598e691c07def7f`.

Comparison SHA256: `339c381eabc7718f2b5d96c0808ab400145c5be5e9b60621cf893aefe5c91502`.

Final identity job `14693251` on `n6131` completed with peak process-tree RSS 1584693248 bytes and no memory-guard stop. The source, log and execution receipt are in the parent comparison folder.
