# Six-channel SIDIS numerical calculation

This pipeline consumes the existing Hqq_v2, Hgg, Hqqbar, Hqqprime, Hgq_v3 and Hqg_v3 partonic F-hat artifacts. Inputs are frozen under `Fhats/` with source paths and SHA-256 identities. Stage scripts use sequential `sNN_` names and each writes an `sNN_result` artifact. Only `../progress.md` records live work and execution state.

## Stage contracts

- S01 imports the exact terminal channel artifacts without mathematical modification, records source/copy hash equality and source convention ledgers, and does not claim numerical or physics validation from copying alone.
- Subsequent stages must recover each stored perturbative order, charge/flavor decomposition, scale convention and distribution action; derive the observable maps and Jacobians inside the calculation tool; supply the required Born contributions for a complete NLO prediction; and gate endpoint integration and normalization before PDF/FF convolution.
- The channel convolutions must use one explicitly specified common PDF/FF and coupling prescription and count every physical incoming/fragmenting flavor once.
- `dsigmapibydpt/` holds the H1 neutral-pion comparison requested for arXiv:1808.04396 Fig. 3, including experimental cuts and three Q-squared intervals, original-paper NLO curves, and theory/data ratios. An imported or digitized reference curve is never substituted for this calculation.

## Physics authority and consumer boundary

The calculation authority is `../Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`; the requested observable reference is https://arxiv.org/pdf/1808.04396 and its cited source hep-ph/0411212. Every derived numerical or symbolic physics value must be produced by executed tools. Missing conventions, unchecked endpoint actions, or missing perturbative orders prevent dependent numerical production. Existing benchmark mismatches remain explicit comparison caveats and are not corrected empirically.

## Imported artifact and consumer identities

- `s01_import_fhats.py`: SHA-256 `f1251a9f9cc7b7f1aa2cf37587e9a085c61f52388cb7663bdc5b3b5ef7a3a1fb`.
- `s01_result`: SHA-256 `6007cbbc1634537663e8d309d94d16513ff4e81b0fdf4ceda094fd69e2ed49ed`.
- `s02_check_input_readiness.py`: SHA-256 `17a607845ab4d4bd75606533ed3b93851778f1f11c3720552ccebe2d02b952f4`.
- `s02_result`: SHA-256 `0f5027016950c8266169b09994cca43c96edfb64e0e908b7943958237a44c946`.

S01 imported all six requested channels, including every Hqqprime S13 cache and all eight Hgq_v3 F-hat components. `s01_result` lists the exact source/copy identities and 19 terminal payload files. Copies of the terminal producer and channel README are import-time provenance snapshots. The original mathematical payloads were not modified. Source README updates after import do not rewrite the frozen snapshot.

S02 verified the 31 frozen files and records the explicit source restriction `HGQ_FINITE_DELTA_PRODUCTION_PROHIBITED`. The frozen Hgq producer at `Fhats/Hgq_v3/s09_extract_fhats.wls` lines 6-7 identifies a remaining finite-delta scheme residue and prohibits using it for a final number. This requires a corrected/accepted upstream artifact or an explicitly resolved originating convention before a six-channel numerical consumer. It is not a new symbolic recalculation or a proof deciding the BigTMD discrepancies. No numerical cross section, convolution kernel, paper-theory digitization, or final comparison plot is supplied by S01/S02.

## User-authorized numerical consumer override

On 2026-09-06 the user explicitly instructed ignoring the Hgq exporter warning and proceeding automatically with the complete numerical calculation. This supersedes the earlier documentary stop for this requested run. The supplied mathematical coefficients remain unchanged; no empirical normalization or scheme subtraction is introduced. The former warning and existing comparison discrepancies remain provenance caveats, not numerical run blockers. `numerics/s02_result` (relative to scripts) records the override and separately enforces frozen input integrity. Original Fig. 3 inputs MRST02 NLO with KKP and Kretzer NLO are selected for both requested comparisons.

## S03 terminal-schema contract

S03 loads one frozen channel payload at a time with FeynCalc initialized, records nested key shapes, expression symbols, scalar heads, distribution/test-function heads and exact input hashes, and writes s03_result plus channel JSON inspection checkpoints. It performs no convolution or coefficient alteration. These large serial loads do not benefit from duplicated parallel kernels; independent production coefficient tasks can use up to eight configured kernels if memory permits.

## S04 and S05 numerical-consumer contracts

S04 derives the massless laboratory pion/photon momenta, partonic invariants, fragmentation-variable transformation, physical integration bounds and cross-section Jacobians using SymPy and gates the defining identities. Its azimuthal treatment follows the supplied azimuth-independent F1/F2 tensor. S05 consumes frozen hats and each channel’s own Born payload, preserves distribution and flavor structure, and must compare native evaluation with direct symbolic evaluation before a production convolution. The initial inspection mode records special-function heads and extracts the accepted Hqq S03 Born payload; it does not constitute a numerical kernel.

## Accepted native inputs and S09 consumer contract

S04's executed result contains the invariant, physical-bound, projector and Jacobian checks. S05 exports all six channels to `s05_cache/<channel>_result` and per-function JSON, with archived producer identities. S06 supplies the original MRST2002 NLO, KKP and Kretzer Fortran implementations, with their input grids, checks and library hashes in `s06_result`. The current S07 receipt supplies scalar and paired F1/F2 operation tables and `s07_cache/s07_evaluator.so`; all 624 saved comparisons against direct Wolfram values passed after exact-arithmetic recovery. It preserves principal complex branches and checks formal singular-log cancellation at each point. Only the real projections enter this observable. S08 records generated flavor actions, neutral-pion interference cancellation, azimuthal acceptance and bounded-plus polynomial checks.

S09 must bind those accepted identities, derive its PDF and integration-coordinate transformations in tools, apply each channel's saved Jacobian flag exactly once, and integrate the complete LO plus NLO correction in the published H1 bins. The two Hqq charge groups retain their channel-specific multiplicities; Hqqprime uses ordered distinct-species sums. The mixed Hqqprime term vanishes only through the S08 neutral-pion identity and a numerical FF charge-conjugation check. All numerical failures must be surfaced, not replaced by zero. The reported error is a numerical integration error; scale/PDF/FF uncertainty is not supplied by this central-scale calculation. The original Hgq_v3 caveat and the azimuth-independent tensor approximation remain attached to the output.

### Expanded precision-validation boundary

The initial 240 S07 comparisons passed at their specified benchmark points. S10 subsequently found severe loss of native accuracy at H1 points selected by the S09 pilot grids, notably Hqq_v2 Delta and Hgq_v3 Delta/Regular/L0. The initial native library is therefore not accepted for production over the full H1 domain. `s10_cache/s10_pilot_precision_result` retains direct native versus 50/90-digit operation-table comparisons. The failed pilot estimates are versioned with `_invalid_precision`; their sampling grids remain useful only for reproducing the precision failure. Consumers must require the expanded precision gates after correction before accepting final numerical results.

The executed `s10_cache/s10_consumer_contract_result` supersedes the older Hqq_v2 benchmark ledger Jacobian claim. S05 marks all Hqq_v2 components as requiring the external S04 fragmentation Jacobian. Hgg, Hqqbar and Hqqprime retain their explicit mapped Jacobians; Hgq_v3 and Hqg_v3 also require the external Jacobian. The supplied mathematical hats are unchanged.

### Exact arithmetic and expanded consumer checks

The first CForm export rounded some exact atomic rational coefficients to machine decimals. That export and its dependent native/pilot results were invalidated and versioned before regeneration. S05 now exports rational numerator/denominator operations, compares prepared expressions against the original frozen expressions with precision-gated Wolfram arithmetic, and records each producer snapshot. Regular terms retain exact uncollected expressions when global rational cancellation is too costly. S10 derives the inverse kinematic map from the S04 definitions and gates reconstruction; S07 enforces those identities inside its arithmetic backend.

The replacement S07 backend uses Boost complex arithmetic at 100 decimal digits and mpmath dilogarithms at 115 digits, retaining the measured Package-X branch convention. Signed zeros are normalized on complex branch cuts. S07 must match both real and imaginary scalar Wolfram benchmarks, including the H1 stress points. Reuse of intermediate values is controlled by exact operation-graph input dependencies and disabled when a formal singular logarithm is present. S09 installs the same callback and consumes only an accepted S07 receipt. S10 supplies an independent operation-table interpreter for precision cross-checking.

### Accepted exact-export and arithmetic artifacts

`s05_result` binds all six per-channel export receipts and their source snapshots. The Hgq_v3 receipt combines both F1 branches from the main exporter with isolated F2 branch exports; `s05_cache/s05_parallel_export_contract` proves that the isolated scripts change only root/output paths and iteration selection. Their mathematical calculation bodies are unchanged. All selected components passed exact rational-coefficient reconstruction where collected and direct original-expression checks at the stored physical points. Born-channel plus coefficients were also checked at interior recoil points.

`s05_cache/s05_json_serialization_result` records the repair of Wolfram's nonstandard approximate-zero JSON spelling. Original byte snapshots, decimal-value equality and unchanged quoted-expression checks are retained. The canonical exporter now emits machine-precision reference fields for the consumer ABI; coefficient expressions remain exact and the calculation/validation arithmetic remains at high precision.

The final native backend uses real arithmetic when a complex value has zero imaginary part, retaining 100 decimal digits, and applies principal signed-zero normalization at branch-sensitive operations. Input-dependency masks permit exact reuse between flavor-weight evaluations. The final `s07_result` and full `s10_result` both passed their gates. S09 requires their hashes before building or integrating and loads the coefficient tables once per process. S09's bin integrals must additionally pass its precision, independent-iteration and channel-sum checks before the comparison plots are accepted.


## Accepted H1 integration and comparison artifacts

The executed central-scale LO-plus-NLO calculation is saved in `s09_result` (SHA-256 `eb4d06f678d9416f30588e76aaaadd363cbb2865b06d7d1f3c9da318060699d4`), produced by `s09_convolve_channels.py` (SHA-256 `86922f5701629c5cef22263a10a21d89552a5bb5e470025f08addbc663b19dba`). All 17 measured bins passed finite-statistics, requested-precision, independent-iteration-group, iteration-consistency and channel-sum checks. Each bin stores the signed LO and NLO-correction contribution of every channel, its full covariance, both FF choices, and its convergence history. Array labels are supplied by the same result's channel/order/FF metadata. The total below is integrated over the plotted H1 bins and their recorded experimental cuts.

| FF | Integrated cross section (pb) | Numerical integration error (pb) |
| --- | ---: | ---: |
| KKP | 826.09 | 4.25 |
| Kretzer | 717.08 | 3.98 |

The errors are Monte Carlo integration errors only. This calculation uses the original MRST2002 NLO PDF, KKP/Kretzer NLO neutral-pion FFs and the common scale defined in S04/S06. The supplied Hgq_v3 residue and azimuth-independent F1/F2 approximation remain as documented above. No empirical matching to the experiment or paper curve was applied.

The final bin was evaluated on freed capacity by invoking the unchanged `integrate_bin` function with identical source, build, seed and integration settings in an isolated output directory. `s09_cache/s09_early_q2_p4/s09_isolation_contract`, `s09_cache/s09_writer_shutdown_result` and `s09_cache/s09_final_bin_handoff_result` record the output routing, verified shutdown of the slower duplicate and byte-identical promotion after all writers stopped. Accepted results were not invalidated by this scheduling handoff. The isolated production output and saved integration map retain provenance value.

The accepted figure/data receipt is `dsigmapibydpt/s03_result` (SHA-256 `813c65b2ee17d53757c8020661d33e533e1083e942d090970b7f50ebb5438afd`). It binds the experiment, original EPS paper curves, executed numerical result and final PDF/PNG files. Cross-section overlays are `dsigmapibydpt/s03_cross_section.pdf` and `.png`; theory/data comparisons are `dsigmapibydpt/s03_ratios.pdf` and `.png`. This calculation is bin averaged; paper ratios use original-curve interpolation at the measured bin centres within the curve support. Those paper ratios are explicitly labelled curve-to-bin comparisons.

With the accepted coefficient/input artifacts present, these commands reassemble saved accepted bins and regenerate the requested figures:

```bash
python scripts/numerics/s09_convolve_channels.py --mode integrate --workers 8 --neval 1000 --nitn 8 --refinements 3
python scripts/numerics/dsigmapibydpt/s03_plot_comparison.py
```

Re-running S01 is unnecessary for reproduction of this accepted result and would refresh import-time provenance; retain the frozen input identities for this calculation.
