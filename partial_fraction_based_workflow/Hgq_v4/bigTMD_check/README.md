# Hgq BigTMD numerical check

Inputs are the accepted Hgq_v4 S10 hats and pinned published BigTMD Hgq
coefficients. Hqg_v3 supplies comparison algorithms only. Authors data are
comparison inputs and cannot change a production coefficient.

Prepare and hash the current-channel reference, derive variable and
distribution maps from their defining relations with Wolfram, evaluate
both F hats at deterministic physical points, and report signed BigTMD
minus local differences. Delta and plus distributions are compared by
coefficients in a common basis. Direct published Python evaluation checks
the ordinary NLO density. Declare tolerances and all decimal policies.

Run on Hoffman2 with bounded memory and persistent inline monitors. Main
codes, reference inputs and results are retained here locally. Record live
progress only in ../../progress.md. A discrepancy is a reported result.

Stages: s01_prepare_reference.py downloads and hash-checks pinned channel 1A, extracts the channel-1 Born selection and driver weights, and imports exact symbolic expressions. Long decimals use the explicitly reported unique rational reconstruction with denominator at most 10^6, following the authorized parent method. s02_export_fhat_benchmarks.wl derives current maps, endpoint/plus transport and 60-digit evaluations at the three parent workflow seeds. It gates the full physical recoil interval. s03_compare_bigtmd_fhat.py directly executes the published decimal functions and reports both canonical coefficients and interior densities with tolerance 1e-10 + 1e-7 times the larger magnitude. Reference disagreement is reported, not fitted. frozen_inputs.json binds only the required current Hgq inputs. The report must state the measured branch coverage.

S01 reads numeric tokens using cached UTF-8 source lines and AST byte offsets, asserting single-line numeric literals and equality to the AST parsed value for every token. Exact-number conversion is memoized; reference hashes and rational-reconstruction gates are unchanged. Each imported function emits progress. The unaccepted slow-parser source/logs are preserved in `s01_previous_14687999`; verified published files remain reusable inputs.

Accepted S01 execution: Hoffman2 job 14688009, source s01_prepare_reference.py, source SHA256 aca02a4be190a04d697227601f08382e8b3b1a2e9e5dc40534f6117d4e8f88e4, result s01_result.json (SHA256 b4b2f1369c2aa994e2a6b8aca5599a825b0c26ca8402ef3214a29bf03c7fb7b7). Log/receipt: s01_run.log and s01_execution.json. Sampled peak RSS 47644672 bytes; no memory/inactivity guard.

Accepted S02 execution: Hoffman2 job 14688011, source s02_export_fhat_benchmarks.wl, source SHA256 5fb56e0806a784a9c0e10a1335a7db714ac2a5bfcb97faf9928cfcf87adf6dd7, result s02_result.json (SHA256 5bf403475a5165031ff112067e8e6cd309c3665696fd483f3ce03e1a096407de). Log/receipt: s02_run.log and s02_execution.json. Sampled peak RSS 459399168 bytes; no memory/inactivity guard.

S02 export from job 14688011 is superseded: Wolfram exported its arbitrary-precision zero imaginary residual as `0.e-64`, which its own importer accepted but strict Python JSON rejected. The source and invalid consumer artifact are versioned in `s02_previous_14688011`. S02 now exports JSON numeric fields at machine precision while retaining the full 60-digit strings, and gates strict Python JSON reload before acceptance. All evaluations must regenerate under the corrected source.

Accepted S02 execution: Hoffman2 job 14688018, source s02_export_fhat_benchmarks.wl, source SHA256 928056c94b72b9767ba58e63ff4e90c545a4c1ca401a5e428168d1f3f41dba1c, result s02_result.json (SHA256 0c4fd5b8201dea85e7735858a49ff1a26e969a9b16e163d84209a26efbfb42c9). Log/receipt: s02_run.log and s02_execution.json. Sampled peak RSS 468033536 bytes; no memory/inactivity guard.

Accepted S03 execution: Hoffman2 job 14688024, source s03_compare_bigtmd_fhat.py, source SHA256 74fd1d8757a9d2e72f20eb6c68de74a924a36b13df1c971465982a755fd2c937, result s03_result.json (SHA256 6f2cfb8e430303347190bfa44c74ae8324f20539b734a33d2781a28a30999194). Log/receipt: s03_run.log and s03_execution.json. Sampled peak RSS 112680960 bytes; no memory/inactivity guard.

Final accepted report: `s03_result.json` SHA256 `6f2cfb8e430303347190bfa44c74ae8324f20539b734a33d2781a28a30999194`; `bigtmd_minus_local.md` SHA256 `0b712a590051deaecce268899163438e938f41c00721af05ce7643fe3a5021f4`. All 30 canonical coefficient comparisons and 6 direct published-Python comparisons pass. The maximum direct relative difference is 2.5726226389472912e-14. Canonical differences are zero at the exported numeric precision; full 60-digit strings remain in S02. Measured numerical branch coverage: {"Interior": [1], "Endpoint": [1]}. These three points do not numerically cover the negative branch or coordinate boundary. The rational-reconstruction assumption is stated in the report; this is benchmark agreement, not a general symbolic proof. The accepted S02 identity is the later job 14688018 entry, superseding job 14688011.
