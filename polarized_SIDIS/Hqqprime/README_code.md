# Hqqprime: incoming quark, tagged distinct-flavor quark

The incoming quark has momentum `p`; the tagged distinct-flavor quark has
momentum `k1`. Preserve the independent incoming and tagged flavor charges,
their interference, and the unobserved flavor assignments.

## S01 inputs

`s01_prepare_inputs.py` uses the shared S01 implementation.
`s01_result/` owns the receipt for selected open-amplitude inputs.
Inherited projected tensors are unpolarized reconstruction references.

## Spin-dependent contract

Retain the two distinct quark spin labels. Whether each charge/spin
component contributes must follow from the defined contractions and
executed gates. Do not copy a spin-transfer coefficient from Hqq.

Later accepted sources/results use consecutive `sNN_` names and the
shared cluster and acceptance contract.

## S05 real tensor contract

`s05_real_spin_response.wls` uses the shared implementation. It retains
the independent `eq` and `eqp` charges from the pinned generated amplitude,
both quark spin indices, and the original tagged momentum `k1`.
Its unpolarized reconstruction reference is
`s05_result/reference/unpolarized_real.wl`, SHA256
`eac5dbc2bfc4d6eb4789345b23d72f194b07bfdcf417427b939cbf135723be4f`.
The reference has no spectator weight applied to its tensor; the new
result must record that weight for the phase-space consumer.

Acceptance requires the common S05 frame, angular, Ward, Hermiticity,
spin-reconstruction, and unpolarized-reconstruction gates. The output is
an angular-averaged real tensor before scalar integral evaluation and
factorization, and must not be consumed as a finite F hat.

## S08 real scalar-mapping contract

Apply the shared S08 mapper only to an accepted S05 result. Retain `eq`
and `eqp` separately in its coefficients and carry the saved spectator
weight and its application flag into the integration stage. Mapping
acceptance requires exact reconstruction; scalar reduction additionally
requires complete coverage by verified Kira rules.

## S12 integrated real tensor contract

Use the shared S12 program after this channel's scalar map has complete
verified reduction coverage. Preserve the generated charge and spectator
bookkeeping and evaluate the measured transverse factor in every endpoint
limit. The reference cut masters and distribution assembly supply the
Delta/L0/L1/regular tensors before final normalization and subtraction.

The compact S05 implementation, SHA256
`33c00fd1361a5655d5f5c0fed5a15986182e4bb2fad67fc91ed0ba93da394507`,
passed the complete Hqqprime first-pair comparison in job `14775213` on
`n7128`. The result `Hqqprime/s05_compact_result/s05_result.wl` has SHA256
`9e1619465a68e8f7fe242421a237d77f9d0452722237124429816b0a4986081d`.
All photon-matrix entries and scalar checks matched the original completed
pair. Wall time was 186.617 seconds and peak child RSS was 382488576 bytes.
The execution receipt is saved alongside the comparison. This accepts
the algebraic change for checkpoint-preserving production; full-channel
Ward, CDR and integration checks remain required.

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

`gq` passed job `14775311` on `n6045`;
`s03_result/gq/s03_result.wl` has SHA256
`c459aac8220ae82c9cbfd6bed399b9111f7560033b96e4a7fe7f75c6a0bddd51`.
`qg` passed job `14775312` on `n6126`;
`s03_result/qg/s03_result.wl` has SHA256
`f15a5df8c7584ad15aff49b720c414ce343253840bfe3b6d342d15f5634d4690`.
Each accepted route passed the full-dimensional GitHub g/pp comparisons,
Ward identities, Hermiticity and complete spin/photon reconstruction.
The shared source SHA256 is
`d7f17d27e9f268c687bb41590ef793ddef0752aa7686dd3b651591c9d1718f6e`.
Checks and execution receipts accompany each result.

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

The real tensor sum may dispatch and checkpoint each photon/scalar entry
independently. Photon entries retain their exact linear sums; Ward entries
use the unchanged accepted scalar reduction function.
Native source-section equality gates preserve the full frame, scalar and
pair-contraction definitions. The calculation hash remains the accepted
compact source; actual dispatch source and per-entry input hashes are
recorded separately. Each scalar sum has its own time/memory bound. Full
Ward, Hermiticity, reconstruction and GitHub comparisons remain mandatory.

Job `14775341` on `n6142` accepted `common/s11_small_collinear_spin.wls`.
`s11_result/s11_result.wl` has SHA256
`8521fa32842be3d2956e892ed172fb31310d2f9b66d8aa1aaeded34a3d6a4e82`.
Its checks and execution receipt are saved alongside the result. The full
original scalar comparisons and all stage acceptance gates passed. This
result remains an input to complete NLO assembly, not a finite NLO hat.

The final S05 basis conversion differentiates the formal spin variables
and evaluates them at zero, preserving factored expressions. Exact rational
reconstruction must reproduce the entire matrix and spin polynomial. The
contractions and their calculation hash are unchanged. The original CDR
comparisons remain mandatory before accepting the complete real tensor.

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

The S05 interface check uses the saved coordinate equations and the accepted
first real pair. Solve the coordinate identity with neutral global assumptions,
then reconstruct every scalar product and compare on the physical domain.
The complete photon projector must reproduce the entire accepted pair matrix
and the native projection definition accepted by S07 before checkpoint reuse.

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

The S15 finite scheme tensor passed Hoffman2 job `14775518`.
`s15_scheme_result/s15_result.wl` has SHA256
`6d3f94985767dbe957318b273dce65e4cc55d378149cd90074e8dea8d112ebf1`. All normalization, helicity-index,
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

The spin-coefficient extraction check reads the complete input-bound photon
matrix and scalar component checkpoints directly. Native coefficient extraction
must reconstruct every saved matrix entry and the full spin polynomial,
preserve both original CDR contractions and match the unchanged extraction
routine on a programmatically selected nonzero polarized component. Record
actual expression sizes and timing before adopting the representation.
The comparison source and manifest are `common/s05_spin_extraction_check.wls`
and `common/s05_spin_extraction_inputs.json`. A comparison is not a complete
S05 result; production must still pass all normal stage gates.

The legacy fully expanded response exceeded both the 4 GiB and 8 GiB decode
allocations (jobs 14775549 and 14776292). Its compressed file is retained on
the cluster only as failed-export provenance; it is not an accepted result.
Recovery uses the smaller saved matrix checkpoints instead of decoding that
file. Completed pair and matrix contractions remain valid and input-bound.

The revised coefficient check differentiates only formal spin variables,
then evaluates those variables at zero. Require exact rational reconstruction
of the full matrix, both original scalar contractions and an old nonzero
component. It records the earlier CoefficientRules reconstruction diagnostic
separately. Before retaining unreduced linear matrix sums in production,
compare the proposed sum with an accepted reduced sum using the unchanged
on-shell reduction, and retain the native Ward reduction. Source and actual
matrix/pair inputs are hash-bound; no candidate is accepted before its gates pass.

Job `14777352` accepted this comparison with result
`s05_spin_extraction_result/s05_result.wl`, SHA256
`ca3d2e5e85ad47b4cad41f6a26609a5886ef011a819223e9b25abe3975ea473b`.
All matrix, spin-polynomial, original CDR and legacy-component comparisons
passed. The selected coefficient used 23,858,272 bytes instead of
250,530,072 bytes. The earlier CoefficientRules residual is rationally zero;
its structural expanded-expression equality was an unsuitable check.
Checks and execution receipt accompany the result. The source SHA256 is
`48d356523f2c44128dbb4841ff85f7bc47b7a9fe95c50c1a605ea72bbe3b3c73`.

The complete S05 tensor passed job `14777388` with source SHA256
`46c45f60a0f97c18d430cd8a3ee05182bc5e10f5deb424e8b69487d76e75e500`.
`s05_result/s05_result.wl` has SHA256
`07679643127071c38d0522479236858ff7fd1f4e770d22d65572072f56e03d9f`.
Ward, Hermiticity, photon/spin reconstruction, both original unpolarized
projections and exact reload of the 13,168,009-byte compressed file passed.
Its checks and execution receipt bind all source and input identities.
S08 consumes this result through the native `Get` interface. Scalar mapping,
integration and finite assembly remain separate acceptance requirements.

S08 coefficient assembly must use the pinned GitHub S11 loop: extract each
master coefficient from each Kira rule before summing its weighted terms.
Bind the original source, preserve all scalar-map and cut checks, and
require exact reconstruction of the direct rule-substituted expression.
Uncovered targets remain explicit inputs to reduction extension and may
not be treated as accepted masters.

The S08 coefficient compaction comparison uses the actual first Hqqprime
component that reached the master-coefficient time bound. Preserve and
reconstruct its raw cut map, apply the unchanged accepted S05 on-shell
reducer to each scalar coefficient, and measure expression sizes and
execution time before adopting the change. Keep the pinned GitHub master
coefficient loop and require exact reconstruction of the compacted reduction.
The comparison source is `common/s08_coefficient_check.wls`; its result
belongs to `Hqqprime/s08_coefficient_result/` and is not a finite hat.

Job `14778197` accepted the independent S05 spin-check dispatch with source
SHA256 `33cf0bacda34aff1b32df4493926bcaa151e57c9763d0261419735c07b048eaf`.
All nine freshly executed photon-component checks and the complete accepted
Hqqprime tensor comparison passed, with no worker check-recording messages.
The proof `Hqqprime/s05_parallel_result/s05_result.wl` has SHA256
`60a05328f3ca59abb5bc5faab2565a77f34b9ced5eee9f2da060f6d512475e4f`.
Checks and the execution receipt accompany it. Each worker owns its check
Association; older reconstruction checkpoints without recorded checks must
be recomputed. Pair and scalar-sum mathematical checkpoints remain valid.
The accepted complete Hqqprime S05 tensor is unchanged.

The S08 rational-sum comparison reuses the exact pairwise `rationalReduce`
function from the supplied standalone reference, copied without modification
to `common/s08_result/reference/s08_standalone_rational_reducer.wls`.
Use the input-bound native raw map and its executed reconstruction checks.
Compare a nontrivial same-channel master coefficient with the original
GitHub assembly, reconstruct every new master coefficient exactly, and
record actual timings before permitting production use. Inputs are bound
by `common/s08_rational_sum_inputs.json`; comparison outputs belong to
`Hqqprime/s08_rational_result/`. No finite hat is established by this check.

The S08 denominator-sum comparison derives factor supports and their common
powers from the actual saved cut coefficients. Each native rational term
must reconstruct its factored denominator and common-denominator embedding;
the complete polynomial numerator and final factorization must reconstruct
exactly. Compare the original same-channel reference coefficient first and
preserve per-master checkpoints bound to the comparison source and inputs.
`common/s08_denominator_sum_check.wls` owns this comparison and writes to
`Hqqprime/s08_denominator_result/`. It cannot replace production assembly
until all saved-component masters and the original control comparison pass.

The known-denominator variant `common/s08_cancel_denominator_check.wls`
preserves the complete denominator-sum comparison and replaces only the
final numerator factorization. It selects a constant-leading-coefficient
variable from each measured factor, computes native polynomial quotient and
remainder, and extracts a factor only when the exact remainder is zero.
Every division and the final polynomial must reconstruct exactly. Its result
is isolated in `Hqqprime/s08_cancel_denominator_result/` and retains the
original same-channel reference comparison. No production use is accepted
without the executed complete-component gates.

`common/s08_map_real_targets.wls` completes the unchanged GitHub cut mapping
before coefficient assembly. The first fresh worker must reproduce the
entire pinned Hqqprime raw map exactly. Independent components then retain
separate source/input-bound checkpoints, complete cut reconstruction checks,
positive-energy support and the original family definitions. The complete
raw target inventory is saved in `Hqqprime/s08_targets_result/`; it is an
input to any required Kira extension and subsequent coefficient assembly,
not an integrated result. This initial entry point is restricted to its
comparison channel until its worker and complete-map gates pass.

The complete known-denominator comparison passed job `14778745` on `n7005`.
`Hqqprime/s08_cancel_denominator_result/s08_result.wl` has SHA256
`215afefb5862347917f3db9fecb401e34c59fcd4a858c12731ae55bdecaef0da`.
All saved-component coefficients passed exact termwise rational reconstruction
and the original same-channel control comparison. Whole-job time was
405.776 seconds; peak child RSS was 2,612,932,608 bytes. The checked source
is `6a8cf24abf16e75d43a787eb50dccc5f001fb2bd00ad9e29a37c147c02f7a020`.
Checks and the execution receipt accompany the result. This validates the
summation algorithm; uncovered scalar targets, integration and finite
assembly remain separate requirements.

The production S08 mapper retains the original cut-mapping functions and
coefficient extraction from each reduction rule. It loads the two exact
rational-summation definitions from the accepted comparison, checks their
source/result identities, and requires a fresh worker control comparison.
Each reduction rule must reconstruct from its extracted master coefficients;
each summed coefficient retains the accepted exact termwise checks. Save
independent component and master checkpoints, preserve deterministic index
order, and consume a complete raw-target map only with matching source and
physical-input identities. Keep the original S08 schema for S12 and require
an exact native compressed-file round trip. The previous production source
is retained as `common/s08_result/reference/s08_map_real_spin_before_known_denominator.wls`.

When the complete raw S08 map contains uncovered cut integrals,
`s08_extend_real_reduction.wls` runs the pinned GitHub S04 Kira/Fermat
configuration writer and symbolic reader unchanged. Its targets include
the actual spin targets and all original targets, rules and masters.
Preserve cut-propagator positions, positive-energy support, physical
invariants and preferred unit-index masters. Require every original rule
to match, complete requested-target coverage and an unchanged master
basis before accepting `s08_reduction_result/s08_reduction.wl`.
The production mapper may consume this scalar-only table after matching
the baseline geometry/reduction identities; S12 still checks master
expansion depth. This extension does not reevaluate master integrals.

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

S05 projection resumes may set `POLARIZED_SIDIS_REAL_SECONDS` explicitly
(the default is 2400 seconds, with a checked maximum of 10800 seconds).
This changes only the native time bound. The 2 GiB operation limit and
4 GiB spin-reconstruction limit, all contractions, checks, and checkpoint
identities remain unchanged. The scheduler and process-tree limits must
cover the selected bound. Preserve the preceding source in
`common/s05_result/reference/s05_real_spin_response_before_projection_time_resume.wls`.

## S08 grouped continuation and checkpoint reuse

`../common/s08_map_targets_by_denominator.wls` loads the exact denominator
grouping and mapping definitions accepted by Hoffman2 job `14792045`.
The proof `Hqqbar/s08_grouped_result/s08_result.wl` has SHA256
`fc69dbab36b65068fde2e89a25ae05a4ac4f166a84bdf03dfde712a93aa66ed0`.
Its control comparison used this channel's original accepted complete
component and proved exact equality of the reconstructed maps. Raw target
representations may differ. Each new channel must match all shared physical
inputs, native versions, scalar products, cut definitions and the original
mapping definitions, and repeat the accepted control on its worker.

The original whole-expression mapping of component 13 reached the native
4 GiB operation limit in job `14784642`. Completed components remain valid.
The continuation imports their exact input-bound checkpoints, verifies task
ordering and recorded reconstruction checks, and records each original
component file hash. New components use the accepted grouped mapper with
separate component/group checkpoints and full reconstruction gates.
Complete output keeps the existing S08 schema and physical mapping hash;
source and algorithm provenance distinguish the continuation. Kira coverage,
integration and final pole cancellation remain required.

## Accepted S05 checkpoint archive

Job `14795525` verified every original checkpoint member against its byte
count and SHA256 before removing the uncompressed completed S05 cache.
The accepted tensor from producer job `14777388` is unchanged.
`s05_result/s05_cache_part01.tar.gz` has SHA256
`76fd13f4f82f29dd7b3992f5508d043bea78103c626d60486f9d9d0ffbee1e7b`.
Its manifest `s05_result/s05_cache_manifest.json` has SHA256
`7d15d8bc1ec4010b4d6a25125ab6955e7fe00890c09eb2864246c0d028cc626a`.
The archive, manifest and `s05_cache_execution.json` are retained locally.
The remote duplicate archive was removed after exact local/remote SHA256 and
byte-count comparison; remote metadata and the accepted S05 result remain.
To resume the producer, transfer the archive back with a SHA256 check, restore
its members at their manifest paths, and verify every member hash.
Current downstream stages consume the accepted S05 result directly.

## S08 reference per-pair mapping comparison

`common/s08_check_pair_mapping.wls` reads the original S05 pair checkpoints
from the verified archive and applies the accepted photon duals and saved
spin-extraction definition. Require the exact pair inventory, input identity,
archive member hashes and reconstruction of each selected accepted S05
component. Map individual pairs with the unchanged GitHub `mapExpression`,
then combine their maps with its unchanged `merge` routine. Compare the
complete own-channel accepted control map as a reconstructed expression and
require full reconstruction and physical-cut checks for the unfinished
components. Keep source/input-bound pair-map checkpoints separate from
production targets. Comparison outputs belong to `s08_pair_mapping_result/`;
they do not establish reduction coverage, integration or finite hats.

The per-pair comparison passed job `14795872` on `n6107` in 968.117 seconds,
with 2,276,593,664 bytes peak observed process-tree RSS. It reproduced the
entire accepted control and completed components 8 and 13, including exact
pair sums, every reference pair map, complete merged-map reconstruction,
physical cut powers and native file reload. The result has SHA256
`a97381483fd34c34ad3046929efa64716bc1c84cc7edb3649d02662cdf3c278c`;
its checks and matching receipt are local. The source SHA256 is
`476319476cc55bdda06fb01b210a2feb7383140c80ab719904570dd66279dd99`.

`common/s08_assemble_verified_targets.wls` may assemble these input-bound
components with the original completed target checkpoints. It must verify
every task identity, physical input hash, reconstruction record, reduction
coverage inventory and the accepted reference mapping definitions. Preserve
the original complete S08 target schema and record the proof hash and each
reused component file hash. Do not overlap this exporter with the previous
target writer. Complete Kira coverage, integration and finite assembly are
still required before reporting finite hats.

The complete target assembly passed job `14795985` on `n7121` in 123.451
seconds, with 1,609,408,512 bytes peak observed process-tree RSS. All 13
components passed their exact input, reconstruction and coverage-inventory
gates, and the native export reloaded exactly. The accepted artifact
`s08_targets_result/s08_result.wl` has SHA256
`3d98ee0e2a009bf069b83445126b9fc5cb163cae36487f72893bc5e97f3e5359`.
Its checks report 297 scalar targets, including 155 requiring extension of
the reference table. Checks and receipt are retained alongside the result.
This accepts the complete target map; reduction coverage and finite hats
remain separate downstream requirements.

The reduction extension passed job `14796003` on `n6047` in 201.110 seconds,
with 797,990,912 bytes peak observed process-tree RSS. Its checks establish
complete requested-target coverage, equality of every original reduction
rule, and an unchanged original master basis. The artifact
`s08_reduction_result/s08_reduction.wl` has SHA256
`d2c03a9a97248a397164588ff207b8a9a58a639cee7ebbc54f527f3f4c9a2e5b`.
The mapper may consume this table using `POLARIZED_SIDIS_REAL_REDUCTION`;
S12 retains the reference master integrals and must still verify sufficient
regulator expansion depth. Checks and receipt accompany the local result.

## S08 streamed numerator contract

`common/s08_check_streamed_numerator.wls` uses the accepted complete target
map, complete Kira extension, and unchanged production input conventions.
It retains the accepted denominator factorization and cancellation equations,
but accumulates each expanded numerator immediately instead of retaining
the full list of expanded rows. Every denominator embedding, individual
addition, known-factor division, and final reconstruction must pass exactly.
Require equality with the accepted same-channel original coefficient and an
executed check of the actual unfinished coefficient before production use.
The proof records the selected component/master, source/input hashes, elapsed
time and memory; `s08_streamed_result/` is a validation artifact, not a finite
hat. Completed original production coefficient checkpoints remain valid.

`common/s08_map_real_spin_streamed.wls` may install only the exact definitions
from a successful streamed-numerator comparison with matching native versions
and original summation definitions. The original source defines the unchanged
mathematical cache identity; the result separately records the dispatch source
and comparison hash. Import the comparison's coefficient only when its complete
production input hash, input files, task, component index and master all agree.
Reuse accepted original component/master checkpoints and retain every original
mapping, reduction-rule, worker-control, reconstruction and native export gate.
S12 consumes the unchanged scalar-map schema. Enabling this continuation
requires the completed comparison receipt and source/input hash checks.


The initial streamed comparison `14796110` completed all 279 numerator
rows with peak observed RSS 1,661,558,784 bytes, then rejected a denominator
factor without a constant leading coefficient. No coefficient or optimization
was accepted from that run. The prior proof source is preserved in
`common/s08_result/reference/s08_check_streamed_numerator_before_factor_support.wls`.
The corrected comparison retains such factors without attempting cancellation;
it applies the unchanged exact quotient/remainder routine to the other factors.
Every actual division and the full final numerator/denominator reconstruction
remain mandatory, including the same-channel accepted coefficient comparison.
The proof records both original and corrected cancellation definitions. The
production consumer verifies and distributes the exact accepted definitions;
no changed code is enabled before the complete proof and native reload pass.


The corrected streamed comparison passed job `14796343` on `n6138`.
`s08_streamed_result/s08_result.wl` has SHA256
`4c87d2d584257c66bba85970d74d730c22c156a8921aa71721efb812519acae8`;
the matching execution receipt has SHA256
`c2c101af7dd88d6c1e2e42d47e801cc2689c0e48d8bcda56e92657c54727c793`.
The check source SHA256 is
`b5acb3cc1469a293ba8f1d6fdc045a22d0e1bd67bdae5a82cd6997faa344bff6`.
All 279 terms of the selected actual component-2 master coefficient passed
exact denominator embedding and numerator accumulation, supported-factor
division, final numerator/denominator reconstruction, and exact native reload.
The own accepted original coefficient comparison also passed. Whole-job time
was 2271.291 seconds, with peak observed process-tree RSS 1,839,501,312 bytes.
Checks, coefficient and matching receipt are verified locally. This accepts
the corrected coefficient summation; complete channel integration and finite
assembly remain required.

The corresponding production source `common/s08_map_real_spin_streamed.wls`
has SHA256 `f65fbeee3345dcf281e60192a7e6ea4dfd08eb547f4aa7fb225134462e1ed601`.
It retains the original mathematical cache identity, loads both exact accepted
summation and cancellation definitions, and requires matching native versions,
source/input identities and a fresh worker control. The proven coefficient is
imported only for the identical task, master, input files and production hash.
All other coefficients retain their own exact reconstruction and reload gates.

## Accepted complete S08 master coefficients

Job `14796501` accepted all 13 components and all 297 required scalar
targets, with zero missing targets and complete reduction coverage. The
input, worker-control, term reconstruction, supported-factor division and
exact native export/reload checks passed. The producer is the unchanged
streamed source `f65fbeee3345dcf281e60192a7e6ea4dfd08eb547f4aa7fb225134462e1ed601`.
Whole-job time was 5112.660 seconds; peak observed process-tree RSS was
7,171,694,592 bytes.

`s08_result/s08_result.wl` has SHA256
`e262ce55f59c1a4a1e8ddd3acfbb487536106af566b373922bd09f8e6e73d3ec`.
The accompanying checks have SHA256
`4953735581ce644ea7e0a543f65535dc54532010324e539e8f54e83462772baf`,
and the matching execution receipt has SHA256
`7c3aa8f4303c07d1c694a3e0d929926a64774a306e8bf0057d3a0525630118a4`.
All three files are hash-verified locally. S12 consumes this complete scalar
map through the unchanged native `Get` interface and reuses the pinned cut
master values. Integration, componentwise pole cancellation and final scheme
export remain required; this coefficient map is not a finite F hat.

## S12 regulator-series comparison contract

`common/s12_check_regulator_series.wls` reads the unchanged S12 initialization
and the accepted complete S08 file. It extracts each actual numerator's
polynomial coefficients in D, verifies exact reconstruction, expands the
small formal polynomial times the unchanged cut master, then restores the
kinematic coefficients. The original regulator-depth gate remains required.
Every formal series must be exactly linear in its temporary coefficients.
Compare all six completed ordinary integrals with their own input-bound S12
checkpoints, and measure component 7's actual master terms. The isolated
`s12_regulator_result/` comparison is not production integration or a finite
hat. Production use requires all comparisons and exact native reload to pass.

The accepted S08 result and checks retain the identities above. An old kernel
from deleted job `14796028` later overwrote the remote output with different
files; those files are quarantined under `cache/s08_late_old_job_14796028/`.
An explicit process-environment check on its node found no remaining process
for that job before the accepted local files were restored and hash-verified.
The S12 input identity and checkpoint hash must match the accepted S08 file.
The first regulator inspection `14797016` read the quarantined variant and
does not establish an optimization of the accepted input; the comparison
above reads the restored accepted input and supplies that evidence.

Job `14797087` accepted the regulator-series comparison on `n7122` in
190.766 seconds, with peak observed process-tree RSS 1,113,337,856 bytes.
All six own completed ordinary integrals matched exactly. Every master term
of component 7 passed polynomial reconstruction, formal linearity and the
unchanged regulator-depth requirement. Its R01 term took 12.027 seconds.
The check source SHA256 is
`65872969e0cb1617ec0a8c75e30b17e6eae94957f7eac668555741214c2f0a4a`.
`s12_regulator_result/s12_result.wl` has SHA256
`88db303407b660cedb0f960321c45babf94acab2873e71aaaad1536a33d91839`;
its checks have SHA256
`085f38fb6cff6ae07e0ac53d28534542013bde5df1a3b833f239540c904c0338`,
and its execution receipt has SHA256
`d3d4d0cbe8e62f8cf653b3c2123c45075f9ea0eccf35da3631e61eaa7f52054e`.
All three artifacts are hash-verified locally.

`common/s12_assemble_real_regulator.wls`, SHA256
`13546e04edf3441fa2a10bb9ae2b2dbfa406c67598f68a517955eabd1233ac4a`,
may install only that executed function for the identical Hqqprime input
hashes and native version. It replaces the ordinary series call, distributes
the function to workers and records the dispatch/proof hashes. The original
S12 mathematical cache identity, six accepted checkpoints, endpoint operations,
master-depth checks and integration output schema remain unchanged. The
superseded S12 job `14796881` was stopped only after the comparison passed;
its main and worker kernels were explicitly checked absent on `n7133`.
Complete S12, S14 pole cancellation and S15 finite export remain required.

## Accepted complete S12 real integration

Job `14797140` on `n7122` accepted all 13 integrated components using the
verified regulator-series dispatch. All component, endpoint and regulator
coverage checks passed. The continuation took 449.020 seconds and peaked at
2,013,560,832 bytes of observed process-tree RSS.
`s12_result/s12_result.wl` has SHA256
`6babce49b20eca3b222339b4f8e1469e482bd8c3dc2723784bae597d5c31a325`;
the checks have SHA256
`ba4e6f274102063bc85f63bc757bacbdf7e1b791e17f98f480a939a23f8691a1`,
and the execution receipt has SHA256
`7d8bfb497dac0f08f3b2104b63946c0d425b8213e9dac4ab2daf6d6ec7c1cae4`.
All files are verified locally. This is the real-distribution input to S14;
complete cancellation and the final S15 export are separate requirements.

## S14 phase-series comparison contract

`common/s14_check_phase_series.wls` reads the unchanged S14 initialization
and the actual accepted S12 distributions. Reuse the exact `laurentProduct`
definition from S12: collect the finite Laurent polynomial, verify its exact
reconstruction, and expand only the common phase kernel to the required order.
Compare finite coefficients and every negative power with the own accepted
S14 checkpoints for the selected nonzero unpolarized and helicity components.
Measure the actual `{4,1,1}` regular component and preserve source/input/native
identities. The isolated `s14_phase_result/` is a comparison only; no changed
production assembly is authorized by its existence without all executed gates
and exact native reload passing. Full componentwise pole cancellation and
the final reference comparisons remain unchanged requirements.

The initial comparison job `14797303` stopped during duplicate FeynCalc
initialization, before reading or comparing assembly coefficients; no comparison
result was accepted. Its source is preserved as
`common/s14_result/reference/s14_check_phase_series_before_single_initialization.wls`.
The corrected reader loads the package once before parsing the original S14
prefix, verifies the unique original load call, and replaces only that repeated
load with `Null`. This preserves native symbol resolution and every original
equation and gate. The mathematical S14 inputs and accepted checkpoints are
unchanged; the corrected full comparison must pass before production use.

The corrected phase comparison passed job `14797324`. All three selected
finite coefficients and negative regulator powers matched their own accepted
assembly checkpoints. The actual 12,825,624-byte `{4,1,1}` coefficient took
126.476 seconds with the reference Laurent product. Result SHA256 is
`2aec26ba5852ad86bf22f5bbbc797e071005d8916de3202923d4bee33fbf74a9`;
checks SHA256 is `5be4d810d5f3565e9a1075e849a1fdfe34e19ee376a56518030d1aa163f9bf17`;
receipt SHA256 is `2f98d66a15040f4d992da7c20d649f9f757729dc8d7a2454aa931499a85fec53`.
The source SHA256 is `cb02337e0b7b4e6734a6d34fe452f90af7fbf29c40a0b6f38e076fad778176ce`.
The source, result, checks and receipt are verified locally. The original S14
assembly continues with unchanged code; this isolated comparison is not final
assembly acceptance and has not changed production.


## S14 unpolarized final-reference residual inspection

Job `14797221` passed all physical component pole-cancellation gates but
failed the F1 unpolarized regular comparison on branch +1. It exported no
accepted finite tensor, and final S15 export remains gated. The failed receipt
is retained in `s14_result/s14_execution.json`; the accepted upstream sources
and results have not been changed on the basis of this failure.

`common/s14_inspect_reference_residual.wls` reads the actual U/U pole
checkpoints with their exact S14 input hashes and labels. It applies the
unchanged final normalization block and native photon weights, then saves the
F1/F2 residuals against the pinned GitHub hats in
`s14_reference_residual_result/`. This is an isolated diagnostic, not finite
assembly acceptance. A correction must be located and checked against these
actual expressions before dependent results can be accepted.


## S14 dimensional-contraction diagnostic

Job `14797895` accepted the residual inspection. Both F1 and F2 regular
branch +1 residuals are nonzero rational expressions, with no remaining
transcendental functions. The result SHA256 is
`a92ec00fbd123a2c27126eeb077e1086991cec9332753667e5ae30cd0818f28a`;
checks SHA256 is `dcce93af23ae85c077076468867c0f3a342d6bc89337403971c90319a00cf68f`;
receipt SHA256 is `8d6c3041a7680f7d840c287a4a78da9078e5a27e4cbb7ca0dd10b7d43f8b6682`.
These files are verified locally.

`common/s14_check_dimensional_contractions.wls` reads those actual residuals,
inverts the original scalar projectors with a native reconstruction check,
and compares physical-spin and full-dimensional subtraction contractions.
It also assembles the already integrated full-dimensional photon metric
with its inherited CDR subtraction. The unchanged reference Laurent product
and final normalization are reused. Results in `s14_dimensional_result/`
locate a discrepancy; they do not authorize a finite offset or certify hats.
Keep production inputs unchanged until the originating correction is proven.


The dimensional diagnostic passed job `14798028` in 176.316 seconds,
with 2,193,887,232 bytes observed peak process-tree RSS. Its result
`s14_dimensional_result/s14_result.wl` has SHA256
`45e1bb0654442f0446bbf6ac3e8151b93e722904ab5527907a0ad209987014c1`;
checks SHA256 is `e8d2a62ee819d987660cdc92fdc28e7e477e8e27a2919be871c88f808e32378d`;
receipt SHA256 is `049d37eee5a8b328df4f43bff40c9dcac7aad927b322680cb723537a9882b50c`.
The incoming-momentum finite residual equals the physical/CDR subtraction
difference exactly. The assembled CDR metric finite coefficient matches the
original reference exactly. The stored metric pole expressions require their
separate exact rational-zero check; diagnostic completion is not final acceptance.

## S11 intermediate-state completion comparison

`common/s11_check_dimensional_convolution.wls` uses the original S11
route, frame, Jacobian, kernel and coupling definitions. It constructs the
intermediate unpolarized state from the accepted auxiliary Born U/E components
and stored CDR averaging factor, retaining the physical resolved spin basis.
Require the complete D=4 spin tensor to remain unchanged, both full-D original
convolutions to reconstruct, and the counterterm difference to contain no
regulator pole. Compare its predicted finite correction with both actual
failed F-hat residuals. The isolated `s11_dimensional_result/` records
`Accepted` only when both residuals vanish; production remains unchanged
until that executed result is checked. This is a subtraction comparison,
not an exported finite NLO coefficient.


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

The corrected S11 production run passed job `14798562` in 37.406 seconds.
Current result SHA256 is `63663f57089447ee0eb724c2f1cd89176e1b40c9a98124fa70b26c85e6f452f0`.
Checks SHA256 is `989918a10915fae3f29458037c493b072af64b2169ab8e76700111f86e0b5da1`;
receipt SHA256 is `06c307074f4952b6026196cdfb95115216e0995e4fba1dca38a74b1bdc51d2de`.
All three artifacts are verified locally. Consumers must use this corrected
result and source `b47acf502782cf5da4720163519a419c81a1a7f750679441a32685da2838f1af`.


## S14 continuation after corrected subtraction

`common/s14_resume_corrected_subtraction.wls` verifies that the S11 artifact
is the only changed input to the original S14 assembly. Read prior finite
checkpoints only from `cache/s14_before_dimensional/Hqqprime/`; verify their
input hashes, labels, acceptance and exact pole residuals. Derive the complete
new-minus-old counterterm tensor from the actual saved results and require
its finiteness and equality with the executed S11 comparison. Recompute
three original assembly controls with the corrected subtraction before
constructing new cache values. Bind every old and new checkpoint by hash.

After these checks, defer evaluation of already cached input parts so the
original assembly reads the validated cache first. Execute the unchanged
component, branch-boundary, original F1/F2 reference and finite-export gates.
Record the actual dispatch source and `s14_resume_result/s14_result.wl` hash
in the assembled result. Cache continuation alone is not final acceptance;
S15 remains dependent on the complete accepted S14 artifact.


## Completed S14 output verification

Job `14798764` executed all component, branch and F1/F2 reference gates
and wrote `s14_result/s14_result.wl` (85,734,919 bytes, SHA256
`531cb108c8933cc8351693f2b6a3d831d5e212b66244f3d4c1d6d2df1fd94e75`).
The scheduler accounting reports failure 46 (enforced h_vmem), exit 137,
maximum virtual memory 4.003G against the 4G allocation; no executor receipt
was produced. This output requires native verification before acceptance.
`common/s14_verify_completed_assembly.wls` reads that exact artifact,
checks source/input/runtime identities, every saved component and projection,
all recorded original-reference gates, and every hash-bound zero-pole
checkpoint from the executed subtraction continuation. The native verification
result belongs to `s14_recovery_result/`; its successful executor receipt
binds the completed S14 artifact. Use a 6 GiB scheduler allocation with the
unchanged 4 GiB child address limit to include supervisor overhead.
S15 still supplies the final helicity-scheme export.

The first saved-output verifier (`14799669`) reproduced all component and
F-hat arrays but used a rational-only predicate for saved pole residuals.
The checkpoint `{ {8,1,4}, 1, Regular }` contains square roots of the
physical transverse invariant and requires the original S14 physical-domain
`reduce`/`zero` predicate. The revised verifier reads those exact definitions
and the endpoint domain from the immutable assembly source, and retains all
identity and reconstruction checks. The failed audit does not modify the
completed S14 artifact or its checkpoints. Its receipt and source are
versioned before the corrected audit.

The completed S14 artifact was accepted by verification job `14799839`.
All source/input identities, complete component and F1/F2 reconstruction,
recorded reference comparisons and every original-domain pole check passed.
Its accepted execution receipt SHA256 is
`95fd3e7a40f4d5b8c0cb6b86dd380bf7d47e8d52a789a3a36c46e277984bbaa1`.
The validation result SHA256 is
`3334434977ebc32f802ef08d3d0ea1ed654637e943d88223fd7dfd54b9b1869b`;
validation checks SHA256 is
`d8ba0a290ee499c8b9f6a349a0d212251701d8fbc973b412ed5fd8976d738768`.
The full S14 result remains exactly the 85,734,919-byte artifact recorded
above. The accepted code and matching artifacts are retained locally.
S15 final scheme conversion and export remain required.


S15 scheme-input dependency: `common/s15_inputs.json` pins the accepted
completed core S11 source `4fa3afa28525d57a63c8aea1dee8a4825d761b504f0cd8192837360ec5b531c6`.
The earlier configuration is retained in
`common/s15_result/reference/s15_inputs_before_dimensional.json`.
Only that source identity and byte count changed; the scheme definitions,
reference kernels and standalone normalization contract are unchanged.
The S15 job configuration must bind the updated JSON itself as well.


## Accepted final partonic hats

S15 final export passed Hoffman2 job `14800135` in 63.099596 seconds.
The complete finite spin response and both F hats are in
`s15_result/s15_result.wl`, SHA256
`1aecfea2bc55f095cb8f9c7285cb53212110d54263b2149a6b6e10e2792e551f`.
The separate exports are `s15_result/s15_F1_hat.wl`, SHA256
`0f2ce07fc02f84b4219aeb137d6c2f2f641ff098422d83ccb7ac2c5688219809`,
and `s15_result/s15_F2_hat.wl`, SHA256
`2d4619c8a5d9cb3c97a9a5f845c2b30a3e6e001bf32f05f8e2974f41b0231738`.
Checks: `s15_result/s15_checks.json`,
`ab125012dd734533f1be1cfd4ebf4884af30067160ac12e9487916b608862ed2`;
execution receipt: `s15_result/s15_execution.json`,
`195d591e40789811d7778e0da5d014120fafa9b1eee9927a5d9621c5d0da270f`.
The regenerated scheme result is `s15_scheme_result/s15_result.wl`,
`eb5e4505751c2bbc041916562a9b1b4f0fc42584f721879ee29081c736364048`.
All files were collected locally and checked against the cluster hashes.

The complete result uses schema `polarized-sidis-finite-partonic-coefficients-v1`.
Read `PhotonLabels`, `SpinLabels`, `IndexOrder`, `PhysicalFrame`,
`PlusDefinition`, `BranchConvention`, `PhysicalConditions` and `FlavorDomain`
from that result before consuming its tensors. `Fhats` contains `F1` and `F2`;
each has `LODelta` and branch-keyed `NLO` distributions. The NLO spin matrices
retain outgoing and incoming indices in the recorded order. The full
`NLOResponse` also retains all photon components.
The export records complete pole cancellation, finite coefficients and
applied finite helicity restoration, and binds accepted S14 and scheme
results. The S14 U/U comparisons reproduce the pinned GitHub hats.
This is the original large-transverse-momentum partonic SIDIS measurement;
PDF/fragmentation convolution, numerical proton polarization and jet matching
remain outside this result.

The accepted final S14 result and the three S15 Wolfram exports above are
retained locally. Their duplicate cluster copies were removed after exact
SHA256 and byte-count comparison and a check that no active channel depends
on them, reclaiming 160893137 bytes of scratch space. Shared validation
artifacts and receipts remain on the cluster. To rerun Hqqprime's completed
S14/S15 consumers remotely, restore those four exact local files at the same
relative paths and verify the hashes listed above first.

## Channel entry files for accepted S08 and S12

`s08_map_real_spin.wls` links to the accepted shared
`../common/s08_map_real_spin_streamed.wls` implementation, SHA256
`f65fbeee3345dcf281e60192a7e6ea4dfd08eb547f4aa7fb225134462e1ed601`.
`s12_assemble_real_spin.wls` links to the accepted shared
`../common/s12_assemble_real_regulator.wls` implementation, SHA256
`13546e04edf3441fa2a10bb9ae2b2dbfa406c67598f68a517955eabd1233ac4a`.
Run from the polarized_SIDIS root with `POLARIZED_SIDIS_CHANNEL=Hqqprime`
and the matching saved job configuration, including its reduction-table
setting and bound validation inputs. These entry links retain the source,
input and result identities documented for jobs `14796501` and `14797140`.
