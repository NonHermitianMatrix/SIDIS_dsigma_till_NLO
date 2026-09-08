# Hqq_v4 BigTMD check

The numerical comparison completed.

Overall agreement: **PASS**.

Tolerance: abs(BigTMD - local) <= 1e-14 + 1e-9 * max(abs(BigTMD), abs(local)).

| Comparison | Passed / total | Largest absolute difference | Largest relative difference |
|---|---:|---:|---:|
| Coefficients | 120 / 120 | 1.839943e-80 | 3.1125514e-78 |
| DirectReconstructed | 24 / 24 | 0 | 0 |
| DirectPublishedDecimals | 24 / 24 | 1.9216557e-16 | 6.4344018e-14 |
| PublishedMinusReconstructed | 24 / 24 | 1.9216557e-16 | 6.4344018e-14 |

The coefficient comparison includes LO delta and NLO delta, L0, L1 and regular terms.
Both F hats, both signs of s+t, and the driver's active up/down flavor weights are covered.
Tests use the driver's nf=4, SU(3), mu=Q and alphaS=1/5. They do not test the coordinate boundary.
The coefficients use the saved [Log[s23/B]^n/s23]+ convention at fixed s and t on [0,B].

Endpoint limits use the declared short-rational reconstruction of the authors' printed constants.
The separate published-decimal comparison evaluates the unrounded source tokens at 80-digit precision
for ordinary interior values. It uses mpmath log/sqrt/polylog, not the repository's truncated polylog series.
No normalization was fitted and no production result was changed.

Measured peak RSS in bytes: {"s01": 84525056, "s02": 502431744, "s02_numerical_job_14691692": 3087552512, "s03_process_before_export": 91656192}. No memory guard was triggered.

Reference: [JeffersonLab/BigTMD, pinned source](https://github.com/JeffersonLab/BigTMD/tree/6e97635d21a63b7975b2e7f5891edc0c35c4dc0c).
The complete numbers, signed differences, exact benchmark inputs and input hashes are in s03_result.json.

| Point | Branch | Q | s | t | s23 | B |
|---|---:|---:|---:|---:|---:|---:|
| q1_positive | 1 | 2 | 16 | -26/17 | 2 | 8 |
| q1_negative | -1 | 2 | 6 | -151/22 | 3/4 | 3 |
| q2_positive | 1 | 5 | 100 | -925/16 | 25/2 | 50 |
| q2_negative | -1 | 5 | 75/2 | -3775/88 | 75/16 | 75/4 |
| q3_positive | 1 | 10 | 400 | -925/4 | 50 | 200 |
| q3_negative | -1 | 10 | 150 | -3775/22 | 75/4 | 75 |
