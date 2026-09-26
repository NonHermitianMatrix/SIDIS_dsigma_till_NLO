# Shared polarized SIDIS stages

Shared programs serve the channel owners listed in the root README.
All stage execution is on Hoffman2 compute nodes. Local source and result
files are completed deliverables; large caches remain on the cluster.

## S01 reference-input contract

Acquire selected open-amplitude source/results from the pinned GitHub
SIDIS tree and verify their byte counts, SHA256 digests, and Git blob
identities. Preserve the original generated species, momenta, diagram
factors, model-charge definitions, and tagged-particle assignments.

Spin-summed Born/real tensors and unpolarized finite hats may be retained
as explicitly labeled reconstruction references. They must never be
accepted as newly polarized results. Importing and hashing a source does
not certify that its spin or factorization convention is appropriate for
the new calculation.

The S01 source/result records the user's selected large-transverse-momentum
SIDIS measurement and complete incoming/outgoing spin response. Its receipt
validates acquisition only; it is not a newly calculated hard coefficient.

S01 passed on Hoffman2 job `14773300`, node `n7041`: 48 pinned files,
2,691,370 bytes. `s01_result/s01_result.json` and `s01_execution.json` bind
the source/configuration and channel receipts. The imported files remain
under each channel's `s01_result/reference/` with their original paths and
separate reference-only role. The maximum child RSS was 12,525,568 bytes;
the short job completed between process-tree samples.

## S02 physical spin basis contract

`s02_define_spin_basis.wls` runs once for all channels. Its result belongs
to `common/s02_result/`; channel links expose the shared contract/result.
It verifies the imported open-state interfaces and derives Pauli density
matrices, quark and antiquark Dirac representatives from normalized
massive wavefunctions and their massless limits, gluon Stokes tensors,
and a complete Hermitian physical-photon matrix basis. The incoming state
has trace one; the outgoing U analyzer sums the measured parton's spin.
Antiquark transposition follows the reversed external-wavefunction indices.

Required checks include Dirac equations, massive spin completeness,
massless projector reconstruction, gluon transversality/completeness,
photon matrix reconstruction, and the installed FeynCalc completeness
replacement interface. These establish canonical physical bases, not
NLO dimensional spin projectors, subtraction terms, or finite hats.

S02 passed all 42 checks in job `14773409` on `n6045`. Its exact result is
`s02_result/s02_result.wl`, SHA256
`135ff5607643e3d4ab0d6475ab17cd25c8d1973c0fa536c47c402d5b22d000bd`.
`s02_checks.json` and `s02_execution.json` record the inventory and checks.
The basis has four components per parton and nine photon components.
Consumers must use the saved `PhotonBasis` and `PhotonDual` matrices,
including the sign/order of their imaginary off-diagonal generators.
Incoming densities are divided by the saved spin dimension; outgoing U
analyzers sum spin. The peak child memory was 370,872,320 bytes.

## S03 Born contract

`s03_born_spin_response.wls` selects a core channel using
`POLARIZED_SIDIS_CHANNEL` and writes that channel's `s03_result/`.
It reuses pinned open amplitudes, the measured reference model charge,
and the accepted S02 spin basis. It solves the Born Breit-frame momenta
from invariant definitions and defines the outgoing X axis by Y cross Z.
The amplitude and conjugate retain distinct photon indices. For a gluon
tag, the outgoing analyzer reverses the helicity-dyad indices explicitly.
The dimensional calculation keeps physical resolved momenta and spin axes
in four dimensions, with D-dimensional unresolved sums. An internal gluon
E component is defined by the difference of the D-dimensional and
four-dimensional sums in the same gauge; it is regulator bookkeeping,
not an additional physical polarization. The photon metric complement is
kept separately for reconstruction of the original dimensional Pg.

Acceptance requires physical spin axes, calibrated Levi-Civita orientation,
fully scalar projected expressions, photon Hermiticity, photon/gluon Ward
identities, exact spin/photon reconstruction, and exact agreement with both
reference Born Pg/Ppp contractions, including their full D dependence
after reconstruction of the reference gluon sum and average. Results have indices
`[photon component, outgoing spin, incoming spin]` and carry no two-body
phase space. Dimensional Born tensors are inputs to NLO subtraction;
they are not finite NLO F hats. The four-dimensional verification program
`s03_born_spin_response_exact.wls` uses exact polynomial reduction of the
transverse coordinate and the original unpolarized Born comparisons.

## S04 transverse angular-average contract

`s04_transverse_angular_average.wls` derives the residual angular moments
for one physical normal direction and the BMHV evanescent directions.
It derives the reference real invariant map and the projection onto the
physical p,q,k1 span, then compares normalized sphere moments with an
independent Gaussian factorization. Odd moments, normalization, transverse
radius reconstruction, and evaluated meromorphic continuation are gated.

The result distinguishes the cut radius from the general radius needed
for an uncut loop momentum. A later consumer must establish that the
measurement and denominators have no residual angular dependence and
reconstruct its complete numerator before applying the moments. This
prerequisite is not a cut integral, virtual integral, or finite F hat.

S04 passed all 14 checks in Hoffman2 job `14773690` on `n6045`.
`s04_result/s04_result.wl` has SHA256
`970f0bfd74d9cb5838703d01d8ce3066ff4dc28367bad67c74076bbab6b7c0b3`.
The result includes 49 moments through verification depth six; consumers
must derive any additional moments they require from the saved generic
expression. `s04_checks.json` and `s04_execution.json` bind the checks,
source, and inputs. Peak child memory was 313,438,208 bytes.

## S05 real-emission contract

Use the pinned open real amplitudes and retain both resolved spin indices.
Keep p, q, and k1 physical, while the unmeasured momenta and polarization
sums retain D dependence. Derive the real Breit frame from the invariant
definitions. Resolve the physical normal component and its complementary
evanescent norm using the on-shell equation; apply the accepted S04 moments
only after checking numerator reconstruction and angular independence of
the denominators, measurement, and positive-energy support.

Preserve each channel's generated charge and spectator bookkeeping.
Off-diagonal diagram pairs require the Hermitian transpose of the photon
matrix when adding their conjugate interference. A scalar real-part
operation on each matrix entry would discard required information.
Require Ward identities, photon/spin reconstruction, Hermiticity, and exact
reconstruction of the pinned unpolarized real tensors. `s05_inputs.json`
binds those reference tensors; they are validation inputs, not polarized
results. Scalar integral reduction, phase-space integration, virtual terms,
factorization, and finite hats remain downstream of this stage.

### S05 projection-order comparison

The candidate `s05_real_spin_response_projected.wls` contracts the photon
projectors into the closed native spin chains before evaluating traces.
It must compare every photon-matrix and scalar-check component with an
existing S05 pair checkpoint having the exact original source/input hash.
Its isolated comparison result records runtime and memory. A comparison
does not replace the full S05 Ward, Hermiticity, charge, and unpolarized
reconstruction gates, and does not establish finite F hats.
Keep candidate caches separate until the executed comparisons pass.

The production S05 source applies photon projectors before Dirac traces.
It reduces and angular-averages the exact coefficients of the spin
polynomial separately, with a reconstruction check. Independent diagram
pairs use the reference's bounded parallel-kernel pattern, limited by the
allocated slots. Each photon or Ward projection has its own checkpoint.
The first diagram pair is recomputed and compared when a previous checkpoint exists;
other previous pairs are reused only with their source/input binding.
It can reuse original pair checkpoints only after matching the original
source, input, and native-version binding, and records their file hashes
in the sector result. The original source is preserved in
`s05_result/reference/s05_real_spin_response_before_projection.wls`.
The subsequent projected source is preserved in
`s05_result/reference/s05_real_spin_response_before_coefficient_reduction.wls`.
The comparison program and its submission configuration reproduce the
original comparison in an isolated directory with that pinned source;
they are not production entry points.

Hoffman2 job `14774236` on `n6406` passed the comparison for Hqqprime
sector Real, pair `{1,1}`. All nine photon-matrix entries, PgD, and the
photon Ward contraction matched the original checkpoint exactly.
`../Hqqprime/s05_projection_result/s05_result.wl` has SHA256
`286afd555f4f38d5a8632a6f3dfc79d842e65fab34ef0e9f0dee82c547099c28`;
its checks and execution receipt are in the same directory.
The measured comparison took 315.454691 seconds without cache reuse;
whole-job wall time was 336.076529 seconds and peak child RSS was
661454848 bytes. No baseline timing ratio is established. This comparison
does not cover external-gluon pairs or complete integrated coefficients.

## S06 reuse of accepted scalar integrals

`s06_reuse_scalar_integrals.wls` validates selected scalar definitions,
Kira rules, cut-master representations and regions, virtual-master values,
and UV residues from the completed unpolarized run. `s06_inputs.json`
binds their exact identities to the pinned GitHub layout manifest and the
original executed source hashes. These are unchanged reusable scalar
inputs; they contain no newly calculated polarized coefficients.

The consumer must map its actual polarized numerator to the saved integral
definitions, preserve the cut and loop measures and continuation, and
check target coverage and required epsilon depth. A missing target or
insufficient expansion depth requires extending only that scalar work.
The old spin-averaged collinear subtraction is not a polarized subtraction.

S06 passed all 51 checks in Hoffman2 job `14773925` on `n6406`.
`s06_result/s06_result.wl` has SHA256
`2408dec8ef08029c96a1d02993e73921ee969dfaba1abd5ca75ab06cda3afda1`.
Nine selected scalar stages and their original sources match the accepted
GitHub identities exactly. The native result schemas, source bindings,
and original acceptance flags passed. The copied reference artifacts and
their sources are under `s06_result/reference/`; the result manifest gives
their precise roles. No scalar integral was reevaluated in this stage.

## S07 virtual spin-tensor contract

Use the original open one-loop amplitudes and their loop routing, together
with the accepted dimensional Born normalization and physical spin basis.
Close native spinor chains before applying physical resolved projectors.
Contract each photon projector into the closed chains before evaluating
Dirac traces. The complete accepted Born spin tensor and each original
virtual CDR projection remain mandatory checks of this interface.
The program decomposes each scalar spin polynomial with CoefficientRules,
checks its exact reconstruction, and performs rational reduction and normal
angular averaging separately on its coefficients. Native photon replacement
is checked against explicit contraction before processing amplitudes.
Keep the unobserved gluon sum dimensional and preserve internal E components
for reconstruction of the original gluon average or tagged gluon sum.

The S04 general radius supplies the loop normal moments; its cut radius
must not be substituted for an off-shell loop momentum. Require exact
angular numerator reconstruction and angular independence of propagators.
Compare each diagram's reconstructed CDR Pg/Ppp integrand with its pinned
original value, before scalar integration. Preserve the complex interference
before adding its Hermitian conjugate. Loop integration, physical
continuation, UV/collinear subtraction, and integrated Ward checks remain
required downstream; an unintegrated virtual tensor is not a finite F hat.

## S08 real scalar-mapping contract

`s08_map_real_spin.wls` consumes an accepted S05 tensor and the accepted
S06 geometry and real reduction library. It reuses the original affine
partial-fraction and Laurent-coefficient mapper without changing its
algebra. Derive the coordinate change from the saved scalar products,
reconstruct every component, and preserve both positive-energy cuts.
Map the extended spin response and photon-metric complement separately;
keep charge variables and the inherited spectator bookkeeping intact.

The result records exact integral coefficients, saved-rule coverage, and
any missing targets. A valid map with missing targets is not a completed
reduction. Integration may proceed only after coverage is complete and
the required master expansion depths have been checked. This stage
performs no scalar integration and produces no finite F hats.

## S09 virtual scalar-mapping contract

`s09_map_virtual_spin.wls` consumes an accepted S07 result. Use each
diagram's original complete topology and the accepted S06 canonical
routing and reduction rules. Derive the loop-coordinate change from
the topology, reconstruct every rational integrand, and compare the
CDR coefficients with the original diagram map after reduction.
Retain complex coefficients until physical master continuation and
Hermitian assembly; include the photon Ward contractions as consumers
of the same integral map.

Record missing targets explicitly. Mapping acceptance does not establish
complete reduction, adequate master expansion depth, integrated Ward
identities, or finite F hats. A topology absent from the original map
must be constructed and validated before that diagram can be accepted.

## Later-stage acceptance

S11 contracts the accepted physical Born spin responses with the S10
kernel matrices, retaining the reference's PDF/FF measure, roots,
Jacobians, plus distributions, and subtraction prefactor. Derive the
rescaled invariants from the inherited scalar products and check the
photon and spin axes against the actual rescaled momenta. Verify the
same convolution routine against every original CDR channel component.
Core channels use their accepted S03 Born inputs; real-only channels
require their own verified auxiliary Born spin inputs before acceptance.
Keep the BMHV convention explicit; finite axial-scheme conversion and
complete real/virtual pole cancellation belong to the final assembly.

The collinear spin kernels use the original S08 normalization and endpoint
convention. Derive their real spin responses from native QCD vertices with
the accepted S02 projectors, average the unresolved azimuth, and take the
collinear limit. Every unpolarized and helicity entry must reproduce the
installed splitting-function library in the reference normalization.
The inherited virtual endpoint coefficient multiplies the spin identity;
check the complete distribution and charge-conjugate channels. These LO
splitting kernels are subtraction inputs, not finite hard coefficients.

S10 passed on Hoffman2 job `14774482`, node `n7140`. The seven generated
quark, antiquark, and gluon routings passed native unpolarized/helicity
kernel comparisons, full spin reconstruction, endpoint checks, and charge
conjugation. `s10_result/s10_result.wl` has SHA256
`9fa4087c0e3819e25947c60a78da255122d16dbb27764af668dfb3781d5503fe`.
The checks and execution receipt are in the same directory. Runtime was
33.538948 seconds and peak child RSS was 385,949,696 bytes. The kernel
indices are `[daughter spin, parent spin]`; channel names order the parent
before the daughter. Consumers must preserve the inherited per-kernel
normalizations. These are LO kernels for NLO subtraction; no hard-tensor
convolution or finite NLO assembly has been performed by S10.

Before execution, read every new or changed program completely, together
with affected shared code and its artifact interfaces. Bind reviewed
source, configuration, and inputs by hash. Use actual serialized artifacts
for interface validation. Syntax checks supplement, rather than replace,
mathematical reconstruction and physical acceptance gates.

Record the measurement, spin basis, regulator prescription, normalization,
factorization definitions, and expected output schema before implementing
their dependent stages. Exact component reconstruction and cancellation
checks are required before a finite hard coefficient is labeled accepted.

## S12 real integral and endpoint assembly

`s12_assemble_real_spin.wls` uses the accepted S08 reduced spin coefficients
with the unchanged S06 cut-master values and soft-region results. It adapts
the reference S17 assembly and retains its distribution convention, branch
domains, cut measure, and epsilon-coverage gates. Substitute the saved
physical transverse coordinate before taking recoil limits, so spin-basis
factors participate in the endpoint calculation. Retain all independent
spin, photon, charge, and sector components. The output contains cut-measure
Delta/L0/L1/regular tensors; phase normalization, virtual and collinear
terms, and final pole cancellation remain the assembly consumer's work.

### S07 compact-invariant validation contract

The scalar-product assignments may use exact temporary abbreviations for
lengthy frame expressions during native traces, as the standalone qg
reference keeps loop products and evanescent norms compact until its
scalar boundary. Restore every abbreviation before normal-angle averaging
and export. The original source is preserved as
`s07_result/reference/s07_virtual_spin_response_before_compact_products.wls`.
The compact implementation must reproduce the complete accepted Born tensor
and the full photon, extended-spin, photon-metric and Ward data of the
existing Hqq diagram-1 checkpoint before production use. Its comparison
result is separate from the final S07 tensor. Projection checkpoints retain
only completed bounded calculations and are tied to source/input hashes.

### S05 compact-invariant comparison and reuse

Keep scalar-product and evanescent-norm definitions compact inside native
Dirac traces and restore their derived values before angular averaging.
The old S05 source is preserved in
`s05_result/reference/s05_real_spin_response_before_compact_products.wls`.
Require exact recomputation of every photon and scalar projection of the
existing Hqqprime first-pair checkpoint before production. After this
comparison, complete old pair and projection checkpoints may be reused
only with their original source, input and native-version identities.
The final all-pair, Ward, Hermiticity and unpolarized gates still apply.

## S13 virtual integration and UV-renormalization contract

`s13_assemble_virtual_spin.wls` reuses the physical master values selected
by the accepted GitHub Hqq virtual result. `s13_inputs.json` pins those
values, the immutable executed assembly source, and the auxiliary-mass
Kira reduction and master values. Validate their native source/input
identities and continuation records before use. Preserve the inherited
loop measure and check the epsilon depth required by each new coefficient.

Apply the reference auxiliary-mass UV expansion to the actual scalar
spin integrands. Reuse only covered Kira targets; require reproduction of
the original CDR residues and independent UV cancellation with the saved
universal field/coupling counterterms for every new spin projection.
Keep complex interference until Hermitian assembly. Check integrated
photon Ward contractions. Export renormalized virtual Laurent tensors;
real emission, PDF/FF subtraction and complete finite-hat cancellation
remain downstream. Validation mode uses the actual pinned unpolarized
virtual maps to exercise the unchanged UV interfaces before spin inputs
are available.

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

## S03 auxiliary Born interface

The auxiliary S03 entry point reuses the accepted S03 frame, regulator,
color average, gluon Stokes, contraction and reconstruction routines. It
loads each channel's pinned `born_qg`/`born_gq` open amplitudes and scalar
reference from `s03_auxiliary_inputs.json`, retains symbolic flavor
charges, and selects the accepted antiquark numerator from actual
native spinor signs. Each result records its route and antiparticle
assignments. Accept only after full-D original g/pp reconstruction,
photon/gluon Ward, Hermiticity, scalar and spin reconstruction checks.
These results supply missing Born tensors for small-channel subtraction;
no integrated hard coefficient or new finite scheme is established here.

For resolved-gluon virtual diagrams, the auxiliary E component completes
the native covariant sum from the physical U density. Executed comparisons
for Hqg and Hgq preserve all physical densities and the entire extended Born
response and reproduce both original first-diagram contractions. Their
`s07_gauge_completion_result/` artifacts bind the source and inputs. Only
this tested density block differs from the accepted compact contraction
source. Hqq retains its original calculation hash; resolved-gluon caches
receive new hashes and cannot consume old E-dependent projections.

The real tensor sum may dispatch and checkpoint each photon/scalar entry
independently. Photon entries retain their exact linear sums; Ward entries
use the unchanged accepted scalar reduction function.
Native source-section equality gates preserve the full frame, scalar and
pair-contraction definitions. The calculation hash remains the accepted
compact source; actual dispatch source and per-entry input hashes are
recorded separately. Each scalar sum has its own time/memory bound. Full
Ward, Hermiticity, reconstruction and GitHub comparisons remain mandatory.

The final S05 basis conversion differentiates the formal spin variables
and evaluates them at zero, preserving factored expressions. Exact rational
reconstruction must reproduce the entire matrix and spin polynomial. The
contractions and their calculation hash are unchanged. The original CDR
comparisons remain mandatory before accepting the complete real tensor.

Job `14777352` accepted this extraction and linear-sum representation.
`Hqqprime/s05_spin_extraction_result/s05_result.wl` has SHA256
`ca3d2e5e85ad47b4cad41f6a26609a5886ef011a819223e9b25abe3975ea473b`.
All nine matrix entries, all spin polynomials, both original CDR projections
and the selected legacy polarized coefficient matched exactly. The selected
coefficient used 23,858,272 bytes instead of 250,530,072 bytes. The proof also
compared a direct pair sum against its accepted reduced checkpoint and
retained the native Ward reduction. Its earlier CoefficientRules diagnostic
is rationally zero despite failing a structural expanded-expression test.
The accepted check source SHA256 is
`48d356523f2c44128dbb4841ff85f7bc47b7a9fe95c50c1a605ea72bbe3b3c73`;
production source
`46c45f60a0f97c18d430cd8a3ee05182bc5e10f5deb424e8b69487d76e75e500`
checks exact equality with both saved helper definitions before reuse.
Complete channel checks and native compressed-result reload remain required.

The existing exact S05 spin-reconstruction predicates may run independently
on the allocated workers and checkpoint each photon component. Preserve
their native rational-zero test, input expressions and deterministic order.
Before adopting this dispatch, require equality of the complete Hqqprime
mathematical result with its accepted S05 artifact; ignore only execution
metadata in that comparison. All contraction and final reference checks
remain unchanged, and a checked component is not a finite hard coefficient.

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

If S09 reports uncovered virtual targets, `s09_extend_virtual_reduction.wls`
uses the original canonical families, Kira/Fermat binaries, generated bounds,
configuration writer and symbolic rule reader. The requested target set is
the union of the actual spin targets and the saved targets/rules/masters.
Require exact agreement with every original rule, the unchanged master basis,
complete new target coverage and sufficient master depth. Its completed map
belongs to `s09_reduction_result/s09_result.wl`; the original S09 map remains
available as provenance. The new reduction is not an integrated coefficient.

S13 may dispatch independent UV components to at most eight allocated
kernels. Preserve the complete UV equations, input identities, task labels,
checkpoint keys and deterministic accumulation order from the serial source.
Require a fresh worker calculation to reproduce an input-bound accepted
serial checkpoint before using that dispatch in production. Each worker
initializes FeynCalc and the same scalar products, has bounded resources,
and writes only its unique task checkpoint. Retain the original summed CDR
UV comparisons and all final UV, master-depth and integrated Ward gates.

Job `14777444` accepted the independent UV dispatch comparison. The saved
result `Hgq/s13_parallel_result/s13_result.wl` has SHA256
`133fd67e5f1d02571a6c5f07ecd85f7cc0101e33a14db963478378c7629f0d9f`.
A fresh nonzero component matched its accepted serial checkpoint exactly;
the run also verified unchanged calculation sections, input/cache binding,
worker initialization and native versions. The comparison used 3.899729
seconds; no whole-job speedup is asserted. The dispatch source SHA256 is
`0d332c9cd7011cadc7a0d40dc4234382023a1f2c419fd616bab3aa4d6f1e0dd2`.
Its calculation cache retains serial source SHA256
`930cb13c80514b51fbd2ae017feee7b1adac813651670e779258156f161aae6f`.
Checks and execution receipt accompany the comparison. Full virtual
integration and cancellation remain required for channel acceptance.

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

The S05 spin-map comparison applies the already validated derivative
coefficient extraction to the scalar-reduction boundary. Reconstruct the
complete spin polynomial, compare the actual accepted Hgg pair/projection
checkpoint bound by `common/s05_spin_map_inputs.json`, and execute the
projection that exceeded its memory bound. Preserve the native traces,
angular moments and individual scalar-reduction equations. Record time,
expression size and memory before any production use. Comparison artifacts
belong to `Hgg/s05_spin_map_result/`; all channel-level gates remain required.

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

The S05 spin-map comparison additionally restores the saved exact scalar
products before rational reduction, omitting the preliminary factorization
in independent abbreviation symbols. Preserve the complete existing
on-shell reduction and angular-average equations. Record restoration and
reduction timings and require equality of the complete accepted Hgg
projection before evaluating the previously bounded projection. This
comparison does not alter production contractions or their valid caches.
The previous comparison source is retained in
`common/s05_result/reference/s05_spin_map_check_before_scalar_restore.wls`.

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

The resource-configurable raw mapper retains its prior source as
`common/s08_result/reference/s08_map_real_targets_before_memory_resume.wls`.
The Kira extension binds the raw result to the exact executed mapper by
its recorded source hash, selecting the current or retained source. This
allows already running jobs to retain their original provenance. Neither
source selection nor resource bounds changes the cut mapping, targets,
reconstruction checks, or scalar integral definitions.

S05 projection resumes may set `POLARIZED_SIDIS_REAL_SECONDS` explicitly
(the default is 2400 seconds, with a checked maximum of 10800 seconds).
This changes only the native time bound. The 2 GiB operation limit and
4 GiB spin-reconstruction limit, all contractions, checks, and checkpoint
identities remain unchanged. The scheduler and process-tree limits must
cover the selected bound. Preserve the preceding source in
`common/s05_result/reference/s05_real_spin_response_before_projection_time_resume.wls`.

S05 may enable `POLARIZED_SIDIS_FACTORED_PAIR=1` after accepting the full
Hgg pair-assembly comparison in job `14782053`. The proof result is
`Hgg/s05_pair_assembly_result/s05_result.wl`, SHA256
`1cd27950314f1eda6f9652fe86521677fa2ad5949ad39854c62b4060af4b57f6`.
Install its exact saved conjugation, photon-pair and scalar-pair definitions;
verify the proof's source, original production source and shared inputs.
Every new expression must satisfy the measured exact rational-head,
integer-power and native real-symbol gates. Preserve the complete trace,
projection, cache, sum and final channel acceptance contracts. The protected
source comparison permits only this pair-completion substitution in addition
to the already accepted photon-index interface change. The preceding source
is retained as `s05_result/reference/s05_real_spin_response_before_factored_pairs.wls`.
The Hgg README records the executed comparison and timing evidence.

S05 may set `POLARIZED_SIDIS_REAL_MEMORY_GIB` to an integer from 2 through 4
when a recorded projection exceeds the default 2 GiB operation cap. Keep
the spin-reconstruction cap at 4 GiB and the scheduler/process-tree bounds
consistent with the allocation. This resource parameter changes no algebra,
input hash, scientific checkpoint, or acceptance predicate. The complete
pre-parameter source is retained as
`s05_result/reference/s05_real_spin_response_before_projection_memory_resume.wls`
with SHA256 `2f207ae75537666abcc6809fef00ff18c48e61c73efebdabdb38b66c4f1459f0`.

## S14 compact final-storage contract

`s14_assemble_finite_compact.wls` preserves the complete accepted phase-series
assembly and changes only its final file writer. Source hashes and a reversible
text substitution must establish that the assembly equations and acceptance
gates are unchanged. Release the already-consumed real, Born, virtual and
subtraction inputs before the final write. Use the native compression and
exact `Get` equality mechanism already exercised by the S15 compact writer;
enforce the same 128 MiB per-file bound and record the storage source hash.

This entry point requires the actual channel's accepted S12/S13/S11 inputs
and allocation-bound execution settings. Its contract is not an executed
acceptance result: require the channel's complete pole cancellation, GitHub
U/U comparisons, native file round trip and execution receipt before use by
S15. The unchanged S14 checkpoints retain their mathematical input identity.

The native source-syntax preflight `s14_check_compact_storage.wls` passed
Hoffman2 job `14811692` on `n6444`, using the reference's `-script` invocation.
Its eight syntax/interface checks bind compact assembly source SHA256
`3e570b82f4f5957c099fdd0c14fb8e6b7592ad0b94d9b9404c96d31d53c0440b`.
`s14_compact_syntax_result/s14_checks.json` has SHA256
`d07f1c8bf0456d4dcddec2e3e250ea562fe380fdc2956060f484068030c3ebf9`;
the execution receipt in the same directory has SHA256
`d0f21296930eb773610210961ccd95350d9a2c2c6ceee1a674ceb8b2c88a8167`.
The job used 28.143693 seconds and 233,529,344 bytes maximum child RSS.
This validates source syntax and the initialization boundary only; it
executes no physics and does not accept a finite S14 output.
