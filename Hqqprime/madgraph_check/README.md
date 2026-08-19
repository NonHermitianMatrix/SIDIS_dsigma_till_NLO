# Hqqprime MadGraph tree-real check

## Scope

This isolated workflow compares the accepted Hqqprime real-emission objects
before phase-space integration with the photon-only process

`e- u -> e- c u c~`.

The local ordered hadronic state is fragmenting `c(k1)`, unobserved `u(k2)`,
and unobserved `cbar(k3)`. Generated PDG order must be measured and mapped to
that local order. Z and Higgs exchange are excluded.

Only byte-identical copies of accepted Hqqprime S01, S06, and S07 sources and
results may be mathematical inputs. Parent artifacts are read-only. Raw
S08/S10, factorization S11/S12, finite S13 F hats, and the separate BigTMD
benchmark are not inputs to this bare-tree comparison.

## Bookkeeping

- Copied S06 already contains final fermion spin/color sums and the
  incoming-quark `1/(2 Nc)` average.
- Copied S01 supplies the current representative, diagram inventory, and SM
  charges used to combine the three separate incoming-squared,
  prime-squared, and mixed tensors coherently.
- Copied S07 supplies charge-resolved Pg and PPP projections.
- The local full-process reconstruction adds the spin-averaged electron
  tensor, electron vertex, and photon propagator once.
- The final particles are distinct and the local final-state factor is one.
  The generated `IDEN` and diagram count are derived and measured in this
  workflow, not copied from another channel.
- Physical ordered-flavour summation remains deferred; this check uses one
  incoming-up/prime-charm representative.

## Reused software

The workflow reuses the pinned MG5_aMC 3.7.0 executable and `six.py` under
`scripts/Hqqbar/madgraph_check` without downloading, reinstalling, or
modifying them. All Hqqprime generation commands, generated code, samples,
results, and logs remain in this directory.

## Stage map

1. `s01_prepare_inputs.py`: copy and hash-bind accepted inputs and reused
   dependencies.
2. `s02_generate_hqqprime_standalone.mg5`: generate the isolated photon-only
   standalone process.
3. `s03_madgraph_c_bridge.f90`: expose generated evaluation and metadata.
4. `s04_direct_madgraph_reference.f90`: evaluate the generated routine
   directly at one deterministic physical point.
5. `s05_validate_madgraph_bridge.py`: validate direct/bridge identity and
   process/kinematic/normalization metadata.
6. `s06_inspect_copied_s07_schema.wl`: validate the local projection schema.
7. `s07_validate_local_matrix_element.wl`: test the fixed-orientation tensor
   and Pg/PPP reconstruction.
8. `s08_validate_azimuthal_average.py`: test the four-angle projected value.
9. `s09_build_four_dimensional_evaluator.wl`: build the compact local
   invariant evaluator.
10. `s10_generate_cut_bin_madgraph.py`: generate and evaluate the common
    deterministic cut sample.
11. `s11_evaluate_local_cut_bin.wl`: evaluate the local expression on the
    identical accepted rows.
12. `s12_integrate_common_cut_bin.py`: form the correlated integrated
    comparison.

No redundant final reconstruction or second production sample is part of
this sequence.

## Current status

S01 is complete and accepted:

- `s01_prepare_inputs.py`, SHA-256
  `074f3c660a4ea5426d3caad543ecdf62a696eb391402adb3761da974e71dded7`,
  6,990 bytes / 204 lines;
- `s01_input_manifest.json`, SHA-256
  `6addb9b9c330e0a2bc60abfb84f12fbf19aef0c5fb0bd582ed2666ea880f6dc1`,
  4,625 bytes;
- `s01_prepare_inputs.log`, SHA-256
  `1f9cafb85127774274da39898d305afa8f90cb196fc0aed68664dfd0e4545a6a`,
  241 bytes.

All six files under `upstream_copies/` are byte-identical to their pinned
parent sources/results, and both reused dependencies match their accepted
hashes. S01 left diagram count, generated PDG order, and `IDEN` unresolved for
current-channel measurement.

S02 generation and the direct Fortran shared library are accepted:

- `s02_generate_hqqprime_standalone.mg5`, SHA-256
  `42ed29707ec12ade4466a6130676cc0fc924f5557ab847bf5cf0e31629be794f`;
- generation log SHA-256
  `d0a951b7c0725a0021c4af1b4b76685aaaa50fe80b34f5e10e94d644af1a6de9`;
- generated process card SHA-256
  `75be20bdcfc89b4ff655627f0466187e1f225f04ee8c7da6d754cc992c88fb59`;
- generated `SubProcesses/all_matrix.f` SHA-256
  `0a7ed053e605f861bb8a61df21c28c31cd5194e37df80531d7e5140d12c1df9b`;
- generated subprocess `matrix.f` SHA-256
  `bb29686e959a0f24fa0021f3e6efce4d2d0f5e6c8b9497d84ca95f0e7f3c2cf3`;
- generated `SubProcesses/liball_2me.so` SHA-256
  `011ef000feab6271fe50debd6a8be7bd7a71586664b7cce13b949e971db29231`,
  164,848 bytes.

The current tool derivation matched copied-S01 and generated diagram counts
at `4`, measured generated PDGs `{11,2,11,4,2,-4}`, derived a unit final-PDG
identity divisor, and matched derived/generated `IDEN` at `12`. The local
ordering maps directly to generated final positions as `c(k1),u(k2),cbar(k3)`.

The optional f2py wrapper selected meson under Python >=3.12 and failed because
meson is not installed, exactly as in the accepted Hqqbar workflow. The valid
direct library compiled and exports all matrix/initialization symbols needed
by S03. Its diagnostic compile log has SHA-256
`19429b8ad167bfb5bf1c6bd9ee9cc1905693bee22d57d350bf016456c9e78aa1`.
No failed-wrapper temporary survived, and no extra dependency is installed.

S03-S05 are complete and accepted:

- S03 source / bridge SHA-256:
  `8d30b5448bdedccb8095eb5eaf69b4f46c09bb09c2d7ca069bd5fa444c64a753` /
  `847bfb7a3ef4498cdf7040e01e0e51ed7b38864025be646f0cfd7f1a580e8b5d`;
- S04 source / direct executable / direct log SHA-256:
  `65a118edbf42d13998b3644cfa11f5204af1ca6cd8ce6bca23da8f4608a78503` /
  `6cb6d04e6f611c4ec74392bc000ac56857d6e6a9e471ab9dd3e4d0343e5417f9` /
  `1c239b0a7ef0b9f32a14de7ffaa6dcfd00042933e5183bf283c9653cf9e07de4`;
- final corrected S05 source / successful log / validation JSON SHA-256:
  `68a072312cd779edc6e21630f9f6959f4449ead22ef53235f04b494b837e3099` /
  `34d613f161cc835ba9b7b236e02236a9145a8d68eaf911cf310da361d358bf03` /
  `95191bfbfa5b804f2e38cc0837cc908198fe1d92ba0e605ad56fd12bf4a8384d`.

The two strict compile logs are empty, SHA-256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`,
which records warning-free builds. S05 freshly derived the copied metadata,
matched all current generated routing/count/normalization gates, and obtained
exact bridge/direct equality at matrix value
`2.80437830246103206e-10`. Its two pre-matrix stdout-transport failures wrote
no result; the accepted log contains only the successful final invocation.

S06 local schema inspection is complete and accepted:

- source SHA-256
  `cefced1a0bc574c166beaed9b5ea93c8e4370bc53f20ecdba6229a4f609e5169`,
  3,777 bytes / 131 lines;
- log SHA-256
  `021fd0e5f1c5caf2950ec0f4624e3ff21522793f1b7100bd8ef843f4c1b83b54`,
  7,665 bytes / 60 lines.

The copied result matched `HqqprimeS07-v1`, schema 1, channel
`Hqqprime only`, exact projector order `{Pg,PPP}`, and exact charge order
`{IncomingChargeSquared,PrimeChargeSquared,MixedIncomingPrimeCharge}` under
both projectors. All six payloads retained inert `FeynAmpDenominator`
representations, `SMP["g_s"]` / `FCGV["EL"]`, exactly one
`ScaleMu^(4 epsilon)` power, and no machine reals. The log ends in
`S06_SUCCESS`; it is the sole S06 output, matching the accepted Hqqbar method.

S07 local matrix-element validation is corrected, regenerated, and accepted:

- source SHA-256
  `9022e35ef9e4c6dd9aab121cf680a0d1b6c8b8c67457d7b37ba770c26ef3c5ad`,
  20,673 bytes / 629 lines;
- canonical log SHA-256
  `807864aebc155b4c9ac4655721b711bab81eb90e1a0a02a9d627c413a481bee0`,
  2,699 bytes / 22 lines;
- result SHA-256
  `79cf7e55218025f35c601c5e08a688644347f227ecd3061aa9d95b03608b9b00`,
  3,926 bytes / 98 lines.

The program derived both physical charges as `2/3` from copied S01, parsed
the current generated parameter card, kept all three charge tensors separate
through their fresh S06-versus-copied-S07 Pg/PPP tests, and obtained zero
reported relative difference for all six projection comparisons. The
coherent physical copied-S06 fixed-orientation matrix was
`2.8043783024610337560...e-10`; the labeled MadGraph value was
`2.804378302461032e-10`, for relative difference
`5.530507946006608e-16`. S08 exposed a missing explicit multiplication sign
across a newline in the first S07 run's projected leptonic `PPP` coefficient;
that old result was deleted and is not an accepted input. The corrected run
preserved every tensor/projector gate and produced projected local matrix
`2.9608497009543090e-10`. S08 is now pinned to the corrected result hash.

S08 azimuthal-average validation is complete and accepted:

- source SHA-256
  `c1230b70ab07ef9137107576253fa42f06e6a99f169e053de9afc49154a84d45`,
  11,237 bytes / 289 lines;
- canonical successful log SHA-256
  `e5e77460dba74c9cc6495c7a356516c9b0fdcb17eb30bdb61393c7980612615d`,
  282 bytes / 5 lines;
- result SHA-256
  `c869f3fa105253fb7aa6994fc21c29d696260e5087cbf322a767f00083670cfe`,
  1,912 bytes / 48 lines.

The four labeled MadGraph values average to
`2.96084970095431556e-10`; corrected S07 gives
`2.96084970095430884e-10`, for relative difference
`2.26990328986545530e-15`. Rest-frame, conservation, masslessness, fixed
photon, zero-angle, and average checks all passed; the atomically reloaded
JSON and terminal `S08_SUCCESS` are the acceptance evidence. The failed
predecessor run wrote no JSON, and its diagnostic log was replaced by this
successful canonical log.

S09 compact four-dimensional evaluator construction is complete and accepted:

- source SHA-256
  `20974e815a97fe6d196a0fdc66a5b2772236779f8d8871f0b6fb9e9fbcb6a640`,
  14,522 bytes / 460 lines;
- log SHA-256
  `0eb9f1c2d33f2a430ab7401f19b3945ea82e431642c710f0183a782f9e86ef2a`,
  508 bytes / 9 lines;
- evaluator-result SHA-256
  `51cb470c5309e06a8122dc48612078967a13b06710ff2b0784e553f755165722`,
  20,490 bytes / 327 lines.

Wolfram solved the scalar products from the six defining invariants, mapped
all six charge/projector payloads, retained them in the result, and compiled
the physical copied-S01 up/charm combination. Physical unit-expression leaf
counts are Pg `2214` and PPP `523`. After applying the accepted couplings, the
compiled benchmark reproduced corrected S07 Pg/PPP with relative differences
`7.529564249051622e-15` and `1.0717819016445564e-15`. The atomically reloaded
all-true result and terminal `S09_SUCCESS` are the acceptance evidence.

S10 deterministic common cut-bin generation is complete and accepted:

- source SHA-256
  `73cbfc2434d3ef0dbaac971871b21ef54f3d22a237c775c18e64fae1a6096ad7`,
  17,992 bytes / 483 lines;
- log SHA-256
  `142eddee1683eee49e7e16f6ea15fbda8914d309d724ee0c7832780ad70ae9d5`,
  913 bytes / 20 lines;
- CSV SHA-256
  `acffeddd2c9c5d0da793cf192648dc5f8d093a7265d9b3d6234df7656e81ffdb`,
  5,430,996 bytes / 27,852 lines;
- metadata SHA-256
  `ac6a208789613ffc39a2eca5a9c7a6ee3017d75e1388a6ca68252aeb30721350`,
  2,352 bytes / 62 lines.

The fixed seed/cuts accepted 27,851 of 120,000 trials. All accepted rows were
evaluated with four Hqqprime bridge angles in direct generated/local order
`c(k1),u(k2),cbar(k3)`. The metadata reload matched the accepted count and CSV
hash. The intermediate MadGraph estimate is
`3.47132831771248661e-4 pb` with sampling error
`6.64949731879813145e-6 pb`; S12, not S10, is the final correlated comparison.

S11 local evaluation on the identical accepted rows is corrected and
accepted:

- source SHA-256
  `72c0dcca68c57fd864942cd02a3864dbf8ac4b8afdd4e40171c33b688f57d1fc`,
  12,666 bytes / 367 lines;
- successful canonical log SHA-256
  `a589630e30ca02de0886110dbd30af3752ef54e478681c00506325a12dc820f3`,
  436 bytes / 8 lines;
- pointwise CSV SHA-256
  `15d1fc2fa1bad06ddeaccecaed55d7627b3915e2bbe8140fc6e48e32c1e91f28`,
  6,203,245 bytes / 27,852 lines;
- summary JSON SHA-256
  `27bd819e827041825c440449231f784797c8ac716c676d32561702beaf080ceb`,
  1,801 bytes / 39 lines.

The first S11 execution used division instead of multiplication in the
defining `g_s=sqrt(4 pi alpha_s)` and stopped before writing outputs. That
single originating operator was corrected; no upstream artifact changed.
The successful run evaluated all 27,851 rows and obtained maximum/mean/median/
99th-percentile relative differences
`2.1785777046371065e-11`, `8.484978726621331e-15`,
`2.7475033404301907e-15`, and `6.705715431613466e-14`. Its atomically reloaded
all-true JSON and terminal `S11_SUCCESS` are the acceptance evidence.

S12 correlated common-bin integration is complete and accepted:

- source SHA-256
  `467929e82f13750f6d05de8de3475949dfd9f2c933c7655c01dff6d73e80efd9`,
  10,773 bytes / 285 lines;
- log SHA-256
  `4753cb6029f05410263f1378d8ad91556fd250d6ef1e7229c574b2fd1b49dc89`,
  331 bytes / 7 lines;
- final result SHA-256
  `26a315d504b7c01974c91b9a7f5b431317eff03cf283f7e9ce3628192548082b`,
  2,560 bytes / 57 lines.

With rejected trials retained as zeros and the common S10 measure/flux/unit
factor, the final tool output is:

- MadGraph: `3.47132831771248661e-4 pb`;
- local copied-Hqqprime projection: `3.47132831771248499e-4 pb`;
- MadGraph sampling error: `6.64949731879813145e-6 pb`;
- local minus MadGraph: `-1.97877397902372727e-19 pb`;
- integrated relative difference: `5.70033657988215510e-16`;
- paired sample correlation: `1.00000000000000000`.

All embedded hash/count/reconstruction/metadata/integrated/correlation checks
passed, the temporary JSON reloaded all true, and the log ends in
`S12_SUCCESS`. This is the authorized terminal artifact. No redundant S13
reconstruction, validator, or second sample is part of Hqqprime's workflow.

## Final status

Hqqprime MadGraph S01-S12 are complete and accepted. The accepted comparison
is the physical incoming-up/fragmenting-charm representative only; the
separate physical ordered-flavour sum remains outside this check, exactly as
stated in the scope and bookkeeping sections above.
