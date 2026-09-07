# Six-channel SIDIS numerical calculation

**Hqg input correction:** The active frozen Hqg_v3 payload is the corrected accepted S12 result, SHA256 4ed44edf3d2c0274249792e21a8b1c7a9bff0ca9ec7c10f07cb072e54a1e45bd. Its dependent coefficient exports were regenerated. Previous cross sections and figures are historical and are preserved in previous_Hqg_correction/. A corrected prediction requires the regenerated accepted s09_result/s11_result and its source-bound figure receipt. The analytical correction is documented in ../bigTMD_comparison/Hqg_v3/README.md.

The requested active inputs are Hqq_v4, Hgg_v2, Hqqbar_v2, Hqqprime_v2, Hgq_v4 and Hqg_v3. Only ../progress.md records execution status.

## Consumer contracts

S01 imports exact accepted payloads and their convention ledgers; S02 verifies their hashes. S03 extracts each current producer's coupling, flavor, distribution and partonic-variable contracts. S04 supplies the unchanged observable maps and external fragmentation Jacobian. S06 supplies the unchanged MRST2002 NLO PDF and KKP/Kretzer NLO neutral-pion FFs.

S05 exports coefficients from the current payloads, preserving exact rationals and checking direct Wolfram values. S07 compiles and compares every exported F1/F2 coefficient and pair. Unchanged channel exports may be reused only with their original source snapshots and unchanged input identities. Every Hqg_v3 coefficient was regenerated after the angular correction; its resume gate checks the source, current payload and invariant-map hashes.

Hqq_v4 consumes its own OtherChargeMomentDefinitions, FlavorDomain and FlavorRange. S03 must evaluate its defining flavor sums for the active quark species and prove charge-conjugation invariance before grouping equal squared-charge flavors. Hgg_v2 carries chargeSum; Hqqbar_v2 carries eq2; Hqqprime_v2 provides the three stripped charge coefficients and their exact charge_monomials. All are partonic coefficients: the S04 fragmentation Jacobian belongs to the numerical action once. Positive rho uses each current producer's rho_squared. Distributional channels retain their own bounded-plus definitions and exact coordinate-boundary tables.

S08 derives the flavor luminosities from the model charges and current contracts, the uniform-azimuth H1 acceptance and bounded-plus actions. S10 compares native and independent arbitrary-precision coefficients at accepted H1 phase-space points. S09 integrates all six current channels together in every experimental bin and accepts only finite results passing the existing precision, stability and channel-sum gates. The central common scale, cuts and bin definitions remain those in s04_result/s06_result.

## Provenance and limitations

previous_six_input_replacement/ contains the superseded numerical generation, frozen old inputs, source snapshots, coefficients, bin statistics and plots. They are historical artifacts and must not enter the current cross section. previous_Hgq_v3/ retains the earlier generation. s01_replacement_receipt binds the preservation and unchanged input identities. Old bin integrals are not reused for this replacement. previous_Hqg_correction/ contains the generation superseded by the Hqg correction.

The F1/F2 uniform-azimuth approximation and supplied-channel comparison limitations remain in the result provenance. No reference coefficient or fitted correction is used. Numerical uncertainties describe integration only.

dsigmapibydpt/s03_plot_comparison.py must consume the new accepted s09_result for both three-panel figure sets. Its experimental tables and original paper curves remain unchanged.

## Accepted current consumer definitions

S03 result SHA256 489d8a9731562ba6f16774db252d12b5ea2d9314ab142a07fcbb0c73cc6bd9d4 binds the six current schemas. S08 result SHA256 1db2f63fbc29c58f84199e7fd93f6d5a228d7bb155d8600bdc5e2dc5b50b514e passes 18 exact/numerical flavor, acceptance and distribution-action checks. Hqq_v4 defining flavor moments are evaluated for four/five active species; the supplied hats are invariant under incoming-charge conjugation and independent of the odd charge moment. Its two equal-charge groups are measured from the Standard Model particle definitions, with moment arguments supplied by those defining sums. Hgg_v2 and Hqqbar_v2 squared-charge parameters and all three Hqqprime_v2 charge monomials are recovered from the current carriers. All distributional channels use their own normalized recoil/bound logarithm.

## Accepted current coefficient exports

S05 result SHA256 d9d15f64e641b23f497d6ff0998f6af22a3615c8dd8116ef8cff7cb9baba4eaa contains 110 scalar exports. S07 result SHA256 53216cae504b2202fbae58de0606c2c3840d46cdd4c8535a5bd7911af9bd08d1 binds 55 paired programs and 876 passing Wolfram/native comparisons. The five unchanged channels retain their accepted source-bound exports. Hqg_v3 exports its corrected branch coefficients and exact coordinate-boundary table; the current native programs are bound to that corrected payload. All current channels apply the external S04 fragmentation Jacobian once. Current export source snapshots remain in s05_cache, work receipts in its channel subdirectories and compiled tables in s07_cache.

S10 result SHA256 e02db3cfdaecb057429d12b907ef8224e8ba07564865e4ed59cf574677990e20 records 28 passing current-coefficient checks at source-bound H1 phase-space samples, using native arithmetic and independent 100/140-digit evaluation. Its sample source supplies coordinates only; no previous F-hat value or bin integral enters the current prediction.

## Accepted corrected cross sections and figures

All 17 current bins passed the original finite-statistics, precision, independent-iteration, consistency and channel-sum gates. Every bin integrates the six selected channels jointly from the corrected input set. No previous bin estimate enters the new cross section.

| FF | Integrated cross section (pb) | Integration error (pb) |
| --- | ---: | ---: |
| KKP | 586.382026 | 3.620991 |
| Kretzer | 430.129113 | 2.910993 |

These totals sum the published bins. Errors are numerical integration uncertainty only. The established uniform-azimuth F1/F2 treatment, common scale, PDF/FF choices and Hgq_v4 comparison limitation remain in force.

| Current artifact | SHA256 |
| --- | --- |
| s01_result | 3ed06427558fcbb9df4c89029509cbca76d226eb3139190b116221830fd4c40d |
| s02_result | 10943c10bb8a66acbd67188a2d09426d9ef5aac53e200c37ad1e46a94f8d6f46 |
| s03_result | 489d8a9731562ba6f16774db252d12b5ea2d9314ab142a07fcbb0c73cc6bd9d4 |
| s05_result | d9d15f64e641b23f497d6ff0998f6af22a3615c8dd8116ef8cff7cb9baba4eaa |
| s07_result | 53216cae504b2202fbae58de0606c2c3840d46cdd4c8535a5bd7911af9bd08d1 |
| s08_result | 1db2f63fbc29c58f84199e7fd93f6d5a228d7bb155d8600bdc5e2dc5b50b514e |
| s09_result | 1b28305aa93b15129d5157b6e38ad6e82b443a86f69d65ddf534a02010b50592 |
| s10_result | e02db3cfdaecb057429d12b907ef8224e8ba07564865e4ed59cf574677990e20 |
| s11_result | 7991a63c16f3836d11a21f2804a19432be66078d79a2426ac791bb7f2337aea5 |
| dsigmapibydpt/s03_result | ce7fae106d12c4e3ca6347793eb5a1e29c3a5760bb0b3303c25b0bbf8407b152 |

The S11 receipt binds all accepted bin files and the aggregation source. The plot receipt binds all experimental/paper inputs, displayed values and PDF/PNG outputs. The previous generation is preserved under previous_Hqg_correction/.

## Published environment files

requirements.txt records the Python distribution versions installed for this accepted run. The locally installed python_deps/ environment, temporary files and Python bytecode are excluded from Git; calculation inputs, source snapshots, results, figures and provenance archives are retained. Wolfram Engine/FeynCalc/FeynHelpers and the C++/Fortran compilers remain runtime prerequisites used by the stage scripts. No numerical payload or accepted result was changed for publication.

## Corrected-Hqg numerical regeneration contract

Import the corrected Hqg_v3 s12_result.wl and its accepted pole/source bindings; retain the explicitly selected other five channel versions. Preserve the preceding numerical generation in previous_Hqg_correction/. Rebuild Hqg coefficient exports and native tables, then integrate all six current channels jointly in all 17 bins with the existing precision/stability gates. Unchanged coefficient exports are reusable only through the existing payload/source hash checks. Keep accepted PDF/FF, observable maps, data and paper curves. Source-independent invariant definitions and validation coordinates may be retained; old bin estimates cannot enter the new prediction. The existing stages provide all calculation entry points.

## Current terminal-input identities

| Channel | Original terminal payload | SHA256 |
| --- | --- | --- |
| Hqq_v4 | Hqq_v4/s10_result.wl | c91b1d3880071228abc21435fbc72fef326f4d568e33cee68e4c6099eb97a1d7 |
| Hgg_v2 | Hgg_v2/s05_result/Fhats.wl | 85a5cd93f6fda886884f1de799a71081fe96933a5172894613f69e6f0e1c5d58 |
| Hqqbar_v2 | Hqqbar_v2/s05_result/Fhats.wl | ce6cada31c35bb582fc4f309538bf9058781164d489861d0b889ba4ddcf32edd |
| Hqqprime_v2 | Hqqprime_v2/s05_result/Fhats.wl | 4aee27e2d6b9decefce735ecb94536a71f4be0f09352cf5a538fd3b27d504cf6 |
| Hgq_v4 | Hgq_v4/s10_result.wl | 575ea96993eb9a86cfeddb6e10d61c0147e3bf74d35bc25eaf3dbb03fceb9bfe |
| Hqg_v3 | Hqg_v3/s12_result.wl | 4ed44edf3d2c0274249792e21a8b1c7a9bff0ca9ec7c10f07cb072e54a1e45bd |

The in-channel corrected benchmark is ../Hqg_v3/bigTMD_check/, a relative alias of bigTMD/. All canonical coefficients and direct interior benchmark values pass. Archived Hgq_v3 is not an active input; Hgq_v4 is the explicitly selected producer.
