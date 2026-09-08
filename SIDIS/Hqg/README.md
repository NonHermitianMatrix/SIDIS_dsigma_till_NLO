# Hqg: SIDIS through NLO with reverse unitarity

The accepted final symbolic hats are [s17_F1_hat.wl](s17_result/s17_F1_hat.wl) and [s17_F2_hat.wl](s17_result/s17_F2_hat.wl). Load [s17_result.wl](s17_result/s17_result.wl) with them for the domains, distribution definitions, normalization, charge/flavor bookkeeping and input identities.

The new integral calculation uses the preserved FeynArts/FeynCalc amplitudes and unintegrated contractions. Real integrals use positive-energy cut propagators, Kira reduction and SubTropica master evaluation. Virtual and self-energy integrals use Kira and SubTropica. No evaluated Package-X/PaVe result or old angular integral supplies a new master value. Exact pole cancellation and the applicable boundary gates passed before these hats were exported.

Final result SHA256: `6f45a83b0c2f2dce2d568431f7eb2fc5e9ba43e0fc612882092b312671ed590b`. Executed final shared source SHA256: `c56f0f20deca9c2100218304eadbfdecb139826c6d36dd2e06bf31b6895a36fa`. The [BigTMD report](../bigTMD_comparison/Hqg/s04_result.md) records 18/18 exact comparisons and 36/36 high-precision checks passing, with the reference-reconstruction and driver scope stated there.

## Consecutive steps and files

| Step | Program | Results and caches | Purpose |
|---|---|---|---|
| s01 | [s01_import_inputs.py](s01_import_inputs.py) | [s01_result/](s01_result/) | Preserve generated amplitudes, unintegrated tensors and unchanged definitions |
| s02 | [s02_definitions.wl](s02_definitions.wl) | [s02_result/](s02_result/) | Define kinematics, cuts and scalar-product maps |
| s03 | [s03_real_families.wl](s03_real_families.wl) | [s03_result/](s03_result/) | Map real tensors to cut integral families |
| s04 | [s04_reduce_real.wl](s04_reduce_real.wl) | [s04_result/](s04_result/) | Reduce real targets with Kira |
| s05 | [s05_virtual_families.wl](s05_virtual_families.wl) | [s05_result/](s05_result/) | Map unintegrated virtual tensors to loop families |
| s06 | [s06_cut_master_inputs.wl](s06_cut_master_inputs.wl) | [s06_result/](s06_result/) | Derive the physical cut-master Euler inputs and measures |
| s07 | [s07_reduce_virtual.wl](s07_reduce_virtual.wl) | [s07_result/](s07_result/) | Reduce virtual targets with Kira |
| s08 | [s08_evaluate_cut_masters.wl](s08_evaluate_cut_masters.wl) | [s08_result/](s08_result/) | Evaluate cut masters with SubTropica |
| s09 | [s09_real_master_coefficients.wl](s09_real_master_coefficients.wl) | [s09_result/](s09_result/) | Insert the real Kira master coefficients |
| s10 | [s10_virtual_master_inputs.wl](s10_virtual_master_inputs.wl) | [s10_result/](s10_result/) | Derive virtual-master parameter inputs |
| s11 | [s11_evaluate_virtual_masters.wl](s11_evaluate_virtual_masters.wl) | [s11_result/](s11_result/) | Evaluate virtual masters with SubTropica |
| s12 | [s12_uv_residues.wl](s12_uv_residues.wl) | [s12_result/](s12_result/) | Evaluate self energies with Kira/SubTropica and derive UV residues |
| s13 | [s13_cut_soft_regions.wl](s13_cut_soft_regions.wl) | [s13_result/](s13_result/) | Evaluate regulated soft regions with SubTropica |
| s14 | [s14_assemble_real.wl](s14_assemble_real.wl) | [s14_result/](s14_result/) | Assemble real delta, plus and regular terms |
| s15 | [s15_virtual_coefficients.wl](s15_virtual_coefficients.wl) | [s15_result/](s15_result/) | Insert virtual Kira master coefficients |
| s16 | [s16_assemble_virtual.wl](s16_assemble_virtual.wl) | [s16_result/](s16_result/) | Assemble and UV-renormalize virtual tensors |
| s17 | [s17_final_hats.wl](s17_final_hats.wl) | [s17_result/](s17_result/) | Cancel IR poles, apply projectors and export final F hats |

The program links point to the single implementations in `../common/`. A shared program processes its applicable channel group and needs to run only once. The local step numbers above are consecutive; the shared source names retain their original execution numbers. Shared-only result directories contain a `shared` link to the accepted common artifacts. Channel inputs, results and resumable caches stay in this channel's numbered result directories.

`previous_runs/` preserves this channel's superseded attempts and the pre-layout README. Shared superseded runs, software and master databases belong to `../common/`. These archives retain execution or resume evidence; they are not disposable temporary caches.

The [layout manifest](../common/s21_result/layout.json) maps every former path to its current location. Recorded physics `SourceHash` values identify the immutable executed sources in `../common/previous_runs/layout_sources/`; the manifest separately records the current sources with path-only changes. The path adapter rejects unrecorded current-source changes before reusing those source identities. A future physics change requires a new source/input generation and validation.

## Executed physics and convention ledger

The detailed record below uses the original **shared stage numbers**. Use the consecutive table above to locate the corresponding channel step. Backticked artifact paths have been translated using the recorded moves. Earlier entries explicitly superseded by later accepted executions are retained for provenance; the final accepted files are the ones linked at the top. Only `../../progress.md` is the live progress record.

### Process and inherited bookkeeping

Incoming quark p, observed gluon k1. Born/virtual recoil is quark k2. Real recoil is quark k2 and gluon k3.

Use the generated quark average, measured model-charge removal and tagged-real weight from S02/S04/S05. The real tensors have eq^2 gs^4 removed. S10 preserves the PDF and gluon/quark-parent fragmentation routes, their D-dimensional Born terms and explicit distribution convention. Nf remains the closed massless-flavor count.

All partons are massless. The photon is spacelike. The source payload's
invariant definitions, scalar-product rules, dimension, tensor-projector
signs, model-charge removal, color symbols and scale convention are kept
verbatim in `s01_result/s01_inputs/`. They must be converted by explicit, checked maps
before combining with a common family basis. No other channel's weight or
charge factor substitutes for this channel's measured quantities.

The old finite Delta coefficients disagree with the authors in the recorded comparison. Neither side sets a new integration coefficient.

### Stage 1: preserved inputs

Run `../common/s01_import_inputs.py` locally. `s01_result/s01_result.json` records every
copied file, its origin, size and SHA256. The unchanged source channel is
`../../Hqg_v3`. Its complete convention ledger is preserved in
`s01_result/s01_inputs/README.md`; its historical angular/Package-X stages are outside
the new integration workflow. `s01_result/s01_reference_sources/` holds source code
for adapting interference, renormalization or assembly only; these sources
are not executed unchanged and their evaluated results are not imported.

Stage 1 accepts byte-preserved inputs only. It is not acceptance of a new
integral, pole cancellation or final F hat. The new scalar-family stage
must check its source identities and exact input reconstruction.

### New integration contracts

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

### Execution and artifacts

Run physics stages on Hoffman2 compute nodes under the shared SIDIS
execution contract. Main sources, inputs, results, logs and resumable
caches are retained locally. Shared loop-family/master artifacts are in
`../common/` and are referenced by hash. This folder owns its independent
channel coefficients, stage outputs and final hats. Job allocations and
process-tree memory guards bound concurrent work before algebra starts.

Append accepted stage contracts and exact artifact identities here as the
new calculation advances. `../../progress.md` is the only live status
record. No new integrated result is asserted by this initial ledger.

### S02: common kinematics and cut-family definitions

`../common/s02_definitions.wl` solves the on-shell and Mandelstam defining
equations in a common loop basis, defines the two positive-energy cuts,
and constructs independent candidate propagator families. It verifies
every imported file hash and inherited Ward result, derives the map from
this channel's saved scalar products, and requires exact reconstruction
of all those products. `s02_result/s02_result.wl` preserves this channel's tensors
and bookkeeping in common coordinates; `../common/s02_result/s02_result.wl` records the
shared Gram matrix, cut definitions, candidate families and channel hashes.
No integral is evaluated or normalizing factor inferred in S02. This stage
is serial because it solves one small shared defining system.

S02 accepted: Hoffman2 job14692733, source SHA256 39d5225662b92b1f9ecd654e6edb721f9f6ad1b52facf2e0a9ba59f616145eed, channel result SHA256 d2d067bdd153cc5b5bef879e7d4c66dc77d3b0bdc00a3cfee61795cfdde12312. Common definitions produced 12 independent candidate cut families; this channel passed all input hashes, inherited Ward checks and exact scalar-product reconstruction. The shared execution peak was232914944 bytes. No integral was evaluated.

### S03: real cut-integral coefficients

`../common/s03_real_families.wl` selects the preserved interference caches and
requires their exact sum to equal this channel's accepted S02 tensors.
It derives affine propagator relations from the actual denominator
polynomials, maps every term to a full loop family with both cuts, and
checks exact reconstruction of each interference. Independent pairs run
on allocated kernels with bounded memory. `s03_result/s03_cache/` binds each complete
map to source, geometry and input identities. `s03_result/s03_result.wl` holds the
channel coefficients; `../common/s03_result/s03_result.wl` and `../common/s03_result/s03_targets` hold the
union of actual Kira targets. All charge sectors are retained. No integral
is evaluated, and a cut may not be removed from a generated target.

S03 accepted artifact: `s03_result/s03_result.wl`, SHA256 `49ad60e95ca26cf6725d052f964df8f1a6686575258a5d8379db25be502b92af`. Execution: common `s03_execution.json`, Hoffman2 job `14692755`, source hash `3f605ff73e1e7d7926ddf9d9a7d369cd0fec0537aba2e2df464c8ef78e3d0b60`. All imported pair identities, exact pair sums, denominator decompositions, family-coordinate reconstructions and per-interference reconstructions passed. Root `s03_targets` contains the union of 315 unique cut-integral targets. The cut indices are preserved; no integral has been evaluated at this stage. Pair maps and their identities are retained in `s03_result/s03_cache/`. This is the input boundary for a new Kira reduction.

### S04: Kira reduction of real cut integrals

`../common/s04_reduce_real.wl` generates the shared Kira configuration from S02 families and S03 targets. The program determines each family's sectors and numerator/denominator bounds from those targets. Both physical cut propagators are marked in Kira. Unit-index scalar integrals are preferred basis candidates, without assuming which are independent. All invariants remain symbolic; Q2 is renamed q2 only inside Fermat and restored on import. Kira rules, databases, logs and configuration are retained in `../common/s04_result/s04_kira_real/`. Acceptance requires a rule for every requested integral and both positive cut indices in every surviving master. `s04_result/s04_result.wl` binds this channel to the shared reduction. Master evaluation and phase-space normalization remain deferred.

### S05: virtual scalar-integral families

`../common/s05_virtual_families.wl` contracts the preserved one-loop amplitudes against the Born amplitude with the inherited physical gluon reference, spin/color average and model-charge removal. Before virtual processing, both Born projector contractions must reproduce the accepted Born result. Hqg uses the preserved tool-derived quark spin count and fundamental color dimension and is gated against its own Born tensors. FeynCalc completes each actual propagator basis and derives scalar-product-to-GLI rules. No tensor-integral/PaVe integration is called. Each mapped diagram must reconstruct the original rational loop integrand exactly; no scaleless term is manually discarded. The pre-Hermitian interference, explicit loop measure, family definitions and scalar coefficients remain in `s05_result/s05_cache/` and `s05_result/s05_result.wl`. Independent diagrams run on four allocated kernels with a2GiB per-operation limit and12GiB combined RSS guard. Kira reduction, self-energy residues and master evaluation are later stages.

S04 accepted: job `14692795`, source SHA256 `7fb2a8373395b2e6d85812186abe3d7394c47ed76722e30c212c262e232a0b03`, common result SHA256 `77754c4eb11f5626cc9ab473aa6c8f7a4722ab94d979cdd175da8e4a79192110`. All315 targets reduce to8 actual cut masters. The final denominator seed is one loop-seed level above the measured target maximum; this eliminated the four boundary dotted candidates. Master identity rules are imported from Kira's final inventory. Both cuts survive in every master. Shared configurations, logs and resumable databases are under `../common/s04_result/s04_kira_real/a300b7c55204a3ffeea15c3568b94ce183ef1e60125a93a634e8ed93bdb2430e/`. No master has been evaluated yet.

S05 propagator interface: convert legacy FeynAmpDenominator lines with FeynCalc `ToSFAD` before numerator scalarization. The installed FCLoopFromGLI reverse converter supports negative-index standard propagators. Added completion candidates use dimension D. Exact pointwise equivalence of the format conversion is a separate gate. Any incomplete numerator map is saved for correction and is explicitly unaccepted.

### S06: fresh parent parameter integrands for cut masters

`../common/s06_cut_parent_inputs.wl` reads the eight actual Kira masters and derives the chord invariants of their parent loop integrals. Scalar-propagator permutations identify equivalent generic parents; each physical cut pair and the exact SIDIS substitution are retained separately. FeynCalc derives each generic Euclidean parameter representation with `FeynmanIntegralPrefactor -> "Unity"`; the program verifies chord reconstruction, routing signs and projective homogeneity, fixes one projective parameter, and passes the ordinary remaining Feynman-parameter measure directly to the SubTropica tuple interface. Shared inputs are in `../common/s06_result/s06_parent_inputs/` and `../common/s06_result/s06_result.wl`. This stage performs no master evaluation. SubTropica evaluation and the positive-energy cut discontinuity, including normalization and continuation checks, are explicit downstream requirements; an uncut parent is not itself an accepted cut-master value.

S06 measure correction: the pinned SubTropica tuple interface expects ordinary `Product dx_i` and multiplies by the parameters internally. The first adapter incorrectly multiplied by those variables as well. Its result and dependent input cache are versioned away under `../common/previous_runs/s06_previous_14692853/`; they were never used to evaluate an integral. The corrected adapter supplies no extra measure factor.

S05 pointwise reconstruction preserves zero-index GLIs: the installed FCLoopFromGLI maps its empty propagator list to zero as an already-integrated scaleless object. The new check reconstructs the product directly from the stored denominator/index definition, retaining polynomial integrands for Kira. Inherited class-level MQU/MQD placeholders are explicitly set to zero under the massless-QCD defining input and the exact specialization is recorded. Byte-preserved imported files remain the provenance source.

S06 corrected input accepted: job14692854, source SHA256 e67ddc0e141cc9a3bfb432f9ae7b2dbbde4ab2d26846e9b45f09166b2ce0a378, common result SHA256 39ade07f5fce3f935790bf418c6994c05f81b100f7a7a3cb5617a5a71c0fee1e. Eight cut masters use five parent templates; the tuple uses ordinary parameter measures.

### S07: SubTropica parent evaluation

`../common/s07_evaluate_cut_parents.wl` calls the full pinned SubTropica STIntegrate entry point with its HyperIntica backend on each newly derived parent Euler tuple, initially through eps^1. Ordinary parameter variables are renamed to scalar symbols without changing the measure. Each worker has its own current directory under `../common/s07_subtropica_parents/`, a3GiB Wolfram memory limit and a one-hour operation bound; the cluster allocation and combined RSS guard bound the complete process tree. Raw engine output is frozen and hashed before hyperlogarithm notation conversion. Acceptance requires a genuine SeriesData result through the requested order. These are Euclidean parent values; no physical cut or F hat is accepted until the recorded cut, normalization, continuation, required-order and endpoint stages pass.

S05 full-basis correction: the installed FCLoopBasisFindCompletion topology overload inspects only the product of its denominators. A numerator direction absent from that product was therefore omitted. The current program builds the coefficient matrix against all loop scalar products involving ell and the three independent external momenta, appends a candidate only when MatrixRank increases, and requires full rank before deriving the GLI rules. Every original integrand is still reconstructed exactly.

S07 artifact completion: save HyperIntica GetAlgebraicBackSubRules alongside each raw result and substitute these rules in its portable series. Require no unresolved Wm/Wp letters. The initial job14692857 finished the five parent evaluations, but its result lacked the exported named-root definitions; that aggregate is retained under ../s07_previous_14692857 and is not a downstream input. Physical positive-energy cut masters remain separate required values.

S05 accepted: Hoffman2 job14692860; source SHA256 c3b6bd31df3fa763c714d173f8048d31aa41b02066c3f9ff6cf5853fcfe6aae2; channel result SHA256 45e4923088f5e449237c9843ee37be6d5b01c14f86c8cc9d917196ec64ffe3ef. Both Born normalizations and every scalarized virtual integrand reconstruction passed. The combined target inventory contains1625 targets. Peak1188827136 bytes; no OOM. These are unintegrated scalar coefficients, before Hermitian conjugation.

S07 portable parent results accepted: job14692861, source SHA256 892b9c8968ca0e3610a894751476f7ee13b045be776165002df193501b30ace9. All five SubTropica parent series have saved algebraic-letter definitions and no unresolved Wm/Wp symbols; peak1802706944 bytes. They are Euclidean parents, not accepted cut values.

### S08: physical cut-master Euler inputs

The cut convention is the ordinary measure integral d^D r delta_plus(r^2) delta_plus((P-r)^2), with no 2 pi factors absorbed. Solve the two cut constraints in the P rest frame and retain the unique positive-energy root. Derive the radial Jacobian and sphere normalization in the program. Each uncut quadratic is converted, on the cuts, into a linear scalar product with an effective external vector; reconstruct it exactly and classify its normalized mass from the Gram matrix. Bubble and one-denominator Euler densities follow by a checked cosine-variable change. For a pair with at least one null effective vector, use the unexpanded Euler representation behind Somogyi arXiv1101.3557, Eqs(7),(56) and AppendixB, with its parameters derived from this family's effective vectors. SubTropica must evaluate the resulting Euler tuple; no angular Laurent table or old evaluated master enters. Treat a second null direction as its own input before epsilon expansion. Save the regulated radial and normalization prefactors separately, together with physical substitutions and support. The conservative epsilon order is measured from the actual Kira rule coefficients plus one endpoint order. The standalone reverse-unitarity reference also evaluates its reduced cut masters via Euler tuples; these are new SIDIS tuples.

### S09: virtual Kira reduction

`../common/s09_reduce_virtual.wl` canonicalizes the S05 scalar families by exact loop translations, reversals and denominator permutations. Every transformed quadratic is reconstructed before targets are merged. The common external Gram matrix is the S02 matrix at w=0; the virtual Born scalar products must use this same basis. Kira receives complete loop families, measured target sectors and numerator/denominator bounds, and symbolic dimension/kinematics. No loop is evaluated by FeynCalc. Save canonicalization rules, original target provenance, Kira databases, final master inventory and complete reduction rules under ../common/s09_kira_virtual. Acceptance requires every canonical target to reduce to the actual final Kira master inventory. SubTropica evaluation, generated external residues, flavor multiplicities and UV/IR assembly remain downstream requirements.

### S10: SubTropica cut Euler evaluation

`../common/s10_evaluate_cut_masters.wl` evaluates every accepted S08 Euler class with the full pinned STIntegrate engine and the epsilon order measured from the Kira rules. The two-null case is a separate input, before expansion. Save the exact tuple, raw engine output, algebraic-letter definitions and portable series under ../common/s10_subtropica_cuts, with separate worker directories and3GiB per-operation limits. The regulated radial prefactor and physical substitutions remain in S08 and must be multiplied before the regulated soft-limit/distribution analysis. A Laurent series at fixed w is not a completed endpoint distribution or final F hat.

S08 accepted: job14692864; source SHA25640ff8ca4843a0701efee5333812147970592bb21325928fa79a3d8ad97d9361e; common result SHA25652dd4c285d7e23cd008204992088877b817d21674c0a211a20afb721f30dbada. The unique positive-energy solution, both cuts and every effective propagator reconstruction passed. Eight Kira masters use four Euler classes; the actual rule coefficients require order1 with the extra endpoint order. Peak478920704 bytes, no OOM. No cut Euler integral is evaluated in this stage.

S08 prefactor correction: the initial source split the Eq(56) Gamma ratio onto a separate top-level Wolfram expression. The saved prefactor therefore lacked that ratio. The invalid aggregate is removed from production and retained under ../s08_previous_14692864; no assembled channel result used it. Use an explicit multiplication operator at the originating line. Two separately derived Euler inputs compare a single null denominator in the direct cut measure against the two-denominator formula with its other normalized vector at rest; S10 must require their evaluated Laurent series to agree. The volume class requires epsilon^2; the other production classes require epsilon^1.

S09 seed completion: the initial per-family bounds retained numerator boundary integrals in exported rules. The new Kira configuration uses the measured global numerator and denominator maxima plus one loop seed, consistently for every canonically equivalent family. The final basis must contain only zero/unit scalar indices; inventories and any missing entries are saved explicitly. Job14692868 is unaccepted and its Kira database remains provenance.

### S11: real coefficients in the Kira master basis

`../common/s11_real_master_coefficients.wl` combines each accepted S03 coefficient map with the accepted S04 Kira rules. It preserves every projector and charge-sector key, sums rational coefficients one master at a time, and records their epsilon and soft-w valuations. Each component has an independent input-bound checkpoint under s11_cache. The stage uses four allocated kernels,2GiB per operation and a combined memory guard. No integration or flavor/symmetry weight is inserted here; inherited weights remain at the channel assembly boundary. The resulting s11_result.wl is the coefficient input for regulated cut-master and endpoint assembly.

### S12–S13: virtual master parameterization and SubTropica evaluation

S12 derives fresh FeynCalc Euler tuples for the actual scalar unit-index masters in S09. Propagator permutations, generic Euclidean chord invariants and the exact physical substitutions are saved. The unnormalized Minkowski loop measure uses FeynmanIntegralPrefactor Unity; the generated amplitude measure mu^(2 epsilon)/(2 pi)^D remains outside. S12 measures the required regulator order from the Kira coefficients. S13 evaluates these tuples with the full SubTropica engine, freezes raw results and algebraic-letter definitions, and retains physical continuation as a separate required operation before Hermitian interference. No old evaluated virtual master enters.

S08 corrected representation accepted: job14692871, source SHA25613b120a7d7d79a1aca6b360dddd5f2e1f8170f7fcc6b2650effcf7145898bc70. S10 cut evaluations and independent normalization accepted: job14692874, source SHA2565b8e29f097a6fb1452c5ea7d95a3ac89489abab96045fa4543241dbd23032c8b, common result SHA256dba9edd52b6cc80846a08f65ec2b98b908a4d7a429edff359dd3a460c597a253. The direct positive-energy null-denominator measure and the pair formula with the other vector at rest have exactly equal Laurent coefficients. Peak1686450176 bytes; no OOM. The four physical-cut Euler density classes are now evaluated; regulated prefactors/physical substitutions and endpoint assembly remain mandatory.

### S14: generated UV residues with Kira and SubTropica

The UV stage expands each preserved scalar interference at large loop momentum and retains terms through logarithmic degree. It replaces the resulting massless vacuum denominators by denominators with a common auxiliary mass, while checking preservation of the logarithmic asymptotics. Fresh FeynArts massless quark, gluon/ghost and one-flavor gluon two-point functions supply propagator insertions; their full scalar maps and longitudinal projections are also reduced by Kira. All loop-coordinate maps reconstruct their original rational integrands. Kira must make the longitudinal terms and the on-shell massless bubble vanish and reduce the remaining terms to scalar masters. SubTropica evaluates the auxiliary vacuum and off-shell bubble masters. The auxiliary-mass-independent UV residue determines the MS coupling counterterm together with generated external-field and Born coupling counts. Both projectors and all three Born channels must give the same result. This is auxiliary-mass infrared rearrangement, not a PaVe UV extractor. No old evaluated self energy or renormalization constant is imported.

S11 accepted: job14692875, source SHA256dc86aa7f7f95265bbd37465ee4e0cfa55e99fb86b6e2e3d6616e4ec9e0432942, channel result SHA256526a367878bf89060c61fbcac8dceaf58a29ac0071442806bfe97ceb58c2dca6. All original charge/projector components are expressed in the eight Kira cut masters, with rational regulator/soft valuations. Peak1074868224 bytes; no OOM.

S09 export closure: the complete-seed Kira inventory contains seven scalar masters, but an exported target rule can still reference an intermediate integral. The importer asks Kira to export that exact intermediate rule and substitutes it recursively, saving each closure request/rule/log. Every terminal must still belong to the original final master inventory; intermediate names are never promoted to masters or set to zero.

S09 accepted: job14692881, source SHA2565e9ddee07997d6584ae3e9f7762a8d2f82986c7cdb124257cc51b09f3257ba26, common result SHA2560c23971167f6b6cab97accd1fe5ddc05c99a7844be2a1aa560d4e4ebcc50090f. The1625 original targets map to252 canonical targets in11 families and reduce to7 scalar masters. An exported intermediate was resolved by its own Kira database rule; all final terminals match the recorded inventory. Peak445472768 bytes; no OOM.

S12 accepted: job14692885, source SHA256 0871a65b07078988cca44afa430fa3bec5b6240e70c44cbcd1f9cbc9f543c275, result SHA256 07e1f4b08b86df75ee9fc9e489d929f22789e4d58017a5cdee40f12abc4c124e. The seven Kira virtual masters map to two fresh Euler templates; all routing, chord, Gram and parameter-measure gates passed. Peak202719232 bytes; no OOM. Required orders are stored per parent. S13 must evaluate these exact tuples; physical continuation and channel assembly remain downstream.

S14 input contract completion: export the auxiliary mass through the same invertible Kira/Fermat symbol map as the kinematic invariants. Measure every required master order from the actual reduced UV/self-energy coefficients. Require the full generated self energies to reduce to one massless external two-point master with finite on-shell coefficients, and record its scaleless on-shell Kira boundary. The retained subtraction pole is MSbar, including the conventional EulerGamma/4pi terms.

S13 accepted: Hoffman2 job14692897, source SHA256 72597f3f84db8658878b577fa70029cde8b1d930f6902ee799c7ee8104f10ba3, result SHA256 048075ce622ca49e6c459da01a5f4a4b489cef1830e08a9d8618858d4a4720d6. Both required Euclidean parent series were evaluated by the full SubTropica engine through their measured orders. Raw results and algebraic-letter definitions are under ../common/s13_subtropica_virtual. Peak1044066304 bytes; no OOM. The generated Feynman prescriptions must be continued to physical kinematics before Hermitian interference; this acceptance is not virtual-channel assembly.

### S15: regulated cut-master soft regions

S15 reads the accepted S08 regulated representations, S10 Euler evaluations and S11 rational coefficients. It measures the required soft Taylor depth from each coefficient and prefactor, and identifies parameter limits with Wolfram Limit. Divergent Euler parameters are treated using SubTropica STGetRegionVectors and STPuiseux before expanding epsilon. Iterate all returned regions; do not use the installed STMoRExpand wrapper, whose region loop selects only the first entry. Convert the internal dlog densities back to ordinary parameter measure for STIntegrate. Save every region vector, unexpanded regulator power, Euler input, raw integral and portable series. Ordinary fixed-w master series and regulated soft-region values have separate fields. No distribution or final F hat is accepted by this stage alone.

S13 acceptance withdrawn pending correction: job14692897 returned an empty box Laurent series. Its completion marker and SeriesData type check alone do not establish a complete master. No physical virtual assembly used this output. Do not consume the initial S13 aggregate; the originating evaluator must be corrected and regenerated.

Shared parent-evaluation dependency correction: S07 job14692861 and S13 job14692897 logged a missing libSingular-4.1.1.so Polymake module. Their aggregates, caches, source copies and receipts are versioned under ../s07_previous_14692861_dependency and ../s13_previous_14692897_dependency and are not production inputs. S10 has no matching library error; its independently normalized cut Euler evaluations remain distinct from the uncut parent values. Repair and test the dependency before regenerating affected parent evaluations. No physical channel used the invalidated parent results.

S14 flavor-label correction: inspect only Field[index] -> species assignments in generated diagrams. FeynArts stores forbidden F[4] entries in the ExcludeParticles metadata; their presence there is not a generated closed flavor. The saved diagnostic contains the intended one-flavor loop. Already completed UV maps may be reused only after byte-identity of their defining code and exact original source/input hash gates; record their original files and hashes in every reused packet.

### Scope clarification: reuse unchanged counterterms and assembly

The user clarified that only integral evaluation is to change. Reuse the existing Born tensors, channel weights, universal renormalization/factorization counterterms and observable assembly wherever independent of the integral replacement. S14's fresh self-energy/UV derivation is redundant under this scope and is not a required production stage; its partial caches are not accepted counterterm inputs. Do not import old integrated virtual tensors or old angular integrals as new master values. Bind any selected unchanged counterterm data to their original source/result hashes, and insert only the new Kira/SubTropica integral results before the new pole-cancellation and final-hat gates.

### S17: reused renormalization inputs

Copy only CouplingResidue, ExternalFieldCounts, ExternalInterference, CouplingWeight, Regulator, MSPole, CouplingsRemoved and their source/input identities from this channel's accepted renormalization payload. Preserve each field's exact Wolfram source text; do not copy RenormalizedVirtual. The cluster validation checks the preserved Born/generated hashes, coupling and field counts against current generated inputs, and vanishing of the inherited scaleless field contribution with one common regulator. These are unchanged scheme/bookkeeping inputs, not newly evaluated loop tensors. Combine them only with newly evaluated virtual masters in the later assembly.

### Final loop-evaluation requirement

The user explicitly confirmed that self-energy loop evaluations must also use Kira/SubTropica. This supersedes the preceding proposal to reuse Package-X-derived counterterm values. The S17 selected values and importer are excluded under ../s17_excluded_packagex and must not be production inputs. S14 remains required for fresh self-energy/UV master evaluation, while already generated amplitudes and exactly verified unintegrated UV maps remain reusable. No old evaluated loop tensor, residue or counterterm value may substitute for the new integral evaluation.

S14 target-export contract: collect the scalar integral keys of every UV and self-energy coefficient map explicitly; require complete target coverage before Kira. Actual Polymake module loading and nonempty evaluated master series are required before accepting UV values. No previously evaluated Package-X counterterm is a production input.

### S17 real cut-measure assembly contract

The new ../s17_assemble_real.wl uses S11 coefficient maps and freshly evaluated S08/S10/S15 masters. Derive soft recoil powers from the regulated prefactors and all SubTropica regions before the epsilon expansion. Sum all master terms in each original component and branch; require stronger recoil poles to cancel. Derive delta and plus coefficients from the regulated constant-test-function integral on [0,B], preserving the inherited [Log[w/B]^n/w]_+ convention. Save the ordinary function, endpoint rows, delta/L0/L1 and regular remainder in the explicit unnormalized positive-cut measure. Phase-space factors, couplings, flavor multiplicities and spectator weights remain at final assembly and are not applied here. Require actual regulator depth and exact original input hashes. Each task has a bounded private cache; no old integrated real result is a production input.

### S18 virtual coefficient contract

../s18_virtual_coefficients.wl reads this channel's accepted S05 maps, uses S09 canonicalization and exact exported Kira rules, and sums rational coefficients master by master for each original projector. Preserve the pre-Hermitian interference convention, loop measure, removed couplings and incoming average. Derive the required master epsilon orders from these full coefficients and require S12 orders to cover them. The stage accepts coefficient maps only, with input-bound caches; physical continuation and S14 counterterms remain downstream.

S13 corrected acceptance: job14692929, sourceSHA8e3674c9feee48a291a577ce8c0e25c5db2f68084fb032bf7cc05301a666e999, common resultSHA5193fc3cbbf055e34dfc6d718fe33fd72e2c676d2a5b5f4a7a6b8175a7a12513. Actual module preflight passed; saved bubble and box series are nonempty, through eps1 and eps0 respectively, with no dependency errors. Physical continuation remains required.

S18 accepted: job14692928, sourceSHAc185ac1b2ba7d5bd0e775bc86274f49ecda9492a2a1b0e5c2b918d57efde5220; channel resultSHA7c58cbf00ff7dc91481ec3703cb83b09595136ded9f3274bedede6bbe1ee7a7f. All rational master coefficients collected. s18_required_orders.wl proves the full-coefficient requirements agree with S12/S13 depths. Pre-Hermitian loop measure and couplings remain unchanged. No physical virtual tensor has yet been assembled.

S15 serialization contract: write package-owned symbols with their explicit contexts and require a context-isolated exact Get/Put roundtrip. The job14692931 aggregate used ambiguous unqualified package epsilon/lambda names and is versioned under ../s15_previous_14692931_serialization; no downstream assembly used it. Its integration mathematics is unchanged by the serializer repair.

S14 accepted: job14692934, sourceSHAdd8482c58e0569ab71e5a206ece5d3ee75d1c5cf582dc5a8f10579060f2076ed; common resultSHA47cc08f577206fbfafc583320aeed48d53cd57b649e1a3e2db3c46dcfacb9aa0. Self-energy/Kira/UV/normalization gates passed; the common coupling residue is a new Kira/SubTropica result. WorkDirectory and master/reduction paths are recorded in the aggregate. All self and virtual UV maps remain input-bound.

### S19 virtual assembly contract

Continue the freshly evaluated S13 Euclidean masters using the saved S12 physical chord substitutions with their inherited Feynman prescription. Verify the imaginary part of the parametric polynomial has the required sign at positive parameters, and evaluate every logarithm/dilogarithm boundary value with Wolfram Limit. Keep epsilon orders required by S18. Sum the pre-Hermitian tensors with their saved loop measure, then add the Hermitian conjugate. Use S14 UV residues and its Kira scaleless on-shell boundary to derive the separated bare field residues; use only the newly evaluated coupling residue in the inherited MSbar counterterm. Require complete UV cancellation and exact recombination of the common-regulator expression. Save new RenormalizedVirtual tensors and physical master caches. No old Package-X evaluated quantity enters this stage.

S15 accepted handoff: job14692935, sourceSHA1597b12ecf01f9df4f526a7ae73a7e98a51be7d64936573b3b635b720cdde066; common resultSHA82cb3ca0de4501b3c045d025e6b93f4228426c344023b2a727fc93d69615ef0b. Exact context-preserving reload passed. Use this corrected aggregate for S17; its endpoint powers remain unexpanded in epsilon until distribution assembly.

### S20 final F-hat contract

../s20_final_hats.wl converts the explicit cut measure using the product of on-shell state normalizations and momentum-conservation normalization. Require exact agreement with this channel's copied phase-definition expression in s20_phase_input.json, whose original source identity is retained. Apply each inherited symmetry/flavor/charge weight once. Core channels use the unchanged S01 subtraction values and new S19 virtual tensors; real-only channels use S16 convolutions and phase. Require every negative epsilon coefficient to vanish separately for each projector and delta/L0/L1/regular component before accepting finite tensors. Apply this channel's saved paper projectors only after pole cancellation. Preserve both physical branches and derive their common s+t=0 boundary from endpoint limits and the unbranched ordinary tensor. Save symbolic F1/F2 expressions, pole receipts, conventions and exact dependencies in this channel. No old integrated F hat or Package-X loop value enters final assembly.

S19 accepted: job14692948, sourceSHAf0e6bfb7831c6fcfc21e27e5ce21626ba33635f9cb3c955dbc270565dc35e7dc; channel resultSHA48d4d2bc5bb0dbec3a7e3d48f3e99ca76d351e241cc69199bc7abbbe616b087c. Every physical master limit, common-regulator reconstruction and UV cancellation gate passed. Use these new renormalized virtual tensors in S20. The optional whole-expression FullSimplify was removed; the inherited ComplexExpand/conjugation operation is unchanged.

S17 measured-depth implementation: S15 derives TaylorDepth0 for every master. Derive each rational coefficient's w valuation; if a singular contribution exists, require total recoil degree exactly-1. Evaluate the regular master endpoint once per master/branch, multiply its rational leading coefficient, then expand epsilon to the required depth. This avoids full-tensor soft series while preserving regulated region powers and all distribution definitions.


#### S17 accepted cut distributions

The bounded Hoffman2 run 14693192 accepted this channel in the all-six-channel assembly. Source `../common/s17_assemble_real.wl` SHA256 `64384610fabf610f54fad5b3d66409cd197fbe970b0ab7a062e3f6591fc22290`; result `s14_result/s14_result.wl` SHA256 `3f4e699dee607789b544873a4f2ca7f1b42e86a5235ae2cad3d2f2bd620624fc`. Its `s14_result/s14_cache/` checkpoints and root execution log/receipt are local. The output retains the original component keys and contains the raw positive-energy cut measure, before phase, coupling and any remaining spectator weights. Both endpoint branches passed the measured recoil-power and epsilon-depth gates. S20 consumes this result with the channel-specific phase and subtraction contracts above. No final combined pole cancellation is asserted by S17.


#### S20 input-context contract

Every final-stage worker must load FeynCalc before reading unqualified legacy result files. New S19 values explicitly name `FeynCalc`SUNN` and `FeynCalc`Nf`; legacy inputs must resolve to those same package symbols. S20 rejects a surviving `Global`SUNN` or `Global`Nf` in its inputs. The first assembly run 14693217 exposed this reader mismatch at the core-channel delta pole. Its source-dependent final artifacts and caches are versioned in `previous_runs/s20_previous_14693217/`; corrected S20 regenerates them. No integral input was invalidated by this reader correction.


#### Common-boundary assembly contract

The new virtual tensor is saved as an unevaluated sum of rational/logarithmic terms that can individually have removable singularities at `t=-s`. S20 must take a Wolfram symbolic limit of their combined expression before substituting the common boundary. Direct substitution produced `Indeterminate` in run 14693218 and is not an accepted boundary operation. Open-branch pole checkpoints from that run remain valid; the boundary must pass finite-evaluation and pole gates after correction.


#### Accepted final F hats: S20

Hoffman2 job `14693226` executed `../common/s20_final_hats.wl` (SHA256 `c56f0f20deca9c2100218304eadbfdecb139826c6d36dd2e06bf31b6895a36fa`) and accepted all six channels. This channel's accepted result identities are:

| File | SHA256 |
|---|---|
| `s17_result/s17_result.wl` | `6f45a83b0c2f2dce2d568431f7eb2fc5e9ba43e0fc612882092b312671ed590b` |
| `s17_result/s17_F1_hat.wl` | `fc161bd3e9f0a69af14e91ad951aed7e8f7356543920f9dcc48e9f5ff2c32b6e` |
| `s17_result/s17_F2_hat.wl` | `4ba318fe07287aee14f0a2b9520cbf06043bb07ce609af83af8038430df09f85` |

Its 24 final Laurent/pole checkpoints in `s17_result/s17_cache/e8425c55fa2a0da8f9a54581696ef12e40eaebe86d3c2b249ad43f9ef1c0c065/` are all accepted. The real-to-phase normalization gate passed. For channels with a virtual contribution, both tensor projectors passed the open-branch and common-boundary pole gates. The common virtual boundary is a Wolfram symbolic limit, so direct substitution into individually singular terms is not needed. The run receipt is `../common/s20_result/s20_execution.json`; its log is `../common/s20_result/s20_run.log`, and the six-channel hash manifest is `../common/s20_result/s20_result.wl`. The recorded remote cache path in the result maps to the local relative cache directory given here.

The two F-hat files each contain an association with `LODelta` and `NLO`. `LODelta` is the leading delta-distribution coefficient. `NLO` has branch keys `1`, `-1`, and `0`; each branch contains `Delta`, `L0`, `L1`, and `Regular`. Use `t = sign omega - s` with `omega > 0` on the open branches; branch `0` is the symbolically evaluated common boundary `t = -s`. The distribution basis is inherited from S17: `Delta` multiplies the delta distribution in `w`, and `Ln` multiplies `[Log[w/B]^n/w]_+` with the saved endpoint scale `B`. The files already contain the coupling and observed-charge factors and the paper projectors. Use the preserved channel color/flavor and scale conventions above; package color/flavor symbols are explicitly qualified.

The calculation uses the new S17 reverse-unitarity/Kira/SubTropica real tensors and, where applicable, the new S19 virtual tensors and S14 counterterms. No old evaluated angular integral, Package-X loop value, or authors' F-hat coefficient is substituted as the result. Unchanged inherited inputs remain identified by `InputHashes`; exact symbol contexts are retained on output.
