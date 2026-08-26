# Hqg channel ledger

This directory implements the large-transverse-momentum SIDIS Hqg channel.
The authoritative physics reference is
`../Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`.
This file records durable conventions, artifact identities, stage contracts,
and downstream boundaries. Live execution state is recorded only in
`../progress.md`.

## Channel and momentum convention

- LO/virtual subprocess: `gamma*(q) + q(p) -> g(k1) + q(k2)`.
- Real subprocess: `gamma*(q) + q(p) -> g(k1) + q(k2) + g(k3)`.
- The fragmenting parton is the first outgoing gluon, `g(k1)`.
- The incoming parton is a quark. S06 consumes the exact incoming spin/color
  average derived and recorded by accepted S01; it does not transcribe the
  factor independently.
- Photon tensor indices remain open through S06 and are contracted with the
  separate Pg and PPP projectors in S07.
- BigTMD routing is channel 3, charge case A, with the physical luminosity
  `Sum_q e_q^2 f_q D_g` deferred beyond the charge-stripped partonic hard
  kernel.

## Electric-charge convention and correction

The representative FeynArts field used by Hqg is `F[3,{1}]`. A fresh
Wolfram Engine 15/FeynCalc/FeynArts query of the loaded SMQCD
`M$ClassesDescription` table produced

```text
F3 -> 2 Charge/3
F4 -> -Charge/3
```

and therefore produced the exact representative coefficient `2/3` and its
exact reciprocal amplitude strip `3/2`. Corrected S01 derives these values
from the loaded model; neither value is used as an unproved input literal.
It stores the raw model quantum numbers, derived coefficients, representative
field/class, and reciprocal proof in `ElectricChargeNormalization`.

The earlier Hqg lineage incorrectly labeled `F[3,{1}]` as down-type, stored
reference charge `-1/3`, and applied strip `-3`. That lineage is invalidated
at its S01 origin. All old mathematical S01 and S04-S13 results/caches are
invalid normalization inputs and must not be consumed. The S02/S03 diagram
renderings are topology-only and are not changed by amplitude normalization.

Any stage that consumes `ElectricChargeNormalization` must require all of the
following from its input rather than hardcoding a charge:

- the reference charge equals the coefficient selected by the saved
  FeynArts representative class;
- the reference charge times `AmplitudeStripFactor` is exactly one;
- the physical BigTMD luminosity remains deferred;
- the complete normalization association is preserved in every cache and
  result provenance record.

When a stage directly regenerates an unstripped Born amplitude, its squared
normalization factor must be derived as `AmplitudeStripFactor^2` and checked
against the saved model charge. No literal factor `9` is valid for the
corrected F3 representative.

## External-gluon state convention

The accepted real-emission state sum is the S06 physical-state correction:

- both real final gluons use D-dimensional axial projectors with reference
  momentum `p`;
- the S05-ledger-derived real diagrams are retained one-for-one as coherent
  resumable rows (the accepted S05 result currently derives eight);
- rows are summed before the final color simplification and incoming-quark
  average;
- LO and virtual one-gluon sums retain the separately validated
  Ward-protected covariant treatment.

The older uncompensated four-polarization real-gluon prescription is invalid
and must never be restored. S07 contracts only the corrected S06 tensor with
Pg and PPP.

## Corrected source contracts

The corrected source identities established before regeneration are:

| Stage | Source contract | SHA-256 |
|---|---|---|
| S01 | `HqgS01-v3`; generated ledgers/model normalization plus inert `HqgS01Kinematics-v2` serialize/reload/install contract | `8e14ab5c5e5c8ea812793cb34b1d48e9edf1e4a133a3200713cf44d4b20800f0` |
| S04 | `HqgS04-v3`; exact repaired-S01 identity gate, generated-ledger counts, and computed QCD virtual-renormalization checks | `ad6c5fd46152805538d1234c787feae212a9f5aa217853d7e81b4818bb567e54` |
| S05 | `HqgS05-v4`; exact repaired-S01/S04 lineage, inert kinematic-v2 reinstall audit, deterministic FeynCalc `FCGV`, coherent bilinears, and content-bound full-virtual TID cache v4 | `750707b417051fa9380772702fc7737f1f659fa160df285186ee82562b8d0e74` |
| S06 | `HqgS06-v4`; exact S05 lineage, tool-derived state/kinematics/counts, physical-axial coherent real rows, content-bound layered caches, computed gates, and atomic spin/color-tensor result | `d24ce8bf36d7e64037fbefa7c40cc299a1cff5e639339f03e6ebde17a3e2c8a6` |
| S07 | `HqgS07-v5`; exact S06-v4 lineage, inherited state/kinematics, Eq. (7) Pg/PPP projections, full content-bound atomic caches/result, and computed gates | `baf695aad89fb8344772bec6c8f6f49c28c18fd842404949fdf74f98d1316e09` |
| S08 | `HqgS08-v5`; exact S07-v5 lineage, inherited kinematics, corrected Eq. (38), tool-derived Appendix-D/frame/xi maps, parsed BigTMD routing, content-bound atomic caches/result, and computed gates | `28a2a552c09470844c5418c7261e88c7abcc80bc3f9388f348cb8e6e4dbf8803` |
| S09 | accepted `HqgS09-v5`; exact S08-v5 binding, tool-derived B19/B27/B30 certificates, mapped-first fused symbolic expansion, exact atomic cache reload plus finalized file SHA-256, compact result, and cache-bypassing fresh validation | `f7a88a6863d90f76972b45f8c0281001d3f16e8f5da220b6c3ae977234d994d0` |
| S10 | current evaluator-v10/final-resume production source; exact submit entry point and Pg recovery checkpoint retained; no S10 result or consumer input is accepted yet | `3a09a5627320f20db8f58deef4a9729946459fcda17030273089495649840926` |
| S11 | source removed by the user-authorized 2026-08-26 cleanup; no accepted result | — |
| S12 | sources removed by the user-authorized 2026-08-26 cleanup; no accepted result | — |
| S13 | source removed by the user-authorized 2026-08-26 cleanup; no accepted result | — |

Engine 15 held parsing reached valid EOF for all changed S01 and S04-S12
sources. For the exact S01 source above, an artifact-free Engine 15 semantic
preflight regenerated every ordinary/counterterm diagram and photon-coupling
ledger, derived the F3/F4 charge map and incoming fermion/fundamental-color
state normalization from the loaded model and FeynCalc probes, and solved the
defining two-body invariant system. All 15 labeled internal gates passed with
terminal marker `HQG_S01_DERIVATION_PREFLIGHT_OK`; no count, charge, state
average, scalar product, or Mandelstam relation is accepted from a copied
current-channel literal.

For the exact S05 source above, Engine 15 held parsing succeeded and an
artifact-free semantic preflight regenerated every full external-state
collection, matched the repaired S01/S04 identities, applied the
model-derived amplitude strip, canonicalized every `FCGV` head, loaded only
the inert `HqgS01Kinematics-v2` records, and directly reinstalled their mass
shells and cross scalar products. All 22 labeled prefix gates passed; the
fresh installation residuals were exact zeros and the validator printed
`HQG_S05_KINV2_PREFIX_PREFLIGHT_OK` without `Set::write`. The preflight
stopped before virtual TID/cache inspection and wrote no artifact. The
subsequent monitored production and independent validation are accepted
below.

The dormant BigTMD handoff now derives its direct-Born normalization from the
same S13 metadata instead of an integer literal. Its exporter source SHA-256
is `72a02f6bb05b4068123d33cb71e2fe61d7229b1435824aad69a35cca1b31326d`;
its Python consumer SHA-256 is
`fd35811331ec21362bed74f89d950e7f5746c3d311b6d260d8f00ddd34c9203a`.
Both parse, but no corrected S13 or BigTMD output exists or is accepted.

### Revoked superseded production artifacts

The S01/S04 identities below were accepted before a clean-process inspection
showed that S01 wrote its live scalar-product rules after installing them.
Their serialized left sides consequently evaluated into values, so
`SolvedScalarProducts` became tautological `value -> value` rules and parts
of `DefiningEquations` also collapsed. The production amplitudes used the
pre-installation rules, but the durable kinematic handoff and its independent
serialization validation are invalid. Acceptance of S01 and dependent S04
is revoked; none of the identities in this section may be consumed until the
corrected S01/S04 artifacts are regenerated and revalidated.

The repaired S01 source now stores mass shells and cross scalar products as
inert momentum/value associations, retains defining equations and solved
rules under `HoldComplete`, verifies direct `SPD` installation residuals, and
performs an InputForm serialize/reload equality gate while live scalar-product
values are active. A clean Engine 15 preflight independently cleared all
scalar products, reloaded the serialized ledger, reinstalled it from the
records alone, obtained four mass-shell and six cross-product zero residuals,
retained held `Pair` evidence, printed
`HQG_S01_KINEMATIC_V2_ROUNDTRIP_PREFLIGHT_OK`, and wrote no artifact.

The revoked S01-v3 identities were:

- source: `s01_calculate_hqg_lo_nlo.wl`, 30,254 bytes, SHA-256
  `73f7e59c2c75b97aa1e3750bbddd23b7b1e2a64a3df4bfd1ccc103ae0c3d5183`;
- result: `s01_result`, 5,217,484 bytes, SHA-256
  `d44ffeb428b075489645c98de27516a70caf05bbdeb18104819a36750d359ff8`;
- production log: `s01_production.log`, 7,895 bytes, SHA-256
  `d5bfe639e078dedc27c22682cbb8722b5e172a36d0293603f5938954ebcd0a19`;
- independent validation log: `s01_independent_validation.log`, 9,472
  bytes, SHA-256
  `1ec5bb814607b93d8afd6e7f3d9ac683d4dd822ea832475b8f7978fd18489148`;
- production: Engine 15 exited zero after all generated count/coupling,
  model charge/state, unique exact kinematics, 23 TID, 23 UV, 23 IR,
  UV/IR split, exactness, and result-write gates passed;
- independent validation: a fresh Engine/FeynArts/FeynCalc/FeynHelpers
  process regenerated all ordinary and QCD-counterterm diagrams and converted
  amplitudes, rederived the charge/state/kinematics records, and recomputed
  every TID, UV, IR, and split expression. FeynCalc's documented
  `FCGetDummyIndices` and equal explicit `FCCanonicalizeDummyIndices`
  namespaces produced all-`True` vectors for 2 LO, 8 real, 23 virtual, and
  12 counterterm amplitudes and for all 23 TID, UV, and IR expressions. All
  saved sums, provenance, checks, coupling inventories, exactness, and
  regulator-separation gates passed with terminal marker
`HQG_S01_V3_INDEPENDENT_VALIDATION_OK`.

For the corrected S04 source above, an artifact-free Engine 15 semantic
preflight loaded the exact accepted S01 result, derived every collection
length from its generated ledgers, projected the counterterm collection,
reconstructed all bare/UV/IR/combined sums and the contribution ledger, and
reported all 23 computed S04 gates `True` with terminal marker
`HQG_S04_REPAIRED_LINEAGE_PREFLIGHT_OK`. Its subsequently regenerated result
and independent validation are accepted in the section below.

No later stage may consume this revoked S01 result identity.

The consequently revoked S04-v3 identities were:

- source: `s04_renormalize_hqg_virtual.wl`, 14,949 bytes, SHA-256
  `ea14faef82b5c1e648b3dd8c70099b14e159f5f29c68042ca998fd17a3f14955`;
- result: `s04_result`, 6,872,398 bytes, SHA-256
  `4c59a8c6d88765e2a22f48da744958176c0276c8e623d62f1e55b61040b23702`;
- production log: `s04_production.log`, 2,127 bytes, SHA-256
  `8b1c076f0ae6bf6d09118a5b1b4deb1585f25ade49136741ca16a0100ecc8d10`;
- independent validation log: `s04_independent_validation.log`, 2,376
  bytes, SHA-256
  `6fcf205eb93fc07d47fea0dda3bda740f4ebbeb83b156bcef00c9e6e08016428`;
- production and independent validation bound both accepted S01 hashes,
  derived every collection size from S01's generated ledgers, reproduced the
  QCD-projected counterterms, contribution ledger, tensor/UV/IR sums,
  charge/BigTMD/PDF handoff, and exact symbolic content, and passed all 23
  computed checks with terminal marker
  `HQG_S04_V3_INDEPENDENT_VALIDATION_OK`.

The revoked identities above remain forbidden. The replacement S01/S04
lineage accepted below is the only permitted handoff to S05.

### Accepted regenerated production artifacts

Repaired S01-v3 is accepted on the inert kinematic-v2 lineage:

- source: `s01_calculate_hqg_lo_nlo.wl`, 34,917 bytes, SHA-256
  `8e14ab5c5e5c8ea812793cb34b1d48e9edf1e4a133a3200713cf44d4b20800f0`;
- result: `s01_result`, 5,219,152 bytes, SHA-256
  `8e4e067f23911d3600c5975f87562abb5dd4c6679c48b01514b4e620a1449198`;
- production log: `s01_production.log`, 7,895 bytes, SHA-256
  `e19ff19862c96ff8cb7381f1ec3e5a1591501cb32f4654705fdcfbb964792125`;
- complete validation log: `s01_independent_validation.log`, 9,291 bytes,
  SHA-256
  `22b35afba547109bf1aec44ac25b0b4eeae1a8efa1fb7c4520baf98c46d79cdd`;
- the written result contains `HqgS01Kinematics-v2`, four inert mass-shell
  records, six inert cross-scalar-product records, held defining equations
  and held solved `Pair -> value` evidence, and no old evaluable
  `DefiningEquations` or `SolvedScalarProducts` keys;
- fresh-process validation reproduced all generated/converted amplitudes,
  all 23 TID, UV, and IR expressions, the split result, sums, counts,
  model-derived charge/state records, and all computed checks. A clean reload
  then serialized and reinstalled the saved kinematics with all-zero
  residuals. The validator printed
  `HQG_S01_KINV2_COMPLETE_VALIDATION_OK` and exited zero without
  `Set::write`.

S04 and later consumers must require exactly these repaired S01 source/result
identities and the explicit kinematic serialization check before use.

Repaired S04-v3 is accepted on that exact repaired-S01 lineage:

- source: `s04_renormalize_hqg_virtual.wl`, 14,949 bytes, SHA-256
  `ad6c5fd46152805538d1234c787feae212a9f5aa217853d7e81b4818bb567e54`;
- result: `s04_result`, 6,872,397 bytes, SHA-256
  `2bbeeee841e5e47bfd2391a1588b2184a16865d334bf78716b1b0573d499bf92`;
- production log: `s04_production.log`, 2,127 bytes, SHA-256
  `882225d142f86cb50a7999848a38a5c27db190a2b889b30068564703dbd396c7`;
- independent-validation log: `s04_independent_validation.log`, 2,921
  bytes, SHA-256
  `9b2f371368f2b883f2f3107fd77a074f6c5eb83aa51e8d71060b9ebebcac668a`;
- production passed the exact repaired-S01 source/result identity gates,
  derived all diagram counts from the S01 generation ledgers, reconstructed
  the QCD-projected counterterms and all same-process tensor/pole sums, wrote
  the result, printed `S04_SUCCESS`, and exited zero;
- fresh-process validation explicitly required the inert S01 kinematic-v2
  serialization gate and independently reconstructed every saved S04 field.
  All 16 result-level gates and all 23 recomputed S04 checks were `True`; the
  validator printed
  `HQG_S04_REPAIRED_LINEAGE_INDEPENDENT_VALIDATION_OK` and exited zero.

S05 and later consumers must require exactly these repaired S04 source/result
identities in addition to the repaired S01 identities above.

Repaired S05-v4 is accepted on those exact repaired-S01/S04 lineages:

- source: `s05_form_hqg_bilinears.wl`, 41,732 bytes, SHA-256
  `750707b417051fa9380772702fc7737f1f659fa160df285186ee82562b8d0e74`;
- result: `s05_result`, 7,423,783 bytes, SHA-256
  `ab5d6e6ff2513c19ecdbe4f95c72de79bbf1d1b3724803db22fc5526c5e21878`;
- full-virtual TID cache: `s05_virtual_full_tid_cache`, 1,327,002 bytes,
  SHA-256
  `f458db5dfa73aa7ce0bd6b546f927ff18f9bb1edb27d41d1f82548ecf77f9893`;
- production log: `s05_production.log`, 4,614 bytes, SHA-256
  `0029df256bbe5d1d2a1dbb0cd74d00df20007967f0910521aaebdbb8f04f734c`;
- independent-validation log: `s05_independent_validation.log`, 8,458
  bytes, SHA-256
  `bea71086022040c4f1270b000a24f45aee2069aa10db242fb50f5df1f44cc86a`;
- fresh production regenerated all full external-state amplitudes, installed
  the inert kinematic records with zero residuals, computed all full-virtual
  TIDs without cache reuse, formed the coherent open-index amplitudes and
  bilinears, passed all 38 computed checks, printed `S05_SUCCESS`, and exited
  zero;
- the fresh-process validator re-executed the source through its no-write
  boundary, required valid cache reuse, independently recomputed all 23 TID
  expressions, and matched every cache entry. It then matched every open
  amplitude, real block, conjugate block, and LO/real/virtual bilinear,
  using FeynCalc-measured common dummy-index namespaces only where raw
  equality was session-name dependent. All 18 aggregate gates were `True`;
  it printed `HQG_S05_KINV2_INDEPENDENT_VALIDATION_OK` and exited zero.

S06 and later consumers must require exactly this S05 source/result identity
and its preserved repaired-S01/S04, charge, kinematic-v2, and cache provenance.

The exact corrected S06 source above held-parses in Engine 15. Its
source-native `HQG_S06_PREFLIGHT_ONLY=1` branch executes the production prefix
and exits before cache initialization. In a fresh Engine process all 26
computed gates passed: accepted S05/S01/S04 identity and schema, reference and
BigTMD routing, model-derived charge and initial-state normalization, generated
counts and coherent real blocks, canonical polarization momenta, the ordered
real final state, inert two-body reinstall, tool-Solve three-body kinematics,
zero defining/installation residuals, exact content hashes, derived unique
cache paths, aggregate and per-row provenance, and absence of every S06
artifact. It printed `HQG_S06_KINV2_PREFIX_PREFLIGHT_OK` and exited zero. This
accepted the source contract before the production and independent-validation
run recorded below.

Repaired S06-v4 is accepted on the exact S05-v4 lineage:

- source: `s06_spin_color_sum_average_hqg.wl`, 60,000 bytes, SHA-256
  `d24ce8bf36d7e64037fbefa7c40cc299a1cff5e639339f03e6ebde17a3e2c8a6`;
- result: `s06_result`, 21,944,404 bytes, SHA-256
  `86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55`;
- production log: `s06_production.log`, 5,328 bytes, SHA-256
  `90e5b94278ab1fab071c98695d5e4541161e988b907a4b492ba12b57c12274ac`;
- independent-validation log: `s06_independent_validation.log`, 5,282 bytes,
  SHA-256
  `d96f9549aec3a908bb53355b8ad551a38c2db79b6c51e860f873c3c81a82382e`;
- LO final/post-Dirac caches: `s06_cache_hqg_lo`, 20,907 bytes,
  SHA-256
  `b887ae07c599c5a6cf2c8b0fb0c9f499466a87c59303acee53bd6eb80e5d4847`,
  and `s06_cache_hqg_lo_after_dirac`, 30,518 bytes, SHA-256
  `bd8e80e4a5c1f9bc1d3c3422b2d67ac92b3061a2974a10f996f347171ace801d`;
- real final/aggregate post-Dirac caches: `s06_cache_hqg_real_qg`, 8,483,451
  bytes, SHA-256
  `dd58095538d6992a7af9ed01faa91e6341e876545ca8b8db165384f8b8a9aeb0`,
  and `s06_cache_hqg_real_qg_after_dirac`, 13,002,025 bytes, SHA-256
  `4987a787dbffc20a5fcfbe5fa759158821cf2ec1a7e7fb6f31ccd1b541331203`;
- real row post-Dirac caches 01–08 have byte counts
  `{2157926,1875196,2158523,1412361,1091887,1412437,1853241,1091514}`
  and respective SHA-256 identities
  `{d408b1cde30a456f9fd6800d98ab777cfe9731fb0c914b648e76b2139a06e70e,
  32ee6b010395143bb5fb929d061ff55610b354b8e0f736ad64ec4a410c11cf99,
  86d959491aff6a3d16f7861537fee6955bbf39163ff17eb1fd56072ca8843f3e,
  425a36ad2917c3a574c9df79713e3ae4b0104596514713c96cef1525d823c198,
  b6aae45d6022ff82deacf4548ef5800a78ec42ca1a9f61196efe7a58fb0957d2,
  f8c62ee882fe9d670f713c9cd9b1e7bf981a2cb17c54fe3d6ba5f4d61e317c07,
  87c678b5c3a955c5242761493a94b2296e9f537669008fd1f6209d44b02a4a4d,
  c2212108795b727c36d17a8d0d5df25613ee1f7dae12243d6560ceb344617ae0}`;
- virtual final/post-Dirac caches:
  `s06_cache_hqg_virtual_interference`, 12,373,535 bytes, SHA-256
  `66a04c426f3c4fd18a7500ac615ee46c51d37305340714bb4c1725e52aeff202`,
  and `s06_cache_hqg_virtual_interference_after_dirac`, 20,017,171 bytes,
  SHA-256
  `5cbd011db6ed7dbf27a6cdc82f6e7207f18f78c9d8a19315c5104aeaa84ebc1c`;
- fresh production derived the real row count from S05, applied physical axial
  projectors to both real gluons, used the accepted one-gluon covariant sums,
  installed tool-derived two-/three-body kinematics, applied the S01-derived
  incoming average, passed all 33 computed checks, atomically published the
  result, printed `S06_SUCCESS`, and exited zero;
- the fresh independent validator recomputed LO, every coherent real row and
  aggregate, and the virtual branch before loading any S06 payload. All 14
  cache expressions and all three result tensors matched raw `SameQ`; all
  metadata, kinematic, state, content, provenance, saved-check, counterterm,
  no-temporary, and post-run identity gates passed. It printed
  `HQG_S06_KINV2_INDEPENDENT_VALIDATION_OK` and exited zero. Its only package
  diagnostics were harmless `StringJoin::string` messages in Boolean progress
  formatting; the printed 14-element cache gate vector and all result gates
  are explicitly `True`.

S07 must require exactly this S06 source/result identity and the complete
accepted S05/S01/S04 lineage embedded in `s06_result`. The S06 caches are
resume/validation artifacts, not direct S07 inputs.

The corrected S07 contract, to be accepted only after production and an
independent fresh-process validation, is:

- require the exact accepted S06 source SHA-256
  `d24ce8bf36d7e64037fbefa7c40cc299a1cff5e639339f03e6ebde17a3e2c8a6`
  and result SHA-256
  `86ccb3c5adaf40ddef3be177aef5c76ef56d72d589acdf658f255a05509d3b55`,
  including its embedded accepted S05/S01/S04 identities;
- consume the tool-derived initial-state normalization, photon indices, and
  inert two-/three-body kinematic records serialized by S06, reinstall both
  records with exact zero residuals, and never re-enter a scalar-product table;
- construct the two extraction tensors from the S06 photon indices and
  incoming momentum according to the reference paper's Eq. (7), apply both to
  each of the three accepted S06 tensors, and defer the Eq. (9) F1/F2 linear
  combinations explicitly;
- bind every cache to the exact S06 source/result, embedded lineage, reference,
  charge/state conventions, input-tensor content, kinematic content, and
  projector content; reject and delete any cache that fails the complete
  provenance contract;
- compute every validation gate from program state, atomically publish caches
  and `s07_result`, and provide a source-native no-write semantic preflight;
- independently recompute all six projections before loading S07 caches or
  result, require raw equality to each cached/result expression, and recheck
  immutable upstream and production identities after validation.

Repaired S07-v5 is accepted on the exact S06-v4 lineage:

- source: `s07_contract_hqg_projectors.wl`, 37,159 bytes, SHA-256
  `baf695aad89fb8344772bec6c8f6f49c28c18fd842404949fdf74f98d1316e09`;
- result: `s07_result`, 6,737,995 bytes, SHA-256
  `c4b235c611beab30db84b75d2cb36f0e63a433e6a2c08a3b280bded72f18e5b6`;
- LO caches: `s07_cache_hqg_lo_g`, 10,347 bytes, SHA-256
  `d1d884e7b6a8dd7a8d280ac7b80c429778f29126fd827304e549e0373ef00aac`,
  and `s07_cache_hqg_lo_pp`, 8,195 bytes, SHA-256
  `174464fd1a22b53f9e0e2ed3b852d559b6c7df05f18678444b33fcb1353b04bd`;
- real caches: `s07_cache_hqg_real_qg_g`, 1,806,882 bytes, SHA-256
  `fc0c3566ce963550b206dfd4c068b841a9d67704fcd7c6912332a29e634c1619`,
  and `s07_cache_hqg_real_qg_pp`, 163,740 bytes, SHA-256
  `ae055e9b775502663e47f17fd7f2be39a4f3e0e74b54cd630aa10ba072a33a74`;
- virtual caches: `s07_cache_hqg_virtual_interference_g`, 2,364,157
  bytes, SHA-256
  `2f12e98a73bb122b0158d3e047cb83c16c84d2ffa4adedcfbe85186f10e36d6a`,
  and `s07_cache_hqg_virtual_interference_pp`, 1,854,957 bytes,
  SHA-256
  `8d5ed6437919a9a50cd20e1e3479be53b8c764920a6521c8fb318f04f826bb5e`;
- production log: `s07_production.log`, 3,956 bytes, SHA-256
  `90939d8adbf6860f1067523190309313c4b4d7c556ce58c61e8964915c0e9104`;
- independent-validation log: `s07_independent_validation.log`, 3,225
  bytes, SHA-256
  `8cd2d8e1f1c5b19543efa0ada7aa533d931915ce0fb565eb87d6437a8f3a4fa2`;
- the source-native no-write preflight passed all 18 computed identity,
  lineage, convention, inherited-state/kinematics, tensor, projector, cache
  specification, and content-hash gates and printed
  `HQG_S07_KINV2_PREFIX_PREFLIGHT_OK`;
- fresh production formed all six Eq. (7) projections, atomically published
  each content-bound cache and the result, passed all 25 computed final gates,
  printed `S07_SUCCESS`, and exited zero;
- the fresh independent validator recomputed all six expressions from accepted
  S06 before loading any S07 payload, then matched every cache and result
  expression by raw `SameQ`. All six cache metadata gates, six cache-expression
  gates, six result-expression gates, 14 aggregate gates, and the immutable
  post-run identity gate were `True`; it printed
  `HQG_S07_KINV2_INDEPENDENT_VALIDATION_OK` and exited zero.

S08 must consume exactly this S07 source/result pair and must not treat the S07
caches as direct mathematical inputs. The S07 result carries the inherited
tool-derived state normalization and two-/three-body kinematic records; any S08
kinematic installation must consume those records rather than re-entering
scalar products.

The corrected S08 contract, to be accepted only after production and an
independent fresh-process validation, is:

- require S07-v5 source SHA-256
  `baf695aad89fb8344772bec6c8f6f49c28c18fd842404949fdf74f98d1316e09`
  and result SHA-256
  `c4b235c611beab30db84b75d2cb36f0e63a433e6a2c08a3b280bded72f18e5b6`,
  including its exact S06/S05/S01/S04 lineage, paper, charge, state, projector,
  input-content, and kinematic records;
- install only S07's inert two-/three-body kinematic associations and prove
  zero residuals; never transcribe a scalar-product table;
- construct the Eq. (19) overall normalization and Eqs. (34), (38), and (39)
  phase-space factors from the paper definitions. In particular, repair the
  old S08 omission of the `2^(-epsilon)` factor in Eq. (38), which Engine 15
  measured as an erroneous old/paper ratio `2^epsilon`;
- derive Appendix-D D5–D8 by having FeynCalc square the four rearrangements of
  the paper's momentum-conservation Eq. (D4). Discover the actual composite
  real-propagator denominator bases and reduce them only when polynomial-ideal
  membership in those generated relations identifies a unique invariant;
- construct the frame-2 angular coefficient vectors from Eqs. (B5)–(B17) and
  invariant dot-product equations, then derive same-type, triple, geometry,
  and numerator-basis relations from those vectors. Gate all frame norms,
  dot products, D5–D8 coefficient residuals, and B18/B19 case assignments with
  Wolfram rather than accepting transcribed coefficient vectors;
- derive zeta uniquely by `Solve` from Eq. (40) with the defining fragmentation
  substitutions, derive the Eq. (29) Jacobian by differentiation, and derive
  the Eq. (31)/(32) boundaries by solving `zeta=1`. Derive the partonic `s,t,u`
  rules from Eqs. (25)–(27);
- bind the measured BigTMD routing files `sidis.py`, `NLO/Pg/fchn3A.py`, and
  `NLO/Ppp/fchn3A.py` by path/hash and retain the discovered mapping, while
  deferring finite regular/delta/plus equality to `bigTMD_check`;
- bind each real-angular cache to the exact S07 source/result, complete lineage,
  paper/BigTMD reference identities, input expression, kinematics, frame,
  phase-space normalization, Appendix-D relations, and angular-master
  definitions; reject/delete stale caches and publish caches/result atomically
  with exact reload checks;
- compute every validation gate from program state and provide a source-native
  no-write semantic preflight;
- independently recompute the two two-body pairs and both real angular
  projections before loading S08 caches/result, require raw equality and full
  provenance, and recheck all immutable identities after validation.

Repaired S08-v5 is accepted on the exact S07-v5 lineage:

- source: `s08_phase_space_integrate_hqg.wl`, 65,932 bytes, SHA-256
  `28a2a552c09470844c5418c7261e88c7abcc80bc3f9388f348cb8e6e4dbf8803`;
- result: `s08_result`, 206,049,416 bytes, SHA-256
  `a25bafca0c9e33790418d9a491b985a73e12a75b9260f7a1864c315c7e608052`;
- real Pg cache: `s08_cache_hqg_real_qg_g`, 20,720,005 bytes, SHA-256
  `26990faf2f3e5167e4ff3d78f10b937963ec0caa53e1d6941472f3361102b275`;
- real PPP cache: `s08_cache_hqg_real_qg_pp`, 4,326,943 bytes, SHA-256
  `9eedf24bb955fe576ff46b016ab63979f88d2a821c9fd3c3cf8858dbdf80359a`;
- source-native no-write preflight log: `s08_preflight.log`, 3,121 bytes,
  SHA-256
  `3fca1f43cbb4e23649f9a9d0808f17caad3d0a1bfcc8dc2f954cc7190817ddbf`;
- accepted production log: `s08_production.log`, 4,094 bytes, SHA-256
  `9ffa81ff7dd2d212dadfcb143677a596ae83b267f6d721d67b05ed0198daf820`;
- cache-free real-angular validation log:
  `s08_fresh_real_independent_validation.log`, 3,836 bytes, SHA-256
  `206c302060cf254efb88881f27f2665c2dd78b59fd4680cbb234a5d4e5a19572`;
- initial result-validator diagnostic log:
  `s08_result_independent_validation.log`, 3,267 bytes, SHA-256
  `d8864d48fafd569af24f99feac66be088396b72cde6c0ec082e28de2505a1c4d`;
- corrected aggregate validation log:
  `s08_corrected_aggregate_validation.log`, 2,526 bytes, SHA-256
  `e889716eedf495db6ae46c04c386f0e61e465b52f0fa40ca4b21768825a4e7eb`;
- retained resource-bound failure evidence:
  `s08_production_failed_13g.log`, 3,503 bytes, SHA-256
  `4a94cf66fac3592fb47b3e462d0cca0fa9608f40c7efe9a2ad558c8dd36b5833`;
- the source-native preflight derived the unique composite propagator maps
  `s12+s13+s23 -> sHat` and `s13+u1+u3 -> t2` from the four FeynCalc-derived
  Appendix-D residuals plus the separately derived global invariant residual.
  All 21 identity, normalization, kinematic, denominator, frame, xi/s23, and
  parsed-BigTMD gates passed, and the snapshot proved both caches/result
  absent;
- fresh production derived 72 Pg and 48 PPP angular-master keys and produced
  angular expressions with leaf counts 7,848,490 and 1,626,805. It produced
  63 distinct unevaluated B19 case-2 masters in the combined result, passed
  all 18 computed final checks, both cache checks, and all four atomic
  reload/post-publication gates, printed `S08_SUCCESS`, and exited zero;
- the first 13 GiB production attempt completed and atomically validated both
  caches but exhausted its imposed memory ceiling during final result reload.
  The renamed result lacked a success marker and was deleted before a clean
  unchanged-source retry. Fresh Engine inspectors reproduced every stored
  input/kinematic/expression hash, so the caches were retained; the retry at
  15 GiB validated both caches, regenerated the transformations/result,
  passed atomic reload, and produced the accepted identities above;
- the cache-free independent validator disabled both S08 cache I/O functions
  in an in-memory exact-source copy, recomputed Pg and PPP completely, printed
  `S08_VALIDATION_FRESH_COMPLETE_BEFORE_CACHE_LOAD`, and only then opened the
  production caches. Both metadata, raw-expression, and expression-hash
  associations were all `True`; artifact snapshots were unchanged and it
  printed `HQG_S08_FRESH_REAL_INDEPENDENT_VALIDATION_OK` with exit zero;
- the initial result validator independently derived every mapping before
  loading the result and proved all raw two-body/cache equalities, both large
  real transformations, structure, phase, xi, BigTMD, content, and identity
  gates. Its structural `SameQ` predicates incorrectly omitted the final
  `Together` on the added `tHat` rule and compared three algebraically
  equivalent parsed Python forms without `Together`, so those diagnostic
  predicates were `False`. The corrected validator cryptographically bound
  that log and the successful fresh-real log, applied the exact normalized
  rule/algebraic comparison, obtained all four two-body, ten mapping, seven
  aggregate, and post-identity gates `True`, printed
  `HQG_S08_CORRECTED_AGGREGATE_VALIDATION_OK`, and exited zero.

S09 and later consumers must require exactly this S08 source/result pair and
its embedded S07/S06/S05/S01/S04 lineage. The S08 caches are production-resume
and validation artifacts, not direct S09 mathematical inputs. Consumers must
preserve the corrected `2^(-epsilon)` factor, the five-residual denominator
canonicalization ledger, the tool-derived frame and xi/s23 maps, and the
measured BigTMD channel-3A file identities; no finite BigTMD kernel equality
is implied at S08.

## S09 contract — Appendix-F expansion and formal endpoint handoff

The corrected entry point is `s09_expand_endpoints_hqg.wl`. Its finalized
artifacts are the compact `s09_result`, the two expression caches
`s09_cache_hqg_real_qg_g` and `s09_cache_hqg_real_qg_pp`, and the production
log `s09_production.log`. The stage/result schema is `HqgS09-v5`; the cache
schema is `HqgS09Cache-v2`.

1. The sole mathematical input is the accepted physical angular pair at
   `s08_result["ThreeBodyAngularIntegrated","Hqg;qg",{Pg,PPP}]`. S09 must
   pin the accepted S08-v5 source/result and both S08 cache hashes recorded
   above, require every computed S08 check and complete embedded lineage, and
   exact-match each S08 cache expression/hash/provenance to the corresponding
   result angular payload. The S08 caches are equality/provenance witnesses;
   they are not an alternate mathematical branch.
2. Inventory every exact five-argument `S08Case2Master` before substitution.
   The current tool measurement is Pg `61` occurrences / `61` distinct
   instances / `24` pair classes, PPP `43/43/18`, and `63` distinct instances
   in the `25`-class union. Runtime must derive and require the complete
   projector-specific inventories and union; accepting a subset or a copied
   expected list is forbidden.
3. Expand nonzero-`j` masters from Appendix F and Appendix B, with every
   formula checked by the defining B19 relation
   `D_D I[j,l](D,C) = -j I[j+1,l](D,C)` at the common printed epsilon order.
   Required F8 `{1,-3}` must also pass the exact independent B19 angular-
   moment derivation. Its logarithmic K moment must use the exact positive-
   domain logarithm split and Wolfram-derived orientation signs for the two
   unit-interval changes of variable, avoiding a branch-obscured direct
   whole-interval antiderivative. Every `j=0` class, including Hqg-only
   `{0,-3}`, must be derived from exact B18 and expanded through `epsilon^2`.
4. The required Hqg class `{2,-3}` must not use the paper's inconsistent
   printed F9 epsilon coefficient. Wolfram must generate it through
   `epsilon^1` as `-D_D` of the independently validated F8 expansion, prove
   the exact recurrence residual zero, integrate the original B19 beta-two
   dependence exactly and independently reconstruct that reduction from its
   measured angular moments, then compare at multiple physical `D>1`,
   `-1<C<1` points with a high-precision one-dimensional beta-one evaluation.
   The residual must exhibit the `O(epsilon^2)` order expected from the
   retained truncation.
5. Hqg-only polynomial classes `{-2,-1}` and `{-1,-2}` must be derived in the
   running program by exact Wolfram integration of the original two-angle B19
   definition and expanded through `epsilon^2`. Their residuals against the
   substitution expressions must be exact zero. A label or copied formula is
   not evidence of derivation.
6. Derive all residual B18/B27-family expansions from the current input. The
   measured hypergeometric signatures are Pg `(1,1,1-epsilon)` and
   `(1,2,1-epsilon)` with three total occurrences, and PPP
   `(1,1,1-epsilon)` with two. Encode paper B30 as an equation and use Wolfram
   `Solve` with B27 to derive the `(1,2)` series through `epsilon^2`; prove the
   exact arbitrary-index defining-series coefficient identity and a
   high-precision `O(epsilon^3)` regression. Expand all measured Beta/Gamma
   objects and prove that individual Gamma series reconstruct both whole
   Gamma ratios through `epsilon^2`. No `PowerExpand`, machine number, or
   numerical branch selection is allowed.
7. Prove that every measured master and residual-special-function
   substitution commutes with the accepted S08 partonic map, and prove one
   fused replacement traversal exactly matches the former sequential route,
   including both composite Gamma ratios. For production, map each physical
   angular projector first, apply the exact Jacobian and all checked
   Appendix-F/B18/B27/B30 substitutions in that single traversal, and evict
   the original and mapped inputs as soon as their consumer finishes. Each
   final cache expression must be exact, nonzero, and free of retained B19,
   hypergeometric, Beta, Gamma, angular, propagator, unmapped-partonic,
   machine, failure, or inactive objects.
8. S09 is a substitution/map stage and applies no new multiplicative weight,
   scale factor, charge, flavor luminosity, state sum, or final-state symmetry
   factor. Derive the unit additional weight with a symbolic solve, retain the
   scale structure measured from the accepted S08 inputs exactly. The accepted
   S08-v5 physical angular Pg and PPP payloads both have the tool-measured
   empty `ScaleMu`-power inventory, so S09 must preserve that empty inventory
   and must not introduce a scale factor. Validate this by a direct exact
   absence/inventory scan of the final expression; do not rebuild a second
   full expression merely to strip a scale factor known to be absent. Preserve
   charge-stripped BigTMD channel 3A and fragmenting `g(k1)`, and keep the
   accepted LO and symbolic virtual pairs as hash-pinned upstream references
   rather than combining or duplicating them.
9. Record the bounded formal identity on the accepted interval
   `0 <= s23 <= B(xi)` through `epsilon^2`, with one unresolved
   `S09EndpointValue` and three `S09PlusDistribution` heads per projector.
   The regular function is `s23^(1+epsilon)` times the exact hash-pinned cache
   expression. Both endpoint values and every stronger singularity remain
   deliberately unresolved for corrected S10; expression size, timeout, or a
   failed `Limit` must never change the semantic output.
10. Bind every cache to the exact S09 program, paper, S08 source/result and
    individual cache identity, projector, exact input-expression hash,
    measured master/special-function inventories, exact content validation,
    and inherited bookkeeping. Atomically write each cache, require exact
    equality between the in-memory expression and its immediate reload, then
    independently reload the finalized cache and compute its real file
    SHA-256. Store only compact descriptors, paths, file hashes, and summaries
    in `s09_result`; do not compute a monolithic Mathematica `Hash` of either
    expanded expression and do not duplicate either expression in the result.
11. Provide a complete source-native no-write preflight that ignores all S09
    output, executes every formula/provenance/map/endpoint/result-candidate
    gate, and proves the S09 artifact inventory unchanged. Process Pg then PPP
    serially and require the physical-input association to be empty afterward.
    Each large substitution is intrinsically single-expression algebra, so
    parallel copies would only increase memory use; the map-first fused route
    and immediate input eviction are the required memory-linear execution
    order. In no-write mode, exact expression content validation and measured
    leaf/byte summaries replace publication-only cache write/reload and file
    SHA gates.
12. After production, validate in a fresh FeynCalc-initialized Engine process:
    exact disk identities and schemas; S08 cache/result payload equality;
    all formula certificates; a cache-bypassing fresh expansion of both
    projectors; exact cache/result hashes and compactness; formal endpoint
    structure; and the complete stage boundary. Accept S09 only on every
    computed gate true, an explicit success marker, zero exit, unchanged
    upstream identities, and no temporary artifact.

The superseded v4 candidate completed every exact formula certificate and the
mapped-first fused Pg expansion in about four minutes, with a zero residual
inventory, then failed only when it tried to compute one monolithic
`Hash[expandedXiS23,"SHA256"]` under the 14 GiB process limit. A separate
instrumented run reached that exact call with Wolfram `MemoryInUse` near
514 MB and no failed mathematical gate. The accepted Hgq S09 implementation
establishes the project-local efficient provenance pattern used by v5: exact
in-memory validation, atomic write/reload equality, independent finalized
reload, and cache-file SHA-256. This changes no physics expression or
operation; it removes the redundant whole-tree hash and its repeated metadata
recomputation.

The first v5 production candidate with source SHA-256
`173890a4b0a4fa61de88604935f09db81fe02765319ac57d0218887973ba0528`
completed both projector expansions, zero residual inventories, atomic cache
writes/reloads, and finalized-cache validation in about 6:40, then correctly
refused to publish `s09_result` because its compact-result gate was false. A
fresh Engine probe of the actual PPP cache metadata measured the intended
formula witness `{Gamma[1-2 epsilon],Gamma[1-epsilon]}` and proved that the
whole-result special-function scan rejected those two required Gamma objects.
The two unaccepted caches were deleted. The corrected source identity in the
table above now tests compactness at the actual cache-expression boundary,
explicitly requires preservation of that Gamma inventory, rejects residual
B19 masters and propagator payloads, and retains the byte-size gate. The
same source-defined compactness predicate is invoked by both the no-write
result-candidate gate and final production, preventing a weaker preflight.
The failed run is preserved as `s09_production_failed_compact_gate.log`; it
did not publish a result or leave a temporary file.

Corrected S09-v5 is independently accepted on the exact S08-v5 lineage:

- source `s09_expand_endpoints_hqg.wl`: 81,676 bytes, SHA-256
  `f7a88a6863d90f76972b45f8c0281001d3f16e8f5da220b6c3ae977234d994d0`;
- compact `s09_result`: 18,074 bytes, SHA-256
  `a1f585334a749146230b1ea0f32e98df34290217798cc8293bbfdbc9ec2b6624`;
- Pg cache `s09_cache_hqg_real_qg_g`: 124,490,269 bytes, SHA-256
  `2691548528a6138213ef4e444776ef7ec44db97b8619275af3341d88c064c378`;
- PPP cache `s09_cache_hqg_real_qg_pp`: 27,698,763 bytes, SHA-256
  `4296c1477f10691a86429eb16458d2e79c68b451b181196c7d7c1fa0c59a60ac`;
- final source-native no-write log `s09_preflight.log`: 5,523 bytes,
  SHA-256
  `547e1c6baef01456807232025a913d1af096e42360ba741f5f7d6c7c71920ad4`;
- production log `s09_production.log`: 6,826 bytes, SHA-256
  `77a66c50081ca1be676973207b43a5946b324f8fca92c70c4535d4bcbbaca604`;
- cache-bypassing validation log `s09_independent_validation.log`: 6,219
  bytes, SHA-256
  `d3b618647c6330abc3356e29b715ecb23fc567c4217c232f5f9e3c834fe882d1`;
- retained failed compact-gate log
  `s09_production_failed_compact_gate.log`: 4,469 bytes, SHA-256
  `d852061463647423af3e9e6b7fb14d091b954e37ce3c2988092fe2d4faec3f69`.

The final preflight recomputed both expressions from accepted S08, passed all
27 computed base gates and the exact shared result-candidate predicate, and
published nothing. Fresh production measured Pg at 43,081,075 leaves /
1,111,995,608 bytes and PPP at 9,520,066 leaves / 245,646,264 bytes; both
post-expansion residual inventories are literal zero. It atomically wrote and
exact-reloaded each cache, independently reloaded the finalized caches,
bound their actual disk SHA-256 values into the compact result, passed all 31
computed checks, printed `S09_SUCCESS`, and exited zero with unchanged
upstream identities and no temporary artifact. A separate fresh
Engine-15/FeynCalc-10.2.1 process uniquely instrumented the exact source only
in memory, bypassed cache reuse, recomputed both projectors, obtained raw
`SameQ` for fresh Pg and PPP against their production cache expressions, and
then passed all 11 independent result, formula, summary, disk-hash,
compactness, endpoint, temporary, and immutable-upstream gates. It printed
`HQG_S09_FRESH_INDEPENDENT_VALIDATION_OK` and exited zero without changing an
artifact.

S09 stops at exact Appendix-F-expanded real kernels and an honest formal
endpoint-distribution handoff. Corrected S10 must load only the two
hash-pinned S09 cache expressions and resolve their endpoint singularity
classes while separately consuming the accepted S08/S07 LO/virtual branch.
Eq. (46) subtraction, pole cancellation, the finite hard part, Eq. (9),
F-hat extraction, physical `Sum_q e_q^2 f_q D_g`, and BigTMD comparison all
remain downstream.

### Corrected S10 candidate contract — not yet accepted

The current grouped-coverage-corrected source SHA-256 is
`b456c6b18b37d1313425563362b5336e73166985dc2ed36586aff3cac4db402b`
(132,075 bytes). Engine 15 has held-parsed all 3,669 physical source lines
with no evaluation (`HQG_S10_GROUP_COVERAGE_HELD_PARSE_OK=True`, held leaf
count 10,656). The strict current-lineage loader, fresh cache namespaces,
runtime loop inventories, inherited kinematic-record installer, derived
coupled-group machinery, compact result, and final publication gates are
implemented. The raw S07 LO/virtual pairs are hash-gated against S08's input
ledger, while the S08 two-body phase-space outputs are independently
hash-gated against S09's reference ledger; different representations are not
compared directly.
The first superseded source's exact source-native no-write prefix preflight passed all 12 computed
identity, bookkeeping, representation-hash, S09-cache, runtime-inventory,
endpoint-placeholder, and no-output gates, printed
`HQG_S10_V5_PREFIX_PREFLIGHT_OK`, and exited zero. Its log is 4,654 bytes,
SHA-256 `44f1c3682fa6b7885068e63379e1006e20dd7575cd6e52d3aa407971df6123e9`
and is retained as `s10_preflight_superseded_source_eb0c3a81.log`.

The first Hoffman production attempt of source SHA-256
`eb0c3a818f1723cc1b4d578fc3717185ec7a40a47d684a3a2a36e3298202bb5e`
was Grid Engine job `14504936`. Scheduler accounting records nine shared
slots, `failed=0`, `deleted_by=NONE`, and application `exit_status=1` after
1,150.178 seconds. The run completed the PaVe, scalar-master, and full Pg/PPP
virtual Laurent caches, then stopped at the first real-endpoint load with
`S10_FATAL: Pg S09 expansion cache has invalid current provenance.` The
17,462-byte failed log is preserved remotely as
`s10_hoffman_failed_job_14504936.log`, SHA-256
`e786c8fbfd268165aa37be7ed207529537a7ec03c45831f9b7102d5476bfb721`.
Before corrected restaging, the three superseded-source PaVe, scalar-master,
and Laurent caches had respective SHA-256 identities
`01d811d997a473106f74dd4446d092a8a2a8e8c8ef9002e8d3a2b7e8ae44beb9`,
`33efecf85a74ad7b85f61a4b1caf96f7bf082e2f28e8cd5cfd6deff3d9427d72`,
and `2dc2952e79a4a3ba0192e16a4eea3d3e862e0b0bd474815fb4bf32d64352198f`;
all three were deleted because their metadata bound the superseded source.
The
originating source defect is a lifetime error: after the prefix-only
preflight boundary, production intentionally clears the large `s09`, `s08`,
and `s07` associations before Laurent expansion, but the delayed S09 cache
loader still dereferences three compact `s09[...]` metadata fields. Thus the
same cache passes preflight before the clear and must fail production after
it. A Hoffman Mathematica-13.1 metadata-only probe independently showed all
22 Pg metadata comparisons `True` before that clear, excluding transfer,
disk-hash, and runtime-version corruption.

The correction contract is bookkeeping-only and must preserve the paper's
calculation boundary: snapshot the S09 cache-stage version, measured
projector scale powers, LO/virtual reference hashes, and downstream physical
flavor-weight flag before releasing the large associations; make the delayed
loader and compact result consume only those snapshots; emit exact false-key
diagnostics for any future provenance failure; and retain the memory release.
No virtual expression, endpoint operation, normalization, regulator,
projector, or Eq. (29)–(32) integration boundary may change. Consistent with
the paper, S10 still resolves/combines real endpoint and virtual terms while
Eq. (46) PDF/FF factorization remains downstream. Any failed-run cache bound
to the superseded source identity is not a corrected-source resume input and
must be removed or versioned away before corrected production. The now-
superseded bookkeeping-corrected source SHA-256 `801bd3e3...` then repeated
the complete no-write preflight:
both full S09 cache payloads loaded, every one of the 12 computed gates was
`True`, the terminal marker was `HQG_S10_V5_PREFIX_PREFLIGHT_OK`, and Engine
15 exited zero. It created no S10 cache or result. The retained corrected
`s10_preflight.log` is 4,654 bytes, SHA-256
`2dffc920dfc50a1aca3357c4231dd7191cfe9608691c0123b9e7ddb71defe57a`.
The same exact source then passed a Hoffman Mathematica-13.1 no-write
preflight as job `14517519`: all 12 gates were `True`, scheduler and
application exit statuses were zero, and the 4,587-byte remote log has
SHA-256
`339326a3aa979f61b2b539c88909a303842739e9354f6e60d543c73151e76273`.

Corrected production job `14517535` of source `801bd3e3...` completed and
published the PaVe, scalar-master, and full Pg/PPP Laurent caches, passed the
evaluation-stable delayed Pg S09 cache load that had failed in job
`14504936`, and reached the structural Pg endpoint scan. It then stopped
safely with application exit status one because a stale early assertion
required `singularLogTermIndices[terms]` to be empty before invoking the
already implemented physical-root group discovery and repair. The tool-
measured Pg list was `{32,34,41,42,43,71}`. Exact source inspection proved
the same function subsequently stores that list, derives coupled groups,
checks both physical square-root signs, and requires completed repair
metadata; the early assertion therefore made the intended grouped treatment
unreachable. The failed 17,605-byte log has SHA-256
`5a44ff4ea80c533d1f70289e5eccbc93e464e1f0ad57d708a68a195f6392ac93`.
Its completed virtual caches have SHA-256 identities
`4b79830ef2bcc7ab2f4e3a31ea82755e7f7e4226756e173b111bf7ec966c24c1`,
`99499f1c2d72e3a3b6961443da3c256e4e8ca7d833c1f9aba6457c44f6f67c13`,
and `97911f64b18a9e00737eb268782c2177d7f965ca07dd108ab84eba10e6d2552f`
for PaVe, scalar-master, and Laurent respectively; they are bound to the
superseded whole-source identity and are not current-source resume inputs.

The current source removes only that contradictory empty-list requirement,
prints the derived singular-log inventory, discovers groups by the existing
tool algorithm, and requires `Complement[logIndices,
coupledSourceIndices]` to be exactly empty before endpoint evaluation. It
increments `CoupledLogEndpointRepairVersion` to 3. No endpoint expression,
branch rule, normalization, regulator, projector, distribution action, or
paper integration boundary changed. Its exact Engine-15 source-native
preflight loaded both accepted S09 cache payloads, passed all 12 computed
prefix gates, emitted `HQG_S10_V5_PREFIX_PREFLIGHT_OK`, and exited zero
without creating any S10 cache or result. The 15-line / 4,651-byte canonical
log has SHA-256
`9659d73a0e6f4720a1fa6e8580ccc1552c718c4cdbd28ac202786826a2e87095`.
The prior local preflight evidence is retained as
`s10_preflight_superseded_source_801bd3e3.log`. The exact current source then
passed the same no-write gate under Hoffman Mathematica 13.1 as job
`14517963`: scheduler `failed=0`, application `exit_status=0`, all 12 gates
`True`, and no S10 cache/result. Its 15-line / 4,588-byte log has SHA-256
`15739ce4b346e937986930b6ca6c31538ecdefcc79a9e1aae17b7cb76cdb8139`.
Production and independent validation remain pending, so S10 is not yet an
accepted consumer input.

#### S10 alpha-two construction diagnostic contract

Job `14517973` of source `b456c6b1...` passed the repaired Pg cache-load and
singular-log scan, measured direct-log indices `{32,34,41,42,43,71}` and the
structural alpha-two index `{33}`, then stopped after the 600-second bound in
the global `Cancel[Together[prefactor nestedRatio^(-1-epsilon)
specialRemainder]]` construction. Scheduler accounting was normal and no
endpoint cache/result was written. Before changing that algorithm, the
stage-prefixed no-write diagnostic
`s10_diagnose_alpha2_regularization_hqg.wl` must:

- load only the exact accepted Pg S09 cache and derive the exceptional index,
  nested power, and all term factors from the current expression at runtime;
- determine whether the nested power is one exact top-level multiplicative
  factor, remove it structurally only on a unique match, and require exact raw
  reconstruction of the original term;
- derive the nested ratio from its defining base relation with Wolfram, build
  the same regular-function definition from the structurally removed
  remainder, and test its endpoint directly and factorwise without a global
  whole-expression `Together`;
- print measured leaf counts, timings, factor endpoint validity, and exact
  Boolean gates; write no result, cache, source, or temporary artifact.

Only a tool-demonstrated exact construction may replace the timed-out global
canonicalization. No endpoint exponent, logarithmic tower, normalization,
branch rule, or distribution formula may change.

The first diagnostic run proved that the nested power is one unique
top-level factor, exact structural removal reconstructs the source term, and
the nested-ratio defining relation and finite nonzero endpoint both pass. The
regular function is then constructed in less than a millisecond without the
global canonicalization. It contains 14 top-level factors; endpoint
substitution is valid for factors 1--13 and invalid only for factor 14.
The localized follow-up derived factor 14 as a `Plus` with 708,680 leaves and
1,412 addends, but endpoint substitution was invalid for every raw addend.
Consequently neither direct, factorwise, nor raw-additive substitution is an
accepted endpoint construction, and the production source remains unchanged.

The next no-write diagnostic must stay confined to factor 14 and have Wolfram
derive its endpoint through exact common-denominator and/or Laurent-series
operations. It must inventory the exact method and timings, reject all
unresolved endpoint objects or surviving `s23`, prove agreement between every
successful independent method, preserve the accepted Pg cache byte-for-byte,
and publish no result/cache. Production may adopt a method only after those
gates pass.

The attempted whole-factor `Series`/`Cancel[Together[...]]` diagnostic was
killed with process exit 137 before emitting an inventory; only the normal
package banner was logged. The accepted Pg cache, diagnostic source, and
production source remained byte-identical, and no S10 cache/result was
created. Its seven-line / 2,958-byte log is retained as
`s10_alpha2_diagnostic_killed_whole_factor.log`, SHA-256
`9fada958cd140e5bfb5f5680d3a90117a9f872b8c9877516caee021bba5a8cb2`.
No endpoint construction is accepted from that run.

The replacement diagnostic must avoid a whole-factor canonical expression.
For each of the 1,412 runtime-derived addends it will have Wolfram compute a
bounded order-zero `SeriesData`, derive the Laurent powers from that object's
own `nmin`, `nmax`, and denominator fields, and accumulate coefficients by
power. Every negative-power sum must reduce to exact zero. The constant term
must be finite and must agree exactly with a separately evaluated sum of
per-addend `SeriesCoefficient[...,0]` values. Deterministic batch checkpoints,
exact reconstruction of the full regular-factor inventory, immutable accepted
input, and no-write/no-cache behavior remain mandatory.

The first coefficientwise implementation completed `SeriesData` extraction
for every addend and reached addend 600 of the independent
`SeriesCoefficient` pass, then Engine 15 exhausted its 10-GiB process ceiling
because both methods' full intermediate lists were simultaneously retained.
No terminal inventory or endpoint was accepted. The accepted input and both
sources remained byte-identical and no S10 artifact was created. The 32-line /
4,607-byte log is retained as
`s10_alpha2_diagnostic_failed_retained_intermediates.log`, SHA-256
`60733cc73741ec55f5be26f7e1a753e8adc98efb0140d5d70c0590632acda29e`.

The corrected diagnostic storage contract evaluates both exact methods within
the same bounded addend batch, compares corresponding constants immediately,
retains only coefficient sums and compact agreement metadata, then clears the
batch and system cache before continuing. This changes no mathematical method
or acceptance condition; it only bounds intermediate lifetime.

The first paired-batch run completed both exact methods for addends 1--50 in
0.264660 seconds with zero constant-coefficient mismatches, then rejected the
batch before retention because its derived coefficient-key union lacked an
explicit zero-power key. Engine 15 independently demonstrated that a requested
order-zero `SeriesData` may encode `nmax=1` while omitting trailing zero entries
from its coefficient list. The extractor therefore pads only those missing
tool-declared trailing slots with exact zeros and joins `0 -> 0` before any
actual constant coefficient (if present) overwrites it. An executable pure-pole
self-test gates this behavior before the accepted Pg cache is loaded. The
failed 11-line / 5,867-byte inventory log is retained as
`s10_alpha2_diagnostic_failed_zero_power_inventory.log`, SHA-256
`48753a54cca4bc77c52a918e2eb01fc01725ef54cdbbc94efad90887fbdd8a4d`.

With the corrected zero-key contract, 50-addend paired batches completed
through addend 550 with zero mismatches, but batch 551--600 exceeded the
10-GiB process ceiling before completion. This isolates the remaining issue to
the live size of one exact-method batch rather than retained prior batches.
The 34-line / 5,581-byte log is retained as
`s10_alpha2_diagnostic_failed_batch50_peak.log`, SHA-256
`b15e2fee82c8cc4319b294aa100ab23fe7efb69fe57c88a821baed506968b2e4`.
The current diagnostic uses five addends per paired batch and preserves every
per-addend method, comparison, coefficient sum, and acceptance gate.

The five-addend run completed through addend 355 with zero mismatches in every
batch, then the same long-lived Engine 15 process exhausted memory during
addends 356--360. The 154-line / 18,913-byte log is retained as
`s10_alpha2_diagnostic_failed_batch5_kernel_lifetime.log`, SHA-256
`6a8942dc9d95270d7a3444434bfbaafdccd673586fd0942b2471fe8d0c06990a`.
The two smaller-batch failures prove that process-lifetime accumulation, not
only one batch's live size, must be bounded.

The current diagnostic execution contract is Hoffman-parallel. It requires the
same nine-slot scheduler allocation as S10 production, launches eight distinct
Wolfram workers using the production-proven kernel configuration, partitions
the runtime addend range into twice as many contiguous chunks as workers, and
runs those chunks in two deterministic waves. Every worker performs both exact
methods per addend and returns only compact per-power sums and agreement
metadata. All workers are closed and relaunched between waves, so each process
handles only one derived chunk. The master requires exact chunk coverage,
returned-range equality, eight distinct worker IDs, all per-addend agreements,
negative-power cancellation, finite endpoint reconstruction, immutable input,
and the no-write contract. Current diagnostic source is 1,065 lines / 33,036
bytes / SHA-256
`bbd2ac22991c0b2d9b7f15daf250d578f7add0b32f5c5aa6bc30104fe684754c`.
The dedicated scheduler entry
`s10_hoffman_alpha2_diagnostic_submit.sh` is 32 lines / 695 bytes / SHA-256
`bdf1f20627a0fbbbc0a5a6dc3a1f1eb842e458052854211e87c428ab93260dce`;
it requests nine shared slots, 8 GiB per slot, and a two-hour cap.

Hoffman job `14518101` executed that parallel source. Wave 1 processed 712
addends with worker IDs `{1,...,8}` and zero mismatches; after all workers were
closed, wave 2 processed 700 addends with fresh IDs `{9,...,16}` and zero
mismatches. All 1,412 addends passed both exact methods. Wolfram derived
Laurent powers `{0}`, no negative powers, finite factor-endpoint SHA-256
`7e469c3695147752a91c50630fb855149d5b7e355839079c1884ffddd9d0b5ae`,
factor-endpoint leaf count 5,905, and reconstructed regular-endpoint leaf count
6,215. Every algebra, reconstruction, finiteness, chunk-coverage, range,
scheduler, and immutable-input gate was `True`.

The job rejected only because the diagnostic's aggregate worker-ID gate
incorrectly required the union across fresh waves to contain eight IDs; the
correct union contained 16. The originating gate now stores every wave's ID
set and requires one set per runtime wave with eight distinct IDs inside each
set. Current corrected diagnostic is 1,071 lines / 33,261 bytes / SHA-256
`e8870ac9815e886d1002c4408666d6a8cb471e0d006bfa1eb227731717181592`.
Job `14518101` had scheduler `failed=0`, application `exit_status=1`, runtime
580.777 seconds, and aggregate `maxvmem=27.119G`; its 178-line / 36,670-byte
log has SHA-256
`488f6ba0a25aa67e7df845a424830fe4a63af988e3d0e896d456eff49480bf34`.
No endpoint/result artifact was written, so a corrected-source diagnostic rerun
is mandatory before production adoption.

Corrected-source Hoffman job `14518114` reproduced both waves, all 1,412
per-addend method comparisons, and the same endpoint inventory with zero
mismatches. Every checklist value, including eight distinct workers per wave,
is `True`, and the terminal marker is
`HQG_S10_ALPHA2_STRUCTURAL_DIAGNOSTIC_OK`. Scheduler accounting is
`failed=0`, application `exit_status=0`, runtime 556.548 seconds, and aggregate
`maxvmem=26.993G`. Its 178-line / 36,713-byte log has SHA-256
`9429c0a00e6390858448e90bf525c971393f192e9bc02828a4a426f404617310`.
The accepted Pg cache stayed byte-identical and no result/cache was written.

Production may now replace the timed-out whole-expression canonicalization
only with the accepted construction: remove the unique nested power as an
exact top-level factor and require source reconstruction; retain the resulting
uncanonicalized regular function; identify direct-substitution-invalid
top-level regular factors at runtime; for each such additive factor derive its
constant term by the accepted bounded per-addend method on deterministic
parallel workers; reconstruct the full endpoint from all finite factor
endpoints; and gate its hash against the independently accepted diagnostic
identity for the current Pg input. The alpha-two exponent, logarithmic tower,
normalization, branch rules, and distribution action remain unchanged.

The implemented production candidate follows that contract in
`s10_complete_virtual_endpoints_hqg.wl`: 4,191 lines / 149,642 bytes /
SHA-256
`cb7beac78da72d25a2cada8a69ffdf5397e94cfaf6f9fd3335a3ecd835afbf13`.
It bumps only the endpoint cache schema to v4 and alpha-two construction
version to 2. Each invalid additive factor is divided into 16 deterministic
source-position chunks, evaluated in fresh waves of at most eight workers,
and accepted only when paired exact `SeriesData` and `SeriesCoefficient`
constants agree for every addend, all derived negative Laurent coefficients
cancel exactly, and the finite Pg hash matches the accepted diagnostic.
Per-factor cache metadata contains only deterministic mathematical evidence;
ephemeral kernel IDs are recorded separately in final execution provenance so
a new scheduler allocation cannot invalidate an otherwise exact resume cache.
The final named gate also requires nonempty per-term factor-hash inventories,
64-character endpoint hashes, the accepted Pg content identity, eight distinct
workers in every launched alpha-two wave, and closed workers before result
publication. Engine 15 inertly parsed all 381 source expressions / 13,182 held
leaves through exact byte 149,642. Focused static inspection found the required
construction/cache/result wiring and no retired whole-expression timeout path.
The source-native Engine 15 preflight then exited zero with all 12 prefix checks
`True` and terminal marker `HQG_S10_V5_PREFIX_PREFLIGHT_OK`. Its 15-line /
4,654-byte log is `s10_preflight.log`, SHA-256
`5db493a60c42de6694d68ad1949836d67b2943074b6c681a4e49c8de695499f5`.
It contains no Wolfram message or fatal marker, source SHA-256 remains
`cb7beac78da72d25a2cada8a69ffdf5397e94cfaf6f9fd3335a3ecd835afbf13`,
and the local S10 cache/result namespace remains empty. The prior source-bound
preflight is preserved as `s10_preflight_superseded_source_b456c6b1.log`,
SHA-256
`9659d73a0e6f4720a1fa6e8580ccc1552c718c4cdbd28ac202786826a2e87095`.
Hoffman one-slot preflight job `14518259` then reproduced the complete 12-check
success boundary and terminal marker from the exact canonical source. Scheduler
accounting is `failed=0`, application `exit_status=0`, runtime 147.099 seconds,
and `maxvmem=3.892G`. Its 15-line / 4,588-byte canonical log has SHA-256
`37650b45420d2abffc9ee6fe8c070f0d3bbd4012c9891ea9941bef61586210ca`.
Remote source remains exact SHA-256
`cb7beac78da72d25a2cada8a69ffdf5397e94cfaf6f9fd3335a3ecd835afbf13`,
and the remote cache/result/temp/upload namespace is empty after preflight.
The corrected source is accepted for full Hoffman production, but no production
result is accepted until that run and all publication gates pass.

Full production job `14518276` validated the v5 alpha-two correction but exposed
a separate standard-endpoint orchestration defect. Both fresh eight-worker Pg
waves completed all 1,412 paired exact-method calculations; production derived
Laurent powers `{0}` and finite invalid-factor endpoint SHA-256
`7e469c3695147752a91c50630fb855149d5b7e355839079c1884ffddd9d0b5ae`,
then advanced through Pg coupled-source coverage with `uncovered={}`. Thus the
originating alpha-two failure is corrected and content-bound in the full stage.

The subsequent first standard Pg batch covered positions 1--8 of 70 on exactly
workers 17--24. Source terms 2--8 each started once, but term 1 started nine
times. There was still one batch marker, no parent fallback, no endpoint cache,
and no result. The ninth start exceeds the finite eight-worker inventory and
tool-demonstrates that Mathematica automatically replaced a failed subkernel
and rescheduled the same `ParallelMap` input indefinitely before the source
could reach its existing serial fallback. A recovery-aware monitor therefore
woke `retry_exhausted`, and only job `14518276` was deleted. Scheduler accounting
is 9,081.207 seconds runtime, 16,738.640 CPU-seconds, `maxvmem=24.930G`, and
user-deletion exit 137. Its exact 526-line / 64,799-byte evidence is preserved
on Hoffman as
`s10_hoffman_failed_unbounded_endpoint_retry_job_14518276.log`, SHA-256
`9217d07f6274a799b4ea59207ff6b69e20315849fa46de7fbc555c23956816e6`.
The v5 source and preflight are preserved as
`s10_complete_virtual_endpoints_hqg_superseded_cb7beac7.wl` and
`s10_hoffman_preflight_superseded_source_cb7beac7.log`, retaining SHA-256
`cb7beac78da72d25a2cada8a69ffdf5397e94cfaf6f9fd3335a3ecd835afbf13`
and `37650b45420d2abffc9ee6fe8c070f0d3bbd4012c9891ea9941bef61586210ca`.
No endpoint cache/result was written; all three whole-source-bound virtual
caches were deleted before replacement-source work.

A no-write Engine 15 probe derived the exact accepted Pg 71-term inventory.
Term 1 measures 43,902 leaves / 1,128,256 bytes, whereas valid later terms reach
6,247,027 leaves / 161,121,824 bytes, so input size cannot safely select the
serial route. The 3-line / 1,408-byte evidence is
`s10_endpoint_size_probe.log`, SHA-256
`55283b9140a1fedf81681ddc336f88de5bf54059ca05fcb52999428ab1752a32`.
A size cutoff is rejected.

The v6 orchestration correction must leave every endpoint algebra method and
coefficient gate unchanged. It must place a 900-second parent deadline around
each bounded `ParallelMap` batch. On deadline, malformed batch return, or any
non-association worker answer, the parent must close all workers before doing
the existing exact serial fallback; full-batch failure recomputes every batch
input serially, while partial failure recomputes only failed positions. Later
batches launch fresh bounded workers. The source must record timeout count,
per-projector serial-fallback source indices, and every explicit worker-launch
ID set; final gates must require each launch set to contain exactly eight
distinct IDs and each fallback index to belong to that projector's runtime
standard-term inventory. The result must publish this provenance. Endpoint
cache v4, alpha-two construction v2, all distribution/branch logic, and the
accepted Pg alpha-two hash contract remain unchanged.

The current local v6 candidate is 4,327 lines / 155,449 bytes / SHA-256
`238ebcf663b4ba9f7b3ad36d6137850b9237212f4803f58c6e54d856b3a340f4`.
Engine 15 inertly parsed the complete file as 386 held expressions / 13,482
held leaves and reached stream position 155,449, exactly equal to the file
byte count. A no-write control-flow test returned true for the finite parent
timeout flag, `$Failed` timeout result, and deterministic parent fallback.
Safe held inspection counted exactly two `ParallelMap` expressions in the
complete source (the accepted alpha-two map and the standard-endpoint map),
with exactly one standard map directly enclosed by the configured parent
`TimeConstrained`. The complete `endpointFactorwiseLaurent` through
`endpointTermLaurent` algebra block is byte-identical between this candidate
and preserved v5, SHA-256
`9003e49c3518c1a89d1828f7ef142104e6b79a464709f2bd638c0e04f6fb2d9e`.
The candidate's direct Engine 15 preflight exited zero with exactly 13 named
checks all true, including the finite endpoint-batch deadline configuration,
accepted S07/S08/S09 identities, both expanded-real cache payloads, the
runtime virtual and formal endpoint inventories, and both no-write gates. It
printed exact terminal `HQG_S10_V6_PREFIX_PREFLIGHT_OK`, emitted no
`S10_FATAL:`, left the complete `s10_cache_*` / `s10_result*` namespace empty,
and did not change the source hash. Canonical `s10_preflight.log` is 15 lines /
4,730 bytes / SHA-256
`917b1318c2f0c7cf9a83aa5d68000fb7b83cb6b110e21d2b0ede9d4ab76afa79`.
V6 is therefore source-native-preflight accepted locally; it remains a
production candidate until the corresponding Hoffman preflight and production
run are independently accepted.

Hoffman one-slot preflight job `14518795` independently reproduced all 13 true
checks and exact `HQG_S10_V6_PREFIX_PREFLIGHT_OK` from the exact v6 source.
Accounting reports `campus2.q@n6125`, `failed=0`, `deleted_by=NONE`, application
`exit_status=0`, 159.611-second runtime, zero signals, and `maxvmem=3.911G`.
Because Grid Engine appended to the staged local log, the raw 30-line / 9,397-
byte combined evidence is preserved as
`s10_hoffman_preflight_appended_local_baseline_job14518795.log`, SHA-256
`02b4f24df3f987331fa5f7bbe63b2e9d36ea04de5b552cdce5b9b37d3270426f`.
Tool extraction after the exact 4,730-byte staged prefix produced the clean
fresh Hoffman block. Canonical remote `s10_hoffman_preflight.log` is 15 lines /
4,667 bytes / SHA-256
`248ba9457dbe806c0f28f7ebb0e7be49738cd19a9fe1d20b593e41e799532235`;
it has exactly 13 true checks, no `S10_FATAL:`, and the exact v6 terminal marker.
Remote source remains SHA-256
`238ebcf663b4ba9f7b3ad36d6137850b9237212f4803f58c6e54d856b3a340f4`,
and the complete remote S10 cache/result/temp namespace is empty. V6 is now
Hoffman-preflight accepted and remains a production candidate only until the
full run and all publication gates pass.

Full v6 production job `14518806` independently proved the finite standard-
endpoint orchestration but exposed a separate deterministic Pg term-1 gate.
Both alpha-two waves completed and the first standard Pg batch reproduced five
worker-replacement starts of endpoint 1. The 900-second parent deadline then
closed all eight workers and printed exact full-batch serial fallback with
`timedOut=True`; serial evaluation immediately rejected term 1 with measured
endpoint pole order `0` after multiplication by `s23`. No endpoint cache or
result was written. Scheduler accounting is `pod_smp.q@n1171`, nine slots,
`failed=0`, `deleted_by=NONE`, application `exit_status=1`, 2,314.234-second
runtime, zero signals, and `maxvmem=27.677G`. Exact 524-line / 64,989-byte
evidence is preserved as
`s10_hoffman_failed_pg_term1_endpoint_order_job_14518806.log`, SHA-256
`b84ecd1a102c51b9697bd006b92fdcdf8302f6da48843cd3b4c9b6a199cd4cde`.
The three exact v6 virtual caches were successfully published and retain
production/resume value; no endpoint cache, result, or temporary file exists.

No endpoint interpretation is accepted from this failure alone. The required
no-write diagnostic must load only accepted Pg S09 cache SHA-256
`2691548528a6138213ef4e444776ef7ec44db97b8619275af3341d88c064c378`,
derive the first standard source term from its current factored expression,
and inertly extract the exact endpoint validity, factorwise, split, and
exceptional-term definitions from v6 source SHA-256
`238ebcf663b4ba9f7b3ad36d6137850b9237212f4803f58c6e54d856b3a340f4`.
It must reproduce and inventory the factorwise failure, skipped/direct path,
`Cancel[s23 term]` endpoint-invalid inventory and measured rational order, then
tool-test bounded `Together`/`Cancel` normalization and independent Laurent
coefficients. It must report only tool-derived hashes, timings, sizes, orders,
validity, and exact-agreement gates; it must not write or change any S10 cache,
result, accepted input, or production source. Production may change only after
that diagnostic establishes the originating defect and a tool-validated exact
replacement method.

The first local execution established the target and production failure prefix
but rejected whole-expression normalization. It derived source term 1 as
43,902 leaves / 1,128,256 bytes / SHA-256
`5d9af0914ad1b6d43bf735a2771456749adb31da49dfa51eca22c6c35f9b5f0e`,
reproduced exact factorwise `$Failed`, and confirmed the direct path is skipped
only by the 30,000-leaf cutoff. `Cancel[s23 term]` took 287.374165 seconds and
produced 2,710,404 leaves / 69,838,920 bytes with numerator and denominator
minimum `s23` exponents both tool-measured as 1, reproducing order 0 and an
invalid atomic direct endpoint. Whole-expression `Cancel[Together[...]]` then
exceeded the 12-GiB ceiling and was killed with exit 137. The 15-line / 5,520-
byte evidence is SHA-256
`bfcf53ced8063ab948ad49ba190862051f8e3a9d73f767c5c0b073b115f5eb3a`.
No input or output artifact changed and no disposable cache was created.

Whole-expression `Together` is not an admissible correction. The follow-up
must identify the invalid atomic endpoint exactly, evaluate each top-level
factor endpoint under its own message/timeout boundary, and use only exact
tool-derived common-monomial or polynomial division of the already-cancelled
numerator and denominator. It must require zero polynomial remainder, exact
source reconstruction, finite normalized endpoint, and agreement with bounded
independent Laurent coefficients before production code may change.

The per-factor follow-up derived exact regular flags `{True,True,False,True}`,
uniquely isolating top-level factor 3; factors 1, 2, and 4 retained finite
endpoint values. A full granular factorwise attempt nevertheless returned
`$Failed` after 610.706794 seconds, so its singular-factor Laurent substep is
also rejected. Running that memory-heavy attempt first caused the subsequent
production cancellation to hit its 600-second bound. The 15-line / 11,552-byte
evidence has SHA-256
`7edf6dec4b77c4133944d55ec4f623335567d54521031bffd6c90905f4f20f87`;
accepted inputs and the output namespace again remained unchanged.

The next run must retain the unique per-factor inventory but must not execute
the rejected granular full calculation. It must run `Cancel[s23 term]` first
in a clean kernel, divide its numerator and denominator by their exact common
tool-derived `s23` monomial with zero polynomial remainders, and require the
normalized negative Laurent coefficient to vanish and its independently
computed finite coefficient to equal direct endpoint substitution.

That whole-polynomial division contract was tested and rejected before any
production change. In a clean third run, `Cancel[s23 term]` completed in
242.669291 seconds and exactly reproduced the 2,710,404-leaf / 69,838,920-byte
expression with SHA-256
`ac6544ffdb4effbf12ef91a1af379b702af5cdc9e2a85ec2c0f6ae26bf220e3d`,
atomic endpoint `Indeterminate`, and tool-derived numerator/denominator
minimum exponents `1` / `1`. Exact whole-numerator
`PolynomialQuotientRemainder` then exhausted the 12-GiB diagnostic ceiling;
Engine shut down and the run exited `1` without a completion marker. The
19-line / 12,640-byte evidence is preserved as
`s10_pg_term1_endpoint_diagnostic_failed_polynomial_division_memory.log`,
SHA-256
`b4a38b1775d3f6de290153e8f6011c87cdbaa7d05bbd7a45980c2b659771aeac`.
Accepted source/input identities and the empty local S10 output namespace
remained unchanged. Whole-polynomial division is therefore not an admissible
production correction.

The successor no-write diagnostic must keep the accepted target derivation,
per-factor inventory, and clean production cancellation, but must not build a
whole quotient polynomial. Mathematica must derive the numerator and
denominator minimum `s23` exponents from the cancelled expression, require
equal positive integer orders for this regular common-factor branch, and use
exact `Coefficient` calls to derive every lower coefficient and both leading
coefficients. Every lower coefficient must be exact zero; both leading
coefficients must be valid and free of `s23`; and the denominator leading
coefficient must be exact nonzero. The finite candidate must be constructed
only from those two tool-derived leading coefficients, remain valid and free
of `s23`, and have a tool-computed negative-one `SeriesCoefficient` of exact
zero. The diagnostic must print timings, expression identities, every gate,
and unchanged source/input/output snapshots, and must exit zero with an exact
completion marker before this bounded leading-coefficient branch may be added
to `endpointTermLaurent`. The existing factorwise, direct, cancelled-direct,
and true-pole paths must remain unchanged.

The first execution of this bounded successor did not reach its new block.
The unchanged production `Cancel[s23 term]` hit its 600-second bound and the
diagnostic exited `1`; at that instant the local host reported load average
`27.24`, 11/15 GiB RAM used, and 3.9/4.0 GiB swap occupied. This coincidence
is resource-pressure evidence, while the exact tool verdict is only the
cancellation timeout. The 14-line / 11,261-byte log is preserved as
`s10_pg_term1_endpoint_diagnostic_failed_cancel_timeout_host_pressure.log`,
SHA-256
`e099ca46ba1e47919a84984526054b206d4a61e771a50fe8c4aa21e2306ed245`.
It establishes no result and does not reject the unentered leading-coefficient
method. The next validation must use the exact same source and accepted inputs
in an isolated Hoffman scheduler job rather than competing with unrelated
local work.

Isolated Hoffman job `14519487` removed that resource ambiguity and rejected
the raw-`Coefficient` implementation. Exact production cancellation completed
in 215.533101 seconds and reproduced expression SHA-256 `ac6544ff…`, atomic
endpoint `Indeterminate`, and minimum numerator/denominator exponents `1` / `1`.
The new block then found a nonzero `Coefficient[...,0]` and stopped at its
lower-coefficient gate before constructing any candidate. This exact conflict
shows that raw `Coefficient` on the retained factored representation is not an
accepted coefficient extractor for this branch; expanding the 2.7-million-leaf
numerator merely to make that call applicable is forbidden by the prior memory
evidence. Accounting reports `campus2.q@n7046`, one slot, `failed=0`, application
`exit_status=1`, 529.142-second runtime, zero signals, and `maxvmem=2.470G`.
The 16-line / 12,629-byte log is preserved as
`s10_hoffman_pg_term1_diagnostic_failed_coefficient_gate_job14519487.log`,
SHA-256
`52962d724348cf85f8de404f507688e72918c4a94dcec29a8bf02653ba48794d`.
The three resumable virtual caches retain their prior identities and no
endpoint cache, result, or temporary result exists.

The corrected successor must keep the same exact cancellation and tool-derived
minimum-order gates, but derive every lower and leading coefficient with
bounded exact `SeriesCoefficient[numerator,{s23,0,k}]` and the corresponding
denominator call, directly on the retained representation. It must require all
lower coefficients exact zero, valid nonzero leading coefficients, a valid
`s23`-free leading-coefficient ratio, exact negative-one coefficient zero, and
exact zero-coefficient agreement with that ratio. No raw `Coefficient`,
whole-expression expansion, polynomial division, or `Together` may occur.
The source-native symbolic harness and full isolated no-write run must both
pass before production changes.

Isolated exact-series retry job `14519631` rejected that extractor on the full
representation. Production cancellation completed in 209.82414 seconds and
again reproduced expression `ac6544ff…` and minimum orders `1` / `1`, but the
first bounded lower `SeriesCoefficient` operation failed or reached its
600-second limit without returning a coefficient. No candidate was built.
Accounting reports `campus2.q@n7126`, one slot, `failed=0`, application
`exit_status=1`, 913.850-second runtime, zero signals, and `maxvmem=2.835G`.
The 16-line / 12,622-byte log is preserved as
`s10_hoffman_pg_term1_diagnostic_failed_series_coefficient_job14519631.log`,
SHA-256
`45db5735dca6c0b6a6f13dffe62491536e804718557c8350dd4bd29fb90300ed`.
The accepted inputs, three resumable virtual caches, and empty endpoint/result
namespace remained unchanged. General series extraction on the huge numerator
is therefore not admissible.

The next successor must derive Taylor data by bounded exact endpoint
derivatives evaluated by Mathematica on the retained expression:
`(D[poly,{s23,k}]/Factorial[k]) /. s23 -> 0`, with every `k` generated from
the tool-derived minimum orders. It must require all lower derivative
coefficients exact zero, valid nonzero leading derivative coefficients, a
valid `s23`-free ratio, and the existing candidate negative-one/zero gates.
No numerator/denominator `Coefficient` or `SeriesCoefficient`, expansion,
polynomial division, or `Together` is permitted. The actual source block must
pass the symbolic independent-`Limit` harness and an isolated no-write run
before production changes.

Endpoint-derivative job `14519770` reached that method but rejected the
generated zeroth-order dispatch before testing the positive leading order.
Cancellation completed in 279.789722 seconds and reproduced `ac6544ff…`; the
lower-order set was `{0}`, but routing order zero through
`D[poly,{s23,0}]` caused the bounded lower extraction to fail. No leading
derivative or candidate was evaluated. Accounting reports `campus2.q@n7126`,
one slot, `failed=0`, application `exit_status=1`, 384.150-second runtime,
zero signals, and `maxvmem=2.453G`. The 16-line / 12,624-byte log is preserved
as `s10_hoffman_pg_term1_diagnostic_failed_derivative_zero_job14519770.log`,
SHA-256
`aae084fe09007b9e3ed848fdc4bd0c7f282de55f28b088e979a5ed39c1daf825`.

The derivative successor must dispatch each tool-generated order explicitly:
order zero uses exact direct substitution `poly /. s23 -> 0`; only positive
orders use `(D[poly,{s23,k}]/Factorial[k]) /. s23 -> 0`. All existing
minimum-order, lower-zero, leading-validity, candidate, no-write, and forbidden-
method gates remain unchanged. The source-native harness must exercise both
the zero and positive branches before another isolated run.

Dispatch-corrected job `14519829` proved that isolated
`productionNumerator /. s23 -> 0` still fails under the bounded/message gate,
even though substitution on the complete cancelled ratio returns atomic
`Indeterminate`. Cancellation completed in 273.256528 seconds; no lower value
or leading derivative was accepted. Accounting reports `campus2.q@n7126`, one
slot, `failed=0`, application `exit_status=1`, 377.894-second runtime, zero
signals, and `maxvmem=2.483G`. The 16-line / 12,624-byte log is preserved as
`s10_hoffman_pg_term1_diagnostic_failed_zero_substitution_job14519829.log`,
SHA-256
`f2aadc434d2d86133d98b464e4469b9b43557490addf7afa8bd19d2e30c29cd9`.
This rejects all whole-numerator/denominator extraction on the retained
factored ratio; the previously measured minimum exponents remain diagnostic
evidence only and may not drive a candidate.

The next no-write diagnostic must work directly on the already-cancelled
top-level `Times` representation. Mathematica must split only those exact
top-level factors, evaluate each factor endpoint under its own timeout and
message boundary without converting messages into a whole-map `$Failed`, and
print every factor/source/endpoint identity. A factor is removable from the
singular subset only when its endpoint is valid, `s23`-free, and exact nonzero;
all exact-zero, invalid, or failed factors must remain grouped. Mathematica may
then apply bounded `Cancel` to only that grouped subset and use its valid direct
endpoint or, if still invalid, a bounded exact `Limit`. The full finite
candidate is the tool-evaluated product of the finite-nonzero endpoint factors
and resolved grouped endpoint, followed by the existing candidate Laurent and
no-write gates. Whole numerator/denominator extraction, expansion, polynomial
division, and `Together` remain forbidden.

Full-term grouped-subset job `14520230` produced the first complete cancelled
factor inventory. Mathematica derived 12 top-level factors with finite-nonzero
flags `{True,True,True,False,True,True,True,True,True,True,False,True}`;
regular indices are `{1,2,3,5,6,7,8,9,10,12}` and the exact singular subset is
`{4,11}`. Factor 4 is a one-leaf `Symbol`; factor 11 is a 2,709,327-leaf /
69,807,848-byte `Plus`, SHA-256
`e8a063c785d37031eba3b5712cb3e97125d12377e98092146d875ae582028304`.
The complete grouped product then failed to resolve within its 600-second
bound. Accounting reports `campus2.q@n7126`, one slot, `failed=0`, application
`exit_status=1`, 1,119.233-second runtime, zero signals, and `maxvmem=2.713G`.
The exact 18-line / 25,841-byte inventory log is preserved as
`s10_hoffman_pg_term1_diagnostic_failed_grouped_subset_job14520230.log`,
SHA-256
`4877169c9505c777839fb32be6fdb077ef27bd0f9246448c932bf40d79f6c2c4`.

The successor must derive, not assume, that the two singular factors consist
of exactly one positive integer power of `s23` and exactly one `Plus`; it must
print their identities and the `Plus` addend count before algebra. Mathematica
must then map in deterministic source order over those addends, applying only
bounded `Cancel[monomial addend]` and direct endpoint substitution per addend,
with per-addend progress, identities, validity flags, and a bounded parent map.
Every endpoint must be valid and `s23`-free before `Total` forms the grouped
endpoint. That tool-derived sum times the already validated regular endpoint
product is the finite candidate for the existing Laurent/no-write gates. The
whole grouped product must not be cancelled, limited, expanded, or combined by
`Together`.

The full-term termwise diagnostic job `14520330` did not reach that successor
block. Its unchanged prerequisite `Cancel[s23 term]` exceeded the explicit
600-second bound and emitted only the exact cancellation fatal. Grid Engine
reports `campus2.q@n7107`, one slot, `failed=0`, `deleted_by=NONE`, application
`exit_status=1`, 703.234 seconds runtime, zero signals, and `maxvmem=2.478G`.
The exact 14-line / 11,257-byte log is preserved as
`s10_hoffman_pg_term1_diagnostic_failed_cancel_timeout_job14520330.log`,
SHA-256
`8f964e0e3e9237a32b7b80b33022ae050c387ca79dfd6dae2e191539ba55e37e`;
its exact source is preserved as
`s10_diagnose_pg_term1_endpoint_order_hqg_cancel_timeout_job14520330.wl`,
883 lines / 27,138 bytes / SHA-256
`761bb3c33696266175935ec85d6de669150596c76bb00357636c9fa7a843561d`.
No termwise addend ran and no candidate was produced.

Further retries of the globally cancelled representation are forbidden. The
accepted native-expression inventory is the new boundary: Mathematica derived
four top-level factors, factor term counts `{1,1,2,12}`, regular flags
`{True,True,False,True}`, and unique singular factor index `3`. Before another
algebraic candidate run, the no-write diagnostic must inventory the exact
`FullForm`-level structure, identities, sizes, top-level multiplicative
factors, and `s23`-dependency skeleton of that two-addend singular factor.
That inspection may perform no cancellation, expansion, series operation,
limit, polynomial division, `Together`, or physics inference. Its output must
be used to select one representation-native Laurent operation whose production
implementation preserves the current exact factorwise formula and derives all
coefficients with Wolfram. The replacement must expose per-addend progress,
must not globally transform the full term, and must pass exact reconstruction,
coefficient-validity, pole/finite, input-identity, and no-write gates before it
can replace the originating production function.

The completed structure-only inspection emitted exact source-object forms and
exited zero without algebra or writes. Its 16-line / 1,068,810-byte log is
`s10_pg_term1_native_structure.log`, SHA-256
`c31ffafde2f0e0e6c9964fe20c01d77f18da1a17a373643ce4b0bd45b15e10fa`.
The singular factor is a 43,015-leaf `Plus` with two approximately 21,500-leaf
`Times` addends. Their complete function inventory consists of arithmetic over
`{Q2,PHT2,s23,xB,xi,zH,epsilon,Pi}`, 189 square-root occurrences drawn from
exactly three structural templates, two `Log` objects, and two
`PolyLog[2,...]` objects. Explicit endpoint powers include
`s23^(3/2)`, `s23^(5/2)`, and `s23^(7/2)`. Consequently neither the singular
factor nor its addends are purely rational Laurent objects in `s23`.

Preserved production log job `14518806` independently shows that Pg source
term 1 belongs to one 61-term physical-root group derived before endpoint
evaluation. The rejected pre-factor-ledger candidate sent every group member
through `endpointTermLaurent` separately and invoked physical-branch group
repair only after every individual pole/finite pair existed. That ordering is
rejected:
the individual term is not the mathematical endpoint unit when its radicals,
logs, or half-integer powers cancel only in the derived group. Before source
changes, a read-only taxonomy must cover all 71 exact Pg terms and every
distinct root, logarithm, dilogarithm, and endpoint-power template. The
replacement must resolve the complete derived physical-root group as one
equation on both already-established physical signs, with Wolfram deriving and
checking all series coefficients; it must not force grouped members through a
generic rational fallback first.

The required read-only taxonomy is now complete. Wolfram covered all 71 exact
Pg source terms and proved unchanged source/input/output identities in
`s10_pg_equation_type_inventory.log`, 12 lines / 346,067 bytes / SHA-256
`0f20e9c6e5f2457f1787399fadfa230e3f538835293fd326b2cafe62297f5dab`.
There are 60 exact outer structural signatures; term 33 is the sole
epsilon-dependent exceptional-power type. Every radical occurrence belongs to
six exponent/template pairs built from three exact radicands. Bounded Wolfram
algebra on those small radicands proved that two are identical and each is
exactly `s23` times the third, so one branch-aware common root generates the
entire radical content. Global per-term rationalization is therefore neither
required nor admissible.

Wolfram next normalized all 29 `Log` and 11 `PolyLog[2,...]` argument templates
against that common inert root and the positive endpoint coordinate. Exact
`SameQ` gates reduce the 40 templates to 39 shared arguments; the evidence is
`s10_pg_shared_argument_basis.log`, 84 lines / 79,891 bytes / SHA-256
`bb076766b1cb66780d2ed76828aaa832eea4d5e78c5d685dfd00c124c2655034`.
The two-sign endpoint classification is accepted in
`s10_pg_argument_endpoint_classes.log`, 5 lines / 10,951 bytes / SHA-256
`aeab778a4cfad2c1f258c40a0aa556d83f64bb8f44e57e0710e78f68de45e4fd`.
On root sign `+1`, the tool finds 27 finite-nonzero, four zero, six unity, and
two direct-indeterminate arguments; on root sign `-1`, it finds 30
finite-nonzero, four zero, and five unity arguments. Direct endpoint
substitution is thus forbidden for the group: argument and function jets must
be formed before the grouped sum.

The accepted shared-series certificate is
`s10_pg_shared_function_series.log`, 131 lines / 119,855 bytes / SHA-256
`d0ac765e64a19c7c342593ee17a455e4575bd806cd38619c40f47b9daf8b14d9`.
Engine 15 derived the common-root jet from its defining square equation through
endpoint-coordinate order six on both physical signs, with every residual
coefficient exactly zero. It then resolved all 29 logarithms and 11
dilogarithms through function-series order two on both signs: 80 branch starts,
40 completed functions, every branch-valid gate true. Final checks are
`RootDefiningEquationThroughOrder -> True`,
`All40FunctionsBothSignsSeriesResolved -> True`, and
`ExactSourceAndInputUnchanged -> True`.

Corrected production introduces a positive symbolic coordinate `t` with
`s23 -> t^2`, without `PowerExpand`. It must derive the common-root jet from
the exact defining equation and reuse one shared argument/function jet table
per physical sign. Exact literal replacements must act on the native factored
source expressions. The v6 implementation SHA-256
`a5fbed83c006ef40b94224a8b86785813f765c6024b57f354db38f1ce84ede2c`
derives endpoint support from the 4--13 recorded top-level factors of every
outer equation type. It SHA-groups factors with exact `SameQ` collision gates,
expands each unique factor only to its dependency-ledger-required order,
convolves coefficient maps, and applies cancellation and finite-value gates
only after all 61 grouped contributions have entered one coefficient
association. Thus no complete grouped term is series-expanded or required to
be finite independently. Every grouped source position bypasses individual
`endpointTermLaurent`; ordinary nongrouped terms retain the existing generic
path. On each sign the complete group must have no negative `t` power and no
residual endpoint-logarithm dependence before its finite coefficient is
accepted. The finite group value is stored at the first deterministic group
member and every absorbed partner is set to exact zero, matching the existing
downstream group bookkeeping. Failure of either sign, reconstruction,
truncation sufficiency, cancellation, or immutability gate is fatal and
publishes nothing. Engine 15 inertly parsed all 394 source expressions / 16,328
held leaves through exact EOF byte 197,289. The bound no-write diagnostic is
SHA-256 `6f69336b7fe90de229bd247a922125d51702ec3c66cdeddb7ee8b7252088e9c6`
and inertly parses 158 expressions / 4,754 held leaves through byte 57,510.
These identities are parse-accepted and are now also bound to the accepted
group-only runtime certificate recorded below.

The first three factor-ledger runtimes reached the shared-function gate after
both 159-factor support passes and independently re-derived function/root
orders two/six. Seventy-eight of 80 branch/function jets passed; only the two
positive-root direct-indeterminate basis functions 16 and 23 failed. Replacing
literal unit equality with bounded algebraic equality did not change that
boundary, and evaluator version 4's direct function `Series` still reproduced
the same two failures. The accepted native-order diagnostic log is 13 lines /
16,846 bytes / SHA-256
`dae29f58fd2227eecabde5eb928cf357ef9d8fac8eba50cc4da8d56dc450329b`;
all four group/order/no-write/early-exit gates are true. It maps production
positions 16/23 by their exact raw-argument hashes to accepted Log templates
13/18. The source-bound negative-power-gate certificate is 2 lines / 2,349
bytes / SHA-256
`9edf3bb91a5184e3b5fc961968bd5c0c6968e17f2e5cefc9f2850f0c626d3edc`:
both direct series resolve, but the generated Log arguments have exact integer
minimum power `-2`, which the prior canonicalizer rejected before constructing
its otherwise general replacement. The corrected two-object certificate is 3
lines / 2,317 bytes / SHA-256
`637aaaa3621a10694b1c634aacf320e284bde0c4a55dc593eb5b9227d904934a`.
With the gate generalized from nonnegative integer to integer, both records
have valid nonzero leading coefficients and unit series, construct their
replacements, remain known through order two, contain zero unresolved
endpoint-dependent Logs, and are free of forbidden representations. Evaluator
version 5 applies only that proven predicate correction; all subsequent gates
are unchanged. Its full validator accepted all 80 shared function/sign records
and entered the positive branch ledger, then emitted no first factor-pilot
marker for 600 seconds. The interrupted no-write log is 895 lines / 101,179
bytes / SHA-256
`c0a2f9e21240f1ddf5f20d0993bf82a6cd3977eb90e1f778ce90ab942a02c8e6`.
Exact source inspection localized the pre-pilot operation: it substituted the
40 shared `SeriesData` jets into each complete 61-term expression before
splitting top-level factors, allowing Wolfram to multiply series across whole
terms during replacement. Evaluator version 6 instead exact-reconstructs each
compressed placeholder term from its top-level factor list, carries the common
endpoint-coordinate power as its own factor, applies root/function/QCD rules
factor by factor, and leaves all cross-factor multiplication to the existing
coefficient-map convolution. Per-term transform and factor-hash markers bound
the formerly invisible region. Endpoint cache/repair/evaluator lineage is
v10/v9/v6 and uses fresh `s10_cache_v10_endpoint_{pg,pp}` paths. No function,
branch, root, or series-order convention changed.

The corrected factor-first group-only validator is accepted. A fresh local
Engine-15 execution completed in 2,637.314634 seconds and the complete
Wolfram/timeout/tee pipeline exited zero. Its canonical log is
`s10_pg_grouped_equation_series.log`, 1,921 lines / 222,463 bytes / SHA-256
`a8316a4d26224ac44c6afc1cbd6f710a5071a35accdf56ef78aaef8e27ec1a15`.
The tool re-derived the 61-member coupled Pg endpoint group, six root
occurrences, 40 shared function templates, both 159-factor structural-support
passes, function/root orders two/six, and all 80 branch/function records. On
each physical root sign it exact-reconstructed all 61 compressed terms,
reduced 404 factor occurrences to 160 exact unique factors with collision
gates, completed all 160 pilot series and order-two extensions, and convolved
all 61 term coefficient maps before testing cancellation. Both emitted branch
certificates report minimum power zero, endpoint-log degree zero, 160 unique
factors, maximum factor order two, and exact-zero residual gates. The final
tool record reports exact integer zero for the diagnostic pole and finite
coefficients, root residuals zero, every function series resolved, literal
reconstruction true, and exact source unchanged. The three final checks—one
runtime-derived target group, complete group evaluation before individual
Laurent handling, and unchanged source/input/output namespace—are all true,
followed by exactly one `S10_PG_GROUP_SERIES_COMPLETE` marker. Independent
post-run counting found two branch certificates and zero fatal markers; source,
diagnostic, and accepted Pg cache identities remained exact, and no
`s10_result`, v10 endpoint cache, or `s10_*.tmp.*` file was published. This
accepts the corrected group evaluator and its equation-object boundary; it is
not a full S10 production result.

The bound diagnostic also has an accepted
`HQG_S10_FUNCTION_ORDER_ONLY=1` mode, valid only together with
`HQG_S10_GROUP_SERIES_ONLY=1`. It derives the same physical-root group, scans
that group's exact native `Log`/`PolyLog[2,...]` traversal order with
`SameQ` deduplication, emits only compact function/argument identities, gates
the 40-function contract and source/input/output immutability, and exits before
structural support or endpoint evaluation. This mode exists solely to map the
production list positions reported by a failed shared-function gate onto the
accepted template inventory; it does not produce or accept a physics result.

Hoffman production job `14533248` exposed a runtime-only defect after passing
the three virtual-cache migrations, UV validation, exact input maps, coupled
Pg group discovery, and both 159-factor structural-support traversals. It ran
on `pod_smp.q@n7405` with seven slots and exited `1` after 2,099.538 seconds;
Grid Engine reports `failed=0`, `deleted_by=NONE`, and `maxvmem=18.281G`.
The exact failed log is preserved remotely as
`s10_hoffman_failed_group_function_series_job_14533248.log`, 1,046 lines /
107,518 bytes / SHA-256
`446759f6bab0d9f8f3bfa4950230739054d31a960f7a761c2fb574c93d5d8dd0`.
Only negative-root native dilogarithm positions 10 and 39 returned `$Failed`;
the other 78 function/sign records passed. The accepted local certificate for
the identical 40-function/two-sign basis resolves all 80 records exactly and
the paper requires the physical branch continuation to remain attached to the
exact logarithm/dilogarithm objects. Source inspection localized the
production-only rejection to per-expression `TimeConstrained` wrappers whose
fallback was `$Failed`, so node speed was incorrectly used as a mathematical
validity predicate.

Evaluator v7 removes all six wall-clock cutoffs inside the physical-root group
evaluator: common-radicand selection, root-ratio normalization, shared-function
argument normalization, structural-support series, exact shared-function
series, and factor-coefficient series. Their algebra, two physical root signs,
orders, endpoint-log normalization, reconstruction, coefficient convolution,
and exact cancellation gates are unchanged. The scheduler limit and
persistent external monitor remain the execution bounds. Endpoint provenance
advances to v11 with fresh `s10_cache_v11_endpoint_{pg,pp}` paths. The exact
current virtual-cache lineage under program `db7a88de...` and cache hashes
`1864b732...`, `9ea773df...`, and `c5cfe5da...` is admitted for one provenance-
only migration while retaining the original accepted ancestor and exact
mathematical-payload `SameQ` gate. Corrected source is 5,728 lines / 201,592
bytes / SHA-256
`897f28aad15069992e2c98f780ed31aef9d3e92cda3cdf23a811c987239bd734`;
Engine 15 reports complete-source `SyntaxQ=True`, and `git diff --check` passes.
The historical group-only certificate remains the accepted mathematical
certificate; no redundant 44-minute rerun is required for removal of
non-mathematical time limits. Full production and independent result reload
remain required.

Corrected-source production job `14533460` disproved the timeout-only diagnosis.
It ran source SHA-256 `897f28aa...` on `campus2.q@n7107` for 3,136.858 seconds,
exited at the application level with scheduler `failed=0`, and reproduced the
same negative-root basis-10 and basis-39 `valid=False` records followed by
`S10_FATAL: Hqg;qg Pg shared group function series failed.` Its new log is
1,046 lines / 107,518 bytes / SHA-256
`e8e0dcff62b5c8ab2a9d7d42b8a486ee8185019f0a34451d6a22e7a8471a20dc`;
no S10 result was published. Therefore evaluator v7 and source `897f28aa...`
are rejected for production, and removing the six `TimeConstrained` wrappers
is retained only as a deterministic-execution improvement, not as the complete
originating correction. The next implementation must reconcile the production
shared-function evaluator with the independently accepted exact 80-record
certificate specifically for negative-root dilogarithm bases 10 and 39 before
another production submission. S11--S13 remain blocked.

The next exact runtime difference is kernel-version-specific and
non-mathematical. The accepted 80-record/group certificate ran Wolfram Engine
15, while both Hoffman failures ran
`/u/local/apps/mathematica/13.1/Executables/WolframKernel`; Hoffman exposes
only Mathematica 12.1 and 13.1 modules. Inside the physical-root evaluator,
six exact `Series` operations were still wrapped in
`Quiet@Check[..., $Failed]`. In Mathematica, `Check` returns its failure value
when the evaluated expression emits a message, even if the returned exact
series could satisfy the explicit structural, order, reconstruction, and
cancellation gates. Provisional evaluator v8 replaces only those six wrappers
with `CheckAbort[Quiet[Series[...]], $Failed]`: messages are suppressed without
changing the returned mathematical object, a genuine abort still becomes
`$Failed`, and every existing exact validity gate remains authoritative.
Endpoint provenance advances to v12 with fresh
`s10_cache_v12_endpoint_{pg,pp}` paths. The three virtual caches produced by
job `14533460` are admitted only under exact source `897f28aa...`, measured
disk hashes `fd041bba...`, `1bdf7546...`, and `e2692af9...`, the complete
prior migration chain, and unchanged mathematical-payload `SameQ` validation.
The candidate source is 5,756 lines / 203,004 bytes / SHA-256
`552dd1e8dbad2c0423c674ff23763b90dd070b4f8cb6b40b4e4d8f9c82d5ec60`;
Engine 15 reports complete-source `SyntaxQ=True`. Its rebound no-write group
validator is 1,847 lines / 57,510 bytes / SHA-256
`194e68a15c4f18f781cbd523520edce26b186c9a5544cce4aea84e606145442e`
and also reports `SyntaxQ=True`. Runtime acceptance requires all 80 function
records and the complete two-sign group certificate under Hoffman Mathematica
13.1 before one full production rerun; until then this candidate is not an
accepted S10 result or consumer input.

That required Hoffman-13.1 gate rejected evaluator v8. Grid Engine job
`14535087` ran on `pod_smp.q@n6439` from `2026-08-25 01:32:14` through
`01:50:16 PDT`, with scheduler `failed=0`, application `exit_status=1`,
1,082.377 seconds wallclock, 1,074.600 seconds CPU, and 4.927 GiB maximum
virtual memory. Its 894-line / 101,073-byte log
`s10_pg_grouped_equation_series_hoffman13_v8.log` has SHA-256
`14cd8387daef198aa8bca4db58f75a6431bc12bc7ae8001a01e30c545ec0fa12`.
The complete log reports five rejected records: positive-root bases 10, 19,
and 25, plus negative-root bases 10 and 39, followed by terminal
`S10_PG_TERM1_DIAGNOSTIC_FATAL`. The earlier status based only on the terminal
tail captured the two negative-root failures and was incomplete. Therefore
changing the six wrappers from message-sensitive `Check` to `CheckAbort` did
not correct the demonstrated Mathematica-13.1 evaluator failure. Production
was not launched, no S10 result is accepted, and the next correction must
start from the exact per-record gate fields for all five records rather than
another unchanged-source rerun.

The existing no-write diagnostic now has a guarded
`HQG_S10_HOFFMAN_SUBGATES_ONLY=1` early-exit mode for that exact task. It
requires the accepted taxonomy and normalized-argument ledgers, rejected v8
gate log SHA-256 `14cd8387...`, and accepted Hoffman-13.1 native-order map log
SHA-256 `cd376841...`. It derives every failed list position and both root
observed sign subset from the rejected log, maps the native raw-argument hashes through the
taxonomy into the normalized basis, and evaluates only those tool-selected
dilogarithms. For each record it reports raw-series sufficiency, every
endpoint-Log argument/minimum-power/leading-coefficient/unit/replacement
sub-gate, final normalization, unresolved-Log count, and forbidden
representation freedom. It must exit without entering structural support or
writing an endpoint cache/result. After correcting its sign-scope parser to
evaluate the exact observed position/sign pairs, the modified diagnostic is
2,416 lines / 75,223 bytes / SHA-256
`42067a3c9834501c5e644418aec19f43662b8d5b860fc44559a4bbcadf1de19c`;
complete-source Engine 15 `SyntaxQ=True`. Runtime acceptance under Hoffman
Mathematica 13.1 was completed by Grid Engine job `14550184` on
`campus2.q@n7137`: scheduler `failed=0`, application `exit_status=0`,
558.598 seconds wallclock, and 1.917 GiB maximum virtual memory. Its 11-line /
9,067-byte log `s10_hoffman_function_subgates_v8.log` has SHA-256
`e5dca7b96c516e4feb38c92c9efc508913c5d54e8c840afe93fdf9cc4e8c9dfb`
and terminal marker `S10_HOFFMAN_FUNCTION_SUBGATES_COMPLETE`. For all five
tool-derived records, every endpoint-Log argument, leading-coefficient,
unit-series, replacement, unresolved-Log, and forbidden-representation gate
passed. The sole failed field was `seriesKnownThroughOrderQ` on normalized
results whose top-level head is `Plus`.

Evaluator v9 corrects that originating predicate without changing the
endpoint mathematics: a composite result is now accepted only when every
embedded `SeriesData` is in `S10EndpointT` about zero and extends beyond the
requested order, while the expression remaining after those series objects
are removed is independent of `S10EndpointT`. Endpoint caches advance to
version 13 and paths `s10_cache_v13_endpoint_{pg,pp}`, so rejected v12
endpoint work cannot be reused. The independent PaVe, scalar-master, and
virtual-Laurent caches remain eligible only through their existing exact
disk-SHA/provenance/type/mathematical-payload migration gates; the files on
Hoffman exactly match the already-coded third accepted migration hashes.
The corrected production source is 5,775 lines / 203,678 bytes / SHA-256
`7cc777181cc84cf4203da48d41019f33bfba288bb65d8520a5235f0f4f7acdc6`;
the source-bound diagnostic is 2,439 lines / 76,018 bytes / SHA-256
`f344ec97d1874c90ee78bdf8ec80e8d9ecc3b2790500bcc360864b5449d306e4`.
Verified Engine 15 reports complete-source `SyntaxQ=True` for both. Runtime
acceptance now requires the corrected five-record proof followed by the full
80-record/two-sign Hoffman-13.1 no-write gate before production submission.

The corrected five-record proof is accepted. Hoffman Grid Engine job
`14550321` ran on `campus2.q@n6046` with scheduler `failed=0`, application
`exit_status=0`, 517.714 seconds wallclock, and 1.917 GiB maximum virtual
memory. Its 11-line / 9,052-byte log
`s10_hoffman_function_subgates_v9.log` has SHA-256
`2130dd5d9660dd7a241a21f13409868286bf82f8c3ff55d0be1e78c9149db681`
and ends in `S10_HOFFMAN_FUNCTION_SUBGATES_COMPLETE`. All five exact failed
v8 records now have raw and normalized known-through-order gates true,
zero unresolved endpoint logs, forbidden-representation freedom, and
`FinalValid -> True`; the exact input/artifact no-write gate is also true.
The remaining pre-production acceptance boundary is the complete 80-record,
two-sign group-only Hoffman-13.1 gate.

The first complete evaluator-v9 gate is a no-write gate, not production.
Hoffman job `14550424` passed all 80 shared-function/sign records and then
exposed a separate performance boundary in the positive-root branch factor
ledger: it remained inside group position 32 before the corresponding
`TERM_TRANSFORM_DONE` marker while using essentially one CPU second per wall
second and about 5.01 GiB. The accepted native-order map derives group
position 32 as source index 42. Wolfram parsing of the accepted equation-type
ledger identifies source 42 as a 531,743-leaf / 13,771,056-byte five-factor
term (SHA-256 `3c72884a...`) with two `Plus` factors of 79,216 and 452,304
leaves, 3,217 half-integer root occurrences, nine logarithms, and two
dilogarithms. The roots reduce to the already-certified one-common-quadratic
physical-root basis. Thus the observed cost precedes any coefficient or
zero gate and is caused by globally inserting root polynomials and live
`SeriesData` jets into the huge additive factors.

The next evaluator contract defers that exact branch substitution without
changing the mathematics. Compressed factor skeletons retain only the
already-certified `S10CommonRoot` and shared-function placeholders through
factorization and hashing. `factorSeriesCoefficientData` splits a factor into
its exact top-level additive parts first, applies one dispatched physical-root
and shared-function substitution independently to those parts, proves that
no placeholder survives, and then uses the unchanged bounded series and
coefficient sum. The group remains combined before Laurent extraction; the
root equation, function jets, required orders, convolution, negative-power
and endpoint-log cancellations, two physical signs, analytic-continuation
objects, and source-immutability gates remain unchanged. This contract is
consistent with the paper's grouped `s23 -> 0` cancellation discussion and
Appendix E's exact logarithm/dilogarithm Feynman-prescription treatment. It
must pass a source-bound runtime equivalence/certificate gate before replacing
evaluator v9 for production.

Evaluator v10 implements that contract with endpoint-cache version 14 and
paths `s10_cache_v14_endpoint_{pg,pp}`. Its exact evaluator mathematics was
runtime-accepted under the former complete production-source identity
`ea92ac48df30d1292463a03ee6f36fd6d4b80cc3881aabc2c32255004fe665b8`.
The current source differs only in post-computation metadata assertions and
the exact migrations required to retain completed caches after that source
change. It held-parses under the verified Engine 15 as 407 expressions / 17,277
held leaves through exact EOF and is 6,002 lines / 213,457 bytes / SHA-256
`3a09a5627320f20db8f58deef4a9729946459fcda17030273089495649840926`.
The unchanged source-extracted no-write diagnostic is rebound to that identity
and is 2,439 lines / 76,018 bytes / SHA-256
`cef904492c381f6094a8b32aa921d93385f746cfc8b5c129c9506f15cecea373`.
Both complete files held-parse successfully and their focused whitespace
audit is clean.

That complete runtime gate is accepted. Hoffman job `14552058` ran the exact
source-extracted diagnostic under Mathematica 13.1 and ended with scheduler
`failed=0`, application `exit_status=0`, 6,150.530 seconds wallclock,
6,141.893 seconds CPU, and 5.919 GiB maximum virtual memory. The 1,921-line /
222,460-byte log has SHA-256
`4b62e0af9c91b3467851ec08e4c4cee8c04cfb3a357228cfffd93472cbb45bf4`
and ends `S10_PG_GROUP_SERIES_COMPLETE`. Both physical-root branches have
literal reconstruction, zero root residuals, all shared-function series
resolved, 160 unique factors, maximum required factor order 2, exact zero
negative-power and endpoint-log residuals, and exact zero grouped pole and
finite coefficients. The source and output namespace were unchanged and no
v14 endpoint cache, temporary publication, or result was created. Evaluator
v10 is therefore runtime-accepted for production; the three accepted virtual
caches remain reusable only through their existing exact disk-SHA,
provenance, type, and mathematical-payload gates.

Production job `14554474` then completed the full Pg alpha-two work, the same
accepted two-sign evaluator-v10 group, and all `70/70` Pg standard endpoint
terms before stopping at `Pg pre-individual grouped Laurent metadata is
incomplete`. Grid Engine recorded `failed=0`, application `exit_status=1`,
5,546.200 seconds wallclock, 8,337.980 seconds aggregate CPU, and 18.532 GiB
aggregate maximum virtual memory across seven processes. Its 2,175-line /
215,718-byte log has SHA-256
`3752bb4149b3f32a1d9fdca9201a909fc5a6ab7c44799c996ee8bd2058e82168`.
No PPP cache, temporary publication, or S10 result was produced. The sole new
artifact was the 69,788-byte `s10_cache_v14_endpoint_pg`, preserved locally as
`s10_cache_v14_endpoint_pg_recovery`, SHA-256
`8d6e117c53d489bf46ee4b9e0388f70295b1cfee77252c70e3f1d17e034c104c`.

Engine 15 inspected that exact association rather than inferring its shape:
there is one coupled-group Association, its `"SourceIndices"` field has 61
indices, the method ledger contains one group-leading record and 60 absorbed
records, and all 70 standard terms are complete. The failed assertion had
used `Length` on the group Association itself, obtaining its three key count;
the corrected assertion derives the expected absorbed count from
`Length /@ Lookup[groups, "SourceIndices"]`. A scan of every other group use
in the complete source found no second association/list mismatch.

Only that exact Pg checkpoint may cross the source-identity change. The
source-native migration requires both the old program SHA-256 above and the
exact cache disk SHA-256 above, validates the complete projector/group/method/
term schema, changes only program and migration-provenance keys through an
atomic write, reloads the file, and requires every non-metadata association
field to remain exact `SameQ`. Engine 15 extracted the actual migration
definition from the corrected source and executed it on a byte-identical
disposable copy: 70 terms, one 61-index group, expected absorbed count 60,
new source binding, and `MathematicalPayloadSameQ -> True` all passed. Because
no evaluator or mathematical expression changed, the accepted 6,150-second
two-sign gate is not repeated. A resume must consume the preserved Pg cache at
`70/70`, finalize Pg, compute PPP, and only then publish and independently
reload-validate S10.

The first corrected-source resume, job `14556061`, was dispatched on
`campus2.q@n7046` but exited at startup after 91.955 seconds with scheduler
`failed=0`, application `exit_status=1`, 83.408 CPU seconds, and 3.260 GiB
maximum virtual memory. Its 4,032-byte log has SHA-256
`d198d2f0b3d1f79cd57eb7327b592cd03e5a9b386bfe46420121318733fc4a33`
and stops at the PaVe-cache migration lineage gate, before any endpoint work.
The originating omission was that the source change also advanced the three
already-migrated virtual caches by one program identity. Their exact accepted
`ea92ac48...` generation is now recorded together: PaVe disk SHA-256
`cbd17459c7ddf1b782f0047a481831be404cdc86d98c94b38d98f07eb31d02cf`,
scalar-master disk SHA-256
`94229575151abb56a059cfd1e797318fd25974a7087adb75f820aec0d81a5f98`,
and Laurent disk SHA-256
`b0d8e18a9af40c09d62e511c2bc0c9db27ffcf719560cb783770625af8f1c2e2`.
Their textual headers and tails prove the exact old/current program lineage,
original accepted identities, and, for Laurent, embedded dependency hashes
equal to the current PaVe/scalar disk hashes. The existing migration routine
now admits this fourth lineage with all prior gates unchanged, migrates the
three caches in dependency order, refreshes only Laurent dependency metadata,
and proves every remaining field exact `SameQ` before continuing.

A complete current-program cache-binding scan found no unhandled reusable
class: virtual progress/subpart caches are absent; the three final virtual
caches are covered by that exact fourth-generation migration; the sole Pg
endpoint cache is covered by its separate exact `8d6e117c...` migration; PPP
cache and result are absent; and S09 expansion caches remain correctly bound
to the accepted S09 program rather than S10. No calculation or mathematical
payload changed in job `14556061`.

The candidate source uses stage `HqgS10-v6` and result schema 2. Before
performing any symbolic operation it must validate the exact accepted S09-v5
result and source identity, both finalized S09 cache paths and disk SHA-256
values, the S09 cache schema and exact projector metadata, the accepted
S08-v5 and S07-v5 source/result identities embedded in S09, and the common
paper SHA-256. It must take the real Pg/PPP expressions only from those two
S09 caches and take the LO and symbolic virtual projector pair separately
from accepted S07. The three mathematically upstream virtual caches may migrate
from the exactly measured prior program identity only when their exact disk
SHA-256, type/version, and S07--S09 lineage all match; migration may change only
program/provenance metadata, must atomically reload, and must prove the
mathematical association unchanged by exact `SameQ`. No endpoint cache and no
other legacy stage, program hash, input hash, cache, or migration exception is
admissible.

For Hoffman execution, the source must remain portable as one self-contained
remote `Hqg_s10` directory. It searches that directory first for a bundled
`Applications` tree, the paper, the accepted S07/S08/S09 sources/results, and
the two accepted S09 expanded-real caches. Relocation is filename-based only:
the program must still require the exact accepted SHA-256 identities and the
original embedded metadata paths/hashes before consuming a colocated copy.
Grid Engine `NSLOTS` is the sole remote worker-allocation input; one slot is
reserved for the parent and at most eight workers are launched. Mathematica
13.1 uses its native localhost kernel launch, whereas Engine 15 retains the
verified explicit local-kernel configuration. The parent alone writes and
reload-validates caches and results. The submit entry point must allow the
tool-validated campus/shared queue families `campus2.q`, `pod_smp.q`, and
`inter_smp.q` without a hostname pin, and request seven shared slots, 6 GiB
per slot, a four-hour maximum, one main Mathematica license with six parallel-subkernel licenses
(`ma=1,ms=6`), and one native BLAS/OpenMP thread per process. It must honor the immediately measured
`myresources` eligibility without adding unauthorized `exclusive` or `highp`
resources.
No additional shell or process address-space ceiling is imposed on the
cluster job; the accurately requested Grid Engine memory resources remain the
scheduler-enforced allocation.
The active scheduling contract was tightened after job `14533460` remained
queued under the former 24-hour / 8-GiB-per-slot reservation. Hoffman2's
official scheduling policy states that excessive resource and walltime
requests delay dispatch and defeat backfilling; the preceding failed
production measured `maxvmem=18.281G` and reached its late Pg boundary in
2,099.538 seconds. The durable entry point therefore requests seven shared
slots, 6 GiB per slot, a four-hour maximum, `ma=1,ms=6`, and the same three
unpinned authorized queue families. Live job `14533460` dispatched on
`campus2.q@n7107` at `2026-08-24 22:31:16 PDT` under that resource contract.

The executable Grid Engine entry point is `s10_hoffman_submit.sh`: 33 lines /
729 bytes, mode 755, SHA-256
`216e0613e63b4f83c158f2aaa4545493d41b4cece046a3484214263af484b22f`.
It passes `bash -n` and `git diff --check`, sets `LC_ALL=C`, loads the Hoffman
`mathematica` module, exports its discovered kernel through
`HQG_WOLFRAM_KERNEL`, changes to `$HOME/Hqg_s10`, and invokes only the exact
corrected S10 source. It contains no `ulimit` or equivalent process-memory
restriction.
The first final-production submission, job `14527781`, remained queued while
the prior entry point omitted Hoffman's required Mathematica license resources;
the scheduler did not expose whether that omission caused the delay. The job
never started and produced no log or artifact. It was deleted and replaced by
job `14530241`. The initial corrected license record still requested nine
8-GiB slots, or 72 GiB on one host. A live free-node audit found multiple idle
16-core `campus2.q` hosts with only 62.9 GiB physical RAM, proving that width
could not fit them. The queued job was altered in place to `campus2.q`, seven
slots, and `ma=1,ms=6`, retaining its job ID and queue age; it dispatched in
the next scheduler cycle to `n6136` at `2026-08-24 18:56:29 PDT`.

Replacement production job `14533098` ultimately dispatched to
`pod_smp.q@n7442` after its hard hostname restriction was removed, but it
exited one at the application level after 355.055 seconds.  Its preserved
24-line / 5,209-byte log has SHA-256
`c03fe6fee591830e15fcfa602dd920471d0a031613e521046add92aa7c09ed30`
and ends at `S10_FATAL: The virtual Laurent cache is invalid.`  The run had
already migrated the PaVe, scalar-master, and Laurent caches in that order.
This exposed a provenance-only migration defect: updating the first two
cache files changes their disk hashes, while the Laurent migration retained
their old embedded hashes and the subsequent validator correctly rejected
that stale dependency binding.  The originating correction must accept only
the exact original cache lineage or the exact first-migration lineage from
job `14533098`, retain the original lineage in the migration record, refresh
only the Laurent cache's PaVe/scalar path and SHA-256 metadata, prove all
remaining mathematical payload is unchanged under exact `SameQ`, and gate
the refreshed hashes against the migrated dependency files.  No endpoint
cache or S10 result was produced.  This corrected source remains a production
candidate until a fresh full run and independent reload validation succeed.

The task-scoped strict-host-verification file is
`s10_hoffman_known_hosts`: 1 line / 108 bytes, SHA-256
`300b05bd3aaee2a36f8bf002e0121c2bcef4db554adeb23919ae043bec4b9809`.
`ssh-keygen -E sha256` measures its DTN ED25519 fingerprint as
`SHA256:lZdo2eNOmwgroOyCOXXFFdQjfQQA1vMpBxgwhGwirwY`, exactly matching the
official Hoffman2 public-host fingerprint. It is used only for strict SFTP
verification and does not modify global SSH configuration.
The task-scoped login-host binding is
`s10_hoffman_login_known_hosts`: 1 line / 104 bytes, SHA-256
`c96be192328256441d44a7a9dda442fbc8cfeaea14b484920b8bc4346e36178b`.
It binds `hoffman2.idre.ucla.edu` to the same ED25519 public key, and an
independent `ssh-keygen -E sha256` check reproduces the same official
fingerprint exactly. It is used only with explicit strict SSH options; no
global SSH configuration is inspected or changed.

The virtual branch must remain analytic and symbolic. Package-X must evaluate
every distinct `PaVe` and direct scalar master discovered in the accepted S07
virtual expressions, using analytic continuation, implicit prefactor one,
and separate UV/IR regulators. The program must derive and record the exact
integral inventories and their content hashes at runtime; it must not assert
copied channel counts or a copied master list. It must remove inherited
symbolic counterterms, insert the explicitly defined QCD constants exactly
once through the tool-validated LO multiplier, prove UV cancellation, match
the accepted two-body LO normalization, and obtain the Laurent coefficients
through epsilon order zero with bounded resumable work. Every production
cache must be atomically written, immediately reloaded, content-validated,
and bound to the exact current program and accepted inputs.

For each real projector the program must identify the factored endpoint
structure, derive every exceptional epsilon-dependent power and every
root-coupled endpoint candidate from the current expression, and resolve the
ordinary and exceptional endpoint Laurent data in deterministic bounded
batches. Coupled groups must be discovered from exact structural signatures
and accepted only after both physical square-root branches independently
show cancellation of every positive `Log[s23]` power; copied source-term
indices are forbidden. The program must prove the stronger endpoint pole
vanishes through the order needed for its finite S10 action, act every delta
and plus distribution on an arbitrary symbolic test function over
`0 <= s23 <= B(xi)`, and leave no S09 distribution placeholder.

The finalized endpoint caches keep each resolved real symbolic test-function
action once, and the finalized virtual Laurent cache keeps the virtual pair
once. The compact S10 result must retain exact cache paths and finalized file
hashes, endpoint and virtual inventories, an exact real-plus-virtual action
reconstruction definition, inherited charge/state/dimensional bookkeeping,
computed checks, and explicit downstream deferrals; it must not duplicate
any large action or cache payload. Before success it must pass a source-native
compactness predicate, exact result reload, disk-cache binding, stable result
SHA-256, post-publication temporary cleanup, and immutable source/paper/S07-
S09 identity gates. S10 must not apply Eq. (46) PDF/FF
factorization, claim real-virtual/factorization pole cancellation, take the
finite hard-part limit, apply the physical flavor luminosity, extract
Eq. (9), or compare with BigTMD; those operations remain downstream.

The pre-contract source `HqgS09-v3` is rejected at origin: it requires
obsolete S08-v4; transcribes inventories/formulae without the required tool
proofs; imports the inconsistent F9 epsilon term; does not expand the actual
`(1,2,1-epsilon)` hypergeometric object; chooses endpoint placeholders by a
resource heuristic; weakly validates caches; duplicates large payloads; and
fills final checks with literal `True`. No S09 artifact exists from that
source, so the invalidation currently affects source only.

### Superseded production lineage and remaining regeneration boundary

The S01 source correction above changes the originating source provenance.
Consequently, the previously accepted generated S01 artifact and every
S04/S05 artifact bound to it are no longer accepted, even where their
mathematical payload may ultimately reproduce. The following exact files were
deleted before corrected production started and can be recovered only by
regeneration from the retained sources:

- `s01_result`, SHA-256
  `aecd2f8fadfa79e6d05cf466e05d1236a31cb744f46f4ee3162141b01963cd2c`;
- `s01_production.log`, SHA-256
  `de87255fe4b8d51eb205fa42f68bb28d5cf1f9321bb087ecc52c2b673bfdc281`;
- `s04_result`, SHA-256
  `7adc189c2f02e60c0203cf5c25f447512bdfce726d01c823e4b06c6415c3cd2e`;
- `s04_production.log`, SHA-256
  `a008aa0696cc1a327c5185861f0db1824aac15394de445d4fe04b74fdfa28c08`;
- `s05_result`, SHA-256
  `f6580e3ff817f2158bb70ee1f3299d0041a1c103a2f782033f91874f42c166c8`;
- `s05_virtual_full_tid_cache`, SHA-256
  `016852ade6ee6837fe1f3359f1a89994a3dd5f6baf1649736be8e06aeb1e677e`;
- `s05_production.log`, SHA-256
  `a53d031154a779659619869a9f497908f74c81de55768aed0bb8688fb2de0c60`;
- `s05_independent_validation.log`, SHA-256
  `ab6f9bf18a27faf6d99e42edcfb70597511a407eb34c3e05804121c36c21e5a7`.

Repaired S01-v3, S04-v3, S05-v4, S06-v4, S07-v5, S08-v5, and S09-v5 above
are accepted. There is currently no accepted corrected S10-S13 production
result. The current S10 production source and resume assets remain available;
the top-level S11-S13 sources were removed by explicit user request. Any later
restoration requires dependency-order regeneration and independent validation.

### Local S10 cleanup boundary

The user-authorized 2026-08-26 cleanup retains exactly these top-level S10
production/resume files:

- `s10_complete_virtual_endpoints_hqg.wl`, SHA-256
  `3a09a5627320f20db8f58deef4a9729946459fcda17030273089495649840926`;
- `s10_cache_v14_endpoint_pg_recovery`, SHA-256
  `8d6e117c53d489bf46ee4b9e0388f70295b1cfee77252c70e3f1d17e034c104c`;
- `s10_hoffman_submit.sh`, SHA-256
  `216e0613e63b4f83c158f2aaa4545493d41b4cece046a3484214263af484b22f`;
- `s10_hoffman_known_hosts`, SHA-256
  `300b05bd3aaee2a36f8bf002e0121c2bcef4db554adeb23919ae043bec4b9809`;
- `s10_hoffman_login_known_hosts`, SHA-256
  `c96be192328256441d44a7a9dda442fbc8cfeaea14b484920b8bc4346e36178b`.

The main source and submit entry point are the exact final production code;
the recovery checkpoint is the accepted 70/70 Pg cache consumed by the final
resume lineage; and the host-key files remain necessary for strict monitoring
and retrieval. All other 36 top-level `s10*` diagnostic, failed-run,
preflight, probe, and diagnostic-submit artifacts (2,515,061 bytes), plus the
four top-level S11-S13 source/helper files (148,706 bytes), were deleted.
Historical filenames earlier in this ledger remain provenance records and no
longer imply local file presence. The separate accepted
`madgraph_check/` S10-S12 pipeline was not changed. Live execution state
remains exclusively in `../progress.md`.

## Stage and dependency boundaries

- S01 is the only amplitude-generation origin and must derive the model
  charge before converting/stripping amplitudes.
- S04 depends on corrected S01 but is not a tree-level MadGraph comparison
  input; it is required because the established S05 container also includes
  the virtual-interference branch.
- S05 must apply the saved strip factor to every regenerated full external
  amplitude, including the real tree used by the check. Immediately after
  `FCFAConvert`, it must canonicalize every `FeynArts`-context `FCGV` head to
  `FeynCalc` `FCGV` before stripping, TID caching, or bilinear construction;
  its v4 cache validator must reject any legacy `FeynArts` `FCGV` payload.
- S06 and S07 are the mathematical local inputs to the bare-tree MadGraph
  check. S06 must consume the accepted S05-v4 result above and preserve its
  corrected S01/S04 provenance; it must not consume an older S05 result or
  the v4 TID cache directly. S07 must consume only an independently accepted
  corrected S06-v4 result.
- Accepted S08 performs phase-space/angular integration and the xi/s23
  transformation. S09-S13 perform endpoint, subtraction, factorization, and
  F-hat extraction work. They are not mathematical inputs to the bare-tree
  MadGraph comparison, but the user's expanded correctness scope requires
  them to be audited and, where invalidated, regenerated in dependency order
  from the independently accepted S08 handoff.
- S02/S03 are visualization-only. Their preserved pages/PDF do not certify
  amplitude normalization and are not inputs to the MadGraph check.

## Hqg MadGraph check contract

The isolated check lives in `madgraph_check/` and follows the accepted
Hqqbar/Hqqprime comparison boundary. Before implementation or execution it
must satisfy this contract:

1. Copy corrected S01, S06, and S07 source/result inputs byte-for-byte into
   `madgraph_check/upstream_copies/`, record SHA-256 identities, and refuse a
   mixed or stale lineage.
2. Generate the full electron process corresponding to the Hqg real tree,
   `e- u -> e- g u g`, with the required QED/QCD orders. Process ordering,
   diagram count, PDG order, incoming helicity/color averages, generated
   `IDEN`, and identical-final-state divisor must be measured from the
   generated MadGraph artifact and never copied from another channel.
3. Compile a bridge to the generated standalone matrix element and validate
   that bridge against an independent direct generated-program reference at
   multiple deterministic physical points.
4. Build the local full electron matrix element from the copied corrected
   Hqg real tensor exactly once: restore the model-derived representative
   charge, add the spin-averaged electron tensor, the second electromagnetic
   vertex, and photon propagator, and preserve S06's physical real-gluon
   state convention.
5. Resolve the two identical final gluons by the generated identity metadata
   and a fixed-orientation pointwise equality. The observed `g(k1)` remains
   labeled locally; no symmetry or multiplicity factor may be guessed.
6. Validate the fixed-orientation local/MadGraph equality after routing and
   convention alignment.
7. At fixed hadronic invariants, evaluate four equally spaced lepton-plane
   rotations and require the resulting average to agree with the Pg/PPP
   projection reconstructed from copied S07.
8. Export a compact four-dimensional unit-coupling local invariant evaluator
   only after the symbolic point/projection gates pass.
9. Generate one deterministic 120,000-trial massless four-body RAMBO sample
   with NumPy PCG64 seed `2026081801`; derive phase-space normalization and
   every process normalization from defining code relations and generated
   metadata; apply the same accepted infrared-safe common-bin cuts on both
   sides.
10. Evaluate local and MadGraph values on identical accepted rows, integrate
    the correlated bin, and require pointwise/sample/bin agreement within the
    established numerical tolerances.

The accepted common-bin cut contract inherited as an algorithm from the two
reference checks is:

```text
0.08 <= Q2/s <= 0.40
0.25 <= sHat/s <= 0.75
min(sij/sHat) >= 0.05
min(-ui/(sHat+Q2)) >= 0.05
min(-ti/(sHat+2 Q2)) >= 0.03
```

These cut values and the deterministic RNG contract are validation settings,
not Hqg physics results. The Hqg diagram inventory, symmetry metadata,
accepted-row count, matrix-element values, and integrated result must all be
produced by the Hqg tool run and recorded here only after acceptance.

## Consumer rules

- Never consume an Hqg result merely because its internal checks are `True`;
  require the corrected source/result hashes recorded in this ledger.
- Never use the invalid S01-v2/S04-v2/S05-v3/S06-v3/S07-v3 normalization
  lineage.
- Never reintroduce the old four-polarization S06 real-gluon prescription.
- Never fold the physical flavor-charge luminosity into a charge-stripped
  partonic hard kernel or apply it twice.
- The MadGraph check validates the corrected four-dimensional bare real tree;
  it does not validate virtual, endpoint, subtraction, or factorization
  stages.
