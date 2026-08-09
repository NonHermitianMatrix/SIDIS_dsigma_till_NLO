# Hgg macro chain

This folder uses the corrected exact SymPy chain frozen in `verified/Hgg`.
Run `s01` through `s08`: gauge-validated Hgq parent trace, Hgg relabelling,
exact R4 endpoint cancellation, R5 reduction, F1/F2 projection, and export.

- Hgg has no virtual partner.
- The R4 and R5 scripts contain the exact pole gates used for admission.
- `output/` includes the accepted R4 zeros, R5 projection pickles, assembled
  pickle, separate F1hat/F2hat expressions, audit records, and terminal logs.
- `check_macros/` contains R1, compact-R3, and export audits.

The failed historical Mathematica Hgg chain is not included.

