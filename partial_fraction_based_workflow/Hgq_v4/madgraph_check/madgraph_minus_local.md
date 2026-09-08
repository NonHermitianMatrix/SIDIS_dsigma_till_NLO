# Hgq MadGraph tree comparison

Incoming gluon, observed quark. Fresh photon-only Born e- g -> e- u ubar and real e- g -> e- u ubar g processes are compared with accepted Hgq_v4 S02/S03.

This checks spin/color-averaged tree Pg/Ppp. It does not test virtual integration, factorization or the complete NLO hard part.

MadGraph RAMBO supplies deterministic physical points. SymPy derives the lepton mass-shell map and exact azimuth quadrature; two lepton settings reconstruct Pg/Ppp. Generated helicities, species, IDEN, couplings and charges fix normalization.

| Point | Projection | Local | MadGraph | MadGraph minus local | Relative difference | Close |
|---|---|---:|---:|---:|---:|:---:|
| born_01 | Pg | -2.655912055530e-09 | -2.655912055530e-09 | -9.926167350636e-24 | 3.73739e-15 | True |
| born_01 | Ppp | 1.049899892681e-05 | 1.049899892681e-05 | -2.879912020665e-20 | 2.74303e-15 | True |
| born_02 | Pg | -7.651793038408e-10 | -7.651793038408e-10 | -7.961613395823e-24 | 1.04049e-14 | True |
| born_02 | Ppp | 1.646130372735e-07 | 1.646130372735e-07 | -1.064085139988e-20 | 6.46416e-14 | True |
| born_03 | Pg | -4.311903053613e-08 | -4.311903053613e-08 | -1.369811094388e-21 | 3.17681e-14 | True |
| born_03 | Ppp | 1.698944305949e-06 | 1.698944305948e-06 | -5.442186686109e-19 | 3.20328e-13 | True |
| born_04 | Pg | -4.643262427116e-09 | -4.643262427116e-09 | 6.617444900424e-24 | 1.42517e-15 | True |
| born_04 | Ppp | 1.671075558044e-08 | 1.671075558043e-08 | -7.844980929453e-21 | 4.69457e-13 | True |
| born_05 | Pg | -5.119562807860e-09 | -5.119562807861e-09 | -1.068717351419e-21 | 2.08752e-13 | True |
| born_05 | Ppp | 3.523046600970e-07 | 3.523046600968e-07 | -2.216579343846e-19 | 6.29165e-13 | True |
| born_06 | Pg | -1.244727699562e-10 | -1.244727699562e-10 | -5.945360652725e-25 | 4.77643e-15 | True |
| born_06 | Ppp | 1.521016192295e-06 | 1.521016192295e-06 | 8.470329472543e-22 | 5.56886e-16 | True |
| born_07 | Pg | -4.463208125453e-10 | -4.463208125454e-10 | -1.160637796988e-22 | 2.60046e-13 | True |
| born_07 | Ppp | 9.628579382657e-06 | 9.628579382657e-06 | -1.101142831431e-19 | 1.14362e-14 | True |
| born_08 | Pg | -3.078307337405e-09 | -3.078307337405e-09 | 1.488925102595e-23 | 4.83683e-15 | True |
| born_08 | Ppp | 2.120638917804e-07 | 2.120638917804e-07 | 5.823351512373e-22 | 2.74604e-15 | True |
| real_01 | Pg | 2.766894563018e-10 | -2.766894563017e-10 | -5.533789126034e-10 | 2.00000e+00 | False |
| real_01 | Ppp | -3.882764714605e-07 | 3.882764714605e-07 | 7.765529429210e-07 | 2.00000e+00 | False |
| real_02 | Pg | 2.290369854832e-09 | -2.290369854831e-09 | -4.580739709663e-09 | 2.00000e+00 | False |
| real_02 | Ppp | -1.125904250031e-06 | 1.125904250028e-06 | 2.251808500059e-06 | 2.00000e+00 | False |
| real_03 | Pg | 5.176663717863e-10 | -5.176663717863e-10 | -1.035332743573e-09 | 2.00000e+00 | False |
| real_03 | Ppp | -3.106932869204e-06 | 3.106932869204e-06 | 6.213865738408e-06 | 2.00000e+00 | False |
| real_04 | Pg | 1.281690519936e-10 | -1.281690519936e-10 | -2.563381039872e-10 | 2.00000e+00 | False |
| real_04 | Ppp | -3.194650171491e-08 | 3.194650171492e-08 | 6.389300342983e-08 | 2.00000e+00 | False |
| real_05 | Pg | 1.100101320557e-10 | -1.100101320557e-10 | -2.200202641115e-10 | 2.00000e+00 | False |
| real_05 | Ppp | -7.528905779660e-08 | 7.528905779660e-08 | 1.505781155932e-07 | 2.00000e+00 | False |
| real_06 | Pg | 9.166449383404e-10 | -9.166449383403e-10 | -1.833289876681e-09 | 2.00000e+00 | False |
| real_06 | Ppp | -1.775315875470e-06 | 1.775315875470e-06 | 3.550631750941e-06 | 2.00000e+00 | False |
| real_07 | Pg | 6.094077796064e-10 | -6.094077796065e-10 | -1.218815559213e-09 | 2.00000e+00 | False |
| real_07 | Ppp | -2.401875936717e-06 | 2.401875936717e-06 | 4.803751873434e-06 | 2.00000e+00 | False |
| real_08 | Pg | 1.240597296223e-09 | -1.240597296223e-09 | -2.481194592446e-09 | 2.00000e+00 | False |
| real_08 | Ppp | -1.756294654223e-06 | 1.756294654232e-06 | 3.512589308456e-06 | 2.00000e+00 | False |

```json
{
  "PhysicalPoints": 16,
  "ProjectionComparisons": 32,
  "AllProjectorsWithinTolerance": false,
  "AllAzimuthAveragesWithinTolerance": false,
  "MaximumProjectorRelativeDifference": 1.9999999999999951,
  "MaximumAzimuthAverageRelativeDifference": 1.9999999999999982,
  "ByProcess": {
    "born": {
      "Count": 16,
      "AllWithinTolerance": true,
      "MaximumRelativeDifference": 6.291654908100499e-13
    },
    "real": {
      "Count": 16,
      "AllWithinTolerance": false,
      "MaximumRelativeDifference": 1.9999999999999951
    }
  }
}
```

Tolerance: abs(difference) <= 1e-25 + 1e-8*max(abs(MadGraph),abs(local)). All per-orientation values, normalization factors, input hashes and projector solves are retained in s03_result.json and s04_result.json. A mismatch is reported without tuning either input.
