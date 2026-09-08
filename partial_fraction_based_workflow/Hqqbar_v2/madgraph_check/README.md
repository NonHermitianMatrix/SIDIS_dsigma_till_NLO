# Hqqbar MadGraph comparison

Generate a fresh `a u > u~ u u QCD=2 QED=1` subprocess. Replace only the
external photon polarization with explicit Cartesian, p and q currents,
retaining MadGraph momentum entries, all vertices and its color algebra.
Compare both saved unintegrated contractions at six deterministic spacelike
photon points and gate the photon Ward identity.

The production square excludes the spectator phase-space symmetry weight.
The comparison removes the identical-particle factor from MadGraph's
SMATRIX result using the weight counted independently from the FeynArts
spectator fields. It checks the remaining incoming quark spin/color average
against the generated helicity table and normalization denominator.

Run s01_generate.py, s02_benchmarks.wls with Wolfram Engine 15, and
s03_compare.py. The last stage builds the supplied standalone sources
without requiring MadGraph to generate the process again. Only the
installed MadGraph package is reused; no old Hqqbar code or data are inputs.

Executed result: 12/12 contractions and all six Ward checks passed. Maximum relative difference: 1.4580247060443812e-15. The detailed values, normalization gates and production hash are in `s03_result.json`; the report is `madgraph_minus_local.md`. Raw generated-current values are in `s03_currents.log`, separate from the execution log.
