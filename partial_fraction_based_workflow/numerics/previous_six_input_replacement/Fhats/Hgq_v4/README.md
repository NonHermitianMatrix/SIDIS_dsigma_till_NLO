# Hgq_v4

This is the user-requested fresh calculation of the incoming-gluon,
observed-quark SIDIS channel. Its algorithms are adapted from `../Hqg_v3`.
The physics reference is the supplied paper, arXiv:1903.01529, especially
Table I, Eq. (46), and Appendices B, D and E. Archived Hgq attempts and
authors' channel coefficients are not production inputs.

## Conventions

The incoming photon and gluon momenta are q and p. The observed quark is
k1. Born and virtual recoil is antiquark k2; real recoil is antiquark k2
and gluon k3. All partons are massless and q squared is -Q2. The observed
quark flavor and its charge eq remain fixed; Nf counts closed massless
quark flavors. The final hats retain symbolic color, regulator, kinematics,
charge, coupling and scale dependence.

FeynArts generates gamma* g -> q qbar and gamma* g -> q qbar g. It also
generates the auxiliary gamma* q -> q g Born needed by Eq. (46), and a
photon-quark vertex for an independent measurement of the model charge.
No amplitude, Born coefficient, normalization result, diagram count,
integration coefficient or checkpoint is copied from Hqg.

Physical gluon polarization sums are used. The incoming-gluon spin count
is derived by contracting the D-dimensional physical polarization sum;
its color dimension and the kernel color constants are derived with
FeynCalc. The quark spin-average convention for the auxiliary Born is the
same unpolarized massless-quark convention used in the paper/Hqg method.
The model charge is measured from the generated photon-quark vertex
against the defining unit-charge vector-current trace. It is removed
before attaching symbolic eq. Tagging/symmetry weights are counted from
the generated external-species ledger, not inherited from Hqg.

The external Hgq Eq. (46) species routes must be enumerated in the code:
PDF Hgq_LO with Pgg and Hqq_LO with Pqg; FF Hgq_LO with Pqq. Kernel CF is
independent of the Hgq Born color factor. Each new kernel normalization,
especially the per-flavor Pqg convention, is checked against the paper.
Momentum maps, delta roots, Jacobians and Ppp rescaling are derived from
the invariant definitions. D-dimensional Born factors survive subtraction.

The explicit loop measure and Package-X scale convention follow Hqg:
Package-X supplies ScaleMu^(2 epsilon); its implicit prefactor supplies
only (2 Pi)^(-4+2 epsilon). UV and IR poles remain separate through the
UV gate. Hermitian conjugation, generated external residues and MS coupling
renormalization precede regulator identification. Couplings eq^2 gs^4 are
removed from NLO contractions; the paper hard-tensor normalization is
applied only during final assembly.

## Stage contracts and correspondence

| New stage | Hqg algorithm | Contract |
|---|---|---|
| S01 generate amplitudes | S04 | Fresh Hgq Born, real and virtual amplitudes, auxiliary Hqq Born and charge vertex; mass, coupling-order and species gates; source-bound amplitude/diagram exports. |
| S02 Born and projectors | S02 and Born part of S05 | Derive scalar products, model charge, color and incoming averages; calculate both Born contractions for Hgq and auxiliary Hqq; require photon/gluon Ward identities; derive the final structure-function projectors. |
| S03 real contractions | S05 | Pairwise spin/color contractions with physical incoming/final gluon sums; derive tagging weight; require all photon/gluon Ward sums and complete scalar rational outputs. |
| S04 virtual integrals | S06 | Diagram-wise Born interference, PV reduction and analytic Package-X integrals with distinct UV/IR poles; no unresolved loop objects. |
| S05 angular basis | S07 | Discover denominators from S03 and derive Appendix D reduction/geometry; require exact reconstruction. |
| S06 angular masters | S08 | Evaluate precisely the masters requested by S05 with the defining integral/series methods and required regulator depth. |
| S07 UV renormalization | S09 | Generate two-point functions and external residues; derive and cross-check the coupling UV residue; require complete UV cancellation. |
| S08 collinear subtraction | S10 | Enumerate Eq. (46) routes and derive kernel normalization, maps and distribution actions; require support, auxiliary-pole and ordinary-reconstruction gates. |
| S09 real phase space | S11 | Apply the paper measure and finite-epsilon soft treatment to fresh Hgq angular terms; reconstruct regulated distributions with exact branch assumptions. |
| S10 final hats | S12 | Combine real, virtual and subtraction terms; require exact cancellation of every negative regulator coefficient for both contractions and distribution components; derive finite hats and required coordinate-boundary values. |

Every stage consumes only new Hgq_v4 results. Source and input hashes bind
checkpoints. Existing Hqg cache-reuse whitelists and channel-specific term,
master and diagram counts are discarded. General mathematical algorithms
may be reused with freshly derived Hgq inputs and reconstruction gates.

## Memory and execution

The user's cluster instruction supersedes local production execution.
Main sources and accepted results remain in local `scripts/Hgq_v4`.
The execution copy is on Hoffman2 at
`/u/scratch/r/rushil/AI_Assisted_SIDIS/Hgq_v4_20260906`.
Production uses the Grid Engine scheduler and its Mathematica 13.1
`/u/local/apps/mathematica/13.1/Executables/WolframKernel` on compute nodes.
Each submitted source is hash-checked after transfer. Results, caches,
logs and execution receipts return to the local folder before acceptance.
An SSH control socket in the ignored `.cluster/` directory is transient
transport state; no password is written into task files or logs.

Long jobs have persistent inline monitors of process-tree memory and
meaningful log output. Per-operation symbolic limits, a process-tree RSS
ceiling and an available-RAM reserve stop work before exhausting RAM.
Checkpoint complete pieces and keep kinematic factors intact; expand only
the regulator when possible. No runner/monitor helper files are needed.
Parallel work is limited to independent pieces that fit RAM and the local
license; intrinsically serial algebra remains serial. Exact acceptance
gates are retained when changing evaluation order or resuming.

## Artifact acceptance and downstream boundary

This ledger defines the contracts; it does not mark an unrun stage accepted.
Accepted artifact identities and tool outputs will be added here after each
stage succeeds. Current execution status is recorded only in
`../progress.md`. The requested deliverable is the independently calculated
symbolic Hgq F hats. Authors' coefficients cannot set a finite term or repair
a failed pole gate. Optional numerical/author comparisons are downstream
of the frozen independent calculation.

## Accepted S01

Hoffman2 job 14687395 ran on n7136 with Mathematica 13.1.0 and FeynCalc
10.2.1. The generated amplitude counts are Born 2, real 8, virtual 15,
auxiliary Hqq Born 2 and charge vertex 1. Every mass, species and
graph-derived coupling-order gate passed; the job exited zero with
S01_SUCCESS. Sources and outputs are present locally.

- `s01_generate_amplitudes.wl`: SHA256 `bd03ca4e615f35e19a470fcb3d317b6484f46fed71e1729cd393cecbd3655c6b`.
- `s01_result.wl`: SHA256 `90ea5cf71f391c94994c583fc730d56dc8796838c9fd5ae22c9363a3abcee8eb`.
- `s01_diagrams.wl`: SHA256 `06e88b5e43e083678244bf65df534032ca7fc216b18b6b26b78541e48719bc10`.
- `s01_cache/`: complete request-level amplitude/diagram checkpoints bound
  to the source, request and software versions.
- `s01_run.log`, `s01_submission.json`, `s01_execution.json`: execution evidence.

The kernel reported MaxMemoryUsed 122566192 bytes. The first monitor's
process-group RSS sample was zero and is not a valid memory measurement;
subsequent monitoring tracks the launched PID and all descendants. The
stage's operation limit and scheduler memory allocation were active.
The S01 data remain valid; this monitoring correction changes no physics.

S02 must consume the generated charge vertex and the two generated Born
processes. It must establish its own charge, averages, Ward identities and
projectors before any real or virtual contraction is accepted.

S02 charge normalization compares two g-contracted currents, matching the
paper Pg convention. Its initial reference-trace sign mismatch was caught
before any accepted Born result; the corrected comparison is gated in S02.
The revised monitor samples /proc for the kernel PID and descendants through
stdout completion; job 14687439 measured 180465664 bytes peak RSS.

## Accepted S02

Job 14687440 on n7138 passed the independent vertex charge
measurement, both Hgq and auxiliary Hqq Born Ward identities, invariant
reconstruction and agreement of generated projectors with paper Eq. 9.
The D-dependent initial averages and both Born contractions are in
`s02_result.wl`; downstream stages must use these measured quantities.
The diagnostic sign mismatch was corrected before this accepted run.

- `s02_born_and_projectors.wl`: SHA256 `4cdd00d8d5049eb190fb6b3e11a856b507083f9e7ab51713b912df3723f272e1`.
- `s02_result.wl`: SHA256 `81da52572b7ee1ae58a9002f54335ae22425859c69d090a284d0b3c7233973da`.
- `s02_run.log`, `s02_submission.json`, `s02_execution.json`: accepted run evidence.

Peak sampled process-tree RSS was 337457152 bytes; the kernel reported
MaxMemoryUsed 269515672 bytes. No memory guard fired.

S03 and S04 use independent pair/diagram tasks with four allocated slots,
up to four local parallel kernels, 2 GiB per-operation limits and a
16 GiB process-tree RSS ceiling within the 32 GiB scheduler allocation.
Kernel host/version equality is gated before parallel contraction.
Each complete task writes a distinct source/input/version-bound cache.

S07 uses the Dirac-adjoint definition of the antiquark field: its field
renormalization is generated by conjugating the calculated quark factor,
and its equality is checked. External multiplicities come from the S01
Born species lists after removing the photon. Coupling powers are read
from the generated Born coupling degrees. S08 obtains Pqq/Pqg kernel
normalizations directly from paper Eqs. 51/52; Pgg normalization is solved
using the gluon momentum sum rule with the quark/antiquark multiplicity
counted from the species set, then gated independently of the hats.

## Accepted S04

Job 14687444 on n6405 completed all fresh virtual interference, PV and
Package-X gates for both projectors. The spacelike-bubble backend gate
kept UV distinct from IR and verified the explicit loop measure.
`s04_result.wl` is the interference before Hermitian conjugation; S07
must supply generated external residues and MS renormalization.
No IR cancellation or final hats are claimed by this stage.

- `s04_virtual_integrals.wl`: SHA256 `453e1ef3ac7893e0867df417f293b637c957a32c0ac4bde7f2ce1a2d16fd2d50`.
- `s04_result.wl`: SHA256 `9e9b4dc6c17659c05603707affad20324595afe67b1dca824c81460642748f2a`.
- `s04_backend.wl`: SHA256 `c8f236776480349abaf3f6465558ea0ff448ded2d5ccabbecd91e81633d73b90`.
- `s04_cache/`: source/input/version-bound completed diagram integrals.
- `s04_run.log`, `s04_submission.json`, `s04_execution.json`: execution evidence.

Peak sampled RSS was 485912576 bytes. The budget expression
selected serial execution; no parallel speedup occurred. Later stages use
an explicit local-kernel launch and report actual budget inputs.

## Accepted S08

Job 14687454 on n7404 passed the paper-kernel normalization, quark
number/momentum and gluon momentum sum rules, species-route enumeration,
root support, endpoint-pole and ordinary-convolution reconstruction gates.
The exact generated routes and normalization association are stored in
`s08_result.wl`, together with D-dimensional convolution coefficients and
the expanded MS counterterms. The MS factor has no added scale power,
as specified below Eqs. 49-50 in the paper.

- `s08_collinear_subtraction.wl`: SHA256 `17fedfd567c9dc835f81675115f8ba7fde925e1b4722fa4ee3de071454a54011`.
- `s08_result.wl`: SHA256 `54064717ee201b62d798e078f00670e3bb459389a6cf4a82d86c613be7d32fbf`.
- `s08_run.log`, `s08_submission.json`, `s08_execution.json`: run evidence.

The short algebraic stage ran serially with peak sampled RSS 354963456
bytes. It does not set or fit any real/virtual coefficient.

## Accepted S07

Job 14687461 on n7441 passed generated two-point coupling/color gates,
gluon transversality, on-shell scaleless UV/IR residue checks, the
Dirac-adjoint residue identity, agreement of coupling UV residues from
both projectors, and complete UV cancellation for Pg and Ppp.
S07 sets no finite or IR coefficient by fitting. Its renormalized virtual
Laurent series is ready for S10 after the real distributions are accepted.

- `s07_renormalize_virtual.wl`: SHA256 `a8aace38a4ea7d32fb98636dd5ab58f2a5d51a711ad7f65d24aa96173bc3708c`.
- `s07_result.wl`: SHA256 `d5a881ef4cb181944b0752b3c837937a5cb0472f3ec86db67fb8040a7d6999b9`.
- `s07_self_energies.wl`: SHA256 `da8c75c5cf6793e56b13a99f55a5b6930a7b8500013f5fa9956d3d93e01193aa`.
- `s07_one_flavor_diagrams.wl`: SHA256 `17397d87e638dd88994acb0d3076341f20ef6355b12c6578da49c476c4613125`.
- `s07_run.log`, `s07_submission.json`, `s07_execution.json`: run evidence.

Peak sampled process-tree RSS was 199737344 bytes; no guard fired.

The S03/S04/S07 execution logs record serial selection: the
runtime reports one processor despite NSLOTS=4, and the old
SubKernels`LocalKernels` context is unavailable. This changes no symbolic
coefficient. Unrun angular stages use the current in-memory local kernel
configuration with the explicit cluster executable and allocation bound.

## Accepted S03

Hoffman2 job 14687443 on n7140 exited zero with S03_SUCCESS.
The stage-specific gates in its source passed; its returned result is bound
to the listed source and inherited input hashes. The result and checkpoints
are local. Peak sampled process-tree RSS was 462573568 bytes;
no memory or inactivity guard fired.

- `s03_contract_real.wl`: SHA256 `32aa8407bc8d87c63231bc295f09431ee9f168c428f08bc6c52683ddef097225`.
- `s03_result.wl`: SHA256 `286b9586de2bec744667421d4b16d1081a0df6e18fda0e328918c46b1dbd0649`.
- `s03_Pg.wl`: SHA256 `928702b9e0bc582958503ab0dd7b41fad40f22390ce94c028e3d60c5d70bb533`.
- `s03_Ppp.wl`: SHA256 `bf948db7e32a9a7d826d7ee5fe3ce1c8ab1390b7fca602d0d2af1ddb24f07243`.
- `s03_PhotonWard.wl`: SHA256 `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa`.
- `s03_GluonPWard.wl`: SHA256 `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa`.
- `s03_Gluon3Ward.wl`: SHA256 `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa`.
- `s03_cache/`: source/input-bound production checkpoints.
- `s03_run.log`, `s03_submission.json`, `s03_execution.json`: execution evidence.

Selected tool evidence:

```text
"Pg"" complete; leaves = "58887
"Ppp"" complete; leaves = "55831
"PASS: ""PhotonWard"
"PhotonWard"" complete; leaves = "1
"PASS: ""GluonPWard"
"GluonPWard"" complete; leaves = "1
"PASS: ""Gluon3Ward"
"Gluon3Ward"" complete; leaves = "1
```

All three real Ward sums are zero. S05 must consume these fresh scalar
contractions and the S02-derived real scalar products. The generated tagging
weight and initial average are stored in the result.

S05 resolves conditional expressions produced by Mathematica 13.1 Solve
using FullSimplify under the explicit physical region before extracting
angular polynomial coefficients. An unresolved-condition gate precedes
coefficient extraction; the invariant and rational-reconstruction gates
remain unchanged. The first S05 run stopped before any basis result.

For Mathematica 13.1, the in-memory local configuration uses the literal
localhost target, KernelCommand, KernelCount and TimeConstraint. The later
Local alias and LimitByLicense option are not used. Host/version checks
gate the actual workers. No local-kernel launch problem alters a physics
coefficient or grants permission to bypass a mathematical acceptance gate.

S05 also resolves the linear denominator-substitution Solve conditions
under the physical region before CoefficientRules. Both substitutions are
gated for unresolved ConditionalExpression wrappers; exact angular
reconstruction remains the acceptance condition. The first correction
passed the frame/geometry gates and launched two compute-node workers,
then stopped at the coefficient gate before producing a basis result.

## Accepted S05

Hoffman2 job 14687539 on n6442 exited zero with S05_SUCCESS.
The stage-specific gates in its source passed; its returned result is bound
to the listed source and inherited input hashes. The result and checkpoints
are local. Peak sampled process-tree RSS was 309682176 bytes;
no memory or inactivity guard fired.

- `s05_real_angular_basis.wl`: SHA256 `b736588b9233349d5c70b181d55a20ac4ffe4faaebc01ad7721aab5af0bf9290`.
- `s05_result.wl`: SHA256 `4aefd2850222e9a9b05a7751471215530b7d377b1bbf516e56f88d38d28cdec5`.
- `s05_run.log`, `s05_submission.json`, `s05_execution.json`: execution evidence.

Selected tool evidence:

```text
"Angular worker count = "2
"\"Pg\"\": \"187\" angular monomials accepted.\"\n"
"\"Ppp\"\": \"182\" angular monomials accepted.\"\n"
```

Both projector bases reconstruct their input exactly. S06 must evaluate the
master keys discovered from these denominator geometries and powers.

Parallel-memory measurement correction: the earlier ps-column parsing
counted only the main kernel. Its S05 parallel RSS figure is not a total
worker peak. A direct assigned-node measurement during S06 found five
job kernels with total RSS 3310243840 bytes. A persistent job-ID-filtered
all-kernel guard now supplements the active chain, and future launch
templates read /proc status directly. Per-operation, address-space and
scheduler limits remained active throughout. The supplemental per-stage
*_memory.json files state their sampling interval explicitly; they do not
claim coverage before attachment. No physics artifact changes.

S06 derives the polar integration-by-parts relation after changing to the
algebraic polar coordinate. Mathematica derives the coordinate domain and
both substitutions; their defining equations, the regulated boundary
terms, the monomial reconstruction and isolation of the requested master
are acceptance gates. Polynomial polar contributions are expanded term by
term, with an exact polynomial-division reconstruction check. No relation
coefficient is supplied by hand. Operations have a 1800-second limit and
a 2 GiB allocation cap. Up to eight compute-node workers share a 16 GiB
combined RSS ceiling within a 64 GiB scheduler allocation. The stopped
pre-correction source and cache are retained under
`s06_previous_14687550/` for provenance, and are not production inputs.

The polynomial-division reconstruction gate reduces its residual with
Expand and FullSimplify under the regulated real integration domain.
It requires an exact zero and prints any unresolved residual before
stopping. The earlier gate attempt and its cache are preserved under
`s06_previous_14687634/`; they are not accepted inputs.

S06 isolates the algebraic IBP derivation in Block with inherited
$Assumptions cleared. Every physical assumption remains explicit in its
boundary, domain, substitution and reconstruction checks. The isolated
cluster check s06_ibp_assumptions_check.json/log passed every recurrence
gate; the globally constrained check timed out in Solve. The recursive
master evaluation is outside this Block.

The source and complete cache from job 14687645 are preserved in
`s06_previous_14687645/`. A source comparison verified that calculation
code outside the tested scope change is identical. Only that exact prior
source hash can supply reusable checkpoints, and a runtime gate rejects
any prior checkpoint from the mixedIBP branch. Original cache input hashes
remain intact and are listed in AcceptedCacheInputHashes. The missing or
changed-branch masters must run under the new source hash. This exception
uses only current-channel, unaffected checkpoints.

Future launchers keep the main kernel in the scheduler process session.
Post-cancellation cleanup checks exact job ID and owner before signalling
any remaining task kernels. The combined RSS guard remains active.

S06 final angular expressions use Collect in epsilon with Factor on
coefficients. An exact Together reconstruction gate protects this change
of representation. The original ML(2,-6) integral with this final operation
passed its isolated cluster check in s06_polynomial_factoring_check.json/log.
The integration code, including its azimuthal moments, is unchanged.
The timing check established that the former global FullSimplify was the
remaining bottleneck; the experimental azimuth normalization is not used.

The exact source and 82 completed master checkpoints from job 14687698
are preserved in s06_previous_14687698/. Their formulas remain valid;
the source comparison changed only final representation and resume
bookkeeping. Its source hash is gated before its original input hash is
accepted alongside the prior unaffected checkpoints. New results retain
all original input-hash provenance in AcceptedCacheInputHashes.

## Accepted S06

Hoffman2 job 14687759 on n6442 exited zero with S06_SUCCESS.
The stage-specific gates in its source passed; its returned result is bound
to the listed source and inherited input hashes. The result and checkpoints
are local. Peak sampled process-tree RSS was 1456160768 bytes;
no memory or inactivity guard fired.

- `s06_angular_integrals.wl`: SHA256 `362e2874c538ca3056c9ca44def30a47c26d0bcd41cd51f6eb9659b58b49bbf5`.
- `s06_result.wl`: SHA256 `8b38d1c0bae729ca06293b2cfbafa6219d1f722354090cff500bc5122b29d76e`.
- `s06_required.wl`: SHA256 `f51e44a6045da74b9df37550302dce7d7bde0b031c319566c4708949d3f85204`.
- `s06_cache/`: source/input-bound production checkpoints.
- `s06_run.log`, `s06_submission.json`, `s06_execution.json`: execution evidence.

Selected tool evidence:

```text
"Required angular masters: "83
"Angular worker count = "8
```

S09 must retain the stored coalescing factor before taking the recoil endpoint;
its finite-epsilon soft treatment is required for the delta distribution.

S09 saves s09_laurent_unreduced_<process>.wl when its soft-series
representation gate fails. It records the exact source/input-bound
expression, returned series, term and assumptions; these are diagnostic
artifacts, never accepted real distributions. S10 cannot consume a failed
S09 run. The first failed attempt is preserved in s09_previous_14687763/.

S09 takes every soft recoil series with explicit s23 > 0 in addition
to its branch assumptions. This is the physical one-sided soft limit.
The saved Pg term 30 check s09_branch_order_check.json/log returned a
canonical SeriesData with no residual Floor/Ceiling corrections and
sufficient order after this assumption was included. Production does not
insert branch constants from that check.

The soft-series gate now requires integer Laurent powers and enough
returned order to cover every requested pole coefficient, before a zero
normal part may be discarded. Previous partial caches are versioned under
s09_previous_14687775/ and cannot be reused. S09 must regenerate both
projectors and both sign branches with this precision contract.

S09 normalizes mixed-master endpoint functions before substituting recoil
kinematics. Wolfram derives the DLMF 25.12.4 inversion formula from its
derivative and an exact anchor, proves each transformed argument negative,
and uses TrigToExp with derivative/anchor gates for inverse hyperbolic
functions. Physical-domain logarithms are combined before Series.
The isolated s09_log_endpoint_check.json/log (job 14687949) passed all
three coefficient endpoint limits and the complete Pg term 65 recoil
series. No angular integral, physics coefficient or regulator power was
changed. The source and partial cache of failed run 14687798 are preserved
in s09_previous_14687798/ and are not accepted cache inputs.
S09 must regenerate its term caches and pass all distribution gates;
S10 remains conditional on accepted S09.

## Accepted S09

Hoffman2 job 14687952 on n6406 exited zero with S09_SUCCESS.
The stage-specific gates in its source passed; its returned result is bound
to the listed source and inherited input hashes. The result and checkpoints
are local. Peak sampled process-tree RSS was 2354106368 bytes;
no memory or inactivity guard fired.

- `s09_real_phase_space.wl`: SHA256 `39568d8eca4cfd7c4ee8bc72e14a124bebb0cebaa1af19f7c360f016966b0c92`.
- `s09_result.wl`: SHA256 `692c40b70f63aae7d0bb8149879af6c0c50f916b38607aee5049b659d3dab44a`.
- `s09_cache/`: source/input-bound production checkpoints.
- `s09_run.log`, `s09_submission.json`, `s09_execution.json`: execution evidence.

Selected tool evidence:

```text
"Angular worker count = "4
```

The result stores both sign branches, regulated endpoint coefficients and
Delta/L0/L1/Regular components. S10 must gate their reconstruction and every
negative regulator coefficient with the accepted S07 and S08 results.

## Accepted S10

Hoffman2 job 14687964 on n7405 exited zero with S10_SUCCESS.
The stage-specific gates in its source passed; its returned result is bound
to the listed source and inherited input hashes. The result and checkpoints
are local. Peak sampled process-tree RSS was 464027648 bytes;
no memory or inactivity guard fired.

- `s10_final_hats.wl`: SHA256 `809627572423ddd23376e625c19ca80d01023143ca3224891f9bd2db2fbdda62`.
- `s10_result.wl`: SHA256 `575ea96993eb9a86cfeddb6e10d61c0147e3bf74d35bc25eaf3dbb03fceb9bfe`.
- `s10_poles.wl`: SHA256 `43edde6d88a5ba15567a8fc09a626867596a46e6e78f22f981a2914592cca1ed`.
- `s10_cache/`: source/input-bound production checkpoints.
- `s10_run.log`, `s10_submission.json`, `s10_execution.json`: execution evidence.

Selected tool evidence:

```text
"PASS: ""soft-coordinate boundary limits agree"
"PASS: ""soft-coordinate boundary limits agree"
"PASS: ""soft-coordinate boundary limits agree"
"PASS: ""soft-coordinate boundary limits agree"
"PASS: ""soft-coordinate boundary limits agree"
"PASS: ""soft-coordinate boundary limits agree"
"PASS: ""soft-coordinate boundary limits agree"
"PASS: ""soft-coordinate boundary limits agree"
```

The result contains StructureFunctions, F1/F2 Hats, finite contractions,
branch domains and the accepted t=-s boundary. The pole file records all
accepted cancellations. Consumers must use the documented plus basis and
branch coordinates. Authors coefficients were not inputs.

## Reading the final result

Load the local result in Wolfram Language:

```wolfram
data = Get["/home/physics/projects/AI_Assisted_SIDIS/scripts/Hgq_v4/s10_result.wl"];
data["StructureFunctions"]["F1"]
data["StructureFunctions"]["F2"]
```

StructureFunctions contains the complete LO + NLO symbolic distributions.
For individual coefficients, use data["Hats"][name]["LODelta"] and
data["Hats"][name]["NLO"][sign][component], where name is "F1" or "F2",
sign is 1 or -1, and component is "Delta", "L0", "L1" or "Regular".
Use BranchCoordinates and BranchDomains for these coefficient forms,
BoundaryAtTEqualsMinusS on the coordinate boundary, and PhysicalRegion
for the allowed kinematics. PlusDistribution is the formal distribution
specified by PlusDefinition, not a function to evaluate pointwise.

The accepted S10 run passed all ordinary distribution reconstructions,
every negative regulator coefficient and all eight two-sided boundary
comparisons. RegulatorCancellationPassed is True. The executed calculation
retains symbolic kinematics, scales, colors, flavor count, charge and
coupling. No authors coefficient enters the calculation.

## Authorized numerical checks

The user requested bigTMD_check/ and madgraph_check/ after the independent
S10 result was fixed. Their READMEs define the comparison contracts.
BigTMD tests final distribution coefficients and ordinary NLO values;
MadGraph tests Born/real tree Pg/Ppp. Numerical evaluation is authorized
for these checks. Neither reference supplies a production correction.

## Numerical comparison artifacts

`bigTMD_check/s03_result.json` (SHA256 `6f2cfb8e430303347190bfa44c74ae8324f20539b734a33d2781a28a30999194`) and `bigTMD_check/bigtmd_minus_local.md` report agreement for 30 canonical coefficient rows and six direct NLO density rows at three deterministic points. Maximum direct relative difference: 2.5726226389472912e-14. The benchmark covers only the positive interior/endpoint branch, SU(3), unit couplings, mu=Q and nf=4. The exact-reference decimal reconstruction and distribution transport are documented in that folder. Numerical agreement does not replace the independent production gates.

`madgraph_check/s05_result.json` (SHA256 `8757ed8318c39b21bcbdc397058f33f375a1178e9a73675f295478dff98894d3`) and `madgraph_check/madgraph_minus_local.md` report Born agreement and an unresolved real-emission sign discrepancy. The supplemental direct-square attempt timed out before a result after passing its momentum-map checks. This tree-validation limitation remains attached to the frozen S03/S10 artifacts; authors agreement does not clear it. No production source, result or cache was changed by these comparisons. The comparison-folder READMEs record source/result/log identities and execution limits.


## Hgq_v4 numerical consumer contract

The user requested replacement of Hgq_v3 in `../numerics/Fhats` by this channel's accepted `s10_result.wl`, with the source-bound `s10_poles.wl` acceptance receipt. The numerical consumer must verify the accepted source/result hashes, regulator-cancellation flag, both branch domains, LO/NLO charge and coupling coverage, coordinate-boundary treatment and the stored plus-distribution definition. It must derive its distribution action from this v4 input and compare every exported coefficient with direct evaluation of the frozen expression before convolution. No v4 producer or coefficient is modified by this consumer.

The consumer retains MRST2002 NLO, both KKP/Kretzer neutral-pion FFs, the existing common scale and H1 cuts. The other five channels may reuse accepted numerical estimates only after unchanged mathematical inputs/programs, recovered full iteration means/covariances and the independent-sampling combination are gated. Otherwise affected bins are reintegrated. All final precision/stability checks still apply. BigTMD comparison coverage and the unresolved MadGraph real-emission comparison remain the limitations recorded above. The production cluster instructions concern this channel's upstream symbolic stages; this numerical consumer uses the existing local numerics runtime and does not rerun those upstream stages.
