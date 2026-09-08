# New SIDIS comparison with BigTMD

All six channels agree: **60/60 exact comparisons** and **120/120 high-precision checks passed**.

| Channel | Exact comparisons | Numerical comparisons | F1 and F2 |
|---|---:|---:|---|
| [Hqq](Hqq/s04_result.md) | 18/18 | 36/36 | Agree |
| [Hqg](Hqg/s04_result.md) | 18/18 | 36/36 | Agree |
| [Hgq](Hgq/s04_result.md) | 18/18 | 36/36 | Agree |
| [Hgg](Hgg/s04_result.md) | 2/2 | 4/4 | Agree |
| [Hqqbar](Hqqbar/s04_result.md) | 2/2 | 4/4 | Agree |
| [Hqqprime](Hqqprime/s04_result.md) | 2/2 | 4/4 | Agree |

The exact claim uses the same declared rational reconstruction of printed BigTMD decimals as the existing all-channel comparison. It is conditional on that reconstruction; it does not recover the unavailable original exact coefficients. Literal imports are preserved. The comparison fixes SU(3), matches the common scale and charges, and transports the same delta and plus-distribution convention. Production F hats retain their symbolic color, flavor, charge and scale dependence.

For Hqq/Hgq, the coefficient count includes the checked tensor projection into both hats; Hqg is compared directly by F-hat coefficient. The remaining channels are compared as complete symbolic finite hats. The reports retain the existing Hgg, Hqqprime and Hqqbar public-driver omissions and the separate Hgq MadGraph caveat.

S03 resolved the finite-delta identity normalizations without changing production results. [Full symbolic output](s03_result.wl), [machine-readable summary](s03_result.json), [cluster receipt](s03_execution.json).
