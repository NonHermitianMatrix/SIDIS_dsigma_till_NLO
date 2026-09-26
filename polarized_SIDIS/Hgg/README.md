# Hgg: Incoming gluon; tagged gluon

The process inventory is `gamma* g -> g(k1) q_i anti-q_i`. The tagged parton always has momentum `k1`. This folder owns its channel amplitudes, stage outputs, accepted checks and final hats. Read [README_code.md](README_code.md) for the complete preserved convention ledger and [README_sources.md](README_sources.md) for exact code/configuration bytes. The [report](../polarized_SIDIS_report.pdf) explains this channel and all shared equations from start to end.

## Spin, flavor and normalization

Both resolved axes are gluon Stokes responses. This is real-only through alpha_s^2: the direct LO delta is zero and there is no same-channel virtual interference. The produced-quark charge sum, not a fixed incoming-quark charge, supplies the electromagnetic bookkeeping.

The spin order is `U,X,Y,H` with outgoing rows and incoming columns. Incoming U averages and outgoing U sums the two physical states. Dimensional E components are bookkeeping for regulated intermediate states, not extra physical polarization states. Charge, flavor, phase-space and spectator factors are restored by the accepted assembly; never add another factor based only on the channel name.

## Start-to-finish path

### S01: Pin amplitudes and measurement

Import the original open amplitudes, field/flavor assignments and comparison tensors from the pinned GitHub commit. The tagged momentum is k1. Validate each input identity before using it; a spin-summed tensor is a comparison, not a source of polarized coherences. See the [common S01 explanation](../common/README.md) for the full shared contract.

### S02: Define spin and photon bases

Derive the U/X/Y/H Pauli insertions, fermion wavefunction projectors, gluon Stokes tensors and nine Hermitian photon components. Incoming identity is averaged by two; outgoing identity is a spin sum. Check completeness, normalization, Hermiticity, Dirac identities and reconstruction. Rows are outgoing and columns incoming. See the [common S02 explanation](../common/README.md) for the full shared contract.

### S03: Contract Born and auxiliary Born amplitudes

Insert the resolved spin projectors into the two-body open amplitudes, solve the physical frame and retain D-dependent completion. Reconstruct the original CDR scalar contractions and test Ward identities. Auxiliary Born tensors supply lower-order subtraction routes; they are not direct LO terms in real-only channels. For this channel these are auxiliary subtraction Born routes only; the direct channel LO delta remains zero. See the [common S03 explanation](../common/README.md) for the full shared contract.

### S04: Average the residual unresolved angle

Solve the p,q,k1 Gram geometry and split the orthogonal momentum into one physical normal and D-4 evanescent directions. Derive normalized beta/Gamma-function moments and compare Gaussian moments. Reconstruct the numerator before applying them. Use the cut radius for real radiation and the general off-shell radius for virtual loops. See the [common S04 explanation](../common/README.md) for the full shared contract.

### S05: Build the real-emission spin tensor

Contract every generated real amplitude and interference pair with the spin insertions, D-dimensional unresolved sums and photon projections. Complete off-diagonal pairs by photon-matrix Hermitian conjugation. Restore scalar products and angular moments; require complete spin reconstruction, Ward/Hermiticity gates and the CDR reference comparison. See the [common S05 explanation](../common/README.md) for the full shared contract.

### S06: Reuse matching scalar integral inputs

Reuse scalar geometry, cut and ordinary loop masters, Kira rules, soft-region expansions and UV inputs only when measure, routing, cuts, continuation and epsilon depth match. New spin numerators can request extra targets; an uncovered target is not zero. See the [common S06 explanation](../common/README.md) for the full shared contract.

### S08: Map and reduce real cut integrals

Use the reference reverse-unitarity map with positive-energy support and exact numerator reconstruction. Inventory all targets, reuse covered Kira rules and extend missing ones with original-rule equality and unchanged-master-basis gates. Assemble rational master coefficients exactly. The accepted producer variant is channel-specific. See the [common S08 explanation](../common/README.md) for the full shared contract.

### S10: Construct collinear spin operators

Derive daughter/parent spin matrices from native splitting amplitudes. Separate ordinary, plus and delta terms. Compare UU and HH distributions with their specified libraries. Parent-first repository kernel names differ from daughter-first P labels. Native dimensional transfer extensions retain the E complement and projector Gram duals. See the [common S10 explanation](../common/README.md) for the full shared contract.

### S11: Convolute PDF and FF subtraction routes

Auxiliary qg, gq and charge-conjugate Born routes supply incoming and outgoing off-diagonal factorization terms. The native MS operator is applied to each own route, with complete intermediate states and exact comparison against the original route. The local integrated-real S11 is a different artifact from this subtraction. The accepted producer is [common/s11_Hgg_native_routes.wls](../common/s11_Hgg_native_routes.wls) and the consumed result is [Hgg/s11_native_result/s11_result.wl](s11_native_result/s11_result.wl). See the [common S11 explanation](../common/README.md) for the full shared contract.

### S12: Integrate real radiation and endpoints

Multiply exact reduced coefficients by masters at sufficient epsilon depth, restore physical transverse kinematics before the recoil endpoint limit, and extract Delta/L0/L1/Regular tensors. Retain both t=sign*omega-s branches and their common boundary. Factored or regulator-aware variants preserve exact ordinary and endpoint reconstruction. See the [common S12 explanation](../common/README.md) for the full shared contract.

### S14: Assemble finite BMHV coefficients

Restore state/phase, coupling, color, charge/flavor and spectator factors in matching conventions. Add real, renormalized virtual where present and signed PDF/FF terms. Require every negative epsilon coefficient to vanish in each independent component/distribution/branch; compare both final UU hats with the pinned reference. Axial conversion is still deferred. See the [common S14 explanation](../common/README.md) for the full shared contract.

### S15: Apply finite helicity restoration and export

Use the signed quark helicity scheme kernel and the accepted S11 convolution to add the finite correction on its selected spin leg. Check absent endpoints, unchanged UU and real-only route conditions. Reproject F1/F2 and reject unevaluated regulators, integrals, failures or machine numbers. Preserve complete metadata and exact saved-output identities. See the [common S15 explanation](../common/README.md) for the full shared contract.

## Accepted execution entry points and result directories

This table is extracted from saved execution receipts. It records the producer that ran, not an assumption based on a channel symlink. A configuration is listed only when its bytes match the receipt hash. Some accepted stages consume archived source implementations. Preserve those inputs.

| Stage label | Executed source | Result directory | Bound job configuration |
|---|---|---|---|
| s05 | [common/s05_resume_Hgg_complete_export.wls](../common/s05_resume_Hgg_complete_export.wls) | [Hgg/s05_result](s05_result) | [.cluster/s05_Hgg_complete_export_native_text_resume_job.json](../.cluster/s05_Hgg_complete_export_native_text_resume_job.json) |
| s07 (local real sequence) | [misc/s07_merge_Hgg_coefficients.wls](../misc/s07_merge_Hgg_coefficients.wls) | [Hgg/s07_result](s07_result) | [misc/s07_inputs.json](../misc/s07_inputs.json) |
| s09 (local real sequence) | [misc/s09_reduce_Hgg_targets.wls](../misc/s09_reduce_Hgg_targets.wls) | [Hgg/s09_result](s09_result) | [misc/s09_inputs.json](../misc/s09_inputs.json) |
| s11 | [common/s11_small_collinear_spin.wls](../common/s11_small_collinear_spin.wls) | [Hgg/s11_result](s11_result) | [.cluster/s11_Hgg_dimensional_corrected_job.json](../.cluster/s11_Hgg_dimensional_corrected_job.json) |
| s14 | [misc/s14_assemble_Hgg_finite.wls](../misc/s14_assemble_Hgg_finite.wls) | [misc/s14_result](../misc/s14_result) | [misc/s14_inputs.json](../misc/s14_inputs.json) |
| s15 | [misc/s15_finalize_Hgg_hats.wls](../misc/s15_finalize_Hgg_hats.wls) | [Hgg/s15_result](s15_result) | [misc/s15_inputs.json](../misc/s15_inputs.json) |

The final subtraction input is [Hgg/s11_native_result/s11_result.wl](s11_native_result/s11_result.wl). Auxiliary qg, gq and charge-conjugate Born routes supply incoming and outgoing off-diagonal factorization terms. The native MS operator is applied to each own route, with complete intermediate states and exact comparison against the original route. The local integrated-real S11 is a different artifact from this subtraction.

## Hgg local-to-shared numbering and aliases

The accepted local real path is `misc/s06_map_Hgg_local.wls` → `s07_merge_Hgg_coefficients.wls` → `s08_collect_Hgg_targets.wls` → `s09_reduce_Hgg_targets.wls` → `s10_reduce_Hgg_coefficients.wls` → `s11_assemble_Hgg_real.wls` → `s14_assemble_Hgg_finite.wls` → `s15_finalize_Hgg_hats.wls`. These are real mapping, target inventory, IBP reduction, coefficient assembly, real integration, finite assembly and export respectively. There is no Hgg virtual stage hidden in local S07/S09.

[Integrated real](s11_local_real_result/) points to `../misc/s11_result`; [finite assembly](s14_local_finite_result/) points to `../misc/s14_result`; [final hats](s15_result/) points to `../misc/s15_result`. The original `Hgg/s11_result` remains the earlier subtraction record, and `Hgg/s11_native_result` is the completed subtraction used by the final assembly. Do not overwrite either with the local integrated-real result.

The native `.wl` loader and its sibling `*_parts/` directory form one result. Piece hashes are checked during loading. Keep each complete directory; copying only the small loader loses its coefficients. The exact bounded storage implementation is `misc/s40_chunked_native_record.wls`; native whole-record and individual-piece reconstruction were accepted before final publication.

## Result schema and interpretation

Load FeynCalc before the native Wolfram files to preserve color-symbol contexts. The full `s15_result/s15_result.wl` is an Association with `PhotonLabels`, `SpinLabels`, `IndexOrder`, `PhysicalFrame`, `ProjectorDefinitions`, `FhatPhotonWeights`, `Bookkeeping`, `PlusDefinition`, `BranchConvention`, `PhysicalConditions`, scheme flags, `LODeltaResponse`, `NLOResponse`, and `Fhats`.

`Fhats["F1"]` and `Fhats["F2"]` each have `LODelta` and `NLO`. `NLO[sign][distribution]` is a 4×4 matrix. The branch keys are integer `1`, `-1`, `0`: `t=sign*omega-s` with `omega>0`, while `0` is the separately established `t=-s` boundary. Select one branch; do not sum them. Distribution keys are `Delta`, `L0`, `L1`, `Regular`. Couplings and charge factors are restored in the stored coefficients; do not multiply by another order-counting power of alpha_s.

`NLOResponse[sign][distribution]` has dimensions 9×4×4 and retains the photon information needed beyond F1/F2. F1/F2 are the legacy contractions, not a complete polarized angular structure-function basis. `s15_F1_hat.wl` and `s15_F2_hat.wl` contain only the corresponding `LODelta`/`NLO` associations; read the full record for conventions. Acceptance requires the matching `s15_execution.json` (`passed: true`), `s15_checks.json` (`finite_nlo_fhats_computed: true`), and matching recorded hashes, including companion parts where present.

## General mathematical form of the large files

For photon component `A`, outgoing spin `j` and incoming spin `i`, a contracted amplitude file contains coefficients of the bilinear spin polynomial

$$R_A(a,p)=\sum_{j,i\in\{U,X,Y,H\}} a_j R_{A,ji}p_i.$$

The mapped-integral files have the form

$$R_{A,ji}=\sum_\alpha c_{A,ji;\alpha}(Q^2,s,t,s_{23},D) I_\alpha,
\qquad I_\alpha=\sum_m r_{\alpha m}M_m.$$

Coefficients are exact algebraic/rational expressions with the recorded spin-frame factors. Master assembly multiplies them by regulated expansions `sum_n eps^n M_m^(n)`, retaining enough depth for the finite term. The finite entries are sums of exact color/charge factors and algebraic prefactors multiplying the analytic functions supplied by the masters, such as logarithms, their products and polylogarithmic or equivalent branch-resolved functions where present. These forms describe organization; they do not assert every allowed term is nonzero.

The final matrix-valued distribution is

$$\widehat{\mathbf F}_r=\mathbf F_r^{LO}\delta(s_{23})+
\mathbf F_r^{NLO,\Delta}\delta(s_{23})+
\mathbf F_r^{NLO,0}\left[\frac1{s_{23}}\right]_+
+\mathbf F_r^{NLO,1}\left[\frac{\log(s_{23}/B)}{s_{23}}\right]_+
+\mathbf F_r^{NLO,reg},\qquad r=1,2.$$

Each bold coefficient is a 4×4 matrix, with rows outgoing and columns incoming in order `U,X,Y,H`. A matrix entry is a coefficient, not a probability. The full photon response contains nine such matrices. Plus distributions act on a smooth test function by subtracting its value at zero on `[0,B]`; they are not ordinary functions at the endpoint. The source and final metadata fix the exact arguments, normalization, branch and charge factors.

## What the acceptance checks establish

The dimensional spin sum is reconstructed, including the regulator complement and incoming-gluon average, and compared with the matching original CDR contractions. Final physical `UU` F1/F2 entries are compared with the pinned spin-summed hats, including distribution slots and branches. Other spin entries are checked by basis reconstruction, Ward identities, Hermiticity, dimensional route consistency, exact reduction/integration reconstruction, UV and full pole cancellation, scheme checks and native export validation.

The unpolarized reference cannot individually validate polarized entries it does not contain. These checks and the recorded independent tree-level comparisons are not a claim of an independent complete finite polarized NLO comparison. See the report and the preserved ledger for the exact scope of each check.
