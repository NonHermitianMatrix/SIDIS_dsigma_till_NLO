# Hqqbar BigTMD comparison

This check compares the supplied Hqqbar coefficient functions directly. The pinned public driver excludes channel 5 from its NLO loop.
All-coefficient comparisons passed: 36/36.
Maximum all-coefficient relative difference: 6.26247e-13.
Maximum regular-only relative difference at its mu=Q choice: 1.61032.

Signed differences are BigTMD minus local. Tolerance: 1e-10 + 1e-7 times the larger magnitude.
Production remains symbolic. Only this check evaluates numerical points, with local hats first evaluated at 60 digits.
This establishes numerical agreement at the listed points, not a general symbolic equality proof against the published decimal functions.
The points cover positive, negative, and zero s+t, three positive scale choices, and both unit and nonunit recoil mass squared.
The regular_only rows test the regular coefficient in isolation. The literal driver supplies mu=Q to the coefficient functions; the other two scales exercise the published functions directly.

Direct published Python decimal arithmetic; no rational reconstruction or coefficient fitting. JIT decorators removed; scalar numpy log/sqrt/pi use Python math equivalents.

The pinned driver excludes channel 5 from its NLO loop. This check calls its channel-5 coefficient functions directly. Wolfram verifies their plus-coefficient endpoints before the complete ordinary density is assembled. The production result is unchanged.

Reference: [pinned BigTMD source](https://github.com/JeffersonLab/BigTMD/tree/6e97635d21a63b7975b2e7f5891edc0c35c4dc0c); [driver selection](https://github.com/JeffersonLab/BigTMD/blob/6e97635d21a63b7975b2e7f5891edc0c35c4dc0c/sidis.py#L231).
Production SHA256: ce6cada31c35bb582fc4f309538bf9058781164d489861d0b889ba4ddcf32edd

| Q2 | s | s23 | t | mu2 | Representation | Hat | BigTMD minus local | Pass |
|---|---|---|---|---|---|---|---|---|
| 4 | 10 | 1 | -3 | 2 | regular_only | F1hat | -0.00482220494 | False |
| 4 | 10 | 1 | -3 | 2 | regular_only | F2hat | -0.00461101783 | False |
| 4 | 10 | 1 | -3 | 2 | all_supplied_coefficients | F1hat | 2.7929048e-16 | True |
| 4 | 10 | 1 | -3 | 2 | all_supplied_coefficients | F2hat | 1.48318857e-16 | True |
| 4 | 10 | 1 | -3 | 4 | regular_only | F1hat | -0.00705327262 | False |
| 4 | 10 | 1 | -3 | 4 | regular_only | F2hat | -0.00521594578 | False |
| 4 | 10 | 1 | -3 | 4 | all_supplied_coefficients | F1hat | 3.56051993e-16 | True |
| 4 | 10 | 1 | -3 | 4 | all_supplied_coefficients | F2hat | 1.91253263e-16 | True |
| 4 | 10 | 1 | -3 | 8 | regular_only | F1hat | -0.00928434029 | False |
| 4 | 10 | 1 | -3 | 8 | regular_only | F2hat | -0.00582087372 | False |
| 4 | 10 | 1 | -3 | 8 | all_supplied_coefficients | F1hat | 3.38271078e-16 | True |
| 4 | 10 | 1 | -3 | 8 | all_supplied_coefficients | F2hat | 1.73472348e-16 | True |
| 4 | 10 | 1.5 | -3 | 2 | regular_only | F1hat | -0.0066566061 | False |
| 4 | 10 | 1.5 | -3 | 2 | regular_only | F2hat | -0.00533335032 | False |
| 4 | 10 | 1.5 | -3 | 2 | all_supplied_coefficients | F1hat | 2.4459601e-16 | True |
| 4 | 10 | 1.5 | -3 | 2 | all_supplied_coefficients | F2hat | 1.37043155e-16 | True |
| 4 | 10 | 1.5 | -3 | 4 | regular_only | F1hat | -0.00910080203 | False |
| 4 | 10 | 1.5 | -3 | 4 | regular_only | F2hat | -0.00555514386 | False |
| 4 | 10 | 1.5 | -3 | 4 | all_supplied_coefficients | F1hat | 2.76796815e-16 | True |
| 4 | 10 | 1.5 | -3 | 4 | all_supplied_coefficients | F2hat | 1.4484941e-16 | True |
| 4 | 10 | 1.5 | -3 | 8 | regular_only | F1hat | -0.011544998 | False |
| 4 | 10 | 1.5 | -3 | 8 | regular_only | F2hat | -0.00577693741 | False |
| 4 | 10 | 1.5 | -3 | 8 | all_supplied_coefficients | F1hat | 3.76434994e-16 | True |
| 4 | 10 | 1.5 | -3 | 8 | all_supplied_coefficients | F2hat | 2.09901541e-16 | True |
| 4 | 10 | 1 | -12 | 2 | regular_only | F1hat | 0.00857637286 | False |
| 4 | 10 | 1 | -12 | 2 | regular_only | F2hat | 0.0225322615 | False |
| 4 | 10 | 1 | -12 | 2 | all_supplied_coefficients | F1hat | 2.77555756e-17 | True |
| 4 | 10 | 1 | -12 | 2 | all_supplied_coefficients | F2hat | -6.9388939e-18 | True |
| 4 | 10 | 1 | -12 | 4 | regular_only | F1hat | 0.010931624 | False |
| 4 | 10 | 1 | -12 | 4 | regular_only | F2hat | 0.0265950682 | False |
| 4 | 10 | 1 | -12 | 4 | all_supplied_coefficients | F1hat | 4.16333634e-17 | True |
| 4 | 10 | 1 | -12 | 4 | all_supplied_coefficients | F2hat | -1.38777878e-17 | True |
| 4 | 10 | 1 | -12 | 8 | regular_only | F1hat | 0.0132868752 | False |
| 4 | 10 | 1 | -12 | 8 | regular_only | F2hat | 0.0306578749 | False |
| 4 | 10 | 1 | -12 | 8 | all_supplied_coefficients | F1hat | 6.9388939e-17 | True |
| 4 | 10 | 1 | -12 | 8 | all_supplied_coefficients | F2hat | 6.9388939e-18 | True |
| 4 | 10 | 1.5 | -12 | 2 | regular_only | F1hat | -0.0099407967 | False |
| 4 | 10 | 1.5 | -12 | 2 | regular_only | F2hat | 0.0141712573 | False |
| 4 | 10 | 1.5 | -12 | 2 | all_supplied_coefficients | F1hat | 1.2490009e-16 | True |
| 4 | 10 | 1.5 | -12 | 2 | all_supplied_coefficients | F2hat | 4.16333634e-17 | True |
| 4 | 10 | 1.5 | -12 | 4 | regular_only | F1hat | -0.00884002542 | False |
| 4 | 10 | 1.5 | -12 | 4 | regular_only | F2hat | 0.0176479869 | False |
| 4 | 10 | 1.5 | -12 | 4 | all_supplied_coefficients | F1hat | 8.32667268e-17 | True |
| 4 | 10 | 1.5 | -12 | 4 | all_supplied_coefficients | F2hat | 2.77555756e-17 | True |
| 4 | 10 | 1.5 | -12 | 8 | regular_only | F1hat | -0.00773925415 | False |
| 4 | 10 | 1.5 | -12 | 8 | regular_only | F2hat | 0.0211247166 | False |
| 4 | 10 | 1.5 | -12 | 8 | all_supplied_coefficients | F1hat | 1.11022302e-16 | True |
| 4 | 10 | 1.5 | -12 | 8 | all_supplied_coefficients | F2hat | 2.77555756e-17 | True |
| 4 | 10 | 1 | -10 | 2 | regular_only | F1hat | 0.00530540539 | False |
| 4 | 10 | 1 | -10 | 2 | regular_only | F2hat | 0.0140586842 | False |
| 4 | 10 | 1 | -10 | 2 | all_supplied_coefficients | F1hat | 5.20417043e-18 | True |
| 4 | 10 | 1 | -10 | 2 | all_supplied_coefficients | F2hat | -1.73472348e-17 | True |
| 4 | 10 | 1 | -10 | 4 | regular_only | F1hat | 0.00705866393 | False |
| 4 | 10 | 1 | -10 | 4 | regular_only | F2hat | 0.0176698677 | False |
| 4 | 10 | 1 | -10 | 4 | all_supplied_coefficients | F1hat | 6.9388939e-18 | True |
| 4 | 10 | 1 | -10 | 4 | all_supplied_coefficients | F2hat | -2.08166817e-17 | True |
| 4 | 10 | 1 | -10 | 8 | regular_only | F1hat | 0.00881192246 | False |
| 4 | 10 | 1 | -10 | 8 | regular_only | F2hat | 0.0212810512 | False |
| 4 | 10 | 1 | -10 | 8 | all_supplied_coefficients | F1hat | 6.9388939e-18 | True |
| 4 | 10 | 1 | -10 | 8 | all_supplied_coefficients | F2hat | -2.08166817e-17 | True |
| 4 | 10 | 1.5 | -10 | 2 | regular_only | F1hat | 0.00221779353 | False |
| 4 | 10 | 1.5 | -10 | 2 | regular_only | F2hat | 0.012379055 | False |
| 4 | 10 | 1.5 | -10 | 2 | all_supplied_coefficients | F1hat | -1.73472348e-17 | True |
| 4 | 10 | 1.5 | -10 | 2 | all_supplied_coefficients | F2hat | -3.46944695e-17 | True |
| 4 | 10 | 1.5 | -10 | 4 | regular_only | F1hat | 0.00369008462 | False |
| 4 | 10 | 1.5 | -10 | 4 | regular_only | F2hat | 0.0159930578 | False |
| 4 | 10 | 1.5 | -10 | 4 | all_supplied_coefficients | F1hat | 6.9388939e-18 | True |
| 4 | 10 | 1.5 | -10 | 4 | all_supplied_coefficients | F2hat | -2.42861287e-17 | True |
| 4 | 10 | 1.5 | -10 | 8 | regular_only | F1hat | 0.0051623757 | False |
| 4 | 10 | 1.5 | -10 | 8 | regular_only | F2hat | 0.0196070607 | False |
| 4 | 10 | 1.5 | -10 | 8 | all_supplied_coefficients | F1hat | -1.04083409e-17 | True |
| 4 | 10 | 1.5 | -10 | 8 | all_supplied_coefficients | F2hat | -3.2959746e-17 | True |
