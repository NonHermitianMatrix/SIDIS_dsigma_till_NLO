# Hgg: incoming gluon, tagged gluon

## Accepted final partonic coefficients

The complete Hgg partonic export is accepted. The local S14 run passed all
144 component assemblies and every original F1/F2 branch/distribution
comparison; the dependent S15 run passed its finite-scheme and complete
finite-export gates. All saved pieces and final files match their execution
receipt hashes. `FiniteNLOFHatsComputed` is true in the final output schema.

- [Full photon/spin response and both hats](s15_result/s15_result.wl)
- [F1 spin matrix](s15_result/s15_F1_hat.wl)
- [F2 spin matrix](s15_result/s15_F2_hat.wl)
- [Executed final checks](s15_result/s15_checks.json)
- [Final execution receipt](s15_result/s15_execution.json)

These channel paths link to `../misc/s15_result/`. Load FeynCalc before
`Get`, and retain each `.wl` index together with its sibling `*_parts/`
directory. Each index checks its data-piece hashes before returning the
native record. Use the saved `IndexOrder`, `SpinLabels`, `PhotonLabels`,
`BranchConvention`, `PlusDefinition` and physical-frame conventions.
The full record retains `NLOResponse` and `Fhats`; the separate hat files
contain `LODelta` and `NLO`. Numerics and jet matching remain deferred.

Current local production code is available through
`s11_assemble_Hgg_real.wls`, `s14_assemble_Hgg_finite.wls` and
`s15_finalize_Hgg_hats.wls`. The corresponding accepted local intermediates
are `s11_local_real_result/` and `s14_local_finite_result/`; the historical
`s11_result/` remains a distinct subtraction input.

| Accepted identity | SHA256 |
|---|---|
| S14 source | `668d8910f400f82431f5fa566a71988723ca40a44a64e16c347e28104bc8b304` |
| S14 receipt | `dfd47e3ed7b415654f168f90e19fe0ee13ed8be2cd5fe1b989e6284e232dd54a` |
| S15 source | `451a6d5a9edf93e9a40b8dc11f37450d2e529398bdf0fac201e9be9158a8b705` |
| S15 configuration | `fa1aee168aef34b9882e36f242e58cc4e52ef2d9b247d2f30daf7ed4f0fc2254` |
| S15 receipt | `3a0341da88a41f9bfe68dffc4557530c487f116f621a4ad092c28b282fec8b52` |
| Full result | `8a15dc756ebe12d25d570c3c14df83c4f852087306885bc7d82bbc118fc7998d` |
| F1 | `9b1b639dccc5a41e058359093447f9b0699f4a8bec78735ec6e960644c72cf63` |
| F2 | `c35e8352fbac86abbe4b4af0548c42bcb4e1cf61312e67528e6312ca92af36b9` |
| Native storage helper | `6f19a926c4638c22f4e4280101cae3b09d694b5a6d9f83656696f680a18ff947` |

S14 completed in 1944.851 seconds with peak observed process-tree RSS 8931282944 bytes. S15 completed in 1959.147 seconds with peak RSS 6297206784 bytes. The local monitor enforced the reserved 4 GiB available RAM and 8 GiB free disk throughout. Source/configuration generations and accepted provenance caches remain retained. The detailed contracts below describe the inherited stages and their accepted corrections.

The incoming gluon has momentum `p`; the tagged gluon has momentum `k1`.
The reference real sector includes an unobserved quark–antiquark pair.
Keep its flavor-charge sum and spectator counting separately from
factorization multiplicities.

## S01 inputs

`s01_prepare_inputs.py` uses the shared S01 implementation.
`s01_result/` owns the receipt for selected open-amplitude inputs.
Spin-summed reference tensors are not polarized coefficients.

## Spin-dependent contract

Define both gluon spin structures from the selected operator basis; do not
substitute quark transverse-spin projectors. Determine which components
belong to the requested observable through executed checks.

Later accepted sources/results use consecutive `sNN_` names and the
shared cluster and acceptance contract.

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

## S12 integrated real tensor contract

Use the shared S12 program after this channel's scalar map has complete
verified reduction coverage. Preserve the generated charge and spectator
bookkeeping and evaluate the measured transverse factor in every endpoint
limit. The reference cut masters and distribution assembly supply the
Delta/L0/L1/regular tensors before final normalization and subtraction.

## S03 auxiliary Born spin tensors

`s03_auxiliary_born_spin.wls` applies the accepted Born-frame and
physical/dimensional spin contractions to the actual pinned `born_qg`
and `born_gq` amplitudes. Preserve explicit flavor charges, derive the
quark/antiquark assignment from the native spinors, and require full-D
reconstruction of the original g/pp contractions, Ward identities,
Hermiticity and complete photon/spin reconstruction. Results belong to
`s03_result/qg/` and `s03_result/gq/` and carry no phase-space factor.
They are auxiliary subtraction inputs, not this real-only channel's
Born cross section. Additional charge-conjugate routes must have their
own native or fully verified amplitude inputs before use.

`gq` passed job `14775313` on `n7123`;
`s03_result/gq/s03_result.wl` has SHA256
`9d4fae5305d926dd243757feadfa2b86952ae4f6d4804bfc96fc588e4e1199a4`.
Each accepted route passed the full-dimensional GitHub g/pp comparisons,
Ward identities, Hermiticity and complete spin/photon reconstruction.
The shared source SHA256 is
`d7f17d27e9f268c687bb41590ef793ddef0752aa7686dd3b651591c9d1718f6e`.
Checks and execution receipts accompany each result.

The `aqg` auxiliary route uses native FeynArts generation with the pinned
qg process and reversed external fermion species. Preserve the original
model, momentum assignments, conversion options and symbolic-charge
normalization. Save the generated amplitude with its result. Require native
antiquark assignments, full-D original g/pp reconstruction, Ward identities,
Hermiticity and complete spin/photon reconstruction before subtraction use.

## S11 small-channel subtraction contract

Use the actual auxiliary Born spin tensors and S10 kernels, with the
pinned GitHub S16 convolutions and preserved factorization routine. Derive
rescaled invariants, roots and Jacobians from the saved real scalar products
and compare every mapped photon/spin axis. Retain both native quark and
antiquark Born routes for Hgg and the fixed-flavor routes for Hqqbar and
Hqqprime. Require exact full-D reproduction of both original scalar
convolutions and absence of soft endpoint poles before exporting regular
spin counterterms. Preserve explicit charges and derive the removed Born
coupling power from the actual saved Born contractions. These counterterms
include the original PhaseCT and restored Born coupling; the consumer must
not apply those factors again. Complete real/virtual cancellation and any
finite spin-scheme conversion remain final-assembly requirements.

The qg auxiliary result passed job `14775314`;
`s03_result/qg/s03_result.wl` has SHA256
`37a5f4efce200707c3596e69dd089414ab097325df161ed8d94754b65872da06`. All original scalar, Ward and spin reconstruction
checks passed; its execution receipt is saved alongside it.

Job `14775337` on `n7133` accepted `common/s03_auxiliary_born_spin.wls`.
`s03_result/aqg/s03_amplitudes.wl` has SHA256
`9e4f8b9889060df69fbba3d6c6809152ccc6f6e0cfa7af6dc1568cf67b36843a`.
`s03_result/aqg/s03_result.wl` has SHA256
`42a21b96b2f6d0af7f9b0b0377830ad25c639ee84fb9bac1acf6d79d61181ed3`.
Its checks and execution receipt are saved alongside the result. The full
original scalar comparisons and all stage acceptance gates passed. This
result remains an input to complete NLO assembly, not a finite NLO hat.

Job `14775343` on `n6129` accepted the shared small-channel subtraction
source, SHA256 `44ac7b5470ce54c6d0276bfa685ab88a5fff8d78d90c3835e7548488c48ffc8a`.
`s11_result/s11_result.wl` has SHA256
`e5a4aa27a7a5e22fe07b0ee22e9f9709ba0d87e5c191ee1bbdfa0115052ceebc`.
Its checks and execution receipt accompany it. Both original full-D
convolutions, all four native charge-conjugate spin routes, and the
absence of soft endpoint poles passed. This is a subtraction input,
not a finite NLO hat. Runtime was 38.155 seconds; peak child RSS was
387899392 bytes.

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

The S15 finite scheme tensor passed Hoffman2 job `14775519`.
`s15_scheme_result/s15_result.wl` has SHA256
`70486a70c6f464e8c095610513159a8994cb1ac009b5e18791d6e5be92eeb64e`. All normalization, helicity-index,
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

The S05 spin-map comparison applies the already validated derivative
coefficient extraction to the scalar-reduction boundary. Reconstruct the
complete spin polynomial, compare the actual accepted Hgg pair/projection
checkpoint bound by `common/s05_spin_map_inputs.json`, and execute the
projection that exceeded its memory bound. Preserve the native traces,
angular moments and individual scalar-reduction equations. Record time,
expression size and memory before any production use. Comparison artifacts
belong to `Hgg/s05_spin_map_result/`; all channel-level gates remain required.

The S05 spin-map comparison additionally restores the saved exact scalar
products before rational reduction, omitting the preliminary factorization
in independent abbreviation symbols. Preserve the complete existing
on-shell reduction and angular-average equations. Record restoration and
reduction timings and require equality of the complete accepted Hgg
projection before evaluating the previously bounded projection. This
comparison does not alter production contractions or their valid caches.
The previous comparison source is retained in
`common/s05_result/reference/s05_spin_map_check_before_scalar_restore.wls`.

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

Job `14779545` accepted the complete scalar-restoration comparison.
`Hgg/s05_spin_map_result/s05_result.wl` has SHA256
`3049dfee6baa6ee6f7aed473ada5237cd7bc445ceb89d5ce13d1cbf7531d9d89`.
The full accepted projection matched exactly, and the previous memory-bound
projection completed in 1403.629925 seconds. Native compressed-file reload
and all reconstruction gates passed. Whole-job time was 2802.875224 seconds;
peak child RSS was 1357971456 bytes. The source is
`common/s05_spin_map_check.wls`, SHA256
`50da84aeb699f0d1ccf15f1bcf49a313774e82a9e3cffe2817fd391ae24e2fcf`.
The comparison result, checks and matching execution receipt are local.
Production may install its exact recorded scalar definitions while retaining
all channel-level Ward, CDR and reconstruction gates. This comparison does
not accept a complete real tensor or any finite NLO coefficient.

The accepted comparison projection is reusable through the input/hash-checked
cache entry `cache/s05/Hgg/430c1735f22eb7d8c345f075c3abebc07a23fd75fb3faa8575413c7938381bff/Real_1_5_P2_2.wl`
on Hoffman2. Its SHA256 is
`75292c069e60a82127959a75c56d0816bf1931936db537ab4a2aeffdb067d490`.
It reads the exact saved Candidate value from comparison result `3049dfee...`,
verifies that result hash, channel, pair, projection and calculation identity,
and supplies the unchanged native projection-cache schema. Retain that
comparison result while this cache entry is needed.

S05 projection resumes may set `POLARIZED_SIDIS_REAL_SECONDS` explicitly
(the default is 2400 seconds, with a checked maximum of 10800 seconds).
This changes only the native time bound. The 2 GiB operation limit and
4 GiB spin-reconstruction limit, all contractions, checks, and checkpoint
identities remain unchanged. The scheduler and process-tree limits must
cover the selected bound. Preserve the preceding source in
`common/s05_result/reference/s05_real_spin_response_before_projection_time_resume.wls`.

The S05 pair-assembly comparison reads the actual accepted Hgg pair and all
of its input-bound projection checkpoints. `s05_pair_assembly_check.wls`
tests native coefficient conjugation after deriving and gating the actual
exact rational expression heads and integer powers, retaining factored sums
instead of repeating the pair's full rational reduction. Verify each actual
symbol against the existing `ComplexExpand` real-symbol convention. Require exact
agreement of every photon entry and scalar projection with the complete
accepted pair, plus exact native output reload. Record measured time and
expression sizes before adopting the representation. The comparison owns
`s05_pair_assembly_result/`; it does not change production or accept a full
channel tensor by itself.

Job `14782053` on `n6405` accepted the complete pair-assembly comparison.
`s05_pair_assembly_result/s05_result.wl` has SHA256
`1cd27950314f1eda6f9652fe86521677fa2ad5949ad39854c62b4060af4b57f6`.
All 153 checks passed, including exact agreement of nine photon entries and
four scalar entries with the complete own-channel pair, rational-head and
real-symbol conventions, and native compressed-file reload. Construction
took 20.849279 seconds; the separate exact comparisons took 2205.165396
seconds. Whole-job time was 2325.764049 seconds and peak child RSS was
2301497344 bytes. These timings do not establish a full-channel speedup.
The accepted source is `common/s05_pair_assembly_check.wls`, SHA256
`47d405b7553fd93f3f4df63a008027e0b6b7500cc3041c59f5e8b7682be57900`.
The comparison used production source `56e507b4...`, retained as
`common/s05_result/reference/s05_real_spin_response_before_factored_pairs.wls`.
Checks and the matching execution receipt accompany the local result.

Production may enable `POLARIZED_SIDIS_FACTORED_PAIR=1` to install the exact
three saved definitions. Require the accepted proof/source identities and
shared spin/angular inputs, and gate rational heads, integer powers and
native real-symbol conventions for each new expression. Preserve the
complete trace/projection/checkpoint code and all final channel gates.
Only off-diagonal pair completion changes its algebraic representation;
accepted scalar and pair checkpoints retain their physical input identity.

Completed S05 pair checkpoints are sufficient for the unchanged resume and
pair-sum readers. Individual projection files belonging to those completed
pairs may be archived on a compute node while other pairs run. Preserve all
projection paths pinned in S05 manifests or job configurations, including
the accepted `Real_1_5_P2_2.wl` comparison. Before removing an individual
file, verify its archived member hash, its unchanged source hash and its
unchanged completed pair hash. Keep each archive below 128 MiB and record
every original path, member hash, owning pair hash and restore base in
`s05_projection_archive_result/s05_cache_manifest.json`. Incomplete pairs
and their projections remain untouched. This is lossless storage management;
it does not accept additional tensor components or finite hats.

Archive job `14795834` passed on `n7121` in 48.654 seconds, with 15,220,736
bytes peak observed process memory. It verified every selected member and
kept all 13 completed pair files unchanged. The manifest has SHA256
`61fb356d8c6145653b9e631e565fb4e79266b95043db324b8f89c602fff7406e`;
it records each original path, file hash and archive part. The three archive
parts, manifest and matching execution receipt are retained locally under
`s05_projection_archive_result/`. Remote duplicate archives were removed after
local/remote byte-count and SHA256 equality checks; remote metadata remains.
To restore a projection, transfer its archive back, verify the archive hash,
then restore only at its manifest path and verify the member hash before use.

## S05 scalar coefficient checkpoint contract

`common/s05_check_scalar_checkpoints.wls` compares coefficient checkpoints
with the complete first diagonal pair's accepted photon projection. The
restored input, physical input identity, native reduction definitions and
transverse constraint bind each checkpoint key. Preserve the exact scalar
restoration, on-shell reduction and angular-average equations; the only
change is saving and reloading completed coefficient values. Require exact
native file reload, own accepted-output equality, and a second full
projection that demonstrably reuses the saved coefficients. Separate
process-specific temporary files prevent concurrent writers from sharing a
temporary path. Comparison artifacts belong to `s05_scalar_checkpoint_result/`;
production use requires its executed gates and retained source identity.

The comparison passed job `14796018` on `n6124` in 388.260 seconds, with
958,099,456 bytes peak observed process-tree RSS. Its complete own accepted
projection comparison and saved-value reload passed. Scalar reduction took
226.500 seconds on the first pass and 35.657 seconds on the reload pass;
these are projection measurements, not a full-channel speedup. The result
`s05_scalar_checkpoint_result/s05_result.wl` has SHA256
`448fa9968a5bc362fe8ff7d2a31a7a2e5284a04a81a2ce7a8d88a135f3440c3f`.
The source SHA256 is
`3f021ad902e9574e1a7f4168e9002ffdcfde02bcc4f21d6166577b644724ee1f`.
Checks and execution receipt accompany the local result.

`common/s05_real_spin_response_cached_scalar.wls` installs these exact
accepted definitions after matching the original reduction equations and
physical inputs. Coefficient caches supplement the unchanged projection
and pair caches. The variant also uses the accepted Hgq spin-polynomial
reconstruction and lossless chunked native writer; their checks remain
mandatory. Its final `s05_result.wl` loader requires all hash-bound payload
parts listed in `s05_payload_manifest.json`. Keep each file below 128 MiB
and require exact reload of the full native result before acceptance.
Final tensor gates and all later finite-assembly gates remain required.

If the two-GiB operation bound interrupts a projection, the unchanged
source's checked `POLARIZED_SIDIS_REAL_MEMORY_GIB=4` setting may resume its
completed scalar coefficients. Use four shared slots with 8 GiB per slot,
a 30 GiB process-tree guard and a 24 GiB per-process address limit. Apply
this only after the preceding writer exits; retain every input hash and
require all original projection, tensor and storage checks. A resource
resume does not by itself accept the interrupted projection.

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


## Corrected S11 dimensional intermediate states

Hqqprime comparison job `14798308` established the omitted intermediate
gluon U/E completeness contribution in the original spin subtraction. Its
64.536-second native run preserved every physical D=4 Born component,
reconstructed both full-D reference convolutions, proved the correction
contains no regulator pole, and returned exact zero for both actual failed
finite F-hat residuals. It also proved the saved CDR metric poles vanish.
Comparison result SHA256 is
`3c76ab221bf3c99ba7c35223b26ca10ec527596dc2f60307d5cc7e508dbc411c`;
checks SHA256 is `519e1caa0fa2f8d40e797c3838c8b4413c15b9e96f47c669907377a51f1ed71f`;
receipt SHA256 is `263420a0b3b402d0c32a66343161c0f801cda759c626337936c074bb3cc35e64`.

The corrected shared S11 source installs that exact accepted definition,
checks its source, native versions and result identity, and evaluates this
channel's own Born tensors and routes. Preserve the original convolutions,
frame, endpoint and normalization checks. Additional gates require unchanged
D=4 components and a pole-free counterterm difference; quark-only external
channels must reconstruct both original full-D contractions from the actual
completed spin convolution. Routes with no dimensional intermediate state
must remain exactly unchanged. Preserve the existing output schema and
record the completion proof, previous subtraction hash and exact difference.

The preceding source is preserved as
`common/s11_result/reference/s11_small_collinear_spin_before_dimensional.wls`.
Prior S11 artifacts are versioned under
`s11_result/reference/before_dimensional_completion/` and are superseded for
assembly. Dependent scheme artifacts and Hqqprime finite checkpoints must
be versioned away before corrected assembly. S05/S08/S12 inputs remain valid.
Complete corrected S11 execution and the original S14/S15 final gates are
still required; the comparison alone is not a finite hat.

The corrected S11 production run passed job `14798563` in 30.423 seconds.
Current result SHA256 is `6d454824faf6e2ba81e12fdecfceb8f215755ab934c0a47eafd528b2b300f4e9`.
Checks SHA256 is `e2b85ddb2df8015a5d40ed00d0e2b430ee354092a655cb4193f8ceb4cab0bcd4`;
receipt SHA256 is `94f74a880543a77976714a3653491059cba9d8f0e387262e2e2a288e8227edbb`.
All three artifacts are verified locally. Consumers must use this corrected
result and source `b47acf502782cf5da4720163519a419c81a1a7f750679441a32685da2838f1af`.


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


S15 scheme-input dependency: `common/s15_inputs.json` pins the accepted
completed core S11 source `4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6`.
The earlier configuration is retained in
`common/s15_result/reference/s15_inputs_before_dimensional.json`.
Only that source identity and byte count changed; the scheme definitions,
reference kernels and standalone normalization contract are unchanged.
The S15 job configuration must bind the updated JSON itself as well.


## S05 early photon Ward comparison contract

`common/s05_check_early_photon_ward.wls` uses the pinned GitHub S05
ordering: substitute the photon momentum in the generated amplitudes
before the spin sum. Derive momentum conservation from the same saved
incoming/outgoing lists and let native DiracSimplify apply the Dirac
equation before forming the pair. Preserve the entire spin-density,
color, spectator, scalar-reduction and angular-average definitions.
Require exact equality of the complete accepted first diagonal pair's
PhotonWard spin polynomial, then evaluate the actual timed-out pair
{2,6}. Record the native timings, original definitions, inputs and output
reload check. This comparison writes only `s05_early_ward_result`;
production adoption requires its successful checks. Existing production
jobs and their checkpoints are not changed by the comparison.


## S05 completed projection archive continuation

Completed pair files supply all subsequent pair-sum inputs. The existing
verified archive routine may compress their individual projection files
on a compute node while unrelated pairs run. Preserve every path pinned
in any S05 input or job configuration, all incomplete pairs and all
completed pair files. Verify each archived member's exact hash and its
unchanged owning pair before removing the raw duplicate. Verify each
JSON manifest by parsing the temporary file before publication. Keep
archives below 128 MiB and record all member paths, hashes and restore
base in `s05_projection_archive_continuation_result/s05_cache_manifest.json`.
Final coefficient acceptance still requires every original stage gate.

Archive continuation job `14800710` passed in 28.281 seconds. It preserved
14 completed pairs and archived 61,023,921 source bytes into 14,619,433 bytes.
The continuation manifest has SHA256
`e904408f4f836ec4eae48d73c2bd48daca70c16bb118cf3be7643f030b0ec2f3`;
its archive has SHA256
`668832926955f0b16470d0229cd0bebd9381d54ff491f300a83bcacae152a93e`.
The matching receipt is `b0d5c419693a6c8d50f99ffef5d5ecb8f261b6235025395edb2ec6d3bc60743a`.
All three files are verified locally in the continuation result directory.

## S05 completed pair storage contract

`common/s05_compact_pair_checkpoints.wls` may replace completed, unpinned
pair files with native `Uncompress` expressions only after exact `Get`
equality against their original values in the accepted native runtime.
Bind each original file hash, size, physical input hash and complete pair
checks. Preserve every path pinned by the S05 inputs or any job configuration.
Before atomic publication, archive and verify the original bytes losslessly
under `s05_pair_storage_result/s05_sources/`; keep files below 128 MiB.
The storage manifest records both byte identities and the original-byte
archive for each pair. Historical archive manifests continue to refer to
those preserved original bytes. This representation changes no native
pair value, contraction, accepted check, or downstream `Get` interface.
The preceding projection archive must have completed before these pair
file bytes change. Unfinished pair/projection files remain untouched.

The cached early-Ward comparison uses
`common/s05_check_cached_early_photon_ward.wls` and the accepted cached
scalar reducer `ee4189f1cc6b6e1aa618ffc9ff40878a8cb6bd806ed880679d16bb7c209e68ff`.
It preserves the original early-Ward equations and complete own-pair
comparison, while retaining completed scalar coefficients through the
already accepted native checkpoint interface. Its separate output directory
is `s05_early_ward_cached_result/`. Production use still requires successful
completion, exact own accepted-output equality and exact native reload.

## S05 compact checkpoint production contract

`common/s05_real_spin_response_compact_checkpoints.wls` retains the complete
immutable cached-scalar implementation and changes only its checkpoint
writer. Require the accepted own-channel pair-storage proof, its source
identity, matching native versions and all executed checks before use.
Every new checkpoint must remain below 128 MiB and reload exactly to its
input value before atomic publication. Existing input hashes, native `Get`
readers, spin contractions and all final channel gates remain unchanged.
Record the storage proof and dispatch identities separately in the final
S05 result. This avoids repeatedly writing and archiving large text pairs;
it does not accept an incomplete tensor or a finite coefficient.


Pair-storage job `14800961` passed all ten exact native reload and original-byte
archive checks in 811.525 seconds. The accepted proof
`s05_pair_storage_result/s05_result.wl` has SHA256
`3c08cc4c364a108a1d64c1e58c8436c5c5cafe07fef005045606e90d9795073d`.
The complete manifest has SHA256
`bd43ee8adadb9d2b3c55df34809176151985be7d0a6e8483c665a54be5796cab`;
the matching receipt has SHA256
`24edf3322f95d0f5203046b38aa0cce257bde23fc50937a4163f88c49d0c9613`.
The proof, checks, manifest, receipt and every original-byte gzip archive are
verified locally. The original 471842828 bytes now occupy
157151070 bytes as native checkpoint files. A verified remote
archive duplicate may be removed after its local hash and byte count match;
keep the manifest and compact native files remotely. Restoring original bytes
requires transferring the indicated gzip archive back and checking the
manifest's original SHA256 after decompression.

Production with the compact checkpoint writer retains the accepted scalar
calculation and uses a bounded 4 GiB task-root scratch allowance, a 2 GiB
filesystem reserve, and 128 MiB individual-file limits. This permits native
atomic-write staging without relaxing the existing operation or process-tree
memory limits. Local collection keeps its separate 3 GiB free-space reserve.
An early-Ward comparison does not alter production until its complete native
comparison and output-reload gates pass.

## S05 reduced angular-input comparison

`common/s05_check_reduced_angular.wls` retains the cached scalar reducer,
original angular moments, numerator reconstruction and final on-shell
reduction. Before the angular routine's initial repeated reduction, native
PolynomialReduce checks the actual numerator against the recorded transverse
constraint. The shortcut requires a transverse-independent denominator and
an exactly unchanged remainder with zero quotient; other inputs use the
original reducer. Derive the candidate from the unchanged angular source
with one checked expression replacement. Compare the entire accepted first
diagonal pair's first photon projection, then evaluate the original pair
{2,6} PhotonWard projection, retaining all spin and color closures. Record
actual timings, input identities, definitions, normal-form checks and exact
saved-value reload in `s05_reduced_angular_result/`. This comparison does not
modify production; adoption requires its complete native checks.

While pending, job `14801780` retained four shared slots and changed its
request to 6 GiB per slot (24 GiB total), following the preceding measured
14,016,544,768-byte peak process-tree RSS. The immutable configuration is
bound in `../.cluster/s05_result/s05_Hgg_memory_allocation_adjustment.json`.
The compact writer loads FeynCalc before parsing the inherited implementation;
the prior unexecuted dispatch is retained under
`common/s05_result/reference/s05_compact_checkpoints_before_native_initialization.wls`.
Actual dispatch SHA256 is
`030c45837ea1fd7b558ab97105e7384bbaad9f35bd53c3e9b868dd4ee19bac29`.

## S05 complete-amplitude photon Ward comparison

`common/s05_check_amplitude_photon_ward.wls` reuses the reviewed early
photon substitution and native momentum-conservation solution. First require
the full accepted diagonal pair's Ward spin polynomial to match. Then sum
every generated amplitude with the photon momentum substituted, retaining
open quark spinors, gluon polarizations, exact dimension and color. Native
Dirac, Lorentz, scalar-product and color simplification must produce an exact
zero amplitude, and the unchanged scalar-contraction routine must also return
zero. Record every source/input identity, generated inventory, native timing
and exact result reload in `s05_amplitude_ward_result/`. A successful proof
may support a separate complete-sector Ward check; it never assigns zero to
individual diagram-pair Ward contributions or accepts unfinished physical
photon projections. Production remains unchanged until this proof passes.

The complete-amplitude comparison `14802097` reproduced the entire accepted
Ward control, but the subsequent open amplitude did not simplify to zero.
It is not an accepted optimization. Its source SHA256 is
`aa13c2621bab08032a2f399f800e7b83ce2a483476f2721413bb70bc86aca6b5`;
the saved residual `s05_amplitude_ward_result/s05_unaccepted_expression.wl`
has SHA256 `0b71c05075bc1aaf9a702e1c2cca266ae465d015a344244f859fed7c38c3a14f`.
`common/s05_check_ordered_amplitude_ward.wls` may test this exact residual
using native Dirac ordering and explicit color traces. Require its original
source/input and full generated-inventory binding, the entire own Ward control,
exact zero after native simplification, unchanged scalar contraction, and
exact output reload. Its separate output is `s05_ordered_amplitude_ward_result/`.
Neither an unaccepted residual nor a partial comparison changes production.

The ordered complete-amplitude Ward proof passed job `14802329` in
371.521 seconds; the ordering and simplification of the saved full amplitude
took 22.237712 seconds and returned exact native zero. The unchanged scalar
routine also returned zero and the entire accepted own-pair control matched.
The proof `s05_ordered_amplitude_ward_result/s05_result.wl` has SHA256
`48367062fd822766d83c23e95da8845e67c5ae0e49f532ee9b47914b7a6a2239`;
its receipt has SHA256
`7cfa37e10aa962ce993471c89c15ee3b230d679a5f7ebd84b19bbee306a0abea`.
Source SHA256 is
`17eeead96293268f88c8ff9fc2d6bc4dfeeafb76eec3edefda7fa1390d8bda53`.
All three result/check/receipt files are hash-verified locally.

## S05 production with a complete-sector photon Ward proof

`common/s05_real_spin_response_sector_ward.wls` reuses the immutable compact
checkpoint implementation and accepted scalar equations. Verify the own
complete-amplitude proof, its receipt, all physical input identities, native
versions, generated amplitudes and original contraction definitions before
processing pairs. Omit only individual PhotonWard evaluations. Preserve every
physical photon projection, PgD and gluon-Ward evaluation. Use a separate
`cache/s05_sector_ward/Hgg/` namespace bound to the physical input and accepted
proof; completed original physical projections remain reusable. Mark new pair
records with that proof identity. Old pair records retain their original
individual Ward values; remove that field only from the in-memory assembly
inventory. Insert the tool-produced complete-sector Ward value before the
original final Ward gates. Do not represent individual pair Ward values as
zero. Preserve the final scientific schema and record the new dispatch,
proof identity and cache namespace. The current native writer must exit
before the new production entry point owns the stage output.

The separate reduced-angular comparison job `14801822` exceeded its
3,600-second candidate-operation bound and is not an accepted optimization.
Its result is not used by the complete-sector Ward dispatch.
The reviewed sector-Ward entry point has SHA256
`6948a70cdb9e796425db2d4fb61bf848af2824cdb1e0e493470c0d81a250dd14`;
its submitted configuration is `.cluster/s05_Hgg_sector_ward_resume_job.json`,
SHA256 `21b6f866680a7f3e3b0248a38654ad676ff142802d0a12883336a8b63355168e`.
The previous stage writer and its four native workers were confirmed absent
on `n6443` before the new entry point was submitted. Their scalar and physical
projection checkpoints remain available to the new namespace.


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

The Hgg continuation keeps 4 slots with h_data=6G per slot,
with both execution guards set to 22 GiB. Equations and checkpoint keys are unchanged.

## Own-channel zero-angular comparison contract

`common/s05_check_Hgg_zero_angular.wls` imports the executed Hqg
zero-angular predicate and guarded checkpoint definition without changing them.
Bind their accepted result, receipt, source and shared physical conventions.
Rebuild the first diagonal Hgg pair with the original contraction code and
compare all spin coefficients of its first two photon projections against
the accepted complete pair. Only coefficients proved zero by the inherited
angular moments may replace accepted coefficients; nonzero reductions remain
unchanged. Require complete input and output reconstruction, a nontrivial
zero shortcut, a nonzero fallback, an empty isolated scalar cache, and exact
result reload. Save representative actual restored equations and per-component
timings in `s05_zero_angular_result/`. This comparison alone does not change
production or establish a complete-channel speedup.

The comparison passed job `14813597` on `n6048` in 147.546084 seconds,
with peak child RSS 994,783,232 bytes. Both complete 25-component photon
projections matched. Nontrivial shortcuts were components 3,8,11,12 of
projection (1,1), and 3,4,8,9,11,12,16,17 of (1,2); their predicates took
0.033208–0.048096 seconds. Trace times were 40.689506 and 26.501555 seconds.
The verified result SHA256 is
`793290082b835554b6bf252955675ca123624aff0c1c5f484845704addede607`,
checks `2871a2c0ec54aba172d09693640ee8e87348e4fb8052c2ca2112cce6fd3e1e8b`,
receipt `85e0353a16dc55cc56d21e7cb3cb3176f3a17d3feedcc7ac8401524cf5db3e51`,
and source `a4db8cbfea5d17a2ca682d99e36f4eea8778037c93fb943de16ea4d9549ef0a1`.
All three result files are verified locally.

`common/s05_real_spin_response_Hgg_zero_angular.wls` may load this exact own
proof after the original complete-sector Ward definition check. Require all
input/native/source identities and unchanged scalar equations, then install
only its executed guarded coefficient routine and distribute its angular-zero
predicate to workers. Keep original nonzero reductions, compact storage,
physical projection and Ward gates, cache identities and result schema.
Test the actual final provenance expression before contractions. A prior
production writer must be quiescent before continuation writes begin.

Interface job `14813612` rejected the first adapter before any physics
contraction because its terminal call also appeared inside a quoted dispatch
boundary. The corrected adapter selects the final occurrence and validates
the complete retained bootstrap. The rejected source is retained as
`common/s05_result/reference/s05_Hgg_zero_angular_before_terminal_selection.wls`
(SHA256 `32996744f8b745f2ddbded7a6090c6b1a02277c142790ff089aa32928ff0d55c`).
The accepted angular comparison and production checkpoints are unchanged.

Interface job `14813620` passed the corrected production bootstrap, proof
bindings, publication expression and complete S12 adapter syntax. Its isolated
sector probe omitted the enclosing loop's `label` binding and was rejected
at the amplitude-inventory gate. The probe must set the single inherited
sector before evaluating that block; this correction changes only the test
configuration, not the production equations or accepted comparison.

The complete scoped production interface passed job `14813628` on `n6132`
in 85.226667 seconds, with peak child RSS 991,588,352 bytes. It executed
the original sector inventory and Ward-definition gates, installed the exact
own shortcut, checked worker distribution and evaluated the actual publication
expression. Accepted production source SHA256 is
`4934c38481b95443fb63f924e8ede4f57ebf27e81220c6c220afd06d58fa0c8d`.
Verified interface checks SHA256:
`cab26227576552deab545e2830bbdf811f252aa6f34b7b5f6f47a75f867a7b47`;
receipt SHA256:
`e46de7a0896c22f4f03be3727ed1c32cf47b6f5e74996bd7b785e6dd7a0797f1`.
The same run verified the complete syntax of the S12 reference-series adapter
at SHA256 `54e0f95f98b4e733923e9526b4cdf1f7311bbaf92c69398c7c593e38035020c7`;
its own actual-input mathematical comparison remains a required startup gate.


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

### S05 early transverse-power comparison contract

`common/s05_check_scalar_power_reduction.wls` reads the complete nonzero restored scalar equation retained by the accepted own angular comparison. It tests native polynomial division of its explicit transverse powers before the original common-denominator reduction. The program derives all remainders from the existing transverse constraint and requires exact monomial reconstruction and division identities. Inputs outside this polynomial support retain the original reducer.

Acceptance requires equality to the complete original pre-average scalar value and the corresponding coefficient in the accepted own diagonal photon projection after the unchanged angular average. Source, saved equation, parent proof, control pair and runtime identities are bound in `s05_scalar_power_result/s05_result.wl`. This comparison does not replace the running production algorithm; a production change requires accepted comparison and timing evidence.

### Accepted S05 early-power scalar comparison and consumer

Job `14814411` passed the complete original scalar comparison and the own accepted projected-coefficient comparison. On the retained 749256-byte nonzero input, the original reduction took 31.617151 seconds and the candidate took 2.648179 seconds. These are individual coefficient timings, not an overall stage speedup. The program measured transverse-power support `{0, 2, 4}` and derived its remainders from the accepted constraint.

- `Hgg/s05_scalar_power_result/s05_checks.json`: SHA-256 `798644c056656f7a52ee9d040cdcaf9fe2c812b5c078768754c10a661f7da0bf`.
- `Hgg/s05_scalar_power_result/s05_result.wl`: SHA-256 `3c27577855c7bc19bf8a50c5a8dad38b73cadb5a061a86c8a0a3fa834edc2019`.

`common/s05_real_spin_response_Hgg_early_power.wls` installs the exact saved candidate only at the guarded nonzero scalar checkpoint call. It binds the accepted proof, input hashes, original reducer, native versions and parent angular proof; requires reversible replacement of that one call; and distributes the candidate to the existing workers. The zero-angular shortcut, pre-average cache semantics, original nonpolynomial fallback, final angular reduction and complete pair/tensor assembly remain inherited. S05 validation and later pole cancellation still gate final acceptance.

### S05 compact worker-transfer contract

`common/s05_real_spin_response_Hgg_packed_pairs.wls` may retain the completed
pair entries as native compressed strings while independent pairs are running.
The existing full pair files, equations, checks and cache keys remain unchanged.
Before dispatch, require exact encode/decode equality of a hash-bound accepted
own complete pair. Require the same complete-record equality for every returned
pair. Before calling the original sum worker, restore only that task's entry
list and verify its exact native encoding. Preserve the original sum function,
task keys, coefficient values, input hashes and order.

The source must replace only the pair/sum dispatch calls and add the lossless
transport functions and comparison metadata. Reversing these replacements must
recover the complete accepted production source. Record the own comparison,
native byte counts, timing and source identity in the final S05 result; retain
all existing reconstruction, Ward, unpolarized-reference and export gates.
No memory reduction is accepted merely from this contract: the compute run
must execute the own complete-pair comparison before production dispatch.

The complete own comparison passed as Hoffman2 job `14814614` in 116.898318
seconds. The hash-bound `Real_1_1.wl` record occupied 91,030,424 native bytes;
its transfer representation occupied 2,723,520 bytes. Packing took 8.963146
seconds and the complete comparison took 22.191801 seconds. Every original
record field was recovered exactly, and the restored sum packet matched the
packet containing the accepted original photon entry. These measurements
describe the control record, not a measured full-stage memory reduction.

| File under `s05_pair_transport_result/` | SHA-256 |
| --- | --- |
| `s05_result.wl` | `c7ff447c4eb82f8078f5f0e21417c2718641314690c1d8da396c0f21c3b17c85` |
| `s05_checks.json` | `c13a1565f8b6afe1ab827348eb3c253a882d15adfa23d0cb522178c365dd6fa4` |
| `s05_execution.json` | `325268265d07d8451a040307d3f0ec659b61a3c8546846d309efe01222a96fb4` |

The source uses `POLARIZED_SIDIS_PACKED_TRANSPORT_VALIDATE_ONLY=1` for the
comparison and requires the accepted proof and receipt in production. Bind
`POLARIZED_SIDIS_PACKED_PAIR_CONTROL_SHA256` to
`e2c22f5dd25724e3c96e85334141b75dcb7e86baa58db10d7e2213313def78dd`.
The control is
`cache/s05_sector_ward/Hgg/d1394d7246f4688fcd675a6f772afc08a0cb265b82e0acbda7ccf061c16831c0/Real_1_1.wl`.
Full canonical pair files and mathematical checkpoint keys remain unchanged;
only in-memory transfer entries carry the native compressed value and its hash.

### Exact native input for the bounded Hgg projection

common/s05_prepare_Hgg_trace_inputs.wls reuses the complete accepted S05
initialization, generated amplitude inventory, spin closures and photon
projection. It saves the first diagonal control and the actual memory-bound
projection {6,6},1,3 as native expressions under s05_trace_input_result/.
Require valid generated indices, closed spin sums, original source/input and
runtime identities, bounded files and exact native reload. This stage does
not evaluate traces, change the production contraction, or accept new tensor
components. Read these actual expressions before changing their evaluation.

### S05 component contraction contract

`common/s05_check_Hgg_spin_components.wls` reads the exact equations saved by
job 14815515. It requires all spin variables to occur outside the native
traces and reconstructs the entire original polynomial from the accepted
spin extractor. Evaluate each coefficient with the already accepted native
precontraction routine, own zero-angular predicate and own early-power scalar
reduction. Preserve every scalar and angular definition and native convention.

Before using the candidate, compare every spin coefficient of the complete
accepted own diagonal control projection. Then evaluate the saved projection
{6,6},1,3 within the original operation bound. Isolated, input- and algorithm-bound
component checkpoints retain reusable work; exact native reload and the existing
file limit gate the comparison result in `s05_spin_components_result/`.
This contract does not accept a production change or finite F hats. Production
use requires the executed own-output comparison and its bound result and receipt.

Completed projections in the accepted complete-sector Ward cache use the same
lossless archive contract under `s05_sector_projection_archive_result/`.
Keep the parent pair records and every configuration-pinned projection intact.
The manifest records original paths, member hashes and parent hashes; verify
all members before raw projection removal and collect bounded archive parts
locally. Incomplete pairs are never selected.

Archive job 14815807 passed all member and parent checks, preserving 33 pair
records. Manifest SHA256 is
`5837c33cdcf57b8d2bafcc6fb067e5b0fd90978c11e6fc91c2088ebc1859a2fa`;
receipt SHA256 is
`97067a27c5e297792d095b85a00513bd85f726ae1c49d4a5f71bb8fc4d794d62`.
The four parts are verified locally under `s05_sector_projection_archive_result/`.
Their duplicate cluster copies were removed after hash verification, freeing
218492020 bytes. Restore a needed projection from the manifest-named local
part and require its recorded member hash; the live pair records remain on
the cluster. This archive does not accept additional physics results.

### S05 component-routine production contract

`common/s05_real_spin_response_Hgg_components.wls` reuses the complete packed
pair entry and installs the exact accepted component routine only at its
trace/scalar call. Require the component proof's successful receipt, complete
own control comparison, source, input, native-version, parent-proof and
scalar-definition identities. Recompute its algorithm binding and preserve
its isolated component checkpoints. Each new input must reconstruct exactly
from its spin coefficients. Keep the existing canonical pair and projection
cache identities, worker allocation, scalar methods, packed transport, Ward,
spin-reconstruction, reference and export gates. The production result records
the proof and dispatch hashes. Do not submit this entry before the focused
comparison is accepted and the preceding canonical writer is quiescent.

For an equation retained only in a compressed scalar checkpoint,
`common/s05_export_native_equation.wls` performs a native format conversion
on the compute node. Bind the exact source checkpoint path and SHA256;
retain its complete record and verify native round-trip equality in the
readable `s05_angular_equation_result/s05_result.wl`. This reader does not
alter the checkpoint or evaluate a new contraction.

The readable native export from job `14816264` is
`s05_angular_equation_result/s05_result.wl`, SHA256
`a7f53a922b9cd37edf11bd4522439e6cd56b13a7e5b26c0e9d2cb336310bb676`.
Its exact-reload receipt has SHA256
`8fd88e70f13c3443e99faa270b0c227239a563de26e96246cdf2798fa0fec227`.

### S05 angular normal-form component comparison contract

`common/s05_check_Hgg_components_angular.wls` reuses the complete component
comparison. At the angular routine's two algebraic-reduction calls, certify
the actual transverse polynomial by selective expansion, exact monomial
reconstruction and native division of its monomials by the inherited
constraint. Reuse the expression only when each quotient is zero and each
remainder is the original monomial; otherwise retain the original reducer.
Preserve the angular moments, denominator checks and numerator reconstruction.
First compare the complete accepted own scalar angular result, then evaluate
the readable checkpoint and the original full control and target projections.
Bind all source/input identities and saved definitions. Scalar checkpoints
may be reused from the preceding component calculation only with the same
scalar algorithm and argument hashes. The angular algorithm has its own
component-cache identity. Production requires this complete comparison,
native reload and successful receipt; no speedup is assumed in advance.

The component production entry consumes this angular comparison from
`s05_components_angular_result/`. Install its recorded angular definitions
only after the original-definition equality check; include the normal-form
routine in the algorithm hash and worker definitions. Preserve the original
fallback and per-input reconstruction checks. The successful comparison
receipt, exact own control and target equations, and the same native runtime
must be bound before production submission. Existing canonical completed
pair and projection records retain their original mathematical identities.

The complete angular/component comparison passed Hoffman2 job `14816479`
on `n7441` in 361.54923476744443 seconds. All 25 coefficients of the accepted
control matched, and the complete saved target projection was evaluated.
Native export/reload and source, input, scalar-cache and runtime checks passed.
This accepts the algorithm for S05 continuation, not a final F hat.

Accepted files under `s05_components_angular_result/`:

- `s05_result.wl`: `81cdf407d27ca5490d99f3bec5431e869e2ae587dc92f6a1d1b769211e1d166d`.
- `s05_checks.json`: `6e41426e2ea42151d7440fca237e00eb78d1f010941b79b1162bfc41f6d7f7be`.
- `s05_execution.json`: `f4d97f10401a06c222e0a6164c63d5310f30b94943c26a25ef01328372f30e5f`.

Checker `common/s05_check_Hgg_components_angular.wls` has SHA256
`0077f3229b9fd92a4380417b51f167c0c828b16cefa6ff97947330d0f517317c`.
The original component comparison's checkpoints remain preserved; its
unfinished output is not an accepted production dependency.

The unchanged completed-parent projection archive may run again under
s05_sector_projection_archive_continuation_result/ for newly completed
pairs. Preserve configuration-bound projections and all parent pair records;
verify every archive member and its unchanged parent before removing a raw
projection. Keep bounded parts locally after verified collection.

The continuation archive passed job 14816917 in31.333014149218798 seconds.
It preserved35 completed parent pairs and archived22,111,172 raw bytes.
All parts were collected with local SHA256 verification; duplicate remote
archive data was removed after a second exact size/hash comparison.
Accepted identities under s05_sector_projection_archive_continuation_result/:

- Manifest: 90c192081d88500aa9e9c1523b0c94beea1899bc8845cedddeec71e014a48651.
- Part01 (17,016,212 bytes): 46bb1bb07300576c5924b385df38a17c8d9c9a0ae5992c87f6da956761baab64.
- Receipt: 3d72986e4774f3c1829b2c5902f3f903c867be276e86b34ddfdf640ef8826bf1.

Restore original member paths and verify member hashes from the manifest
before any future consumer requests an archived projection. This storage
operation does not accept the incomplete channel tensor or a finite hat.


After every pair was completed, job 14816570 exceeded its 22 GiB combined
RSS guard during simultaneous photon sums. Its completed pair and sum
checkpoints remain valid; no complete S05 tensor was accepted. The actual
Photon_1_1 input list measured 1,555,618,360 native bytes. The existing serial
dispatch runs the identical packedPairTask and packedSumTask functions and
retains their exact transport, binding, reconstruction and final gates.
Resume with one 24 GiB slot and the unchanged 22 GiB process/tree guards,
4 GiB operation limit, input hashes and cache identities. This supersedes
the earlier four-slot continuation setting for the completed-pair assembly.
Only concurrency changes; no algebraic optimization or timing gain is claimed.


The unchanged completed-parent projection archive contract also applies to
remaining unpinned projections in the original cache namespace. Preserve
every parent and all configured projection inputs. Record the final archive
under `s05_original_projection_archive_final_result/`, with member hashes,
parent hashes, exact restore paths, verified bounded parts and its receipt.
This storage-only continuation changes no equations or cache identities.

Archive job14817050 passed all member/parent gates in42.032403885s. It
preserved16 completed parents and archived99,373,799 raw bytes. All parts,
manifest and receipt are hash-verified locally; duplicate remote archive
parts were removed only after exact local/remote comparison. Identities:
- s05_cache_manifest.json: f36d49154d6d79dd964c4431c4338a0a9a93a02061c3d31140737f3018feea13.
- s05_cache_part01.tar.gz: 84c53b898eecf8247febffc220bd23c8f42e827f2d18ba0f401a894ecbddcbd1.
- s05_cache_part02.tar.gz: 4686c3c90cb39a6302d468ca86ab53c558e89ea6bb154ada9f825d2a3194e447.
- s05_execution.json: 8aeb6ec59e29b4bd951f9d9bed7c15ae761dd5974d00fd112c25be197160cda6.

Completed compact pair files listed in the accepted pair-storage manifest
may be retained locally under s05_pair_storage_result/s05_compact_sources/
when the corresponding completed sector pair exists. Before removing a
remote duplicate, require exact local/source/manifest bytes and hashes,
36 completed sector parents, and exclusion from every explicit input pin.
Preserve all sector parents and original-source archives. To restore a
retired compact checkpoint, copy the matching basename back to the manifest
file path and verify its recorded compact SHA256. No native value changes.

Exact local compact copies retained; remote duplicate bytes removed: 157151070.
- s05_compact_sources/Real_3_4.wl: 3e9c98afa74e7760bebe1891257d7e823a8b36035e115367d725f3fb98dc0ea3.
- s05_compact_sources/Real_1_4.wl: 06a302687f73045e9fa18c5ae91372804760b75b11899b144acaa5a7f3763a1c.
- s05_compact_sources/Real_2_4.wl: 79f79046bed6b008e3809fb398d7f349210b0983f5f922ffef162c1d11673342.
- s05_compact_sources/Real_1_5.wl: f22d55dac6817e6ce83bb6e865cba85b537a78ccbe4c719e892adf57dcb75517.
- s05_compact_sources/Real_2_5.wl: eb95ca7e773ba3e093dbaae1f4d87050f29f1e828ffc44ffe8ac57c011576dc9.
- s05_compact_sources/Real_1_7.wl: 24ac3444626a6d31662adc60b5651ad822dd96a3256cbc0e847add1cbf305e02.
- s05_compact_sources/Real_2_3.wl: be1269b71aceb92f43b073cb2a07ed17981a056dd9060f36fdae0a7698974f50.
- s05_compact_sources/Real_1_8.wl: ffdfdcb7fb7f7e072c97dbfa40f05b2cc3bedbc2013c2fc33d680ca1dda4f539.
- s05_compact_sources/Real_2_7.wl: 3d61f7ba8a7ceaba6a9b1775a1084ad3e38b09fdc5d436d25aecb5af6f73f9c0.
- s05_compact_sources/Real_2_8.wl: da2278b611a9d2d78d39acf06bf8a4950128023fd16387bd68566ce4a19345c9.


### Completed-pair assembly contract

`common/s05_assemble_Hgg_completed_pairs.wls` consumes the complete pinned
pair inventory in `common/s05_Hgg_completed_pair_inputs.json`. It invokes
the original accepted pair reader once per pair, adds the unchanged matrix
and scalar entries, releases each full pair, and calls native `Share[]` to
avoid retaining duplicate expression storage. It does not rerun contractions
or repeat packed-pair serialization. All pair input, Ward-proof, dimensional,
charge and projection identities remain required.

Before downstream tensor checks, the assembled first photon entry must
reproduce the entire saved native `Photon_1_1` sum exactly, including its
original full-input hash and a comparison with the original linear sum.
Record per-pair memory and elapsed time. No speedup or memory improvement
is accepted before that run. Save input- and source-bound component sums
with exact native reload, and retain complete pair metadata for resumption.
The sum comparison is an assembly checkpoint, not a finite F hat.

The replacement must reverse exactly to the original production assembly
outside the replaced pair/sum block and its provenance field. Photon
Hermiticity, Ward identities, spin and photon reconstruction, original
unpolarized projections and complete native export remain unchanged.
The entry point retains the original scientific schema and source identity
and adds its dispatch/assembly evidence separately. Its downstream S08
reader consumes the same tensor fields. Retain one 24 GiB slot, 22 GiB
process/tree guards, 4 GiB operation limit and the 4 GiB shared scratch
limit; locally retained completed-channel duplicate outputs may be removed
remotely only after exact hash and consumer checks.


Completed shared-assembly sum files may be retained locally at their original
relative cache paths once the native log has advanced to the next sum, or
the complete assembly evidence has been atomically published. Verify exact
size and SHA256 before removing a remote duplicate. Record original paths,
source/job identity and hashes in
`s05_completed_assembly_result/s05_cache_manifest.json`. The running tensor
checks use the in-memory sums. Before any later S05 resume, restore every
locally retained file to its exact manifest path and verify its hash; a
missing remote cache is not mathematical invalidation. This permits bounded
scratch use while retaining reproducibility and completed work.


### Bounded component-sum recovery contract

The previous completed-pair assembler retained all matrix/scalar sums and
exhausted native memory in job14817772 before finishing. All36 accepted
parent pairs remain valid. `common/s05_assemble_Hgg_component_sum.wls`
reuses the original generated sector setup, pair reader and executed
linearComponentSum definition. Each invocation reads the same pinned pair
inventory, retains only one requested projection from each pair, and saves
one complete native sum under `s05_component_sums_result/<key>/`. It omits
repeated whole-session Share scans, which released essentially no bytes in
the failed run. This does not repeat any contraction or change any equation.

The original Photon_1_1 complete sum is reused by its pinned file hash,
InputHash, native Key, original SumInputHash and accepted checks. Its native
export/reload must compare exactly. This is reuse of accepted work, not a
fresh algebraic comparison or recomputation. Other keys may run only after
this reuse receipt passes with matching source, manifest, physical inputs
and native versions. Bind new sums to the exact parent file inventory in
ParentSumInputHash; preserve the prior full-expression binding separately
as OriginalSumInputHash for the reused control. Do not hash the multi-GB
symbolic input list: job14818924 exhausted its operation limit at that
redundant hash after reading all36 accepted parents. The original executed
linearComponentSum definition and every pinned parent remain unchanged.
Derive the complete key inventory from the generated photon dimensions and
actual saved scalar fields. Retain original Ward-sum treatment, exact native
reload, all parent identities, measured memory/time and bounded file sizes.
A component-sum result is not an accepted complete S05 tensor or a finite
F hat. The remaining Hermiticity, photon/spin reconstruction, CDR reference
and native export gates remain mandatory for the eventual final assembly.

### Projection of bounded sums

`common/s05_project_Hgg_component_sum.wls` uses the same generated sector
setup and accepted `compactSpinResponse` definition. It derives the required
matrix-entry support from the actual saved `PhotonDual`, reads only those
accepted component sums, and saves one complete outgoing/incoming response.
It checks each contributing entry against its transposed native conjugate.
The full photon-basis inverse is derived and checked using an arbitrary
symbolic matrix before substituting any saved entries.

The structural spin reconstruction implementation is reused from the
accepted Hqq comparison as an algorithm, not as evidence for Hgg. Before
using it on an assembled sum, compare its result with the original native
reconstruction predicate on the corresponding complete photon response of
Hgg's first accepted diagonal pair. Require exact response restoration and
spin-polynomial reconstruction on the actual full sum. Record source,
parent sum, basis and physical-input hashes, runtime, and memory. Each
projected response is an intermediate; complete Ward/CDR-reference checks,
S05 export, integration and finite assembly remain required.

### Retention of completed scalar caches

After all native pair records in s05_Hgg_completed_pair_inputs.json are
present and hash-verified, the earlier cache/s05_coefficients/Hgg files may
be retained in bounded local archives under s05_coefficient_archive_result.
The bounded sum and projection entries consume the completed pairs and do
not call the scalar contraction routine. Exclude every cache file pinned by
an active job, verify each archived member's size and SHA256, then remove
only identical remote duplicates. Preserve all pair records, scalar-method
proofs, sources, and the archive manifest. Restore exact manifest paths and
hashes before any future scalar-contraction resume.


Scalar coefficient archive accepted: manifest s05_coefficient_archive_result/s05_cache_manifest.json,
SHA256 5d0569c1edc3255bcb2a099e1de33e2e864d25f283ac5ba5f23381256790f1ab. All 4373 members were verified before
removing 241862721 identical remote bytes. Native pair manifest unchanged.

### Bounded S05 export contract

The component export must retain the original scientific schema and field
names. Verify every projected response and complete scalar sum against its
accepted receipt, physical inputs and implementation. Require all matrix
entries to be covered by the Hermiticity checks, every spin reconstruction,
the original Ward values, and both original CDR reference contractions.
Use the native photon-basis inverse to reconstruct matrix entries from the
accepted spin responses when requested; do not retain a second full matrix
during mapping. A hash-verifying native loader may load the large fields on
request. Its metadata and component manifest must identify every required
payload. Compare every loaded response against its actual accepted native
value and verify the dimensional scalar field before accepting the export.
This changes storage, not the spin basis, normalizations or equations.

The parent-binding reuse passed job14819699 on n7404 in276.0255296602845
seconds. All36 parent file identities and the original complete sum were
accepted, and compressed native reload compared exactly. No new summation
or algebraic speedup is claimed. Source SHA256
67f4b5daf66d9ef7a7413eff9d64f61adcec1776a1d2679937355f797dae781f.
Accepted files in s05_component_sums_result/Photon_1_1/:
- s05_result.wl: 07a53696477ea08bf3444bd3a8e90ca3fb74ebca48f05541dfd48434a9a6f20a.
- s05_checks.json: ce55bb63acc26928049c80f4fd08522e4ced10140f578748c2c68b4b208c8af9.
- s05_execution.json: 906b77db03c2bd6a066229501236fae6a0f48e7bf92541679cbb2ab8af9f95f0.
These files are hash-verified locally. The remaining components use the
same source and manifest, with this accepted reuse receipt as prerequisite.


### Component input contract for S08

The S05 exporter derives MappingTaskMetadata and MappingTaskSources with
the original nonzero MapIndexed ordering from each actual accepted native
response, followed by the dimensional metric task. Each source names the
exact payload hash, field and native index. The S08 Hgg adapter replaces
only the eager task inventory with those metadata and delayed native
values, and distributes a one-payload cache separately to each worker.
The original mapping, reconstruction, target reduction, coefficient code,
reference controls, ordering and scientific result schemas are unchanged.
Require exact source restoration after each dispatch-only replacement,
metadata agreement for every loaded payload, and source/hash identity.
The S05 loader must reproduce every accepted response and metric before
this adapter may run. Bind the adapter hash separately from the unchanged
mathematical implementation and retain all payloads in the receipt.

First complete photon projection accepted: job14819865,979.7526573995128
seconds. ResponseBytes1555613208; peak native memory6067057608 bytes.
All original predicate comparisons, full-sum Hermiticity, spin
reconstruction and native reload passed. Accepted files are
s05_projected_components_result/Photon_1/s05_result.wl
(3b5319949f3b54c50ebb4c6ad2ec4deed15dc5e27826473016e26b1156f46a03),
s05_checks.json (2b338ec9a383fba4faf6ccf7879a55de290413c961949036d1fb71abbd0f1b80),
and s05_execution.json (b9dffda41cdd4b5b22ca340adc572f272980bc07bd37d9643cdb7535dab9d994).
These are retained and hash-verified locally. This accepts one component,
not the complete S05 tensor or a finite F hat.


The accepted Photon_1_1 component sum is retained locally at its exact
original result path and hash07a53696477ea08bf3444bd3a8e90ca3fb74ebca48f05541dfd48434a9a6f20a.
After its only consuming projection14819865 passed, the remote duplicate
was removed with active input exclusion. Receipt/checks remain remote.
Restore the local file before rerunning that projection. The abandoned
Real_assembled_Photon_1_1.wl.17925.tmp has no reader or resume role and
was removed; its accepted original control file remains pinned remotely.


### Shared scratch allowance

The4GiB workflow scratch guard interrupted calculations during simultaneous exports. Cluster quota reports1190GiB used against1863GiB hard limit. Replacement allocations use a bounded12GiB shared workflow scratch allowance, unchanged RAM limits and128MiB file bound. Maintain the local3GiB reserve and bounded transfers. This supersedes earlier4GiB scratch contracts. Preserve checkpoints and failed receipts.


### Recovery of a completed native component export

If the shared storage guard interrupts only the export/reload after the
complete original sum was calculated, preserve the failed execution receipt
and complete temporary native file. The recovery entry must require the
original source/configuration binding, parent file inventory, physical
InputHash/InputHashes, native versions, exact linear-sum definition,
generated pair count and every saved check. Read the entire temporary
Uncompress artifact and republish it with the original native writer,
requiring exact reload. Preserve its original scientific SourceHash and
add recovery evidence to the executed report/receipt. A truncated or
incompatible temporary file cannot pass. This recovery accepts only the
component sum; projection and all final gates remain required.


The accepted off-diagonal sums measured3701929928 and3774061808 native
input bytes before summation. A projection consumes both corresponding
entries and retains a response plus its reconstruction. Remaining
projection allocations therefore use one24GiB slot,22GiB process/tree
guards and4GiB bounded operation allowance. The same8da952 projection
source and all acceptance gates remain unchanged; record actual peaks.

The attempted8GiB operation setting was rejected before algebra by the
shared source range check; it was never an accepted execution profile.
Use the supported4GiB operation limit for projections and complete export.

The component input adapter f33a42480fefbc830a0b99bb0d9c957d490ee7dd1a7c278bd26aac221fabf7ce
passed job14820899: all11 actual nonzero Photon1 values reproduced exactly
in a native worker,211.387745 seconds and3715513248 peak bytes.
Accepted s08_component_input_result/s08_result.wl SHA256
1e0e022217b0f67d519f04aaa7f13653aab246720a5df112d3dd13ffee08deba;
checks a7fec7e1db8b0ff07cdcde1e7634e00c241188b381992640b98862eaac5130c9;
receipt58aa8266912b9637f86ba6f31dd978851fba06cb92f189fd9a89a6ddf88e181d.
This accepts the native input interface, not integration or finite hats.

Recovered complete diagonal sums retain their original mathematical source
and all parent identities; original native export/reload passed.
Photon3_3 job14820807,518.337434 seconds: result
6f83989c6ccbfe0e05d974f742c62a1c9ec43e5809e4b9bc7dfe6cd7bf60e108,
checks4db2b87d114dee0d49bfd5aaebbb45f25693d8e80d93edfc2376360ebc5eeaed,
receipt8865088b9114a13fac16ea067cfe9f71d783deff728f9417767309fc59bf638b.
Photon2_2 job14820808,561.036908 seconds: result
a6516294d05d003516c31413291ba16e1f3679b15c00eba6ae986fefae4dee8c,
checksa9799e9eb678834e8594e03b4b975dc0c44a840d17c9555cd9f063739ff73114,
receipt593eef4d7d07305fe8f9eb80b69096c767930c650f6f55c4f8d7c421be899ff5.
All are hash-verified locally under s05_component_sums_result/<key>/.


### Termwise conjugation of complete sums

Photon2 projection14821162 reached its full native Hermiticity test but
exceeded the4GiB operation bound in the original whole-expression support
scan. No accepted sum or response was invalidated.
common/s05_project_Hgg_termwise.wls retains the exact8da952 complete
projection, original scientific SourceHash and every original gate. It
applies the same factoredRealConjugate definition to individual top-level
Plus terms, suppressing only repeated support logging. The program must
reproduce every conjugated entry of its complete own accepted control
PhotonMatrix exactly before using this dispatch on an assembled sum.
All original control, full Hermiticity, photon and spin reconstruction,
CDR extraction and native reload gates remain required. Record the new
ConjugationDispatchHash and own complete comparison timing in each output.
Record actual largest-term/input sizes and elapsed time; do not claim a
speedup before executed evidence. Preserve existing accepted projections
and resume only failed or unfinished components.

Projection3 accepted job14821161 in1240.961210 seconds. Native files
under s05_projected_components_result/Photon_3/ are hash-verified locally:
result9c2213984530aeea0c8edc0fd05389324cf5552697db9cdf27045e417dadc027,
checks0fac1391b8b4d7f26cce35f10f64f553cfaf4b6bab296f5daef3c5072beb24d7,
receipt3afde95e96a0cd2cfef0ec98048169752ff8d979ef2372815bf90ddfa8fbdd8a.
All original native reconstruction, Hermiticity and exact reload checks
passed with unchanged8da952 source. Reuse this projection unchanged.

The conjugation-only dispatch c7d4a35b passed exact own matrix comparison
and full Photon2 Hermiticity in14821507, then failed the4GiB bound in the
original full spin extraction. The saved sum is2650127760 native bytes,
396 top-level terms, largest23328464 bytes.
common/s05_project_Hgg_termwise_spin.wls (65c3ef36f71171068a4f111238d5ec48ab7a49938c70ea5f00c3605e0a71d276)
retains that conjugation and applies the unchanged compactSpinResponse
definition to each top-level term before native Total. Require exact
complete own control response equality, full original structural spin
reconstruction and every existing projection/export gate. Source/input
identities and scientific SourceHash remain unchanged; the dispatch hash
records this implementation. Existing accepted projections remain valid.


### Accepted complete photon sums and dimensional metric

These native results and receipts are retained under
`s05_component_sums_result/<key>/`; all passed original parent-identity,
sum and exact reload gates. They are intermediate inputs to projection
and complete export, not finite coefficients. Photon_1_1 retains the
previously documented local-only result copy; the other rows remain on
the cluster for their consumers.

| Key | Job | Result SHA256 | Receipt SHA256 |
|---|---|---|---|
| Photon_1_1 | 14819699 | 07a53696477ea08bf3444bd3a8e90ca3fb74ebca48f05541dfd48434a9a6f20a | 906b77db03c2bd6a066229501236fae6a0f48e7bf92541679cbb2ab8af9f95f0 |
| Photon_1_2 | 14819871 | 0a9207fe73efc7424299c378c55de6c862ccb9ee150224891fdd172d6e513cca | 195d7c3506dff0477dffda8be94e53954ba347e5c74f37612ea0062af5e9942c |
| Photon_1_3 | 14820804 | fe4e5e7fa23724706320adc29ee3dc474da1b00c454f5e4dc35fc29ab3c121a7 | bc4667987aa93ea9001d83ade64830109cb0fa15daf0c39010ddfe92c6ee8a34 |
| Photon_2_1 | 14819870 | 6caa647319bdcc9684ebe12de16314dfabd7bf9312c4a7d4925c28c6a43eb0c0 | f28b1f86dbbf377da14b083b9f85a73f77ed2bdc8077850b99e6010380d929fa |
| Photon_2_2 | 14820808 | a6516294d05d003516c31413291ba16e1f3679b15c00eba6ae986fefae4dee8c | 593eef4d7d07305fe8f9eb80b69096c767930c650f6f55c4f8d7c421be899ff5 |
| Photon_2_3 | 14820805 | 0312e794fe50cb624dcc2c4111233b5dd1079eb35bde92a9c026662add84c79b | 01c93555c7b9748fec89123c6ed53aa0984ab8eeddb84ee8cec4dc6cb9372171 |
| Photon_3_1 | 14820806 | 5870fbace06f32474f3700c4c45a7ad19138bf6381fd5037dce84e4857f18c84 | 7d0c5c231aa481222a6128650574ebc0c4e533c0db5ee7caa326d7cdd2ad3b9b |
| Photon_3_2 | 14821003 | bde82118ab7637055ccdd0f03c67f162509bbce519e0510629cf611b66671f31 | 6208cccd9fb85c2ae1584309606eae00e71e178b72c3333ce04c273fbdd5e7c3 |
| Photon_3_3 | 14820807 | 6f83989c6ccbfe0e05d974f742c62a1c9ec43e5809e4b9bc7dfe6cd7bf60e108 | 8865088b9114a13fac16ea067cfe9f71d783deff728f9417767309fc59bf638b |
| Scalar_PgD | 14821005 | 4be70bab6bf41a651bb9a9def3d109eb35df6d27104ff7c35261c27ba7948dc3 | 8ea0afb566ff849b94f287b450e2571bb6cbac54540b62bf61ea3523fe797cf3 |

Remaining S12 integration uses the unchanged7bbecbad factored-series
entry with four4GiB shared slots,4GiB per-process and14GiB process-tree
bounds,12GiB scratch. The native implementation already caps workers at
four and gives each task an independent canonical checkpoint. Own
ordinary/endpoint comparisons remain mandatory. This is the existing
Hqq allocation pattern; no new algebra or measured speedup is asserted.


Photon2 complete projection accepted job14821801 in1511.927149 seconds.
The termwise-spin implementation65c3ef36 passed the complete own control
comparison, full-sum Hermiticity, structural spin reconstruction and exact
native reload. Response extraction took353.486548 seconds; native peak
memory was10054330008 bytes. No whole-channel speedup is inferred.
Files under s05_projected_components_result/Photon_2 are retained locally:
s05_result.wl SHA256 d37fb0bf54fcda505cb861fd206f53dfd2fc8b5d169fa81c32984638d2646ec7
s05_checks.json SHA256 adfed1b117ffb8a76db795d7ccf08736772017ae025241293a8ec522b68a1089
s05_execution.json SHA256 3d6a487644f37247e09990a47a0af73eec85ca52d28c9fc0a7c435caa00b2faa
Reuse this accepted response unchanged. Complete S05 and finite gates
remain required.

Independent photon projections may run in four separate allocations concurrently. Each retains the accepted65c3ef36 code, its own output/checkpoint directory,1x24GiB scheduler allocation,22GiB process/tree guard and4GiB operation bound. Shared scratch remains12GiB; no mathematical source or accepted artifact changes.

Both native gluon Ward component sums passed their original coefficient
reconstruction and exact reload gates. These accepted files are retained
locally under s05_component_sums_result/<key> and remain available remotely
for complete S05 export. They are not finite coefficients.

Scalar_GluonWard_p accepted job14821395 in3095.1126899644732 seconds.
s05_result.wl SHA256 80c2e38185df98783e1e78998c51e6f1eb5b7d57dba25a16ccf84928295fc797
s05_checks.json SHA256 507a4ee0c4f1d2a17c82e2b68c9e5f211490846d361f70c81c6d4b6b8f767e3d
s05_execution.json SHA256 dd639da31eb7cf226ba1a67643e4910a627310223c65821a936a5dc5df82e1ab

Scalar_GluonWard_k1 accepted job14821613 in2634.773509460967 seconds.
s05_result.wl SHA256 c2790e5a5904388000eb4b10f56147e20f3bb625bb5f3b0b29425e5dce26b840
s05_checks.json SHA256 cb6f3a1e53d0439a95ceb7ff05c0022b79e5ed4a866267e3ef751a9ac87cd940
s05_execution.json SHA256 157a7d47054418abea255a3dbc6033dba656f7df940b13a4f1f8abb8ae728db3

### Reduced Hermiticity at the complete-projection boundary

The bounded projection8da952 used zeroArray directly on the difference of
independently factored off-diagonal sums. That predicate tests literal zero;
the original shared S05 equation first applies algebraicReduce. Jobs14822531
and14822446 rejected the Photon_1_2 representation at this omitted-reduction
boundary. Restore the original native algebraic reduction before the zero
test, preserving the transverse constraint. Compare against the complete own
original Hermiticity control and record residual/reduced sizes and timing.
Accepted diagonal responses satisfy the stronger original check and remain
valid; no complete off-diagonal response was accepted under the failed check.

For spin extraction, reuse the accepted Hqq structural algorithm with only
its response-return interface changed, as in the reviewed Hqg implementation.
Require exact own original response equality, exact coefficient restoration
and full spin reconstruction. Keep existing sums, native versions, all Ward
and CDR checks, result schema, hashes and memory/storage bounds. The corrected
projection entry must pass these gates before its result is consumed.

Remaining independent S05 projections may occupy up to six separate scheduler
allocations concurrently. Each retains1x24GiB requested memory,22GiB native
process/tree bounds,4GiB bounded operations and the12GiB shared scratch guard.
Use the two-hour request with6900s wrapper bound, adopting existing jobs before
submitting any missing projection. No calculation or artifact identity changes.

### Projection resubmission resource contract

At the user request, the six unexecuted projection submissions were replaced using the accepted14821801 batch pattern:1core24GiB4h. The process/tree limits remain22GiB, operation limit4GiB, shared scratch limit12GiB; wrapper wall becomes14100s. Source817d2afc17c3087eba8bb9ffb153327cf32895031249298c266d3df382fd5b5f and mathematical inputs are unchanged. Old configurations are preserved under .cluster/s05_result. Current bound configurations are:

- .cluster/s05_Hgg_project_Photon_4_reduced_hermiticity_job.json SHA256 de021352a05efa8d3c43f72abda2056bae37a385ecf22f0329cb9efb027ed95a
- .cluster/s05_Hgg_project_Photon_5_reduced_hermiticity_job.json SHA256 7089b757a06e9e7ffb24cf059604dd16c60c44e2bc87db76958bc5a70926d21d
- .cluster/s05_Hgg_project_Photon_6_reduced_hermiticity_job.json SHA256 34af68e18ceff842bb4c49fc967b2f7afbb081bbcd9a4ba8cc3046278c2f3bd9
- .cluster/s05_Hgg_project_Photon_7_reduced_hermiticity_job.json SHA256 6bd000b567ed6966418ab5bd8d12cf4811fe1645304150134daa6a0abf018398
- .cluster/s05_Hgg_project_Photon_8_reduced_hermiticity_job.json SHA256 0ccaed8dcc411c7fd2ef4168cc031843b46a60438717a0a11f30fd343b3f730c
- .cluster/s05_Hgg_project_Photon_9_termwise_spin_job.json SHA256 8f93f72a408f3ccc47d5bb570c9777a7d286486eefa336b4f252de0552b6f399

### Termwise structural extraction contract

Reuse the exact accepted structuralSpinExtraction on each native Plus term, derive and check linearity of the saved incoming/outgoing spin contraction, require exact restoration of the original term list and every term polynomial, and sum responses without retaining one whole-expression coefficient substitution table. Compare to this channel's complete accepted diagonal-pair response using the original extractor before production. Retain full photon Hermiticity, original scientific hashes, exact serialization and all downstream gates. Keep per-term4GiB operation bounds and22GiB process/tree bounds; full-operation memory/speed improvement remains unaccepted until measured. Preserve accepted projections and recover only failed ones.

Additional accepted photon projections:5 job14822891, result45dd242066516e24674c98dff4a4ebd8b58203b4b8f4f289bf7d9ce64a177c93, checksb71c6de6a607afad4af60494496c4009bd81b5097c805cf44434811aa0957523, receipt4e6699d5b32a3529700d7c0cf15d6bbbf60b0ed753463d8271778019f093fc07;8 job14822894, resultb7aaffbb43d97fc09e6a97806672ac73f95c3b53be7bd306f9a8d4dee887fec2, checksccdbcc5cd5cbe52de2e6b35f60d29c3ba5f6fd912221c44da1e3a554883c97b0, receipt9eb7edc39314aee3f730cf91433b7f2d9c36d605827dbd13e98e93bf073a53c8. Exact full Hermiticity, own control, entire spin reconstruction and compressed native reload passed. Files under Hgg/s05_projected_components_result/Photon_5 and Photon_8 are locally verified.

The first streamed candidate failed only in constructing symbolic control matrices, before production output. Its Table held a Sequence expression as an iterator. Corrected common/s05_project_Hgg_streamed_terms.wls uses explicit incoming/outgoing lengths and dimension assertions; all remaining streaming equations and downstream contracts are unchanged. Full native acceptance remains required before reuse.

### Entrywise photon projection contract

common/s05_project_Hgg_entrywise_spin.wls extracts each accepted unweighted
matrix entry with the identical termwise structural extractor before applying
the saved PhotonDual weights. Require spin-independent weights, native symbolic
linearity of photon and spin contractions, every exact term reconstruction,
and a complete own accepted weighted-response comparison. CDR substitution
retains the original rules and average; apply it to the same saved entries
before releasing them. Preserve full-entry Hermiticity, scientific identity,
output schema, original controls and native reload. Conjugation retains the
same termwise native operations with separate4GiB term bounds; full reduction
of its residual remains bounded. Overall22GiB process/tree guards remain.
This resolves dispatch of weighted multi-GB sums as single terms; it is not
accepted until executed own and production gates pass. Preserve existing
accepted projections1/2/3/5/8 and recover only unfinished4/6/7/9.
Source SHA256: cf900acf03c03f50f365d844143f7c8107b34d15e80d180c2aa05fb295f7c1b9

Entrywise projection6 accepted job14825254 in1233.591821s with original
Hermiticity, own weighted-control comparison, all1464 term reconstructions
and exact compressed reload. Child peak21950128128bytes; sampled tree peak
20009996288bytes. Sourcecf900acf03c03f50f365d844143f7c8107b34d15e80d180c2aa05fb295f7c1b9;
configuration75ec787390c5fbd95306faeabcb5239fd684e4b0d2f0e014f535ff0d0f26e415.
Under s05_projected_components_result/Photon_6:
s05_result.wl a984b2f7ba3abf51a7ada60804d0b047281983cde9478e1d363f34483b29b821;
s05_checks.json4fea5291fed615cb6d4a169d5dcc8fda711fa7f7b12c78a5c55e74e3bb370a98.
This accepts a complete photon/spin projection; complete S05 export and
S08/S12/S14/S15 remain required before any Hgg finite-hat claim.

Projection6 result111771369bytes, checks and receipt are locally hash-verified;
receiptfc62f9914f5b037599b73c0b1e945237a1c4df49ba3d65c345928d35fc8afe93.
Entrywise projection9 accepted14825259 in1171.928558s; child peak19450093568bytes.
Its complete own/Hermiticity/spin/reload gates passed. Under Photon_9:
result708070a0444338b6dd5e00a6af0c65bccb78d15ed2fc44285fa150929429e97f;
checks6f2909fe86a969d47abd16996172eb6a1b794937855e621e0337c8d5a0e23346.
Both retain sourcecf900acf and the unchanged projection scientific identity.
Complete S05 and downstream finite assembly remain separately gated.

### Piecewise projection storage contract

The projection writer may serialize the actual Response entries, dimensional
CDR coefficient and remaining metadata separately using native Compress.
Retain original key ordering, complete array dimensions and a hash-verifying
Get loader. Use the existing payload manifest schema and bounded payload
files. Require exact complete own accepted control reload before production
and exact full output reload before publication. Preserve every projection,
Hermiticity, structural reconstruction and CDR equation and record storage
source, size, memory and timing evidence. Only unfinished projections may
use this writer; accepted projections remain immutable. No allocation or
full-stage speedup is asserted by this pre-execution contract.

Projection9 result and checks are verified locally with receipt
6ffca42573b41c147340b5f72157482265b29af778355e24f9213fe6112bb0d0.

### CDR contraction from the accepted extended spin response

The entrywise extractor proves the full incoming/outgoing spin polynomial, including dimensional gluon components. The original CDR substitution may therefore be applied to the saved incoming/outgoing basis variables and contracted with that response. Require native derivation from the unchanged original substitution definition, a complete own accepted-control equality to the direct original photon substitution, and exact inherited CDR average. Release the original complete sums before this contraction. Retain the full original Hermiticity, each term reconstruction, response shape and complete piecewise output reload; save source/input/control comparison evidence. This changes the evaluation path only and requires executed acceptance.

### Fresh-kernel piecewise export resume

After a stopped writer completes every native piece round trip and saves its complete hash-verifying temporary reader, resume export in a fresh kernel. Bind the failed execution receipt, native log, original producer and every temporary/payload file; require all original scientific input, basis, source and native identities. Load the complete original reader, compare all metadata, every response entry and the CDR coefficient exactly to the bound native pieces, and require complete key/shape/group coverage. Only then publish the unchanged reader and the standard manifest/checks. This completes full reload without retaining the former contraction heap. Preserve accepted projections and never rerun completed contractions merely to finish storage.

### Complete export resource and weighted-input contract

The complete export must accommodate the measured native projection size in Get operations. Keep its mathematics unchanged and bound native reads separately from algebra. Derive pWeights with the original saved photon basis/frame; retain a CDR coefficient only when its original weight is nonzero, and check exact equality of the original and retained weighted coefficient for every accepted projection. Preserve all final Pg/Ppp comparisons, original generated support, metadata, complete component loader comparisons and unchanged output schema. Resource sizing must use measured fresh-reader memory and keep explicit process/scheduler guards.

Fresh export acceptance uses exact SameQ of all bound native pieces and full metadata/layout coverage. ByteCount and the original writer size record are resource observations, not expression-identity predicates. Preserve both observations in the export report.

S08 resource contract: the unchanged accepted component-input adapter may use a separately bounded16GiB native Get before the existing4GiB mapping operation. Force only the selected deferred input before entering that operation; preserve original coordinate substitution, mapper, checks, ordering, input hashes and cache identities. Record resource adapter hash separately from the unchanged accepted input-adapter hash. Existing accepted complete own reader comparison remains bound; no mapping equation or acceptance gate is removed.

### Accepted fourth photon projection export

Job14826372 completed the exact metadata/all25 response/CDR piece comparisons and native original input/support gates, reusing all contractions from14825606. Source common/s05_resume_Hgg_piecewise_export.wls d7e6b840caa50aad87cfeb6fe89ee79150b73ff61f6bcf5d2419796056d8e91a. Under s05_projected_components_result/Photon_4, result1b26350dc41d79bedf7e9b1fe1fd1079cdc4c209880a615c8188aa5c6e4aad9e, checks6cbfc8a0ee0a642adfdcd4dbb601536773cc216077398b4505c32cc9f3454ff0, manifestba7677b2cff9d416b7257e46d5f116d41cab1855647be59a4d1ddf1395f203cf, receipt376c2d5ab250a46ff9f529860599b2c10627a57abec41774022efb56050fd300. All28 payload files and metadata are hash-verified locally; retain all payloads for Get. Manifest paths permit duplicate separators and should be normalized as relative POSIX paths without permitting parent traversal. Wrapper710.816260s; child peak11278094336bytes. This accepts the projection, not a complete Hgg tensor or finite hats.

### Reuse of accepted grouped cut mapping

Before grouped production, load the exact saved Hgq/Hqg grouping, merge and reconstruction definitions. Require unchanged native mapper definitions, denominator geometry, scalar input identities and native versions. Select a nonzero own accepted photon-response input with native size measurements, produce its original target map with the unchanged mapper, and require full equality of the grouped reconstruction. Preserve native cut support, each group certificate, all target and reduction gates, original scientific identities and accepted control checkpoint. Record the executed own comparison and source bindings before processing remaining targets. The separate bounded native reader remains required.

Grouped input entry point `common/s08_map_Hgg_grouped_inputs.wls` has SHA256 `08db7db98fe1d07b12742428ea2ea2ea544b86fee60668f529e643ef79753de8`. It reuses the exact accepted Hgq algorithm, selects the smallest nonzero response in the first native photon payload, compares the original complete map, and saves `s08_grouped_comparison_result/s08_result.wl` before remaining grouped tasks. Original target source and scientific cache identities remain unchanged; extra dispatch/comparison evidence is recorded in the target result. Acceptance remains conditional on executed native gates.

Parallel mapping resource contract: the existing independent raw-target and master-coefficient workers may use four shared slots with16GiB per slot,24GiB per-process address bound and60GiB aggregate RSS guard. Preserve separate16GiB native reads and4GiB algebra bounds, exact task ordering and distinct cache files. This changes resource allocation only; native own-control and final checks remain mandatory, and no speedup is accepted without measurement.

### Response-only native read comparison contract

For S08 Response tasks only, the accepted piecewise projection loader may omit evaluating CDRPhotonCoefficient, which the task reader does not consume. Preserve the complete native payload existence/hash checks, metadata, all response entries and original reconstruction. The candidate must be an exact reversible replacement of the sole CDR read assignment in the actual pinned loader; all other native files use unchanged Get. Require a Hoffman2 comparison of every returned field except the intentionally omitted CDR field against the complete own accepted Photon4 record, including its entire Response, with source/receipt/payload binding and measured read times and memory. Install only the accepted definitions; retain original dimensional metric reads, component inventory checks, mapping source and all final gates. This is an input-I/O optimization, not a change to equations.

### Accepted final photon projection native export

Projection7 was accepted by fresh-reader job14827058 using unchanged source common/s05_resume_Hgg_piecewise_export.wls d7e6b840caa50aad87cfeb6fe89ee79150b73ff61f6bcf5d2419796056d8e91a. All27 full-loader/piece equalities, original projection conventions, support and metadata checks passed. Original contractions and payloads were reused; no physics expression was regenerated.

Hash-verified local artifacts under s05_projected_components_result/Photon_7: s05_result.wl38e033fe3d0310253df474336801f3b7393a2089e48961d9cf19fa17f9d8ada4; s05_checks.jsonf5c489ab5ba66a2ab46287dae6b586bce0ddc7e5655906d2b2ed5efcac96cd2f; s05_payload_manifest.json7146c839bbf835c2cab2602402281c6f2e878237322ecc8bf36aa4b848cddebf; s05_execution.json676fcc3715c74aecc3854f6b9caf82b02d60955d5625b5b4d93f379c6b32716c. All28 manifest payloads are local and hash verified. Wrapper1686.010538s; child peak11278446592bytes. Together with projections1–6 and8–9, this completes the accepted projection input set. Complete S05 export still requires its full CDR/UU and loader checks, followed by S08/S12/S14/S15.

Pending consumer common/s08_map_Hgg_response_inputs.wls SHA256ab968190a07201bb4cdcfec547580210950ace960d71201d3d6d63961c199d20 may install only the accepted response-read definitions after receipt, native-version, source and own-input hash checks. It changes the sole native Get in hggTaskValue reversibly, falls back to ordinary Get for non-piecewise files, retains the entire original component inventory check, and records ComponentResponseReadComparison in target/master outputs. Original mapping equations, target order and checkpoint identities remain unchanged. Acceptance requires the own comparison above; no production adoption is established by writing the source.

Native path correction: comparison14827484 established that $InputFileName is a special Wolfram symbol that cannot be rebound with Block. The corrected comparison source 31ea98f6d2732ec4b364e18caf54244f8f592384fed7a6df914ede65c781557e derives DirectoryName[path], substitutes its quoted native literal into the sole DirectoryName[$InputFileName] occurrence, and requires full reverse restoration of both that substitution and the omitted CDR assignment. This preserves the original payload checks without a special-symbol assignment. The corrected comparison must pass before this reader is accepted; no physics output was invalidated.


### Accepted response-only native input read (job14828218)
The complete Photon4 comparison passed every retained-field exact equality and native reload gate. Original read534.066554seconds; response-only read423.027802seconds on the same node n7644. Retained expression7480156232bytes. This measurement applies to the read, not a claimed full-stage speedup.
Accepted comparison source common/s08_check_Hgg_response_read.wls SHA256 e9a066e9e47ed9e82c06a95bc39479e177b1c60a66db4edf6e8d074d50b33170.
Result Hgg/s08_response_read_result/s08_result.wl SHA25626833dd3d7306c70dde337fc1356f9a341b0da494264aa1e55ebb0cc1e318abb; checks d9cddf54178821b28faa86f55e71d1501ff465fe2f34f21971578334cd750916; execution61b8d91e6216b0e5f22d4f92a1f45a929165c7375aa9c6ad5faeaa604d7a3fd7; configuration801c6464a0b2439880ccd0c458e094b3159675ce069dba421b58e7fc4d5fc10f. All are verified locally.
The accepted source releases the duplicate after exact equality and avoids redundant multi-GB expression hashes; this corrects report-memory failure14827757. Input, producer, receipt, manifest and source hashes remain bound.
The original consumer SHA256ab968190a07201bb4cdcfec547580210950ace960d71201d3d6d63961c199d20 is retained as `common/s08_result/reference/s08_map_Hgg_response_inputs_before_20260921_evening_resume.wls`. The executed consumer `common/s08_map_Hgg_response_inputs.wls` is SHA25680e0d148094ce46df049c434453aec556b9be7f5b51481e460ca488967e34016; its only change from that archived source qualifies ``FeynCalc`$FeynCalcVersion`` in the native-version gate. Accepted partition receipts bind this version. Future target and coefficient job configurations must pin the executed source. It installs only the accepted reader and changes only the native Get inside hggTaskValue. All input hash checks, complete response entries, inventory checks, grouping comparison, mapping reconstruction, reduction and finite-assembly gates remain required. The reader skips the unused CDR payload only for the piecewise projection format; ordinary inputs retain Get. No finite Hgg F hat is established by this reader proof.


### Complete-export inactivity contract
The complete export uses native-read bounds of1200seconds and the inherited algebra bound POLARIZED_SIDIS_REAL_SECONDS=10800. Its watchdog inactivity allowance must be10860seconds to permit that existing algebra contract. Configuration s05_Hgg_complete_weighted_export_job.json incorrectly used1260seconds; correction uses the distinct tag s05_Hgg_complete_weighted_export_algebra_bound, identical native source and accepted inputs,32GiB allocation,30GiB per-process/tree guards,4GiB algebra and16GiB native reads. Only a failed execution receipt is retired; accepted projection and component-sum artifacts remain valid. A completed finite Hgg result still requires all original export, integration, pole-cancellation and final-export gates.


### Complete-export checkpoint continuation contract
Execution14828705 reached the wall limit after both full unpolarized CDR reference checks and reader comparisons1–6 passed. Its saved metadata SHA256f858b207d449632d03f284a4706a9998c0cb1ee5b2a2b7064ca027a0e41c20d7 is listed in that execution receipt. A continuation must pin the failed receipt, original reviewed weighted-export source, metadata, temporary reader and log; regenerate the reader from the unchanged original construction and require exact text equality before reusing logged comparison indices. Only a contiguous prefix of original successful reader checks may be reused. All parent artifacts remain hash-bound. Execute every remaining response comparison and the dimensional-metric comparison before publishing the original complete S05 interface and manifest. Record the continuation evidence separately; do not recalculate accepted CDR contractions or mark the old execution as accepted.

### Accepted complete S05 export14834821
All nine exact response-reader comparisons, the dimensional metric, original CDR/unpolarized reference checks and continuation proof reload passed. Complete response inputs are locally hash verified against s05_result/s05_execution.json (751e3e565e5353358bdaf208d3f71c0e2abe6064ba69199123cfbbe0d1ec7c75). Loader e393caa6fa12e05403700794e3c74b929839c70e979fd29ef23d3af4edf5e452; metadata f858b207d449632d03f284a4706a9998c0cb1ee5b2a2b7064ca027a0e41c20d7; component manifest f7ce4d944cc6bd40004257be12d722c53056d632600cdd9f6c6301480da8adc0; checks e4fa86a2ea450aefdeecb90238edb2c92d7399ade3eabb26112ad133f4c584d0. Wrapper2343.130436seconds. Preserve every referenced projection payload beside its loader. S08 mapping and S12/S14/S15 remain mandatory.

Response-adapter initialization contract (corrected after jobs14843822/14843849): retain the original mapper as the sole main-kernel FeynCalc initializer; wrappers defined before initialization must qualify FeynCalc`$FeynCalcVersion in saved-proof comparisons. The earlier extra wrapper load caused a duplicate-load abort and is removed. All accepted proof/artifact identities, task ordering and original mapper remain unchanged. Both target and coefficient consumers use this corrected entry. No new native-input comparison is accepted until execution passes the unchanged checks.

Queue allocation contract: use two shared16GiB slots for the remaining raw map, retaining24GiB process address,30GiB aggregate RSS,16GiB native-read headroom where already configured and4GiB production algebra bounds. This reduces the requested reservation to32GiB. Equations, accepted inputs and canonical checkpoints are unchanged; queue start time is not guaranteed.

### Exact remaining S08 input contract
common/s08_extract_mapping_inputs.wls (433001a7a8a3b334b23326fed3bfbb66810b5b9e4b8bc4376099a8521150e74d) reuses the unchanged accepted channel initialization and native task inventory, stopping before mapping workers. It saves source/input/runtime-bound complete coordinate expressions and original mapping/family/grouping definitions, with exact native Compress/Get equality and bounded readable equation renderings. Hqg exports its existing own control and tasks without canonical checkpoints; Hgg exports the actual timed-out control8 from execution14844895. These are input artifacts only, under s08_mapping_inputs_result, and do not accept any new map or finite coefficient. Future optimizations must preserve every complete reconstruction/cut check and pass comparison against an accepted own output. Existing mathematical checkpoints are unchanged.


Input-export recovery contract: s08_extract_mapping_inputs.wls recovery mode consumes the retained failed native record, requires unchanged held equation, native/source/scientific input identities and fresh exact geometry, then republishes only after full stable Compress/Get equality. Normal extraction compares every nongeometry field structurally, geometry with the already accepted exact recursive comparison, and requires a stable final native record. This corrects serialization only; no mapping or finite hat is accepted by recovery.


Accepted native input recovery 14873388: original equation is structurally unchanged; all original scientific input identities, fresh full geometry and stable full-record Compress/Get equality passed. Source preserved at common/s08_result/reference/s08_extract_mapping_inputs_accepted_recovery.wls SHA256 027cc09db70fb0adcd79faee123cc33473906c3816fa9e17dbb3dae6ae83c6d8. Result identities: {"Hgg/s08_mapping_inputs_result/s08_component_0008.wl": "23bac881805e9ea0da7b96af42e16ec67e94e43c22363bfc9c9b1bf89e03e30e", "Hgg/s08_mapping_inputs_result/s08_component_0008_equation.wl": "60a656837d56b5022c0f62c8fe0a2cd3d185f4590cd7e74eaae894fc8b7e66d3", "Hgg/s08_mapping_inputs_result/s08_recovery_checks.json": "fe7af7ddc0b231c47bc765e642c6d60f9e205841da4c134dcc6fd67ef3fb1034"}. Native computation used 55.60439364193007 seconds; this accepts input serialization only.


Termwise mapping contract: common/s08_map_saved_terms.wls consumes only receipt-bound native mapping inputs and installs the accepted Hqg polynomial family definitions with unchanged original propagator/cut mapping. Retain original outer rational terms instead of first combining them into denominator groups. Require exact full additive input identity, every original per-piece family/cut reconstruction, the accepted exact coefficient merge certificate, and complete own Hqg control-map equality. For the first Hgg control, compute both original and polynomial family mappings of every original piece and compare every coefficient before accepting the complete linear merge. This is an own full termwise comparison, explicitly not a completed monolithic original-map run. Independent piece caches are source/input/expression-bound. No production adoption or finite hats until the relevant executed gates pass.


Grouped polynomial production from the original-term control: common/s08_map_Hgg_polynomial_inputs.wls may replace the timed-out monolithic original-control call with the receipt-bound, full original-term comparison result. Bind the native control equation, full own task identity, scientific inputs, mapper and comparison sources, and native versions. Reuse the accepted Hqg polynomial family and additive-piece definitions with unchanged Hgg reader, grouping, merge, cut and target contracts. Before production require complete own grouped-map equality against that original-term control. The candidate may extract an exact numeric outer factor, preserving native input identity and every coefficient on restoration. Use a separate phase-core group cache and record the comparison provenance explicitly; no claim of a completed monolithic original map. Original source files and accepted mathematical outputs remain unchanged.


Outer-phase correction: native inspection14874222 established that Hqg component28 is an outer Plus, and direct equation reading at line44262 identifies its second phase-wrapped sum. The initial candidate14874210 incorrectly required the entire expression to be a numeric product and stopped before publishing any map. Corrected helper handles phase-wrapped children of an outer sum, preserves each original term identity, and uses the already accepted full coefficient-merge certificate. Hqg supports saved-input-only control validation before its full production reader. Corrected shared helper source SHA256 1c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9. Production acceptance still requires complete native own-output checks.


Accepted numeric-phase own control14874243: exact actual input inventory is two phase-wrapped sums of60 terms each. Complete own phase-scaled grouped-map equality, every inherited group/family/cut/merge gate and exact native export passed. Mapping control46.443264seconds; full validation149.86842049658298seconds, child peak495828992bytes. Source common/s08_resume_Hqg_polynomial_maps.wls SHA2561c146bef316cc9dc3b02aff9a19bc500b599443674ac30246a43625108ac4ba9. Hqg/s08_numeric_phase_control_result/s08_result.wl SHA25613466dcb9273f5d26936e3a1b0b44247ae165a1c0c7e09e31ebecc0cc8865b5d; checks45d87ac80d8eee978285d265cf0d2e3e272ea771da3c27d5782860d3ec710873; receipt47af96264f588639dd56c02a9569bd8e25d25145480004508064eb000f1d1c9f. This accepts the helper/control interface, not any new complete component or finite hat.


Independent own original-term comparison: common/s08_map_Hgg_original_terms.wls preserves the complete pinned s08_map_saved_terms.wls implementation, changing only its entry-source identity and removing the unrelated Hqg full-component prerequisite. Hgg still computes the original and polynomial map of every original term, compares every coefficient exactly, and accepts only after complete additive, linear-merge, physical-cut and native-export gates. Its own result is sufficient for the subsequent full Hgg grouped comparison. The incomplete Hqg experiment14873515 supplies no acceptance to this Hgg calculation.


### Accepted own original-term map, job 14874266
All 36 original term maps agree coefficient by coefficient with the original
mapper. The complete linear merge, full reconstruction, physical cuts and
exact native export passed. This is the complete own termwise comparison,
not a monolithic original-map execution or a finite F hat.
Source: common/s08_map_Hgg_original_terms.wls
7e84be0db1e958e430341639e3bfa8096a838c52b5756a534bf68aa6e0ce08fb.
Under s08_termwise_comparison_result: result
649f888d1117a6ca53135cd756373a90bacf4d44265a1d6c009abfb44bda7073; checks
490e76a92e7b7ad8043056bd761d8830bd1043a2f3f40b9fecd45a3381575fc9; receipt
484a6b9b08d555c3ea322093bf22f11ca094ad4aa293081f99c93d8bcc0ecfc7.
Full execution 1337.497147 seconds; peak observed process-tree RSS
1492865024 bytes. All artifacts are hash-verified locally. The polynomial
production consumer is common/s08_map_Hgg_polynomial_inputs.wls
5d9194e935797c50ef15709f53d5118907299fa1f44bdbae98d4b30a77635cb8.
It must preserve this bound own original-term result and additionally pass
its complete grouped-output comparison before processing remaining targets.
All reduction, integration, componentwise pole cancellation, unpolarized
reference and final-export gates remain required.


### Scalar monomial map reuse contract
A candidate may extract loop-monomial coefficients from the actual polynomial
prefactor returned by the unchanged reference extractAtoms. Derive variables
from the recorded coordinate rules and require exact numerator reconstruction
and loop-independent coefficients. Compute each unit-monomial/propagator map
with the unchanged original mapper and original familyRows; cache only by the
source, geometry, native version, denominator powers and monomial powers.
Keep all original basis-map reconstruction and cut checks, then require full
reconstruction of every actual input, the complete accepted own Hgg map and
exact native export. Record cold mapping time, basis counts and memory. This
is an isolated candidate; no production adoption or speedup claim follows
from writing it. Existing production maps and caches remain immutable.


Active-equation export contract: common/s08_export_Hgg_active_equations.wls reads the accepted Photon_1 response, selects the first two tasks from the accepted mapping metadata, applies only the own receipt-bound coordinate rules and exports the entire equations. Require exact native read-back equality and preserve source/input hashes. This supplies readable inputs for the current extraction bottleneck, not new mapped coefficients or finite hats.


Scalar-basis candidate was not adopted: source e0014e6301bd74ff1e5dae2f21db3454bba67a64af4c37df931381cad080334f. Job14874504 was intentionally stopped after slower completed terms; native exit -9, no complete own-map comparison or accepted output. Saved provenance {"Hgg/s08_scalar_basis_result/s08_execution.json": "14a79846338ade304292894925b6e1327b6bf42ce735b17bbf36ecf6996455a5", "Hgg/s08_scalar_basis_result/s08_log.txt": "c74c21e34dd72a5f7f71dc6fc3386dfdbec0d9decaa69b953916c5a7f1e9b897"}. Existing production mapping and accepted coefficients remain unchanged.


Direct factored-denominator extraction contract: common/s08_extract_factored_denominators.wls preserves the explicit numerator, derives loop propagator powers and an external scale from the actual denominator, and checks exact input/scale identities. Before adoption require every original own-control atom to agree in powers and polynomial prefactor, then inherited complete group reconstruction on the exported actual targets1/2. Bind source, coordinate input, original mapper and full active-equation receipt. No production change or speedup claim before acceptance.


Direct-denominator validation correction: job14874603 stopped before acceptance because its small scale-identity test used Cancel on an additive difference. The corrected source uses the unchanged reference zero (Factor/Together) test. Both first control terms had already agreed with the original powers/prefactors; no complete comparison or production adoption follows from those partial checks. Preserve the failed source at common/s08_result/reference/s08_extract_factored_denominators_before_scale_zero.wls.


Direct factored-denominator extraction contract: common/s08_extract_factored_denominators.wls preserves the explicit numerator, derives loop propagator powers and an external scale from the actual denominator, and checks exact input/scale identities. Before adoption require every original own-control atom to agree in powers and polynomial prefactor, then inherited complete group reconstruction on the exported actual targets1/2. Bind source, coordinate input, original mapper and full active-equation receipt. No production change or speedup claim before acceptance.


Factored-atom reconstruction certificate contract: reuse the accepted complete group certificate and replace only its per-term large-expression zero check by a native formal-numerator certificate. Derive numerator, denominator, propagator product and scale from each actual term/atom; require exact source reconstruction, exact prefactor identity, symbolic denominator relation and specialization to the actual mapped term. Preserve the original group partitions, summed numerators and all full linearity substitutions. Require all36 original own atom comparisons, complete own original grouping agreement and both actual large grouping checks before adoption. No finite-hat acceptance follows from this mapping optimization.


Direct factored-denominator extraction contract: common/s08_extract_factored_atom_certificate.wls preserves the explicit numerator, derives loop propagator powers and an external scale from the actual denominator, and checks exact input/scale identities. Before adoption require every original own-control atom to agree in powers and polynomial prefactor, then inherited complete group reconstruction on the exported actual targets1/2. Bind source, coordinate input, original mapper and full active-equation receipt. No production change or speedup claim before acceptance.


Factored-input production consumer contract: s08_map_Hgg_factored_inputs.wls preserves the existing polynomial Hgg map, input reader and own full mapped-control comparison. Install only a passed, hash-bound factored-atom certificate whose original definitions equal the currently installed extractor and grouping certificate. Reuse its actual1/2 groups only for identical native expression hashes; all other equations use the same validated extractor/certificate. Distribute all changed definitions explicitly. Keep fresh-worker, original task inventory, physical-cut, mapping/reduction and final finite-export gates. This entry is staged until its proof is accepted and prior native writers are quiescent.


Accepted factored-atom certificate, native job14874739: all36 complete original own atom comparisons, complete original own grouping, exact actual target1/2 grouping, all formal identity/partition/substitution gates and exact native read-back passed. Actual grouping times54.105307s and50.049663s,36groups each. Full execution511.535891s; child peak3527442432bytes. Source and consumer identities {"common/s08_extract_factored_atom_certificate.wls": "14162d12f4f0e322476371b4b2f24303de2dc2b77305972fb602988739984aca", "common/s08_map_Hgg_factored_inputs.wls": "b9e6263fb6b83d585e5e50e09f7aee8d3b9299a406cff8f23b97031be98443be", "Hgg/s08_factored_atom_certificate_result/s08_execution.json": "d8be3b1571d656c9f289bb535bb723926501e04b3d4f51adc86d01c7f0e9d843"}. Result identities {"Hgg/s08_factored_atom_certificate_result/s08_checks.json": "ab0a693037d8ee7b9879ef43e5a6668217a4a821ae3000c6ff3ff53e765456ce", "Hgg/s08_factored_atom_certificate_result/s08_result.wl": "1bd4be24fd6ad69011f2848162e0ecea506a6e94e2fd0e143edc2a20c1c0437b"}. Saved locally with verified hashes. Consumer may reuse exact matching actual groups; its own full mapped-control and fresh-worker reference checks remain required, as do all subsequent finite/pole/reference/export gates. This accepts extraction/grouping only.

For a later checkpoint resume, the unchanged factored mapper may use four
shared workers at8GiB each, preserving32GiB total reservation,24GiB
per-process address and30GiB tree limits. Observed job14875400 worker
VmPeak values were6027788/6081576kB, with parent4108156kB. This is
resource evidence for these inputs, not proof of a global runtime speedup
or a bound for every later component. Keep all native memory, reconstruction,
cut and exact export checks. Resume only after prior writer quiescence;
retain all input/source-bound group and target checkpoints.

## S08 scalar reconstruction certificate comparison contract

common/s08_check_scalar_reconstruction_certificates.wls keeps the original
partial-fraction, polynomial transformation, coefficient and merge algebra.
Its isolated candidate replaces two dense whole-expression reconstruction
checks with exact per-coefficient Laurent checks, a native formal exponent
identity, actual inverse family-coordinate checks, a spin-independent
unit-denominator partial-fraction identity, and the accepted complete atom
and merge certificates. It must reproduce the entire accepted own component8
and completed production component1/group16 coefficient by coefficient.
Both cut-power gates and all original coefficient-generation checks remain.
Source, inputs, accepted group binding and outputs are recorded by hash.
No production use or speedup claim is authorized by an unpassed comparison.
The comparison owns s08_scalar_certificate_result; production checkpoints
remain read-only. Do not confuse this with the rejected scalar-basis mapper.

The prepared consumer common/s08_map_Hgg_certified_inputs.wls retains
the immutable b9e6263 factored-mapper identity for valid mathematical
checkpoints and records its own consumer source in ScalarReconstruction
evidence. It installs receipt-bound family/mapping/certificate definitions
only after complete own and actual-group equality checks pass and the
actual-group measurement improves. The environment
POLARIZED_SIDIS_SCALAR_CONSUMER_ONLY=1 with
POLARIZED_SIDIS_COMPONENT_STAGE=targets exercises the same import against
the saved native proof before production. Consumer outputs belong to
s08_scalar_consumer_result. Preserve the accepted atom/group/merge checks,
worker distribution and downstream contracts. This prepared entry is not
yet accepted or enabled in production.

## Accepted S08 scalar reconstruction certificates

Job14879656 passed the entire own component8 comparison (all36 original
terms and complete merge) and the accepted production component1/group16
comparison. Every coefficient is unchanged; both physical cuts remain at
unit power. Source common/s08_check_scalar_reconstruction_certificates.wls
SHA256 af45a3609fbbeaa1417bb2022a7b562cf9f3597563a455d3e4302c32471468f1.
Result s08_scalar_certificate_result/s08_result.wl SHA256
7de02ad26398d35a76a172f9ecf397e227177ef978b489657358050e24ff31d4;
checks032f4d7be67db9bc0641d0d9358e1bafa911208d9c8e19e86bcb1a138d2878e8;
receiptbd4f78e554ab8a710fed98690647888b30edda804cb876c3d878f07d7753d931.
Actual-group mapping117.685476s versus saved395.463889s; this sample timing
is not a whole-channel speedup. Native peak memory1341086744bytes.
The consumer common/s08_map_Hgg_certified_inputs.wls must additionally pass
its small native saved-proof import and generated dispatch contract before
production. It preserves b9e626... mathematical cache bindings and all
coefficient algebra; records its own source/proof hashes in execution and
PolynomialMapping/ScalarReconstruction evidence. Control mode requires
POLARIZED_SIDIS_COMPONENT_STAGE=targets and
POLARIZED_SIDIS_SCALAR_CONSUMER_ONLY=1; outputs s08_scalar_consumer_result.

The native consumer control14879725 passed all actual saved-proof imports,
definition identities, generated-dispatch syntax/restoration and native export.
Consumer source27b5d28bff24828735784d339403c52888513c4d4b54c11e36a5ca66b5d1774f;
s08_scalar_consumer_result/s08_result.wl122391ef7bd7cab15b6626db0d799029c9de9e6cd90930b33cb91f7ea9c15f88;
checks b0aa5bf6ab116cc15f5b226f5854ee913f6e99d24e97669096e1f80ed40244ee;
receipt8444d7c2c82c5e3ea7e36ea39d4d263ce9a3d3470a9b81d1a30b03894708dbad.
Production may install these accepted definitions with the original b9e626...
mathematical cache binding, retaining all existing accepted group/piece maps.
Execution binds the new source and both comparison/consumer receipts. Preserve
all current native memory/cut/merge/export gates and unchanged finite assembly.

## S08 repeated monomial-substitution comparison contract

`common/s08_check_monomial_substitution_reuse.wls` reuses the accepted complete
scalar-certificate setup and comparisons. Its sole candidate change caches
`CoefficientRules[Expand[shifted],polynomialVariables]` by the exact held
substitution expression and variable list inside the native kernel. All
coefficient-generation operations and reconstruction checks remain. The cache
is isolated in memory and does not write production checkpoints. The entire
accepted own component8 and actual component1/group16 maps must agree exactly;
report cache hits/misses, cache/kernel memory and native mapping/merge timings
against the accepted scalar-certificate baseline. The result owner is
`s08_monomial_reuse_result`. This is a candidate contract, not acceptance or a
speedup claim. No production consumer may use it without passed native results.

## Monomial-substitution reuse: equivalent, not adopted (14879799)

Native job14879799 reproduced the complete own component8 and saved
component1/group16 maps with all inherited checks, but showed no runtime
improvement. Keep the accepted scalar-certificate production mapper.
Do not repeat this candidate or treat it as an accepted optimization.

Executed timings: own mapping 758.038401s versus baseline 733.292225s;
actual group 122.863566s versus 117.685476s.
The tool counted 1939 cache hits and 163 misses, only
0.08889199999999993s evaluating unique substitutions, and 1095824 cache bytes.
Thus this measured operation does not account for the production bottleneck.
The cache was in memory only and is gone with the completed kernel.

Source `common/s08_check_monomial_substitution_reuse.wls`: `36db9d983961320da6f823293ae33c32da79e6879c58259bc6fae26d57cd4bbd`.

Configuration `.cluster/s08_Hgg_monomial_reuse_20260923_job.json`: `c149fca5a120ba1c24ba7dca25ac087f6ced76abab2f22eccfbca478f9d423bf`.

Keep comparison evidence to avoid repeating this candidate:

- `Hgg/s08_monomial_reuse_result/s08_checks.json`: `61c4e7f8e3e8d2ce4bc8a704fc08bec091f8e7407f20d298629a3d84a1a05806`

- `Hgg/s08_monomial_reuse_result/s08_result.wl`: `f19eb69f2c034bbcbcd84c353b80c2fe6f9258c2c18f37f1f05219feaca8b767`

- `Hgg/s08_monomial_reuse_result/s08_execution.json`: `e8dfc9568685494ed1854f4e2d984350099b496436b8c1407d84a931e6d4738a`


## Exact input export for mapping memory limits

`common/s08_export_Hgg_blocked_equations.wls` reads explicitly selected
production component indices from the accepted S05 task metadata and the
accepted complete-response reader. It applies the coordinate rules from the
accepted native component8 input, saves the complete equations, and requires
exact native reload equality. It retains actual payload, source and coordinate
input hashes. Its owner is `s08_blocked_equations_result`; these artifacts are
input equations for reading and correcting the bounded mapping, not accepted
raw maps or finite F hats. It performs no production cache writes and changes
no coefficient, phase, cut or normalization convention. The production mapper
continues to require every component and final cancellation/export gate.

### S08 compact grouping contract

`common/s08_map_Hgg_compact_groups.wls` removes only the unused full reconstruction assignments in the accepted denominator grouping and grouped-map functions. All atom, grouping, merge and cut reconstruction certificates remain required. Before use in production, its native comparison must restore the accepted definitions exactly, reproduce the complete accepted component-8 map, and run the actual hash-bound exported component-12/13 groupings under the existing 4 GiB operation bound. Canonical coefficient and group cache bindings remain unchanged. The candidate is unaccepted until its execution receipt and checks pass; no final F hats are established by this intermediate comparison.

### Exact failed-input equations retained

Native export `common/s08_export_Hgg_blocked_equations.wls` (SHA256 `bbfb708b088e1c36934afe5ede6303140160760a2e910a61aa4babe9bf7b1a77`) passed job `14879888`. `s08_blocked_equations_result/s08_execution.json` has SHA256 `13fe33a4fa5d192b224cf515705e598020cc46aa62730709084d782a30bfc933`; all complete native round-trip checks passed. Component 12 equation: `c002804b2bad63a81b66fff3a33c666a8c20f0d8de1eed2d4adc97f88c1312e6`, native bytes 549895136. Component 13 equation: `b1dee2138a0402dc023c924447303252888e3027a1e112a16fdcd7b03008564a`, native bytes 540653952. Both retain the accepted Photon-2 payload and component-8 coordinate-rule contract. These are original mapping inputs, not mapped or finite coefficients.

### Accepted compact grouping and continuation

Job `14879891` accepted `common/s08_map_Hgg_compact_groups.wls` (SHA256 `5e2dd7be9e4a49667dbafeae67788cee96932a610352ce71d8ce552a9537a52b`). The complete own component-8 map agrees exactly with its accepted output; actual inputs 12/13 each yield 36 groups under the unchanged 4 GiB algebra bound (111.262190/110.887413 seconds). Only two unused reconstructed sums are removed; atom, grouping, merge, coefficient and cut checks remain intact. Result SHA256 `fef1e66bbd4c0335a151997d8d8d0623d7689ae163d139fad9a0ca2e26b6cd30`; checks `ce3712982e802a42f2d390458f9299cf3279dd9b965af99c125bbd658fc05125`; receipt `720a5dcba576546845ad80d3e47d1b45c7b8bc3b493629db9fc9f192ab933c6d`, under `s08_compact_groups_result/`. Peak native kernel allocation in the complete comparison was 5677854704 bytes; the operation bound measures additional allocations.

`common/s08_resume_Hgg_compact_groups.wls` (`ac28e3fc94867eb99051130cf62f0195885f110d175dd4450d3315b6c9805f4b`) installs those accepted definitions only after verifying the complete native/input/definition contract. It retains the canonical coefficient/group cache identity and all existing fresh-worker/full-task gates. It is a production consumer awaiting its own native execution; this comparison does not establish finite F hats.


### Compact definition consumer: preserve the accepted piece dispatcher

The production importer must apply the inherited `mapExpression -> polynomialPieceMap` dispatch substitution to both saved original and candidate grouped-map definitions. The comparison stores the direct scalar entry; production already installs the accepted checkpointed piece entry. Require exactly one scalar call, no pre-existing piece entry in the saved definitions, exact equality to the current original production definitions, and exact inverse substitution for the candidate. Keep all receipt/input/native-version, own complete-map, fresh-worker, coefficient and cut gates. The preceding consumer failed its definition-identity gate before producing any new maps; no accepted coefficient cache depends on that failure. The failed source is retained at `common/s08_result/reference/s08_resume_Hgg_compact_groups_before_piece_dispatch.wls`. Corrected source SHA256 `50d21381fbe2d71fc8e4b21002de24527bbad5a85e760e4e010016cbdd4551ad`; native installation remains required.

Native production job14879919 passed the corrected importer50d21381fbe2d71fc8e4b21002de24527bbad5a85e760e4e010016cbdd4551ad against the actual saved proof, including exact inherited piece dispatch and candidate installation. Its complete component8 comparison reproduced every original mapped coefficient; native grouped/control time159.296667s and equality0.078501s with compatible checkpoints. This validates the import and own complete-map interface; it does not accept the remaining component maps or final finite hats. Preserve the accepted compact proof and unchanged canonical/group/piece cache identities.


### S08 coordinate-boundary contract

The coordinate substitution must remain the exact recorded `value /. coordinateRules`. A resource-boundary candidate may evaluate it under its own unchanged4GiB bound before invoking the unchanged phase/group mapper under the same bound. Require reversible complete task-source reconstruction, the complete accepted own-map and fresh-worker gates, and exact comparison against exported input13. An explicit single-component run must declare its subset, use a distinct result owner, retain full per-component gates, and may save only that component’s compatible canonical checkpoint after all its checks pass. It must never masquerade as the complete98-task target result. Full production adoption requires the subset’s accepted native receipt. All scalar/phase/group definitions, canonical cache bindings and downstream finite gates remain unchanged.

## S08 local input binding contract

The coordinate-only candidate job14879971 failed the complete mapping memory
bound after reproducing the entire actual component13 input. It produced no
accepted map and must not be treated as an accepted optimization.

`common/s08_map_Hgg_local_inputs.wls` binds the large expression once in each
of the existing numeric-factor and phase-dispatch functions. The source must
restore each complete original definition exactly, change only local argument
binding, and reproduce the complete own accepted component8 map in a separate
control owner. The actual missing component13 must then pass input equality,
all unchanged group/family/merge/cut checks and native export under the same
4GiB operation bound. Full production requires that accepted subset receipt
and exact source/input identities. Existing canonical/group/piece caches keep
their mathematical bindings; no overlapping writer is allowed for component13.
The candidate has no acceptance or measured speedup until these runs pass.

The continuation `common/s08_resume_Hgg_local_inputs.wls` may run only after
the complete actual-component subset has an accepted receipt and every output
hash matches, including the fresh own-control record. It pins the exact tested
entry, restores only the ordinary accepted-control reuse condition, and retains
all complete-stage checks. It must not overwrite the accepted subset/control
evidence. Mathematical target/group/piece cache identities remain unchanged.

## S08 complete-component memory budget

Local-binding candidate14880027 reproduced the entire own8 map but still
failed actual13 under the outer4GiB bound. It remains unaccepted; its gated
continuation stopped without changing production.

`common/s08_map_Hgg_component_budget.wls` keeps the accepted compact mapper
and all coefficient functions unchanged. Only the outer complete-component
frame receives8GiB; inner grouping/mapping/merge operations retain the existing
4GiB bound, and native loading remains separately bounded. The existing
24GiB allocation/22GiB process guard is unchanged for the isolated13 run.
Exact source reversal, accepted own-map reuse, actual full input equality and
all component reconstruction/export checks remain required. Full production
must bind the passed actual13 subset receipt and exact source/input hashes.
This is resource-scope correction, not an accepted algebraic speedup.

## S08 direct grouping contract

The complete-component budget candidate14880068 failed the inner derive-denominator-groups memory bound on actual13 and remains unaccepted. The direct grouping candidate installs the accepted compact hggOriginalGrouping body directly as groupDenominators, with exact reversible symbol renaming. It bypasses the lookup wrapper whose saved groups concern already-completed inputs1/2, while preserving all grouping, coefficient, merge and cut certificates. It requires a fresh whole own8 comparison, exact exported13 input equality and complete component13 native mapping/export before any full-channel adoption. Canonical/group/piece cache bindings remain unchanged. No speedup or finite acceptance follows from source inspection alone.

## S08 streamed final group-merge comparison contract

The isolated comparison reuses the unchanged accepted Hqqprime streamed-sum
and available-denominator cancellation definitions. Inputs are the complete
saved group coefficient packets for the accepted own Hgg component, bound by
SHA256 in common/s08_Hgg_streamed_merge_inputs.json. It must reproduce the
complete independently accepted own termwise map and canonical component with
the original merge, then compare every candidate coefficient to that original
merge. Require all packet checks, exact streamed reconstruction and native
export/reload. Measure the original and candidate merges on identical inputs.
No production source or checkpoint is modified. Adoption in the final grouped
merge requires a passed comparison receipt and measured improvement; it must
preserve all original phase, atom, family, cut and downstream checks. This is
not finite-hat acceptance and supplies no new physical convention.

The streamed final-merge comparison passed native job14880650 and reproduced
every own original and canonical coefficient. It is **not adopted**: original
merge81.277429s, candidate82.311986s on identical complete component8 inputs.
The existing merge stays unchanged. Entry SHA256
b0d99ff8e63fbc799c6c58cfd0625eee019b70a8e7d8f28e65159792b15237f7;
input manifest cb38a3447246e54ba0eb6c680d319a51bc1a6459b162cbc9a45446042805be56;
result s08_streamed_merge_result/s08_result.wl
b0813075a22d514af6d0ce63d589358da19a314ec415b639f2a860d64d475a04;
checks7f7b7b1cf8d36c94ad63fe0e3e5f0e70ad8395d9a5b9f1e3e1b3ce7ad55847a6.
Receipt SHA256 3248ce55952da1208a6a529add99c8039bac7ee8420f20509256ed1964caad45.
Log cache/s08_Hgg_streamed_merge_20260923.log. Retain this comparison as evidence
that merely replacing the final merge did not accelerate the accepted control;
no production result depends on the candidate.

## S08 family-input normalization comparison contract

The isolated `common/s08_check_family_input_normalization.wls` tests removing
only the preliminary Cancel immediately before the unchanged familyRows
Together call. It binds the accepted scalar-certificate definitions, actual
saved component1/group16 equation and own complete component8. Run the
unchanged complete comparison first with the original mapper, then with the
single reversible source edit on identical inputs. Require every accepted
own and actual coefficient, reconstruction, cut, merge and native-reload
check. Record both fresh timings; no production adoption without exact
comparisons and a measured improvement. Output belongs to
`s08_family_normalization_result`; all production sources and checkpoints
remain unchanged during comparison.


## S08 disjoint remaining-component execution contract

The independent remaining-component entry reuses the complete pinned direct
grouping implementation and changes only task selection and output ownership.
Its selected indices are computed from the complete saved task inventory by
excluding component13. Require the program to check disjointness and complete
coverage with that component. Retain a fresh complete own8 comparison,
canonical input hashes, all per-group and per-component certificates, and
unchanged canonical/group/piece cache identities. Component13 has a separate
writer. Outputs use s08_other_group_components_result and a separate
s08_other_group_control_result; neither subset is a complete-channel map.
The complete-channel continuation must bind both accepted subset receipts
before collecting all components and enforcing the unchanged complete-map,
reduction, assembly, pole and finite-export gates.


The normalization comparison completed in native job14881239 with all exact own/actual coefficient gates passed. It is **not adopted**: original timings {"OwnMapping": 861.160209, "OwnMerge": 101.417786, "ActualMapping": 161.379344}; candidate {"OwnMapping": 825.2683140000001, "OwnMerge": 95.575357, "ActualMapping": 197.523531}. The total change is -0.004973620266560591 relative and the actual group is slower, so this provides no material production speedup. Keep the existing mapping and all cache bindings. Source3d0825c8616d4cd34bab275f572288748c18f6b1a17efef97cc538f615e4bc83; resultdc8d5d04bb5ac3ce38cf3311f380c53768b639244abf20843915b75949d8c7c3; checksa66845d566f9ee2e6dcc6b9ce90d78410b4e663844aba9eb5c6cba2acef1117a; receipt528d6642ad7a201d4393c0fa19dc6b55168bd11628fd4c6bf71683ccb380c12c. Retain comparison as reproducible evidence; no production result depends on the candidate.

## Direct-group checkpoint resume validation

Job14882067 completed its own full component8 comparison and saved three
additional component13 groups before the native wall limit. Its authentic
receipt binds the exact direct mapper and comparison result. The resume entry
may reuse that unchanged comparison only after verifying the receipt/output
hashes, current scientific input and expression hashes, denominators, component
identity, native versions and every saved reconstruction check. Restore only
the original validated comparison-cache condition; all mapping equations,
actual13 input equality, group/cut/merge checks and final subset gates remain.
The running batch has a separate control owner. This changes restart work only;
it is not a new algebraic algorithm or an accepted finite hat.


## Accepted isolated component13 map

Hoffman2 job `14886548` on `n7045` accepted the complete component13
map with the inherited reconstruction, cut, input-identity and native reload
gates. It reused only the exact bound own-control comparison and completed
the previously remaining groups. This is a scalar mapping input, not a
complete-channel map or a finite F hat.

- `s08_direct_group_component_result/s08_checks.json`: `4dd7f4e53f465c5631c26517b8e3661a3b486a105478580e10d9e985fb6ff08b`
- `s08_direct_group_component_result/s08_result.wl`: `bca777e359a4b37abf9f1cd81488db11312e50a6a5b92ee5386c21c8c80733b3`
- `s08_direct_group_control_result/s08_result.wl`: `176069d91e6e2feed20cc9cfa1d17312df1caa80358f6406beab5adeec2e86b8`

Receipt: `s08_direct_group_component_result/s08_execution.json`, SHA256
`f1a2696eb31cb62ad4a1facf21a8e35988c95fcde0ce436342ab3f1604c79113`.
Resume entry: `common/s08_resume_Hgg_direct_groups.wls`, SHA256
`ab0b6ea4da3b9563d48ee9f59cf4742ff77317fa68a260a6c9009f641efa0e7a`.
Native log: `cache/s08_Hgg_direct_group_resume_20260924_part5.log`.
Execution took 4831.512715702876 seconds; peak observed tree RSS
5443145728 bytes. The result, checks and receipt
are hash-verified locally. The complete-map consumer must bind this receipt
and the disjoint remaining-component receipt before reduction/assembly.


### External-factor mapping candidate contract (not yet accepted)

The isolated source common/s08_check_external_factor_mapping.wls partitions each actual Times expression using the native loop-coordinate inventory. It derives external factors from the saved equation, checks exact whole-input reconstruction, runs the unchanged accepted scalar map on the remaining core, and scales its complete coefficient association. No factors are transcribed from another channel.

Acceptance requires exact agreement with both the full accepted Hgg component-8 map and component-1 production group 16, unchanged cut keys and family/merge definitions, and a fresh original-versus-candidate timing on that production group. The output owner is s08_external_factor_result. Production mapping and checkpoints remain unchanged until these checks pass and a speed improvement is measured. Input/native-version/proof hashes and all checks are saved with the result.

### Bounded parallel continuation

The unchanged target mapper uses NSLOTS (up to eight kernels) for independent components with separate deterministic cache owners. The continuation following native job14888706 requests four slots at h_data=12G per slot, retaining the previous total48GiB reservation and44GiB tree-RSS guard. This changes only execution parallelism; source, input identities, group/cache contracts and acceptance gates are unchanged. The controller adopts the already running allocation and applies the new request only at the next checkpoint continuation. Measured preceding two-worker tree peak was18.56GB and largest process VmPeak9.868GB. These are resource measurements, not a measured four-worker speedup.

### External-factor production consumer contract

The consumer may install only the executed external-factor definitions saved by the isolated comparison. Require its authentic successful receipt, exact source/input/native-version bindings, full own and actual coefficient comparisons, positive measured improvement, and equality between the live original mapper/family/merge and the saved original definitions. Distribute the complete wrapper, retained mapper and native coordinate inventory to each worker. Preserve every existing group, piece and component checkpoint identity because their exact mathematical outputs were compared; accept reused packets only through their existing input/reconstruction checks. Record the comparison and consumer hashes in the mapped result. Unfinished groups alone use the new algorithm. This contract is pending the comparison result and does not itself authorize a finite-hat claim.

The first external-factor candidate (job14889343, source db22a90d427713648fae042800ceec66fd26ad9240126ea3bfd08f0ecda1ed27) was rejected at own term9 by the unchanged strict atom-specialization predicate. It produced no accepted result and was not installed in production. The revised candidate applies the exact existing atom certificate as an eligibility predicate before choosing the factored map; an ineligible input uses the unchanged original full mapper. Both paths retain all original mapping/cut/reconstruction gates. Full own and actual comparisons must pass again before adoption.

### Reuse of completed scalar reductions

A compatible-rule library may import only accepted Hqg and Hgq Kira exports with authentic receipt/result/source bindings. Require exact equality of the geometry and baseline hashes, full inherited master basis, positive-energy cut support and each saved family definition. Compare all common integral rules exactly, keep unique integral keys, and reproduce the entire accepted Hqg rule inventory. Measure actual coverage of the accepted Hgg component13 input. This library is only a reusable scalar input: full Hgg target coverage remains mandatory before the reduction stage can be accepted. The original native Kira workflow remains the fallback for uncovered targets; no spin coefficients may be inferred from another channel.

The compatible-rule library passed Hoffman2 job14889496 in60.224308s. It contains583 unique rules, exactly reproduces the full accepted Hqg and Hgq reductions, and leaves43 uncovered targets in the accepted431-target Hgg component13 map. This is a subset coverage measurement, not a full-channel reduction. Source common/s08_collect_compatible_reductions.wls d66084511920128f7cff8d91d2e2df6a1bfcbc2152310903cb9b60ad271ab2b9; result s08_compatible_reductions_result/s08_result.wl 2d2dcc4f763188b176da715330dd03bc61698e1b848ab2b2cf1fc42da9e9f10f; checks c7dcc6def0544ac2a41e1ad2173bc2ec22bea01e5a38a0112724951b051fe7e4; authentic receipt7f33a2ad46e214cac136844a8d796edc1b3bfd7b5c58bd3b966976cf95196fc3. All are hash-verified locally.

The reduction consumer must bind this accepted library and the complete Hgg target map. Preserve the original Kira configuration/reader block exactly, requesting the baseline target inventory plus any actual Hgg targets not present in the accepted library. Before merging outputs, compare every overlapping newly reduced rule to the reused rule; require original master basis and complete Hgg coverage. Record full target inventory, reduced target inventory and explicit dispatch/library provenance. No full-channel reduction can be accepted from the subset comparison alone.

The guarded external-factor algorithm passed job14889440 in875.173977s. Fresh complete production-group times: original91.127128s, candidate83.001384s; complete own36-term mapping492.30791s and merge65.074056s, with exact whole accepted output equality. There were26 factored cases and11 original fallbacks; no reconstruction predicate was weakened. Source common/s08_check_external_factor_mapping.wls 4c1c87e30ee55bc5aa61067dd081bb2646449bcddcb93590d6423e9e3a9f6407; result s08_external_factor_result/s08_result.wl 52977c036e140df9d19cc6fe1565ce9ed9591f65f05f8288660a0a51dd07559c; checks91ba89b9f47341990e01a60c8353277625cf3c2328b315c27992c140f41572f6; receipt1804b9f6a05156f8a327d3cbdfe6d9e74e5552494ff41495c7953bd83391193b. These artifacts are hash-verified locally.

Production consumer common/s08_map_Hgg_external_factors.wls (1dfd5d3e78ba7066d6d12ea443c6eca95903b4d104e0fa1bf596fc30891c116e) installs only those saved definitions, with exact live-original checks and complete worker definitions. The retained mapper supplies the fallback. Existing group and component caches remain mathematically valid. Production consumer execution and complete Hgg mapping are still separate acceptance requirements.

Resume bookkeeping must include the phase-group directory cache/s08_Hgg_grouped/244be3fbf4bd6c97320bdf9194b8d1744e45b97597929aba9717bf70927353ec_numeric_phase as well as the original group and component directories. These files contain completed native group checkpoints and must count as progress at an allocation boundary.

### Reduction-reuse consumer comparison contract

The complete consumer common/s08_extend_reused_real_reduction.wls preserves the exact reference Kira block, master and complete-target gates. Its isolated control mode uses the accepted full Hqg target map and compares every assembled rule against the accepted complete Hqg reduction. The control must avoid Kira because the accepted library covers that inventory. Its output belongs to Hgg/s08_reduction_reuse_control_result; it is not an Hgg full-channel reduction. Production adopts this consumer only after that comparison passes. Any uncovered actual Hgg targets use the unchanged reference native block with its two Kira threads and an allocation of at least two slots. The original SourceHash remains the underlying reference workflow identity, and DispatchSourceHash, compatible-library hashes, actual Kira target inventory and reused target inventory identify the adapter explicitly.

The reduction-reuse consumer passed native job14889637 in105.398812s. It reproduced the entire451-target accepted Hqg reduction exactly, avoided Kira, and retained all original basis and coverage gates. Consumer source d5671f76872bc66bbaf3142507e6d919db3205bdbba3845c5cf5311f450c8e22; isolated output s08_reduction_reuse_control_result/s08_reduction.wl f737ccfdd6fad64294380f804546ac2e0c6df8c742703bf2df0763767011940a; checks72c5934cb9003f29bfb19e679f955eeb7da8ac2b12a89ccbfc4c91dd73400ef8; receipt05c62a989ea1ece22e3cb123603376ddee2b3f7fe85873558017167219508fe9. Outputs are hash-verified locally. Hgg production may now reuse covered integral rules and run the original native Kira block for uncovered targets. Require overlap equality and complete actual Hgg coverage at that execution; no finite-hat claim follows from this control.

### Hgg off-diagonal dimensional transfer contract

S11 currently uses leading physical kernels in the PDF gq/gaq and FF qg/aqg routes. The completed Hqg native qg result contains a nonzero MS operator difference, which the Hgg S14 entry does not otherwise supply. Before changing Hgg subtraction, common/s10_Hgg_offdiagonal_transfer.wls must reuse that accepted qg source/result, derive aqg using its own generated antiquark amplitude and density, and compare the complete native matrices. For PDF gq/gaq use arXiv:0807.4424 Eq.(33), count crossed fermion legs from the generated amplitude, derive the normalization against the pinned leading kernel and require independence from kinematics and agreement of every physical entry. Construct CDR incoming averaging from the native projector Gram matrix and subtract its regulator remainder as Eqs.(38)-(39). Require exact reconstruction, unchanged physical limits, vanishing new soft residues, charge-conjugate output equality and native reload. The isolated s10_offdiagonal_result is a transfer input, not a corrected S11 or a finite hat. An own Hgg convolution and final cancellation/reference gates remain required before accepting changed hats.

### Own Hgg native-route convolution contract

A new S11 owner s11_native_result may reuse the exact saved Hgg Born tensors, roots, Jacobians, route inventory, phase and coupling normalization from the accepted small-channel subtraction. Before any change, reproduce every current route convolution and the complete saved counterterm using the original equations. Accept only the native off-diagonal transfer result with authentic source/input/native-version bindings. For each generated route apply its recorded PDF or FF operator difference to that route own Born response. Require zero physical-dimension difference, zero new soft residues, exact full expansion equality to the saved counterterm plus the computed addition, and absence of regulator poles in the complete counterterm change. Preserve the physical frame, charge-conjugate bookkeeping and output schema. Keep the existing subtraction as immutable comparison provenance; final S14/S15 consumers must explicitly bind the new owner and its successful receipt, retaining full pole cancellation and unpolarized-reference gates. A passed convolution is not a finite F hat.

Native off-diagonal transfer job14889771 accepted in30.123195s. Both complete incoming PDF operator differences are exactly zero; the two FF operator differences agree by an independently generated full-dimensional antiquark comparison. All physical leading entries, crossing normalization, reconstruction, endpoint and native reload gates passed. Source2a3db69ff4f16697fb6b93c603f3d5ef1d8f21266864098e76cf3c91a0e64dcf; s10_offdiagonal_result/s10_result.wl b21e330880da774f84d326ff35fb8b9a42340e4bfd7274bd6bf67236e3282ce7; checks9505a2f0852654a77a4a647f234fff549a9bb2ecdc9998efce00087f5f0d0c04; receipt56681b18b9dd051dd29c0c7092c20cb9dfbb327c8399003d780c4abbb8dc7c34. The own Hgg convolution still gates any subtraction update.

### Native subtraction final consumers

The Hgg S14 native-subtraction entry changes only the accepted subtraction input owner to s11_native_result, validates its successful receipt/source and finite-change gates, and preserves all compact phase assembly, componentwise pole cancellation, both branch boundaries and original U/U F-hat comparisons. Record the exact subtraction and dispatch hashes in the accepted tensor. The Hgg S15 entry reuses the completed Hqg exporter adapter with the Hgg native subtraction source and owner. Require the matching accepted S14 receipt and subtraction hash, unchanged previously accepted helicity conversion, every original finite-export gate, and exact native reload. The new scheme owner is s15_native_scheme_result; original scheme artifacts remain comparison provenance.

The own native-route convolution passed job14889816 in45.384267s. It exactly reproduced every saved route, the full old convolution and counterterm, then proved the computed change is finite and the full new expansion equals the accepted counterterm plus the addition. Source1a6f84a95188a81e60b1543d7b514f9b5c35934a3c05a1ce792bef33005abe05; s11_native_result/s11_result.wl a10efe2fbb104be6696c66a336be9f38f9d71ddb55d9274d2e9f42ade4a37a3e; checks7a7e7257e77656fd5f0384e50e599e1da87415954805420851257d3e19c2abe5; receiptfd0f172b15f7c54904c4c2471e0d29186a1b26727a6eedf9f207307a20caef17. The tool-reported changed component indices are [[1, 1, 1], [1, 1, 2], [2, 1, 1], [2, 1, 2], [3, 1, 1], [3, 1, 2], [4, 1, 1], [4, 1, 2], [5, 1, 3], [6, 1, 3], [8, 1, 4], [9, 1, 4]]. These files are hash-verified locally. New Hgg finite assembly must use s11_native_result. The older s11_result is retained only as immutable baseline/provenance required by the accepted comparison; it does not include this native MS operator addition. S14 complete reference agreement remains pending.


### Production entry points for the remaining Hgg stages

The channel-local links below resolve to their shared reviewed implementations.
Run them from the polarized_SIDIS root with the corresponding receipt-bound
cluster configuration. The older generic entries remain reference interfaces;
the native S11 owner must be used by the final Hgg assembly.

| Stage | Channel entry | Result owner |
|---|---|---|
| S08 remaining map | s08_map_Hgg_external_factors.wls | s08_other_group_components_result |
| S08 reduction | s08_extend_Hgg_ready_reduction.wls | s08_reduction_result |
| S08 mapped coefficients | s08_map_Hgg_response_inputs.wls | s08_result |
| S10 native off-diagonal transfer | s10_Hgg_offdiagonal_transfer.wls | s10_offdiagonal_result |
| S11 native subtraction | s11_Hgg_native_routes.wls | s11_native_result |
| S12 integrated real tensor | s12_assemble_real_factored_series.wls | s12_result |
| S14 finite assembly | s14_Hgg_native_subtraction.wls | s14_result |
| S15 local scheme preparation | s15_prepare_native_scheme.wls | s15_local_scheme_result |
| S15 final export | s15_finalize_Hgg_coefficients.wls | s15_result and s15_native_scheme_result |

A source link or prepared configuration does not certify its output.
Only the stage's successful execution receipt and complete acceptance gates
establish an accepted result.


### Direct-group worker input contract

After restoring the exact accepted direct grouping body, worker setup may omit the obsolete hggFactoredGroups lookup and its hggAcceptedGroups library. Require that the installed grouping and phase-map definitions have no references to either object, that both are absent on every fresh worker, and that the existing complete own-map and reconstruction gates remain unchanged. Record omitted native bytes and distribution seconds. This is a worker-data transfer change only; all task equations, definitions and checkpoint identities remain unchanged. Keep the prior external-factor entry as immutable provenance under common/s08_result/reference. No runtime improvement is claimed before a native measurement.


### Reduction of an accepted mapped subset during remaining mapping

common/s08_extend_Hgg_ready_reduction.wls reuses the exact accepted reduction-reuse
adapter and unchanged reference Kira block. In subset mode it accepts only the
authentic complete component13 map, preserves every cut, family, master, baseline
and fresh/reused overlap check, and writes s08_ready_reduction_result with a
subset schema and ChannelCoverageComplete=False. It must never populate the
full-channel reduction owner in subset mode.

In full mode the same entry binds the accepted subset receipt, exact source,
native versions, geometry, cuts, master basis, physical mapping inputs and
complete target coverage. Compare all overlapping scalar rules exactly before
adding only missing keys to the existing accepted rule library. The unchanged
original full-target gates and full-channel output owner remain mandatory.
Record both mapping and reduction provenance and the native Kira target list.
This overlaps work required by the complete Hgg calculation; it introduces
no new integral equations or spin assumptions.

The component13 subset reduction passed Hoffman2 job14890063 in165.601888s;
Kira reported100.3s. It covered442 supplied-plus-baseline targets with the eight
inherited masters, with no missing targets and every original rule and
fresh/reused overlap check passing. This remains a subset scalar input.
Source common/s08_extend_Hgg_ready_reduction.wls
2ccd9ba37b0fe8af7157f1ed8dd09dec26ffae2b6ddf779a67eed5bce1bdb7a3.
Result s08_ready_reduction_result/s08_reduction.wl
2937bdc9379b5fae92ec098f013f48c91a40f41e2b24af31f583c0e1dacb667c;
checks28f662de66b3bc37072767a46cd184841c2790f35e364dae70ee6f2b02cbf15f;
receipt008365f6c1ececfddd6cddd8d856a5090cff65c487721e17392e27d2b02e808e.
Native log cache/s08_Hgg_ready_reduction_20260924.log. These artifacts are
hash-verified locally. The channel-local ready-reduction entry is now the
preferred full S08 reduction entry, consuming this subset only after its
full-mode receipt/input/overlap gates; full Hgg coverage remains mandatory.

The unchanged mapper supports up to eight independent Wolfram workers through
NSLOTS. Its next continuation may request eight slots at h_data=10G per slot,
with a76GiB aggregate RSS guard and unchanged24GiB per-process address guard,
8GiB component bound and4GiB operation bound. The observed preceding four-worker
peak34879770624B provides the sizing evidence; no eight-worker speedup has yet
been measured. The unused-library transfer edit and all existing own-output,
reconstruction and input-bound checkpoint gates remain mandatory.


The external-factor production consumer before the fresh-reference equality
correction, including omission of the unused worker lookup library, has SHA256
8f2270347a3662a6544fd557fe632abcafca8c9761ffa8b0310d99c4e74adf63.
The prior1dfd5d3e variant is retained exactly as
common/s08_result/reference/s08_map_Hgg_external_factors_before_worker_trim.wls.
That source passed configured expansion/interface syntax review, but native
job14890657 subsequently failed the strict fresh-reference expression-form
comparison. Job14905264 established exact coefficient equality; the corrected
consumer and its proof bindings are recorded below. No coefficient algorithm or
cache identity was changed by the worker-input edit or comparison correction.


## Bounded local Hgg scheme preparation

The user-authorized `misc/s05_prepare_Hgg_scheme.wls` executes the complete existing Hgg S15 entry in scheme-only mode, changing only local runtime checks, output paths and explicit execution provenance. It requires the accepted native S11 receipt and the archived accepted scheme receipt, preserves every original scheme gate and the full prior-tensor comparison, and records the actual local Wolfram/FeynCalc versions separately from imported cluster commands. Outputs remain under misc/s05_result until the executed checks and exact native reload pass. It does not export finite hats or bypass the unfinished S08/S12/S14 work. One kernel is limited to8GiB tree RSS,12GiB virtual address space,4GiB available-RAM and disk reserves,32MiB outputs and600seconds. The larger virtual-address allowance is not a RAM reservation. After acceptance the source link and result/check/receipt copies belong to Hgg/s15_prepare_native_scheme.wls and Hgg/s15_local_scheme_result; final production export must still verify the actual complete S14 tensor.


### Accepted local Hgg finite-scheme preparation

Authorized local run `local_Hgg_scheme_20260924` passed in8.012012seconds with335728640bytes peak observed RSS. The full inherited scheme calculation, previous accepted tensor comparison, input-receipt bindings and exact native reload passed under Wolfram15.0/FeynCalc10.2.1. No temporary physics cache was created. Source `misc/s05_prepare_Hgg_scheme.wls` has SHA256`cf3a14ace200d7312335e791ebac5ecc438287859717332d19132ddcdfa4d658`; `Hgg/s15_prepare_native_scheme.wls` links to this exact source. Invoke the verified Engine15 kernel with `POLARIZED_SIDIS_LOCAL_AUTHORIZED=1`, `POLARIZED_SIDIS_CHANNEL=Hgg`, and `POLARIZED_SIDIS_SCHEME_ONLY=1` under the limits in misc/s05_inputs.json.

The following Hgg copies are byte-identical to the canonical local-run artifacts:

- `s15_local_scheme_result/s15_result.wl`: SHA256`a47e0fbc33473901b810ab7c548f140802acc92a92650dd7e88e83ec0d6b10a8`; canonical `misc/s05_result/s05_result.wl`.
- `s15_local_scheme_result/s15_checks.json`: SHA256`d29611fdaa15a339ade8b24b818808b7c331b8304407a4bee5c2f44917fcad75`; canonical `misc/s05_result/s05_checks.json`.
- `s15_local_scheme_result/s15_execution.json`: SHA256`95dfbe3b07c175a60323d355b51403c11c5928f533ac2f2ae8b11f317380bc86`; canonical `misc/s05_result/s05_execution.json`.
- `s15_local_scheme_result/s15_inputs.json`: SHA256`cb3f7419887478da1dc62064d2d5dba6482bada3be8b1b0f867b0b253688d5b4`; canonical `misc/s05_inputs.json`.
- `s15_local_scheme_result/s15.log`: SHA256`931c9c7b0489ea80ac1d855ea6481c24ae04538c9b76c4c3d7a98d1ec0dc191a`; canonical `misc/s05_result/s05.log`.

The copied receipt intentionally retains its original misc artifact paths and its explicit local execution identity; no Hoffman2 job is claimed. This accepted scheme tensor does not contain the uncomputed Hgg finite hats. The existing full Hgg S15 exporter still computes and checks this same scheme as part of its final S14-bound execution; keep s15_result reserved for that complete export.

## Authorized local S08 continuation contract

`misc/s06_map_Hgg_local.wls` provides a one-kernel execution of the accepted
original scalar mapper and its executed polynomial, scalar-certificate,
compact-grouping, numeric-phase and external-factor definitions. It retains
all exact reconstruction and cut-power gates. The native piecewise payload reader is restricted to the selected response entry;
its original file-hash checks and writer ordering remain. The actual component38
reader preflight passed, loading620727744bytes. Task ordering is reused.
The complete local component8 coefficient comparison passed before the inherited
whole-response read hit its operation memory bound. The selected-reader revision
reuses that successful comparison only after exact source-section, input, native
version and saved-control identity checks; the failed whole-response run is
retained explicitly as a resource-bounded attempt, not an accepted full stage.
Its input/configuration hashes bind the exact
imported artifacts; all scratch writes stay under `misc/s06_work`.

Local Wolfram15.0 provenance is recorded separately from imported cluster13.1
provenance. Before unfinished components may execute, the local implementation
must recompute the complete accepted component8 and reproduce every coefficient.
The original scientific input/group identities remain dependency identifiers;
they do not claim that local work executed with the cluster runtime. Newly
written packets carry actual local versions and the own-comparison hash.
Only receipt-accepted local components may be promoted for downstream use.
The initial selected component is38. Outputs are partial maps, not finite hats.
Runtime guards require one CPU, at most8GiB tree RSS, at least4GiB available
system RAM and free disk, and at most2GiB scratch. Execution status is recorded
only in `scripts/progress.md`.

The channel entry `s08_map_components_locally.wls` links to the reviewed misc
program. `s08_local_components_result` links to its canonical `misc/s06_result`
output owner, so native results, checks and execution receipts are visible in
the channel folder without duplicating storage. Filenames retain the local
S06 stage prefix and receipt paths. Only `passed: true` in the corresponding
execution receipt accepts a completed local component; this directory is not
the final-hat export. The explicit earlier resource-bound attempt remains in
its `reference` subdirectory for control provenance.


### Complete fresh-worker reference comparison contract

`common/s08_check_Hgg_reference_map.wls` reuses the accepted external-factor comparison setup and its exact executed definitions. It loads the same pinned Hqqprime tensor and reference raw map used by the production fresh-worker gate, verifies complete source/input identity, then computes both original and candidate maps and every exact coefficient difference. The separate `s08_reference_map_comparison_result` owner retains the full input equation, both coefficient maps, differences, strict expression identity and algebraic identity with native versions and hashes. No production checkpoint is changed. Only an executed exact comparison may establish whether the strict expression-form failure is representational or mathematical; final Hgg assembly/export remains separately gated.


### Accepted fresh-reference equality correction

Hoffman2 job14905264 accepted the complete saved Hqqprime reference comparison in391.682756seconds. Both maps have197 identical integral keys; every exact coefficient difference is zero, although strict expression identity is false. Original mapping145.01338seconds; external-factor mapping107.1652seconds. The external factor and the full reconstruction/cut gates passed. This establishes an expression-representation mismatch in the old production control, with no changed coefficients or invalidated scientific checkpoints.

Artifacts under `s08_reference_map_comparison_result`: result `e1f742f05e11adbd78f9741c8a405f0d2a2ff53f7a9d146e92951ba90621cd21`; checks `7041a11f84a5ce6844161c152f948044782dd99714fa4f984fbc0a0b1918d105`; authentic receipt `9a359e3cd4e9c07b91cb73ad631236a93ff1fa3e12deb9a7176ad5a895d4b675`. Comparison source `common/s08_check_Hgg_reference_map.wls` is `4261bb809315d37609ba424f0e59969730cf68374273b5a145e7fe6257180e15`. All result files are hash-verified locally.

The corrected Hgg consumer `common/s08_map_Hgg_external_factors.wls` is `f56a17a46371995ea64efcecc35eae81f55162f77b121b0119a19c31a90a6c87`. It binds this comparison and replaces only the fresh-reference predicate with identical integral-key inventory and exact coefficient equality. All reconstructed source checks, own comparisons, scalar operations, cuts and checkpoint identities remain unchanged. The prior8f227034 source is retained in `common/s08_result/reference/s08_map_Hgg_external_factors_before_reference_equality.wls`. Its production execution must pass the corrected fresh-worker gate before unfinished components run. No finite Hgg hats are established by this mapping comparison.


### Worker-independent polynomial checkpoint lookup contract

The proposed S08 cache reader searches existing `kernel_*` folders only after the current worker lacks an accepted packet. Reuse requires the exact existing `Hash[{pieceScientificHash,piece},"SHA256"]` binding and all original acceptance checks; writes remain in the requesting worker directory. No coefficient, grouping, merge, cut or native-version rule changes. Before installation, the comparison must select an actual Hgg denominator group from the accepted input record, reproduce its accepted group coefficients with the unchanged fresh mapper, reproduce every coefficient through the new reader, retain the exact input equation and native hashes, and measure both runtimes. Only a passed comparison and unchanged live original definitions authorize production use.


### Accepted polynomial checkpoint reuse and packet-return correction

Hoffman2 job14907466 accepted `common/s08_check_shared_piece_cache.wls`
(SHA256 `9008b7ad9c6730f9f8013f3beb62e5847b299bc8c09f3937d15a20f38e7254b2`).
The actual input is component8/group1. Fresh mapping, candidate cache-miss mapping,
and cross-worker cache-hit mapping agree with every coefficient of the accepted
own group. Both reconstruction and cut gates remain unchanged. The cache-hit path
performed zero new piece writes. Timings: fresh3.609347s, miss3.139256s,
hit0.868715s; this is a measured4.1548x saving for this hit, not a full-channel estimate.
Peak kernel memory1341234152bytes. The benchmark scratch was removed after success.

The comparison found the inherited `polynomialPieceMap` cache-hit early return
could leave a literal `Return[packet]` inside the packet list. The accepted candidate
uses an ordinary hit/miss conditional ending in the packet. It also searches sibling
worker folders after a local miss. The exact scientific hash, input/piece binding,
acceptance checks, per-worker writes, scalar algebra, merge and cut rules are retained.
No accepted coefficient or scientific cache was invalidated. Unaccepted attempts
remain under the comparison owner's reference directory and cannot authorize use.

Accepted artifacts under `s08_shared_piece_cache_result`:

- `s08_result.wl`: `c6ae4723f23712f7d73c34f5fbdc2795f24ccb74611c0c8aa7258d4e45c164c1`.
- `s08_checks.json`: `fdb67ff740f113144e669cc1642bdd52ac426da7c02b8ec334f75ca3cf3f1eba`.
- `s08_input_equation.wl`: `786cda60bad08c1ce0ed3e9bf5a72d4e44e4b43b641aaba8fa1b3a9571f990d4`.
- `s08_execution.json`: `5628756fef2d96baff4590673d89e3bd594db621eae9d8a59fbbd70f58c805d3`.

The complete input equation is readable native Wolfram text. Its canonical
polynomial cache namespace is `cc35b918161bacca5aca65007f5a6d463824d9286205207f470954b9ae0cade0`,
derived by the program from the accepted Hqg polynomial proof and Hgg input/source.
`common/s08_map_Hgg_shared_pieces.wls` installs only the executed candidate after
receipt/source/input/native-version and complete original-definition checks;
it distributes the same reader to production workers. Its source is
`8f00658f8caa85a094b2085ae50f1c6183df33a4e91a1f5c6ae82d96f438171c`.
This comparison is not a finite F-hat export; full S08/S12/S14/S15 gates still apply.


### Selected-entry cluster reader contract

`common/s08_check_selected_entry_read.wls` may reuse the complete selected-entry
reader from `misc/s06_map_Hgg_local.wls` on Hoffman2 after a native comparison.
It must bind the original piecewise writer, payload manifests and task metadata,
preserve full payload hashes and serialization ordering, derive a task from the
accepted piecewise Photon4 payload's native metadata, reproduce that complete
input exactly, and measure cold loading against the current response-only reader
on the same task. Photon1 is monolithic and would exercise only the fallback;
it is therefore not a timing fixture for this optimization.
The test changes no coefficient mapping. A passed receipt, exact native/input/source
identities and retained original fallback definition are required before any
production consumer installs the reader. Existing whole-response cache remains
available for payload formats outside the selected-entry interface. This is an
input-loading contract and does not establish any additional finite hats.

The prepared `common/s08_map_Hgg_selected_inputs.wls` consumer binds the executed
selected-entry proof, exact original reader definitions, native versions, current
scientific inputs and task inventory before installation. It preserves the entire
original reader as the monolithic fallback and distributes that alias plus the
selected reader globals. It retains the accepted shared polynomial cache and all
mapping/reconstruction/cut gates. A prepared source alone does not authorize
use: the selected-entry comparison must first pass on Hoffman2.

### Accepted selected-entry cluster reader

Hoffman2 job14907743 accepted the actual Photon4/component36 comparison. Both
readers returned exactly the same full input expression. Current cold read:
550.46766s and7475973904 retained bytes; selected-entry read:84.667988s and
1110627984 retained bytes. This is6.501485x for this loading operation, not a
whole-channel estimate. Original payload hashes, native writer ordering, complete
task metadata, original fallback and exact native proof reload passed.

Comparison source `common/s08_check_selected_entry_read.wls`:
`c05455bfbfda6dc1270da95a6278c74bc449cd84bb4219ae81221f96dbad8379`.
Accepted artifacts under `s08_selected_entry_read_result`:

- `s08_result.wl`: `0dc5449091ba123ec1ad00973f2cea3b9dd156bb7aa0b1013206b2881139ad85`.
- `s08_checks.json`: `2ba078ca0a2a07d1f6a16eef2fa1518d9d723621e3a9d719dbfdb92a6ac601fd`.
- `s08_execution.json`: `254bebc3370026205eddbb2c7203f404a454f69d150030fd4093998825b4b2cf`.

All21175 artifact bytes are hash-verified locally. The selected implementation is
the exact existing `misc/s06_map_Hgg_local.wls` source5c5df155, executed here with
Hoffman2 native versions. The consumer
`common/s08_map_Hgg_selected_inputs.wls` has SHA256
`74d62bafead0b9ccea9495c98c8fdb6b98e5585a98d98cac7e1221b0511424b7`.
It requires this comparison, installs its exact saved definitions and preserves
the monolithic fallback. It also retains the accepted shared-piece optimization,
all coefficient checks and scientific checkpoint identities. The running earlier
entry is separate; this reader is for subsequent checkpoint continuations.

### Bounded loop-monomial cache comparison contract

`common/s08_check_monomial_cache.wls` compares original, cold-cache and warm-cache
mapping of the same saved component8/group1 input and all its accepted coefficients.
Only the loop-monomial conversion dispatch changes; the conversion itself is
extracted from the exact existing accepted family source, with reversible local
symbol renaming. Cache keys bind the complete shifted expression and variable list;
a hit additionally checks the exact stored input. The cache is in memory only,
bounded at64MiB per worker. The complete family coefficient assembly, independent
accepted own output, reconstruction and cut gates remain. Production use requires
an executed exact comparison and a measured useful saving; lack of a saving leaves
this as a comparison result, not a production optimization.

The bounded monomial-cache comparison14908308 passed exact own coefficients and
all reconstruction gates, but **did not show a useful speedup**: original3.405088s,
cold3.378276s, warm3.429458s. It is not installed in production. The25 stored
conversions occupied110520bytes; the in-memory cache ended with the job and no
mathematical disk cache was created. Do not treat this candidate as an accepted
speed optimization. Source6c9970c948c3675064fe295f7763fb4a6e702e7eb652d22e8da2198a7d0a15fc;
under `s08_monomial_cache_result`, resultbf82851f2597cc1688b64a2c21f6aef44b01ff46f7511ba5abb4441c5c272e92,
checksa2c3a3825e3047492f5ad39b0fae07ccb29bdb8e3af4ef080c37766df8240cbc,
receiptff9cbb720a465b4cfca0b38bd4fe8c19e4dc9b6f391682b7949e541611421740.

### Additive reconstruction correction contract

The inherited polynomial-piece reconstruction check reported a failure in the component39/outer1/group21 interval of job14906378. The focused stage common/s08_check_Hgg_additive_reconstruction.wls must reproduce the original decision on the actual accepted native input, export its equation and residual, and establish exact rational reconstruction plus unchanged own accepted coefficients before the candidate check may be installed. Existing passed mappings retain their original checks; no affected failed-group output or final Hgg export is accepted.

### Accepted actual additive reconstruction correction

Hoffman2 job14908667 (entry common/s08_check_Hgg_additive_reconstruction.wls SHA25661071a42a311a84ebdbf30fdb33bd7b9e8d9c86c21a17172b4e1b5004ddfd221; confige34bc62e1b83ff08ca61a97d451b2e2ebe6095f480eb826538b4b27bcedab36d) reproduced the original false Expand decision on component39, outer1, group21, denominator powers {0,2,0,0,2,0}. The native complete rational difference is exactly zero, with unchanged own accepted control coefficients and all reconstruction/cut gates retained. The original test took13.238905s; exact rational reconstruction301.117968s; own coefficient comparison0.464584s. This fixes the decision only; splitting, family coefficients, cut conventions and cache scientific identities remain unchanged.

Accepted artifacts under Hgg/s08_additive_reconstruction_result: s08_result.wl b7dde18f5f9d0532c17352e27a87df302482c27de820a2d51e1cd5af27949478; s08_input_equation.wl4cda50d89a117b0a7607ab0bb25cc299635f13bb47505b150d0cc84c40767074; s08_reconstruction.wl6418852896cd946d0202f80b2c1891421d01c8d45c648f93cddcd5a8eb7e56e9; checks0378929c806d1df6145eaa6691a2ca5c1cc93143b44bd72b9030fe8e1b90486c; receiptc6cef86ad140833ea96d4ef74b8c3ee50acaf25eaa4094e8bd5743d96a55f50e. All five compact artifacts are hash-verified locally. The native equation-only export14908752 also passed exact reload; readable equationde5e9e7c1ab0b72a917a60baabc54a0901ef01b731b26a09e72260da5131366d,618656 bytes. No failed-group map or Hgg finite coefficient was accepted by these checks.

### Accepted reuse of the exact additive identity

Hoffman2 job 14909202 accepted reuse of the complete identity already proved by
14908667. The cached decision took 0.037413 s versus 301.117968 s for the original
exact rational reconstruction. Installation took 0.070154 s; the literal native
input occupied 71808768 bytes within the 256 MiB bound. The generic exact checker
was preserved by exact definition comparison, actual and own-control predicates
matched their accepted outputs, and native export/reload passed. This timing is
for that identity only. It does not establish a whole-channel runtime.

The exact comparison configuration is
`.cluster/s08_Hgg_additive_certificate_exact_20260925_job.json`, SHA256
`385712651000e9213e14d1b59d4f22460a3ee658e1a147dceff333172b9bdf5d`.
Artifacts under `s08_additive_certificate_cache_result` are:

- `s08_result.wl`: `0f1aa99d48f5473f7ba5c992b79721dce638fc5433d7aeb2e02851658dd152b7`.
- `s08_checks.json`: `801f960bd8fe605297e6ad884ed96820ab35e0979a4aef01f0206d01f94febb1`.
- `s08_execution.json`: `87804978c161d1ce0935f897ca9e694ecbe4c336e83989a6d452df1b82be29c4`.

`common/s08_map_Hgg_exact_additive.wls`, SHA256
`9c259ac9390bbdd8d0052258c2c75d045fe6d1548f11950c2fece9ad269d3b0a`,
requires both accepted correction and reuse receipts, exact original definitions,
scientific input hashes and native versions before installation. It retains the
selected-entry reader and shared polynomial checkpoints. It changes no splitting,
family coefficient, normalization, measurement or cut convention. Complete mapping
and the S12/S14/S15 gates remain required before a finite Hgg export.

Production integration14909304 rejected the optional cached identity at its complete-input contract before component mapping. The isolated14909202 timing is valid only for its comparison and does not authorize production cache installation. That optional installation is withdrawn; source9c259ac9 is preserved under common/s08_result/reference/s08_map_Hgg_unaccepted_cached_identity.wls. The direct accepted correction consumer common/s08_map_Hgg_exact_additive.wls is restored with SHA256fe08e56d0a4f0a22080f160584b27145e96fa9557c2431bd5740b55d1a4f94a6. It uses the exact generic checker accepted in14908667, keeps selected-entry/shared-piece reuse, and preserves all scientific checkpoints. No component or finite output was produced by14909304.

### Disjoint batch dispatch contract

A partition dispatcher may reuse the complete accepted direct mapper
`common/s08_map_Hgg_exact_additive.wls` (SHA256
`fe08e56d0a4f0a22080f160584b27145e96fa9557c2431bd5740b55d1a4f94a6`).
It must derive disjoint component subsets from the native task inventory, retain
the separately accepted component-13 boundary, and prove that the subsets cover
exactly the existing remaining-index set. Component and numeric-phase checkpoints
remain in their original scientific namespaces. Polynomial writes must use a
job-and-worker-specific `kernel_*` folder, preserving the accepted shared reader,
input binding and atomic writer. Own-control and final subset outputs must also
be separate for each batch. Every mapping and coefficient equation stays unchanged.

Before dispatch, a native interface run must verify exact source restoration,
the actual accepted own-group coefficients on a cache miss and hit, native
serialization, worker namespace separation and complete disjoint task coverage.
A subset result is not a complete target map or a finite F hat. The existing full
mapping/target assembly and S12/S14/S15 acceptance boundaries remain mandatory.

### Accepted disjoint batch dispatch

Hoffman2 job `14910580` accepted `common/s08_map_Hgg_partitioned.wls`
(SHA256 `cdf9518ee3ac9a54ca865cfb867f3b28a9bacf91589e439957c72165219a388e`).
The configuration is `.cluster/s08_Hgg_partition_compact_20260925_job.json`,
SHA256 `0e0608ec9b7351f4de6a5c3b354782c289de59bf5738a0114f5282871ecafeb7`.
The native run preserved the complete polynomial mapper and atomic writer,
reproduced all accepted own coefficients on a cache miss and hit, reproduced
the complete own Hgg map and fresh reference control, and verified exact native
serialization. Both workers reproduced the own group and wrote to distinct
job/worker directories. Native partition coverage retains the separately
accepted component 13 and covers every remaining component exactly once.

Under `s08_partition_interface_result`, the accepted artifacts are:

- `s08_result.wl`: `55998b53774a030333b721acc72ab07bfc46d8354b816a8f02a9172639f11dc3`.
- `s08_checks.json`: `bc9ebcd98d2cff4d01d1cce0334abe2ec1d6c625f616aa2c97dbc8125554f892`.
- `s08_execution.json`: `be706eff22c94b4f24d6ab6b88dbe6e921fe31420f7e0eb306284d66b2e2c9a1`.

The complete own-control artifact is
`s08_partition_interface_control_result/s08_result.wl`, SHA256
`52eb99fb4f2b2b90ea51ba1f41ff1b64a1af1a7384d684b60de7c82ba6af04d7`.
All these files are hash-verified locally. Whole-job runtime was
632.464159514 seconds, with 2884071424 bytes peak observed process-tree RSS.
The own-group miss/hit timings were 4.478485/0.437471 seconds; these are fixture
timings, not a full-channel speed estimate.

Production subsets use `s08_partition_01_result` through
`s08_partition_04_result`, with separate corresponding control owners.
Component, grouped and phase checkpoints keep their original scientific
identities; polynomial writes use job/worker directories read by the accepted
shared reader. Production requires the accepted interface receipt, exact
source/input identities and unchanged complete definitions. After all subsets
pass, the unchanged direct mapper must close the canonical complete-map owner
before target assembly, full reduction and the existing finite-export gates.
This interface result does not contain finite Hgg F hats.

### Exact outer-phase cancellation comparison contract

`common/s08_check_Hgg_outer_phase_cancellation.wls` compares an early native
scalar-distribution decision against the completed component43/44 maps and
the accepted nonzero component8 control. It distributes only exact numeric
outer factors across existing terms, proves the formal identity and its exact
specialization to both complete actual expressions, and bypasses mapping only
when the prepared native expression is identically zero. All other expressions
retain the unchanged original numeric-phase mapper. Preparation is bounded at
120seconds and2GiB additional memory; a bound falls back to the original mapper.

The accepted partition bootstrap, complete original mapping definitions, input
hashes, native versions and existing own/reference controls remain binding.
Comparison and own-control outputs use private `s08_outer_phase_cancellation_result`
and `s08_outer_phase_cancellation_control_result` owners. Production use requires
exact accepted-output agreement for both actual zero maps and the nonzero own
control, unchanged original definitions, exact native reload and measured useful
runtime reduction. A completed comparison is not itself acceptance of a speedup
or a finite Hgg F hat. Current production jobs use the unchanged accepted mapper.

The first outer-phase comparison14912204 completed but did not accept a shortcut:
nonzero own output agreed, while both actual preparations reached the2GiB
temporary bound. Sourceb79fbcdb is preserved as
`common/s08_result/reference/s08_check_Hgg_outer_phase_before_hash_trim.wls`.
Under `s08_outer_phase_cancellation_result`, resultb128994a5007738e39180e48874e20ab4dec5430dad0be310d98d7808dfc0409,
checkse2c88e22f0521f940c21a21286a7c32ac88092b046964bf2f685b9fa59c45d5a,
receiptc614060dcef8d61211c7c2e1054b4fcdc9523cd18f253e459bbbbf4368b8b8ac
are preserved locally and are not production acceptance. No production mapping
was changed. The same comparison with duplicate return-metadata Hash calls
removed uses private `s08_outer_phase_cancellation_trimmed_result` and control
owners. It keeps the exact scalar identities, zero-only criterion, original
fallback, input bindings and2GiB/120second preparation limits. Acceptance still
requires both actual complete maps and nonzero own comparison plus measured saving.

The trimmed outer-phase comparison14912281 established exact scalar distribution
without the temporary memory failure, but neither actual43 nor44 became zero.
`Accepted` remainsFalse. This candidate is not installed in production. Its
private `s08_outer_phase_cancellation_trimmed_result` preserves the executed
negative result and unchanged nonzero own control; no physics checkpoint is
invalidated by the comparison.

### Actual component38 failed-group input contract

The production14911505 log identifies ExtendedResponse{4,1,5}, outer term2,
group5, denominator powers{0,0,1,0,0,2}, as exceeding the mapping memory bound.
No complete component38 result was produced. Native input export must reuse
the accepted selected reader, coordinate substitution, numeric-phase selection
and compact grouping, assert this task/group ordering against the log, and
export the exact group equation, additive pieces, current relevant definitions
and input identities with exact native reload. This is an input artifact only;
it cannot authorize a map, reduction or finite export. Other valid component
and group checkpoints remain reusable.

### Input-derived affine family coordinates

A bounded correction comparison may choose a temporary affine loop basis from
positive powers present in the exact saved component38 group5 numerator. Basis
selection, inverse rules and both composition checks must be performed natively.
The actual expression must round-trip exactly, and the derived family-coordinate
rules must compose to the original rules. Only the local family polynomial
variables and substitution may change; global integral families, denominator
selection, coefficient assembly and all Laurent/atom/merge certificates remain.
The complete original family source must be restored by reversing those edits.

Acceptance requires every coefficient of the saved nonzero own group to agree,
all pieces of the actual failed group to map within the original4GiB operation
bound, their exact full linear reconstruction, unchanged mapping/certification
definitions, and native result reload. Private comparison checkpoints may be
resumed only with exact source/input/basis/version identity. No production
checkpoint or final coefficient is accepted merely because this comparison starts.

The affine comparison split check uses a native formal distributivity identity,
with exact specialization to the entire original equation and every ordered
actual piece. The selected factor and unchanged piece algorithm are checked
directly, avoiding full multivariate expansion solely to prove this split.
All coefficient, family and input round-trip gates remain unchanged. The revised
comparison has private owner `s08_affine_piece_basis_result`; its native exact
input and own-output acceptance are still required before production use.

The native affine comparison14912378 is accepted. Source
`common/s08_check_Hgg_affine_family_basis.wls` has SHA256
`8fa1b1c2569fb6cdd7053447cd1217f8d21e2e78cebd136eab6db6980b2a1d0a`.
Under `s08_affine_piece_basis_result`, result291e3969c71f7536ddb3160e6961d4143a7c915b7972d4099b112454a8263716,
checks3080d600afe3262c55a7cbf084fa45122c4e09fccbbae8dd63c722746e58b3d4,
receipt7f47c6781507e713e6e64b2d6bd86ca90918c3c89c8d7064e6128f7fbfe8e9e3
bind the exact failed inputd683e891. Own complete coefficients agree. The actual
group completes in6.425514s, with two piece timings2.841903/2.921847s and native
peak1341230600B; the complete comparison job takes60.254439133s. Native selected
forms, inverse and all reconstruction gates are in the proof. This resolves the
failed group within its original4GiB bound; it is not a finite F hat.

`common/s08_map_Hgg_affine_partitioned.wls` installs those exact family and split
certificate definitions after the unchanged accepted partition installation.
It must reproduce the entire live piece function before replacing only its
reconstruction decision, exercise both saved own and failed-group equations
through the actual production reader/writer, and compare complete coefficients
with the accepted proof. Existing scalar geometry, group/piece identities,
component dispatch and worker own/reference controls remain binding. New helpers
and derived coordinate rules must reach every worker before dispatch.

The affine installation gate compares the saved proof with production before
changing definitions. `s08_check_Hgg_affine_contract.wls` reports each saved
contract field and prints differing native family/mapper entries against the
exact accepted production artifact chain. It cannot accept a physics output
or authorize removing a failed identity check.

The affine geometry installation must use the existing Hqg recursive exact geometry comparator: identical key/order/list/rule structure, and native exact rational equality for differing scalar expressions. Production retains its original global family object and requires it to remain structurally unchanged after installation. The private s08_affine_geometry_contract_result reports every original guard plus this complete native equality and uses the existing exact compressed serializer. Plain-text diagnostic14912425 is unaccepted because its reload failed; it produced no physics output.

Hoffman2 job14912444 accepted the complete affine installation geometry contract, including native equality of all family entries, every original fixed definition, input identities and exact report reload. Source common/s08_check_Hgg_affine_contract.wls SHA256401f1849c598e789dc73a9143e3f0416306033f48e65cccbc343f877dfb49b55; config33f01ca4bc62545b27d6c676d17536f9f96d01ae0bc130a6c78581c98b2cad00. Under s08_affine_geometry_contract_result, result e3c211a1618e065cca95309add4c4a65b48179d47e55f4b202d3056e45fbe672 and receipt c860381b5cd6fdda86fd596cd4096a0661f684db4ab2981d478f3760ce1b0a28 bind the executed check. Differing noncanonical representations are recorded as InputForm text; their native exact comparison flags are unchanged. This is an installation contract, not a coefficient result. The corrected consumer common/s08_map_Hgg_affine_partitioned.wls SHA25620045e89edbfdc0a4f00c30e4559ccbcd76fb5bd33e3e53736e53692443edc3f retains the complete production own/actual coefficient checks before dispatch and leaves the original global family object structurally unchanged.

A focused slow-input export may reuse the complete accepted component reader/grouping implementation for native component37, outer1, denominator group34 (the exact powers and group order must match the production log). common/s08_export_Hgg_slow_group_input.wls writes only the exact input, definitions, identities and readable equation to s08_slow_group_input_result, with native exact reload. Selection uses the accepted task inventory; no equation, mapping cache, current production definition or finite coefficient may change through this export. A performance change would separately require actual-input reconstruction and own accepted-output equality before use.

### Polynomial-content comparison contract

The isolated common/s08_check_Hgg_polynomial_content.wls comparison uses the exact saved37/outer1/group34 input and accepted affine family definitions. Native FactorTermsList extracts loop-independent content in the already accepted affine coordinates; full numerator expansion equality, exact coordinate round trip, complete factor partition and original-variable-only output gate each preparation. The original scalar mapper, integral families and reconstruction certificates remain unchanged. Acceptance requires exact complete own and component38 group coefficient comparisons, complete actual37 mapping/reconstruction within4GiB per operation, exact native reload and measured useful performance before any production installation. s08_polynomial_content_result is a private comparison owner; running this comparison does not change production caches or establish a finite F hat.

The polynomial-content candidate is not accepted for production. Native14912626 preserved own and accepted38 coefficients but extracted only factor-1 from the first actual37 polynomial, leaving19173304B→19173208B. The job was stopped before wasting a complete slow remap. Its log/submission retain negative evidence; no production output is invalidated.

The isolated common/s08_check_Hgg_affine_cancel.wls comparison changes only the original scalar mapper Cancel call to evaluate in the already accepted affine coordinates and restore original coordinates. It requires full original-input round trip, native exact rational cancellation identity, output restoration identity, exact reversal of the entire scalar mapping definition and all unchanged family/scalar gates. Accepted own and38 coefficient comparisons plus complete actual37 reconstruction, native reload and measured performance are required before production. Private output owner s08_affine_cancel_result; this is not a finite coefficient stage.

Early-Cancel comparison14912644 is unaccepted: its newly added cancellation check incorrectly used Cancel on a difference. Sourcece419d1f is preserved as common/s08_result/reference/s08_check_Hgg_affine_cancel_before_equality.wls. The corrected check uses the existing reference zero function, Factor[Together[difference]]===0. The mapping algorithm, all input identities and resource bounds remain identical; private output owner s08_affine_cancel_exact_result prevents reuse of the failed comparison. Production is unchanged.

A production early-Cancel entry may extend the unchanged accepted affine partition entry only after s08_affine_cancel_exact_result has a passing execution receipt and exact native reload. It must bind the proof, producer, actual slow input and affine proof by hash; compare the complete original/fixed definitions; install precisely the saved earlyAffineCancel and candidate externalOriginalMap definitions; reverse the Cancel-only edit exactly; exercise the production piece interface against accepted own and38 coefficients; distribute the new function and its basis dependencies before dispatch. Existing group/component cache identities, cut/geometry conventions and final assembly gates remain unchanged. The completed actual37 group may be reused only through a separate exact input/group binding, never inferred from a filename.

Hoffman2 comparison14912650 is accepted: source8d907ac032714de63957955887333c9fb2b448646c081c5e63895c7703659aa4/config324fe7df01f7e62098633caf48e1318d74e52bb7e901442281b365723ba2fdda. s08_affine_cancel_exact_result/s08_result.wl SHA2562799ab7216e0317454e0fbdc51f57269860f9e04edb612973183fcad2e43f054 and checks e3eb36f45063e198a3f4730e84e9089af1ddc16433e7e9765ddca38ce94ad482 preserve native exact input/cancellation/restoration identities, own and accepted38 coefficient equality, complete actual37 mapping and exact save/reload. Native own/known38/actual37 timings are (1.389768, 3.03964, 217.604265) seconds. Actual37 pieces95.795376/101.876868s; peak tree1542098944B, total job271.103844s. Proof source/formats and scalar/cut gates are binding for production early-Cancel entry. No finite Hgg F hat is claimed by this optimization acceptance.

The early-Cancel production installation was accepted in14912694: complete original/fixed definition bindings, native own and accepted38 piece-interface coefficient comparisons, absence of temporary coordinates and unchanged scalar certificates all passed; interface time4.877641s. Production entry common/s08_map_Hgg_early_affine_partitioned.wls SHA256baad8ab821ddf00a3a2d92a7383046ae4ff5bd6afd62aa46433d81a493982b88 installs the exact accepted helper and preserves all scientific checkpoint bindings. The native proof and source hashes above authorize its reuse on remaining disjoint partitions.

### Dimensional-metric extraction input contract

`common/s08_export_Hgg_metric_input.wls` uses the accepted selected-reader and
coordinate-conversion setup to select the original `PhotonMetricD` task from
the native inventory. It must retain the complete equation, reproduce its
numeric-phase term inventory, and identify the terms rejected by the existing
explicit-polynomial numerator predicate. Its readable output records the actual
rejected term, numerator, denominator and loop-dependent non-polynomial powers.
Input, producer, reader, native-version and complete reload checks are required.
This is an input export only: it does not change S05, accepted component maps,
the extraction algorithm, or the final assembly gates. Any extraction fallback
must separately reproduce the accepted own coefficients and reconstruct the
actual metric input before production use.

The input export14913061 passed native reload in75.303896s and reproduced an
empty list for metric task98. This is failed-reader evidence, not a physical
zero or a valid metric equation. Its result39bbf5b9f1eacef6ebca02a51784ff5e1ce9ac3aef96d79f033ce8f2388f859b,
equations5070b9b2a9f430eec3a4f173bbe6d50d7a3456012ae2660791c939353a7c283b
and receipt4708d6195f714ff0640edab24a04c26650716c6e443eb3c412ac264fa288900b
are retained under `s08_metric_input_result`. The S08 component reader ends in
`Extract[hggCachedValue,row["Index"]]`; its scalar task has an empty index.
The original S05 loader instead returns the metric payload's `Value` directly.

`common/s08_check_Hgg_metric_reader.wls` must reproduce that empty-index failure,
change only the scalar return to the whole field, and compare the full corrected
metric value with the original S05 loader. It must also reproduce the accepted
own response equation and retain the complete original reader under exact
source reversal. Original payload checks, task inventory, contexts, native
versions and scientific input identities remain binding. Its comparison proof
requires exact reload; no mapping or finite coefficient
is accepted by this reader comparison. Existing nonempty-index response maps
remain valid, and their mathematical contents are not changed by this fix.

The production consumer `common/s08_map_Hgg_metric_partitioned.wls` extends the
accepted early-Cancel partition entry. It changes only the saved scalar fallback
reader after the selected-response installation, requires full source/input/task
and accepted-proof identities, and installs exactly the native reader definitions
that reproduced the complete original S05 scalar. Response dispatch, mapping
equations, worker distribution, checkpoint identities and downstream gates stay
unchanged. The canonical target collector reuses accepted component maps; the
compact coefficient consumer removes tensor values after requiring nonempty
accepted reconstruction checks. Those consumers need no mapping-algorithm change.

Reader comparison14913108 reproduced the full S05 scalar successfully but then
exhausted memory in an unnecessary scalar hash/coordinate-export block. It is
unaccepted and produced no component map. The corrected comparison removes that
unused block, clears scalar values before the own-response comparison, and keeps
both complete equality tests and the full reader/source restoration checks.

Hoffman2 comparison14913146 accepted the corrected reader in150.757629s with
3145138176B observed peak tree memory. Source19d3e2e34ceaf52c46bb954d09dca5069306b972eeb2764ae56339072c84878c
and config6e71ab41a8a74e52174041e4ced96a5d1de0571b7c56e0e1d29b41bc4fb78401
bind the executed comparison. Under `s08_metric_reader_result`, result
a25f0d5a504c02753e14b191d07e0ac47adbaeaf8aa1d71d3515f2cd78dd7ab3,
checks7a1e569fab0335469d6ae2a036298541d53ca0861fc642649ee11352ccbf8ec9
and receipt58d6a459a88af509f4130c6d2a72b7f51d6e0adcc8e8459f3a6ecf2d6f4dde0d
are copied and hash-verified locally. Native metric size799899408B; complete
scalar and own-response equality checks passed. Consumer
`common/s08_map_Hgg_metric_partitioned.wls` SHA256177ae0baf676d0c9751e67c432e230d7ec911d1c60d01cebe35bebc6499e97a0
must install exactly these accepted reader definitions before mapping task98.
This proof accepts the reader only; task98 mapping and finite Hgg export remain
subject to their original reconstruction and assembly gates.

Production14913204 and14913210 accepted the complete reader installation against
the saved original/fixed definitions, input/task hashes and proof receipt. The
selected-response dispatch remained unchanged. In14913204, actual metric98 then
passed original rational reconstruction, numerator/denominator polynomial tests,
generated-propagator support, denominator-scale reconstruction and polynomial
numerator extraction. This resolves the empty-index reader failure at its
origin; acceptance of the entire metric map still requires the later mapping gates.

## S08 metric spin-polynomial comparison contract

`common/s08_check_Hgg_metric_spin_split.wls` reads the complete corrected S05
metric through the accepted reader, derives its denominator groups unchanged,
and selects an already accepted production group by its full input binding.
The spin variables must come from the accepted S05 `ComponentStorage` metadata.
Native polynomial coefficient extraction must reconstruct the entire group
numerator exactly and leave a spin-independent denominator. Map each scalar
coefficient with the unchanged accepted early-affine mapper, restore its spin
monomial, and require the complete merge certificate and equality of every
coefficient with the accepted metric-group cache. The comparison retains
all scientific input identities, cuts, coordinates and normalization.
Measure the actual group runtime and expression sizes; no production use is
authorized by this contract alone. Its isolated owner is
`s08_metric_spin_split_result`; completed production caches remain immutable.

Comparison14913365 rejected the literal Expand-only zero decision before any map.
The corrected comparison uses the existing S05 spinMap predicate
`zero[Expand[numerator-reconstructed]]`, preserving exact rational coefficients.
Its owner is `s08_metric_spin_split_exact_result`; the earlier source and
input export are retained as unaccepted-comparison provenance. No production
algorithm or accepted result is changed by this correction.

A metric spin-split production consumer, if the complete comparison passes
and records `SpeedupObserved -> True`, may install only its exact saved
piece and mapping definitions. Derive its spin variables from the same S05
metadata and require exact current scalar/family/cut definition identities.
Retain the original piece mapper for spin-independent response inputs; its
worker cache controls and accepted component/group caches stay unchanged.
Before dispatch, exercise the spin branch with a native saved spin variable
times the accepted own group and compare every coefficient with the unchanged
accepted group times that same variable. This is an interface check; the
actual spin-dependent metric comparison remains mandatory.

## S08 metric group parallel-dispatch contract

`common/s08_map_Hgg_parallel_groups.wls` may change only the independent
group table to ordered native `ParallelTable` after the existing allocated
workers and fresh-worker reference gates pass. Execute the component loop
on the main kernel so no nested parallelism is required. Preserve the
complete group mapping body, binding hashes, original checkpoint paths,
worker-private piece files, serialization, cut and reconstruction gates.
Require exact reversal of the native table change, then complete accepted
own-input agreement between the original serial and parallel group functions
before dispatching the remaining metric. Explicit `Global` definition
distribution supplies the group-local values; FeynCalc is already loaded
by the unchanged worker initialization. Keep the same scheduler and native
memory/storage limits. This is scheduling reuse, not a new scalar-map algebra.

Native spin comparison14913387 passed every full accepted metric-group coefficient and native export. Result fdb6af496931b7f12c821aef3b744bda8370d112772c08fde03137c40af78ffb, checks ad28f182d29b659c06ef4c794f48e89c696a480cdc54e3456829ff72010f95ed. Original1239.205176s; candidate1519.92336s; SpeedupObserved=False. Retain the accepted original early-affine mapper; the spin-split consumer is not authorized for production by this result.

Production14914444, config258b2a4b80f4ddb14d6cb9990f1b4ac6c68fa5812d7d8f4c536c26e0852d1f87, accepted the dispatch interface in sourcee253c1c98bee506809e5f3da408521f63aec693b5116b39645022818f1f914c5. Full serial/parallel own coefficients agree; scalar/group/cache/serialization definitions are identical. Four existing workers are used; own cached times74.58388s/124.773313s are interface measurements, not a production speedup claim. Keep all pre-existing group bindings and checkpoints. Full metric and final finite export still require their original gates.

### Per-integral metric merge contract

`common/s08_merge_Hgg_metric_groups.wls` will reuse the exact per-integral
`mergeKey` and `mergeSave` implementation from
`common/s08_check_pair_merge_linearity.wls`, bound to its accepted Hqqbar
execution. It must retain the original `merge`, group mapping, input bindings,
cut and reconstruction predicates, and match the entire accepted Hgg own-control
map before merging the metric groups. Only the outer group merge is distributed
across the allocated workers; each integral coefficient is independently bound,
reconstructed, saved and reloaded. Completed group maps remain inputs. The
component dispatcher runs on the root kernel to avoid nested parallel work.
This contract does not establish an accepted optimization or finite F hats;
acceptance requires the executed own-output and full production gates.

### Exact reuse of per-coefficient merge checks

The pending merge consumer may reuse the worker reconstruction checks for its outer denominator-group merge only after binding the exact group inputs, returned coefficient association, and every native coefficient checkpoint. The original formal `certifyPairMerge` remains required; all inner scalar/group certificates retain their definitions. The candidate must reject changed input or output identities and reproduce the original complete accepted own Hgg map before processing the metric component. This is a pending execution contract, not an accepted optimization or finite F hat.

### Bounded local coefficient merge

The user reauthorized resource-safe local continuation on 2026-09-25. The local
`misc/s07_merge_Hgg_coefficients.wls` reads hash-pinned saved group maps directly
and reuses the accepted original merge, per-coefficient reconstruction and atomic
checkpoint implementation. It must reproduce every coefficient of the accepted
complete Hgg component8 from its saved groups before processing the metric groups.
Local Engine15 and imported cluster13.1 provenance remain separate. At most two
workers, a10GiB process-tree RSS ceiling,4GiB available-RAM reserve,8GiB disk
reserve and bounded individual operations protect the laptop. Outputs remain
under `misc/s07_result`; this arithmetic merge does not replace the full metric
input/group binding, cut/reconstruction certificate or downstream finite gates.
A cluster consumer must bind the same original group files and verify each
imported coefficient against its actual complete native input sum before reuse.
No local timing improvement or accepted metric result is established by this
contract alone.

### Local component-wise target collection

`misc/s08_collect_Hgg_targets.wls` may reuse the unchanged initialization from
the accepted local S06 implementation to bind the original scalar geometry,
grouping definitions, task inventory and scientific hashes. For the metric it
must read the actual S05 scalar payload, apply the saved coordinate rules,
derive all denominator groups and match every imported group's complete input
binding. The accepted local S07 coefficient records must match their exact
input packets and saved output hashes; retain the original formal merge
certificate and physical-cut check. All other components are read individually
from hash-pinned accepted raw caches, with complete task/input/check identities.
The collector retains raw coefficients in separate files and exports their
identities, complete target inventory and unchanged bookkeeping. This storage
interface requires an explicit component-wise consumer and is not a finite hat.
Local runtime and imported runtime provenance must remain distinct.

The local `misc/s09_reduce_Hgg_targets.wls` reuses the complete original
reduction initialization up to executable selection and the accepted compatible
and subset rule installation functions. Only authorized local runtime checks,
the file-backed map source/path and explicit imported-runtime comparisons change.
If the combined accepted rule library covers every derived target, the original
basis/baseline/coverage gates accept the selected rules without running Kira.
Otherwise it exports the actual uncovered inventory and does not accept a full
reduction. Preserve original reducer identity separately from local dispatch
identity and never manufacture a Kira execution or executable hash.

### Local master-coefficient storage contract

`misc/s10_reduce_Hgg_coefficients.wls` retains the complete reference mapping,
master-coefficient sum, rule reconstruction and per-master checkpoints from
`common/s08_map_real_spin_compact_inputs.wls`. Its source-change manifest records
the local runtime and file-interface changes. Read only the hash-pinned raw file
for the current component; require exact equality to the collector metadata and
raw target inventory. Preserve every reduced coefficient and downstream metadata
field when omitting the already saved raw coefficient values from the assembled
output. Run the original fresh-worker accepted coefficient comparison; retain
all actual rule and term reconstruction checks. Use at most two local Engine15
workers and record the imported Engine13.1 conventions separately. Outputs and
checkpoints remain isolated under misc until acceptance. This pending storage
change establishes no mathematical speedup or finite F hat.

### Local real-emission integration contract

`misc/s11_assemble_Hgg_real.wls` invokes the complete reference S12 factored-series
routines with local runtime, paths and native compressed storage. Keep every
original master product, phase-space normalization, branch, endpoint, regulator
coverage and own-output comparison. Imported Engine13.1 proofs retain their
recorded runtime; all new controls and integration run under Engine15. The
actual local master-coefficient receipt is mandatory. Two workers use isolated
`misc/s11_work` caches; `misc/s11_result` contains distributions and own-control
artifacts. The source-change manifest makes every runtime/storage edit explicit.
Acceptance requires executed full component and native round-trip checks; finite
F hats still require subtraction, pole cancellation and final export.

Accepted local S07 arithmetic merge: source 74e2b702715928bfc281bce448ef091c45923a254e6db09d5e77c44996d6ed62, result 9145abe0b2ef5a24fb2e9a10e219fdc32c96df7884f48b18b9f1cd6ce0022842, receipt 2c35b81cf98dbb4ef8d788fa62ba3fab04be1598a814841c47214ec7a9299e2b. All 249 metric coefficient records and all own-control coefficients passed original reconstruction and native reload. Metric merge 2329.642655s; own comparison 26.181019s. Complete metric input bindings and final finite gates remain required downstream.

### Local finite assembly contract

`misc/s14_assemble_Hgg_finite.wls` preserves the native Hgg subtraction adapter
and complete shared finite assembly, including every independent pole, branch,
charge/coupling and unpolarized F1/F2 comparison. Its real input is the accepted
local integration receipt; the existing S05 lazy loader supplies the unchanged
frame. Imported phase proofs retain their original runtime identity. Only local
execution, input/output paths and explicit new runtime provenance change. Keep
intermediate pole records under `misc/s14_work` and bounded native exports under
`misc/s14_result`. Final scheme conversion and F-hat export remain mandatory.

### Local final export contract

`misc/s15_finalize_Hgg_hats.wls` preserves the complete Hgg exporter, accepted
dimensional subtraction and helicity conversion, with an authentic accepted
local finite-assembly receipt. Keep every original finite-expression, basis,
reference and scheme gate. New outputs identify actual Engine15 and imported
Engine13.1 conventions separately. Only runtime and artifact locations change;
`misc/s15_result` must contain the executed final native result, F1/F2 hat files
and checks before any final Hgg claim or publication into channel-owned results.

The first local S07 arithmetic result is preserved under
`misc/s07_result/reference/before_path_correction`: its filename index omitted
the initial character of `misc/` because the directory string ended in `/`.
Every coefficient payload and arithmetic check remains unchanged. The corrected
S07 entry normalizes its root and provides an explicit metadata-only repair mode
that binds the archived source/config/result/receipt, verifies every unchanged
payload hash and corrects only file metadata. The complete arithmetic source is
compared exactly after removing the repair branch and root-normalization change.
S08 and S10 also normalize their roots before emitting relative file identities.
Use the corrected S07 receipt/index once accepted; retain the original arithmetic
provenance and all production coefficient caches. Native path review is
`misc/s07_result/s07_path_review.json`.

Accepted local S07 repaired index (original arithmetic retained): source eef36a7e8e34543a3a623acb7f9d8b5da97c7174e841ecfe8abd4484d2d8ec51, result 856fac8e74f8ba39c8a9723b943c39180580be702d38cf8b364e500ca2d8ebb8, receipt 7591b4961390520ff78dcf605c5ff86d65d7d43a0863e446c4c82dccb6b1c765. All 249 metric coefficient records and all own-control coefficients passed original reconstruction and native reload. Metric merge 2329.642655s; own comparison 26.181019s. Complete metric input bindings and final finite gates remain required downstream.

Metadata-only S07 correction accepted: source eef36a7e8e34543a3a623acb7f9d8b5da97c7174e841ecfe8abd4484d2d8ec51, configuration 1a76b711d0c23c73d52883d0022292d509466caaa3d226767d72c8931d7b45f3, corrected index 856fac8e74f8ba39c8a9723b943c39180580be702d38cf8b364e500ca2d8ebb8. All original coefficient payload hashes are unchanged, source arithmetic comparison passed, and the repaired index passed native reload. New receipt records execution_kind=metadata_path_correction; archived original receipt remains the arithmetic execution evidence. Native path and source review also confirmed the corrected S08/S10 file-key identities.

Accepted local s08 intermediate: source 154a228c6814cb5a430648bfd5eeb41c33ff859e92e5c5c2e49fecf6a203c1bb, configuration 282915482d754987227b4a281ecfc39a94166cb3276d3afafc78dff66c3abca5, receipt ce0c468aa50adfc79a2c46777d95563a4a797da49596030a575768dec10c5c1a. Executed checks all pass; actual local runtime and imported conventions remain separate. Artifacts: misc/s08_result/s08_result.wl SHA256 17ebe5990f1315ac29a5f85abf6a675e6a9a693567cc58bf4b66e8c9dbc2fc3b; misc/s08_result/s08_metric_map.wl SHA256 9702e0c84dbceb9efb5fffcd29262f06bb86e488bf030b21cac0fee94d2328f7; misc/s08_result/s08_checks.json SHA256 9b11f03bfc39e85adc8a8f3bcd63a8f9611ef9d266dc7e4ed03fc83f4242ef1b. Consumer must use the documented file-storage interface. Finite Hgg still requires all subsequent assembly/cancellation/export gates.

Accepted local s09 intermediate: source 12cfb2224a2fe30c84adcecbb595620954f8b12053ae260530c0437d6673f2fa, configuration 1a2b23b8ce5269d2bceb4037768f4b73a172daf3505e526fc901973bba1de3c4, receipt ab61c4881eff26f4ba891a9cbbc1bb2531081637ee6a223ee878146310b9c90b. Executed checks all pass; actual local runtime and imported conventions remain separate. Artifacts: misc/s09_result/s09_reduction.wl SHA256 e526df0a852f856c01088e649e5e0dc02f214a4b2877835a9792a501aa1d62ab; misc/s09_result/s09_checks.json SHA256 a5fb27b3687a5715fd978dae90cf75f1fdd9b3a24399fa484134578fb103612c. Consumer must use the documented file-storage interface. Finite Hgg still requires all subsequent assembly/cancellation/export gates.

### Local direct-reference coefficient comparison contract

The isolated `misc/s16_compare_Hgg_reference_sum.wls` comparison reuses the fully reviewed local S10 initialization and literal pinned GitHub `referenceCoefficients` operation. It binds the current S10 source/configuration and reads the actual first Hgg raw component and its program-selected first master. Its result is a candidate/timing record only; production is unchanged. Adoption requires comparison to an accepted own Hgg coefficient and a measured benefit. Native algebra is bounded to180seconds and monitored to2GiB RSS; no production cache is overwritten.

### Exact polynomial comparison boundary

`misc/s17_compare_Hgg_exact_polynomials.wls` and `misc/s18_sum_exact_polynomials.py` are isolated comparison code. Wolfram derives all rational terms and denominator factors from the actual S10 inputs, checks native text round trips and factor reconstruction, and binds the serialized equations. FLINT0.8.0 performs exact polynomial addition, denominator normalization by measured leading coefficient, and exact factor division. Each denominator embedding, sum update and cancellation reconstructs exactly. The native importer must reproduce the accepted reference coefficient before retaining a candidate Hgg coefficient. Production adoption additionally requires an accepted own-Hgg comparison and relevant timing measurement. No finite coefficient or scheme result is inferred from this comparison.

### Own-Hgg comparison for the exact polynomial sum

The S17 isolated candidate completed with original accepted reference control and exact termwise reconstruction, resultSHA256 `aaf79a1c86d209e7fb7588825baec86ef7fad7b9bb1242f7a54d18daf0afb32f`; backend time141.202794421s on406 actual Hgg terms. `misc/s19_validate_Hgg_polynomial_sum.wls` must compare all keys of the36 original own-component8 group maps with the accepted `OwnCoefficients` record, including zero sums. It reuses the unchanged S17 native transfer function and S18 exact backend and verifies authentic source/result receipts and each imported group hash. This comparison validates the summation algorithm; it does not by itself accept a finite F hat.

### Production exact-sum adapter contract

The unchanged exact backend `misc/s18_sum_exact_polynomials.py` passed all320 accepted own-Hgg raw sums in S19 and the406-term actual master sum in S17. The production adapter `misc/s20_Hgg_exact_sum.wls` must derive variables from each actual expression, stream native-verified polynomial term records to a bounded transfer file, validate backend input/source identities and reconstruct the native scalar coefficient. The transfer format must match the already executed S17 payload exactly on the same saved input before use. Zero sums retain the original contract; unsupported complex coefficients use the unchanged accepted native summation. Temporary transfer files may be deleted only after successful import; source/input/output hashes and reconstruction evidence remain in production coefficient checkpoints. The input/output schema for real integration is unchanged.

### Accepted exact-polynomial implementation

All320 own-Hgg coefficient comparisons passed in S19. The S20/S21 native interface review passed equality of the complete actual406-term transfer payload, equality of the imported candidate coefficient, and execution of the full adapter on the accepted reference control. Accepted identities:

- `misc/s19_result/s19_result.wl`: SHA256 `a94865b15b145f06e62bf03d91d5447e05020620f30f278b0f242680095b4bd6`.
- `misc/s19_result/s19_execution.json`: SHA256 `69672f86b0214505e4c669cfb1825efe807923b749ba6a5174ac45f68190d338`.
- `misc/s20_Hgg_exact_sum.wls`: SHA256 `c931b5dcd5725e80f04930686ce7cfd546b0093e12ad080adddd110caf1fb4dd`.
- `misc/s18_sum_exact_polynomials.py`: SHA256 `5a8af32c6fb25426ff5fc3dcf4e4bbd65fafa2f47815d2dd705d31dfdf7a53a7`.
- `misc/s20_interface_review.json`: SHA256 `268750b8ed1d0f9e6bad728844b5237d283e598050a1d159ad9c22a4c8a96ea0`.
- `misc/s20_result/s20_review_execution.json`: SHA256 `3f2039f600b1da0af575b854ca03b558e9688451b7472fe6f91725a3497b9b4e`.

S19 native execution passed, but its monitor had a postprocessing log-name error; the recovered receipt explicitly leaves exact wall time unavailable. S20 has a normal native execution receipt. Historical S16/S17/S21 loader comparisons used the original S10 source/configuration now preserved under `misc/s10_result/reference/before_exact_polynomial_sum/`; do not rerun those historical prefixes against the revised S10 and mistake a provenance mismatch for a mathematical failure. The revised S10 consumes their immutable accepted proofs. Local execution exports an empty scheduler job ID and explicitly records Engine15/local provenance. The production adapter changes only exact rational coefficient summation; the accepted mapping, reductions and downstream integration contract are unchanged. Finite Hgg acceptance still requires S11, S14 and S15 gates.

### Accepted output-check scope correction

The local S10 coefficient arithmetic is unaffected by the worker `AssociateTo::invak` warning: both output-projection tests evaluated true, but their bookkeeping was outside a local `checks` association. The exact correction is to scope the complete `localReducedComponent` function in `Block[{checks=<||>}, ...]`. Native S22 review used the original production `mapComponent` cache reader and a completed component, confirmed no message from the correction and exact equality of the entire returned coefficient record. The active executed source remains immutable; apply the saved correction to published code with explicit original execution provenance, without recalculating accepted coefficients. Accepted bindings:

- `misc/s22_result/s22_source_changes.json`: SHA256 `a584716902217036f51be3cdd7bb47613f1efe0daf960bcd8e79e649195f298f`.
- `misc/s22_result/s22_review.json`: SHA256 `b0b25beb5cbd8ddcd63b23659b5861a060d214e54994fb8c7f94a2933411e83e`.
- `misc/s22_result/s22_execution.json`: SHA256 `dca68de82873ae4a6ce1510bad29fca38a6443e1fb3e877fcf985712e98fa783`.

### Channel access to accepted local completion stages

These links follow the channel's existing shared-code convention and consume no duplicate result storage. They retain exact executed code, receipts, accepted results and the original `misc/` input identities. The local source files derive the same polarized-SIDIS root when entered through these channel links.

| Accepted operation | Channel code | Channel results |
|---|---|---|
| Metric coefficient merge | [s07_merge_Hgg_coefficients.wls](s07_merge_Hgg_coefficients.wls) | [s07_result](s07_result) |
| Complete target-map collection | [s08_collect_Hgg_targets.wls](s08_collect_Hgg_targets.wls) | [s08_local_targets_result](s08_local_targets_result) |
| Complete reduction coverage | [s09_reduce_Hgg_targets.wls](s09_reduce_Hgg_targets.wls) | [s09_result](s09_result) |

These are accepted intermediate stages. The existing shared collinear-kernel `s10_result` is a separate input and remains unchanged. Final Hgg F-hat publication requires the later integration, subtraction, pole-cancellation and export gates.

Accepted local s10 intermediate: source 8a4a355f817a66301ef6106535353db070d6d32c0215aef25e97c9808432a8e7, configuration dcc14d2421538f45836f35ce5b3fb961ea23532e43a9f1ef95a1c7eba37e8f0e, receipt f099722f8dacc57d202158d92e91a64ea845f680a49ffd71ccbee615ad677533. Executed checks all pass; actual local runtime and imported conventions remain separate. Artifacts: misc/s10_result/s10_result.wl SHA256 464a7b28544131645b126afc7115c549c9df3bf07fd91eed0ebab0f8194968bb; misc/s10_result/s10_checks.json SHA256 f8f70a52d3b03ad571ce5d7620c8f3b36f5296cb88c6b35d5bfa91df5421e3cb. Consumer must use the documented file-storage interface; remaining finite/export stages are still required.

### Published local coefficient code and accepted outputs

[s10_reduce_Hgg_coefficients.wls](s10_reduce_Hgg_coefficients.wls) and [s10_local_coefficients_result](s10_local_coefficients_result) provide channel access to the complete98-component coefficient stage. The channel entry applies the accepted S22 check-scope repair and its own source/configuration paths. Its complete source reconstructs exactly from the recorded baseline plus the saved transformations; native syntax passes, and the S22 actual-component comparison proves the complete returned mathematical record is unchanged. Source SHA256 e96ebb6cdab4dd44aaf69332668dc5b906c72a24fcdbe68f069a783602e6270b, configuration SHA256 f69782b7946ee05b99773fff67c4e02600f3582b90073995068c2a9f0b91a108, transformation manifest SHA256 2cb36a6fc2a6e39b003165a07b14c62159dff924ea44dee88cb0afadca9a18f5. The manifest now reports the correct published source hash.

The accepted coefficient result was executed by the unchanged `misc/s10_reduce_Hgg_coefficients.wls` (SHA256 8a4a355f817a66301ef6106535353db070d6d32c0215aef25e97c9808432a8e7) using `misc/s10_inputs.json`; its authentic receipt and all original input hashes remain intact. The corrected channel entry has not rerun the full coefficient calculation. The original transform manifest retains its historical stale source-hash label as immutable provenance; original configuration and native review bind the actual executed source correctly. The separate channel manifest contains the complete corrected transformation. Final integration continues to consume the original accepted result and receipt. This coefficient stage remains an intermediate, not a finite F hat.

### Retained master-product repair boundary

The first local S11 attempt did not accept any integrated result: component81/R02 failed the retained-order comparison between `laurentProduct` and the native polynomial product. The saved S10 coefficient result remains accepted. Inspect the actual native coefficient, master and retained residual before altering the integration implementation. Preserve the failed source/configuration/receipt; require exact reconstruction and an own-input comparison for a correction. No dependent finite Hgg output is valid until the corrected integration and final gates pass.

### Accepted exact-argument comparison repair

The captured R02 discrepancy is exactly zero after algebraically canonicalizing the arguments of `Log`/`PolyLog`, without changing those arguments or splitting logarithms. Native S24 proved every argument mapping, complete retained-product equality, and unchanged saved coefficient/master. Helper `misc/s24_canonical_Hgg_arguments.wls` SHA256 6970979493d320b9fe23a8accef519e9c0237dccb320920cede9ffc17a66151d, proof SHA256 3fe0de724d015a4bed7aaaf57822d6934d58a6f5a17e235433756d2e27209391, receipt SHA256 32e82cc9abd57b8889a4b95580cf659ffad6050010befce33e0b8d92aeda3a05. The helper is installed only in local Hgg S11 and distributed to its workers; all physical product, coverage, endpoint and own-reference gates remain.

S11 now saves the direct ordinary control immediately with a binding derived from the actual component, transverse substitution, master equations, original epsilon-series definition and native runtime. Its later original endpoint comparison reuses `OriginalValue` from the accepted own-comparison record only after exact component identity. No coefficient algorithm changes. The failed original source/configuration/log/receipt are preserved under `misc/s11_result/reference/before_argument_comparison`; historical S23 used those source bytes. No integrated or finite Hgg result was accepted from that failed run.

The complete ordinary-control comparison additionally required `Expand` inside each function argument before `Together`/`Factor`: native S25 captured products containing radicals and differently written squared factors. Expanded-argument S24 verifies exact equality of every argument, the full individual product and the entire saved ordinary result, with no branch transformation and no coefficient change. Accepted helper SHA256 0b04a1ec7d2898c1eb77fc2400d0c61ca45558f2e21695dad5b8141ecf33cf8a, proof SHA256 1ed61045d5ccd8692e7a1263cb335618d1bd63ea75fa3f9e3087a2e1d32452ee, receipt SHA256 b79f462a7036c3d671e8fdacf5fadce1a91016ee31d3be21677f72c4ae3f2bdd. The previous helper/proof are archived under `misc/s24_result/reference/before_expanded_arguments`; the second failed S11 source/config/log/receipt are under `misc/s11_result/reference/before_expanded_arguments`. Preserve the validated direct-control cache for identity-gated reuse. The S11 entry source is unchanged; only the verified comparison helper and its bindings advance.

Accepted local ordinary-control artifact `misc/s11_result/own_reference/s12_result.wl` SHA256 `338b9d4403296e74dfb27fa052348fac0841caf5410eb7ac003db01bdbc686e3`: the complete original and recurrence ordinary contributions agree under exact function-argument normalization. The direct original value was reused only with its exact input/value binding; its calculation was not repeated. This is an accepted integration control, not a finite F hat. Its full distribution comparison and the remaining S11/S14/S15 gates remain required.

## Reviewed final-stage entry aliases

These channel-owned symbolic links retain the original reviewed production source under `../misc/`; they do not duplicate the implementation or change its execution identity. Each entry uses the same polarized_SIDIS root when opened through this directory. Acceptance of a source review does not imply acceptance of its mathematical output. Consumers must use the executed stage checks and execution receipts before using a result.

- `s11_assemble_Hgg_real.wls` → `../misc/s11_assemble_Hgg_real.wls`; SHA-256 `f0654d5410d76bb7f11262132a4267661fb6f9ed9aa43e068c80b4a3c55979d8` (accepted exact regulator, coefficient and derivative preparation with component-local memo scope; executed S11 receipt identifies the accepted generation).
- `s14_assemble_Hgg_finite.wls` → `../misc/s14_assemble_Hgg_finite.wls`; SHA-256 `668d8910f400f82431f5fa566a71988723ca40a44a64e16c347e28104bc8b304` (accepted regulator-only phase, exact pole sum, scoped polynomial predicate and exact final-reference comparison; all finite checkpoints retained; final acceptance requires the executed finite/export gates).
- `s15_finalize_Hgg_hats.wls` → `../misc/s15_finalize_Hgg_hats.wls`; SHA-256 `451a6d5a9edf93e9a40b8dc11f37450d2e529398bdf0fac201e9be9158a8b705`.

Existing `Hgg/s10_result`, `Hgg/s11_result`, and historical `Hgg/s14_result` retain their original shared-kernel, subtraction, and historical roles. Local integration and finite-assembly artifacts use distinct owning aliases upon acceptance. Final Hgg hats must carry the S15 finite-export flag and accepted complete pole/reference gates.

## Component-local recoil memoization contract

The reference recoil helper memoizes by the full coefficient and branch. Integration tasks must retain this memo only within one component; the scalar master memos remain reusable. The scoped task calls the unchanged assembler with the unchanged accepted recoil definition, restores the previous definition table afterward, and reports retained memo bytes and native memory. A source-reconstruction gate must prove that only cache lifetime, replay bookkeeping and worker dispatch changed. Saved components can be replayed only after reconstruction of their original complete input hash, verification of every cached file hash and accepted checks, exact task metadata, and native equality of all retained payload fields. The existing complete own-channel ordinary/endpoint comparison must pass using the scoped task before remaining production components run. No finite Hgg output is established by this contract.

The complete native replay interface review for source `e225551ffb8cf25cd207a406e0efd2fccbe11e27239126df6bb6a62cb519ab98` passed on all 35 actual accepted caches. It checked source reconstruction, original full input identity, full normalized directory identity, individual file hashes, metadata, accepted checks, complete payload preservation, compressed writer and exact reload. The disposable replay cache was removed. Review: `misc/s11_interface_review.json`; native log: `misc/s11_result/s11_replay_review.log`. Own complete scoped-output comparison is still required by the production entry.

Component-local recoil memoization is accepted on the complete own Hgg control: ordinary comparison32.137221s; full endpoint comparison40.188104s; all Delta/L0/L1/Regular, soft-coefficient and branch-assumption comparisons passed. The helper definition table was restored exactly; temporary memo19363144B and control MemoryInUse1349116128→1221830040B were measured. Proof `misc/s11_result/own_reference/s12_endpoint_comparison.wl` SHA-256 `dc1b257a0946e58e5127e7a095c832d55aaf49a23ddb686367115d53c53cd91a`. Source `e225551ffb8cf25cd207a406e0efd2fccbe11e27239126df6bb6a62cb519ab98`; replay retains original per-component provenance fields. This establishes the memory-scope change, while the full integration and finite/export gates remain required.

## Regulator preparation contract

The actual component36 first-master input is captured in `misc/s26_result/s26_result.wl` (SHA-256 `09ad0e822847e2c2f89d7406d6b1b9227bee01dfa48a86a3fb332984c5d7c273`). Native extraction showed that its stored numerator and denominator are already polynomials in eps and their ratio is exactly the original25,431,120B coefficient. A direct-ratio preparation may bypass multivariable Together only after polynomial-support and exact reconstruction gates; unsupported forms retain the reference preparation. Before use, require comparison with the saved own-channel product and all recurrence/master-product coverage checks on the actual component36 input. The accepted recurrence and finite-export requirements remain unchanged.

The S27 direct, uncombined-ratio candidate is unaccepted for production: its own-product comparison passed, but its large-input remainder validation was terminated for performance. S28 instead factors the exported denominator with the installed python-flint0.8.0 API and invokes the unchanged accepted `s18_sum_exact_polynomials.py::sum_case`. Every factorization, division and numerator/denominator reconstruction is checked exactly. Native algebraic-atom encoding, polynomial-variable encoding, JSON round trips, input/backend hashes, restored physical expressions and cache reloads are required before the reference recurrence consumes a reduced ratio. The full own-product and actual failed master-product comparisons remain production gates. API reference: https://python-flint.readthedocs.io/en/latest/fmpq_mpoly.html#flint.fmpq_mpoly.factor (installed0.8.0 method documentation also read).

S29 regulator-series candidate contract: derive regulator support from the full transferred numerator and denominator, reconstruct both exactly, execute the standalone rationalSeries recurrence using exact polynomial arithmetic and verify every retained numerator coefficient. Preserve algebraic atoms and master-depth checks. Acceptance requires comparison to the own S23 product and execution on the actual S26 component36 capture. No final F hat or production acceptance is implied by this candidate.

Accepted exact regulator recurrence: misc/s29_exact_Hgg_regulator_series.wls SHA256 7d1265b21f0515faf66a99084e14d792119f2e0794a208d91d40618a2f8142d4, backend misc/s29_regulator_series.py SHA256 60719fe9098d852fab9ab6ac9c38b7e9e58e451c97ca825a6d1a6942fe36fab0, result 824706b0659a80c91fc5ac19434839eb92e156df4390f743f620826080bf50c2, genuine execution receipt 1a5412887e9f4efc50034f3c0af6e066fe589f3b7e725419048dde9de8b35d03. Complete own S23 product agrees, and actual S26 component36 R01 product evaluated with native master-depth/product gates. Backend recurrence/residual0.406s, native transfer/reconstruction11.172s; these timings are for that scalar coefficient, not full Hgg. The reference recurrence and exact coefficient residual reconstruction are executed with unchanged S18 sum_case. Assembly source 6ec0f3edd2cd8683baa98a6a97598fd8e2004dd7dce968e68888cd3f1fe9945e installs these accepted definitions; endpoint conventions unchanged. Parent e225 source/config preserved at misc/s11_result/reference/before_exact_regulator_series. All35 original accepted component payloads are reused unchanged across these reviewed edits.

S29 runtime provenance is explicitly recorded from FeynCalc`$FeynCalcVersion. The earlier mathematical comparison had an unresolved Global version symbol and is superseded under misc/s29_result/reference/before_runtime_context. Both exact comparisons were rerun successfully; production must consume the corrected receipt and resolved native-version field. Validation now reads the archived e225 parent source/config so it remains reproducible after production advances.

Full own Hgg comparison accepted for exact-regulator assembly source 6ec0f3edd2cd8683baa98a6a97598fd8e2004dd7dce968e68888cd3f1fe9945e: ordinary27.575347s, endpoint39.698258s. All original ordinary, Delta/L0/L1/Regular, branch assumptions and soft-coefficient checks passed. Ordinary proof misc/s11_result/own_reference/s12_result.wl SHA256 05451460d513cd4c628a378e568da2a66dc0efd2f4418de62728a31d88362e82; endpoint proof misc/s11_result/own_reference/s12_endpoint_comparison.wl SHA256 ecb75fcdfdbf07360f47427fdd5736f61133ccfceaf5da3986cbde0aa3cfa2c7. These comparisons authorize the changed arithmetic under current configuration 7d7a09853e82b4f1b785a88589d368b6fd65445f3d96e2054b51482eca070bf4; they are not finite Hgg hats.

Endpoint derivative optimization boundary: preserve the original native derivative s23 D[rational,s23]/rational and the original recoil limit, physical assumptions, endpoint expansion and distributions. Any exact-sum replacement must reconstruct the entire derivative, bind current coefficient/master/branch and source, and compare against an accepted own reduced derivative before installation. Production still uses the original reference recoil helper until such validation passes.

Endpoint optimization contract: derive the logarithmic derivative from the existing factored coefficient using native differentiation and an exact symbolic product-rule identity. Require exact factor reconstruction, per-factor cancellation reconstruction, unchanged accepted polynomial summation, own accepted derivative equality, and the original actual endpoint limit before installation. The failed nested-fraction transfer is archived and is not a production input.

Accepted endpoint-preparation proof: source 4b0b6bf2b1451af3c7ba8a2ca280b561154b09cd819835d6ad50558a1dc672d0, result e462676a8a4a9b7ed2266ade9753a0254eaaa25e3054dc1444ff6048bf2d3aa8, receipt 4d8769ae219c33dda2ded641a45dca25e471fd73f8d742bfcb6a62e1731533dd. Native product-rule and per-factor exact reconstruction, own accepted ratio equality and original actual endpoint-limit gate pass. Actual reduction11.002602s, polynomial backend1.244008s. Production source f788f130311271cd393c92fd1f4a5d9014887aebde3940abe62162dc6f3cd893 replaces only logarithmic-derivative reduction, retains original coefficient factorization, endpoint limits/assumptions, soft coefficients and distributions; own full component comparison remains mandatory. Archived parent6ec source/config/own controls under misc/s11_result/reference/before_exact_recoil_derivative. Resume cache records preserve all mathematical payloads with source/file provenance.

Full own Hgg production comparison accepted under source f788f130311271cd393c92fd1f4a5d9014887aebde3940abe62162dc6f3cd893, config 10e1e9186672c542450cbe7d4e36d068e487834eb72cb00f8be1e1d3085d33a2: ordinary and complete both-branch endpoint/soft/distribution checks pass. misc/s11_result/own_reference/s12_result.wl SHA256 919cf1d6c54df23726e62bc8f95ba4fb017c0a2b3a7cbb3ba0c0e2c7532631af; misc/s11_result/own_reference/s12_endpoint_comparison.wl SHA256 8fd90cfdd2205d50ab981aa3de52fbb1aa1f703916e53d5242557f37c3370cf9. This proves the changed integration algorithm reproduces the accepted own component; final finite assembly and export gates remain required.

Resource-only dispatch update: source 8f8f91c8ae41d358b2ff9bec94a53d2feade842e2a497d26e91184fcf47022c9 permits4 local assembly workers, retaining unchanged mathematics,10GiB total-tree RSS bound and4GiB availableRAM reserve. Exactly3 worker-count settings differ from accepted-algorithm parent f788f130. Source/config/own comparisons and stopped-run receipt archived in misc/s11_result/reference/before_four_workers; saved components and exact scalar caches remain reusable.

Coefficient-preparation candidate contract: reuse the accepted S31 polynomial factorization on one exact coefficient term, under a separate source-hash cache namespace, with derivative helper restored after each call. Compare entire own and actual values against their accepted S30 reference factorizations before replacing coefficient Cancel/Factor preparation. Preserve every derivative, endpoint, branch and assembly gate. Candidate is not accepted or installed until its executed comparison receipt passes.

Accepted coefficient-preparation proof: source 32c5137b02fd3847334f4e8db80648ea32fd44059c2fbdb9821fd3fab5d06c89, result abaf3f6020ffda09271099ba73f061ecca2d0a5b59989f4f1526d9414406bdca, receipt 0cc81da6f38063d8ff4a37e525e35efa9c56a0fe9383b709f94115001ba2ec9e. Entire own and actual coefficients exactly equal accepted reference; native factor presentation differs but exact Cancel/Together difference is zero. Actual preparation11.4s. Production source f0654d5410d76bb7f11262132a4267661fb6f9ed9aa43e068c80b4a3c55979d8 retains all derivative/endpoint/distribution operations and uses a separate source-hash normalization cache through the unchanged S31/S18 backend. Parent before_exact_coefficient_preparation retains full source/config/own comparisons and genuine stopped-run receipt. Full own component comparison remains mandatory before remaining assembly.

Full own Hgg component comparison accepted for current coefficient/derivative optimizations: source f0654d5410d76bb7f11262132a4267661fb6f9ed9aa43e068c80b4a3c55979d8, config 8c2dacf46d550a322163b01c2a44c01c52bc7efede3ee00cd9aff9f56bc53f2a. misc/s11_result/own_reference/s12_result.wl SHA256 2cc025d837826a683ef3ecb72fba94f69ecad5f29b46440dcef884a5b7802cf2; misc/s11_result/own_reference/s12_endpoint_comparison.wl SHA256 34c616b209c1706942c29c57db1a95a7d3cb98cac21e2aaea5da3d291427c2bb. Ordinary, both endpoint branches, Delta/L0/L1/Regular and soft coefficients agree exactly with the accepted own reference; finite assembly/export gates remain required.

Accepted local s11 intermediate: source f0654d5410d76bb7f11262132a4267661fb6f9ed9aa43e068c80b4a3c55979d8, configuration 8c2dacf46d550a322163b01c2a44c01c52bc7efede3ee00cd9aff9f56bc53f2a, receipt 0cb678662eda58331a86939d27650a815be806dc87f380f859b024895632eb9f. Executed checks all pass; actual local runtime and imported conventions remain separate. Artifacts: misc/s11_result/s11_result.wl SHA256 1d7a48839c7afe712152de5cde8d54a4c0990471139697a4960570d5f9709baf; misc/s11_result/own_reference/s12_result.wl SHA256 2cc025d837826a683ef3ecb72fba94f69ecad5f29b46440dcef884a5b7802cf2; misc/s11_result/own_reference/s12_endpoint_comparison.wl SHA256 34c616b209c1706942c29c57db1a95a7d3cb98cac21e2aaea5da3d291427c2bb; misc/s11_result/s11_checks.json SHA256 727e48c93318f2a3d57493bc9dd40b3e27c7c35717664c0561be6afc5e50b920. Consumer must use the documented file-storage interface; remaining finite/export stages are still required.

S14 memory-recovery contract: source6694ffec retains579 finite checkpoint files from48 complete components plus the first endpoint pieces of the failing component. The local kernel exhausted its address budget while assembling the actual label recorded in misc/s33_inputs.json; no pole mismatch was reported. S33 must capture the exact native phase/subtraction parts with current source/config/input identities, compare the unchanged finite operation with its own accepted checkpoint, and measure the same operation on the failing component after releasing unrelated state. Preserve all original cancellation/reference gates and production caches; no failed or partial S14 run is a final coefficient.

S33 isolated original finite operation accepted: source3c095f33262d339e9dc934fe259463887a3991799666be37f0f978c1191072c7, result1febf943ae0fe169adb878635a8e3d07632f139cccad1046f473e797941f5012. The original actual pole cancels after unrelated state release; full own accepted finite value matches. Wall530.611s, peakRSS4853190656B. Actual captured phase part1257660384B. S34 candidate contract: restrict only the original laurentProduct polynomial expansion to eps, reconstruct complete original own and actual phase expressions exactly, and compare complete native finite results with this accepted S33 output. Preserve native poles, endpoint branches, normalization and final unpolarized gates.

Accepted regulator-only phase proof: source5e7cfb92730c26e3e0ac66b59b838e91d9fcda0d8fefe6d32c2219620f077060, result2a5ba02c1931a21d1b8d1faae6472da8e23b729c67dd20bcd26a7fd84ad6a2df, receipteae0f36d002d938e2ab12b2d1a1cff477bbfd1dbb9cbb15dffc494d2be1a8f8b. Entire own and actual phase expressions reconstruct exactly; both full finite values and original pole gates pass. Actual phase10438720B (original1257660384B), generation17.248678s; finite191.662074s (original282.011613s). S14 sourceb3b8872279048bd8930bca812779baeb9258555205a363fb2ea7f90dbc19e3a1 installs the verified helper, verifies original mathematical input identities before finite-cache reuse, and clears temporary system algebra between components. All native final pole/reference/export gates remain mandatory. Parent source/config/receipt remain under misc/s14_result/reference/before_regulator_only_phase. Native interface review is required before production.

Native corrected S14 interface accepted: misc/s14_resume_interface_review.json SHA256 2c0ebdc0af337075c9fe67e479c4a6b589990386968a947c75c6ab15322cc71a, receipt misc/s14_result/s14_resume_review_execution.json SHA256 5dbd3bbf7aadc9847ea960c468065a68e00fd8c008676b53c1ce2fab847217e2. Source b3b8872279048bd8930bca812779baeb9258555205a363fb2ea7f90dbc19e3a1, configuration e7d94acbb0292f65b035d483732d9b1fe211dbcd3931562e5d51d4e41cb9edd2. Complete source reconstruction, original math input identities, exact installed phase definition, entire own/actual cached payload preservation, native finitePart reader and full final consumer syntax passed. Final finite/reference/export gates remain required.

Exact-pole comparison contract: the negative-branch S14 checkpoint identified in misc/s35_inputs.json retains a26910432B expanded pole sum with algebraic roots and differently written polynomial denominators. S35 must preserve the complete saved expression, use the unchanged accepted S31/S18 exact polynomial backend under a separate source-hash namespace, prove native term/algebraic-generator reconstruction, and compare with a nonzero accepted native scalar control. A pole may pass only if this exact calculation returns zero; do not impose a sign or subtract an assumed residual. No upstream mismatch is established until the exact sum has been evaluated.

### Exact finite-pole sum contract (S35)

The failed negative-branch regular pole at `{4,1,1}` is retained unchanged in the current S14 cache. `misc/s35_exact_Hgg_finite_poles.wls` sums that exact rational/algebraic expression with the unchanged accepted S31/S18 backend. It requires exact native transfer and polynomial reconstruction, equality to the accepted nonzero S31 scalar control, and an explicit zero/nonzero result. No branch, sign, subtraction or pole criterion is changed. An unaccepted result cannot be consumed as a finite coefficient.

S35 accepted: the actual saved negative regular pole at {4,1,1} is exactly zero, with exact termwise polynomial reconstruction and the complete nonzero accepted control comparison. Source db7af7beea88b0abe0560d97f92881b8ee00f7730248dae94719b1833dba0214, proof 1dfeafc17d167152f0884def751246ab94d2e719c0575eeb790c3b11ae316565, genuine receipt b56724517205cabc99e18606703e9c0bbd99fbf8406067706a95db2b6901125c. Actual full native transfer/sum 11.605266 s; 960 terms; total run 35.105084032999 s and peak RSS 660815872 B. This establishes a simplification failure without a physics/sign change. S14 adds the accepted summation only after the existing pole reduction for rational/algebraic expressions; original cancellation and finite/reference gates remain. New source 1cf026a44aaabe16caa8312d2affc729cedfe6cf67770614e9f2138f028ddc82; native interface validation is required before production.

Exact pole-sum integration accepted: full current S14 source reconstruction, accepted checkpoint payload preservation and the actual failed finitePart execution passed. Negative regular {4,1,1} pole is exactly zero; complete finite output retained unchanged. Source 1cf026a44aaabe16caa8312d2affc729cedfe6cf67770614e9f2138f028ddc82, review 56bef94f8c164db568c87aeb4d633a277bd439e3de17474c142e22d6c8f74162, genuine review receipt c6dc36642e6190271fefa26ecc1daef4465e5fd113b6c5ffc14cb7c46648881a. Actual finitePart 181.005326 s; full review 245.42839313800505 s, peakRSS 4641370112 B. The accepted native finite checkpoint is in the current production input-hash cache; do not repeat this component on resume. Full channel final gates are still mandatory.

Scoped Laurent predicate contract and accepted input evidence: S36 keeps the complete shifted regulator polynomial exactly, uses the same PolynomialQ gate, and restricts only Expand to eps. Actual input reconstruction and the original accepted predicate pass; isolated test25.117006294s,372801536B peakRSS. Its source command is retained in the genuine misc/s36_result/s36_execution.json receipt. Production S14 source d79c5f9ae1e9b2e94dde7cefd6fe2eefb24f9e52ba9a244859f51a6df0798018 installs only that predicate and hash-checked replay of the completed parent generation; every pole and final gate remains required. New accepted checkpoint inventory b84d66d8dbecddc4b61b6743b6cd36870f9a614fcc107a5291c8864d0631c15f. Current source/config/native interface must pass before resume.

Scoped-predicate production interface accepted: source d79c5f9ae1e9b2e94dde7cefd6fe2eefb24f9e52ba9a244859f51a6df0798018, review 58fd84216d598dad34a8a2fcdc0d9351c8dffcc4eee505e1781ef956b9c0569b, genuine receipt dc2348290645f1c6304c473e443e07c9c6afe49f38d2191100f5bf9d9b863cf3. Entire actual finite coefficient exactly equals its accepted parent result, and original pole/finite gates pass. Same actual finitePart now 12.812178s versus181.005326s; complete interface run75.181187119s, peak1828909056B. Both original and immediately previous mathematical checkpoint identities are validated before reuse. All final channel/reference/export gates remain required.

Final-comparison memory contract: all144 physical components passed under S14 source d79c5f9ae1e9b2e94dde7cefd6fe2eefb24f9e52ba9a244859f51a6df0798018. F1,+1,Regular comparison hit the native temporary-memory bound, without a reported nonzero difference. S37 captures that exact projected comparison using original assemble/projector equations and accepted finite-cache identities. HoldFirst prevents evaluating an unused phase argument on a cache hit; any attempted phase recalculation in this capture fails explicitly. This is a comparison input, not a final hat export.

S37 accepted comparison capture: source7665bf68a018cafe710ccec9af7c243edd7a0c87803df81f3542c1700f75f542, result87d720addc17c740632ac7af9ac661070c74b8b663c283736f1eb59c8b25482f. Native accepted-cache assembly for the nine U/U photon components30.083669s; full capture105.161595599s,peak2844422144B. Exact F1,+1,Regular difference305972088B. S38 contract: retain original Refine/PowerExpand physical assumptions and Factor log arguments; use exact functional and denominator atoms plus opaque numerator coefficients solely to avoid expanding polynomials; require full restoration at every substitution, native distributive reconstruction, accepted S31/S18 polynomial transfer/sum, complete nonzero own logarithmic control, and actual F1 reference equality. This optimization is unaccepted until executed checks pass.

S39 grouping contract: the saved exact native transfer has61419 rational terms and395 distinct denominator strings (input SHA2569c5e18103ce219001a00e15c7acbd7ab5d203c2d0995b0f16d19549f6f362d65). Group equal native denominators by exact polynomial numerator addition, check every addition reconstructs, and factor each group once before unchanged S18 summation. Keep original input term count separately from grouped count. All factorization, common-denominator and native result reconstruction gates remain. This avoids thousands of duplicate expanded denominator strings; no physics, normalization, branch or functional mapping is changed. Native reference acceptance remains required.

Exact final-reference comparison accepted: S38 source4cdc074e176257463c9b12fe42a07a0636f16e8fca8073e5ce11ec70767a9157, result a4487d74be08b1180f2393b88b969670571c7d4182a2e6f22c3391298987f72a, genuine receipt08450d7684191554a8a914f4cce2d0de40064c97f9495d56d5ed69a35471948a. Complete accepted nonzero logarithmic control and actual original F1,+1,Regular comparison pass. Actual246.66962s, remaining exact simplification0.037576s; full run320.594897384s,peak2716659712B. Grouped backend S39 sourcecbe8f63c1fa9a704f11d96b24b70dcf247851f158113a859ef5e264868832602 preserves exact native termwise reconstruction and original S18 factor/sum gates. New S14 source 0851a9874c20a4b33317a38d24c2da250fb75329f9bd5c35f981a707eae03267 applies this helper only to final NLO reference comparisons and holds finitePart phase arguments on accepted-cache returns. All1728 finite checkpoint labels are pinned; original/previous/full-component parent hashes are independently reconstructed from unchanged mathematical inputs. Final native interface and all F1/F2 comparison/export gates remain required.

Final-comparison resource contract: exact S38 comparison succeeded at peak RSS 2716659712B, but the installed 2GiB temporary bound stopped during exact polynomial transfer at peak3034570752B. Only final-reference calls use a 4GiB temporary bound with the original1200s timeout; all pole gates and process-wide10GiB RSS/4GiB available-RAM/8GiB disk reserves remain. Equations and exact zero criterion are unchanged. Source 84eda5307948fe20ae8e97b385176f7818bc69f60cba235d955b425ae9c1019e requires the current actual native interface to pass before production. Failed interface source/config/log/genuine receipt retained under misc/s14_result/reference/before_final_comparison_memory_bound.

Current final-comparison interface accepted: source 84eda5307948fe20ae8e97b385176f7818bc69f60cba235d955b425ae9c1019e, review 0a7b94a135c473e72b9ed801f875bb9943c4904c68cc6bbf7b6dd0b658a674b7, genuine receipt 7eaed07d76baa6e5e1faa262c11b4e0ad828cf2bbcdc03471d87398c4e472193. Full cached payload and held-argument reuse checks pass; original actual F1 difference exactly zero under final-only4GiB temporary bound. Comparison 49.251578s; full review 125.28262873199856s; peakRSS 3277778944B. All final full-channel comparisons and export gates remain mandatory.

Final-transfer buffer contract: S14 passed every F1 comparison and F2 positive-branch/endpoints before the negative regular comparison exhausted native address memory (peakRSS9755074560B). The actual backend output remains at misc/s11_work/recoil_derivative/94bf1dc2f1fa0d817b69b38c5d1d8275fd81abb9524599068f8b305987b5381a_431253/output.json; preserve its input and output until an accepted native cache replaces it. The corrected source bd2406fb5ce16224113dd643264f40ef6951667b6fc54c41041ff844de8289be clears only dead terms/pair/lifted/payload/forward-rule buffers after all transfer/backend identity and cancellation gates, before parsing the normalized answer. The complete S31 mathematical implementation reconstructs exactly; S38 helper identity and accepted normalized caches are unchanged. An executed nonzero accepted control through the changed path and actual final comparison must pass before resume.

Buffer-release interface accepted: source bd2406fb5ce16224113dd643264f40ef6951667b6fc54c41041ff844de8289be, review feb08978de524b7ccb7c71cbb76c22afb1919451df750aa3515fb1ccea20a769, genuine receipt 3972259bd7b39b705fd055ff95beff87b303c93603329e8ddfd89e5c0c9ec8b5. Complete nonzero accepted control through changed buffer path and exact actual final comparison pass; source reversibility, all prior cached payloads and held-argument reuse pass. Full native review 170.30610865600465s, peakRSS 2809339904B. Mathematical backend/cache identities remain unchanged; full final gates are required.

All144 Hgg components and every F1/F2 branch/distribution reference gate passed; final whole-record compression exceeded memory before output. Implemented bounded native writer 16c9e34599836b21bd93ef97f6754ad361bbbf31f8831d42c2a742869c63936e with exact per-piece reload, full-record reconstruction, hash-bound transparent Get reader and actual complete own/input roundtrip gate. No mathematical/schema changes; require execution acceptance before S14/S15 storage installation.

Bounded native storage accepted on actual saved S35/S37 records: source 894ef77af62414c61f309f19e2ab04cfc68bbe731a9849d8b400e2fa2a9f6016, checks c8f58b01142af32a20b3605d2ecee2b182f5fb2e0b94cbdadcad7fb3813bc6ed, genuine receipt dc41fcd6d698fd1213f50fa510ae246eecac8d1c0df02d873a83c3647a158348. Individual pieces reload exactly; full ordered-key/list/leaf native-access comparison passes, and a changed actual Difference field is rejected. Raw aggregate SameQ exposes a representation difference without unequal accessed leaves; no numerical tolerance or algebraic simplifier is used in the accepted fieldwise test. The transparent Get index binds every piece by SHA256. Preserve each index together with its sibling *_parts directory. S14 668d8910f400f82431f5fa566a71988723ca40a44a64e16c347e28104bc8b304 and S15 451a6d5a9edf93e9a40b8dc11f37450d2e529398bdf0fac201e9be9158a8b705 change only storage; all mathematical final gates remain required. Current combined source/interface review precedes resume.

Complete S14/S15 storage handoff accepted: assembly 668d8910f400f82431f5fa566a71988723ca40a44a64e16c347e28104bc8b304, final exporter 451a6d5a9edf93e9a40b8dc11f37450d2e529398bdf0fac201e9be9158a8b705, review b94590dd23e26b89f9de078f856017fcaa0bcd2a41be5b261ec79e4f481d7176, genuine receipt 0eb53faca92eab9faf2a8e0bcca8f650591b2b3e6bcc4c9d2e8fd1eef609da93. Full source reconstruction, original final consumer builder and actual assembly writer roundtrip pass. Review 65.10658222700295s,peakRSS1682681856B. Accepted exact S40 pieces/reader proof supplies storage validation; no mathematical stage is altered.

Consistent exact storage interface accepted: S40 source 6f19a926c4638c22f4e4280101cae3b09d694b5a6d9f83656696f680a18ff947, checks f25e5fbec2522fad37a4c2cde3750bd8090228bcb5ad513a865b0e11f0d48564, genuine receipt 4b3d177727f414b6a8b7b94ffb1833cdc406ddefe35e98aafeb309a17e90d7e8. Whole actual native record, saved failed piece and changed-field negative control pass; wall 125.2186078510058s, peakRSS 3082473472B. Native ordered-key/list/leaf equality is applied consistently to each piece and the entire record; no tolerance or simplifier. Actual failed-piece fixture retained at misc/s40_result/reference/actual_piece.wl. S14/S15 mathematics and sources unchanged; current configuration requires native handoff review before resume.

Corrected piece/whole storage handoff accepted: S14 source 668d8910f400f82431f5fa566a71988723ca40a44a64e16c347e28104bc8b304, S15 source 451a6d5a9edf93e9a40b8dc11f37450d2e529398bdf0fac201e9be9158a8b705, configuration 1b2bb620b2ed785a53892213d66fabe172fcf9f78f3e811815da1e68654009e1, review 77d7ae74b1fec21f473b1881593c94a5591364c91d2a2fc4b63c4cce68ae2e94, genuine receipt 348b377ff42efbb09c429ebc09e679cd27862c966a3ff56987cd2d84ed92959c. Exact native cache payloads, complete sources and actual assembly writer roundtrip pass; wall 70.10657062700193s, peakRSS 1692819456B. Resume S14 then S15 from accepted finite and reference caches; all full-channel export gates remain required.

Accepted local s14 intermediate: source 668d8910f400f82431f5fa566a71988723ca40a44a64e16c347e28104bc8b304, configuration 1b2bb620b2ed785a53892213d66fabe172fcf9f78f3e811815da1e68654009e1, receipt dfd47e3ed7b415654f168f90e19fe0ee13ed8be2cd5fe1b989e6284e232dd54a. Executed checks all pass; actual local runtime and imported conventions remain separate. Artifacts: misc/s14_result/s14_result.wl SHA256 2322bcd6e3856e2312357fc4abd59b21c723a84f732917826507630f67dca27e; misc/s14_result/s14_checks.json SHA256 50587556471a9d65ccff3bfcdf9225e38f478974400cc44125e8839c3d0a4e4b; misc/s14_result/s14_result_parts/71750456810b672c8c4760b7f4db93f712ba3b53b9ab048c303759f256679068.wl SHA256 8699997bb0ada53a80dadda1effbee18a05e345b3e14800a6a0c7efcf549fd0b; misc/s14_result/s14_result_parts/0591f66446b12ed0d8c2762a3c192ca9466458385d14491692fad1d4949366b6.wl SHA256 f18be7a33d13366f27087ac8ab89a8506f4a51994dc113b831508edf373e5622; misc/s14_result/s14_result_parts/2923c25472f5b106e0b452ede56e5918668f33cdd93b479cd65a335a5e339950.wl SHA256 17ff7f6fc541fbd2914a66cb0e7311546764b5b0a93f55f949a499a57ed49769; misc/s14_result/s14_result_parts/05199968c84b976d864a819e5524cfbf37f2634ced290682ccd4841a40d96b52.wl SHA256 3eeb905a1fa82616c884a46844d9a69eeebe36f8dfa48e3637e13ccce5389b45; misc/s14_result/s14_result_parts/20c667f42e0cf50918b95690e0381123689e470c7054a8c4d73834da654fa085.wl SHA256 4203e1b3ec894b8939d6a9e6c4819d536a9ffd6ac904c244b932cdf4a6363a97; misc/s14_result/s14_result_parts/37245a8c39e0dee9868a3877a178fd241ce19533edf9e16af9c6b600817c0899.wl SHA256 57211e162a6e0705f66821e0c37ed3a593de4c4b7cfb79e939a9bc8dda64ed2d; misc/s14_result/s14_result_parts/38e6c8b36d428b320bad3185b8e738aed2e659d900aab6e9128df63d6dcbcf27.wl SHA256 566677f84c92d86a62e1d87b4350093b5eef6b576726c1f0d1f4b0c3e474ba17; misc/s14_result/s14_result_parts/fa735a769edeca9f7885c249b1769a0d56e6055bbd415030851ccdb647c0096d.wl SHA256 50c9fa9156fc9c0fcb553b93403db286c8b79077619d8a73e37c4c55ef9aa1bf; misc/s14_result/s14_result_parts/a8666eecc4ba7017399e378a55f6a5a096a725b0ce9b49441130e3ba0e2c333b.wl SHA256 c47e4b0e39769d31435abf7e5cd2e1ef142f87ed052586765a2d0eeb4399a582; misc/s14_result/s14_result_parts/f4645283809888d27171031959a0e34d6f6b63792e5fef2273423572e22a524a.wl SHA256 01a148d257c64c77940ec961275564123fe5a9a7bef5c1857935824802f85fab; misc/s14_result/s14_result_parts/acf77a5942ea2ad60ebb9bf017b8e23c902ec8f70f761e2217521796f749446f.wl SHA256 2c6104f5fcad6bbc545feefc474a88034145d3967dbcabe2f151ebe458e8ee78; misc/s14_result/s14_result_parts/f4a818eb74cb6c72a29298a62a5a7fc57f6719154b89f6076debd05e0c460cc9.wl SHA256 7375dbe9e31a89ebab194135cc762b413de7fd8a4ef4a23716590a45cf500b66; misc/s14_result/s14_result_parts/eff8db4e62371bbac77fe6a8918b04c150433185da0344a29be3206fe9094bd5.wl SHA256 9173584978b21a05734eac226e3517790cc4543554933fadfe1ca8d6a7d1e09b; misc/s14_result/s14_result_parts/cfdb15453dbb8b07a1e043c0942d516000a8a1e51be30cd2ea2aa87edad07075.wl SHA256 28781d45d5d499ed8f80ea97d51f51fea2f8b0842bdff676d534ad4cd0bc5bca; misc/s14_result/s14_result_parts/17c60388e4ea8d3d4444d9bfb039796e2868c7b27f79c592f8ffc228c295edd6.wl SHA256 af4bb257645360f0970190e0b5871d892fe7c863369e8d4fd7f5933b970900ee; misc/s14_result/s14_result_parts/b5a43a0cfd64d5b901f646d6fc2cb64f37d5d46575b92dc4cc9bd123462a67e2.wl SHA256 f145e276b2ce0d642b14994fd3823a1e7c405d311bbbf2b29a77e023dc4671fa; misc/s14_result/s14_result_parts/9ab1340573102b941de204e9e425d30682884770ec0cc1831b1e21256d602730.wl SHA256 ef9502603e9c12b65ffb72ea369355ca5e6b7de0750554f3c404e6c3091f5d71; misc/s14_result/s14_result_parts/683b882cec8356e2fbfc2b6171960377ce675d76e7d4b9de2090f920ecce4f23.wl SHA256 171ee3ae1fc0c36df1f11b199dfba8afaeef68e0764f3772248d9149af708634; misc/s14_result/s14_result_parts/75605308d27ea9a6a2a3236c3812188838a5aec88cd176d46c003e4322fc33a6.wl SHA256 ef609e350495b504ce82905633b5db4a920d94858dba318ac2f5fa3796a566ab; misc/s14_result/s14_result_parts/d4da8207d3b54caf86d93b4d6551c465ce5c15310bb06bc3497386772b0db094.wl SHA256 878b58ac1002376894047467c995ab00fedd92485c49c13ee678e27624dc326f; misc/s14_result/s14_result_parts/81596cdbaa5cd9c999a8325e5674e95d282662bb2e38f062709e68b80975ffea.wl SHA256 430bba9f8346abf51aca0ec10cdd9fab5408fc6b943e38d97f9a6389901d75bd; misc/s14_result/s14_result_parts/07df36a31ace04b3d791e3288203b608d940f66dd444b9938555a3a552e8a190.wl SHA256 e7d21e83695d1e09a611e6c7d4970b1a3324cefb03f92167c0ad20490258e8b3; misc/s14_result/s14_result_parts/691141a97fb2d126ebdf18069a690262d7aa26c89865459def06c82ac8d124b4.wl SHA256 80ea41c93ccc500e5163f5ceafd8362195b686419d5e641d712f631b44107a97; misc/s14_result/s14_result_parts/25c316228ac9ce7dbf0abeb556b36db295936e0bfbf567d0b16a74326bfd1b83.wl SHA256 619e1d36190d76a113913f0c4dfdf6d65df2b3b41076d185a12aef5455c983f9; misc/s14_result/s14_result_parts/1b782dea2e3dc14043285d2acbed68a44676c6dfffbe99b391aaf3bc72764d05.wl SHA256 429e54a90939f40d078e21fb001d8b1d8178f8f3765f8c61243d282a999be4f4; misc/s14_result/s14_result_parts/b3ffda58cc6230147b13e7db368fe0596daf31ada58d568db48f437520c9cb11.wl SHA256 37a8cb26b3496daa44183ba071adcff024452597517f26ae113a652ce4c4f611; misc/s14_result/s14_result_parts/3097e7215c88413cc2a8c876c4b980f10453b305d7718931f5bc0eb4b50537b7.wl SHA256 39ac19f92d692fc0614800cf682a9b9f25a8ffcf7337bf48697fc136aa12ef64; misc/s14_result/s14_result_parts/b3d6a6119716243beebdaa4fe7b6486d0223bef024f44b70ab89dc0ce980370a.wl SHA256 8d090014678cc1861c12ab61e0a29a36521373ea1f259c0a157a963f6df84911; misc/s14_result/s14_result_parts/3b43c9d4c264dad607e2c937707d9144fc8abb07c3b28b718209254b8e2e350e.wl SHA256 0a6558f40664d49177879ccaa4e44874f5356870e87cbc7824925bd0f16217d3; misc/s14_result/s14_result_parts/3cdd091831a910a6d3568e8960e6cb9530e5f5e6b11c2a0a8d8db9999c720276.wl SHA256 adf83814730fc748c0f93c57ff3e8a66b51b5205e8548a180485bb0ebaa16910; misc/s14_result/s14_result_parts/f5b8071bb8c73f46063ae254de95bb320f8e05f769e1fa205f3298ed0b0c13c6.wl SHA256 6c69bd5b6140396fb6bdbcd9c9373ab737d0b85d55b61e1a6e325a65feaedec1; misc/s14_result/s14_result_parts/ffdccc211738630df3d4f275cfe46c046dd16f9847b2c2b5b387a3ac3a5ffceb.wl SHA256 d7b25d9b02ed68b6f5cceb738aaf567bae2323e7079f30b47b668630c1def2fa; misc/s14_result/s14_result_parts/7f142edd0eaa1c4efc28ea18386b83dc863ba646243b8e423a776c79466721fc.wl SHA256 266f2f668b261a84d8a97d020d2cffa25fb4694dd06f433cd36f665add8bcc55; misc/s14_result/s14_result_parts/829a9065a2f71bf83f068a6fc5148d2a369d39f812175e0573cddfbc38f56b1f.wl SHA256 e8041b0d731595a38345bcf93720cfd0b80a2e4317c3d091c3bee87101625243; misc/s14_result/s14_result_parts/44984b58dbae3809ca60c0e5aa127ee4bf597974cb4cdc4f94082e153ca79122.wl SHA256 32d88f11035d227b3c2ae4ed324989e94c4bbef8878c85d617823d3ea1058df9; misc/s14_result/s14_result_parts/1f2520fedef503b44808515b12416e7f4914b25163d16622cf1df4756b9575e4.wl SHA256 907dd98114554365977a859a93d598f31cba531657b2e3e9428c9b261ba4b19e; misc/s14_result/s14_result_parts/446ece1790299d5ff24bf6830a5c31a35eda013016cbb25d7817509953da79ba.wl SHA256 823dd2a928e56d640643640c063b8bccbf963a41b463bdfe3c808be82aa1abab; misc/s14_result/s14_result_parts/5f27cb6f5bc4bcebf53d0f5b1eb130580976005e1d7dd46ad1e09ec6869ee00e.wl SHA256 5fa17b831a0d815d4e3676ef7ca14f2f7819ff01a6886a7a4b02290eb98ea82e; misc/s14_result/s14_result_parts/eaf72e988aaeae0ab455ac13b999023875d2e06c2952fc844371a6cad72065bc.wl SHA256 e1c98d8e9ea971c5225b02524ee3f84538bce43fa68fc02006b6112cf50d099b; misc/s14_result/s14_result_parts/16426ed9477d026d1981c9c59594bff32bd4d212f91b7771315a8be33f6caf4f.wl SHA256 93259abe376673234c578b43e9430695195e9c2dce3748f1352e21933ed73a02; misc/s14_result/s14_result_parts/59e04b4a84dacb00a5b99e9534a4726a1cd162dba16b0a7ada52c4cbc0623cfe.wl SHA256 18ea632e37a205fb9d2fc7e90d730f98b9a0239ad16868f7f189befba536a587; misc/s14_result/s14_result_parts/c9d0629c01cddf15ad8a7a6be977fc58963a3cab691872788d8dbf345462fc13.wl SHA256 f8abfd74841f10765ba2e1a0c11e888706260a75f25b3525e60c925e3793abc1; misc/s14_result/s14_result_parts/abf5bde6c9fa34d78d02f2bf610d7a5b6a62ec7eff606057958ca55ff4e067ce.wl SHA256 52a3c77dba883984fb8afa28973cf6930dc661e898fbad138b37f7a02eb52f07; misc/s14_result/s14_result_parts/731523558381849f500a4c7704cc0bd9caf19cd0819249d842de94f8f7e2fae8.wl SHA256 4e689d1c09e63949a0f4880051f54ec7e7520f27010f64749d09f24f568d1af6; misc/s14_result/s14_result_parts/ce571198a8ecc85f8c5c7c9297188ca2406b60fdb5075a7893fcfae7c948ea41.wl SHA256 461a87202eff7ac2d6c1e95069fe0a796c9b57a1f5ec54a9bbfad0395f94b750; misc/s14_result/s14_result_parts/cb8478f0493ab6f0a4303319ee440ea5340ae2cecff1c669859aeee96a7ec326.wl SHA256 872785d44a04f8f1031bcd7ebcca24d1a68f0b88c3e28a8176e065aa12751447; misc/s14_result/s14_result_parts/7e8654c2dfb6567100c69b9c9afaad692bb7ac04f841dd214d76dc39c9c4e9c4.wl SHA256 247666727d3c3fe176f1a16f092bb962361811ad39db7898bc788f408b2e0571; misc/s14_result/s14_result_parts/e3e41a284d4e5649471ca1e71adaffd0f55e93b8dac50480003cde2951c2dc4d.wl SHA256 6dfbf6bc701873886b2c82f30fb73c674dfbc9b8b0a4190b253a1a8b661d9ba8; misc/s14_result/s14_result_parts/4af1a155a92dd0ce5e9ac398355b46402eec6e58f8e2d9dc1f7716b15a16e2d3.wl SHA256 e4b3ce15b13b7dfb832febcf362ebb5be6bddbeddeddf3a27ca2842c0c39ae5f; misc/s14_result/s14_result_parts/79a49efff601361d92a84bdaddc17e3628d137b2e5b798a7d8abe44416090174.wl SHA256 729ec227414e40c22f71633a624de16c123fc683a4d2b32d2e5b23d62c659dfb; misc/s14_result/s14_result_parts/0c81e98bb12584b8f3b7a4bd29a01c8d9c23d1ca885c31f14391c33851310045.wl SHA256 2eb8ed55c7a0fc78d9b6745eb9577ad84e2f16d89a778a05c1eaa798c4eb206b; misc/s14_result/s14_result_parts/86d6e425c8569ce15fce8e85f784ee43c949ee8bbfeb09702d1fb75ab106a443.wl SHA256 353380c0386ca43e3d827364e681bafe6409fc0c3b925f0c91e6c52d2a264bb5; misc/s14_result/s14_result_parts/9e05e4e6fb738da2475b027eb4c87dd4c944eedf243507f81aa1d69e9d3bf1a1.wl SHA256 90fe7bcbe9051ad9299c566459b111282332547ae83fc4a6b001cd10a9708dd3; misc/s14_result/s14_result_parts/8b376ffebbef53ace046ab7c7b8f6e3e4a5a5cbe57d299e11ac0a28f5e936629.wl SHA256 b1d3ffd42ac062f9606122a2097d6e03354fbf55803e4b22e69d3ade533aac07; misc/s14_result/s14_result_parts/0d5cec5ced3cd0ec22f1114ff90f1d99b31ed5e656aa294177aa7116898b8ff9.wl SHA256 6d0b81e1999f57ca0ea864b58c14cd16faf51774b62c58a64fa5bd6516997bf3; misc/s14_result/s14_result_parts/5b65feba8dbf3af8f4c56a69e86e6cbbc12dd9a9e03af0c340acc44cd50d8cb5.wl SHA256 53726d48326d7de3fe631ca739b844079be804d6a4d33b9d90f40490cdb8f09a; misc/s14_result/s14_result_parts/518816620559d913d35b83e54f3e0de04a110ad04661473f8dcd18de72d9b09d.wl SHA256 59a0413f30b56e56ba231e89b87e51631f2a49282189e354b11f76d2a2d9f888; misc/s14_result/s14_result_parts/1a19b2ed7dc07ebba4343fa2ed1ede9ef3446cd352fee5aa484704eff1d7c594.wl SHA256 4f765d9403c3b88f9bcdf2e8444932ec8f99af5614e6515a9aa1124794655857; misc/s14_result/s14_result_parts/1a30a3ffe8fd956f1e1181103922713807707ac0ab1a0fd48bb8830fb3cdee70.wl SHA256 850bb9b2402f539ca8bfbdc405dc8bef26795340e42475aac8354a23dec05bb9; misc/s14_result/s14_result_parts/efc914517f8734690118ba788dbbdface598eef3cad813651b6c833d1d4ba262.wl SHA256 f043107d249f8e8deb1b73a2da98bcb5e4a72d54851f33d20ba40ccd469533da; misc/s14_result/s14_result_parts/9f5db8d1c2ac09667bc50f4adcfef0b2eeec95eeb17d274b64858f647455b304.wl SHA256 24da2a61dae523e09da030946712e857d7e6d1e77d1c886f314db38fed5b81b6; misc/s14_result/s14_result_parts/caef34450c2ebcf93193859d9592c94272e13edf9a63464c1728738ac7bbe873.wl SHA256 d9e93bb8b33e3c58716c659559e7d0f9aa69b9d1e3d9029a8063157dabb53d52; misc/s14_result/s14_result_parts/8a2d2f7c294e4e831183f682ccc805df27ad873e0b0e0a9458288dff2dfa51e5.wl SHA256 e68eee83fb2b16d403c0e0cef191fa876df8a569d27ec9e00b206b5ec420952d; misc/s14_result/s14_result_parts/85ec998761ec731bc9990e78013da32b0f9bbb40b35f49bb2d138f9b47a3d8a6.wl SHA256 4eb191836249bb002b1e0997a3c8ff9ec2e5fad462eabccde34f9506fdd57ac4; misc/s14_result/s14_result_parts/b33a13d4c4342546b121a5425cf4604d0930d0911d363fcf625d7943df406b1a.wl SHA256 2096373c6de430595f82ba6c21afef12bd9368a7c9c6e50e59c3b5f0a451a719; misc/s14_result/s14_result_parts/3aac1695a07a3dc3549c55e262edbebbc1d56f8db49d2f455c59af21446bc194.wl SHA256 ef9a7b84921bdc2aaa5de7134edf6d4b3d7b023eeca9d4a5ea71e1784fd7d144; misc/s14_result/s14_result_parts/efeb2d5c75f06220bd7c65b593315eab21ace0f0a7bb10c198ef5ad0704852a9.wl SHA256 2e8988f52c7c22aa2d4ab4a848b7b9be0c7fca0fd9fb977dc0203873e8ed5c26; misc/s14_result/s14_result_parts/422be9460639b5f9de0bab1d1b23d72472a4582d67c05ae69e44bcfee6897bd8.wl SHA256 143a56e20fa567fed60fe3b251f2adf86edb066ceca201e972321765e35e0a4b; misc/s14_result/s14_result_parts/a0e252f0a9fc19cd3ca9df3b64f11c134a016d6dfa41d3cd7a2c8ea2c3236f9c.wl SHA256 e97e717baed3d4970622c7b6589e29caa787dfaba8d6fdb63ffbd6d7720d73d5; misc/s14_result/s14_result_parts/291c87f037fac8e4ff2a5a3ca2f02a7039463b11edc4ae00c0845b1d534bc1dc.wl SHA256 f5b389028ae535d08d5e56120cefc02ec9b3ff33bcab7dbe4fe3dd776cfccbd2; misc/s14_result/s14_result_parts/a8cf8acae9809deec06328cdbe9d905636838f5f9e2d684a4bd4bcf404ed42c6.wl SHA256 ec75ea8a2d8fc93162f227cff0de04998eba57fdfebc912724d0d88af825505f; misc/s14_result/s14_result_parts/4dae81775b32184c473db99a834fd97a4b726f22d25e4844403006994f5b93eb.wl SHA256 3bd9a335e61afd4049ec870c9d323351abc512743f894ca9c76957aa89615f3e; misc/s14_result/s14_result_parts/aca9848ae3e50a1cc72c6dc54eccf2bc16a2260a83eee288375c6188c172dcd2.wl SHA256 30eab29d0f4326bbfccf7df80129cad8a8a9493d5cb2a2d5723c6226cfda0452; misc/s14_result/s14_result_parts/ee4cf339703c5d035f6aab758f6bbb9c948bd09167468101a790cfaf68886f36.wl SHA256 6169a82d7aa2058e3e5550517caf0997019b37c9877ecc9986824616d033d134; misc/s14_result/s14_result_parts/5618244271823a204bb2fea28a59eee48dfc2371ccec0ce8fd71a1b159eb10df.wl SHA256 9e647e14d4a6d32d7032eea4a4f6f34e6ec15311254144e8c86b93d53178e673; misc/s14_result/s14_result_parts/bc7d9cb8437df612e0d2fe9b9395a56387d6f0492f588aa55486340bbe349922.wl SHA256 fe06c9ea9005e6c986c1340a98d07da89c1432946b6b70775b936b2e794200ad; misc/s14_result/s14_result_parts/05100934e86fbfe86c37e64bd9001c817e1f99ae40e170e3efa3424182484229.wl SHA256 3790753fd8c3f8f4798f8726fd6b5c65299ce4b1b5e2098dd513e877169c811d; misc/s14_result/s14_result_parts/3405d70fb260dafb37438760c599979f4b1e82a66a9f843ab52ae3a0e9abdcde.wl SHA256 0eb233c85b620b6f99b208bae38731c7e47807167053117f355622a3780d2f08; misc/s14_result/s14_result_parts/e94c67130d885a5b73f1573bd7ff6377d20dfd19db70ea44de572bcb72dd0c51.wl SHA256 0195a3b18d0fba4dfcf96818af28232e48dba771ebd97d7d169af5bdb431d173; misc/s14_result/s14_result_parts/d3f16b730c0326c3a5e8c9bf5da1529c227d37a7b0d5b2bdd049c93670d500c1.wl SHA256 96de0d547935657c68113ffe4447492f2cb406ee5bfa49b6b50a128ce2fbab35; misc/s14_result/s14_result_parts/32cf6c41a4723043c0bed5a0a3332841f03b41e08d79b04957f8f9d592f2a231.wl SHA256 6eac85c986ee81182124ad64753b58d42fd1da70a0c6c917747748ae7c0a38b2; misc/s14_result/s14_result_parts/1e9cf31beace1e45bbc97197f5e097bdccf5ce3213c62c42d783270618de3a66.wl SHA256 6c9f1e34a508bab3cddec8cda5205169a6d5ebc60adc988337fbb6c59eb96461; misc/s14_result/s14_result_parts/5a1e0f8d4be136f1a49a952652d43a8ecb411be57b2f8d0b65c4d04e1c04b2d2.wl SHA256 f83172f942b5b8ec67c9106ffc42d961fc862cb6734e142798d693a4e14704c0; misc/s14_result/s14_result_parts/bcea5958f80f1f4dfcb59875f938bd830a596e98c738343c90e91aed18f283a7.wl SHA256 49846a7dfcf5f19750c7bca96e647ebb7d44ec28c388f716125dae75e814bea3; misc/s14_result/s14_result_parts/0aa7f58e718c71566ef6ddeff3f6d4fae1e5377613969c6d65645846c638c5d7.wl SHA256 dbed7688a2baee370d5010fafd16528885c6382400a99c02fde3e3805fc273fd; misc/s14_result/s14_result_parts/72e52dd31538497f797123cf9b54a697e86eb706bc19994bf46d2a4bb5387a91.wl SHA256 9b6883f8fa4197f60ad6b1d59a47a64bc40fe4978e0bdc877c8f4d3cd15a82b1; misc/s14_result/s14_result_parts/afc222c68f249b8f40cb20a2f55b8bc268b884865c81ffde27319f258964f464.wl SHA256 6661ce37056012ab40b21420be36f454e4f0972615ea4f31c8afec73a73edb22; misc/s14_result/s14_result_parts/26d07068ac622094ab12a477ed1209822edc83dfab1d42c19e6e3341dc704bc9.wl SHA256 d080bdeb1ac9798352aca2bf8662e09239557112936b7f77e0e0d4274168ce96; misc/s14_result/s14_result_parts/f8836e9b663f279cb01e5473c2c7172ab09060a848cec70992386034d56bc615.wl SHA256 78bda5ca1cdd1ef4efe1318028fde8e794ad8ee875819f52eae7ab8c6c44e64a; misc/s14_result/s14_result_parts/1f57e713edffaf165d377c3e675cff1f1316b5542595e02d543c253279a9a983.wl SHA256 6a98e776fe5fb7d5ce3e874fd21c557f7117b48695ab2807704c74cdc51e6277; misc/s14_result/s14_result_parts/dcdeaecefde4c4bf20af30729e3995f298bd4bc7f28f88ececd42066180ec582.wl SHA256 667db9b85bcb18af6f9d91e7d5198bc1c17e91b4ec3d93a4807296051b34bfbd; misc/s14_result/s14_result_parts/d07b3ad3cc0b3de2d6451f1b8314417957de566d41a41f3da1730063c4002900.wl SHA256 ec80a7a22465d83abc912d8d02346d9b1bb6373f383aaf3d3292dd42461f70a7; misc/s14_result/s14_result_parts/95f53f7a59cb7a60b312bb069c42316971bcc96fefb92beb3ec952a6462a0741.wl SHA256 510ca553a3a8137ce6ac7c0d67b075fc721d349051693d7067cdc14b246794b2; misc/s14_result/s14_result_parts/01855b7e67edf2fcd7acf12876c62a329cae59731387a824a9632958f6825d5a.wl SHA256 dc77017a6d6f91ff651c80e316b910bf053c381eb00a18dc862f8b6c2d73810d; misc/s14_result/s14_result_parts/54bfb6b39d3ff05082a40a0df60dc34eb7074a982e6333d5567ec727044f4094.wl SHA256 07a34793fe86823ec43cf87fb9db45452c5fe4c916b1457b5b2953166f5a3316; misc/s14_result/s14_result_parts/b6bcb3d49de9dc49ca96ba16e92b6832e1b8ab7ef1504c259987cf646880e5c0.wl SHA256 85975e20b9b72315b44f88214d65683bc9d3accdd95b31ad87c92613d8190e44; misc/s14_result/s14_result_parts/e35dfc9cfa6ecd77fa8036a6b03e2a487df54b8b1c74526d7a4f1255c1ef00b4.wl SHA256 334c9b9ebacf3be8c4e6f47d4ec7b7aa8410e3e84b9a5b63d9a062e051309d94; misc/s14_result/s14_result_parts/f72d727d6bb2d415e7e1e9f0f76463d39ff88c0bd70456136df135556100c6f3.wl SHA256 fc0eda849b568e1cc86642d1aa2cf85b12c871253f30bff28d5d5393f40bf543; misc/s14_result/s14_result_parts/ca30805547c9b974d521cbafaba79ca5c141d1b5ca9e832f651d97283d5948d2.wl SHA256 f9b8419625d79445ac106e0b16e9c6d5b6095ec078c39e58dd80f503fbb76652; misc/s14_result/s14_result_parts/7d839796f861bfaacca23cc34dee037d0708acd4f0e4d230df6898cae00a129c.wl SHA256 6f1302e9c5569519670050d4ed2b86f05a256fae7f1d27865165fbc8cdc877be; misc/s14_result/s14_result_parts/b02c7d28134fc6c084c19318da9b2dbcdefe7a1faf5198908f6e228b1cf06d32.wl SHA256 b4a9068ef3f5185210b5ab06b85b61619e13ee172beaec6fd9ec9ea2b1d549e1; misc/s14_result/s14_result_parts/e6e1dc7e8bced01153d1025b04dad57e2fff5dbdeb4c3b6f15f2a93ea765e1f8.wl SHA256 141ea6ae3f445e618e8671468d5adf5accaa0da8f273f317dd6193c29dd1cd8b; misc/s14_result/s14_result_parts/32f3828c4ef7c78fbf26a523e0b15db23cafe6ad0303c5c8305eb6597bc4df7a.wl SHA256 9bd35c87cb3ebb60e5d5ddc264246789073c4baca3cd0266040778f64c24e7f8; misc/s14_result/s14_result_parts/a2fc57ad8008475ac5113a30135b27ac94bd172d65189ccefb2ca992f7a9e5de.wl SHA256 80efcbb194180b761b8865986c0b96b8358852b17ef7184f97fc1576d08cf580; misc/s14_result/s14_result_parts/c9a1329a5938a744d693eefbece06e7768c1786606f9ce7b254ae7c8f29a4b17.wl SHA256 af4b69904fe5ba3ae369d72f5b0bf25ba347714dadab01df08156936871b47f8; misc/s14_result/s14_result_parts/e40a6b8c1f634e294ef1b772151643d2787c1af1ff19575bfdf718df2ac4e5e4.wl SHA256 3b394419868616a0e276a8cb5d0fbb1ed33e09635c12ca4b3d1a9600a959c5cd; misc/s14_result/s14_result_parts/68b5ee65749dff3bebfcfb75ad7c359002bf92e8ac269671a81a1db14dd8b3c3.wl SHA256 c66b98599b8487690557ecd74cc131ea09da5d33968a514ce8bd8d9f2499fe8c; misc/s14_result/s14_result_parts/e768a2d275d361169deda42d1ca2e91d77780807c75fb9bc1597b117f0cafcee.wl SHA256 050249674198f9af17d4ce7ba37a5331b430d389e89634e49ef6fc368e8cf419; misc/s14_result/s14_result_parts/7ba6bd73fb5b2fadf069d308de0865e90dfdf3f951427e3ca4348d8dfb2f8fd6.wl SHA256 be2f42a360fc95a21e47f67a656ea76e553fedbff2733fc36f23fe0a0511daf0; misc/s14_result/s14_result_parts/4b26152dd98716af5b8749fb9b46e3c3285cad38914a14dc0174b3303df30839.wl SHA256 fc6a330506a6b1bc7e367a0458768be1d500b54baaba599cb5818241bfbe6e38; misc/s14_result/s14_result_parts/d3c71de00e109f5bf815bae91d7808defc04b502b45f51f57fa0813b7e52f977.wl SHA256 87909e43898652bcc1960fc23d6062e2040df8fa5c1ac524cd33d52a2570f6cb; misc/s14_result/s14_result_parts/c74774bb311268fd50e093d0831e60b83737061b22bdbf4ef6fabf5992be07e8.wl SHA256 10fe1920f7229381f8eb6650bdba8ca07507d3705c4e2f514ae98924d5596ccb; misc/s14_result/s14_result_parts/ee507f5ccfbce74e2e5960a2a006718029f4511463d273c3cba2b89c77659852.wl SHA256 12343c9ef3b78c79b318f4be494e8545ef49c3672c4fdf6c475cc3cc45abe357; misc/s14_result/s14_result_parts/5e861bc0853dc5c8de7cd4cbbe06e8942c9ea8fa0893c6e1748eaddf5fb8ad12.wl SHA256 d154903670d271719f87f33b5aaf3db400a5325c115b2e7fd825042238223724; misc/s14_result/s14_result_parts/29b36970277d76de41999c7f73ab42f042a41e186eee6b33ef19cd4df364e6d2.wl SHA256 f5dee00c04e313de99a8ca3ff15894586d2f3ee44b17c5c55d945df682e3dbde; misc/s14_result/s14_result_parts/d3f5912a211e794b0890470625adfd005e119e44701ffd59c8a91d5ee156ce0e.wl SHA256 b089877b2ae2547e505e37d14df55ea0ed1ef1710c41da60d9ee0f2225b5fe48; misc/s14_result/s14_result_parts/391840e3e647a6802474c4df739b12e457ff950dd6992cfe7bea847cc83a7118.wl SHA256 c4622881f4ef082b85e463aaefc3759e62dfd70f0f9a4139e68bc374c51a58f3; misc/s14_result/s14_result_parts/1aba3d3024dee2e9bcdf4da584be99375873ea3fdedfbcff71838668d1839ffc.wl SHA256 8932de4edc14f57f04f5073ac291a943e7ae3c2ad509eb9f64340933b0658414; misc/s14_result/s14_result_parts/d320b3ff94e1b9129aaaf1e05c294b597443850a0764840752b1ea98a399ceff.wl SHA256 a91977ad3ec6c93392ef1e42878e9e1835133bb59add1ea00bba2af6f9c13de0; misc/s14_result/s14_result_parts/d77fdafc36774b8f8876055cb897435814c6c414243e21261d900238ee37840f.wl SHA256 31d681b2190c4251ca7bb0a0700b9d3f77e699ec38f7a21e85cb9677cbd4eb77; misc/s14_result/s14_result_parts/dc8a8d69a7b6be3fbb0fc5e1e15581621fe96a67c1bd8f904ed6c182134585f2.wl SHA256 0b4ac8bf9e33a1c8219c0c21758f8e4edea5822a5e8e18aa9901e3b5dbd5e7b4; misc/s14_result/s14_result_parts/081ece24a08e27ff04c9904872ce771f45ab852a26a62a768f63124069ff097f.wl SHA256 c3ac274dcfb85fcaec71623a38c2ad3d4bc97293f7f3b5fa83cd490ea0d709ce; misc/s14_result/s14_result_parts/d13bbb464d6d38c7515772ef1fa6d45c7834a937e58b81a98af22f17a5f5291c.wl SHA256 8df218571d59f6147ad4ffa8d68a137ce736f169ed996a10f5477f311bf55f88; misc/s14_result/s14_result_parts/df3c9bef01396a073ea5c7158ca73e60a6cff51beb9b00955acc0ed5accf436b.wl SHA256 adce8ae0df5381870f12d72d4f0f3e3f0ae2a970955f081e62d510bd010935af; misc/s14_result/s14_result_parts/3ac4333ee13974d4668af532ff83c6e7d8d88cdb18213a4d85fd6d0f0c196025.wl SHA256 3df9abb3f943c4655698894d0cf74408da8eb7ca1c7356a1fa04ef49d6974b14; misc/s14_result/s14_result_parts/4995e71f9767de8843f68d20328d61d43546c3b05461e3452b63ce8ef7c24367.wl SHA256 7c1ef903358489a198e400c80632b90e1d25d5dd7e3214ea1e614018b9b30f96; misc/s14_result/s14_result_parts/49a1d9247310b093e5fc1db72426e4885df63328e36018287d03d12056fe82e5.wl SHA256 3650f10fed4d917ad20151bf8e6818d983adbba7e599962239d648b60520f562; misc/s14_result/s14_result_parts/2f14b2a0169cf3d4019ea76d0f11c4be65c0d3bdcaa17ff47201791981fa73f2.wl SHA256 5aaabbae5b1a069bdaab22ce52348f299870ea3e90df09e400a6e0fb11a037e7; misc/s14_result/s14_result_parts/59bb242b1ff59e51efe971102923cda8c37c868b6869130c41f310f89c71feb9.wl SHA256 778c70a4351cd07a550bc1ed38b02c0b487584a535b4c4e2afe8ddc3995988d6; misc/s14_result/s14_result_parts/2e5904c4cb4a8b45e7c9449c81ab16550cd6abfb62029f1f7657e2cbbb140363.wl SHA256 a2292e55b84cbd8c5ab030a102b4fcf59a0cac4dc6e0d5108a89b90e8a60aa8e; misc/s14_result/s14_result_parts/69f510337862ca818d2a1683fa354ca1f39c6cf4c8a43853332375faab1ed9b5.wl SHA256 52b1c98e4e6c6a5f491e6e2274fcd6d5b4d15273907271eb86ab62fe95d9c3ab; misc/s14_result/s14_result_parts/4fe3efb5e0847a14e1b15ad3e9d3cd5c24fb48cf0099db18d1abba0f055aa240.wl SHA256 a460753143a116985f7ac3556dfd5fa90f07e20bce2c9a7a91e7020c59addc1b; misc/s14_result/s14_result_parts/2b3993eb44886d173765666a909622133eb8d8c2ac635e03c8310516324f3209.wl SHA256 d184981ec2a2a5f78eec7da9472c144f3281b09cd187c0e409c056388e6fa7ff; misc/s14_result/s14_result_parts/3254d97291c783d5cbb752f24106beaad5e26d4aaa7ed62bcbb561d80060c3d5.wl SHA256 c39a5e25307754d6597869bbbea64fb4c8ea94dd3339d2ffe689c4a9c8183f11; misc/s14_result/s14_result_parts/27302f1e065bd1a6c02985449e08851bcec531499912e742564ef5b72fec7a82.wl SHA256 292df4af6b032618ef60cd7e07dad3a80c8da4f92dfca72be1f8be427c216739; misc/s14_result/s14_result_parts/bb42fa1fb55a0deaf48f4287be2be41fe09263312513b113d70d4e7f0fa9c70d.wl SHA256 c1213e486436e591abfc9290734371cc0dd462ab3a9099c98baddb0dd27711f9; misc/s14_result/s14_result_parts/693f8fc7938a5db5b0de846841cf158d6df0125f1e0d80d15d37c04d872d5da4.wl SHA256 3c3e5f0da352266991a911e97c5cad1d13660490271babbf69f62de5fb2a815a; misc/s14_result/s14_result_parts/34b93fa377b325749c5f5399d39e9f85dc1402377668aa1247eb4de5af77a047.wl SHA256 335f3dd84cee8ff25535a70c4f2f9aa2282cd3827a223bc6e29fe346ec0f0d10; misc/s14_result/s14_result_parts/d490188055ace6545e437e4b66e0e40961657000eec7ae678b890da1051f1acf.wl SHA256 b2da9dc1de8de2f7c41d5891150b71d920a5e305736f2c8c5bbadb8071bc39b0; misc/s14_result/s14_result_parts/5ea8b12f6de7ce37db0dc155676481ff9a99ca59be1a70259b1a400fadde69f7.wl SHA256 cd1de3280a91bef86b9f978f556db0f4d3c7ffa2166f096c1bdc429fae8fa1a4; misc/s14_result/s14_result_parts/027b05ef87d6e69a1e3d68fd3175dc73fac50f2bcd1af6e8238ab540083d9b06.wl SHA256 6b6953881ef97cb3c664dbc558132eee1b97c02698ceee239b941b5ec3c7afb9; misc/s14_result/s14_result_parts/bc8d9f01bf50e93274e7d30aea5b62b79f3ea48795bdf48788d44d5f1643d312.wl SHA256 3f8baec9f4bc19f29ccf7d659ab04e9945983a6ad202fbc97f41cf3dde987dbd; misc/s14_result/s14_result_parts/caa84de4d9596ca963c3be425e7eb6f592e8b1bfd088d7890bd7b57c0646648c.wl SHA256 dd28ef2d339900c7a5cf86b1dbad5afc48d6257341f7124572bbabc3ffe8a30a; misc/s14_result/s14_result_parts/59d9c03610688261d12c6bfeab79d5061e1f0a38bff19e80b47db016d0281fc8.wl SHA256 8c5cc229d7d29419f2d60246aa4c365adfb1ac059ee0438906d25fecb885355d; misc/s14_result/s14_result_parts/0ade6f50cc9c60311958ea01a95c30873bc28ce72b6085db2aaa9badb2086992.wl SHA256 8c8c20502bec94e0072ac1ad2ddedf0cbc09de3bac401c717a6074beb73e9482; misc/s14_result/s14_result_parts/99f95877d89511dbaa589b4366924cca9fee919e999ea689dff30996c0f09d96.wl SHA256 8ca8550e9659b0704e109e5f1da0ed465ba1576f8f81d38a40197cfe18e6b273; misc/s14_result/s14_result_parts/c8c0976cfacf0ff376e5f90afe0dc30721a39b0cc434eb8c141ac124bff20d5d.wl SHA256 ac54fed7f06b8bf4a069b729ee9f7063f642afd1b9e21fa731cb361550e60ab6; misc/s14_result/s14_result_parts/f49c8832d668ebd396b68d99b3f4724c1049adae0b92459394896c59bcf47c79.wl SHA256 e9bbdbc569aac09875a5da88dfd3a318e8b73057ed9d678fb7bcc59e75e01f69; misc/s14_result/s14_result_parts/d338f43f9e5d8b655afa1a59e8aee7a074b2b82266dc1c48eb7e96e8a433441c.wl SHA256 39e5d01679a86cc38afc278bd995fb8e43525a8ebd87089db366cc9b0af66d48; misc/s14_result/s14_result_parts/5d92f4774c6fc82f855dd60dc507811b5083dcc805e986768b1ef31dd5f74314.wl SHA256 f3d3120a05f90b82c9507f21035bdb2616d6e5c7a07d2226081a8a33b15201dd; misc/s14_result/s14_result_parts/5e17a632533f8b193dbc91d46821a46bdee6a8dbb4a2f478c4aa028222d3db5e.wl SHA256 15047b0cef8ffd5f3f8fd7e00ff34c684f5c148080418731221b29c2c4b9370c; misc/s14_result/s14_result_parts/32b4dacbece7e6dcbdb76996c22418450661505548eb66c88514923c1691001e.wl SHA256 2c936079c5005e7f1c7a5c2ad24a6e5b11248faad75cf7cca6daf1bbc3ff4fa8; misc/s14_result/s14_result_parts/e7f6448dced46c6c6cb22ba23981d1466c92a9a2b9785963b9378b8e57e6e99b.wl SHA256 a6682b37212d04316b09c2946e90663538ee67b2798e2db6adafe7d545f5538f; misc/s14_result/s14_result_parts/587ce7fc24182df892b5d16a799e83b6eb3f3a4a7b3d609e332c371c47e2f562.wl SHA256 ada641fa333c1c269e6e0a4682df5b61df0a99ec98a7fa1cda6633ee5ab1f001; misc/s14_result/s14_result_parts/21665c0b615d182c6586024f6879ba94ec2b2622c82d25b59675ed4dfa790cf9.wl SHA256 2d045eccde3965e240d48bc9f8401005bf434224df88c3897e344e9cbc6f96e7; misc/s14_result/s14_result_parts/a171f7369ad8969b2bdb9281bfd0ea4bd87e8a951f11b3edbb448bbe1d5a13fc.wl SHA256 5a90c1578b8b4f9c1443746c02efa6439a6b7a388306c4bb9fbb4db55dcdb75b; misc/s14_result/s14_result_parts/d06e3950d7820edc655328ebf42fc7c9c34e54254d0acc098407c5c52f9fb7ae.wl SHA256 be34d8e9dfc8f360926e53f923aa02711fb800047ffb643c938582ea2406f9ee; misc/s14_result/s14_result_parts/1466cbe97315883ce05b2223067bbc24d8a543f782785d80d98d1a303d5c2b14.wl SHA256 7fd91878b40333e7ac5fc5466ee675ae5eea273c5ed81987c17cf9112e3a6218; misc/s14_result/s14_result_parts/c56aea2a0220582aa42cdb29e3d6ed8803267a4f35fa7db605a2206f30dc9fcc.wl SHA256 8808f535dd3aafe0d68e3cb7fd0460d88a7e7caad7f807c71022be279c8e1447; misc/s14_result/s14_result_parts/4725b2fc562833f5d99e834c2e2c0f13d170d4649936683d1a11c8a17ee5a9df.wl SHA256 b4d4c74c40d474799217d30733e0ea0150ab2db610e7354630e7f732f5a574d1; misc/s14_result/s14_result_parts/68e974b454080171c23838c20d173624d4845ec44e1de714379aeb045f682512.wl SHA256 7cb9d684bcc098088a4246e8f85a3a916fdaa28842c87430d85f9dcc6ce34559; misc/s14_result/s14_result_parts/894fbd625dab89c4c95c2e9198309b31c14ad80d34a9ead7bdfca118f8b96d17.wl SHA256 20d31d7b4297ec3cb310da2ca2fc8158eb206abc929aec0e87fcfe16794987be; misc/s14_result/s14_result_parts/0b601b4e64cfa2edc7f75745f0accfbf118e3989c2693e567d65dd48fcfe54a1.wl SHA256 97b0ef9f4e8fbcff0dc37cd2c8f57584e8726cab2863f10b98fa28a84a3ec8fe; misc/s14_result/s14_result_parts/147553ee65dc9f23e522e1cb5a9c4a39d4e8e6e9faada5477bff621b7026440d.wl SHA256 ffa1be05c7d7a31fd6fdaefba0474fe2feece79a3c0e1b649f82a514074c696c; misc/s14_result/s14_result_parts/f8ff451788d9709ea9f63506d99c57b8611baf92b80a2059f4cf0cbea4619c39.wl SHA256 ceab0892d41fe2e447aedd886029b3e93150540a06c59629aa11ea27d761fd84; misc/s14_result/s14_result_parts/e9ababed8fc3bea348687f889c9ad92e53a7320d9de4818ab6bd204b6b1d7f3f.wl SHA256 f58f6a0ce11b8696dfe7e343bafee3f1455097343ac7ffcc34709431020096a7; misc/s14_result/s14_result_parts/69ee09ffc164573bb33291904770b2fbf6ef82fcb312625d70aea4718db0546b.wl SHA256 c18d1095a1b26fb7eedbe02144af764fab7c09cf2f15a38d1f923325c31b99fe; misc/s14_result/s14_result_parts/7e494b7544eb1864212e84bee0668902cbfc4fca9e5a593fac32b211de447cf0.wl SHA256 a8c1ca30dcc8e287afd8aed0f946322eab8fc2e338c23af8a27caf34a81f12ac; misc/s14_result/s14_result_parts/6835eb944a9473401bad6b62f586c901e5685a0c9fa526b6e4214d67a2f15c99.wl SHA256 ce1e112296ac4a9ac633cefb54be2c8c26a4fe4a0e618f957d862ee7bbfc21ca; misc/s14_result/s14_result_parts/a2dbc0bfe44802c83a933ff3141885d8c3735064cea8c7fac10fdc80f6040b62.wl SHA256 4e60189e570e10d8dca3862ba48c6e5e0f160b3bc4b4731e2614154f94e495f1; misc/s14_result/s14_result_parts/c0b7c3072542c0a6a016e6c7523894cec034fee008575c7783c9fc1e7c4943c0.wl SHA256 e298a73aa804456aebf981340ab234c6206857393d660b809b6d3e15a2cae75f; misc/s14_result/s14_result_parts/2c5b018482d8b850cf3cfa86c7304f3e5823ca1796166524a62a8d849f94ed33.wl SHA256 b65c199df7e8e698d57577c89cd7f0196943747866acedea36b2206b3273dd78; misc/s14_result/s14_result_parts/21d10e00e48502d3f9fbdeac9e807718e5030ca85582cf03c1485d7d8c90c54e.wl SHA256 936dd592c7e7e4ad46a90cf33d5df7bc8ecc36d84f239e18b3dda84e68d607d2; misc/s14_result/s14_result_parts/a975f3dec5990028d771b4ecc8507bbdd5eb1ec92ded57b580badd8763a7c2d2.wl SHA256 b4cc70d62cf275a91d434bb177b4b31132c9b57267033685d2a9e46ef5c0bd05; misc/s14_result/s14_result_parts/a70beaf94fb76b76955033ac745dfa3b906d4b92f1c49d656529cad1526d46e3.wl SHA256 87c702853dfb41f80d2703296e70d4069552b050d73c064820188a79b28254e0; misc/s14_result/s14_result_parts/76ce1abd3c27d43689ecb9ffe7da7184625d1dd4867f53fdeaba9cb4e6fcfe10.wl SHA256 8e8e9e763c7121ebac5924dd17966dd2bfcf99e86e90d230e25fd38fabb2eba1; misc/s14_result/s14_result_parts/91a157df278faebfc75cac3fcf7ce6ab46b8855cf14173867471d3465b59c521.wl SHA256 ad8855f83a2394a23dc71fb4b5019b27300305bec22ca957fbe35c0fe1c12ad7; misc/s14_result/s14_result_parts/22957fe0b262e77fa1a6a3adf1d970883dd07207f56f0bd8957deaace7e9aa7d.wl SHA256 271d0af75d34118d03c411bbc02f104deac7751fdaa8cb9c53440f88839832f0; misc/s14_result/s14_result_parts/da315266634fc52d700a6e44144e328794c3687d9a84c6366979de96fa92062e.wl SHA256 3278d44755223880b00ec9b288766129c1c878df5f077ec6659b29ae07f8ebbd; misc/s14_result/s14_result_parts/3f3d898ad244a3d3fb419b6e95ea916aae5dd8067b66d81f8117ae1b8e8ee819.wl SHA256 a4ad4d261df70595cd415e07fe550a309fabc01f2b84c2424532825a6f937632; misc/s14_result/s14_result_parts/916f8855fa5c1b07eb7bad6488fd312264d7e7116c411f4709d6c05009f6f98d.wl SHA256 b01fc9b8f89c9b9e8476f02f598fc6d581e3e52b7e99e4dcd53a2180e66be047; misc/s14_result/s14_result_parts/fac4e0396692adb4db10e03e0af2f149322a09ccc92934fd462c9ed714b51ce3.wl SHA256 74d6c6c0d08daa8f571fb5f96094ededba4bcfb11f750f6008e78c73147d5e63; misc/s14_result/s14_result_parts/71314ba0a764e9b2470a351ec0be43a5e17e145b6f36e31cf5748b31e01761fc.wl SHA256 3e302a2279c6709d4fc188c5bb16dafc491cddbe13b0183ef3bfcf7b664cfbb3; misc/s14_result/s14_result_parts/7760cf604f8dadd8f1da87afc20631a321340e8da47412adb17a2683f250815b.wl SHA256 9417aee42ad76c8cb8951d2df873d9a104d4f3f9509fe4ce22dda4b4ac5411cf; misc/s14_result/s14_result_parts/795d91c3b7e80d08c8824f6a25996949e215c48f5549301c604ea92ec61f4258.wl SHA256 6a0270211c1771881bd435a3a8c7ca1b840b123216c45a4b8b34e90e6fc0c6eb; misc/s14_result/s14_result_parts/234014754958647d123f5a698c33859c0ff4a0657ef1ae6fb89765c085690364.wl SHA256 c33253ff5949bc5abc1348c08f74316c73a32d354400733a509d1f7a7869289d; misc/s14_result/s14_result_parts/9c0099ba4d66e1a7a1fcba32a821fac060c7fd39a135922e2a0ede98c27675f2.wl SHA256 cc559bd9d9c480de7ba4bd035d16a021a9910a9075403eca40af2e604eb727bf; misc/s14_result/s14_result_parts/397b8747aa50452e9bffb3983c9f97fae89699605a96bfb16d3004339cbd321b.wl SHA256 9ac148698ee1f48ec86d3f7bbd53e1f71fd950cf65f4022d787cbd56cdeda278; misc/s14_result/s14_result_parts/b6dd273214f67b77c083076c1e84e00e29a6fb2cdbc4fdf53f1c099f39dfdd82.wl SHA256 155d31b8bd0dbb61adb9d5e99fea64214f196b58d5711ca0078d32d9a9c2394a; misc/s14_result/s14_result_parts/2703f340b54ba4389e1fa4ef0a4d107a2d7c80ef6e808fba0f33ea365bfb4d02.wl SHA256 f7cddc8dd811d191c319559b4d45b7204028c3b94b1043e534b13edd42634325; misc/s14_result/s14_result_parts/b32d420a0445ccf73f71eac47927ac1756cf3420817a00b43939825470897f20.wl SHA256 4a58ddc262c9871ec940f54b32cbeb052c42f0d1c9b4888b417e5ef364d1b98a; misc/s14_result/s14_result_parts/cbf1d942219cc4391695b5ebdbeced19518bd7d7b6f0ad211842884f8fd96f08.wl SHA256 eecdc292cfef9eac96e0c932c6ea0fd6680e48b72dc001987af8536390015cd9; misc/s14_result/s14_result_parts/c7a7ae4c752ecf496199f37d7f711f7d725757530328439cbc1ca9021b67c701.wl SHA256 0312eef7f7c8fd33986aa1b85e704afb1a3a336598eb98397082c2084d0f7c22; misc/s14_result/s14_result_parts/76f497150e1f0318614800fe89e8761fc6ab14e8124726e69b72aa151655320d.wl SHA256 9397235d85a5c471b47a454061f73fedb1b7429be3cd366efeca40d7d48809bd; misc/s14_result/s14_result_parts/9f531afa4f75b6f6fbb7776c8da6f7f2d798b4a09890d333b7a6f936b5a40d2e.wl SHA256 ad4285dfc7771d7d135b409f660f71d7574362978845a21fe9df6457460a5300; misc/s14_result/s14_result_parts/e624e844555cd1d0692e2ee87feddefe0827ba7c427c6c52c41989d34e103f5a.wl SHA256 50d9b8411604f3407e86d4a75a9b415dd0fe9c48adb04e4c37c2c21185d82a8e; misc/s14_result/s14_result_parts/49a259e29fb01b38966041920aab4ab5ace179aa68acf297f604d74762c1ce66.wl SHA256 269ffa522d129c26923025a9b7dfec1a2da43105dbf36d59d48d3bf2e22439e2; misc/s14_result/s14_result_parts/747c9d06153806a74ba97e58538fb9137ce06777c5579ad831fff750a7d872ef.wl SHA256 c33bb6b0ff16d110c509b9b9d339ba022c212bc6f13f33f25906ba3923350327; misc/s14_result/s14_result_parts/8cc5866499040ee960406c0a64cb03fa7963b2e1c83537914c0571d8ca48618e.wl SHA256 0448366dcd0557ed92821307f1c14e4e93dff5a8c7e69bc7dc5ef74ae2dbbb19; misc/s14_result/s14_result_parts/897c0476130a3b79861642abb6b280ae0acbe6589f1484625b6125d355ff20a4.wl SHA256 8b9daa9519e35f91ce6fee5dcfd980c5cef471f2760089d794d350f718cfcab1; misc/s14_result/s14_result_parts/f1d2806f45ee4014a074b4bb2ad890f906dc5d3143f2034dc160f3277a9f0cff.wl SHA256 53a25a9a2f6cbd893b270695a7edb8235ab58ffb2d0d11adba6841478b3bfaae; misc/s14_result/s14_result_parts/29a671bcd3c26da3e9da8b087baf38267e687e995bafde51a625238ffdf3f290.wl SHA256 b52b39a90c91ed04566ec74517f1d6a7ba0bd67835aeb7a64bd855955bfde207; misc/s14_result/s14_result_parts/058bbc6341bcec89042bcbe7f7db3317935a19d336db3c726e8ed01df5b0d5d7.wl SHA256 2acf4b1a95da1b2b1bb2aa3f030e8003993beb8eda470e5107021cce2a57f0f6; misc/s14_result/s14_result_parts/86023690785e3b7ccdd1360b2424766e5ccfedbee35f20a27811ebe3f360b939.wl SHA256 ab4bad1822d5deef6b173faf28fc5f9ceba2f43d6ffbf9b282e6a5d66cc2154f; misc/s14_result/s14_result_parts/7f76be438edf2ba0aa0f7ef99c64ee8887ef8bfa850141f6496d4a17f3305e67.wl SHA256 31aac3d3ad44bbfeef6128460dc29ea6b02f7842802d20eba7aa4474b6d95397; misc/s14_result/s14_result_parts/0a916438dab78aa92699b106004e670acefdeebf0db36a13d0b61ac121a1444d.wl SHA256 d509b92b1a64f811117772e1686ced9cfdf4202c58cb06324bdf7059b516e3a2; misc/s14_result/s14_result_parts/cc1fb21402ada76e9e309eab32dbfd466d05eaca54c5cbadf2ccd01885ba201e.wl SHA256 57d52b761e69d83f8764351f58aa26bdf71f3ffdb3f0e099278cc07ff3ac5ad0; misc/s14_result/s14_result_parts/b698250e3f5d71871be5d2fd7ad97ffc44cc6f03eaff8e6a73f8269113378cc3.wl SHA256 a5ef9d21b57be07e1b620212eb6b150a10e12bb13accf3ce47fcb4ec38666f00; misc/s14_result/s14_result_parts/d481e4f48a7279e0f8a494b6199966d01d7552907f6aff5bca919b82ba81fae2.wl SHA256 c7cb78f8759d3ba918678e7569929ccbef9696684a1f253fd6e19a153323243e; misc/s14_result/s14_result_parts/cafcb92c3f0faf843ef6f37b436a37980fa2cce1434c87ffec82a927da134ffb.wl SHA256 5b884275935a2aa3f2b488febb0243c777f00b1ad39219f3b07e224a56405fc6; misc/s14_result/s14_result_parts/e9ea69604de40a4df6e2bf9dc78cfc02d8d947c5dd83f489c33962c155615ece.wl SHA256 17a140f0a5943f8178023ab07437980a52ef6259d157f3e232ce6394241f29c4; misc/s14_result/s14_result_parts/fa6efbd607870dcfd4b418cea0c3fe6fad69071023ed74c4c2c8a10e6be041a8.wl SHA256 19f83900eaed0a4f34b17cb8b5f8cfabf02f7ae1eeb0ea25028e4240f706f87d; misc/s14_result/s14_result_parts/52635ce744920117f4d80725b01d0fc8a107580e40067b8906c61accae532aa0.wl SHA256 b69ea3648ad52ce0088e4e060dd0579c0f99e207c997bd18f9037b2fdbb5f8b0; misc/s14_result/s14_result_parts/3937a0df8c45a39643238c0b5c8348851ed80ca044cc7c021538c864e29591a6.wl SHA256 c4c82fa9cd364ce6da8a6cc5c97402a40335b15215dfa4cee21e9151002d28ad; misc/s14_result/s14_result_parts/96b6c48d728318396d27a733c066937572efcb6dc629ccc02e66f69bdb2b2ce8.wl SHA256 57d575421b7b454a18fcc394caee66898b2644c771c562063b48435dd1cc1cf4; misc/s14_result/s14_result_parts/fa03f7982cf27445933fb739cc5909248a3170d2457c4cd76cdacf27e0e7db85.wl SHA256 d37e26c2f383dfa1d075991c2025520b859cd7cc6920d7fbf4dd304fcdc87e2d; misc/s14_result/s14_result_parts/552a81df93a12edf1abb0e6924701ec8b0e3aa014ace41f87e3fa013e1dbf9bc.wl SHA256 4e49eb6ad1f6f8bd6a46714f5dd43a5542c2b041fbe757b5f60a21784c5baaf0; misc/s14_result/s14_result_parts/8fb7963c535194ba97b24cb605b5425c72a6b9c749ba4e3d0f603c10000266f4.wl SHA256 8867c36fc398355503b0aaf95f0cb1f698a4acfb7b3210d78c1097a42259e3a9; misc/s14_result/s14_result_parts/5102625724c6d07da61ea88ec1f5f4b848467d645fb4f9437215d75484e4b12a.wl SHA256 bc4b854727c55dcc153c4da4f1873d0a69c275deebc105964433f7b3f05a70f2; misc/s14_result/s14_result_parts/9930f3573dab5a0483e44906f241f2a8a10358c64ca04e6528615a92e9f94526.wl SHA256 5ffac9cf37f28de4e5151bc01b1230aaa15bce92fed01f64516d5a0abbdcabd1; misc/s14_result/s14_result_parts/ae9f44742e5ac8c8fbf82a4d7533b00e8b7e8615fc5e390b16b30daa870a1636.wl SHA256 15a69c97eff1092bfbcb61a14d82f88e5005731b63fc904bb2a499f1feac6a72; misc/s14_result/s14_result_parts/e0cb07fc99f6b871ec58c1d6547c5b069a306b0de8074d4006305b0cf070e9c1.wl SHA256 920117f63088fab7a965327a2803a96ee695a0394f3b858e18c4d34f954a9a74; misc/s14_result/s14_result_parts/9849e3d1363ca67968e56bf10994f6572a5841af4df97adc9c408f9920ec9013.wl SHA256 dd1da2ea8bcaf4c7050d2f88c23bc3f88a0852ecf63ff64aa46136b85d7d75aa; misc/s14_result/s14_result_parts/076d084af240dfd0fbc0b238382f6d292bb061b5647d812d47f17329a2463f1c.wl SHA256 5cf75bcce984420dff9e21ed3901c4c850508fcebd59b69fde7accb5732cfe71; misc/s14_result/s14_result_parts/31c91dd4edf81e6b8d2a3796ae22c669c8a0515608f974c1fd0b8258e571915d.wl SHA256 8650012f7397272ca41fc5dd51c09ab80b5261876b9f0f944e163861551c8da6; misc/s14_result/s14_result_parts/89b04824beb9a926d385a1874a43c2ded43702ae11b3f8bc7342e0fe180ba61b.wl SHA256 4f698104c7e26ff60dab641a3b33c0b40687c6fe4df7cb3daedbea447cdb790c; misc/s14_result/s14_result_parts/29aac75fe56a3153bcdf9b5b5870b3b67fbbb138996cdfa093684a773a1a7267.wl SHA256 537d54439b9982763858a011e05a14bb4f3ee6d8763aaa780ac8dd682a852a90; misc/s14_result/s14_result_parts/3d2657e44444e31b63ca19355e31677556fdc59d5e9e9382140fa9953816a7af.wl SHA256 7d173819ef725355c37183b357659e1b12c298046fb77dc782bf510803a67143; misc/s14_result/s14_result_parts/0ec2b881399d9abbb490ca5d3ff6c49ce9786c38ba0144683413433c6fbe2349.wl SHA256 3beec8581286fd7cf8a6ded246a601d8ff868a783402b3fd19e886f5898c4f2c; misc/s14_result/s14_result_parts/a2a890de19ed498adfb971cd9bf36cd6ea8ba465e218ed2f67f9b6d2aac38afd.wl SHA256 5cfef62fa40d2ee29fd321bc0a1568fe637816d5a842374a75e15feea2a10503; misc/s14_result/s14_result_parts/9b58afb58bbc68400751966c9c45f6103224b6f4cdbf649a10ce90c63725ae7b.wl SHA256 c3f1069279a0028c981f8d22555fcd547a027f0f64d5722f20dc4eabd062fa46; misc/s14_result/s14_result_parts/96fe3d65bdc6906e6b60eabe5ed36fd5ff0869e964a12c94c002164ff8021608.wl SHA256 53955590c1b7d8db8cd33e7325bd745b1791357d6a143a2417f91eb521df7e76; misc/s14_result/s14_result_parts/ab1c3ad29838cd145c1d632caa94729341000013ea3ef861f5f0989f0d7b1b5b.wl SHA256 26701cc616e3d27a0c14ce4c768d0c98f498885d35bed443352ad7795985a4dc; misc/s14_result/s14_result_parts/0f3459748fa74c2868b4cbf0023a41bc0c6dae68fa712992a41b2e18682cc279.wl SHA256 589b624b002eaa0039616de018519a5c6178b251ec13ec74e0d18dc29bbd9afd; misc/s14_result/s14_result_parts/28786a7f3048ad82c2f59558cc339e73173b0b1d283a2b33da63688a31b77be5.wl SHA256 7be1af09189aba6858832ffe9fc099a7add42b6597b0f59972f40e23f0892b25; misc/s14_result/s14_result_parts/433b31ea1f9f95dee5f050e7f84a326fc85c49aa8cd086975780f92b811147b4.wl SHA256 554006566dd22b245693ba7ef9755ba6a166e602dcfc0652c3f2f54d43e8684a; misc/s14_result/s14_result_parts/20742507d2ede7c0f9baad58f3bf1836d18be24b0819fdfb5c1a238bc5e3d069.wl SHA256 6c9e788eb215446e8d9989f922082f8a7bb085cf16b00bd60fd84b2e6f2dd99f; misc/s14_result/s14_result_parts/baf0fdc7dea9b7ab775d6a48675f83a6bfd7dc02044096a3fbdfdf1da91acc25.wl SHA256 81f6b0c0a57d9bb1098b89de780e4b8d773fe8b44b88242ab576f640b2add312; misc/s14_result/s14_result_parts/bc0ec11c1b5644a30662c5336d488659e73e99d9a709e459dc53c2e658167a8e.wl SHA256 ebcdd8a91d1a524c3ede27b72014e9b7890490bc109ac61a344e15e82ea83863; misc/s14_result/s14_result_parts/9e8e8c6fda1f60ee336bd4959be815415b5d8f5af094c52f954a938147e11b56.wl SHA256 54e1cf75b92aa9a4ebd84195a9181c7771f02cac80a339791a5a8ccbac18622f; misc/s14_result/s14_result_parts/5395cf880cd82ac16b6b83e5757e2fda25f2f3ce97e642eb01d35edf05a1633d.wl SHA256 f016c021b691f7a2da997b9a2ab5509ca3ce8d83bb59ccd364187463e801d23c; misc/s14_result/s14_result_parts/a40b981ddca161ffcc4dd13eaa6cd259b00c93bf602049c5d727de38bf950e28.wl SHA256 70c9a4b8afee4f98ab8c3885583042a6c75687a753ec0b2cc0637b3b74fef7b8; misc/s14_result/s14_result_parts/d82b5475634d5f27d2d5e5517884f375ef518213fb77d0cfa3f26bc8ccaa27b4.wl SHA256 aa1214fef452eb148aaa9b61b8933e92904f8bddfd54e9bb3ef6387289f4196f; misc/s14_result/s14_result_parts/fe1ef4de96b37e43a2e1773464edf3af96fde7ce6a2a7b06925b7aee9ddeb057.wl SHA256 f4b94d9187baf83661d0b30c9b6bade6cc9e761efd49874a71b3e11525a571d3; misc/s14_result/s14_result_parts/b6905fc0442153a28bfb5e81a08a1832dda97825defc0a903b51b267cf794c36.wl SHA256 5ec5d20b3c5e37bfb60953e0747e67480aa1f3bff502bbe7241d3d335e50d0a4; misc/s14_result/s14_result_parts/717d9c20283d5610f7ea5c9bfff35431123cbd14f81fc25556d9544972e59dc1.wl SHA256 32b46917a55db6aa2d5c61416c755ea96fd6b62c84fff1d37b06a510b84e7e29; misc/s14_result/s14_result_parts/1446254d0978a441f230294450fbcc4e84f99d8d43b9de3c9f12a489f5ae9bcb.wl SHA256 a27fb9319428cde1bfeb58127b6aa7d79d5bf7c44cc705b27124cb4419c706ef; misc/s14_result/s14_result_parts/0fa18bba8200ef033e42beccc5d31a4c1419421c432c3b86c7ac1595fbdb7a1b.wl SHA256 9169df478192258826bd5566c24884113ea94cba624c44162c1495274a03690f; misc/s14_result/s14_result_parts/a4dd6c4104aeeccc91ace968e29196de83f33f873807fa7d320a77eaa4adba06.wl SHA256 7010cdf60a2e62e5c624a4bf7d053a616405b36f2b5419c4dc447ad6d0d587cf; misc/s14_result/s14_result_parts/f78697b9d9d301cdc0fcc04f400dc387e62618019ddd2b5c5c9897b5fee3184e.wl SHA256 5c10747ab3116fffe178bf45f73b599e1468723d4ce3880bc3b24f3f71cca814; misc/s14_result/s14_result_parts/cb8d93962d0fc3c168f69dadcb7067086710c27b5c1fd5b96d582bf4e461774b.wl SHA256 7f187bb44c116d911745de24f0974a6806926177b0e8438a5abea97a04804263; misc/s14_result/s14_result_parts/fb2cd27e538a70bb8e7ed653131713b89a2596763d5bab1cff27e79f19837a1d.wl SHA256 f6708b5e94a9a3dd866f2287914793b681288bc087655ab6158b4d599287ab54; misc/s14_result/s14_result_parts/6f80575ab485b3b50a6e054cce218c827b321fc02cd2da9c936867db1191106d.wl SHA256 f04612dc62d4e339a4cd9dbebfce0046734d8910461a4f7aa1ff8b202a4897c8; misc/s14_result/s14_result_parts/5c387d357e35add8426636995a7d5e7366fc2d69d4addbdbbd25b94410b23848.wl SHA256 b49b2edf2ab777b4a3c1c3314f334297bbb38acd80741591f17f9072a1298819; misc/s14_result/s14_result_parts/57b50f9a56bd9620dc60921ae762a88ee58fdd51297d85becaf01cb9a59c3545.wl SHA256 176101f3f8253984b72b50c5133613e0dbafe43c59a290c0060ac27aa998861a; misc/s14_result/s14_result_parts/4cd1d3576ad8faeba6757100bf7193db0f38b962d7dda2139b3d6f4170e91d07.wl SHA256 bcfaf19d68f4547a1723e155a0ff50581395d449ccd19ff46132f05993226a2e; misc/s14_result/s14_result_parts/30ffb6a24c7e5675bcd58dad0ff0a7aec42a905cbea7f534a5781829115e4a32.wl SHA256 24e5d2325d2a1870ce1716d094bc1cc073be90f6edbca67a57c0754f8857a1ff; misc/s14_result/s14_result_parts/dfc7f7a931a5837915a86d88cbcb6d803121bca7187d62895b55746a171c0278.wl SHA256 8dab26ea480d74bba50e8a777fac3d621f6fb21e92a4760f39b1e2299143b7b9; misc/s14_result/s14_result_parts/e57ba670a14a081c2a7b054ae52cb8acd1e98b3d5e45d526220a06b14055eb1a.wl SHA256 efae8e5413aed272aa7304f51e88fe1e22d3c097d48817fbc37b4260b757b425; misc/s14_result/s14_result_parts/4602fd44921aae3f2781536faf1bc5871aa47fb61823db3dea0ccea7ba58665e.wl SHA256 8c99976cb07c568cbe0fc73a8918992e7d5be2c55447cda020e6b1af010a5c92; misc/s14_result/s14_result_parts/3ba26f23b7a8518beacb96d080735068d99b421647571030a6c4a912a4030f85.wl SHA256 10d3740582811b09254b8f7e38d36f070e67caa3ed2a6308ebcc6b06176e0337; misc/s14_result/s14_result_parts/f65c82e4a747a2f472c20262f7390f67e61e46f2e0620ba93a8d9d349ef62bbe.wl SHA256 8ae2bf0f200ac827853184da915f83f1303d78f89de078335e056de370417081; misc/s14_result/s14_result_parts/eeb4f54497862fd405643f868e72b5aad9de7ff3aa3892597cb135e1775d1783.wl SHA256 5960a8eed33f7880951bd862ab35ec017db03d6b92c44b65bc39d7521f34eb47; misc/s14_result/s14_result_parts/e1acac5cefb3890bd3c60f47750f2a548624c5bc6239e34d388ca97b79e5d14c.wl SHA256 bb59fea7ecde47980519e3d101559ae5f7760713b2e66699af861304db64f9ab; misc/s14_result/s14_result_parts/2ca4fa09440098e5c9ff613e567367d59096b39b9c89f46e4f1b333a96d53455.wl SHA256 678fc334820df4c4b128d8b3429c64c779b1133042e6e30e4ff6dc50d056e360; misc/s14_result/s14_result_parts/562b796858a0fc5ebcdc82abf54f033485af20712fc76bc2e04bdd864869af6e.wl SHA256 28ac436c602956a49a5a46cba9a180da71f08b0e49afdcf421f3b7b6ce62a235; misc/s14_result/s14_result_parts/8226788221cb72b8f77b643d265bb0c1dae478cf46a5d423c9add5fa328c3cb5.wl SHA256 a8bbd6d83e60cc810da3af8f610d6de6c626e758569a4fbe68f117653fac8250; misc/s14_result/s14_result_parts/0be2121d2a3ce94fdf20723a85edeba475a3755c17178616105f387d0b0007c3.wl SHA256 8f3110973da1d274fdc4a9e249836f89ff039d0cb069c76c1b9ae6b5fccda35f; misc/s14_result/s14_result_parts/497f9cbb27f74e7ba30db0a55af57178914620cae2313a8eafdbfed63a07832d.wl SHA256 edf1e2092be003cf51e2353a18d4ddf73b6f5d6a1f0e566a93baa0efac45ed52; misc/s14_result/s14_result_parts/4914ad50cda1be6bb0f7dfb708172bf85d79ad0c22947b95c52810273b4d355b.wl SHA256 02642db4d21b26ba44bebbf897ae1f96f3e92f2c36edb1c389f10f24b83ca5bd; misc/s14_result/s14_result_parts/a618e8f4624c6129ebd3a561a250ed6cd7d0796fbdd0cc5718644141150e6025.wl SHA256 985edd4822cdcf7c67019e5e028e5edb0292a3ff9d33454e825321d7d9226e0b; misc/s14_result/s14_result_parts/b96b48b6ed308761921e432d1f7b52312e7f44c3b5723fe7bc3fe9e6fbd6d56b.wl SHA256 2ab88ba320cdd3b80dd9dbdea828b4ec9d45b6a38be1b71abedf6dfbb00350cd; misc/s14_result/s14_result_parts/b7714580e97724ec72db81703098a3d8ca13539e48b94531032d237506fe42fe.wl SHA256 5c80d651d4b5ab3ed43a746d322756bb4254416cf08048c51ffddaa3470fed05; misc/s14_result/s14_result_parts/039bae8554d036b98201088f4dfccda3f1f321e284321b5cbb67b39666fdf299.wl SHA256 a6316d659c04cf43bef8658cb51a0d5ccb4a2270b8b38894198ea9965f67d04f; misc/s14_result/s14_result_parts/31d131de6fb95574afb6d724af65acdac9421c1fdfde8fbda97be3caa236bc31.wl SHA256 ca7619ca5e65614e45fd19acf30f0e327ff604bce257b19f6ed5db466170687c; misc/s14_result/s14_result_parts/b4e4840f1dce361929bf249ebff22ab64d392d5628123405991fdbb2369c4462.wl SHA256 86c6843a8092a8990c484eb104adc4983a4e96327849522aed96069a89396195; misc/s14_result/s14_result_parts/ea5d90eebab71409df80e7eb5c6a68675ae1705695f14262938f49ea37b2fd53.wl SHA256 e68c35d1e9028f6f99edc91c8b52b85aa5bdd718307eea17261296a88f29b091; misc/s14_result/s14_result_parts/e5835acce50396671f159c6046b529f1c9a9025759379de6fc1042062d144668.wl SHA256 5156e23e4b4a713df790aa417033bf427adc7f1be82d07933fe0c3baf03660ea; misc/s14_result/s14_result_parts/d109b000af003a75eaddd71e637e101909ade0700805ee871c6c46ab0b43ceca.wl SHA256 5e980aac84b538a2baa0aee0a2aa031bc47e66d2b5dab970508df7d2f4008cec; misc/s14_result/s14_result_parts/d68768cae8c96c2750820662983be590a3a81caff6b9fb5dd22cf08dbd037842.wl SHA256 6b154659d1540caf8ff12fe0260669b71e6013c835a3c064e80c3822ee6c5f29; misc/s14_result/s14_result_parts/149fdb77997dc8615f7334d967072d94512b3b356326fd4101af06e71b9bd8e2.wl SHA256 d6602ef754d3744bf5b486daa4c678615f334c5bae47ab499269742ef1bb657b; misc/s14_result/s14_result_parts/65b07bcfb9076d5deaa9261bb0d9a3030c2a2ead47672c103970e71b81675dcf.wl SHA256 88ff3f9c9e6b46cc74bfe78b6ff7cc29ab6f81ac186a4e2efc807f103a8fa395; misc/s14_result/s14_result_parts/b646cb893187d695f515452b8a217edf809224d002912736730e01208c6b60a9.wl SHA256 b2371a3d67d967eb159825e41127e150fb42c79af3b4a3572fc7422fec4d5771; misc/s14_result/s14_result_parts/6e0dd458fadbcacb6938885475928bf7fb8f4de5628639e0eb93f72c6333b326.wl SHA256 5b12912b3441da7372d449e4086cfefcc1662708d107c137289be26b32952da7; misc/s14_result/s14_result_parts/3a9d5072f9e8fa121abdb17bf46076a04acafef461e7fabf4709162855473942.wl SHA256 da4012d983ac0f7c4f4e90a23450ced1ecbb1a9fedb867b30b10077ebcdec6c6; misc/s14_result/s14_result_parts/d6a87f4f460c5e62fb02ae6c0b6e22dc1fc45ee3f56895a57c3ad302d39872ca.wl SHA256 a61d7ac206eee511751bc5d426b61f80cd3c13de316a9529da393523b9f1583a; misc/s14_result/s14_result_parts/8652fe1b6bc6dc1dd9e94da4b4404a44b27b4146f51f86dc887aae88cc54140c.wl SHA256 3f8bcc0a830bfe46559aadb1768ac6f0a0b97e154ed529379d6661426c166719; misc/s14_result/s14_result_parts/67e7333046df023f64afa58dc93b615e7f35c912506dae54fb075c5ffebcdc17.wl SHA256 4465c7edf895e1a1cf88246a8e978609d0042b986ec63635da318f0ae0e2e2c7; misc/s14_result/s14_result_parts/46f248bcada63d42a64f57558e62fab612013469a7b0e5ecef3b260758927d2e.wl SHA256 3d1eb31c16390e1d90ad99f3ce780d9be6cad08fb0cdfc9981faeec56debb638; misc/s14_result/s14_result_parts/871c73810cd986dbbab0b4d3bfffe8b453363f369893d159c74fa44fe710208b.wl SHA256 faf4186a9c5be04c3f62678d81c26cf5f2da0ab3400aa3add8aed13f1f35b150; misc/s14_result/s14_result_parts/ba7b20322a126b91d73e2e05e93eed56676de123294f73f910ca48de134b550f.wl SHA256 29415d4066c34bc9026978230c48122c8e7c5aded23888b09439e3a18eaec2c5; misc/s14_result/s14_result_parts/60800d292c0ca495b4e580b523a129fbc3220d55261e95ab321cf8c4b5f44f59.wl SHA256 2cc3693d34f3c2cc95f953d1cfe691b48210c6a2ab712685c7d31aa5d2d07a3f; misc/s14_result/s14_result_parts/1511d6009548205b11bb611445b108e7148c7593f0d0caa5759ec127f8e4064e.wl SHA256 7e7484981e125c71e2fa99980bde710252c1688e98e5dfc0dd8f22b7c886f72f; misc/s14_result/s14_result_parts/7f593f3530b92f2ef12b0f6a95e7d5f5b3d76d8163489f7cd33915ae3f29b329.wl SHA256 a9e4663a9f2df9ce928ca9b10a4788255232c73c941db3659f6c08867d3ad940; misc/s14_result/s14_result_parts/74710e85dd8fe5cb7c389667bba52daff1d7445fd3d386d126a1fcdd7ea1cdb8.wl SHA256 664bd205a004510cc865af552a749d5bdeb7c53db7e9f97fcd64fd2cb0bc7cf1; misc/s14_result/s14_result_parts/089ff5064d9ebb40698be107c71784b024b44554608da22b13e8fd210c7311b8.wl SHA256 c44ee63bcbb2082b92d11dd4b5c8c14473a956c48c18853ab58cbfe1085f275e; misc/s14_result/s14_result_parts/61dc4123b3827b3dfe3ef63693173c46862f1a801666416a64b4352b9b222c36.wl SHA256 0bfffa3c0403814da107a72f02de0499fbeab800063580f8eb6e40ff4d04c99a; misc/s14_result/s14_result_parts/5af2cd6956fcf24b5c5d0be783b408b9e2404999ee56c627a3f0394d3f1e559c.wl SHA256 e5e070a62bbc8ba15211e8fd55c3a2df8665c2cd94e1bed999ec93c5d2d58220; misc/s14_result/s14_result_parts/d3edfb8b41787bfbfdf7bae4136ab22e9ac38d8c58633b7abcdd40aca75d9cb1.wl SHA256 dbef0d9365fbfb2a67cd9fbc676b1063fa41cb1bb2ac49a2ee58347350a3c148; misc/s14_result/s14_result_parts/169f1453913ef461d02863a9af01f5233d3d7821a2aa033a1454801668a1e76c.wl SHA256 3b47877dc2ca27f910f113eac711c5d892c01ab72bb7612f2bf07b8134c764c9; misc/s14_result/s14_result_parts/4787fa95b2c42acac1ef1c85fbde7f37ff2d9537dd859a0c2249111447190369.wl SHA256 0364736107aa8a7d09af47e54382ab01792162686b1a6cc8d6b8e53e850e23a9; misc/s14_result/s14_result_parts/cade1bb84b9bd4b3c0ece21d9a040e0bf9edc62d73748fabc9c9725905e6b7f1.wl SHA256 c91dd020efe3ba622e05e047fa69d645e0cc6c2d4f644c3fc338b0d62bcb66fd; misc/s14_result/s14_result_parts/b147c65c81531377f457c5414bd2e51f1be2f04bac8d1fb0d79542f5ee9b9d88.wl SHA256 969d0deb57e8813b34cd93d9def7fe77f1605174ed15626adb9ce9d394a387fa; misc/s14_result/s14_result_parts/f84c116f671eebb5d4218817663e973d94d166729d9f526ef7c36c694c8d97aa.wl SHA256 3e658adb692b088e6e37f4ab107a49c5d9ea5839e28a3a07c42d9463cb76ba0c; misc/s14_result/s14_result_parts/e0bdf96fa1484d01077e03770656d48f6e3a2d4e143d4397fbe63fd2fa7c2df0.wl SHA256 e2fe414b914fa7d7bfa0adfb781c8ae633e30338dc06cecd89a8343f6eced89f; misc/s14_result/s14_result_parts/f6e5a361c0138af552f52e644d2ec4048406679de5a305bfa20c00c1c71ba385.wl SHA256 a6c478bbcc7e461213d62c1a82484fa260ad1f1fbf25d791c13b2b2b15d9a9a2; misc/s14_result/s14_result_parts/211ed7649c89666b11b92f194c9045cc929a8308d9371f3717a6cbab6e42a91c.wl SHA256 d6c228a240fee2d6b95a64e56e547a2f26a9662340ae6d06729acaf60c3d845c; misc/s14_result/s14_result_parts/70c9f5958e8adafb6e2371831449b7d1bda8e572e4d800c53c454ed7d940272d.wl SHA256 f014666458634e8b8c140d3f524a8c6796b0f391ff12e5bc7dbb2b21d1efa833; misc/s14_result/s14_result_parts/7f76d6dbc5959aae0525a7d1af39e1a4a8945698fbea627cd578d512fa3120d8.wl SHA256 55f166ab9cf4ce38d23ac81df89f00d6cb4ab51933833a4bde9d569389bc85ce; misc/s14_result/s14_result_parts/d419dd9e23dbdce609c50937315b689f51dd0861f7648a5e4d721b4cf1f2e914.wl SHA256 27250bdbde52d0fc7620b689985fb377c4ad4a6b1c5350b75f0ec2e68d37f766; misc/s14_result/s14_result_parts/9206a17d921f5648fa7295b73ba43ee743baa83ac7efca475bf1fdcafe505d9a.wl SHA256 759fbcc36094c9de606c2210ef2d36eda02a20793450c6bc212802518059e48a; misc/s14_result/s14_result_parts/6f2c8600fbb82650db700b1653f11fef4639c680d89fc2483c1da42ca70ed5f2.wl SHA256 a3c8d68866d2c794f60c6ebb590a402216af983fefd568facf1b0af80940c953; misc/s14_result/s14_result_parts/25bf8e1a2393f1108d37029b3df5593236c755742ec93465bbafa9b290bddcf6.wl SHA256 20c470e9bc59af8c25c370a999f271dc595875aac4b7c0664044a08c692f57ff; misc/s14_result/s14_result_parts/bedc5f4f6d3de55f840d3ab488889a3b1a7358b4e90d0f06d724632a48d3eb1f.wl SHA256 7cd41ab4f567737abc844ae8d2562ea16f21ee7238d54457700026fc5386d809; misc/s14_result/s14_result_parts/ee666c3a6832f66055593e1a43992698d9f670ee5e7058c98238df7b49353291.wl SHA256 1a30e774da74e8e766997c042bc573596368c3699ccca71fa27576e9caa946de; misc/s14_result/s14_result_parts/379e4a295817c6fc46ff9a1f48849cd68fdac149eaa825f0372dbfab9db9f70c.wl SHA256 0848c2f3d23ef2d94a1235beaca7805c3034e3330d6814a5be11462354479465; misc/s14_result/s14_result_parts/05ca225292275ef83c215f060cdc121a5272e22e2c1bb4aea41472c330da2fc7.wl SHA256 584ca3b1896ad6460561dd07919da4b1decfb98f3b0f65c8d086d3a056c6f067; misc/s14_result/s14_result_parts/5a10f1fb92008f13ecabf2752cc576759e4782fd69135420ff9c70eeb765d7b3.wl SHA256 8171ddf5e3c1349160ee9cc2d95d314da735622475f79e8d04e4f023001a7a69; misc/s14_result/s14_result_parts/a290de9e253e3ecc6c4c778a516053fa3943e092245f496b7505b95518028cf9.wl SHA256 f42294b337fd9dc2015fae6c11a519d0ea9f3484887f954f3c116907f1fedbb5; misc/s14_result/s14_result_parts/040efaad166733164a722e35eccb17c2a19a177fe1d5c108b61dcccdf198dbec.wl SHA256 ad65f627c0035e9fdc68b67e5ad4f0e282dfca2fda9ab561aa7d1d8caa7c8da3; misc/s14_result/s14_storage_interface_parts/b840929d3c2ad8bb58a03aba2a6e9ef9053722c475bb0b0793b2b15f60077dcb.wl SHA256 1dfeafc17d167152f0884def751246ab94d2e719c0575eeb790c3b11ae316565. Consumer must use the documented file-storage interface; remaining finite/export stages are still required.

Accepted local integration and finite assembly are exposed through `s11_local_real_result/` and `s14_local_finite_result/`, respectively, pointing to their original `../misc/` result directories without copying or changing files. The existing `s11_result/` remains the subtraction result. The final consumer uses the local finite assembly specified in the reviewed S15 source.

Accepted local s15 intermediate: source 451a6d5a9edf93e9a40b8dc11f37450d2e529398bdf0fac201e9be9158a8b705, configuration fa1aee168aef34b9882e36f242e58cc4e52ef2d9b247d2f30daf7ed4f0fc2254, receipt 3a0341da88a41f9bfe68dffc4557530c487f116f621a4ad092c28b282fec8b52. Executed checks all pass; actual local runtime and imported conventions remain separate. Artifacts: misc/s15_result/s15_result.wl SHA256 8a15dc756ebe12d25d570c3c14df83c4f852087306885bc7d82bbc118fc7998d; misc/s15_result/s15_F1_hat.wl SHA256 9b1b639dccc5a41e058359093447f9b0699f4a8bec78735ec6e960644c72cf63; misc/s15_result/s15_F2_hat.wl SHA256 c35e8352fbac86abbe4b4af0548c42bcb4e1cf61312e67528e6312ca92af36b9; misc/s15_result/scheme/s15_result.wl SHA256 58a1e69a771a23c59d9460047301fc5e1321de92af90ede4e40981c3e8f832b3; misc/s15_result/s15_checks.json SHA256 5f2e5b9238ef656e8f61bf3ea163ae496325a54b04d9727c908be203c14d2f18; misc/s15_result/s15_result_parts/0591f66446b12ed0d8c2762a3c192ca9466458385d14491692fad1d4949366b6.wl SHA256 f18be7a33d13366f27087ac8ab89a8506f4a51994dc113b831508edf373e5622; misc/s15_result/s15_result_parts/2923c25472f5b106e0b452ede56e5918668f33cdd93b479cd65a335a5e339950.wl SHA256 17ff7f6fc541fbd2914a66cb0e7311546764b5b0a93f55f949a499a57ed49769; misc/s15_result/s15_result_parts/a8666eecc4ba7017399e378a55f6a5a096a725b0ce9b49441130e3ba0e2c333b.wl SHA256 c47e4b0e39769d31435abf7e5cd2e1ef142f87ed052586765a2d0eeb4399a582; misc/s15_result/s15_result_parts/eff8db4e62371bbac77fe6a8918b04c150433185da0344a29be3206fe9094bd5.wl SHA256 9173584978b21a05734eac226e3517790cc4543554933fadfe1ca8d6a7d1e09b; misc/s15_result/s15_result_parts/cfdb15453dbb8b07a1e043c0942d516000a8a1e51be30cd2ea2aa87edad07075.wl SHA256 28781d45d5d499ed8f80ea97d51f51fea2f8b0842bdff676d534ad4cd0bc5bca; misc/s15_result/s15_result_parts/9ab1340573102b941de204e9e425d30682884770ec0cc1831b1e21256d602730.wl SHA256 ef9502603e9c12b65ffb72ea369355ca5e6b7de0750554f3c404e6c3091f5d71; misc/s15_result/s15_result_parts/683b882cec8356e2fbfc2b6171960377ce675d76e7d4b9de2090f920ecce4f23.wl SHA256 171ee3ae1fc0c36df1f11b199dfba8afaeef68e0764f3772248d9149af708634; misc/s15_result/s15_result_parts/07df36a31ace04b3d791e3288203b608d940f66dd444b9938555a3a552e8a190.wl SHA256 e7d21e83695d1e09a611e6c7d4970b1a3324cefb03f92167c0ad20490258e8b3; misc/s15_result/s15_result_parts/691141a97fb2d126ebdf18069a690262d7aa26c89865459def06c82ac8d124b4.wl SHA256 80ea41c93ccc500e5163f5ceafd8362195b686419d5e641d712f631b44107a97; misc/s15_result/s15_result_parts/b3ffda58cc6230147b13e7db368fe0596daf31ada58d568db48f437520c9cb11.wl SHA256 37a8cb26b3496daa44183ba071adcff024452597517f26ae113a652ce4c4f611; misc/s15_result/s15_result_parts/3cdd091831a910a6d3568e8960e6cb9530e5f5e6b11c2a0a8d8db9999c720276.wl SHA256 adf83814730fc748c0f93c57ff3e8a66b51b5205e8548a180485bb0ebaa16910; misc/s15_result/s15_result_parts/7f142edd0eaa1c4efc28ea18386b83dc863ba646243b8e423a776c79466721fc.wl SHA256 266f2f668b261a84d8a97d020d2cffa25fb4694dd06f433cd36f665add8bcc55; misc/s15_result/s15_result_parts/829a9065a2f71bf83f068a6fc5148d2a369d39f812175e0573cddfbc38f56b1f.wl SHA256 e8041b0d731595a38345bcf93720cfd0b80a2e4317c3d091c3bee87101625243; misc/s15_result/s15_result_parts/446ece1790299d5ff24bf6830a5c31a35eda013016cbb25d7817509953da79ba.wl SHA256 823dd2a928e56d640643640c063b8bccbf963a41b463bdfe3c808be82aa1abab; misc/s15_result/s15_result_parts/cb8478f0493ab6f0a4303319ee440ea5340ae2cecff1c669859aeee96a7ec326.wl SHA256 872785d44a04f8f1031bcd7ebcca24d1a68f0b88c3e28a8176e065aa12751447; misc/s15_result/s15_result_parts/7e8654c2dfb6567100c69b9c9afaad692bb7ac04f841dd214d76dc39c9c4e9c4.wl SHA256 247666727d3c3fe176f1a16f092bb962361811ad39db7898bc788f408b2e0571; misc/s15_result/s15_result_parts/0c81e98bb12584b8f3b7a4bd29a01c8d9c23d1ca885c31f14391c33851310045.wl SHA256 2eb8ed55c7a0fc78d9b6745eb9577ad84e2f16d89a778a05c1eaa798c4eb206b; misc/s15_result/s15_result_parts/0d5cec5ced3cd0ec22f1114ff90f1d99b31ed5e656aa294177aa7116898b8ff9.wl SHA256 6d0b81e1999f57ca0ea864b58c14cd16faf51774b62c58a64fa5bd6516997bf3; misc/s15_result/s15_result_parts/518816620559d913d35b83e54f3e0de04a110ad04661473f8dcd18de72d9b09d.wl SHA256 59a0413f30b56e56ba231e89b87e51631f2a49282189e354b11f76d2a2d9f888; misc/s15_result/s15_result_parts/1a19b2ed7dc07ebba4343fa2ed1ede9ef3446cd352fee5aa484704eff1d7c594.wl SHA256 4f765d9403c3b88f9bcdf2e8444932ec8f99af5614e6515a9aa1124794655857; misc/s15_result/s15_result_parts/1a30a3ffe8fd956f1e1181103922713807707ac0ab1a0fd48bb8830fb3cdee70.wl SHA256 850bb9b2402f539ca8bfbdc405dc8bef26795340e42475aac8354a23dec05bb9; misc/s15_result/s15_result_parts/85ec998761ec731bc9990e78013da32b0f9bbb40b35f49bb2d138f9b47a3d8a6.wl SHA256 4eb191836249bb002b1e0997a3c8ff9ec2e5fad462eabccde34f9506fdd57ac4; misc/s15_result/s15_result_parts/3aac1695a07a3dc3549c55e262edbebbc1d56f8db49d2f455c59af21446bc194.wl SHA256 ef9a7b84921bdc2aaa5de7134edf6d4b3d7b023eeca9d4a5ea71e1784fd7d144; misc/s15_result/s15_result_parts/efeb2d5c75f06220bd7c65b593315eab21ace0f0a7bb10c198ef5ad0704852a9.wl SHA256 2e8988f52c7c22aa2d4ab4a848b7b9be0c7fca0fd9fb977dc0203873e8ed5c26; misc/s15_result/s15_result_parts/a0e252f0a9fc19cd3ca9df3b64f11c134a016d6dfa41d3cd7a2c8ea2c3236f9c.wl SHA256 e97e717baed3d4970622c7b6589e29caa787dfaba8d6fdb63ffbd6d7720d73d5; misc/s15_result/s15_result_parts/a8cf8acae9809deec06328cdbe9d905636838f5f9e2d684a4bd4bcf404ed42c6.wl SHA256 ec75ea8a2d8fc93162f227cff0de04998eba57fdfebc912724d0d88af825505f; misc/s15_result/s15_result_parts/aca9848ae3e50a1cc72c6dc54eccf2bc16a2260a83eee288375c6188c172dcd2.wl SHA256 30eab29d0f4326bbfccf7df80129cad8a8a9493d5cb2a2d5723c6226cfda0452; misc/s15_result/s15_result_parts/d3f16b730c0326c3a5e8c9bf5da1529c227d37a7b0d5b2bdd049c93670d500c1.wl SHA256 96de0d547935657c68113ffe4447492f2cb406ee5bfa49b6b50a128ce2fbab35; misc/s15_result/s15_result_parts/1e9cf31beace1e45bbc97197f5e097bdccf5ce3213c62c42d783270618de3a66.wl SHA256 6c9f1e34a508bab3cddec8cda5205169a6d5ebc60adc988337fbb6c59eb96461; misc/s15_result/s15_result_parts/0aa7f58e718c71566ef6ddeff3f6d4fae1e5377613969c6d65645846c638c5d7.wl SHA256 dbed7688a2baee370d5010fafd16528885c6382400a99c02fde3e3805fc273fd; misc/s15_result/s15_result_parts/afc222c68f249b8f40cb20a2f55b8bc268b884865c81ffde27319f258964f464.wl SHA256 6661ce37056012ab40b21420be36f454e4f0972615ea4f31c8afec73a73edb22; misc/s15_result/s15_result_parts/1f57e713edffaf165d377c3e675cff1f1316b5542595e02d543c253279a9a983.wl SHA256 6a98e776fe5fb7d5ce3e874fd21c557f7117b48695ab2807704c74cdc51e6277; misc/s15_result/s15_result_parts/dcdeaecefde4c4bf20af30729e3995f298bd4bc7f28f88ececd42066180ec582.wl SHA256 667db9b85bcb18af6f9d91e7d5198bc1c17e91b4ec3d93a4807296051b34bfbd; misc/s15_result/s15_result_parts/95f53f7a59cb7a60b312bb069c42316971bcc96fefb92beb3ec952a6462a0741.wl SHA256 510ca553a3a8137ce6ac7c0d67b075fc721d349051693d7067cdc14b246794b2; misc/s15_result/s15_result_parts/b6bcb3d49de9dc49ca96ba16e92b6832e1b8ab7ef1504c259987cf646880e5c0.wl SHA256 85975e20b9b72315b44f88214d65683bc9d3accdd95b31ad87c92613d8190e44; misc/s15_result/s15_result_parts/7d839796f861bfaacca23cc34dee037d0708acd4f0e4d230df6898cae00a129c.wl SHA256 6f1302e9c5569519670050d4ed2b86f05a256fae7f1d27865165fbc8cdc877be; misc/s15_result/s15_result_parts/e6e1dc7e8bced01153d1025b04dad57e2fff5dbdeb4c3b6f15f2a93ea765e1f8.wl SHA256 141ea6ae3f445e618e8671468d5adf5accaa0da8f273f317dd6193c29dd1cd8b; misc/s15_result/s15_result_parts/32f3828c4ef7c78fbf26a523e0b15db23cafe6ad0303c5c8305eb6597bc4df7a.wl SHA256 9bd35c87cb3ebb60e5d5ddc264246789073c4baca3cd0266040778f64c24e7f8; misc/s15_result/s15_result_parts/c9a1329a5938a744d693eefbece06e7768c1786606f9ce7b254ae7c8f29a4b17.wl SHA256 af4b69904fe5ba3ae369d72f5b0bf25ba347714dadab01df08156936871b47f8; misc/s15_result/s15_result_parts/e40a6b8c1f634e294ef1b772151643d2787c1af1ff19575bfdf718df2ac4e5e4.wl SHA256 3b394419868616a0e276a8cb5d0fbb1ed33e09635c12ca4b3d1a9600a959c5cd; misc/s15_result/s15_result_parts/d3c71de00e109f5bf815bae91d7808defc04b502b45f51f57fa0813b7e52f977.wl SHA256 72e30bf72675573301122093152c749b069a90d7433a9b319bc60cfdad63233e; misc/s15_result/s15_result_parts/c74774bb311268fd50e093d0831e60b83737061b22bdbf4ef6fabf5992be07e8.wl SHA256 10fe1920f7229381f8eb6650bdba8ca07507d3705c4e2f514ae98924d5596ccb; misc/s15_result/s15_result_parts/785ebee5062cffb3932aff356249ef2ef96e96be26fe79c245728330686c99ee.wl SHA256 f96bc3dceb06e65ef28d0e7163601c6dd9f341d653337c8431d87413d3c4bf21; misc/s15_result/s15_result_parts/4ad48e2ea55ee125e92046efa4fe1c6e3d35b95b9745a0e22e325c0a7c65f686.wl SHA256 2c1494fcb8d51ad35f4fd687640399cd91c83b037a721f0bc445684cd67beedd; misc/s15_result/s15_result_parts/d77fdafc36774b8f8876055cb897435814c6c414243e21261d900238ee37840f.wl SHA256 31d681b2190c4251ca7bb0a0700b9d3f77e699ec38f7a21e85cb9677cbd4eb77; misc/s15_result/s15_result_parts/df3c9bef01396a073ea5c7158ca73e60a6cff51beb9b00955acc0ed5accf436b.wl SHA256 adce8ae0df5381870f12d72d4f0f3e3f0ae2a970955f081e62d510bd010935af; misc/s15_result/s15_result_parts/2b3993eb44886d173765666a909622133eb8d8c2ac635e03c8310516324f3209.wl SHA256 d184981ec2a2a5f78eec7da9472c144f3281b09cd187c0e409c056388e6fa7ff; misc/s15_result/s15_result_parts/27302f1e065bd1a6c02985449e08851bcec531499912e742564ef5b72fec7a82.wl SHA256 292df4af6b032618ef60cd7e07dad3a80c8da4f92dfca72be1f8be427c216739; misc/s15_result/s15_result_parts/bb42fa1fb55a0deaf48f4287be2be41fe09263312513b113d70d4e7f0fa9c70d.wl SHA256 c1213e486436e591abfc9290734371cc0dd462ab3a9099c98baddb0dd27711f9; misc/s15_result/s15_result_parts/34b93fa377b325749c5f5399d39e9f85dc1402377668aa1247eb4de5af77a047.wl SHA256 335f3dd84cee8ff25535a70c4f2f9aa2282cd3827a223bc6e29fe346ec0f0d10; misc/s15_result/s15_result_parts/d490188055ace6545e437e4b66e0e40961657000eec7ae678b890da1051f1acf.wl SHA256 b2da9dc1de8de2f7c41d5891150b71d920a5e305736f2c8c5bbadb8071bc39b0; misc/s15_result/s15_result_parts/5ea8b12f6de7ce37db0dc155676481ff9a99ca59be1a70259b1a400fadde69f7.wl SHA256 cd1de3280a91bef86b9f978f556db0f4d3c7ffa2166f096c1bdc429fae8fa1a4; misc/s15_result/s15_result_parts/081309087001b816e3ded28b61307946f553395cf3bf593fb96f8040c43062f6.wl SHA256 3ddf489eb5b23d15f34bae0666b941341c189cc12343c63918ddb1baeca92971; misc/s15_result/s15_result_parts/f49c8832d668ebd396b68d99b3f4724c1049adae0b92459394896c59bcf47c79.wl SHA256 e9bbdbc569aac09875a5da88dfd3a318e8b73057ed9d678fb7bcc59e75e01f69; misc/s15_result/s15_result_parts/a171f7369ad8969b2bdb9281bfd0ea4bd87e8a951f11b3edbb448bbe1d5a13fc.wl SHA256 5a90c1578b8b4f9c1443746c02efa6439a6b7a388306c4bb9fbb4db55dcdb75b; misc/s15_result/s15_result_parts/d06e3950d7820edc655328ebf42fc7c9c34e54254d0acc098407c5c52f9fb7ae.wl SHA256 be34d8e9dfc8f360926e53f923aa02711fb800047ffb643c938582ea2406f9ee; misc/s15_result/s15_result_parts/1466cbe97315883ce05b2223067bbc24d8a543f782785d80d98d1a303d5c2b14.wl SHA256 7fd91878b40333e7ac5fc5466ee675ae5eea273c5ed81987c17cf9112e3a6218; misc/s15_result/s15_result_parts/c56aea2a0220582aa42cdb29e3d6ed8803267a4f35fa7db605a2206f30dc9fcc.wl SHA256 8808f535dd3aafe0d68e3cb7fd0460d88a7e7caad7f807c71022be279c8e1447; misc/s15_result/s15_result_parts/c782d2749400be2fdd60115c4c7d32db6f137bbce09fca675154f8f3aa69cbda.wl SHA256 f4d09cad66ce4d2578df0a410ade5a81d3873383353cc967e2cdd11f85517e1b; misc/s15_result/s15_result_parts/4725b2fc562833f5d99e834c2e2c0f13d170d4649936683d1a11c8a17ee5a9df.wl SHA256 b4d4c74c40d474799217d30733e0ea0150ab2db610e7354630e7f732f5a574d1; misc/s15_result/s15_result_parts/7e494b7544eb1864212e84bee0668902cbfc4fca9e5a593fac32b211de447cf0.wl SHA256 a8c1ca30dcc8e287afd8aed0f946322eab8fc2e338c23af8a27caf34a81f12ac; misc/s15_result/s15_result_parts/c0b7c3072542c0a6a016e6c7523894cec034fee008575c7783c9fc1e7c4943c0.wl SHA256 e298a73aa804456aebf981340ab234c6206857393d660b809b6d3e15a2cae75f; misc/s15_result/s15_result_parts/21d10e00e48502d3f9fbdeac9e807718e5030ca85582cf03c1485d7d8c90c54e.wl SHA256 936dd592c7e7e4ad46a90cf33d5df7bc8ecc36d84f239e18b3dda84e68d607d2; misc/s15_result/s15_result_parts/2a27c1a477e8237844f9feadc9b1802b0b8fc218a3584cfe1417ec44ea8e0d3a.wl SHA256 8d439ffd92e59fab6aa10790e314fb67911483c53dbaa1a472e1d2041a90cb9f; misc/s15_result/s15_result_parts/916f8855fa5c1b07eb7bad6488fd312264d7e7116c411f4709d6c05009f6f98d.wl SHA256 b01fc9b8f89c9b9e8476f02f598fc6d581e3e52b7e99e4dcd53a2180e66be047; misc/s15_result/s15_result_parts/fac4e0396692adb4db10e03e0af2f149322a09ccc92934fd462c9ed714b51ce3.wl SHA256 74d6c6c0d08daa8f571fb5f96094ededba4bcfb11f750f6008e78c73147d5e63; misc/s15_result/s15_result_parts/7760cf604f8dadd8f1da87afc20631a321340e8da47412adb17a2683f250815b.wl SHA256 9417aee42ad76c8cb8951d2df873d9a104d4f3f9509fe4ce22dda4b4ac5411cf; misc/s15_result/s15_result_parts/795d91c3b7e80d08c8824f6a25996949e215c48f5549301c604ea92ec61f4258.wl SHA256 6a0270211c1771881bd435a3a8c7ca1b840b123216c45a4b8b34e90e6fc0c6eb; misc/s15_result/s15_result_parts/234014754958647d123f5a698c33859c0ff4a0657ef1ae6fb89765c085690364.wl SHA256 c33253ff5949bc5abc1348c08f74316c73a32d354400733a509d1f7a7869289d; misc/s15_result/s15_result_parts/9c0099ba4d66e1a7a1fcba32a821fac060c7fd39a135922e2a0ede98c27675f2.wl SHA256 cc559bd9d9c480de7ba4bd035d16a021a9910a9075403eca40af2e604eb727bf; misc/s15_result/s15_result_parts/058bbc6341bcec89042bcbe7f7db3317935a19d336db3c726e8ed01df5b0d5d7.wl SHA256 2acf4b1a95da1b2b1bb2aa3f030e8003993beb8eda470e5107021cce2a57f0f6; misc/s15_result/s15_result_parts/2c97c6cebfc0fc5d67d36450bbce46850132109c0a5007f08655cf4c4873a56d.wl SHA256 4d9d3bf1b8b9f6849347c70349c76f61150aaec83e89b36c35c85ed79f7e8218; misc/s15_result/s15_result_parts/7f76be438edf2ba0aa0f7ef99c64ee8887ef8bfa850141f6496d4a17f3305e67.wl SHA256 31aac3d3ad44bbfeef6128460dc29ea6b02f7842802d20eba7aa4474b6d95397; misc/s15_result/s15_result_parts/b698250e3f5d71871be5d2fd7ad97ffc44cc6f03eaff8e6a73f8269113378cc3.wl SHA256 a5ef9d21b57be07e1b620212eb6b150a10e12bb13accf3ce47fcb4ec38666f00; misc/s15_result/s15_result_parts/d481e4f48a7279e0f8a494b6199966d01d7552907f6aff5bca919b82ba81fae2.wl SHA256 c7cb78f8759d3ba918678e7569929ccbef9696684a1f253fd6e19a153323243e; misc/s15_result/s15_result_parts/e9ea69604de40a4df6e2bf9dc78cfc02d8d947c5dd83f489c33962c155615ece.wl SHA256 17a140f0a5943f8178023ab07437980a52ef6259d157f3e232ce6394241f29c4; misc/s15_result/s15_result_parts/fa6efbd607870dcfd4b418cea0c3fe6fad69071023ed74c4c2c8a10e6be041a8.wl SHA256 19f83900eaed0a4f34b17cb8b5f8cfabf02f7ae1eeb0ea25028e4240f706f87d; misc/s15_result/s15_result_parts/52635ce744920117f4d80725b01d0fc8a107580e40067b8906c61accae532aa0.wl SHA256 b69ea3648ad52ce0088e4e060dd0579c0f99e207c997bd18f9037b2fdbb5f8b0; misc/s15_result/s15_result_parts/3937a0df8c45a39643238c0b5c8348851ed80ca044cc7c021538c864e29591a6.wl SHA256 c4c82fa9cd364ce6da8a6cc5c97402a40335b15215dfa4cee21e9151002d28ad; misc/s15_result/s15_result_parts/4daad588f07ac2ec08ce5dda5c372c3759b8b75c8ee07ceaed4090a2d36d1927.wl SHA256 f2c208a081efb2f9876f8cffa72c72ae5abf3af4c9964fb98c0bcf262c285998; misc/s15_result/s15_result_parts/8fb7963c535194ba97b24cb605b5425c72a6b9c749ba4e3d0f603c10000266f4.wl SHA256 8867c36fc398355503b0aaf95f0cb1f698a4acfb7b3210d78c1097a42259e3a9; misc/s15_result/s15_result_parts/5102625724c6d07da61ea88ec1f5f4b848467d645fb4f9437215d75484e4b12a.wl SHA256 bc4b854727c55dcc153c4da4f1873d0a69c275deebc105964433f7b3f05a70f2; misc/s15_result/s15_result_parts/9930f3573dab5a0483e44906f241f2a8a10358c64ca04e6528615a92e9f94526.wl SHA256 5ffac9cf37f28de4e5151bc01b1230aaa15bce92fed01f64516d5a0abbdcabd1; misc/s15_result/s15_result_parts/ae9f44742e5ac8c8fbf82a4d7533b00e8b7e8615fc5e390b16b30daa870a1636.wl SHA256 15a69c97eff1092bfbcb61a14d82f88e5005731b63fc904bb2a499f1feac6a72; misc/s15_result/s15_result_parts/e0cb07fc99f6b871ec58c1d6547c5b069a306b0de8074d4006305b0cf070e9c1.wl SHA256 920117f63088fab7a965327a2803a96ee695a0394f3b858e18c4d34f954a9a74; misc/s15_result/s15_result_parts/9849e3d1363ca67968e56bf10994f6572a5841af4df97adc9c408f9920ec9013.wl SHA256 dd1da2ea8bcaf4c7050d2f88c23bc3f88a0852ecf63ff64aa46136b85d7d75aa; misc/s15_result/s15_result_parts/076d084af240dfd0fbc0b238382f6d292bb061b5647d812d47f17329a2463f1c.wl SHA256 5cf75bcce984420dff9e21ed3901c4c850508fcebd59b69fde7accb5732cfe71; misc/s15_result/s15_result_parts/3d2657e44444e31b63ca19355e31677556fdc59d5e9e9382140fa9953816a7af.wl SHA256 7d173819ef725355c37183b357659e1b12c298046fb77dc782bf510803a67143; misc/s15_result/s15_result_parts/a2a890de19ed498adfb971cd9bf36cd6ea8ba465e218ed2f67f9b6d2aac38afd.wl SHA256 5cfef62fa40d2ee29fd321bc0a1568fe637816d5a842374a75e15feea2a10503; misc/s15_result/s15_result_parts/9b58afb58bbc68400751966c9c45f6103224b6f4cdbf649a10ce90c63725ae7b.wl SHA256 c3f1069279a0028c981f8d22555fcd547a027f0f64d5722f20dc4eabd062fa46; misc/s15_result/s15_result_parts/28786a7f3048ad82c2f59558cc339e73173b0b1d283a2b33da63688a31b77be5.wl SHA256 7be1af09189aba6858832ffe9fc099a7add42b6597b0f59972f40e23f0892b25; misc/s15_result/s15_result_parts/bc0ec11c1b5644a30662c5336d488659e73e99d9a709e459dc53c2e658167a8e.wl SHA256 ebcdd8a91d1a524c3ede27b72014e9b7890490bc109ac61a344e15e82ea83863; misc/s15_result/s15_result_parts/a40b981ddca161ffcc4dd13eaa6cd259b00c93bf602049c5d727de38bf950e28.wl SHA256 70c9a4b8afee4f98ab8c3885583042a6c75687a753ec0b2cc0637b3b74fef7b8; misc/s15_result/s15_result_parts/1446254d0978a441f230294450fbcc4e84f99d8d43b9de3c9f12a489f5ae9bcb.wl SHA256 a27fb9319428cde1bfeb58127b6aa7d79d5bf7c44cc705b27124cb4419c706ef; misc/s15_result/s15_result_parts/0fa18bba8200ef033e42beccc5d31a4c1419421c432c3b86c7ac1595fbdb7a1b.wl SHA256 9169df478192258826bd5566c24884113ea94cba624c44162c1495274a03690f; misc/s15_result/s15_result_parts/a4dd6c4104aeeccc91ace968e29196de83f33f873807fa7d320a77eaa4adba06.wl SHA256 7010cdf60a2e62e5c624a4bf7d053a616405b36f2b5419c4dc447ad6d0d587cf; misc/s15_result/s15_result_parts/f78697b9d9d301cdc0fcc04f400dc387e62618019ddd2b5c5c9897b5fee3184e.wl SHA256 5c10747ab3116fffe178bf45f73b599e1468723d4ce3880bc3b24f3f71cca814; misc/s15_result/s15_result_parts/cb8d93962d0fc3c168f69dadcb7067086710c27b5c1fd5b96d582bf4e461774b.wl SHA256 7f187bb44c116d911745de24f0974a6806926177b0e8438a5abea97a04804263; misc/s15_result/s15_result_parts/fb2cd27e538a70bb8e7ed653131713b89a2596763d5bab1cff27e79f19837a1d.wl SHA256 f6708b5e94a9a3dd866f2287914793b681288bc087655ab6158b4d599287ab54; misc/s15_result/s15_result_parts/6f80575ab485b3b50a6e054cce218c827b321fc02cd2da9c936867db1191106d.wl SHA256 f04612dc62d4e339a4cd9dbebfce0046734d8910461a4f7aa1ff8b202a4897c8; misc/s15_result/s15_result_parts/57b50f9a56bd9620dc60921ae762a88ee58fdd51297d85becaf01cb9a59c3545.wl SHA256 176101f3f8253984b72b50c5133613e0dbafe43c59a290c0060ac27aa998861a; misc/s15_result/s15_result_parts/4602fd44921aae3f2781536faf1bc5871aa47fb61823db3dea0ccea7ba58665e.wl SHA256 8c99976cb07c568cbe0fc73a8918992e7d5be2c55447cda020e6b1af010a5c92; misc/s15_result/s15_result_parts/f65c82e4a747a2f472c20262f7390f67e61e46f2e0620ba93a8d9d349ef62bbe.wl SHA256 8ae2bf0f200ac827853184da915f83f1303d78f89de078335e056de370417081; misc/s15_result/s15_result_parts/bc61ea75aa71ecfe7bd46fbf82d6bda5b59d4517716783c2769d5618cbabc1bf.wl SHA256 350a83ed5cc7bde7f77f56d56495ff2d7fea8cddd57febd499172d9e83dc6baf; misc/s15_result/s15_result_parts/562b796858a0fc5ebcdc82abf54f033485af20712fc76bc2e04bdd864869af6e.wl SHA256 28ac436c602956a49a5a46cba9a180da71f08b0e49afdcf421f3b7b6ce62a235; misc/s15_result/s15_result_parts/e96268f5454e939ac7e0f692cf948a1e2fd83cd098ff20376f3a8d32a86624f4.wl SHA256 717c2ccb84589bc2ea1b178d89900682be2b934a476531fa914a529eb9e8f996; misc/s15_result/s15_result_parts/0be2121d2a3ce94fdf20723a85edeba475a3755c17178616105f387d0b0007c3.wl SHA256 8f3110973da1d274fdc4a9e249836f89ff039d0cb069c76c1b9ae6b5fccda35f; misc/s15_result/s15_result_parts/497f9cbb27f74e7ba30db0a55af57178914620cae2313a8eafdbfed63a07832d.wl SHA256 edf1e2092be003cf51e2353a18d4ddf73b6f5d6a1f0e566a93baa0efac45ed52; misc/s15_result/s15_result_parts/a618e8f4624c6129ebd3a561a250ed6cd7d0796fbdd0cc5718644141150e6025.wl SHA256 985edd4822cdcf7c67019e5e028e5edb0292a3ff9d33454e825321d7d9226e0b; misc/s15_result/s15_result_parts/b52402bdba03b595f0ffaf91aa0e7311010b36ab79cdf3f2771042d238d8e868.wl SHA256 4e833f7d6ac686ac19f03627f42c16ce8fd0510a900b75ce9cad670407a4943e; misc/s15_result/s15_result_parts/31d131de6fb95574afb6d724af65acdac9421c1fdfde8fbda97be3caa236bc31.wl SHA256 ca7619ca5e65614e45fd19acf30f0e327ff604bce257b19f6ed5db466170687c; misc/s15_result/s15_result_parts/b4e4840f1dce361929bf249ebff22ab64d392d5628123405991fdbb2369c4462.wl SHA256 86c6843a8092a8990c484eb104adc4983a4e96327849522aed96069a89396195; misc/s15_result/s15_result_parts/ea5d90eebab71409df80e7eb5c6a68675ae1705695f14262938f49ea37b2fd53.wl SHA256 e68c35d1e9028f6f99edc91c8b52b85aa5bdd718307eea17261296a88f29b091; misc/s15_result/s15_result_parts/149fdb77997dc8615f7334d967072d94512b3b356326fd4101af06e71b9bd8e2.wl SHA256 d6602ef754d3744bf5b486daa4c678615f334c5bae47ab499269742ef1bb657b; misc/s15_result/s15_result_parts/65b07bcfb9076d5deaa9261bb0d9a3030c2a2ead47672c103970e71b81675dcf.wl SHA256 88ff3f9c9e6b46cc74bfe78b6ff7cc29ab6f81ac186a4e2efc807f103a8fa395; misc/s15_result/s15_result_parts/6e0dd458fadbcacb6938885475928bf7fb8f4de5628639e0eb93f72c6333b326.wl SHA256 5b12912b3441da7372d449e4086cfefcc1662708d107c137289be26b32952da7; misc/s15_result/s15_result_parts/3a9d5072f9e8fa121abdb17bf46076a04acafef461e7fabf4709162855473942.wl SHA256 da4012d983ac0f7c4f4e90a23450ced1ecbb1a9fedb867b30b10077ebcdec6c6; misc/s15_result/s15_result_parts/d6a87f4f460c5e62fb02ae6c0b6e22dc1fc45ee3f56895a57c3ad302d39872ca.wl SHA256 a61d7ac206eee511751bc5d426b61f80cd3c13de316a9529da393523b9f1583a; misc/s15_result/s15_result_parts/38bade02e6f9a94dacceaf753ff8b99aafc40a9c15a44f5122107debea51b7ba.wl SHA256 e4d7ad9b2c6e006c5e2cd647461ab2cb13dfdcf6eb1f83efe666b9a018b66897; misc/s15_result/s15_result_parts/60800d292c0ca495b4e580b523a129fbc3220d55261e95ab321cf8c4b5f44f59.wl SHA256 2cc3693d34f3c2cc95f953d1cfe691b48210c6a2ab712685c7d31aa5d2d07a3f; misc/s15_result/s15_result_parts/74710e85dd8fe5cb7c389667bba52daff1d7445fd3d386d126a1fcdd7ea1cdb8.wl SHA256 664bd205a004510cc865af552a749d5bdeb7c53db7e9f97fcd64fd2cb0bc7cf1; misc/s15_result/s15_result_parts/0a946d05ffc449e1c46ea682cd1fa94ef3f16e62f399f0af4d73f61e2f9257c9.wl SHA256 e92ee638c2a0d0c0af9328403e51dcdba037158126c2c90f602a95ee2eaaa602; misc/s15_result/s15_result_parts/5af2cd6956fcf24b5c5d0be783b408b9e2404999ee56c627a3f0394d3f1e559c.wl SHA256 e5e070a62bbc8ba15211e8fd55c3a2df8665c2cd94e1bed999ec93c5d2d58220; misc/s15_result/s15_result_parts/169f1453913ef461d02863a9af01f5233d3d7821a2aa033a1454801668a1e76c.wl SHA256 3b47877dc2ca27f910f113eac711c5d892c01ab72bb7612f2bf07b8134c764c9; misc/s15_result/s15_result_parts/4787fa95b2c42acac1ef1c85fbde7f37ff2d9537dd859a0c2249111447190369.wl SHA256 0364736107aa8a7d09af47e54382ab01792162686b1a6cc8d6b8e53e850e23a9; misc/s15_result/s15_result_parts/e0bdf96fa1484d01077e03770656d48f6e3a2d4e143d4397fbe63fd2fa7c2df0.wl SHA256 e2fe414b914fa7d7bfa0adfb781c8ae633e30338dc06cecd89a8343f6eced89f; misc/s15_result/s15_result_parts/f6e5a361c0138af552f52e644d2ec4048406679de5a305bfa20c00c1c71ba385.wl SHA256 a6c478bbcc7e461213d62c1a82484fa260ad1f1fbf25d791c13b2b2b15d9a9a2; misc/s15_result/s15_result_parts/7f76d6dbc5959aae0525a7d1af39e1a4a8945698fbea627cd578d512fa3120d8.wl SHA256 55f166ab9cf4ce38d23ac81df89f00d6cb4ab51933833a4bde9d569389bc85ce; misc/s15_result/s15_result_parts/d419dd9e23dbdce609c50937315b689f51dd0861f7648a5e4d721b4cf1f2e914.wl SHA256 27250bdbde52d0fc7620b689985fb377c4ad4a6b1c5350b75f0ec2e68d37f766; misc/s15_result/s15_result_parts/9206a17d921f5648fa7295b73ba43ee743baa83ac7efca475bf1fdcafe505d9a.wl SHA256 759fbcc36094c9de606c2210ef2d36eda02a20793450c6bc212802518059e48a; misc/s15_result/s15_result_parts/25bf8e1a2393f1108d37029b3df5593236c755742ec93465bbafa9b290bddcf6.wl SHA256 20c470e9bc59af8c25c370a999f271dc595875aac4b7c0664044a08c692f57ff; misc/s15_result/s15_result_parts/bedc5f4f6d3de55f840d3ab488889a3b1a7358b4e90d0f06d724632a48d3eb1f.wl SHA256 7cd41ab4f567737abc844ae8d2562ea16f21ee7238d54457700026fc5386d809; misc/s15_result/s15_result_parts/ee666c3a6832f66055593e1a43992698d9f670ee5e7058c98238df7b49353291.wl SHA256 1a30e774da74e8e766997c042bc573596368c3699ccca71fa27576e9caa946de; misc/s15_result/s15_result_parts/379e4a295817c6fc46ff9a1f48849cd68fdac149eaa825f0372dbfab9db9f70c.wl SHA256 0848c2f3d23ef2d94a1235beaca7805c3034e3330d6814a5be11462354479465; misc/s15_result/s15_result_parts/a290de9e253e3ecc6c4c778a516053fa3943e092245f496b7505b95518028cf9.wl SHA256 f42294b337fd9dc2015fae6c11a519d0ea9f3484887f954f3c116907f1fedbb5; misc/s15_result/s15_F1_hat_parts/a8666eecc4ba7017399e378a55f6a5a096a725b0ce9b49441130e3ba0e2c333b.wl SHA256 c47e4b0e39769d31435abf7e5cd2e1ef142f87ed052586765a2d0eeb4399a582; misc/s15_result/s15_F1_hat_parts/cfdb15453dbb8b07a1e043c0942d516000a8a1e51be30cd2ea2aa87edad07075.wl SHA256 28781d45d5d499ed8f80ea97d51f51fea2f8b0842bdff676d534ad4cd0bc5bca; misc/s15_result/s15_F1_hat_parts/85ec998761ec731bc9990e78013da32b0f9bbb40b35f49bb2d138f9b47a3d8a6.wl SHA256 4eb191836249bb002b1e0997a3c8ff9ec2e5fad462eabccde34f9506fdd57ac4; misc/s15_result/s15_F1_hat_parts/a8cf8acae9809deec06328cdbe9d905636838f5f9e2d684a4bd4bcf404ed42c6.wl SHA256 ec75ea8a2d8fc93162f227cff0de04998eba57fdfebc912724d0d88af825505f; misc/s15_result/s15_F1_hat_parts/d3f16b730c0326c3a5e8c9bf5da1529c227d37a7b0d5b2bdd049c93670d500c1.wl SHA256 96de0d547935657c68113ffe4447492f2cb406ee5bfa49b6b50a128ce2fbab35; misc/s15_result/s15_F1_hat_parts/95f53f7a59cb7a60b312bb069c42316971bcc96fefb92beb3ec952a6462a0741.wl SHA256 510ca553a3a8137ce6ac7c0d67b075fc721d349051693d7067cdc14b246794b2; misc/s15_result/s15_F1_hat_parts/5ea8b12f6de7ce37db0dc155676481ff9a99ca59be1a70259b1a400fadde69f7.wl SHA256 cd1de3280a91bef86b9f978f556db0f4d3c7ffa2166f096c1bdc429fae8fa1a4; misc/s15_result/s15_F1_hat_parts/c0b7c3072542c0a6a016e6c7523894cec034fee008575c7783c9fc1e7c4943c0.wl SHA256 e298a73aa804456aebf981340ab234c6206857393d660b809b6d3e15a2cae75f; misc/s15_result/s15_F1_hat_parts/916f8855fa5c1b07eb7bad6488fd312264d7e7116c411f4709d6c05009f6f98d.wl SHA256 b01fc9b8f89c9b9e8476f02f598fc6d581e3e52b7e99e4dcd53a2180e66be047; misc/s15_result/s15_F1_hat_parts/234014754958647d123f5a698c33859c0ff4a0657ef1ae6fb89765c085690364.wl SHA256 c33253ff5949bc5abc1348c08f74316c73a32d354400733a509d1f7a7869289d; misc/s15_result/s15_F1_hat_parts/3937a0df8c45a39643238c0b5c8348851ed80ca044cc7c021538c864e29591a6.wl SHA256 c4c82fa9cd364ce6da8a6cc5c97402a40335b15215dfa4cee21e9151002d28ad; misc/s15_result/s15_F1_hat_parts/ae9f44742e5ac8c8fbf82a4d7533b00e8b7e8615fc5e390b16b30daa870a1636.wl SHA256 15a69c97eff1092bfbcb61a14d82f88e5005731b63fc904bb2a499f1feac6a72; misc/s15_result/s15_F1_hat_parts/3d2657e44444e31b63ca19355e31677556fdc59d5e9e9382140fa9953816a7af.wl SHA256 7d173819ef725355c37183b357659e1b12c298046fb77dc782bf510803a67143; misc/s15_result/s15_F1_hat_parts/a2a890de19ed498adfb971cd9bf36cd6ea8ba465e218ed2f67f9b6d2aac38afd.wl SHA256 5cfef62fa40d2ee29fd321bc0a1568fe637816d5a842374a75e15feea2a10503; misc/s15_result/s15_F1_hat_parts/a40b981ddca161ffcc4dd13eaa6cd259b00c93bf602049c5d727de38bf950e28.wl SHA256 70c9a4b8afee4f98ab8c3885583042a6c75687a753ec0b2cc0637b3b74fef7b8; misc/s15_result/s15_F1_hat_parts/b4e4840f1dce361929bf249ebff22ab64d392d5628123405991fdbb2369c4462.wl SHA256 86c6843a8092a8990c484eb104adc4983a4e96327849522aed96069a89396195; misc/s15_result/s15_F1_hat_parts/6e0dd458fadbcacb6938885475928bf7fb8f4de5628639e0eb93f72c6333b326.wl SHA256 5b12912b3441da7372d449e4086cfefcc1662708d107c137289be26b32952da7; misc/s15_result/s15_F1_hat_parts/d419dd9e23dbdce609c50937315b689f51dd0861f7648a5e4d721b4cf1f2e914.wl SHA256 27250bdbde52d0fc7620b689985fb377c4ad4a6b1c5350b75f0ec2e68d37f766; misc/s15_result/s15_F1_hat_parts/9206a17d921f5648fa7295b73ba43ee743baa83ac7efca475bf1fdcafe505d9a.wl SHA256 759fbcc36094c9de606c2210ef2d36eda02a20793450c6bc212802518059e48a; misc/s15_result/s15_F2_hat_parts/0591f66446b12ed0d8c2762a3c192ca9466458385d14491692fad1d4949366b6.wl SHA256 f18be7a33d13366f27087ac8ab89a8506f4a51994dc113b831508edf373e5622; misc/s15_result/s15_F2_hat_parts/2923c25472f5b106e0b452ede56e5918668f33cdd93b479cd65a335a5e339950.wl SHA256 17ff7f6fc541fbd2914a66cb0e7311546764b5b0a93f55f949a499a57ed49769; misc/s15_result/s15_F2_hat_parts/683b882cec8356e2fbfc2b6171960377ce675d76e7d4b9de2090f920ecce4f23.wl SHA256 171ee3ae1fc0c36df1f11b199dfba8afaeef68e0764f3772248d9149af708634; misc/s15_result/s15_F2_hat_parts/cb8478f0493ab6f0a4303319ee440ea5340ae2cecff1c669859aeee96a7ec326.wl SHA256 872785d44a04f8f1031bcd7ebcca24d1a68f0b88c3e28a8176e065aa12751447; misc/s15_result/s15_F2_hat_parts/1a19b2ed7dc07ebba4343fa2ed1ede9ef3446cd352fee5aa484704eff1d7c594.wl SHA256 4f765d9403c3b88f9bcdf2e8444932ec8f99af5614e6515a9aa1124794655857; misc/s15_result/s15_F2_hat_parts/aca9848ae3e50a1cc72c6dc54eccf2bc16a2260a83eee288375c6188c172dcd2.wl SHA256 30eab29d0f4326bbfccf7df80129cad8a8a9493d5cb2a2d5723c6226cfda0452; misc/s15_result/s15_F2_hat_parts/1e9cf31beace1e45bbc97197f5e097bdccf5ce3213c62c42d783270618de3a66.wl SHA256 6c9f1e34a508bab3cddec8cda5205169a6d5ebc60adc988337fbb6c59eb96461; misc/s15_result/s15_F2_hat_parts/e6e1dc7e8bced01153d1025b04dad57e2fff5dbdeb4c3b6f15f2a93ea765e1f8.wl SHA256 141ea6ae3f445e618e8671468d5adf5accaa0da8f273f317dd6193c29dd1cd8b; misc/s15_result/s15_F2_hat_parts/e40a6b8c1f634e294ef1b772151643d2787c1af1ff19575bfdf718df2ac4e5e4.wl SHA256 3b394419868616a0e276a8cb5d0fbb1ed33e09635c12ca4b3d1a9600a959c5cd; misc/s15_result/s15_F2_hat_parts/d77fdafc36774b8f8876055cb897435814c6c414243e21261d900238ee37840f.wl SHA256 31d681b2190c4251ca7bb0a0700b9d3f77e699ec38f7a21e85cb9677cbd4eb77; misc/s15_result/s15_F2_hat_parts/df3c9bef01396a073ea5c7158ca73e60a6cff51beb9b00955acc0ed5accf436b.wl SHA256 adce8ae0df5381870f12d72d4f0f3e3f0ae2a970955f081e62d510bd010935af; misc/s15_result/s15_F2_hat_parts/a171f7369ad8969b2bdb9281bfd0ea4bd87e8a951f11b3edbb448bbe1d5a13fc.wl SHA256 5a90c1578b8b4f9c1443746c02efa6439a6b7a388306c4bb9fbb4db55dcdb75b; misc/s15_result/s15_F2_hat_parts/d06e3950d7820edc655328ebf42fc7c9c34e54254d0acc098407c5c52f9fb7ae.wl SHA256 be34d8e9dfc8f360926e53f923aa02711fb800047ffb643c938582ea2406f9ee; misc/s15_result/s15_F2_hat_parts/058bbc6341bcec89042bcbe7f7db3317935a19d336db3c726e8ed01df5b0d5d7.wl SHA256 2acf4b1a95da1b2b1bb2aa3f030e8003993beb8eda470e5107021cce2a57f0f6; misc/s15_result/s15_F2_hat_parts/3d2657e44444e31b63ca19355e31677556fdc59d5e9e9382140fa9953816a7af.wl SHA256 7d173819ef725355c37183b357659e1b12c298046fb77dc782bf510803a67143; misc/s15_result/s15_F2_hat_parts/a40b981ddca161ffcc4dd13eaa6cd259b00c93bf602049c5d727de38bf950e28.wl SHA256 70c9a4b8afee4f98ab8c3885583042a6c75687a753ec0b2cc0637b3b74fef7b8; misc/s15_result/s15_F2_hat_parts/0fa18bba8200ef033e42beccc5d31a4c1419421c432c3b86c7ac1595fbdb7a1b.wl SHA256 9169df478192258826bd5566c24884113ea94cba624c44162c1495274a03690f; misc/s15_result/s15_F2_hat_parts/31d131de6fb95574afb6d724af65acdac9421c1fdfde8fbda97be3caa236bc31.wl SHA256 ca7619ca5e65614e45fd19acf30f0e327ff604bce257b19f6ed5db466170687c; misc/s15_result/s15_F2_hat_parts/60800d292c0ca495b4e580b523a129fbc3220d55261e95ab321cf8c4b5f44f59.wl SHA256 2cc3693d34f3c2cc95f953d1cfe691b48210c6a2ab712685c7d31aa5d2d07a3f; misc/s15_result/s15_F2_hat_parts/379e4a295817c6fc46ff9a1f48849cd68fdac149eaa825f0372dbfab9db9f70c.wl SHA256 0848c2f3d23ef2d94a1235beaca7805c3034e3330d6814a5be11462354479465; misc/s15_result/scheme/s15_result_parts/eb3b34550ff695bab62ef92336f0fcef3092bbb9aae0b17c9bf2bd2d8ebc0462.wl SHA256 b974d20c30da799e5d87a24e771ec03facd1b97c388d6ffe0e90377c29069af5. Final native F1/F2 exports passed finite, scheme and inherited assembly checks; publish with their exact source and receipt identities.
