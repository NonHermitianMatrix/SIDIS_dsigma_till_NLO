# Hqqbar comparison with BigTMD

The symbolic production result is frozen before reference coefficients are
downloaded. The reference is JeffersonLab/BigTMD commit
6e97635d21a63b7975b2e7f5891edc0c35c4dc0c, channel 5A.

Run s01_prepare_reference.py, s02_benchmarks.wls with Wolfram Engine 15,
and s03_compare.py. The comparison evaluates the completed local hats at
60 digits and the published coefficient functions with their original
Python decimal literals. It records signed differences at 18 physical
points covering both signs and zero s+t, two recoil values and three scales.

The first stage reads the flavour mapping and dispatcher from the pinned
driver. The second stage checks the endpoints of the supplied plus
coefficients before treating them as ordinary finite densities. The third
stage compares regular-only and complete coefficient representations.
The public driver excludes channel 5 from its NLO loop; the coefficient
comparison is performed directly and does not claim the driver includes it.

Reference coefficients are never inputs to the production calculation.

Executed result: 36/36 complete ordinary coefficient comparisons passed, with maximum relative difference 6.2624673039599742e-13. All four published plus-coefficient endpoints vanished exactly. The accepted production SHA256 is `ce6cada31c35bb582fc4f309538bf9058781164d489861d0b889ba4ddcf32edd`. `s03_result.json` retains the regular-only discrepancies and the dispatcher omission; `coefficient_agreement` is true.
