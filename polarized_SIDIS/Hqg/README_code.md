# Hqg: incoming quark, tagged gluon

The incoming quark has momentum `p`; the tagged gluon has momentum `k1`.
This tagging differs from Hqq even when the external species coincide.
Keep this channel's charge, recoil, and fragmentation routing.

## S01 inputs

`s01_prepare_inputs.py` uses the shared S01 implementation.
`s01_result/` owns the receipt for the selected pinned open amplitudes.
The original spin-summed tensors are reconstruction references only.

## Spin-dependent contract

The chosen spin basis must specify which quark–gluon spin responses are
required. A gluon tag is not a tagged quark with a renamed label. Do not
assign a quark Collins fragmentation structure or assert a vanishing
component without the appropriate operator definition and executed check.

Later accepted sources/results use consecutive `sNN_` names and the
shared cluster and acceptance contract.

## S03 dimensional Born result

`s03_born_spin_response.wls` links to the shared reviewed implementation.
Its `s03_result/s03_result.wl` passed 47 checks in Hoffman2 job
`14773822` on `n6408`; SHA256
`f08420e83f346d36de3f890ba51c2f31692907a699c0cab5fb96e43eb71c059a`.
The physical response has indices `[photon, outgoing spin, incoming spin]`
and dimensions `9,4,4`, with 20 nonzero dimensional entries.
The internal gluon E component and photon metric complement retain the
regulator information needed to reproduce the full dimensional unpolarized
Born Pg/Ppp. All physical spin components match the independent four-dimensional
verification result. Ward identities, Hermiticity, and reconstruction passed.

The checks and execution receipt are in the same result directory. The
four-dimensional reference is under `s03_result/four_dimensional/`. These
are Born tensors without phase-space factors; they are inputs to NLO
subtraction and are not finite NLO F hats. Peak child RSS was
494735360 bytes.

## S05 real tensor contract

Use the shared S05 implementation and acceptance gates. The generated
process is read from this channel's pinned `s04_diagrams.wl`; the tagged
gluon retains its physical Stokes components and internal E complement.
The reference tensor is `s05_result/reference/unpolarized_real.wl`, SHA256
`bc1dc43674b42c271d37d559b9ef4031118bd04302bfbe201beb2696ef36d362`.
Preserve the tag weight derived from this process and validate the
dimensional Pg/Ppp reconstruction before accepting any tensor.

## S07 virtual tensor contract

Use the shared `s07_virtual_spin_response.wls` and its common README
contract. Keep this channel's original generated loop amplitudes, massless
quark specialization, charge normalization, and tagged momentum.
`s07_result/reference/unpolarized_virtual.wl` is the pinned original
pre-Hermitian virtual mapping result and serves only as an integrand
reconstruction check. Native spin closure precedes physical spin projection;
the complex virtual interference is retained until scalar integration.

## S11 spin subtraction contract

Use the shared S11 program with this channel selection. Its reference
source and result are under `s11_result/reference/`. Retain the accepted
physical Born spin axes under the derived PDF/FF momentum rescalings,
contract S10 kernels in their recorded index order, and verify every
original CDR convolution before accepting the new spin counterterms.
The result retains the reference endpoint distributions and prefactor.
It is a BMHV subtraction input; finite axial-scheme conversion and
complete real/virtual pole cancellation remain final-assembly gates.

## S12 integrated real tensor contract

Use the shared S12 program after this channel's scalar map has complete
verified reduction coverage. Preserve the generated charge and spectator
bookkeeping and evaluate the measured transverse factor in every endpoint
limit. The reference cut masters and distribution assembly supply the
Delta/L0/L1/regular tensors before final normalization and subtraction.

## S11 accepted subtraction tensors

Job `14774826` on `n7140` passed 59 checks, including every
original CDR convolution and all spin-dependent routes. The result
`s11_result/s11_result.wl` has SHA256
`1e6725ce5ad93598bf3744502333e8fee20741c3bb1be368aa9444d6a1a4482f`.
Checks and execution receipt are saved alongside it. The source is the
unchanged shared S11 program, SHA256
`9c5784631fbeb46741b274186985fb21f1607d4063525025517bb0560f11de96`.
These BMHV subtraction tensors retain the reference measure and endpoint
convention. Finite scheme conversion and complete real/virtual pole
cancellation remain assembly requirements. Runtime was 112.187 seconds;
peak child RSS was 459104256 bytes.

## S13 renormalized virtual tensor contract

Use the shared S13 adapter only with this channel's accepted S07 and S09
results and complete reduction coverage. Preserve the physical master
continuation, complex interference, loop measure and generated external
field bookkeeping. Require new-spin UV cancellation, original CDR UV
reconstruction, and integrated Ward checks. Its Laurent tensors require
real and collinear assembly before they become finite F hats.

For the virtual per-diagram CDR comparison, test a reference-completing
auxiliary component defined as the inherited covariant D-dimensional
sum minus the physical U density. Its difference from a purely
evanescent projector is gauge bookkeeping. Require native equality of
the completed sum, unchanged physical spin densities, the entire accepted
extended Born tensor, and the actual first-diagram GitHub contractions
before changing the virtual auxiliary component. The comparison result
belongs to `s07_gauge_completion_result/`.

The gluon-completion comparison passed in job `14775323` on `n7121`.
`s07_gauge_completion_result/s07_result.wl` has SHA256
`ff0502ceb3f982008f2a108675ad77060631f4a194716db52cebf4a38e42f8d9`. Both original first-diagram projections and the
entire extended Born spin response passed. The physical spin density is
unchanged; the auxiliary E component completes the reference covariant sum
for individual diagrams. Corrected virtual runs use new input-bound caches;
previous resolved-gluon E-dependent checkpoints are not reusable.

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

The S15 finite scheme tensor passed Hoffman2 job `14775515`.
`s15_scheme_result/s15_result.wl` has SHA256
`a08152384bf38938e96563abf9b91de1217c4b11b5dfa8d1fb20a78299d51104`. All normalization, helicity-index,
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

The complete S07 virtual tensor was accepted by Hoffman2 job 14778361 on
n6406, including all inherited diagrams and worker checks. Source SHA256 is
b7ea0a41744e3e3a5b17d993276604ddca3a37e1e403379461fb069698e29a90;
Hqg/s07_result/s07_result.wl has SHA256
b5b4b79349842d4383b607b671ea97554b82c1039631f972985d09380c8e308c.
The checks and execution receipt are saved alongside the result. S09 consumes
this accepted tensor. Its loop integration, UV subtraction, and finite assembly
remain separate acceptance gates.

S05 projection resumes may set `POLARIZED_SIDIS_REAL_SECONDS` explicitly
(the default is 2400 seconds, with a checked maximum of 10800 seconds).
This changes only the native time bound. The 2 GiB operation limit and
4 GiB spin-reconstruction limit, all contractions, checks, and checkpoint
identities remain unchanged. The scheduler and process-tree limits must
cover the selected bound. Preserve the preceding source in
`common/s05_result/reference/s05_real_spin_response_before_projection_time_resume.wls`.

The complete virtual map passed job `14779908` on `n7127`.
`s09_result/s09_result.wl` has SHA256
`cb8b13ed50340bd4d62ad593d3c5d8cb018eb9734779197c2f878649610b3484`.
All 15 diagrams and their original dimensional Pg/Ppp comparisons passed.
The map records 205 targets and eight uncovered targets, so it requires
the S09 Kira extension and its master-depth checks before S13 integration.
The unchanged mapper source has SHA256
`4d5ef7c92f3a71f9410d8c1fe2c83e26431f23b84b3a0ea83131bb4bd9f072a5`.
Checks and the execution receipt accompany the local result. This map is
an intermediate integral representation, not a finite partonic coefficient.

The S09 reduction extension passed all 289 checks in Hoffman2 job
`14782253` on `n6406`. It reduced the eight additional targets with no
missing targets, preserved the seven-master basis, reproduced the original
rules, and verified sufficient master expansion depth. The completed map
`s09_reduction_result/s09_result.wl` has SHA256
`4dd48185b5d1fb9c6dbf52ae019253496aa66168da5172db6d2afe5b3d9f70db`;
the scalar table `s09_reduction_result/s09_reduction.wl` has SHA256
`c6281ac00f5488f8c7560fc11c29caf154da74cf8b9a0fca791cdcacdb6e753a`.
Checks and the execution receipt accompany both files. The unchanged
extension source has SHA256
`1e60cbbacb7919ca6a57a130cac2fee3ea6aeee2a7ddba14a634c8df9598fd71`.
S13 consumes the completed map through `POLARIZED_SIDIS_VIRTUAL_MAP`;
UV renormalization and finite real/virtual assembly remain separate gates.
Executed wall time was 458.322 seconds; peak child RSS was 638234624 bytes.

S05 resource resumes may set `POLARIZED_SIDIS_REAL_MEMORY_GIB` to an integer
from 2 through 4; the default is 2. This parameter changes only the native
operation cap. Spin reconstruction retains its 4 GiB cap. Scheduler,
per-process and process-tree limits must cover the selected allocation.
The complete contraction, scalar reduction, pair completion, input hashes,
checkpoint identities and all final acceptance checks remain unchanged.
The pre-parameter source is retained as
`common/s05_result/reference/s05_real_spin_response_before_projection_memory_resume.wls`,
SHA256 `2f207ae75537666abcc6809fef00ff18c48e61c73efebdabdb38b66c4f1459f0`.

## S13 auxiliary UV reduction extension contract

Use the unchanged shared `s13_extend_uv_reduction.wls` through this
channel's entry point. Its source SHA256 is
`d04c5cc50a2cf597c35e2d2952a83a066d86d45700dfce33f0c02de38e53a0e2`.
The manifest `s13_uv_reduction_result/s13_inputs.json` binds immutable
copies of this channel's native missing-target packets under `inputs/`.
The tool must derive the additional targets from those packets, verify
their common mapping identity and inherited auxiliary families, run the
original Kira writer and reader, preserve the original reduction rules
and master basis, reduce every recorded target, and pass the native
saved-result round trip.

Only an accepted channel-owned extension may be supplied through
`POLARIZED_SIDIS_UV_REDUCTION=Hqg/s13_uv_reduction_result/s13_result.wl`.
The S13 consumer must verify its mapping identity against this channel's
current virtual calculation. Physical master integration and all UV,
Ward and original-reference checks remain required. The extension
itself is a reduction input and does not certify a finite F hat.

The auxiliary UV extension passed all 118 checks in Hoffman2 job
`14783189` on `n6406`. The tool reduced the recorded additional
target and preserved the original rules and auxiliary master basis.
`s13_uv_reduction_result/s13_result.wl` has SHA256
`8e7ff2ae5a953953f11d570d4e01dcc4825c38d30f0067904fa2ecf113c6a0cb`.
Checks and the execution receipt accompany the result. Its input manifest
has SHA256 `494c83ed03422f5ac34f31cac1ce2ef500d31306be550de697d7bc5b33431400`.
The immutable missing-target packets remain under `inputs/`; the native
Kira work is retained under `cache/s13_uv_extension/Hqg/` on Hoffman2.
S13 may consume this accepted table after checking its own mapping identity;
its completed original-rule task checkpoints remain reusable. UV cancellation
and finite real/virtual assembly are still required. Executed wall time was
32.634 seconds; peak child RSS was 335560704 bytes.

## Completed-stage cache archives

The completed S07 per-diagram cache is preserved in
`s07_result/s07_cache.tar.gz`, SHA256
`3ab9dd33549e00726bdf267724f1be1e2e261b57ca34cedbfbfe8a90a9f62487`.
The accompanying `s07_result/s07_cache_manifest.json` binds every member
to its original byte count and SHA256 and records accepted producer job
`14778361`. Every member was read back and hash-verified
before the uncompressed completed cache was removed.

The completed S09 per-diagram cache is preserved in
`s09_result/s09_cache.tar.gz`, SHA256
`8180e78fc7e97ad0decfed36b3c52a0f3bea1df323e9192ae69cb066a406a518`.
The accompanying `s09_result/s09_cache_manifest.json` binds every member
to its original byte count and SHA256 and records accepted producer job
`14779908`. Every member was read back and hash-verified
before the uncompressed completed cache was removed.

The archives and manifests are retained locally. Remote duplicate archives
were removed only after the local and remote SHA256 and byte counts matched;
the remote manifests and accepted stage results remain available. Current
consumers read those accepted results. To resume an archived producer, transfer
the archive back with a SHA256 check, then restore its members relative to
the polarized_SIDIS root at the manifest paths and verify every member.

S13 resource resumes may set `POLARIZED_SIDIS_VIRTUAL_SECONDS` to a
positive integer at most 10800; the default remains 1200 seconds. This
changes only the native operation time bound. The 2 GiB native memory
bound, UV equations, master integration, normalization, task order,
checkpoint identity and all acceptance checks remain unchanged. Verify
the complete implementation against the retained pre-parameter source
`common/s13_result/reference/s13_assemble_virtual_spin_before_resource_resume.wls`,
SHA256 `cb690814cc4ae374503ac0f6af01a435e0f37a6076cc6cac081e483fee867c7f`,
after removing only the explicit resource configuration and verification
blocks. Every worker must receive and confirm the configured time bound.
Before production, use the existing parallel-comparison mode to reproduce
one of this channel's accepted nonzero UV task checkpoints with a fresh
worker and the same auxiliary reduction table. Keep the scheduler and
process-tree bounds in force.

Job `14783382` on `n7041` accepted the resource interface with
142 native checks. A fresh worker reproduced this channel's
accepted nonzero serial UV checkpoint exactly, using its accepted auxiliary
UV extension. The result `s13_parallel_result/s13_result.wl` has SHA256
`e34079c7a3ae5b3d15248267aebb394352366cd93de2da3478908001f5a495b5`.
The matching checks and execution receipt accompany it. The reviewed source
is `common/s13_assemble_virtual_spin.wls`, SHA256
`44bc4684e7aa164e7d9e0928bb2572c7f7ea146e8215653516fef6bf1e729989`.
The run verified equality of the complete earlier implementation after
removing only the declared resource interface, and verified the same
configured bound on every worker. Runtime was 149.812 seconds;
peak child RSS was 1001123840 bytes. The mathematical input
identity and accepted task checkpoints remain unchanged. This validation
accepts the resource interface; a complete S13 tensor and S14/S15 checks
remain required for finite coefficients.

## S05 scalar-equation inspection contract

`../common/s05_inspect_scalar_equation.wls` inspects the actual native
projection selected by `../common/s05_scalar_inspection_inputs.json`.
It loads the unchanged production initialization, pair definitions and
accepted scalar-restoration definitions. Instrumentation must reproduce
the complete original scalar reducer after removing only the timing wrappers.
The output in `s05_scalar_equation_result/` records the traced expression,
the actual scalar input at the slow operation, its denominator inventory,
the defining transverse constraint, timings and an exact saved-file reload.
The selected same-channel accepted projection is hash-bound for a later
comparison. This inspection neither changes production algebra nor accepts
an optimization; any replacement must reconstruct the captured equations
and reproduce the accepted projection before production use.


## S05 coordinate reuse contract

`../common/s05_check_coordinate_cache.wls` applies the existing scalar-product
memoization pattern to the unchanged `coordinates` routine. It must preserve
that routine's exact native definition and every trace, scalar-restoration,
transverse-reduction and angular-average equation. Cache at most 256 vectors
and 16 MiB per kernel. Derive the control pair and projection from its pinned
checkpoint filename, reproduce that complete own-channel accepted value, and
execute the explicitly selected timed-out projection. Keep early trace and
completed projection checkpoints in an isolated input-bound cache; do not
write the active production cache. The result in `s05_coordinate_cache_result/`
records the executed definitions, actual coordinate values, hits, misses,
timings, candidate projection and all exact checks. Production use requires
successful comparison and exact saved-file reload. This comparison alone
does not accept a complete real tensor or any finite NLO coefficient.

## S05 completed scalar coefficient reuse

`common/s05_real_spin_response_cached_scalar.wls` may load the scalar
checkpoint definitions accepted by Hgg comparison job `14796018`, result
SHA256 `448fa9968a5bc362fe8ff7d2a31a7a2e5284a04a81a2ce7a8d88a135f3440c3f`.
Require the same native reduction definitions, transverse constraint,
spin/angular conventions and runtime. Each cache entry is bound to this
channel's own physical input hash and its fully restored coefficient.
Trace, scalar reduction, angular averaging and complete channel gates are
unchanged; process-specific temporary files prevent shared temporary writes.
The shared variant source SHA256 is
`ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff`.
It also retains the accepted spin-polynomial reconstruction and lossless
chunked native storage. Keep the main loader, payload manifest and all
listed SHA256-bound payload parts together, and require exact full-output
reload. The independent coordinate comparison remains separate until its
own executed gates pass. No coordinate algorithm is changed by this variant.


## S13 UV-residual inspection contract

The complete S13 acceptance gate rejected component `ExtendedResponse[4,4,4]`
in job `14796515`, after all UV task checkpoints and both original CDR
comparisons passed. No complete Hqg S13 result is accepted from this run.
`common/s13_inspect_uv_residual.wls` and `common/s13_uv_inspection_inputs.json`
reproduce only that assembly component using the unchanged production prefix,
accepted input files and completed UV checkpoints. Print and retain its actual
per-diagram residues, summed Hermitian UV residue, Born tensor, field/coupling
counterterms and residual, with exact source/input identities and native reload.
An inspection success means the diagnostic was exported; the separate
`UVCancellationPassed` flag must not be treated as true unless calculated true.
No production correction or cache invalidation is authorized by this diagnostic
alone; identify the originating expression and affected outputs first.

The inspection passed job `14796553`; its result SHA256 is
`91c455e0a0e7e246a37d3ecb526dc3e2d172e5f179692f7f61b125b95a37cca5`.
`common/s13_check_uv_branches.wls` tests that saved residual using the exact
physical assumptions read from the production source. Require exact zero of
both the original residual and the complete saved Hermitian/field/coupling sum
before using residual refinement after the original S13 simplification. The
Hermitian amplitude and all counterterms remain unchanged. Retain the comparison
in `s13_branch_result/`; the earlier conjugation candidate did not pass its
complete comparison and is not used in production.

`common/s13_assemble_virtual_refined.wls` may run only after the residual
comparison passes. It loads the unchanged source and completed UV tasks, checks
the comparison's receipt, input identities, assumptions and native versions,
and inserts its exact saved refinement definition immediately before the
existing complete-UV-cancellation gate. Preserve all assembly equations,
counterterms, Ward checks and output schema. Record the dispatch source and
comparison hashes alongside the original calculation identity in the output.

The residual refinement passed job `14796603`. The comparison result
`s13_branch_result/s13_result.wl` has SHA256
`61a7a702157262d0dbc758922569184b26603ed2cb7986cb6a75430920578b7e`.
Both the originally rejected residual and the independently reassembled saved
UV sum returned exact zero under the inherited physical assumptions. Its source
SHA256 is `55494a9171c36213d476b2f518a748d7f8023921e98dc51124c6461dd7f5348a`;
checks and receipt are saved alongside the result. This establishes a residual
simplification issue in S13 rather than a changed counterterm. Full channel
assembly and all final finite-output gates remain required.

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

## Accepted complete S13 virtual assembly

Job `14796613` on `n7133` passed all 187 recorded checks, including
componentwise UV cancellation, integrated photon Ward identities and the
complete virtual-component inventory. `s13_result/s13_result.wl` has SHA256
`f248fe71494c4e0c3ba9977cb034814109e23602dcbfa36dd037329fd2bb44b6`;
`s13_checks.json` has SHA256
`f6310be5509685589e0792132a7d6021ddfc9dc68554203452868f3883f63654`.
The matching execution receipt and both artifacts are verified locally.
The dispatch source `common/s13_assemble_virtual_refined.wls` has SHA256
`1009fc9778874ba0f285c7ebcd09e3fd38a712ee0f286d05483fa25d618ba331`. It reused the original loop, UV and field/coupling equations,
adding only the accepted physical-domain residual refinement before the
unchanged exact-zero gate. Runtime was 527.358 seconds; observed peak
process-tree RSS was 1,614,880,768 bytes. This is the complete loop-integrated,
UV-renormalized tensor; S14 must still combine it with real and collinear
terms and cancel all remaining poles before finite F hats can be exported.


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

The corrected S11 generation passed job `14799109`. Its result SHA256
is `12fa352ba9ae7edde73e3cfda989e4f4ed2c81864c0808503500a995bcc0486f`;
checks SHA256 is `534ad443caa21624a5610b113ae919575f69a2f4a28e3e1af9b3b38f85983778`;
execution receipt SHA256 is `9bb5738609b14b27624e9a489301a198105d9f1e90e3026c5f4486e971adf284`.
All own-route D=4 comparisons, unchanged-route comparisons, inherited
reference and endpoint checks passed; the complete counterterm difference
is pole-free. The source SHA256 is
`4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6`.
The matching code and result are retained locally. Earlier S11 and S15
scheme artifacts remain versioned; final assembly must use this result.


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


The finished scalar-equation diagnostic log is losslessly retained on
Hoffman2 as `s05_scalar_equation_result/s05_native.log.gz` (2,604,948 bytes;
SHA256 `1b5ec300470246238dd6b9d934fb1f45725d97b79491010127d892a76ae192a7`).
Decompression reproduces the original 63,282,034 bytes with SHA256
`8d8f6f57ed2ce8b35dc3470a43f3d4163e6997077a407230fa8555c368796dc0`.
The original producer `14795605` and its native writers were absent before
compression; the equation result and all production checkpoints were kept.
This diagnostic archive does not certify the inspected projection.


Archive job `14800589` passed in 237.536 seconds. It preserved
14 completed pairs and archived 33,002,449 source bytes into
7,853,201 bytes. The manifest SHA256 is
`4eb930bf639566098b7e3b423c5d5dc77a2f94443e398fed873a1bc327fccd23`;
the archive SHA256 is
`ed52a96027e1542363b750a9170ad612fe66f060ed378737981702462595e905`.
The matching execution receipt SHA256 is
`c27dd5c8498561637a6dd062f5395833be488dab374cdadd2775604218f353f0`.
These artifacts are verified locally under `s05_projection_archive_result/`.
Restore only manifest paths and require each archived member hash before use.


## Allocation-bound continuation and final-assembly review

Continue the existing measured real calculation from its accepted scientific
checkpoints. Require the same command, mathematical inputs, operation limits
and native acceptance gates when changing execution guards. Subsequent S05
allocations retain four shared slots; their process and combined RSS guards
leave 2 GiB below the total scheduler allocation.

After accepted S12 integration, bind the actual result and review its native
loading and export requirements before S14/S15 submission. Reuse accepted
finite assembly, scheme conversion and exact native serialization interfaces;
collect the matching scheme artifact with the final hats. S12 completion is
not finite-hat acceptance. This execution boundary preserves all mathematical
stages and prevents reuse of obsolete finite-export resource settings.

The Hqg continuation keeps 4 slots with h_data=5G per slot,
with both execution guards set to 18 GiB. Equations and checkpoint keys are unchanged.

## S05 polynomial scalar comparison contract

`common/s05_check_polynomial_scalar.wls` tests polynomial slicing of the
actual saved native projections listed in `common/s05_polynomial_scalar_inputs.json`.
Derive eligible variables and powers from each expression; require polynomial
dependence, variable-independent denominators and transverse constraint, and
an exact inverse coefficient map. Apply the original on-shell reducer, including
its full reconstruction checks, to every coefficient. Retain the unchanged
coordinate equation through bounded memoization, scalar restoration and angular
average. Both complete saved Hqg projections must reproduce their original
accepted values exactly. The comparison records actual scalar inputs, slice
powers, timings and input hashes and must pass exact native output reload.
Its files belong to `s05_polynomial_scalar_result/`; it must not write production
projection or scalar-coefficient caches. This is an isolated algorithm comparison,
not an accepted production optimization or a finite partonic coefficient.

The polynomial-slicing candidate is not accepted. Comparison job `14812563`
on `n6041` did not finish its first control and reported the native operation
time limit. The recorded baseline reduced that control's first restored input
(6,793,728 native bytes) in 355.677202 seconds; the candidate was still inside
its last slice after a longer observed interval. It supplies no accepted
projection or speedup. Its source and failed execution receipt are retained
for identification, and it must not be installed in production.

## S05 interrupted scalar input recording

`common/s05_real_spin_response_recorded_scalar.wls` retains the accepted
cached S05 implementation and its scalar-coefficient keys. Before the original
scalar reducer executes, write its exact restored argument to a bounded,
compressed native file under `cache/s05_pending_scalar/Hqg/`, with the
physical input, argument, algorithm and dispatch identities. Verify exact
native reload and test the storage interface on this channel's actual accepted
projection before starting contractions. A successful scalar evaluation removes
its diagnostic input; an interrupted evaluation leaves its input for inspection.
These files are diagnostic inputs, not completed scalar checkpoints.

Require exact reversal of the recording-only definition substitution and
unchanged scalar reduction, angular averaging, pair completion, normalization,
scientific checkpoint and final-acceptance equations. Keep the existing native
operation-time interface, including its allowed maximum of 10,800 seconds, and
the allocation memory guards. Record the observer dispatch identity separately
from the unchanged mathematical source and cache identities. The complete S05
checks and downstream integration/finite-assembly checks remain mandatory.

The isolated recording-interface check executes this exact reviewed entry
through its native storage probe and definition gates, then stops before
the contraction tail. It uses the actual accepted Hqg projection and preserves
the production caches. Its inline native command is bound in
.cluster/s05_Hqg_recording_interface_job.json; its checks and execution receipt
belong to s05_recording_interface_result/. Passing this interface check does
not accept additional real contractions or finite coefficients.

Job 14813155 on n7043 passed all 103 recording-interface checks in
95.566832 seconds, with 970,764,288 bytes peak observed process-tree RSS.
The exact accepted projection round-trip, cleanup, definition reversal and
unchanged scalar/angular equations passed before contractions. The checks
SHA256 is 63002b3238a74df381620745e101c7ea0d6547b82b71b9efad23bed028b5b38d;
the execution receipt SHA256 is
3007e6181d2c20359922524d033954af5402b1bc05222f13fe7b18191e01653a.
Both artifacts and s05_native.log are verified locally. This accepts the
input-recording interface only; no additional physics result was computed.
The isolated runtime directory cache/wolfram_s05_Hqg_recording_interface has
no production or resume role after this completed check and is disposable.

The recorded scalar-equation inspection reads immutable copies of actual
pending inputs from job 14813349, under cache/s05_retained_scalar_inputs/Hqg/.
The inline native entry in .cluster/s05_Hqg_scalar_equations_job.json verifies
their file, source, native-version and argument identities, exports the complete
ScalarInput equations to s05_scalar_input_result/s05_input_NN.wl, and requires
exact native reload. These are readable reduction inputs, not solved coefficients
or an accepted optimization. Production inputs and reducers remain unchanged.

The readable-input export passed job 14813403 on n6129 in 28.315011 seconds.
Both complete equations passed exact native reload and their original argument,
source and native-version identity checks. The checks SHA256 is
2fb77b71346116cb98baed45d7564c3697487272c04039125681241bb363d666;
the execution receipt SHA256 is
d95c278f05f2568bedb759e1e950c37a408a74e33de5f6f8fb6ebfda82a657da.
The complete equation files, checks, receipt and compressed source inputs under
s05_scalar_input_result/reference/ are hash-verified locally. Restore a source
copy at the original path in the checks before reproducing this inspection.
The isolated cache/wolfram_s05_Hqg_scalar_equations runtime has no continuing
production, resume or provenance role after collection.


## S05 factor normalization comparison contract

common/s05_check_factored_scalar.wls (SHA256 b71e6e54cad58d443a2c6dd28861fd8269220ec5f041051c7e67d8e76691e397)
uses the unchanged original initialization and scalar reduction equations.
Its candidate factors the distinct nonatomic bases of integer powers in the
actual scalar input once, proves every base identity and exact inverse
substitution for the complete input, then invokes the original reducer.
No angular, spin, coordinate, normalization or on-shell reconstruction
equation changes. Production caches are not written by this comparison.

The inputs in common/s05_factored_scalar_inputs.json (SHA256 8d01d642923d855eed818029e4982581f57024d403a12560ab50907bac0f2086)
bind both native scalar arguments recorded by job 14813349 and the two
accepted Hqg diagonal/off-diagonal photon projections. Require both full
projection comparisons, all defining reduction gates, actual normalization
measurements and exact native save/reload before adopting this candidate.
Its result owner is s05_factored_scalar_result/. No speedup or production
acceptance is established by this pre-execution contract.

The job configuration ../.cluster/s05_Hqg_factored_scalar_job.json
(SHA256 3d63e1d98d4de8fa6d1ba135b82854447c36f9a0762ad58e661274b382f6f081) requests one shared slot,
8 GiB and two hours, with 7 GiB wrapper guards and a 4 GiB native bound.


## S05 earlier angular averaging comparison contract

common/s05_check_angular_first.wls (SHA256 dde7a175a086fee41f9a3a1b0144bfbed6a4298d8e5eb844ccb6734378257fa5)
tests the inherited angular operator at the restored scalar-coefficient
boundary, after all epsilon and coordinate contractions. Preserve the
original coordinate, scalar-restoration, rational on-shell reduction and
angular definitions. Require polynomial angular dependence, angle-free
denominators and transverse constraint, exact coefficient reconstruction,
and equality of every used monomial moment with the original operator.
Only then reduce the averaged expression with the original scalar reducer.
The final angular operator remains in the complete projection pipeline.

Inputs are pinned in common/s05_angular_first_inputs.json (SHA256 abb6b99df9509383e43147e9987d4d2d7c4dffbee3dd95b9f33917d59987a995).
Both complete accepted Hqg projections must reproduce exactly. Recorded
scalar outputs explicitly carry AngularAveraged=True; they cannot replace
pre-average scalar checkpoint values. This comparison writes only under
s05_angular_first_result/ and never modifies production coefficient caches.
The isolated job ../.cluster/s05_Hqg_angular_first_job.json (SHA256 100be373b431eeb939cd218ffc640d8337a9d74c3ffc00d433ae71ac81619754)
uses one slot, 8 GiB and two hours with 7 GiB wrapper and 4 GiB native bounds.
Own complete comparison and reconstruction checks are required before any
production adoption; no optimization or final coefficient is accepted here.


## S05 factored-term angular comparison contract

common/s05_check_angular_terms.wls (SHA256 66b62ff921f492be4bbf940e1c3a597a01f96e59d385cd48e56cf7ddec1610c4)
uses selective angular expansion and derives each term degree from its
actual expression. Require exact reconstruction of every term and the
complete input, preserving factors independent of the normal coordinate.
Apply the unchanged inherited moments and original scalar reducer only
after epsilon contractions and scalar-product restoration. Retain all
angular-domain, moment, definition and complete own-projection gates from
the preceding comparison. Record expression sizes and executed timings.

The input packet common/s05_angular_terms_inputs.json (SHA256 7675759f598bc0a2dc4d0de016ff8ede8c06132c1e15dc307336ea6d9b722f2d)
also pins the newly completed original even scalar coefficient at
s05_angular_terms_result/reference/s05_even_scalar_control.wl (SHA256
c5b70d36ba15440be41fbba70fa5c5f7bdaaeeea5f5ada7db3ebdb751f4c2b50). Require the candidate
average to reproduce its original angular average exactly, with matching
input and argument identities. This baseline is verified locally and
remotely. Averaged candidate values remain distinct from pre-average
production caches. Only complete executed comparisons can accept a change.

Job ../.cluster/s05_Hqg_angular_terms_job.json (SHA256 ce858b9dbc3756a47fe4bb660d8d19612fda6bf7d5e20da344f8785b91c1f92e)
retains the one-slot, 8 GiB, two-hour comparison allocation and all bounds.


The factor-only comparison is not accepted: job 14813428 reached its native
operation time bound before completing the first recorded scalar. Its receipt
SHA256 is dbfd1c728c42afe3d8cbe3955035a4b8bbe137d2888cad59858547a0ba9ca81c.
It produced no accepted complete projection and must not be installed.

The coefficient-collection angular comparison, job 14813432, was retired
before either complete projection comparison passed. Its recorded inputs
completed in 13.680752 and 1022.636958 seconds, but coefficient collection
expanded the second input to 207027008 native bytes. Its partial scalar files
under s05_angular_first_result/ are diagnostic comparison outputs, not an
accepted production algorithm. Receipt SHA256:
3972036ef70ecb852ef81e80af8c9ae19fce82da04672504eff0484ed9513644.
The receipts, native logs and partial scalar values are hash-verified locally.
Both isolated runtime directories were removed after their jobs exited;
production caches and the recorded original inputs remain intact.


The term-preserving angular comparison is not accepted: job 14813440
reached the native time limit during its first complete projection. Its
even recorded scalar reproduced the original angular average exactly in
679.722987 seconds, but that partial comparison does not validate a full
replacement algorithm. Receipt SHA256:
2f63444f250431801fbbe992c0327d68323a141a8f181064717da475f0efe089.
The receipt, native log and partial scalar values are retained locally; the
isolated runtime was removed after exit. Production reducers are unchanged.

## S05 exact zero angular-moment shortcut contract

common/s05_check_zero_angular.wls (SHA256 2c40af2197fdc38e01aa9f617a6aae94d855389a0eabd069f65f1fcf74db44b6)
tests only coefficients whose actual inherited angular moments are all
exactly zero. Preserve angle-independent denominators and the on-shell
constraint, and require exact input/term reconstruction and every used
moment to match the original angular operator. Insert the predicate after
the original cache lookup; every nonzero reduction remains the original
code. Never store an averaged zero in a pre-average coefficient cache.

Require a nontrivial recorded input to exercise the actual guarded cache
interface without writing a cache value, and a nonzero input to retain its
original reduction path. For each saved own-channel complete projection,
restore every actual raw spin coefficient, independently prove each zero
replacement against its accepted coefficient, and reconstruct the whole
projection. Reuse accepted coefficients for the unchanged nonzero path;
the comparison explicitly records that those reductions are not recomputed.
Require a nontrivial shortcut in the own-channel projections, unchanged
reduction definitions, native reload and all bound input identities.

Input configuration common/s05_zero_angular_inputs.json has SHA256
86671c78ed1f2d0efcc2e0b0eb3a6269ca576879b0b7a3c5cf7b71184359d3e5.
Job .cluster/s05_Hqg_zero_angular_job.json has SHA256
4716857de4686b93d84486dde73d2e925ed9b4a031d04c55b0c66e3a0078c10f.
The isolated validation retains one shared slot, 8 GiB and two hours,
with 7 GiB external guards and the original 4 GiB native bound. Results
belong to s05_zero_angular_result/. Passing this comparison can accept only
this narrow shortcut; complete production S05 and finite-assembly gates
remain required. No production adoption is authorized by this contract alone.


## S05 zero-moment production adapter contract

common/s05_real_spin_response_zero_angular.wls may run only after the
complete own-channel zero-moment comparison has passed. Require its matching
execution receipt, source/configuration hashes, complete checks, native
versions and physical input identity. Install only its executed predicate
and guarded coefficient definition, after proving the original definition
matches production. Retain the original nonzero reducer, angular operator,
coefficient cache identity, projection checks and final tensor gates.
Distribute the predicate to the existing workers and record its proof and
dispatch hashes separately. Preserve completed checkpoints and start only
after the previous writer has exited. Any scheduler resume keeps the
existing four-slot allocation, operation limits and external memory guards.
The adapter itself does not certify a complete tensor or finite F hats.

The complete zero-moment validation passed job 14813481 on n6637 in
631.018463 seconds, with 795463680 bytes peak observed process-tree RSS.
Result SHA256: 5652da0e601652452b43370aaf27f376b628d041eb0aa20641683d420b50abd3.
Checks SHA256: f809a1a75b0030b2bdbf534fa5f62f267fd63a15fcbe77b4b51368b3e2c8e36a.
Receipt SHA256: 7fb216094c1d7593fd3b084ee5775bf21b4a14577593481d365d3bb6e64cbb67.
Both complete own projection comparisons passed, each with nontrivial
shortcuts in components 4, 8, 9, 13 and 20. Their unchanged nonzero outputs
were reused explicitly; every proposed zero was independently checked.
Recorded input predicates took 0.321492 and 2.436630 seconds. The actual
guarded cache interface returned the derived zero without writing a scalar
cache value. These measurements validate the shortcut, not an end-to-end
production speedup. Files and receipt are verified locally.

Production adapter source SHA256: d9f626dea56ab0165dc954f4ca06bc9c90d85d6c0ff511a4a0820a7686e561cb.
Interface configuration .cluster/s05_Hqg_zero_angular_interface_job.json has SHA256
64ef69efc3f73d140adc12b5f5ce79d77b3e55f8bbb83a3ac015fd129b9a81c2.
The interface-only run stops before contractions after loading the actual
accepted proof and testing all source, native, input and installed-definition
gates. Its checks belong to s05_zero_angular_interface_result/. It requests
one shared slot, 6 GiB and 15 minutes, with a 5 GiB process/tree guard.

The zero-moment adapter interface passed job 14813493 in 47.075313 seconds.
Checks SHA256: f6ba514a2ba7570c2445fbbd9ab561b86f069840515764aef581d69d15a51ff8.
Receipt SHA256: c66fdf07a67d2c942a49fbde55d238dbdc13dd0b33ff4d48f99620c81888426c.
Both files and the native log are verified locally. This accepts the native
proof loading and installation interface, before production contractions.

## S05 failed-projection memory allowance

Job 14813349 reported a native memory bound for {"Real", {1,6}, 1,3};
its other workers and completed coefficients remain usable. Amend only that
projection's native allowance to 8 GiB, within the existing four-slot, 20 GiB
scheduler allocation and 18 GiB external guards. Every other projection keeps
its 4 GiB bound. Require a unique source substitution and its exact inverse;
retain the accepted zero-moment predicate, all nonzero equations, physical
inputs and checkpoint identities. Record the resource override in the result.
The preceding adapter source is retained as
common/s05_result/reference/s05_real_spin_response_zero_angular_before_memory.wls
(SHA256 d9f626dea56ab0165dc954f4ca06bc9c90d85d6c0ff511a4a0820a7686e561cb).
Exercise the amended adapter against the accepted proof before production.

The amended adapter SHA256 is 232e4cb7f02871bf8c69528b997f1d8b71ddd491caf36d69e99af909269064cb.
Its memory-interface configuration .cluster/s05_Hqg_zero_angular_memory_interface_job.json has SHA256
a0063a7b02afdd55b43d40ac4d5d15c93814474d40edb64b0645efb05fcb4558.
It retains the preceding interface contract and bounds; its separate
checks and receipt belong to s05_zero_angular_memory_interface_result/.

The amended memory interface passed job 14813501 on n7408 in
54.342741 seconds. Checks SHA256:
1b6384b403663327dbff93739e2e1435baa1733f6242efcf456d88c747979578.
Receipt SHA256:
b50165aa30306a944d67861eda7e640ed8d2bab1a4f9b982a2636465e017a859.
All native input, proof-loading and definition gates passed; its matching
artifacts are retained locally. Its disposable runtime was removed after exit.

Production continuation .cluster/s05_Hqg_zero_angular_continue_job.json has SHA256
44fb40813dee1eee6c168a0062dad9507fe1a4c8261253a29bd9b6b5b8134ab2.
It retains four shared slots at 5 GiB each, the 18 GiB external guards,
10800-second operation bound, complete stage gates and prior checkpoints.
The controller may select it after the current writer exits, including the
observed memory failure only for the specifically amended projection. Any
other memory or mathematical failure requires inspection before resubmission.

## Verified per-process data limit

The actual JOB_ID-bound kernels of 14813349 on n7043 report RLIMIT_DATA
5368709120 bytes and RLIMIT_AS 19327352832 bytes. The address-space guard
does not raise that scheduler data limit. The next accepted zero-angular
continuation therefore uses two shared slots at 10 GiB each, preserving
the total 20 GiB reservation and both 18 GiB external guards. This
supersedes the four-slot, 5 GiB-per-slot request for this continuation
and leaves headroom for the specifically allowed 8 GiB native projection.
The native source, JSON configuration, equations, operation limits and
checkpoint identities remain unchanged. Retain the qsub request in the
submission receipt; use the same accepted config SHA256
44fb40813dee1eee6c168a0062dad9507fe1a4c8261253a29bd9b6b5b8134ab2.

Resource interpretation was checked against the current official production
guide at https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing-Altair-production.html
and the actual running kernel limits. No current compute job was interrupted.

## Final provenance interface correction

Review found a multi-argument `AssociateTo` call in the zero-angular adapter's
final provenance update. Its prior source is retained as
`common/s05_result/reference/s05_real_spin_response_zero_angular_before_provenance.wls`
(SHA256 `232e4cb7f02871bf8c69528b997f1d8b71ddd491caf36d69e99af909269064cb`).
The correction passes the metadata rules as a list. Before contractions,
execute the exact publication expression against the actual proof/source
identities and require the complete resulting association. The independent
interface run records this check under `s05_zero_angular_provenance_interface_result/`.
It must pass before the amended adapter resumes production. Scalar equations,
zero-moment definitions, task bounds and scientific cache identities are unchanged.

The corrected interface passed job `14813554` on `n6132` in 112.765427
seconds, including the actual complete provenance update. Adapter SHA256:
`2fc40e6a92e854cde292568c4e8ec09c600a113ec0e35d2085f9fc17b07cf2f3`.
Checks SHA256 `137b6aecd602ca996b61948a070a68c6b0b0bddd045c08c4451da43c2ae69edd`;
receipt SHA256 `57f560e8984ef9cf5e9308dc53d079f11bde0928e178119cff7f4818338182e0`.
Both artifacts are verified locally. The continuation must bind this amended
source and receipt; retain two slots at 10 GiB, the 18 GiB external guards,
and the original complete S05 gates.


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


## Compact real-assembly inputs

The reviewed `common/s12_assemble_real_compact_inputs.wls` keeps the reference
recurrence contract above and retains only the component fields actually
consumed by S12: Sector, Kind, Index and ReducedCoefficients. It validates the
complete accepted S08 artifact first and requires exact equality of every
retained consumer field. Record the original and projected native byte counts
in the own comparison and final S12 result. Preserve the complete source-file
input binding, unchanged endpoint equations and native own-input comparison.
No memory or timing improvement is accepted without the executed measurement.

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


## Native trace-input interface

`common/s05_prepare_trace_inputs.wls` reuses the complete accepted S05
initialization, pair construction and photon projection without evaluating
the long traces. It saves the exact projected expressions for pairs (1,6)
and (1,7), photon components (1,1) and (3,2), together with the native
input identity, spin variables, source hashes and runtime. Require exact
native reload and bounded files. The plain equation export permits direct
inspection. These are inputs, not evaluated tensors or accepted optimizations;
the running production cache is read-only to this stage.

The native trace-input export passed Hoffman2 job 14814332 in 75.606453
seconds. Result SHA256 is
`7b811300f44286a675f80954a07ff8d338d1dfc20f17b052801366070b440d77`;
matching receipt SHA256 is
`4b10d6cf2ab4c3f15c67f21301ec4ff1bca42d498ceab08929627caf6f5bdc73`.
The local plain native result contains all four exact input expressions.

`common/s05_check_precontracted_traces.wls` tests only moving the existing
Lorentz contraction before the unchanged Dirac trace evaluation. Preserve
BMHV, physical and evanescent dimensions and the complete spin variables.
Compare the full traced difference with the accepted pair (1,7), photon
(1,1) trace through the unchanged scalar and angular reader. Require exact
zero and matching accepted projection/input identities; use an isolated
scalar cache for this comparison. Then measure the actual (3,2) inputs of
pairs (1,6) and (1,7), recording exact values and timings. This comparison
is separate from the production cache and cannot accept a complete tensor
or establish a speedup before its own executed evidence exists.

The complete trace-order comparison passed Hoffman2 job 14814379 on n1162
in 446.226943 seconds. Its result SHA256 is
`f27aba6db432fe11f8d81b561382d550e0e61b255f68828fa80606edccc4419e`;
checks SHA256 is `e2532f5ada3b93a740763dcc50b93f3076e66765466f67f071c2fe035998c37f`;
receipt SHA256 is `5e506014f2ec36370a7b841d4bf044604495ccd56f8747f045a8bab22dfec622`.
The full control trace difference vanished through the unchanged scalar and
angular reader. The (1,6) and (1,7) photon (3,2) cases took 148.079365 and
125.991262 seconds including contraction, respectively. Their original
production log recorded trace-call times of 516.001127 and 600.23293 seconds
for this two-input set; the interleaved log does not label each timing by pair.
This is an own-input trace timing comparison, not a full-stage speedup.

`common/s05_real_spin_response_precontracted.wls` installs the exact accepted
trace definition and retains the zero-angular dispatch, scalar reductions,
physical input/cache identity, projection checks and final assembly. Reuse a
saved comparison trace only when its full native input hash matches. Require
the preceding producer and its native kernels to exit before the new writer
starts. Preserve every accepted projection and scalar checkpoint. The original
complete tensor and unpolarized-reference gates remain mandatory.

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

### S05 own early-power scalar comparison contract

`common/s05_check_Hqg_scalar_power.wls` reuses the exact candidate definitions from the accepted Hgg scalar-power comparison. Its input is the previously recorded nonzero Hqg scalar equation identified by the accepted own zero-angular proof. Acceptance requires matching source/runtime/input/constraint identities and exact equality to the completed own pre-average scalar coefficient in the canonical cache. The original long reduction is reused, not rerun. The comparison records the full equation, original accepted value and measured candidate value in `s05_scalar_power_result/s05_result.wl`. Production remains unchanged until that comparison passes.

### Accepted S05 own early-power comparison and consumer

Job `14814441` reproduced the complete accepted pre-average scalar coefficient for the retained 16328288-byte Hqg equation. The candidate took 49.506082 seconds. The original `s05_Hqg_recorded_checkpoint_continue.log` reports 2932.793393 seconds for the identical argument hash `90019a5b7b789436d04aeb3ea3eb52dfb59ab1f0da21041a414634161ede8608`; these measurements came from separate jobs and do not measure an overall stage speedup.

- `Hqg/s05_scalar_power_result/s05_checks.json`: SHA-256 `82d50646755ebc4bd4552d3f94c969e244c7d4822361b4299492384365f90317`.
- `Hqg/s05_scalar_power_result/s05_result.wl`: SHA-256 `fcfe41f590c45f3aa7f516c477cc0766c975f655726d5180494640c85c1fe8d7`.

`common/s05_real_spin_response_Hqg_early_power.wls` retains the executed contraction-before-trace adapter and installs the exact own-tested power reduction only at its nonzero scalar checkpoint call. The original zero-angular shortcut, coefficient keys, nonpolynomial fallback and angular averaging remain inherited. Saved coefficients and complete projections remain reusable. The production entry point checks exact source, input, native-version and own-proof identities and preserves the complete pair/tensor assembly.

### S05 remaining-pair parallel allocation

The unchanged reviewed early-power entry point may continue with four shared
workers at 6 GiB per slot, with 22 GiB process/tree guards. The original
operation bounds, equations, native versions, canonical checkpoint identities,
accepted precontracted trace, own power-reduction proof and angular checks
remain unchanged. This supersedes the two-worker allocation for the remaining
independent pairs, without modifying the algebra or recomputing accepted
pair/coefficient checkpoints. Stop the prior allocation and verify its native
workers are quiescent before the single-writer handoff.

The resource decision uses job 14814449's observed peak process-tree memory
of 3,862,667,264 bytes after 6971.155884347856 elapsed seconds, with 24 complete
pair files present. The unchanged native inventory gate determines the full
diagram-pair set. More workers provide additional independent task slots;
these observations do not establish a measured full-stage speedup. Keep all
source/input bindings and full S05 acceptance gates before downstream work.

The same completed-projection archive procedure may continue under
`s05_projection_archive_continuation_result/`. The preceding manifest and
archives remain immutable. Preserve incomplete pairs, complete pair records
and configuration-pinned projections; all member/parent hash and bounded
transfer checks remain required before removing duplicate archive copies.

Archive job `14816795` passed with 28 parent pair files preserved and
54,889,210 raw bytes archived. The continuation manifest SHA256 is
`1a4764b0684bfdbf567cea0f6475c4d7b96c477a3a6fe0effcfc733735baff64`;
receipt SHA256 is
`4ca1b2ffbc2cde5dc53c9cd8f7fc0d76395d1296848ef160b6acdb8be5ac00af`.
The 13,193,945-byte archive, SHA256
`1983a205d908f0e7bd0f3291f2695c5272d24634116c2f0ad295d2e480f2845e`,
is verified locally. Its duplicate cluster copy was removed only after
matching hashes and sizes; restore manifest paths with member checks if needed.


### Shared scratch allowance

The4GiB workflow scratch guard interrupted calculations during simultaneous exports. Cluster quota reports1190GiB used against1863GiB hard limit. Replacement allocations use a bounded12GiB shared workflow scratch allowance, unchanged RAM limits and128MiB file bound. Maintain the local3GiB reserve and bounded transfers. This supersedes earlier4GiB scratch contracts. Preserve checkpoints and failed receipts.


### Factored complete Hermiticity check

After all accepted component sums are present, the original whole-matrix
ComplexExpand check may be replaced by the existing factoredRealConjugate
routine. common/s05_real_spin_response_Hqg_factored_checks.wls first
compares the original complete predicate and the candidate on Hqg's own
first accepted complete pair. It requires native definition identity and
exact predicate agreement before applying the same method to the full
summed matrix. The original scalar reduction, all real equations, input
and canonical cache identities, reconstruction, reference and output
gates remain unchanged. Preserve all pairs and assembled sums during the
single-writer handoff. Output records HermiticityDispatchHash and
HermiticityComparison with own input hash and measured timings. This
candidate requires executed acceptance; no speedup is claimed yet.


### Remaining linear assembly and spin reconstruction

Job14821614 passed full factored Hermiticity, the Ward checks, photon
reconstruction, original spin extraction and spin reconstructions1..3,
then exceeded the22GiB process-tree guard while four workers handled
the remaining spin checks. Preserve all accepted pair, sum and spin
checkpoints. No completed finite result is invalidated.

common/s05_real_spin_response_Hqg_linear_assembly.wls, SHA256
858a273c7037c32ff8173b8e72e03d14692c5cda6de4848756f099782b8eced3,
reuses the accepted Hqq structural algorithm and Hgg photon-basis inverse.
The program derives extraction from the original structural definition,
changes only its return contract and verifies exact source restoration.
Require exact own complete original photon coefficients, all9 original
control spin responses and all9 original reconstruction predicates. The
generic inverse must hold identically and its forward coefficients must
match every actual full photon coefficient exactly. Full native spin
reconstructions retain the original task/cache bindings; accepted checks
are reused only by those bindings. CDR/reference and native chunked
export gates remain unchanged. Record LinearAssemblyDispatchHash and
LinearAssemblyComparison. Execute with2x12GiB, unchanged22GiB process/tree
guards and12GiB scratch to limit simultaneous large worker payloads.
Executed acceptance of this entry is recorded below.

Remaining S12 integration uses the unchanged7bbecbad factored-series
entry with four4GiB shared slots,4GiB per-process and14GiB process-tree
bounds,12GiB scratch. The native implementation already caps workers at
four and gives each task an independent canonical checkpoint. Own
ordinary/endpoint comparisons remain mandatory. This is the existing
Hqq allocation pattern; no new algebra or measured speedup is asserted.

### Accepted complete S05 real tensor

Job14822153 accepted source858a273c7037c32ff8173b8e72e03d14692c5cda6de4848756f099782b8eced3 in2677.775291 seconds. Complete original Ward, Hermiticity, photon/spin reconstruction and GitHub unpolarized-reference gates passed. Structural extraction exactly reproduced all own control responses; original full reconstruction and CDR checks were retained. The native export input was7727378792 bytes; serialization and exact reload took837.079289 seconds.

The complete result uses the existing chunked Get interface. All seven payloads (209762094 total bytes), loader, manifest, checks and receipt are hash-verified locally under s05_result/. Keep every manifest payload beside the loader.
s05_result.wl SHA256 522ceae713f66c9748ead11403608287304ee1eb0c56ba05f307ef4ab54c5c7d
s05_checks.json SHA256 3eb721f610de2b82497ddbda8be93f5faeb44f008b4e1314b8d8d0ec1942e7fe
s05_payload_manifest.json SHA256 e39440acfbf41cf39a03a648749e713aaec8355fa8b9b1cfb8d6ad9ada4ad826
s05_execution.json SHA256 d17e1936cb1516c4268175b4f43cfc02a7243020d8b20a735869e47e1f68cb91

This is the accepted real tensor for S08 mapping and subsequent integration. It is not a finite NLO F hat; S12 integration and S14/S15 cancellation/export remain required.

### S08 assigned-component worker contract

The target mapper currently distributes every original Value to every worker.
For the accepted large Hqg tensor, the packet-input entry may distribute only
component metadata and pass the assigned original component to its worker.
Keep the complete original mapTargetTask definition, mapper equations,
canonical target/checkpoint identities and final schema unchanged. Require
exact source restoration for dispatch edits, exact task metadata and native
input hashes, and equality of the complete own smallest nonzero mapped
component against the original interface (excluding execution timing and the
separately accepted check logs, as in the accepted compact-input comparison).
Keep original and candidate checks separately accepted. Release unused full
spin/sector containers after the original setup and control construction.
Record actual task/metadata sizes and worker distribution time; no speedup
is established until execution. Bind the new entry in the queued configuration
and retain the original configuration before release.

The reviewed assigned-component entry is common/s08_map_Hqg_target_packets.wls,
SHA256 2be9cfe584e8b1714827d89db0e75c542a31a96bf8e1b413bb767324a61551a4. The immutable native mapper
and full mapTargetTask body are retained. Check-log differences from native
reduction memoization are recorded and accepted separately; all mathematical
output fields must agree exactly. Native own-input acceptance remains pending.

S08 allocation amendment for14822896:2 shared slots at16GiB per process retain the32GiB total reservation,4h runtime,24GiB process-address/30GiB tree guards,4GiB native operation allowance and12GiB scratch. Complete native input ByteCount7727378952 is loaded before packet release; this gives the main reader more per-process data headroom. Source2be9cfe5, configurationf833a37e6b9b2ae96c2ec0a111b5abc4cfd6be04128b405dc0f05ded07aa1539, all input hashes and canonical checkpoints are unchanged. NSLOTS selects two workers and all own/fresh-worker checks remain required. Exact old/new scheduler requests are bound in .cluster/s08_result/s08_Hqg_14822896_allocation_amendment.json. No S08 memory or runtime improvement is accepted before its native run.

The attempted restoration of explicit h_vmem=INFINITY was skipped because job14822896 was already running. No second resource amendment occurred. The two-slot16GiB physical reservation and native24GiB address/30GiB RSS guards remain configured; the native receipt must establish inherited/effective limits. Preserve every unchanged hard resource in future qalter calls.

### Own grouped target comparison contract

Reuse the exact accepted Hgq grouping, native mapping and merge certificate
definitions with the same scalar geometry and reference mapper. Bind the Hgq
proof/receipt/native versions and common input hashes; do not substitute its
channel coefficients. On Hqg, select the actual accepted complete canonical
control by its saved Sector/Kind/Index and own target InputHash. Recompute its
full map through denominator groups in an isolated source/input-bound cache,
retain every per-group original reconstruction and formal merge check, and
compare the entire result with Hqg's accepted map. Record the actual control
equation, denominators, definitions and timings. Only an accepted comparison
can authorize production reuse; the existing Hqg writer remains unchanged.

### Own grouped packet production contract

`common/s08_map_Hqg_grouped_packets.wls` may execute only with an accepted
complete own grouped comparison and matching receipt, source, native runtime,
actual task and scientific inputs. Install its exact recorded grouping and
merge definitions; retain the original mapper for each group and the complete
canonical target checkpoint contract. The fresh-worker packet control must
reproduce the full accepted grouped control record. Its equality to the prior
original map is established by the bound own comparison, not by claiming
identical alternative integral representations. Keep the fresh Hqqprime
reference control and every per-component reconstruction/cut check.

Scope the packet identity check's association before calling the unchanged
inner task scope. Preserve target order, values, normalization and final schema.
Record both own comparison and dispatch identities. Reuse accepted canonical
components and complete group checkpoints only by their exact input bindings.
Retire the previous writer before production; complete coverage, integration
and finite cancellation/export remain mandatory.

### Polynomial form of own map equality

An isolated comparison may clear the actual mapped propagators using powers derived from both complete integral maps. Verify every family propagator against the saved common denominator, all coefficients independent of loop coordinates, and every cleared term polynomial and exactly reconstructed. Derive a common bivariate polynomial from those terms and require every coefficient of the candidate-minus-own-accepted map to vanish exactly. Preserve complete own task/hash binding, group certificates and native mapping definitions. This compares the full rational identity; it does not assume equality of alternative integral representations. Reuse completed group caches by the original grouping source/input identity; save this comparison separately until accepted.

Own grouped comparison accepted14825272: s08_grouped_comparison_result/s08_result.wl082a4e59961aca18189d6566ec27b47a717d32cf25ecc2edbb88a023a85b2c08; checks18518fbafe55db4920b94a13cbe5bdd6e3ea8bd2986a30d18cd665832fe03de2; receiptfbf1066d08715f13cac7c909c7117002a49723dc5f60677fc0a55b28531ccaef. Entire own accepted map and all15 group/merge/cut checks passed. Original1962.557271s, grouped1036.785081s, full rational equality2098.523618s. All files verified locally. Use original grouping proof/cache identity and guarded packet adapter; the separate polynomial comparison is unnecessary for this accepted handoff and was cancelled, with no production output accepted from it.

Checkpoint-resource contract: future grouped-packet resumes may use four shared slots at16GiB each, retaining the same native source, scientific/group cache identities, per-process24GiB address guard, total30GiB RSS guard and4GiB per-operation bound. Preserve the full-reader16GiB headroom and every own/fresh-worker comparison. A controller handoff must adopt the active job and wait for its receipt; it must not interrupt production simply to change parallelism. No speedup is asserted before measured execution.

### Loop-coordinate expansion comparison contract

An isolated S08 comparison may restrict the original familyRows numerator Expand to the variables declared in its own CoefficientRules. Derive that variable list from the installed original definition; change only the single Expand statement by exact reversible source replacement. Preserve Together, denominator handling, coefficient extraction/factorization, every family and full-map reconstruction, physical cuts, grouping and merges. Reuse the actual accepted Hqg control equation and compare the entire resulting map with its accepted grouped map. Use a separate source/input-bound group cache, record cold candidate timing, native versions and prior baseline timing/job provenance, and do not claim a same-machine speedup from different jobs. Production adoption requires executed own equality and a reviewed consumer; no accepted map is invalidated.


### Complete loop-coordinate expansion comparison, not adopted
Job14828051 passed every full own-input mapping, original cut-support and complete reconstruction gate, and the saved native result reloaded exactly. Source common/s08_check_Hqg_loop_expansion.wls SHA25698d5a83138273ba65fa178370516b0886e32974c8b66c4afd8e2bcabf6e6b9e0. Result Hqg/s08_loop_expansion_result/s08_result.wl SHA2564e49e241a3a74671e179bb6494666726b05e6944c86661e92ad30b612783d9b6; checks e01867f9ce7029cbcf5744b4b884e6eb6b90af3f596e0a6c79784b7b719e37c3; execution8401a9f37fb8b1968a93d687d7199203d1f1d5fdbfe4f644260a8fcfd51646d7; configuration2844cfa063ace130a1cced6cd55413e1ea5ea817d04bbc11c8cdca9f2f561e2c. All are verified locally.
Candidate mapping2494.182497seconds on n7005; prior grouped mapping1036.785081seconds on n1149. Exact comparison0.006682seconds. These different-node measurements do not establish a speedup. Production keeps common/s08_map_Hqg_grouped_packets.wls SHA2560c3865a2abab5cce425c7c00d878852e9e47a3c1f31f830b24bc776796a63838 and its canonical checkpoints. This comparison supplies no additional finite F hat.


### Targeted continuation after execution14828747
The run reached components30–31 while component17 exceeded the10800second outer mapping bound in denominator group10 of14; this is not an algebraic comparison failure. Existing canonical component/group checkpoints remain valid. The separately executed loop-coordinate expansion proof14828051 passed complete own-output equality. A continuation may install those exact accepted familyRows definitions only for the timed-out component, with original-input/native/source/receipt checks and exact reversible wrapper installation. Every other task keeps its original definitions. Preserve all group reconstruction, own reference controls, cut support and final acceptance gates; retain the canonical mathematical checkpoint identities. Measure the affected component before claiming any speedup.

## S08 blocked input reading contract

common/s08_read_Hqg_blocked_input.wls uses the unchanged accepted grouped initialization and grouping definitions to save the exact input for component17/group10 recorded in job14828747. Its configuration binds an immutable copy of that failure log and receipt. The readable native result retains the original task identity, denominator powers, coordinate rules, families and group cache binding, and must pass exact Put/Get equality. It performs no mapping and accepts no optimization or finite coefficient.

The blocked-input consumer format uses native Compress/Get with an exact round trip, matching accepted target exports. s08_readable_input.wl is a human-readable rendering only; use s08_result.wl for calculation. The initial plain Put rendering failed exact structural reload and is not a production input.

## S08 polynomial family mapping contract

common/s08_map_Hqg_polynomial_group.wls consumes the accepted native blocked-input export and the accepted own grouped comparison. It derives loop variables from the original family function, collects numerator coefficients before affine family substitution, and transforms the resulting loop monomials. The original propagator decomposition, complete family and cut reconstruction, and cut-power checks remain. Before the blocked group it must reproduce every coefficient of an accepted Hqg group with the same denominator powers. Only an accepted native proof may publish the new group into the original input-bound group cache. Preserve the group binding, measure timings, and retain unchanged canonical downstream schemas. This group is not a finite hat.

After accepted polynomial-group execution, common/s08_resume_Hqg_polynomial_maps.wls installs the exact saved family function in the unchanged grouped parallel mapper. It verifies complete source, native version, physical-input, original-function and own-comparison identities. Workers receive the original declared polynomial variables. Original target/group cache bindings, per-group reconstruction, full control comparison and final target export gates are retained. No adoption before the executed comparison passes.

### Saved blocked input recovery contract
The original export producer is preserved as common/s08_result/reference/s08_read_Hqg_blocked_input_before_recovery.wls (c2de29e0bcdb63d094aaa51a3e867a862d82e128e1bbbffc26f8c7013bd12aae). Its component17/group10 expression has the original group hash; diagnostic14835546 confirms stable reload. The corrected input stage reads this small retained native record, binds the failed export receipt, producer, original configuration and every scientific input, and requires exact own group hash and fresh geometry before exact final serialization. No full tensor or mapping is recomputed. Acceptance still requires the new execution receipt.

The saved family metadata is compared recursively by identical field keys, ordered lists, rule left sides and exact zero algebraic differences at leaves. Term ordering in native associations is not a physics change. The accepted saved representation is retained; exact final file reload remains required. The polynomial consumer applies the same fresh-geometry check.

### Accepted recovered blocked input
Job14836199 accepted the small native input in50.719126seconds, with original source/config/scientific input and group hashes unchanged. Every fresh family field passed recursive exact symbolic comparison; exact final Compress/Get equality passed. This resolves the blocked-input serialization interface, not the remaining cut mapping or finite F hats.
Source common/s08_read_Hqg_blocked_input.wls SHA256 6144e16ec9794788b8989945d77331e72b0711ea19d4d56be48a525f384b78e2
Hqg/s08_blocked_input_result/s08_checks.json SHA256 69cd3b051448555f77eb39516ebdbb524b948e828ea5cf64fc26e0122c834cda
Hqg/s08_blocked_input_result/s08_readable_input.wl SHA256 9ea7447259d028a2f35b618f004d67470f64df80b195fd56eb7b8367115b2a4b
Hqg/s08_blocked_input_result/s08_result.wl SHA256 5b34caba376f6107c2e4a449a53f68725b30fa8f84fba86e1b45ba95ba24e87c
Hqg/s08_blocked_input_result/s08_execution.json SHA256 f73ff150223bcbd5d38f67dda80b007617440442a0ab9f17e905bb3cfbaad679
Use s08_result.wl as the calculation input and s08_readable_input.wl to inspect its equations. The polynomial map14836267 consumes the accepted native input and must still pass its own-output and complete reconstruction checks.

### Outer additive piece mapping contract
The blocked input has an outer additive factor. The candidate derives its terms from that saved expression, bounds the split inventory to eight terms, and requires exact native reconstruction. It retains the original mapExpression, polynomial family function, complete per-piece family/cut checks and the already accepted certifyGroupMerge/certifyPairMerge definitions. Complete term maps are cached by source/input/expression/native identity with separate worker directories. Before applying the method to the blocked group, compare every final coefficient with an accepted own Hqg group. The parallel adapter may install only the executed saved definitions and must preserve original group/target bindings. The earlier unsplit polynomial attempt14836267 passed its own comparison but timed out on the blocked group; it is not an accepted optimization.

### Accepted termwise blocked-group map14843727
Complete own coefficient equality, native per-term cut/family reconstruction, full linear merge and exact exports passed. Blocked component17/group10 completed in10.403291seconds; own comparison4.928964seconds versus original control2.655281seconds. Prior unsplit blocked attempt exceeded1800seconds on a different node; no same-machine speedup ratio is asserted. Full job108.935034seconds, child peak447860736bytes.
Hqg/s08_polynomial_group_result/s08_checks.json SHA256 496ff7bdd0d2940ebf216a5c9903fc0481296dd726122fbf597675f0f2cc8f66
Hqg/s08_polynomial_group_result/s08_result.wl SHA256 cf2d51fc00e4324d77ac8a69deb84a33e728d81672c802848ab678ca6dff1c7d
cache/s08_Hqg_grouped_comparison/e40b57a74f12b8300779c6e5e6ddfc7aa5017587ddf16def7c83d2a85ab8f22a/component_17_group_0010.wl SHA256 2da91374a33c1c3597574dfb4b4aab3b0fc998b525531deb25dcd3b5689ec1ea
Receipt s08_polynomial_group_result/s08_execution.json SHA256 d41412eb52f3c0f52976a7e12d52ee66e1373543d35997bb5833f866ae202c0e. The saved definitions may now be used by the bound parallel consumer; all existing target/group cache identities and final gates remain mandatory. This is an accepted group, not a complete finite hat.

Queue allocation contract: the factored raw continuation configuration .cluster/s08_factored_targets_Hqg_remaining_hqg_factored_groups_20260923_job.json (SHA256edecf23d1ea4c9f9fac3e0833832bc61b8abd9eea8b3ee5f5bd2b4930c3571f4) requests four shared8GiB slots. It retains the32GiB total reservation used by the preceding two-slot16GiB configuration,24GiB process-address and30GiB aggregate-RSS guards, and4GiB production algebra bounds. The existing dispatcher assigns independent targets, with separate per-worker piece caches and per-target group/output identities. Exact accepted inputs and canonical target checkpoints remain unchanged. This resource configuration does not establish an algebraic speedup or guarantee queue start time.

Startup correction: the polynomial continuation delegates its sole main-kernel FeynCalc load to the unchanged original mapper. Its pre-initialization proof function uses the qualified FeynCalc`$FeynCalcVersion. All accepted polynomial definitions, proof/source bindings and canonical checkpoints remain unchanged; the complete native proof and mapping gates must pass in the continuation.

### Exact remaining S08 input contract
common/s08_extract_mapping_inputs.wls (433001a7a8a3b334b23326fed3bfbb66810b5b9e4b8bc4376099a8521150e74d) reuses the unchanged accepted channel initialization and native task inventory, stopping before mapping workers. It saves source/input/runtime-bound complete coordinate expressions and original mapping/family/grouping definitions, with exact native Compress/Get equality and bounded readable equation renderings. Hqg exports its existing own control and tasks without canonical checkpoints; Hgg exports the actual timed-out control8 from execution14844895. These are input artifacts only, under s08_mapping_inputs_result, and do not accept any new map or finite coefficient. Future optimizations must preserve every complete reconstruction/cut check and pass comparison against an accepted own output. Existing mathematical checkpoints are unchanged.


Input-export recovery contract: s08_extract_mapping_inputs.wls recovery mode consumes the retained failed native record, requires unchanged held equation, native/source/scientific input identities and fresh exact geometry, then republishes only after full stable Compress/Get equality. Normal extraction compares every nongeometry field structurally, geometry with the already accepted exact recursive comparison, and requires a stable final native record. This corrects serialization only; no mapping or finite hat is accepted by recovery.


Accepted native input recovery 14873387: original equation is structurally unchanged; all original scientific input identities, fresh full geometry and stable full-record Compress/Get equality passed. Source preserved at common/s08_result/reference/s08_extract_mapping_inputs_accepted_recovery.wls SHA256 027cc09db70fb0adcd79faee123cc33473906c3816fa9e17dbb3dae6ae83c6d8. Result identities: {"Hqg/s08_mapping_inputs_result/s08_component_0004.wl": "febda84cb6f8b97f5f5bd00998228c7b068e12fe20c5b74617285954437cb85e", "Hqg/s08_mapping_inputs_result/s08_component_0004_equation.wl": "e6e02d42533bd3392aa161d6ee63354fa4b0c615bd31d7fe391991e12e27558d", "Hqg/s08_mapping_inputs_result/s08_recovery_checks.json": "4cdd24d8e45b83ea219576916db85e3498cc8ec3095bdf4ba8f34038f863c63c"}. Native computation used 52.02781871519983 seconds; this accepts input serialization only.


Termwise mapping contract: common/s08_map_saved_terms.wls consumes only receipt-bound native mapping inputs and installs the accepted Hqg polynomial family definitions with unchanged original propagator/cut mapping. Retain original outer rational terms instead of first combining them into denominator groups. Require exact full additive input identity, every original per-piece family/cut reconstruction, the accepted exact coefficient merge certificate, and complete own Hqg control-map equality. For the first Hgg control, compute both original and polynomial family mappings of every original piece and compare every coefficient before accepting the complete linear merge. This is an own full termwise comparison, explicitly not a completed monolithic original-map run. Independent piece caches are source/input/expression-bound. No production adoption or finite hats until the relevant executed gates pass.


Accepted pending native inputs, job14873393: all components28–37 passed original equation identity, exact recursive geometry and stable full-record native reload. Receipt s08_mapping_inputs_result/s08_pending_execution.json SHA256 6cfd75e101db3cd85a6b85a1ddecd90baa06567cb0bef95bb69434210eb93923. Input identities are the receipt result_sha256 entries; readable equation files are for inspection, native component files are for computation. No new mapped or finite coefficient is accepted by this export.

Numeric outer-factor mapping contract: derive an exact nonzero numeric factor only when the remaining outer factor is one Plus expression. Require exact native reconstruction of the actual saved input. Reuse the original grouped mapper on that remaining sum, preserve every original group/family/cut/merge gate, and require exact coefficient-wise restoration of the numeric factor. Before production, the same function must reproduce the phase-scaled complete accepted Hqg grouped control using the factor extracted from an actual pending input. Separate production group-cache directory for phase-stripped expressions; original target schemas and accepted components remain unchanged. Record native comparisons, source/input hashes and measured timings in the final mapping result.


Outer-phase correction: native inspection14874222 established that Hqg component28 is an outer Plus, and direct equation reading at line44262 identifies its second phase-wrapped sum. The initial candidate14874210 incorrectly required the entire expression to be a numeric product and stopped before publishing any map. Corrected helper handles phase-wrapped children of an outer sum, preserves each original term identity, and uses the already accepted full coefficient-merge certificate. Hqg supports saved-input-only control validation before its full production reader. Corrected shared helper source SHA256 1c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9. Production acceptance still requires complete native own-output checks.


Accepted numeric-phase own control14874243: exact actual input inventory is two phase-wrapped sums of60 terms each. Complete own phase-scaled grouped-map equality, every inherited group/family/cut/merge gate and exact native export passed. Mapping control46.443264seconds; full validation149.86842049658298seconds, child peak495828992bytes. Source common/s08_resume_Hqg_polynomial_maps.wls SHA2561c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9. Hqg/s08_numeric_phase_control_result/s08_result.wl SHA25613466dcb9273f5d26936e3a1b0b44247ae165a1c0c7e09e31ebecc0cc8865b5d; checks45d87ac80d8eee978285d265cf0d2e3e272ea771da3c27d5782860d3ec710873; receipt47af96264f588639dd56c02a9569bd8e25d25145480004508064eb000f1d1c9f. This accepts the helper/control interface, not any new complete component or finite hat.


Factored-group reuse contract: s08_check_Hqg_factored_groups.wls imports the exact executed Hgg extractor and formal-numerator certificate from accepted job14874739, requiring identical original scalar/group definitions, scientific geometry inputs and native versions. Reproduce complete own Hqg component4 original atom/group output before processing receipt-bound saved components30/31. Use the existing exact numeric-phase splitter and certify every complete core; retain external numeric factors and exact input identities. This isolated comparison may export reusable groups only after exact native reload. It does not change active production, accept maps, or permit discarding valid old checkpoints. Adoption requires a reviewed consumer and its own complete mapped-control check.


Factored-group production consumer contract: s08_resume_Hqg_factored_groups.wls must preserve the complete existing polynomial/numeric-phase dispatcher. Before installing definitions, bind a successful own factored-group comparison, identical scientific inputs/native versions, original extractor/group/certificate definitions and exact saved input identities. Reuse complete saved core groups only by exact expression hash; otherwise use the accepted extractor/certificate. Retain original target and piece checkpoints and reuse group checkpoints only when their original binding matches. Keep the existing complete own mapped-control, fresh-worker, cut, reduction, assembly and finite export gates. Do not launch alongside another writer for the same Hqg targets.


Accepted own factored-group comparison14875694: all36 own original atoms and complete original grouping agreed. Full actual30 cores grouped in15.684392s and15.265868s,17groups each; actual31 cores in4.185760s and4.154662s,14groups each. All exact formal-numerator/partition/phase input identities and full native reload passed. Own original/new group representations are structurally identical: False. Result identities {"Hqg/s08_factored_groups_result/s08_checks.json": "0077352e675eaf9ca38899be0ea00cc153aaaaea0250f2f0255b3ba071df8c56", "Hqg/s08_factored_groups_result/s08_result.wl": "02c630c10bbc1a6f66b7369929904db21a28c129376cdf9b34dbafd7e49d1077"}. Source/receipt/consumer identities {"common/s08_check_Hqg_factored_groups.wls": "82ff3b35977132bb8a7650bc88fe9e30905859c289a7ec183cc781fbd03c02c7", "common/s08_resume_Hqg_factored_groups.wls": "49d523467d59f0b275002f86125ed7cbbc79e344953262ea6cd78564e01f41b3", "Hqg/s08_factored_groups_result/s08_execution.json": "d48f5a720554d246e3d2ff2303009b392f97add7152f60b8e78543701e0af6e8"}. Entire executed comparison235.763302s, native child peak2207350784bytes. This accepts grouping only. Production uses the complete mapped-control acceptance recorded below; any old group cache is reusable only under its exact native input binding.


Accepted factored-group consumer control14875973: the complete own component4 map, with the numeric phase extracted from accepted pending input28, reproduced every accepted mapped coefficient. All denominator partition, family/cut reconstruction, full group merge, restored-phase and exact native export checks passed. Consumer source common/s08_resume_Hqg_factored_groups.wls SHA25649d523467d59f0b275002f86125ed7cbbc79e344953262ea6cd78564e01f41b3. Hqg/s08_factored_control_result/s08_result.wl SHA2562b25cea82619f7064b578ae27667cd6bd7dedb302a4fb135d811cef2737da949; checks SHA256d99104682585649c1681490757ff041456879af291088c5882e8fb2d3e93c40d; execution receipt SHA256dda3acb11f03c097ba30e407f9f7276605122707d78a665e8e5a22b9c6a0e6ef. Native control3140.848884seconds; full execution3278.792472seconds. This is a full mapped-control acceptance, not evidence of an overall mapping speedup or completion of remaining targets or finite hats. Preserve exact target/piece checkpoint identities; new and old groups remain interchangeable only when their native binding matches. A production continuation must not overlap another target writer.

## S08 actual packet-record comparison contract

The saved failed own packet from job14877708 must be compared directly with
the original accepted grouped-control record and the prior packet.
common/s08_check_Hqg_packet_record.wls reconstructs that record using its
original producer and pinned scalar reduction, checks the exact scientific
metadata and full integral-key inventory, and computes exact differences
for every structurally changed coefficient. Timing, check-history and byte
counts are recorded separately. No production comparator is changed until
the actual saved records establish the cause; no accepted map is invalidated
by diagnostic metadata alone. Outputs belong to s08_packet_record_result.

The actual saved-record comparison passed job14879403. The result
s08_packet_record_result/s08_result.wl has SHA256
68cf3dd3210b6fc47b3b276bdfa0bebd4598b83b8d761ab90de83e2f0b0da604;
receipt SHA256 edb9f626f70cbdf192b00127991f09c3a61bec27bfd13d0350e9a9a9aee7f20b.
Every coefficient is structurally identical when addressed by its integral
key; only dictionary insertion order differs. Scientific metadata and
InputBytes/OutputBytes also match. The corrected entry
common/s08_resume_Hqg_ordered_packets.wls must sort coefficient keys only
for the exact own-record comparison and its evidence hashes. Its isolated
POLARIZED_SIDIS_PACKET_ORDER_ONLY=1 mode exercises that same comparator
on both actual saved packets before production. All other record fields,
accepted algebra, canonical target bindings and downstream gates remain.

The exact corrected interface passed job14879609, including reproduction
of the original failure, complete record equality after coefficient key
sorting, unchanged generated dispatch, and exact native export. Source
common/s08_resume_Hqg_ordered_packets.wls has SHA256 3257bf9b22ee906fa9a08543eb807860096598015bc721c4d10e7bae83ea6653.
Result s08_packet_order_result/s08_result.wl has SHA256 e132b214023916e2b55ff8b62d29e4ae52bee73cd5d78b46491c3bcb98241e74;
receipt SHA256 d799a40823eea389f99cbc6bf0611f60ef7412274d46ea2380b1d11cd1ce96be. The canonical comparison changes key order only;
coefficient values, all other record fields, cache identities and accepted
algebra remain unchanged. Production continues with four8GiB shared slots,
24GiB per-process address and30GiB process-tree guards. The new entry owns
its dispatch identity while retaining the immutable factored mapper49d5234.

## S08 reuse of accepted scalar reconstruction certificates

The candidate common/s08_resume_Hqg_certified_maps.wls reuses the executed
Hgg/s08_scalar_certificate_result definitions only when original family/map
functions, current factored extraction/certificate definitions, common scalar
input hashes and native versions match exactly. It retains numeric phase
handling and canonical integral-key comparison from the accepted Hqg entry.
Control mode POLARIZED_SIDIS_PHASE_CONTROL_ONLY=1 must map the entire own
component through the existing accepted numeric-phase comparison, using a
separate group/piece cache to prevent the old maps from satisfying the test.
The control owns s08_scalar_control_result; production requires its passed
receipt and exact source/input hashes. Kernel startup alone receives300s
instead of60s; coefficient algebra and existing mathematical cache bindings
remain unchanged. All cut, reconstruction, full comparison and export checks
remain mandatory. No unpassed control permits production installation.

The complete own Hqg comparison14879739 passed with no coefficient change,
including numeric phase, every group/piece reconstruction, physical cuts and
native export. The isolated control took179.043622s; the earlier fresh
factored control recorded3140.848884s. These are control timings only.
Accepted consumer source 4b1f4d48984e894eac1e11351d9da9955553af9ace2c6af1dd5e368517484230; result
s08_scalar_control_result/s08_result.wl SHA256
31db51cec74c3d288c2df6ed7b6bbc05b97f748240e20b2ae4d1bb520e97f12f;
checks2bec97ad19a450574a3d404d817ee32286f2c8e38077a22c4f65c772044a6f0e;
receipt0c815cbcc5d85f8b2639e341fd4550edf6d640ccb2ecfb4185697fe4553106a7.
This consumer may now run production with the unchanged mathematical cache
bindings. It records accepted Hgg scalar proof and its own control/source
hashes separately, preserves the ordered-packet comparison, and allows300s
for kernel startup. Accepted target/group/piece caches retain production and
resume value. The own isolated comparison cache remains reproducibility
and validation evidence. Finite NLO export still requires downstream gates.

## Accepted complete S08 raw target mapping (14879752)

Native job14879752 passed with four workers. All37 independent real-response
component maps passed the full inherited reconstruction, positive-energy,
measurement, cut-power, numeric-phase, complete-record comparison and exact
native-export checks. This is the raw map, not a finite NLO F hat.

The accepted map contains278 distinct integral targets;136 were absent from
the inherited reduction library. Consumers must run the existing reduction
extension and require complete target coverage before master assembly/S12.
S14 pole/reference gates and S15 final exports remain required.

Entry `common/s08_resume_Hqg_certified_maps.wls`, SHA256
`4b1f4d48984e894eac1e11351d9da9955553af9ace2c6af1dd5e368517484230`.

Configuration `.cluster/s08_certified_targets_Hqg_remaining_hqg_certified_maps_20260923_job.json`, SHA256
`951706c9dff1da6729e872c8fde314b2138a7899bbee36dc3e351ff124c4721a`.

Accepted native outputs, verified locally:

- `Hqg/s08_targets_result/s08_checks.json`: `a69eba65569fe01242dd359d14f5e24e2b96b3daa78e136748a3200d8eed25bd`

- `Hqg/s08_targets_result/s08_result.wl`: `9a761924e7b4be3b2f9a192ea72497e3be48176c49ce877ebd49245b667238a7`

- `Hqg/s08_targets_result/s08_execution.json`: `4053c383ce8f4aabecb8595c29eb4f894578ad0df0f9afde344f93072a4d50e6`


Production log: `cache/s08_certified_targets_Hqg_remaining_hqg_certified_maps_20260923.log`.
Canonical component cache remains
`cache/s08_targets/Hqg/bd2242c9a42c3a41157e0d44ef3bb8784fe7d444bf22423fbbd7d9e664754064`.
Its accepted mathematical bindings are retained; the new exact reconstruction
proofs and entry source are recorded separately in the result evidence.
No accepted earlier LO/NLO channel result was regenerated.

## Accepted S08 complete reduction extension (14879806)

Native Kira job14879806 passed complete actual spin-target coverage and
all inherited-rule comparisons. Inputs are the accepted all37-component raw
map above and the unchanged scalar library, positive-energy support and cut
geometry. The original complete Kira configuration and reader were reused.
This acceptance supplies the reduction library for master-coefficient
assembly; it is not finite F-hat acceptance.

Entry `common/s08_extend_real_reduction.wls`: `db9875bb42086b9e52a405bc61b46262661cf91b72681dc57c22c977121a22e7`.

Configuration `.cluster/s08_reduction_Hqg_remaining_hqg_certified_maps_20260923_job.json`: `42ff47b2fc10a2a6f6a936099196bc8a7efe92fcd93abdc909b0078ac1f5ba56`.

Accepted files, verified locally:

- `Hqg/s08_reduction_result/s08_checks.json`: `3d7be80741c126446ab9aacd5de9aa1de906d84cdb2d29d39630509d95754824`

- `Hqg/s08_reduction_result/s08_reduction.wl`: `8fbbe1ccd98c37e9a36b692c43f9a8de894bc4196826ef3b195045ba9b432aa9`

- `Hqg/s08_reduction_result/s08_execution.json`: `d0c115641734f531bb5f295403f10c4b6bb7bdfa546b599b4b735457f513887a`


Native log: `cache/s08_reduction_Hqg_remaining_hqg_certified_maps_20260923.log`.
Kira cache: `cache/s08_extension/Hqg/3b09110c3c36de4ff69d8d453a7bdaf34eb06f6694224a9aea8d2ffc9076bff6`.
Master-coefficient assembly must bind this receipt and reduction file, then
require zero missing targets before S12. S14 cancellation/reference and S15
finite-export gates remain the final acceptance boundary.

## S08 direct worker raw-map loading contract

The candidate `common/s08_map_real_spin_worker_files.wls` changes only the
compact coefficient entry's worker-input transport. It suppresses the parent
`rawTargetComponents` value during recursive definition distribution, then
loads the same hash-bound accepted native raw-map file directly on each worker
with automatic definition distribution disabled. Workers must reproduce the
parent's complete array hash, component metadata/order and reconstruction
checks under identical native versions. Original coefficient, reduction,
cache, control and final-export code remains byte-for-byte recoverable.
The isolated interface comparison owns `s08_worker_file_input_result` and
uses the actual all37-component Hqg map accepted in14879752. No production
use is allowed before this native interface comparison passes; existing
production remains its sole output/cache owner.

Native validation job14879836 did not pass: it exited with code1 and
reported `No more memory available` after the actual raw-map contract gate,
under its 6GiB process address-space bound. It produced no accepted result.
Receipt: `s08_worker_file_input_result/s08_execution.json`,
SHA256 `f3c129812372a00609ee305d50fa371dcd5f5f573e604d5b8d29f9af7471c8a2`.
The candidate is unaccepted and is not used by production. Its source,
configuration and failure receipt are retained to prevent repeating the
failed interface attempt; no coefficient or production cache was changed.

### Complete S08 master-coefficient result

Native job `14879810` accepted all 37 master-coefficient components with complete reduction coverage. `s08_result/s08_result.wl` SHA256: `d04a8c05b8486c21feefe8eeb394e9542c7ec484481578c61eebf2ca4df3ed05`; checks: `692eee3d0ec1f49ffbf8c946db78948bc73f83fd82705ac23458a7c718d6a8a6`; execution receipt: `6ad6dacbae4d7fcc5b9fea43d89b62cf1380253beb8eac1979fe9e0b5e1554b1`. Source remains `common/s08_map_real_spin_compact_inputs.wls` (`aea8d3ac781c29b85a00d341a994420d3af5ee7f450ff7ddc0f2074e8851475f`); accepted streamed numerator and known-denominator algorithms are unchanged. The result is the complete master-coefficient input for S12; finite hats still require S12/S14/S15 checks and exports.

## Accepted complete S12 assembly (14879893)

All37 real-response components passed native assembly, endpoint and saved-output
checks. Accepted master input is the complete14879810 S08 result. This stage
is the real-distribution input for S14; finite F hats require S14 and S15.

Source: `common/s12_assemble_real_factored_series.wls`; execution receipt
`Hqg/s12_result/s12_execution.json`, SHA256 `b1c07dab2ef152c60cc97aa2e6942193c0c72604fbc0886483d7476833e391ad`.

- `Hqg/s12_factored_series_result/s12_endpoint_comparison.wl`: `257e8f120c2f2db32d4b6bc4d61a1b5350adff556401e37824f5a5e4c4012068`
- `Hqg/s12_factored_series_result/s12_result.wl`: `0f424ffb0c216fbd2c7c5750376345b76c3b2339ec82f619541eea93ec2552e9`
- `Hqg/s12_result/s12_checks.json`: `2a7e089602dca9eed9b97c7ec1c62bccf87fe7160e6daab8b258e5ac3cc5e906`
- `Hqg/s12_result/s12_result.wl`: `165bed0ff28573bb421316432d1d4339934cb54dc2df79555f387cfcae54800c`

Native log: `cache/s12_factored_series_Hqg_remaining_hqg_certified_maps_20260923.log`.
Keep accepted component checkpoints for reproduction and resume. The controller
binds these exact results and the accepted virtual/subtraction inputs into S14.

## S14 saved-pole analysis contract

The isolated s14 pole analysis reads the exact native failure record for {4,1,1}, positive branch, Delta from job14880030, with recorded input hash and source-bound physical assumptions. It must retain real, virtual and subtraction Laurent coefficients separately, report exact simplification and native physical-point evaluations, and export its inputs and outcomes without modifying production caches. Diagnostic acceptance is not pole-cancellation or finite-hat acceptance. No physical convention is changed by this analysis.

The saved-pole analysis14880128 exported native exact CanonicalSeparateSum values zero at both recorded poles. It retained the original combined expressions and all three input contributions; all33 radical rewrite certificates passed. Result s14_pole_analysis_result/s14_result.wl hash0cb468b30c67422823c72488cf4e9681e1acc4f6c80565c298de5ee9ea6dadfe; receipt aad9a72c74cc31d3539e9da54d10bf7270cba8a1908304adfa72b5bacfd9721f. This diagnostic establishes a simplification issue in the saved pole check, not complete finite-hat acceptance. Reused factorization must be proved directly on the actual saved residual and original input sum, and retain an own accepted control, before assembly adoption.

### S14 refined-predicate consumer contract

The Hqg compact consumer must require its own passed s14_pole_refinement_result receipt, actual input hash, exact inherited physical conditions and saved original finitePart/zero definitions. Only the finite pole predicate may change to the already executed factorization routine. Deferred evaluation of completed finite checkpoints must reproduce the whole accepted control component before continuation. Keep every spin/photon component, branch, distribution, reference and finite-export gate, with the same scientific cache identity. Bind the refinement proof and consumer source into final metadata.

## Accepted Hqg pole-refinement proof (14880348)

The own native proof passed on the actual failed finite checkpoint and its
original real, virtual and subtraction input sum. For both saved poles, the
original production reduction reproduces the saved residual exactly and the
unchanged accepted factor-refinement routine returns zero. The own accepted
control poles remain unchanged. The complete compressed native result passes
exact reload. This accepts the pole predicate for the consumer; it does not
accept complete finite F hats.

- Checker `common/s14_check_Hqg_pole_refinement.wls`:
  `a2f5bc445db2fad7ff271d799eb7a09852c92f2dcc3645a4294ab175f28dd1d2`.
- Result `s14_pole_refinement_result/s14_result.wl`:
  `188ecb1ef43e3a9458a45c1c8b9dc3b2f81e9f86fd081492c4984ae547af73c7`.
- Checks `s14_pole_refinement_result/s14_checks.json`:
  `843d3ccc874000190cfc5e0c752fa97494a78d9c05698f492f8855ccc06c39ab`.
- Receipt `s14_pole_refinement_result/s14_execution.json`:
  `e65418fe477edb27ccd39d5798e40e1a78069f47f8d7179db5cda589b65206da`.
- Configuration `.cluster/s14_Hqg_pole_refinement_native_export_20260923_job.json`:
  `944eb9adee2e41c1851b75aa1c21545e9ce2d5f200c342e5a1abc0ea954c4e52`.
- Native log `cache/s14_Hqg_pole_refinement_native_export_20260923.log`.

The result binds the failed/control checkpoint hashes, original finitePart and
zero definitions, physical domain, native versions and accepted Hqqbar factor
certificate. Use `common/s14_assemble_Hqg_refined.wls`
(`cea77d3fb463b56f20c352f895616859b291687d78511452204d17d67f34af5d`)
only with this exact proof and receipt. Its own complete control-component
comparison and every assembly/reference/export gate remain required. No
amplitude, spin convention or finite coefficient was changed by this proof.
Existing accepted finite checkpoints retain their scientific input identity.


## S14 regular-pole and frame reuse contract

The Delta/endpoint factor predicate passed its original failing case in native14881270. The regular term at {{4,1,1},1,Regular} then exceeded the pole-cancellation time bound at power-1; its saved residual is not a demonstrated nonzero physical pole. Retain immutable copies of that checkpoint, the own accepted control, and the failed execution receipt under s14_regular_pole_result/reference. Reuse the unchanged Hqq accepted common-root routine from s14_pole_refinement_result, requiring the own Hqg control, exact saved regular residual, original input sum, derived physical-domain root signs, root identities, full polynomial reconstruction and native export/reload gates. No production adoption until that comparison passes. Existing accepted endpoint/component caches keep their scientific identity. For the necessary assembly restart, reuse common/s14_project_real_frame.wls unchanged to extract and prove the complete original Channel/Checks/Frame interface once; the assembly consumer must bind its accepted receipt and exact original producer hashes. Both changes leave the measurement, subtraction scheme and all finite/reference/export gates intact.

## Accepted own regular-pole root proof and assembly consumer contract

Hoffman2 job `14882018` accepted `s14_regular_pole_result/s14_result.wl`
(SHA256 `86695a775a72ab554b2665406359a04da72295372197705a1cc510274244e297`).
The unchanged Hqq common-root routine, checked on the actual Hqg Regular
checkpoint, proves both the saved residual and original input-sum pole zero.
The original reduction reproduces the saved residual exactly; the accepted
own control is unchanged. The proof, checks and native receipt are saved
together, with immutable input checkpoints under `reference/`. This is a
pole-reduction proof, not acceptance of a complete finite coefficient.

The consumer `common/s14_assemble_Hqg_regular_refined.wls` must require
this accepted native proof, identical scientific input hash, original
finite/zero definitions, physical domain and own whole-component comparison.
It reuses the complete parent `s14_assemble_Hqg_refined.wls` and the accepted
projected-frame reader. Only the pole predicate and exact S05 field reader
change; native reversibility gates retain all assembly and final-reference
checks. The scientific input hash continues to use the original S05 tensor.
Frame extraction acceptance, all poles, both branches/common boundary,
U/U reference reconstruction, finite-scheme conversion and exact native
exports remain required before accepting final F hats.

The exact S05 consumer-field extraction passed job `14882019` in672.359s.
`Hqg/s14_frame_result/s14_result.wl` SHA256 is
`14a578516760f43a9f841fad9c73b1943b2116c528e7f9a5b17d398a5a7cf055`.
Its native receipt and checks bind the complete original producer, preserve
exact Channel/Checks/Frame fields, and verify the compressed native reload.
The original full tensor and its payloads remain the scientific inputs;
the projected reader records their unchanged identities.

The common-root consumer source SHA256 is `fae984700e3a0e55cf560d68de69c7df1d684e9ab1198bb165a94b620eb3b499`. Its native
job `14882352` passed the complete original/control comparison and the
exact projected-reader contracts before the remaining assembly. The
original and deferred control took11.164995s and2.130460s respectively;
the whole control after common-root installation took2.148842s and was
identical. The projected fields occupy45888native bytes in the consumer,
with about602MB memory after input release. This establishes the consumer
interface; the complete remaining poles and final export still gate acceptance.

## Computed-pole checkpoint storage contract

`common/s14_assemble_Hqg_cached_poles.wls` retains the executed root reduction
for each exact residual/domain pair. Only the final checkpoint representation
changes from refactoring the unreduced residual to storing that already
computed result. Every stored pole must have an executed proof and equal zero;
all original Laurent coefficients, pole predicates and finite extraction remain.
Before continuing, the native program must reproduce the complete own accepted
control and compare the actual immutable Regular checkpoint's full finite
coefficient to the original input-sum extraction. The comparison uses an
isolated source-bound checkpoint directory before installing its verified
result in the canonical cache. Record proof and source identities in the
finite result. This optimization remains unaccepted until those native gates pass.

The cached-pole consumer `17eb5b69a3f2099a2bf798695480c0039e58d9ae0140436e4854519449b54798`
passed its native interface gates in job `14882420`: exact restoration of
the original finite extractor and predicates, executed proof for every
stored zero, full actual input-sum finite equality, equality to the existing
accepted canonical finite checkpoint, and complete own-control equality.
The actual Regular checkpoint comparison took143.038664s. Native log marker
`HQG_POLE_STORAGE_ACCEPTED` records these facts; `PoleStorageEvidence` and
`ComputedPoleProofs` are included in the eventual finite result. The entire
channel remains unaccepted until all assembly/reference/export gates pass.

## Exact final-reference residual inspection contract

The complete component assembly in14882420 passed all poles but failed the
F1 U/U positive-branch Delta reference equality. Do not accept final hats.
Reuse s14_inspect_Hgq_reference_residual.wls with this channel's own failed
receipt, accepted source/input-bound finite checkpoints and original assembly
normalization. The Hqg inspection entry uses the already accepted projected
S05 reader, reconstructs F1/F2 Delta directly from the native checkpoints,
and saves the exact candidates, expectations, residuals and readable equations.
Its diagnostic success certifies the reconstruction/export, not zero residuals
or complete finite F hats. No subtraction or spin convention is changed.

## Finite subtraction difference comparison contract

Direct source/input review identifies the operation this comparison must test:
`completeIntermediateBorn` in `common/s11_check_dimensional_convolution.wls`
maps the extra-dimensional label `E` into `U` before
`common/s11_collinear_spin_convolutions.wls` applies the ordinary physical
`gg` kernel. The saved Hqg `IntermediateStateCompletions/GluonFragmentation`
records that conversion. The accepted native transfer result
`Hgq/s10_dimensional_gluon_result/s10_result.wl` instead retains separate
parent/daughter `U` and `E` entries and records zero off-diagonal soft
residues. The inherited completion proof belongs to Hqqprime; the S11
producer's direct dimensional-reference spin-contraction gate is conditional
on the channel containing no gluon. Its earlier PASS therefore does not
establish that check for Hqg. This is a concrete source/input discrepancy to
test, not an accepted finite correction. Preserve the old subtraction as the
bound diagnostic input; the native comparison and all-component reference
gates below determine whether the proposed replacement can be accepted.

`common/s14_check_Hqg_reference_terms.wls` reuses the executed Hgq comparison
algorithm on Hqg inspection job14884878 (using the S02 executor) and its current and archived S11
results. Retain the original normalization and physical domain; require the
actual full Delta counterterm difference to equal the saved finite difference.
Project it using the original F1/F2 weights and compare against each actual
reference residual. Record whether it explains that residual exactly. This
comparison changes no production input and does not accept final hats.

The user-authorized bounded local comparison
`misc/s01_check_Hqg_residual.wls` (SHA256
`25189bb520af738dc5d4276d30611d1d500eea2c80c45b2f7abdef33ea58da8a`)
has now executed these exact saved equations with Wolfram 15.0/FeynCalc10.2.1.
Its result `misc/s01_result/s01_result.wl` (SHA256
`22c2d9ede4bf5f53558fea27f952451c0c184c6db51e92a6c92930e6ce361b1f`)
and local execution receipt establish zero for both positive-branch Delta
residuals after removing the actual S11 completion change. The old reconstructed
E-to-U soft coefficient is `4 SUNN`; the saved native coefficient is zero.
The diagnostic took10.03s wall and411918336bytes peak child RSS. Its inputs
retain the original13.1 runtime identities, and the missing receipt from14884507
is explicitly recorded rather than fabricated. This establishes the origin of
the two inspected mismatches; all24 branch/distribution reference comparisons
and complete corrected-spin assembly still gate final acceptance.

## Native outgoing-gluon subtraction contract

The Hqg adapter reuses the accepted Hgq dimensional gluon result14816855,
including its independently checked FF matrix, and the accepted MS subtraction
algorithm. Derive the outgoing intermediate-state contraction from the native
Gram dual, Hqg extended outgoing Born labels and original FF route. Complete
the CDR U projector and derive the dimensional average from the native Gram;
retain physical X/Y/H definitions. Derive the CDR regulator remainder from
the uncrossed raw matrix and remove it in the physical block as in the accepted
MS algorithm. Keep all original convolution roots, weights, distributions and
endpoint identities. Require a regulator-free full-spin correction and every
F1/F2 branch/distribution reference comparison reconstructed from Hqg own finite
checkpoints. This is isolated under s11_msbar_result; existing production
inputs are retained until all native comparisons pass. No splitting value
is transcribed from another channel or inferred from reference agreement.

## Finite assembly after native FF subtraction

The Hqg finite-update entry retains the accepted frame reader and pole/checkpoint
implementation. Initialize the old scientific input identity, require the accepted
native MS subtraction and its full own-reference comparison, and derive the full
old/new counterterm difference. It must be regulator free. Reproduce an accepted
whole component with zero change, then directly assemble a component with nonzero
change using the new subtraction and fresh input hash. Require equality with its
checkpoint update before reusing every own accepted Laurent coefficient. Retain
all original finite projections, U/U comparisons, metadata and native export gates.
Reference precollection uses the already executed comparison reducer and an exact
reconstruction gate; no residual is assigned zero without evaluation.

## Final export with accepted native FF subtraction

common/s15_finalize_Hqg_coefficients.wls is the channel-only adaptation of
accepted Hgq finalization. Retain the complete original helicity-restoration
calculation and compact native writer. Require the accepted updated S14 receipt,
its exact subtraction identity and full unpolarized comparison flag; reproduce
the archived own helicity-conversion tensor exactly. The scheme record belongs
to s15_msbar_scheme_result and final coefficients to s15_result. This contract
does not mark either assembly or final export accepted before executed checks.

## Bounded local reference-comparison contract

The user-authorized local implementation remains under `misc/` until accepted.
For the actual saved Regular comparison equation, derive logarithm rewrites
with the original reference operations and prove each identity on the original
physical domain. Normalize root arguments only with exact native identities.
Represent maximal kinematic coefficients by temporary symbols, require exact
restoration of the whole input, and compare the native coefficient lists of
the original and reconstructed logarithm polynomials. Simplify restored
coefficients separately to avoid an unrestricted expansion in thousands of
temporary coefficient symbols. This is an unaccepted algorithm until it also
reproduces an own accepted complete comparison; the full branch/distribution
reference checks, corrected spin assembly, pole checks and S15 export remain
mandatory. Local Wolfram 15.0 execution and reused cluster 13.1 input identities
must remain distinct in the result provenance.

## Dimensional quark-to-gluon fragmentation transfer contract

Reuse the accepted S10 generated quark-gluon vertex, spin basis, collinear
frame, and full-dimensional transverse angular measure. Keep the parent
quark spin numerator physical and the unobserved daughter-quark spin sum
dimensional; retain the observed-gluon physical projectors and its E
complement separately. The native contraction must reconstruct every spin
component and reproduce the accepted S10 qg matrix in the physical limit.
Derive the CDR completion by summing the outgoing U and E projectors;
record its regulator remainder and the physical-block MS operator using
the same subtraction convention as the accepted gluon-transfer algorithm.
No finite term may be inferred from the Hqg reference residual. The resulting
S10 matrix is a subtraction input only; route convolution, all reference
comparisons, complete spin assembly and final export remain separate gates.

The dimensional quark-to-gluon transfer passed Hoffman2 job `14886248`
on `n7127` in60.245s, peak384266240bytes. Source
`common/s10_dimensional_quark_gluon_transfer.wls` SHA256
`16a98ccb008189f631f6da124e602e581219cd7635212f5e9272ef6be7fbf46b`
produced `s10_dimensional_quark_gluon_result/s10_result.wl` SHA256
`dac72a358f77e3b10483b88108da433a2e265e234cf5e04bb699a22b2d917162`.
The authentic checks, execution receipt and native log accompany it.
Every physical-limit spin entry reproduces accepted S10; the saved native
MS difference has only a U/U entry. It must be convolved through the
original QuarkFragmentation route, with its source-bound Born tensor,
Jacobian, endpoint prescription and prefactor. This accepts the splitting
input, not the full corrected subtraction or final Hqg coefficients.

`common/s11_finalize_Hqg_all_routes.wls` combines the accepted native gg
transfer and this qg transfer. It preserves the original route inventory,
convolutions, normalization, and physical spin basis. It applies the
coefficient-separated dimensional expansion with exact reconstruction and
own original-Series comparisons. The shared reference reducer requires
proved logarithm/root rewrites, exact whole-input restoration and polynomial
coefficient reconstruction, and an own complete original-reducer comparison.
Each branch/distribution comparison is cached by its complete equation and
source/runtime identity. Final acceptance requires every original F1/F2
branch/distribution residual to vanish before S14/S15 may consume the result.

The all-route subtraction consumer retains the existing S14 finite-update
entry and S15 final entry. Both require the source identity of
`common/s11_finalize_Hqg_all_routes.wls`. S14 retains the old complete-output
control and the fresh changed-component assembly comparison. It may reuse
an S11 reference reduction only when both the native equation/domain hash
and the accepted source/input/runtime identity match exactly; otherwise
it calls `common/s11_exact_reference_reduction.wl`. The final record retains
the hashes of these reference-equation checkpoints. Original pole, full
spin tensor, unpolarized-reference and helicity-scheme export gates remain.


## Accepted all-route native subtraction

Hoffman2 job14886271 accepted the complete native gg and qg fragmentation
subtraction, retaining the original incoming route, roots, Jacobians, Born
tensors, distributions and normalization. Every original F1/F2 comparison
passed for all three branches and all four distributions. The shared exact
reducer reproduced its own complete original Delta comparison before use;
the zero-support interface correction is included in its accepted source.

Source: common/s11_finalize_Hqg_all_routes.wls, SHA256
c0b59352030e2d089a141045edbe4e25269d61ca825923cace595d194fa09b14.
Reducer: common/s11_exact_reference_reduction.wl, SHA256
168b4b51f1ff470e33a7a4a7cb1a5727a21a1b6050086a8d3ede67690a2eef7c.
Result: s11_msbar_result/s11_result.wl, SHA256
b2bce739b0ea9e4164a433511dcf5d7d4957438cee2c8d0df63a5e703a213f72.
Comparison: s11_msbar_result/s11_comparison.wl, SHA256
5efbf228e7a5fea6c9a7692137cf5666133e1b32b6d605cd2167f972a3a63d87.
Checks: s11_msbar_result/s11_checks.json, SHA256
beb8e7037c6e1571cd7ee9d33d34c13f8116c42d28ef063d1a4e3408c5fe3656.
Authentic receipt: s11_msbar_result/s11_execution.json, SHA256
6225373b0e249d8388ea35d533a1bff9ba22c965807bb385299f67574cc6c293.
Native log: cache/s11_Hqg_all_routes_20260924_part2.log on Hoffman2.

Execution took1294.842417s; peak child RSS1967673344bytes.
Use this accepted subtraction for the finite-update S14 and final S15
entries. The earlier s11_result is retained only as the immutable old input
bound to accepted Laurent checkpoints and the discrepancy proof. Do not use
it as the final physical subtraction. Exact equation comparison checkpoints
remain under cache/s11_reference/Hqg with the recorded source/input/runtime
identity. Complete spin assembly, final pole/reference gates and axial-scheme
export must still pass before the Hqg F hats are accepted.


## Accepted full-spin finite assembly after all-route subtraction

Hoffman2 job14886398 accepted all144 physical spin/photon components,
complete inherited pole cancellation, every final F1/F2 branch/distribution
reference comparison, and exact native export/reload. The finite-update
algorithm first reproduced the complete old accepted control, then matched
a directly reassembled changed component exactly. For that complete control,
direct assembly took20.092151s and checkpoint update1.448419s; this is a
measured control comparison, not a claim about whole-workflow speedup.

Entry: common/s14_assemble_Hqg_finite_update.wls, SHA256
e7fbf33120608ee0d213545791ec52c60a84edf9c9951a7091a6d97df19c0227.
Result: s14_result/s14_result.wl, SHA256
f119ec5d570e69ecbd3ea74b08875cf4429e960979be0ad9ee348d54c192cfe6.
Checks: s14_result/s14_checks.json, SHA256
eaadea10185e812597d2f9be0e2840963c4cb70a90dca026ffe30eb5ee7f9435.
Authentic receipt: s14_result/s14_execution.json, SHA256
54eb3660791c0ec3dee8bc7c9a3f19d1188f57ca4f3345ab96a50b0fb76fcd26.
Native log: cache/s14_Hqg_all_routes_20260924.log on Hoffman2.
Execution1554.111996s, peak child RSS10075205632bytes.
The native file is44413705bytes and is retained locally with its verified
checks and receipt. It binds the accepted all-route S11 subtraction and
the immutable own Laurent checkpoints. This accepts the finite BMHV
assembly; the final S15 axial-scheme conversion/export is still required
before calling the final Hqg hats accepted.


## Accepted final coefficients after all-route subtraction

Hoffman2 job `14886547` on `n1078` accepted the complete S15 export.
The bound S14 result contains all 144 physical photon/spin components, passed
componentwise pole cancellation and the pinned U/U F1/F2 comparisons. S15
preserves that input identity, reproduces the prior own helicity conversion,
applies the recorded finite scheme conversion, and passes all final native
export/reload and unpolarized-preservation gates. The final checks record
`finite_nlo_fhats_computed: true`. The earlier S14-only boundary above is
superseded by this final acceptance.

Entry: `common/s15_finalize_Hqg_coefficients.wls`, SHA256
`2889b3ea4a0d4a95236cbd3e9a4da2e1399eb52a817848953bc7f4932771121d`.
Configuration: `.cluster/s15_Hqg_all_routes_20260924_job.json`, SHA256
`61f105715a5b7162d970688967119d94b16d58fe9e32a0d4fdc6039183bc3121`.

- `s15_msbar_scheme_result/s15_result.wl`: `de2657493e4a31c69a19ff152d296da7cfa3f79f967b88b4dfec807d46a4b953`
- `s15_result/s15_F1_hat.wl`: `26f9f1e6e094a9de429183753e6a80d1aa153e084ccf3838d6f8ff1050c66049`
- `s15_result/s15_F2_hat.wl`: `491bf6fbb6aaa6d6f8ee24360b068002377cd1481624d7b57a435a2dffed8146`
- `s15_result/s15_checks.json`: `c653567791fdd306d7a2468782aef78c61e8d79692b7e943e4c524bb8d0ac489`
- `s15_result/s15_result.wl`: `5f4ab0cc6e4e05ba5c04058fd00ce7d1ed69e81b147e776178fa8ae782190948`

Execution receipt: `s15_result/s15_execution.json`, SHA256
`50552f6804737170b71d616edad67adf19b96b084ff274ea8ee04b0906bb794b`.
Native log: `cache/s15_Hqg_all_routes_20260924.log` on Hoffman2.
Execution took 663.3245483413339 seconds; peak observed process-tree RSS
was 7295426560 bytes. Final coefficients, their checks,
the finite scheme tensor and execution receipt are retained locally.

Consumers should load `s15_result/s15_result.wl` for the full spin/photon
library and `s15_F1_hat.wl` / `s15_F2_hat.wl` for the original projector
exports. Preserve the saved spin basis, scheme, branches and distributions.
These are partonic large-transverse-momentum SIDIS coefficients; numerical
PDF/FF convolution and jet matching remain outside this export.


## Accepted stage entry points and local results

The entries below produced the accepted records. Shared stages link to their
common owners to avoid duplicating data. S01 uses `s01_prepare_inputs.py` and
`s01_result/s01_result.json`. Execute native stages from the polarized_SIDIS
root using their recorded cluster configuration and environment.

| Stage | Accepted entry in this folder | Local result |
|---|---|---|
| s02 | `s02_define_spin_basis.wls` | `s02_result/s02_result.wl` |
| s03 | `s03_born_spin_response.wls` | `s03_result/s03_result.wl` |
| s04 | `s04_transverse_angular_average.wls` | `s04_result/s04_result.wl` |
| s05 | `s05_real_spin_response_Hqg_linear_assembly.wls` | `s05_result/s05_result.wl` |
| s06 | `s06_reuse_scalar_integrals.wls` | `s06_result/s06_result.wl` |
| s07 | `s07_virtual_spin_response.wls` | `s07_result/s07_result.wl` |
| s08 | `s08_map_real_spin_compact_inputs.wls` | `s08_result/s08_result.wl` |
| s09 | `s09_map_virtual_spin.wls` | `s09_result/s09_result.wl` |
| s10 | `s10_collinear_spin_kernels.wls` | `s10_result/s10_result.wl` |
| s11 | `s11_finalize_Hqg_all_routes.wls` | `s11_msbar_result/s11_result.wl` |
| s12 | `s12_assemble_real_factored_series.wls` | `s12_result/s12_result.wl` |
| s13 | `s13_assemble_virtual_refined.wls` | `s13_result/s13_result.wl` |
| s14 | `s14_assemble_Hqg_finite_update.wls` | `s14_result/s14_result.wl` |
| s15 | `s15_finalize_Hqg_coefficients.wls` | `s15_result/s15_result.wl` |

S10 also includes the accepted dimensional gg/qg transfer inputs documented
above; S12 retains its factored-series result and endpoint comparison.
S11 uses `s11_msbar_result` for the final subtraction. The older `s11_result`
is retained only for exact upstream checkpoint provenance. S15 owns the
full tensor, separate F1/F2 hats, finite scheme result, checks, and receipt.
