# MadGraph comparison

All checks pass: **True**.

Fresh MadGraph version = 3.7.0: 8 diagrams; 6 spacelike-photon points, 12 contractions.

Maximum relative difference: `1.4580247060443812e-15`.
Maximum normalized squared Ward residual: `1.3788630105079316e-32`.

| Point | Contraction | Local | MadGraph | Relative difference |
|---:|:---|---:|---:|---:|
| 1 | g | -0.745847836107656 | -0.745847836107656 | 0.000e+00 |
| 1 | pp | 9.58357851445207 | 9.58357851445207 | 0.000e+00 |
| 2 | g | -1.7180339631812 | -1.7180339631812 | 5.170e-16 |
| 2 | pp | 26.5946832301879 | 26.5946832301879 | 2.672e-16 |
| 3 | g | -1.52291387110605 | -1.52291387110605 | 1.458e-15 |
| 3 | pp | 546.347409558774 | 546.347409558774 | 2.081e-16 |
| 4 | g | -4.71983382216934 | -4.71983382216935 | 1.882e-16 |
| 4 | pp | 94.4226826852964 | 94.4226826852964 | 1.505e-16 |
| 5 | g | -7.37103009505866 | -7.37103009505866 | 4.820e-16 |
| 5 | pp | 211.192790043625 | 211.192790043625 | 1.346e-16 |
| 6 | g | -4.7431961379618 | -4.7431961379618 | 7.490e-16 |
| 6 | pp | 691.459055796501 | 691.459055796501 | 3.288e-16 |

This checks the unintegrated tree-level current tensor in four dimensions.
The symbolic phase-space integration and MSbar subtraction are covered by
the production checks and the separate BigTMD comparison.

The photon polarization is explicit; no photon spin average is applied.
The generated photon-helicity multiplicity cancels its average in SMATRIX.
The generated quark spin/color average is checked directly. The spectator
symmetry weight is removed to match the unweighted production square. The common
coupling factor is read from the initialized MadGraph model and divided out
to compare with the saved expression at eq = gs = 1 and Nc = 3.

Production hats SHA256: `ce6cada31c35bb582fc4f309538bf9058781164d489861d0b889ba4ddcf32edd`.
