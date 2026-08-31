# Hgg MadGraph tree-real check

This isolated workflow compares the accepted pre-angular Hgg real-emission
objects with the photon-only process

`e- g -> e- g u u~`.

The local hadronic order is `g(k1),u(k2),ubar(k3)`, with `k1` fragmenting.
Only byte-identical copies of accepted Hgg S01, S06, and S07 sources/results
are mathematical inputs. Parent Hgg artifacts are read-only. S08--S13 and the
BigTMD benchmark are excluded.

The check reuses the pinned MG5_aMC 3.7.0 installation under
`../../Hqqbar/madgraph_check/` without modifying it. Generated PDG order,
diagram count, final-state identity divisor, `IDEN`, and the SMQCD F3 charge
are measured in this workflow. S01--S12 follow the stage map recorded in the
parent Hgg README. S12 is terminal; there is no redundant final validator or
second production sample.

## Current status

S01--S05 are accepted. MG5_aMC generated eight diagrams with PDG order
`{11,21,11,21,2,-2}` and `IDEN=32`; the compiled bridge and the direct
generated routine agree exactly at the deterministic massless point, where
both return `7.443988980863332e-10`. S06 also passed the copied-result schema
inspection for the sole Hgg tensor and its direct `Pg`/`PPP` projections.

With the refreshed physical-projector inputs, S07 is accepted. The copied S06
tensor gives `7.443988980863335e-10`, MadGraph gives
`7.443988980863332e-10`, and the relative difference is
`4.167022956439278e-16`. Copied S07 Pg/PPP match fresh copied-S06 contractions.
Accepted JSON SHA-256 is
`65eaaea96974c808c0a3008e8da97a708b26dd22bbeb4026f6a9467316165871`;
all eight checks are `True`.

## S08 contract

`s08_validate_azimuthal_average.py` consumes only the accepted S07 JSON,
current Hgg bridge, and generated parameter card. It boosts the deterministic
six-momentum point to the hadronic rest frame, rotates only the lepton plane
through four angles separated by `Pi/2` around the incoming-gluon axis, and
calls the Hgg bridge at each angle. The rotations must preserve total
four-momentum, all external masses, photon momentum, and photon virtuality;
the zero angle must reproduce S07 MadGraph and the four-angle average must
match S07's projected local value under the unchanged reference tolerances.
The stage writes only `s08_azimuthal_average_validation.json` atomically and
stops before evaluator or cut-bin construction.

S08 is accepted. Source/log/result SHA-256 values are
`5e300d23b9f562fd27f1a60974b754a4c7018dd48de6b06d88a7a6503ca996ee` /
`39a88b90f21c2e31c698d52183f21a4c616bc1df67afea6129626007e4a6230d` /
`59ac11e6055141c0edc521def89a24c4743dae6e8f3ebb043400e673f4b56fdb`.
The MadGraph four-angle average is `9.15888602533511731e-10`, the S07
projected local value is `9.15888602533510490e-10`, and their relative
difference is `1.35471815611346966e-15`; all eight checks are true.

## S09 contract

`s09_build_four_dimensional_evaluator.wl` consumes the copied accepted S07
Pg/PPP pair plus accepted S07/S08 JSON and parameter card. It must derive all
scalar products from the six current invariant definitions with Wolfram
`Solve`, map every propagator momentum generically, then set `D=4`, SU(3),
`ScaleMu=1`, `EL=1`, and `g_s=1`. It compiles exactly the single physical Hgg
Pg/PPP pair to a WVM evaluator and must reconstruct the accepted S07 physical
Pg/PPP benchmark after applying the current parameter-card couplings. It
atomically writes only `s09_four_dimensional_physical_projections`.

S09 is accepted. Source/log/result SHA-256 values are
`50a9fce7f5febc3a8c4e8b2aaeadc46b674a2d8517a09b25c3050bf861b87a34` /
`1bb5ea3db3e45de684f254b7dc3a7f70a65369824edcf3302ed7693a65cb7bc7` /
`8d34213d140d7bd8d3df3f5594a351ad864d3bceb937a3a92243b3d7ee28e32c`.
Unit-coupling leaf counts are Pg `21,838` and PPP `12,820`; the compiled
benchmark relative differences are `6.2939352731495626e-15` and
`1.841851745379798e-15`. All nine checks are true.

## S10 contract

`s10_generate_cut_bin_madgraph.py` uses NumPy PCG64 seed `2026081801` to
generate 120,000 massless four-body RAMBO trials at `sqrt(s)=1000 GeV`. It
applies the same invariant, azimuth-symmetric cuts as Hqqprime/Hqqbar and
keeps rejected trials as common zeros. For accepted rows it evaluates four
Hgg bridge rotations in generated/local order `g(k1),u(k2),ubar(k3)`, while
gating conservation, masses, fixed photon momentum, and lab/rest invariance.
It atomically writes the invariant/MadGraph CSV and source/input/hash-bound
metadata JSON; no local evaluator is called at this stage.

S10 is accepted. Source/log/CSV/metadata SHA-256 values are
`5c052bb03ad85fbc5a6df9624023c55773eb818d56e04fff208c901aa1956ad5` /
`db30b505041029982ef4f124bf3accee37531c1771492acff7fcbcc83f43223a` /
`52bb7105468906ea3538837ed26096a0027d2fc62395731f74462923d2efbca0` /
`28cd203dbc58420c573c34ce621118cac7d4545d578d26d35dfd7b2d7887faae`.
The fixed cuts accepted 27,851/120,000 rows. The intermediate MadGraph
estimate is `1.81604882301399919e-3 pb` with ordinary sampling error
`3.35628482117494967e-5 pb`.

## S11 contract

`s11_evaluate_local_cut_bin.wl` pins the S09 evaluator, S10 CSV/metadata, and
parameter card. It compiles the Hgg unit Pg/PPP pair, evaluates exactly the
accepted rows in their saved order, applies current card couplings, derives
the lepton scalar-product ratio with Wolfram `Solve`, and reconstructs each
projected full matrix element without another charge or symmetry factor. It
requires maximum pointwise relative difference below `2e-9` and the 99th
percentile below `2e-11`, then atomically writes the pointwise CSV and summary
JSON.

S11 is accepted. Source/log/CSV/JSON SHA-256 values are
`aa0d9f300a343cedecb8e40d230cd316a3f849879dae9d909c8c01990ec32247` /
`cb95457b13952bdd6893d77dd71ecb06e74db4b24b247e9fa150f242fb9e8c45` /
`ff10a84ffe4a929fb6229c2f5e83dfbe0de99f1b8678a34a3f9d3d59e0e788dc` /
`8c4d29ed4bd9ef6a300ded2f2ff4a0158a433e26fa63a9d44b5497c6b2088131`.
The run evaluated all 27,851 rows. Maximum/mean/median/99th-percentile
relative differences are `1.5937917374248115e-11`,
`3.295136957652517e-15`, `1.6971642659475213e-15`, and
`1.389283676613529e-14`; all nine checks are true. The Hgg WVM evaluator
returns exactly real machine-complex values, so S11 explicitly verifies a
zero imaginary residual and then takes `Re` before applying its unchanged
real positivity and comparison gates.

## S12 contract

`s12_integrate_common_cut_bin.py` consumes only the accepted S10 metadata/CSV
and S11 summary/pointwise CSV. It must verify their pinned hashes, schemas,
row counts, trial ordering, and exact MadGraph-column identity, then apply the
single common phase-space, flux, and unit conversion to both estimators with
all rejected trials retained as common zeros. It reconstructs the S10
MadGraph estimate and error, reports the local estimate, paired difference,
integrated relative difference, and sample correlation, and requires the
accepted metadata plus integrated agreement gates. It atomically writes only
`s12_integrated_comparison.json`; S12 is the terminal Hgg MadGraph-check stage.

S12 is accepted. Source/log/result SHA-256 values are
`bcf6b37701aba8e7dd1e4182b7f3e816ec53b1d39c2a0c7bed94acfac1a75468` /
`ec17943bb639c252df1f97b2e493b7ad2b107ac6cfe7de1b8f310cdbac14962c` /
`07c4e4b1b64b42dc36206deb95ea755044fccfe6bb04d7b95c01bb23214db51f`.
The tool reports MadGraph `1.81604882301399919e-3 pb`, local Hgg projection
`1.81604882301399768e-3 pb`, MadGraph sampling error
`3.35628482117494967e-5 pb`, local-minus-MadGraph
`-1.65625568819893015e-18 pb`, integrated relative difference
`9.12010551263776570e-16`, and sample correlation
`9.99999999999999889e-1`. Independent reload verified all seven checks,
counts, input hashes, and source identity.

## Final status

Hgg MadGraph-check S01-S12 are complete and accepted. The terminal artifact
is `s12_integrated_comparison.json`; no additional validator or second sample
is part of this check workflow.
