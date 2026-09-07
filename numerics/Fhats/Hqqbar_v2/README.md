# Hqqbar at order alpha_s squared

The process is gamma*(q) + q(p) -> qbar(k1) + q(k2) + q(k3), with
k1 observed and k2,k3 integrated. The quark flavour is fixed. The charge
parameter `eq2` in the final result denotes that flavour's squared charge.
The reference is Wang et al., arXiv:1903.01529, especially Table I and
Eqs. 19, 38, 46, 52, 53. No virtual contribution occurs in this channel.

The calculation reuses the process-independent code written for Hgg_v2
in this conversation. Every amplitude, Born tensor, interference, angular
integral and subtraction is recalculated in this directory. No old
Hqqbar pipeline code or result is an input.

Stage contracts:

- `s01_amplitudes.wls` generates the real process and the two subtraction
  Born processes with FeynArts. It selects the required electromagnetic
  and strong coupling powers, and counts identical spectator fields to
  obtain the phase-space symmetry weight.
- `s02_square.wls` computes D-dimensional spin/color-averaged current
  contractions `g`, `pp`, `qq`, with the electromagnetic coupling removed.
  Every interference is checkpointed. The full photon Ward identity and
  exchange of the two identical spectators must hold exactly. The real
  tensor here has no phase-space symmetry weight.
- `s03_partial_fractions.wls` reduces angular denominators using Appendix D.
  Every result must reconstruct its saved interference exactly.
- `s04_angular_integrals.wls` integrates using Appendix B and checks the
  pole masters against F24 and F28. It tests the summed recoil endpoint at
  symbolic epsilon; no endpoint distribution may be discarded without
  that check.
- `s05_factorize.wls` applies the counted real symmetry weight and Eq. 46.
  The initial subtraction uses q -> g and gamma* g -> qbar q. The final
  subtraction uses gamma* q -> g q and g -> qbar. Each occurs once for
  this fixed-flavour channel. Both collinear residues must cancel exactly.
  The paper's projectors are derived from the tensor decomposition before
  writing finite symbolic F1hat and F2hat.

The kinematics and dimensional conventions are the paper's: Q2=-q.q,
s=(p+q)^2, t=(q-k1)^2, w=(k2+k3)^2, a=(p-k2)^2, b=(k1+k2)^2,
D=4-2 epsilon. The physical region and positive auxiliary square root
are saved with the result. `mu2` is the common squared MSbar scale.

Run Wolfram stages directly with Engine 15. Results are stored in the
matching sNN_result directories. Checkpoint reuse requires unchanged
sources and inputs; regenerate dependent results after a physics change.
The inline process monitor stops the process group above 6 GiB RSS or
below 2 GiB available system RAM and limits address space to 9 GiB.
The live execution record is `../progress.md`.

Stage 1 selects coupling powers after FeynCalc DotSimplify extracts scalars
from noncommutative products. The initial attempt stopped before saving
amplitudes because that extraction was missing. The corrected run generated
eight QCD real diagrams and two diagrams for each Born process. All later
stages use only these corrected outputs.

Every stage-4 contraction is a two-entry `{pole, finite}` vector, including
exact zeros. This shape is gated in stages 4 and 5. The first angular run
used scalar zero for empty sectors; its real integration outputs and all
stage-5 outputs were discarded before regeneration. Master integrals,
geometry, amplitudes and partial fractions are independent of that storage
correction and remain valid.

## Accepted result and use

The completed symbolic result is `s05_result/Fhats.wl`; `Fhats.txt` in the
same directory is its plain-text form. It contains `F1hat` and `F2hat` in
its `Fhats` association, including alphaS squared and eq2. Nc remains
symbolic. The current tensor and phase-space normalization follow Eqs. 19
and 38, including 1/(2 pi)^4. The program counted the identical-spectator
weight as 0.5; it is applied once in stage 5.

```wolfram
result = Get["s05_result/Fhats.wl"];
f1 = result["Fhats"]["F1hat"];
f2 = result["Fhats"]["F2hat"];
```

For evaluation, replace `rho` by `Sqrt[result["rho_squared"]]` before
substituting the physical parameters. The kinematic replacement rules for
xhat, zhat, Q2 and qT2 are stored as `hat_variable_rules`.

All Born and real photon Ward identities, identical-spectator exchange,
interference reconstruction checks, angular master checks, the recoil
endpoint at symbolic epsilon and both collinear pole cancellations passed.
The saved delta and plus coefficients are zero for both hats.

Accepted artifacts are `s01_result/manifest.wl` and its three amplitude
files; `s02_result/real.wl`, `born_qg.wl`, `born_gq.wl`, and `kinematics.wl`;
`s03_result/real.wl`; `s04_result/real.wl`, `geometry.wl`, and
`endpoint_residues.wl`; and `s05_result/Fhats.wl`, `Fhats.txt`,
`counterterms.wl`, `projectors.wl`, and `pole_residues.wl`.
The numbered directories retain the interference and master checkpoints.
The corresponding `sNN_result.log` and `sNN_resources.json` record the
accepted executions. `s05_failed_representation.log` retains the rejected
storage-format run for provenance; it is not an accepted result or input.

Accepted F-hat SHA256:
`ce6cada31c35bb582fc4f309538bf9058781164d489861d0b889ba4ddcf32edd`.

The largest monitored production process group used 506.6 MiB RSS.
No OOM occurred. The corrected accepted stages ran serially with bounded
memory and independent interference checkpoints; no speedup from parallel
Wolfram kernels is claimed. The two independent reference checks ran
concurrently with separate result directories and 3 GiB address-space caps.

## Independent checks

`madgraph_check/madgraph_minus_local.md` records 12/12 successful
contraction comparisons at six spacelike photon points. The maximum
relative difference is 1.4580247060443812e-15; all six
photon Ward checks pass, with maximum normalized squared residual
1.3788630105079316e-32. The generated normalization and
FeynArts spectator count agree. The generated standalone sources, explicit
current driver, raw `s03_currents.log`, and `s03_result.json` are included.

`bigTMD_check/bigtmd_minus_local.md` records 36/36 successful comparisons
with the complete ordinary channel-5 coefficient density at 18 points.
The maximum relative difference is
6.2624673039599742e-13. The published
plus coefficients are proved to vanish at the endpoint before their
finite contributions are included. The pinned public driver's NLO loop
omits channel 5 entirely; this direct coefficient comparison does not claim
the driver includes Hqqbar. The regular-only mismatch is retained in the
report. Both checks preserve the accepted production hash above.

No production stages or requested channel checks remain deferred.

## Current six-input numerical consumer contract

The user selected this channel for the numerical generation in ../numerics/.
That consumer imports the accepted terminal payload byte-for-byte and records its
identity in numerics/s01_result. Its S03 recovers this payload's own charge,
flavor, distribution and partonic-variable contracts; S05 exports these
coefficients and checks direct Wolfram values. The numerical consumer applies the
S04 fragmentation Jacobian to these partonic hats once and retains the source
normalization. It does not alter any symbolic production coefficient.
Current charge moments, positive-rho definitions and bounded-plus conventions
must come from this channel's own payload. S07/S10 gate native evaluation before
S09 convolves with the unchanged MRST02 and KKP/Kretzer inputs. The numerical
README documents stage interfaces; only ../progress.md records execution status.

Accepted current numerical coefficient interface: ../numerics/s03_cache/Hqqbar_v2_consumer_contract, SHA256 005dc2671f979cfd0dff16e8373c25077363a70f4b59623002c1cea294ffa61f; ../numerics/s05_cache/Hqqbar_v2_result, SHA256 c1815d967a10c7123e45bc9877db77f6f06616791ad0eec7bc369b2af2414659. The current ../numerics/s07_result (SHA256 15fdc7e47c5494bdea7d7750089ec7f942a2920367ae64a9b5cd115fb16620e8) binds 2 paired programs for this channel and their exact operation-table/source identities. All associated Wolfram/native checks passed. These numerical interface identities supersede earlier numerical-export references for the active six-input generation; symbolic production identities and comparison caveats above remain unchanged. Convolution uses the established partonic coefficient and charge conventions; final integrated-bin acceptance is recorded separately in the numerical ledger.

Accepted numerical consumer output: ../numerics/s09_result, SHA256 66c0df6a0a8001e4603d939602bb8c7aa378fe77c916437f1b9115b8363b36ad, and ../numerics/s11_result, SHA256 9f7ccd91726edc6735f905ae36dc5c3b4076c97290613866e340dd5a9240fd62. All 17 current full-channel bins pass the original numerical gates; the S09 component arrays retain this channel's signed LO/NLO contributions with complete within-bin covariance. Both comparison figures are bound by ../numerics/dsigmapibydpt/s03_result, SHA256 f82e5fd31e63c1b2c5c5a110e9a872b20324c8e64e49202a9f52ba66e4b6cc6e. No symbolic channel payload changed.

## Source-bound six-channel analytical comparison

The separate [analytical report](../bigTMD_comparison/Hqqbar_v2/s04_result.md) compares this channel's unchanged current F hats with pinned BigTMD commit `6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. Both F hats agree in the stated comparison. Channel absent from the NLO loop. The exact-algebra claims are conditional on the declared reconstruction of printed decimal constants and the report's color, charge, scale, branch and distribution conventions.

Input SHA256: `ce6cada31c35bb582fc4f309538bf9058781164d489861d0b889ba4ddcf32edd`. Comparison SHA256: `2edb7f0a9254ef27b01fe66eb34105066eda6579e62def6f1d4a99cd5de79471`. Report SHA256: `c422f11f8449e016a0b5c59ade45fb83f2d903881bcbc216ef80df624a49646d`. The comparison-directory README and receipts bind the source, result, proof-cache and validation identities. No production expression or existing independent-validation caveat is superseded by this comparison.
