# Hqg MadGraph tree comparison

Incoming quark, observed gluon. Fresh photon-only Born `e- u -> e- u g` and real `e- u -> e- u g g` processes are compared with accepted Hqg_v3 S02/S05.

This directly tests the projector boundary corresponding to Hqqbar S07, with spin/color sums already included. It is not a separate full open-tensor S06 check. No loop, phase-space integration, factorization or finite NLO delta coefficient is tested.

MadGraph's own RAMBO supplies eight accepted deterministic points per process. The exact lepton mass-shell map and azimuth quadrature are derived by SymPy. Two lepton kinematics reconstruct both Pg and Ppp. Columns include the same photon propagator and measured coupling/charge normalization. The generated identical-gluon factor is converted to the accepted tagged-gluon convention.

The numerical interface also passed a direct Fortran-driver comparison for each process. Generator workflow: [official MadGraph standalone documentation](https://cp3.irmp.ucl.ac.be/projects/madgraph/wiki/FAQ-General-4).

| Point | Projection | Local | MadGraph | MadGraph − local | Relative difference | Close |
|---|---|---:|---:|---:|---:|:---:|
| born_01 | Pg | -3.771988659438e-08 | -3.771988659438e-08 | -3.308722450212e-23 | 8.77183e-16 | True |
| born_01 | Ppp | 1.607590431396e-05 | 1.607590431396e-05 | -5.082197683526e-20 | 3.16138e-15 | True |
| born_02 | Pg | -4.356072908611e-09 | -4.356072908611e-09 | -3.722312756489e-23 | 8.54511e-15 | True |
| born_02 | Ppp | 2.693186833498e-07 | 2.693186833497e-07 | -6.368628972168e-20 | 2.36472e-13 | True |
| born_03 | Pg | -5.350267995761e-09 | -5.350267995761e-09 | -8.271806125530e-24 | 1.54605e-15 | True |
| born_03 | Ppp | 4.767896873663e-08 | 4.767896873656e-08 | -6.657149569827e-20 | 1.39624e-12 | True |
| born_04 | Pg | -3.062800285100e-06 | -3.062800285099e-06 | 4.290221877843e-19 | 1.40075e-13 | True |
| born_04 | Ppp | 2.545769368199e-06 | 2.545769368204e-06 | 5.236357679926e-18 | 2.05689e-12 | True |
| born_05 | Pg | -1.720717271403e-07 | -1.720717271403e-07 | -7.226249831263e-21 | 4.19956e-14 | True |
| born_05 | Ppp | 2.487131051344e-06 | 2.487131051343e-06 | -5.437951521373e-19 | 2.18644e-13 | True |
| born_06 | Pg | -1.054483822089e-08 | -1.054483822089e-08 | -2.150669592638e-23 | 2.03955e-15 | True |
| born_06 | Ppp | 2.884715134288e-06 | 2.884715134288e-06 | 8.893845946170e-21 | 3.08309e-15 | True |
| born_07 | Pg | -4.047674799132e-08 | -4.047674799132e-08 | 6.617444900424e-24 | 1.63488e-16 | True |
| born_07 | Ppp | 1.259957226748e-05 | 1.259957226748e-05 | -5.082197683526e-21 | 4.03363e-16 | True |
| born_08 | Pg | -2.089104166776e-07 | -2.089104166776e-07 | 1.799945012915e-21 | 8.61587e-15 | True |
| born_08 | Ppp | 2.876174408845e-06 | 2.876174408845e-06 | -4.967848235646e-19 | 1.72724e-13 | True |
| real_01 | Pg | -4.693509395996e-09 | -4.693509395995e-09 | 1.737079286361e-22 | 3.70102e-14 | True |
| real_01 | Ppp | 6.492813495082e-07 | 6.492813495082e-07 | 0.000000000000e+00 | 0.00000e+00 | True |
| real_02 | Pg | -2.084341591436e-09 | -2.084341591436e-09 | 5.707546226616e-23 | 2.73830e-14 | True |
| real_02 | Ppp | 1.460615616635e-07 | 1.460615616634e-07 | -1.242226756708e-19 | 8.50482e-13 | True |
| real_03 | Pg | -2.705576414489e-08 | -2.705576414489e-08 | -8.900463391071e-22 | 3.28967e-14 | True |
| real_03 | Ppp | 1.208634730295e-05 | 1.208634730295e-05 | 8.080694316806e-19 | 6.68580e-14 | True |
| real_04 | Pg | -3.486956583950e-09 | -3.486956583950e-09 | -4.963083675318e-24 | 1.42333e-15 | True |
| real_04 | Ppp | 2.843023171363e-07 | 2.843023171363e-07 | 3.811648262644e-21 | 1.34070e-14 | True |
| real_05 | Pg | -3.703112232641e-09 | -3.703112232641e-09 | 8.271806125530e-25 | 2.23374e-16 | True |
| real_05 | Ppp | 1.242143821536e-06 | 1.242143821536e-06 | -6.352747104407e-22 | 5.11434e-16 | True |
| real_06 | Pg | -1.084768685879e-08 | -1.084768685879e-08 | 6.617444900424e-24 | 6.10033e-16 | True |
| real_06 | Ppp | 2.397952247679e-06 | 2.397952247679e-06 | 3.218725199566e-20 | 1.34228e-14 | True |
| real_07 | Pg | -4.710590674224e-09 | -4.710590674224e-09 | 9.098986738083e-24 | 1.93160e-15 | True |
| real_07 | Ppp | 2.270361358744e-06 | 2.270361358744e-06 | 1.694065894509e-20 | 7.46166e-15 | True |
| real_08 | Pg | -1.313416522977e-09 | -1.313416522977e-09 | 2.998529720505e-23 | 2.28300e-14 | True |
| real_08 | Ppp | 1.890658184499e-07 | 1.890658184502e-07 | 2.770327133114e-19 | 1.46527e-12 | True |

```json
{
  "PhysicalPoints": 16,
  "ProjectionComparisons": 32,
  "AllProjectorsWithinTolerance": true,
  "AllAzimuthAveragesWithinTolerance": true,
  "MaximumProjectorRelativeDifference": 2.056886120686034e-12,
  "MaximumAzimuthAverageRelativeDifference": 1.37208688122839e-13,
  "MaximumGluonExchangeRelativeDifference": 3.2499497972157905e-13,
  "ByProcess": {
    "born": {
      "Count": 16,
      "AllWithinTolerance": true,
      "MaximumRelativeDifference": 2.056886120686034e-12
    },
    "real": {
      "Count": 16,
      "AllWithinTolerance": true,
      "MaximumRelativeDifference": 1.4652712773901644e-12
    }
  }
}
```

Tolerance: abs(difference) <= 1e-25 + 1e-8*max(abs(MadGraph),abs(local)). All per-orientation values, normalization factors, input hashes and projector solves are retained in s03_result.json and s04_result.json. A mismatch is reported without tuning either input.
