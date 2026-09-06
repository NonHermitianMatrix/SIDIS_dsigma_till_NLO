# Hgq F-hat numerical comparison

Incoming gluon, observed quark; BigTMD channel **1A**. Signed difference: **BigTMD − local**.

Three deterministic benchmarks evaluate the accepted Hgq inputs. Settings: g_s=1, eq=1, SU(3), mu=Q, nf=4. All dependent kinematics and weights were calculated by Wolfram from the defining relations and accepted Hgq projectors.

## Direct published-Python comparison

These are ordinary NLO densities at s23>0: regular plus both ordinary plus kernels, including the zeta-to-s23 Jacobian on both sides. The pinned Python decimal functions are executed as written. Endpoint distributions are not evaluated pointwise.

| Benchmark | F hat | Local | BigTMD | BigTMD − local | Relative difference | Close |
| --- | --- | --- | --- | --- | --- | --- |
| interior_1 | F1 | -1.169773139788e-05 | -1.169773139788e-05 | -1.524659305058e-20 | 1.30338e-15 | True |
| interior_1 | F2 | -1.613602832869e-05 | -1.613602832869e-05 | -4.065758146821e-20 | 2.51968e-15 | True |
| interior_2 | F1 | -7.649774559546e-06 | -7.649774559546e-06 | -5.082197683526e-21 | 6.64359e-16 | True |
| interior_2 | F2 | -6.011258591290e-06 | -6.011258591290e-06 | -1.355252715607e-20 | 2.25452e-15 | True |
| interior_3 | F1 | -1.154261822480e-05 | -1.154261822480e-05 | -1.118083490376e-19 | 9.68657e-15 | True |
| interior_3 | F2 | -9.284816494636e-06 | -9.284816494636e-06 | -2.388632911257e-19 | 2.57262e-14 | True |

## Canonical coefficient comparison

These coefficients use delta(s23), L0=[1/s23]_+, L1=[Log(s23/B)/s23]_+, and Regular on [0,B], at fixed xhat,Q,qT2,zH. Born is the LO delta coefficient; Delta is NLO only. Both t(s23) and the Jacobian are transported through the plus action. The author column uses tool-evaluated endpoints and rational reconstruction of long decimals with denominator at most 10^6. It is distinct from direct execution above.

| Benchmark | F hat | Coefficient | Local | BigTMD | BigTMD − local | Relative difference | Close |
| --- | --- | --- | --- | --- | --- | --- | --- |
| interior_1 | F1 | Born | 2.867442435013e-04 | 2.867442435013e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F1 | Delta | 1.003676229723e-06 | 1.003676229723e-06 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F1 | L0 | 2.838299272127e-05 | 2.838299272127e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F1 | L1 | 5.326432128266e-05 | 5.326432128266e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F1 | Regular | -8.612331424282e-06 | -8.612331424282e-06 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | Born | 2.997927992138e-04 | 2.997927992138e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | Delta | -4.196466450062e-06 | -4.196466450062e-06 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | L0 | 2.967458643311e-05 | 2.967458643311e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | L1 | 5.568816231696e-05 | 5.568816231696e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_1 | F2 | Regular | -1.291022444337e-05 | -1.291022444337e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | Born | 3.926713240073e-04 | 3.926713240073e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | Delta | 5.180196433916e-05 | 5.180196433916e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | L0 | 8.955661130101e-05 | 8.955661130101e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | L1 | 7.294085943984e-05 | 7.294085943984e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F1 | Regular | -8.639901598433e-06 | -8.639901598433e-06 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | Born | 2.255151291716e-04 | 2.255151291716e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | Delta | 2.752446566239e-05 | 2.752446566239e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | L0 | 5.143327136703e-05 | 5.143327136703e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | L1 | 4.189067633102e-05 | 4.189067633102e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_2 | F2 | Regular | -6.579898605010e-06 | -6.579898605010e-06 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | Born | 3.361312647416e-04 | 3.361312647416e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | Delta | 1.848398752825e-05 | 1.848398752825e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | L0 | 6.592724495407e-05 | 6.592724495407e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | L1 | 6.243823227183e-05 | 6.243823227183e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F1 | Regular | -1.320231670861e-05 | -1.320231670861e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | Born | 3.044231967751e-04 | 3.044231967751e-04 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | Delta | 1.327031872605e-05 | 1.327031872605e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | L0 | 5.970816989880e-05 | 5.970816989880e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | L1 | 5.654828414663e-05 | 5.654828414663e-05 | 0.000000000000e+00 | 0.00000e+00 | True |
| interior_3 | F2 | Regular | -1.078795164189e-05 | -1.078795164189e-05 | 0.000000000000e+00 | 0.00000e+00 | True |

## Result

```json
{
  "DirectInteriorCount": 6,
  "CanonicalCoefficientCount": 30,
  "AllDirectInteriorWithinTolerance": true,
  "AllCanonicalCoefficientsWithinTolerance": true,
  "CanonicalAgreementByPart": {
    "Born": true,
    "Delta": true,
    "L0": true,
    "L1": true,
    "Regular": true
  },
  "PublishedPythonVsReconstructionWithinTolerance": true,
  "MaximumDirectInteriorRelativeDifference": 2.5726226389472912e-14,
  "MaximumCanonicalAbsoluteDifference": 0.0,
  "MaximumCanonicalRelativeDifference": 0.0
}
```

Tolerance: abs(difference) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local)). A mismatch is reported without changing either input. PDFs/FFs, luminosity, zh/(xi*zeta), and outer convolution are deferred identically. This benchmark does not establish which calculation causes a discrepancy.

Kinematics, 60-digit evaluations, source hashes and all numerical rows are saved in s01_result.json, s02_result.json and s03_result.json.
