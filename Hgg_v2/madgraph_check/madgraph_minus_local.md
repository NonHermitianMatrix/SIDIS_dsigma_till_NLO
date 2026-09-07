# MadGraph comparison

All checks pass: **True**.

Fresh MadGraph version = 3.7.0: 8 diagrams; 6 spacelike-photon points, 12 contractions.

Maximum relative difference: `8.7252374229563941e-16`.
Maximum normalized squared Ward residual: `1.5113150621836690e-32`.

| Point | Contraction | Local | MadGraph | Relative difference |
|---:|:---|---:|---:|---:|
| 1 | g | -34.6744887476358 | -34.6744887476358 | 4.098e-16 |
| 1 | pp | 2656.70782528148 | 2656.70782528148 | 5.135e-16 |
| 2 | g | -6.38597304035577 | -6.38597304035577 | 4.172e-16 |
| 2 | pp | 545.517680509889 | 545.517680509889 | 2.084e-16 |
| 3 | g | -8.42244891096761 | -8.42244891096761 | 0.000e+00 |
| 3 | pp | 1796.66115381692 | 1796.66115381692 | 3.797e-16 |
| 4 | g | -1.30426536303459 | -1.3042653630346 | 6.810e-16 |
| 4 | pp | 48.8612081012698 | 48.8612081012699 | 8.725e-16 |
| 5 | g | -1.32454080488314 | -1.32454080488314 | 0.000e+00 |
| 5 | pp | 38.8372279247224 | 38.8372279247224 | 1.830e-16 |
| 6 | g | -2.0985856646873 | -2.0985856646873 | 0.000e+00 |
| 6 | pp | 110.696864948397 | 110.696864948397 | 3.851e-16 |

This checks the unintegrated tree-level current tensor in four dimensions.
The symbolic phase-space integration and MSbar subtraction are covered by
the production checks and the separate BigTMD comparison.

The photon polarization is explicit; no photon spin average is applied.
The generated photon-helicity multiplicity cancels its average in SMATRIX.
The generated gluon spin/color average is checked directly. The common
coupling factor is read from the initialized MadGraph model and divided out
to compare with the saved expression at eq = gs = 1 and Nc = 3.

Production hats SHA256: `85a5cd93f6fda886884f1de799a71081fe96933a5172894613f69e6f0e1c5d58`.
