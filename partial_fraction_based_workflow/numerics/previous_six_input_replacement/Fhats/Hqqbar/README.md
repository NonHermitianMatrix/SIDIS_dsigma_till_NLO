# Hqqbar bookkeeping reference

This file records stable physics, normalization, flavor, and artifact
conventions for the Hqqbar calculation. It is intended for agent handoff.
The only live status record is `scripts/progress.md`; this README does not
authorize a later stage by itself.

## Authoritative references

- Physics reference: `scripts/Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`
  - SHA-256: `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`
  - Paper Table I defines this channel as the real-only hard part
    `H_{q qbar; q q}` with no two-body Born or virtual partner at
    `O(alpha_s^2)`.
  - Paper Table II supplies charge-conjugated channels; it does not change the
    field or symmetry bookkeeping below.
  - The paper uses MS-bar collinear factorization. The overbar is visible in
    the PDF although text extraction renders it as plain `MS`.
- BigTMD reference: the vendored JeffersonLab/BigTMD snapshot under
  `scripts/Hqq/bigTMD_check/BigTMD_reference`, previously pinned to commit
  `6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`.
  - `sidis.py` SHA-256:
    `150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d`
  - Pg `fchn5A.py` SHA-256:
    `9314f660d6ba9e37c203cf010da2f9aee84e993958e5dd3ad7896fb33ac5b48b`
  - Ppp `fchn5A.py` SHA-256:
    `5c275d8ee0e01fa23e47e3ddef6d84150babc71ef01e391d75e3ed9f12f09a5e`
  - Pg/Ppp `fchn5B.py` and `fchn5C.py` are identical zero modules, SHA-256
    `d38500ab56c6bde16853883a42b6f89f701faff7ee31c8d5fd39c32a18ac5f9b`.

If any hash changes, re-establish the affected convention from the source
before reusing a result or cache.

## Channel and momentum definition

The channel is

`gamma*(q) + q(p) -> qbar(k1, fragmenting) + q(k2) + q(k3)`.

- Paper indices: incoming `i=q`, fragmenting `j=qbar`, unobserved `k=l=q`.
- Momentum conservation: `p + q = k1 + k2 + k3`.
- Mass shell: `p^2 = k1^2 = k2^2 = k3^2 = 0`, `q^2 = -Q^2`.
- The first outgoing momentum is always the observed/fragmenting momentum
  `k1`. Never relabel a spectator as `k1` after an amplitude is generated.
- The useful three-body invariants are `s=(p+q)^2`,
  `t_i=(q-k_i)^2`, and `s_ij=(k_i+k_j)^2`. The endpoint variable for this
  observed leg is `s23=(k2+k3)^2`.
- This is a tree amplitude of exact coupling order `EL g_s^2`; its squared
  hard part begins at `EL^2 g_s^4`, i.e. `O(alpha_s^2)` in QCD.
- There is no Hqqbar two-body Born amplitude, one-loop virtual amplitude, or
  UV-counterterm amplitude at this order.

## Identical-particle bookkeeping

The spectators `q(k2)` and `q(k3)` are identical unobserved quarks.

- Generate the full coherent amplitude, including the exchanged-fermion
  diagrams and their Fermi signs.
- Sum all diagrams before conjugating/squaring.
- The later fully integrated spectator phase space must receive exactly one
  `1/2!` identical-particle factor. S01 does not apply it because S01 stores
  amplitudes, not a squared/phase-space-integrated hard part.
- Do not apply a second `1/2` in flavor assembly, projector contraction, or
  BigTMD comparison.

## Flavor and electromagnetic charge bookkeeping

- Hqqbar is same flavor throughout. It has no `(Nf-1)` multiplier and no
  independent different-flavor tensor.
- BigTMD mapping: channel 5, charge case A only.
- Physical luminosity:
  `Sum_q e_q^2 f_q(xi,mu) D_qbar(zeta,mu)`, including antiquark-initiated
  charge-conjugate terms only when the full hadronic sum is assembled.
- BigTMD cases B and C are exactly zero for channel 5. Do not form an A+B+C
  scalar sum.
- The FeynArts reference field `F[3,{1}]` is up type, with exact
  `Q_ref=+2/3` and `Q_ref^2=4/9`. Comments elsewhere calling it down type are
  known to be wrong.
- S01 divides every one-photon reference amplitude by `Q_ref`, using the
  exact rational factor `3/2`. The saved hard amplitude retains the
  electromagnetic coupling `EL` but no numerical quark charge. Apply the
  physical `e_q^2` only in the later flavor luminosity.
- Never replace a charge tensor by a bare `Nf`, and never use machine
  decimals for charge or flavor factors.

## BigTMD channel-5 caveat

BigTMD's `sidis.py` describes channel 5 as the observed-antiquark channel.
The last `qb` token in its process comment is inconsistent with fermion
number and with paper Table I; the physical final state has two spectator
quarks as written above.

Both Pg and Ppp `fchn5A` contain nonzero `regular`, `delta`, `plus1B`, and
`plus2B` functions, while all B/C functions vanish. However, the shipped
`sidis.py` NLO loop lists channels `[1,2,3,4,6]`, omitting channel 5, and its
distribution branch is restricted to channels below 4. Therefore the driver
does not evaluate the supplied channel-5 kernels. Later validation must call
the pinned `fchn5A` projector functions explicitly and must not infer a zero
hard part from the driver omission.

## Dimensional and scale bookkeeping

- Keep `D=4-2 epsilon` symbolic through amplitude, spin/color sum, phase
  space, and pole cancellation. Do not convert symbolic expressions to
  decimal form.
- S01 stores the exact FeynArts/FeynCalc amplitude without attaching a
  renormalization-scale power.
- With a dimensionless renormalized coupling convention
  `g_0 = ScaleMu^epsilon g_s (...)`, the two strong vertices correspond to
  `ScaleMu^(2 epsilon)` at amplitude level and `ScaleMu^(4 epsilon)` after
  squaring. If a later hard-part convention factors a common lower-order
  scale power, it must state that factor explicitly and attach only the
  remaining relative power. Never silently mix the absolute and relative
  conventions.
- Fix the scale power before Laurent expansion and verify its `Log[mu]`
  slope against the pinned BigTMD channel-5 kernels.
- Do not add an extra MS-bar `S_epsilon` if the same
  `Log[4 Pi]-EulerGamma` constant is already supplied by the phase-space or
  loop measure. Record each source of that constant separately.

## S01 contract

The S01 entry point is `s01_calculate_hqqbar_real.wl`.

It must:

1. Generate the particle-level SMQCD tree process
   `{V[1],F[3,{1}]} -> {-F[3,{1}],F[3,{1}],F[3,{1}]}` with momenta
   `{q,p} -> {k1,k2,k3}`.
2. Select exact coupling signature `{EL^1,g_s^2}` and require eight diagrams.
3. Convert every selected diagram to a D-dimensional FeynCalc amplitude.
4. Strip the exact reference charge by `3/2`, retain diagram-level and
   coherent-sum representations, and reject machine numbers, loop objects,
   or unevaluated FeynArts amplitudes.
5. Save `s01_result` atomically with source/reference hashes, software
   versions, field/momentum definitions, diagram counts, and passed checks.

S01 does not perform spin/color sums, conjugation, the `1/2!` spectator
factor, phase-space integration, projector contraction, collinear
factorization, or BigTMD numerical comparison.

## Validated S01 artifact

The production artifact generated on 2026-08-17 has:

- source: `s01_calculate_hqqbar_real.wl`
- source SHA-256:
  `750d7c607f57b403d55ba36715a6700015c16fe7b831686204e89758912c4e71`
- result: `s01_result`, 50,550 bytes
- result SHA-256:
  `69401e04b6ad1c3023da1a91155b7a90876510e273e4a2183bd11a7bcf9ab3b4`
- production count: 8 selected `EL g_s^2` diagrams from 40 SMQCD
  candidates
- validation-only count: 8 down-reference diagrams, excluded from the
  production payload
- exact up/down charge-stripped coherent residual: zero
- fresh-kernel validation: all 18 schema, source/reference hash, diagram,
  charge, field/momentum, symbolic-exactness, and absence-of-loop checks true

The accepted production log is `s01_production.log`. An earlier result from
the same calculation was deleted before regeneration because its stored
BigTMD hash association was malformed; no downstream artifact was built from
it. The accepted hashes above refer only to the corrected source and result.

## S02 contract

S02 is a visualization/provenance stage only. Its entry point is
`s02_export_hqqbar_diagrams_postscript.wl`.

It must:

1. Require the validated S01 source/result hashes recorded above and a
   complete `HqqbarS01-v1` result with every embedded check true.
2. Accept only the single `Hqqbar;q_q` FeynArts diagram set, require its two
   stored counts to equal eight, and independently regenerate eight raw
   amplitudes from that stored `TopologyList`.
3. Paint the set with a `3 x 3` layout and render exactly one physical native
   PostScript page.
4. Atomically write
   `.s02_ghostscript/pages/s02_set_001.ps` and reject stale or extra S02
   PostScript files in that directory.
5. Atomically write `s02_result` with the S02 source hash, both S01 hashes,
   diagram/layout/page counts, PostScript byte count and SHA-256, and a passed
   check ledger.

S02 must not regenerate physics amplitudes for use downstream, alter S01,
square amplitudes, apply the identical-quark factor, perform phase-space or
projector algebra, or assemble a PDF. PDF assembly is a possible S03 task and
is not authorized by this contract alone.

## Validated S02 artifact

The visualization artifact generated on 2026-08-17 has:

- source: `s02_export_hqqbar_diagrams_postscript.wl`, 12,894 bytes
- source SHA-256:
  `96c0982c4dc95d4174a3866248936ba110db3ab8b29bf1203cc0e9997c6ca49c`
- result: `s02_result`, 2,995 bytes
- result SHA-256:
  `2dc020ce5fb5eb6c591b55ddd0021ce3efc6d0ecbd5581ae1656e160187b6b38`
- PostScript: `.s02_ghostscript/pages/s02_set_001.ps`, 13,181 bytes
- PostScript SHA-256:
  `2c6c53a2f422307eab66eb5e92e916a092277ef89c2ff89097856275b3a1b48d`
- content/layout: the single validated S01 set of 8 diagrams, painted in a
  `3 x 3` layout as exactly one physical PostScript page
- production ledger: all 18 embedded input, representation, layout,
  integrity, and visualization-only checks true
- fresh-kernel validation: all 26 independent source/upstream binding,
  freshly regenerated amplitude-count, PostScript, inventory, and
  temporary-artifact checks true

The accepted production log is `s02_production.log`. Production completed in
about 15 seconds under an 8 GiB address-space ceiling with no fatal, OOM,
kill, timeout, or stall condition. S02 changed no physics amplitude and did
not start PDF assembly or S03.

## S03 contract

S03 is the final diagram-visualization assembly stage. Its entry point is
`s03_convert_hqqbar_diagrams_pdf.sh`.

It must:

1. Require the exact validated S02 source, `s02_result`, and PostScript
   SHA-256 values recorded above; accepting a merely nonempty or similarly
   named upstream artifact is forbidden.
2. Require exactly the one expected input stream
   `.s02_ghostscript/pages/s02_set_001.ps`, a `%!PS-Adobe-` header, one
   declared DSC page, and one matching `%%Page:` marker. Stale or extra
   `s02_*.ps` streams are fatal.
3. Reuse `../Hqq/.s02_ghostscript/runtime` only as the established generic
   Ghostscript 10.02.1 program/library dependency. No Hqq source, result,
   cache, or diagram page is an input.
4. Validate the PostScript through Ghostscript `nullpage`, convert it with
   `pdfwrite` into a PID-specific temporary file, validate that temporary PDF
   through `nullpage`, and require Ghostscript to report exactly one PDF
   page.
5. Atomically rename the validated temporary file to
   `s03_hqqbar_feynman_diagrams.pdf`, then print the S03 source, S02 inputs,
   and final PDF hashes plus byte/page counts for the accepted log and stable
   handoff ledger.

S03 performs no amplitude generation or modification, symbolic or numerical
physics algebra, phase-space integration, factorization, projection, or
BigTMD comparison. Its PDF is not a mathematical input to later stages.

## Validated S03 artifact

The PDF assembly artifact generated on 2026-08-17 has:

- source: `s03_convert_hqqbar_diagrams_pdf.sh`, 6,675 bytes, mode `755`
- source SHA-256:
  `7f95492b60d0d7f7eaae31dd03035f3e4a51397f25bed480046edb79e5cdd979`
- production log: `s03_production.log`, 824 bytes
- production-log SHA-256:
  `3afb2a8c35d47f62b6be4a588c347d759561fd96fb5ad961f9901d75b9292fe7`
- PDF: `s03_hqqbar_feynman_diagrams.pdf`, 21,461 bytes
- PDF SHA-256:
  `0fa19a357ceb73c11e5f3c78f9ef995a393239b411f5d7f0c9f1bafbf3b83e25`
- content: the sole validated S02 PostScript stream, yielding exactly one
  PDF 1.7 page
- production validation: exact S02 source/result/PostScript hashes, exact
  one-stream/one-page DSC inventory, Ghostscript input parse, temporary-PDF
  parse, one-page query, atomic rename, and final hash preservation all pass
- independent validation: Poppler reports one unencrypted page with no
  JavaScript and Ghostscript 10.02.1 as producer; a separate Ghostscript
  `nullpage` parse succeeds; all logged hashes/counts match the actual files;
  no partial PDF remains

Production completed in about 0.4 seconds under a 4 GiB address-space ceiling
with no fatal, OOM, kill, timeout, or stall condition. S03 modified no S01/S02
artifact, performed no physics calculation, and did not start S04.

## S04 contract

S04 is an explicit real-only/virtual-absence bookkeeping gate. Its entry point
is `s04_validate_hqqbar_virtual_absence.wl`.

Paper Table I supplies Hqqbar at `O(alpha_s^2)` only through the tree real
`H_{q qbar;q q}` process. Accordingly, S04 must not invent or port a two-body
Born amplitude, loop virtual amplitude, loop-pole collection, renormalization
constant, or UV-counterterm amplitude. It must:

1. Require the accepted S01 source SHA-256
   `750d7c607f57b403d55ba36715a6700015c16fe7b831686204e89758912c4e71`
   and result SHA-256
   `69401e04b6ad1c3023da1a91155b7a90876510e273e4a2183bd11a7bcf9ab3b4`.
   S02 and S03 are visualization artifacts and are not S04 physics inputs.
2. Require a complete `HqqbarS01-v1`/channel-5/case-A result with the pinned
   paper and BigTMD hashes, every S01 check true, and the exact explicit
   absence ledger for the two-body Born, one-loop virtual, and UV-counterterm
   parts.
3. Require the sole real payload `Hqqbar;q_q` to contain eight exact symbolic
   amplitudes, reconstruct both reference-charge and charge-stripped coherent
   sums exactly, obey the exact `3/2` charge-strip relation, and contain no
   loop object, UV/IR regulator, machine number, or prematurely attached
   `ScaleMu`.
4. Atomically write `s04_result` with stage
   `HqqbarS04-v1`, disposition `NotApplicableAtThisOrder`, source/program
   hashes, the validated real-payload audit, an all-true check ledger, and
   explicit integer-zero contributions for the absent two-body Born,
   one-loop virtual, loop-pole, and UV-counterterm sectors.
5. State unambiguously that those zeros mean the sectors are absent at this
   perturbative order, not that a loop amplitude was calculated and happened
   to vanish. The downstream mathematical input remains the coherent S01 real
   amplitude.

S04 performs no amplitude regeneration, conjugation/squaring, spin/color sum,
phase-space integration, `1/2!` identical-spectator insertion, scale-power
attachment, collinear factorization, projector contraction, or BigTMD
numerical comparison. Those operations remain deferred to later explicitly
authorized stages.

## Validated S04 artifact

The real-only/virtual-absence gate generated on 2026-08-17 has:

- source: `s04_validate_hqqbar_virtual_absence.wl`, 17,992 bytes
- source SHA-256:
  `b4afa7ff960449b2df5dbd38886e8e2a49aa2c14ed06d4cea515edcca65284e3`
- result: `s04_result`, 5,139 bytes
- result SHA-256:
  `b92526579c1aff40f40d305fe0087b000dde45355391843364c4ea5e52f72e9e`
- production log: `s04_production.log`, 578 bytes
- production-log SHA-256:
  `b6eb223260a22c2c7554a47657201e822ca95c5446cb07d8857796923df0a3b9`
- disposition: `NotApplicableAtThisOrder`, with 8 accepted real diagrams
  and explicit integer-zero absent Born/virtual/pole/UV-counterterm sectors
- production ledger: all 24 source, reference, absence, real-payload,
  charge, symbolic-purity, and atomic-write checks true
- fresh-kernel validation: all 20 independent schema, hash-binding,
  zero-semantics, real-audit, and downstream-instruction checks true

No S01 amplitude was changed or recomputed. The accepted downstream physics
input remains the coherent charge-stripped real amplitude in `s01_result`;
`s04_result` supplies the machine-checked instruction that no virtual term is
to be added at this order.

## S05 contract

S05 forms the sole open-photon-index real amplitude bilinear. Its entry point
is `s05_form_hqqbar_real_bilinear.wl`.

It must:

1. Require the accepted S01 source/result and S04 source/result SHA-256 values
   recorded above. S04 must be complete, `HqqbarS04-v1`, and explicitly
   `NotApplicableAtThisOrder`; S02/S03 visualization artifacts are not
   mathematical inputs.
2. Use only the eight accepted `Hqqbar;q_q` FeynArts diagrams. Because S01
   stores truncated kernels, regenerate those same diagrams with
   `Truncated -> False`, convert them with the S01 D-dimensional massless
   conventions, and apply the exact reference-charge strip `3/2` to every
   full amplitude.
3. Require exactly the four external fermion wavefunction orientations
   observed in preflight:
   `Spinor[Momentum[p,D],0,1]`,
   `Spinor[-Momentum[k1,D],0,1]`,
   `Spinor[Momentum[k2,D],0,1]`, and
   `Spinor[Momentum[k3,D],0,1]`. The negative `k1` orientation is the
   fragmenting antiquark; `k2,k3` are the identical spectator quarks.
4. Sum all eight charge-stripped amplitudes coherently before conjugation,
   open only the incoming-photon polarization into `s05Mu`, evaluate one
   dummy-index-renamed conjugate with `s05Nu`, and form the factored bilinear
   representing all `8^2 = 64` ordered diagram pairs.
5. Store the exact charge-stripped bilinear core and the downstream physical
   tensor with the absolute dimensional factor `ScaleMu^(4 epsilon)`. This is
   the square of the two-strong-vertex amplitude convention recorded above.
   Do not add a separate MS-bar `S_epsilon` at S05.
6. Keep the physical same-flavor weight `Sum_q e_q^2 f_q D_qbar` deferred;
   the bilinear retains `EL^2` but no reference numerical quark charge.
7. Apply neither the identical-spectator `1/2!` nor the incoming-quark
   spin/color average `1/(2 Nc)` at this stage. Preserve all external spinors
   for S06, where spin/color sums and the incoming average are to be applied;
   keep the single `1/2!` deferred to the integrated phase-space stage.
8. Atomically write `s05_result` with stage `HqqbarS05-v1`, current program
   and upstream hashes, external-state/charge/scale/symmetry ledgers, the open
   amplitudes and bilinear, explicit zero virtual interference inherited from
   S04, and an all-true check association. S05 creates no production cache.

S05 performs no spin or color sum, Dirac trace, incoming-state average,
phase-space integration, collinear factorization, projector contraction,
F-hat inversion, or BigTMD numerical comparison.

## Validated S05 artifact

The full-state real-bilinear artifact generated on 2026-08-17 has:

- source: `s05_form_hqqbar_real_bilinear.wl`, 23,259 bytes
- source SHA-256:
  `af499834c79fd69e69f33306a2e049a32f3d2ed88a50afcc65d5d37b0b9fd29e`
- result: `s05_result`, 62,218 bytes
- result SHA-256:
  `b72245cd5200ab0e649588ca77607feb21c152be2e20faead5ef74bc992a5f17`
- production log: `s05_production.log`, 3,476 bytes
- production-log SHA-256:
  `62ab28c5e238fba2850b21a02c6022efbf9234b88bf09da91e65b98f8aa942fa`
- content: 8 full charge-stripped amplitudes, their coherent open-index sum,
  evaluated conjugate, 64-pair factored core, and exact
  `FeynCalc` `ScaleMu^(4 epsilon)` scale-attached tensor
- production ledger: all 27 source, upstream, state, charge, coherence,
  coupling, scale, deferral, symbolic-purity, and atomic-write checks true
- fresh-kernel validation: all 29 intended independent gates pass; an initial
  validator-only `Global`/`FeynCalc` `ScaleMu` shadow was resolved by checking
  the explicitly context-qualified production symbol, with no source/result
  correction or rerun required

No cache or temporary result remains. S06 must consume only the saved
`ScaleAttachedRealTensor`, preserve its two photon indices, sum all four
external fermion spin/color states, and apply exactly the incoming-quark
average `1/(2 Nc)`. It must not add a virtual term, physical charge weight, or
the still-deferred identical-spectator phase-space factor.

## S06 contract — fermion spin/color sum and incoming-quark average

S06 has one and only one physics input: the validated
`s05_result["Bilinear"]["ScaleAttachedRealTensor"]` for
`gamma*(q)+q(p) -> qbar(k1)+q(k2)+q(k3)`. The accepted S05 source and result
SHA-256 values must be pinned before any algebra is performed.

1. Work in the same symbolic D-dimensional massless kinematics. Install the
   three-body scalar products defined by `sHat`, `ti`, `ui`, and `sij`, but do
   not impose a phase-space parametrization or set `D -> 4`.
2. Apply `FermionSpinSum` to all four external fermion lines: incoming
   `q(p)`, fragmenting `qbar(k1)`, and identical spectators `q(k2),q(k3)`.
   Evaluate every resulting Dirac trace exactly. There is no external gluon,
   hence no gluon polarization sum in this channel.
3. Sum all final and initial fundamental-color indices, then apply exactly one
   incoming-state average `1/(2 Nc)`: `1/2` is the unpolarized incoming-spin
   average displayed in paper Eq. (14), and `1/Nc` is the incoming fundamental
   color average. Final states are summed, never averaged.
4. Preserve the open photon indices `s05Mu,s05Nu`; do not perform a photon
   polarization sum or contract either paper projector. Projector contraction
   belongs to a separately authorized S07.
5. Preserve the already attached absolute factor
   `FeynCalc`ScaleMu^(4 epsilon)` exactly once. Do not add a decimal
   approximation, a second scale power, or a separate MS-bar `S_epsilon`.
6. Keep the physical same-flavor weight `Sum_q e_q^2 f_q D_qbar` deferred.
   The tensor remains charge stripped and contains only its symbolic `EL^2`
   coupling dependence.
7. Keep the sole identical-spectator `1/2!` deferred to the fully integrated
   three-body spectator phase space. S06 must neither multiply the tensor by
   that factor nor divide diagram interferences by it.
8. Add no LO, virtual, loop, counterterm, phase-space, factorization,
   F-hat-inversion, or BigTMD-comparison contribution. S04 proves that the
   virtual branch is not applicable at this perturbative order.
9. Any resumable S06 cache must be an atomic Association bound to both the
   exact S06 program SHA-256 and exact accepted S05 result SHA-256. The final
   `s06_result` must be atomic, reload-validated, fully symbolic, and expose
   both the color-summed tensor before the incoming average and the final
   spin/color-averaged tensor for an exact `1/(2 Nc)` audit.

S06 performs no projector contraction, phase-space integration, collinear
factorization, physical flavor-charge assembly, F-hat extraction, or BigTMD
comparison.

## Validated S06 artifact

The spin/color-summed and incoming-averaged real tensor generated on
2026-08-17 has:

- source: `s06_spin_color_sum_average_hqqbar.wl`, 24,529 bytes
- source SHA-256:
  `787d001e6d285d1e74cfe9654ca8f61fe9a66d3b2e5972b20291bf39a02014fe`
- result: `s06_result`, 14,674,347 bytes
- result SHA-256:
  `fd6499e32ce65273381e5350131fe06e8ed3b9a05083b446189b0d7d7323f9ef`
- post-Dirac cache SHA-256:
  `031befe95ed23f6bba7b0feb8f9573ee1981046c09492e18c824e1e497595f25`
- final spin/color cache SHA-256:
  `c1b8661b4213bc5d97a26a9d6da9474de46d14a632ada6866511bc055c2ad097`
- production-log SHA-256:
  `2b2e0de7e7729952c9418a63255c097d162c7fb1d8b272e51bbad429b5398fb9`
- content: one exact D-dimensional color-summed pre-average tensor and its
  final `1/(2 Nc)` spin/color-averaged tensor, both with open photon indices
  and exactly `FeynCalc`ScaleMu^(4 epsilon)`
- production ledger: all 25 source, upstream, state-sum, trace, color,
  incoming-average, charge, scale, symmetry, virtual-absence, symbolic-purity,
  and atomic-provenance checks true
- fresh validation: all 18 independent tensor/result checks and all 6 cache
  binding/payload checks true; the log contains `S06_SUCCESS` and no fatal,
  timeout, kill, abort, or OOM marker

No S06 temporary file remains. S07 must consume only
`Tensors/SpinColorAveragedRealTensor`; the unaveraged tensor is retained solely
to audit the exact incoming average. S07 may contract the two paper
projectors, but it must not integrate phase space or change any charge, scale,
symmetry, or virtual-absence ledger.

## S07 contract — paper projector contractions

S07 has one and only one tensor input: the validated S06
`Tensors/SpinColorAveragedRealTensor`. Current Hqq, Hgg, and Hqg source or
result files are not physics inputs or normalization authorities for this
channel; only generic FeynCalc mechanics may be compared against them.

1. Paper Eq. (7) defines `P_g^{mu nu}=g^{mu nu}` and
   `P_PP^{mu nu}=P^mu P^nu`. The partonic decomposition in Eq. (16) replaces
   the hadronic momentum by the incoming parton momentum, so S07 must contract
   exactly with `g^{mu nu}` and `p^mu p^nu`.
2. Use the same exact D-dimensional massless three-body scalar products as
   S06. Keep D and epsilon symbolic. Do not apply a four-dimensional limit,
   decimal conversion, numerical kinematic substitution, or Eq. (9) F1/F2
   extraction to either saved projection.
3. Before accepting the contractions, impose an independent electromagnetic
   current gate on the accepted Hqqbar tensor. Double-contract with `q`, make
   ordinary tree propagator denominators explicit only inside the diagnostic,
   and require exact zero at the rational, conservation-consistent point
   `Q2=2`, `sHat=10`, `(t1,u1,t2,u2,t3,u3)=(-4,-6,-4,-5,-6,-1)`,
   `(s12,s13,s23)=(5,3,2)`. D remains symbolic in this gate. This diagnostic
   must not replace or numerically specialize the saved symbolic projections.
4. Save exactly two nonzero scalar projections named `Pg` and `PPP`. Both
   photon indices and every other Lorentz index must be fully contracted;
   no external-state, Dirac, explicit-color, or unevaluated `Contract` object
   may remain.
5. Preserve the existing `FeynCalc`ScaleMu^(4 epsilon)` exactly once in each
   scalar. Add no extra scale, MS-bar `S_epsilon`, physical charge weight, or
   identical-spectator `1/2!`.
6. Eq. (19) makes the projections inputs to a later phase-space integral.
   Therefore S07 adds no `1/(2 Pi)^4`, three-body angular measure, k1 measure,
   symmetry/multiplicity factor, PDF/FF counterterm, endpoint distribution,
   F-hat inversion, or BigTMD comparison. Ordinary tree
   `FeynAmpDenominator` objects remain inert for the next stage.
7. There is no LO or virtual branch for Hqqbar at this order. S07 must retain
   the exact S04-S06 virtual-absence disposition and the charge-stripped
   BigTMD-channel-5A ledger.
8. Use separate atomic Association caches for `Pg` and `PPP`, each bound to
   the exact S07 program SHA-256, accepted S06 source/result SHA-256, paper
   SHA-256, projector name, and channel ledger. Atomically write and reload
   validate `s07_result` with exactly two projections.

The two projector contractions are independent, but each acts on a
722,442-leaf tensor. Run them serially to avoid doubling peak memory on this
machine; local parallel kernels would increase OOM risk without accelerating
either intrinsically single-expression contraction.

## Validated S07 artifact

The paper-projector artifact generated on 2026-08-17 has:

- source: `s07_contract_hqqbar_projectors.wl`, 22,822 bytes
- source SHA-256:
  `4631639ae9e06a266e507d8854ee0cadf55d9106faff5ab13fe616f33fb50db4`
- result: `s07_result`, 830,312 bytes
- result SHA-256:
  `a0bcb6faac5ee4d2e8e5ffdff33bad91f2333424f486e101c9c62d1a49318f50`
- `Pg` cache SHA-256:
  `44aca534625102093b50df5b209a0c859f9b175d7d71691f112649f87cc4e3e9`
- `PPP` cache SHA-256:
  `d73db25c25549bf9e848e7774ca8a4d1519db19102a20ee527bfa6ef9a569023`
- production-log SHA-256:
  `c7ad4003e8b3d772b69b54a5112df2c3fa30384a2046ab397f3263a3d8c3e7e9`
- content: exactly two nonzero, D-dimensional, charge-stripped,
  spin/color-averaged, unintegrated scalars—`Pg` with 102,851 leaves and
  `PPP` with 19,762 leaves
- production ledger: all 25 paper/source/upstream, Ward, projector, scalar,
  scale, charge, symmetry, virtual-absence, symbolic-purity, deferral, and
  atomic-provenance checks true
- fresh validation: all 20 independent checks true, including exact fresh
  reconstruction of each projection directly from the accepted S06 tensor,
  cache metadata/payload equality, exact Ward record, retained inert tree
  denominators, and all downstream deferrals
- log status: `S07_SUCCESS` is present with no fatal, timeout, kill, abort, or
  OOM marker; no S07 temporary file remains

No Hqq, Hgg, Hqg, or Hgq artifact was consumed. S08 is not started and must
not be inferred from this completed projector stage.

## S08 contract — three-body phase space and angular masters

S08 consumes only the validated S07 pair
`ScalarProjections/NLOReal_OAlphaS2/Hqqbar;q_q/{Pg,PPP}`. Other-channel S08
sources may diagnose generic implementation mechanics, but their tensors,
weights, charges, caches, and results are forbidden inputs.

1. Make the ordinary tree propagator denominators explicit under the exact
   massless three-body scalar products. Apply the momentum-conservation
   identities and `D -> 4-2 epsilon`, combine the exact rational expression
   with `Together`, and only then expand/classify angular powers. No decimal or
   four-dimensional specialization is allowed.
2. Require the full pre-angular `Pg` and `PPP` expressions to be invariant
   under simultaneous spectator exchange
   `{t2<->t3,u2<->u3,s12<->s13}`. This proves the labelled integrand includes
   the coherent identical-fermion exchange structure before its combinatorial
   phase-space correction.
3. Implement Appendix D Eqs. (D5)-(D8): separate same-type denominator
   ADMVs, reduce three different types to at most two, and rewrite numerator
   ADMVs in the chosen two-variable basis. Require both the printed D5-D8
   coefficient identities and exact reconstruction in a common basis.
4. Integrate `beta1,beta2` using the paper's Appendix-B frame coefficients.
   Evaluate case-1/massless-massless masters exactly with Eq. (B18); retain
   case-2/virtual-photon-massless integrals as the exact symbolic head
   `S08Case2Master[j,l,d,cosChi,epsilon]` defined by Eq. (B19). Do not apply
   Appendix F, B21-B27 epsilon/analytic-continuation formulas, or endpoint
   distributions in S08.
5. Multiply by Eq. (39)'s exact measure and Eq. (19)'s common
   `1/(2 Pi)^4`:
   `s23^(-epsilon) 2^(-2) Pi^(-epsilon) Gamma[1-epsilon] /
   ((2 Pi)^(6-2 epsilon) Gamma[1-2 epsilon])`. The power on 2 is exactly
   `-2`, not `-2 epsilon`.
6. Apply the single deferred identical-spectator factor `1/2!` exactly once
   when the labelled `k2,k3` phase-space measure is attached. Save both the
   pre-symmetry angular expression for audit and the physical expression, and
   require `physical = preSymmetry/2`. All downstream stages must record the
   factor as already applied.
7. Keep observed `k1` differential. Apply Eqs. (29)-(32) exactly with
   `xHat=xB/xi`, replace `zeta` by `s23`, multiply by the exact
   `d zeta/d s23` Jacobian, and store `xi in [A,1]` and
   `s23 in [0,B(xi)]`. Prove the derivative, Eq. (40), overall conservation,
   and lower-bound identities symbolically; do not perform the remaining
   `xi,s23` convolution.
8. Preserve the accepted charge-stripped BigTMD-channel-5A tensor and exactly
   one `FeynCalc`ScaleMu^(4 epsilon)`. Add no physical
   `Sum_q e_q^2 f_q D_qbar`, no separate MS-bar factor, no LO/virtual term,
   and no second symmetry factor.
9. Process `Pg` and `PPP` serially. Use separate atomic Association caches
   containing pre-/post-symmetry expressions, each bound to the exact S08
   program, paper, S07 source/result, projector, scale, charge, and symmetry
   ledgers. Atomically write and reload-validate `s08_result`.

S08 stops at exact angular masters and the symbolic `xi,s23` kernels. S09
epsilon/master expansion, endpoint delta/plus distributions, factorization,
F-hat extraction, and BigTMD comparison are not authorized here.

## Validated S08 artifact

The three-body phase-space/angular artifact generated and corrected on
2026-08-17 has:

- source: `s08_phase_space_integrate_hqqbar.wl`, 50,357 bytes
- source SHA-256:
  `2947bef60f303969ba451fc69cf1af76b0550a4f0d18bc2632d43568bf95bda6`
- result: `s08_result`, 12,328,312 bytes
- result SHA-256:
  `163eea0d42febe7642abb106599aa7d8c594eed2e6888a62cc1dde7985ec0dec`
- `Pg` cache SHA-256:
  `a762eb92f48397e9150c1c1aed22278979c4104642eede680f9eea7e32a8baec`
- `PPP` cache SHA-256:
  `57e7ae86126b054513258fdd8a125f8736151b7526fc6cf6e9bfad193947e03b`
- production-log SHA-256:
  `351d7bd7428fca422b33b86f34713b85c98e1215936d48983b25771f5e49e07f`
- exact Appendix-D reconstruction: 65/65 `Pg` and 12/12 `PPP`
  disjoint common-basis partitions have zero residual; the reduced terms group
  into 82 and 86 angular masters, respectively
- symbolic output: 59 distinct retained Eq. (B19) case-2 masters;
  pre-/post-symmetry leaf counts `Pg=346828`, `PPP=197268`; transformed
  `xi,s23` leaf counts `Pg=1986877`, `PPP=1298496`
- production ledger: all 36 source/paper/upstream, rationalization,
  spectator-exchange, Appendix-D, Appendix-B, phase-space normalization,
  one-time `1/2!`, variable-change, scale/charge/virtual, symbolic-purity,
  provenance, and no-S09 checks true
- fresh validation: all 32 independent result/cache/math checks true,
  including exact cache-to-result payload equality, disk cache hashes,
  `physical=preSymmetry/2`, and freshly recomputed Jacobian, Eq. (40),
  conservation, and boundary identities
- log status: `S08_SUCCESS` is present with no fatal, OOM, timeout, kill, or
  cache-mapping warning; no S08 temporary remains

The initial production attempt had correct mathematical payloads but used
`AssociationMap` incorrectly when constructing the cache-hash Association.
That attempt was never accepted. The source was corrected to map over
Association values, a regression gate was added, and the result and both
source-bound caches were deleted and regenerated rather than edited in place.

S09 must consume only
`ThreeBodyAngularIntegrated/Hqqbar;q_q/{Pg,PPP}` or the corresponding
`XiS23ConvolutionKernels/ThreeBodyReal/Hqqbar;q_q/{Pg,PPP}` physical payloads.
The identical-spectator factor is already applied exactly once and must not be
applied again.

## S09 contract — Appendix-F master expansion and formal endpoints

S09 consumes only the accepted physical post-`1/2!` S08 `Pg` and `PPP`
payloads. It must pin the paper plus the S08 source, result, and both cache
SHA-256 values above. Other-channel scripts may illustrate generic file/cache
mechanics but are not physics or formula authorities.

1. Require the complete retained B19 inventory, rather than accepting a
   subset. Across the pair it is exactly
   `{{-2,0},{-2,1},{-1,-1},{-1,0},{-1,1},{-1,2},{0,-2},{0,-1},
   {0,1},{0,2},{1,-3},{1,-2},{1,-1},{1,0},{1,1},{1,2},{2,-2},
   {2,-1},{2,0},{2,1},{2,2}}`. `Pg` has 68 occurrences in 15 classes and
   `PPP` has 73 occurrences in 20 classes.
2. Expand the nonzero-`j` masters directly from Appendix F, using the branch
   conventions and auxiliary definitions in F1-F5 together with B21-B31.
   Retain the epsilon order printed by the paper: through `epsilon^1` for the
   applicable formulas except F28/F29, which stop at `epsilon^0`. Derive every
   `j=0` class from exact B18 and expand it through `epsilon^2`; use B27 through
   `epsilon^2`, with B28-B31 represented by the paper's final F28/F29 formulas.
   The accepted input contains exactly three residual B27 occurrences in Pg
   and three in PPP. Because S08 factorizes the common phase-space Gamma ratio
   around nested B18 terms, expand structurally unmatched individual
   `Gamma[1-epsilon]`/`Gamma[1-2 epsilon]` only after proving that their series
   reconstruct both required whole Gamma ratios exactly through `epsilon^2`.
   Never use `PowerExpand`, machine numbers, decimal conversion,
   or numerical kinematics to select a branch.
3. Independently gate the Appendix-F transcription with the B19 defining
   relation `D_D I[j,l] = -j I[j+1,l]`, compared at the common available
   truncation order for all eleven adjacent required pairs whose printed
   partners are mutually consistent. Validate required F8 (`{1,-3}`)
   separately and exactly from B19: perform the `beta2` moments, reduce the
   remaining polynomial numerator to `J_n`/logarithmic `H_n` moments, and
   require both its leading and `epsilon^1` coefficients to agree identically.
   The printed but physically unused F9 `epsilon^1` term fails both this B19
   derivative check and a direct high-precision defining-integral check;
   therefore it must not be imported, patched, or used to reject the correct
   F8 expression. Record this paper-internal diagnostic explicitly.
4. Substitute the checked master expansions into the physical angular pair,
   then apply S08's accepted exact `xi,s23` kinematic rules and Jacobian. Save
   the expanded transformed kernels in separate atomic `Pg`/`PPP` caches.
   Require no retained B19 head, `Hypergeometric2F1`, `Beta`, machine number,
   or angular variable in either cache.
5. The additional S09 multiplicative weight is exactly one. Preserve the
   already-applied identical-spectator `1/2!`, charge-stripped channel-5A
   convention, and the single inherited `FeynCalc`ScaleMu^(4 epsilon)`.
   Continue to defer `Sum_q e_q^2 f_q D_qbar`; introduce no extra MS-bar
   `S_epsilon`, LO/virtual term, or real/virtual combination.
6. On `0 <= s23 <= B`, record the exact formal distribution identity through
   `epsilon^2`,
   `s23^(-1-epsilon) = -B^(-epsilon) DiracDelta[s23]/epsilon +
   B^(-epsilon) Sum[(-epsilon)^n/n!
   S09PlusDistribution[n,s23,B],{n,0,2}] + O(epsilon^3)`, where the plus head
   acts as `[Log[s23/B]^n/s23]_+`. Define the corresponding regular function
   as `s23^(1+epsilon)` times the exact cached kernel, but mark its endpoint
   values unresolved: stronger real-emission singularities must be resolved
   structurally in the later endpoint stage, not hidden by a false finite
   substitution in S09.
7. Eq. (46) collinear subtraction, resolved delta/plus coefficients, PDF/FF
   counterterms, finite hard coefficients, Eq. (9) inversion, F-hat
   extraction, and BigTMD comparison are all downstream. S09 must not claim
   any of them and must not create or launch S10.
8. Bind each cache to the exact S09 program and accepted upstream hashes,
   projector, exact master inventory/counts, and the scale/charge/symmetry/
   virtual ledger. Store only compact endpoint descriptors plus cache paths
   and their real disk hashes in the atomic result; do not duplicate the large
   kernels merely to inflate `s09_result`.
9. Map Association values only with key-preserving `Map`, require an exact
   key/shape/value regression probe, and recompute/recompare actual disk hashes
   after atomic reload. Treat every warning as a production failure. Provide a
   full no-write preflight path. Process the two large expressions serially;
   parallel copies would increase OOM risk without accelerating their
   intrinsically single-expression substitutions.

S09 ends with exact expanded real-emission kernels and an honest formal
endpoint-distribution handoff. It does not resolve the endpoint or perform
factorization.

## Validated S09 artifact

The Appendix-F-expanded real-kernel and formal-endpoint artifact accepted on
2026-08-18 has:

- source: `s09_expand_endpoints_hqqbar.wl`, 51,892 bytes; SHA-256
  `71c4f10cc35cf767f5ae01a895e78d1beee751100f71b83524cd95e796561280`
- compact result: `s09_result`, 12,769 bytes; SHA-256
  `2b50259061ec86cd735b1c04b0a73712d7cae1ff7176d6d97776a9746a1d7a15`
- `Pg` cache: 5,878,532 bytes; SHA-256
  `1f34249af61f94bd91d81cb0315f51480fc9256e03c7558c441e9f7a7f8415b7`
- `PPP` cache: 4,447,633 bytes; SHA-256
  `0e208d193319eb6f34b18825fd2805b18a2bf9cddbdeb54e95e27486a7552324`
- production log: 6,765 bytes; SHA-256
  `2e935e9b57840942c73f2f7eb593e869865578457146f113ac2df6a69bd9d872`
- exact output sizes: `Pg` has 2,450,525 leaves / 69,980,312 in-memory
  bytes and `PPP` has 1,855,694 leaves / 52,825,896 bytes
- production ledger: all 35 paper/upstream, exact-master, formula-recurrence,
  B19-F8, B18/B27/Gamma-series, symbolic-purity, map-commutation,
  one-time-bookkeeping, formal-endpoint, stage-boundary, atomic-cache, and
  real-disk-provenance checks are true
- independent validation: fresh disk hashes, schemas, provenance, all stored
  checks and exact residual certificates, 21-class/141-occurrence/59-instance
  inventory, cache bindings and sizes, symbolic purity, complete `xi,s23`
  mapping, inherited scale/charge/symmetry/virtual ledgers, unresolved
  delta/three-plus endpoint structure, compactness, and no-factorization/
  no-F-hat/no-BigTMD boundary all pass
- log status: `S09_SUCCESS` is present with no fatal, OOM, kill, timeout,
  cache-mapping warning, or leftover S09 temporary

The text-form `Put` artifacts contain an unqualified `ScaleMu` token. Any
consumer or independent validator must load FeynCalc before `Get`, exactly as
the production program does, so the token resolves to
``FeynCalc`ScaleMu`` rather than a newly created ``Global`ScaleMu``. A diagnostic
kernel that omitted this initialization produced the latter context, while a
fresh FeynCalc-initialized kernel validated both caches and the compact result
with unchanged hashes. No S09 artifact was patched or regenerated.

## S10 contract — combined endpoint Laurent resolution and action

S10 is the single user-facing Hqqbar stage that performs both kinds of work
separated into Hqq S9.5 and Hqq S10: resumable exact endpoint-Laurent cache
construction and subsequent delta/plus-distribution action. It consumes only
the accepted S09 result and its two hash-pinned projector caches above.

1. Load FeynCalc before every `Get`, pin the exact S09 source, result, Pg-cache,
   PPP-cache, and paper SHA-256 values, and require all 35 S09 checks. Process
   Pg then PPP serially at the projector level and never hold duplicated large
   projector expressions merely for convenience.
2. Each accepted projector is a nine-factor product with exactly one common
   `s23^(-epsilon)` and one dominant additive remainder. Require exactly 76 Pg
   and 78 PPP source terms. Determine all additional endpoint powers from the
   current algebra, not from Hqq indices.
3. The current source has exactly one extra vanishing
   `base^(-1-epsilon)` per projector: Pg source term 8 and PPP source term 6.
   Prove dynamically that `base(0)=0` and
   `Cancel[Together[base/s23]] /. s23->0 = zH^2/PHT2`. Refactor each as an
   alpha-two contribution. Ordinary terms use the alpha-one delta coefficient
   `-B^(-epsilon)/epsilon`; alpha-two terms use
   `-B^(-2 epsilon)/(2 epsilon)` and the doubled logarithmic tower.
4. Use the corrected Hqq factorwise endpoint algorithm for every ordinary
   term. For `term=r q`, with only `q` singular and
   `q=q[-2]/s23^2+q[-1]/s23+...`, extract the coefficients of `s23 term` as
   `r(0) q[-2]` and `r(0) q[-1]+r'(0) q[-2]`. Only use bounded exact direct or
   Laurent fallbacks when this structural route is unavailable. Machine
   arithmetic, decimal conversion, numerical kinematics, and branch-blind
   `PowerExpand` are forbidden.
5. Do not repeat the old Hqq coupled-log defect. A physical-root audit finds
   branch-zero logarithms in Pg source sets
   `{12,22,57,75}`, `{13,23,39,74}`, `{40,73}`, and `{61,76}`, and in PPP
   sets `{12,35,48,77}`, `{13,32,46,70}`, `{47,78}`, and `{64,73}`. Resolve
   the positive and negative physical square-root branches, replace every
   genuinely vanishing logarithm by `Log[s23]+Log[slope]`, and require every
   positive power of the inert `Log[s23]` to cancel within its derived group.
   Store one finite physical `Piecewise` anchor per proven group and exact zero
   in its companion slots. A group is accepted only after this symbolic proof;
   raw termwise endpoint values are not physics results.
6. Atomically checkpoint only parent-ordered per-term results. Every cache must
   be bound to the exact S10 program and accepted S09 hashes and record the
   source indices, alpha class, coupled-log repair metadata, extraction
   methods, completed coverage, and real disk hash. At most two independent
   term workers may run concurrently; fall back to exact serial evaluation if
   workers are unavailable. Parallel projector copies and concurrent cache
   writes are forbidden.
7. Sum the repaired ordinary stronger-pole coefficients separately for each
   projector and prove their epsilon orders required for a result retained
   through `epsilon^0`. Preserve any exact evanescent remainder in the audit
   ledger, but exclude it from the finite-order regular function only after
   proving its analytic continuation cannot contribute through that order.
8. Act the complete alpha-one and alpha-two delta/plus towers on an arbitrary
   symbolic `S10ConvolutionTest[projector,s23]` regular at zero and independent
   of epsilon. The saved actions must contain an ordinary endpoint-subtracted
   inactive integral and no `S09EndpointValue`, `S09PlusDistribution`, or
   `DiracDelta` object.
9. The additional S10 multiplicative weight is exactly one. Preserve the
   already-applied S08 identical-spectator `1/2!`, the charge-stripped
   channel-5A convention, and the single inherited
   ``FeynCalc`ScaleMu^(4 epsilon)``. Do not add a physical
   `Sum_q e_q^2 f_q D_qbar`, MS-bar factor, LO term, virtual term, or a second
   symmetry factor.
10. S10 ends with the fully symbolic, collinearly unsubtracted Hqqbar real
    convolution actions. The paper's Eq. (46) PDF/FF subtraction, cancellation
    of remaining collinear poles, `epsilon->0` finite hard-part limit, Eq. (9)
    inversion, F-hat extraction, and BigTMD comparison remain downstream.

## Validated S10 artifact

The endpoint-resolved real convolution artifact accepted on 2026-08-18 has:

- source: `s10_resolve_endpoints_hqqbar.wl`, 67,032 bytes; SHA-256
  `793f9aaafbda74c605c3885915eabf9323e8b5761c84e9954d0759a5f890ac20`
- result: `s10_result`, 11,418,177 bytes; SHA-256
  `57e637d3eca490dfe08e341d866e5fa08ec1d69b14c7c476cf17c51890a65cb6`
- `Pg` endpoint cache: 6,476 bytes; SHA-256
  `e130cafa2e9b02748f16e9c812d60bfaf29d37d9225eb362045d061d30fc8185`
- `PPP` endpoint cache: 6,560 bytes; SHA-256
  `173e44bc67623274801a8ad9cc2e92183c39456b20d4cb68a21544100f2b225e`
- production log: 25,919 bytes; SHA-256
  `dfc0e48f0c4ffa40deec1fec54958f7d71f9b61172a003e72f351c2be2829add`
- exact coverage: all 76 Pg and 78 PPP source terms, with alpha-two source
  positions Pg 8 and PPP 6 and nested endpoint ratio `zH^2/PHT2`
- physical-root certificates: all four coupled-log groups per projector were
  repaired and every stronger endpoint pole required through the finite order
  vanishes exactly
- action status: all delta/plus distributions have acted on the arbitrary
  `S10ConvolutionTest`; only ordinary endpoint-subtracted inactive integrals
  remain
- bookkeeping: one inherited ``FeynCalc`ScaleMu^(4 epsilon)``, charge-stripped
  channel 5A, one already-applied identical-spectator `1/2!`, no virtual/LO
  branch, and no Eq. (46), finite hard-part, F-hat, or BigTMD claim
- validation: all 26 production checks and all 12 fresh independent
  provenance/schema/inventory/branch/pole/action/bookkeeping groups are true;
  the log has `S10_SUCCESS_SYMBOLIC` and no fatal, OOM, kill, timeout, or
  Wolfram diagnostic marker; no temporary artifact remains

Any consumer must load FeynCalc before `Get`, because the text artifact
contains the unqualified serialized `ScaleMu` token.

## S11 contract — Hqqbar Eq. (46) collinear counterterms

S11 calculates, but does not add, the four symbolic Eq. (46) counterterms:
PDF and FF pieces for each of Pg and PPP. It binds the accepted S10 handoff and
the accepted S01 charge convention, while generating the required two-body
Born hard parts directly.

1. Use the external paper labels `i0=q`, `j0=qbar`. The initial-state species
   sum has only
   `H_(g qbar)^(LO) convoluted with P_(g/q) = Hgqbar convoluted with Pgq`.
   The final-state species sum has only
   `H_(q g)^(LO) convoluted with P_(qbar/g) = Hqg convoluted with Pqg`.
   There is no diagonal Hqqbar term because its two-body Born hard part is
   absent, and no one-loop quark-to-antiquark flavor-changing kernel exists.
2. Generate exactly the reference `gamma* q -> g q` and
   `gamma* g -> qbar q` two-body processes with observed momentum `k1` assigned
   respectively to `g` and `qbar`. Apply the incoming averages
   `1/(2 Nc)` and `1/((D-2)(Nc^2-1))`, sum rather than average final states,
   and contract separately with the paper Pg and PPP projectors.
3. Read the exact up-reference charge strip `3/2` from accepted S01 and apply
   it at amplitude level before squaring. Independently generate the same two
   channels with the down field and strip by `-3`; require the charge-stripped
   Pg and PPP pairs to agree exactly. Apply no flavor multiplicity or physical
   charge sum in S11. Continue to defer `Sum_q e_q^2 f_q D_qbar`.
4. Attach exactly `FeynCalc`ScaleMu^(2 epsilon)` to every stripped Born square.
   This is the absolute one-strong-vertex Born scale from the established
   dimensionless-renormalized-coupling convention. The partonic PDF/FF factor
   in Eq. (46) contributes no additional `mu^epsilon`, as the paper states.
5. Use the positive prefactor
   `g_s^2 S11SEpsilon/(16 Pi^2 epsilon)`. The sign follows by subtracting the
   negative order-alpha_s partonic PDF/FF terms in Eqs. (49)-(50). Retain
   `S11SEpsilon` symbolically; do not guess or duplicate a finite MS-bar
   constant at this stage. The paper explicitly labels its prescription MS.
6. Use exactly the printed kernels
   `Pgq(y)=2 CF (1+(1-y)^2)/y` and
   `Pqg(y)=2 TF ((1-y)^2+y^2)`. Both are regular at `y=1`, so every saved
   component is one ordinary inactive integral; no splitting plus or delta
   distribution is introduced.
7. Use Eqs. (34)-(35) with `twoBodyNormalization=2 Pi/(2 Pi)^4`. Under the
   common endpoint variable, set the PDF and FF splitting variables to
   `1-s11S23/pdfScale` and `1-s11S23/ffScale`, prove the Born delta argument
   vanishes, and prove their endpoint ranges are `[xHat,1]` and `[zHat,1]`.
8. Convert the internally projected incoming momentum to the external paper
   projector by multiplying only the PPP PDF density by `1/y^2`. Pg is
   invariant under this rescaling, and neither FF density receives it.
9. Add exact electromagnetic Ward gates for both generated reference Born
   tensors. Require exact symbolic expressions, no machine numbers, no
   unevaluated FeynArts/FeynCalc state objects, and no unexpected Pqq/Pgg or
   Hqqbar-LO contribution.
10. Save an atomic, reload-validated `s11_result` bound to the exact S11 source,
    paper, accepted S01 source/result, accepted S10 source/result/caches, and
    channel-5A reference hashes. S11 must not add its counterterms to S10,
    test pole cancellation, take `epsilon->0`, invert Eq. (9), extract F-hats,
    or compare finite expressions with BigTMD; those operations are downstream.

## Validated S11 artifact

The Eq. (46) counterterm artifact accepted on 2026-08-18 has:

- source: `s11_calculate_collinear_counterterms_hqqbar.wl`, 39,749 bytes;
  SHA-256
  `2864463cd41d8bbc00247d429244decc061201e877ff60a511664924ce78a3d4`
- result: `s11_result`, 18,255 bytes; SHA-256
  `3cc321fc994a803f1d28a7fe35b84b4a4c466a9d95ed4e66bb3bca3e40aff889`
- production log: 5,911 bytes; SHA-256
  `84eff6f30b675fc836e888569f7baa1fa3e9ac638d6503d14ab7bb9a14d01b88`
- saved keys: exactly `PgPDF`, `PgFF`, `PPPPDF`, and `PPPFF`
- species: PDF `Hgqbar^(LO) x Pgq`; FF `Hqg^(LO) x Pqg`; no diagonal
  Hqqbar Born term and no Pqq/Pgg term
- direct-generation gates: two diagrams per Born channel, correct incoming
  quark/gluon averages, exact Ward residuals, and exact agreement between
  independently stripped up- and down-field Pg/PPP pairs
- scale/scheme: exactly one `ScaleMu^(2 epsilon)` per Born/counterterm,
  symbolic paper-MS `S11SEpsilon/epsilon`, and no additional PDF/FF
  `mu^epsilon`
- convolution gates: both Born on-shell identities and endpoint maps pass;
  only the PPP PDF density receives `1/y^2`; each counterterm contains exactly
  one regular inactive integral
- production validation: all 31 source/provenance/physics/bookkeeping checks
  are true
- independent validation: all 12 fresh schema/hash, species, Born,
  Ward/charge, map, exact-formula-rebuild, integral, scale/scheme, deferral,
  and BigTMD-binding groups are true
- process state: production exited zero in about 28 seconds under an 8-GiB
  address-space ceiling; no OOM, kill, timeout, fatal marker, or temporary
  artifact remains

As for S09/S10, load FeynCalc before `Get` so serialized `ScaleMu` resolves in
the `FeynCalc`` context. S11 is a counterterm-only artifact; S10 combination,
pole cancellation, the finite hard parts, F-hats, and BigTMD comparison remain
downstream.

## S12 contract — factorization combination and finite projector actions

S12 consumes only the accepted S10 endpoint-resolved real actions and the
accepted S11 Eq. (46) counterterms recorded above. It must pin the paper, both
programs, both results, and both S10 endpoint caches to their exact SHA-256
identities. Other-channel S12 programs are implementation references only;
their terms, weights, channel routes, fixed indices, and physics formulas are
not Hqqbar inputs.

1. Load FeynCalc before every serialized artifact. Require the exact S10
   `HqqbarS10-v1` and S11 `HqqbarS11-v1` schemas, all saved checks, the S10
   source/cache bindings, and the S11 paper/S10 bindings. Reject accidental
   `Global`` copies of FeynCalc/QCD symbols.
2. Rebuild the paper Eqs. (29)-(32) physical map symbolically:
   `xHat=xB/xi`, the exact `zeta(xi,s23)`, `zHat=zH/zeta`,
   `k1TPartonic2=PHT2/zeta^2`, the exact `d zeta/d s23` Jacobian, and
   `0 <= s23 <= B(xi)`. Require Eq. (40), the external-invariant identity,
   both counterterm Born-shell identities, and both splitting variables at
   the endpoint to have exact zero residuals.
3. Map S11 rather than transcribing a counterterm by hand. For each of the
   four saved keys, extract its single ordinary-integral density, remove only
   `S11ConvolutionTest`, substitute the physical external map, multiply by the
   `zeta -> s23` Jacobian, and attach the common S10 test convention. As an
   independent gate, rebuild the same mapped densities from S11's saved
   `Hgqbar`/`Hqg` Born projections, the saved two-body normalization, and the
   printed `Pgq`/`Pqg` kernels. Require exact equality for Pg-PDF, Pg-FF,
   PPP-PDF, and PPP-FF. Only PPP-PDF may contain the external-projector
   `1/y^2` conversion.
4. Use the positive Eq. (46) sign already present in S11. Expand the exact
   MS-bar factor `S11SEpsilon -> (4 Pi)^epsilon/Gamma[1-epsilon]` with Wolfram
   `Series`; do not insert a hand-written finite constant. The counterterms
   retain their one Born `ScaleMu^(2 epsilon)` and receive no additional
   PDF/FF `mu^epsilon`. Do not multiply the S10 real term by another
   `S_epsilon`: its accepted three-body measure and absolute
   `ScaleMu^(4 epsilon)` are already present.
5. Derive the real-action partition from the accepted S10 expression. The
   current hash-pinned action has exact-zero endpoint and `phi(0)` fields and
   one `phi(s23)` integral per projector. The present algebra yields one
   alpha-two family plus 75 ordinary Pg source terms and one alpha-two family
   plus 77 ordinary PPP source terms. Recheck these counts and structural
   identities at runtime; never import another channel's term inventory.
6. Extract the S10 coefficients of `epsilon^{-2}`, `epsilon^{-1}`, and
   `epsilon^0` term by term with exact factorwise series algebra. Process Pg
   then PPP serially; parallel copies of these multi-million-leaf projector
   expressions would increase OOM risk and do not accelerate a single-term
   `Series`. Atomically checkpoint every term and aggregate, binding it to the
   exact S12 program and S10 result hashes. Limit each kernel epoch and resume
   only after validating every cache hash and term-expression hash.
7. Expand the mapped S11 total through `epsilon^0`, then combine by projector
   and by action field. Require the real double pole to be exact zero and the
   real-plus-Eq.-(46) simple pole to be exact zero for every field. A timeout,
   memory failure, unevaluated residual, warning, or merely numerical zero is
   a production failure; write an exact atomic diagnostic before stopping.
8. Save the exact finite factorized Pg and PPP coefficient pairs and their
   actions on arbitrary `S10ConvolutionTest`. The result must contain no
   `epsilon`, `SeriesData`, `S11SEpsilon`, S11 test head, unresolved endpoint
   distribution, `DiracDelta[s23]`, machine number, or accidental QCD symbol.
9. The additional S12 multiplicative weight is exactly one. Preserve the
   charge-stripped BigTMD-channel-5A convention, the sole spectator `1/2!`
   already applied at S08, and the absence of LO and virtual Hqqbar terms.
   Continue to defer `Sum_q e_q^2 f_q D_qbar`; do not add a flavor
   multiplicity, second symmetry factor, virtual/Hermitian projection, or
   cross-channel result.
10. S12 stops after finite factorized projector actions. Paper Eq. (9)
    inversion, F-hat extraction, physical flavor/charge convolution, and
    BigTMD comparison are S13-or-later work and must not be performed or
    claimed here.

### S12 color-canonicalization correction and resume policy

The first S12 production attempt completed all 154 expression-bound S10
Laurent term caches and both projector aggregates, then stopped at the Pg
simple-pole gate.  The exact saved residual factors by
`FeynCalc`CA - FeynCalc`SUNN`: S10 retains FeynCalc's SU(N) dimension as
`SUNN`, while S11 writes the same invariant as `CA`.  S12 must therefore
canonicalize `FeynCalc`SUNN -> FeynCalc`CA` before pole reduction and finite
action construction.  This is a notation correction at the S12 combination
boundary, not a change to the accepted S10 real action or S11 counterterm.

The completed term coefficients remain exact and reusable because the
Laurent extraction itself is unchanged.  A corrected-source resume may
atomically migrate a term cache from the one exact pre-correction S12 source
SHA-256
`4341ba8d3280365ea8a26ad7403c76221acf0e9fb7eb1f33efd5bd79e52bc42e`
only after revalidating its schema, stage, exact S10 hash, projector, family,
position, source-term hash, Laurent powers, coefficient purity, and absence
of accidental QCD contexts.  Migration changes provenance only; it must not
change the cached coefficient.  Aggregate caches and completion markers are
then regenerated from the migrated term payloads so that their constituent
file hashes bind the corrected source.  The small mapped-counterterm cache is
also regenerated under the corrected source hash.  No other legacy source
hash is compatible.

Before a corrected production resume, no-write preflight must prove the
`SUNN -> CA` regression exactly, rederive the S10 partitions and
representative Laurent coefficients, and validate every legacy term cache
eligible for migration.  The final result must be free of `SUNN` as well as
the previously forbidden epsilon/series/context artifacts.  If any term
cache fails compatibility validation, only that originating term and its
dependent aggregate are invalidated and recomputed.

### Accepted S12 result

The corrected S12 production completed successfully in one resume epoch.
The accepted source SHA-256 is
`b56647afa5e8cb07bbaccce9bdeff84552cd9d3ef968deec543cd11a4f599e9f`;
the accepted `s12_result` is 7,072,450 bytes with SHA-256
`30f979da9279ff538fb2974f8639140a941194f8868cbadaf82953decf8f11ba`.

- all 154 term payloads passed exact compatibility checks and were
  provenance-migrated with their coefficients unchanged; no Laurent term was
  recomputed
- the six aggregates, two completion markers, and mapped Eq. (46)
  counterterm cache were regenerated and bind the corrected source
- every Pg and PPP `epsilon^-2` and `epsilon^-1` action component is exact
  zero after `SUNN -> CA` canonicalization
- every saved production check and every independent result/cache validation
  gate is true; the finite coefficient pairs and actions contain neither
  `SUNN`, epsilon/series artifacts, nor machine numbers
- the obsolete failed-residual diagnostic was deleted after its regression
  passed; no S12 temporary file, OOM, kill, timeout, or corrected-run fatal
  marker remains

S12 stops at the exact finite factorized Pg/PPP actions on arbitrary
`S10ConvolutionTest`.  Paper Eq. (9) inversion, F-hat extraction, physical
flavor/charge convolution, and BigTMD comparison remain S13-or-later work.

## S13 contract — Eq. (9) inversion and finite Hqqbar F-hats

S13 consumes only the accepted corrected S12 result and is the first stage
allowed to combine Pg and PPP.  Its entry point is
`s13_extract_fhat_hqqbar.wl`.

1. Load FeynCalc before `Get`.  Pin the exact accepted S12 source SHA-256
   `b56647afa5e8cb07bbaccce9bdeff84552cd9d3ef968deec543cd11a4f599e9f`,
   S12 result SHA-256
   `30f979da9279ff538fb2974f8639140a941194f8868cbadaf82953decf8f11ba`,
   and paper SHA-256
   `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.
   Require the complete `HqqbarS12-v1` schema, every saved check, exact-zero
   complete pole association, current program binding, and accepted
   S10/S11/paper provenance.
2. Apply the paper Eq. (9) partonic inversion exactly in
   `D=4-2 epsilon`:
   `F1Hat=(-Pg/2+2 xHat^2 PPP/Q2)/(1-epsilon)` and
   `F2Hat=-xHat Pg/(1-epsilon)+4 xHat^3(3-2 epsilon)
   PPP/(Q2(1-epsilon))`.  S12 proves the negative epsilon powers vanish
   separately for each projector and field, so no epsilon-dependent inversion
   weight can feed a pole into the finite coefficient.  Only after this gate
   may S13 use the four-dimensional weights
   `{-1/2,2 xHat^2/Q2}` and `{-xHat,12 xHat^3/Q2}`.
3. Use only S12's exact `FiniteCoefficientPairsByProjector` and physical map
   `xHat=xB/xi`, with interval
   `{s23,0,Q2(xi/xB-1)(1-zH)-PHT2/zH}`.  Require exactly Pg and PPP and the
   three fields Endpoint, IntegrandPhiS, and IntegrandPhi0.  Do not recover
   coefficients by parsing the rebuilt S12 actions.
4. Combine Pg and PPP field by field with an exact two-by-two weight matrix.
   Prove symbolically that its inverse reconstructs independent dummy Pg/PPP
   coefficients and that its determinant is `-4 xHat^3/Q2`; do not use
   decimal conversion or numerical kinematics as an inversion test.
5. Save both exact F-hat coefficient pairs and rebuild one ordinary inactive
   `s23` action for each of `F1Hat` and `F2Hat` on a matching arbitrary
   `S13ConvolutionTest`.  Remove the projector-labelled S10 test heads; retain
   the physical integration interval and all exact endpoint/regular fields.
6. Require the output pairs/actions to contain no epsilon, `SeriesData`,
   machine number, `SUNN`, unresolved S09/S11 distribution/test object,
   accidental Global-context QCD symbol, or failure/infinity object.  Add no
   `Re`, `Im`, `Conjugate`, or Hermitian projection; S12 has already produced
   the accepted physical finite actions.
7. The additional S13 multiplicative weight is exactly one.  Preserve the
   charge-stripped same-flavor convention, the sole spectator `1/2!` already
   applied at S08, the finite scale dependence inherited from S12, and the
   exact absence of LO and virtual Hqqbar pieces.  Do not add a flavor
   multiplicity, second symmetry factor, physical charge, or concrete PDF/FF.
8. Bind the pinned BigTMD channel-5A reference files: Pg/Ppp `fchn5A` are the
   nonzero projector modules, while every channel-5 B/C module is the same
   exact-zero file.  Record that the shipped `sidis.py` loop omits channel 5
   and would not exercise those functions.  This is a provenance/convention
   gate only; S13 must not translate the decimal Python formulas, construct a
   BigTMD benchmark, or claim agreement.
9. Provide a no-write preflight that exercises the complete source/result,
   Eq. (9), map, pair-schema, exact-inverse, color, and bookkeeping gates.
   Process the modest accepted S12 result and both F-hats serially; subkernel
   copies would add memory pressure without accelerating either exact linear
   combination.  Write `s13_result` atomically and reload-validate it against
   the exact current S13 source and S12 hashes.
10. S13 stops at exact finite charge-stripped `F1Hat` and `F2Hat` actions.
    The outer xi convolution, physical
    `Sum_q e_q^2 f_q D_qbar`, numerical PDFs/FFs or kinematics, cross-channel
    sum, and explicit BigTMD comparison remain downstream.

### Accepted S13 result

The logged S13 production completed with
`S13_SUCCESS_FINITE_FHAT_HQQBAR` and exit status zero.  The accepted source
SHA-256 is
`760cad942ee628c0e3de3b76362cbbb103bf6c8d9c920983b84f717b5adf1f13`;
the accepted `s13_result` is 14,891,953 bytes with SHA-256
`4224b46a064087ed3b20e36a049dd1929019f66583263fcb2c28c9b69614c64f`.

- every saved pair, function, and final validation predicate is true
- the only structure-function keys are `F1Hat` and `F2Hat`, each with exact
  `Endpoint`, `IntegrandPhiS`, and `IntegrandPhi0` coefficient fields
- both rebuilt actions are ordinary root-level inactive `s23` integrals on
  the physical interval, and neither the pairs nor actions contain machine
  reals
- the corrected log contains no fatal, OOM, kill, timeout, abort, or
  termination marker

This result is the accepted exact, finite, charge-stripped Hqqbar input for
the separately authorized downstream BigTMD comparison.

## BigTMD check contract — channel 5A regular coefficient

The authorized check lives in `bigTMD_check/` and consumes only the accepted
S13 result above plus the pinned BigTMD snapshot already stored under
`scripts/Hqq/bigTMD_check/BigTMD_reference`.

1. Bind the local input to `HqqbarS13-v1`, source SHA-256
   `760cad942ee628c0e3de3b76362cbbb103bf6c8d9c920983b84f717b5adf1f13`,
   result SHA-256
   `4224b46a064087ed3b20e36a049dd1929019f66583263fcb2c28c9b69614c64f`,
   and the all-true S13 pair/function/final check ledgers.  Bind the reference
   driver and channel-5 A/B/C projector modules to the hashes stored in S13.
2. Compare BigTMD channel 5, charge case A, for the observed antiquark.  The
   physical `Sum_q e_q^2 f_q D_qbar` luminosity remains deferred on both
   sides.  Add no case-B/C sum, flavor multiplicity, reference charge, or
   second identical-spectator factor.
3. Follow the pinned `sidis.py` distribution assembly, not merely the
   existence of generated module functions.  The driver restricts delta and
   plus terms to channels below 4, so channel 5 is regular-only.  Require the
   local S13 `Endpoint` and `IntegrandPhi0` fields to be exact zero and compare
   only `IntegrandPhiS` against the A-module `regular` functions.  The
   nonzero channel-5A `delta`, `plus1B`, and `plus2B` functions are not part of
   this driver convention; all B/C functions are exact zero.
4. Use physical interior benchmarks satisfying `PHT2=zH^2 qT2`,
   `xHat=xB/xi`, and `0<s23<B`.  BigTMD invariants are
   `s=Q2(1-xHat)/xHat`,
   `zHat=((1-xHat)-xHat s23/Q2)/((1-xHat)+xHat qT2/Q2)`, and
   `t=-(1-zHat)Q2-zHat qT2`.
5. The local coefficient already contains the exact `zeta -> s23` Jacobian
   introduced upstream.  Multiply each BigTMD regular projector by the same
   driver Jacobian
   `zeta xHat/(Q2 ((1-xHat)-xHat s23/Q2))`.  Keep the remaining driver factor
   `zh/(xi zeta)`, PDFs, FF, and xi integration inside the deferred arbitrary
   test function; do not apply that factor to only one side.
6. Set `EL=1`, `g_s=1`, `ScaleMu=Q`, `CA=3`, `CF=4/3`, and `TF=1/2`.
   Construct reference F hats with the paper/driver four-dimensional weights
   `F1Hat=-Pg/2+2 xHat^2 Ppp/Q2` and
   `F2Hat=-xHat Pg+12 xHat^3 Ppp/Q2`.
7. Preserve the accepted local expressions symbolically and exactly through
   rational benchmark substitution.  At the user's explicit instruction,
   execute BigTMD's decimal Python coefficients as written rather than
   rationalizing them.  Numerical comparison is evidence about the pinned
   decimal implementation at the selected benchmarks, not a replacement for
   the exact S13 result.
8. Write compact local, reference, signed-difference, and Markdown-report
   artifacts atomically.  Report `BigTMD - local`, every benchmark and F hat,
   maximum absolute/relative differences, tolerance, and whether all tested
   coefficients agree.  A completed mismatch is a valid check result and
   must not be hidden by editing either calculation or reference output.

### Completed BigTMD check result

The check was completed at three physical interior points using the pinned
decimal channel-5A functions exactly as written.

- S01 source SHA-256:
  `a6fc0f9bd09f2e4faa67bdaea04ab8538f6f70a25bf2ca3ec6d7ae3a460b8435`
- local benchmark SHA-256:
  `1d33d0b1a06720a71491102cf8fce4cf48e00011ea08b34fe9bd7ce89e58b90e`
- S02 source SHA-256:
  `c5361f7567974ead535b47ebf34e736ed0b0712e42757830a5ce40059c488e4b`
- BigTMD benchmark SHA-256:
  `28ca192823b7b0d75a662dd63ba5cf1bab5eb4db5e77d4f45d56ec18ab77f8dd`
- signed-difference JSON SHA-256:
  `498758a707db5e3b4e7595098a73af5a87225a0b6f55ea37ae722076cd90790a`
- Markdown report SHA-256:
  `da0dbdfae07d0f0264c28d468311e637cdc4081ff2aee0712f9f85d9ee9bb102`

All channel-5 B/C functions are exact zero, and the endpoint/subtraction
fields agree at exact zero under the driver's regular-only selection.  None
of the six nontrivial F1Hat/F2Hat regular comparisons passes
`abs(diff) <= 10^-10 + 10^-7 max(abs(BigTMD),abs(local))`.  The maximum
absolute difference is `1.7747856338187397 10^-6`; the maximum relative
difference is `0.71327847294978641`.

The current S09/S12 source confirms that the local kernel contains exactly
one `d zeta/d s23` Jacobian, algebraically identical to the one applied to the
BigTMD regular functions in this check.  F-hat and inverse-reconstructed
projector ratios vary with the point and projector and even change sign, so
the mismatch is not one omitted overall charge, symmetry, Jacobian, or
normalization factor.  The pinned driver never executes channel 5 in its
active loop; this explicit comparison therefore exposes disagreement in
otherwise dormant channel-5A formulas.  No accepted local result, macro, or
BigTMD reference file was edited to force agreement.

## Independent MadGraph tree-real check

The isolated `madgraph_check/` workflow compares the current Hqqbar real
matrix element with MG5_aMC 3.7.0 for the photon-only eight-diagram process
`e- u -> e- u u u~`. All physics inputs are byte-identical S06/S07/S08/S10
copies; no accepted Hqqbar source, cache, macro, or result was changed.

An unrestricted four-dimensional comparison to raw S08/S10 is mathematically
undefined: at an interior rational `s23` point, copied S10 has nonzero simple
collinear poles in both projectors (`Pg` `2.28771661166253e-8/epsilon`, `PPP`
`-9.36688755227388e-6/epsilon`). Therefore the valid raw-real comparison uses
the copied pre-angular S06/S07 matrix with identical invariant separation
cuts, before any S11/S12 factorization counterterm.

The local charge/spin/color/symmetry normalization was first checked against
a four-angle MadGraph azimuthal average at fixed invariants and agreed to
`2.4023e-15` relative. The production common sample then used 120,000
deterministic massless four-body RAMBO trials, of which 27,851 passed the
fixed infrared-safe bin. Results are:

- MadGraph: `3.66827994997779932e-4 pb`
- copied-S07 local: `3.66827994997779769e-4 pb`
- ordinary Monte Carlo standard error: `5.98431860980528321e-6 pb`
- integrated relative difference: `4.43807371508019922e-16`
- pointwise median / 99th percentile / maximum relative differences:
  `3.3285e-15 / 6.6937e-14 / 2.1790e-11`

The detailed normalization ledger, cuts, stage map, and hashes are recorded
in `madgraph_check/README.md`; the primary result is
`madgraph_check/s12_integrated_comparison.json`.

## Rules for later stages

- Start each newly authorized script with the next sequential `sNN_` prefix.
- Bind every cache/result to the exact source and upstream SHA-256 hashes.
- Write production and resume artifacts through temporary-file-plus-rename;
  never overwrite the only valid checkpoint in place.
- Preserve coherent interference before any diagram grouping.
- Add electromagnetic Ward-identity gates when an open photon tensor first
  exists.
- Keep Pg and Ppp separate until the paper Eq. (9) inversion.
- Compare explicitly against BigTMD channel 5A at matched flavor,
  normalization, Jacobian, scale, and distribution conventions.
