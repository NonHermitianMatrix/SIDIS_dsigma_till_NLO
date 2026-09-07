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

## V4 numerical replacement and plot contract

The active calculation replaces only Hgq_v3 with Hgq_v4. The five other channels, MRST02 PDFs, KKP/Kretzer FFs, scales, beam definitions, laboratory cuts and experimental bins retain their accepted definitions. S03 requires a complete current `../s09_result` with all bin precision and stability gates accepted. It plots this calculation's bin averages, H1 total errors and the original paper's NLO curves across all three Q-squared ranges, plus both theory/data ratios.

`s02_extract_published_curves.py` imports the original EPS NLO KKP/Kretzer vertices into `s02_result`, SHA256 `e6a60d2263fe5a728179866c48dcf717a19d732cb1aa34264a6b665024c57e2b`. These remain unchanged reference curves. Paper ratios use log-axis interpolation at bin centres inside the available curve support, without extrapolation; these are curve-to-bin comparisons. This calculation uses bin integrals divided by bin widths. Experimental total errors are not combined with the already-included statistical errors again. Theory errors represent numerical integration only.

The prior v3 numerical figures and their exact historical identities are preserved in `../previous_Hgq_v3/dsigmapibydpt/`. They are not current v4 outputs. The regenerated files retain the stage names `s03_result`, `s03_cross_section.{pdf,png}` and `s03_ratios.{pdf,png}`; the current result receipt must bind their exact hashes and the new numerical input hash.

## Accepted v4 figures

All 17 accepted v4 bins appear in both three-panel figure sets, with both FF choices, H1 total errors and original paper curves. Source s03_plot_comparison.py SHA256 `fc080c16bfb862b543e6c92fdccb483d7d3d45db503e83789eeb3456d426450f`; numerical input SHA256 `872f98c70e9b860387ed72bf61fad3013e986a599c5234ae6d154f5896cb2c17`; figure receipt s03_result SHA256 `22408cbc8d3cf4e093cc234a6cb356198c54a68981737579a8ff0e11bac5d8b4`. Both figures passed visual inspection. Paper-centre interpolation and numerical-error-only conventions remain in force.

- `s03_cross_section.pdf`: SHA256 `c0065614f75d02fd7a8ae5dc73c3214ffd8b3e4a1f97ee20dfdcf743a80905ed`.
- `s03_cross_section.png`: SHA256 `7504da1c80d457e7c85670bd607767ef2e268f365f22cd81553d497a8783d5cc`.
- `s03_ratios.pdf`: SHA256 `9cdfdafd52dc7b304cc21964889c697560402b751c9c087cf2a76ac559954b94`.
- `s03_ratios.png`: SHA256 `0937b317c54637288a078b680c0ea53bc3db8ca393bc361bd077e1a4b0ae8697`.
