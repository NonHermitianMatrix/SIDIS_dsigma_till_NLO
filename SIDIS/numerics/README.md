# SIDIS numerical predictions and plots

The six SIDIS F hats were convolved again with the same numerical setup as [the existing numerics workflow](../../numerics/README.md). All 17 H1 bins and both fragmentation-function choices passed the numerical gates. The main code, results, logs and production/validation caches are local in this folder; calculations ran on Hoffman2.

## Final files

| Output | Files |
|---|---|
| Cross sections, three Q2 intervals | [PDF](dsigmapibydpt/s03_cross_section.pdf), [PNG](dsigmapibydpt/s03_cross_section.png) |
| Theory/H1 ratios, three Q2 intervals | [PDF](dsigmapibydpt/s03_ratios.pdf), [PNG](dsigmapibydpt/s03_ratios.png) |
| Bin predictions, signed channel components and covariance | [s09_result](s09_result) |
| Final aggregation and input checks | [s11_result](s11_result) |
| Plotted values and input/output identities | [Plot receipt](dsigmapibydpt/s03_result) |

“This calculation” in the figures means the newly integrated SIDIS hats. H1 data, published paper curves and the existing complete BigTMD overlay are preserved. No previous own bin estimate enters the new prediction.

The tool-produced integrated totals are:

| FF | Cross section (pb) | Integration error (pb) |
|---|---:|---:|
| KKP | 584.273239 | 3.130143 |
| Kretzer | 429.553078 | 2.688716 |

Errors here are numerical integration errors only.

## Physics and bookkeeping

The inputs are the accepted final hats in [Hqq](../Hqq/README.md), [Hqg](../Hqg/README.md), [Hgq](../Hgq/README.md), [Hgg](../Hgg/README.md), [Hqqbar](../Hqqbar/README.md) and [Hqqprime](../Hqqprime/README.md). S01 freezes the payloads, their executed producer and source-bound pole evidence. S03 derives the coupling/charge degrees, flavor moments, bounded-plus definition and branch-boundary contract from those payloads. S05 reads their `Fhats` fields directly, including the saved branch-zero terms and S03-derived Hqqprime charge components.

The numerical definition is inherited unchanged: MRST2002 NLO PDFs, KKP NLO neutral-pion FFs and Kretzer NLO neutral-pion isospin average; the same H1 data/bins, massless kinematics, beam energies, laboratory cuts and common scale. [S04](s04_result) contains the exact generated maps and scale definition. [S06](s06_result) binds the original Fortran grids/routines, coupling calibration and physical constants. [S08](s08_result) contains the generated flavor sums, acceptance and distribution actions. The external fragmentation Jacobian is applied once.

The original uniform-azimuth F1/F2 approximation and inherited Hgq MadGraph sign-comparison limitation remain. See the [SIDIS coefficient comparison](../bigTMD_comparison/README.md) for the reference conventions. Paper curves are sampled at bin centres for their ratios; our and BigTMD predictions use bin averages.

S05 initializes no FeynHelpers or Package-X. Its exact-rational exports come from the SIDIS reverse-unitarity/Kira/SubTropica results. The native format retains an unused legacy `pax` field; the exporter measures and checks the absence of that operation. S10 reuses only old validation coordinates, with fresh evaluations of the new coefficient tables. The plot consumer checks the actual shared physical inputs while retaining each prediction's separate coefficient provenance.

## Stages and run order

Use the cluster runtime described below and run the existing programs directly from this folder. The numbered programs retain the original workflow's names; S10 has a separate inverse-map mode needed before S05.

| Order | Program or mode | Output |
|---:|---|---|
| 1 | [s01_import_fhats.py](s01_import_fhats.py) | `s01_result`, `Fhats/` |
| 2 | [s02_check_input_readiness.py](s02_check_input_readiness.py) | `s02_result` |
| 3 | [s03_inspect_fhat_schemas.wl](s03_inspect_fhat_schemas.wl) | `s03_result`, `s03_cache/` |
| 4 | [s04_derive_convolution_maps.py](s04_derive_convolution_maps.py) | `s04_result` |
| 5 | [s06_prepare_pdf_ff.py](s06_prepare_pdf_ff.py) | `s06_result`, `s06_cache/` |
| 6 | [s08_derive_consumer_actions.py](s08_derive_consumer_actions.py) | `s08_result` |
| 7 | [s10_validate_precision.py](s10_validate_precision.py) `--invariant-contract` | `s10_cache/s10_invariant_contract_result` |
| 8 | [s05_prepare_hard_functions.wl](s05_prepare_hard_functions.wl), once per channel | `s05_cache/<channel>_result` and exact operation exports |
| 9 | [s07_compile_hard_functions.py](s07_compile_hard_functions.py) | `s05_result`, `s07_result`, `s07_cache/` |
| 10 | `s10_validate_precision.py --sample-source references/s01_validation_coordinates.json` | `s10_result`, `s10_cache/` |
| 11 | [s09_convolve_channels.py](s09_convolve_channels.py) `--mode build`, then `--mode smoke` | `s09_cache/s09_build_result`, `s09_cache/s09_smoke_result` |
| 12 | `s09_convolve_channels.py --mode integrate --workers 8 --neval 1000 --nitn 8 --refinements 3` | Per-bin checkpoints in `s09_cache/`, `s09_result` |
| 13 | [s11_aggregate_replacement.py](s11_aggregate_replacement.py) | Final `s09_result`, `s11_result` |
| 14 | [dsigmapibydpt/s03_plot_comparison.py](dsigmapibydpt/s03_plot_comparison.py) | Both PDF/PNG figure sets and plot receipt |

Invoke Wolfram stages with the selected kernel's `-noprompt -script` options. S05 requires `SIDIS_S05_MODE=export` and `SIDIS_CHANNEL` set to one of `Hqq`, `Hqg`, `Hgq`, `Hgg`, `Hqqbar`, `Hqqprime`. Run Python programs with the recorded Python environment. The copied plot S01/S02 programs and their unchanged accepted data carriers are retained for input provenance; they do not need rerunning to render these figures.

All six channels are integrated jointly with deterministic recorded bin seeds. The original precision, independent-iteration, iteration-consistency, finiteness and component-sum gates are retained. Accepted bin checkpoints can be resumed with the same input identities and settings. S11 binds the current final `s09_result`; it adds the final aggregation metadata to the integration output.

## Folder contents and runtime

| Folder or record | Contents |
|---|---|
| `Fhats/` | Frozen SIDIS payloads, executed source, pole packets and channel README snapshots |
| `references/` | Frozen data and paper inputs, original numerical source snapshots, accepted unchanged input records, validation coordinates |
| `vendor/` | Original PDF/FF Fortran routines and grids, frozen SM particle/parameter definitions |
| `sNN_cache/` | The owning stage's exports, native builds, precision checks, grids and resumable bin results |
| `runtime/` | Cluster Python/compiler versions and requirements |
| `dsigmapibydpt/` | Data/reference carriers, plotting sources, figures and plotted-value receipt |
| `sNN_*_execution.json` / `sNN_execution.json` | Exact executed source hashes, command, job, exit/result gates and sampled memory |
| `sNN_*_run.log` / `sNN_run.log` | Cluster stage output |

[s01_reuse_manifest.json](s01_reuse_manifest.json) records the original source snapshots and initial copies, plus unchanged input hashes. Current executed source hashes are recorded in the stage execution receipts. It is not a live source-status record. Only [scripts/progress.md](../../progress.md) records live execution status.

The cluster uses Python 3.10.9, GCC/GFortran 12.5.0 and Boost 1.82 headers. Exact main package versions are in [runtime/s01_result.json](runtime/s01_result.json). VEGAS 6.3 is the compatible cluster wheel; the original environment used 6.4.1. Electromagnetic and unit-conversion inputs were frozen to the original accepted values, and all shared physical-setting checks passed. The runtime environment sets `WOLFRAM_KERNEL`, `CXX`, `FC`, compiler library/header paths and `SIDIS_CLUSTER_RUN=1`; exact commands are retained in the execution receipts. Compiled libraries contain cluster paths, so rebuild S06/S07/S09 before using them in a different environment.

Exports ran with at most four Wolfram processes and bounded operations. Integration used eight workers. Per-process address space was limited to 7 GiB; the integration process-tree RSS guard was 12 GiB with a 4 GiB node-memory reserve. Persistent monitors observed process state, output and memory and stopped dependent stages on failure.

## Accepted validation and artifact identities

The executed checks passed: 110 scalar exports, 55 paired functions, 7662 native/Wolfram comparisons, 1274 independent precision comparisons, and all 17 bins. Both figures were visually inspected. The largest sampled process-tree RSS across accepted jobs was 1.48 GiB. No OOM or memory-guard event occurred.

| Current artifact | SHA256 |
|---|---|
| [s09_result](s09_result) | `7d9c6095945b07bfa56deb39af6c3543c574b7c2faad0765d0f55caba55a4eff` |
| [s11_result](s11_result) | `f3f1b3a0996b36cae247b1a840768ee27091e5f06ff65dac8206951fa0acf90c` |
| [dsigmapibydpt/s03_result](dsigmapibydpt/s03_result) | `b5d7cf4e8b3d12a24099b6ad910fae06318e66fc49377e8fe959a0273f6b68dc` |

Every plot-file hash and the input chain are in the plot receipt. Accepted job/source identities and logs are:

| Stage | Hoffman2 job | Receipt | Log |
|---|---|---|---|
| s01_runtime | 14693752 | [s01_runtime_execution.json](s01_runtime_execution.json) | [s01_runtime_run.log](s01_runtime_run.log) |
| s03 | 14693739 | [s03_execution.json](s03_execution.json) | [s03_run.log](s03_run.log) |
| s04 | 14693759 | [s04_execution.json](s04_execution.json) | [s04_run.log](s04_run.log) |
| s06 | 14693758 | [s06_execution.json](s06_execution.json) | [s06_run.log](s06_run.log) |
| s08 | 14693763 | [s08_execution.json](s08_execution.json) | [s08_run.log](s08_run.log) |
| s10_invariant | 14693764 | [s10_invariant_execution.json](s10_invariant_execution.json) | [s10_invariant_run.log](s10_invariant_run.log) |
| s05 | 14693765 | [s05_execution.json](s05_execution.json) | [s05_run.log](s05_run.log) |
| s07 | 14693777 | [s07_execution.json](s07_execution.json) | [s07_run.log](s07_run.log) |
| s10_precision | 14693785 | [s10_precision_execution.json](s10_precision_execution.json) | [s10_precision_run.log](s10_precision_run.log) |
| s09_build | 14693810 | [s09_build_execution.json](s09_build_execution.json) | [s09_build_run.log](s09_build_run.log) |
| s09_smoke | 14693811 | [s09_smoke_execution.json](s09_smoke_execution.json) | [s09_smoke_run.log](s09_smoke_run.log) |
| s09_integrate | 14693812 | [s09_integrate_execution.json](s09_integrate_execution.json) | [s09_integrate_run.log](s09_integrate_run.log) |
| s11 | 14693839 | [s11_execution.json](s11_execution.json) | [s11_run.log](s11_run.log) |
| s03_plot | 14693841 | [s03_plot_execution.json](s03_plot_execution.json) | [s03_plot_run.log](s03_plot_run.log) |
