# Hqg MadGraph tree-real check

## Scope

This isolated workflow compares the accepted corrected Hqg bare real tree with
the photon-only full-electron process

`e- u -> e- g u g`.

The ordered local hadronic state is observed `g(k1)`, quark `u(k2)`, and
unobserved `g(k3)`.  Only byte-identical copies of the accepted Hqg S01, S06,
and S07 sources/results may enter.  S08 and all endpoint, virtual,
factorization, and finite-hard-part stages are outside this check.

## Bookkeeping contract

- Copied S06 already contains final spin/color sums, the incoming-quark
  average, and D-dimensional physical axial polarization sums for both real
  gluons with reference momentum `p`.
- The check restores the representative charge derived in copied S01, then
  adds the spin-averaged electron tensor, second electromagnetic vertex, and
  photon propagator exactly once.
- The two outgoing gluons are identical, while observed `g(k1)` remains
  labeled locally.  MadGraph process ordering, diagram count, PDG order,
  incoming averages, generated `IDEN`, and the identity divisor are measured
  from this generated process.  No symmetry factor is guessed or copied.
- Four equally spaced lepton-plane rotations at fixed hadronic invariants must
  reproduce the copied S07 Pg/PPP reconstruction.
- This validates only the corrected four-dimensional bare real tree and is
  independent of the Hqg S10 production job and caches.

## Reused software

The pinned MG5_aMC 3.7.0 executable and `six.py` under
`scripts/Hqqbar/madgraph_check` are reused read-only.  Hqg generated code,
samples, logs, and results remain in this directory.

## Stage map

1. `s01_prepare_inputs.py`: hash-bind and copy accepted Hqg inputs.
2. `s02_generate_hqg_standalone.mg5`: generate the photon-only process.
3. `s03_madgraph_c_bridge.f90`: expose generated evaluation and metadata.
4. `s04_direct_madgraph_reference.f90`: call the generated routine directly.
5. `s05_validate_madgraph_bridge.py`: validate bridge, routing, metadata, and
   final-gluon exchange symmetry at deterministic points.
6. `s06_inspect_copied_s07_schema.wl`: validate the copied projection schema.
7. `s07_validate_local_matrix_element.wl`: validate fixed orientation and
   Pg/PPP reconstruction.
8. `s08_validate_azimuthal_average.py`: validate the four-angle average.
9. `s09_build_four_dimensional_evaluator.wl`: export the compact local
   four-dimensional unit-coupling evaluator.
10. `s10_generate_cut_bin_madgraph.py`: generate and evaluate the one
    deterministic 120,000-trial common sample.
11. `s11_evaluate_local_cut_bin.wl`: evaluate the local expression on the
    identical accepted rows.
12. `s12_integrate_common_cut_bin.py`: produce the correlated bin comparison
    and terminal validation artifact.

## Current status

S01 input binding is complete and accepted:

- `s01_prepare_inputs.py`, SHA-256
  `a3a298bc9fa0ea5c8ba3341080eb6c85e49d39b4ce0c35e3d1412f449be6f58c`;
- `s01_input_manifest.json`, SHA-256
  `71411ec19a5354c74cb58902c2da6afcaa2d66ecda7a1065e71ef3a5a38a0879`;
- `s01_prepare_inputs.log`, SHA-256
  `30273e8cd8af84179742e7a81839c37bc196ecf0f465c937eb2b8c8dc35c922e`.

The manifest reloaded with every check true.  All six files under
`upstream_copies/` are byte-identical to their accepted parents, and both
reused dependencies match their pinned hashes.  Generated process metadata
remain deliberately unresolved until S02--S05.  No Hqg MadGraph result is
accepted yet.

S02 generation and direct-library compilation are complete pending the S05
cross-gate.  MG5 generated one subprocess with eight diagrams.  Tool parsing
of its exact Fortran measured PDGs `{11,2,11,21,2,21}`, beam-helicity factors
`{2,2}`, final-PDG identity divisor `2`, and generated `IDEN=24`.  Exact
SHA-256 values are: S02 card `1172a9cd...`, generation log `7c2c4f97...`,
compile log `239702f5...`, generated process card `126f178a...`,
`all_matrix.f` `ac4433fd...`, subprocess `matrix.f` `89a3a87f...`, and
`liball_2me.so` `7c7e2be4...`.  These measurements are not accepted as bridge
metadata until S05 independently rederives and matches them.

S03--S05 are complete and accepted.  S03 source/library SHA-256 are
`493ba53a...` / `291f4adb...`; S04 source/executable/direct-log SHA-256 are
`78ce3f1f...` / `6383230a...` / `1144c66c...`; S05 source/log/result SHA-256
are `b1bd329c...` / `d1ded2ec...` / `28dc6ca1...`.  Both strict compile logs
are empty (`e3b0c442...`), recording warning-free builds.  S05 rederived the
current generated and copied metadata, matched generated/derived `IDEN=24`,
matched the bridge to the independent generated call at three points with
maximum relative difference zero, and matched exchange of the two final
gluons at all three points with maximum relative difference
`1.4128713412511093e-16`.  The atomically reloaded result has every check true.
The local identity normalization against copied S06 remains for S07 and is
not inferred from this generated-only gate.

S06 copied-schema inspection is complete and accepted.  Source/log SHA-256
are `4e00d869...` / `45f41acf...`.  Engine 15 matched corrected
`HqgS07-v5`, channel `Hqg only`, branch `Hqg;qg`, and exact projector order
`{Pg,PPP}`.  Both expressions are exact and machine-real-free; their inert
denominator and coupling inventories contain only the expected propagator
forms, `SMP["g_s"]`, and `FCGV["EL"]`.  The log ends in `S06_SUCCESS`.

S07 local-tensor validation is complete and accepted.  Source/log/result
SHA-256 are `226f97b2...` / `20fb70c2...` / `518e1b94...`.  Engine 15 derived
the representative charge and amplitude strip factor from copied S01,
constructed the spin-averaged electron tensor by `DiracTrace`, reconstructed
the Pg/PPP tensor coefficients by `LinearSolve`, and uniquely selected the
generated final-state identity correction `2`.  The corrected strict-JSON
artifact has every check true; the fixed-orientation local/generated relative
difference is `4.7894450549967675e-16`, and both fresh/copy projection
residuals are exactly zero.  The projected value is deliberately deferred to
the four-angle S08 acceptance gate.

S08 four-angle azimuthal validation is complete and accepted.  Source/log/
result SHA-256 are `3dba964b...` / `b0e6d7b9...` / `a04e67cc...`.  The strict
JSON reload has every gate true.  Its equally spaced generated labeled values
average to `9.366193510867247e-10`, compared with the copied projected local
value `9.366193510867218e-10`, for relative difference
`3.09104455356008e-15`.  Thus the fixed-orientation and projected-normalization
contracts are both accepted before building the bulk evaluator.

Corrected S09 four-dimensional evaluator export is complete and accepted.
Source/log/result SHA-256 are `d902efb8...` / `39ad51f2...` / `ab1b2cb3...`.
Engine 15 measured 718 raw Pg and 70 raw PPP complex atoms, proved both
symbolic imaginary parts and both original-minus-real reconstructions exactly
zero, and stored explicit real parts containing zero complex atoms.  All eleven
reload gates are true.  The machine-real accepted-point Pg/PPP relative
differences are `1.5992584498302527e-15` and exactly zero.  S10 is pending
deterministic regeneration solely to pin this corrected S09 identity.

Corrected-provenance S10 is complete and accepted.  Source/log/CSV/metadata
SHA-256 are `7dca74b4...` / `26444317...` / `6f64a12a...` / `78881497...`.
Strict readback confirms complete status, 27,851 rows, the corrected S09 hash
`ab1b2cb3...`, and the same byte-identical deterministic CSV as before.  The
generated estimate and sampling error remain `0.010130077053352622` pb and
`0.00016730446869397996` pb.  S11 must consume this exact CSV and metadata.

Corrected S11 common-row local evaluation is complete and accepted.  Source/
log/CSV/JSON SHA-256 are `10342940...` / `899d2072...` / `4f343916...` /
`95eddd1c...`.  Strict reload has all ten gates true and exactly 27,851 rows.
Maximum, mean, median, and 99th-percentile local/MadGraph relative differences
are `2.179208133497826e-11`, `8.108069319327058e-15`,
`2.6734483251578605e-15`, and `6.427960527741967e-14`.  The superseded failed
representation log is retained as `s11_failed_zero_imaginary_representation.log`
with SHA-256 `fc6e711d...`; it is not a consumable result.

S12 correlated integration is complete and is the terminal accepted MadGraph
check.  Source/log/result SHA-256 are `2eed6fec...` / `72ef5fdc...` /
`9e08e8b1...`.  Strict reload has all seven terminal gates true.  On the exact
common 120,000-trial sample with 27,851 accepted rows, MadGraph gives
`0.010130077053352624` pb with sampling error `0.00016730446869397999` pb,
while the local projected result gives `0.010130077053352619` pb.  Their signed
difference is `-6.032295206949415e-18` pb, integrated relative difference is
`5.954836449099844e-16`, and sample correlation is exactly `1.0`.  No stage
beyond S12 is required for this isolated bare-real-tree check.
