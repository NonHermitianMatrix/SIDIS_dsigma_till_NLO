# Hqqprime at order alpha_s squared

The process is gamma*(q) + q(p) -> qprime(k1) + q(k2) + qbarprime(k3),
with distinct massless quark flavours and k1 observed. The paper is
Wang et al., arXiv:1903.01529, Table I, Table II and Eqs. 19, 38, 46,
52 and 53. There is no virtual contribution for this channel.

The independent charges `eq` and `eqp` label the incoming and observed
quark flavours. Their three monomials are retained throughout:
`eq^2`, `eq eqp`, and `eqp^2`. The implementation uses up and down fields
as distinct flavour representatives, with symbolic photon couplings.
The original model charges are read from FeynArts rather than copied from
another channel. No old Hqqprime code or result is an input.

Five production stages:

- `s01_amplitudes.wls`: FeynArts generates the real process, gamma* q -> g q,
  and gamma* g -> qprime qbarprime. ModelEdit replaces only the two
  photon-quark couplings by symbolic charges. Coupling-order and charge
  reconstruction gates precede saving. Spectator multiplicities are counted.
- `s02_square.wls`: compute the D-dimensional `g`, `pp`, and `qq` current
  contractions with spin/color averages and the electromagnetic coupling
  removed. Save each interference and require the full photon Ward identity
  and the three-term charge polynomial.
- `s03_partial_fractions.wls`: apply Appendix D and require exact
  reconstruction of every interference.
- `s04_angular_integrals.wls`: apply Appendix B, check F24/F28 and vector
  shapes, and test the summed recoil endpoint at symbolic epsilon.
- `s05_factorize.wls`: use Eq. 46. The initial term contains q -> g and
  the Born tensor proportional to eqp^2. The final term contains g -> qprime
  and the Born tensor proportional to eq^2. Each occurs once. Require
  symbolic pole cancellation, derive the F-hat projectors, and save both
  complete hats and their three separate charge coefficients.

All amplitudes, interferences, angular integrals and subtractions are
recalculated here, using the general code written in this conversation.
The stage-4 zero-vector correction is included from the start.

The kinematics are Q2=-q.q, s=(p+q)^2, t=(q-k1)^2, w=(k2+k3)^2,
a=(p-k2)^2, b=(k1+k2)^2, D=4-2 epsilon. Nc remains symbolic, and mu2
is the common squared MSbar scale. The positive auxiliary square root
and physical support are saved with the result.

Run the five sNN scripts directly with Wolfram Engine 15. Results and
checkpoints are in the matching sNN_result directories. Reuse requires
unchanged sources and inputs; remove dependent results after a physics
change. The executed inline monitor limits address space to 9 GiB and
stops a process group above 6 GiB RSS or below 2 GiB available system RAM.
The sole live progress record is `../progress.md`.

Independent MadGraph and BigTMD checks follow after the production result
has been saved and hashed. No reference coefficient enters production.

Accepted production artifacts

All five stages passed their symbolic gates. The final result is
`s05_result/Fhats.wl`, SHA256 `4aee27e2d6b9decefce735ecb94536a71f4be0f09352cf5a538fd3b27d504cf6`.
It contains `Fhats` (F1hat and F2hat), `contractions` (g and pp),
`charge_components` and `contraction_charge_components`, keyed by
`eq2`, `eq_eqp`, `eqp2`. These keys denote coefficients; `eq` and `eqp`
remain independent symbols in the complete expressions.

Exact input and result files are in `s01_result` through `s05_result`;
logs and monitor receipts are `sNN_result.log` and `sNN_resources.json`.
Both MSbar pole cancellations and charge reconstruction passed.
The stage-5 association export was corrected before this result was saved;
failed stage-5 artifacts were deleted before its successful rerun.
Peak monitored production RSS was 523.4 MiB.

Independent validation

- `madgraph_check/madgraph_minus_local.md`: 48/48 contractions and
  24/24 Ward checks pass across four independent charge assignments.
- `bigTMD_check/bigtmd_minus_local.md`: 108/108 complete-coefficient F-hat
  comparisons pass, resolving all three charge terms independently.
  The regular-only driver differs because it skips channel-6 plus terms;
  both representations remain in the report.

The production hash was unchanged throughout both checks. All five main
stages and both check sequences are accepted. No additional production
stage was introduced. Peak sampled job RSS across the recorded monitors
was 523.4 MiB; no memory guard or OOM occurred. Numeric substitutions
are confined to the checks. Production and reference caches retain
reproduction and checkpoint value; no disposable test cache was created.
