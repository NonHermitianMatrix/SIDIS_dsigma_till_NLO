# Common mathematics and shared workflow

Read this guide for the purpose, inputs and output contract of each common stage. The [physics report](../polarized_SIDIS_report.pdf) supplies the equations in sequence, including all channels; [README_code.md](README_code.md) preserves detailed accepted conventions and exact historical acceptance evidence. [README_sources.md](README_sources.md) contains the exact source/configuration listings, including archived implementations used by current adapters.

The regulator is BMHV with resolved physical spins and photon axes in four dimensions. Dimensional complements are retained until factorization and finite assembly. The final helicity convention includes the recorded finite restoration. Reference scalar integrals are reusable when their definitions match; spin-summed hard tensors do not determine polarized coherences.

## S01: Pin amplitudes and measurement

Import the original open amplitudes, field/flavor assignments and comparison tensors from the pinned GitHub commit. The tagged momentum is k1. Validate each input identity before using it; a spin-summed tensor is a comparison, not a source of polarized coherences.

Baseline implementation: [common/s01_prepare_inputs.py](s01_prepare_inputs.py). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **common/s01_inputs.json and each channel s01_result/reference**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S02: Define spin and photon bases

Derive the U/X/Y/H Pauli insertions, fermion wavefunction projectors, gluon Stokes tensors and nine Hermitian photon components. Incoming identity is averaged by two; outgoing identity is a spin sum. Check completeness, normalization, Hermiticity, Dirac identities and reconstruction. Rows are outgoing and columns incoming.

Baseline implementation: [common/s02_define_spin_basis.wls](s02_define_spin_basis.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **common/s02_result/s02_result.wl**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S03: Contract Born and auxiliary Born amplitudes

Insert the resolved spin projectors into the two-body open amplitudes, solve the physical frame and retain D-dependent completion. Reconstruct the original CDR scalar contractions and test Ward identities. Auxiliary Born tensors supply lower-order subtraction routes; they are not direct LO terms in real-only channels.

Baseline implementation: [common/s03_born_spin_response.wls](s03_born_spin_response.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **channel s03_result; auxiliary route subdirectories for real-only channels**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S04: Average the residual unresolved angle

Solve the p,q,k1 Gram geometry and split the orthogonal momentum into one physical normal and D-4 evanescent directions. Derive normalized beta/Gamma-function moments and compare Gaussian moments. Reconstruct the numerator before applying them. Use the cut radius for real radiation and the general off-shell radius for virtual loops.

Baseline implementation: [common/s04_transverse_angular_average.wls](s04_transverse_angular_average.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **common/s04_result/s04_result.wl**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S05: Build the real-emission spin tensor

Contract every generated real amplitude and interference pair with the spin insertions, D-dimensional unresolved sums and photon projections. Complete off-diagonal pairs by photon-matrix Hermitian conjugation. Restore scalar products and angular moments; require complete spin reconstruction, Ward/Hermiticity gates and the CDR reference comparison.

Baseline implementation: [common/s05_real_spin_response.wls](s05_real_spin_response.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **channel s05_result with any companion payloads**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S06: Reuse matching scalar integral inputs

Reuse scalar geometry, cut and ordinary loop masters, Kira rules, soft-region expansions and UV inputs only when measure, routing, cuts, continuation and epsilon depth match. New spin numerators can request extra targets; an uncovered target is not zero.

Baseline implementation: [common/s06_reuse_scalar_integrals.wls](s06_reuse_scalar_integrals.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **common s06 results and pinned scalar-library records**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S07: Build the one-loop/Born spin interference

For Hqq, Hqg and Hgq, contract one-loop amplitudes with the Born amplitudes in both conjugate orders. Keep the complete complex photon response and general off-shell angular geometry. Compare original CDR integrand contractions. The real-only channels have no direct virtual sector at this order.

Baseline implementation: [common/s07_virtual_spin_response.wls](s07_virtual_spin_response.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **core-channel s07_result**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S08: Map and reduce real cut integrals

Use the reference reverse-unitarity map with positive-energy support and exact numerator reconstruction. Inventory all targets, reuse covered Kira rules and extend missing ones with original-rule equality and unchanged-master-basis gates. Assemble rational master coefficients exactly. The accepted producer variant is channel-specific.

Baseline implementation: [common/s08_map_real_spin.wls](s08_map_real_spin.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **real target, reduction and mapped-coefficient results**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S09: Map and reduce ordinary virtual integrals

Preserve ordinary propagators and routing; reconstruct the loop map and compare inherited CDR projections. Extend only the actual missing targets, check all old rules, and retain enough master depth. This stage is absent for the real-only channels; Hgg local S09 is instead a real reduction.

Baseline implementation: [common/s09_map_virtual_spin.wls](s09_map_virtual_spin.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **core-channel s09 results and reduction extensions**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S10: Construct collinear spin operators

Derive daughter/parent spin matrices from native splitting amplitudes. Separate ordinary, plus and delta terms. Compare UU and HH distributions with their specified libraries. Parent-first repository kernel names differ from daughter-first P labels. Native dimensional transfer extensions retain the E complement and projector Gram duals.

Baseline implementation: [common/s10_collinear_spin_kernels.wls](s10_collinear_spin_kernels.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **common/s10_result plus dimensional-transfer records**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S11: Convolute PDF and FF subtraction routes

Generate every allowed flavor route. Solve the rescaled Born recoil constraint and Jacobians, retaining the PDF d(eta)/eta and FF d(zeta)/zeta^2 measures. Incoming kernels act on columns and outgoing kernels on rows. Keep dimensional Born/kernel products through the pole prefactor. Use s11_small_collinear_spin for real-only channels and the final dimensional completion where specified below.

Baseline implementation: [common/s11_collinear_spin_convolutions.wls](s11_collinear_spin_convolutions.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **channel s11 result; completed msbar/native variants where required**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S12: Integrate real radiation and endpoints

Multiply exact reduced coefficients by masters at sufficient epsilon depth, restore physical transverse kinematics before the recoil endpoint limit, and extract Delta/L0/L1/Regular tensors. Retain both t=sign*omega-s branches and their common boundary. Factored or regulator-aware variants preserve exact ordinary and endpoint reconstruction.

Baseline implementation: [common/s12_assemble_real_spin.wls](s12_assemble_real_spin.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **channel s12_result; Hgg misc/s11_result**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S13: Integrate and UV-renormalize virtual terms

Insert complex ordinary loop masters and auxiliary-mass UV residues, add the original field/coupling counterterms, and require componentwise UV cancellation and integrated Ward identities. Infrared poles remain until assembly. No direct S13 sector exists for Hgg/Hqqbar/Hqqprime at this order.

Baseline implementation: [common/s13_assemble_virtual_spin.wls](s13_assemble_virtual_spin.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **core-channel s13_result**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S14: Assemble finite BMHV coefficients

Restore state/phase, coupling, color, charge/flavor and spectator factors in matching conventions. Add real, renormalized virtual where present and signed PDF/FF terms. Require every negative epsilon coefficient to vanish in each independent component/distribution/branch; compare both final UU hats with the pinned reference. Axial conversion is still deferred.

Baseline implementation: [common/s14_assemble_finite_spin.wls](s14_assemble_finite_spin.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **channel s14_result; Hgg misc/s14_result**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## S15: Apply finite helicity restoration and export

Use the signed quark helicity scheme kernel and the accepted S11 convolution to add the finite correction on its selected spin leg. Check absent endpoints, unchanged UU and real-only route conditions. Reproject F1/F2 and reject unevaluated regulators, integrals, failures or machine numbers. Preserve complete metadata and exact saved-output identities.

Baseline implementation: [common/s15_finalize_spin_coefficients.wls](s15_finalize_spin_coefficients.wls). The accepted channel adapter may wrap or specialize it; consult the channel table before running. Output contract: **every channel s15_result**. This stage may be shared or channel-specific as its configuration states. Its native `Checks` and execution receipt bind the accepted producer and inputs.

## Interfaces that must remain exact

The real photon response is reconstructed from the complete Hermitian basis. Off-diagonal pair completion uses conjugate transpose; outgoing gluon projectors have their recorded index transpose. Pauli normalization is incoming average/outgoing sum. Unresolved angular moments are valid only after full numerator reconstruction with angle-independent denominators and measurement.

Scalar maps must preserve cuts, positive-energy support, routing, measures and the original master basis. Counterterms use daughter/parent matrix indices; repository kernel keys put parent first. The final gluon-channel subtraction adapters retain dimensional intermediate-state Gram duals and MS regulator-remainder conversion. Axial helicity conversion is a separate S15 operation. The legacy unpolarized comparison is a gate, not a formula for missing polarized entries.

Production sources have accepted exact representations for long rational sums and regulated series. Some adapters read archived source text and require exact hashes and unique replacement boundaries; those archived files are implementation dependencies. Do not delete them as old experiments. Source appendices preserve their literal content; channel receipts identify which variants produced the current accepted outputs.
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
