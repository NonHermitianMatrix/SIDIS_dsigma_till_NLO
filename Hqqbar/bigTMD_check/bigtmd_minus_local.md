# Hqqbar BigTMD channel-5A consistency check

Signed difference: **BigTMD minus local**.

The comparison is charge-stripped, case A, and regular-only. The pinned driver excludes channel 5 from its active loop and applies delta/plus terms only for channels below 4.

| Benchmark | F hat | Local | BigTMD | BigTMD-local | Relative | Close |
|---|---|---:|---:|---:|---:|:---:|
| interior_1 | F1Hat | -7.134229707099e-07 | -2.488208604529e-06 | -1.774785633819e-06 | 7.13278e-01 | False |
| interior_1 | F2Hat | -1.904875438442e-06 | -3.244985957771e-06 | -1.340110519329e-06 | 4.12979e-01 | False |
| interior_2 | F1Hat | -6.206238153227e-07 | -1.537135532350e-06 | -9.165117170275e-07 | 5.96247e-01 | False |
| interior_2 | F2Hat | -1.061040580308e-06 | -1.828375427995e-06 | -7.673348476873e-07 | 4.19681e-01 | False |
| interior_3 | F1Hat | -6.352056562428e-07 | -1.495727547579e-06 | -8.605218913362e-07 | 5.75320e-01 | False |
| interior_3 | F2Hat | -5.833550417308e-07 | -5.553311875081e-07 | 2.802385422276e-08 | 4.80391e-02 | False |

Endpoint and subtraction fields are exactly zero locally and zero under the driver selection: `True`.

All channel-5 B/C generated functions are exact zero: `True`.

Maximum absolute difference: `1.774785633819e-06`.

Maximum relative difference: `7.132784729498e-01`.

All six nontrivial regular coefficients within tolerance: `False`.

Overall tested agreement: `False`.

Tolerance: `abs(diff) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local))`.

BigTMD decimal coefficients were executed as written; the local inputs remained exact until final benchmark evaluation.
