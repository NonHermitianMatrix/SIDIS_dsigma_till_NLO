# Hgg: new SIDIS F hats versus BigTMD

**Both F hats agree: 2/2 exact comparisons and 4/4 90-digit physical-point checks passed.**

Both complete finite NLO hats agree as symbolic functions. Independent charge symbols remain formal. Finite ordinary remainders from the reference plus functions are included.

The exact claim uses the same declared rational reconstruction of printed BigTMD decimals as the existing all-channel comparison. It is conditional on that reconstruction; it does not recover the unavailable original exact coefficients. Literal imports are preserved. The comparison fixes SU(3), matches the common scale and charges, and transports the same delta and plus-distribution convention. Production F hats retain their symbolic color, flavor, charge and scale dependence.

Reference commit: `6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. Difference direction: new SIDIS minus reconstructed BigTMD.

S02 uses the existing checked reference conversion and normalizer. S03 completes the twelve finite-delta identities across the actual dilogarithm argument sign regions and their separating boundary. The S02 residuals required further simplification; no production coefficient was changed. The 90-digit checks evaluate the original expressions at two exact physical points per comparison with the stored relative/absolute tolerance of 10^-60.

The existing source-bound comparison records that the pinned public driver skips nonzero ordinary remainders from this channel's plus functions. This report compares the complete coefficient files. See the [existing driver finding](../../../bigTMD_comparison/Hgg_v2/s04_result.md).

- [Current production result](../../Hgg/s11_result/s11_result.wl).
- [Frozen input manifest](s01_result/manifest.json).
- [Exact differences and numerical evidence](s03_result.wl).
- [S02 proof caches](s02_result/).

Production SHA256: `85cc9a0e52f453fe65441e17a3f6b43aa7c81e457359477bc992bdd5ed453e43`.

Comparison SHA256: `621e25979f06899d3475cec41feb97809ba67490759c8ed7c73ba2cf7f6e362d`.

Final identity job `14693251` on `n6131` completed with peak process-tree RSS 1584693248 bytes and no memory-guard stop. The source, log and execution receipt are in the parent comparison folder.
