# Hqg macro chain

Run `s01` through `s19` in order. Hgq's gauge-validated real trace is first
generated and then relabelled for Hqg. The remaining stages perform endpoint
algebra, virtual relabelling/renormalization, counterterms, C1/C2, R5 mapping,
and separate regular/distribution F-hat assembly.

- Required gates are embedded in the trace code, `s14_Hqg_C1_exact.py`, and
  `s15_stage2_poles.wls`.
- `output/` contains the accepted distribution `.m` files, regular `.mx`
  container, mapped R5 `.mx` inputs, and generated R1 algebra.
- `check_macros/` holds exact-map, export-roundtrip, regression, and promotion
  checks only.

The regular `.mx` is preserved byte-for-byte; do not numerically convert it.

