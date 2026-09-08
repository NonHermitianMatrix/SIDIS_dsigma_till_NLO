# Hgq_v3 terminal artifact consumer ledger

This ledger was recovered for the user-authorized six-channel numerical import because the channel had no README. It records only established provenance from `../progress.md` until terminal metadata is inspected. The physics authority is `../Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`. Live state remains exclusively in `../progress.md`.

## Existing recorded evidence

- The user identifies this directory as the incoming-gluon, fragmenting-quark channel.
- The 2026-09-05 15:45 progress entry identifies `s09_extract_fhats.wls` and eight outputs under `s09_fhats/`. The terminal component definitions, perturbative-order coverage, scale/coupling and distribution conventions must be recovered from that producer and the stored artifacts before a numerical consumer is written. No accepted SHA-256 ledger was previously supplied.
- The 2026-09-05 21:40 BigTMD entry replaces an earlier comparison using wrong conventions. The corrected comparison still reports `Overall tested agreement: False`; no universal fitted normalization is accepted. The earlier all-component validity claim was withdrawn.
- The 2026-09-05 23:05 entry records a successful MadGraph comparison at three tree-real points after correction of the comparison averaging frame. This validates the tree-real matrix element only. It does not validate integrated real, virtual, MS-bar, endpoint or final F-hat normalization.
- Earlier progress entries identify an unresolved finite delta MS-bar residue. The available later records do not document an accepted correction closing it. This is an unresolved input convention/validation issue, not permission for a downstream consumer to remove terms empirically.

## Numerical import contract

The new `../numerics/s01_` stage may freeze exact terminal output bytes with source/copy hashes and preserve the terminal producer as provenance. This is a transport/integrity operation and confers no new physics acceptance. Before convolution, a tool must inventory symbols, distribution definitions, order coverage and normalization, and every physically consequential ambiguity must be resolved explicitly. A benchmark discrepancy alone does not decide which result is responsible. Known-invalid upstream expressions must never be silently used or repaired by an empirical downstream factor.
