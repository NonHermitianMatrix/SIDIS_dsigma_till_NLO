# Hqq: incoming quark, tagged same-flavor quark

The reference assigns the incoming quark momentum `p` and the tagged quark
momentum `k1`. Its sectors include quark–gluon recoil at Born/virtual level
and quark/gluon or quark-pair real final states. Keep the separate
same-flavor and distinct-flavor components and their charge bookkeeping.

## S01 inputs

`s01_prepare_inputs.py` uses the shared S01 implementation to validate this
channel's selected pinned open-amplitude inputs. `s01_result/` owns its
input receipt. Inherited spin averages and spin-summed tensors are
unpolarized reconstruction references, not polarized production tensors.

## Spin-dependent contract

Retain incoming and tagged outgoing spin information in the new tensor.
Derive its contractions, normalization, flavor weights, and required
subtraction from the selected measurement and spin basis. Do not infer a
spin-transfer coefficient from the old F1/F2 values.

All later accepted sources and results use consecutive `sNN_` stage names.
The common README defines review, cluster, and acceptance requirements.

## S03 four-dimensional verification result

`../common/s03_born_spin_response_exact.wls` passed 38 checks in Hoffman2
job `14773778` on `n6408`. The saved result is
`s03_result/four_dimensional/s03_result.wl`, SHA256
`9f8425fb1e8cadc7d8771cd1ac7808459070b7efacebe6258db3efdd09644883`.
Its `[photon, outgoing spin, incoming spin]` array has dimensions `9,4,4`
and 22 nonzero components. The accompanying checks and execution receipt
bind the source and inputs. The run passed both Ward checks, Hermiticity,
spin/photon reconstruction, and the original unpolarized Pg/Ppp comparisons.

This result has no phase-space factor or NLO corrections. Its role is the
four-dimensional verification input for the dimensional Born calculation.
The cluster copy is `cache/s03_exact/Hqq/s03_result.wl` under the isolated
polarized-SIDIS root. It must remain available for the dimensional job.

## S03 dimensional Born result

`s03_born_spin_response.wls` links to the shared reviewed implementation.
Its `s03_result/s03_result.wl` passed 47 checks in Hoffman2 job
`14773799` on `n7441`; SHA256
`99dff181bf85da2d93376236b37b98e116f5965d5015cba01eb150bb19e5c9cc`.
The physical response has indices `[photon, outgoing spin, incoming spin]`
and dimensions `9,4,4`, with 24 nonzero dimensional entries.
The internal gluon E component and photon metric complement retain the
regulator information needed to reproduce the full dimensional unpolarized
Born Pg/Ppp. All physical spin components match the independent four-dimensional
verification result. Ward identities, Hermiticity, and reconstruction passed.

The checks and execution receipt are in the same result directory. The
four-dimensional reference is under `s03_result/four_dimensional/`. These
are Born tensors without phase-space factors; they are inputs to NLO
subtraction and are not finite NLO F hats. Peak child RSS was
303656960 bytes.

## S07 virtual tensor contract

Use the shared `s07_virtual_spin_response.wls` and its common README
contract. Keep this channel's original generated loop amplitudes, massless
quark specialization, charge normalization, and tagged momentum.
`s07_result/reference/unpolarized_virtual.wl` is the pinned original
pre-Hermitian virtual mapping result and serves only as an integrand
reconstruction check. Native spin closure precedes physical spin projection;
the complex virtual interference is retained until scalar integration.

## S09 virtual scalar-mapping contract

Use the shared S09 adapter and this channel's original per-diagram
topologies. Preserve complex interference coefficients and the physical
spin basis. Each CDR projection must reconstruct its saved reduced
unpolarized counterpart; every new integral must have a verified
reduction before downstream integration.

## S11 spin subtraction contract

Use the shared S11 program with this channel selection. Its reference
source and result are under `s11_result/reference/`. Retain the accepted
physical Born spin axes under the derived PDF/FF momentum rescalings,
contract S10 kernels in their recorded index order, and verify every
original CDR convolution before accepting the new spin counterterms.
The result retains the reference endpoint distributions and prefactor.
It is a BMHV subtraction input; finite axial-scheme conversion and
complete real/virtual pole cancellation remain final-assembly gates.

## S05 real tensor contract

Use the shared S05 contraction and acceptance gates with this channel's
generated fields, momentum assignments, charges, and spectator weight.
The original tensor in `s05_result/reference/unpolarized_real.wl` is an
exact unpolarized reconstruction check. Preserve all physical incoming
and tagged outgoing spin components and the internal dimensional gluon
complement where present. Independent diagram pairs use allocated local
kernels with separate projection checkpoints; require Ward identities,
Hermiticity, spin reconstruction, and both original scalar projections.
This stage supplies an angular-averaged tensor before scalar integration
and factorization; it does not export finite NLO coefficients.

### Accepted complete S05 real tensor

Hoffman2 job `14813560` on `n7107` passed all 184 recorded checks,
including every RealQGG, RealSame and RealDistinct pair, sector Ward and
Hermiticity checks, exact photon/spin reconstruction and all original
dimensional Pg/Ppp charge components. The accepted entry point is
`common/s05_real_spin_response_proven_reconstruction.wls`, SHA256
`e8dacabc2f79fff22b2bd2eece599d516c795b9075aacffb60138ec84d65c3bb`. It reuses the own accepted structural reconstruction
through the original checkpoint interface.

The result loader `s05_result/s05_result.wl` has SHA256
`e46d13e0db202860004cb323c655ce803d68df2f2392436c388afd342dd56076`. Keep its three payload files beside it; the authoritative
`s05_result/s05_payload_manifest.json` has SHA256
`665c04ba01c2d1791b09f3951c942192eefa45644a23585c395f89ffdcf270ed` and binds all 72585282 stored bytes. The complete saved
expression passed exact native reload. Load FeynCalc before loading the
result through its existing Get interface.

Checks SHA256: `e1ad071db2beb72cd0f9d906bc03055c2275c2c8a322d75e86a54dc4e87f2b1e`.
Execution receipt SHA256: `0e2c4adb2398adb8262852fd2ae128145e86b421b858148af8ba1c53bb937f4b`.
The verified local native log is `s05_result/s05_native.log`, SHA256
`d9b28bfdd3dee07d8ae8adf29672a38a5a0ca28a39504fa1afc383423de3563c`; its cluster source is
`cache/s05_Hqq_proven_reconstruction_continue.log`.
Runtime was 9187.86829008162 seconds; reported peak child RSS was 5524340736 bytes.
All listed result artifacts and payloads are hash-verified locally.

S08 consumes this complete tensor with the inherited frame, dimensional
complements, sector charges and coupling normalization. Scalar reduction,
integrated real distributions and complete S14/S15 acceptance are required
before this channel supplies finite NLO hats.

The scheduler allocation amendment for job `14795983` is recorded in
`../.cluster/s05_result/s05_Hqq_allocation_adjustment.json`. Despite the
original `eight_worker_resume` tag, its pending request was changed to
four shared slots with 8 GiB per slot, preserving 32 GiB total, the four-hour
wall limit, and the unchanged calculation configuration and cache. The native
worker count follows `NSLOTS`; it must not be inferred from the job name.

## S12 integrated real tensor contract

Use the shared S12 program after this channel's scalar map has complete
verified reduction coverage. Preserve the generated charge and spectator
bookkeeping and evaluate the measured transverse factor in every endpoint
limit. The reference cut masters and distribution assembly supply the
Delta/L0/L1/regular tensors before final normalization and subtraction.

## S11 accepted subtraction tensors

Job `14774696` on `n6131` passed every original CDR convolution and
spin-dependent route check. `s11_result/s11_result.wl` has SHA256
`425903851318644ff1f737337a55c82f0708053eadff38da671e69549357c4e3`.
Its checks and execution receipt are saved alongside it. All four PDF/FF
routes retain the reference roots, Jacobians and distribution convention.
The endpoint branch comparisons are exact on the recorded physical domain.
The source is `../common/s11_collinear_spin_convolutions.wls`, SHA256
`9c5784631fbeb46741b274186985fb21f1607d4063525025517bb0560f11de96`.
Runtime was 1215.614197 seconds and peak child RSS was 397848576 bytes.
These are BMHV subtraction tensors, before finite scheme conversion and
complete real/virtual pole cancellation.

## S13 renormalized virtual tensor contract

Use the shared S13 adapter only with this channel's accepted S07 and S09
results and complete reduction coverage. Preserve the physical master
continuation, complex interference, loop measure and generated external
field bookkeeping. Require new-spin UV cancellation, original CDR UV
reconstruction, and integrated Ward checks. Its Laurent tensors require
real and collinear assembly before they become finite F hats.

The compact virtual source SHA256
`daca2aaa7d7253bbf0d9f0a48a88cac14bdd2b41b21f1e678b201cde6656a00b`
passed job `14774851`: the full accepted Born spin response and all Hqq
diagram-1 photon, extended-spin, metric and Ward data matched exactly.
The comparison and execution receipt are under `Hqq/s07_compact_result/`.

Independent virtual diagrams may use allocated parallel kernels. Preserve
the accepted compact source in `s07_result/reference/` and require native
byte equality of the complete contraction definitions and diagram algebra
before reusing its input-bound checkpoints. The mathematical input hash
uses that accepted calculation source; the final result separately binds
the current dispatch source. Each worker initializes the same scalar
products and regulator scheme, owns disjoint diagram checkpoints, and
retains every diagram's original CDR reconstruction gates.

S13 reference validation passed in job `14775246` on `n7126`: both
original Hqq UV residues were reproduced, the auxiliary reduction
interfaces passed, and the seven physical master continuations retained
their original accepted source/input identities. The result is
`Hqq/s13_validation_result/s13_result.wl`, SHA256
`e1c9524478eac0360e42d52fcbbf856448a1ed6fc46d9d3c6b1cbd25932cbb2a`.
The reviewed source SHA256 is
`398f7b9692a5eea3ce1092aa9a6913ce6ff4ae42e6ba1b9bec5b88a6fab5e595`.
The 109.305-second validation peaked at 423800832 bytes child RSS. This
accepts reference reuse and the UV interface; new-spin integration and
componentwise UV cancellation still require the accepted S07/S09 inputs.

`s07_scalar_interface_check.wls` inspects the first missing projection
using the unchanged production definitions and actual open amplitude. Its
result records any remaining native tensor/color objects and the exact
expression; it is diagnostic evidence, not an accepted virtual tensor.

## S14 finite assembly contract

Use the pinned GitHub S20 phase-space, flavor and endpoint assembly with
accepted S12 real distributions, S13 renormalized virtual tensors and S11
spin subtraction. Require every negative regulator power to vanish for
each physical photon/outgoing/incoming spin component, on both branches
and their common boundary. Reconstruct the photon tensor and apply the
original F1/F2 projectors as additional outputs. Preserve explicit charge
weights and small-channel coupling factors; small S11 counterterms already
include phase and coupling normalization. Finite minimally subtracted BMHV
results must retain their scheme label and cannot certify completion of
the finite axial conversion or compatibility with standard helicity fits.

Photon-axis substitution must handle both four-dimensional and
D-dimensional native external indices; evanescent components vanish
against the recorded physical axes. Before using the corrected interface,
require exact comparison with explicit native contraction on the actual
failing Hqq virtual diagram and equality of all projections on the
accepted first-diagram and real-pair validation inputs. Preserve completed
scalar checkpoints only after these input-bound checks pass.

The complete native photon-index projection passed job `14775402` on
`n7368`. `Hqq/s07_photon_projection_result/s07_result.wl` has SHA256
`bec859612c1056d0befabb981be4734fd9c8021b5bc203a6ceeb6b8fb080055f`.
All dimensional-index interface checks and every explicit projection on
the failing diagram passed; every first-diagram projection was unchanged.
The originally failing projection is now fully scalar. Checks and the
execution receipt bind the inputs. This accepts the interface correction,
not a complete virtual tensor or an integrated coefficient.

The coordinate and complete photon interfaces passed job `14775503` in
97.143 seconds, with 291123200 bytes peak child RSS. The result is
`Hqqprime/s05_interface_result/s05_result.wl`, SHA256
`eed6f9e3bd8316c5e82ffa0c30abaef524729f639e2070e478ba5503b35ae5e3`.
The coordinate map reconstructs every defining scalar product and agrees
with the prior conditional solution on the physical domain. All native
photon projections and the entire accepted first-pair matrix are unchanged.
The reviewed interface source SHA256 is
`b3452147d90346bf2e793be9508096df2dd382d56e99f7ec713b075809f5b959`.
The corrected production source is
`bc2ef4236aff147c1b1166c8ee774040746dcc915f416cf3d83ccdd3e5aabf69`.
It preserves the compact calculation hash and completed scalar checkpoints;
the coordinate gate now precedes contraction. This comparison does not
accept a complete real tensor or a finite coefficient.

## S15 final helicity-scheme contract

Use the accepted S11 route inventory, roots, Jacobians, Born tensors and
convolution function for the finite axial restoration. The scheme definition
is fixed by hep-ph/9612250 Eqs. (16), (46), (47) and its stated time-like
counterterm, with the hard-insertion sign verified against the supplied
standalone factorization contract. Derive the normalization ratio from the
saved quark kernel and require the full Born/coupling prefactors to agree.
Only the quark/antiquark helicity operator receives this conversion; prove
its zero endpoint distributions with the inherited convolution routine.
A scheme-only result is an assembly input. Final S15 export additionally
requires accepted S14 componentwise pole cancellation and records both
upstream identities and the applied finite conversion. Numerics and jet
matching remain outside this partonic result.

S14 must also reproduce the pinned final GitHub F1/F2 hats in its U/U
component, including Born, both distribution branches and their common
boundary. The immutable comparison hats are in s14_result/reference and
are bound by common/s14_inputs.json. They are validation inputs only.

The S15 finite scheme tensor passed Hoffman2 job `14775514`.
`s15_scheme_result/s15_result.wl` has SHA256
`71594bc157c0922ce84c10d19d2bd6ec3dd6d57ad38e1bb85649471bfcbb5268`. All normalization, helicity-index,
endpoint and unpolarized-preservation checks passed. The source SHA256 is
`54838cdee6222b75e578a242a940bdb79bd1517d41e098cbd9ca18fd369463f8`.
Checks and the execution receipt accompany the result. This accepted finite
conversion still requires the complete S14 tensor before final S15 export.

S05 final output uses a native `Compress` expression read by the unchanged
`Get` interface. Require exact equality after reloading the actual saved
result and retain the 128 MiB file limit. This storage change leaves all
contractions, scalar checkpoints and reconstruction gates unchanged.

S14 final-reference comparisons convert `Q2 -> Q^2`, `w -> s23` and
``Nc -> FeynCalc`SUNN``, following the accepted small-channel subtraction
conventions. Require the reference hats to contain no remaining legacy
kinematic/color names or accidental global color symbols.

S07 passed Hoffman2 job `14775499` on `n6443`. The complete virtual spin
integrands for all 15 original diagrams passed their native contraction,
worker, Born and CDR Pg/Ppp reconstruction checks. The result is
`s07_result/s07_result.wl`, SHA256
`d459114a553aa7a8d9ee9165f502d337940db0dadf7abc0f3e46385d031d3ec5`.
The checks and execution receipt accompany it. The source SHA256 is
`3bf664aa2860ec32df9570f7d8832ccd868b2add23f5125a35f465e87862cff5`.
Runtime was 5785.169 seconds; peak child RSS was 1252569088 bytes and
peak sampled process-tree RSS was 4436369408 bytes. S09 must map these
integrands before S13 integration and UV renormalization.

S09 mapping passed job `14777379`; `s09_result/s09_result.wl` has SHA256
`2cb05618d7865efc87f75e60e94d5d717bd146b256b435b6f8043daffd97d549`.
It mapped all 15 diagrams and identified eight additional scalar targets.
The complete reduction passed job `14778290` in 439.356 seconds with
523460608 bytes peak child RSS. Every original Kira rule matched, the
seven-master basis was unchanged, and complete coverage and master depth
passed. The completed map `s09_reduction_result/s09_result.wl` has SHA256
`77b67c7e2d8994561df91693ab88e76da661a18aebb8290b4219741acdb35bf9`;
its `s09_reduction.wl` has SHA256
`7bee4b807d7d70678ff26f867d2b3ff333547fb0de33555a8c7e77778b1b0d1a`.
Checks and execution receipts accompany both outputs. The extension source
is `common/s09_extend_virtual_reduction.wls`, SHA256
`1e60cbbacb7919ca6a57a130cac2fee3ea6aeee2a7ddba14a634c8df9598fd71`.
S13 consumes the completed map through `POLARIZED_SIDIS_VIRTUAL_MAP`;
loop integration, renormalization and final pole cancellation remain required.

S05 resource resumes preserve the complete accepted contraction and exact
spin-reconstruction predicates, verified against the archived dispatch source
`common/s05_result/reference/s05_real_spin_response_before_resource_resume.wls`.
Only final spin reconstruction may use a 4 GiB native allocation; all other
operations retain 2 GiB, and scheduler/process-tree guards remain mandatory.
Every replacement worker must initialize FeynCalc, BMHV, scalar products and
the recorded node/runtime before processing a task. Completed input-bound
checks and contractions remain reusable. The optional scalar-restoration path
requires the complete accepted Hgg comparison and installs its exact saved
definitions; it cannot run on an unaccepted candidate.

S08 target mapping is shared by all six channels. It reads the immutable
original mapper, verifies the complete unchanged mapping/checkpoint block,
and retains the original calculation hash for completed target checkpoints.
Each new channel first reproduces the pinned complete Hqqprime control map
with its worker; the native measured scalar products must agree exactly.
The remaining components retain their own complete reconstruction and cut
checks. The native component bounds default to 3600 seconds and 2 GiB.
Resource resumes may set POLARIZED_SIDIS_TARGET_SECONDS and
POLARIZED_SIDIS_TARGET_MEMORY_GIB explicitly within the scheduler and
process-tree limits; this leaves all equations and checkpoint identities
unchanged. Completed components are reused. Final maps use native compression with an
exact Get round trip and the same downstream schema. Each channel still
requires complete target coverage, integration and finite assembly.

### Auxiliary UV target extension contract

`s13_extend_uv_reduction.wls` reads the actual missing-target packets saved by
S13, pinned in `s13_uv_reduction_result/inputs/`, and extends the original UV
Kira table. Its configuration and native reader are copied byte for byte from
the pinned GitHub `s14_uv_residues.wl`. Requested targets are the union of the
recorded polarized targets and the original targets, rules, and masters. All
original rules must agree exactly, all requested targets must reduce, and the
original auxiliary master basis must be unchanged. The accepted extension may
then supplement S13 without invalidating checkpoints already evaluated with
the original rules. It does not change the UV expansion or evaluate new masters.

The S13 consumer accepts the extension only through
`POLARIZED_SIDIS_UV_REDUCTION=<channel>/s13_uv_reduction_result/s13_result.wl`.
It verifies the extension, source, input hashes, original master values, family
definitions, and exact original rules before supplementing the table. A full
source comparison against the accepted parallel implementation gates unchanged
UV expansion, task execution, physical integration, and counterterms. The
original checkpoint identity is preserved only because every original rule is
reproduced; extension provenance is recorded separately in the final result.

The auxiliary extension was accepted by Hoffman2 job `14779887` on `n6133`
in 36.10 seconds. Source `common/s13_extend_uv_reduction.wls` has SHA256
`d04c5cc50a2cf597c35e2d2952a83a066d86d45700dfce33f0c02de38e53a0e2`.
Accepted result `Hqq/s13_uv_reduction_result/s13_result.wl` has SHA256
`d3fa0bb8f1dd3460215a79fd650e0bd1bf519d1fde78bc29b251eabaf2ffe68c`;
its checks and execution receipt are in the same directory. The recorded new
target reduced, all original rules agreed, the master basis was unchanged,
and native save/reload was exact. This accepts the auxiliary table, not a
finite partonic coefficient. Production S13 uses the optional table reader
with the original successful UV checkpoints and retains final UV cancellation.

The complete S13 virtual assembly passed all 187 checks in Hoffman2 job
`14782369` on `n1158`, including componentwise UV cancellation, integrated
photon Ward identities, and the complete virtual component inventory.
`s13_result/s13_result.wl` has SHA256
`206a3bd85d0575ef58fbe26a192d4ac1690b11a12ee34273b9d672c5f0519d5d`.
The checks and execution receipt are saved alongside the result. The
accepted source is `common/s13_assemble_virtual_spin.wls`, SHA256
`cb690814cc4ae374503ac0f6af01a435e0f37a6076cc6cac081e483fee867c7f`;
the execution log is `cache/s13_Hqq_checkpoint_resume.log`. This result
uses the accepted complete S09 map and auxiliary UV table recorded above.
S14 consumes it together with the accepted real and subtraction tensors;
complete infrared pole cancellation and finite export remain S14/S15 gates.

S05 projection resumes may set `POLARIZED_SIDIS_REAL_SECONDS` explicitly
(the default is 2400 seconds, with a checked maximum of 10800 seconds).
This changes only the native time bound. The 2 GiB operation limit and
4 GiB spin-reconstruction limit, all contractions, checks, and checkpoint
identities remain unchanged. The scheduler and process-tree limits must
cover the selected bound. Preserve the preceding source in
`common/s05_result/reference/s05_real_spin_response_before_projection_time_resume.wls`.

## Completed-stage cache archives

After accepted S05 job `14813560`, the existing completed-stage archive
routine may preserve `cache/s05/Hqq/` in lossless, size-bounded archive parts
under `s05_result/`. Require the accepted producer receipt and result hashes,
no active S05 writer, and no active downstream job binding these cache paths.
Verify every member's byte count and SHA256 after reading each archive back;
publish the complete restore manifest before removing raw duplicates. S08
continues from the accepted tensor loader and its three bound payload files.
Restore and hash-check the archived paths before repeating the S05 producer
or an earlier comparison that consumes them directly.

S05 archive job `14813857` passed in 46.84581630700268 seconds and preserved all
793 cache files (184140870 logical bytes) in 44042222 archive bytes.
The verified local `s05_result/s05_cache_manifest.json` has SHA256
`907fc1b575b141999a7fbb1734671a8636325443e83c46bb030e0bab12df07ab`; it binds both archive-part identities, every original
member path, size and hash, and accepted producer job `14813560`.
The archive execution receipt SHA256 is
`5d77924fc95c146f058757dace2a4c9c438ef6a70c53387585209c5aa83037c8`. Both archives were copied locally and every local member
was read back and hash-verified. The accepted tensor and payloads are unchanged.

The completed S07 per-diagram cache is preserved in
`s07_result/s07_cache.tar.gz`, SHA256
`4b1a99d6de6358359f3b8c26ef68a8123e0c96df0ab8e690729bfbc787c644a9`.
The accompanying `s07_result/s07_cache_manifest.json` binds every member
to its original byte count and SHA256 and records accepted producer job
`14775499`. Every member was read back and hash-verified
before the uncompressed completed cache was removed.

The completed S09 per-diagram cache is preserved in
`s09_result/s09_cache.tar.gz`, SHA256
`33514b4745209e87a88f7fe90150036fdc251549c707266544c021bbe89104c1`.
The accompanying `s09_result/s09_cache_manifest.json` binds every member
to its original byte count and SHA256 and records accepted producer job
`14777379`. Every member was read back and hash-verified
before the uncompressed completed cache was removed.

The archives and manifests are retained locally. Remote duplicate archives
were removed only after the local and remote SHA256 and byte counts matched;
the remote manifests and accepted stage results remain available. Current
consumers read those accepted results. To resume an archived producer, transfer
the archive back with a SHA256 check, then restore its members relative to
the polarized_SIDIS root at the manifest paths and verify every member.

## S08 streamed master coefficients

After the complete target map and Kira coverage pass, use
`common/s08_map_real_spin_streamed.wls`, SHA256
`f65fbeee3345dcf281e60192a7e6ea4dfd08eb547f4aa7fb225134462e1ed601`.
It loads the exact streamed numerator and supported-factor definitions accepted
in Hqqprime job `14796343`, result SHA256
`4c87d2d584257c66bba85970d74d730c22c156a8921aa71721efb812519acae8`.
Require the matching receipt, immutable original coefficient source, native
versions and fresh-worker reference coefficient comparison. Every own-channel
coefficient retains exact term embedding, numerator summation, polynomial
quotient/remainder and reconstruction checks. An unsupported cancellation
factor remains in the exact denominator. Preserve the original physical cache
identity and downstream scalar-map schema; record the dispatch and comparison
identities separately. This algorithm acceptance is not a complete channel
coefficient or finite F hat.


## S11 intermediate-state completion

The intermediate unpolarized gluon sum in the convolution uses the accepted
Born `ExtendedResponse`, its E complement, and `CDRAverageConversion`.
Use the exact completion definition accepted by Hqqprime job `14798308`,
result `3c76ab221bf3c99ba7c35223b26ca10ec527596dc2f60307d5cc7e508dbc411c`.
The original roots, Jacobians, splitting kernels and endpoint convolution
remain unchanged. Require every own-route physical D=4 Born tensor to
agree, every route without an intermediate E state to remain unchanged,
and the complete counterterm difference to be pole-free. For external
quarks, reconstruct both dimensional reference projections from the actual
spin convolutions and their photon complement, for every distribution.
Retain the earlier source and S11/S15 scheme artifacts under their
`reference/before_dimensional_completion` owners before replacement.
S14/S15 must consume the new accepted subtraction identity; complete pole
cancellation and finite reference comparisons remain mandatory.


## S14 reference phase-series reuse

`common/s14_assemble_finite_phase_series.wls` retains the original S14
assembly and replaces only its two real-phase product operations with
the accepted S12 Laurent-product implementation. The complete source and
Hqqprime comparison `2aec26ba5852ad86bf22f5bbbc797e071005d8916de3202923d4bee33fbf74a9`
are checked before use. Each actual coefficient must reconstruct as a
finite Laurent polynomial; every occurring Laurent monomial multiplied by
this channel's own phase must exactly reproduce the original native Series
operation. Record those executed comparisons and the dispatch identity in
the result. Pole cancellation, branch boundaries, charge bookkeeping,
original F1/F2 comparisons and export gates remain unchanged. The adapter
is not an accepted channel result until those native checks pass.


## S11 completion by convolution difference

Job `14799110` passed all route and actual dimensional-reference checks,
then its supervisor stopped the silent final expansion at the 1260-second
inactivity threshold (last measured RSS 485,457,920 bytes). Its accepted
route checkpoints remain reusable; no corrected Hqq S11 result was exported.
`common/s11_complete_collinear_difference.wls` executes the unchanged
reviewed initialization and route-cache reader, derives the actual
new-minus-old convolution tensor, and expands only that difference. Before
using it for Hqq, require the routine to reproduce the entire already
accepted corrected Hqg and Hgq counterterm tensors from their own saved
old/new convolutions and prefactors. Require zero D=4 convolution difference
and a finite correction, retain the original final gates, and record the
control hashes, actual dispatch identity and timings. Print component
progress during this remaining expansion. No route, kernel, phase,
endpoint or subtraction normalization changes.


Accepted S11 difference completion: job `14799938`, native wall time
73.826831 seconds, result
`cee04d0085b5f07c91d9c3367c66595fd0b90e90f0b98a9750b9bcf82071a052`,
checks `b0f18b311ac0f2e4006a4626df6b4a403326b63227a152e4854414b58cbdeff7`,
receipt `789d7f3353b36a6113006f9bd966b9c12dec16b37c9bfa8e611b68948219c046`.
The full Hqg and Hgq counterterm controls, own dimensional-reference
convolutions, finite correction and unchanged pole structure all passed.
Use this result in subsequent assembly; retain its dispatch identity
`4fd168cc9ed75b92592729fd5d00466ed7a812e142dfe3d3e3280acf5fa126e8`.


S15 scheme-input dependency: `common/s15_inputs.json` pins the accepted
completed core S11 source `4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6`.
The earlier configuration is retained in
`common/s15_result/reference/s15_inputs_before_dimensional.json`.
Only that source identity and byte count changed; the scheme definitions,
reference kernels and standalone normalization contract are unchanged.
The S15 job configuration must bind the updated JSON itself as well.


## S05 completed projection archive continuation

Completed pair files supply all subsequent pair-sum inputs. The existing
verified archive routine may compress their individual projection files
on a compute node while unrelated pairs run. Preserve every path pinned
in any S05 input or job configuration, all incomplete pairs and all
completed pair files. Verify each archived member's exact hash and its
unchanged owning pair before removing the raw duplicate. Verify each
JSON manifest by parsing the temporary file before publication. Keep
archives below 128 MiB and record all member paths, hashes and restore
base in `s05_projection_archive_result/s05_cache_manifest.json`.
Final coefficient acceptance still requires every original stage gate.


Archive job `14800525` passed in 146.144 seconds. It preserved
25 completed pairs and archived 17,277,167 source bytes into
4,222,897 bytes. The manifest SHA256 is
`330caa083a08fc883ecf16e1e82b2ca18ece596b03c82840f0a48c4934c09cdd`;
the archive SHA256 is
`cd0a87b1a653b96694123de59d7e63cfdaec6927f00f466e901f363d1bd627f0`.
The matching execution receipt SHA256 is
`82335210eed1b3ea495cb6f45735f917f5290fc394d6f3a869193ee437001d26`.
These artifacts are verified locally under `s05_projection_archive_result/`.
Restore only manifest paths and require each archived member hash before use.

## S05 scalar checkpoint continuation

The next native continuation uses the unchanged shared
`common/s05_real_spin_response_cached_scalar.wls`, SHA256
`ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff`.
It requires the accepted Hgg coefficient-checkpoint proof, matching scalar
definitions and shared physical conventions. Existing Hqq pair and projection
identities remain unchanged; new coefficient keys bind Hqq's actual input.
The accepted Hgq spin-polynomial reconstruction and chunked native writer
retain exact reconstruction and complete saved-result reload gates. Keep
all payload parts listed in `s05_payload_manifest.json` with the result.
Use four shared slots, the checked 4 GiB native operation bound and a
30 GiB process-tree limit. The prior native writer must exit before resume.
All original channel Ward, CDR and reconstruction gates remain required.

While pending, job `14801746` retained four shared slots and changed its
request to 6 GiB per slot (24 GiB total), following the preceding measured
7,292,055,552-byte peak process-tree RSS. The original immutable calculation
configuration remains bound in the amendment record
`../.cluster/s05_result/s05_Hqq_memory_allocation_adjustment.json`.
The scheduler's effective limits apply in addition to the native bounds.

The scheduler checkpoint continuation uses the same four slots at 6 GiB
per slot with a 22 GiB process-address limit and a 22 GiB process-tree RSS
limit. These replace the older 24/30 GiB wrapper limits so that both guards
fit inside the scheduler allocation. The 4 GiB native operation cap,
unchanged scalar source and existing mathematical cache identities remain
in force. Its immutable job configuration is
`../.cluster/s05_Hqq_scheduler_checkpoint_resume_job.json`, SHA256
`d46d2bddb58cb32d39258c8ee1ec9fbe2d95a465c8dbb4c72c201374bbeeb995`.


## S05 reconstruction memory contract

The resource adapter `common/s05_real_spin_response_reconstruction_memory.wls`
(SHA256 `1ff7f505c4a838674176488f81e7bb0891324bff9a0a0baad93d7a48a76e9cd3`)
retains the pinned cached S05 implementation and changes only the native
memory bound for `{"RealSame", "exact spin reconstruction", 9}` to 8 GiB.
This supersedes the earlier 4 GiB reconstruction limit only for that task.
All other native limits, mathematical predicates, input/cache identities,
reconstruction checks, and downstream schemas remain unchanged. Require
unique replacement sites, complete native syntax, and exact reversal to the
pinned full source before evaluation. Record the adapter hash and override
in the completed result separately from the unchanged calculation identity.

The job configuration `../.cluster/s05_Hqq_reconstruction_memory_checked_job.json`
(SHA256 `8face9861b10dc1f1954836212a873a92c471233df7ef2fb38584153f775c825`)
keeps four shared slots at 6 GiB per slot, a four-hour wall allocation, and
22 GiB process-address and process-tree guards. Reuse only input-bound
accepted checkpoints, including RealSame reconstruction components 1--8
from job `14811834`; retain that failed execution receipt under `reference/`.
Every remaining real-sector and final output check is still required. This
resource contract does not accept the missing reconstruction or a finite hat.

The adapter package-loader replacement is scoped to the main initialization
line; allocated-worker loaders remain byte-identical. All three full-source
replacement sites and their exact inverse are checked before submission.
The earlier adapter stopped before initialization in job 14813424 and
produced no mathematical result; its receipt is retained under reference/.

## Per-process scheduler data-limit continuation

The next resource-only resume uses two shared slots at 12 GiB per slot,
preserving the existing 24 GiB total reservation and 22 GiB address/tree
guards. This gives the 8 GiB native RealSame reconstruction allowance
per-process scheduler headroom. The previous four-slot, 6 GiB-per-slot
request imposes a lower per-process data limit. Preserve all native
equations, operation bounds, checks and checkpoint identities. Leave the
current writer running and apply this setting only after it exits.
Configuration .cluster/s05_Hqq_data_limit_continue_job.json has SHA256
4b72be1060c694407408cc4fd17baaa1193431ea26e51f5f0d0106f89e76cc13.
## Reconstruction equation reader

The RealSame component-9 reconstruction in job `14813427` exceeded its
7200-second native time bound. This did not establish a nonzero residual.
The complete pair and component sums, Ward/Hermiticity checks and accepted
reconstruction components remain reusable with their original identities.
The prepared per-process data-limit continuation has not been submitted;
that allocation change alone is not an accepted remedy for this timeout.

`common/s05_read_reconstruction_equations.wls` reads the unchanged production
initialization and saved matrix entries for the reported component and an
own accepted control. Native photon-dual contractions determine which saved
entries are required. Require every packet's current input hash, key and
accepted checks, the unchanged derivative-extraction definitions, and the
control's full task binding. Export the actual equations as readable native
Wolfram files and require exact reload. Retain the response, definitions and
input identities in `s05_reconstruction_equation_result/`. This reader does
not accept a new reconstruction algorithm or change production checkpoints.

The equation reader passed job `14813535` on `n7107` in 204.45642376691103
seconds. Its complete native packet has SHA256
`5e8e0d77dd233652180a509771ac8e770a80a99d4105ae651806e90dcc29d8ba`;
the execution receipt has SHA256
`c97606f20b945ee4f8c023b4b4c2a935d2ad323a901efffc25a85440458a08ba`.
Both actual equations, the packet, checks and receipt are verified locally.
Component 8 is 5,288,423 bytes of readable text (63,599,912 native bytes),
and component 9 is 8,128,626 text bytes (98,648,792 native bytes).
The control retains its original accepted full task binding.

`common/s05_check_structural_reconstruction.wls` tests temporary symbols
for maximal spin-independent subexpressions of these exact equations.
Require native independence from every spin variable, exact restoration
of the original expression, the unchanged derivative extraction, exact
polynomial reconstruction in the temporary symbols, and exact equality
of the restored response with the existing response. Compare the control
with its own accepted reconstruction and require rejection of a deliberately
changed response. Retain actual input identities, definitions, timings and
memory/size measurements in `s05_structural_reconstruction_result/`.
This candidate must not write production caches or be installed before
its complete executed checks pass.

The first comparison, job `14813544`, was rejected by its negative control.
Its evidence update called `AssociateTo` with three arguments, so the two
final reconstruction checks were absent. No comparison result or production
checkpoint was accepted. The prior source is retained under
`common/s05_result/reference/s05_check_structural_reconstruction_before_evidence.wls`
(SHA256 `0aa85f928c2011ae31c9d813f6e68d3088a5ac1d9b4dc3931c62e1908c98969b`).
The corrected checker supplies a list of rules and requires the exact six-key
evidence inventory before acceptance. Both original input comparisons and
the negative control remain mandatory.

The corrected comparison passed job `14813552` on `n6132` in
117.58250970882364 seconds. Result SHA256:
`b8d397e29a9b9210e2d4db1aabf361eb5ece0c338bbe0c93d0fd846fc8be44de`;
checks SHA256 `ca4a2db28f7e004cb09077ec520c1e736a886782f418fe3ef96321da8d61bbef`;
receipt SHA256 `ec3a408d4ae8acf143e6d04e963f233c35d8e2c2f701c7c42653641de94e6fab`.
All six exact checks passed for both components, and the altered response was
rejected. Component 8 took 1.972943 seconds; component 9 took 3.000280 seconds.
The latter's native check expression decreased from 98,648,792 to 101,128
bytes, with exact restoration of its original equation and response.
These measurements concern the reconstruction check only.

`common/s05_real_spin_response_proven_reconstruction.wls` may reuse this
accepted component-9 check through the existing S05 checkpoint reader.
Require the pinned comparison and receipt, unchanged source/native versions,
every actual physical and equation input hash, the complete six-key evidence
inventory, and the original task binding. Preserve the own accepted control.
Write the existing checkpoint schema with the comparison identity and require
exact reload. The production task must independently match its original
binding before reuse; all other tasks and final channel gates are unchanged.
Keep the actual calculation source/cache identity and record this reuse in
the final result. Resume with two shared slots at 12 GiB each and 22 GiB guards.


## Reference rational-series integration contract

`common/s12_assemble_real_reference_series.wls` preserves the accepted S12
initialization, soft-region and endpoint equations, component caches and final
schema. Load the exact executed standalone rational recurrence and product
checks from Hqqbar's accepted `s12_rational_series_result`. Bind its receipt,
source, scalar master library and native versions. On this channel's complete
accepted S08 map, select the smallest nonzero coefficient block and compare its
complete ordinary contribution with the original native Series calculation.
Record both exact values, input identities and timings in
`s12_reference_series_result/s12_result.wl`; require exact equality and native
reload before any production components run. Reuse that checked contribution
and apply the unchanged recurrence, regulator-depth, numerator-reconstruction
and native-product gates to remaining components. Existing accepted S12
component checkpoints remain valid. This contract makes no full-channel
speedup claim before executed measurements exist. Finite acceptance still
requires the complete S14 and S15 gates.

## Saved-matrix Hermiticity comparison contract

`common/s05_check_factored_hermiticity.wls` reads already completed sector
photon sums and uses the executed factorized conjugation definition from the
accepted pair-assembly proof. For each available complete Hqq sector matrix,
compare the candidate with the original full Hermiticity calculation on the
sector's own first pair, reject a deliberately changed control, and require
the complete saved sector matrix to pass the candidate exactly. Bind every
saved input, matrix, source and native version; store timings and exact proof
reload under `s05_hermiticity_result/`. Production may reuse a certificate
only when the full current matrix hash and physical inputs match. This does
not accept incomplete real tensors or replace their other checks.

The comparison passed job `14813631` on `n6132` in 319.5096737900749
seconds. The complete RealQGG and RealSame matrix checks took 37.370915 and
32.65914 seconds respectively. Both own original pair controls agreed and
both changed controls were rejected. Result SHA256:
`b23311b9af3f205e742aa4395356ee0ac5467dd2d13bf8f5d3ba82141bc5fbdb`;
checks `0fb8a4b861b50f0b30d5a2a218c382641a2730274179b2e4ca1fee0cf0a3dce1`;
execution `aa26a3c2751e1afcf533968ab14b4f56774ac2db9c700ebf5442556379a58d57`.
These are check timings, not a measured full-channel speedup.

`common/s05_real_spin_response_proven_hermiticity.wls` builds on the unchanged
accepted reconstruction adapter. It may reuse these complete matrix checks
only after verifying all saved equation hashes, physical inputs, source and
native versions, original controls and negative controls. A changed matrix
or unverified sector uses the original Hermiticity equation. The validation
mode must exercise this dispatch on both actual full matrices and reject a
changed matrix and unverified sector before production adoption. Preserve
all other real-tensor checks and bind the reused proof in the final result.


## Compact real-assembly inputs

The reviewed `common/s12_assemble_real_compact_inputs.wls` keeps the reference
recurrence contract above and retains only the component fields actually
consumed by S12: Sector, Kind, Index and ReducedCoefficients. It validates the
complete accepted S08 artifact first and requires exact equality of every
retained consumer field. Record the original and projected native byte counts
in the own comparison and final S12 result. Preserve the complete source-file
input binding, unchanged endpoint equations and native own-input comparison.
No memory or timing improvement is accepted without the executed measurement.

The production dispatch validation passed job `14813646` on `n7141` in
294.54365654848516 seconds. It loaded both complete saved sector matrices,
accepted exact matches and rejected changed matrices and unverified sectors.
Adapter SHA256:
`31567605bbeddbc9b0758e25a4a39d662b10e193de742ead65049cc43c77b0e1`;
interface checks `c3dfb14f91809375ecffc19c30bf6c77af6c4e4ee8f11487560a3ec966b46c7a`;
receipt `df6391eedcbe27819d5404e6429c715de4c7d1ed5e353b71201edde051b78986`.
The guarded restart may use this adapter with the existing two-slot,
12 GiB-per-slot allocation and unchanged 22 GiB process/tree limits.

## Final assembly with released tensor inputs

After accepted S12 integration, use
`common/s14_assemble_finite_compact_inputs.wls` (SHA256
`0e87dc4d088369ad3cd9754e31c5aedd4e6a80db2f18b3d318abb345cd68a613`).
It retains the phase-series assembly and verified compact native writer.
After the original S05 acceptance gates and frame extraction, require exact
frame equality and release the otherwise unused full S05 tensor. Record its
native byte count and memory before/after; the original input file and payload
hashes remain bound. Require exact restoration of all original assembly source
text after removing that insertion. Pole cancellation, complete branch and
unpolarized-hat comparisons, and native reload remain mandatory.

Run S14 serially with one 32 GiB slot and 30 GiB process/tree guards, then the
unchanged compact S15 with one 24 GiB slot and 22 GiB guards. Preserve the
original 2 GiB/1200-second algebra-operation bounds and four-hour scheduler
requests. These are bounded allocations, not measured own-channel performance.
Bind accepted S05/S11/S12 and, for core channels, S03/S13 receipts before
assembly. Bind accepted S14 before S15 and collect the scheme result together
with both final hats. Require the final finite-export gate before declaring
this channel complete; accepted upstream stages alone do not establish it.

## Accepted compact S08 worker interface

The unchanged streamed reducer with compact task inputs passed the Hgq own
comparison in Hoffman2 job 14813742 on n1849. Both selected complete
mathematical coefficient records matched their accepted outputs exactly;
original and regenerated check logs passed separately. Source
`common/s08_map_real_spin_compact_inputs.wls` SHA256:
`aea8d3ac781c29b85a00d341a994420d3af5ee7f450ff7ddc0f2074e8851475f`.
Proof `Hgq/s08_compact_worker_result/s08_result.wl`:
`2a432d7b590886beb124c8652c724c2a2aaedfcdbc8d9db4a8a76d4570a5a8bf`;
checks `46599a65bb066f23285992b0365e5f2a2ea88af1a9d0d15295a0b5435745a291`;
receipt `7a9dfbaec20fb2b6c3de3205b01a2dfd62abbc221134be44177c0a4471372bca`.

Hgq task data decreased from 2,248,476,856 to 26,544 native bytes; main-kernel
memory decreased from 5,868,329,888 to 1,148,912,856 bytes at the release
boundary. Worker distribution took 543.906422 seconds and the complete
coefficient comparison took 10.706544 seconds. Total run time was
922.512149260845 seconds. These are Hgq measurements, not a runtime promise
for another channel or a full-stage timing comparison.

The same data-only interface may follow each complete accepted raw map.
Require the own physical-input, raw-map ordering and reconstruction gates,
exact retained task fields and spin metadata, unchanged mapper/reducer
equations and canonical checkpoint identities. Bind the accepted comparison
and receipt with the production source. Retain original Value fields wherever
empty raw-map checks require the original zero-input predicate. Finite hats
still require the complete downstream acceptance gates.

Prepared job configurations may acquire additional input hashes after upstream
acceptance. Verify the exact saved template hash, require every other field
and every existing input hash to remain unchanged, and atomically save the
fully bound configuration before submission. An altered prior binding is an
error; it must not be silently overwritten. This corrects the unexecuted S12
template-to-result interface without changing its native equations.

### S08 own-component pair-mapping comparison contract

`common/s08_check_quark_sector_pair_mapping.wls` reuses the hash-pinned Hgq
comparison implementation and the original reference cut mapper, selecting
the real sector from an already accepted Hqq target-map component. Both
spin axes must match the accepted quark basis. The program must verify the
complete accepted diagram-pair inventory, every pair input identity and
checks, exact reconstruction of the saved spin component from the pairs,
exact reconstruction after mapping and merging, both physical cuts, and
exact agreement with the complete own accepted target map. No extra pair
weights or channel-specific algebra are introduced. The comparison uses
its own cache and `Hqq/s08_pair_mapping_result/`; it cannot overwrite the
canonical target map. Its source and inputs are pinned in
`common/s08_quark_sector_pair_mapping_inputs.json` and the job configuration.
Timing evidence is required before adopting a production change; the
comparison alone is neither a complete S08 stage nor a finite F hat.

The comparison was accepted by Hoffman2 job `14814064` on `n1078`.
All gates passed, including the complete own `RealQGG` component `{1,3,3}`
comparison against canonical target component 3. The complete comparison
job took 391.60520193725824 seconds; that accepted original component
records 1418.986639 mapping seconds. These are wall-time measurements
with different work allocation, not a claim about total CPU cost.
Accepted artifacts in `Hqq/s08_pair_mapping_result/`:
- `s08_result.wl`: `20bac42a04dc20611e10870b60a35cc7fe8a503109c094c8e4187a0a12b0d2b7`.
- `s08_checks.json`: `8ab7fcbbb36a0db5ed412f03f9bfea5d78ec76cd31cce67357783d400553c757`.
- `s08_execution.json`: `4c1a0220af191a86fa846cf5abf612894af6eea9fbea70370516f47afab9d089`.
The comparison source hash is
`25e5127b4e274c5742581cd168740836471307b3ba4958b8df6765bfc9680c18`;
its configuration hash is
`0365cc7fdaf9fe696c6443557bbeddf7c2a317c9f9fe465d86f308472bac5036`.
Only the 36 full `RealQGG` pair records (39,926,601 bytes) were restored
from the accepted S05 archive for this consumer; other archived records
remain compressed.

`common/s08_map_quark_sector_targets_by_pair.wls` must bind that exact
comparison and use its unchanged pair extraction, mapping and merge
functions only for the control's inherited sector. Other sectors retain
the unchanged `mapTargetTask` implementation. Reuse accepted canonical
components before dispatch, require the original fresh-worker control,
restore the complete original task order before export, and retain every
original S08 acceptance and exact serialization gate. Use a single writer
for the canonical cache; the prior raw-mapping allocation must be
quiescent before this dispatcher starts. This is a dispatch optimization,
not a change to target hashes, measurement or algebraic conventions.

The sector dispatcher has a compact-worker successor,
`common/s08_map_quark_sector_targets_compact.wls`. The original
`mapTargetTask` function is unchanged. Its worker receives one original
task, index, task count and native task hash. A worker-local list places
that exact task at its original index and preserves the original count;
other entries are unused. The worker checks the task hash and reconstructed
index/count before invoking the unchanged function. Distribution occurs
inside `Block[{tasks}, ...]`, so the main task list is not copied to every
worker. The accepted pair mapper and fresh-worker reference comparison
remain unchanged, as do every canonical cache key and result check.
This removes an unnecessary transfer; a whole-stage speedup is not yet
established. Existing accepted component caches remain valid.

### S12 factored-series integration contract

The shared entry point `common/s12_assemble_real_factored_series.wls` retains the
original S12 component interface, endpoint distributions, master inputs and
canonical cache identity. It reuses the executed Hqqbar standalone rational-series
recurrence and recoil-factorization definitions. The regulator product is compared
and returned through the requested order; higher powers are discarded only after
the native Series comparison passes. No master-depth or numerator-reconstruction
gate is removed.

Before integrating the remaining components, this channel must reproduce its own
smallest nonzero ordinary contribution with the original native Series, and compare
a complete original component with the factored calculation: ordinary part, both
endpoint branches, all four distribution coefficients and every soft coefficient.
Isolated control caches preserve the original calculation. Accepted canonical
components are retained. The two durable comparison artifacts are
`s12_factored_series_result/s12_result.wl` and
`s12_factored_series_result/s12_endpoint_comparison.wl`; their exact input, source,
task and native-version identities are required on reuse. These are validation
artifacts, not final F hats. S14 pole cancellation and S15 export remain required.

### S08 identical-quark pair mapping contract

common/s08_check_same_sector_pair_mapping.wls uses the unchanged accepted
quark-sector comparison equations, with only its own source, configuration and
result paths changed. The control is the accepted RealSame transverse-spin
component 32 ({1,3,3}), SHA256
8aa6ac8c83f0dbf6394f64d4c0921a0b19e780e1ea569e5e1ef782761b7f0a35.
The complete 36 full pair inputs, 31,052,752 bytes, are restored from the
accepted S05 archive manifest
907fc1b575b141999a7fbb1734671a8636325443e83c46bb030e0bab12df07ab;
every member hash is preserved. The native inventory gate establishes the
diagram-pair count; the restored file count is bookkeeping only.

Require every existing comparison gate, including complete component
reconstruction from pairs, exact mapped reconstruction, physical-cut powers,
and comparison with the own accepted full map. Results belong to
Hqq/s08_same_pair_mapping_result/; the comparison cannot overwrite the
canonical target cache. No runtime improvement is established until it runs.

Only after acceptance, common/s08_map_same_sector_targets_compact.wls
may use that exact comparison to dispatch RealSame per pair. Its mapping,
merge, worker interface and canonical checkpoint gates are unchanged from
the accepted RealQGG dispatcher. Existing canonical components retain their
identities. A single writer is required; retire the prior raw-map allocation
before production handoff. All other sectors use the original mapper and
reuse accepted canonical checkpoints first.

The identical-quark comparison was accepted in Hoffman2 job 14814800 on
n6044. All pair maps, complete original-input reconstruction, both physical
cuts, complete own accepted-map comparison and native reload passed for
component 32. The full comparison job took 1227.4641200192273 seconds; the
original component records 1140.320362 mapping seconds. These measure
different work, and do not establish a full-stage speedup. Pair extraction,
merge and per-pair timings and expression sizes are retained in the proof.
Accepted identities under Hqq/s08_same_pair_mapping_result/:

- s08_result.wl: 9c98d101b1f49e7423278219f80bc4953d72d832b107268cb0b487653f29b0b6.
- s08_checks.json: 967b02ab48a31b72d2049ab0d58c796e5675bbf69f8ab74ce830bad469775c60.
- s08_execution.json: deab915513233c611e671250dfef985cb53f1cad0e0b864dc40c17cf16e37bc0.

Comparison source SHA256:
bce641c29f3a4ea773e1f8539284913b56717f2d90a0c0e936c2c4f4f8cfced6.
Input configuration SHA256:
31320634a62abab032dbbae678c0a167b9e672c5e567601da840cea30b74d57c.
Production dispatcher common/s08_map_same_sector_targets_compact.wls:
f3fe81032aa198ae406ff51bc56c5974253c4f759a2c2e9bb96b920de7b20f56.
Use the existing four-slot 8-GiB-per-slot allocation, 24-GiB process and
30-GiB tree guards. Retain the original canonical mapping identity, all
accepted components and the own comparison's resumable pair checkpoints.
The original sector-neutral mapping functions and subsequent reduction,
integration, pole cancellation and finite-export gates remain unchanged.

### S08 pair-sum equation export

`common/s08_export_Hqq_pair_sum.wls` reads the unchanged pair-mapping
initialization and accepted spin extractor. Export the exact unsimplified
input `Total[values] - task["Value"]` for component 57, where job 14814850
exceeded the memory bound. Retain the task, complete pair equations, source
and input hashes, native versions and exact export/reload checks in
`s08_pair_sum_equation_result/`. This is a native representation conversion;
it does not accept a modified zero predicate or any additional target map.

The native equation export passed job `14816714`; result SHA256 is
`ccb2b6419cf12354531bb652e8768476d6e46d2c74b65f6a9b8506880c802801`,
readable equation SHA256 is
`ea664eebb9add41bbc32f546a3881be2cb8657aed8b27705d5598ac5c0129fef`,
and receipt SHA256 is
`4fdb27b8c8099a332688793f4894503908a893224b918a2fb68c6d8eff332f43`.
The task is RealSame ExtendedResponse `{9,4,1}`; its unsimplified difference
has native byte count 45926520. No additional mapping was accepted.

`common/s08_check_Hqq_pair_sum.wls` tests exact expansion before the inherited
rational zero test. Bind the saved equation and complete production inputs;
require the failed equation to expand exactly to zero and compare the old
and proposed predicates on the own accepted control. Reuse the accepted
control's complete mapped reconstruction after binding its successful
receipt, source, inputs, runtime and unchanged map/merge definitions. The
new zero predicate is confined to the original pair-sum boundary. Preserve the original
mapper and merge definitions, and record native timings, sizes and exact
reload under `s08_pair_sum_result/`. Production use requires this executed
comparison; the original zero predicate remains the fallback for inputs
that do not vanish by expansion. No physics or mapping gate is removed.


`common/s08_map_same_sector_expanded_sum.wls` retains the complete accepted
same-sector dispatcher and changes only its original pair-sum zero predicate.
It must load an accepted `s08_pair_sum_result` receipt and verify the proof's
source, task inputs, native versions and original zero/map/merge definitions.
The mapped reconstruction, cut checks, canonical cache identity, task order,
worker transport and other-sector mapper remain unchanged. Record the
pair-sum proof hash with newly accepted canonical records and the final target
map. Do not run this entry before the native comparison is accepted.

The focused pair-sum comparison passed Hoffman2 job `14816856` on `n1164`
in 154.83162139705382 seconds. The saved stalled cancellation expands exactly
to zero; the original and proposed predicates agree on the own accepted
control. The unchanged full map comparison is reused with its exact source,
input, runtime and map/merge definition bindings. Accepted identities under
`s08_pair_sum_result/`:

- Result: `d7c91af28ef3d1fce414043fec0c83765d4934efd8d1c93a256382a0e0bf9cd6`.
- Checks: `047e28f98c399c64000ea8cd07494c7767aaf1679844628823c99e41b5c82974`.
- Receipt: `d88a6cf1f222659a5b9db8c1cd79ee6659ab5931c2962f7f3cd52c0237480fda`.

Comparison source: `e9b7dcd679e968dac614db8f03a10f43f723d7d930d09219b97856d74677cd6e`.
Production source: `207a13a315bd44b4faff0a0e2f72efe26ad12d8669f1c977eda11885a2f45c44`.
The preceding failed comparison added an unnecessary full-map recomputation;
it accepted no output. Its source and receipt remain in the owner's reference
directory. The accepted comparison above changes only the pair-sum predicate.
Existing canonical maps and pair checkpoints remain valid.


### S08 remaining distinct-sector metric map

`common/s08_check_distinct_sector_pair_mapping.wls` reuses the complete
accepted same-sector comparison with only its source, configuration and
output paths changed. Select the saved RealDistinct control component59
and remaining metric component87 through configuration. PhotonMetricD
retains incoming/outgoing spin and must not be replaced with the old
unpolarized Pg map. Require the inherited native inventory, pair/input
identities, complete input reconstruction, unchanged reference mapping,
physical-cut checks, own accepted-map comparison and exact native reload.
The pair inputs are restored byte-for-byte from the accepted S05 archive.
Outputs remain isolated under `s08_distinct_pair_mapping_result/`; no
canonical result may be replaced while its current producer is active.
A successful comparison may supply the remaining canonical component only
after exact source/input/runtime binding and prior-writer quiescence.
Complete mapping, integration and finite assembly gates remain required.

`common/s08_assemble_Hqq_verified_targets.wls` uses the original target
initialization and export. It requires the complete accepted distinct-pair
receipt, original mapping/merge definitions, native versions and input
identities. Prefer each existing canonical component; take only missing
components from the accepted comparison. Check every task identity and
recorded reduction inventory, and retain exact native export/reload. The
controller must establish prior-writer quiescence before output publication.
This consumer is prepared; its executed acceptance is still required.

The assembly preserves the original mapper `SourceHash` and records its own
`DispatchSourceHash`, as the existing dispatcher does. The unchanged
extension reader verifies the original calculation identity; the assembly
receipt additionally binds the actual dispatch and accepted pair proof.


### S08 coefficientwise distinct-sector merge

`common/s08_merge_Hqq_distinct_pairs.wls` reuses the complete accepted
`common/s08_check_pair_merge_linearity.wls` implementation, changing only
its owning source/configuration/result paths and the pinned pair producer.
The parent is the current distinct-sector pair calculation. Read its actual
saved control59 and metric87 maps with their original input bindings; do not
recalculate the ten completed pair maps. The original merge runs separately
for each integral key, retaining independent exact coefficient reconstruction,
complete native formal linearity specialized to every actual map term,
physical cut checks and exact native export/reload. Require the entire own
accepted control coefficient association to match exactly before adoption.

The isolated result owner is `s08_distinct_pair_merge_result/`; per-coefficient
checkpoints remain source/input-bound. Neither comparison completion nor a
raw target map is a finite F hat. Existing canonical components are preferred
when the accepted missing component is consumed. Original reduction,
integration, subtraction, pole cancellation and final export remain required.


`common/s08_assemble_Hqq_merged_targets.wls` is the same verified-target
assembly consumer with only the distinct per-key merge source, configuration,
result owner, schema and own-control check selected. It requires complete
accepted merge receipt and exact input/runtime/map/merge definitions before
consuming a missing canonical component. Original target export and all
reduction coverage and reload checks are unchanged. The controller must
prevent concurrent canonical publication: if the original comparison passes,
its existing downstream controller retains ownership; otherwise confirm that
comparison has terminated before the merged-target assembly starts.


The coefficientwise distinct merge passed Hoffman2 job `14817783` on
`n6125` in315.64771840395406seconds. The complete own control59 coefficient
map matches exactly; component87 passes each original coefficient merge,
exact reconstruction, complete native linearity specialization, physical cuts
and native reload. No contraction or pair mapping was repeated. This accepts
the missing map, not integrated or finite coefficients.

Accepted source `common/s08_merge_Hqq_distinct_pairs.wls` SHA256:
`e3f9a80341dba51c2950a04a1819269d5ac66225c814812675d2c1f6edcb176d`.
Input configuration SHA256:
`a7904d627393814bd0240ace44d6dea926eb607c0cca53a6223da6c21270dff8`.
Artifacts under `s08_distinct_pair_merge_result/`, retained locally:

- `s08_result.wl`: `57c2c391909713e23458df511142d3432638245496e02720f08e140333376932`.
- `s08_checks.json`: `957b9f9d98c42a15c44b9089be6c8da964ba89a93bd22a7ed921915f3172a844`.
- `s08_execution.json`: `534c9b19dd85c2bf2a37f7c762ca3be9eac55bc335becbec823dc0c226257af2`.

Consumer `common/s08_assemble_Hqq_merged_targets.wls` SHA256
`e18ca2094a1ca01f473cb7c034494351b063d1fbb76809027c0eee0fd5d7b9ee`
retains the original target exporter and prefers accepted canonical records.
The exact old comparison14817157 native kernels have been retired after
new merge acceptance, preserving all86 canonical maps and both pair caches.
All original reduction, integration, subtraction and final export gates remain.


### Accepted complete S08 target map

Merged-target assembly job `14817867` on `n7407` passed in
270.55989026091993seconds. Every87 original task binding and recorded
reduction inventory passed;86 canonical records were retained and only
missing component87 came from accepted distinct merge14817783. The native
output passed its original file bound and exact round trip. This map does
not yet establish complete reduction coverage or finite coefficients.

Accepted `s08_targets_result/` artifacts, retained locally:

- `s08_result.wl`: `8b7f7cc5a5a8e6b318786934a8667399343bcfc08a1e2c31d33f261a261fbf66`.
- `s08_checks.json`: `b5919ea38c80bf176f3feaae3cc5229f8e72b4c54bca582e3349606725caeaba`.
- `s08_execution.json`: `9e6cbcd8efdf031844b48320abdbd66b97bd07b23be5a98d5e51b1617c3835b2`.

Dispatch source and proof identities are recorded above. Configuration
SHA256 is `bf91ceb70f0dc340c72f833ce505ed38db97ca6640b32eac00c4a6dc13c46af9`.
Native log: `cache/s08_Hqq_merged_target_assembly.log` on the recorded
Hoffman2 root. Consume through unchanged `common/s08_extend_real_reduction.wls`
and require complete reduction coverage before S12.


### Accepted S08 complete reduction coverage

Unchanged Kira extension job `14817871` on `n7044` passed in
269.68271288461983seconds. Every inherited reduction rule matched, and
complete actual spin-target coverage passed. The extension source remains
`common/s08_extend_real_reduction.wls`, SHA256
`db9875bb42086b9e52a405bc61b46262661cf91b72681dc57c22c977121a22e7`.
Configuration SHA256:
`6ab7f58728ebd01309963ddbd1196ff9ff44a4696da59fa621d34e70b915826e`.

Accepted `s08_reduction_result/` files, retained locally:

- `s08_reduction.wl`: `5b13eddfae2b29f2c619573b1461571dca808ba68389b9f321c48f3a6aa966f0`.
- `s08_checks.json`: `f38da26163e943a64775cb0e572beb390dcf19ebb1f91bdd79b1e0fa174d7ae2`.
- `s08_execution.json`: `2097721877c563e0ae08b9823452ec440c86952dbaad52711518b8eceb3503ea`.

Native log: `cache/s08_Hqq_reduction_guarded_pipeline.log`. The compact
coefficient reader consumes this exact reduction and the accepted complete
target map. Integration, finite assembly and final export remain required.


The complete master-coefficient assembly passed job14817874 on n7140 in
7637.147176370025 seconds. All87 components, exact coefficient
reconstruction, complete reduction coverage and compressed native reload
passed. No integral target remains missing. The unchanged entry is
common/s08_map_real_spin_compact_inputs.wls, SHA256
aea8d3ac781c29b85a00d341a994420d3af5ee7f450ff7ddc0f2074e8851475f.
Accepted and locally hash-verified files under s08_result/:
- s08_result.wl: 630b599ef433544214acc847d34ff22ff5f00f105571efd800033d7ccdbef1f6.
- s08_checks.json: 7fbe700aa8551b87f2f8481bb12e74dfd49a2720bde9909d68f9cf8217a2e55b.
- s08_execution.json: 4890be738eee8f2f5f80a5fa2e1247acc8bcda83d6fd3b04b77b780546c859b0.
S12 consumes this exact complete map, retaining all RealQGG, RealSame and
RealDistinct spin components. S14/S15 finite acceptance remains required.


Completed S08 cache archive accepted: manifest s08_cache_archive_result/s08_cache_manifest.json,
SHA256 68a208c026ca56d662192362e0aaa871c1c2fe309219203ba22d1ae5faa7a894. All 375 members were verified before
removing 44899463 identical remote bytes. Accepted S08 result630b599ef433544214acc847d34ff22ff5f00f105571efd800033d7ccdbef1f6 unchanged. Restore the exact manifest paths before any S08 resume.


### Shared scratch allowance

The4GiB workflow scratch guard interrupted calculations during simultaneous exports. Cluster quota reports1190GiB used against1863GiB hard limit. Replacement allocations use a bounded12GiB shared workflow scratch allowance, unchanged RAM limits and128MiB file bound. Maintain the local3GiB reserve and bounded transfers. This supersedes earlier4GiB scratch contracts. Preserve checkpoints and failed receipts.


### Remaining S12 worker allocation

The unchanged factored-series entry7bbecbad and shared ca377703 kernel
implementation already support four independent workers. Each component
uses its own canonical cache file, and the original finest-grained task
ordering is unchanged. After the two-worker allocation observed a
3251798016-byte process-tree peak, remaining work may resume with four
4GiB slots, the unchanged4GiB per-process cap, a14GiB process-tree cap and
12GiB shared scratch. Preserve both accepted own-comparison artifacts and
pin their exact hashes during the single-writer handoff. This is an
allocation change; no measured whole-stage speedup is claimed.

### Conditional reuse of the reference recoil calculation

A candidate S12 entry may use the pinned GitHub S17 softRows definition
when the actual branch coefficient has polynomial numerator and denominator
in the measured recoil variable. Convert only the recorded recoil symbol
and function name, and require reversible exact source identity. Inputs
that fail this native support test retain the accepted factored algorithm.
Before production, require equality of an own accepted complete component:
ordinary term, both branch assumptions, all distribution coefficients, and
all soft coefficients. Bind native inputs, versions, source and reference
by hash and record timings. Preserve accepted canonical components and
all original integration, master-depth, pole and export gates. The candidate
is not accepted by this contract alone.

The conditional reference endpoint comparison passed job14822556 in174.507411 seconds. Native control1 exercises the polynomial path and reproduces the entire accepted ordinary/soft/distribution result on both branches. Source cde27a8c89576b6264528e83f1526c6d488f56a78eebc33dfe0c9b7384fee537.
Files in s12_reference_recoil_result/accepted_14822556/:
s12_result.wl SHA256 1330bec1cceab1b3ad3e9a2c4108f107d30255b43c82798caf26adc58141f3a1
s12_checks.json SHA256 fe593bb6b982e888619d8e386cf1179a8c1d913d05515a29c0c7fadc3de16939
s12_execution.json SHA256 8c0c3c685354700e565b76931ae6f7d84f68e5f84564f2809539897cccbb0a17
Production may use this entry with the same canonical component identity and four-worker resource contract. Remaining nonpolynomial coefficients retain the accepted factored fallback. A full-channel speedup has not yet been measured.

The accepted14822556 comparison source is preserved at common/s12_result/reference/s12_reference_recoil_before_resume_metadata.wls. The corrected production entry writes comparison checks only on a fresh comparison or when missing, preserving them on replay. Its new source identity requires a fresh own comparison before parallel production and retains unchanged mathematical definitions.

### S12 measured-memory allocation

The preceding four-worker run14821399 observed4752867328 bytes peak process-tree
RSS over4241.983586 seconds. Accepted own recoil comparison14822556 observed
1365950464 bytes. A two-worker shared allocation with4GiB per slot may use the
same source, inputs and canonical checkpoints, retaining the4GiB per-process
address limit and using a7GiB process-tree guard within8GiB reserved memory.
Runtime request remains4h; all own comparisons and distribution gates remain.
This is an allocation change for queue eligibility, not a measured full-stage speedup.

### S12 serial allocation contract

The unchanged base entry selects its existing serial map when NSLOTS is absent
or1; it launches no parallel kernels and retains every component/checkpoint and
final integration gate. Source9fb68f329aac43cf66ebfbf23f9b9fb4f590bd255dc78743840eb0093850ac42
and inherited definitions remain unchanged. Native accounting reports peak
ru_maxrss1787776kB for interrupted four-slot14821399 and1787904kB for accepted
comparison14822556. A serial4GiB reservation retains the4GiB process address
limit and sets the process-tree RSS guard to3.75GiB. Configuration .cluster/s12_Hqq_reference_recoil_serial_job.json
hash6ef87a0cdc6e4b66c689fe3172af590f083e7916825bcc228da6ff76274c69b4. This defines resource bounds, not an accepted
new physics result or measured full-channel speedup.

### S12 endpoint input equations

The read-only entry common/s12_read_recoil_equations.wls binds accepted S08 input630b599ef433544214acc847d34ff22ff5f00f105571efd800033d7ccdbef1f6 and reads component42, its recorded transverse substitution, and the complete denominator and noninteger-power expressions of each nonzero coefficient. Its native output under s12_recoil_equations_result is an input-equation extract, not a finite coefficient or an accepted optimization. Source SHA256 4f3ba2fc830bdf6005b86d50317d4cdee14af66f75e24a567d123e8340e4295d. The existing guarded cluster wrapper runs it with1core4GiB, no production mutation; exact output reload is required.

### S12 transverse-root endpoint candidate contract

Exact native input extract471687833441639ac6994f1df790ff87fd7ee499c49572806b8642284fa915a8 (job14822854) records component42 denominators and the one shared transverse root. Entry common/s12_assemble_real_transverse_endpoint.wls derives a homogeneous root power from each actual coefficient, gates exact reversible extraction/reconstruction, derives the physical positive finite root endpoint and zero recoil valuation with native Limit, and invokes the unchanged pinned polynomial softRows on the remaining coefficient. Unsupported inputs retain the existing fallback. No ordinary/master/endpoint-distribution equations change. Before production, a complete already accepted Hqq component containing the actual root must match in its ordinary term and every branch distribution and soft row, with exact native reload and source/input bindings. Only a separate comparison cache and s12_transverse_endpoint_result are written in comparison mode. Source768c8ca0e6ad4cafc2a4160d5a22eec7b14335d61f828c6ca7a2252b83a74db0; comparison configuration26836f31021e3d4998eef1d47b2460f7a2e3498a230337a651f72dda10406b32. One core4GiB reservation,3.75GiB tree guard,2GiB operation cap. The candidate is not accepted or claimed faster until the executed comparison/timings pass.

The first transverse-endpoint comparison14822878 stopped at the reconstruction predicate before any endpoint value was accepted. The predicate now reuses the reference zeroCoefficient definition (Factor[Together[value]]===0), which combines the full difference before testing zero. Candidate sourcef2b8c5f8d8a9ca0f71512c18be743bbc17c8f8f53eaf487a74dab93df3cd68cc was read completely after this correction; all extraction, native limit, full own-component and downstream interface gates remain. Failed comparison receipt/source/log are versioned separately; no production output is invalidated.

### Endpoint comparison equation contract

The corrected candidate14822902 passed exact root extraction and physical root endpoint gates, but its complete own component25 comparison stopped at Delta on the positive branch. It remains unaccepted and unused by production. Entry common/s12_read_endpoint_comparison.wls reads the exact saved original and candidate components, prints their Delta and difference equations, and evaluates all eight distribution differences under the same saved branch assumptions. Result schema records each full difference and native FullSimplify result; the read-stage success marker alone is not algorithm acceptance. Sourcebc94f8e03bd4a5a12099e654be0753a1df7f1c78e27f0e7a94dd8e78dd6535bd.

### Native physical endpoint equivalence

The own comparison uses common/s12_endpoint_equivalence.wl to derive ratios of the actual radical atoms, prove each replacement with native FullSimplify under the original branch assumptions, and then factor the exact difference. Only proved identities are applied. Reader common/s12_compare_endpoint_roots.wls tests every Delta/L0/L1/Regular and soft coefficient of the saved old/candidate component25. Source 40b0bcffffc14c84ae98eba017f6e98295306cdc9cd9d37b4916d0415677a126; helper 92ccb10b7a74d99b65ea7229b7527d6bc01ed78950dac5509dc27d163632a7a9. All comparisons and exact reload must pass before accepting the candidate; this contract is not acceptance.

Endpoint physical-equivalence reader14822946 passed in48.641868s, result54e7c3cc4e8df065b15f8120c932692d8ee3b779efe6f3bc57f8c8b6d9221818 and receipt70cb0be9430145ebe112d135a84304da01c88974a630d902a408dde080b3d105. The entry now reuses the exact saved candidate component, requires an exact source-prefix identity for its unchanged endpoint mathematics, and applies the accepted physical equivalence helper to all complete own comparisons. Source c92ce6bc629f18493619dbbf850267fded825d3a6683c96a3c6df70a27ad1fbe; helper 92ccb10b7a74d99b65ea7229b7527d6bc01ed78950dac5509dc27d163632a7a9. Complete production entry acceptance is still required before handoff.

### Accepted transverse endpoint and production resume

Complete own comparison14822951 passed in155.485565s; accepted sourcec92ce6bc629f18493619dbbf850267fded825d3a6683c96a3c6df70a27ad1fbe and result0fdeda16209e5853acf572fff5525bbf39fb1b1447b126e84b9af943700f94c6, checks4055715fd8b4b9f8b8d841b7918489bb8f9c1c613924ffd40f79dcb919b4dcd0, receiptc6f4e19f5ef3b072278d49d2fd27596b9dde69ed60fb85314cf8a8c2288dfdf6 are preserved under s12_transverse_endpoint_result/accepted_14822951. The production entry c35d4ac121e8a962a986ba07670971ed78e5ac5d6a7daae4be5fb51fb207f3c7 keeps the identical endpoint mathematics and fixes resume bookkeeping: own control is selected by accepted original hash; comparison checks are rewritten only for a fresh proof. The new source binding reruns the complete own comparison before any production component. Production config 3b924f6d3d20fc53e1fc09979a6f5190c4009d7d5d944b3919911b043811dc34 uses the existing serial4GiB reservation,3.75GiB tree guard,2GiB operation cap,4h allocation and12GiB scratch allowance. Retire the old writer only after component43 is atomically saved or the old job has stopped; preserve every complete canonical component. S12 outputs include the newly bound own proof and checks; its production receipt provides their hash acceptance. Remaining S14/S15 final gates are unchanged. No full-channel speedup or finite Hqq export is claimed.

### Retained Laurent identity candidate

Entry common/s12_assemble_real_retained_series.wls source a6c7321e5aba5cc0754323ea5fb369646e6ba95d1039301ec26ab019903f3346 reuses the full accepted transverse-endpoint prefixc35d4ac and unchanged standalone rational recurrence. In checkedRationalSeries it replaces the whole-residual symbolic-zero shortcut by a literal-zero shortcut, preserving the original independently derived residual power range and every required coefficient identity. It records check time and residual size. Before use, require exact complete ordinary-output agreement with accepted component43 hash124fb11cb9867052bd0229f19f9a8e869679e3f1b9119203f6781bc464f85471 and exact proof reload. Comparison mode writes only its own result directory and retains the active production calculation. No speedup or acceptance is claimed until native comparison passes.

Retained-check entrya6c7321e5aba5cc0754323ea5fb369646e6ba95d1039301ec26ab019903f3346 passed complete own ordinary comparison job14823113 in444.911565s total wrapper time. Saved proof s12_retained_series_result/s12_result.wl hash46b7aaa96435e270a68c5afd4e2f01cf06a658400a5db3d7a58f03662e414960; receiptcfebcba3a146f2ea3238eb1e0724b331623ca8b05446b6d3250f6238533f0845. The proof records full original/candidate ordinary values, source/input/native identities and timings. Production may resume the same43 accepted canonical components with this entry; the unfinished44 is not an accepted output. Config 84cce324bfb858ecade6d2fe36b4bd317ca855f4506077ad9d45e958b41e7a5b retains serial4GiB/3.75GiB tree/2GiB operations/4h/12GiB scratch. Both transverse endpoint and retained ordinary proofs are checked before production. Final S14/S15 acceptance remains pending; do not infer a whole-channel speedup from this control.

Production14823132 stopped at integer rational identity coverage within component44 after its first two master contributions. No component44 was accepted. The a6c7321 shortcut requires investigation for residuals whose Exponent is not an integer; the prior43-component cache and completed channels are unaffected. Read-only entry common/s12_read_retained_residual.wls derives and saves actual remaining master residuals, denominator equations, native support bounds and original reference zero predicates from the bound S08 component44. Reader source eb83e6d23b81c6bc0803c7d90546570a6aef905b36e10a80904d7510a27a0c5a. Its success marker is an equation-read result, not coefficient acceptance.

Empty-support correction contract: native diagnostic14823340 result6cdf81ba17c53cd39c35a383ac8bae3edfb0a4ba5da07cc789a5dbe921704c4f identifies R03 {1111}, component44, first Infinity and original reference zero True. The corrected checker retains coefficient-wise identities for integer bounds and requires the original whole-residual exact-zero predicate for other bounds. Require exact recurrence-output comparison on this actual case and the full accepted component43. Preserve sourcea6 and its accepted43 proof under common/s12_result/reference/s12_retained_series_before_empty_support.wls and s12_retained_series_result/accepted_14823113. No production acceptance follows from this contract.

### Deferred transverse substitution contract

A separate candidate may retain the existing transverse-coordinate symbol during the unchanged ordinary master-product recurrence and apply the exact saved transverseRule to its output. Gate regulator independence and master placeholder absence; preserve all original recurrence/depth/product identities and endpoint/distribution code. Require full accepted component43 equality, actual component44 empty-support case equality against the prior caller, exact reload, source/input bindings and measured timings before production. Existing accepted components remain canonical. This contract alone accepts no change.

Corrected retained checker ebbb1a516ab4852aa1cbe0c328c4b4303cce46641369614c33eaa0a906d4bab1 passed actual component44 empty-support and complete component43 output comparisons in job14823454. Proof 43cb1760e07c7f477d0e14f4688ceadd30e434e8eb9846c04d42fcab5e22577e, receipt 5acec4f5d94864ba332adad8a2bde02e70411f89f8c97e334eb616ef12157fcb. Resume unchanged canonical43 checkpoints. Shared two-slot allocation reserves8GiB with7GiB tree bound; serial fallback reserves4GiB with3.75GiB tree bound. Both retain4GiB per-process address cap,2GiB operation cap,4h wall and12GiB scratch. The existing finest-grained map and definition distribution are unchanged. Exact native worker locality and all component/final gates remain required.

Deferred substitution accepted job14823513: source34e832952e9c85462a216c6d5e8a112d9d0ad46132ee2adda08f03c0b952290b, complete43 ordinary17.865421s, exact prior43 and actual44 equality plus reload. Proofd44c1844e3ca8e6b4bbdd215f6efe4a0dd383cc5c7ca0eded6065c8ab747be70; receipt79366d58c191c5cd2a597b32e016e52df47fb7d6c4042a6c52bf747c99cd2369 under s12_symbolic_transverse_result. The full corrected checker ebbb1a516 remains inherited; output carries SymbolicTransverseSourceHash and SymbolicTransverseComparisonHash. Existing shared worker distribution contains the new candidateOrdinary without additional symbols. Remaining endpoint and final assembly are unchanged. Production resumes accepted canonical components with1core4GiB/3.75GiB tree/2GiB operation/4h/12GiB scratch. Full-stage time is not yet measured.

S14 allocation amendment: unchanged compact/phase/base code and inputs, job14823848 retains its queue identity. Reservation16GiB, process address/tree guard14GiB, existing2GiB operation cap,4h wall and12GiB scratch. Actual Hqq S05/S12 producer peaks and full input-release implementation informed this bounded request; whole S14 memory has not yet been measured. Configuration 501458ccd9569753d4b58006e2148546c85901dee293d2141a2a50703d1a1be5; previous32GiB/30GiB config preserved as .cluster/s14_result/s14_Hqq_accepted_remaining_before_memory16_job.json. All input hashes, component checkpoints and pole/finite checks are unchanged.

### Accepted complete S12 real assembly

Job14823651 passed all87 real spin components and every component check using common/s12_assemble_real_symbolic_transverse.wls SHA25634e832952e9c85462a216c6d5e8a112d9d0ad46132ee2adda08f03c0b952290b. Configuratione26d128ef68b691faf414db3c7d8944176d37135e2b5eb3da0419bc45c9e4cee; wrapper1645.685350s; measured child peak2343804928bytes. Accepted earlier components1–43 were reused unchanged; this runtime covers the resume, not the whole original stage. Native checks cover complete ordinary contractions, both physical branches, endpoint distributions and all component acceptance. Final local identities:

- Hqq/s12_result/s12_result.wl SHA256 cde36c13c61541063c25bd0c6342375d233f5fa9923dae1b18f07c24662161a2
- Hqq/s12_result/s12_checks.json SHA256 e35aad551bc3c8eda0cebc2c8ce304b9218fe6836156886a6514d5977605bec6
- Hqq/s12_result/s12_execution.json SHA256 a1e04f9ab3d0be3b3bdbd33a649e153284a7c5710facf02a59edf306e5d1925e

The94,765,873-byte result retains the standard polarized-sidis-real-distributions-v1 schema and original scientific source/input identities, with SymbolicTransverseSourceHash/ComparisonHash plus inherited endpoint provenance. Read it with Get in the established FeynCalc contexts. This is integrated real radiation; phase/flavor weights, real–virtual assembly, PDF/FF subtraction, complete pole cancellation and S15 scheme/finite export remain downstream requirements. No final Hqq F hat is accepted by S12 alone.

### S14 exact real-frame input contract

The complete S14 consumer reads only Channel, Checks and Frame from the S05 tensor before clearing it. A native projection may retain exactly those saved fields, require exact field equality against the accepted full tensor, bind every producer result hash and native version, and pass exact serialized reload. Record the actual frame and byte/memory measurements. Any later projected reader must preserve original scientific input identities and all assembly equations, carry projection provenance, and retain every pole/finite check. No reader change or reduced allocation is accepted merely by this contract.

Prepared projected-frame consumer common/s14_assemble_finite_projected_frame.wls SHA256 c5abaf703fb0e4e749ff4ff17d9be0c85e3d84adc405ccd05d893d9e5ab78754 reads only the accepted exact projection, binds its producer/results/receipt/native versions, and appends the original S05 loader to the original scientific input list. Original phase/compact/base source hashes and all equations and gates are retained; reversible insertion checks run natively. The final result additionally records RealFrameProjection provenance. The complete source and consumer interfaces have been read; text-level restoration passed. Native extraction and actual-reader execution are still required before acceptance. This changes data loading only and makes no measured full-stage speedup claim.

Exact frame-projection resource contract:8GiB reservation/address limit,7GiB RSS guard,15-minute scheduler request and840-second wrapper. Source503ef2168287d2e0309c42704de529c395af605a9c8a99111fb59f31deea5cb5 unchanged; configaca1c0baa9ee9830a145d8ec1879f75b179cc2057d35c322ac6349b182ee7146. Previous1h config2850c674 is preserved under .cluster/s14_result/s14_Hqq_frame_before_runtime15_job.json. Native exact field/reload acceptance is still required; no finite result follows from the extraction.

The attempted explicit virtual-limit amendment was skipped because S14/frame had already completed; no scheduler alteration was applied. Both native receipts report unlimited inherited address limits, with the configured native limits applied. Preserve every hard resource when using qalter, because its resource list replaces the old list.

Exact frame projection accepted by job14824417: result Hqq/s14_frame_result/s14_result.wl SHA256 ae013e58fcd90e3dfda4a4d75f0e394fd821700832b4f6362250b7034f01c295; checks e106ebd66afc2568a41c5beb4145dc5805b55a2977ee3d652912af62141a69ff; receipt 3d04490b7e92f8480b5eafe3311109d46e6e504d477c832b17d1d286151e3637. Own exact field equality and native reload passed. Measured original/projection ByteCount2455790576/45856, read68.608497s, wrapper130.589481s, childmaxRSS3318575104bytes. This accepts the input projection only; the projected assembly reader still requires native execution.

S14 charge reconstruction contract: inspect the actual saved S12 expression at the failed component before changing weighted[]. Preserve exact CoefficientRules, inherited weights, scientific input identities and all pole/UU-reference gates. Any corrected comparison must reconstruct its own polynomial exactly, including the actual previously rejected expression; no coefficient or flavor weight may be altered to satisfy the gate.

Charge-reconstruction comparison accepted by14824976: Hqq/s14_charge_result/s14_result.wl42cf25c26bc9c535b6497c0fbbca218a561cd32060b8c9cbdcebba0a61192e8b; checksfa7436a8a292daf5b5eaf37300449c7b847190157ab8a8d707ad5e15ab240e06; receipt6ff1cf649f99b1b2dc55aac6e947719a939ff579ac7edd44c9c65f2cdc9a5196. All27 actual first-component expressions reconstruct exactly;7 require Together after Expand. Common/s14_assemble_finite_exact_charge.wls changes only that exact comparison and reuses accepted frame projection; unchanged phase/flavor weights, poles, original scalar projectors and final unpolarized-reference checks remain mandatory. Already accepted finite component caches are mathematically unaffected and may be reused under their original input identity. Full corrected S14/S15 acceptance is pending.

### Finite component cache dispatch

common/s14_assemble_finite_cached_parts.wls checks the existing finite component
file before evaluating phase arguments, using HoldFirst at the dispatch only.
The unchanged original finitePart still evaluates every uncached contribution
and runs its complete pole gates. Bind the same scientific InputHash and Label;
compare a complete own accepted cache value with the original reader and prove
that the phase argument is not evaluated. Record reused file hashes and exact
comparison metadata. Require reversible replacement of only the finitePart
call in assemble; retain all final branch, UU-reference and native export gates.
This cache-order optimization does not alter accepted finite coefficients.
Reviewed source SHA256 0ffae5e7a1a813a5f3537d3159784d2bde2490d5c8937888a6b35c16575bd39b. Native startup comparison is required.

### Regulator-only phase expansion comparison

common/s14_check_regulator_phase.wls retains the complete native Laurent
product and changes only Expand[laurent] to Expand[laurent,eps]. Select an
actual own accepted nonzero Delta/L0 finite checkpoint by its current
scientific InputHash and Label. Compare every Laurent coefficient of the
original and candidate phase products on that complete saved S12 input;
retain exact polynomial reconstruction, kernel-series order, native reload
and original source identities. Record the actual coefficient/kernel,
checkpoint hash, full outputs, zero residuals and measured timings. Its
separate s14_regulator_phase_result is a comparison artifact, not a finite
coefficient. Production requires its executed acceptance and source binding.

Regulator-phase comparison accepted job14825343 in85.260748s, child peak1552961536bytes.
Own nonzero control{{1,1,1},1,L0} used54896 native coefficient bytes.
Original product0.065607s, regulator-only product0.009920s, comparison0.006780s;
all Laurent residuals exactly zero. This measures that control only.
Result a19badb940fe9a3430b8c31787bdd7cf4578433d6d96ca91857c4719321637d5;
checks57f46529fcfb045d4ef9bc12e0a66fad0cfb9f6d9442c8e11b80cb126dd74f37;
receipt222cfc3597efd7c00ecc13d829f92350259c1cd047d95231796599d75ecda691.
Files are hash-verified locally under s14_regulator_phase_result.

common/s14_assemble_finite_regulator_phase.wls installs only those exact saved
Laurent definitions after native/source/input and original-definition checks.
Keep cached component dispatch, full actual phase-polynomial reconstruction,
per-power original-Series comparisons, every pole/branch/UU-reference gate and
S15 contract. Record RegulatorPhaseComparison provenance. Preserve accepted
finite caches; retire the preceding writer before replacement production.
Source SHA256 1041756262c93b364a255f4b726a2450c06fb1ed6a551da81b02e09c656bd883

### Structural regulator coefficient comparison contract

Reuse the accepted structural atom/shrink substitution pattern to keep
regulator-independent subexpressions intact during phaseProduct. Derive the
replacement table from each actual coefficient; require exact restoration
and regulator-independent replacements, the original integer Laurent support,
polynomial reconstruction, kernel and evaluation gates. Preserve original
Laurent-product definitions. Compare the complete saved own accepted phase
coefficient against its bound original value before evaluating the actual
first Regular input. Record actual equations, sizes, timings, definitions
and native identities. Production adoption requires executed own acceptance;
the current assembly and all finite checkpoints remain unchanged meanwhile.

### Structural charge weighting contract

The reference S20 weights pre-separated charge coefficients. Reuse the same
weights after deriving the current charge polynomial with exact independent
coefficient placeholders. Require charge-independent substitutions, exact
input restoration, native polynomial decomposition/reconstruction, and full
equality of the restored coefficient rules to every accepted record in the
own first-component charge comparison. Preserve all names and weight lookup
equations. Bind the accepted proof, actual inputs and native versions. Record
executed source definitions and measurements before any production adoption.

### Accepted compact charge and phase implementation

Job14825737 accepted all27 own coefficient-rule comparisons and original own phase comparison. The first Regular weighted input is7229784 native bytes; its regulator abstraction is2816bytes with55 coefficients. Measured weighting1.303729s and phase0.072282s. Source common/s14_check_structural_weight.wls f099ff3893730d2c046b1f52617ef1c4446de454bbe373775363f44abb41f5b6. Under s14_structural_weight_result, phase proof s14_result.wl710a1e6cae141f262dd50a9517e3c519ecf5047edd2d23ee86b9642d8fbd1f51; charge proof s14_charge_comparison.wl0a390f60c1608fbd9c6c5fc221d8791de9fe0dd56c01fd11153552a8ab8cb09f; checks444475ab93ff92631e0f2d89b82b06f999b8ef37e155de830db1575d4270fa1d; receipt5815dd2eb5647a332e5380cad5fe920fc2e64cf05630fa380aac37e0e0c66714. All are hash-verified locally. This is an accepted algorithm/input comparison, not finite hats.

Production contract: install only those exact saved weighting/coefficient and phase definitions after source, native, input, original-definition and receipt checks. Keep original Laurent equations and original per-power Series comparisons, using the already reconstructed abstract Laurent polynomial for its powers. Compare the entire actual weighted coefficient and phase value with the accepted proof before assembly. Preserve the cached finite reader, all pole/branch/UU-reference gates and unchanged S15 consumer.

### Own saved-pole refinement comparison contract

Reuse the exact accepted Hqg s13_branch_result residual-refinement definitions on the saved Hqq Regular pole and an own accepted nontrivial L0 pole. Preserve the original Hqq physical/flavor assumptions, source/input/native identities and finitePart equations. Require the original control predicate and the candidate to return exact zero; require candidate zero on both the actual saved residue and its original InputParts Laurent coefficient. Snapshot changing inputs by hash. The separate s14_pole_refinement_result is an algorithm comparison, not final hats. Production adoption requires its executed acceptance and leaves every assembly and unpolarized-reference gate mandatory.

Root-first pole contract: derive distinct rational-power atoms from each actual residue, factor only their arguments and normalize them with native PowerExpand/FullSimplify under the inherited conditions. Verify every replacement by exact native simplification of its difference before substitution. Then perform exact Together/Factor on the normalized expression; retain original fallback for unresolved cases. Compare the complete own accepted L0 pole and both saved and original-sum Regular poles before production. Record rules, residuals and timings; a timeout is not a nonzero physics result.

Common-root basis contract: factor actual root arguments natively, prove factor signs on the inherited domain and reconstruct every rational argument exactly. Introduce distinct root variables only for the derived positive factors; verify each original root equals its reconstructed monomial on that domain. Reduce the resulting rational numerator modulo the derived root-square equations and verify the full polynomial-reduction identity. Accept a zero only after exact reconstruction and the existing own L0/saved Regular/original-sum checks. No literal root values or new physical assumptions may be introduced.

### Accepted own common-root pole comparison

Job14826184 passed with source b43b9e438dd20750fd058e3f343e9b096ca0568cc361179c9cfa537791b3dab4. Result s14_pole_refinement_result/s14_result.wl SHA256544b29854428fa6ffefd7550e57029b942aa9d68b2c229e86e3b6c24dd22fa9a; checks11a10c6fcf0deed6b604f0b8352947db50f63c5a4e0324f9dae5ad9d97f2e3a0. The unchanged own L0 control and both saved and original-input Regular poles vanish exactly. Every factor sign, root replacement, denominator domain and polynomial-reduction identity passed. Saved-pole68.666853s versus original-input-pole4.390929s; wrapper149.871213s, child peak1750749184bytes. This is a simplification comparison, not final hats.

Production may evaluate the accepted routine directly on the raw Laurent residue before the original reduce call. Return its exact tool-proven zero when obtained; otherwise retain the original reduction/predicate. Require reversible finitePart-only replacement, exact accepted proof/native/input/source bindings, and all original pole/finite/branch/UU-reference gates. Existing accepted finite components and scientific input identities remain unchanged.

### Accepted complete finite assembly

Hoffman2 job14826413 accepted all144 physical spin/photon components, every pole-cancellation and finite gate, and every original unpolarized Born/F1/F2 comparison on all three branches and Delta/L0/L1/Regular terms. The unchanged compact native export passed exact reload. The entry common/s14_assemble_finite_raw_poles.wls has SHA25603184a96c33d21407daba97b69e0569b86ff6fdc457f5af39d5248ab8b42dc4b; configuration .cluster/s14_Hqq_raw_poles_final_job.json has SHA256693ab880546dacce03eb4a45e20cbe330a64cd2debed7d7c154c391a9e605daa.

Hash-verified local artifacts: s14_result/s14_result.wl def2de598974d0f58b71bf20e96cb76182c75e17ed341a12c15abd3de74b2666; s14_checks.json225dca4cba75e7fd19d22c807ef0fdcd3107864f6ce1677588ebfa9304ce64c4; s14_execution.json8c78e028852e615d9fac51be2e43e04a3254614c676f85d6312de21e9826514f. Native result39140877bytes; wrapper4652.572503s; child peak6019158016bytes. This accepts the finite minimal-subtraction assembly; the separate S15 scheme restoration and final F-hat export must also pass before consuming final hats. Retain the source-bound compact, structural charge/phase and raw-pole proofs recorded above.

### Accepted final polarized F hats

Hoffman2 S15 job14827391 accepted the final Hqq coefficients after the S14 pole/finite and unpolarized-reference gates. The unchanged common/s15_finalize_spin_coefficients_compact.wls applies the defined finite BMHV helicity restoration, preserves the unpolarized coefficient, and checks the full partonic export and exact native file reloads. Configuration .cluster/s15_Hqq_raw_poles_final_job.json SHA256406aeb026b176a0401bd78c049516e915be91d87fa12b28fbedc6ae32314057a.

All outputs are local and hash verified:

- s15_result/s15_result.wl:22dc3335d453d5e0318e6d8a294d1e128ec8fa85ef1c6f67bf90a84b8bf51d99
- s15_result/s15_F1_hat.wl:2bea88b76e14c778f1b3516787a0773de197551ff9692398bcb961092b9e890a
- s15_result/s15_F2_hat.wl:143d6226976c84f6633c8baff5b26d9b3ebd07b9743ef716391d4a6bcf4f99cd
- s15_result/s15_checks.json:bc3f1a01a1b01e8d79a22a355a5b24e0594e37cb2b6dd7cc7a2216849bac5987
- s15_result/s15_execution.json:561e5d1bea65baa90fb21c51cc6d4ac8b6bbfad54883ec1584da04864a2e0794
- s15_scheme_result/s15_result.wl:7e6f7b3b650779295cae18e7c09ece120c205202d536ac527fafd386b68bb2fe

Load the final hats with native Get; their compact files are lossless self-contained Wolfram expressions. The full result retains the photon and incoming/outgoing spin basis, branch and endpoint-distribution conventions described above. Wrapper505.839164s, child peak3978162176bytes. These are finite partonic coefficients for the inherited large-transverse-momentum SIDIS measurement. Hadronic convolution/numerics and jet matching remain deferred.
