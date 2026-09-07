# Hgg at order alpha_s squared

This calculation follows Wang, Gonzalez-Hernandez, Rogers, and Sato,
arXiv:1903.01529, using the supplied PDF. The supplied stand-alone QCD
reference informed the FeynArts/FeynCalc amplitude and interference method.
No other channel's calculation code is an input.

The channel is gamma*(q) + g(p) -> g(k1) + q(k2) + qbar(k3).
k1 is observed. The quark and antiquark are integrated once, with no
identical-particle factor and no second copy of the spectator pair.
The final charge factor `chargeSum` denotes the sum of squared charges of
the massless quark flavours. `Nc` remains symbolic.

The stages run directly with Wolfram Engine 15:

- `s01_amplitudes.wls`: FeynArts diagrams for the real process and the two
  Born processes needed in Eq. 46. Photon charge remains symbolic.
- `s02_square.wls`: D-dimensional FeynCalc spin/color sums, physical gluon
  polarization sums, and the photon Ward identity. Each interference is
  checkpointed separately. The electromagnetic coupling is removed for the
  current tensor. The incoming quark average is 1/(2 Nc); the incoming
  gluon average is 1/((D-2)(Nc^2-1)).
- `s03_partial_fractions.wls`: Appendix D affine partial fractions. Every
  checkpoint is required to reconstruct its original rational expression.
- `s04_angular_integrals.wls`: Appendix B angular integrals, with the pole
  masters checked against F24 and F28. The recoil endpoint is checked at
  symbolic epsilon before writing the full integrated result.
- `s05_factorize.wls`: Eq. 46 MSbar subtractions, exact cancellation of
  both collinear pole residues, and extraction of F1hat and F2hat using
  the tensor decomposition. No virtual contribution occurs in this channel
  (Table I).

The main result is `s05_result/Fhats.wl`, with a plain-text version in
the same directory. Its `Fhats` association contains `F1hat` and `F2hat`.
It includes alpha_s squared and `chargeSum`, with the current-tensor and
phase-space normalization of Eqs. 19 and 38, including 1/(2 pi)^4.
`mu2` is the common squared MSbar renormalization and factorization scale.
The incoming/outgoing quark and antiquark terms in the factorization sum
follow Table II; they do not duplicate the real spectator pair.

The Mandelstam variables are the paper's `s`, `t`, and `w = s23`;
`u` has been eliminated using momentum conservation. The program records
the positive auxiliary square root as `rho_squared` and `rho_branch`.
Replace `rho` by `Sqrt[result["rho_squared"]]` when evaluating a hat.
The physical region and the substitution rules to xhat, zhat, Q2, qT2
are stored in the result. There are no fitted numerical parameters in the
production calculation.

Each stage saves its results in its numbered result directory. The trace
stage and integration stages can resume from their own checkpoints. Run
stages in order; the later stages must not be treated as complete until
their full result files and checks exist. The external BigTMD comparison
is performed only after the production result has been saved and hashed.

The execution monitor uses a 9 GiB address-space limit, stops a process
group above 6 GiB RSS or below 2 GiB system-available RAM, and records peak
RSS and exit status in `sNN_resources.json`. FeynCalc interference algebra
also uses a 4 GiB Wolfram memory constraint. No extra runner files are
required.

The executed result passed the Born and real photon Ward identities,
all interference partial-fraction identities, the F24/F28 master checks,
the recoil-endpoint test at symbolic epsilon, and both collinear pole
cancellations. The accepted hats file SHA256 is
`85a5cd93f6fda886884f1de799a71081fe96933a5172894613f69e6f0e1c5d58`.
The maximum monitored process RSS was 1,353 MiB; no OOM occurred.

`bigTMD_check/bigtmd_minus_local.md` records the independent comparison.
All 36 comparisons agree with the complete published coefficient functions
to a maximum relative difference of 8.140229468365256e-13. The public
driver omits finite Hgg contributions contained in its own plus-function
files. That driver discrepancy is retained in the report. The production
result was not changed after the reference comparison.

`madgraph_check/madgraph_minus_local.md` records the independent MadGraph
3.7.0 check of the unintegrated current tensor. A fresh eight-diagram
subprocess agrees for both contractions at six deterministic spacelike
photon points: 12/12 pass, with maximum relative difference
8.725237422956394e-16. All six photon Ward checks pass; the maximum
normalized squared residual is 1.511315062183669e-32. The standalone
generated sources and explicit-current driver are included. This check
leaves the production tensor and final hats unchanged.

Checkpoint reuse assumes the same source and input conventions. If a
calculation stage or an input is changed, remove its dependent result
directories before regenerating; do not reuse stale checkpoints.

## Current six-input numerical consumer contract

The user selected this channel for the numerical generation in ../numerics/.
That consumer imports the accepted terminal payload byte-for-byte and records its
identity in numerics/s01_result. Its S03 recovers this payload's own charge,
flavor, distribution and partonic-variable contracts; S05 exports these
coefficients and checks direct Wolfram values. The numerical consumer applies the
S04 fragmentation Jacobian to these partonic hats once and retains the source
normalization. It does not alter any symbolic production coefficient.
Current charge moments, positive-rho definitions and bounded-plus conventions
must come from this channel's own payload. S07/S10 gate native evaluation before
S09 convolves with the unchanged MRST02 and KKP/Kretzer inputs. The numerical
README documents stage interfaces; only ../progress.md records execution status.

Accepted current numerical coefficient interface: ../numerics/s03_cache/Hgg_v2_consumer_contract, SHA256 781adc1ecc6a3270202cfaedbb73a4d61e51db7fa4edd0b901af72800147b2ee; ../numerics/s05_cache/Hgg_v2_result, SHA256 5cb2cd43f549fbdd7b18b9114d8e3e41a5ca3fb79cf222efe8f65f338eca8502. The current ../numerics/s07_result (SHA256 15fdc7e47c5494bdea7d7750089ec7f942a2920367ae64a9b5cd115fb16620e8) binds 2 paired programs for this channel and their exact operation-table/source identities. All associated Wolfram/native checks passed. These numerical interface identities supersede earlier numerical-export references for the active six-input generation; symbolic production identities and comparison caveats above remain unchanged. Convolution uses the established partonic coefficient and charge conventions; final integrated-bin acceptance is recorded separately in the numerical ledger.

Accepted numerical consumer output: ../numerics/s09_result, SHA256 66c0df6a0a8001e4603d939602bb8c7aa378fe77c916437f1b9115b8363b36ad, and ../numerics/s11_result, SHA256 9f7ccd91726edc6735f905ae36dc5c3b4076c97290613866e340dd5a9240fd62. All 17 current full-channel bins pass the original numerical gates; the S09 component arrays retain this channel's signed LO/NLO contributions with complete within-bin covariance. Both comparison figures are bound by ../numerics/dsigmapibydpt/s03_result, SHA256 f82e5fd31e63c1b2c5c5a110e9a872b20324c8e64e49202a9f52ba66e4b6cc6e. No symbolic channel payload changed.

## Source-bound six-channel analytical comparison

The separate [analytical report](../bigTMD_comparison/Hgg_v2/s04_result.md) compares this channel's unchanged current F hats with pinned BigTMD commit `6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. Both F hats agree in the stated comparison. Nonzero ordinary remainders of plus functions omitted. The exact-algebra claims are conditional on the declared reconstruction of printed decimal constants and the report's color, charge, scale, branch and distribution conventions.

Input SHA256: `85a5cd93f6fda886884f1de799a71081fe96933a5172894613f69e6f0e1c5d58`. Comparison SHA256: `88f684f0de53441c1581391b00583d83d973f0a516bce657d3494c9307d2a992`. Report SHA256: `1989330fe3fac41a471217657e2ead477a8736cd590854788c42c04ce02728ba`. The comparison-directory README and receipts bind the source, result, proof-cache and validation identities. No production expression or existing independent-validation caveat is superseded by this comparison.
