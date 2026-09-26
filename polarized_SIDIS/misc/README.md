# Local accepted continuation and native storage

This folder contains the accepted bounded local Hgg continuation, its result owners and the supporting exact storage/interface checks. Its earlier description as only disposable checks is superseded by the accepted final calculation. Preserve [README_code.md](README_code.md) for the original technical record and [README_sources.md](README_sources.md) for exact code bytes. [Hgg/README.md](../Hgg/README.md) explains the physics and aliases.

## Production sequence and mathematical purpose

| Local stage | Meaning | Result consumed downstream |
|---|---|---|
| s06_map_Hgg_local | Map actual real tensors to the original cut families with exact reconstruction. | Per-component real-map records. |
| s07_merge_Hgg_coefficients | Combine exact mapped coefficients while preserving their input identity. | Complete coefficient map. |
| s08_collect_Hgg_targets | Inventory every cut-integral target needed by that map. | Target set for Kira. |
| s09_reduce_Hgg_targets | Reduce those real targets with inherited families and rules; this is not a virtual stage. | Accepted complete reduction. |
| s10_reduce_Hgg_coefficients | Apply the reduction and assemble exact master coefficients. | Coefficients used by local S11. |
| s11_assemble_Hgg_real | Insert regulated cut masters and endpoint terms at sufficient depth. | [s11_result](s11_result/), aliased as Hgg/s11_local_real_result. |
| s14_assemble_Hgg_finite | Combine integrated real and Hgg native subtraction, restore normalization, cancel poles, compare UU hats. | [s14_result](s14_result/), aliased as Hgg/s14_local_finite_result. |
| s15_finalize_Hgg_hats | Apply the accepted scheme/export logic and save the full response and hats. | [s15_result](s15_result/), aliased as Hgg/s15_result. |

The entry points and their `sNN_inputs.json` bind their full shared implementations, native interface proofs, actual input pieces and configuration. Local execution uses the verified Wolfram Engine 15.0 executable, the configured FeynCalc installation and `POLARIZED_SIDIS_LOCAL_AUTHORIZED=1`. This adapter preserves imported cluster provenance and records the local native versions; it does not assert that cluster and local kernels are identical.

## Why the other files exist

The S12 and later numbered comparison/interface files in this folder are accepted or archived targeted studies used to establish exact algebraic or storage equivalence. They are not additional perturbative orders. Their names, header descriptions and literal implementations are indexed in README_sources.md. Current input manifests identify which proofs remain required; do not delete a proof or an archived implementation that a production adapter hashes or reads.

`s40_chunked_native_record.wls` writes and reads exact native pieces with per-piece identities and complete reconstruction. Its comparisons use ordered keys and exact native values, not numeric tolerances. Final Hgg loaders require all sibling part directories. Memory-bound mathematical checkpoints and accepted production proofs remain reusable; only isolated disposable tests with no resume/provenance value should be removed.

The completed local S14 and S15 receipts report approximately 1944.9 s / 8.32 GiB and 1959.1 s / 5.86 GiB peak process-tree RSS, respectively. Those are recorded runs, not a guarantee for a fresh input or machine. Keep at least the current 4 GiB available-RAM and 8 GiB disk reserves for any future authorized local work. Monitor the entire process tree and stop before exhausting either resource. No physics rerun is needed merely to read this documentation.

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
