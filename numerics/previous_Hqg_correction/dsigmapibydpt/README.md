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

## Accepted six-input figures

The current 17 accepted bins appear in both three-panel figure sets. All data, theory and ratio values are recorded in s03_result, SHA256 f82e5fd31e63c1b2c5c5a110e9a872b20324c8e64e49202a9f52ba66e4b6cc6e. Its numerical input is ../s09_result, SHA256 66c0df6a0a8001e4603d939602bb8c7aa378fe77c916437f1b9115b8363b36ad. Every recorded input/output hash passed final verification. Both PNGs were visually inspected: all three Q-squared panels, legends, units, curves, bin averages, errors and ratio conventions are legible. The source and original paper/data inputs are unchanged.

- s03_cross_section.pdf: SHA256 db692d4c90d1cdbd5677a75488203bd01f56cc3a6730134358f9d051b2a2f79f.
- s03_cross_section.png: SHA256 184c2b53612d33b637f93b07fd2dd7796b31360647e6b01656a2ad29996a92af.
- s03_ratios.pdf: SHA256 0142b94d4ed3f1d597b5a8b5300667ff08c63f5453e2bfa46c205b61bbf7c65c.
- s03_ratios.png: SHA256 89f74f8f2fc86cd32e8500baa7ae4d115ddf33eae6b18571fb7d29d9c4f6d0dd.
