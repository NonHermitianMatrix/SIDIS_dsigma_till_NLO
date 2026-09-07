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
- Full theory overlays and ratios require a valid six-channel numerical result from `../`. The explicit Hgq_v3 finite-delta restriction is recorded in `../s02_result`. The user explicitly overrode that documentary restriction on 2026-09-06; the numerical run uses the supplied components and preserves the caveat in its provenance.

## Accepted experimental input identities

- `s01_import_h1_data.py`: SHA-256 `a6354c15fd7e0858d2ddd024df436b009d24b37fbfb1ef9b3df74db14bccd783`.
- `s01_result`: SHA-256 `4f3406d3dc88bb71292cdbc1132f6309cce6442cb4b64509f0d3c218fe84c421`.

The executed importer accepted 17 published bins over the three Q-squared intervals. Every embedded input, unit, positive-data, ordered-bin and uncertainty-label gate passed, and the atomic JSON reload matched exactly. Decimal strings and the distinct source bin edges are preserved. `s01_result` includes hashes and source URLs for the raw HEPData record/tables and records the beam-placeholder exclusion. The raw tables and the three reference publications are retained as calculation inputs and provenance.

## User-authorized numerical consumer override

On 2026-09-06 the user explicitly instructed ignoring the Hgq exporter warning and proceeding automatically with the complete numerical calculation. This supersedes the earlier documentary stop for this requested run. The supplied mathematical coefficients remain unchanged; no empirical normalization or scheme subtraction is introduced. The former warning and existing comparison discrepancies remain provenance caveats, not numerical run blockers. `numerics/s02_result` (relative to scripts) records the override and separately enforces frozen input integrity. Original Fig. 3 inputs MRST02 NLO with KKP and Kretzer NLO are selected for both requested comparisons.


## Accepted paper curves and final comparison

`s02_extract_published_curves.py` imports the original EPS NLO KKP/Kretzer vertices into `s02_result` (SHA-256 `e6a60d2263fe5a728179866c48dcf717a19d732cb1aa34264a6b665024c57e2b`). These are the reference paper's curves, kept separate from the numerical convolution.

`s03_plot_comparison.py` (SHA-256 `e59af76c21beb1d037caef850c2307e1751a2107f5c693440d156a8046d1879c`) consumes the accepted 17-bin `../s09_result`, HEPData and the original curves. Its `s03_result` (SHA-256 `813c65b2ee17d53757c8020661d33e533e1083e942d090970b7f50ebb5438afd`) contains every plotted bin value, numerical error and theory/data ratio, plus source/output hashes. The final outputs passed visual inspection after footer spacing, minor-tick formatting and ratio-label placement were corrected; numerical inputs and values were unchanged.

- `s03_cross_section.pdf` / `s03_cross_section.png`: all three Q-squared ranges, H1 total errors, this calculation with both FFs, and both published NLO curves.
- `s03_ratios.pdf` / `s03_ratios.png`: this calculation/data and paper/data, with the H1 relative-total-error band.

This calculation uses genuine bin averages from integration. The paper ratios evaluate the digitized log-axis curve at bin centres inside its available support, without extrapolation; they are curve-to-bin comparisons, not bin-integrated paper predictions. The gray experimental band uses the reported total error without adding the statistical error again. Theory error bars show numerical integration error only. The supplied Hgq_v3 caveat and azimuth-independent tensor convention remain attached to the numerical input.
