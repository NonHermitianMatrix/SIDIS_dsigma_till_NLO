# Hqqbar: incoming quark, tagged same-flavor antiquark

The incoming quark has momentum `p`; the tagged antiquark has momentum
`k1`. Keep the identical spectator-quark counting and fixed-flavor charge
convention. The antiquark spinor and spin-projector signs must be
established in the chosen basis.

## S01 inputs

`s01_prepare_inputs.py` uses the shared S01 implementation.
`s01_result/` owns the receipt for selected open-amplitude inputs.
Spin-summed references cannot supply the spin-dependent contraction.

## Spin-dependent contract

Retain the incoming-quark and tagged-antiquark spin indices. Derive allowed
components and the required subtraction routes rather than assigning
them from the same-flavor quark channel.

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

Use the common independent spin-check dispatch only after its full
Hqqprime accepted-output comparison passes. It preserves this channel's
native exact reconstruction predicates and checkpoints each input-bound
photon component. Keep all original CDR, Ward and saved-file reload gates.

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

`gq` passed job `14775309` on `n7121`;
`s03_result/gq/s03_result.wl` has SHA256
`9cb6b437c7c7c316ce83e1b9eef1b1c66d8c8329d59074b3065e01718631ee69`.
`qg` passed job `14775310` on `n7126`;
`s03_result/qg/s03_result.wl` has SHA256
`7ddf294ee5969ff4177017020fab1f8b516bbc8d208c0fa38f81d919e46f97c7`.
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

Job `14775340` on `n6129` accepted `common/s11_small_collinear_spin.wls`.
`s11_result/s11_result.wl` has SHA256
`f0e94377e39f080cda5b6652093b956b4164dd8fcd9ec25b58b2a803d1cf04d4`.
Its checks and execution receipt are saved alongside the result. The full
original scalar comparisons and all stage acceptance gates passed. This
result remains an input to complete NLO assembly, not a finite NLO hat.

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

The S15 finite scheme tensor passed Hoffman2 job `14775517`.
`s15_scheme_result/s15_result.wl` has SHA256
`b8576684d857a559c2f3d09a04f8ee333689ac991e90608d62d155473eb755c7`. All normalization, helicity-index,
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

The complete real tensor was accepted by Hoffman2 job 14779758. The final
spin reconstruction, photon Ward and Hermiticity checks, both original CDR
projectors, and compressed save/reload all passed. Source SHA256 is
58f6a7959d651ec0e1d4e1738f24248c1460f817953deda33a55b4b12333183f.
Hqqbar/s05_result/s05_result.wl has SHA256
c571de817144f84801193dff3829a6b22700f3575b5be0edf3ea2bf4b0dffc6d,
and its checks and execution receipt are alongside it. S08 consumes the
complete spin tensor; no finite NLO coefficient is asserted by S05.

S05 projection resumes may set `POLARIZED_SIDIS_REAL_SECONDS` explicitly
(the default is 2400 seconds, with a checked maximum of 10800 seconds).
This changes only the native time bound. The 2 GiB operation limit and
4 GiB spin-reconstruction limit, all contractions, checks, and checkpoint
identities remain unchanged. The scheduler and process-tree limits must
cover the selected bound. Preserve the preceding source in
`common/s05_result/reference/s05_real_spin_response_before_projection_time_resume.wls`.

## Completed-stage cache archives

The completed S05 per-diagram cache is preserved in
`s05_result/s05_cache.tar.gz`, SHA256
`2a8445b8fdc221731d19154c9ecdd4459f024c37d7f680785405a2d41235bd24`.
The accompanying `s05_result/s05_cache_manifest.json` binds every member
to its original byte count and SHA256 and records accepted producer job
`14779758`. Every member was read back and hash-verified
before the uncompressed completed cache was removed.

The archives and manifests are retained locally. Remote duplicate archives
were removed only after the local and remote SHA256 and byte counts matched;
the remote manifests and accepted stage results remain available. Current
consumers read those accepted results. To resume an archived producer, transfer
the archive back with a SHA256 check, then restore its members relative to
the polarized_SIDIS root at the manifest paths and verify every member.

## S08 equation inspection contract

`../common/s08_inspect_mapping_equations.wls` reads the actual first two
components whose complete raw mapping exceeded the native time bound.
It uses the unchanged mapper initialization and atom-extraction routine to
measure the complete denominator and each saved additive term's denominator.
The program groups equal generated propagator-power vectors and requires
exact reconstruction of each original input before saving the equations,
operation timings, expression sizes and memory measurements in
`s08_equation_result/`. This is an input inspection, not an accepted map.
Any changed mapping algorithm still requires exact reconstruction and an
executed comparison with the accepted complete reference control map.

The inspection passed Hoffman2 job `14791106` on `n7127` in 163.687 seconds,
with 1593352192 bytes peak observed RSS. Its result
`s08_equation_result/s08_result.wl` has SHA256
`1b22fb16c047be46bd56fa9988873eb4c0e8cd526bd939ca8a5ec3e93d5c6a64`;
checks and its matching receipt accompany it. The source hash is
`82d722a3fc2c9440b8dd46b13369c90f7c3faee895138d00e76502ad791cf726`.
The native inspection found 34 denominator groups for component 1 and 14
for component 2, with exact reconstruction of each saved input. Complete
denominator extraction took 8.213 and 8.372 seconds respectively.

`../common/s08_grouped_mapping_check.wls` applies the unchanged reference
mapper separately to these native denominator groups, merges its outputs
with the unchanged reference routine and reconstructs the complete input.
Every group has an input-bound checkpoint. Before accepting either inspected
component, compare the complete mapped rational expression with the accepted
Hqqprime control map, keeping the measured propagators and both physical cut
powers unchanged. Different exact partial-fraction representations may have
different raw target coefficients; record raw-map identity separately from
exact reconstructed-map equality. Complete target coverage and subsequent
Kira/master gates remain mandatory. The comparison results belong to
`s08_grouped_result/`; no production mapping change is accepted before this
executed comparison passes.

The grouped comparison passed Hoffman2 job `14792045` on `n6047`.
`s08_grouped_result/s08_result.wl` has SHA256
`fc69dbab36b65068fde2e89a25ae05a4ac4f166a84bdf03dfde712a93aa66ed0`;
its checks and execution receipt accompany it. The two inspected components
passed complete reconstruction in 597.683 and 980.065 seconds, after their
original whole-expression mapping exceeded 10800 seconds each. The accepted
control's reconstructed expressions agree exactly; their raw coefficient
lists differ because the partial-fraction representation differs. Peak
observed process-tree RSS was 1501401088 bytes. This accepts the grouped
mapping algorithm and those two components, not the complete channel map.

`../common/s08_map_grouped_real_targets.wls` is the production continuation.
It loads the exact grouping definitions from that accepted result, verifies
the unchanged reference mapper and all physical inputs, and reuses the two
accepted components with explicit proof provenance. Every other component
retains the same complete reconstruction and cut-power gates. Independent
components have separate checkpoints under `cache/s08_grouped_targets/`;
individual group maps retain their comparison-bound checkpoints under
`cache/s08_grouped_check/`. The complete output retains the existing
`polarized-sidis-real-target-map-v1` schema and base physical mapping hash.
The reduction reader recognizes this explicit source alongside the original
mapper. The original reduction source is preserved in
`common/s08_result/reference/s08_extend_real_reduction_before_grouped_source.wls`.
Kira coverage, master integration, pole cancellation and finite export are
unchanged downstream requirements.

`../common/s08_inspect_grouping_equation.wls` isolates the native operation
inside denominator grouping for component 4, which reached its allocation
bound. It must load the exact accepted grouping definition, retain every
equation and check while inserting timers, and save the actual operation
input, complete component, measured propagators, native timing and exact
file reload in `s08_group_equation_result/`. It does not replace the grouped
mapper or change any accepted component. A changed grouping algorithm must
reconstruct this captured input and match the accepted grouping outputs
before production use.

The grouping inspection passed job `14795652` on `n7404`; its result
`s08_group_equation_result/s08_result.wl` has SHA256
`bb7fd3bbbad24b69ac0dc7ce5cc6a4182044a24ff81cc39876d3a726f32ecfdb`.
All 36 term extractions and native grouping finished; the final exact
reconstruction test on a 17,008,896-byte expression exceeded 180 seconds.
The original production operation had reached its 4 GiB allocation bound.
The saved artifact retains that exact expression and every timing.

`../common/s08_check_group_reconstruction.wls` tests an exact certificate
for that same reconstruction. Each original term must reconstruct from
the unchanged atom extractor; native code must prove complete disjoint
group membership, each complete numerator sum, the formal linear identity
and its substitution into every actual term and group. The grouped outputs
must match both accepted controls exactly and reproduce the captured
failing reconstruction expression. All grouping equations remain unchanged.
This comparison writes `s08_group_certificate_result/`; production use
requires every comparison and saved-file gate to pass first.


The grouping certificate passed Hoffman2 job `14795689` on `n7408`.
`s08_group_certificate_result/s08_result.wl` has SHA256
`b0f6a49846b8b7f770f30ea48bc8d9aa6b4733234eed70d2ac08ed489264be5a`;
its matching checks and execution receipt accompany it. Source SHA256 is
`e30c5c7ee3e756605af6e3594e44ae9afe67b32e652ef7359fee504efeafb412`.
The complete grouping and exact certificate took 8.8404 seconds for the
captured component 4. Both own accepted grouping outputs matched exactly;
the captured reconstruction expression was also identical. This accepts
the grouping certificate, not a complete cut map or finite coefficient.

`../common/s08_map_certified_group_targets.wls` loads those exact executed
definitions after checking the original grouping definitions, physical
inputs, native versions and own control identities. The reference atom
extractor, group mapper, merging and complete-map reconstruction remain
unchanged. It preserves the original grouped calculation/checkpoint hash
because every grouped expression and mapping operation is unchanged; it
records its actual new source hash and the certificate hash separately.
The source `s08_map_grouped_real_targets.wls` remains immutable for both
checkpoint provenance and any active producer. The reduction reader must
recognize the new source explicitly. All downstream coverage, master,
pole-cancellation and finite-export gates remain required.

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

## S08 mapping-operation inspection

`common/s08_inspect_group_map.wls` reads the accepted certified grouping
and the actual first groups of components 25 and 26 whose reference mapping
exceeded 10800 seconds. Instrument the unchanged mapping expressions with
120-second operation limits, save the actual bounded-operation inputs, and
require exact recovery of the original source after removing instrumentation.
The isolated `s08_map_equation_result/` is an equation/timing artifact, not
a target map. It must leave production maps and checkpoints untouched.

Inspection job `14797411` rejected its extracted block at the native syntax
check, before mapping either input. The initial source and receipt are preserved
as `common/s08_result/reference/s08_inspect_group_map_before_definition_anchor.wls`
and `s08_map_equation_result/s08_definition_anchor_execution.json`. The corrected
reader anchors to the complete function definition, checks both boundaries are
unique and validates the original block before instrumenting it. Production
source and all accepted mathematical outputs remain unchanged.

## S08 family-polynomial comparison contract

`common/s08_check_family_polynomials.wls` consumes the accepted operation
inspection and its exact captured coordinate inputs. Replace only family
collection: expand the numerator in the integration variables, retain the
outer monomial denominator, and use native polynomial coefficients. Require
exact denominator and polynomial reconstruction and zero residual coefficients
after the unchanged coefficient factoring. The original partial fractions,
family selection, complete-map reconstruction and cut powers remain required.
Compare the entire accepted reference control map and reconstruct both actual
captured inputs before accepting this function. Record the original and changed
definitions, exact input hashes, native versions and timings in
`s08_family_polynomial_result/`. No production change precedes these gates.

The corrected operation inspection passed job `14797427` in 805.023 seconds.
Both first groups (components `{8,1,4}` and `{8,4,1}`) reconstructed and
reached the family-coordinate `Together` operation, which exceeded the
120-second inspection bound on 36,624,008 and 36,971,752-byte inputs.
The exact captured inputs and source are saved in
`s08_map_equation_result/s08_result.wl`, SHA256
`dcf9d1fc3a41b1a9a1ca08d799f8fc61a3966a4a661f13180829390592026ddf`.
Checks SHA256 is `554616e44dcf64d65187b032af9c26607a85fa5be3dd72b2ee98677774386b77`;
receipt SHA256 is `94397b421e56c604d134019756b919106c5fa6bd5b68d32e96f77a7d9e072318`.
All are hash-verified locally. The source SHA256 is
`3fe02e959b09fe512ca70fe829670d8500d08c7d7b6cfa7e037a6bada0064ae1`.
This accepts the operation inspection only, not the unfinished maps.

The initial family-polynomial comparison `14797587` exited at the source
syntax guard before loading inputs or evaluating a coefficient. A missing
closing bracket in the control-inventory gate was corrected; the entire
source passed lexical delimiter inspection. The original source and receipt
are retained as `common/s08_result/reference/s08_check_family_polynomials_before_syntax_correction.wls`
and `s08_family_polynomial_result/s08_syntax_execution.json`. Native syntax,
all input bindings and every mathematical comparison remain execution gates.

Comparison `14797638` reached the first polynomial-collection reconstruction
gate and rejected structural zero equality; no changed algorithm was accepted.
Its source and receipt remain under
`common/s08_result/reference/s08_check_family_polynomials_before_coefficient_identity.wls`
and `s08_family_polynomial_result/s08_structural_identity_execution.json`.
The continuation evaluates the actual residual coefficient by coefficient with
the unchanged reference `zero` function, prints a bounded residual sample, and
requires every exact rational residual to vanish. A structural mismatch alone
is not treated as proof of equivalence or inequality; all comparisons and
actual-input reconstruction gates remain mandatory.


Family-polynomial comparison `14797691` passed the complete reference control
but did not finish the actual component-25 family input before its inactivity
limit (1045.728 seconds total; peak observed RSS 5351870464 bytes). It exported
no accepted polynomial algorithm. Its receipt is retained in
`s08_family_polynomial_result/s08_execution.json`, SHA256
`1648ac47d4b90a31b16d56c6382bf9176a6642e0461c0713e572c331509e7f26`.
The production mapper and accepted target checkpoints remain unchanged.

## S08 reference diagram-pair continuation contract

`common/s08_check_quark_pair_mapping.wls` reuses the executed Hgq pair mapper's
spin extraction, original reference mapping, coefficient merging and complete
reconstruction, with Hqqbar's certified grouped initialization and actual
quark/antiquark spin inventory. It first reproduces the own accepted complete
component-1 map, then maps components 25 through 29 from the archived S05 pairs.
`common/s08_quark_pair_mapping_inputs.json` pins the actual 36-pair input set;
the obsolete one-pair cache in the same archive is excluded. Native checks must
match every pair to the accepted S05 input hash and ordered diagram inventory,
reconstruct each full tensor component, preserve both physical cuts, and check
the merged map exactly. Results in `s08_pair_mapping_result/` retain source,
configuration, pair, control and native-version identities. These results only
become production assembly inputs after the executed checks and native reload
pass. Reuse the existing 24 accepted grouped components with their unchanged
input identities; complete reduction, integration and finite assembly remain
required for final hats.


`common/s08_assemble_quark_pair_targets.wls` accepts only the successful pair
comparison receipt and its exact source/configuration/input identities. It
combines those fully checked components with the existing grouped checkpoints,
checks every task and reduction-coverage record, and uses the unchanged grouped
export block. It records the actual assembly source and all reused component
hashes. `common/s08_extend_pair_reduction.wls` only registers this new assembly
source in the immutable reduction reader and records its own DispatchSourceHash;
the SourceHash continues to identify the unchanged mathematical reduction
program. The Kira configuration, reader, original-rule comparisons, cut support
and complete coverage checks are untouched. Downstream master-coefficient,
integration and finite-assembly programs retain their existing interfaces.


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

The corrected S11 production run passed job `14798561` in 50.848 seconds.
Current result SHA256 is `0e45b5224df19ee88700b50fc163fdfb5fdceea192ffb42ccfae340bcb86c43e`.
Checks SHA256 is `3a923d48c9612b6d54c978565f6d042f7b5ebadf05910d84a9e68e7f7866e228`;
receipt SHA256 is `083eedf0a7b215cc057df9b4372b704c2fd63c8a37e5eab2a850ddd3c317b965`.
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

## S08 pair-merge reconstruction comparison

`common/s08_check_pair_merge_linearity.wls` reads the current accepted pair
maps and reuses the original reference merge separately for each integral
key. Every map must match the exact original spin-pair binding and retain
its executed reconstruction checks. Require native per-key equality to the
complete coefficient sum, an exact formal linearity identity, specialization
to every actual map term, and the original complete spin-pair sum check.
Compare the entire accepted own-channel component-1 pair map before the
last selected component. Keep both physical cut powers and record all input
hashes, original definitions, timings and exact native output reload.
The isolated comparison owns `s08_pair_merge_result/` and its own coefficient
cache. It must not write the active pair or canonical target caches.
Production adoption requires the executed comparison and reconstruction gates.

## S08 complete pair-map export from verified components

`common/s08_complete_pair_mapping.wls` may combine the accepted pair-merge
comparison with original input-bound component checkpoints. Require the
comparison's successful receipt, exact source/configuration/native identities,
every executed coefficient and formal reconstruction check, and exact equality
of its complete own-channel control with the original control checkpoint.
Every reused checkpoint must match its file hash, task, original study hash,
physical input hash, cut powers and complete reconstruction checks. Require
exact coverage of the original selected component inventory. Reuse the original
pair-result schema and mathematical source identity, recording the actual
completion source, comparison and reused-file identities separately. Publish
only after the previous writer has exited. The unchanged raw-map assembler
then retains its existing receipt, reduction-coverage and downstream gates.

The comparison job `14801738` was amended while pending to one shared slot
with 8 GiB memory, using its unchanged serial coefficient path. The exact
scheduler amendment is retained in
`../.cluster/s08_result/s08_Hqqbar_merge_allocation_adjustment.json`.
Its actual worker count is derived from `NSLOTS`, not the original submission
record. The original pair run's final native failure was the complete mapped
reconstruction of component 29; all selected individual pair maps and its
coefficient merge had completed. Those maps remain bound comparison inputs.

The complete pair-merge comparison passed job `14801738` on `n1161` in
147.702460 seconds. Both selected components passed the complete original
spin-pair sum, each original coefficient merge and exact sum reconstruction,
native formal linearity with specialization to every actual map term, both
physical cut powers, and exact saved-output reload. The complete component-1
coefficient map matched its own original accepted control exactly. Component
29 passed all 156 integral-key coefficient sums. This accepts its reconstruction, not
an integrated or finite channel result.

The verified local result `s08_pair_merge_result/s08_result.wl` has SHA256
`f676c6065b84fb77b0f80c23bfd22ea2063b32506e99517eb6c356831b992a7e`;
checks SHA256 is
`2d78bacbe4bfe1414006d5fd2b46da6d3cee4bb19a7a9f0d7bcee77cf52272d2`;
receipt SHA256 is
`ece33f7a31040bdcb8b942ce1a6d004ae239e1b75619096ff251e5305ed6f636`.
Its source SHA256 is
`531822a5be4cf830202ca16a9cfaae1d8d7fd9b53c429cc901867da421c58f72`.
The completion consumer must bind these artifacts and preserve the original
component checkpoints named in `common/s08_pair_completion_inputs.json`.

The complete selected pair-map export passed job `14801966` on `n6441`
in 105.208295 seconds. Its result `s08_pair_mapping_result/s08_result.wl`
has SHA256 `1c7004443aa51acb542d42d826626356db46b9180089bd7079cc3908b3dc86b1`;
checks SHA256 is `8bbce5a529b65c3f40ecafc47227c138e87d27da591b2b256c6c766caec4cafc`;
receipt SHA256 is `73836532ef2a9f783fd449b0d84d0ec60bc9b638c43ae0c4764ff814c7266bc5`.
All three are verified locally. The actual completion source is
`common/s08_complete_pair_mapping.wls`, SHA256
`fc8132ea505476932c1574a53f91194a9638a1082c77d51e23c8ca81b3831887`.
The result separately retains the original mathematical source, the accepted
merge comparison and each original component file identity. The original
raw-map assembler consumes this complete result through its unchanged schema.

Raw-target job `14801986` accepted every one of the 29 components and
232 distinct targets. The native raw map `s08_targets_result/s08_result.wl`
has SHA256 `123b64a63dfb5cdcd0d4817af74809ce31658e7b3d1a32d662253accbd41e96a`;
its execution receipt has SHA256
`86b3003cade6ed53d4ee3f9880a87625647950cc1a2b857d9a09f698d4dc7c6e`.
The unchanged reduction extension then passed in job `14801995`, covering
all 13 additional targets with no missing target. The resulting library
contains 328 targets and eight masters. Its native reduction
`s08_reduction_result/s08_reduction.wl` has SHA256
`94a4257b2030b1208221faefdf74db47435e086706d2797335ede0354c4a5d7a`;
the matching receipt has SHA256
`daeeb101ac4535f54ad7ca39c3a3e2d1f3050f6612ee0bb433bcc6a5db5b2524`.
All native results, check files and receipts are verified locally. Consumers
must bind these actual outputs before coefficient assembly. These maps and
reductions do not constitute finite F hats; S12, S14 and S15 gates remain
required.

Coefficient job `14802031` passed the complete 29-component scalar map,
all master-coefficient reconstruction checks, complete reduction coverage,
and exact native reload. The accepted `s08_result/s08_result.wl` has SHA256
`98ec141e8b923b0856062287ec44daff6a620152edcd42ff5a0d2b9c1086eee7`;
its checks have SHA256
`780b44bce44f46e5ff8a1e4401ed7c7b6d292693f55c49bc0a2b77cbda904ed1`;
the execution receipt has SHA256
`7152eb4cb0860369a890a33bea33f40f7e44a4f89f34c7ed8ce750beee06e964`.
The unchanged streamed source is
`f65fbeee3345dcf281e60192a7e6ea4dfd08eb547f4aa7fb225134462e1ed601`.
All three artifacts are verified locally. S12 must consume this exact map;
phase-space integration and final S14/S15 acceptance are still required.

## S12 reference rational-series comparison

`common/s12_check_rational_master_product.wls` reads the accepted scalar
coefficients and original master functions. Reuse only the standalone
reference's exact `rationalSeries` definition, with the regulator symbol
converted explicitly. Derive each coefficient's numerator, denominator and
Laurent orders with native tools, and require the truncated denominator-times-
series identity. Preserve the complete master polynomial and check its native
reconstruction. Compare the complete ordinary contribution of an accepted own
Hqqbar component, then measure the first unfinished component. Use a separate
`s12_rational_series_result/` output; retain source/input/control hashes, native
definitions, timings and exact reload. Do not change the running integrator or
its endpoint, subtraction and finite-export gates before this comparison passes.

Rational comparison `14802580` passed the input, native master-depth and first
rational numerator checks, then rejected a polynomial-product equality check
whose Laurent iterator had infinite bounds for a zero-degree inventory. It
exported no accepted result and changed no production equation. Its source
`f04001b8a0d7f42e3823d598ddd66eedd38d1f7d74881748daa691e3c428cec7`
is preserved as
`common/s12_result/reference/s12_check_rational_master_product_before_zero_identity.wls`;
its receipt is `s12_rational_series_result/s12_iterator_execution.json`.
The corrected comparison uses the existing exact rational-zero predicate for
the entire polynomial product and complete own-control difference, and checks
the zero case before iterating rational numerator powers. All master remainder,
input identity, reconstruction and output gates remain mandatory.

## S12 production with verified rational master products

`common/s12_assemble_real_rational.wls` retains the original S12 initialization,
physical input hash, completed component checkpoints, endpoint distributions
and export schema. It may install the rational-product definitions only from
the successful own-channel comparison, with exact receipt, source, configuration,
input and native-version bindings. Preserve native master-remainder coverage
and every per-coefficient reconstruction check. The tested ordinary component
may be reused only for the identical input-bound task; all endpoint terms are
still evaluated by the original code. Distribute the exact accepted definitions
to the allocated workers and record the adapter and proof identities. The prior
S12 writer and native workers must exit before this adapter owns the output.
Final S14 cancellation and S15 export remain required.

The rational-product comparison passed job `14802611` on `n7122` in
338.258799 seconds. The complete own control matched in 3.063649 seconds;
the full ordinary contribution of unfinished component 13 took 263.608841
seconds. All native master-depth, rational numerator, full product, original
endpoint-definition and exact reload checks passed. The verified local proof
`s12_rational_series_result/s12_result.wl` has SHA256
`0724c147d2349bd44183ecb90936a56d1c7790f7ebd6dade58459cd0c1f8373a`;
checks SHA256 is `015b2a9326533264f20c5eb86dde660262a8547d39443e25ebc4893200fe1051`;
receipt SHA256 is `406139892f2afcce55da23b0c374078dcc99e52d38166406fa06c7cdc2346874`.
The accepted comparison source is
`e6dabfbb04a9b68c9f5019ee1bc7c82a3f250b31f1c0d8975996c70303f31583`;
the reviewed production adapter is
`25de9eb8201f602b83e3e6757adc8adf88c58e3583e01f5dfb1a9188ff836f6f`.
This accepts the ordinary-product algorithm and tested contribution; complete
S12 distributions and S14/S15 finite hats still require their own gates.

## S12 recoil-valuation failure capture

`common/s12_capture_recoil_valuation.wls` reproduces the original `softRows`
valuation on the actual first failed component, using the same accepted scalar
map, transverse substitution, branch assumptions and master pieces. Retain the
exact original valuation equations and stop before subsequent endpoint algebra.
Save the coefficient, branch-substituted rational expression, native returned
valuation, master, piece and exact input identities in
`s12_recoil_valuation_result/`, together with readable equations and exact reload
checks. This isolated diagnostic must not write the live S12 cache or accept
endpoint terms, a complete integration stage, or finite hats. A production
correction requires its own executed equivalence and existing-output checks.

The diagnostic passed job `14804419` on `n7404` in 630.109319 seconds.
For component 14, master `CutIntegral["R01",{1,1,1,1}]`, branch 1,
the original limit returned `ConditionalExpression[1, Element[D | eq^2, Reals]]`.
The strict integer predicate rejected this conditional result. This diagnostic
does not authorize removing that condition or changing the branch assumptions.
The verified native capture has SHA256
`52e449e2ae0bded08bf31d7b0ef80bdf68a53ea1b953c1a5af4d247df0c1c9be`;
its readable equations have SHA256
`8a61c4bc1e102c09faffbafa1d7920e7d446e215a95cfb17f060054f767fc9ce`.
The failed production receipt is preserved in
`s12_recoil_valuation_result/s12_production_failure.json`.

## S12 exact recoil-factorization comparison

`common/s12_check_recoil_factorization.wls` uses native `Factor` and `Together`
on the actual coefficient and its logarithmic derivative before the unchanged
recoil limit. Require exact coefficient and derivative reconstruction without
new assumptions, and an unconditional integer from the original limit and
branch assumptions. Compare that value with the saved diagnostic on its stated
domain. Retain the original leading endpoint, master regions, Laurent products,
distribution assembly and component acceptance checks. Use the already accepted
rational ordinary-product definitions. Recalculate complete components 1 and 15
and require exact agreement with their own accepted ordinary and branch outputs;
then calculate the two unfinished components 14 and 16. Keep all candidate
checkpoints under a separate source/input-bound cache. Save definitions, input
and control identities, measurements, complete candidate components and exact
reload checks in `s12_recoil_factorization_result/`. No canonical S12 output
or final F hat is accepted by this comparison alone.

## S12 completion from accepted recoil components

`common/s12_complete_recoil_factorization.wls` may run only after the exact
recoil comparison passes. Bind its receipt, source, configuration, original
definitions, native versions and complete physical input identities. Reuse
only the configured target components with identical native task hashes and
all component checks passed. Save each target with exact native reload into
the original cache, preserving the accepted component schema and input hash;
an existing target must be identical. Run the original rational adapter's
complete assembly and export gates, recording the completion source and
comparison identities separately. The accepted controls and other original
component files remain unchanged. S14 and S15 remain the finite-result gates.

The recoil comparison passed job `14804751` on `n7439` in
1865.467207 seconds. Both complete own controls (1 and 15) matched their
accepted ordinary, soft and distribution coefficients on both branches.
The complete remaining components 14 and 16 passed the original integration
checks with exact coefficient and derivative reconstruction. All original
master, series and assembly definitions were retained, and native reload
passed. The captured failing valuation took 1.857649 seconds with the
validated preprocessing; its original diagnostic took 565.58601 seconds.
This timing comparison concerns that captured valuation only.

The verified local proof `s12_recoil_factorization_result/s12_result.wl`
has SHA256 `611d710798d44896a8e313afaf5ac1020bad6a4395b21d0b194dcf75b6060d2b`;
checks SHA256 is `22c91863a57fe65e2151221f7ba27c4dbfae2844cabdd1156faba731b2729937`;
receipt SHA256 is `edb6f61db567f7d04cdc6475026eec2bd068843268b1809321948eb1514e36ff`.
The comparison source SHA256 is
`348e2c990209688c52ab4695100303fc6da3ad11beaa1bda9135ee53c022ece7`;
input configuration SHA256 is
`cb4ca0cb9afb77d331b17ca9400249a11070f2f06489500791d94b5eba2b9274`.
Its native log is `cache/s12_Hqqbar_recoil_factorization_native.log`.
The source/input-bound cache location and component identities are retained
in the proof's `Cache` and `ComponentHashes` fields. The reviewed completion
consumer has SHA256
`9b9b034d1f9e64f3fc4accdfd0965d20c85d427296ddc0c4ad61d9015ede1222`.
Both entry points initialize FeynCalc once before parsing the inherited
definitions and suppress the nested duplicate package load. The initial
initialization-only job `14804709` produced no calculation result.

## Accepted complete S12 real distributions

Job `14805132` on `n7439` passed the complete 29-component real integration
and every component acceptance check in 73.072332 seconds. It retained all
original accepted component files and installed the two exact accepted recoil
components with native reload checks. The verified local aggregate
`s12_result/s12_result.wl` has SHA256
`43efba252efd016462992ac17c5a9aec30bcf0e0a6bf5db6a91c1d8b081e1497`;
checks SHA256 is `e5cdea7bd0738e030fe6470b7469ac2ac28e908acd13b51e59e5e116e13c36f3`;
receipt SHA256 is `9d99a8c9a94b15c8dd2752b91afb7499af2e87365f37a02e56ab0dd11c78bca1`.
The original component cache remains
`cache/s12/Hqqbar/2b43ec40e4eb73555f089a7a4474a257b2a4d8f0a29a71059c9eb094192367bf/`.
The execution log is `cache/s12_Hqqbar_recoil_complete.log`.
The aggregate retains the original S12 physical source identity and records
the rational-product adapter, recoil completion source and accepted comparison
identities separately. S14 must bind this aggregate and the corrected S11
counterterms before cancellation; finite F hats require S14 and S15 acceptance.

## S14/S15 address-space contract

Keep the execution guard consistent with the requested scheduler allocation.
S14 job `14805169` received 6 GiB but its configuration imposed a 4 GiB
address-space limit. The native kernel exited with `No more memory available`
after 583 distribution checkpoints; it did not report a failed pole gate.
Its receipt records 3,160,129,536 bytes maximum child RSS. Preserve the
input-bound checkpoints under
`cache/s14/Hqqbar/1952bf80411325d892453d5076c7bf9dace4c92fc5dd88d7b34752cd1569e24f/`.
The address-guard continuation uses the same source and input hashes, a
6 GiB address-space limit, and a 5 GiB process-tree RSS limit within one
6 GiB scheduler slot. Apply those same guards to the subsequent S15 export.
The native operation bounds, equations, pole predicates, reference comparisons
and acceptance/export requirements remain unchanged.

## S14 exact pole-factorization comparison

`common/s14_check_pole_factorization.wls` reads the actual rejected
`{{4,1,1},-1,"Regular"}` checkpoint from job `14805498` and its complete
original input parts. Use the exact factorization/refinement definition
already accepted in Hqg's S13 branch comparison, with this S14 branch's
unchanged physical conditions. Require exact zero of the saved residue and
the pole reconstructed from the complete original input sum. Recheck an
own accepted positive-branch component with both original and refined
predicates. Bind the failed execution, checkpoints, source, native versions
and physical inputs. Save the comparison under
`s14_pole_factorization_result/`, with native reload checks. It must not
write the canonical finite-assembly cache. A nonzero result remains a
rejected comparison and requires investigation of the upstream terms;
neither this comparison nor a single canceled pole accepts final F hats.

The initial comparison in job `14805811` reproduced exact zero from the
complete original input sum, but whole-expression refinement did not prove
zero of the saved transformed residue. Its native factorization contains a
small square-root factor multiplying a polynomial. The revised comparison
checks exact rational factorization and reconstruction of the full product,
then applies the already accepted refinement to each square-root-containing
factor under the same physical conditions. Acceptance still requires a native
exact zero for both the saved residue and the original input sum, together
with the unchanged own-control checks. Record the actual zero factor and its
conditions in the proof. The preceding source is preserved in
`common/s14_result/reference/s14_check_pole_factorization_before_factor_certificate.wls`.
No production source or accepted coefficient changes before those gates pass.

Job `14805974` verified complete factor reconstruction and zero of the own
positive control and original input-sum factor, but did not certify the saved
negative-branch residue. No canonical result was changed. The comparison now
applies the unchanged original S14 `zero` predicate to each small radical
factor before the inherited UV refinement. It also replaces the loop-local
`Return` with `Break` and a checked post-loop return, preventing a proved zero
factor from falling through to the whole-expression fallback. The original
source is preserved in
`common/s14_result/reference/s14_check_pole_factorization_before_factor_predicate.wls`.
Both complete-pole acceptance gates and exact product reconstruction remain
mandatory; no physical condition or input term is modified.

The corrected comparison `14806436` still left the saved negative-branch
residue unresolved, while its original input-sum pole was exactly zero.
The next comparison retains the actual factorization and original predicates,
then asks native `Reduce` whether a remaining radical factor can be nonzero
on the unchanged physical domain. Derive the variable list from the actual
factor and conditions; first prove every such variable is real under those
conditions and that the domain is nonempty. Accept this certificate only when
the exact nonzero domain is `False`. Retain that native result, variable list,
factor and conditions in the comparison. This changes neither the physical
domain nor any assembly input, and both original complete-pole gates remain.
The prior source is retained in
`common/s14_result/reference/s14_check_pole_factorization_before_real_domain.wls`.

The real-domain comparison source explicitly substitutes the computed variable
list and the original conditions into `Exists` with `With` before `Resolve`.
The previous source is retained as
`common/s14_result/reference/s14_check_pole_factorization_before_explicit_quantifier.wls`.
Require an exact `True` nonempty-domain decision before testing for a nonzero
factor anywhere in that domain. Save or print the evaluated quantifier and
its result; a setup failure cannot certify pole cancellation. This changes no
physical assumptions, saved residue, original input part, or acceptance gate.

## S14 accepted exact pole refinement

The own-channel comparison passed Hoffman job `14806606` on `n7639` in
183.038728 seconds, with peak observed process-tree RSS 1,517,072,384 bytes.
The original accepted control remains zero. Both the saved failed pole and
its complete original input-sum pole are exactly zero on the original physical
domain. The program proved this domain nonempty and `Reduce` returned `False`
for the condition that the saved residue's selected factor is nonzero there.
No root replacement or new physical assumption was supplied.

Accepted comparison source SHA256:
`adfb5f8c877b57b191a08514488580907bc221008dab61e24ebee6d196cee14f`.
Locally verified result/checks/receipt under `s14_pole_factorization_result/`:
`a6eda2b934dee5208732d33d793ab7e1ff96f2c0ed3475534eb6b48affd472f7`,
`6fc4cc2a8e00fa11587443d770c8df97ca69e4207626835af8099d2d790c31ae`,
`d4b9a4bbfeddf562cd7d25f8c6a78d6b8c2bda5576587aa80842da5430931117`.

`common/s14_assemble_finite_refined.wls` installs only these executed
refinement definitions, after checking the own-channel input, original
functions, native versions, source/configuration and comparison receipt.
Change only the pole predicate inside the original `finitePart` definition;
require exact restoration of that definition by the inverse symbol replacement.
Keep the original global zero predicate, all phase-series checks, physical
conditions, finite-coefficient extraction, reference-hat comparisons and
accepted canonical checkpoint identities. Retain executed factor certificates.
Compress only the aggregate native S14 export, with exact reload and a
128 MiB file bound. S15 consumes that same native expression and collects its
matching scheme result. Require all remaining cancellation, reference and
finite-export gates before accepting the channel's F hats.

The refined S14 entry point uses the unique literal initialization
`phaseRunTail="indices=Tuples"` as its boundary, located by `StringPosition`.
The earlier broader assignment prefix also matched the later replacement
assignment and caused job `14806677` to exit before initialization. The earlier
entry point is retained under `common/s14_result/reference/`; no algebraic
result was produced by that invocation. The source text reconstructs exactly
from the separated prefix, newline and tail; the execution and final-export
boundaries are each unique. All mathematical definitions remain unchanged.

The rejected `s14_unaccepted.wl` scratch copies from comparison jobs
`14805811`, `14805974`, and `14806436` were removed after their hashes were
verified and no job input bindings referenced them. They occupied 20,995,106
bytes and are superseded by the accepted proof, which embeds the complete
original failed checkpoint and its input parts. Earlier source versions and
execution receipts remain available. Production consumes the accepted proof;
rerunning the historical comparison requires its original bound inputs in an
isolated working copy, since resumed S14 replaces the canonical failed receipt
and checkpoint with the next generation. The failed main receipt is retained
under `cache/previous_Hqqbar_s14_result_14805498/`.

## S14 native storage sharing and scheduler headroom

Job `14806723` passed all 144 physical-component cancellation checks and
constructed the finite F1/F2 projections. Scheduler accounting reports
`failed 46: execd enforced h_vmem limit`, exit 137 and 6.029 GiB maximum
virtual memory during the first nontrivial final-reference comparison.
The aggregate and final hats were not accepted. The execution receipt was
recovered explicitly from scheduler accounting and the last heartbeat after
confirming native-writer absence; its origin is recorded in the receipt.
Preserve all accepted, input-bound finite-component checkpoints.

The refined entry point uses native `ClearSystemCache` and `Share` immediately
before the unchanged reference comparisons. These native storage operations
preserve expression values by definition; they do not introduce a new algebraic
algorithm. Record memory before/after, bytes reported by `Share`, and elapsed
time. Between final
comparisons clear only the native system cache; keep the original zero predicate
and require exact reconstruction of the original comparison source. This is a
storage operation and does not replace or weaken a mathematical gate.

The continuation requests one 10 GiB scheduler slot, with a 9 GiB per-process
address limit and an 8 GiB process-tree RSS limit, leaving space for the execution
wrapper. Keep the original 2 GiB per-operation bound, four-hour runtime, 4 GiB
scratch cap and 128 MiB file limit. The preceding source is preserved as
`common/s14_result/reference/s14_assemble_finite_refined_before_shared_storage.wls`.
S15 must use the same scheduler headroom and bind the newly accepted S14 result;
collect the matching final scheme artifact along with its hats and receipt.

Storage candidate `14807408` reached all 144 finite components but exhausted
memory before the sharing measurement or final comparisons. Remove its
unnecessary whole-state hash, which traversed several full copies of the same
tensor data before any cache clearing or sharing. Keep the exact original
comparison-source restoration gate and all executed pole and reference tests.
The preceding storage candidate is retained as
`common/s14_result/reference/s14_assemble_finite_refined_before_bounded_storage_check.wls`.

The continuation defers only the input expression of `finitePart`, using a
`HoldFirst` wrapper with the identical input-bound checkpoint lookup. A cache
miss calls the original eager `finitePart` implementation, so uncached inputs
and every pole/finite gate retain their original evaluation. Require exact
inverse restoration of the assembler definitions. Before the full assembly,
execute the original and deferred assemblers on the complete own component
identified by the accepted pole proof; require identical indices and every
branch/distribution coefficient, with both sets of component checks passed.
Retain measured timings and the comparison evidence in the aggregate result.
Boundary construction, normalization, complete spin coverage and final reference
comparisons remain unchanged. This consumes the previously accepted canonical
finite checkpoints without first recalculating their phase products.

Job `14807645` passed that complete own-component comparison: 71.720036 seconds
with eager inputs and 8.650442 seconds with deferred inputs. All 144 physical
components were then assembled. Native sharing saved 6,624,528 bytes in
1.158778 seconds; it was not a substantial memory reduction. The original
F1 positive-branch Regular reference comparison reached the 2 GiB operation
limit, so no final aggregate was accepted.

Before the original final-reference zero predicate, collect the actual
logarithmic and other transcendental functions using the same native `Collect`
and `Factor` operations as the pinned S20 reduction. This places coefficient
grouping before the original `Refine`, without altering the original predicate
or branch assumptions. Require exact native `Together[original-prepared]===0`
for every prepared expression. First compare the complete accepted own finite
coefficient identified by the pole proof's `ControlLabel` and `ControlHash`;
its actual checkpoint must still match that accepted hash and input identity.
Record the native functional basis, expression sizes, timing and reconstruction
evidence. Keep the 2 GiB operation limit and every final equality gate.
The preceding source is preserved as
`common/s14_result/reference/s14_assemble_finite_refined_before_reference_precollection.wls`.

## S14 saved-export recovery and bounded S15 storage

Job `14807831` passed all 144 physical components and every original F1/F2
Born, branch and boundary comparison. Its own finite-control regrouping
reconstructed exactly, reducing native storage from 64,291,904 to 1,861,376
bytes. The complete 48,234,145-byte compressed temporary export was written,
but the subsequent full reload exhausted the 9 GiB process address limit.
The mathematical assembly and original predicates are retained unchanged.
The pending export SHA256 is
`aee247d6a6bee3e5a78648be537a72d9f3994b6848cdb36d8b61b00d8269a19f`.
It is not accepted merely because the serialized file exists.

`common/s14_complete_saved_finite_export.wls` reads that exact file in a
fresh kernel. Bind the failed producer receipt, complete source/configuration
and input identities, original log and every accepted finite checkpoint.
Require the native input hash, full physical basis, all recorded mathematical
checks and all reference comparisons to match. Reuse the producer's exact
coupling and normalization code, compare every full branch/distribution
component with its own canonical finite checkpoints, and reconstruct every
saved tensor entry and F1/F2 projector. Publish only the identical validated
bytes and a separate recovery check/receipt. This avoids repeating the
finished integration and reference algebra while independently checking the
actual saved coefficients. Fresh-kernel recovery `14808529` also exhausted
the 9 GiB address limit during `Get`, before any component comparison; it
does not supply acceptance evidence. Its receipt records 844.233206 seconds
and 8,522,932,224 bytes maximum child RSS. A bounded streaming encoding check
validated the complete base64/zlib payload and checksum and measured
2,276,284,274 decoded serialization bytes using 9,883,648 bytes maximum RSS.
This is encoding evidence, not a native expression or physics check.

Use one 24 GiB scheduler slot for saved-export recovery and its S15 consumer,
with a 22 GiB process address limit and a 21 GiB process-tree RSS limit.
Retain the one-hour allocation, 3,300-second guarded runtime, existing
file/scratch limits, exact pending-file identity and all native comparison
gates. This larger read allocation accommodates the measured serialized
payload; successful native decoding and the complete checks remain required.

Job `14809043` completed native loading and verified the saved schema and
input identity. It then rejected structural identity for component `{1,1,1}`.
The recovery comparison must preserve both coefficient forms and require an
exact native scalar difference of zero when their structures differ, with
600-second and 2 GiB additional-memory bounds. Require identical association
keys and complete component coverage; compare the aggregate tensor directly
against its saved components. A nonzero difference or resource limit stops
publication and saves the actual compared equations. This is a comparison
contract, not acceptance of the first mismatch or of the export. The preceding
recovery implementation is preserved as
`common/s14_result/reference/s14_complete_saved_finite_export_before_scalar_equality.wls`.

`common/s15_finalize_spin_coefficients_compact.wls` preserves the complete
original S15 calculation by exact inverse source comparison. Only its native
writer and object lifetimes change. Compress each output, enforce the 128 MiB
file bound and require exact native reload before publication. Release the
already-consumed S14 object before final serialization, and release the full
final result before writing its separate hats. Record the compact dispatch
hash alongside the original mathematical source hash; collect the matching
scheme artifact. All original scheme, normalization and finite-result gates
remain mandatory before final hats are accepted.

## Accepted complete S14 finite tensor

Recovery job `14809165` on `n7005` passed all 797 checks, including every
branch/distribution value of all 144 physical components, complete tensor
embedding, all F1/F2 projections and the final finite-content check. Every
scalar matched directly; no algebraic-difference fallback was used. The
initial whole-association identity failure did not require changing a
coefficient. The published native bytes exactly match the completed
producer export from job `14807831`, which had passed all original pole
cancellations and unpolarized final-reference comparisons.

The local accepted files are `s14_result/s14_result.wl`, SHA256
`aee247d6a6bee3e5a78648be537a72d9f3994b6848cdb36d8b61b00d8269a19f`;
`s14_result/s14_checks.json`, SHA256
`225b23f83beddf1a6d2fd60e85b4e9810d33eb6fd566447d5c83e9fb71beaf95`;
and `s14_result/s14_execution.json`, SHA256
`f5baaca27f6335921ed2b121fe03c97cae0a42f1136f48b30a7edde8541924a9`.
The recovery source SHA256 is
`69705aae403f337f39b2aaf6845895543dc62e5f1eaad6f72dd9aea4124bba5d`.
Executed wall time was 923.745370 seconds; maximum child RSS was
8,582,086,656 bytes. The full compressed native file is 48,234,145 bytes
and requires substantially more memory when loaded; use the recorded
compute allocation. S15 must bind this exact accepted tensor and pass its
finite-scheme and export gates before it is a final F-hat deliverable.

## Accepted final partonic hats

S15 job `14809292` on `n7005` passed the complete finite-scheme, finite-content
and exact saved-file reload checks in 1251.241472 seconds. It consumes the
accepted S14 tensor above, including all componentwise pole cancellations
and original unpolarized F1/F2 reference comparisons. Every final artifact
and its matching scheme result has been hash-verified locally.

| Artifact | SHA256 |
|---|---|
| `s15_result/s15_result.wl` | `e51108ed10bce89526378cc6c29ae1b8fcfacfdd28c1c01c9a28cca573c78290` |
| `s15_result/s15_F1_hat.wl` | `40da5c3e5a5b13f29bfd62040e9250ef37ba9a7c46a00715d374b59f75e5bd85` |
| `s15_result/s15_F2_hat.wl` | `8ce1b02a55cf11859a6c160743a61767aaf63baa19e6e309637203b776e4237c` |
| `s15_result/s15_checks.json` | `01fc599c1b7341e93c81f601e829e3c63e8876a3549969f8011548e87b9959de` |
| `s15_result/s15_execution.json` | `7b920dd0cd14753d102521afb8caeac52a144666dd8aa0c2b3844156bab57b6a` |
| `s15_scheme_result/s15_result.wl` | `74c8682092e6bb3d05d45ac1a7ce13e02d92b5876b462e857c46d2001774b445` |

The executed compact entry point is
`common/s15_finalize_spin_coefficients_compact.wls`, SHA256
`8f2bb37f8b38701c669a08b9270d290aeb7292ab162f0b66820dea7b8eb3ddc9`.
The channel entry `s15_finalize_spin_coefficients.wls` links to this accepted
compact implementation. Invoke it from the polarized_SIDIS root with
`POLARIZED_SIDIS_CHANNEL=Hqqbar` and the recorded compute allocation.
It preserves original mathematical source SHA256
`54838cdee6222b75e578a242a940bdb79bd1517d41e098cbd9ca18fd369463f8`.
The bound configuration is `.cluster/s15_Hqqbar_saved_compact_equality_job.json`,
SHA256 `eaa640be485d64f128d9fe86f3fdecaa0b4cc28791c5dd2a28860cd2337632db`;
the execution log is `cache/s15_Hqqbar_saved_compact_equality.log`.

Read the native compressed files with `Get` in the recorded Wolfram/FeynCalc
environment on the compute allocation. The complete result sets
`FiniteNLOFHatsComputed -> True`. Read its `SpinLabels`, `PhotonLabels`,
`IndexOrder`, `PhysicalFrame`, `BranchConvention` and `PlusDefinition` before
consumption. `Fhats` contains `F1` and `F2`; each has `LODelta` and `NLO`,
with branches `1`, `-1`, `0` and distributions `Delta`, `L0`, `L1`, `Regular`.
The hat matrices retain outgoing and incoming spin indices; `NLOResponse`
retains the complete photon response. Keep the recorded finite helicity
restoration and factorization scheme. Proton/fragmentation convolutions,
numerics and jet matching remain deferred.

## Channel entry files for accepted S08 and S12

`s08_map_real_spin.wls` links to the accepted shared
`../common/s08_map_real_spin_streamed.wls` implementation, SHA256
`f65fbeee3345dcf281e60192a7e6ea4dfd08eb547f4aa7fb225134462e1ed601`.
`s12_assemble_real_spin.wls` links to the accepted shared
`../common/s12_complete_recoil_factorization.wls` implementation, SHA256
`9b9b034d1f9e64f3fc4accdfd0965d20c85d427296ddc0c4ad61d9015ede1222`.
Run from the polarized_SIDIS root with `POLARIZED_SIDIS_CHANNEL=Hqqbar`
and the matching saved job configuration. S12 requires its recorded
`POLARIZED_SIDIS_RECOIL_PROOF_SHA256` value and the bound rational-series
and recoil-comparison artifacts. These entry links retain the source, input
and result identities documented for jobs `14802031` and `14805132`.


## Retention and restoration of accepted large exports

The hash-verified local S14 tensor and the three S15 coefficient exports
listed above are the retained final copies. Their duplicate cluster files
may be removed after confirming their receipt hashes, local copies and
absence from active job inputs. Keep checks, receipts, sources, scheme
artifacts and required integration/recovery checkpoints.

Before a cluster rerun that consumes these exports, restore the exact local
bytes at the original paths and verify their recorded SHA256 identities.
The saved S14 producer file `s14_result/s14_result.wl.tmp` is byte-identical
to the accepted `s14_result/s14_result.wl`; restore it from that same local
file when reproducing the recorded recovery job. Other channels do not
consume these completed S14/S15 exports.

### Completed S14 cache archive contract

The completed finite-assembly cache may be archived with the existing lossless
multipart cache routine after validating the accepted S14 and S15 local exports
and confirming that no active job consumes those cache paths. Preserve every
member's original path, byte count and SHA-256 in
`s14_cache_archive_result/s14_cache_manifest.json`. Verify every archive member
remotely and locally before removing a remote raw file. Keep the compressed
archives and manifest locally. Restore these exact members before rerunning
the historical S14 recovery or any comparison that names those checkpoint paths.
The accepted coefficients, sources, checks, receipts and subtraction inputs are
not changed by this storage operation.

The archive passed on Hoffman2 as job `14814472` in 29.479242 seconds. All
1,728 members, totaling 165,898,564 raw bytes, were verified remotely and again
after bounded local transfer. The corresponding remote raw cache and duplicate
archives were then removed after confirming that no active job consumed them.
The final coefficients and their accepted identities above are unchanged.

| Retained file under `s14_cache_archive_result/` | SHA-256 |
| --- | --- |
| `s14_cache_manifest.json` | `3bcc9743e6f197a6c671a74010b03b5a71ef472fe9dcadc6e2e8c3de69bc769e` |
| `s14_cache_part01.tar.gz` | `ac1de9e1e1e5d8f066d28356727549c37b78e0319a4c3a742f313f2ef162064b` |
| `s14_cache_part02.tar.gz` | `08838fcb6cd88cd21b4835fe3cd80d5499c376a0bb5b61eeb012631b997161c9` |
| `s14_execution.json` | `b251e362d046233d80302ce1b33f6b574ff3c5a346b18b66f03b8f8d720517f6` |

The archives occupy 8,923,924 bytes locally. Restore their recorded relative
member paths beneath the polarized_SIDIS root, checking every member against
the manifest, before using the historical S14 checkpoint recovery. The saved
job configuration is `.cluster/s14_Hqqbar_completed_cache_archive_job.json`,
SHA-256 `62fad21cafaadaefee3c101c01e465626dd8d1ee92b4cfe5295b38d4a4c0a835`.


Completed S12 integration caches may be retained under
s12_cache_archive_result after confirming final job14809292 and absence
from all active job input bindings. Preserve exact member paths, sizes and
hashes; verify each compressed member locally before removing identical
remote duplicates. Restore these paths before a future S12 resume.
This storage operation does not alter accepted coefficients or proof inputs.


### Completed S12 cache retention

The completed S12 cache for final job14809292 is retained in
s12_cache_archive_result/s12_cache.tar.gz, SHA256 1877818a2ad729d96a92ac95ceb8415db3c34b8ca38eb64ed8aa8c6649b9210d.
The accompanying s12_cache_manifest.json records every original relative
path, byte count and SHA256. All members were checked against the archive
before removing 33892151 duplicate bytes from remote scratch.
Restore the exact paths and verify member hashes before any future S12
resume. Final S14/S15 coefficients and accepted receipts are unchanged.
