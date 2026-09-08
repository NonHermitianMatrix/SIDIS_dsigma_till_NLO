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

Both three-Q2 figure sets contain all 17 accepted bins from the corrected six-channel numerical generation. Their source ../s09_result has SHA256 1b28305aa93b15129d5157b6e38ad6e82b443a86f69d65ddf534a02010b50592; the plot receipt s03_result has SHA256 dc07dd2e0fec946540683271cce99bd407aecc6688d2417bde2b6154576e7b3a. All six source payload identities and every plotted input/output hash passed final verification. The data, original paper curves and ratio definitions remain those documented above. Our errors are numerical integration uncertainty only.

| Figure | SHA256 |
| --- | --- |
| s03_cross_section.pdf | 0dcc4978952b206572ca68d2dea7ffea4259263c21c075519e5d75264ea58fe9 |
| s03_cross_section.png | 9cb4a6fa0fd13fff2554465197f33841ca9ad345f1def855318fd36757f2f307 |
| s03_ratios.pdf | 48592ffecea2c490e533ae02665b6dc2317ab7fe60a0049fada208c32e8b2863 |
| s03_ratios.png | 41a60f4b495fd4dc7fc039070553729ae632da34ce068febd96ab4d3c3715612 |

The previous figures are preserved in ../previous_Hqg_correction/dsigmapibydpt/. s03_plot_comparison.py remains the direct regeneration entry point. It consumes the current accepted ../s09_result together with the existing s01_result/s02_result experimental and paper inputs.
