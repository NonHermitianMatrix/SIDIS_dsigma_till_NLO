# Hqg_v3

This directory calculates the incoming-quark, observed-gluon channel independently.
The physics method is the supplied paper, arXiv:1903.01529. No other channel files
are used. The authors' coefficients are comparison data and cannot set a production
normalization, pole, finite term, or acceptance criterion.

## Existing comparison data

The earlier reconstruction from the authors' coefficients is preserved in
`comparison/`. Its `s03_result.wl` is an author-derived comparison result, not an
independent NLO prediction. The rounded-decimal reconstruction assumption and
source identities remain documented there.

## Independent stages

- `s02_born_and_projectors.wl`: QCD Compton Born current, symbolic spin and color
  averages, invariant relations, photon/gluon Ward identities, and derivation of
  the structure-function projectors. It loads no comparison data. The current
  `s02_result.wl` was regenerated with this independent entry point.
- `s04_generate_amplitudes.wl`: FeynArts generation of the Born, real, and virtual
  amplitudes for gamma* q -> g q and gamma* q -> g q g only. The photon has
  q^2=-Q2; quarks and gluons are massless. The observed gluon is k1, the outgoing
  quark is k2, and the additional real gluon is k3.

The calculation keeps the color number, dimensional regulator, kinematics,
flavor count, and scales symbolic. Real-gluon sums use physical polarizations.
The loop measure is explicit. The paper's angular phase space and final-state
normalization are applied after amplitude contraction. Collinear subtraction is
performed on each tensor contraction before applying the final projectors.

Acceptance of the independent NLO result requires real and virtual integrations,
UV renormalization, collinear subtraction, and exact cancellation of all poles.
Only after that result is fixed will the authors' channel-3 coefficients be read
for a comparison. A disagreement will be reported and investigated; the
independent result will not be adjusted merely to force agreement.

## S05 contraction contract

`s05_contract_real.wl` derives the scalar products from invariant definitions, checks the generated Born normalization against S02, and contracts real interferences pair by pair with physical gluon sums. Polarization sums precede Dirac trace expansion. Each saved pair is symbolic in D and SUNN; exact replay against the earlier contraction order gates reused pairs. The full result requires the photon and both gluon Ward identities. Cache files are in `s05_cache/`, keyed by amplitude and source hashes; the current log is `s05_run.log`. Intermediate projector files are not accepted as a complete real result until all Ward gates pass.

## S06 virtual contract

The next stage will contract each generated virtual diagram with the generated Born amplitude, remove the independently measured model charge, reduce its one-loop tensor integrals, and evaluate them with the installed Package-X interface using the explicit loop measure. UV and IR regulators remain separate until the UV-renormalization gate. The output must contain no unresolved tensor or loop integral. It supplies the two-body virtual contractions to later endpoint assembly; it does not by itself establish IR cancellation. Production runs are serial to retain memory headroom, with limits and an inline persistent monitor.

## S07 real angular reduction contract

The real contraction is reduced using Appendix D linear relations derived from its actual denominator polynomials. Every resulting term has at most two independent angular denominators, and the complete rational reconstruction must equal S05 exactly. Rest-frame momenta and angular denominator scales are solved from the invariant definitions. The output records the master indices, scales, direction cosines, and exact coefficients; no angular integral is yet asserted by this stage.

S06 scale convention: Package-X includes its own `ScaleMu^(2 Epsilon)`. Pass only `1/(2 Pi)^(4-2 Epsilon)` through `PaXImplicitPrefactor`, then identify `ScaleMu` with `mu`; the physical measure is exactly Appendix E1. The startup check revealed the duplicate scale before any virtual diagram result was produced. Only the Package-X FeynHelpers interface is loaded. The successful interface check used approximately 316 MiB RSS; address-space allowance must exceed the smaller physical-RAM ceiling.

S05 accepted artifacts: `s05_result.wl`, `s05_Pg.wl`, `s05_Ppp.wl`, the three `s05_*Ward.wl` zero results, and `s05_cache/`. The accepted entry point is `s05_contract_real.wl`; `s05_run.log` records the successful resume. All three Ward sums are exact zero. The model charge square was measured as 4/9 by comparison with the independently constructed S02 current; it is removed from the exported contractions. The generated tagged-real weight is 1. Coefficients are symbolic in D and SUNN with `eq^2 gs^4` removed. These amplitudes still require phase-space integration, renormalization, and factorization.

## S08 angular integration contract

The required master indices come only from accepted S07 terms. Massless angular integrals use Eq. B18, with the hypergeometric expansion generated from its defining series and contiguous relations. Mixed integrals use the regulated endpoint subtraction in Eqs. B19-B26; polynomial cases are integrated as angular moments. Coefficients are retained through epsilon^1, and the massless coalescing factor `(1-z)^(-epsilon)` remains explicit for the recoil endpoint stage. Every master must be evaluated symbolically with at most a single angular epsilon pole. The authors channel coefficients and Appendix F channel-dependent data are not inputs.

Accepted S07 artifacts: `s07_real_angular_basis.wl`, `s07_result.wl`, `s07_run.log`; both complete rational reconstructions passed. Angular geometry uses the polynomial squared-norm condition to establish the cases in Appendix B. Accepted S06 artifacts: `s06_virtual_integrals.wl`, `s06_result.wl`, `s06_cache/`, `s06_run.log`, and the corrected `s06_backend.wl`. All 15 virtual diagrams for Pg and Ppp contain evaluated loop integrals. The stored interference still requires addition of its Hermitian conjugate, external-leg bookkeeping, and renormalization. UV and IR regulators remain distinct.

## S09 renormalization contract

Generate the massless quark and gluon two-point diagrams with the same FeynArts QCD conventions as S04. Resolve one closed quark flavor explicitly and retain its multiplicity as Nf. Derive the external propagator residues by inserting the generated two-point function into the free propagator, keeping scaleless UV and IR pieces separate. Determine the MS coupling residue from the UV renormalization condition; Pg and Ppp must independently give the same real, kinematics-independent value. Check the complete UV residue before identifying the regulators. This uses no IR residue or authors coefficient to choose a counterterm. The OS/MS definitions follow the FeynCalc renormalization documentation: https://feyncalc.github.io/FeynCalcBookDev/Extra/Renormalization.html .

## S10 factorization contract

Use the installed FeynCalc splitting-function interface for the unpolarized leading kernels, with its normalization checked against paper Eqs. 51 and 53. Derive the incoming and outgoing momentum maps, delta-function roots, Jacobians, and Ppp projector rescaling from scalar products. The quark-parent fragmentation term uses the same S02 Compton amplitude with its two final momenta relabeled; no other channel source is used. Map each kernel plus distribution with an auxiliary endpoint regulator and require cancellation of that auxiliary pole. Preserve the D-dimensional Born terms through the MS subtraction. The output supplies delta, plus, and ordinary terms for the combined IR gate.

Accepted S09 artifacts: `s09_renormalize_virtual.wl`, `s09_self_energies.wl`, `s09_result.wl`, and `s09_run.log`. The generated massless residues contain separate UV/IR poles and vanish when those regulators are identified. Both projectors independently give the same MS coupling residue; complete UV cancellation passed before regulator identification. `RenormalizedVirtual` includes the Hermitian conjugate, external residues, and coupling renormalization, with `eq^2 gs^4` removed. Two-body phase space and the hard-tensor normalization remain for final assembly. This is a UV gate; combined real-plus-virtual IR cancellation is tested in S12.

## S11 phase-space contract

Apply paper Eq. 39 to the S07 angular coefficients and S08 evaluated masters. Treat the soft recoil limit at finite epsilon before truncating its endpoint coefficient. For coalescing massless directions, use the exact Gauss connection formula (DLMF 15.10.21) and its defining Taylor series to retain all soft branches. Combine terms before accepting cancellation of recoil powers stronger than the distributional endpoint. Generate delta and logarithmic plus distributions on the explicit interval [0,B] from their regulated integral definition. Check ordinary-part reconstruction. Keep term checkpoints bound to the sources and accepted inputs. Final real/virtual/collinear pole cancellation belongs to the following assembly stage.

Accepted S10 artifacts: `s10_collinear_subtraction.wl`, `s10_result.wl`, and `s10_run.log`. FeynCalc kernel normalization relative to paper Eqs. 51/53 was measured as 1/2; the gluon kernel uses the same factor. Momentum fractions are explicitly declared scalar to FeynCalc. All PDF and gluon/quark-parent fragmentation convolutions passed their support, endpoint-regulator, and ordinary-part reconstruction gates. `Counterterms` supplies Delta, L0 and Regular coefficients with `eq^2 gs^4` removed, including the D-dimensional Born contributions and the paper MS subtraction. L0 is defined on [0,B]. The overall hard tensor factor remains deferred.

## S12 final assembly contract

Combine S11 real distributions, S09 renormalized virtual contractions with two-body phase space, and S10 subtraction in the same symbolic coupling and regulator convention. Require exact cancellation of every negative regulator power in delta, L0, L1, and ordinary terms, separately for Pg and Ppp and both soft-coordinate branches. Only then apply the S02-derived projectors, Born kinematic map, and paper hard-tensor normalization. Preserve exact color/flavor/scale dependence. Export finite LO and NLO hats with explicit plus-distribution definitions and physical support. Authors coefficients remain excluded until these independent artifacts are fixed.

S08 mixed-master reduction: higher mixed indices are obtained by differentiating the defining massive denominator and by integrating a polar total derivative in the regulated convergence domain. Wolfram derives the relation, checks its polar boundary terms, and reconstructs the differentiated integrand exactly. The base mixed master still uses paper B19-B26. Completed masters from the preserved prior S08 source remain accepted; their original source and S07 hashes are retained in the output metadata. The total derivative is an integration method, not an input from published channel coefficients.

Accepted S08 artifacts: `s08_angular_integrals.wl`, `s08_result.wl`, `s08_required.wl`, `s08_cache/`, and `s08_run.log`. All 81 requested masters are evaluated through epsilon^1 with at most a single angular pole. LL values separate Regular from Coalescing; multiply the latter by `(1-z)^(-eps)`. S11 must use the exact finite-epsilon hypergeometric connection before its soft recoil series. The higher mixed master relation passed both polar boundary and exact integrand reconstruction gates; the preserved source and accepted cache input hashes document reused masters. Successful monitored RSS peaked at 1021.6 MiB.

S11 checkpoint convention: `s11_cache/Pg_NNN.wl` and `Ppp_NNN.wl` store each complete ordinary contribution and both regulated soft-coordinate expansions. The cache includes the immutable source that generated reused terms; acceptance requires a source-plus-S07-plus-S08 hash listed by the current stage. Branch geometry is memoized, rational coefficients are factored, and the system simplification cache is cleared periodically to retain RAM headroom. No term is accepted from a partial ordinary-only calculation.

S11 endpoint logarithms: retain the physical side s23>0 when expanding logarithms. Factor logarithm arguments, use `PowerExpand` with explicit branch assumptions, then simplify each remaining recoil-log coefficient exactly before accepting recoil independence. For the first mixed-master endpoint requiring this step, Wolfram returned zero for the Log[s23] coefficient in both branches. No assumed-zero logarithmic term is dropped.

S11 branch checkpoints: `s11_cache/s11_Pg_branch_1.wl`, `s11_Pg_branch_-1.wl` and corresponding Ppp files store complete distribution coefficients. Reuse requires a preserved source/input hash. Distribution assembly multiplies the already-expanded Laurent coefficients by the small regulated kernels coefficient by coefficient. S12 checks the resulting L0/L1/regular ordinary-part reconstruction against S11 Ordinary before its IR gates. The S12 `StructureFunctions` export will contain assembled F1/F2 expressions with their distributions and coordinate-boundary treatment.

Accepted S11 artifacts: `s11_real_phase_space.wl`, `s11_result.wl`, `s11_cache/`, and `s11_run.log`. All 187 Pg and 147 Ppp terms and four complete coordinate branches passed their stage gates. S12 independently confirmed the ordinary-part reconstruction for each projector and branch. `Real` contains Ordinary and Branches; each branch supplies Delta, L0, L1, Regular and SoftCoefficients with its assumptions. The regulator is recorded in `Regulator`, the branch map is `t -> sign omega-s`, and Ln is `[Log[s23/B]^n/s23]_+` on [0,B]. The hard tensor factor `(2 Pi)^(-4)` is still deferred to S12. Source snapshots and accepted input hashes identify reused exact checkpoints. The successful final resume peaked at 3020.0 MiB monitored RSS; earlier guard stops resumed only from completed checkpoints.

S12 memory convention: expand only the regulator when combining Laurent inputs and extracting finite coefficients; retain factored kinematic expressions. Clear the symbolic system cache before an unsaved contraction. The prior fully expanded S12 checkpoints, source and logs are preserved in `s12_cache_expanded_b03ad1751fe0/` for provenance. The revised source regenerates its S12 caches and reruns all acceptance gates.

S12 full IR acceptance: `s12_poles.wl` has `Accepted -> True`. Every input negative regulator power cancels exactly in each of Delta, L0, L1 and Regular for Pg/Ppp and both coordinate branches; L1 contains no pole. The four independent S11 ordinary-distribution reconstructions also passed. The accepted finite contraction checkpoints are in `s12_cache/`, generated with regulator-only expansion. This IR acceptance is separate from the final structure-function export and coordinate-boundary gates. Source SHA256: `c72a5c75a7186b490d10d403b3a869272f9e6a136dfe7b1ddaeb211398afc162`.

S12 boundary evaluation: normalize the finite logarithmic expressions with explicit physical assumptions before taking one-sided omega limits. Store each evaluated finite side in `s12_cache/Boundary_F1_Delta_1.wl` and the corresponding structure-function/distribution/sign files; the expression/assumption hash and accepted source hash gate reuse. Both sides must agree exactly before the boundary enters the final hats. Immutable `s12_cache/s12_source_*.wl` snapshots identify accepted earlier contraction caches; the final export records all accepted source/input hashes. This revision changes boundary evaluation and checkpointing only.

S12 boundary-series convention: use the accepted S11 interior branch assumptions for logarithm normalization and the one-sided omega series. The entire series through order zero must simplify to an omega-independent finite value; no negative power or logarithm is silently discarded. Unresolved Series/Limit/Derivative/ConditionalExpression outputs fail acceptance. This computes the same boundary limit and retains exact agreement of both coordinate branches as the gate. The already computed F1 Delta positive-side direct Limit remains a valid independent checkpoint. Wolfram Series branch-assumption syntax follows https://reference.wolfram.com/language/ref/Series.html .

S12 Regular boundary memory order: take the exact omega series before general kinematic expansion/simplification. Simplifying the full multi-variable Regular expression first exceeded the RSS ceiling. The final full-series finiteness and opposite-side equality gates are unchanged. Source snapshots preserve all accepted earlier boundary and contraction checkpoints.

S12 Regular term checkpoints: partition with `Expand` restricted to logarithmic/special-function factors, keeping kinematic factors intact. Exact reconstruction of the partition is required. `s12_cache/Series_F1_Regular_1_00001.wl` and corresponding name/sign/index files save each evaluated symbolic series with its expression/assumption hash and source/input hash. Individual terms may retain negative omega powers or logarithms; only the complete sum is required to be omega-independent and finite. The system cache is cleared every five terms. General logarithmic reduction likewise restricts expansion to collected functions before factoring their coefficients. This is the same linear series calculation with bounded memory and resumable pieces.

S12 shared boundary-series cache: `s12_cache/SeriesShared_<hash>.wl` stores the series of each omega-dependent factor, keyed by that factor and its complete assumptions, with accepted source/input provenance. Omega-independent factors are selected from the actual term and their product with the dependent factor must reconstruct that term exactly. They are restored after reading/computing the series. This permits exact reuse between F1 and F2 without copying channel coefficients. The partition identity uses restricted algebraic Expand only. No per-index Series cache was produced before this change.

S12 Regular finite-sum handling: after adding the cached term series, leave omega-independent terms in their exact form and simplify only any remaining omega-dependent terms. An algebraic reconstruction gate checks this partition. The final full expression still must be omega-independent and finite, and both branch values must agree. This avoids an unnecessary general simplification of the already finite constant part.

Accepted S12 artifacts: `s12_final_hats.wl`, `s12_result.wl`, `s12_poles.wl`, `s12_cache/`, `s12_run.log`, and `s12_frozen_inputs.json`. All negative regulator coefficients cancel exactly for Pg/Ppp in both branches. All F1/F2 boundary values are finite and their two sides agree exactly. `StructureFunctions` contains the assembled LO+NLO F1/F2 distributions; `Hats` contains LODelta and NLO Delta/L0/L1/Regular coefficients; `BoundaryAtTEqualsMinusS` supplies the evaluated common boundary values. `BranchCoordinates`, `BranchDomains`, `PlusDefinition`, and `PhysicalRegion` specify the representation. The hard normalization and coupling conversion are included. `AuthorsCoefficientsUsed` is False. The final successful run peaked at 1528.5 MiB RSS. Frozen result SHA256: `0c31db0e92387801fe41300d055bcf793ddbf231ff94624fd88f6153d12c958c`.

## S13 comparison contract

Verify the frozen S12 hashes before and after comparison. Read only the authors Hqg coefficient data and its source/convention metadata. Derive and check the variable and distribution maps, then compare symbolically within the color/scale domain supported by the authors data. Record precision or reconstruction assumptions separately from exact identities. Export exact differences and the actual equality outcomes. The comparison cannot alter an independent production coefficient or normalization.

S13 implemented mapping: a symbolic Gram matrix derives paper Eqs. 21-27 and the transverse momentum from its defining orthogonality conditions. Its inverse map must equal the author KinematicRules and reduce to independent S02 Born kinematics. The coefficient-times-plus rule is derived from equality of test-function integrands; author Log[s23/Q^2] is converted to the S12 Log[s23/B] basis, and recoil-dependent plus coefficients are reduced to their endpoints with the remaining ordinary contribution preserved. The common comparison is first made in independent invariants s,t; the verified physical-variable map acts on both coefficient and test function when pulling back to fixed xhat,Q,qT2. Author rational reconstruction remains an explicit conditional input. `s13_cache/` stores comparison inputs, evaluated canonical coefficients and exact equality outcomes. Frozen S12 hashes are gated before and after.

S13 auxiliary identity contract: `s13_dilogarithm_identities.wl` derives inverse, Mobius and complement dilogarithm transformations by solving their differentiated logarithmic basis and fixing the integration constants at finite endpoints. Derivative and endpoint residuals must vanish. Reality on the unit interval is derived from the defining real series and a summable absolute majorant. `s13_dilogarithms.wl` is a mathematical normalization input only after all gates pass; `s13_delta_transform_diagnostic.wl` identifies the stage producing an indeterminate comparison. Neither is an input to S12.

S13 author-input recovery: the archived S03 direct-substitution shortcut left a physical zero-times-singular logarithmic product in the positive-branch Delta input. The original endpoint stage is corrected to refine each physical sign branch before accepting substitution and otherwise take the defining finite-recoil one-sided limit. Prior S03 outputs and dependent S13 caches are versioned away; S12 frozen files are unchanged. The regenerated authors representation explicitly excludes s+t=0; S13 compares both open branches.

S13 normalization contract: each radical and special function is reduced separately under the complete physical assumptions. Dilogarithm inverses and complements use `s13_dilogarithms.wl`, with its generating source hash and unit-interval domains checked. The real defining-series identity permits temporary real placeholders only for proved unit-interval dilogarithms. The resulting expression is collected as a polynomial in formal functions and its algebraic coefficients are factored separately. Every normalized result must remain finite; function checkpoints include the current input/source hash. This changes comparison reduction only.


Accepted corrected author S03: `comparison/s03_assemble_fhats.wl`, `comparison/s03_result.wl`, `comparison/s03_tensor_Pg.wl`, `comparison/s03_tensor_Ppp.wl`, both zero cutoff files, and `s13_author_endpoints_run.log`. Each physical-branch endpoint is finite and both endpoint/plus cutoff identities passed. Source SHA256 450b0bc6e7d1e4eccc7528405d36e4d75df78223b8865ca2924b936e0fc29f27; result SHA256 a0a0cecffaf068a7ace491b1b623f10f15913be45c1be03ded0d2c27a719f464. The author representation excludes s+t=0. The guarded run exited 0 with peak RSS 690.2 MiB. These remain author-derived comparison data; independent S12 is unchanged.

S13 delta nonidentity contract: `s13_delta_nonidentity.wl` reads only completed Delta comparison checkpoints. It asks Wolfram for the exact dilogarithm range on the unit interval, proves any inequality added to an equality test from that range, and tests the saved equality with nonzero symbolic quark charge. A False result certifies a nonidentity; any unresolved result remains explicitly unresolved. The helper uses 512 MiB per operation and a 1 GiB RSS guard and cannot modify S12 or main comparison checkpoints.

S13 accepted delta decision: `s13_delta_nonidentity.wl`, `s13_delta_nonidentity_result.wl`, and `s13_delta_nonidentity_run.log` prove all four Delta equalities False for nonzero symbolic charge by Wolfram FunctionRange and exact physical-domain implications. InputHash and the exact comparison checkpoint hash bind each proof to the saved difference. The comparison export retains both the original equality and `EqualityForNonzeroCharge`, with the compact exact Difference and proof. This establishes a mismatch with the authors reconstruction without selecting which calculation is correct.

S13 phase reduction: ArcTanh expansion can generate Arg functions. Reduce each Arg/Abs/Sign under the physical assumptions before collecting algebraic coefficients. Reused function results remain exact; the preserved prior source binds accepted cached comparisons. No phase is dropped by assumption.

S13 rational coefficient checkpoints: `s13_cache/Coefficients_<hash>.wl` stores the exact formal-function coefficient list, and `Algebraic_<hash>.wl` stores each completed Together reduction. Expression/assumption and accepted source/input hashes gate reuse. Every coefficient is finite and logs its exact zero status. This combines rational terms without requiring an unnecessary full polynomial factorization. A monitor may resume after a time or RAM guard only when new complete algebraic checkpoints were produced; the same limits remain.

S13 factor-preserving grouping: partition the restricted-expanded formal polynomial into each term's function-dependent monomial and independent factor. Both the product reconstruction and the regrouped expression are checked exactly before acceptance. `GroupedCoefficients_<hash>.wl` stores these monomial/coefficient pairs without a general CoefficientRules expansion; existing `Algebraic_<hash>.wl` reductions remain keyed by the exact expression and assumptions. Old expanded coefficient-list checkpoints are retained for provenance and cannot collide with the new cache format.

S13 grouping acceptance uses exact term-product reconstruction, exact preservation of the multiset of original factor rows, a single common monomial per group, and Wolfram's scalar distributive identity. These establish the regrouping without re-expanding kinematic coefficients. Each rational summand is factored before the full Together operation; this is exact rational algebra under the same physical-domain representation. A failed direct syntactic reconstruction produced no accepted grouped cache.

S13 completed rational coefficients are factored after their Together checkpoint is read. The resulting complete finite comparison is saved as `<label>_reduced.wl` before analytic equality testing, with an exact mapped-expression/assumption hash and accepted source/input provenance. This prevents repetition of the completed rational reduction when an analytic equality test needs a different evaluation strategy.

S13 inverse-hyperbolic conversion: ArcCoth is converted by ComplexExpand and the exact difference from the original function must simplify to zero under the physical assumptions before use. The conversion runs before coefficient collection. Already saved remainders containing ArcCoth are normalized directly, preserving the completed rational checkpoints. This addresses representation only and cannot choose a finite physics coefficient.

S13 first accepted Regular comparison: `s13_cache/F1_1_Regular.wl` records Equality True, and `F1_1_Regular_reduced.wl` is exact zero. The inverse-hyperbolic conversion was independently verified under its physical assumptions before this acceptance. The Delta nonidentity proof remains separate and unchanged.


## Accepted S13 comparison

Accepted artifacts: `s13_compare_authors.wl`, `s13_result.wl`, `s13_run.log`,
`s13_cache/`, `s13_delta_nonidentity.wl`, and
`s13_delta_nonidentity_result.wl`. The successful final run exited 0 and
peaked at 1892.2 MiB monitored RSS. All frozen S12 hashes and the unchanged
author-input hash passed at completion.

Both Born coefficients, L0/L1 coefficients, and all Regular coefficients agree
exactly in both coordinate branches. All Delta comparisons are proved unequal
for nonzero symbolic quark charge. The comparison specializes only the authors'
supported SU(3) color value and common scale. Long author decimals retain the
explicit rational-reconstruction assumption with denominator at most 10^6.

Load `s13_result.wl` and read `Comparisons`. Each Delta entry includes its compact
exact `Difference`, `EqualityForNonzeroCharge -> False`, and its bound
`NonidentityProof`. The other entries have `Equality -> True` and
`Difference -> 0`. `DeltaNonidentityProof` records the exact function-range and
physical-domain evidence. `AllEqual` is False.

The independent `s12_result.wl` remains unchanged and contains the final symbolic
F1/F2 through NLO. This comparison establishes the finite Delta discrepancy; it
does not establish which calculation is responsible. No production coefficient
or normalization was adjusted to obtain author agreement.

S13 source SHA256: `2469d1d53b67b833e9c5e9cc0db0cf7ada3fa94cffeea37c31d5df7e9fceea37`.
S13 result SHA256: `c3fd17bb39e701b781a806d6b5b65213732c1094757e6eae83762a11c45b2f5f`.


## Numerical BigTMD comparison

The user-authorized numerical comparison is in `bigTMD/`; its README records
the exact sources, outputs, conventions and hashes. Only Hqqprime benchmark
seeds and report format were reused. Physics inputs remain the independent
frozen Hqg S12, accepted Hqg S13 maps and pinned BigTMD channel 3A.

`bigTMD/s01_result.json` contains the 60-digit numerical export and derived
physical Jacobian/plus-coefficient transport. The direct published-Python
ordinary NLO density agrees at all six F1/F2 benchmark values, with maximum
relative difference 3.9362819690409382e-15. The canonical Born, L0, L1 and
Regular coefficients agree; all six NLO Delta values differ.
`bigTMD/bigtmd_minus_local.md` is the numerical table and
`bigTMD/bigtmd_minus_local.json` retains every signed difference and tolerance
decision. The author canonical table retains the existing rational-
reconstruction assumption; the direct Python table executes the published
decimals as written. The three numerical seeds sample the positive branch.
S12 and S13 are unchanged, and no result was tuned to force agreement.


## MadGraph tree projector comparison

The user-authorized quick comparison is complete in `madgraph_check/`. It
generates fresh photon-only Born `e- u -> e- u g` and real
`e- u -> e- u g g` processes with MadGraph 3.7.0. Only generic generator
software is reused; no other channel coefficient or calculation program is
a physics input. Exact copies of the accepted Hqg S02/S04/S05 artifacts
supply the independent side.

SymPy derives the lepton mass-shell map and exact finite azimuth quadrature.
Two lepton kinematics reconstruct both Pg and Ppp at each fixed hadronic
point. Generated species/IDEN and the S05 tag weight fix the conversion to
the observed-gluon convention; no factor is fitted. The direct Fortran/C
interface, physical momenta, generated/independent diagram counts, runtime
couplings and source bindings passed their gates.

All 32 projector comparisons at 16 Born/real points passed, with maximum
relative difference 2.0568861206860341e-12. All azimuth averages and the real-gluon
exchange check also passed. `madgraph_check/s05_result.json` contains the
complete numerical result; `madgraph_check/madgraph_minus_local.md` is the
table, and that folder README records exact artifact identities.

This checks the tree projector boundary after spin/color sums (corresponding
to the Hqqbar S07 boundary discussed with the user). It is not a separate
check of every open-tensor component, nor a test of virtual integration,
subtraction or the NLO delta discrepancy. Parent results are unchanged.


## Numerical consumer artifacts for the H1 comparison (previous Hgq_v3 generation)

The supplied terminal payloads are frozen unchanged under `../numerics/previous_Hgq_v3/Fhats/Hqg_v3/`. The numerical coefficient receipt is `../numerics/previous_Hgq_v3/s05_cache/Hqg_v3_result` (SHA-256 `1ba766c66783ce4118dce7037723a903da0d5a932b838dcc94cdc44d439c2c84`). Its exact source snapshots and original-expression comparisons define this consumer export.

The saved `JacobianAlreadyIncluded` flags are `[False]`. The consumer applies the S04 fragmentation Jacobian externally whenever the saved flag is false. Distribution actions and flavor bookkeeping follow `../numerics/previous_Hgq_v3/s08_result`; the map and measure definitions follow `../numerics/previous_Hgq_v3/s04_result`. MRST2002 NLO and both KKP/Kretzer neutral-pion NLO FFs use the central common scale defined there. The supplied F1/F2 tensor has the recorded azimuth-independent acceptance treatment.

All 168 saved native comparisons for this channel passed in `../numerics/previous_Hgq_v3/s07_result` (SHA-256 `96fedb34243fceae228e9e3225c77ee20f60ac457e0c06b1c0dd610889cf286c`). The full independent precision receipt is `../numerics/previous_Hgq_v3/s10_result` (SHA-256 `50be42f83e76734649862ab040229831e8a740c6439de83905405da549a447ea`). Hadronic bin outputs must additionally pass S09 numerical precision, iteration consistency and channel-sum gates. See `../numerics/previous_Hgq_v3/README.md` for the complete numerical consumer contract and provenance.


## Accepted H1 numerical consumer result

The accepted six-channel numerical consumer is `../numerics/previous_Hgq_v3/s09_result` (SHA-256 `eb4d06f678d9416f30588e76aaaadd363cbb2865b06d7d1f3c9da318060699d4`), with producer `../numerics/previous_Hgq_v3/s09_convolve_channels.py` (SHA-256 `86922f5701629c5cef22263a10a21d89552a5bb5e470025f08addbc663b19dba`). All 17 H1 bins passed its precision/stability and channel-sum gates. Per-bin LO/NLO channel contributions, FF labels and complete numerical covariance are retained in that result; the inherited conventions recorded above are unchanged. The supplied channel payload was not modified.

The comparison receipt is `../numerics/previous_Hgq_v3/dsigmapibydpt/s03_result` (SHA-256 `813c65b2ee17d53757c8020661d33e533e1083e942d090970b7f50ebb5438afd`), binding the accepted cross-section and ratio PDF/PNG artifacts. Numerical errors are integration only; the common central-scale, azimuth-independent and user-overridden Hgq_v3 boundaries remain those of the numerical ledger. See `../numerics/previous_Hgq_v3/README.md` for accepted input and writer-handoff identities and consumer instructions.


The active numerical consumer uses the user-requested Hgq_v4 replacement under `../numerics/`; the identities above belong to the archived Hgq_v3 generation. This channel's supplied mathematical payload is unchanged. The active consumer contract is in `../numerics/README.md`.

### Accepted Hgq_v4 six-channel numerical consumer

The current numerical channel set is Hqq_v2, Hgg, Hqqbar, Hqqprime, Hgq_v4 and Hqg_v3. `../numerics/s05_cache/Hqg_v3_result` has SHA256 `1ba766c66783ce4118dce7037723a903da0d5a932b838dcc94cdc44d439c2c84`. Import manifest SHA256 `eee1b32a94c9b3f0500c76437035ce48b6a3dbdc8ae1d8add8fefdbc4da8aace`; six-channel result SHA256 `872f98c70e9b860387ed72bf61fad3013e986a599c5234ae6d154f5896cb2c17`; aggregation receipt SHA256 `d9d8de8d23d3d1bcbfd49f8d7c77f6e9b16e4cabd23cd52089105c023c0c44e3`. All 17 bins pass the original final numerical gates. Fifteen bins preserve the five unchanged channels with complete covariance; q0_p3 and q1_p2 use fresh full-channel samples after their saved covariance floors exceeded the new total precision target. Supplied channel coefficients and PDF/FF/cut conventions are unchanged by this numerical consumer. Figure receipt: `../numerics/dsigmapibydpt/s03_result`, SHA256 `22408cbc8d3cf4e093cc234a6cb356198c54a68981737579a8ff0e11bac5d8b4`. The v4 comparison limitation and uniform-azimuth convention remain explicit in the numerical output.
