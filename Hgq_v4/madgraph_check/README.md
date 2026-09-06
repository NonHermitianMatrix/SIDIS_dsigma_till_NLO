# Hgq MadGraph tree projector check

Inputs are accepted Hgq_v4 S01 amplitudes, S02 Born/projectors and S03 real
contractions. Generate fresh photon-only e- g -> e- u ubar and
e- g -> e- u ubar g with generic MadGraph. The observed parton is u;
ubar is k2 and the additional gluon is k3. Hqg_v3 supplies algorithms and
generic software only. No other channel result is an input.

Use deterministic physical points and tool-derived lepton azimuth
quadrature to reconstruct Pg and Ppp with two lepton settings. Measure
generated species, helicities, color and symmetry denominators, coupling
powers, charges and diagram counts; gate them against the current inputs.
Compare Born/real projectors and azimuth averages at the same momenta.
This is a tree check, not a validation of virtual, subtraction or complete
NLO coefficients. Do not impose an identical-gluon exchange check on Hgq.

Stages: s01 prepares inputs and model metadata; s02 generates processes;
s03 builds and samples MadGraph; s04 evaluates the current independent
contractions; s05 writes signed differences and tolerance decisions.
Run on Hoffman2 with bounded memory and persistent inline monitors. Main
codes/results remain local. Only ../../progress.md records live status.

Accepted S01 execution: Hoffman2 job 14688000, source s01_prepare_inputs.py, source SHA256 ea28500e0aecccc46740aae821430f969ea4bc847027f508174b12460af43804, result s01_result.json (SHA256 68f43c3cc11934cfdbd21751386b0e28c8a5cd8e61361db094f590dc8546e15e). Log/receipt: s01_run.log and s01_execution.json. Sampled peak RSS 36532224 bytes; no memory/inactivity guard.

Accepted S02 execution: Hoffman2 job 14688006, source s02_generate_processes.mg5, source SHA256 2ef64cfa9a8d02585a7f3f715ed9cc5bbd4dcbb41399be3c8283cc56507e5f76, result s02_result.json (SHA256 7f37f8886c26c1d8de54c318f1f08ba62f7935914c5f8035ab28b804d540bce9). Log/receipt: s02_run.log and s02_execution.json. Sampled peak RSS 109907968 bytes; no memory/inactivity guard.

Accepted S03 execution: Hoffman2 job 14688008, source s03_sample_madgraph.py, source SHA256 d47225318d9fedccf268ecec7915b17ba80ecb0888def662f277419f52d2f738, result s03_result.json (SHA256 dafe7f763249e3a0658773bdbd859eb93de6e604d9872d6585637078f166c2c9). Log/receipt: s03_run.log and s03_execution.json. Sampled peak RSS 80097280 bytes; no memory/inactivity guard.

Accepted S04 execution: Hoffman2 job 14688010, source s04_evaluate_local.wl, source SHA256 225cf8495532f3280baf7101a61d59a4e989cfa40cbd6ba4124ef8cc291f143c, result s04_result.json (SHA256 a9430ee7247649f81d22c9a2b5f48d5587f60b9865fef57358fbfefdd245cbbc). Log/receipt: s04_run.log and s04_execution.json. Sampled peak RSS 184213504 bytes; no memory/inactivity guard.

Accepted S05 execution: Hoffman2 job 14688012, source s05_compare.py, source SHA256 702697f5dfde7a82f88c12c947ec80b118cdf79fb26b506c1ff39cf503aa5174, result s05_result.json (SHA256 8757ed8318c39b21bcbdc397058f33f375a1178e9a73675f295478dff98894d3). Log/receipt: s05_run.log and s05_execution.json. Sampled peak RSS 0 bytes; no memory/inactivity guard.

S05 execution acceptance means a complete report, not agreement: its Born comparisons pass and real comparisons fail. Supplemental `s06_validate_real_projection.wl` checks the saved scalar products against sample four-vector dot products and directly squares the total generated real amplitude at the first existing real point, using FeynCalc and physical gluon polarization sums. It compares that fresh result with both the stored real contraction and MadGraph. No sign is fitted and no production result is modified by this check.

S06 scalar-product residuals use the product of Euclidean four-vector norms as the roundoff scale, including zero on-shell Minkowski products. The scalar-product and mass-shell tolerance is 1e-12; raw benchmark vectors retain their existing floating-point input precision. The old absolute zero-product check stopped on a 1.8474111129762605e-12 mass-shell residue and did not establish an invariant-map error.

Final comparison report: `s05_result.json` SHA256 `8757ed8318c39b21bcbdc397058f33f375a1178e9a73675f295478dff98894d3`; `madgraph_minus_local.md` SHA256 `31e5de4cabb8eba9b3d6598ad6d0d427c9c9f56f851c4bb75876fd19b62a2146`. Born agreement passes, maximum relative difference 6.291654908100499e-13. Real agreement fails, maximum relative difference 1.9999999999999951; the displayed real projectors have opposite signs. No sign is fitted and no production coefficient is changed. This real-emission discrepancy is unresolved.

Supplemental S06 is not accepted: source `s06_validate_real_projection.wl` SHA256 `122a252339275ec54ba9fd23a3e029cca24b457f0c0566c9f1adaa0673aed207`, job 14688021, `s06_run.log` and `s06_execution.json`. The momentum-definition gates passed; the outgoing-gluon polarization-sum operation reached its 180-second limit before a direct squared-amplitude result. No `s06_result.json` exists and no physics conclusion follows from that unfinished square. Its source and logs have diagnostic/provenance value and are retained; no disposable diagnostic cache was created. S05 peak RSS zero is an unavailable sample for that sub-second process, not a physical zero-memory measurement. Generator and evaluation jobs used the verified installed Anaconda Python 3.10.9; generic MadGraph software was unchanged.
