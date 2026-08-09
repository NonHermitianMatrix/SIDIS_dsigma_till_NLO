# Hgq macro chain

Run `s01` through `s18` in numerical order. The chain covers kinematics and
LO traces, the Hgq real trace, R2/R3/R4 endpoint algebra, the crossed and
renormalized virtual contribution, mass-factorization counterterms, C1/C2,
R5 regular-sector construction and both F-hat projectors.

- Required physics gates: `s13_Hgq_C1_catani.py` and
  `s14_Hgq_C2_gate.py`.
- `s17` assembles the exact regular sector; `s18` assembles the distribution
  sectors without mixing them.
- `output/` contains the accepted distribution F-hats, regular F-hat pickle,
  mapped R5 projections, and generated R1 algebra.
- `check_macros/` contains crossing, R3/R4, beta0, and regression checks. They
  validate the chain but do not produce the accepted hard functions.

Use `SOURCE_MANIFEST.json` to restore original paths in a disposable repo and
to verify every copied byte.

