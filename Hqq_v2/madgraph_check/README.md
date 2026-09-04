# Hqq_v2 unintegrated-real MadGraph check

## Scope

This directory independently checks the accepted Hqq_v2 tree-level real
emission tensors in `../s02_result.wl` against MadGraph5_aMC@NLO at a common
physical massless phase-space point.  It is a read-only downstream check: no
accepted Hqq_v2 source, result, or cache is modified or regenerated.

This is the part of the workflow for which MadGraph is directly appropriate.
MadGraph supplies independent four-dimensional squared matrix elements before
the paper-specific S04 phase-space integration, S05 endpoint expansion, S06
virtual-master evaluation, and S07 MS-bar factorization.  It is therefore not
used as a direct evaluator of the distribution-valued final S08 `F1Hat` and
`F2Hat`.

The physics authority is
`../../Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`.
Live status is recorded only in `../../progress.md` with the exact tag
`[Hqq_v2, people or agents working on other channels should ignore]`.

## Fixed process map

| Hqq_v2 real family | FeynArts representative | MadGraph process |
|---|---|---|
| `Hqq;gg` | `gamma* u -> u g g` | `e- u > e- u g g / z h QED=2 QCD=2` |
| `Hqq;q_qbar_sameFlavor` | `gamma* u -> u u u~` | `e- u > e- u u u~ / z h QED=2 QCD=2` |
| `Hqq;qPrime_qbarPrime` | `gamma* u -> u d d~` | `e- u > e- u d d~ / z h QED=2 QCD=2` |

The third process intentionally uses `d d~`: Hqq_v2 S01 defines its
different-flavor representative with `F[4,{1}]`, and the accepted charge
ledger identifies that field as down type.  No later flavor-multiplicity sum
is included in this representative-level check.

## Generator and normalization contract

- Generator: the already installed official MG5_aMC 3.7.0 entry point at
  `../../Hqqbar/madgraph_check/software/MG5_aMC_v3_7_0/bin/mg5_aMC`, SHA-256
  `d51e70db5c95fb72df985760819a0733c9bdb2401de3b27995d53788d2050a74`.
  The accepted installation manifest SHA-256 is
  `ffb2f66933097f3103c096c369c94963cddea5cbcc32c73932c7519f832f615c`.
- Hqq_v2 inputs are `../s01_result.wl` SHA-256
  `83a4643632beb6a2c8383ba2634e37b4a5cd033827ba92374f849d0a5b5d9911`
  and `../s02_result.wl` SHA-256
  `316c6e18b49bd7c446506fc866546d0c998f6d61cec3c3813693cbf72b735c83`.
- S02 tensors already contain the incoming-quark spin/color average
  `1/(2 SUNN)`.  The local reconstruction supplies the spin-averaged electron
  tensor and the electron-side photon factor `e^2/Q^4`.
- The local up/down charges are read from the accepted S01 charge ledger.  The
  strong and electromagnetic couplings are read from the generated MadGraph
  parameter card.
- MadGraph's final-identical divisor is converted to the local labeled-state
  convention by a factor derived from repeated final-state PDGs.  This gives
  no hand-entered symmetry factor in the comparison program.
- The fixed benchmark is constructed by the programs from its defining
  massless four-vectors.  Conservation, masslessness, spacelike photon
  virtuality, diagram counts, PDGs, direct generated-routine closure, and
  identical-particle exchange symmetry are executable gates.
- A disagreement is a valid completed check result and is reported without
  altering either side.

## Stage contracts

1. `s01_generate_hqq_v2_standalone.mg5` generates the three photon-only
   standalone MadGraph processes under `generated_process/`.
2. `s02_madgraph_c_bridge.f90` exposes the generated dispatcher through a
   minimal ISO-C initialization/evaluation interface and is compiled
   to `s02_libhqq_v2_madgraph_bridge.so` against the generated
   `liball_2me.so`.
3. `s03_evaluate_madgraph_reference.py` hash-validates the generated inputs,
   parses metadata from the generated Fortran, evaluates the bridge and direct
   generated routines at the benchmark, derives identical-state factors from
   PDGs and the spin/color factors from `IDEN`, and atomically writes
   `s03_madgraph_reference.json`.
4. `s04_compare_hqq_v2_real_tensors.wl` hash-validates S01/S02/S03, contracts
   each accepted Hqq_v2 real tensor with FeynCalc at the same benchmark, and
   atomically writes `s04_local_vs_madgraph.json` and
   `s04_local_vs_madgraph.md`.

## Status

Production generation and comparison are complete.

### Accepted artifact identities

- S01 generation card SHA-256:
  `4b285a44cd7c2a7951c5c7e8a6c54b772407e27c88835637cf835d12b1d3e016`;
  generation-log SHA-256:
  `74a21bb432a3926af08a3d5a3662c8513ba8ff8f912dd1e6f23cb2acddf69199`.
  MadGraph generated 20 diagrams with family counts `8/8/4`.
- The generated process tree contains 107 files and 1,160,661 bytes.  The
  SHA-256 of the sorted records `relative-path NUL file-SHA256 newline` is
  `ffcce7a072098ee2bb56a407990d36ec9dec1e4df2f1388988aa250f2749fa01`.
  In particular, `all_matrix.f` has SHA-256
  `13764a16588bce5678cf4866aef9434e8abe4fde437e30c411ed50f2b274d56e`;
  the three `matrix.f` hashes are
  `0120dfd14d7743c02ec36fafa9bc0f06d602ff0c896af83e5deafcae6b6a1962`,
  `aceeb6caaed7ea57aafd34348a36ceafaffdd1b2cbeb230ced19417d1f49bd77`,
  and
  `76baa973586f9b2d90e45ed9e9dff57e0dbc2f966f79fc6f91d4fbb86bb849c8`.
- S02 bridge-source SHA-256:
  `35b3262b79f301dce3342e46a89eb0fafa171fa9be9c1bb46a782ec3b8e9db01`;
  generated `liball_2me.so` SHA-256:
  `1295bb0b67009747184d329706b5e7e67030fc0cd1f673f2f54e9c0d54cb3491`;
  bridge-library SHA-256:
  `7004a082805d69e4a3ac751530d8f1f15fea74eacd1d7c7e88ca47a79edb3b30`.
  The generated-library and strict bridge-compile log hashes are
  `07db20d5eacab83b1282d8a7d6b721f96fe7c50965f66b99a3390b6289a5c42e`
  and
  `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
- S03 source SHA-256:
  `1e2d6ce4cafed9b1f1d00ef5f6cad936792611364d8941d50fb1e49b4d7a489b`;
  `s03_madgraph_reference.json` SHA-256:
  `90fa221e5d423109d78b1570b9cec2193b94ba2dbed2301d3455b478c6406baf`;
  log SHA-256:
  `2e0c29b1ab01064726494ad3202687d2c9f9f934ef5888b27dacdd11dec8bdd7`.
  All 16 reference gates pass, including exact floating direct/bridge
  closure for every process.
- S04 source SHA-256:
  `8ce45b029812b4dc810072078240186e4ff6346155e1e7a7d646d45a3e71fd9a`;
  `s04_local_vs_madgraph.json` SHA-256:
  `867d0b8108ef2b248417cb4e8c4df4b59cc7d430f9c81acf7acc89526233b215`;
  `s04_local_vs_madgraph.md` SHA-256:
  `fbbb90e917797aca913e94c04f9cf257c2bed60ebb8bebd02592cf5bfd95ece1`;
  log SHA-256:
  `667752774a93d134e5cd38bcb7efcd5049db01ce4f857ca670659eaa08ae4b28`.
  Independent reload validation passes all 16 structural gates and all three
  comparison records.

### Result

All three unintegrated real-emission families agree within
`abs(local-MadGraph) <= 1e-20 + 1e-9 max(abs(local),abs(MadGraph))`:

| Family | Relative difference | Result |
|---|---:|:---:|
| `Hqq;gg` | `4.7894450549967675e-16` | pass |
| `Hqq;q_qbar_sameFlavor` | `5.716947383231899e-16` | pass |
| `Hqq;qPrime_qbarPrime` | `5.367995950182366e-16` | pass |

The maximum absolute difference is `4.1359030627651384e-25`; the maximum
relative difference is `5.716947383231899e-16`.  The detailed signed
comparison is `s04_local_vs_madgraph.md`.  No accepted parent Hqq_v2 artifact
was changed.  The folder contains 121 files and 1,256,601 bytes, with no
temporary file, Python bytecode, or `__pycache__` residue.

S04 remains serial because it uses one shared FeynCalc scalar-product state;
replicating the 54 MiB accepted tensor artifact into subkernels would add
serialization and state risk for only three contractions.
