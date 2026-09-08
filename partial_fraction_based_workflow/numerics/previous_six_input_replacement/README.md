# Six-channel SIDIS numerical calculation

The active input set is Hqq_v2, Hgg, Hqqbar, Hqqprime, Hgq_v4 and Hqg_v3. The user requested replacement of the imported Hgq_v3 F-hats and regeneration of the affected numerical outputs. Upstream channel payloads are preserved. Only `../progress.md` records execution status.

## Stage and convention contracts

S01 freezes the accepted payloads with SHA-256 identities and retains unchanged-channel snapshots from the prior manifest. S02 checks those frozen inputs. S03 recovers their schemas and the v4 consumer contract. S04 supplies the accepted observable maps and Jacobians; S06 supplies MRST2002 NLO and KKP/Kretzer NLO neutral-pion FFs. These channel-independent inputs remain unchanged.

S05 exports the current channel coefficients with exact rational coefficients and original-expression checks. The five unaffected channel exports retain their accepted source snapshots and identities. Hgq_v4 must use its own LO/NLO coefficients, both branches, boundary data and plus-distribution convention. S07 constructs and validates the native high-precision operation tables; S08 derives the flavor and distribution actions. S10 validates coefficient precision at H1 points. S09 applies the experimental cuts, integrates the channel contributions and accepts only bins meeting every numerical precision/stability gate.

The common central scale, uniform-azimuth F1/F2 approximation and H1 observable definitions are those in `s04_result` and `s06_result`. The v3 finite-delta override is no longer an active input convention. Hgq_v4 retains the BigTMD coverage and unresolved MadGraph real-emission comparison documented in `../Hgq_v4/README.md`; reference comparisons do not supply a coefficient correction.

## Preserved prior numerical generation

`previous_Hgq_v3/` contains the accepted prior numerical receipts, source snapshots, coefficient caches, bin means/covariances, integration checkpoints and figures. Its README is the durable ledger for those historical artifacts. `s01_replacement_receipt` records removal of the imported v3 files. The active `Fhats/Hgq_v3` folder is removed; the numerical replacement did not delete upstream channel files. The old Hgq_v3 README was absent during the historical-ledger update; its frozen import-time provenance is retained in the archive.

Unchanged-channel integral reuse requires source/program and input identity checks plus reconstruction of the stored full iteration statistics. A read-only compatibility loader may initialize the `_mlist` field omitted by the installed VEGAS unweighted pickle loader; recovered means/covariances must reproduce the accepted JSON. New Hgq samples use independent seeds. The composition must select channels by their metadata, propagate complete covariance, and pass the same final bin gates. Superseded Hgq estimates must never enter the v4 total.

`dsigmapibydpt/` retains the experimental tables and original paper curves. Its numerical overlays and ratios must be regenerated from the accepted v4 aggregate. Numerical error bars represent integration uncertainty only.

## S11 replacement aggregation contract

S11 combines the accepted per-bin S09 results after the documented full-bin fallback where needed. It verifies the preserved-bin receipt, current build identity, every convergence gate, component sums and covariance-derived errors, and complete experimental bin coverage before recomputing panel/total cross sections. It writes the plot-compatible `s09_result` and source/input-bound `s11_result`; `dsigmapibydpt/s03_plot_comparison.py` then regenerates both figure sets. A full-bin fallback replaces all components of that bin and never mixes discarded partial samples into the result.

## Accepted Hgq_v4 numerical generation

All 17 H1 bins pass the original precision, stability, finite-statistics and channel-sum gates. The five unchanged channel inputs and operation tables passed exact identity checks. Fifteen bins combine their accepted unchanged-channel integrals with independent v4 samples and complete covariance; q0_p3 and q1_p2 use fresh full-channel integrations to meet the same final precision target. Supplied hard coefficients and tolerances are unchanged.

| FF | Integrated cross section (pb) | Integration error (pb) |
| --- | ---: | ---: |
| KKP | 561.689374 | 2.965471 |
| Kretzer | 410.771218 | 2.438471 |

708 Wolfram/native comparisons and 12 H1-point coefficient precision comparisons passed. Numerical errors exclude theoretical scale/PDF/FF uncertainty. The azimuth approximation and v4 comparison caveat remain attached to the output.

- s09_result: SHA256 `872f98c70e9b860387ed72bf61fad3013e986a599c5234ae6d154f5896cb2c17`.
- s11_result: SHA256 `d9d8de8d23d3d1bcbfd49f8d7c77f6e9b16e4cabd23cd52089105c023c0c44e3`, with aggregation source and exact per-bin identities.
- dsigmapibydpt/s03_result: SHA256 `22408cbc8d3cf4e093cc234a6cb356198c54a68981737579a8ff0e11bac5d8b4`, with every plotted value, ratio and output identity.

Both PDF and PNG figure sets are in dsigmapibydpt/ and passed visual inspection. Superseded v3 figures remain in previous_Hgq_v3/.
