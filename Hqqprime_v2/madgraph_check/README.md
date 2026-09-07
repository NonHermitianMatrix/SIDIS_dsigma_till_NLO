# Hqqprime MadGraph check

Generate `a u > d u d~ QCD=2 QED=1` with MadGraph 3.7.0. Compare the
unintegrated current tensor at six exact kinematic points and four charge
assignments, including separate photon couplings on each quark line and
both signs of their interference.

Only the external photon polarization is replaced by Cartesian, p and q
currents. Its generated momentum entries, all vertices and color algebra
remain intact. The original model charges read by FeynArts are checked
against the two initialized MadGraph photon couplings before setting the
independent test charges. The incoming quark average and spectator weight
are checked from the generated normalization and field counts.

Run s01_generate.py, s02_benchmarks.wls with Wolfram Engine 15, then
s03_compare.py. The generated standalone source can be rebuilt by stage 3.
No older Hqqprime check code or result is used.

Accepted check artifacts

The fresh generated process has 4 diagrams. All 48 contractions
and 24 Ward checks passed. Maximum relative contraction difference:
`3.20163877546439e-15`; maximum normalized squared Ward residual:
`5.000661084488203e-32`.

Generation provenance: `s01_result.json`; exact seeds and 60-digit references:
`s02_result.wl` and `s02_result.json`; comparisons: `s03_result.json` and
`madgraph_minus_local.md`; raw currents: `s03_currents.log`; build log:
`s03_build.log`. Generated standalone sources, model input, patched matrix,
driver and build products are retained for reproducible reruns.
The checked production hash is `4aee27e2d6b9decefce735ecb94536a71f4be0f09352cf5a538fd3b27d504cf6`.
