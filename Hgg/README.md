# Hgg channel ledger

This directory contains the incoming-gluon, fragmenting-gluon channel

`gamma*(q) + g(p) -> g(k1) + q(k2) + qbar(k3)`.

The first outgoing momentum `k1` is always the fragmenting gluon. The
quark-antiquark pair is represented by the SMQCD field `F[3,{1}]`. A fresh
Engine 15/FeynArts metadata probe on 2026-08-30 derived its electric charge as
`+2/3`; it is an up-type representative. The older S01/S05 prose calling it
down-type is stale.

The only live status record is `../progress.md`. The physics authority is
`../Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`.

## Bare-tree validation boundary

The independent four-dimensional MadGraph comparison consumes byte-identical
copies of only these accepted pre-angular artifacts:

| Stage | Source SHA-256 | Result SHA-256 | Status |
|---|---|---|---|
| S01 | `9ec55e7e9881f0715289a9d2a2fce45b1c04a024260783a0d7742464d91c358e` | `f9dc6222b793830691c2a82db1d2ce045b2cb92ebd2dacc21948382adf3fa4be` | accepted |
| S06 | `aa6fede493ab224965f09dec28263fda1e94f3b85e51c55ce7331cc242f6e68e` | `dd1ccc91960f3a37b4acc397acc90f91da64340a79dd89132cdf4fcd9f5616e3` | accepted physical-projector result |
| S07 | `4aaedba41d5051218defe4bb927cbcf6a640957860c3578232c6a39db14accc6` | `94bcbf6259f59d67dad3051f60f31041475fcd61d96a9fd1e31b473bd8550197` | accepted physical-projector projection |

S01 contains the eight-diagram real-only representative. The replacement S06
sums the final
quark/antiquark spins and both gluon polarizations/colors, and applies the
incoming-gluon average `1/((D-2)(SUNN^2-1))`. Its accepted tensor path is
`SpinColorAveragedTensors/NLOReal_OAlphaS2/Hgg;q_qbar`. S07 provides exactly
`Pg` and `PPP` at
`ScalarProjections/NLOReal_OAlphaS2/Hgg;q_qbar`.

Raw S08/S10 endpoint objects and S11/S12 factorization objects are not inputs
to a four-dimensional bare-tree check. S13 and `bigTMD_check/` are also not
inputs.

## Downstream flavour-normalization correction

The model-derived S01 representative charge-squared is `4/9`, but the former
Hgg S09/S11/S12 lineage attached `9 * HggFlavorChargeSum`, which assumed a
charge-squared `1/9` representative. That former S09--S13 lineage and its
BigTMD benchmark were invalidated and replaced. This does not alter the
validity of the S01 field identification as an up-flavour representative.
The independent bare-tree numerical comparison is recorded separately below.

The authorized correction regenerates parent S08--S13 sequentially. S08 must
consume corrected S07 and rewrite both source-bound angular caches. S09 and
S11 must independently derive the `F[3]` electric quantum number from the
loaded SMQCD `M$ClassesDescription`, form the physical weight as
`HggFlavorChargeSum / RepresentativeChargeSquared`, and record the derived
charge and normalization identity. S10 must consume S09's weight metadata;
S12 must require the independently derived S09/S11 charge squares and weights
to agree before rebuilding all Laurent caches and proving every pole field is
exactly zero; S13 must consume only that corrected finite S12 result. Old
S08--S13 results and mathematical caches are invalid and must not be reused.
During the parent S08--S13 task, the old-S13-dependent `bigTMD_check` outputs
remained quarantined. Their later separately authorized regeneration is
recorded below.

Regenerated S08-v1 is accepted. It consumed corrected S07 result SHA-256
`94bcbf6259f59d67dad3051f60f31041475fcd61d96a9fd1e31b473bd8550197`
and independently passed all 20 saved-result/cache gates, including exact Pg
and PPP cache-expression agreement. Exact S08 identities are source
`5f46b314055c00afb513d615ac5ec6636644fced52eedd9f72bedb4281e21e56`,
production log
`52ff37f1ca460835ec493a98b1aa3f3f7e0d738ee5687935a3cd5b19b624b141`,
result `450cea0482bd9cbfcf7c62bae2256b318d0e69d2de26aa3adbf386bedda8ced4`,
Pg cache `fb4189a1b35f06aeaa90fb9ca1558fc6845ec078cfff34983a95ed3546d7fa65`,
and PPP cache
`7dc9eb1b373b59d362f62192b5f0f12fb0c219c67e6f074164b38017bddb45ec`.
Its tool-recomputed case-2 master count is 86. S09-v2 must bind to this exact
S08 result and independently derive its representative charge normalization
from SMQCD before endpoint expansion.

Regenerated S09-v2 is accepted. Its fresh-process validation rederived SMQCD
charges `2/3` for representative `F[3]` and `-1/3` for validation `F[4]`,
verified representative charge-squared `4/9`, and verified applied weight
`(9 HggFlavorChargeSum)/4` through the symbolic normalization identity. The
corrected S08 contains 25 tool-measured master-index pairs; the Hgg-specific
negative-index pairs `{-3,0}`, `{-3,1}`, `{-2,-1}`, and `{-1,-2}` are derived
inside S09 from S08's held Eq. (B19) definition. Both endpoint distributions
were reconstructed exactly from their respective v2 cache in the independent
gate. Exact identities are source
`6f25ff13929e68d6e34c9eb21a16767d86d3c9164b1c971f5f8bba27ccda8ad3`,
production log
`1111aa262c5c17ab93361795c0bbf7f06e0af3b0d55ea004c4be8cba47037400`,
derivation-probe log
`50160123e8498818466fa6eded93f9ca1d57dd4bce708eb4846396cb08c516dd`,
result `440ae3876dd03a2233b7a0c75c428ce6bb934ee5345ddb70b87019152588be96`,
Pg cache `b2eb3a5ab3381d4b16a3374aea304f128b0c8c8480b46007ba246a37c41651b0`,
and PPP cache
`b68d17265861e107db2b7f4fec3f881a42c0dece4fe0743799577abc5aeec225`.
S10-v3 must bind to this exact S09 result, consume its recorded model-derived
weight, and resolve the two symbolic endpoint placeholders into fresh v3
Laurent caches.

Regenerated S10-v3 is accepted. Corrected S09 yields tool-measured remainder
counts 113 for Pg and 141 for PPP, each partitioned into two alpha-2 terms and
the remaining standard terms. The old fixed 164-total/two-alpha-2 terminal
gate was replaced by per-projector data-derived partition completeness; no
mathematical cache logic changed. Independent validation passed all 18 gates,
including current S09/expansion-cache hashes, exact physical alpha-2 nested
ratios, zero stronger-pole orders through the required epsilon order, clean
symbolic actions, and the flavor-normalization identity. Exact identities are
source `87ed1838e0ab5bb04495471f56e55c644d6e3e835069df07f7e20133887d9a90`,
production log
`2d9eba365e9c33b7cf396ced0608975b257e6dec1709d7c9b269d08f622265da`,
result `6b1dd0193b6e3f04a02e230e99002f4602895a06c2b3270d7a00717721d28a16`,
Pg endpoint cache
`f0d50e90b8f3b622070a49acf7d26b7edf72723cb757b3c390af3c5370bc879f`,
and PPP endpoint cache
`0127fc04119da53a637b30bf194c94ca0b1984eafd3eb7ce6e789d363acdbb1c`.
S11-v2 independently derives its SMQCD representative charge normalization
for the collinear counterterms; it does not consume S10's action as a physics
input. S12-v3 is the stage that must require the S09/S11 normalization
metadata to agree before combining S10 and S11.

Regenerated S11-v2 is accepted. Fresh FeynArts validation independently
rederived representative/validation charges `2/3` and `-1/3`, their squares
`4/9` and `1/9`, and the applied counterterm weight
`(9 S11HggFlavorChargeSum)/4`. All 20 gates passed, including the current
authoritative-paper hash, four directly generated Born channels, exact zero
charge-conjugation residuals, all mapping checks, and all four ordinary
symbolic PDF/FF counterterms. Exact identities are source
`d2a0d5e18f0ebb793e92f8de56f1a8814ca10f20c737a8163b9bc68b5f1817a3`,
production log
`dae4d5735b5b2379ca198dbc1199ee9b4e0cabd231655b6639f698b922372e71`,
and result
`2423cf5e06dca94a6cdc9948563c6ef9e09d5fae8a0cf455e75437cac01ab83e`.
S12-v3 must bind to the accepted S10 and S11 results, map S09 and S11 flavor
symbols to one common `HggFlavorChargeSum`, require their independently
derived representative squares and weights to agree, and write only v3
Laurent caches/results.

Regenerated S12-v3 is accepted. Its final inventory is Pg `1 alpha2 + 111
regular` and PPP `1 alpha2 + 139 regular`, totaling 252 independently
source/term-hash-bound part caches, six Laurent aggregates, and two projector
completion markers. The production kernel was safely recycled every four new
terms after a longer batch demonstrated resident-memory accumulation; this
changed no mathematical cache logic. Fresh validation checked all 252 part
payloads, recomputed every aggregate part-hash list and completion-marker
hash, validated the mapped S11 cache and common flavor identity, and found
every Pg/PPP double- and simple-pole field exactly zero. All finite functions
are epsilon/distribution-free while retaining their ordinary integrals,
symbolic tests, and `HggFlavorChargeSum`. Exact identities are source
`cec5855421652541e239278c2c38e636c801d7f9a207e2c86231531b814729a3`,
initial production log
`6072ec3e8c7bf23536352c91ecdd8acef6aa803d0527f0a61473c73ff2d3ed8f`,
resume log
`410e67cb241191f614512532216d9e05d74007c0428951b91ac47ef7bfd62bbc`,
result `b8c5a31b317fc00cff0877f99dcd7a28637da46e0654445b7875455df982ab54`,
mapped-counterterm cache
`f96dcbe2729f3942b2eb85e651c87b04d0985374089bfc82e33af62003341181`,
ordered term-cache manifest
`735a2b97c57bd2dfffc60b277ff6f32ee3c361880f7415b60b20385f7eb186ea`,
and ordered aggregate/marker manifest
`b060f3c40dc6866ee88e66d768eb5f512db610f7a417fa61fb8409a5712ad32c`.
S13-v2 must bind to this exact S12-v3 result and apply only its existing Eq.
(9) final hard-function extraction.

Regenerated S13-v2 is accepted. A fresh validator rebuilt all three Eq. (9)
coefficient fields and both final symbolic actions directly from accepted
S12, then found exact expression equality for `F1Hat` and `F2Hat`. All 18
independent gates passed, including exact algebraic four-dimensional weights,
current S12/paper bindings, epsilon and projector-test removal, matching
`S13ConvolutionTest` functions, retained ordinary integrals, and physical
flavor weight. Exact identities are source
`c2ccab6b17835e30148c507180601f0586434d90836723ddbde3953e212d2331`,
production log
`a38717866ad8b09efbcd91cb4be4a4e70b226cfa19ebf6552c8e78e8611526a3`,
and result
`9977c411c111d58f9e7fb4b768c165e10c0e1bfd92470afd3423f5a75dfb9e8f`.
This completes the authorized parent Hgg S08--S13 regeneration from corrected
S07. The later separately authorized BigTMD regeneration is accepted below.

## BigTMD check

The two-stage comparison in `bigTMD_check/` was regenerated from accepted
S13-v2 result SHA-256
`9977c411c111d58f9e7fb4b768c165e10c0e1bfd92470afd3423f5a75dfb9e8f`.
S01 source SHA-256 is
`41ca589eec8e69121a1509c839aedc336126151354411f0cfdf49a20d6a99a08`;
S02 source SHA-256 is
`a5da8e6b57b2d26b968bdbb365168cd12b2c714188eee97f45f4bb62fef30280`.
The preserved BigTMD checkout remains clean at commit
`6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`.

Independent terminal validation passed all 15 construction, provenance,
difference, summary, report, finiteness, and regular-only gates. The four
endpoint/subtraction coefficients remain exactly zero. For the regular field,
the saved signed `BigTMD - local` differences are
`-7.821163069710413e-06` for F1Hat and
`-6.381900732032689e-06` for F2Hat. The comparison remains diagnostic with
`AllWithinTolerance=False`; no equality was forced.

Exact generated identities are S01 log
`6139bdb6f0784334488ae896811b2773bd20cda50553643867c0815fbb98d6fa`,
local benchmark JSON
`8f7c0b9a7a75c78046d6c31e3cb333353b2f077935054f96146884a18a2569e0`,
BigTMD benchmark JSON
`4afc688c31d3779b6c865577a87a1b710168bd2edff238f6369bfc865712e212`,
difference JSON
`2c163a855e8ccb53fde1a302ad054b9a065a7d246443a5cf943d46f3c25fa087`,
and Markdown report
`03cf16f794973be6e93d3c3a9248f119864232858510c093a67160715c9ac421`.
Detailed contracts and consumer instructions are in
`bigTMD_check/README.md`.

## MadGraph check contract

The isolated workflow lives in `madgraph_check/` and compares the photon-only
process

`e- g -> e- g u u~`.

Z and Higgs exchange are excluded. The local hadronic momentum order is
`g(k1),u(k2),ubar(k3)`. Generated PDG order, its map to this local order, the
diagram count, the final-state identity divisor, and MadGraph `IDEN` must all
be measured by the new workflow. The current SMQCD charge must be derived
from copied S01/model metadata; no charge, count, or normalization literal may
be copied from another channel.

The local reconstruction uses copied S06/S07 before angular integration. It
adds the spin-averaged electron tensor, electron electromagnetic vertex, and
photon propagator exactly once, using the same couplings as the generated
parameter card. The fixed-orientation S07 gate must pass before any angular or
cut-bin stage is allowed to run.

The implemented task programs are:

1. `s01_prepare_inputs.py`
2. `s02_generate_hgg_standalone.mg5`
3. `s03_madgraph_c_bridge.f90`
4. `s04_direct_madgraph_reference.f90`
5. `s05_validate_madgraph_bridge.py`
6. `s06_inspect_copied_s07_schema.wl`
7. `s07_validate_local_matrix_element.wl`
8. `s08_validate_azimuthal_average.py`
9. `s09_build_four_dimensional_evaluator.wl`
10. `s10_generate_cut_bin_madgraph.py`
11. `s11_evaluate_local_cut_bin.wl`
12. `s12_integrate_common_cut_bin.py`

S01--S05 passed: the compiled bridge and direct generated MadGraph routine
agree exactly at `7.443988980863332e-10`, with eight diagrams, generated
`IDEN=32`, measured PDG order `{11,21,11,21,2,-2}`, derived F3 charge `2/3`,
and unit final-state identity divisor. S06 passed the copied Hgg schema
inspection.

After the physical-projector correction, refreshed S01/S05/S06 passed and S07
accepted the fixed-orientation comparison. The copied S06-v2 tensor gives
`7.443988980863335e-10` while MadGraph gives `7.443988980863332e-10`, with
relative difference `4.167022956439278e-16`. Copied S07-v2 Pg and PPP also
match fresh contractions of copied S06-v2. The accepted JSON SHA-256 is
`65eaaea96974c808c0a3008e8da97a708b26dd22bbeb4026f6a9467316165871`;
all eight recorded checks are `True`.

MadGraph-check S08--S12 subsequently completed and are accepted. The terminal
common-bin result is `madgraph_check/s12_integrated_comparison.json`, SHA-256
`07c4e4b1b64b42dc36206deb95ea755044fccfe6bb04d7b95c01bb23214db51f`.
It reports MadGraph `1.81604882301399919e-3 pb`, local Hgg projection
`1.81604882301399768e-3 pb`, integrated relative difference
`9.12010551263776570e-16`, and all seven terminal checks true. Detailed
S08--S12 source/result identities and validation evidence are recorded in
`madgraph_check/README.md`.

The check reuses the pinned MG5_aMC 3.7.0 executable and `six.py` under
`../Hqqbar/madgraph_check/` read-only. It neither installs another MadGraph
copy nor modifies any parent Hgg artifact.

## Accepted S06 physical-polarization correction

The fixed-orientation MadGraph gate localized the mismatch to the S06 external
gluon polarization boundary.  Before any replacement artifact is accepted,
`s06_spin_color_sum_average_hgg.wl` must use physical axial polarization sums
for the incoming gluon `p` and observed final gluon `k1`, with the massless
non-collinear spectator momentum `k2` as their common reference.  The program
must derive and gate both reference norms, both momentum-reference products,
and the incoming physical-polarization count.  Its spin/color averaging,
tensor schema, and S07 consumer contract otherwise remain unchanged.

S06-v2 passed its no-write preflight and fresh production run.  Its exact
reference specifications are `{{p,k2},{k1,k2}}`; Engine 15 derived nonzero
products `{-u2/2,s12/2}`, zero reference norms, and the unchanged incoming
average.  The result and both source-bound caches passed exact reload checks.
S07 and every later dependent artifact remain invalid until freshly regenerated,
and the fixed-orientation MadGraph comparison must pass without an empirical
normalization factor.

S07-v2 keeps the existing `Pg` and `PPP` contraction definitions unchanged.
Before reading the tensor it must require S06-v2 provenance, the physical axial
polarization convention, two passing reference checks, zero reference norms,
and nonzero momentum-reference products.  Its caches remain bound to the exact
S06 result hash.

Fresh S07-v2 production completed both projections and all recorded checks.
Its Pg/PPP caches are bound to the accepted S06-v2 result hash; a bounded
independent reload returned all metadata and provenance gates `True`. The
fixed-orientation MadGraph comparison subsequently passed, so dependent S08+
regeneration is authorized.
