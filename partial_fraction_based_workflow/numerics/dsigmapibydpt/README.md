# H1 neutral-pion transverse-momentum comparison

Target: arXiv:1808.04396 Fig. 3, which reproduces Daleo, de Florian and Sassot hep-ph/0411212 Fig. 4. The experimental source is H1 hep-ex/0404009, Table 2/Fig. 4, distributed as HEPData record ins647847 Tables 7, 8 and 9. All live execution state belongs only in `../../progress.md`.

## S01 contract

`s01_import_h1_data.py` consumes the locally downloaded HEPData record and three raw JSON tables in `../references/`. It verifies the record-to-table DOI link, measured observable and units, reaction, Q-squared and y qualifiers, ordered contiguous momentum bins, finite positive measurements, and separately labelled statistical/total errors. It preserves the original decimal strings and writes `s01_result` atomically with source/data hashes. This is experimental input preparation only; no theory value is generated.

## Observable and reference conventions

- The observable is the neutral-pion cross section differential in pion transverse momentum in the virtual-photon–proton center-of-mass system, in pb/GeV. It is not differential in the rescaled photon transverse momentum.
- Q-squared intervals and the inelasticity interval come directly from the table qualifiers. Bin edges differ between Q-squared intervals and must be retained.
- H1 hep-ex/0404009 specifies positron energy 27.6 GeV, proton energy 820 GeV, pion laboratory angle between 5 and 25 degrees from the proton beam, and pion/proton laboratory energy fraction above 0.01. HEPData's SQRT(S)=0.0 field is a placeholder and cannot be used as the collider energy; a subsequent tool must derive the energy invariant from the documented beam momenta.
- The paper's original theory uses MRST02 PDFs and KKP or Kretzer FFs, with the common squared scale defined by Eq. (28) of hep-ph/0411212. That publication's later reference to Eq. (27) for the scale choice is a numbering inconsistency; Eq. (28) contains the scale definition. The user instructed automatic continuation; the numerical run uses the original MRST02 setup with both KKP and Kretzer choices.
- Total uncertainty already includes statistical uncertainty. A consumer must not add the two again.
- A ratio to a binned measured cross section needs the corresponding bin-averaged theory value. A curve sampled at arbitrary bin centers is not an accepted substitute for bin integration. Published paper curves, if extracted from the figure, require separate digitization provenance and cannot supply this calculation's prediction.
- Full overlays and ratios consume the accepted active six-channel numerical result, including Hgq_v4. Its unresolved MadGraph real-emission comparison remains a provenance caveat; no correction is fitted to data or to the paper curves.

## Accepted experimental input identities

- `s01_import_h1_data.py`: SHA-256 `a6354c15fd7e0858d2ddd024df436b009d24b37fbfb1ef9b3df74db14bccd783`.
- `s01_result`: SHA-256 `4f3406d3dc88bb71292cdbc1132f6309cce6442cb4b64509f0d3c218fe84c421`.

The executed importer accepted 17 published bins over the three Q-squared intervals. Every embedded input, unit, positive-data, ordered-bin and uncertainty-label gate passed, and the atomic JSON reload matched exactly. Decimal strings and the distinct source bin edges are preserved. `s01_result` includes hashes and source URLs for the raw HEPData record/tables and records the beam-placeholder exclusion. The raw tables and the three reference publications are retained as calculation inputs and provenance.

## Six-input replacement plot contract

The active source set is Hqq_v4, Hgg_v2, Hqqbar_v2, Hqqprime_v2, Hgq_v4 and Hqg_v3. S03 consumes the current accepted ../s09_result, with all experimental bins passing the original integration gates. It regenerates s03_cross_section.{pdf,png}, s03_ratios.{pdf,png} and the source/input/output-bound s03_result.

MRST02 PDFs, both KKP/Kretzer FFs, scales, cuts, experimental tables and original paper curves retain their accepted definitions. Paper ratios interpolate the original curve on its log axes at bin centres inside its support; this calculation uses bin-integrated averages. Errors on this calculation represent integration uncertainty only.

The superseded figure receipts and plots are retained in ../previous_six_input_replacement/dsigmapibydpt/; earlier artifacts remain in ../previous_Hgq_v3/. They are historical outputs.

## Accepted corrected-Hqg figures

Both three-Q2 figure sets contain all 17 accepted bins from the corrected six-channel numerical generation. Their source ../s09_result has SHA256 1b28305aa93b15129d5157b6e38ad6e82b443a86f69d65ddf534a02010b50592; the plot receipt s03_result has SHA256 4f95f09300c8195c10eec7b96dce177a5a9f2b5cf91c0aa9ce9c71f5f2ef8ad0. All six source payload identities and every plotted input/output hash passed final verification. The data, original paper curves and ratio definitions remain those documented above. Our errors are numerical integration uncertainty only.

| Figure | SHA256 |
| --- | --- |
| s03_cross_section.pdf | 910446ac66ff305a3a83e5c22fbc648b18925565c33856558812802cce4513a0 |
| s03_cross_section.png | d38d4c63cced35d8bc34f1f053710d92f3fe10a15010c46187b94fa3e78e24ea |
| s03_ratios.pdf | 53e5e1ae172a9d6b2def9d554d196a050631c0a06c864fc199fcaa036c133245 |
| s03_ratios.png | 2400604ef5138069764e37bc71199763d18e882008ed16bf1823b892f5c0c2a4 |

The previous figures are preserved in ../previous_Hqg_correction/dsigmapibydpt/. s03_plot_comparison.py remains the direct regeneration entry point. It consumes the current accepted ../s09_result together with the existing s01_result/s02_result experimental and paper inputs.

S03 layout-only correction contract: reserve an explicit rectangle for the subplot layout so x-axis labels and the three-line figure footer are separated. Reuse the same accepted s09_result and paper/data inputs; require every saved panel/ratio value and input hash to match the preceding figure receipt exactly. The preceding source and figures are preserved in s03_previous_layout/.

Final layout acceptance: both regenerated figures were visually inspected, with the ratio PNG inspected at original resolution. All three panels, title, legend, axis labels, data/theory marks and footer are legible. The ratio PDF text also contains the complete labels. The layout-only rerender preserved every plotted value and input identity exactly. Current producer SHA256: 525f67fc0ed2258e6610822539ede462932fb13f5103e1c1047280c66a80a96a.

## Accepted BigTMD reference overlays

Both BigTMD variants are plotted for KKP and Kretzer across all three Q-squared ranges, in the cross-section and theory/data figure sets. The new variant follows every coefficient omission in pinned sidis.py: omit Hqqbar (channel5); retain only regular functions in Hgg and Hqqprime (channels4 and6); retain the called Born/regular/delta/plus terms in the other channels. The exact source-derived charge-case selection is embedded in the reference input and plot receipt. The complete BigTMD variant retains the complete source formulas.

Both variants use the same accepted MRST2002 NLO PDF, FFs, scales, cuts and observable as the own calculation. The reference representation is the documented rational reconstruction of the printed BigTMD coefficients at pinned commit 6e97635d21a63b7975b2e7f5891edc0c35c4dc0c. This reproduces the coefficient omissions only; no other public-driver PDF/FF, auxiliary cut or numerical-approximation choice is imported.

All17 selected-variant bins passed the unchanged integration gates with no refinement. The full-reference curves, own curves, experimental data and original paper values were preserved exactly. Channel covariance is retained within each reference variant; the full and selected reference integrations use independent random seeds. Errors describe numerical integration only.

| Variant | FF | Total over published bins (pb) | Integration error (pb) |
| --- | --- | ---: | ---: |
| BigTMD full | KKP | 581.854064713 | 2.98802310063 |
| BigTMD full | Kretzer | 426.962283803 | 2.4253851281 |
| BigTMD sidis.py selection | KKP | 575.584217785 | 3.06326646309 |
| BigTMD sidis.py selection | Kretzer | 417.549729923 | 2.25029032865 |

Current portable input s04_bigtmd_result SHA256 a0c59eaa3734fe45e75ab0ad6b516fd5a58ebb2bfd5a81eb5f7a99ee8c500b96. Current plot receipt s03_result SHA256 4f95f09300c8195c10eec7b96dce177a5a9f2b5cf91c0aa9ce9c71f5f2ef8ad0. The receipt records requested_bigtmd_variants_complete=true. Plot producer SHA256 525f67fc0ed2258e6610822539ede462932fb13f5103e1c1047280c66a80a96a. Both PDF/PNG sets were visually accepted and every current input/output hash was verified.

The plotting entry point remains s03_plot_comparison.py. The portable reference input is sufficient to regenerate these figures with the other numerics inputs. Reference selection, coefficient export, compilation, integration and assembly are the S05-S09 stages under ../../bigTMD_comparison/numerics/; their source/result identities are documented there and embedded in the imported receipt. The own S09 and S11 results are unchanged.

The preceding complete-only input, source and figures are preserved in s03_before_driver_selection/. Earlier own-only figures remain in s03_before_bigtmd/. These are historical artifacts; the current imported reference contains both requested variants.
