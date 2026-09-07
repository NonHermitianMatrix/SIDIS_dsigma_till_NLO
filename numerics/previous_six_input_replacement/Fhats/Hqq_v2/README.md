# Hqq_v2 symbolic NLO channel ledger

## Scope and authority

This directory contains the retained symbolic pipeline for

`gamma*(q) + q(p) -> q(k1) + X`

through order `alpha_em alpha_s^2`. Its terminal outputs are the finite MS-bar partonic structure functions `F1Hat` and `F2Hat` in `s08_result.wl`.

The physics authority is `../Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`.

Live execution state is recorded only in `../progress.md` with the exact tag `[Hqq_v2, people or agents working on other channels should ignore]`. This README is the durable convention, dependency, and accepted-artifact ledger. File existence alone is not acceptance.

## Fixed conventions

- All algebra and kinematics are exact and symbolic.
- Dimensional regularization is conventional dimensional regularization with `D = 4 - 2 epsilon`.
- UV renormalization is MS-bar, with the paper's `S_epsilon` convention.
- The incoming photon has `q^2 = -Q2`; all QCD external and internal particles are massless.
- The observed fragmenting momentum is `k1`.
- Momentum conservation, scalar products, Jacobians, projector weights, flavor weights, symmetry factors, spin/color averages, and pole coefficients are derived and checked by the tools, not inserted by hand.
- The primitive projections are the paper's Eq. (7) `Pg` and `PPP`; Eqs. (8)--(9) are applied only after factorization yields finite projected actions.
- The Born/virtual family is `Hqq;g`. Real families are `Hqq;gg`, identical-flavor `Hqq;q qbar`, and different-flavor `Hqq;qPrime qbarPrime`.
- FeynArts generates diagrams and amplitudes. FeynCalc performs conversion, state sums, tensor/Dirac/color algebra, Ward gates, and one-loop tensor reduction. FeynHelpers/Package-X evaluates the one-loop masters.
- The one-loop measure follows Eq. (E1). The physical virtual term is the explicit tool-evaluated Hermitian combination after analytic continuation.
- Two- and three-body phase space follow Eqs. (29)--(39) and Appendix A. Angular reduction/evaluation follows Appendices B and D.
- Endpoint terms remain separated into `Delta`, bounded-plus, and `Ordinary` sectors until exact pole cancellation is established.
- Eq. (46) uses positive hard-part counterterms, `alpha_s S_epsilon/(4 Pi epsilon)`, and no extra factorization `mu^epsilon` or `Log[mu]` term.
- Every published stage is hash-bound, written atomically, and accepted only after exact gates and a fresh reload.
- Final finiteness means every independent `epsilon^-2` and `epsilon^-1` distribution-sector residual is literal zero and the hats contain no regulator or unresolved series object. Finite delta/plus distributions and logarithms remain physical parts of the result.

## Retained production chain

| Stage | Retained source(s) | Accepted result |
|---|---|---|
| S01 | `s01_generate_hqq_amplitudes.wl` | `s01_result.wl` |
| S02 | `s02_build_hqq_tensors.wl` | `s02_result.wl` |
| S03 | `s03_renormalize_project_hqq.wl`, `s03_finalize_uv_recovery.wl`, `s03_probe_scaleless_uv_ir.wl`, `s03_correct_hqq_external_lsz.wl` | `s03_result.wl` |
| S04 | `s04_integrate_hqq_phase_space.wl` | `s04_result.wl` |
| S05 | `s05_expand_hqq_endpoints.wl`, `s05_correct_hqq_same_flavor_endpoint_residue.wl`, `s05_validate_hqq_same_flavor_endpoint_correction.wl` | `s05_result.wl` |
| S06 | `s06_evaluate_hqq_virtual.wl`, `s06_add_hqq_external_lsz_from_cache.wl` | `s06_result.wl` |
| S07 | `s07_factorize_hqq_msbar.wl`, retained correction/validation sources, `s07_combine_hqq_from_cache.wl`, `s07_finalize_hqq_from_finite_cache.wl` | `s07_result.wl` |
| S08 | `s08_extract_hqq_fhats.wl` | `s08_result.wl` |

There is no extra runner or diagram-rendering stage. Stage sources are invoked directly. Wolfram work uses verified Engine/Mathematica 15. Parallel kernels are used only for independent S05 coefficient tasks; stateful or intrinsically serial algebra remains serial.

## Accepted primary identities

| Artifact | SHA-256 |
|---|---|
| `s01_generate_hqq_amplitudes.wl` | `5125f6f8a2c2ac7cfa44fc3b8bb437e1f5fdf26c52169d9c4991f5b35ab660d1` |
| `s01_result.wl` | `83a4643632beb6a2c8383ba2634e37b4a5cd033827ba92374f849d0a5b5d9911` |
| `s02_build_hqq_tensors.wl` | `2559c4b388b9fcb746dcf37bebbd33731f6adf7584e749ac632e4db68854fe73` |
| `s02_result.wl` | `316c6e18b49bd7c446506fc866546d0c998f6d61cec3c3813693cbf72b735c83` |
| `s03_result_pre_lsz_superseded_bb9b4c75.wl` | `bb9b4c7571029bf7fd851132b583a3896bea5713543ec1a3774c84b99a03c5b4` |
| `s03_correct_hqq_external_lsz.wl` | `8fb858fdd596a0dc21ffdf03031e0f21d2585d5e976b3bb6ee9c4a003bb8c40d` |
| `s03_result.wl` | `b3d483dea534ed26b93e601c28788b6c5797a200bb04e72c913b1c0c6c69ab80` |
| `s04_integrate_hqq_phase_space.wl` | `ea8a4a56d9aca1e7c7f09ca86b8bafe2fc1633e7533ac8857f792d193e61e793` |
| `s04_result.wl` | `8c6a83d9c92cf36f99b46a81a0b42159375a900915aa13ffed030984e557b68c` |
| `s05_expand_hqq_endpoints.wl` | `cd8e471d24fec0e751463c36f08bdeb72c0a791379d350cbc99e24b541d4fdac` |
| `s05_result_pre_endpoint_correction_e470276a.wl` | `e470276aaf3fe68ec908207f171096142fc5e4bf9d23427d9463df444656ec1f` |
| `s05_correct_hqq_same_flavor_endpoint_residue.wl` | `f59ed00061be52090bddac52b3aa9a08dcdbcf1e7895ce618a49cde831f8be2c` |
| `s05_result.wl` | `bf51eec22fb34160531263757c8b0195497780e34e4bdd18ed6f3c4292ea9ddb` |
| `s06_evaluate_hqq_virtual.wl` | `4b78bd25d05d52913ad668973fc6c404b1b883e6b94e6ede0562ac98d892e8d3` |
| `s06_result_pre_lsz_superseded_b8e8b105.wl` | `b8e8b105bf62f2148d56d419a2563c8970dcf7c8b1b8e097f6ad55e0f1dddb9e` |
| `s06_add_hqq_external_lsz_from_cache.wl` | `bca55a4735f54453071f47e920348de5fdf1cb541e990a1e6a9126bae9054216` |
| `s06_result.wl` | `a27caf9b820b3685f59119a3a814a035233f50ba64013f2d47308fcf00cb5979` |
| `s07_factorize_hqq_msbar.wl` | `db2012e21e8abe0fe4c007f3811ed57fd4cd5f2635301fb107a0aa0bf45a7c00` |
| `s07_factorization_laurent_cache_corrected.wl` | `4b5538d1b8bf89c7ff94b45ad79458f9d8c3a6c42f6b6aa637b0529bc7ffcdef` |
| `s07_combine_hqq_from_cache.wl` | `2871fb493112d7d030e7a10cdc4aa3071ee9ded1db785405d8ad2d434f2641f9` |
| `s07_finite_projected_actions_cache.wl` | `8118047f56686a4032efcc00944508b09cd230b43379f236951a4b732e0b4a96` |
| `s07_finalize_hqq_from_finite_cache.wl` | `3c75f4315e4f6727a43442657d14926b2ef89891babf996e87a92f1a57d33c07` |
| `s07_result.wl` | `a858aab618a044d223b1caf5897579db68a692f596fd0b1eafb2d692054b88e4` |
| `s08_extract_hqq_fhats.wl` | `f426373c24143950cb8cdb09a6410e7ec76e0d4f960293f6380021cf54c211b7` |
| `s08_result.wl` | `0b69a0db7740127ab16c53d181317b7defbd17af846e55582213ca28d1d35741` |

Wolfram-produced terminal expression hashes:

- `F1Hat`: `24010c0ba80c1da601d39fcad6684a986024773cd84beafcbc09e956d6da4823`
- `F2Hat`: `54aa977540c56796b7c5b03aead322022788455caa110b9fe285373fec139b36`

## Required checkpoints and dependencies

### S03

- `s03_pre_uv_checkpoint.wl` (`20e642e5...16a5`) and `s03_failed_uv_cancellation_local.log` (`e080747e...437c`) plus `s03_uv_recovery_local.log` (`5bb9f642...2132c`) remain because the accepted S03 finalizer reads and hash-checks them.
- `s03_scaleless_uv_ir_probe_result.wl` (`83bda791...6293`) and its source remain inputs to the external-LSZ correction.
- The explicit pre-LSZ snapshot remains because S04 and the original S06 path bind it, while current `s03_result.wl` includes the accepted LSZ correction.

### S05

- `s05_master_cache.wl`: `8d968dbc9583c41736aec709b9d09e62eba9be52cc1a31475cc70c3910b4b839`.
- `s05_root_group_cache.wl`: `e9c4c488cc1fccb76b9dd3bba81204880bb4a215e038f199a5e239749f05f3fc`.
- `s05_root_group_cache_v2.wl`: `261a3634646d151724fcc98a434d908cd4b350248db2d9bac251b316da5bf585`.
- `s05_coefficient_cache/` retains 40 accepted records under producer `68f905e9...0178a` and 152 under `9a0ed022...c712`.
- `s05_endpoint_cache/pg_same_epsilon_1/` retains 53 local accepted direct-endpoint records.
- The sorted relative-path hash manifest of those 245 retained records is `ce5d99ea6d8515fbeb262c958d7af3bf75cfcf2a895ac15dd9b3051d21f0ccfb`.
- The pinned backend is `vendor/SubTropicaHyperIntica/HyperIntica.wl`, SHA-256 `252acac91a7cb87c7334f2c7227a4c7aeea7bfc2c3b53c58f9fb28a4a6b284d5`, official commit `adfd3af3be234cb43a2322bd9ec442caa26edd74`; its license remains.

### S06

- `s06_master_cache.wl`: `194798bbeae02f03192e57dfc5f14fc61bf40579e20049608de78c76909fe54c`.
- `s06_branch_cache.wl`: `ff1e712bbfd19b267fdc7829e9ff14efd90d91b1d58d282796ce2dead12e8456`.
- The pre-LSZ result remains the immutable input to `s06_add_hqq_external_lsz_from_cache.wl`.
- `s06_packagex_pave_normalization_route_validation_result.wl` (`155f2f71...a339`) is a frozen downstream input to the S07 finalizer. Its historical comparison source is omitted because several comparison-only candidates were already absent before terminal cleanup.

### S07 corrections and final checkpoint

The accepted combiner hash-checks the compact correction sources/results below, or they generate its corrected factorization cache:

- Same-flavor delta: `s07_diagnose_delta_common_basis.wl`, `s07_delta_common_basis_result.wl`, `s07_diagnose_same_flavor_pole_origin.wl`, `s07_same_flavor_pole_origin_result.wl`, and `s07_combination_diagnostic_pre_s05_endpoint_correction_d68a942f.wl`.
- Bounded plus: `s07_diagnose_bounded_plus_endpoint_coefficient.wl`, `s07_bounded_plus_endpoint_diagnostic_result.wl`, and `s07_combination_diagnostic_pre_bounded_plus_endpoint_correction_8aac6488.wl`.
- Ordinary: `s07_diagnose_ordinary_endpoint_subtraction_map.wl`, `s07_ordinary_endpoint_subtraction_diagnostic_result.wl`, and `s07_combination_diagnostic_pre_ordinary_endpoint_and_ppp_factorization_correction_e3238bb7.wl`.
- Initial-state `PPP`: `s07_diagnose_ordinary_ppp_log_basis.wl`, `s07_ordinary_ppp_raw_residual_cache.wl`, `s07_analyze_ordinary_ppp_rational_residual.wl`, `s07_ordinary_ppp_rational_factor_result.wl`, `s07_diagnose_initial_ppp_projector_rescaling.wl`, `s07_initial_ppp_projector_rescaling_diagnostic_result.wl`, `s07_correct_initial_ppp_factorization_cache.wl`, `s07_factorization_laurent_cache_corrected.wl`, `s07_validate_corrected_factorization_cache.wl`, and `s07_factorization_laurent_cache_corrected_validation_result.wl`.
- Base factorization cache `s07_factorization_laurent_cache.wl`: `4c8f93cbe9a6a35051f5b607f82ea87644473beaeca28c39940f3d17b6b97c48`.
- Corrected-cache validation result: `5d7903c932e20e25ff9cc1771ccbd1087d44be49ffd2f06643356d768681adbf`.
- Final finite checkpoint `s07_finite_projected_actions_cache.wl`: `8118047f56686a4032efcc00944508b09cd230b43379f236951a4b732e0b4a96`. It contains all twelve literal-zero pole residuals and all six finite `Pg`/`PPP` sector actions. It is the sole algebra-heavy resume input for the accepted S07 finalizer.

The versioned `s07_combination_diagnostic_pre_*.wl` files are retained inputs from sequential failed-gate diagnosis. Their generators used the temporary canonical path `s07_combination_diagnostic_result.wl`; that active temporary path must remain absent during accepted production.

## Terminal validation

- S07 fresh validation accepted all twelve exact pole zeros and `s07_result.wl`.
- S08 production passed all nine paper/input, projector-derivation, finite-weight, schema, scheme-profile, and exactness gates.
- Independent S08 validation passed all ten gates, including exact and regulator-free hats.
- `s08_result.wl` contains top-level `F1Hat` and `F2Hat` associations with `Delta`, `BoundedPlus`, and `Ordinary` sectors.
- The downstream `bigTMD_check/` pipeline completed against pinned BigTMD
  channel 2 at commit `6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`.
  Its tool-generated comparison contains 24 finite, unique rows and reports
  `0/24` within tolerance; the signed-difference report is
  `bigTMD_check/bigtmd_minus_local.md`.  This mismatch does not modify or
  invalidate the accepted S08 artifact by itself.
- The downstream `madgraph_check/` pipeline generated the exact `ugg`,
  `uuu~`, and `udd~` photon-only processes with MG5_aMC 3.7.0 and compared
  their generated squared matrix elements with the accepted unintegrated S02
  real tensors.  All three families pass; the maximum relative difference is
  `5.716947383231899e-16`.  This validates the tree-real amplitude/tensor
  layer, not the later integration, endpoint, virtual, or MS-bar stages.

## Terminal cleanup policy

As requested on 2026-09-04, this directory retains only accepted generation/correction sources, accepted results, immutable snapshots consumed by corrections, production/resume caches used by those sources, compact correction inputs, the final S07 checkpoint, the final S07/S08 results, the two requested downstream check pipelines, this README, and the pinned backend/license.

Rejected source experiments, failed/parse/probe/monitor logs, invalid candidates, unused diagnostics, scheduler-control links, the general `logs/` directory, and unused vendor repository metadata were moved to desktop trash. They are currently recoverable from trash but no longer exist in this directory. Outside the self-contained downstream check directories, the only retained logs are the two S03 text artifacts parsed by the accepted S03 finalizer; historical identities and outcomes remain in `../progress.md`.  Each check directory retains only the production/build logs that provide execution evidence for its accepted outputs.

The current inventory is 68 top-level entries and 442 files total, occupying approximately 709 MiB. The requested check directories contain 12 BigTMD-check files and 121 MadGraph-check files. All 25 primary identities listed above passed SHA-256 comparison after cleanup; the 245-file S05 cache manifest, final S07 checkpoint, and terminal S08 result also retained their accepted hashes.
