# Hqqprime: SIDIS through NLO using reverse unitarity

## Process and inherited bookkeeping

Incoming quark p, observed distinct-flavor quark k1, unobserved incoming-flavor quark k2 and observed-flavor antiquark k3. There is no virtual contribution at this order.

Keep independent incoming/observed charges eq and eqp and all three terms eq^2, eq eqp, eqp^2. Model charges, spectator counts and spin/color averages come from the generated inputs. Initial subtraction uses q to g and the Born tensor carrying eqp^2; final subtraction uses g to qprime and the Born tensor carrying eq^2.

All partons are massless. The photon is spacelike. The source payload's
invariant definitions, scalar-product rules, dimension, tensor-projector
signs, model-charge removal, color symbols and scale convention are kept
verbatim in `s01_inputs/`. They must be converted by explicit, checked maps
before combining with a common family basis. No other channel's weight or
charge factor substitutes for this channel's measured quantities.

Do not discard a charge sector or endpoint term without an exact identity from the new cut calculation.

## Stage 1: preserved inputs

Run `../s01_import_inputs.py` locally. `s01_result.json` records every
copied file, its origin, size and SHA256. The unchanged source channel is
`../../Hqqprime_v2`. Its complete convention ledger is preserved in
`s01_inputs/README.md`; its historical angular/Package-X stages are outside
the new integration workflow. `s01_reference_sources/` holds source code
for adapting interference, renormalization or assembly only; these sources
are not executed unchanged and their evaluated results are not imported.

Stage 1 accepts byte-preserved inputs only. It is not acceptance of a new
integral, pole cancellation or final F hat. The new scalar-family stage
must check its source identities and exact input reconstruction.

## New integration contracts

The real map replaces the unobserved on-shell phase-space constraints by
positive-energy cuts. Both cuts remain present in Kira targets and
reductions. Family definitions, momentum routing, signs, loop measures,
normalization and reconstructing coefficient maps must be saved with the
generated targets. Any removal of dependent propagators is an algebraic
family construction, not the paper's angular integration.

Kira supplies the reduction rules and actual master inventory. SubTropica
evaluates every required real and virtual master to the regulator depth
determined by its coefficient and endpoint requirements. Raw engine output
is saved before normalization or physical continuation. Cut conventions,
branches and source/input hashes remain explicit. Neither the paper's
angular tables nor PaVe/Package-X evaluations enter this calculation.

After inserting the new masters, assemble UV renormalization, regulated
real distributions and the channel's factorization terms. Require exact
pole cancellation for each independent projector/charge component before
projecting and exporting symbolic F1hat/F2hat. Establish endpoint support,
distribution definitions and physical branch limits from the new result.
Old integrated hats may be read only as a subsequent comparison.

## Execution and artifacts

Run physics stages on Hoffman2 compute nodes under the shared SIDIS
execution contract. Main sources, inputs, results, logs and resumable
caches are retained locally. Shared loop-family/master artifacts are in
`../common/` and are referenced by hash. This folder owns its independent
channel coefficients, stage outputs and final hats. Job allocations and
process-tree memory guards bound concurrent work before algebra starts.

Append accepted stage contracts and exact artifact identities here as the
new calculation advances. `../../progress.md` is the only live status
record. No new integrated result is asserted by this initial ledger.

## S02: common kinematics and cut-family definitions

`../s02_definitions.wl` solves the on-shell and Mandelstam defining
equations in a common loop basis, defines the two positive-energy cuts,
and constructs independent candidate propagator families. It verifies
every imported file hash and inherited Ward result, derives the map from
this channel's saved scalar products, and requires exact reconstruction
of all those products. `s02_result.wl` preserves this channel's tensors
and bookkeeping in common coordinates; `../s02_result.wl` records the
shared Gram matrix, cut definitions, candidate families and channel hashes.
No integral is evaluated or normalizing factor inferred in S02. This stage
is serial because it solves one small shared defining system.

S02 accepted: Hoffman2 job14692733, source SHA256 39d5225662b92b1f9ecd654e6edb721f9f6ad1b52facf2e0a9ba59f616145eed, channel result SHA256 d78889c9a9d0e5ced433b5434d488ae523024bc3c31f1c50317fb516641ceea3. Common definitions produced 12 independent candidate cut families; this channel passed all input hashes, inherited Ward checks and exact scalar-product reconstruction. The shared execution peak was232914944 bytes. No integral was evaluated.

## S03: real cut-integral coefficients

`../s03_real_families.wl` selects the preserved interference caches and
requires their exact sum to equal this channel's accepted S02 tensors.
It derives affine propagator relations from the actual denominator
polynomials, maps every term to a full loop family with both cuts, and
checks exact reconstruction of each interference. Independent pairs run
on allocated kernels with bounded memory. `s03_cache/` binds each complete
map to source, geometry and input identities. `s03_result.wl` holds the
channel coefficients; `../s03_result.wl` and `../s03_targets` hold the
union of actual Kira targets. All charge sectors are retained. No integral
is evaluated, and a cut may not be removed from a generated target.

S03 accepted artifact: `s03_result.wl`, SHA256 `543dfc86a7dbb1b77a60b9267a9bcb5e61e141f086c073b93a6e8c252f3cb21c`. Execution: common `s03_execution.json`, Hoffman2 job `14692755`, source hash `3f605ff73e1e7d7926ddf9d9a7d369cd0fec0537aba2e2df464c8ef78e3d0b60`. All imported pair identities, exact pair sums, denominator decompositions, family-coordinate reconstructions and per-interference reconstructions passed. Root `s03_targets` contains the union of 315 unique cut-integral targets. The cut indices are preserved; no integral has been evaluated at this stage. Pair maps and their identities are retained in `s03_cache/`. This is the input boundary for a new Kira reduction.

## S04: Kira reduction of real cut integrals

`../s04_reduce_real.wl` generates the shared Kira configuration from S02 families and S03 targets. The program determines each family's sectors and numerator/denominator bounds from those targets. Both physical cut propagators are marked in Kira. Unit-index scalar integrals are preferred basis candidates, without assuming which are independent. All invariants remain symbolic; Q2 is renamed q2 only inside Fermat and restored on import. Kira rules, databases, logs and configuration are retained in `../common/s04_kira_real/`. Acceptance requires a rule for every requested integral and both positive cut indices in every surviving master. `s04_result.wl` binds this channel to the shared reduction. Master evaluation and phase-space normalization remain deferred.

S05 scope: the new virtual-family stage processes the inherited Born/virtual channels Hqq, Hqg and Hgq. This channel retains its recorded real-only NLO bookkeeping and its S03/S04 real-integration boundary.

S04 accepted: job `14692795`, source SHA256 `7fb2a8373395b2e6d85812186abe3d7394c47ed76722e30c212c262e232a0b03`, common result SHA256 `77754c4eb11f5626cc9ab473aa6c8f7a4722ab94d979cdd175da8e4a79192110`. All315 targets reduce to8 actual cut masters. The final denominator seed is one loop-seed level above the measured target maximum; this eliminated the four boundary dotted candidates. Master identity rules are imported from Kira's final inventory. Both cuts survive in every master. Shared configurations, logs and resumable databases are under `../common/s04_kira_real/a300b7c55204a3ffeea15c3568b94ce183ef1e60125a93a634e8ed93bdb2430e/`. No master has been evaluated yet.

## S06: fresh parent parameter integrands for cut masters

`../s06_cut_parent_inputs.wl` reads the eight actual Kira masters and derives the chord invariants of their parent loop integrals. Scalar-propagator permutations identify equivalent generic parents; each physical cut pair and the exact SIDIS substitution are retained separately. FeynCalc derives each generic Euclidean parameter representation with `FeynmanIntegralPrefactor -> "Unity"`; the program verifies chord reconstruction, routing signs and projective homogeneity, fixes one projective parameter, and passes the ordinary remaining Feynman-parameter measure directly to the SubTropica tuple interface. Shared inputs are in `../common/s06_parent_inputs/` and `../s06_result.wl`. This stage performs no master evaluation. SubTropica evaluation and the positive-energy cut discontinuity, including normalization and continuation checks, are explicit downstream requirements; an uncut parent is not itself an accepted cut-master value.

S06 measure correction: the pinned SubTropica tuple interface expects ordinary `Product dx_i` and multiplies by the parameters internally. The first adapter incorrectly multiplied by those variables as well. Its result and dependent input cache are versioned away under `../s06_previous_14692853/`; they were never used to evaluate an integral. The corrected adapter supplies no extra measure factor.

S06 corrected input accepted: job14692854, source SHA256 e67ddc0e141cc9a3bfb432f9ae7b2dbbde4ab2d26846e9b45f09166b2ce0a378, common result SHA256 39ade07f5fce3f935790bf418c6994c05f81b100f7a7a3cb5617a5a71c0fee1e. Eight cut masters use five parent templates; the tuple uses ordinary parameter measures.

## S07: SubTropica parent evaluation

`../s07_evaluate_cut_parents.wl` calls the full pinned SubTropica STIntegrate entry point with its HyperIntica backend on each newly derived parent Euler tuple, initially through eps^1. Ordinary parameter variables are renamed to scalar symbols without changing the measure. Each worker has its own current directory under `../common/s07_subtropica_parents/`, a3GiB Wolfram memory limit and a one-hour operation bound; the cluster allocation and combined RSS guard bound the complete process tree. Raw engine output is frozen and hashed before hyperlogarithm notation conversion. Acceptance requires a genuine SeriesData result through the requested order. These are Euclidean parent values; no physical cut or F hat is accepted until the recorded cut, normalization, continuation, required-order and endpoint stages pass.

S07 artifact completion: save HyperIntica GetAlgebraicBackSubRules alongside each raw result and substitute these rules in its portable series. Require no unresolved Wm/Wp letters. The initial job14692857 finished the five parent evaluations, but its result lacked the exported named-root definitions; that aggregate is retained under ../s07_previous_14692857 and is not a downstream input. Physical positive-energy cut masters remain separate required values.

S07 portable parent results accepted: job14692861, source SHA256 892b9c8968ca0e3610a894751476f7ee13b045be776165002df193501b30ace9. All five SubTropica parent series have saved algebraic-letter definitions and no unresolved Wm/Wp symbols; peak1802706944 bytes. They are Euclidean parents, not accepted cut values.

## S08: physical cut-master Euler inputs

The cut convention is the ordinary measure integral d^D r delta_plus(r^2) delta_plus((P-r)^2), with no 2 pi factors absorbed. Solve the two cut constraints in the P rest frame and retain the unique positive-energy root. Derive the radial Jacobian and sphere normalization in the program. Each uncut quadratic is converted, on the cuts, into a linear scalar product with an effective external vector; reconstruct it exactly and classify its normalized mass from the Gram matrix. Bubble and one-denominator Euler densities follow by a checked cosine-variable change. For a pair with at least one null effective vector, use the unexpanded Euler representation behind Somogyi arXiv1101.3557, Eqs(7),(56) and AppendixB, with its parameters derived from this family's effective vectors. SubTropica must evaluate the resulting Euler tuple; no angular Laurent table or old evaluated master enters. Treat a second null direction as its own input before epsilon expansion. Save the regulated radial and normalization prefactors separately, together with physical substitutions and support. The conservative epsilon order is measured from the actual Kira rule coefficients plus one endpoint order. The standalone reverse-unitarity reference also evaluates its reduced cut masters via Euler tuples; these are new SIDIS tuples.

## S10: SubTropica cut Euler evaluation

`../s10_evaluate_cut_masters.wl` evaluates every accepted S08 Euler class with the full pinned STIntegrate engine and the epsilon order measured from the Kira rules. The two-null case is a separate input, before expansion. Save the exact tuple, raw engine output, algebraic-letter definitions and portable series under ../common/s10_subtropica_cuts, with separate worker directories and3GiB per-operation limits. The regulated radial prefactor and physical substitutions remain in S08 and must be multiplied before the regulated soft-limit/distribution analysis. A Laurent series at fixed w is not a completed endpoint distribution or final F hat.

S08 accepted: job14692864; source SHA25640ff8ca4843a0701efee5333812147970592bb21325928fa79a3d8ad97d9361e; common result SHA25652dd4c285d7e23cd008204992088877b817d21674c0a211a20afb721f30dbada. The unique positive-energy solution, both cuts and every effective propagator reconstruction passed. Eight Kira masters use four Euler classes; the actual rule coefficients require order1 with the extra endpoint order. Peak478920704 bytes, no OOM. No cut Euler integral is evaluated in this stage.

S08 prefactor correction: the initial source split the Eq(56) Gamma ratio onto a separate top-level Wolfram expression. The saved prefactor therefore lacked that ratio. The invalid aggregate is removed from production and retained under ../s08_previous_14692864; no assembled channel result used it. Use an explicit multiplication operator at the originating line. Two separately derived Euler inputs compare a single null denominator in the direct cut measure against the two-denominator formula with its other normalized vector at rest; S10 must require their evaluated Laurent series to agree. The volume class requires epsilon^2; the other production classes require epsilon^1.

## S11: real coefficients in the Kira master basis

`../s11_real_master_coefficients.wl` combines each accepted S03 coefficient map with the accepted S04 Kira rules. It preserves every projector and charge-sector key, sums rational coefficients one master at a time, and records their epsilon and soft-w valuations. Each component has an independent input-bound checkpoint under s11_cache. The stage uses four allocated kernels,2GiB per operation and a combined memory guard. No integration or flavor/symmetry weight is inserted here; inherited weights remain at the channel assembly boundary. The resulting s11_result.wl is the coefficient input for regulated cut-master and endpoint assembly.

S08 corrected representation accepted: job14692871, source SHA25613b120a7d7d79a1aca6b360dddd5f2e1f8170f7fcc6b2650effcf7145898bc70. S10 cut evaluations and independent normalization accepted: job14692874, source SHA2565b8e29f097a6fb1452c5ea7d95a3ac89489abab96045fa4543241dbd23032c8b, common result SHA256dba9edd52b6cc80846a08f65ec2b98b908a4d7a429edff359dd3a460c597a253. The direct positive-energy null-denominator measure and the pair formula with the other vector at rest have exactly equal Laurent coefficients. Peak1686450176 bytes; no OOM. The four physical-cut Euler density classes are now evaluated; regulated prefactors/physical substitutions and endpoint assembly remain mandatory.

S11 accepted: job14692875, source SHA256dc86aa7f7f95265bbd37465ee4e0cfa55e99fb86b6e2e3d6616e4ec9e0432942, channel result SHA2562b6628bb1df66d708549a91fa13ed933e8a0ad0c7e996cf86e1ec67f92193655. All original charge/projector components are expressed in the eight Kira cut masters, with rational regulator/soft valuations. Peak1074868224 bytes; no OOM.

## S15: regulated cut-master soft regions

S15 reads the accepted S08 regulated representations, S10 Euler evaluations and S11 rational coefficients. It measures the required soft Taylor depth from each coefficient and prefactor, and identifies parameter limits with Wolfram Limit. Divergent Euler parameters are treated using SubTropica STGetRegionVectors and STPuiseux before expanding epsilon. Iterate all returned regions; do not use the installed STMoRExpand wrapper, whose region loop selects only the first entry. Convert the internal dlog densities back to ordinary parameter measure for STIntegrate. Save every region vector, unexpanded regulator power, Euler input, raw integral and portable series. Ordinary fixed-w master series and regulated soft-region values have separate fields. No distribution or final F hat is accepted by this stage alone.

Shared parent-evaluation dependency correction: S07 job14692861 and S13 job14692897 logged a missing libSingular-4.1.1.so Polymake module. Their aggregates, caches, source copies and receipts are versioned under ../s07_previous_14692861_dependency and ../s13_previous_14692897_dependency and are not production inputs. S10 has no matching library error; its independently normalized cut Euler evaluations remain distinct from the uncut parent values. Repair and test the dependency before regenerating affected parent evaluations. No physical channel used the invalidated parent results.

## S16: unchanged collinear subtraction and projector inputs

For real-only channels, extract only the factorization-root, Jacobian, Born convolution and tensor-projector section of the preserved s05 source, with paths redirected to byte-preserved s01 inputs and this channel's s16_result directory. Evaluate these loop-independent expressions afresh on Hoffman2. Preserve the source-defined charge-conjugate flows, fixed-flavor convention, incoming Ppp rescaling and MSbar subtraction prefactor. No old real integration or old final hats are loaded. S16 accepts subtraction/projector inputs only; new real-master assembly and pole/endpoint checks remain required.

S16 accepted: job14692913; source SHA256 ee121b6a83eec08225a20f7cd3dc13faf404f990bcba89142d206f47f7acf52a; channel result SHA256 314213c4fdef3d4aa26fe24d81018dc2d4aeee46f2d9a5931dcd75548fd60691. The source-selected subtraction/projector block passed support, Jacobian, color and paper-projector gates. Its evaluated MSbar phase and per-channel Born convolutions are in s16_result.wl; exact extracted source and intermediate results are in s16_result/. Peak928432128 bytes; no OOM. No real integral or endpoint distribution is evaluated here.

## Scope clarification: reuse unchanged counterterms and assembly

The user clarified that only integral evaluation is to change. Reuse the existing Born tensors, channel weights, universal renormalization/factorization counterterms and observable assembly wherever independent of the integral replacement. S14's fresh self-energy/UV derivation is redundant under this scope and is not a required production stage; its partial caches are not accepted counterterm inputs. Do not import old integrated virtual tensors or old angular integrals as new master values. Bind any selected unchanged counterterm data to their original source/result hashes, and insert only the new Kira/SubTropica integral results before the new pole-cancellation and final-hat gates.

## Final loop-evaluation requirement

The user explicitly confirmed that self-energy loop evaluations must also use Kira/SubTropica. This supersedes the preceding proposal to reuse Package-X-derived counterterm values. The S17 selected values and importer are excluded under ../s17_excluded_packagex and must not be production inputs. S14 remains required for fresh self-energy/UV master evaluation, while already generated amplitudes and exactly verified unintegrated UV maps remain reusable. No old evaluated loop tensor, residue or counterterm value may substitute for the new integral evaluation.

## S17 real cut-measure assembly contract

The new ../s17_assemble_real.wl uses S11 coefficient maps and freshly evaluated S08/S10/S15 masters. Derive soft recoil powers from the regulated prefactors and all SubTropica regions before the epsilon expansion. Sum all master terms in each original component and branch; require stronger recoil poles to cancel. Derive delta and plus coefficients from the regulated constant-test-function integral on [0,B], preserving the inherited [Log[w/B]^n/w]_+ convention. Save the ordinary function, endpoint rows, delta/L0/L1 and regular remainder in the explicit unnormalized positive-cut measure. Phase-space factors, couplings, flavor multiplicities and spectator weights remain at final assembly and are not applied here. Require actual regulator depth and exact original input hashes. Each task has a bounded private cache; no old integrated real result is a production input.

S15 serialization contract: write package-owned symbols with their explicit contexts and require a context-isolated exact Get/Put roundtrip. The job14692931 aggregate used ambiguous unqualified package epsilon/lambda names and is versioned under ../s15_previous_14692931_serialization; no downstream assembly used it. Its integration mathematics is unchanged by the serializer repair.

S15 accepted handoff: job14692935, sourceSHA1597b12ecf01f9df4f526a7ae73a7e98a51be7d64936573b3b635b720cdde066; common resultSHA82cb3ca0de4501b3c045d025e6b93f4228426c344023b2a727fc93d69615ef0b. Exact context-preserving reload passed. Use this corrected aggregate for S17; its endpoint powers remain unexpanded in epsilon until distribution assembly.

## S20 final F-hat contract

../s20_final_hats.wl converts the explicit cut measure using the product of on-shell state normalizations and momentum-conservation normalization. Require exact agreement with this channel's copied phase-definition expression in s20_phase_input.json, whose original source identity is retained. Apply each inherited symmetry/flavor/charge weight once. Core channels use the unchanged S01 subtraction values and new S19 virtual tensors; real-only channels use S16 convolutions and phase. Require every negative epsilon coefficient to vanish separately for each projector and delta/L0/L1/regular component before accepting finite tensors. Apply this channel's saved paper projectors only after pole cancellation. Preserve both physical branches and derive their common s+t=0 boundary from endpoint limits and the unbranched ordinary tensor. Save symbolic F1/F2 expressions, pole receipts, conventions and exact dependencies in this channel. No old integrated F hat or Package-X loop value enters final assembly.

S17 measured-depth implementation: S15 derives TaylorDepth0 for every master. Derive each rational coefficient's w valuation; if a singular contribution exists, require total recoil degree exactly-1. Evaluate the regular master endpoint once per master/branch, multiply its rational leading coefficient, then expand epsilon to the required depth. This avoids full-tensor soft series while preserving regulated region powers and all distribution definitions.


### S17 accepted cut distributions

The bounded Hoffman2 run 14693192 accepted this channel in the all-six-channel assembly. Source `../s17_assemble_real.wl` SHA256 `64384610fabf610f54fad5b3d66409cd197fbe970b0ab7a062e3f6591fc22290`; result `s17_result.wl` SHA256 `0cef076a2af7423327945967c99066aa02a13f11a04ca117a26bde99bbf83446`. Its `s17_cache/` checkpoints and root execution log/receipt are local. The output retains the original component keys and contains the raw positive-energy cut measure, before phase, coupling and any remaining spectator weights. Both endpoint branches passed the measured recoil-power and epsilon-depth gates. S20 consumes this result with the channel-specific phase and subtraction contracts above. No final combined pole cancellation is asserted by S17.


### S20 input-context contract

Every final-stage worker must load FeynCalc before reading unqualified legacy result files. New S19 values explicitly name `FeynCalc`SUNN` and `FeynCalc`Nf`; legacy inputs must resolve to those same package symbols. S20 rejects a surviving `Global`SUNN` or `Global`Nf` in its inputs. The first assembly run 14693217 exposed this reader mismatch at the core-channel delta pole. Its source-dependent final artifacts and caches are versioned in `s20_previous_14693217/`; corrected S20 regenerates them. No integral input was invalidated by this reader correction.


### Accepted final F hats: S20

Hoffman2 job `14693226` executed `../s20_final_hats.wl` (SHA256 `c56f0f20deca9c2100218304eadbfdecb139826c6d36dd2e06bf31b6895a36fa`) and accepted all six channels. This channel's accepted result identities are:

| File | SHA256 |
|---|---|
| `s20_result.wl` | `26e5c071f4a005d2682b8b3e3a0af3b25d0e0dbc904863a3621da37c8f3d291b` |
| `s20_F1_hat.wl` | `f2ddd545e69793e030cc3ce9298c973e343595ff071fa1331670be7b9d1d57bc` |
| `s20_F2_hat.wl` | `8371f2e522f212d8252797842a3ff8af4d7bcc89e821bbc7e6f80230e430dbc4` |

Its 2 final Laurent/pole checkpoints in `s20_cache/7dcd4c31d7c011de09ae9809367e560a189ae00c66f3424faf4e275e98867e02/` are all accepted. The real-to-phase normalization gate passed. For channels with a virtual contribution, both tensor projectors passed the open-branch and common-boundary pole gates. The common virtual boundary is a Wolfram symbolic limit, so direct substitution into individually singular terms is not needed. The run receipt is `../s20_execution.json`; its log is `../s20_run.log`, and the six-channel hash manifest is `../s20_result.wl`. The recorded remote cache path in the result maps to the local relative cache directory given here.

Each F-hat file contains the finite NLO regular coefficient directly. The corresponding `s20_result.wl` records zero `Delta`, `L0`, and `L1` after their exact endpoint-cancellation gates. The files already contain the derived spectator weight, coupling factors, channel-specific charges, phase normalization and paper projectors. Use the inherited `Nc`, charge and squared-scale `mu2` conventions above.

The calculation uses the new S17 reverse-unitarity/Kira/SubTropica real tensors and, where applicable, the new S19 virtual tensors and S14 counterterms. No old evaluated angular integral, Package-X loop value, or authors' F-hat coefficient is substituted as the result. Unchanged inherited inputs remain identified by `InputHashes`; exact symbol contexts are retained on output.
