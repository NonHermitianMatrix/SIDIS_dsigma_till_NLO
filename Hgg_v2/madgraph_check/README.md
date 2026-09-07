# MadGraph check

This check compares the saved, unintegrated Hgg current tensor with a fresh
MadGraph standalone calculation of `a g > g u u~ QCD=2 QED=1`.
The production expressions remain symbolic and are not changed by this check.

The photon is spacelike. Only its external HELAS wavefunction is replaced:
its momentum entries retain the generated HELAS convention, and its four
polarization entries are supplied explicitly. The four Cartesian currents
give the metric contraction; the incoming gluon momentum gives the `pp`
contraction. The photon momentum supplies a Ward-identity check. All other
external wavefunctions, vertices, diagrams and color algebra are generated
by MadGraph. The incoming gluon spin/color average is retained, and the
electromagnetic coupling is removed to match the production current tensor.

Stages:

- `s01_generate.py`: generate the standalone subprocess with MadGraph 3.7.0.
  Set `MG5_PATH` to its installation directory if needed.
- `s02_benchmarks.wls`: construct deterministic on-shell phase-space points
  with a spacelike photon and evaluate both saved contractions at 60 digits.
- `s03_compare.py`: build the explicit-current driver and compare the
  double-precision MadGraph values with the saved tensor. Fail on a Ward
  residual or relative discrepancy above the recorded tolerances.

MadGraph's standalone interface is documented at
https://cp3.irmp.ucl.ac.be/projects/madgraph/wiki/FAQ-General-4 .
Only the installed MadGraph package is reused; no other channel's check
code or results are used.

The executed comparison passed all 12 contractions at six points, with
maximum relative difference 8.725237422956394e-16. All six Ward checks
passed, with maximum normalized squared residual 1.511315062183669e-32.
The detailed report is `madgraph_minus_local.md`; values, tolerances,
normalization checks and source hashes are in `s03_result.json`.

The generated `standalone` source tree is included, so the comparison can
be rebuilt by running `python s03_compare.py` without rerunning MadGraph.
Compiled libraries, object files and the executable are excluded from Git.
Stage 2 is run with the Wolfram Engine 15 executable used by the production
pipeline. Each check stage has a 3 GiB address-space cap in the executed
run; stage 2 and 3 memory receipts are included. No OOM occurred.
