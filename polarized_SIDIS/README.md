# Polarized SIDIS: a reader's guide

This directory contains the completed spin-resolved partonic large-transverse-momentum SIDIS calculation through alpha_s^2 for all six channels. The measurement is the pinned GitHub SIDIS measurement. Numerical proton PDFs, fragmentation functions, hadronic convolutions, jet matching and Collins-asymmetry numerics are deferred.

Read the [physics report (PDF)](polarized_SIDIS_report.pdf) for a start-to-finish explanation of every common stage and every channel, including equations and the general form of the long expressions. Its [LaTeX source](polarized_SIDIS_report.tex) is editable. This README explains the layout; [README_code.md](README_code.md) explains running and reading the workflow and preserves the original technical ledger.

## What each folder owns

| Folder | Meaning and contents |
|---|---|
| [common](common/README.md) | Shared equations, spin bases, contraction/integration/factorization programs, pinned references and their common results. |
| [Hqq](Hqq/README.md) | Incoming quark, tagged same-flavor quark; Born, real and virtual sectors. |
| [Hqg](Hqg/README.md) | Incoming quark, tagged gluon; Born, real and virtual sectors. |
| [Hgq](Hgq/README.md) | Incoming gluon, tagged fixed-flavor quark; Born, real and virtual sectors. |
| [Hgg](Hgg/README.md) | Incoming gluon, tagged gluon; real-only at this order with auxiliary Born subtraction. |
| [Hqqbar](Hqqbar/README.md) | Incoming quark, tagged same-flavor antiquark; real-only with subtraction. |
| [Hqqprime](Hqqprime/README.md) | Incoming quark, tagged distinct-flavor quark; real-only with subtraction. |
| [misc](misc/README.md) | Accepted bounded local Hgg continuation and its exact native storage interfaces; not disposable scratch. |
| [.cluster](.cluster/README.md) | Scheduler submissions, input-bound job configurations, execution/resource guards and receipts. |
| [mathPolycoms](mathPolycoms/README.md) | Dependency interface; installed tools are not vendored here. |
| [numerics](numerics/README.md) | Reserved numerical factorization stage; no completed hadronic numerical prediction. |
| [bigTMD_comparison](bigTMD_comparison/README.md) | Reserved later comparison boundary; not an independent polarized-NLO validation. |
| [documentation](documentation/README.md) | Documentation input/build receipts, source-reconstruction manifest and portable PDF compiler. |

## How the calculation flows

Import open amplitudes → define spin/photon basis → contract Born and real amplitudes → map and reduce scalar integrals → integrate real endpoint distributions. In parallel, the three Born channels form and integrate the virtual interference. Collinear spin operators and auxiliary/core Born tensors supply PDF/FF subtraction. S14 restores normalizations and cancels all poles. S15 applies the finite helicity conversion and exports the final coefficients. [common/README.md](common/README.md) explains each numbered step in detail.

These are physical dependency stages, not a request to execute all historical programs in filename order. Accepted adapters and resumptions are recorded in each channel's stage table. In particular Hgg's local stage numbering is different from the shared numbering. Its final result is exposed through its channel folder, with companion parts kept beside each loader.

## Final outputs for all channels

| Channel | Complete record | Projected hats | Acceptance record |
|---|---|---|---|
| Hqq | [Hqq/s15_result/s15_result.wl](Hqq/s15_result/s15_result.wl) | [F1](Hqq/s15_result/s15_F1_hat.wl), [F2](Hqq/s15_result/s15_F2_hat.wl) | [checks](Hqq/s15_result/s15_checks.json), [receipt](Hqq/s15_result/s15_execution.json) |
| Hqg | [Hqg/s15_result/s15_result.wl](Hqg/s15_result/s15_result.wl) | [F1](Hqg/s15_result/s15_F1_hat.wl), [F2](Hqg/s15_result/s15_F2_hat.wl) | [checks](Hqg/s15_result/s15_checks.json), [receipt](Hqg/s15_result/s15_execution.json) |
| Hgq | [Hgq/s15_result/s15_result.wl](Hgq/s15_result/s15_result.wl) | [F1](Hgq/s15_result/s15_F1_hat.wl), [F2](Hgq/s15_result/s15_F2_hat.wl) | [checks](Hgq/s15_result/s15_checks.json), [receipt](Hgq/s15_result/s15_execution.json) |
| Hgg | [Hgg/s15_result/s15_result.wl](Hgg/s15_result/s15_result.wl) | [F1](Hgg/s15_result/s15_F1_hat.wl), [F2](Hgg/s15_result/s15_F2_hat.wl) | [checks](Hgg/s15_result/s15_checks.json), [receipt](Hgg/s15_result/s15_execution.json) |
| Hqqbar | [Hqqbar/s15_result/s15_result.wl](Hqqbar/s15_result/s15_result.wl) | [F1](Hqqbar/s15_result/s15_F1_hat.wl), [F2](Hqqbar/s15_result/s15_F2_hat.wl) | [checks](Hqqbar/s15_result/s15_checks.json), [receipt](Hqqbar/s15_result/s15_execution.json) |
| Hqqprime | [Hqqprime/s15_result/s15_result.wl](Hqqprime/s15_result/s15_result.wl) | [F1](Hqqprime/s15_result/s15_F1_hat.wl), [F2](Hqqprime/s15_result/s15_F2_hat.wl) | [checks](Hqqprime/s15_result/s15_checks.json), [receipt](Hqqprime/s15_result/s15_execution.json) |

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

## Reconstructing the code from READMEs

Every owned pre-existing README is preserved as `README_code.md`. Imported upstream README files under pinned `reference/` inputs keep their original paths and hashes. The new guides explain the mathematics and stage contracts; the exact source appendices remove ambiguity about implementation.

[common/README_sources.md](common/README_sources.md), the six channel `README_sources.md` files, [misc/README_sources.md](misc/README_sources.md), and [.cluster/README_sources.md](.cluster/README_sources.md) contain lossless source/configuration listings, relative paths, modes, symlink targets and SHA-256 hashes. The reconstruction procedure is in [README_code.md](README_code.md). It recreates the listed code bytes, including retained implementation dependencies. External software, large mathematical input/result data and production caches remain separate dependencies bound by manifests; documentation is not a replacement for those datasets or licenses.
