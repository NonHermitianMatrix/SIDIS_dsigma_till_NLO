# Hqq macro chain

Run `s01` through `s24` in order. This is the clean Hqq2 real/virtual chain,
the accepted August 6/7 C1/C2 gates, accepted R5 regular assembly, optimized
finite four-sector F-hat assembly, and strict provenance validator.

- Real graph groups: qgg, same-flavour pair, and different-flavour pair.
- `s20_Hqq_C1.wls` and `s21_Hqq_C2_final2.wls` are the immutable accepted
  gates; do not replace them with later diagnostic point-gate experiments.
- `s22` constructs the regular sector. `s23` combines all 14 recorded sources
  into delta, plus0, plus1, and regular F1hat/F2hat sectors. `s24` checks all
  source hashes and finite atoms.
- `output/` contains the accepted gate logs, all 14 exact F-hat input sources,
  and the verified final artifact.
- `check_macros/` contains only bounded R3/R4/V2 cross-checks.

No file from the quarantined old-Hqq or rejected F1-attempt trees is present.

