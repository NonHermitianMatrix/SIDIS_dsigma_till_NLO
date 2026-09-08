# Hgg comparison with BigTMD

The production hats are frozen before downloading reference coefficients.
The three stages are `s01_prepare_reference.py`, `s02_benchmarks.wls`,
and `s03_compare.py`, in that order. Run the Python stages with Python;
run the Wolfram stage directly with Engine 15. No PDF or FF installation
is required for these partonic comparisons.

The reference is JeffersonLab/BigTMD commit
`6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. Only its driver and channel
4A/B/C contraction functions are inputs. `s01_result.json` binds their
hashes and the unchanged production result. No reference coefficient is
used to generate or adjust the production hats.

The driver assigns Hgg to channel 4A. Its charge-pair sum divided by two
equals the production sum over quark flavours. Its coupling weight and
the paper's tensor normalization are matched symbolically in stage 2.
The comparison sets Nc=3, alpha_s=1, and chargeSum=1, thereby comparing
the coefficient per unit flavour-charge sum. The physical variables,
projector matrix, and positive square-root branch are computed by Wolfram.

Stage 2 proves that the published plus1B and plus2B coefficients vanish
at the recoil endpoint. Their products with the plus distributions are
therefore ordinary contributions, `plus1B/w + plus2B Log[w]/w`.
The published driver's `chn < 4` condition omits these contributions for
Hgg. Both its regular-only selection and the complete supplied coefficient
representation are compared and retained in the report. The literal
driver passes mu=Q; the additional scales test the coefficient functions
directly.

The complete coefficient representation passes all 36 F-hat comparisons
at 18 physical points. These cover positive, negative, and zero s+t,
unit and nonunit recoil, and three scale choices. The maximum measured
relative difference is 8.140229468365256e-13. The regular-only driver
selection disagrees; see `bigtmd_minus_local.md` and `s03_result.json`.

Local hats are evaluated at 60 digits. The direct published Python test
preserves its decimal literals, removes only JIT decorators, and uses
Python math for scalar numpy log/sqrt/pi operations. The endpoint proof
imports the decimal tokens as exact base-10 rational numbers; it needs
no rational reconstruction. The numerical tolerance is
1e-10 + 1e-7 times the larger magnitude. This is numerical agreement at
the listed points, not a global symbolic equality proof against the
published decimal functions.

Accepted symbolic evidence is in `s02_endpoint_result.wl` and
`s02_endpoint_result.json`. The evaluated points are in `s02_result.json`.
The final signed differences and source identities are in `s03_result.json`.
