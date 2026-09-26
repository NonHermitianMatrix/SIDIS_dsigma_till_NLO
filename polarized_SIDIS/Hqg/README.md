# Hqg: Incoming quark; tagged gluon

The process inventory is `gamma* q_i -> g(k1) q_i; real g(k1) q_i g`. The tagged parton always has momentum `k1`. This folder owns its channel amplitudes, stage outputs, accepted checks and final hats. Read [README_code.md](README_code.md) for the complete preserved convention ledger and [README_sources.md](README_sources.md) for exact code/configuration bytes. The [report](../polarized_SIDIS_report.pdf) explains this channel and all shared equations from start to end.

## Spin, flavor and normalization

Columns are quark spin and rows are gluon Stokes responses. The outgoing resolved gluon dyad uses the recorded analyzer transposition, while the other real gluon is summed. The accepted S05 linear assembly changes the representation, not the complete interference.

The spin order is `U,X,Y,H` with outgoing rows and incoming columns. Incoming U averages and outgoing U sums the two physical states. Dimensional E components are bookkeeping for regulated intermediate states, not extra physical polarization states. Charge, flavor, phase-space and spectator factors are restored by the accepted assembly; never add another factor based only on the channel name.

## Start-to-finish path

### S01: Pin amplitudes and measurement

Import the original open amplitudes, field/flavor assignments and comparison tensors from the pinned GitHub commit. The tagged momentum is k1. Validate each input identity before using it; a spin-summed tensor is a comparison, not a source of polarized coherences. See the [common S01 explanation](../common/README.md) for the full shared contract.

### S02: Define spin and photon bases

Derive the U/X/Y/H Pauli insertions, fermion wavefunction projectors, gluon Stokes tensors and nine Hermitian photon components. Incoming identity is averaged by two; outgoing identity is a spin sum. Check completeness, normalization, Hermiticity, Dirac identities and reconstruction. Rows are outgoing and columns incoming. See the [common S02 explanation](../common/README.md) for the full shared contract.

### S03: Contract Born and auxiliary Born amplitudes

Insert the resolved spin projectors into the two-body open amplitudes, solve the physical frame and retain D-dependent completion. Reconstruct the original CDR scalar contractions and test Ward identities. Auxiliary Born tensors supply lower-order subtraction routes; they are not direct LO terms in real-only channels. See the [common S03 explanation](../common/README.md) for the full shared contract.

### S04: Average the residual unresolved angle

Solve the p,q,k1 Gram geometry and split the orthogonal momentum into one physical normal and D-4 evanescent directions. Derive normalized beta/Gamma-function moments and compare Gaussian moments. Reconstruct the numerator before applying them. Use the cut radius for real radiation and the general off-shell radius for virtual loops. See the [common S04 explanation](../common/README.md) for the full shared contract.

### S05: Build the real-emission spin tensor

Contract every generated real amplitude and interference pair with the spin insertions, D-dimensional unresolved sums and photon projections. Complete off-diagonal pairs by photon-matrix Hermitian conjugation. Restore scalar products and angular moments; require complete spin reconstruction, Ward/Hermiticity gates and the CDR reference comparison. See the [common S05 explanation](../common/README.md) for the full shared contract.

### S06: Reuse matching scalar integral inputs

Reuse scalar geometry, cut and ordinary loop masters, Kira rules, soft-region expansions and UV inputs only when measure, routing, cuts, continuation and epsilon depth match. New spin numerators can request extra targets; an uncovered target is not zero. See the [common S06 explanation](../common/README.md) for the full shared contract.

### S07: Build the one-loop/Born spin interference

For Hqq, Hqg and Hgq, contract one-loop amplitudes with the Born amplitudes in both conjugate orders. Keep the complete complex photon response and general off-shell angular geometry. Compare original CDR integrand contractions. The real-only channels have no direct virtual sector at this order. See the [common S07 explanation](../common/README.md) for the full shared contract.

### S08: Map and reduce real cut integrals

Use the reference reverse-unitarity map with positive-energy support and exact numerator reconstruction. Inventory all targets, reuse covered Kira rules and extend missing ones with original-rule equality and unchanged-master-basis gates. Assemble rational master coefficients exactly. The accepted producer variant is channel-specific. See the [common S08 explanation](../common/README.md) for the full shared contract.

### S09: Map and reduce ordinary virtual integrals

Preserve ordinary propagators and routing; reconstruct the loop map and compare inherited CDR projections. Extend only the actual missing targets, check all old rules, and retain enough master depth. This stage is absent for the real-only channels; Hgg local S09 is instead a real reduction. See the [common S09 explanation](../common/README.md) for the full shared contract.

### S10: Construct collinear spin operators

Derive daughter/parent spin matrices from native splitting amplitudes. Separate ordinary, plus and delta terms. Compare UU and HH distributions with their specified libraries. Parent-first repository kernel names differ from daughter-first P labels. Native dimensional transfer extensions retain the E complement and projector Gram duals. See the [common S10 explanation](../common/README.md) for the full shared contract.

### S11: Convolute PDF and FF subtraction routes

The final FF subtraction includes native gluon-to-gluon and quark-to-gluon dimensional transfers on the channel's own Born routes. The physical four-state kernel alone does not retain all finite regulator contributions. Use this completed subtraction, not only the original s11_result. The accepted producer is [common/s11_finalize_Hqg_all_routes.wls](../common/s11_finalize_Hqg_all_routes.wls) and the consumed result is [Hqg/s11_msbar_result/s11_result.wl](s11_msbar_result/s11_result.wl). See the [common S11 explanation](../common/README.md) for the full shared contract.

### S12: Integrate real radiation and endpoints

Multiply exact reduced coefficients by masters at sufficient epsilon depth, restore physical transverse kinematics before the recoil endpoint limit, and extract Delta/L0/L1/Regular tensors. Retain both t=sign*omega-s branches and their common boundary. Factored or regulator-aware variants preserve exact ordinary and endpoint reconstruction. See the [common S12 explanation](../common/README.md) for the full shared contract.

### S13: Integrate and UV-renormalize virtual terms

Insert complex ordinary loop masters and auxiliary-mass UV residues, add the original field/coupling counterterms, and require componentwise UV cancellation and integrated Ward identities. Infrared poles remain until assembly. No direct S13 sector exists for Hgg/Hqqbar/Hqqprime at this order. See the [common S13 explanation](../common/README.md) for the full shared contract.

### S14: Assemble finite BMHV coefficients

Restore state/phase, coupling, color, charge/flavor and spectator factors in matching conventions. Add real, renormalized virtual where present and signed PDF/FF terms. Require every negative epsilon coefficient to vanish in each independent component/distribution/branch; compare both final UU hats with the pinned reference. Axial conversion is still deferred. See the [common S14 explanation](../common/README.md) for the full shared contract.

### S15: Apply finite helicity restoration and export

Use the signed quark helicity scheme kernel and the accepted S11 convolution to add the finite correction on its selected spin leg. Check absent endpoints, unchanged UU and real-only route conditions. Reproject F1/F2 and reject unevaluated regulators, integrals, failures or machine numbers. Preserve complete metadata and exact saved-output identities. See the [common S15 explanation](../common/README.md) for the full shared contract.

## Accepted execution entry points and result directories

This table is extracted from saved execution receipts. It records the producer that ran, not an assumption based on a channel symlink. A configuration is listed only when its bytes match the receipt hash. Some accepted stages consume archived source implementations. Preserve those inputs.

| Stage label | Executed source | Result directory | Bound job configuration |
|---|---|---|---|
| s03 | [common/s03_born_spin_response.wls](../common/s03_born_spin_response.wls) | [Hqg/s03_result](s03_result) | [.cluster/s03_Hqg_job.json](../.cluster/s03_Hqg_job.json) |
| s05 | [common/s05_real_spin_response_Hqg_linear_assembly.wls](../common/s05_real_spin_response_Hqg_linear_assembly.wls) | [Hqg/s05_result](s05_result) | [.cluster/s05_Hqg_linear_assembly_job.json](../.cluster/s05_Hqg_linear_assembly_job.json) |
| s07 | [common/s07_virtual_spin_response.wls](../common/s07_virtual_spin_response.wls) | [Hqg/s07_result](s07_result) | [.cluster/s07_Hqg_ward_resume_job.json](../.cluster/s07_Hqg_ward_resume_job.json) |
| s08 | [common/s08_map_real_spin_compact_inputs.wls](../common/s08_map_real_spin_compact_inputs.wls) | [Hqg/s08_result](s08_result) | [.cluster/s08_master_coefficients_Hqg_remaining_hqg_certified_maps_20260923_job.json](../.cluster/s08_master_coefficients_Hqg_remaining_hqg_certified_maps_20260923_job.json) |
| s09 | [common/s09_map_virtual_spin.wls](../common/s09_map_virtual_spin.wls) | [Hqg/s09_result](s09_result) | [.cluster/s09_Hqg_completed_spin_job.json](../.cluster/s09_Hqg_completed_spin_job.json) |
| s11 | [common/s11_collinear_spin_convolutions.wls](../common/s11_collinear_spin_convolutions.wls) | [Hqg/s11_result](s11_result) | [.cluster/s11_Hqg_dimensional_corrected_job.json](../.cluster/s11_Hqg_dimensional_corrected_job.json) |
| s12 | [common/s12_assemble_real_factored_series.wls](../common/s12_assemble_real_factored_series.wls) | [Hqg/s12_result](s12_result) | [.cluster/s12_factored_series_Hqg_remaining_hqg_certified_maps_20260923_job.json](../.cluster/s12_factored_series_Hqg_remaining_hqg_certified_maps_20260923_job.json) |
| s13 | [common/s13_assemble_virtual_refined.wls](../common/s13_assemble_virtual_refined.wls) | [Hqg/s13_result](s13_result) | [.cluster/s13_Hqg_refined_assembly_job.json](../.cluster/s13_Hqg_refined_assembly_job.json) |
| s14 | [common/s14_assemble_Hqg_finite_update.wls](../common/s14_assemble_Hqg_finite_update.wls) | [Hqg/s14_result](s14_result) | [.cluster/s14_Hqg_all_routes_20260924_job.json](../.cluster/s14_Hqg_all_routes_20260924_job.json) |
| s15 | [common/s15_finalize_Hqg_coefficients.wls](../common/s15_finalize_Hqg_coefficients.wls) | [Hqg/s15_result](s15_result) | [.cluster/s15_Hqg_all_routes_20260924_job.json](../.cluster/s15_Hqg_all_routes_20260924_job.json) |

The final subtraction input is [Hqg/s11_msbar_result/s11_result.wl](s11_msbar_result/s11_result.wl). The final FF subtraction includes native gluon-to-gluon and quark-to-gluon dimensional transfers on the channel's own Born routes. The physical four-state kernel alone does not retain all finite regulator contributions. Use this completed subtraction, not only the original s11_result.

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
