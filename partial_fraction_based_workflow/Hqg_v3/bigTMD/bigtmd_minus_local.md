# Hqg F-hat numerical comparison

Incoming quark, observed gluon; BigTMD channel **3A**. Signed difference: **BigTMD − local**.

The three benchmark seeds match the named Hqqprime setup. Physics inputs are Hqg only. Settings: g_s=1, eq=1, SU(3), mu=Q, nf=4. All dependent kinematics and weights were calculated by Wolfram from the accepted Hqg maps and projectors.

## Direct published-Python comparison

These are ordinary NLO densities at s23>0: regular plus both ordinary plus kernels, including the zeta-to-s23 Jacobian on both sides. The pinned Python decimal functions are executed as written. Endpoint distributions are not evaluated pointwise.

| Benchmark | F hat | Local | BigTMD | BigTMD − local | Relative difference | Close |
| --- | --- | --- | --- | --- | --- | --- |
| interior_1 | F1 | -3.487164161625e-05 | -3.487164161625e-05 | -8.809142651445e-20 | 2.52616e-15 | True |
| interior_1 | F2 | -2.908352781751e-05 | -2.908352781751e-05 | -5.421010862428e-20 | 1.86395e-15 | True |
| interior_2 | F1 | -7.777789041550e-06 | -7.777789041550e-06 | 2.710505431214e-20 | 3.48493e-15 | True |
| interior_2 | F2 | -4.303720891523e-06 | -4.303720891523e-06 | 1.694065894509e-20 | 3.93628e-15 | True |
| interior_3 | F1 | -5.454750788668e-05 | -5.454750788668e-05 | 1.897353801850e-19 | 3.47835e-15 | True |
| interior_3 | F2 | -4.386616270396e-05 | -4.386616270396e-05 | 1.151964808266e-19 | 2.62609e-15 | True |

## Canonical coefficient comparison

These coefficients use delta(s23), L0=[1/s23]_+, L1=[Log(s23/B)/s23]_+, and Regular on [0,B], at fixed xhat,Q,qT2,zH. Born is the LO delta coefficient; Delta is NLO only. Both t(s23) and the Jacobian are transported through the plus action. The author column uses the accepted corrected symbolic endpoints and rational reconstruction of long decimals with denominator at most 10^6. It is distinct from direct execution above.

| Benchmark | F hat | Coefficient | Local | BigTMD | BigTMD − local | Relative difference | Close |
| --- | --- | --- | --- | --- | --- | --- | --- |
| interior_1 | F1 | Born | 3.689072540948e-04 | 3.689072540948e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F1 | Delta | 4.394254038854e-05 | 5.605889245920e-05 | 1.211635207066e-05 | 2.16136e-01 | False |
| interior_1 | F1 | L0 | 3.651578765783e-05 | 3.651578765783e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F1 | L1 | 6.852655267175e-05 | 6.852655267175e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F1 | Regular | -3.090215850424e-05 | -3.090215850424e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | Born | 2.959697934432e-04 | 2.959697934432e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | Delta | 3.482574663232e-05 | 4.449636226799e-05 | 9.670615635667e-06 | 2.17335e-01 | False |
| interior_1 | F2 | L0 | 2.929617135619e-05 | 2.929617135619e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | L1 | 5.497801795575e-05 | 5.497801795575e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | Regular | -2.589885989977e-05 | -2.589885989977e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | Born | 1.487285750582e-04 | 1.487285750582e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | Delta | 3.185614913772e-05 | 3.928864465790e-05 | 7.432495520178e-06 | 1.89177e-01 | False |
| interior_2 | F1 | L0 | 3.392054976133e-05 | 3.392054976133e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | L1 | 2.762715132161e-05 | 2.762715132161e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | Regular | -8.152810528012e-06 | -8.152810528012e-06 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | Born | 7.892971202166e-05 | 7.892971202166e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | Delta | 1.688191588364e-05 | 2.082053730384e-05 | 3.938621420200e-06 | 1.89170e-01 | False |
| interior_2 | F2 | L0 | 1.800151197059e-05 | 1.800151197059e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | L1 | 1.466162838540e-05 | 1.466162838540e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | Regular | -4.502743425806e-06 | -4.502743425806e-06 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | Born | 1.663628252743e-04 | 1.663628252743e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | Delta | 3.840865730436e-05 | 4.402061008548e-05 | 5.611952781121e-06 | 1.27485e-01 | False |
| interior_3 | F1 | L0 | 3.262964170125e-05 | 3.262964170125e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | L1 | 3.090281034660e-05 | 3.090281034660e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | Regular | -5.536894926340e-05 | -5.536894926340e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | Born | 1.341821987311e-04 | 1.341821987311e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | Delta | 3.090237771742e-05 | 3.541837433474e-05 | 4.515996617319e-06 | 1.27504e-01 | False |
| interior_3 | F2 | L0 | 2.631788117366e-05 | 2.631788117366e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | L1 | 2.492508186514e-05 | 2.492508186514e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | Regular | -4.452870741535e-05 | -4.452870741535e-05 | 0.000000000000e+00 | 0.00000e+00 | True |

## Result

```json
{
  "DirectInteriorCount": 6,
  "CanonicalCoefficientCount": 30,
  "AllDirectInteriorWithinTolerance": true,
  "AllCanonicalCoefficientsWithinTolerance": false,
  "CanonicalAgreementByPart": {
    "Born": true,
    "Delta": false,
    "L0": true,
    "L1": true,
    "Regular": true
  },
  "PublishedPythonVsReconstructionWithinTolerance": true,
  "MaximumDirectInteriorRelativeDifference": 3.936281969040938e-15,
  "MaximumCanonicalAbsoluteDifference": 1.2116352070662186e-05,
  "MaximumCanonicalRelativeDifference": 0.21733497173147623
}
```

Tolerance: abs(difference) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local)). A mismatch is reported without changing either input. PDFs/FFs, luminosity, zh/(xi*zeta), and outer convolution are deferred identically. This benchmark does not establish which calculation causes a discrepancy.

Kinematics, 60-digit evaluations, source hashes and all numerical rows are saved in s01_result.json, bigtmd_fhat_benchmarks.json and bigtmd_minus_local.json.
