# Hqq_v2 BigTMD channel-2 consistency check

Signed difference: **BigTMD minus local**.

Channel-2 cases A, B, and C are combined with the weights produced by the pinned driver for one incoming/fragmenting up quark and four active flavors.

Driver-derived case weights: `{"A": 0.4444444444444444, "B": 0.0, "C": 0.6666666666666666}`.

| Benchmark | Observable | F hat | Local | BigTMD | BigTMD-local | Relative | Close |
|---|---|---|---:|---:|---:|---:|:---:|
| interior_1 | Delta | F1Hat | 1.007491645319e-02 | -4.515123185089e-05 | -1.012006768504e-02 | 1.00448e+00 | False |
| interior_1 | Delta | F2Hat | 8.328087687700e-03 | -3.533244531378e-05 | -8.363420133013e-03 | 1.00424e+00 | False |
| interior_1 | Plus0 | F1Hat | 1.489623696946e-03 | -2.963284427576e-04 | -1.785952139704e-03 | 1.19893e+00 | False |
| interior_1 | Plus0 | F2Hat | 1.207743966019e-03 | -2.402545619260e-04 | -1.447998527945e-03 | 1.19893e+00 | False |
| interior_1 | Plus1 | F1Hat | 5.103951014118e-03 | 7.465722599900e-05 | -5.029293788119e-03 | 9.85373e-01 | False |
| interior_1 | Plus1 | F2Hat | 4.138136398337e-03 | 6.052992737075e-05 | -4.077606470966e-03 | 9.85373e-01 | False |
| interior_1 | Ordinary | F1Hat | -2.882496167245e-04 | -2.040948886647e-05 | 2.678401278580e-04 | 9.29195e-01 | False |
| interior_1 | Ordinary | F2Hat | -2.213842737268e-04 | -1.762794789495e-05 | 2.037563258318e-04 | 9.20374e-01 | False |
| interior_2 | Delta | F1Hat | 3.134174856823e-02 | -8.508849870743e-05 | -3.142683706694e-02 | 1.00271e+00 | False |
| interior_2 | Delta | F2Hat | 1.690973167732e-02 | -4.485950003667e-05 | -1.695459117735e-02 | 1.00265e+00 | False |
| interior_2 | Plus0 | F1Hat | -9.715553530449e-04 | -2.897118612406e-04 | 6.818434918043e-04 | 7.01806e-01 | False |
| interior_2 | Plus0 | F2Hat | -5.196938933841e-04 | -1.549695389657e-04 | 3.647243544183e-04 | 7.01806e-01 | False |
| interior_2 | Plus1 | F1Hat | 1.023399402083e-02 | 6.684034677895e-05 | -1.016715367405e-02 | 9.93469e-01 | False |
| interior_2 | Plus1 | F2Hat | 5.474257520051e-03 | 3.575351619278e-05 | -5.438504003858e-03 | 9.93469e-01 | False |
| interior_2 | Ordinary | F1Hat | 5.930270477605e-06 | -9.439880498812e-06 | -1.537015097642e-05 | 1.62821e+00 | False |
| interior_2 | Ordinary | F2Hat | 4.389164076645e-05 | -5.433470134713e-06 | -4.932511090117e-05 | 1.12379e+00 | False |
| interior_3 | Delta | F1Hat | 3.024783379219e-02 | -1.927141968123e-04 | -3.044054798901e-02 | 1.00637e+00 | False |
| interior_3 | Delta | F2Hat | 2.468803146438e-02 | -1.552048320307e-04 | -2.484323629641e-02 | 1.00629e+00 | False |
| interior_3 | Plus0 | F1Hat | -5.579509580322e-03 | -4.093482535368e-04 | 5.170161326785e-03 | 9.26634e-01 | False |
| interior_3 | Plus0 | F2Hat | -4.521236871363e-03 | -3.317066473809e-04 | 4.189530223982e-03 | 9.26634e-01 | False |
| interior_3 | Plus1 | F1Hat | 1.307879782434e-02 | 8.804131542290e-05 | -1.299075650891e-02 | 9.93268e-01 | False |
| interior_3 | Plus1 | F2Hat | 1.059812553509e-02 | 7.134240664195e-05 | -1.052678312845e-02 | 9.93268e-01 | False |
| interior_3 | Ordinary | F1Hat | 2.867517588351e-04 | -3.564308972260e-05 | -3.223948485577e-04 | 1.12430e+00 | False |
| interior_3 | Ordinary | F2Hat | 2.663485511085e-04 | -2.848472329711e-05 | -2.948332744057e-04 | 1.10695e+00 | False |

Maximum absolute difference: `3.142683706694e-02`.

Maximum relative difference: `1.628214570974e+00`.

All 24 coefficients within tolerance: `False`.

Tolerance: `abs(diff) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local))`.

The local expressions remained exact through rational substitution; BigTMD decimal expressions were executed as written.
