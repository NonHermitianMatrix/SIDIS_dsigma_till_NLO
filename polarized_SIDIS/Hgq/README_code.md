# Hgq: incoming gluon, tagged fixed-flavor quark

S05 native output may use verified text chunks when its compressed tensor
exceeds the per-file bound. `common/s05_chunked_result_io.wls` writes a small
`s05_result.wl` loader that verifies every payload SHA256 before native
decompression. Require exact equality of `Get[s05_result.wl]` with the full
in-memory tensor and retain `s05_payload_manifest.json` plus every listed
payload locally and remotely. Each part remains below 128 MiB; transfer
parts with the existing bounded, reserve-checked collector. The scientific
schema and downstream `Get` interface are unchanged. Serialization alone
may use 8 GiB within the allocated 20 GiB process limit. Validate the same
writer and reader against an accepted saved tensor before production use.

The storage comparison passed job `14795932` on `n6124` in 170.785 seconds,
with peak observed process-tree RSS 1,433,055,232 bytes. The accepted result
`s05_storage_validation_result/s05_result.wl` has SHA256
`9b8cea3c856074a6421ce965cfafab0e0b87aa93b3d3c89ae2f5f4bdc1b0351f`.
It forces multiple payload parts on an accepted native tensor and proves
exact reload through the unchanged `Get` interface. The writer source hash is
`6c3cf6deedd7de13c79b0f363cc2010c4ab6b6b12a2b10862283459b478c45ea`.
`common/s05_real_spin_response_chunked.wls` changes only the final storage
block of the reviewed spin-polynomial implementation. Its source SHA256 is
`448522b6dc2b65061cc012789cabd082c9c9e45deb97bb744f5edb39337786a0`.
Production acceptance still requires the complete tensor gates and exact
reload of its own output; the comparison alone does not accept that tensor.

Completed S05 pair checkpoints are sufficient for the unchanged resume and
pair-sum readers. Individual projection files belonging to completed pairs
may be archived on a compute node while tensor assembly continues. Preserve
every path pinned in the S05 manifests and job configurations, all pair
files, and all assembled sums and spin checks. Verify each archive member's
SHA256 and byte count and the unchanged completed pair hash before removing
the redundant raw projection. Retain compressed parts below 128 MiB and the
manifest in `s05_projection_archive_result/`, with bounded local transfers.
This changes storage only; it does not accept additional scientific output.

Job `14796091` verified 467 redundant projection files while preserving all
36 completed pair checkpoints. Its archive manifest has SHA256
`4dd8c624b0bec618ded1add23513c634a9918cb6dae914b9cbca465548bdcb3d`.
The local archives in `s05_projection_archive_result/` are
`s05_cache_part01.tar.gz` (SHA256
`761331855c5033b0a2f1a245bb7cb5ed12d7d951fe438f3da85728c49a02a00a`)
and `s05_cache_part02.tar.gz` (SHA256
`35bd38a639dd72b16be04720b30184259241eb581234a3d4d9c240657e7ae7fd`).
Both archives and the matching execution receipt are retained locally.
Remote duplicate archives were removed after exact local/remote hash and
byte-count checks; remote metadata, all pair files and tensor sums remain.
To restore a projection, verify its archive hash, restore at the manifest
path relative to this calculation root, then verify its original member hash.

The incoming gluon has momentum `p`; the tagged quark has momentum `k1`.
Preserve the fixed observed flavor, its charge, and this channel's physical
gluon convention. The reference gluon spin average is dimensional.

## S01 inputs

`s01_prepare_inputs.py` uses the shared S01 implementation.
`s01_result/` owns the selected open-amplitude input receipt. The original
spin average and projected tensors are unpolarized references only.

## Spin-dependent contract

An incoming gluon's spin basis differs from a quark's. Define the required
responses and their proton-operator interpretation before contraction.
Keep the incoming/outgoing spin and charge labels explicit.

The upstream README historically recorded an independent MadGraph real
sign-comparison caveat. It must not be silently treated as resolved by an
input import or by a new polarized pole cancellation.
The explicit S17 comparison in job `14818632` resolves that caveat: the
comparison reader used a signed color-representation label as `SUNN`.
Native color traces determine the positive dimension, and all 32 original
projector comparisons pass with the corrected reader. See the accepted S17
evidence below; the production F hats are unchanged.

Later accepted sources/results use consecutive `sNN_` names and the
shared cluster and acceptance contract.

## S03 dimensional Born result

`s03_born_spin_response.wls` links to the shared reviewed implementation.
Its `s03_result/s03_result.wl` passed 47 checks in Hoffman2 job
`14773868` on `n6442`; SHA256
`570bde9d826e893d775f6bc458307369c6eb65316872f7268562345e527da177`.
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
316846080 bytes.

## S05 real tensor contract

Use the shared S05 implementation and acceptance gates. The incoming
gluon retains its physical Stokes components and internal E complement;
its dimensional average is reconstructed only for comparison with the
original tensor. The reference is
`s05_result/reference/unpolarized_real.wl`, SHA256
`286b9586de2bec744667421d4b16d1081a0df6e18fda0e328918c46b1dbd0649`.
Preserve this generated process's tagged flavor and spectator weight.
The independent MadGraph caveat above remains distinct from these gates.

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

Job `14774827` on `n6126` passed 60 checks, including every
original CDR convolution and all spin-dependent routes. The result
`s11_result/s11_result.wl` has SHA256
`1fbc01498047f39d73573dc5e97ebac79ace566ba0d8e8e494aebf5043c929fd`.
Checks and execution receipt are saved alongside it. The source is the
unchanged shared S11 program, SHA256
`9c5784631fbeb46741b274186985fb21f1607d4063525025517bb0560f11de96`.
These BMHV subtraction tensors retain the reference measure and endpoint
convention. Finite scheme conversion and complete real/virtual pole
cancellation remain assembly requirements. Runtime was 333.145 seconds;
peak child RSS was 472997888 bytes.

## S13 renormalized virtual tensor contract

Use the shared S13 adapter only with this channel's accepted S07 and S09
results and complete reduction coverage. Preserve the physical master
continuation, complex interference, loop measure and generated external
field bookkeeping. Require new-spin UV cancellation, original CDR UV
reconstruction, and integrated Ward checks. Its Laurent tensors require
real and collinear assembly before they become finite F hats.

### S07 gluon-reference comparison contract

The original native Pg/Ppp comparisons use the generated amplitude with
the reference's covariant gluon polarization sum. The resolved physical
Stokes axes must be distinguished from that gauge choice at the individual
diagram level. `../common/s07_reference_gauge_check.wls` tests both sums
against the actual pinned first-diagram integrand, using the accepted
compact contraction definitions. Its output diagnoses the comparison
interface only; it cannot accept a full virtual tensor or finite hat.

For the virtual per-diagram CDR comparison, test a reference-completing
auxiliary component defined as the inherited covariant D-dimensional
sum minus the physical U density. Its difference from a purely
evanescent projector is gauge bookkeeping. Require native equality of
the completed sum, unchanged physical spin densities, the entire accepted
extended Born tensor, and the actual first-diagram GitHub contractions
before changing the virtual auxiliary component. The comparison result
belongs to `s07_gauge_completion_result/`.

The gluon-completion comparison passed in job `14775322` on `n7123`.
`s07_gauge_completion_result/s07_result.wl` has SHA256
`ff95049db3c217c2b51dea1505542521ad42cbeb753e8acabc9fa90d67a3ebc0`. Both original first-diagram projections and the
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

The S15 finite scheme tensor passed Hoffman2 job `14775516`.
`s15_scheme_result/s15_result.wl` has SHA256
`13d01274ac5ee6d12cbeac52be24471900ca7eb9439ca6a4d1ea4de912067a58`. All normalization, helicity-index,
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

Independent S13 UV components may use the shared bounded parallel dispatch
after a fresh worker reproduces an accepted serial checkpoint. Preserve
the serial source/input cache identity and the native calculation exactly;
sum returned components in the original diagram/component order. Every
original CDR residue, full UV cancellation and integrated Ward check remains
required for accepting the complete virtual tensor.

The worker comparison passed job `14777444`. Its result is
`s13_parallel_result/s13_result.wl`, SHA256
`133fd67e5f1d02571a6c5f07ecd85f7cc0101e33a14db963478378c7629f0d9f`.
It verified a fresh nonzero component against the accepted serial result,
unchanged native equations and unchanged cache identities. The recorded
inventory has 720 independent UV tasks. The dispatch source SHA256 is
`0d332c9cd7011cadc7a0d40dc4234382023a1f2c419fd616bab3aa4d6f1e0dd2`;
serial source `930cb13c80514b51fbd2ae017feee7b1adac813651670e779258156f161aae6f`
continues to define the calculation cache. This comparison accepts worker
dispatch and does not accept an integrated virtual coefficient.

The complete S07 virtual tensor passed Hoffman2 job `14775501` on `n6440`.
`s07_result/s07_result.wl` has SHA256
`8fac078b7695b9769289fc2f22873a86e26d1a67c35d55240b19950db80ba0c5`. The source SHA256 is
`3bf664aa2860ec32df9570f7d8832ccd868b2add23f5125a35f465e87862cff5`.
All diagram, worker and inherited reference comparisons passed. Checks and
the execution receipt accompany the result. It is the complete virtual
integrand input to S09 and S13; loop integration and finite assembly remain
required before a finite NLO coefficient can be accepted.

If S09 reports uncovered virtual targets, `s09_extend_virtual_reduction.wls`
uses the original canonical families, Kira/Fermat binaries, generated bounds,
configuration writer and symbolic rule reader. The requested target set is
the union of the actual spin targets and the saved targets/rules/masters.
Require exact agreement with every original rule, the unchanged master basis,
complete new target coverage and sufficient master depth. Its completed map
belongs to `s09_reduction_result/s09_result.wl`; the original S09 map remains
available as provenance. The new reduction is not an integrated coefficient.

S09 mapping passed job `14776353`; `s09_result/s09_result.wl` has SHA256
`0bb4747ce698189ad4bc7e4b19155e8e61888b75a2f1609beae612f06846a29c`.
It mapped all 15 diagrams and identified five additional scalar targets.
The extension passed job `14777336` on `n6405` in 183.872 seconds, with
531943424 bytes peak child RSS. Every original Kira rule matched, the
seven-master basis was unchanged, and reduction coverage and master depth
passed. The completed map `s09_reduction_result/s09_result.wl` has SHA256
`b8c9a8e746f32c2bc72c075097157a69edd5f22594574f3b29494e5bd64f9a55`;
the accompanying `s09_reduction.wl` has SHA256
`86cf03f793378b46a7794b44d5620a6eff3ea69fb0aa5326cc8a5e90b6e0f96a`.
Checks and execution receipts accompany both outputs. The extension source
SHA256 is `1e60cbbacb7919ca6a57a130cac2fee3ea6aeee2a7ddba14a634c8df9598fd71`.
S13 selects this completed map through `POLARIZED_SIDIS_VIRTUAL_MAP` and
verifies its recorded input hashes, spin identity and coverage/depth gates.
The virtual integration and UV-renormalization routines are unchanged.

S13 consumers must verify each result hash against its execution receipt
immediately before use. The files associated with receipt `14777449` were
overwritten by the older serial process `14777368` after that receipt was
written. That mixed output set is invalid for downstream use and is isolated
remotely under `cache/previous_s13_Hgq_output_conflict_14777449/`.
The unchanged, input-bound native UV and assembly checkpoints retain their
mathematical provenance. Regeneration must use the reviewed S13 source and
produce a new matching receipt after all prior writers have exited.

The accepted S13 output generation is job `14778459` on `n7005`.
`s13_result/s13_result.wl` has SHA256
`dd7f3776cc7e9d83ed0f749140bfe2da7424e65130ff56bf1538db0421e0f51d`;
`s13_checks.json` has SHA256
`13d8afc8f7f7536f6266891c8c96a071f57161df60497d5a86f957f9387bada5`.
The receipt and both matching artifacts are saved locally. The unchanged
S13 source `0d332c9cd7011cadc7a0d40dc4234382023a1f2c419fd616bab3aa4d6f1e0dd2`
reused its verified UV and integrated-component checkpoints after prior
writers exited. Original CDR UV residues, input identities and the complete
accepted component inventory passed again. Runtime was 118.273 seconds
with 779546624 bytes peak child RSS. This tensor is loop-integrated and
UV-renormalized; cancellation of its remaining infrared poles still requires
the real and factorization contributions in S14.

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

S05 projection resumes may set `POLARIZED_SIDIS_REAL_SECONDS` explicitly
(the default is 2400 seconds, with a checked maximum of 10800 seconds).
This changes only the native time bound. The 2 GiB operation limit and
4 GiB spin-reconstruction limit, all contractions, checks, and checkpoint
identities remain unchanged. The scheduler and process-tree limits must
cover the selected bound. Preserve the preceding source in
`common/s05_result/reference/s05_real_spin_response_before_projection_time_resume.wls`.

## Completed-stage cache archives

After full S05 acceptance, its remaining producer cache may use the same
lossless archive procedure as Hqqprime. Require the accepted tensor receipt
and every result hash, no active S05 producer or pinned cache consumer, exact
archive-member hashes and byte counts, and parts below 128 MiB before removing
raw cache files. Keep `s05_result/s05_cache_manifest.json`, its parts and
`s05_cache_execution.json` locally. Preserve the accepted tensor loader and
all five payloads on the cluster for S08; those files are not cache cleanup
targets. A future producer resume must restore and verify archived members.

The completed S07 per-diagram cache is preserved in
`s07_result/s07_cache.tar.gz`, SHA256
`09fe30ddeac229760dae85ea0039c989d5651b8fb068ca2d77ca52c264c780d1`.
The accompanying `s07_result/s07_cache_manifest.json` binds every member
to its original byte count and SHA256 and records accepted producer job
`14775501`. Every member was read back and hash-verified
before the uncompressed completed cache was removed.

The completed S09 per-diagram cache is preserved in
`s09_result/s09_cache.tar.gz`, SHA256
`8a5aeebe92b5d326628d7dc1a1c16d533e0d060eb73ff9f27fb93c00e929cfd1`.
The accompanying `s09_result/s09_cache_manifest.json` binds every member
to its original byte count and SHA256 and records accepted producer job
`14776353`. Every member was read back and hash-verified
before the uncompressed completed cache was removed.

The archives and manifests are retained locally. Remote duplicate archives
were removed only after the local and remote SHA256 and byte counts matched;
the remote manifests and accepted stage results remain available. Current
consumers read those accepted results. To resume an archived producer, transfer
the archive back with a SHA256 check, then restore its members relative to
the polarized_SIDIS root at the manifest paths and verify every member.

## S05 equation-based reconstruction comparison

The comparison program is `../common/s05_spin_reconstruction_check.wls`;
`../common/s05_spin_reconstruction_inputs.json` pins this channel's actual
assembled photon expressions and its five accepted reconstruction checkpoints.
It loads the unchanged production initialization, field inventory, photon
conversion and spin extraction, derives the polynomial structure from those
expressions, and tests selective spin expansion followed by exact rational
checks of any remaining coefficients. Every photon component must reconstruct
exactly; each existing accepted checkpoint must match the current input binding
and predicate output. Timings, expression sizes and memory measurements belong
to `s05_spin_reconstruction_result/`. This comparison cannot accept a complete
real tensor or finite hat, and its candidate is not enabled in production
before the complete executed comparison passes.

The unchanged serial assembly needs more than its former 12 GiB process
address-space cap: job `14783103` exited for lack of memory after five
reconstruction checks. Its continuation configuration requests one slot with
20 GiB and an 18 GiB process-tree guard, retaining all input-bound checkpoints.

The reconstruction comparison generation `14787835`, using source
`ba1dbaf4529a3fb83156d028b163d98d3a2ab186f24c137ac29ea45a208abd53`,
did not finish its complete acceptance gate. Components 1 through 7 passed,
including comparisons with the five previously accepted checks, but component
8 exceeded the comparison's 300-second operation bound. Its receipt and
`cache/s05_Hgq_spin_reconstruction_exact.log` preserve that failed generation.
There is no accepted optimization result from this run. Do not enable the
candidate predicate or treat those partial checks as a complete real tensor.

The comparison continuation preserves the exact tested predicate and derives
its cache identity from the archived algorithm source, equation manifest,
production input identity and native versions. Each component records its
original binding, exact reconstruction, own accepted-output comparison where
available, timings and checks before advancing. A native operation has a
1200-second time bound and the same 4 GiB allocation bound. These comparison
checkpoints are separate from the unchanged production cache. Complete
nine-component acceptance remains mandatory before enabling the predicate.


The complete reconstruction comparison passed job `14795486` on `n6640`.
`s05_spin_reconstruction_result/s05_result.wl` has SHA256
`68bd1b38f42d0623d7e174dca57ff59e9aef016495155180fa103c4b565a7210`;
its checks and matching execution receipt are retained locally. Source SHA256
is `4283708ea806d88f7f4e2dc6532f4f7de9f90c1673ef030f73d0ce277b6e939d`.
All nine actual photon components reconstructed exactly and all five own
accepted component comparisons passed. Components 8 and 9 took 586.959018
and 616.264422 seconds. This accepts the reconstruction predicate and its
input-bound checks, before the complete real-tensor and integration gates.

`../common/s05_real_spin_response_spin_polynomial.wls` retains the original
production source and calculation hash, loads the exact accepted predicate,
and changes only the final spin-reconstruction check and its checkpoint
reader. Existing production checks remain reusable. A comparison checkpoint
may be imported only for this same channel, physical input hash, full task
binding, spin-axis inventory and exact recorded measurement. Its provenance
is retained explicitly. Other tasks run the executed polynomial predicate;
trace, scalar, pair, sum, Ward, CDR and final serialization routines remain
unchanged. Require the original complete production acceptance gates before
S08 can consume the tensor. Never overlap writers to the production cache.

## Accepted complete S05 real spin tensor

Job `14795984` on `n6643` passed the complete S05 tensor gates: all 36
pairs, Ward identities, photon Hermiticity, photon/spin reconstruction,
original dimensional Pg/Ppp comparisons, and exact native output reload.
The source is `common/s05_real_spin_response_chunked.wls`, SHA256
`448522b6dc2b65061cc012789cabd082c9c9e45deb97bb744f5edb39337786a0`.
The loader `s05_result/s05_result.wl` has SHA256
`c93632c558a2710cda98691e8f52929e88d224c9a71bce456a9935231ccff7ec`;
its five payload files and manifest are all retained locally and remotely.
The manifest SHA256 is
`8da2d519fd8cf29f1fe5e7e7fb38242d4f6549661a5e087f86d9d2fe29fce8a0`.
The matching execution receipt SHA256 is
`06894e0522f2ce56d59bcd688fb568b6f4dbdc1e18bfd95e2322956a253c81ba`.
Runtime was 3019.410 seconds; observed peak process-tree RSS was
12,491,030,528 bytes. The native tensor has ByteCount 5,847,788,240 and its
serialized payload totals 157,074,778 bytes. S08 consumes the loader through
unchanged `Get`; this tensor precedes cut integration and finite assembly.

Job `14796294` archived and verified the remaining completed S05 cache.
Its manifest `s05_result/s05_cache_manifest.json` has SHA256
`c64bedc096c83f082fe1f2263e3c77d1690b8122b5d3f9ec5109666796c0b786`.
All three parts and `s05_cache_execution.json` are retained locally with
verified hashes. The remote duplicate parts were removed only after exact
local/remote hash and byte-count verification; the remote manifest remains.
This complements the projection archive above. Neither
archive is an input to S08, which reads the complete accepted tensor.

The first S08 loader attempt (`14796203`) exhausted its 8 GiB process
address-space limit before the accepted-input gate. No target map was
accepted. A resource-only continuation uses one 24 GiB process and a 22 GiB
process-tree guard, with unchanged 4 GiB mapping operations and source hash
`8700fb675c4a0196d1a6f7aa7d1710e25a9210b0de85bd902990e2e7589772a9`.
Serial dispatch avoids replicating the large tensor in worker processes.
All original input, worker-control, reconstruction and export gates remain.

After that serial writer exits, a resource-only resume may use two shared
slots with 16 GiB per slot, a 24 GiB per-process address limit and a 30 GiB
process-tree guard. The complete native tensor is 5,847,788,240 bytes; the
serial mapper's measured peak process-tree RSS is 7,504,392,192 bytes.
Keep the 4 GiB operation bound and all completed target checkpoints, and
require the existing fresh-worker reference comparison before new mappings.
The subsequent streamed coefficient stage may use the same two-worker
allocation with its unchanged 2 GiB operation bound. This changes dispatch
and resource limits only; mathematical source identities, accepted caches,
reconstruction gates and output schemas stay unchanged. Full-channel
acceptance and a measured runtime are still required.

## S08 reference pair-order comparison

`common/s08_check_gluon_pair_mapping.wls` reuses the accepted Hqqprime
pair-mapping implementation, the unchanged reference mapping/merge functions,
and the same compact spin extraction already used by this channel's S05.
Derive the incoming/outgoing axis lengths from this accepted tensor and require
the recorded gluon E complement. Restore only its 36 accepted pair records,
verifying each member against `s05_cache_manifest.json`. Select the complete
own-channel accepted canonical map and a nonzero incoming-E component from the
actual task inventory. Require the complete pair sum, each pair map, the merged
map, both cuts and the own accepted map to reconstruct exactly. The isolated
comparison belongs to `s08_pair_mapping_result/`; it must not write the active
canonical mapping cache or claim a complete target map or finite coefficient.

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

## S08 production in the accepted reference pair order

`common/s08_map_real_targets_by_pair.wls` may run only after the complete
own-channel pair comparison passes with identical sources, pair files,
measurement inputs and native versions. It executes the comparison's unchanged
spin extraction, pair mapping, summation and reconstruction operations across
the full task inventory. Retain the canonical target input hash and reuse only
accepted canonical checkpoints with the exact task identity. Preserve the
original fresh-worker reference-map comparison and canonical export gates.
Record the production dispatch hash and comparison hash separately.

The canonical writer must exit, and its own job's native kernels must be
confirmed absent, before this implementation writes that cache. Use four
shared slots at 8 GiB per slot, a 24 GiB process-address limit, a 30 GiB
process-tree guard and the comparison's 4 GiB mapping-operation bound.
After a new complete component is checked and saved with exact native reload,
its intermediate per-pair maps may be removed: the accepted canonical map,
pair evidence and original S05 pairs retain its result and reproducibility.
Keep the original comparison's selected per-pair caches. These are mapping
outputs; Kira completion, integrated coefficients and finite assembly remain
separate requirements.

The complete pair comparison passed job `14796627` in 7927.373 seconds,
with peak observed process-tree RSS 9,520,463,872 bytes. Both selected
components reconstructed exactly from all 36 pair maps; the complete own
accepted control map matched. Result SHA256 is
`3e76aa58afd796344e94f2dcb40b94765e1d0cd7a92443e92429a4dc5f4eeb55`;
checks SHA256 is `b07476f9a918bae2f6b447614ee886cc659c9006b3aa4a56b7aa428fcb78566b`;
receipt SHA256 is `ebc1e5404a4d14e2f5e8ceb1e93bd50dee572b04ffa461616a9ff12d30ebae37`.
All are verified locally. This establishes correctness of the tested mapping
order, not a speed advantage or acceptance of the unexecuted production adapter.

After the accepted pair comparison completed, its 36 temporarily restored
S05 pair files were returned to archive-only storage. All three original
compressed parts were reverified locally against manifest
`c64bedc096c83f082fe1f2263e3c77d1690b8122b5d3f9ec5109666796c0b786`;
each restored member was hash-checked and active-job input bindings were
checked before removal. The canonical mapper consumes the complete S05
loader and payloads, which remain available. Running the optional pair
adapter requires restoring those exact manifest members first.


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

The corrected S11 generation passed job `14799111`. Its result SHA256
is `fd14b9701bce2f78f8b18ba7b381e4fa2c6f1b80bd4e2ae4113adcbd92eb9bae`;
checks SHA256 is `332152d9c7609a8e7be4b486eeba0dd83fa30e76f1291825dbff10e300335298`;
execution receipt SHA256 is `61029350c0ba8fb90d432f5d2dbf865f72bef3df3f1e1cefd63f516af4168050`.
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

## S08 certified denominator comparison

`common/s08_check_certified_denominator_mapping.wls` uses the unchanged
canonical initialization and original reference mapper inside each denominator
group. Load the exact accepted Hqqbar grouping and merge-linearity definitions,
verify their source, measurement and native-version identities, and retain
every original per-group mapping and cut check. Replace only the final global
rational reconstruction with exact per-integral coefficient sums and the
executed native linearity certificate. No physical mapping operation changes.
Select an own accepted canonical component from pinned files, require complete
reconstructed equality with its saved map, then time the first component
outside that pinned accepted inventory. Record exact inputs, definitions,
timings, complete checks and native reload under
`s08_certified_denominator_result/`; use a separate bound cache. This comparison
must not write the active canonical target cache. It does not accept a complete
channel or authorize production use before its complete checks pass.

## S08 certified mapping continuation contract

`common/s08_map_certified_denominator_targets.wls` may install only the exact
definitions from the successful own-channel denominator comparison. Require its
receipt, source/configuration hashes, native versions, complete component checks
and original mapping/merge definitions to match the current production inputs.
Retain the canonical physical input/cache identity, original accepted components,
original fresh-worker reference comparison and final target-map export checks.
Reuse a comparison component only after its current task and input identity match.
Pass each worker its individual task with a native hash check; do not distribute
the complete task list to every worker. Preserve the comparison's input-bound
group checkpoints and every term/group reconstruction and cut check. Record the
adapter and comparison identities separately in the final map. The prior
canonical controller and its native writer must relinquish this stage before
production writes begin. Kira coverage, integrated distributions and finite
assembly/export remain downstream requirements.

The own-channel certified comparison passed job `14802243` on `n6046` in
4746.850131 seconds, with peak observed process-tree RSS 7,328,002,048 bytes.
The complete accepted component 2 was mapped in 1084.561012 seconds and its
full reconstructed equality check took 1443.939701 seconds. Component 7 completed
all 23 denominator groups and final reconstruction in 1663.975408 seconds.
The original canonical component 2 recorded 1687.317199 seconds for mapping;
the separate full comparison cost is retained in the evidence above.
The verified local `s08_certified_denominator_result/s08_result.wl` SHA256 is
`04c9d378a4c3ae74e16177a399435a687a476df6182cea953c6dfa47fe6c0feb`;
checks SHA256 is `dc310a7f00eb14ea42eb0f713a9137435a7196305eafddf57ffeabe7367b7e4a`;
receipt SHA256 is `86f6610b2aeba4ef9839b75a634a2025360f80b1a3a2f120a90bc84faa58f498`.
The comparison source SHA256 is
`92b48ef6d8503188c58059cf9d7eb1ade32250ec5632d1ccdda3b695245d603e`,
with configuration `6f1af64503698c68affe68610038e9d091f78cc62b58ba2851af54ca498bf593`.
The reviewed production adapter SHA256 is
`276180187746d185e01f4b0ca88af004a0e81492ca9449bb97f280c4384ef821`.
Its allocation is four shared slots at 8 GiB each, a 24 GiB process-address
limit, 30 GiB process-tree guard, and the comparison's 4 GiB/3600-second native
operation bounds. Original canonical cache components 1–6 remain reusable;
the accepted comparison additionally supplies component 7 for the same input.
The complete production map and downstream finite coefficients are not implied
by this accepted comparison.

## S08 pair-input restoration for canonical completion

The 36 original S05 pair inputs have been restored on Hoffman from the three
locally retained archive parts. Manifest SHA256 is
`c64bedc096c83f082fe1f2263e3c77d1690b8122b5d3f9ec5109666796c0b786`.
Every restored member passed its manifest SHA256 and byte-count check;
their combined size is 149,750,802 bytes. The complete S05 loader and payloads
are unchanged. This supersedes the archive-only availability statement above.

Use the unchanged reviewed pair adapter
`common/s08_map_real_targets_by_pair.wls`, SHA256
`274340d710c5e9c3c1b88310e63c1a1a8b97bab2683567de4580b29f42855db8`,
and its own accepted comparison `14796627` under the preceding contract.
The canonical target cache remains owned by exactly one producer. Require
previous controller exit and native-writer absence before the adapter starts.
Its original complete component reconstruction, exact reload, mapping and
cut checks remain mandatory; accepted canonical components are reused by input
and task identity. The S08 reduction, S12 integration, S14 cancellation and
S15 finite export are unchanged consumers. The final S15 collection includes
the scheme result whose hash is recorded in the final coefficients.


## Final-assembly input review

After accepted S12 integration, bind the actual result and review its native
loading and export requirements before S14/S15 submission. Reuse accepted
finite assembly, scheme conversion and exact native serialization interfaces;
collect the matching scheme artifact with the final hats. S12 completion is
not finite-hat acceptance. This execution boundary preserves the existing
mapping and integration stages and avoids obsolete finite-export resource
settings. The pinned reference sign caveat remains applicable.


## Accepted complete S08 real-target map

Hoffman2 job 14807261 on n1155 passed all 132 checks
for 37 canonical components and 374 scalar targets. Its source is
common/s08_map_real_targets_by_pair.wls (SHA256 274340d710c5e9c3c1b88310e63c1a1a8b97bab2683567de4580b29f42855db8).
The full result s08_targets_result/s08_result.wl has SHA256
20759f1682d632d314a1ff379f4451cbfd1a1df452dcfc8fafde3275c0610292.
Checks SHA256: 547a68b4f36c70c0fd4e5b995b238dc653219120cfee6e7ff71ff21fa6f418ac.
Execution receipt SHA256: 3a55af091068181954fa2adc85f04df216a61cbcf19bcb712040c4154a26bd26.
All three files are hash-verified locally. Every component passed complete
cut-family reconstruction, both physical cuts, native serialization and
the inherited mapping conventions. 207 targets require extension of the
reference reduction table before master coefficients and integrated real
distributions can be accepted. This map is not an integrated real tensor
or a finite F hat. Preserve the independent reference-sign caveat above.


The complete S08 reduction extension passed job 14813436 on n6041
in 250.07000207155943 seconds. All 354 checks passed, including
the original Kira rules, 207 additional targets and complete coverage of
the 522-target union, with 0 missing and 8 masters.
The verified reduction s08_reduction_result/s08_reduction.wl has SHA256
b887fb744892c61f934518178e1d1b4ef6ced915ee75cf80bee58c8a53f41f13.
Checks SHA256: da32b3a0012ac08b0154005f7fb5667ed42c4e0ff2d49a2885d51b2d410e2706.
Execution receipt SHA256: 5e5ea584f48b574606382c4171ade1c0021cc895726479babe21b2b6aea29504.
All files are verified locally. Master-coefficient construction, real
integration and finite assembly remain distinct required stages.

## Compact final assembly and export contract

After the accepted S12 receipt and its actual result hashes are verified,
use `common/s14_assemble_finite_compact.wls` (SHA256
`3e570b82f4f5957c099fdd0c14fb8e6b7592ad0b94d9b9404c96d31d53c0440b`).
It preserves the phase-series assembly above and changes only the final
native representation, requiring exact reload of the complete saved result.
Bind the original S05 loader, all five manifest payloads, and the accepted
S03/S05/S11/S12/S13 receipts and result identities before submission.
The 5,847,788,240-byte decoded S05 tensor and its measured 12,491,030,528-byte
producer process-tree peak rule out the obsolete 6 GiB assembly allocation.
S14 is serial: request one shared-queue slot at 32 GiB, with 30 GiB process
address and process-tree guards; retain the original 2 GiB/1200-second
native-operation bounds and four-hour scheduler request. This is a bounded
allocation choice, not a measured S14 memory requirement or runtime promise.

After complete S14 acceptance, use
`common/s15_finalize_spin_coefficients_compact.wls` (SHA256
`8f2bb37f8b38701c669a08b9270d290aeb7292ab162f0b66820dea7b8eb3ddc9`).
Request one slot at 24 GiB with 22 GiB address/process-tree guards, retaining
the unchanged finite-conversion calculation and its native-operation bounds.
The earlier Hqqbar final-export run measured 8.72 GB peak child RSS; that is
resource evidence from another channel, not an Hgq runtime or memory result.
Require this channel's full pole, branch, unpolarized-reference, scheme and
exact native reload checks. Collect `s15_result.wl`, both F hats, the checks,
receipt and matching `s15_scheme_result/s15_result.wl`, each under the 128 MiB
file cap and with the existing local/remote reserves. These contracts do not
accept unexecuted stages or resolve the separate reference-sign caveat.


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

## S08 compact worker inputs

`common/s08_map_real_spin_compact_inputs.wls` retains the reviewed streamed
coefficient implementation and canonical cache identity. After the complete
own raw-map acceptance and ordering gates, omit task Value only where the
raw component has nonempty accepted reconstruction checks. Retain the original
Value for empty-check components so the existing zero-input test is unchanged.
Require exact task metadata and retained-value equality. After all tensor
input gates, retain exactly the spin metadata used by final S08 export and
release the unused full tensor and sector reference. Record native input byte
counts and memory measurements; do not alter mapping or coefficient equations.

Before production use, reconstruct complete accepted own components 14 and 16
in a separate cache from their hash-bound master packets. Do not copy the
complete component outputs into that cache. Require exact native equality
of both mathematical records, excluding only their execution-dependent Checks
log; both original and regenerated Checks must independently pass. Use the
unchanged component function and record actual raw-check and master counts;
an empty master block need not have empty raw-map checks. Preserve the
original zero-input condition whenever such an input occurs. Bind the complete
source, raw map, reduction, inputs, packet files and native versions. This
comparison does not establish complete channel acceptance or a speedup before
its measurements execute. Preserve the active producer and its checkpoints.

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

The first compact-worker comparison (job 14813722) is unaccepted. It passed
the data-projection identities but its memory ledger used a multi-argument
AssociateTo call, and its validation incorrectly required an empty raw-check
log in the empty master block. The corrected comparison uses a list of rules
for the ledger, distinguishes raw-check counts from master counts, and records
the actual selected-control inventory. The unchanged coefficient function and
production cache are unaffected. The rejected source is retained under
`common/s08_result/reference/s08_compact_worker_before_validation_fix.wls`,
SHA256 `136176109da6f5a13bb70cf252d49e67ff2243cc83352054558989a638deecf6`.
Complete own-output equality remains required before adoption.

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


## Accepted complete S08 coefficient map

Hoffman2 job `14813688` on `n1157` passed all 48 top-level checks
and the individual component reconstruction checks. Its 37 canonical
components cover all 374 scalar targets, with zero missing reductions.
It reuses the accepted real tensor, raw target map and eight-master reduction
extension above, with their original cuts, support, spin metadata and ordering.
The executed source is `common/s08_map_real_spin_streamed.wls`, SHA256
`f65fbeee3345dcf281e60192a7e6ea4dfd08eb547f4aa7fb225134462e1ed601`.

The verified local `s08_result/s08_result.wl` has SHA256
`cbe63dcaf1a601d399e3edf1e7a7d41fe7636ab3a1f9dc933dc4477d03d338aa`; checks SHA256
`249991f0d33f2568e723fd9af853ab9f4c1f23980941399d3bab872cf94ec963`; execution receipt SHA256
`578dabcb5776d901f1308112f36fa6da0445bdc9bd90575a8086f15524785345`. Its exact compressed native round trip passed.
The verified local log `s08_result/s08_native.log` has SHA256
`9c69cc431e5988eced9758676cc9a320303f1940bf52dae5df35fa2941fde22c` and comes from
`cache/s08_Hgq_coefficients_pair_completion.log`.
Runtime was 6192.112236086046 seconds; peak child RSS was 9891885056 bytes,
and peak observed process-tree RSS was 15455760384 bytes.

Load FeynCalc before Get. S12 consumes this accepted coefficient map through
the compact-input/reference-series contract above and must pass its own
original-series comparison and endpoint checks. The scalar map contains
coefficients of unevaluated masters; it is not an integrated real tensor or
a finite F hat. S14/S15 acceptance and the inherited independent-reference
sign caveat remain distinct requirements and limitations.


## S12 product-order and factored-endpoint contract

The Hgq-specific `common/s12_assemble_real_factored_inputs.wls` retains the
standalone rational recurrence, its complete numerator reconstruction and
master-depth checks. The ordinary product returns native polynomial Series
at the requested order. Require the previous product to agree through that
order, and require the output to contain no higher regulator powers. Before
remaining production components, reproduce the complete original ordinary
calculation for the smallest nonzero component and for component 3, which
exposed the prior product comparison failure.

Install only the exact recoil factorization definitions accepted in Hqqbar
job 14804751, bound by its proof, receipt, source and native versions.
Each coefficient and logarithmic derivative must reconstruct exactly.
Recompute complete own accepted component 1 in an isolated control cache;
require its ordinary term, both branches, distributions and soft support
to agree. The two own comparisons belong to `s12_factored_series_result/`.
Preserve all accepted canonical components by original input identity.
This contract authorizes the bounded continuation only after its executed
own comparisons pass; it does not accept new results in advance.

After complete accepted S08 mapping, the 36 restored S05 pair files are
again available through the verified three-part local archive only. Every
archive and member hash was rechecked against the unchanged manifest above,
and active-job input bindings excluded these files before 149,750,802 bytes
of redundant remote copies were removed. Accepted S05 loader/payloads,
S08 maps, S12 components and the original manifests are preserved. Restore
the exact manifest members before any future S05 or pair-mapping resume.

### Accepted S12 factored-input assembly

Job `14814320` passed all 76 top-level checks and all 37 component checks in 2822.356837654952 seconds. The original native-Series ordinary control, the previously rejected component comparison, and the full two-branch endpoint comparison passed. This accepts the integrated real contribution only; finite coefficients require the downstream S14 and S15 gates.

- `Hgq/s12_factored_series_result/s12_endpoint_comparison.wl`: SHA-256 `f3e6d14e21e3e473f0d868a5a64b579099160ba8805b9ef1879294870ed6b762`.
- `Hgq/s12_factored_series_result/s12_result.wl`: SHA-256 `bbe3016da16b4d5ba0d18b8ee978526d6cb666f570e1161a3d2e879d14002cb6`.
- `Hgq/s12_result/s12_checks.json`: SHA-256 `e0e7facaf03e12f7ae2c0d38d129b782512f86b1fecd0c4a1cd64763eddbb278`.
- `Hgq/s12_result/s12_result.wl`: SHA-256 `2ef0d63d50c8109f06762e63be776fa95a806a7157fe718a978c1108f1e702ea`.

Execution receipt: `Hgq/s12_result/s12_execution.json`, SHA-256 `d6b6ccca5a2dd83b7fb8575ba06282d62b3b7a4e786d06d43e2f0881092a38f1`. The executed source is `common/s12_assemble_real_factored_inputs.wls` (see the bound source identity in this receipt). Canonical accepted component checkpoints remain reusable under the unchanged S12 mathematical input identity.

### S14 own pole-refinement contract

The saved S14 checkpoint for `{{5,1,3},1,"Regular"}` retains the original
input parts and single-pole residual from job `14814407`. Its original zero
predicate reached the 2 GiB operation bound; this checkpoint is not accepted.
Preserve its exact bytes and failed receipt before any resume overwrites them.
Earlier accepted checkpoints keep their original mathematical input identity.

`common/s14_check_Hgq_pole_factorization.wls` must install the exact residual
refinement definitions accepted for Hqqbar in job `14806606`, with the native
runtime, original zero predicate and UV-refinement definitions unchanged.
Require an own accepted checkpoint comparison, zero for every saved failed
residual, and an independent zero check of every pole extracted from the
complete original input sum. Keep the original physical branch conditions;
record exact factor reconstruction and domain certificates as in the reference.
Release the unused S05 tensor after retaining its original frame, using the
already accepted S14 input-retention boundary. No other assembly input changes.

Use `s14_pole_factorization_result/` for the preserved failed input, receipt,
accepted control and comparison result. A later production consumer must bind
the accepted comparison and use its exact definitions. Complete S14 pole and
unpolarized-reference checks, followed by S15, still gate the final hats.

The first own comparison (job 14814633) certified the saved residual but
exceeded its 300-second bound when refining the independently extracted raw
input-sum pole. It did not produce an accepted proof or final hats. Preserve
its source as common/s14_result/reference/
s14_check_Hgq_pole_factorization_before_input_reduction.wls
(SHA256 45c43e374ba97047a17f77e3c86ae1af037633ca4f308a9d38192dfadc26d4dd).

The corrected comparison reproduces the original finitePart producer exactly:
extract the pole coefficient from Expand[Total[InputParts],eps], run the
unchanged reduce with the original physical conditions, and require exact
equality with the saved residue. Only then reuse the already computed
refinement of that same residue. Record this explicit method in each row.
The executed inherited refinement, branch domain, original control and
300-second/2-GiB operation bounds remain unchanged. Acceptance still requires
every saved residue and independently reconstructed input-sum pole to vanish.

### Completed S08 cache storage contract

The accepted S08 mapping (14813688) and downstream S12 integration (14814320)
permit lossless archiving of completed Hgq caches under cache/s08,
cache/s08_targets and cache/s08_certified_denominator. Preserve every file
bound by a saved job configuration. Require no live S08 Hgq writer and no
live job referencing the selected cache prefixes. The archive manifest
records every original relative path, byte count and SHA256, and binds the
accepted stage receipt. Keep raw files until all compressed parts and all
members are independently verified locally. Preserve all accepted stage
results and restore archived members by manifest before any cache-dependent
rerun. The storage operation makes no change to calculated coefficients.

The S08 archive was accepted in Hoffman2 job 14814827 (21.113163744099438
seconds). All 595 archived members (150,412,340 bytes) passed independent
local verification before their remote raw copies and duplicate remote
archives were removed. Every configuration-bound member remains in place.
Restore archived members from the local manifest before a cache-dependent
rerun. Local identities under Hgq/s08_cache_archive_result/:

- s08_cache_manifest.json: e6a43438c1d325f7ab612808e5e2d783390cf358d79bf9d9d007f76ed3225393.
- s08_cache_part01.tar.gz: 1fcfa0cf8b160a99c220ceeb8685bd6a50ed2cedd21a319ec6d83b7fca50b1ac.
- s08_cache_part02.tar.gz: 944a8d43507a56fb771e0cec55863836b74e9444f2988ab8202c94af688a91cb.
- s08_execution.json: 67256bf8496d725e7442dbc3d149245993802caa3df07cb44d224f202ee1cf8b.

The corrected Hgq pole comparison was accepted in Hoffman2 job 14814823
(803.5692396759987 seconds). The original input reduction exactly reproduced
the saved residue, and both the saved residue and independently reconstructed
input-sum pole refined to zero. All original-control, source/input/domain,
certificate and native-reload checks passed. This is a pole-refinement proof,
not a complete finite coefficient. Accepted identities under
Hgq/s14_pole_factorization_result/:

- s14_result.wl: ab78fcece05caa049844b31e1b4ebdad35722600881b0e0de8025e72db18c6ff.
- s14_checks.json: da5fec84d3923abf16df459c5a102fc4ff2805fb0bae4b1ff21eb4c563d622a6.
- s14_execution.json: 36ef269a485dde2eeb7834e513945f0889c84c3ebcb6ccf0cd8a6b1d0d66fc8e.

Resume S14 with common/s14_assemble_finite_Hgq_refined.wls, SHA256
3d7851127d6713b036c17c4dd2db483da5e4dfe2c8764937ca12948f4ad9c0c0.
It binds this proof and installs its exact executed refinement only in the
finite pole predicate. Keep all accepted canonical finite checkpoints.
Compare the original and deferred-input assembly on the complete accepted
control component before production. Retain the original reference-zero
predicate, exact finite precollection reconstruction, all photon/spin/branch
comparisons, full pole cancellation, bounded native export and exact reload.
Use the existing one-slot 32-GiB allocation and 30-GiB guards, followed only
after S14 acceptance by the unchanged compact S15 export. Final F hats still
require S15 acceptance.

### S14 certified root-normalization comparison contract

common/s14_check_Hgq_root_normalization.wls addresses the saved negative-branch
Delta pole at index {8,4,1}. Its exact input and source identities are bound by
common/s14_Hgq_root_normalization_inputs.json; the original failed checkpoint
and execution receipt are preserved in s14_root_normalization_result/.

Derive factor products from each actual radicand using FactorList and require
exact reconstruction. Determine factor signs on the unchanged original domain
with Refine/Reduce; retain undecided factors inside the root. Expand only the
certified positive factors, preserve the residual phase, and apply a replacement
only after its separate native equality certificate passes.
Require a nonempty original domain, real variables, certificates for every
applied replacement, exact zero after Together/Expand, complete comparison
with the accepted own Hgq pole-refinement result, and exact reproduction of
the saved residue by the original input-sum reduction. The existing full
factor-refinement method remains the fallback for any unhandled expression.
No replacement rule or zero residue is supplied by hand.

The original phase, charge, spin, subtraction and branch conventions remain.
Keep all accepted canonical finite checkpoints. The comparison has its own
result directory and cannot accept a final F hat. Production must bind the
complete accepted proof and install its normalization and fallback definitions
exactly before using them. Retain the original per-operation bounds and all
final pole, boundary, reference-hat and finite-export gates. No speedup is
established before the comparison executes.

Native operation documentation:
https://reference.wolfram.com/language/ref/FactorList.html

The unaccepted initial comparison source is retained at
common/s14_result/reference/s14_check_Hgq_root_normalization_before_factor_products.wls,
SHA256 d248580d519f57e2864324e3c2826ab9d8b5568a49775772d39de265a4a07a71.
It supplied no usable root replacements and does not authorize production.

### Accepted S14 root-normalization comparison

Hoffman2 job `14815355` on `n7133` passed all 137 checks in
626.0167889550794 seconds. Both saved negative-branch Delta poles at
`{8,4,1}` vanished exactly after individually certified root replacements.
The unchanged original input reduction reproduced each saved residue exactly;
the earlier accepted nontrivial Hgq residue and original control also passed.
The single-pole normalization recorded 0.23927 seconds, four certified rules,
and zero output. This is a measured residue operation, not a full-stage timing.

Accepted identities under `s14_root_normalization_result/`:

- `s14_result.wl`: `9cf724c955b63837b9b0f114cf42db7d158d70760bc7480a089b3cd9ff3c0ae2`.
- `s14_checks.json`: `ab3d631f4bad5cda06707fd084fd2c1d2b6470b3c9c2bce311754904876ce7f9`.
- `s14_execution.json`: `96e04ad4ff33baf72a2484d815a283ef650076d64652eb40374b566596f8f1c5`.

The executed checker `common/s14_check_Hgq_root_normalization.wls` has SHA256
`9f0bbb17fe7aacfb79279b18339cbe426252120247ce834aa41d856d69afff2c`;
configuration SHA256 is
`459be9bca8c070ea7c557315f09b933af3e861c53509892a0f1d29e0058b9e27`.
Use `common/s14_assemble_finite_Hgq_roots.wls`, SHA256
`4f695976bf5320e47df51bc3d8def722c573d2988be5c3afd412c794068d73c8`,
to install these exact definitions and the unchanged accepted fallback.
Preserve canonical finite checkpoints and require the own complete component
comparison before continuation. The complete S14 and S15 acceptance gates
still determine whether the channel's final F hats have been computed.

### Hgq finite-reference residual contract

common/s14_inspect_Hgq_reference_residual.wls reuses the original reference
residual reader for the positive-branch Delta comparison from job 14815403.
Read only the accepted U/U pole checkpoints, verify each original input and
label, and apply the exact inherited normalization and F1/F2 photon weights.
Use the core reference hats and original soft-domain conditions. The source
retains the accepted S05 frame-release boundary and exact finite precollection.
Save both candidate/reference expressions and their reduced differences in
s14_reference_residual_result/, with readable native residual files and exact
reload checks. These are comparison inputs, not accepted final coefficients.
Complete spin-pole cancellation alone does not pass the finite-reference gate.

### Saved Hgq reference-term comparison

`common/s14_check_Hgq_reference_terms.wls` reads the accepted residual packet
from job 14815618 and the exact current and archived S11 tensors. Reuse the
original S14 normalization definitions and saved photon weights. Verify the
stored finite counterterm change against the actual subtraction difference,
then compare its U/U projection with both saved Delta residuals. Wolfram
FunctionExpand and FullSimplify use the original physical domain. Save the
readable residual, correction and remaining difference with exact native reload
under `s14_reference_terms_result/`. This identifies a possible source of the
comparison failure; it does not modify production or accept finite hats.

### Resolved gluon subtraction comparison contract

Job 14815783 established that both positive-branch Delta reference residuals
equal the S11 dimensional-completion correction exactly. Its saved result is
`s14_reference_terms_result/s14_result.wl`, SHA256
`1b814737476b73a498584caad99d811478ebaef0bcb359038c4bd03d365a1cbd`.
The preceding S11 artifact is preserved under
`s11_result/reference/before_resolved_gluon/`.

`common/s11_check_Hgq_resolved_gluon.wls` identifies the native gg self route,
checks its saved soft and Delta spin identity against the complete dimensional
physical Born response, and retains the original physical spin convolution for
that route. Require every other route unchanged and recover the complete
original convolution tensor exactly. Verify that the full spin counterterm
difference is finite. Reconstruct both U/U hats from their accepted finite
checkpoints and compare every distribution on all branches with the pinned
GitHub hats, retaining the original normalization and physical domains.
Save the candidate, all exact comparison residuals and checkpoint identities
in `s11_resolved_gluon_result/`. Only an executed all-component comparison
can authorize replacing S11 and regenerating dependent finite results.

The external-state convention is described in Catani, Seymour and Trocsanyi,
Phys. Rev. D 55, 6819, Sec. IV B-C:
https://cds.cern.ch/record/313983/files/PhysRevD.55.6819.pdf

### Native gluon intermediate-spin transition contract

`common/s10_gluon_evanescent_transfer.wls` extends the original native gg
vertex calculation with the extra dimensional transverse projector. Retain
the complete S10 physical collinear frame, azimuth integration, lightlike
projection, Pauli/Stokes conventions and reference-derived normalization.
Derive the projector Gram matrices and their duals inside FeynCalc/Wolfram;
keep incoming and outgoing dual contractions explicit. Extract the leading
extra dimensional transitions only after dividing by their native projector
norms. Require the full physical block to reproduce every accepted S10 gg
component, exact Gram reconstruction, evaluated collinear limits, and the
soft limits of the additional transitions. Record the native matrices and
all bindings in `s10_gluon_transfer_result/`; this is an input to a new S11
comparison, not a correction of the production hats by itself.

The native transition calculation passed job `14816541` on `n6106` in
32.232019267976284 seconds. Both complete physical blocks match the original
S10 kernels; the Gram/dual reconstruction, native contraction, azimuthal
integration, collinear limit and exact result reload passed. The additional
physical-to-E PDF and E-to-physical FF transitions have zero soft residue in
the native result. These are leading dual-normalized transitions in the
original physical angular frame, not a replacement for a full dimensional
splitting function or a finite hat.

Files under `s10_gluon_transfer_result/`:

- `s10_result.wl`: `4b32f19586f56b1ccda00968a0acbddc0eea5b1b7068f2ea6a42fc0df5edee13`.
- `s10_checks.json`: `94591f0d91389ba77fbec320ff9aef5b77ec2e4c4d8b603e00170b19cb8748c9`.
- `s10_execution.json`: `b0f367b038313539852445b064e5c00e906ccf668f63b08bce5b9206bb812728`.

Source `common/s10_gluon_evanescent_transfer.wls` has SHA256
`db6777c40194028070e4a0dfbf3af1ef5be01ff0f342ac161434f30ed8e7f766`.

### S11 native-transition convolution contract

`common/s11_convolve_Hgq_gluon_transfer.wls` uses the original S11 frame,
routes, momentum rescalings, Jacobians, convolution and endpoint rules.
Retain the original physical gg route and convolve the actual extended
Born E component with the native PDF transfer row. Derive the endpoint
identity from the saved Gram and dual matrices and require no additional
off-diagonal soft or Delta term. Other routes remain unchanged.

Expand the resulting counterterms with the inherited prefactor and MS pole.
Require the complete change relative to the previous subtraction to be
finite. Compare its projection with every saved reference residual from
job 14816029, binding that comparison's source, inputs, checkpoint hashes,
normalization, photon weights and physical domains. That earlier comparison
failed and is a residual input only; it is not an accepted subtraction.
Require all distributions of F1/F2 on all branches to match before accepting
the candidate in `s11_gluon_transfer_result/`. Preserve canonical production
inputs until this comparison passes and downstream source bindings are updated.


### Incoming gluon crossing comparison contract

The uncrossed native-transition convolution in job `14816682` did not
restore the six Regular reference components; its Delta, L0 and L1
comparisons vanish. Its isolated comparison is not an accepted production
subtraction. Canonical S11 remains unchanged.

`common/s10_crossed_gluon_transfer.wls` applies the initial-state crossing
relation of Signer and Stockinger, arXiv:0807.4424, Eq. (33), to the native
unaveraged gluon response, transposing the crossed spin indices before
applying the intermediate-state Gram dual. Derive the fermion count from
the native vertex and retain the state-count normalization from the native
Gram matrix. Require the original raw tensor and Gram data to match the
accepted uncrossed calculation exactly, and require the complete physical
PDF and FF blocks to match the accepted S10 output. Retain all native frame,
vertex, spin-reconstruction, soft-limit and reload gates. Save under
`s10_crossed_gluon_result/`. This alone cannot accept a finite subtraction;
its convolution must restore every saved finite-reference component.

The crossing calculation passed job `14816791` in 35.84033568203449 seconds.
Its result SHA256 is
`65e1d5a20af6e390db214b5ade6c682190ceaf218585dca1038908ddf389a7df`;
receipt SHA256 is
`6480ae625f81c1b40faa5d1229e03b0cf1ec3210ae2ed7a00ac4259278f02ab4`.
The serialized PDF/FF leading matrices and soft residues equal the preceding
native result exactly. Repeating the identical S11 convolution is unnecessary;
the existing failed comparison still applies to these inputs.

### Full-dimensional unresolved angular average contract

`common/s10_dimensional_gluon_transfer.wls` keeps physical external spin
axes and derives the daughters' projected and full-dimensional scalar
products from the on-shell frame equations. Keep unresolved daughter
momenta in D dimensions, expand momentum sums before assigning dimensions,
and define the complementary projector as the full transverse projector
minus the physical U projector. Require mass shells, parent virtuality,
Gram duality and orthogonality inside the native calculation.

Average the physical transverse fraction with the normalized sphere-splitting
measure whose ranks are obtained from the native Gram matrix. Wolfram must
derive its moments, reproduce the D-2 second moment of hep-ph/9610553
Eq. (30), and reconstruct every angular polynomial exactly. Require the
complete dimensionally spin-summed gg kernel to equal the reference kernel,
the original physical limit and all physical spin components to reproduce
accepted S10, then apply the already checked incoming crossing relation.
Retain full D-dependent matrices as well as leading transitions under
`s10_dimensional_gluon_result/`. This remains a splitting-input comparison,
not an accepted finite subtraction or a final hat.


The full-dimensional native splitting calculation passed job `14816855`
on `n7405` in 33.71734417416155 seconds, including the dimensional angular
second moment, full spin-summed reference kernel and all physical spin blocks.
Accepted files under `s10_dimensional_gluon_result/`:

- Result: `8673c70ab8dca6be2775e70e339c1100829472e27f74a9f8eb1d2e3f13948006`.
- Checks: `a0c7fadc72f816047db187bee42683e98a74bd0bdc60f4a33dfd61600fcab26c`.
- Receipt: `ab74a24ab801fe574e738848eea1714404bd3fe256925cacf81432978367d5ab`.

Accepted source SHA256 is
`113b9968a31eec26914c7018515e9ca214bfbc622b9fe7f5a3b539037aef957d`.
The failed predecessor supplied no accepted splitting output; its preserved
source and receipt belong to `reference/`. The corrected source uses explicit
multiplication in the angular measure and fills native dimensional scalar
products for every frame momentum before polarization sums.

`common/s11_convolve_Hgq_dimensional_gluon.wls` reuses the complete native
transition convolution with only the accepted splitting input, its producer
identity and the result owner changed. Keep all original rescaling, measure,
endpoint, expansion and full spin-finiteness checks. Require every saved
F1/F2 distribution residual on every branch to vanish before accepting the
candidate under `s11_dimensional_gluon_result/`. Canonical production S11
and finite caches remain unchanged until that complete comparison passes.

The leading extra-state convolution in job 14816888 left six Regular
reference residuals; all eighteen endpoint comparisons vanished. It exported
only the comparison and checks, with no accepted subtraction result. The
saved comparison is s11_dimensional_gluon_result/s11_comparison.wl
(SHA256 0c9789b706202e66d927976fbc4c63bb2f49c6009d267565704d182517cb9e02).
Canonical S11 and S14 inputs remain unchanged.

common/s11_check_Hgq_dimensional_operator.wls compares the complete
accepted dimensional PDF operator with the embedded physical leading
operator, including the physical block's regulator terms and its E row.
Derive the difference natively from the saved matrices, reconstruct the
complete operator exactly, and require unchanged leading physical kernels,
zero additional soft residue, finite counterterm difference and every
original finite-reference comparison. The reference is arXiv:0807.4424,
Eqs. (36)-(39); the full dimensional unpolarized gg kernel must have zero
regulator-dependent remainder relative to its accepted leading kernel.
This is a diagnostic of the dimensional operator, not certification of a
finite polarized factorization-scheme conversion. Keep it under
s11_dimensional_operator_result/ and mark AcceptedForProduction -> False.
No production subtraction or final coefficients are replaced by this run.


The full dimensional operator comparison passed job `14816904` in
754.079195 seconds. All 24 F1/F2 distribution comparisons vanish. The
comparison result has SHA256 `faf7a7e3bb591f74c7c9bfe79826b7861a47e060127fff51c77749e18ecc8f21`,
subtraction candidate `304347322fe1cf2d9fafc5125b7de2333fc468abd8d297f8c00abe5bc8ccd01b`,
checks `07999cd38975d077f0e1d4be5aff4c700f7dd5402e802a0db50a40e0a0de4f7b`,
and execution receipt `1e6c11b89d2175a885bc6e2b9e0f5925ebf0efa1a7f87aa702427edfae1c0e65`.
They remain diagnostic inputs under `s11_dimensional_operator_result/`.

`common/s11_finalize_Hgq_subtraction.wls` derives the CDR spin matrix
from those native projector definitions: complete the U projector with E,
apply the S03 incoming state average, and preserve the physical X/Y/H
projectors. Require equality to the accepted physical leading kernel and
full dimensional unpolarized kernel. Remove the native CDR regulator
remainder according to arXiv:0807.4424 Eqs. (36)-(39), embedded in the
physical block of the complete operator. Keep the same convolution,
require a finite counterterm difference and all 24 reference comparisons.
Output belongs to `s11_msbar_result/`. This accepts subtraction only;
componentwise finite assembly and S15 quark axial conversion remain required.


`common/s14_assemble_Hgq_finite_update.wls` consumes the accepted
`s11_msbar_result/` subtraction. Retain the original input-bound Laurent
checkpoints as decomposition inputs, not final coefficients. Derive and
require a regulator-free difference of the actual old/new counterterms.
Require the old own-component output to be reproduced, and compare a
component with nonzero correction against direct assembly with the new
subtraction and a fresh input hash. Only then update all finite components,
retaining every original final-reference comparison and bounded exact reload.
Record every reused checkpoint hash and the comparison timings in S14.

`common/s15_finalize_Hgq_coefficients.wls` preserves the accepted final
exporter and compact writer, binds the new subtraction source and S14
receipt explicitly, and compares its helicity-restoration tensor with the
previously accepted own tensor. The scheme input belongs to
`s15_msbar_scheme_result/`; final hats retain the usual `s15_result/` owner.
No shared production entry point for the other channels is changed.


Completed S07/S08/S09 native outputs below are retained locally; remote
redundant copies were removed after exact size/hash verification and a
check that no active or next-stage input manifest consumes them. Restore
by the recorded identity before repeating these earlier stages:
- Hgq/s07_result/s07_result.wl: 8fac078b7695b9769289fc2f22873a86e26d1a67c35d55240b19950db80ba0c5 (31889772 bytes).
- Hgq/s08_result/s08_result.wl: cbe63dcaf1a601d399e3edf1e7a7d41fe7636ab3a1f9dc933dc4477d03d338aa (31901797 bytes).
- Hgq/s08_targets_result/s08_result.wl: 20759f1682d632d314a1ff379f4451cbfd1a1df452dcfc8fafde3275c0610292 (28889537 bytes).
- Hgq/s09_result/s09_result.wl: 0bb4747ce698189ad4bc7e4b19155e8e61888b75a2f1609beae612f06846a29c (11538052 bytes).
- Hgq/s09_reduction_result/s09_result.wl: b8c9a8e746f32c2bc72c075097157a69edd5f22594574f3b29494e5bd64f9a55 (10970409 bytes).


The MS subtraction passed job 14816971 in 490.43038256908767 seconds.
Every native CDR-kernel, full-spin finite-difference and all 24 reference
comparison gates passed. Accepted artifacts under s11_msbar_result/:
- s11_checks.json: d22c7bd974497539633b43e598c364d4549ccd6428ee65367fc5501b01585b96.
- s11_comparison.wl: 9ffcd88823666079950a25cbe5980233dfac4dfad8dad39d09672265dbdf1ee2.
- s11_execution.json: 546a601107cfb6c2ecaca60c75cc0c141fac64da40b14c4ae1683823ce814ee5.
- s11_result.wl: 121ef3aaffdc3555150172b0dbb0c004175ff2b1994e193cd3d89f3d75e539e3.
Use this accepted subtraction for the Hgq finite-update adapter. The
older canonical subtraction is retained solely for the explicit finite
difference and original checkpoint identity; it is not a final coefficient.


The finite-update adapter qualifies its native integral patterns as
`FeynCalc`GLI` and `FeynCalc`PaVe` before dynamic package initialization.
The pre-correction source is retained at
`common/s14_result/reference/s14_Hgq_finite_update_before_native_context.wls`
(SHA256 d4e520c04d161745552eeae999815ad45ebcfd6c73665b4060debf8d75571770).
Corrected source SHA256 is
1a1a93a147c5a6988f1eed039554949ab03b7cf2423b97408878ef24700d0dca.
No equations, normalization or accepted subtraction inputs change.
Repeat the complete original gates with the explicitly qualified patterns
before accepting the updated finite export; do not accept job14816997.


The final-reference reuse entry may consume the accepted MS comparison
and its original resolved-gluon residual packet instead of repeating the
large regular-expression reduction. Bind every native source, reference,
normalization, photon weight, old finite checkpoint and subtraction identity.
For each comparison, require exact reconstruction of the actual exported
unpolarized coefficient from those checkpoints and the actual finite change.
Derive the projection-update identity natively with independent placeholders,
and require the saved original residual plus the actual MS change to reproduce
the accepted zero residual. Compare the method with the unchanged direct
calculation for an own endpoint before using regular-term reuse. Preserve
all spin-finiteness and pole gates, and save the complete certificate and timings.
No reference result is accepted solely from a successful job or a matching label.


### Accepted finite assembly with reference-comparison reuse

Hoffman2 job `14817067` passed in 1462.6093233153224 seconds. The
original component pole/finiteness checks, all F1/F2 reference distributions,
exact reconstructed coefficients, native projection-update identities and
saved-result reload passed. The reuse method also matched the unchanged
direct own endpoint calculation before it was used for Regular comparisons.
The complete certificates and operation timings are stored in
`ReferenceReuseCertificate` and `FiniteUpdateEvidence` in the native result.

Accepted entry: `common/s14_assemble_Hgq_reference_reuse.wls`, SHA256
`0b6399010d47c35f475cc42993989f00235c6694826f9752925175a2eed74ee3`.
It retains finite-update source
`1a1a93a147c5a6988f1eed039554949ab03b7cf2423b97408878ef24700d0dca`
and accepted MS subtraction job `14816971`. Configuration SHA256:
`d4078c21df442114b55afa34f15dbe6c97d72b9158d91315f1b907b40a655f8f`.

Accepted artifacts under `s14_result/`:

- `s14_result.wl`: `019c130123adcbce8534c7f1b8d6a4fd2f2a7b4fb4c14c9942a556ae577b2ac1`.
- `s14_checks.json`: `5d0d52c64dcd09d2f9f9d4de738078c30c207dd4d6536d438898032abde0c04b`.
- `s14_execution.json`: `5dca5503e4b4559990e5b7534eed4bcc119f4705363e88460d3922a18bb5e1c6`.

The native log is `cache/s14_Hgq_reference_reuse.log` on the recorded
Hoffman2 task root. Consume this result with the reviewed
`common/s15_finalize_Hgq_coefficients.wls`; the final quark axial conversion
and export gates remain required. S14 alone does not mark the final
partonic coefficient workflow complete. The original checkpoints remain
reproducibility inputs for the finite-update certificate.


### Accepted final partonic coefficients

Hoffman2 job `14817104` on `n7005` passed all 52 finalization checks in
682.8625157549977 seconds. The native finite helicity-conversion tensor
matches the previously accepted own tensor; the unpolarized coefficient is
preserved. The complete final response and both F hats passed bounded export
and exact native reload. All files below were transferred and verified by hash.

Final entry: `common/s15_finalize_Hgq_coefficients.wls`, SHA256
`7534b5926208b4cecb79bd85498c11cb6b01012c7bd7401a0d8226452b9531ee`.
Configuration SHA256:
`ac8fe352eb43fb9496990ca495b6a668a216d53e839b5c63b154b27f9406e5cf`.
It consumes the accepted S14 result and dimensional MS subtraction recorded
above; their original source and receipt bindings remain explicit.

Accepted files under `s15_result/`:

- `s15_result.wl`: `bc5a8cd2ec0a0c872f4038f51ad501b1ce823e9f956fb3ade997a5dddc8b3881`.
- `s15_F1_hat.wl`: `f7092f664c9a3c5995aa5d8e185d6e12501df55393baf65df283f8feb414da24`.
- `s15_F2_hat.wl`: `eb7062be857bba1d8154a9c8176cf447ed00837411330a0d6cd52f365afed5b8`.
- `s15_checks.json`: `c70245b2de927266cbe546da9a1c7350a25465a53ad40e4ae82a482efd1cb0bb`.
- `s15_execution.json`: `8905f0ed50fca480a2ee3e51519cf8bffd52b34d1994933730c62f3ec127803a`.

Matching scheme artifact: `s15_msbar_scheme_result/s15_result.wl`, SHA256
`44110a1d905a254cc6033cf7a292ca0d29627988c2bc0d98482c68b211e92383`.
The native log is `cache/s15_Hgq_msbar_reuse_final.log` on the recorded
Hoffman2 task root. Load FeynCalc before `Get`; retain the native result's
photon labels, spin labels, index order, physical frame and branch conditions
when consuming its spin matrices. These are partonic coefficients for the
original large-transverse-momentum SIDIS measurement. Hadronic convolution,
user-selected proton polarization and jet matching remain deferred.

Acceptance covers the native pipeline gates and agreement with the pinned
unpolarized reference. The independent upstream MadGraph sign-comparison
caveat recorded above remains unresolved by this calculation.


### Completed output storage

After final acceptance14817104, the four large S14/S15 outputs below remain
locally available with their original accepted hashes. Their redundant
cluster copies were removed after exact local/remote identity and all job
configuration consumer checks. Restore exact local bytes before rerunning
any completed Hgq consumer. References, checks, receipts and needed caches
remain on Hoffman2.

- Hgq/s14_result/s14_result.wl: 019c130123adcbce8534c7f1b8d6a4fd2f2a7b4fb4c14c9942a556ae577b2ac1 (29869721 bytes).
- Hgq/s15_result/s15_result.wl: bc5a8cd2ec0a0c872f4038f51ad501b1ce823e9f956fb3ade997a5dddc8b3881 (19142741 bytes).
- Hgq/s15_result/s15_F1_hat.wl: f7092f664c9a3c5995aa5d8e185d6e12501df55393baf65df283f8feb414da24 (4047513 bytes).
- Hgq/s15_result/s15_F2_hat.wl: eb7062be857bba1d8154a9c8176cf447ed00837411330a0d6cd52f365afed5b8 (4601361 bytes).


Completed Hgq S05 loader/payloads and S12 result are retained locally with
unchanged accepted receipt/manifest hashes. After final14817104 acceptance
and checking all configured consumers, duplicate remote bytes were removed
to provide scratch space for unfinished channels. Restore the exact local
files to their original paths before any future Hgq recomputation.


The completed S14 native cache under
`cache/s14/Hgq/1445d357bea559d366c4a1ada4a5a2aac0af0a72e62d5810f0727f15dea892f4`
is retained in `s14_cache_archive_result/s14_cache.tar.gz`, SHA256
`35e89ebb4c93e66aa89a2e18c213d1676f951b3a27eb2647e41d0433d0f4dc2d` (5903939 bytes). The manifest
`s14_cache_archive_result/s14_cache_manifest.json`, SHA256
`4cd596666df9651fa43a9da5bfddcac6cb372e038554d41108891ac85185a875`, binds all1728 original
member paths, hashes and sizes. Every archive member was independently
verified locally before its duplicate remote cache file was removed;
107895585 original bytes are preserved by that archive. Final14817104
and its delivered coefficients are unchanged. Before any S14 resume, verify
the archive hash, restore its members at the manifest paths relative to the
recorded task root, and verify every original member hash.


### Independent reference-sign comparison contract

`common/s16_check_Hgq_reference_sign.wls` resumes the unfinished direct
real-amplitude comparison using the original `scalarPair` definition from
Hgq_v4 S03 without algebraic changes. Inputs, the existing MadGraph point,
normalization and original first-pair checkpoint are copied unchanged under
`s16_result/reference/` and bound by `common/s16_Hgq_reference_sign_inputs.json`.
Derive invariants from the saved four-vectors; check all original scalar
products against those vectors before using the original invariant table.
The first pair must exactly reproduce its own accepted saved value at that
point. Derive the complete pair inventory from the generated amplitudes,
retain the original interference and normalization operations, and use
independent pair workers with bounded native checkpoints. Report the total
against both the stored contraction and existing MadGraph projection.
A completed comparison report does not itself mean agreement, and does not
change the sign or acceptance of any production coefficient. Any discrepancy
located upstream requires correction at that originating stage before
dependent results can be accepted without the caveat.

The independent S16 reader converts each coordinate inside the JSON momentum
association explicitly with native Rationalize, then requires the absence
of machine reals before calling the unchanged symbolic pair routine. The
initial run's symbolic Dirac isolation failed on machine-real zero; it
produced no comparison or accepted pair. That input-interface correction
does not establish any production-sign error or resolve the MadGraph caveat.

The native S16 contractions from job14818476 exactly reproduce the original
first pair and complete Ppp at real_01. They are retained under
`s16_result/native_contractions_14818476/`; their scaled report is superseded
because combining its machine-real normalization with large exact rational
coefficients produced a spurious zero. The S16 entry now exactifies each
normalization value before the final numerical evaluation. Its preserved
ExactTotal and PairRecords remain valid independent of that reporting issue.

### Corrected independent color-dimension comparison contract

`common/s17_check_Hgq_color_dimension.wls` corrects the independent comparison
reader's substitution of a signed UFO representation label for SUNN. The
original metadata labels the quark representation with a negative integer;
UFO uses signed labels to distinguish representations from conjugates
(https://link.springer.com/article/10.1140/epjc/s10052-023-11780-9). Derive
the positive SUNN solution from FeynCalc fundamental/adjoint traces and
both absolute model color dimensions. Retain the original amplitudes,
contractions, sample points, normalization and measured MadGraph results.
At every original point, first reproduce the old comparison with its old
signed substitution, then evaluate both projectors and lepton-setting
averages with the tool-derived positive dimension. Require all original
comparison tolerances, and separately match the saved exact S16 total to
the corresponding corrected stored contraction and MadGraph projector.
The corrected reader, not a sign adjustment of any hard coefficient, is
the originating comparison-interface fix. It accepts no new polarized
spin information and leaves the channel's native F hats unchanged.


### Independent Hgq sign caveat resolved

The old MadGraph comparison's real-emission sign discrepancy is resolved by
Hoffman2 job `14818632`, completed in 27.396610748 seconds. Its S04-style
reader substituted the signed UFO antitriplet label `-3` for SUNN. Native
FeynCalc fundamental/adjoint traces and the model dimensions instead derive
the positive color dimension `3`. Reproducing every old comparison with the
old substitution establishes the originating reader error. The corrected
reader passes all 32 Born/real Pg/Ppp comparisons at all 16 original points
and all lepton-setting azimuth averages, with maximum relative difference
6.285644251393455e-13. No native contraction, subtraction term, F hat or
production sign was changed. Earlier references in this ledger to the
unresolved independent sign caveat are superseded by this executed result.

The independently re-evaluated 36-pair exact S16 contraction at real_01 also
agrees: fresh and corrected stored Ppp are 3.8827647146051354100e-7;
MadGraph gives 3.882764714605064e-7 (relative difference
1.840657628718811e-14). The saved S16 scaled report's spurious zero is
superseded; its exact contractions were reused without recalculation.
This resolves this unpolarized tree comparison caveat; it does not claim
independent MadGraph validation of all polarized NLO components.

Accepted `s17_result/` identities:

- Source `common/s17_check_Hgq_color_dimension.wls`: `143924c807c54680b3cb20c80dad3d43872cc91635a5e72a226567d4210910bf`.
- `s17_result.wl`: `b34a3e570e9aa84e19e9d5e1948c3d0d5989ea2d7ad26f20973783083eac2a01`.
- `s17_checks.json`: `cb6f5d0ff6014755fafd06fbd00c70455fc3b4b6efe295fd7b2d72df2ae3192e`.
- `s17_execution.json`: `0af7e6fa26b17fdf640311e99c7132d5068f2ce38165a2b8f65b9d57b30acaeb`.
- Configuration: `69e0b9922de83eaa522c79173c64d385aa4f88448d58348a0805c2fef726e9ed`.

The previously accepted S14/S15 unpolarized-reference and pole checks remain
applicable, with final S15 artifacts unchanged.


### Completed S12 cache retention

The completed S12 cache for final job14817104 is retained in
s12_cache_archive_result/s12_cache.tar.gz, SHA256 3bf1d887d26a2904e47fd1819dff78d7f6e2be314a433b19e60a7a7afb58eed8.
The accompanying s12_cache_manifest.json records every original relative
path, byte count and SHA256. All members were checked against the archive
before removing 25753814 duplicate bytes from remote scratch.
Restore the exact paths and verify member hashes before any future S12
resume. Final S14/S15 coefficients and accepted receipts are unchanged.
