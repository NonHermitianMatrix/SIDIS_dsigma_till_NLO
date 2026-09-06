# Hqg MadGraph comparison

The user requested a quick MadGraph check and authorized choosing its stages.
Only the incoming-quark, observed-gluon channel is checked. Physics inputs
are the accepted parent S02 Born contractions, S04 generated amplitudes and
S05 real contractions. Numerical evaluation is authorized by this request.
No other channel coefficient or calculation program is an input. The existing
MadGraph 3.7.0 installation is reused solely as generic generator software;
fresh processes and all new files live in this directory.

## Contract

Generate photon-mediated e- u -> e- u g (Born) and e- u -> e- u g g
(real tree), excluding Z and Higgs exchange. Measure generated momentum/PDG
order, diagram counts, coupling powers and averaging/identical-particle
factors; bind them to the current Hqg inputs. Final gluon tagging must follow
S05's saved TagWeight, derived against the generated final-state identities.

Use a small deterministic set of massless phase-space points from MadGraph's
RAMBO implementation. Enforce masslessness, conservation, spacelike photon
momentum and separation from singular boundaries. The saved Pg/Ppp tensors
are compared through the lepton-azimuth average: derive the spin-averaged
lepton trace and its projection coefficients with algebra tools, and compare
with the same azimuth average of the generated full matrix element. Restore
couplings/charge once from measured current inputs and generated parameters.

The sequence prepares source-bound inputs, generates fresh MadGraph code,
samples its matrix element, evaluates the local contractions and writes the
signed numerical comparison. Embedded physical, normalization, mapping and
coverage gates establish what was checked. A mismatch is reported without
tuning either source. This tree check does not test virtual terms, collinear
subtraction or the finite NLO delta discrepancy.

Runs remain serial under address-space and RSS limits, with persistent inline
monitors for long jobs. Only ../../progress.md (scripts/progress.md) records
live execution status. No optional large integration or repeated production
sample is part of this quick comparison.

## Implemented sequence and boundary

1. s01_prepare_inputs.py copies the accepted Hqg S02/S04/S05 sources/results
   and generic MadGraph software, records hashes and model particle metadata.
2. s02_generate_processes.mg5 generates fresh photon-only Born and real
   standalone Fortran processes using one core.
3. s03_sample_madgraph.py builds a small C-callable interface and validates it
   against the generated direct Fortran driver. It uses MadGraph RAMBO with
   a fixed seed and eight accepted points per process. Two lepton kinematics
   per hadronic point allow Pg and Ppp to be reconstructed separately.
   SymPy solves the defining lepton mass-shell map and proves the finite
   azimuth quadrature exact for the bilinear trace. Gamma matrices come from
   SymPy; numerical traces and projection solves use NumPy. Generated IDEN,
   species multiplicities, runtime couplings and charges gate normalization.
4. s04_evaluate_local.wl evaluates the copied Hqg contractions at the same
   defining invariants and restores the measured coupling/charge powers.
5. s05_compare.py writes the signed per-projector comparison and summary.

This directly checks the same projector boundary as Hqqbar S07; it includes
the spin/color sums already present in Hqg S05. It is not a separate check of
every component of an uncontracted tensor such as Hqqbar S06.

The standalone workflow follows the official MadGraph documentation:
https://cp3.irmp.ucl.ac.be/projects/madgraph/wiki/FAQ-General-4 .

## Accepted result

S01 through S05 completed. Preparation recovered from dangling optional
software links and installed the missing generic six 1.17.0 dependency
locally before generation. Neither issue produced a physics result.
The two generated processes, interface/sample run, local evaluation and
final comparison then completed with their embedded gates.

The 16 deterministic physical points produce 32 separate Pg/Ppp comparisons.
All passed the declared tolerance; the maximum relative projector difference
is 2.0568861206860341e-12. Every tested azimuth average also passed,
with maximum relative difference 1.3720868812283901e-13. The current-channel
identical-gluon exchange check passed at maximum relative difference
3.2499497972157905e-13. No local or generated coefficient was adjusted.

Measured process bookkeeping:

| Process | Diagrams | IDEN | Incoming denominator | Final symmetry denominator | Gluon tags | S05-style tag weight | MadGraph tagged factor |
|---|---:|---:|---:|---:|---:|---:|---:|
| born | 2 | 12 | 12 | 1 | 1 | 1 | 1.0 |
| real | 8 | 24 | 12 | 2 | 2 | 1 | 2.0 |

The exact generated/independent diagram-count gates, runtime charge and
coupling gates, direct Fortran/interface comparisons, physical momentum
checks, exact azimuth-quadrature proof, two-setting projector reconstruction
and local Ward/input-hash gates all passed. The result refers to the bare
four-dimensional tree projector boundary, not a finite NLO hard part or
a separate reconstruction of an open photon tensor.

The largest sampled process-group RSS was 302.8 MiB in S04. All runs were
serial; no memory/inactivity guard triggered and no OOM occurred. Generated
code, libraries, direct-driver checks and the deterministic sample retain
production/reproduction/validation value and are kept. No disposable test
cache was created. Parent Hqg inputs were hash-checked unchanged.

Consumer entry points are s03_result.json (generated numerical projections,
momenta, orientation values and normalization), s04_result.json (local
values), and s05_result.json (all signed projector/average comparisons).
madgraph_minus_local.md is the human-readable table. Sources, generated
artifacts and logs remain under this folder. Reproduction must use a fresh
output destination or preserve the accepted outputs before a new run.

Accepted source/result/log identities:

| File | SHA256 | Bytes |
|---|---|---:|
| s01_prepare_inputs.py | `d3af12ef603b5850717f906c000e38078a0a24b7e49ef06b6dadf19c2ea3fab1` | 2729 |
| s01_result.json | `86f783a9692e389ab818b1a077002a53cfceb0d2a4af7b45f3ed44e1d96dded2` | 1879 |
| s01_run.log | `30ccb3df27d93025f5cbdcf767e0b1c49004ddecd8f04148bc97a6f16a579828` | 225 |
| s02_generate_processes.mg5 | `3d27e0469f067c163d4c31450bee88312bf0b418863a97d4318e2eeeb67c728c` | 358 |
| s02_run.log | `81cc2be64ccf68b93e05ac6bb7467be7c38f3daedcdcc37cddd933816ed84fdb` | 6433 |
| s03_sample_madgraph.py | `027868aacb19f174fe5c37b0e1da0b89cad0992f250aebdd02636d14372dcaf0` | 15625 |
| s03_result.json | `d61b1a4573fedc8a2eff099134413b2e818d3e4199913ea5893b697af56532bd` | 31138 |
| s03_run.log | `5028418d06257392af87d6e7b71e9fee14ec04b2548d4ef41bb928c226fa055f` | 40291 |
| s04_evaluate_local.wl | `abb195e4fc0bc218413c55793eb2e6b56b8b4dfad73d49489421d73d38b75d47` | 6829 |
| s04_result.json | `25c9eb5369ec681a08604148ea3d5898457de201152f038068f98329eccff1a1` | 7724 |
| s04_run.log | `3a8e6fc723c3bac37f23296471d23fcdef894108d32ecd19fadb5bdea88bbd66` | 4754 |
| s05_compare.py | `b0f4c60a081d9cb6f7f68e4f7c457f0b52fa25f1cefb0a21072f8821721f26b1` | 5635 |
| s05_result.json | `a3a2032397a75b7416555f0e0903c8a51f2ae6383141ec5c610378d6202379da` | 25291 |
| s05_run.log | `828aefc5459c3c51c3fb462e39d25d966609d0866ddbc1fd83451c4862745015` | 650 |
| madgraph_minus_local.md | `af028b904e66d916b4b477a172d1b3ab7f80e6dfadde1b0697935054b130d866` | 5372 |
