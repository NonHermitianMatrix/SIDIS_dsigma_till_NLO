# Hqg numerical BigTMD comparison

The user requested a numerical comparison modelled on Hqqprime. Only its
benchmark seeds, settings and report format are reused. Hqg physics inputs
are the independent frozen ../s12_result.wl and pinned BigTMD channel 3A
under ../comparison/. The accepted ../s13_result.wl supplies the verified
variable and distribution maps. No independent coefficient is changed.

## Contract

S01 evaluates the saved local hats and canonical authors coefficients at
exact rational benchmark inputs, using Wolfram arbitrary-precision arithmetic
and checking physical support, finiteness, precision and input identities.
Delta and plus objects are compared through their coefficients, never as
ordinary pointwise functions. The report must specify its distribution basis
and apply any variable-change Jacobian consistently.

S02 evaluates the pinned decimal channel-3A Python functions directly for
the ordinary interior density and reports BigTMD minus local, with the
Hqqprime tolerance 1e-10 + 1e-7*max(abs(BigTMD),abs(local)). It also reports
the S01 coefficient comparisons, labelling the author rational-reconstruction
assumption separately from execution of the published decimals.

The three Hqqprime benchmark seeds use unit couplings, SU(3), mu=Q, nf=4.
Dependent invariants and coupling conversion must be calculated by the tools.
All runs are serial with address-space and per-operation limits and a
persistent inline RSS/available-RAM monitor. scripts/progress.md is the only
live progress record. Numerical disagreement is an output, not a reason to
adjust either calculation.

## Numerical representation

At fixed xhat, Q, qT2 and zH, S01 solves zeta(s23)=1 for B and
differentiates zeta for the Jacobian J. It evaluates the saved invariant
coefficients at t(s23) and at the physical endpoint t(0). The canonical
coefficient-times-plus identity is derived from the arbitrary-test action
inside the program; the recoil dependence of both J and t contributes to
the ordinary remainder. The reported basis is delta(s23), L0, L1 and
Regular, where Ln=[Log[s23/B]^n/s23]_+ on [0,B]. Born is reported separately.
The remaining luminosity, zh/(xi*zeta), PDFs/FFs and outer integration are
deferred identically on both sides, as in the Hqqprime benchmark.

The direct published-Python comparison uses the ordinary NLO density on
s23>0, including regular and both plus-kernel terms. It is not a pointwise
evaluation of an endpoint distribution. The canonical coefficient table
uses the corrected exact author endpoints and S13 rational reconstruction;
this distinction remains explicit in the outputs.

Programs: s01_export_fhat_benchmarks.wl and s02_compare_bigtmd_fhat.py.
Outputs: s01_result.json, bigtmd_fhat_benchmarks.json,
bigtmd_minus_local.json and bigtmd_minus_local.md. Each program writes
atomically, checks coverage/finiteness and leaves the frozen inputs unchanged.

## Accepted numerical comparison

Both production stages exited zero with their embedded gates satisfied.
S01 evaluated the saved independent Hqg hats and corrected canonical author
coefficients at 60-digit requested precision; its minimum retained precision
was 60 digits. S02 executed only the pinned channel-3A Pg/Ppp
Python functions. Published-Python interior values and the reconstruction
agree within the declared benchmark tolerance.

All 6 direct ordinary NLO density comparisons agree within tolerance;
the largest relative difference is 3.9362819690409382e-15. Of the 30 canonical
coefficient comparisons, every Born, L0, L1 and Regular value agrees; all NLO
Delta rows differ. This reproduces the S13 discrepancy numerically without
changing an independent coefficient. The discrepancy does not identify
which calculation is responsible.

The three requested benchmark seeds sample positive s+t at the interior and
physical endpoint, as measured by S01; this numerical table does not claim
coverage of the other coordinate branch. The prior symbolic S13 comparison
covers both open branches. The canonical coefficient table includes the
physical Jacobian and coefficient-times-plus transport described above.

The persistent monitor sampled a maximum S01 RSS of 558.5 MiB; no RAM or
inactivity guard triggered. S02 finished before a second one-second RSS
sample. No parallel kernels or disposable test caches were created.
The frozen S12 and accepted comparison input hashes passed before and after
evaluation. No extra reconstruction or production repeat was run.

Accepted source/result/log identities:

| File | SHA256 | Bytes |
|---|---|---:|
| s01_export_fhat_benchmarks.wl | `72305046dca76ea94cdbdc0e755d49e3eb568a3d5a31c480125753cd1c08f454` | 13418 |
| s01_result.json | `082c2caff55242b68e0a2e01a57864e17dbb43cd7794e7a63c54203e2bc4a80f` | 19846 |
| s01_run.log | `e768610bea915666e0a02769098aefd0b90709d1be2f1de855ab63fbec0f24e2` | 22527 |
| s02_compare_bigtmd_fhat.py | `df61d1ee3f8b6a4ec7a1184892d5ed6a36390217abbb78f96eacec4b0b2e4abe` | 11677 |
| s02_run.log | `a98e824e17ce73a6a465c84ceb410c8d546fc7e72ab78feb4150bfd639a16295` | 3260 |
| bigtmd_fhat_benchmarks.json | `26e10ae150a8fc365dd74c7cbba948bec427d0be116a2e68a56af122cda44657` | 3794 |
| bigtmd_minus_local.json | `35250f4794663304ba915c4daa2b07f9a23fc67be89124a2740e48affe437390` | 17918 |
| bigtmd_minus_local.md | `3d8382870b9b3ed6920bb04955bf3bb4036d08f8c534c8bcc87f40acc549e329` | 6398 |
