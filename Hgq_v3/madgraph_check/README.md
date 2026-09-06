# Hgq_v3 MadGraph check

Reuses the MadGraph process, bridge and parameter cards from
`scripts/Hgq/madgraph_check` (same physical process,
`e- g -> e- u u~ g / z h QED=2 QCD=2`), byte-copied into `upstream_copies/`
with SHA-256 recorded.  MadGraph is NOT regenerated.

- `s01_validate_copied_bridge.py` - loads the copied bridge and reproduces the
  accepted matrix element `6.297541985951792e-11` EXACTLY (relative difference
  0.0), with conservation, masslessness and spacelike-photon checks.
- `s02a_generate_points.py` - three independent massless configurations.
- `s02b_export_local.wls` - Hgq_v3 `Mg`, `Mpp` at those points from `s02_result.m`.
- `s03_compare_madgraph.py` - rebuilds `W` from the two projections, averages the
  lepton plane over four azimuths, compares.

## Result

| point | MadGraph | local | MG/local |
|---|---:|---:|---:|
| tetrahedron | 7.7384538728e-11 | 7.7384538728e-11 | 1.0000000000 |
| asym_1 | 5.8125126261e-10 | 5.8125126261e-10 | 1.0000000000 |
| asym_2 | 5.2569936619e-09 | 5.2569936618e-09 | 1.0000000000 |

**EXACT MATCH**, three independent points, agreement at the 1e-10 level, no
fitted constants.  Hgq_v3's real matrix element is confirmed against MadGraph.

`local = e^4 e_u^2 (L.W)/Q2^2`.  The extra `e^2` relative to Hgq's S18 is needed
because `s02_result.m` carries `eq^2 gs^4` and no `EL`.  The incoming-gluon
average `1/(2(1-eps))/(Nc^2-1) = 1/16` times the leptonic `1/2` reproduces
MadGraph's `IDEN=32`.

### The frame matters

`W` is rebuilt from `Mg` and `Mpp` as
`W = F1(-g+qq/q^2) + (F2/(p.q)) Pt Pt`, verified to return both projections
exactly (`g.W = -3F1 + F2/(2 xhat) = Hg`, `p.W.p = -F1 Q2/(4 xhat^2) +
F2 Q2/(8 xhat^3) = Hpp`).

The azimuthal average MUST be taken in the `p+q` rest frame with `q` along `z`.
`<L>` is symmetric about the rotation axis, so it is built from `g`, `q` and the
frame time direction `n`; the contraction needs `n.W.n`, which two projections
determine ONLY when `n` lies in `span{p,q}`.  In the lab frame `p` and `q` are
not collinear, `n` leaves that span, and the comparison fails by a
point-dependent few percent.  In the collinear frame `p` and `q` have only `t,z`
components, `n` is in their span, and the contraction closes on `F1`, `F2`.

## Related finding

Hgq's check invalidated its original S06 for using a covariant external-gluon
polarisation sum, replaced by the physical axial projector after a Ward
certificate.  Hgq_v3 does NOT share that defect: `s02_real.wls:83-84` uses
`DoPolarizationSums` with explicit reference vectors and `:94-96` gates
reference-vector independence.
