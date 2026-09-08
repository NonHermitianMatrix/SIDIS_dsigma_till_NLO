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
