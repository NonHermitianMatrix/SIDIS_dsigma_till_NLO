# Hgg BigTMD comparison

The supplied coefficient functions agree after their vanishing-endpoint plus pieces are included in the ordinary density. The published driver omits these pieces for Hgg and disagrees.
All-coefficient comparisons passed: 36/36.
Maximum all-coefficient relative difference: 8.14023e-13.
Maximum driver-selection relative difference at its mu=Q choice: 0.308435.

Signed differences are BigTMD minus local. Tolerance: 1e-10 + 1e-7 times the larger magnitude.
Production remains symbolic. Only this check evaluates numerical points, with local hats first evaluated at 60 digits.
This establishes numerical agreement at the listed points, not a general symbolic equality proof against the published decimal functions.
The points cover positive, negative, and zero s+t, three positive scale choices, and both unit and nonunit recoil mass squared.
The published_driver rows test the driver's regular-only selection. The literal driver supplies mu=Q to the coefficient functions; the other two scales exercise the published functions directly.

Direct published Python decimal arithmetic; no rational reconstruction or coefficient fitting. JIT decorators removed; scalar numpy log/sqrt/pi use Python math equivalents.

The published driver selects plus only for chn < 4 (sidis.py 231), so it drops the Hgg plus-function pieces. Wolfram proves these coefficients vanish at w=0: their products with the plus distributions are ordinary finite-density contributions. Adding plus1B/w + plus2B*Log[w]/w restores agreement. The original driver discrepancy remains reported. Production was not changed.

Reference: [pinned BigTMD source](https://github.com/JeffersonLab/BigTMD/tree/6e97635d21a63b7975b2e7f5891edc0c35c4dc0c); [driver selection](https://github.com/JeffersonLab/BigTMD/blob/6e97635d21a63b7975b2e7f5891edc0c35c4dc0c/sidis.py#L231).
Production SHA256: 85a5cd93f6fda886884f1de799a71081fe96933a5172894613f69e6f0e1c5d58

| Q2 | s | s23 | t | mu2 | Representation | Hat | BigTMD minus local | Pass |
|---|---|---|---|---|---|---|---|---|
| 4 | 10 | 1 | -3 | 2 | published_driver | F1hat | 0.000657262244 | False |
| 4 | 10 | 1 | -3 | 2 | published_driver | F2hat | 0.00125556347 | False |
| 4 | 10 | 1 | -3 | 2 | all_supplied_coefficients | F1hat | -4.12864187e-16 | True |
| 4 | 10 | 1 | -3 | 2 | all_supplied_coefficients | F2hat | -4.29777741e-16 | True |
| 4 | 10 | 1 | -3 | 4 | published_driver | F1hat | -0.000374281 | False |
| 4 | 10 | 1 | -3 | 4 | published_driver | F2hat | 0.00190202324 | False |
| 4 | 10 | 1 | -3 | 4 | all_supplied_coefficients | F1hat | -4.26741975e-16 | True |
| 4 | 10 | 1 | -3 | 4 | all_supplied_coefficients | F2hat | -4.54497551e-16 | True |
| 4 | 10 | 1 | -3 | 8 | published_driver | F1hat | -0.00140582424 | False |
| 4 | 10 | 1 | -3 | 8 | published_driver | F2hat | 0.00254848301 | False |
| 4 | 10 | 1 | -3 | 8 | all_supplied_coefficients | F1hat | -4.78783679e-16 | True |
| 4 | 10 | 1 | -3 | 8 | all_supplied_coefficients | F2hat | -5.34294831e-16 | True |
| 4 | 10 | 1.5 | -3 | 2 | published_driver | F1hat | 0.000186470062 | False |
| 4 | 10 | 1.5 | -3 | 2 | published_driver | F2hat | 0.00165784019 | False |
| 4 | 10 | 1.5 | -3 | 2 | all_supplied_coefficients | F1hat | -5.26922256e-16 | True |
| 4 | 10 | 1.5 | -3 | 2 | all_supplied_coefficients | F2hat | -5.52075746e-16 | True |
| 4 | 10 | 1.5 | -3 | 4 | published_driver | F1hat | -0.0010490212 | False |
| 4 | 10 | 1.5 | -3 | 4 | published_driver | F2hat | 0.00251604764 | False |
| 4 | 10 | 1.5 | -3 | 4 | all_supplied_coefficients | F1hat | -4.68375339e-16 | True |
| 4 | 10 | 1.5 | -3 | 4 | all_supplied_coefficients | F2hat | -5.41233725e-16 | True |
| 4 | 10 | 1.5 | -3 | 8 | published_driver | F1hat | -0.00228451246 | False |
| 4 | 10 | 1.5 | -3 | 8 | published_driver | F2hat | 0.0033742551 | False |
| 4 | 10 | 1.5 | -3 | 8 | all_supplied_coefficients | F1hat | -5.30825384e-16 | True |
| 4 | 10 | 1.5 | -3 | 8 | all_supplied_coefficients | F2hat | -5.75928194e-16 | True |
| 4 | 10 | 1 | -12 | 2 | published_driver | F1hat | -0.0011976583 | False |
| 4 | 10 | 1 | -12 | 2 | published_driver | F2hat | 0.00379882536 | False |
| 4 | 10 | 1 | -12 | 2 | all_supplied_coefficients | F1hat | -6.52256027e-14 | True |
| 4 | 10 | 1 | -12 | 2 | all_supplied_coefficients | F2hat | -2.3481217e-14 | True |
| 4 | 10 | 1 | -12 | 4 | published_driver | F1hat | -0.000500308842 | False |
| 4 | 10 | 1 | -12 | 4 | published_driver | F2hat | 0.00501320649 | False |
| 4 | 10 | 1 | -12 | 4 | all_supplied_coefficients | F1hat | -6.78346268e-14 | True |
| 4 | 10 | 1 | -12 | 4 | all_supplied_coefficients | F2hat | -2.78110868e-14 | True |
| 4 | 10 | 1 | -12 | 8 | published_driver | F1hat | 0.000197040616 | False |
| 4 | 10 | 1 | -12 | 8 | published_driver | F2hat | 0.00622758763 | False |
| 4 | 10 | 1 | -12 | 8 | all_supplied_coefficients | F1hat | -5.92859095e-14 | True |
| 4 | 10 | 1 | -12 | 8 | all_supplied_coefficients | F2hat | -1.28230759e-14 | True |
| 4 | 10 | 1.5 | -12 | 2 | published_driver | F1hat | -0.0146637967 | False |
| 4 | 10 | 1.5 | -12 | 2 | published_driver | F2hat | -0.00301853132 | False |
| 4 | 10 | 1.5 | -12 | 2 | all_supplied_coefficients | F1hat | -6.89226454e-13 | True |
| 4 | 10 | 1.5 | -12 | 2 | all_supplied_coefficients | F2hat | -4.41979786e-13 | True |
| 4 | 10 | 1.5 | -12 | 4 | published_driver | F1hat | -0.014937152 | False |
| 4 | 10 | 1.5 | -12 | 4 | published_driver | F2hat | -0.00229487043 | False |
| 4 | 10 | 1.5 | -12 | 4 | all_supplied_coefficients | F1hat | -7.28417326e-13 | True |
| 4 | 10 | 1.5 | -12 | 4 | all_supplied_coefficients | F2hat | -5.08038056e-13 | True |
| 4 | 10 | 1.5 | -12 | 8 | published_driver | F1hat | -0.0152105072 | False |
| 4 | 10 | 1.5 | -12 | 8 | published_driver | F2hat | -0.00157120954 | False |
| 4 | 10 | 1.5 | -12 | 8 | all_supplied_coefficients | F1hat | -6.76902978e-13 | True |
| 4 | 10 | 1.5 | -12 | 8 | all_supplied_coefficients | F2hat | -4.1755488e-13 | True |
| 4 | 10 | 1 | -10 | 2 | published_driver | F1hat | -0.000377555004 | False |
| 4 | 10 | 1 | -10 | 2 | published_driver | F2hat | 0.00258408857 | False |
| 4 | 10 | 1 | -10 | 2 | all_supplied_coefficients | F1hat | -2.85882429e-15 | True |
| 4 | 10 | 1 | -10 | 2 | all_supplied_coefficients | F2hat | -1.79717352e-15 | True |
| 4 | 10 | 1 | -10 | 4 | published_driver | F1hat | -3.89341376e-05 | False |
| 4 | 10 | 1 | -10 | 4 | published_driver | F2hat | 0.00361877953 | False |
| 4 | 10 | 1 | -10 | 4 | all_supplied_coefficients | F1hat | -3.06699111e-15 | True |
| 4 | 10 | 1 | -10 | 4 | all_supplied_coefficients | F2hat | -1.99146255e-15 | True |
| 4 | 10 | 1 | -10 | 8 | published_driver | F1hat | 0.000299686728 | False |
| 4 | 10 | 1 | -10 | 8 | published_driver | F2hat | 0.00465347049 | False |
| 4 | 10 | 1 | -10 | 8 | all_supplied_coefficients | F1hat | -3.00887787e-15 | True |
| 4 | 10 | 1 | -10 | 8 | all_supplied_coefficients | F2hat | -1.83533744e-15 | True |
| 4 | 10 | 1.5 | -10 | 2 | published_driver | F1hat | -0.00224112233 | False |
| 4 | 10 | 1.5 | -10 | 2 | published_driver | F2hat | 0.00170630488 | False |
| 4 | 10 | 1.5 | -10 | 2 | all_supplied_coefficients | F1hat | -5.44703171e-15 | True |
| 4 | 10 | 1.5 | -10 | 2 | all_supplied_coefficients | F2hat | -3.77475828e-15 | True |
| 4 | 10 | 1.5 | -10 | 4 | published_driver | F1hat | -0.00215200624 | False |
| 4 | 10 | 1.5 | -10 | 4 | published_driver | F2hat | 0.0026766318 | False |
| 4 | 10 | 1.5 | -10 | 4 | all_supplied_coefficients | F1hat | -5.10008702e-15 | True |
| 4 | 10 | 1.5 | -10 | 4 | all_supplied_coefficients | F2hat | -3.15025783e-15 | True |
| 4 | 10 | 1.5 | -10 | 8 | published_driver | F1hat | -0.00206289015 | False |
| 4 | 10 | 1.5 | -10 | 8 | published_driver | F2hat | 0.00364695873 | False |
| 4 | 10 | 1.5 | -10 | 8 | all_supplied_coefficients | F1hat | -5.07233144e-15 | True |
| 4 | 10 | 1.5 | -10 | 8 | all_supplied_coefficients | F2hat | -3.12250226e-15 | True |
