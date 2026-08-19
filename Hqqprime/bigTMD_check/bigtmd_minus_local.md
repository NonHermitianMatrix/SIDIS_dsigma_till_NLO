# Hqqprime BigTMD channel-6 A/B/C consistency check

Signed difference: **BigTMD minus local**.

The comparison keeps channel-6 charge cases A, B, and C separate and selects only their regular coefficients. The pinned driver includes channel 6 in its active loop and restricts delta/plus assembly to channels below 4.

| Benchmark | Case | Local charge key | F hat | Local | BigTMD | BigTMD-local | Relative | Close |
|---|:---:|---|---|---:|---:|---:|---:|:---:|
| interior_1 | A | IncomingChargeSquared | F1Hat | 5.587858436753e-07 | -2.214568037034e-07 | -7.802426473787e-07 | 1.39632e+00 | False |
| interior_1 | A | IncomingChargeSquared | F2Hat | 4.956652537527e-07 | -1.725926028751e-07 | -6.682578566278e-07 | 1.34820e+00 | False |
| interior_1 | B | MixedIncomingPrimeCharge | F1Hat | -2.780966991293e-07 | -2.780966991293e-07 | -6.352747104407e-22 | 2.28437e-15 | True |
| interior_1 | B | MixedIncomingPrimeCharge | F2Hat | -4.268585259066e-07 | -4.268585259066e-07 | -1.588186776102e-22 | 3.72064e-16 | True |
| interior_1 | C | PrimeChargeSquared | F1Hat | 3.802977813833e-06 | -2.444118969299e-06 | -6.247096783132e-06 | 1.64269e+00 | False |
| interior_1 | C | PrimeChargeSquared | F2Hat | 5.063921124984e-06 | -3.602856864338e-06 | -8.666777989323e-06 | 1.71148e+00 | False |
| interior_2 | A | IncomingChargeSquared | F1Hat | 1.098985986860e-07 | -5.502221247653e-08 | -1.649208111626e-07 | 1.50066e+00 | False |
| interior_2 | A | IncomingChargeSquared | F2Hat | 6.297316255475e-08 | -4.869318366990e-08 | -1.116663462247e-07 | 1.77324e+00 | False |
| interior_2 | B | MixedIncomingPrimeCharge | F1Hat | -2.359206523749e-07 | -2.359206523749e-07 | -2.646977960170e-23 | 1.12198e-16 | True |
| interior_2 | B | MixedIncomingPrimeCharge | F2Hat | -1.679112705892e-07 | -1.679112705892e-07 | 3.970466940255e-22 | 2.36462e-15 | True |
| interior_2 | C | PrimeChargeSquared | F1Hat | 4.115547951275e-06 | -1.639416897155e-06 | -5.754964848431e-06 | 1.39835e+00 | False |
| interior_2 | C | PrimeChargeSquared | F2Hat | 3.333798075821e-06 | -1.912667170879e-06 | -5.246465246701e-06 | 1.57372e+00 | False |
| interior_3 | A | IncomingChargeSquared | F1Hat | 3.506103379557e-07 | -1.200663747487e-07 | -4.706767127044e-07 | 1.34245e+00 | False |
| interior_3 | A | IncomingChargeSquared | F2Hat | 3.172265541370e-07 | -1.388838230806e-07 | -4.561103772175e-07 | 1.43781e+00 | False |
| interior_3 | B | MixedIncomingPrimeCharge | F1Hat | -3.503560194643e-07 | -3.503560194643e-07 | -8.470329472543e-22 | 2.41763e-15 | True |
| interior_3 | B | MixedIncomingPrimeCharge | F2Hat | -4.061649406109e-07 | -4.061649406109e-07 | -4.235164736272e-22 | 1.04272e-15 | True |
| interior_3 | C | PrimeChargeSquared | F1Hat | 2.426768536422e-06 | -1.693584647288e-06 | -4.120353183710e-06 | 1.69788e+00 | False |
| interior_3 | C | PrimeChargeSquared | F2Hat | 2.762950836580e-06 | -8.961634240237e-07 | -3.659114260604e-06 | 1.32435e+00 | False |

Endpoint and phi-zero fields are exactly zero locally and zero under the channel-6 driver selection: `True`.

Maximum absolute difference: `8.666777989323e-06`.

Maximum relative difference: `1.773237069483e+00`.

All 18 nontrivial regular coefficients within tolerance: `False`.

Overall tested agreement: `False`.

Tolerance: `abs(diff) <= 1e-10 + 1e-7*max(abs(BigTMD),abs(local))`.

BigTMD decimal coefficients were executed as written; the local expressions remained exact until final benchmark evaluation.
