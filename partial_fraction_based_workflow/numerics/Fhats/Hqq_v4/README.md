# Hqq_v4

Fresh incoming-quark, observed-quark SIDIS calculation requested by the user.
The authoritative physics reference is the supplied large-transverse-momentum
SIDIS paper. The standalone NLO QCD reference supplies tool and derivation
methods. The current staged Hqg/Hgq workflow supplies general algorithms;
all Hqq amplitudes, species weights, charge sectors and normalizations must
be generated and gated for this channel. No older Hqq result or published
author coefficient is an independent production input.

Run on Hoffman2; primary scripts, exact results, checkpoints and execution
evidence remain local in this directory. Every script has an sNN_ prefix.
Use source/input-bound checkpoints, bounded per-operation memory, a combined
process-memory guard and persistent inline job monitors. Keep real pieces
separate through angular and distribution extraction; do not load all large
intermediates together. Only ../progress.md records live status.

Before each stage is implemented, this ledger must specify its inputs,
conventions and tool-checkable acceptance contract. No unrun stage or final
hat is accepted by this initial contract. Physics quantities are produced
only by executed tools, with exact reconstruction, Ward, UV/IR and finite
result gates before downstream use.

## S01 contract: fresh amplitudes

Use FeynArts SMQCD with incoming photon q and quark p; the observed quark
has momentum k1. Born/virtual recoil is gluon k2. The three real requests
from paper Table I are qgg, same-flavor qq qbar, and distinct-flavor q qprime
qbarprime, with the observed flavor always at k1. Generate auxiliary Hgq
and Hqg Born amplitudes within Hqq_v4 for Eq. 46. Generate primary and
secondary photon-quark vertices for charge normalization. All partons are
massless; q squared is -Q2.

Generate topologies and insert fields separately for every request. Preserve
raw amplitudes, inserted diagrams, momentum/species requests, actual graph
counts, coupling degrees, source/input hashes and package versions. Derive
coupling degrees from connected-graph valence identities and gate every
converted amplitude. Identical-particle tagging weights and distinct-flavor
charge sectors are determined downstream from these generated objects,
not prescribed as numeric weights. Closed-loop flavor multiplicity remains
symbolic downstream. WFCorrections are excluded at generation and restored
from generated residues during renormalization.

S01 runs serially because FeynArts initializes shared model state; generation
is bounded per request and source-bound request checkpoints permit resume.
Acceptance requires complete nonzero massless amplitude lists, identified
external species and graph-derived coupling-order gates. No Born/real
contraction or F hat is asserted by S01.

## S02 contract — Born tensors and projectors

Input is the source-verified s01_result.wl. Derive model charge normalization from the photon vertex and a defining unit current; gate the primary/secondary vertex relative sign. Derive quark spin multiplicity by the trace of an idempotent positive-energy Dirac projector, gluon spin multiplicity by its physical polarization tensor, and color dimensions/Casimirs by FeynCalc traces. Contract Hqq, auxiliary Hgq and auxiliary Hqg Born inputs with their generated incoming species and outgoing tag. Derive scalar products from invariant equations and Eq. 9 projectors from the tensor decomposition. Require scalar exact expressions and all photon/gluon Ward identities. Output s02_result.wl; cluster execution is serial because these small Born contractions share FeynCalc scalar-product definitions.

S01 accepted execution: Hoffman2 job 14688983 on n7440, source SHA256 a2528dded66aa9b0b38d2e57601497cef9215fa0bc97a40b1024894e2a76572b. Artifacts: s01_result.wl, s01_diagrams.wl, per-request s01_cache, s01_run.log, s01_execution.json. Result SHA256 0dc987fe060db67a8fa060945380760b0ceb788843882e760c0a79959852297a. Generated nonzero/massless/coupling-order/species gates passed. No authors input.

S02 accepted execution: job 14688987, source SHA256 a3671e72f49871a6268c4fcec05364c102a4572baeae1bd6d2414479dee12776, result SHA256 000d506ed74e608d51b58d2dedf66d287ce7a1e66c894132e6451b7e0dcc26de. Artifacts s02_result.wl, s02_run.log and s02_execution.json contain the measured spin/color/charge values, fresh three-Born tensors, both invariant maps and Eq. 9 projectors. Every photon/gluon Ward and normalization gate passed.

## S03 contract — real contractions

Use only source-verified S01/S02. Derive gluon legs and the tag/factorial phase-space weight from each generated final state. Classify each distinct-flavor diagram by the actual photon-bearing open Dirac chain; preserve its charge-ratio degree through pairwise contraction. Derive the multiplicity of unobserved distinct flavors by a symbolic sum excluding the observed flavor. Keep nontrivial charge moments symbolic with their defining sums. Contract physical gluon polarizations and the photon metric/P-momentum projectors, with independent photon and gluon Ward identities for every charge component. Up to eight allocated local kernels perform separate pairs with unique source-bound checkpoints. Keep the separate sector/charge tensors through angular reduction; do not combine large real expressions. Output s03_result.wl and component tensors in s03_*.wl.

## S04 contract — one-loop integrals

Source-verified S01/S02; interfere each generated Hqq virtual diagram with the generated Born, using the outgoing-gluon physical polarization sum and measured incoming-quark average. Derive a spacelike bubble backend check, reduce with TID and evaluate with Package-X under the explicit paper loop measure. Preserve distinct UV/IR regulators and keep the Hermitian-conjugate operation for S07. Require elimination of spin/color/polarization objects, loop momentum and all unevaluated loop integrals. Up to eight allocated independent diagram workers; source-bound s04_cache. Output s04_result.wl and s04_backend.wl.

## S08 contract — Eq. 46 collinear subtraction

Use S01/S02 only. Get splitting kernels from FeynCalc and map them to paper Eqs. 51–53 by exact normalization ratios; require quark-number and quark/gluon momentum sum rules. Enumerate each generated Born only with its actual k1 tag, then select PDF/FF routes from Eq. 46 species matching. Derive rescaled invariants, convolution roots/Jacobians and pp-projector conversion. Use the paper PDF/FF measures and MS pole convention. Require support, endpoint and ordinary-distribution reconstruction gates. Output s08_result.wl with every selected route and its separate contribution. These small shared-symbol convolutions are serial.

S08 accepted execution: job 14689100, source SHA256 6b821fc64d1b8b593f6635dd49269a36b62588903c1681763a1e6b034cfe865d, result SHA256 3febb99ebac11172d1ce55b4315cf118b0cbc158b0d25a7fe1ae943b1371e6ea. s08_result.wl records the tool-selected PDF/FF routes, kernels, exact support/Jacobian/projector maps and MS counterterms. All kernel sum-rule, endpoint and reconstruction gates passed.

S03 accepted execution: job 14689094, source SHA256 7f79d99eea7a3da932f45cc1c7c4d30e91e0acf30111259b316c50fdc329c4e0, result SHA256 80839ff33a066dd1edefbbd39a22513cc726372631b85d68e0a5a3a2653ad4e2. Artifacts: s03_result.wl, separate component tensors, source-bound s03_cache, s03_run.log, s03_execution.json. All real photon/gluon Ward identities passed, including each independently identified distinct-flavor charge component. FlavorWeight and OtherChargeMomentDefinitions are mandatory downstream inputs.

## S05 contract — separate angular bases

Input accepted S03. Solve the paper unobserved-pair rest frame and reconstruct every invariant scalar product. Derive the spectator-exchange map and gate its involution, angular-variable representation and unit measure Jacobian; discard an integrated component only when its integrand is exactly exchange odd. Reduce each remaining tensor separately by null-space partial fractions and polynomial division. Include harmless zero-power invariant denominators so polynomial sectors have a complete angular basis. Require exact reconstruction for every retained tensor and physical geometry domains. Save per-tensor source-bound s05_cache checkpoints and s05_result.wl; up to eight independent allocated kernels. Carry every flavor/charge definition unchanged.

## S06 contract — requested angular masters

Input source-verified S05. Determine the required light/light and massive/light masters from all component bases, deduplicate and evaluate them in this channel. Use the paper angular-integral definitions, tool-derived hypergeometric seed/contiguous relations, explicit convergence-domain moments and boundary-gated angular integration by parts. Keep the coalescing epsilon power separate until S09. Gate symbolic evaluation and at most one angular pole. Output s06_result.wl, s06_required.wl and source-bound s06_cache; no other channel master result or checkpoint is eligible for reuse. Up to eight allocated master workers.

## S07 contract — UV renormalization and external residues

Inputs source-verified S01/S02/S04. Generate massless quark, gluon/ghost and one-flavor gluon self energies with FeynArts; derive propagator residues with separate UV/IR regulators and require gluon transversality and vanishing scaleless integrals after regulator identification. Count external fields and coupling powers from S01. Derive the coupling UV residue independently from both projectors, require agreement and kinematic independence, and gate complete UV cancellation before identifying regulators. Output s07_result.wl, s07_self_energies.wl and generated one-flavor diagrams. FeynArts generation is serial; independent residue evaluations use up to the number of allocated residue tasks.

## S09 contract — real phase space and distributions

Use accepted S05/S06, retain every sector/charge tensor separately and apply the paper Eq. 39 phase-space measure. Extract the soft expansion before losing the coalescing epsilon power, on both signs of s+t. Derive endpoint delta/plus coefficients using the regulated defining integrals. Require evaluated ordinary terms, recoil-independent soft coefficients, cancellation of stronger recoil powers and absence of a higher logarithmic plus distribution. Source-bound per-term and per-branch s09_cache; up to eight independent allocated workers. Output s09_result.wl with each component and its unchanged flavor/charge definitions.

## S10 contract — final symbolic Hqq F hats

Inputs source-verified S02/S03/S07/S08/S09. Gate reconstruction of every separate ordinary real component, apply the S03-derived flavor weights only to the compact distribution components, and combine real/renormalized-virtual/Eq. 46 counterterms. Check every negative regulator power for both tensor projectors, every distribution coefficient and both coordinate branches before extracting finite terms. Apply the derived Eq. 9 projectors and the paper coupling/hard-tensor normalization only after cancellation. Require finite matching one-sided limits at t=-s. Output s10_result.wl with F1/F2, LO delta, NLO delta/L0/L1/regular coefficients, branch domains and boundary values, plus s10_poles.wl and source-bound s10_cache. Final assembly is serial to avoid concurrent writes to the shared acceptance record; independent real/loop stages already use allocated parallel workers. No authors coefficients are inputs.

S04 accepted execution: job 14689163, source SHA256 2015db73f067bfed4515e5ae1d6af5305aba419c50cf4536a9bab35af7b0ba1b, result SHA256 14f995edcb1745a80eb97ac024ae15212fa35c665a04abd298961910b3183522. Artifacts: s04_result.wl, s04_backend.wl, source-bound s04_cache, s04_run.log and s04_execution.json. Worker startup uses explicit Global package-loader options; every worker reproduced the main UV/IR bubble before diagram work. All PV and analytic loop-evaluation gates passed. The failed initial source is retained under s04_previous_14689098 for provenance and is not a downstream input.

S07 accepted execution: job 14689165, source SHA256 113012c3858223143430a55c979c3b0611a85dc3ba86b4c68a2363522e86d0ff, result SHA256 6426b1a168844dfbb218209b1c5f3db80a03b7c428b904f639dab69eb26c2103. Artifacts: s07_result.wl, s07_self_energies.wl, s07_one_flavor_diagrams.wl, s07_run.log and s07_execution.json. Generated gluon self energies are transverse; scaleless residues have separate cancelling UV/IR parts; both projectors determined the same kinematics-independent coupling residue. Complete UV cancellation passed separately for Pg and Ppp before common-regulator Laurent expansion.

S05 resume contract: the initial whole-basis time limit expired on a same-flavor tensor without producing an accepted S05 result. Source s05_previous_14689149/s05_real_angular_basis.wl has SHA256 494b83da3f208b019011e964e3bf692113a16d2d0811a245be2166577348eab0. Its eight completed component bases may be reused only with matching old source/input identity and a current exact tensor reconstruction or spectator-parity gate. The revised implementation caches each unique coordinate coefficient set, postpones factoring until equal angular monomials are grouped, and retains 900-second operation and 2 GiB memory guards with a 3600-second whole-basis ceiling. This changes algebraic representation/execution only; S03 input and angular definitions are unchanged.

The unrun S06/S09/S10 entry points preflight their complete source with Wolfram SyntaxQ before starting algebra; this adds no extra runner or test file.

S05 same-flavor implementation: reduce the accepted S03 same-flavor diagram-pair cache entries separately before merging angular coefficients. Require each pair cache input identity and exact equality of their sum with the accepted S03 tensor. Each pair then passes exact angular reconstruction. Reuse same-channel derived denominator geometry only after reconstructing its defining angular form. Merge equal denominator/power monomials and gate each coefficient identity. This chain of exact identities proves the final sector basis without constructing a large combined numerator during angular reduction. Other eight accepted bases retain their source-identity and current reconstruction gates. Pair, geometry and merge checkpoints keep the same 2 GiB operation memory bounds.

Superseded S05 execution (merged same-flavor bases invalid because of nested denominator lookup): job 14689280, source SHA256 4d81b3f614259b70b7df63a821e87c019aee9016ce3d13361cc20f34733071fa, result SHA256 f9e793957b859042412916d9a447117f662348af85185a796282989e061c8de3. Artifacts: s05_result.wl, source-bound s05_cache, s05_run.log and s05_execution.json. The same-flavor S03 pair sums, every pair basis, reused geometry, reused component basis and merged angular coefficient passed its exact identity gate. Both mixed-charge tensors integrated to zero by the measured spectator-exchange identity. PairTaskGroups/PairInputHashes preserve exact current-channel inputs. Five allocated workers completed the accepted run in 98.9 seconds; peak combined RSS 2140340224 bytes. This result must not be used downstream; the corrected merge must preserve each pair denominator under a top-level index lookup.

Superseded S06 execution (requested masters and input identity derived from the invalid merged S05 basis): job 14689311, source SHA256 5cdac2d98bcb271c08d6f68ea7392be0e0dfdb5564591649242321833c89aaed, result SHA256 e1d80524a6f66a435091fceb60783944332c0ccb7a6058724e166132293b2d6f. Artifacts s06_result.wl, s06_required.wl, s06_cache, s06_run.log and s06_execution.json. Every requested angular master was fully evaluated; the hypergeometric, polynomial-division, integration-by-parts, coefficient-reconstruction and angular-pole gates passed where applicable. The coalescing epsilon factor remains explicit for S09. No predecessor or authors master result was used.

S09 regular-term handling: when the exact term is independent of s23, require Wolfram Residue at s23=0 to evaluate to zero before producing an empty singular-soft row list. This handles the CAS return type for a regular constant; no finite ordinary term is discarded. Completed checkpoints from source s09_previous_14689322/s09_real_phase_space.wl (SHA256 7d77edcee8aa0be6174e084e471ac238c70c60609fce8b0f88f73d2344cedef4) remain eligible only with matching unchanged S05/S06 input hashes; the failed term produced no accepted checkpoint.

Recoil diagnostic contract: s09_diagnostic/s01_check_primary_moments.wl uses the current Hqq_v4 inputs only. Independently integrate the angular polynomial in the distinct-flavor primary-charge tensor using defining polar/azimuthal integrals and compare its Laurent coefficients with the S05/S06 recipe. Separately square the full generated primary-charge amplitude and compare it with S03 pairwise contraction. Save exact differences and recoil coefficients without replacing production values or waiving any gate. This small diagnostic runs serially with shared FeynCalc scalar-product definitions and the standard memory bound. Its result is diagnostic evidence, not final hats.

Diagnostic s09_diagnostic/S01 evidence: s01_result.wl SHA256 6c500ff5d50ad0a4a261cbf6540dc5da5752bd9b8a08711c20d529bd46628798, source SHA256 08463999cf6387beb6afd7d389fc3bfb30a37bad8c16c6a20f6a5e3eedbd43c2. Direct primary-charge polynomial angular integration equals the S05/S06 recipe through epsilon, its stronger-recoil coefficient is zero, and full-amplitude contraction equals the S03 pairwise tensor for both projectors. This evidence covers that tested component only and does not waive the failed same-flavor S09 gate.

Diagnostic s09_diagnostic/S02 contract: verify current S05/S06 and eligible S09 source/input hashes, then compare each same-flavor Pg cached ordinary expression with the epsilon-expanded soft rows using a direct recoil series on both coordinate branches. Save the exact differences and all unevaluated/time-limited cases; no diagnostic outcome changes a production result. Independent terms use allocated kernels and bounded operations.

Diagnostic s09_diagnostic/S03 contract: source-verify S01/S02/S03/S05; square the complete generated RealSame amplitude with FeynCalc and the measured Hqq initial average/tag/charge factors; compare its Pg scalar tensor with the S03 pair sum. Independently extract the angular tensor stronger-recoil coefficient with Wolfram Limit. Save all exact comparisons without changing production values. Shared FeynCalc scalar-product definitions keep this diagnostic serial.

Diagnostic s09_diagnostic/S04 contract: for requested mixed masters with a positive massive index and a nonpositive massless index, integrate the defining azimuthal polynomial exactly and integrate each polar epsilon coefficient directly with Wolfram Integrate. Compare through epsilon with S06 without using its polar-division or massive-derivative algorithms. Gate the nonsingular massive denominator on the integration domain, verify source identities, and save exact differences/unevaluated cases. This diagnostic does not authorize replacing a value without correcting and rerunning S06 and dependent stages.

Diagnostic s09_diagnostic/S05 contract: source-verify the accepted S05 basis, reproduce the exact denominator-index lookup used by its same-flavor merge, and check that every returned list entry equals the requested denominator. Compare with a search restricted to top-level entries and save any mismatches. This is a deterministic indexing diagnostic and does not modify algebraic results.

S05 corrected merge contract: restrict FirstPosition to list level 1 and require the selected two denominators to be exactly identical to the original pair denominators for every remapped term. This completes the exact pair/merge proof chain. Superseded S05/S06/S09 outputs and caches are versioned under s05_previous_14689280 locally and on Hoffman2. Only the eight original, independently reconstructed non-Same bases from source 494b83da3f208b019011e964e3bf692113a16d2d0811a245be2166577348eab0 may be reused from that archive, with unchanged source/input verification. Recompute Same pair bases/merge, S06 requests/masters and all S09 terms. No old S09 checkpoint hash is eligible.

Originating-error evidence: diagnostic s09_diagnostic/S05 job 14689567, source SHA256 23e763303ab171bc9fb96309d1c923b65562513a0cc49f9cd70507250efe5f95, result SHA256 66bffd4e325f9820a14ac963a1b70934ed6be8b8a0c99ab5136fd1b42446ee9e, identified the wrong Pg a12 and Ppp u3 lookup entries exactly. Diagnostic S03 job 14689542 independently found full-amplitude/pairwise equality and zero unintegrated stronger-recoil coefficient; s03_result.wl SHA256 d0fd2eed98ef801709ce50311f88b975bb29c016d20bac792614b0a3393368e4. These artifacts establish the correction provenance and cannot substitute for regenerated S05-S10 production gates. The interrupted mixed-master diagnostic produced no accepted result.

Corrected S05 accepted execution: job 14689578, source SHA256 1190e1ca92638083acb4eb540235c9f4e9db76fc4386e66ea664f4bb08b2df96, result SHA256 fd6d533d8b1e7d586f237055e1c28381ffd0f8274bdc34c633b32b5540c2c474. Artifacts s05_result.wl, fresh s05_cache, s05_run.log and s05_execution.json. Every current pair basis, top-level denominator mapping, reused non-Same basis and merged coefficient passed its exact reconstruction gate. This is the only accepted S05 downstream input. The source retains original non-Same geometry/cache provenance under s05_previous_14689280/s05_cache.

S10 direct exports: after complete IR cancellation and finite matching boundary gates, write the exact StructureFunctions entries separately as s10_F1_hat.wl and s10_F2_hat.wl. The full s10_result.wl remains the convention, component and input-identity carrier for both expressions.

Regenerated S06 accepted execution: job 14689589, source SHA256 5cdac2d98bcb271c08d6f68ea7392be0e0dfdb5564591649242321833c89aaed, result SHA256 04218fda09eb61e84428c3c85c4fd257a94d4ce99b00c957479467b20e11789a. This result and fresh s06_cache are bound to corrected S05 result fd6d533d8b1e7d586f237055e1c28381ffd0f8274bdc34c633b32b5540c2c474. All required masters completed with evaluation, recurrence, integration-by-parts and angular-pole gates where applicable. Only this regenerated S06 result is an accepted S09 input.

S09 accepted execution after S05 correction: job 14689599, source SHA256 166175e3847b16e0e5ae092c0089af92115fd0686cd2f077cd86cfb3538d29ba, result SHA256 de0d9da2fb1d11e676b5f36d20c1e53ec7b5a738a84a5e7607abe74cb556bc65. Artifacts s09_result.wl, fresh source/input-bound s09_cache, s09_run.log, s09_execution.json and exact zero s09_recoil_* outputs. All component ordinary/endpoint evaluation, stronger-recoil cancellation and absence-of-higher-plus gates passed on both coordinate branches. This is the only accepted S09 downstream input. It retains the S03 flavor/charge bookkeeping and the explicit paper Eq. 39 measure.

S10 flavor-domain contract: recover ObservedFlavor and the exact flavor-sum bounds from source-verified S03. Derive their allowed integer upper-bound domain with Reduce, require that S09 carries identical component/charge bookkeeping, and use that domain in assembly and boundary reductions. The first S10 attempt used the broader Nf >= 0 domain and failed a Piecewise-dependent delta single-pole gate; its source/cache/poles are under s10_previous_14689620. This is an S10 domain correction, with no S01-S09 formula or value changed. Save FlavorDomain, FlavorRange, ObservedFlavor and the used component weights in the final result.

S10 exact flavor-count canonicalization: when the saved S03 multiplicity is Piecewise, extract a candidate expression from that tool-produced Piecewise and require Reduce[FlavorDomain && original != candidate, Nf, Integers] to return False. Only this proved identity can replace the multiplicity in component weights; retain both expressions and the counterexample result in the final artifact. The count is not transcribed from memory or obtained by fitting an IR coefficient.

Final S10 accepted execution: job 14689645, source SHA256 2a6baa04a7f776c06108f13cbd961a6a05ba867de545ed3299bf548b720a2d0b, result SHA256 c91b1d3880071228abc21435fbc72fef326f4d568e33cee68e4c6099eb97a1d7. Artifacts s10_final_hats.wl, s10_result.wl, s10_F1_hat.wl, s10_F2_hat.wl, s10_poles.wl, source/input-bound s10_cache, s10_run.log and s10_execution.json. The exact integer flavor-count proof, every ordinary-distribution reconstruction, every IR pole, and every finite matching coordinate-boundary gate passed. No authors coefficient was an input.

Consumer: s10_F1_hat.wl and s10_F2_hat.wl are the exact StructureFunctions entries from s10_result.wl, including LO and NLO distributions. Load the full result for the Hats coefficient tables, plus-distribution convention, physical/branch/flavor domains, observed-flavor identity, electric-charge moment definitions and all input hashes. Keep these definitions with the direct expressions. All kinematics, couplings, colors, flavors and scale dependence remain symbolic.

Accepted direct-output SHA256: F1 2ee1cf825ccb2d40296645e2c6ca108d90bfb38588df2f1543b64bab369d3839; F2 1814bb03a3057a2bc6a5a1192d1b795a21b4cdb435271c2d66e8d51fc222860f; pole record 998bdec952dd20bf94e916d240c210852346a9c87e44d271c2b02f94c5455422. These accepted outputs supersede every prior S10 attempt. Archived failed sources/results and the focused completed diagnostics retain correction/validation provenance; the interrupted disposable mixed-master test cache was removed.

BigTMD comparison consumer: bigTMD_check/README.md defines the isolated three-stage numerical comparison. It consumes accepted S10/S02 at frozen SHA256 identities and imports only the authors Hqq channel. Its reference reconstruction and numerical outcomes do not modify or replace production results.

Accepted BigTMD check: bigTMD_check/s03_result.md and s03_result.json report 120/120 reconstructed-reference coefficients and 24/24 independently evaluated published-decimal direct hats passing, both signs of s+t and up/down charges, nf=4, SU(3), mu=Q. Maximum published-decimal relative difference 6.434401797943158e-14. S03 source SHA256 aeb0bad68e19dac8861987755d8e545b8efa578a4b2fc2402c0af07a39c56873, JSON SHA256 c79e40bb3fe890f5f4d88e844fffb315901e0fd2e472f4084dc0f954ebb74040. The check ledger records normalization/distribution transport, endpoint reconstruction, precise source identities, resource evidence and required serialization-resume snapshot. No authors coefficient entered production and no symbolic production result changed.

## Current six-input numerical consumer contract

The user selected this channel for the numerical generation in ../numerics/.
That consumer imports the accepted terminal payload byte-for-byte and records its
identity in numerics/s01_result. Its S03 recovers this payload's own charge,
flavor, distribution and partonic-variable contracts; S05 exports these
coefficients and checks direct Wolfram values. The numerical consumer applies the
S04 fragmentation Jacobian to these partonic hats once and retains the source
normalization. It does not alter any symbolic production coefficient.
Current charge moments, positive-rho definitions and bounded-plus conventions
must come from this channel's own payload. S07/S10 gate native evaluation before
S09 convolves with the unchanged MRST02 and KKP/Kretzer inputs. The numerical
README documents stage interfaces; only ../progress.md records execution status.

Accepted current numerical coefficient interface: ../numerics/s03_cache/Hqq_v4_consumer_contract, SHA256 cb7f93f2890a22bd35a84637c4ad8122b5b764949963cf37cbceb08403387335; ../numerics/s05_cache/Hqq_v4_result, SHA256 cf6a4b20d84af8e9909cca9badd37bcf1f63f03331b52328fe73150d7319cf67. The current ../numerics/s07_result (SHA256 15fdc7e47c5494bdea7d7750089ec7f942a2920367ae64a9b5cd115fb16620e8) binds 15 paired programs for this channel and their exact operation-table/source identities. All associated Wolfram/native checks passed. These numerical interface identities supersede earlier numerical-export references for the active six-input generation; symbolic production identities and comparison caveats above remain unchanged. Convolution uses the established partonic coefficient and charge conventions; final integrated-bin acceptance is recorded separately in the numerical ledger.

Accepted numerical consumer output: ../numerics/s09_result, SHA256 66c0df6a0a8001e4603d939602bb8c7aa378fe77c916437f1b9115b8363b36ad, and ../numerics/s11_result, SHA256 9f7ccd91726edc6735f905ae36dc5c3b4076c97290613866e340dd5a9240fd62. All 17 current full-channel bins pass the original numerical gates; the S09 component arrays retain this channel's signed LO/NLO contributions with complete within-bin covariance. Both comparison figures are bound by ../numerics/dsigmapibydpt/s03_result, SHA256 f82e5fd31e63c1b2c5c5a110e9a872b20324c8e64e49202a9f52ba66e4b6cc6e. No symbolic channel payload changed.

## Source-bound six-channel analytical comparison

The separate [analytical report](../bigTMD_comparison/Hqq_v4/s04_result.md) compares this channel's unchanged current F hats with pinned BigTMD commit `6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. Both F hats agree in the stated comparison. Channel and all coefficient classes included. The exact-algebra claims are conditional on the declared reconstruction of printed decimal constants and the report's color, charge, scale, branch and distribution conventions.

Input SHA256: `c91b1d3880071228abc21435fbc72fef326f4d568e33cee68e4c6099eb97a1d7`. Comparison SHA256: `9cbd84ade57c35073608ba05258a536538bb5e5bc0f3c4d2ac136f91e9cc3c28`. Report SHA256: `521c32cbfd8b17c48453bd83030746c58418a225c15ffcad3aaffcafeffec948`. The comparison-directory README and receipts bind the source, result, proof-cache and validation identities. No production expression or existing independent-validation caveat is superseded by this comparison.
