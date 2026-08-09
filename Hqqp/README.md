# Hqqp macro chain

Run `s01` through `s10` in order. Cases A, B, and C are traced separately,
then passed through the accepted shared R4/R5 verification and F1/F2 assembly
chain. Hqqp is real-only and has no virtual partner.

- The gauge projection is included in the R1 trace programs.
- `s08_Hqq_R5_verify.wls` is the required exact finiteness gate.
- `output/` contains the accepted separate F1hat/F2hat expressions and the
  convolution statement.
- There are no additional nonessential checks for this frozen channel, so
  `check_macros/` is intentionally empty.

