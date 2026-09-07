# Hqqprime channel ledger

## Scope and authority

This directory is the incoming-quark, fragmenting-different-flavor-quark
channel. The physics authority is
`../Large_Transverse_Momentum_in_Semi-Inclusive_Deeply_Inelastic_Scattering_Beyond_Lowest_Order.pdf`.
The only live status record is `../progress.md`; this README records durable
conventions, stage contracts, accepted artifact identities, and downstream
boundaries.

Paper Eq. (33) assigns the first hard-part index to the incoming flavor, the
second to the fragmenting flavor, and indices after the semicolon to unobserved
partons. Fig. 2(R-E) and Table I therefore define this channel as
`H_{q qPrime};q qbarPrime`, with `qPrime` different from `q`. It has no virtual
partner and first contributes through a tree `2 -> 3` process to the
`O(alpha_s^2)` hard part.

## Fixed channel conventions

- Incoming fields/momenta: `{gamma*(q), q(p)}`.
- Ordered outgoing fields/momenta:
  `{qPrime(k1), q(k2), qbarPrime(k3)}`.
- `k1` is always the fragmenting momentum.
- All quarks are massless and amplitudes are converted in
  `D = 4 - 2 epsilon` dimensions.
- S01 retains the electromagnetic coupling and separates the two linear
  charge amplitudes: photon attachment to the incoming-flavor line and photon
  attachment to the different-flavor pair line.
- A generic amplitude is retained as
  `Qq * AIncoming + QqPrime * APrimePair`, where `Qq` and `QqPrime` are
  dimensionless quark charges in units of the electromagnetic coupling.
  This preserves the distinct `e_q^2`, `e_qPrime^2`, and
  `e_q e_qPrime` structures required by paper Table II.
- No equal-charge multiplicity or flavor sum is applied in S01. Any later
  active-flavor assembly must retain the three charge tensors separately.

## S01 contract: generate the real amplitude and charge basis

The source/result/log identities are:

- `s01_calculate_hqqprime_tree.wl`;
- `s01_result`;
- `s01_calculate_hqqprime_tree.log`.

S01 must use FeynArts with the `SMQCD` model at particle insertion level. It
must generate all tree `2 -> 3` diagrams and select only amplitudes whose
tool-measured coupling signature contains one electromagnetic and two strong
couplings. It must not hard-code a diagram count copied from another channel.

To prevent charge collapse, S01 must generate three independent massless
representatives in the same momentum order:

1. incoming up type / different-generation up type;
2. incoming up type / down type;
3. incoming down type / up type.

The `F[3]` and `F[4]` electric charges must be extracted from the loaded SMQCD
class metadata. Mathematica `Solve` must derive `AIncoming` and `APrimePair`
from the first two representative sums. The unused third representative is an
independent hard gate: its reconstruction residual must be exact zero.

S01 acceptance requires all of the following tool checks:

- authoritative paper and source hashes are recorded;
- each representative has a nonempty selected diagram set, every selected raw
  amplitude has exactly the requested coupling signature, and all three
  measured selected counts agree;
- every selected amplitude converts with FeynCalc, remains nonzero, is
  massless and `D` dimensional, and contains no UV/IR regulator or loop
  momentum;
- incoming, fragmenting, and unobserved field/momentum order is saved
  explicitly and the two flavors are distinct in every representative;
- SMQCD charge metadata is found, its two coefficients are distinct, and the
  two-component solve succeeds;
- up/up, up/down, and independent down/up reconstruction residuals are all
  exact zero;
- both charge-basis amplitudes are nonzero and the generic symbolic amplitude
  reproduces each representative after substituting its tool-derived charges;
- the result is written atomically, reloaded independently, has status
  `Complete`, and has every saved check true.

The three representatives are processed serially. FeynArts/FeynCalc model
initialization and diagram generation use shared global state, so local
parallel kernels are not used for this small S01 stage; parallel execution
would not provide a safely demonstrated benefit.

## Accepted S01 artifacts and evidence

S01 is independently accepted with these exact identities:

- source: `s01_calculate_hqqprime_tree.wl`, SHA-256
  `17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4`;
- result: `s01_result`, SHA-256
  `842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b`;
- production log: `s01_calculate_hqqprime_tree.log`, SHA-256
  `0b521dbdab587f9d1103795698bfe7638c56dff530e5c02eaac4d374eb90ce44`;
- authoritative paper: the PDF named above, SHA-256
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.

No cache is created by S01. The rejected first-run log was deleted before the
clean corrected run, and no `s01_result.tmp.*` file remains.

The accepted tool run and separate read-only validator established:

- exactly four selected `{e^1, g_s^2}` diagrams for each of the up/up,
  up/down, and down/up representatives, with selected-number, raw-amplitude,
  and converted-amplitude lengths equal in every case;
- model-derived normalized charge coefficients `UpType -> 2/3` and
  `DownType -> -1/3`;
- two nonzero charge-basis amplitudes, with diagnostic leaf counts `537` and
  `351`;
- exact-zero direct and generic reconstruction residuals for all three
  representatives, including the unused down/up validation representative;
- correct different-flavor field order, `{q,p}` incoming and `{k1,k2,k3}`
  outgoing momentum order, massless `D`-dimensional converted amplitudes, and
  no loop momentum or UV/IR regulator objects;
- all saved checks true, all 18 independent validation gates true, exactly
  one production success marker, shell exit `0`, and no fatal, timeout, OOM,
  kill, or abort marker.

Wolfram serialization reloads the coupling placeholders inside the saved
diagnostic raw amplitudes as ``FeynCalc`FCGV["EL"]`` and ``Global`FAGS``, rather
than their production-time FeynArts contexts. The independent validator
identified these reloaded symbols and remeasured coupling powers `{1,2}` for
every raw diagram. Downstream calculations must consume the saved converted
amplitudes or charge-basis amplitudes; they must not infer coupling powers by
assuming production-time contexts for the diagnostic raw expressions.

## S02 contract: export the accepted diagram record

The S02 identities are:

- source: `s02_export_hqqprime_diagrams_postscript.wl`;
- result manifest: `s02_result`;
- production log: `s02_export_hqqprime_diagrams_postscript.log`;
- rendered pages: `.s02_ghostscript/pages/s02_page_NNN.ps`.

S02 is a visualization/provenance stage only. It must hash-bind the accepted
S01 source and result, reload `s01_result`, require its complete Hqqprime S01
identity and saved checks, and process the representative order `up_up`,
`up_down`, `down_up`. For every representative it must verify the saved
different-flavor field/momentum ordering, require a valid stored FeynArts
diagram container, and regenerate amplitudes from that container to prove the
regenerated count equals the saved selected count.

S02 must obtain diagram and page counts from the current artifact. It must not
copy numeric counts from Hqq or another channel. Each representative is
painted separately with its label and the generic paper process
`gamma* q -> qPrime q qbarPrime`. Every captured page must be a
`FeynArtsGraphics` object, and every rendered sheet must be a nonempty native
PostScript string beginning with `%!PS-Adobe`.

Pages must first be written to a process-specific temporary directory. S02
must verify their exact filenames, sizes, headers, and SHA-256 hashes; write
and reload an atomic `s02_result` manifest containing S01 provenance,
representative counts, page ownership/order, page hashes, and all acceptance
checks; and only then publish the final page directory and manifest. A clean
production launch must refuse to overwrite an existing S02 result or final
page directory.

The accepted no-write probe measured four diagrams and one rendered sheet for
each of the three representatives, but production S02 must remeasure and gate
these values itself. Painting remains serial because FeynArts uses shared
global state and this small rendering stage has no safely demonstrated
parallel benefit.

### Accepted S02 artifacts and evidence

S02 is independently accepted with these exact identities:

- source: `s02_export_hqqprime_diagrams_postscript.wl`, SHA-256
  `1af7043dd1530bf19ea72f0261add1a3773f92a1bee9b418e87f29b2e3fd2132`;
- result manifest: `s02_result`, SHA-256
  `2ff55677e07fbf4108e88c3e9e33606e920376e755c57e10e766df8793d3c26d`;
- production log: `s02_export_hqqprime_diagrams_postscript.log`, SHA-256
  `87819e34a585cb3a24ece64d84b1c39040e67f8f299d51b674e721ccf9d55d63`;
- page 001 (`up_up`): SHA-256
  `80dbf50748e338f4f2b681d1109d1ca201d43d8debf80ff71542530a422bd820`,
  10,763 bytes;
- page 002 (`up_down`): SHA-256
  `1acf2dd5756c906e942d8f174434ca5e72930d41fb3d539cadb6e49507911b25`,
  10,765 bytes;
- page 003 (`down_up`): SHA-256
  `b4c4801423adba773045f36c26bf4fa25e780b86ac114e65b64b7c525151a4da`,
  10,765 bytes.

Production and the separate validator both regenerated diagram counts
`<|up_up -> 4, up_down -> 4, down_up -> 4|>` from the stored FeynArts
containers and found one page per representative. All 13 independent manifest
gates passed. Ghostscript parsed every exact page successfully with the
bundled runtime environment, and raster inspection confirmed four complete
diagrams on each page with the expected page-specific flavour labels. The
disposable raster previews were deleted; the three accepted PostScript pages
remain the complete S03 input and provenance record. No S02 temporary artifact
remains.

## S03 contract: convert the accepted pages to PDF

The S03 identities are:

- source: `s03_convert_hqqprime_diagrams_pdf.sh`;
- PDF: `s03_hqqprime_feynman_diagrams.pdf`;
- production log: `s03_convert_hqqprime_diagrams_pdf.log`.

S03 may be implemented only after S02 is independently accepted. Its source
must bind the accepted S02 result and exact ordered page hashes, reject any
missing, extra, empty, reordered, or changed page, and require a successful
S02 production log. It must reuse only the generic Ghostscript runtime at
`../Hqq/.s02_ghostscript/runtime`, validate all PostScript inputs, write a
process-specific temporary PDF, validate that PDF with Ghostscript, verify its
page count equals the accepted S02 input-page count, and atomically publish the
final PDF without silently overwriting an existing result.

S03 performs no diagram generation or physics transformation. It changes only
the visualization container from ordered PostScript sheets to one PDF. The
accepted S02 pages remain production/provenance inputs and must not be deleted
after conversion.

The now-accepted S03 input binding is the `s02_result` SHA-256 and ordered
three-page SHA-256 list recorded in the accepted S02 ledger above. S03 must
also require the S02 source and log hashes recorded there.

### Accepted S03 artifacts and evidence

S03 is independently accepted with these exact identities:

- source: `s03_convert_hqqprime_diagrams_pdf.sh`, SHA-256
  `d1269bc57c31cfb02bd0ef585b6f79cd320e780614f1dceed2c0505c6ba060be`;
- production log: `s03_convert_hqqprime_diagrams_pdf.log`, SHA-256
  `7689920510aea75095ed5300ed43a213cc5765960447d7c983dd975ab74cca4f`;
- PDF: `s03_hqqprime_feynman_diagrams.pdf`, SHA-256
  `5bc89565eabcb9403e550a8889cce102eb1bf81d2d7ba9751ef7f50d95c4f12e`,
  30,312 bytes, PDF 1.7, three pages.

Production and independent validation both established that all accepted S02
dependencies were unchanged, all three PostScript inputs parsed, the temporary
and final PDF parsed, the PDF page count equals the ordered input count, the
log has exactly one success marker and shell exit zero, and no partial output
remains. The conversion used the bundled Ghostscript 10.02.1 runtime.

An intentionally stronger raster check found that separately rendered source
and PDF PNG files are not byte-identical. Engine 15 decoded them and bounded
the difference on every page to the same 293 of 1,938,816 pixels: 138 removed
black pixels and 155 added black pixels. Every changed pixel has counterpart
black geometry within one raster pixel in the opposite render. Direct visual
inspection confirmed that all diagrams, ordering, topology, arrows, numbering,
and flavour labels are preserved. This is accepted as uniform one-pixel vector
edge quantization during PostScript-to-PDF conversion, not content loss. The
disposable comparison rasters were deleted after validation.

## Downstream boundary

S01 produces amplitudes and charge provenance only. It performs no bilinear,
spin/color sum, polarization sum, incoming average, projector contraction,
phase-space integration, subtraction, flavor sum, or fragmentation
multiplicity. Later stages must consume the saved ordered momentum convention
and the two charge amplitudes without collapsing them. After loading
`s01_result` into `s01Result`, the accepted consumer entries are
`s01Result["ChargeBasis", "IncomingLineAmplitude"]`,
`s01Result["ChargeBasis", "PrimePairLineAmplitude"]`, and
`s01Result["ChargeBasis", "GenericAmplitudeSum"]`, with generic charge symbols
recorded in `s01Result["ChargeBasis", "GenericChargeSymbols"]`. A later stage
must verify the source and result hashes above before use and keep the
`e_q^2`, `e_qPrime^2`, and `e_q e_qPrime` structures separate.

S02 and S03 are not amplitude consumers for later physics stages. Their
PostScript/PDF artifacts are human-readable diagram records only; no later
bilinear, projector, phase-space, or subtraction stage may use them in place
of `s01_result`.

## S04 contract: certify virtual-sector absence

The S04 identities are:

- source: `s04_validate_hqqprime_virtual_absence.wl`;
- result: `s04_result`;
- production log: `s04_validate_hqqprime_virtual_absence.log`.

This is a required bookkeeping gate, not a virtual calculation. The paper's
Table-I classification and Figure-2 channel definition place Hqqprime first
at the tree `2 -> 3` contribution to the `O(alpha_s^2)` hard part, with no
two-body Born/one-loop partner in this channel at that order. S04 must encode
that absence unambiguously so a later combiner cannot mistake a missing file
for an omitted calculation.

S04 consumes only the accepted S01 source/result and authoritative reference
PDF at these exact SHA-256 identities:

- S01 source:
  `17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4`;
- S01 result:
  `842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b`;
- reference PDF:
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.

The S02 PostScript manifest/pages and S03 PDF are explicitly non-input
visualization products. S04 must not depend on, modify, or reproduce them.

Before publishing a result, S04 must independently require all of the
following from the hash-pinned S01 record:

1. exact `HqqprimeS01-v1`, `Hqqprime only`, `Complete` identity and all saved
   S01 checks equal to literal `True`;
2. the recorded tree `2 -> 3`, `O(alpha_s^2)` process, ordered
   `{q,p} -> {k1,k2,k3}` routing, `k1` fragmenting different-flavour quark,
   ordered unobserved `{q,qbarPrime}`, massless `D=4-2 epsilon` convention,
   retained electromagnetic coupling, amplitude strong-coupling power two,
   and no applied flavour multiplicity;
3. exact ordered representative set `up_up`, `up_down`, `down_up`; distinct
   incoming/prime field classes; nonempty selected sets; equality of every
   stored count with the corresponding measured diagram/amplitude-list
   lengths; and exact equality of every per-diagram converted-amplitude total
   with its stored sum;
4. exact two-component charge bookkeeping: distinct generic charge symbols,
   nonzero incoming-line and prime-pair line amplitudes, the expanded generic
   identity, and exact zero reconstruction residuals for every saved rational
   SMQCD charge assignment, including the independent `down_up` gate;
5. exact symbolic purity of the converted real payload: no machine reals and
   no loop-integral, loop-momentum, UV/IR-regulator, or scale symbols; and
6. absence throughout S01 of any two-body Born, virtual-amplitude,
   one-loop, pole, or UV-counterterm payload key.

The result must be a compact audit record and must not duplicate raw diagrams
or amplitudes. It must identify its disposition as
`NotApplicableAtThisOrder`, record the absent two-body Born, one-loop virtual,
loop-pole, and UV-counterterm contributions as exact integer zeros, and state
that those zeros mean structurally absent contributions rather than evaluated
zero expressions. It must retain measured representative/count summaries,
charge-basis leaf counts, exact zero residual summaries, and complete pinned
source/reference provenance. Publication must use a process-specific temporary
file, reload and validate it, atomically rename it, refuse silent overwrite,
and leave no temporary artifact.

S04 performs no diagram or amplitude generation, conjugation, bilinear,
spin/color/polarization sum, incoming average, projector, phase-space
integration, subtraction, factorization, scale operation, flavour sum, or
charge-tensor collapse. S05 remains the first stage authorized to form the
real-amplitude bilinear while preserving the separate `e_q^2`,
`e_qPrime^2`, and `e_q e_qPrime` structures.

### Accepted S04 artifacts and evidence

S04 is independently accepted with these exact identities:

- source: `s04_validate_hqqprime_virtual_absence.wl`, SHA-256
  `9d9d75d1105e46173fca63077e2b1779532cdece8fab592e6fba5d403e1cfcbc`;
- result: `s04_result`, SHA-256
  `2691d382f27986cd821218ea5730c4b25a259755dc5eb7a5fd61babad10cbe84`,
  4,607 bytes;
- production log: `s04_validate_hqqprime_virtual_absence.log`, SHA-256
  `2aea9a322e4597f3ad269c9f27b698f99afe4b4ac05a713c183a551dc193bf16`.

Production exited zero with exactly one `S04_SUCCESS`, no fatal/warning/abort
marker, and no process-specific temporary result. A fresh Engine-15 validator
rehash-bound the source, S01 result, and paper; reloaded both results; and
independently repeated every identity, convention, representative, exact
charge reconstruction, symbolic-purity, virtual-key-absence, compactness, and
downstream-boundary gate.

The accepted `s04_result` has stage disposition
`NotApplicableAtThisOrder`. Its `AbsentContributions` association contains
exact integer zero for `TwoBodyBorn`, `OneLoopVirtual`, `LoopPole`, and
`UVCounterterm`; these values mean structurally absent/not-applicable sectors,
not evaluated zero virtual expressions. The independently reproduced real
audit is `up_up -> 4`, `up_down -> 4`, `down_up -> 4`; all per-diagram totals
and both representative residual ledgers are exact. The charge-basis leaf
counts are 537 for the incoming-line amplitude, 351 for the prime-pair
amplitude, and 897 for the generic sum.

Compactness validators must inspect values and serialized contexts rather than
rejecting summary labels by name alone. `RepresentativeListLengths` uses
labels such as `SelectedDiagrams` with integer count values, and
`ChargeBasisLeafCounts` uses amplitude names with integer leaf-count values.
The accepted result contains none of the three actual S01 amplitude
expressions, no FeynArts/FeynCalc symbol context, and no topology, insertion,
or amplitude payload. A first name-only independent predicate rejected these
required labels; the corrected type- and context-aware validator passed, and
production required no modification or rerun.

S05 must hash-validate and consume `s01_result` for the actual real amplitudes,
and may consume `s04_result` only as the virtual-absence/bookkeeping gate. It
must preserve all three charge tensors. S04 does not authorize any projector,
phase-space, factorization, subtraction, scale, or flavour-multiplicity step.

## S05 contract: form the charge-resolved real bilinear

The S05 identities are:

- source: `s05_form_hqqprime_real_bilinear.wl`;
- result: `s05_result`;
- production log: `s05_form_hqqprime_real_bilinear.log`.

S05 is the first squared-amplitude stage. It consumes only the accepted S01
amplitude record and accepted S04 virtual-absence gate at these exact
SHA-256 identities:

- S01 source:
  `17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4`;
- S01 result:
  `842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b`;
- S04 source:
  `9d9d75d1105e46173fca63077e2b1779532cdece8fab592e6fba5d403e1cfcbc`;
- S04 result:
  `2691d382f27986cd821218ea5730c4b25a259755dc5eb7a5fd61babad10cbe84`;
- authoritative paper:
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.

S02 and S03 remain visualization-only non-inputs. S04 must be complete,
`HqqprimeS04-v1`, and `NotApplicableAtThisOrder`, with exact integer-zero
absence entries for the two-body Born, one-loop virtual, loop-pole, and UV
counterterm sectors.

S05 must perform these tool-checked operations in order:

1. Require the complete accepted `HqqprimeS01-v1` identity, conventions,
   representative order, all-true checks, exact measured count ledger, and
   two-charge reconstruction. Use only each representative's accepted
   `SelectedDiagrams` container.
2. Regenerate all three representative sets with FeynArts
   `CreateFeynAmp[...,Truncated->False]`, then use FeynCalc with the accepted
   `{q,p}->{k1,k2,k3}`, massless, D-dimensional, no-loop convention. Require
   every regenerated count to equal its measured S01 count and every full
   diagram to contain exactly one electromagnetic and two strong vertices.
3. Require exactly the four tool-measured full-state spinors
   `Spinor[Momentum[k1,D],0,1]`,
   `Spinor[-Momentum[k3,D],0,1]`,
   `Spinor[Momentum[k2,D],0,1]`, and
   `Spinor[Momentum[p,D],0,1]` for every representative. These preserve the
   fragmenting `qPrime(k1)`, unobserved `qbarPrime(k3)`, unobserved `q(k2)`,
   and incoming `q(p)` orientations for S06.
4. Use Wolfram `Solve` and the exact S01 SMQCD charge assignments to derive
   the full incoming-line and prime-pair amplitudes from `up_up` and
   `up_down`. Require both basis amplitudes nonzero and independently require
   exact-zero full-amplitude reconstruction for all three representatives,
   including the unused `down_up` gate.
5. Coherently sum before multiplication. Open only the incoming photon into
   `s05Mu`; use the complete accepted photon-opening map for slashed
   polarization, both scalar-product orders, Lorentz-pair, and epsilon-tensor
   occurrences. Require exact-zero opened-amplitude reconstruction for every
   representative and preserve all external spinors.
6. Form evaluated, dummy-index-renamed conjugates with photon index `s05Nu`.
   From the two open charge-basis amplitudes, construct and store separately:
   the incoming-line squared tensor, the prime-pair squared tensor, and the
   mixed tensor defined by the sum of both ordered cross products. Wolfram
   must expand the generic real-charge polynomial and prove exact
   reconstruction with coefficients `Qq^2`, `QqPrime^2`, and
   `Qq QqPrime`. No relative sign may be inserted from memory or copied from
   another channel.
7. Derive the coherent ordered-pair count from the measured current-channel
   diagram count. For a physical representative, the accepted probe measured
   four diagrams and therefore the program must itself derive and gate the
   corresponding ordered-pair count rather than transcribe it.
8. Derive the dimensional scale factor inside Wolfram from S01's saved
   strong-coupling power using the established dimensionless-renormalized
   coupling convention. The accepted probe produced exactly
   ``FeynCalc`ScaleMu^(4 epsilon)``. Attach that factor once to each of the
   three charge tensors and the generic tensor; add no separate MS-bar
   `S_epsilon` at S05.
9. Derive final-state multiplicities from every saved outgoing-field list.
   The accepted probe produced exact symmetry factor `1` for all three
   representatives: `qPrime`, `q`, and `qbarPrime` are distinct final-state
   identities, so no nontrivial identical-particle factor is applied or
   deferred for this channel.
10. Reject photon polarization from every opened amplitude, conjugate, and
    bilinear tensor; the retained pre-opening full amplitudes intentionally
    keep it as external-state provenance. Reject unevaluated conjugation,
    loop or UV/IR objects, premature spin/color/projector operations, and
    machine numbers from their applicable payloads. Atomically write and
    exact-reload `s05_result`, refuse silent overwrite, and create no cache.

The result must retain the full representative amplitudes for provenance,
the full and open two-component charge basis, both conjugates, the three
unscaled and scale-attached charge tensors, a generic polynomial
reconstruction, the exact residual ledgers, and all source/input hashes. Its
virtual-interference entry is exact integer zero inherited from S04 and means
absence, not a computed cancellation.

S05 applies no fermion spin/color sum, Dirac trace, incoming average,
projector contraction, phase-space factor or integration, subtraction,
factorization, physical charge/flavour sum, or fragmentation multiplicity.
The ordered physical sum over `q` and `qPrime != q` remains deferred and must
retain all three charge tensors; it must not be replaced by a bare `Nf` or
`Nf-1` factor at S05. S06 must process each scale-attached charge tensor
separately, sum the four external fermion spin/color states, and apply exactly
the incoming-quark average `1/(2 Nc)` while preserving `s05Mu,s05Nu`.

The three representative regenerations remain serial. FeynArts/FeynCalc use
shared model and index state, and each physical amplitude must be coherently
summed before its product; this small stage has no safely demonstrated
parallel benefit and needs no production cache.

### Accepted S05 artifacts and evidence

S05 is complete and independently accepted with this exact artifact ledger:

- source `s05_form_hqqprime_real_bilinear.wl`: SHA-256
  `95a405581e6b5c9f24af44b513895cfa42c6524c097bc23e624de5c8df1c66f5`,
  42,908 bytes;
- result `s05_result`: SHA-256
  `d78577388379acf513733d6d21e85a30ab34200a1a35e7b7605e6241bfbfdec7`,
  127,367 bytes;
- production log `s05_form_hqqprime_real_bilinear.log`: SHA-256
  `41401a464f33c0e82ff99e1a4eb1c3a6c7cdae94094fccf42665187289e52432`,
  4,085 bytes.

The verified Engine 15 production run exited `0`, atomically wrote and exactly
reloaded schema `HqqprimeS05-v1`, printed exactly one `S05_SUCCESS`, and
reported all 35 saved checks true. The log has no `S05_FATAL`, abort,
termination, kill, out-of-memory, or timeout marker. Its only non-stage
notices are the standard FeynCalc/FeynArts banners, the known FeynArts
protected-`Discard` notice, and the known `FCGV` context-shadowing notice;
these did not accompany a calculation failure.

The production tool reported and the fresh independent kernel reproduced:

- full representative counts `up_up -> 4`, `up_down -> 4`, and
  `down_up -> 4`, with 16 coherently ordered diagram pairs;
- exactly the four recorded external spinor orientations and derived
  final-state symmetry factor `1` for every representative;
- the separately retained tensor keys `IncomingChargeSquared`,
  `PrimeChargeSquared`, and `MixedIncomingPrimeCharge`, with unscaled leaf
  counts 371, 361, and 733 respectively;
- exact-zero full/open representative residuals, coefficient-extraction
  residuals, and generic three-charge-structure reconstruction residual;
- the scale factor ``FeynCalc`ScaleMu^(4 epsilon)`` derived from two copies of
  the saved two-strong-vertex amplitude, with no separate MS-bar
  `S_epsilon`;
- exact virtual contribution zero with the S04 meaning
  `NotApplicableAtThisOrder`, rather than a calculated virtual cancellation.

For independent acceptance, a fresh Engine 15/FeynCalc/FeynArts kernel loaded
only the accepted S01 and S04 inputs, regenerated all 12 full per-diagram
amplitudes, solved and gated the two-component charge basis, opened the photon
index, evaluated both conjugates, and rederived the direct and
coefficient-extracted tensors before loading the published S05 artifact.
Literal equality then passed for every saved amplitude, basis component,
conjugate, tensor, scale attachment, and residual ledger. The independent run
also passed the open-index, spinor-retention, exact-symbolic, no-loop, and all
deferred-operation gates and ended with `S05_VALIDATION_OK`.

The exact S05 inventory is the declared source, result, and log only. There is
no S05 cache, temporary result, runner, monitor, or persistent validator file.
The three representative regenerations were kept serial because their shared
FeynArts/FeynCalc model and generated-index state has no demonstrated safe
parallel benefit at this size.

S06 must consume each entry of
`ChargeResolvedBilinears/ScaleAttachedChargeTensors` separately. It must sum
all four external fermion spin/color states and then apply exactly the single
incoming-quark average `1/(2 Nc)`, while preserving `s05Mu`, `s05Nu`, and all
three charge structures. It must not add a virtual term, symmetry factor,
physical flavour/charge sum, projector contraction, phase-space operation, or
factorization operation. Those latter operations remain explicitly deferred
to their contracted downstream stages.

## S06 contract: fermion spin/color sums and incoming-quark average

The S06 identities are:

- source: `s06_spin_color_sum_average_hqqprime.wl`;
- result: `s06_result`;
- production log: `s06_spin_color_sum_average_hqqprime.log`;
- per-charge post-Dirac caches:
  `s06_cache_hqqprime_<charge-key>_after_dirac`;
- per-charge final caches:
  `s06_cache_hqqprime_<charge-key>_spin_color`.

S06 has one and only one mathematical input collection: the three entries of
the accepted
`s05_result["ChargeResolvedBilinears","ScaleAttachedChargeTensors"]`.
It must pin these exact inputs before any algebra:

- S05 source SHA-256
  `95a405581e6b5c9f24af44b513895cfa42c6524c097bc23e624de5c8df1c66f5`;
- S05 result SHA-256
  `d78577388379acf513733d6d21e85a30ab34200a1a35e7b7605e6241bfbfdec7`;
- authoritative paper SHA-256
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.

The S01 and S04 source/result identities inherited inside S05 must also match
their accepted ledger values. S02 and S03 remain visualization-only
non-inputs.

S06 must perform and gate these operations:

1. Require complete `HqqprimeS05-v1` status, all 35 saved checks, exact
   S01/S04/paper provenance, the accepted different-flavour external-state
   order, absent virtual branch, no applied physical flavour sum, no applied
   incoming average, and the exact three ordered charge keys
   `IncomingChargeSquared`, `PrimeChargeSquared`, and
   `MixedIncomingPrimeCharge`.
2. For every key, require exactly the four external spinor orientations
   `Spinor[Momentum[k1,D],0,1]`,
   `Spinor[-Momentum[k3,D],0,1]`,
   `Spinor[Momentum[k2,D],0,1]`, and
   `Spinor[Momentum[p,D],0,1]`; both open photon indices `s05Mu,s05Nu`;
   explicit fundamental-color data; no photon polarization; and exactly one
   absolute ``FeynCalc`ScaleMu^(4 epsilon)`` factor.
3. Install the same exact massless D-dimensional three-body scalar products
   in terms of `sHat`, `ti`, `ui`, and `sij`. Do not impose a phase-space
   parametrization, conservation elimination, numerical point, or `D -> 4`.
4. Apply FeynCalc `FermionSpinSum` separately to each complete charge tensor,
   summing the incoming `q(p)` and all three final fermions
   `qPrime(k1),q(k2),qbarPrime(k3)`. Evaluate every D-dimensional Dirac trace
   exactly. There is no external gluon and therefore no gluon-polarization
   sum; the virtual-photon indices remain open.
5. Apply FeynCalc color algebra to sum all initial and final fundamental-color
   indices. Then multiply by the single incoming-state average whose spin
   part is the explicit paper Eq. (14) factor `1/2` and whose color part is
   `1/Nc` for the incoming fundamental quark. Save the color-summed tensor
   before this average and prove exactly that the final tensor equals it
   divided by `2 FeynCalc`SUNN`. Final states are summed and never averaged.
6. Preserve each charge key independently through every cache and output
   association. Do not combine the three tensors, alter the tool-derived
   mixed-term sign, substitute physical charges, or replace the ordered
   `q,qPrime != q` flavour assembly by `Nf` or `Nf-1`.
7. Preserve both photon indices and the single existing absolute scale factor
   exactly once. Add no separate MS-bar `S_epsilon`, virtual term, symmetry
   factor, physical charge/flavour weight, projector, phase-space factor,
   subtraction, factorization, or numerical approximation.
8. Bind every cache to the exact S06 program hash, accepted S05 source/result
   hashes, charge key, cache kind, and hash of that key's exact input tensor.
   Write caches and `s06_result` through process-specific temporary
   Associations, reload and validate before atomic rename, refuse to
   overwrite a final result, and delete only a demonstrably invalid cache.
9. The three charge tensors are independent and may be evaluated on three
   local kernels. Configure every worker in memory with the verified Engine
   15 `WolframKernel` command, require exactly three launched workers, retain
   deterministic key ordering, and return payloads to the main kernel. Only
   the main kernel may validate and write caches, preventing concurrent writes
   to any artifact. Algebra within one coherent tensor remains serial.
10. Provide a no-write preflight that follows the complete production algebra
    but neither reads nor writes S06 caches/results. The final result must
    expose ordered associations of color-summed pre-average and spin/color-
    averaged charge tensors, the exact average relation, complete cache
    provenance, all-true checks, and explicit downstream deferrals.

S06 stops at the three D-dimensional, open-photon-index, spin/color-averaged
real tensors. A separately authorized S07 may contract the paper's `Pg` and
`PPP` projectors with each final charge tensor separately. S07 must not
collapse charge structures, integrate phase space, apply a flavour sum,
introduce a symmetry or virtual factor, perform factorization, or start an
F-hat/BigTMD comparison.

### Accepted S06 artifacts and evidence

S06 is complete and independently accepted with stage schema
`HqqprimeS06-v1`, result schema version `1`, cache schema
`HqqprimeS06Cache-v1`, and this exact artifact ledger:

- source `s06_spin_color_sum_average_hqqprime.wl`: SHA-256
  `eef94883991b5fb6d10345f29943234f90c2da695879c4ca6f2ee99a4a970adc`,
  41,542 bytes;
- result `s06_result`: SHA-256
  `92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607`,
  2,222,671 bytes;
- production log `s06_spin_color_sum_average_hqqprime.log`: SHA-256
  `0b0a0f5dd473849e7f1f995754620b3ecbc353615053e67da97c0daa1225c394`,
  8,496 bytes;
- incoming-squared post-Dirac cache
  `s06_cache_hqqprime_incoming_charge_squared_after_dirac`: SHA-256
  `18085d0b63561e117ea5145f2326238f23751eed69400680f6cf4e582e90f055`,
  141,168 bytes;
- prime-squared post-Dirac cache
  `s06_cache_hqqprime_prime_charge_squared_after_dirac`: SHA-256
  `12fe7c064af30c00984cfe73da7965f1166e32eef2e3edfb678b44759372ed62`,
  132,157 bytes;
- mixed post-Dirac cache
  `s06_cache_hqqprime_mixed_incoming_prime_charge_after_dirac`: SHA-256
  `47c112fd55cb28d547037ae56d5058d7e61052a4a9e12e282f15bc8f296a9576`,
  785,889 bytes;
- incoming-squared final cache
  `s06_cache_hqqprime_incoming_charge_squared_spin_color`: SHA-256
  `96ac6fc8ecb8ddffa2071fafc9387c561403e48367c60649eebe91fc04df4a63`,
  173,537 bytes;
- prime-squared final cache
  `s06_cache_hqqprime_prime_charge_squared_spin_color`: SHA-256
  `de13f5f2927d610e62cc60932c1e33fde4268e11396434d0f9ec2ab3db7ff4fc`,
  156,418 bytes;
- mixed final cache
  `s06_cache_hqqprime_mixed_incoming_prime_charge_spin_color`: SHA-256
  `324e71bd7c603494f665d3b6b502250c2d62a2d89c3a1c6223719266d8bb6101`,
  1,067,614 bytes.

The verified Engine 15 production run exited `0`, printed exactly one
`S06_SUCCESS` and `S06_PRODUCTION_SHELL_EXIT=0`, atomically wrote and exactly
reloaded the result and all six caches, and reported all 35 saved checks true.
The log contains no fatal, abort, termination, kill, out-of-memory, or timeout
marker. Exactly three explicitly configured Engine 15 workers processed the
three charge keys in deterministic order; algebra within each tensor remained
serial and only the main kernel wrote artifacts.

Production and the fresh independent reconstruction reported these leaf
counts in the fixed `IncomingChargeSquared`, `PrimeChargeSquared`,
`MixedIncomingPrimeCharge` order:

- post-Dirac: `20,262`, `20,452`, `114,865`;
- color-summed before the incoming average: `13,103`, `13,293`, `78,993`;
- final spin/color-averaged: `13,106`, `13,296`, `79,000`.

For independent acceptance, a fresh Engine 15/FeynCalc kernel loaded the
accepted S05 input and reconstructed all three tensors before loading any S06
output. Three fresh workers independently repeated `FermionSpinSum`, fully
evaluated D-dimensional `DiracSimplify`, and `SUNSimplify`; the validator then
applied the saved incoming-state average and loaded the published result and
caches. Literal equality passed for every reconstructed post-Dirac tensor,
color-summed tensor, final tensor, cache payload, and result entry. It also
rechecked exact source/upstream/paper/cache identities, all 35 saved checks,
the exact final-to-pre-average relation, and all state, color, Dirac, scale,
charge, virtual, symmetry, and downstream-deferral gates. It exited `0` with
`S06_VALIDATION_OK` and reproduced result SHA-256
`92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607`.

The accepted output preserves both `s05Mu,s05Nu`, the separately proven
absolute ``FeynCalc`ScaleMu^(4 epsilon)`` factor, and the three charge keys.
It contains no external spinor, Dirac, or unsummed color object and satisfies
the exact saved relation in which each `SpinColorAveragedChargeTensors[key]`
entry equals the corresponding `ColorSummedUnaveragedChargeTensors[key]`
entry divided by ``2 FeynCalc`SUNN``.
Final fermion states are summed and not averaged. No physical ordered
flavour/charge assembly, symmetry factor, virtual term, polarization sum,
projector, phase-space operation, separate MS-bar `S_epsilon`, factorization,
or numerical approximation was applied.

The exact S06 inventory is the declared source, result, production log, three
post-Dirac caches, and three final caches. There is no temporary result,
runner, monitor, persistent validator, or retained disposable-preflight log.
An authorized S07 consumer must read each entry of
`s06_result["Tensors","SpinColorAveragedChargeTensors"]` separately, preserve
all three charge keys plus the scale/symmetry/virtual ledgers, and limit itself
to the contracted projector step stated above.

## S07 contract: paper `Pg` and `PPP` contractions by charge tensor

The S07 identities are:

- source: `s07_contract_hqqprime_projectors.wl`;
- result: `s07_result`;
- production log: `s07_contract_hqqprime_projectors.log`;
- per-charge/per-projector caches:
  `s07_cache_hqqprime_<charge-key>_<projector>`.

S07 has one and only one mathematical input collection: the ordered three
entries of the accepted
`s06_result["Tensors","SpinColorAveragedChargeTensors"]`. It must pin these
exact inputs before any contraction:

- S06 source SHA-256
  `eef94883991b5fb6d10345f29943234f90c2da695879c4ca6f2ee99a4a970adc`;
- S06 result SHA-256
  `92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607`;
- authoritative paper SHA-256
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.

The S05/S01/S04 identities inherited inside S06 must also match the accepted
ledger values. S02 and S03 remain visualization-only non-inputs; no other
channel source, tensor, result, or cache is a normalization or physics input.

S07 must perform and gate these operations:

1. Require complete `HqqprimeS06-v1` status, result schema version `1`, all
   35 saved checks, exact upstream/paper provenance, the accepted
   different-flavour state ordering, the exact incoming average relation,
   absent virtual branch, unapplied physical flavour sum and symmetry factor,
   and the ordered charge keys `IncomingChargeSquared`,
   `PrimeChargeSquared`, and `MixedIncomingPrimeCharge`.
2. Consume only the spin/color-averaged tensor for each key. Require both
   open photon indices `s05Mu,s05Nu`, no remaining external-state, Dirac, or
   color object, no generic charge symbol or machine number, and the exact
   inherited global ``FeynCalc`ScaleMu^(4 epsilon)`` factor using the proven
   marker-factor audit rather than a representation-sensitive occurrence
   count.
3. Install the same exact massless D-dimensional three-body scalar products
   in `sHat`, `ti`, `ui`, and `sij`. Paper Eqs. (7) and (16) fix the only two
   extraction tensors at this stage as
   `Pg^(mu nu) = g^(mu nu)` and `PPP^(mu nu) = p^mu p^nu`, where `p` is the
   incoming parton momentum. Contract each projector with each charge tensor
   separately. Do not substitute `D -> 4`, assign numerical kinematics to a
   saved projection, or form the paper Eq. (9) F1/F2 combinations.
4. Before accepting projections, derive an exact conservation-consistent
   rational Ward-test point with Wolfram `FindInstance` from the current
   three-body relations and sign constraints; do not transcribe a point from
   another channel. For each charge tensor, double-contract with the photon
   momentum, make ordinary tree propagator denominators explicit only inside
   this diagnostic, apply the derived point while leaving `D`, `epsilon`, and
   ``FeynCalc`ScaleMu`` symbolic, and require the exact residual to be zero.
   The diagnostic must not alter or specialize any saved projection.
5. Save exactly six nonzero scalars: `Pg` and `PPP` for every charge key.
   Every photon and other Lorentz index must be fully contracted, with no
   unevaluated `Contract`, external-state, Dirac, or explicit-color object.
   Ordinary tree `FeynAmpDenominator` objects remain inert for the later
   phase-space/rational-reduction stage.
6. Preserve both ordered projector keys and, within each projector, all three
   ordered charge keys. Do not combine charge structures, alter the
   tool-derived mixed-term sign, substitute physical charges, or replace the
   ordered `q,qPrime != q` flavour assembly by `Nf` or `Nf-1`.
7. Preserve exactly one inherited absolute scale factor in every scalar.
   Add no separate MS-bar `S_epsilon`, virtual term, final-state symmetry
   factor, physical charge/flavour weight, projector-combination weight,
   phase-space normalization, subtraction, factorization, or numerical
   approximation.
8. Bind each cache to schema `HqqprimeS07Cache-v1`, the exact S07 program,
   paper, S06 source/result hashes, charge key, projector name, and hash of
   that key's exact input tensor. Store one scalar payload per cache. Write
   caches and result through process-specific temporary Associations, reload
   validate before atomic rename, refuse silent result overwrite, and delete
   only a demonstrably invalid cache.
9. The three charge tensors are independent. Configure exactly three local
   workers in memory with the verified Engine 15 `WolframKernel`; assign one
   charge key to each worker. Each worker evaluates its Ward diagnostic and
   its `Pg`,`PPP` contractions serially, returns the payload in deterministic
   charge order, and writes nothing. Only the main kernel may validate and
   write caches/result. Launching more kernels within one coherent scalar
   contraction would not accelerate its intrinsically serial algebra.
10. Provide a complete no-write preflight that ignores existing S07 caches
    and neither reads nor writes S07 output. The atomic result schema
    `HqqprimeS07-v1` must expose the projector-first path
    `ScalarProjections/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<Pg-or-PPP>/<charge-key>`,
    the six production-measured leaf counts, exact Ward ledger, parallel and
    cache provenance, all-true checks, and explicit downstream deferrals.

The clean pre-implementation probe derived its Ward point with Wolfram and
obtained exact-zero residuals for all three current-channel charge tensors.
It measured the following nonzero scalar leaf counts without writing output:
incoming-squared `Pg=5,181`, `PPP=84`; prime-squared `Pg=5,323`, `PPP=669`;
mixed `Pg=10,067`, `PPP=737`. Production must measure these quantities again;
the probe counts are evidence, not hard-coded acceptance literals.

S07 stops at the six D-dimensional, charge-resolved, spin/color-averaged,
unintegrated scalar projections. A separately authorized S08 may consume
each scalar independently for the paper's three-body phase-space/angular
machinery. It must preserve the three charge structures and all
scale/symmetry/virtual ledgers; it must not infer physical flavour assembly,
Eq. (9) inversion, factorization, F-hat extraction, or an external-code
comparison from S07 completion.

### Accepted S07 artifacts and evidence

S07 is complete and independently accepted with stage schema
`HqqprimeS07-v1`, result schema version `1`, cache schema
`HqqprimeS07Cache-v1`, and this exact artifact ledger:

- source `s07_contract_hqqprime_projectors.wl`: SHA-256
  `4ac73e5b846e088c7c92acfed2bb935ba969e9049d778f83e5f8cfa34fcab1e7`,
  40,543 bytes;
- result `s07_result`: SHA-256
  `b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026`,
  158,979 bytes;
- production log `s07_contract_hqqprime_projectors.log`: SHA-256
  `af4379a85fa7d72cdbc0c2ce31e1fdfe96d213f07fd287edc2d92923640a89e8`,
  8,586 bytes;
- incoming-squared `Pg` cache
  `s07_cache_hqqprime_incoming_charge_squared_pg`: SHA-256
  `0be494f50caa76ceead7514d644239503f64e6a64920c67acf23c9cd5205293c`,
  32,089 bytes;
- prime-squared `Pg` cache
  `s07_cache_hqqprime_prime_charge_squared_pg`: SHA-256
  `6b616dcbac454e47f33e3135d685de5be45e6ab15bc96b5dd99b74d1cf981b05`,
  28,131 bytes;
- mixed `Pg` cache
  `s07_cache_hqqprime_mixed_incoming_prime_charge_pg`: SHA-256
  `0adcf5b9ae04e8eabce4be7e3380c2d05c15163d67ea8d83232a4c9d3701fff2`,
  62,158 bytes;
- incoming-squared `PPP` cache
  `s07_cache_hqqprime_incoming_charge_squared_ppp`: SHA-256
  `d43a35cb4aabdccdf1bc8dcdd35723d6d78c78cb495c108bad28addacf2634c0`,
  1,667 bytes;
- prime-squared `PPP` cache
  `s07_cache_hqqprime_prime_charge_squared_ppp`: SHA-256
  `735f4eea301f79f86498ab2f1e7d4ab920a61efb01b02e376faac33514400b54`,
  5,053 bytes;
- mixed `PPP` cache
  `s07_cache_hqqprime_mixed_incoming_prime_charge_ppp`: SHA-256
  `a580e4b0010648b16fe3767702f06f956d1b089af8e6113de4495e3b553455dc`,
  5,325 bytes.

The complete no-write preflight and the production run each launched exactly
three explicitly configured Engine 15 workers, one per charge tensor. Each
worker evaluated its Ward diagnostic and then `Pg`,`PPP` serially; only the
main kernel wrote artifacts. Production exited `0`, printed exactly one
`S07_SUCCESS` and `S07_PRODUCTION_SHELL_EXIT=0`, atomically wrote and exactly
reloaded all six caches and the result, and reported all 33 saved checks true.
The durable log contains no fatal, abort, termination, kill, out-of-memory,
timeout, or Wolfram diagnostic marker.

Wolfram `FindInstance` derived the exact conservation-consistent Ward point

`{Q2->1,sHat->3,t1->-3/2,u1->-3/2,t2->-7/4,u2->-5/4,
t3->-7/4,u3->-5/4,s12->1,s13->1,s23->1}`.

The program proved all six saved conservation/sign relations at that point
and obtained exact zero for the double-photon Ward residual of every charge
tensor while leaving `D`, `epsilon`, and ``FeynCalc`ScaleMu`` symbolic.

Production and the fresh independent reconstruction reported these leaf
counts in fixed incoming-squared/prime-squared/mixed order:

- `Pg`: `5,181`, `5,323`, `10,067`;
- `PPP`: `84`, `669`, `737`.

For independent acceptance, a fresh serial Engine 15/FeynCalc kernel loaded
only accepted S06, rederived the Ward point, recomputed all three Ward
residuals, and formed all six projector contractions before loading any S07
output. It then required literal equality with every result entry and cache
payload, freshly recomputed input/expression hashes, exact disk/cache/result
provenance, all 33 saved checks, projector/charge order, scalar purity,
parallel-execution metadata, and every charge/scale/symmetry/virtual deferral
gate. All 11 validation groups were literal true and the run exited `0` with
`S07_VALIDATION_OK`.

Every accepted projection is nonzero, D-dimensional, fully Lorentz scalar,
free of generic charge symbols and external-state/Dirac/color/machine
objects, and retains the separately proven absolute
``FeynCalc`ScaleMu^(4 epsilon)`` factor exactly once. Ordinary tree
`FeynAmpDenominator` objects remain inert. The mixed charge tensor has not
been sign-adjusted or combined with either squared tensor. No Eq. (9)
combination, physical ordered flavour/charge sum, symmetry factor, virtual
term, phase-space normalization/integration, separate MS-bar `S_epsilon`,
factorization, endpoint distribution, F-hat extraction, or external-code
comparison was applied.

The exact S07 inventory is the declared source, result, production log, three
`Pg` caches, and three `PPP` caches. There is no temporary result, helper,
runner, monitor, persistent validator, or retained preflight log. An
authorized S08 consumer must read each scalar separately from
`s07_result["ScalarProjections","NLOReal_OAlphaS2",
"Hqqprime;q_qbarPrime",projector,chargeKey]`, preserve both ordered
projectors and all three ordered charge keys, and limit itself to the
contracted three-body phase-space/angular step.

## S08 contract: charge-resolved three-body phase space and angular masters

The S08 identities are:

- source: `s08_phase_space_integrate_hqqprime.wl`;
- result: `s08_result`;
- production log: `s08_phase_space_integrate_hqqprime.log`;
- per-charge/per-projector caches:
  `s08_cache_hqqprime_<charge-key>_<projector>`.

S08 has one and only one mathematical input collection: the six entries of
the accepted
`s07_result["ScalarProjections","NLOReal_OAlphaS2",
"Hqqprime;q_qbarPrime",projector,chargeKey]`. It must pin these exact inputs
before any phase-space algebra:

- S07 source SHA-256
  `4ac73e5b846e088c7c92acfed2bb935ba969e9049d778f83e5f8cfa34fcab1e7`;
- S07 result SHA-256
  `b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026`;
- authoritative paper SHA-256
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.

The S06/S05/S01/S04 identities inherited inside S07 must also match the
accepted ledger values. S02 and S03 remain visualization-only non-inputs; no
other channel tensor, result, cache, count, charge weight, or symmetry factor
is a mathematical input.

S08 must perform and gate these operations:

1. Require complete `HqqprimeS07-v1` status, result schema version `1`, all
   33 saved checks, exact upstream/paper provenance, ordered projectors
   `Pg,PPP`, ordered charge keys `IncomingChargeSquared`,
   `PrimeChargeSquared`, `MixedIncomingPrimeCharge`, distinct-flavour state
   ordering, absent virtual branch, unapplied physical flavour sum, and the
   accepted scale and symmetry ledgers.
2. Consume every scalar separately. Make ordinary tree propagators explicit
   under the exact massless three-body scalar products, apply the accepted
   momentum-conservation invariant rules and `D -> 4-2 epsilon`, combine each
   exact rational expression with `Together`, and only then expand and
   classify angular powers. Reject machine numbers, a four-dimensional
   specialization, remaining propagator/momentum objects, or a generic
   charge symbol.
3. Implement paper Appendix D Eqs. (D5)-(D8): separate same-type denominator
   ADMVs, reduce three different ADMV types to at most two, and rewrite
   numerator ADMVs in a selected two-variable basis. Derive the unity
   relations with Wolfram linear algebra and require both the D5-D8 frame
   coefficient identities and exact common-basis reconstruction for every
   disjoint input-term partition. No reduced term may retain more than two
   ADMVs or two ADMVs of the same type.
4. Integrate `beta1,beta2` using the paper Appendix-B frame coefficients.
   Evaluate case-1/massless-massless masters exactly with Eq. (B18). Retain
   case-2/virtual-photon-massless integrals as the exact symbolic head
   `S08Case2Master[j,l,d,cosChi,epsilon]` defined by Eq. (B19). S08 must not
   apply Appendix F, Eqs. (B21)-(B31) epsilon/analytic-continuation formulas,
   an endpoint expansion, or a distribution identity.
5. Multiply every angular result by Eq. (39)'s exact outside-angular measure
   and Eq. (19)'s common `1/(2 Pi)^4`, and prove their product equals
   `s23^(-epsilon) 2^(-2) Pi^(-epsilon) Gamma[1-epsilon] /
   ((2 Pi)^(6-2 epsilon) Gamma[1-2 epsilon])`. The numerical power on `2`
   is exactly `-2`, not `-2 epsilon`.
6. Derive the current-channel final-state symmetry factor in the running
   program from the accepted distinct-species and representative-factor
   ledgers, and require the two derivations to agree. For
   `qPrime(k1),q(k2),qbarPrime(k3)` the accepted current-channel value is
   exact integer `1`; no Hqqbar-like spectator exchange assertion or `1/2!`
   is applicable. Save the pre-factor angular result and the physical result,
   prove exact equality branch by branch, and record that no nontrivial
   symmetry factor remains for downstream application.
7. Keep observed fragmenting `qPrime(k1)` differential. Apply paper
   Eqs. (29)-(32) with `xHat=xB/xi`, replace `zeta` by `s23`, multiply by the
   exact `d zeta/d s23` Jacobian, and store `xi` in `[A,1]` and `s23` in
   `[0,B(xi)]`. Wolfram must prove the Jacobian derivative, Eq. (40), overall
   partonic conservation, the lower-bound identity, and `zeta=1` at the
   upper `s23` boundary. Do not perform the remaining `xi,s23` convolution.
8. Preserve the projector-first and charge-second order through every
   record, cache, and result. Preserve the tool-derived mixed charge tensor
   without a sign adjustment or combination, the single inherited absolute
   ``FeynCalc`ScaleMu^(4 epsilon)`` factor, and the structurally absent
   virtual branch. Add no physical ordered `q,qPrime != q` flavour/charge
   sum, bare `Nf` or `Nf-1`, separate MS-bar `S_epsilon`, Eq. (9) projector
   combination, subtraction, factorization, or numerical approximation.
9. Bind every cache to schema `HqqprimeS08Cache-v1`, the exact S08 program,
   paper, S07 source/result hashes, charge key, projector, exact input-scalar
   hash, scale/charge/symmetry/virtual ledgers, and one angular record. Write
   caches and result through process-specific temporary Associations, reload
   and validate before atomic rename, refuse silent result overwrite, and
   delete only a demonstrably invalid cache.
10. The three charge keys are independent. Configure exactly three local
    workers in memory with the verified Engine-15 `WolframKernel`; assign one
    charge key to each worker and process `Pg` then `PPP` serially inside that
    worker. Workers return deterministic payloads and never write files; only
    the main kernel validates and atomically writes the six caches and result.
    A complete no-write preflight must ignore caches and write no S08 output.

The accepted pre-implementation probe made all six tree-denominator payloads
explicit and exact before any source was written. In incoming-squared,
prime-squared, mixed order, it measured combined/expanded term complexity
`Pg: 1966/182/5474, 1974/182/5474, 2852/272/8537` and
`PPP: 55/10/296, 215/40/1158, 265/60/1897`, where each triple is combined
leaf count / expanded term count / expanded leaf count. Maximum denominator
ADMV counts are `Pg: 2,2,4` and `PPP: 2,2,4`; the mixed branches contain 96
and 28 terms with more than two denominator ADMVs. Production must remeasure
and reduce the current expressions; these probe values are evidence rather
than hard-coded acceptance literals.

The atomic result schema `HqqprimeS08-v1` must expose the projector-first
paths
`PreSymmetryAngularAudit/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<projector>/<charge-key>`,
`ThreeBodyAngularIntegrated/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<projector>/<charge-key>`,
and
`XiS23ConvolutionKernels/ThreeBodyReal/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<projector>/<charge-key>`.
It must also retain exact Appendix-D audits, Appendix-B master inventories,
the variable-change certificates, six production-measured leaf-count
records, cache/parallel provenance, all-true checks, and explicit downstream
deferrals.

S08 stops at exact angular masters and symbolic `xi,s23` real kernels. A
separately authorized S09 may expand the retained masters and introduce the
formal endpoint distributions. S08 does not authorize Appendix-F expansion,
endpoint delta/plus coefficients, factorization, Eq. (9) inversion, F-hat
extraction, physical flavour assembly, or external-code comparison.

### Accepted S08 artifacts and evidence

S08 is complete and independently accepted with stage schema
`HqqprimeS08-v1`, result schema version `1`, cache schema
`HqqprimeS08Cache-v1`, and this exact artifact ledger:

- source `s08_phase_space_integrate_hqqprime.wl`: SHA-256
  `dbbc23d05697f4e45c23471be8f3ed12448d8db0d973e60d67cdebbcabec8ed4`,
  65,932 bytes;
- result `s08_result`: SHA-256
  `4916b943c1bbc7b1aeeb91d5fa022d00b5341166fc805b95e21e8ee4f99bb246`,
  3,850,571 bytes;
- production log `s08_phase_space_integrate_hqqprime.log`: SHA-256
  `e2f9435475afbf1ed0c32f5dc5011532adbca29b69b1a4d0450c1ca2c37b3170`,
  14,680 bytes;
- incoming-squared `Pg` cache
  `s08_cache_hqqprime_incoming_charge_squared_pg`: SHA-256
  `855101208854c720385e89785464f77cfe71a947728fd6b6d022f95130d0f781`,
  110,425 bytes;
- prime-squared `Pg` cache
  `s08_cache_hqqprime_prime_charge_squared_pg`: SHA-256
  `5c3ead313a0e228174fa5c334d9144d8ce04bad5ec33dfb7d7170b3589d83c28`,
  61,565 bytes;
- mixed `Pg` cache
  `s08_cache_hqqprime_mixed_incoming_prime_charge_pg`: SHA-256
  `f9ac39e5b22e1484ec012a17609bf0b5e00a54d3a153705d669ba8a29b63caaa`,
  391,948 bytes;
- incoming-squared `PPP` cache
  `s08_cache_hqqprime_incoming_charge_squared_ppp`: SHA-256
  `7518ed803aa4dd136405665f9a6c294f7c5b9056f3e911ea63e85a21e1b1e70c`,
  59,877 bytes;
- prime-squared `PPP` cache
  `s08_cache_hqqprime_prime_charge_squared_ppp`: SHA-256
  `bf567c8652ba861dd029abf20bf74ebf992cc7d91aa93c440ae6058fd4ebba43`,
  32,530 bytes;
- mixed `PPP` cache
  `s08_cache_hqqprime_mixed_incoming_prime_charge_ppp`: SHA-256
  `e8e3de995b764e528495be129c99ff52b66f6207ca016db139a62d849366e491`,
  314,872 bytes.

The complete no-write preflight, monitored production, and fresh
post-production no-write reconstruction each launched exactly three
explicitly configured Engine-15 workers, one per charge key. Each worker
processed `Pg` then `PPP` serially and wrote nothing; only the main production
kernel wrote the six caches and result. Production exited `0`, printed
exactly one `S08_SUCCESS` and `S08_PRODUCTION_SHELL_EXIT=0`, and reported all
38 saved checks true. The durable log contains no Wolfram diagnostic, fatal,
abort, termination, kill, out-of-memory, or timeout marker.

All six current expressions were independently made rational before angular
classification. In incoming-squared, prime-squared, mixed order, the exact
Appendix-D reduced-term / angular-master counts are:

- `Pg`: `1,870/18`, `1,368/17`, `4,064/28`;
- `PPP`: `260/10`, `290/14`, `1,860/33`.

Every disjoint reconstruction partition has exact-zero residual and no
reduced term retains more than two ADMVs or two of the same type. Across all
six physical expressions there are 47 distinct retained exact
`S08Case2Master` instances. Eq. (B18) masters are evaluated exactly; Eq. (B19)
masters remain unexpanded, as required by the S08/S09 boundary.

Pre-factor and physical angular leaf counts are identical because the
current-channel factor is exact integer `1`. In the same charge order they
are:

- `Pg`: `15,067`, `8,168`, `60,617`;
- `PPP`: `8,001`, `4,241`, `49,754`.

After the exact paper Eqs. (29)-(32) `zeta -> s23` map and Wolfram-derived
Jacobian, the corresponding kernel leaf counts are:

- `Pg`: `72,767`, `47,994`, `405,479`;
- `PPP`: `42,619`, `28,358`, `375,160`.

The fresh post-production reconstruction ignored every cache/output and
reproduced all 38 checks, all six reduction/master counts, all angular and
transformed leaf counts, and the 47-master inventory. A separate fresh
Engine-15/FeynCalc validator then passed 12 independent groups: exact disk
identities/sizes; result schema/checks; freshly recomputed S07 input hashes;
six cache schemas and provenance; literal cache-to-result payload equality;
fresh reconstruction of every saved `xi,s23` kernel; paper normalization,
Jacobian, Eq. (40), conservation, and boundary identities; master and
Appendix-D inventories; leaf counts; species-derived symmetry; exact
scale/charge/purity; and parallel/virtual/downstream bookkeeping. It exited
`0` with `S08_VALIDATION_OK`.

The program derived species labels and multiplicities from
`qPrime(k1),q(k2),qbarPrime(k3)`, independently compared the resulting factor
with all three accepted representative factors, and obtained exact integer
`1` both ways. Therefore every physical angular branch is literally equal to
its pre-symmetry branch; no Hqqbar-like exchange-symmetry assertion or
spectator `1/2!` was used, and no nontrivial symmetry factor remains for a
downstream consumer.

Every accepted angular and transformed branch retains exactly one inherited
absolute ``FeynCalc`ScaleMu^(4 epsilon)`` factor, is free of generic charge
symbols, and preserves the three charge keys without a sign adjustment or
combination. The virtual contribution remains structurally absent. No
physical ordered flavour/charge sum, bare `Nf` or `Nf-1`, separate MS-bar
factor, Appendix-F/endpoint expansion, factorization, Eq. (9), F-hat, or
external comparison was applied.

The accepted consumer paths are
`ThreeBodyAngularIntegrated/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<projector>/<charge-key>`
and
`XiS23ConvolutionKernels/ThreeBodyReal/NLOReal_OAlphaS2/Hqqprime;q_qbarPrime/<projector>/<charge-key>`.
An authorized S09 must consume every projector/charge branch independently,
must not introduce a nontrivial final-state symmetry factor, and must keep
physical ordered flavour assembly, Eq. (9), factorization, F-hat extraction,
and external comparison deferred to their separately contracted stages.

The exact S08 inventory is the source, result, production log, three `Pg`
caches, and three `PPP` caches. There is no temporary result, disposable
preflight/reconstruction log, helper, runner, monitor, or persistent
validator file.

## S09 contract: Appendix-F master expansion and formal endpoints by charge tensor

The S09 identities are:

- source: `s09_expand_endpoints_hqqprime.wl`;
- result: `s09_result`;
- production log: `s09_expand_endpoints_hqqprime.log`;
- per-charge/per-projector caches:
  `s09_cache_hqqprime_<charge-key>_<projector>`.

S09 has one and only one mathematical input collection: the six physical
angular branches at
`s08_result["ThreeBodyAngularIntegrated","NLOReal_OAlphaS2",
"Hqqprime;q_qbarPrime",projector,chargeKey]`. It must pin the corresponding
accepted mapped branches, paper, source, result, and all six S08 caches before
any expansion:

- S08 source SHA-256
  `dbbc23d05697f4e45c23471be8f3ed12448d8db0d973e60d67cdebbcabec8ed4`;
- S08 result SHA-256
  `4916b943c1bbc7b1aeeb91d5fa022d00b5341166fc805b95e21e8ee4f99bb246`;
- authoritative paper SHA-256
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`;
- the six S08 cache identities recorded in the accepted S08 ledger above.

The S07 and earlier identities inherited inside S08 must also match their
accepted ledger values. No other channel formula result, tensor, count,
weight, symmetry factor, cache, or result is a mathematical input.

S09 must perform and gate these operations:

1. Require complete `HqqprimeS08-v1` status, result schema version `1`, all
   38 saved checks, exact paper/upstream/cache provenance, ordered projectors
   `Pg,PPP`, ordered charge keys `IncomingChargeSquared`,
   `PrimeChargeSquared`, `MixedIncomingPrimeCharge`, the accepted distinct-
   flavour state ordering, structurally absent virtual branch, unapplied
   physical ordered flavour sum, and exact scale/symmetry ledgers. Every S08
   cache must reload as `HqqprimeS08Cache-v1` and its exact physical angular
   payload must equal the corresponding S09 input branch.
2. Inventory every retained exact five-argument `S08Case2Master` before
   substitution. The tool-measured occurrence/distinct-instance counts are
   `Pg` incoming `16/16`, prime `12/12`, mixed `24/24`, and `PPP` incoming
   `9/9`, prime `11/11`, mixed `26/26`. Across all six branches require
   exactly 98 occurrences, 47 distinct exact instances, and this 21-class
   union:
   `{{-2,0},{-2,1},{-1,-1},{-1,0},{-1,1},{-1,2},{0,-2},{0,-1},
   {0,1},{0,2},{1,-3},{1,-2},{1,-1},{1,0},{1,1},{1,2},{2,-2},
   {2,-1},{2,0},{2,1},{2,2}}`. Gate the exact branch-specific class lists
   measured in the pre-implementation probe; do not accept only the union.
3. Expand every nonzero-`j` master directly from the authoritative paper's
   Appendix F definitions F1-F5 and applicable formulas F8 and F12-F29,
   using Appendix B Eqs. (B21)-(B31). Retain each paper formula's printed
   epsilon order: through `epsilon^1` except F28/F29, which stop at
   `epsilon^0`. Derive every `j=0` class from exact Eq. (B18) and expand it
   through `epsilon^2`. Expand every exact residual B18 Beta object and the
   sole residual B27 signature `Hypergeometric2F1[1,1,1-epsilon,_]` through
   `epsilon^2`. Prove that separately expanded `Gamma[1-epsilon]` and
   `Gamma[1-2 epsilon]` reconstruct both required whole Gamma ratios through
   that order before using the individual series. Never use `PowerExpand`,
   machine numbers, decimal conversion, or numerical branch selection.
4. Independently validate the Appendix-F transcription with the exact B19
   defining relation `D_D I[j,l] = -j I[j+1,l]` at each common available
   epsilon order for the eleven adjacent required pairs. Validate required
   F8 class `{1,-3}` separately from B19 by exact beta-two moment integration
   and polynomial `J_n`/logarithmic `H_n` moment reduction, requiring its
   leading and `epsilon^1` residuals to vanish identically. The printed F9
   `epsilon^1` term is not physically required because `{2,-3}` is absent;
   its known paper-internal inconsistency must be recorded but neither
   imported, patched, nor used to reject the independently validated F8.
5. Substitute the validated expansions into every physical angular branch,
   then apply the exact S08 `xi,s23` rules and Wolfram-derived Jacobian. Prove
   branch by branch that master and case-1 substitution commute with that
   map. The resulting six exact transformed caches must retain no
   `S08Case2Master`, `Hypergeometric2F1`, `Beta`, `Gamma`, machine number,
   angular variable, inert propagator, or unmapped partonic variable.
6. The additional S09 multiplicative weight is exact integer `1`. Preserve
   every charge tensor independently without sign adjustment or combination,
   the current-channel final-state factor exact integer `1` with no
   nontrivial downstream symmetry factor, the single inherited absolute
   ``FeynCalc`ScaleMu^(4 epsilon)`` factor, and the structurally absent
   virtual branch. Add no physical ordered `q,qPrime != q` flavour/charge
   assembly, bare `Nf` or `Nf-1`, separate MS-bar `S_epsilon`, LO or virtual
   term, or Eq. (9) projector combination.
7. On the exact S08 interval `0 <= s23 <= B(xi)`, record the formal identity
   through `epsilon^2`:
   `s23^(-1-epsilon) = -B^(-epsilon) DiracDelta[s23]/epsilon +
   B^(-epsilon) Sum[(-epsilon)^n/n!
   S09PlusDistribution[n,s23,B],{n,0,2}] + O(epsilon^3)`, where the plus head
   acts as `[Log[s23/B]^n/s23]_+`. For each projector/charge branch define
   the regular function as `s23^(1+epsilon)` times its exact hash-pinned S09
   cache expression. Keep every endpoint value and stronger singularity
   explicitly unresolved; S09 must not manufacture a finite endpoint value
   by substitution.
8. Bind each cache to schema `HqqprimeS09Cache-v1`, the exact S09 program,
   paper, S08 source/result, its individual S08 cache hash, projector, charge
   key, exact input-expression hash, exact branch/all-master inventories, and
   the inherited scale/charge/symmetry/virtual ledgers. Store one expanded
   expression per cache. Only the compact result may contain endpoint
   descriptors, cache paths, and real disk hashes; it must not duplicate the
   six large kernel expressions.
9. Map Association values only with key-preserving `Map`, and require an
   exact nested projector/charge key-shape/value regression gate. Write every
   cache and result through a process-specific temporary Association, exact-
   reload validate before atomic rename, refuse silent final-result
   overwrite, recompute actual disk hashes after reload, and treat every
   Wolfram warning as failure. A complete no-write preflight must ignore all
   S09 caches and write no S09 output.
10. The three charge keys are independent and the measured branches are
    modest enough for one worker per charge. Configure exactly three local
    workers in memory with the verified Engine-15 `WolframKernel`; process
    `Pg` then `PPP` serially inside each worker, return deterministic payloads,
    and write nothing from a worker. Only the main kernel may atomically write
    six caches and the compact result. Algebra within one branch remains
    serial.

The atomic result schema `HqqprimeS09-v1` must preserve projector-first and
charge-second order and expose six formal endpoint descriptors plus the six
source-bound cache identities. S09 stops at exact Appendix-F-expanded real
kernels and an honest unresolved endpoint-distribution handoff. A separately
authorized S10 may resolve the endpoint singularity classes. S09 does not
authorize resolved delta/plus coefficients, distribution action,
factorization/subtraction, pole cancellation, an `epsilon -> 0` finite hard
part, Eq. (9), F-hat extraction, physical flavour assembly, external-code
comparison, or creation/launch of S10.

### Accepted S09 artifacts and evidence

S09 is complete and independently accepted with stage schema
`HqqprimeS09-v1`, result schema version `1`, cache schema
`HqqprimeS09Cache-v1`, and this exact artifact ledger:

- source `s09_expand_endpoints_hqqprime.wl`: SHA-256
  `d1e2c26ccbb5bb0413f930f36b0428346dd621c27d9b52101f54bad16c06ae5f`,
  75,840 bytes;
- compact result `s09_result`: SHA-256
  `f2da97c62e8de83e24bbec0c80f89ca1dd966db66effe37902c70fce49fe0193`,
  25,552 bytes;
- production log `s09_expand_endpoints_hqqprime.log`: SHA-256
  `a47450ab1767b10555b1dfb0709b827cadcab425d6279330fe22f113ff7d5b07`,
  13,898 bytes;
- incoming-squared `Pg` cache
  `s09_cache_hqqprime_incoming_charge_squared_pg`: SHA-256
  `159b8d9926103ca9cdc317886cec8cd72fe165420f99a237a2fb7202e86da512`,
  376,141 bytes;
- prime-squared `Pg` cache
  `s09_cache_hqqprime_prime_charge_squared_pg`: SHA-256
  `6290657216f198e91b72f7fed91652b2a1ec77007394894621bdc28a1af75c06`,
  282,448 bytes;
- mixed `Pg` cache
  `s09_cache_hqqprime_mixed_incoming_prime_charge_pg`: SHA-256
  `165cce56c1eb186ef6ea1647d2314c9a264bdaadfc5b50daf181a4bad867c75a`,
  1,350,640 bytes;
- incoming-squared `PPP` cache
  `s09_cache_hqqprime_incoming_charge_squared_ppp`: SHA-256
  `a75be55b428da0fb9f4be7932a53004898a7d1e0f7f59172b364f9038f1cd8ef`,
  258,412 bytes;
- prime-squared `PPP` cache
  `s09_cache_hqqprime_prime_charge_squared_ppp`: SHA-256
  `b861d0d7e6b3cf9cce07faefd4ae605545f2428bd90b8d9a8081a71283d3504d`,
  272,629 bytes;
- mixed `PPP` cache
  `s09_cache_hqqprime_mixed_incoming_prime_charge_ppp`: SHA-256
  `4ed9ff250fd5097ddf0918407e07725a35386ca1dabfa49b2fae3ccf998f2f6c`,
  1,371,229 bytes.

The complete no-write preflight, production, and fresh post-production
no-write reconstruction each used exactly three explicitly configured
Engine-15 workers, one per charge key, with `Pg` then `PPP` serial inside
each worker. Workers wrote nothing; only the production main kernel
atomically published and exact-reloaded the six caches and compact result.
Production exited `0` with exactly one `S09_SUCCESS` and
`S09_PRODUCTION_SHELL_EXIT=0`; all 44 final checks are true. The accepted log
contains no Wolfram diagnostic, fatal, abort, termination, out-of-memory,
kill, or timeout marker.

The tool remeasured the complete physical basis as 98 master occurrences,
47 distinct exact instances, and the contracted 21-class union. All eleven
exact B19 derivative-recurrence residuals vanish, and both independent exact
F8 B19 moment residuals vanish. Required F8 class `{1,-3}` is present; the
paper-problematic and physically absent F9 class `{2,-3}` was neither used
nor patched. Every zero-`j` B18 object and residual B27/Beta/Gamma object was
expanded through the contracted order, while F28/F29 retain their printed
order.

In incoming-squared, prime-squared, mixed order, the exact expanded
leaf-count / in-memory-byte-count records are:

- `Pg`: `146839/4201920`, `110679/3160376`,
  `555363/15821008`;
- `PPP`: `99781/2848360`, `105885/3013568`,
  `564118/16046064`.

Every cache expression is exact, nonzero, fully mapped to the accepted
`xi,s23` variables, and free of retained `S08Case2Master`,
`Hypergeometric2F1`, `Beta`, `Gamma`, inert propagator, angular variable,
unmapped partonic invariant, machine number, or failure/series object. Each
retains the accepted absolute ``FeynCalc`ScaleMu^(4 epsilon)`` factor, while
the three charge tensors remain separate in fixed order. The additional S09
weight and current-channel final-state factor are both exact integer `1`; no
nontrivial symmetry factor, physical ordered flavour/charge assembly,
separate MS-bar factor, or virtual branch was introduced.

The compact result contains no duplicated cache expression. It records six
hash-pinned formal endpoint descriptors on `0 <= s23 <= B(xi)`, each with one
unresolved delta endpoint head and three formal plus-distribution heads. The
endpoint values, stronger singularities, and distribution action remain
explicitly unresolved, as required at the S09/S10 boundary.

A fresh reconstruction bypassed every published S09 cache and reproduced
all formula certificates, inventories, forbidden-object zeros, and six
leaf/byte summaries without changing any production hash. A separate
read-only Engine-15/FeynCalc validator then passed all nine independent
groups: S09 disk identities/sizes; result schema/checks; accepted input
bindings; six cache schemas/provenance; expression hashes/sizes/purity;
master/formula certificates; formal endpoint handoff; bookkeeping/parallel
execution; and compactness/disk-reference/S10-boundary checks. It exited `0`
with `S09_INDEPENDENT_VALIDATION_OK`.

The exact S09 inventory is the declared source, compact result, production
log, three `Pg` caches, and three `PPP` caches. There is no temporary,
disposable preflight/reconstruction log, helper, runner, monitor, persistent
validator, or S10 artifact. Consumers must load FeynCalc before `Get` so the
serialized scale symbol resolves to the established ``FeynCalc`ScaleMu``
context. A separately authorized S10 must load the six expressions only from
the hash-pinned cache paths, preserve projector-first/charge-second ordering,
all three charge tensors, the unit current-channel factor, inherited scale,
and absent virtual branch, and limit itself to resolving the endpoint
singularity classes.

## S10 contract — charge-resolved endpoint Laurent resolution and action

The authorized S10 entry point is
`s10_resolve_endpoints_hqqprime.wl`. It consumes only the accepted S09
compact result and its six hash-pinned endpoint-expression caches listed
above. Hqqbar and Hqq endpoint programs are generic implementation
precedents only; none of their term indices, groups, weights, charges,
caches, or results is an Hqqprime input.

1. Load FeynCalc before every `Get`. Pin the exact paper, S09 source, S09
   result, and six S09 cache SHA-256 identities above; require schema
   `HqqprimeS09-v1`, all 44 S09 checks, exact projector order
   `{Pg,PPP}`, exact charge order `{IncomingChargeSquared,
   PrimeChargeSquared,MixedIncomingPrimeCharge}`, and the complete S09
   cache/provenance binding before doing endpoint algebra.
2. Split each accepted expression dynamically at its unique common
   `s23^(-epsilon)` factor and largest top-level additive remainder. Require
   the current tool-measured source-term inventory, in projector-first and
   charge-second order: Pg `{17,13,28}` and PPP `{10,12,30}`. Require all
   remaining compact factors to form an endpoint-finite common prefactor;
   do not globally expand the six accepted kernels.
3. Derive epsilon-dependent powers whose bases vanish at `s23=0` from every
   current term. The accepted Hqqprime inventory is empty in all six
   branches, so S10 is alpha-one only. An alpha-two or other exceptional
   regulator class is a fatal input change, not permission to copy another
   channel's refactorization or distribution tower.
4. For each ordinary source term, extract the Laurent coefficients of
   `s23 term` by exact factorwise endpoint algebra: isolate the single
   singular multiplicative factor, evaluate the complementary regular
   product and its derivative at the endpoint, and combine the singular
   factor's required coefficients. Use bounded exact direct, cancellation,
   or full Laurent fallbacks only when the structural route is unavailable.
   Reject machine arithmetic, numerical kinematics, branch-blind
   `PowerExpand`, unresolved limits, infinities, and nonexact output.
5. Audit every distinct logarithm on both physical square-root branches
   after the exact source-derived substitution
   `xi=xB(1+a)`, `PHT2=rT Q2 a zH(1-zH)`. Require the measured coupled groups:
   Pg incoming `{{14,15}}`, Pg prime `{{8,10}}`, Pg mixed
   `{{11},{12},{27},{28}}`; PPP incoming `{{8,10}}`, PPP prime
   `{{9,11}}`, PPP mixed `{{15},{17},{28},{30}}`. The corresponding
   positive-root zero/unresolved source inventories are
   `{14,15}/{14}`, `{8,10}/{10}`, `{11,27}/{}`, `{8,10}/{10}`,
   `{9,11}/{9}`, and `{15,30}/{}`; the negative-root zero inventories are
   `{}`, `{}`, `{12,28}`, `{}`, `{}`, and `{17,28}`, with no negative-root
   unresolved entries. Every unresolved index must be covered by its
   source-derived group.
6. Replace a vanishing logarithm only after deriving its finite nonzero
   endpoint slope with Wolfram code. Within each measured group and on both
   physical roots, require the coefficient of every positive power of the
   inert endpoint logarithm to vanish exactly. Store one finite physical
   `Piecewise` anchor in the first group slot and exact zeros in companion
   slots; singleton groups must prove their cancellation internally. A raw
   termwise `Log[0]` or unresolved square-root limit is never an accepted
   endpoint value.
7. Sum the stronger `s23`-pole coefficients separately in every
   projector/charge branch and reduce them exactly. Require their
   `epsilon^0` and `epsilon^1` coefficients to vanish, which is the complete
   requirement for an action retained through `epsilon^0`; preserve any
   exact higher-order evanescent residual as audit data and remove its
   noncontributing stronger-pole piece from the finite-order regular
   function only after that proof.
8. Act the complete alpha-one bounded delta/plus tower through
   `epsilon^2` on an arbitrary symbolic
   `S10ConvolutionTest[projector,chargeKey,s23]` that is regular at zero and
   independent of epsilon. Each saved action must contain one ordinary
   endpoint-subtracted inactive integral on the exact S09 interval
   `0<=s23<=B(xi)` and no `S09EndpointValue`, `S09PlusDistribution`,
   `S09RegularEndpointFunction`, `S09ExpandedKernelReference`, or
   `DiracDelta[s23]` object.
9. Preserve S09's bookkeeping exactly: additional S10 weight integer `1`,
   final-state factor integer `1` with no nontrivial symmetry factor,
   separate and uncombined charge tensors in their accepted order, exactly
   one inherited ``FeynCalc`ScaleMu^(4 epsilon)`` factor, no separate MS-bar
   `S_epsilon`, no physical ordered-flavour/charge assembly, and the
   structurally absent virtual branch. Pg and PPP remain separate.
10. Publish six schema-`HqqprimeS10Cache-v1` Associations in the same
    projector/charge naming pattern as S09. Bind each to the exact S10
    source, paper, S09 source/result, its individual S09 cache and expression
    hashes, source indices, root inventory/groups, extraction methods,
    endpoint proof data, action, and inherited bookkeeping. Write and
    exact-reload each cache through a process-specific temporary path and
    atomic rename; only the compact schema-`HqqprimeS10-v1` result may store
    their ordered paths and real disk hashes without duplicating the six
    actions.
11. Provide one complete no-write preflight that validates the full source,
    upstream, split, alpha-class, physical-root, coupled-group,
    representative Laurent, distribution-action, parallel-configuration,
    and no-artifact gates. For production, configure exactly three local
    Engine-15 workers in memory, one per independent charge key, with `Pg`
    then `PPP` serial inside each worker. Workers write nothing and return
    deterministic ordered payloads; only the main kernel writes the six
    caches and compact result. Intrabranch algebra remains serial.
12. S10 ends with exact charge-resolved, collinearly unsubtracted real
    convolution actions. Paper Eq. (46) PDF/FF counterterms and
    factorization, remaining collinear-pole cancellation, the
    `epsilon->0` finite hard part, Eq. (9) inversion, F-hat extraction,
    physical ordered-flavour/charge assembly, and external-code comparison
    remain separately authorized downstream work.

### Accepted S10 artifacts and evidence

S10 is complete and independently accepted with stage schema
`HqqprimeS10-v1`, result schema version `1`, cache schema
`HqqprimeS10Cache-v1`, endpoint-proof version `1`, and this exact artifact
ledger:

- source `s10_resolve_endpoints_hqqprime.wl`: SHA-256
  `9ec4991d19fc5e61bc79ecb35f90062d15e8b2cd427ede637ed596519f05e988`,
  93,414 bytes;
- compact result `s10_result`: SHA-256
  `1ce9ef022312ff333b2dc949a858a5883380106c63742fada970f5ebc0d12c25`,
  21,013 bytes;
- production log `s10_resolve_endpoints_hqqprime.log`: SHA-256
  `13681f89cb835bd0aa36804e356b85e1f408c4e62b812934854508ae7752294e`,
  10,162 bytes;
- incoming-squared `Pg` cache
  `s10_cache_hqqprime_incoming_charge_squared_pg`: SHA-256
  `c89636c1233f201751231f7f41b5948aee4c217bc8daea936569c0e328870cae`,
  383,938 bytes;
- prime-squared `Pg` cache
  `s10_cache_hqqprime_prime_charge_squared_pg`: SHA-256
  `971a9a7aa07f496f64fc6c5f8b333d156bfbf27ebeadc8d88297a4b11c85452f`,
  291,906 bytes;
- mixed `Pg` cache
  `s10_cache_hqqprime_mixed_incoming_prime_charge_pg`: SHA-256
  `a1de00773858b02a79e0952183769f85a4678114fc6af9859e15302df412d8bb`,
  1,368,010 bytes;
- incoming-squared `PPP` cache
  `s10_cache_hqqprime_incoming_charge_squared_ppp`: SHA-256
  `29135863a484eeae754f54750635916e9908e6582dc4ae5cbca6d5414f2f2346`,
  266,242 bytes;
- prime-squared `PPP` cache
  `s10_cache_hqqprime_prime_charge_squared_ppp`: SHA-256
  `80d2704635b95253c41c31468d4df41b7832081c15780c32e50a11197e8cbe9a`,
  285,374 bytes;
- mixed `PPP` cache
  `s10_cache_hqqprime_mixed_incoming_prime_charge_ppp`: SHA-256
  `714352bcd6a33806222f6706c3f7731aca03d98221e1a935f9669b0c717ad21c`,
  1,397,333 bytes.

The single complete preflight used exactly three explicitly configured
Engine-15 workers, validated every contracted branch class and representative
endpoint operation, printed `S10_DYNAMIC_PREFLIGHT_SUCCESS`, and left the S10
inventory source-only. Production used the same three-charge-worker layout,
with `Pg` then `PPP` serial inside each worker and no worker-side writes. It
exited `0`, printed exactly one `S10_SUCCESS`, atomically published and
exact-reloaded all six caches and the compact result, and left all 32 final
checks literal `True`. The accepted production log contains no Wolfram
diagnostic, fatal, abort, termination, timeout, kill, or memory-failure
marker.

A fresh no-write reconstruction used three new Engine-15 workers and
recomputed every scale core, ordered source-term Laurent record, coupled-root
certificate, stronger-pole record, endpoint value, formal-distribution
coefficient, and resolved action. It matched all six caches and the compact
result exactly, printed `S10_FRESH_RECONSTRUCTION_SUCCESS`, and changed no
artifact hash. A separate read-only validator then accepted the exact
nine-file hash/size/inventory ledger, paper and S09 bindings, all 44 upstream
checks, all 32 S10 checks, six cache schemas and summaries, root and term
inventories, coefficient ledgers, stronger-pole records, formal skeletons,
action hashes and structure, bookkeeping, three-worker execution record,
compactness, downstream boundary, and production log. Its final corrected
compact-certificate pass returned `True` for every projector/charge branch,
reconfirmed all nine hashes, and printed
`S10_INDEPENDENT_VALIDATION_SUCCESS` with exit status `0`.

The tool-derived source-term counts remain Pg `{17,13,28}` and PPP
`{10,12,30}` in incoming-squared, prime-squared, mixed order; Engine derived
their aggregate as `110`. Every term is alpha-one, every exceptional-power
and direct-singular-log inventory is empty, and all 110 terms used the exact
`factorwise regular` extraction route. Every required-pole-subtraction flag
is `False`. In every branch the reduced stronger-pole residual is exact zero,
its `epsilon^0` and `epsilon^1` records are both exact zero, and the resolved
endpoint value is exact zero. The common exact-zero expression SHA-256 is
`e41dbd4473a67c310bfa14d8ca5e709a622b35e9bf09472e9ff1df41278cad32`.

The accepted physical-root zero/unresolved inventories and coupled groups
are exactly those in the S10 contract above. Every coupled certificate has
maximum endpoint-log degree zero on each physical root and an all-true proof
ledger. For compactness, a persisted `CoupledGroupCertificates` entry stores
the ordered `SourceTermIndices`, `FiniteAnchorSHA256`, and two compact
`RootCertificates`; it deliberately omits the `FiniteAnchor` expression and
each root's `FiniteConstant` expression after those values have been inserted
into the repaired finite coefficients. Each root record retains its maximum
degree, positive-log-power checks, and `FiniteConstantSHA256`. Fresh
reconstruction is the exact expression-level validation of those hash-only
proof records.

The six resolved actions have these exact hash / leaf-count / in-memory-byte-
count identities in projector-first and charge-second order:

- Pg incoming:
  `0c285dc6fae56da3d44542aa4a67f2586824a1ad5ae6708578a256f2baf6b683 /
  144541 / 4140008`;
- Pg prime:
  `8645325b1daacc23f17a2944ccd8073057cf00561abc2805d75ba6394eb952b0 /
  109501 / 3128928`;
- Pg mixed:
  `bafd02f11047948c154712105a9383ffe40a49d3a3853d24883f01c4761f6013 /
  547855 / 15617392`;
- PPP incoming:
  `9332d89547c2489e46bba670d212c064e6d65e0d19c0d692e396b5f5dd630519 /
  98663 / 2818544`;
- PPP prime:
  `007fadf16354b774e579fcae8b82a407120fc954230b951b692f1cd37d751c3e /
  105447 / 3002248`;
- PPP mixed:
  `e4b08fd6166279557ffab6e892f718f874fc7b3613b421b8dc6c77e9d6cfbb07 /
  558360 / 15890048`.

Each action is exact, contains exactly one inherited
``FeynCalc`ScaleMu^(4 epsilon)`` factor and one ordinary endpoint-subtracted
`Inactive[Integrate]`, retains its arbitrary branch-labelled
`S10ConvolutionTest`, and contains no S09 distribution/endpoint placeholder,
`DiracDelta[s23]`, or machine number. The common formal skeleton coefficient
hashes are delta
`acdc87529b35c582a93049109bed6fe19d6891bb195b768c85471b063159bb1a`,
plus-0
`12bb047661d665aa2be9fdc66ab129e375dd69d0007e94b750ee2e1bd9e163d4`,
plus-1
`f1e4989cf713a5f35e302b65e5ef9df626cae2bf3c580557f2dd53f163f331bf`,
and plus-2
`e4b46743e47b699ef2f937c86500d8589cacf73acb1072b65965aec32837868f`.

S09 bookkeeping is unchanged: the additional S10 weight and current-channel
final-state factor are exact integer `1`; Pg and PPP and all three charge
tensors remain separate in fixed order; there is no separate MS-bar
`S_epsilon`, nontrivial symmetry factor, physical ordered-flavour/charge
assembly, or virtual branch. The compact result contains no resolved action;
it provides their ordered cache paths, real disk hashes, branch summaries,
and the exact downstream deferrals.

The exact S10 inventory is the declared source, compact result, production
log, three `Pg` caches, and three `PPP` caches. There is no temporary,
preflight/reconstruction output, helper, runner, monitor, or persistent
validator file. Consumers must load FeynCalc before `Get`, load
`ResolvedAction` only from the six cache paths pinned by `s10_result`, verify
the cache hashes, and preserve projector-first/charge-second ordering, the
three separate charge tensors, unit factors, inherited scale, and absent
virtual branch. The now-accepted S11 calculates the correct paper Eq. (46)
PDF/FF counterterms without adding them to these collinearly unsubtracted real
actions. A separately authorized S12 must align and add the two stages, prove
the remaining pole cancellation, and take the required finite limit; Eq. (9),
F-hat extraction, physical flavour assembly, and external comparison remain
further downstream.

## S11 contract — charge-resolved Eq. (46) collinear counterterms

The authorized S11 entry point is
`s11_calculate_collinear_counterterms_hqqprime.wl`. It calculates and saves
the paper Eq. (46) initial-PDF and final-FF counterterms but does not add them
to S10. A later S12 may align the S10/S11 tests and physical variables,
combine them, prove the remaining pole cancellation, and take the finite
limit.

1. Load FeynCalc before every `Get`. Pin the exact paper, accepted S01 source
   and result, accepted S10 source and compact result, and all six accepted
   S10 endpoint-cache SHA-256 identities recorded above. Require complete
   schemas `HqqprimeS01-v1` and `HqqprimeS10-v1`, every accepted S01 and S10
   check, projector order `{Pg,PPP}`, charge order
   `{IncomingChargeSquared,PrimeChargeSquared,
   MixedIncomingPrimeCharge}`, and the complete inherited scale, symmetry,
   virtual-absence, and physical-assembly deferrals. S11 uses the S10
   artifacts only as a hash-pinned handoff; it must not load or recompute a
   resolved S10 action.
2. Derive the Eq. (46) species sums in Wolfram from the Table-I two-body Born
   support and Eqs. (51)-(53) one-loop splitting support for external
   `i0=q`, `j0=qPrime`, with `qPrime != q`. The PDF sum must reduce uniquely
   to `HgqPrime^(LO) x Pgq`; its photon charge owner is `qPrime`, so it maps
   only to `PrimeChargeSquared`. The FF sum must reduce uniquely to
   `Hqg^(LO) x Pqg`; its photon charge owner is `q`, so it maps only to
   `IncomingChargeSquared`. The mixed tensor has no PDF or FF route. A
   diagonal Hqqprime Born term and one-loop flavour-changing quark or
   antiquark kernel are absent, not evaluated zeros.
3. Generate the two required two-body Born channels directly with FeynArts
   and FeynCalc: `gamma* q -> g(k1) q` for Hqg and
   `gamma* g -> qPrime(k1) qbarPrime` for HgqPrime. Require exactly the
   tool-measured diagram inventory, assign `k1` to the stated fragmenting
   species, sum rather than average final states, and apply the exact incoming
   averages `1/(2 Nc)` for the quark channel and
   `1/((D-2)(Nc^2-1))` for the gluon channel.
4. Read the exact up- and down-type electric charges from accepted S01 model
   metadata and derive each amplitude strip factor as its reciprocal inside
   the program. Generate both Born channels with the up field and regenerate
   both with the down field; after stripping, require exact equality of Pg
   and PPP for each channel. Do not insert a physical charge, flavour
   multiplicity, `Nf`, or `Nf-1`.
5. Open the photon indices, form the exact squared tensors, perform the
   polarization/spin/color sums, and require exact electromagnetic Ward
   contractions for both reference and independent-charge generations.
   Contract separately with paper `Pg=g^(mu nu)` and
   `PPP=p^mu p^nu`, keeping `D=4-2 epsilon` symbolic.
6. Attach exactly one absolute ``FeynCalc`ScaleMu^(2 epsilon)`` factor to
   every charge-stripped Born square. This is the one-strong-vertex Born
   scale in the established dimensionless-renormalized-coupling convention.
   Eq. (46)'s partonic PDF/FF factors add no `mu^epsilon`; the accepted S10
   real action remains separately bound to its single absolute
   ``FeynCalc`ScaleMu^(4 epsilon)`` factor for later combination.
7. Use the paper Eqs. (34)-(35) two-body normalization
   `2 Pi/(2 Pi)^4` and derive the PDF/FF splitting variables, on-shell Born
   delta identities, Jacobians, and endpoint ranges in Wolfram. Convert the
   internally projected incoming momentum to the external paper projector
   with `1/y^2` only for the PPP PDF density. Pg and both FF densities receive
   no such factor.
8. Use the positive Eq. (46) prefactor
   `g_s^2 S11SEpsilon/(16 Pi^2 epsilon)` implied by the negative partonic
   PDF/FF terms in Eqs. (49)-(50). Retain `S11SEpsilon` symbolically in the
   paper's MS-bar convention. Use exactly
   `Pgq(y)=2 CF (1+(1-y)^2)/y` and
   `Pqg(y)=2 TF ((1-y)^2+y^2)`. Both are regular at `y=1`, so each nonzero
   component is one ordinary inactive integral against an arbitrary symbolic
   test and contains no splitting delta/plus placeholder.
9. Save `CountertermComponents` and `CountertermsByProjectorCharge` in
   projector-first/charge-second order. For each projector, the incoming-
   squared branch has exact component support `PDF -> 0, FF -> nonzero`; the
   prime-squared branch has `PDF -> nonzero, FF -> 0`; and the mixed branch
   has `PDF -> 0, FF -> 0` and exact-zero total. Thus the six ordered totals
   contain four nonzero one-integral actions and two explicit structural
   zeros. The arbitrary test must carry both projector and charge labels.
10. Preserve the accepted additional weight `1`, final-state factor `1`,
    three separate charge tensors, coefficient-tensor charge freedom, absent
    virtual branch, and unapplied physical ordered `q,qPrime` flavour/charge
    assembly. Add no nontrivial symmetry factor, separate flavour weight,
    S10 action, second scale factor, concrete PDF/FF, numerical kinematics,
    Eq. (9) combination, or external-code convention.
11. Write one compact schema-`HqqprimeS11-v1` Association atomically through
    a process-specific temporary path, exact-reload it, refuse silent
    overwrite of an existing final result, and leave no temporary artifact.
    After a complete held parse/static audit, execute the calculation once in
    production with all provenance, routing, Born, Ward, charge, mapping,
    scale, component-shape, and atomic-write gates embedded. Do not repeat the
    accepted S10 calculation or duplicate the full S11 Born calculation in a
    redundant preflight/reconstruction run.
12. Keep the direct Born generations serial. FeynArts/FeynCalc model,
    generated-index, and scalar-product state is package-global, and this
    small stage has no safely demonstrated benefit from local subkernels.
    S11 ends with charge-resolved counterterms only. S10 combination,
    collinear-pole cancellation, the `epsilon -> 0` finite hard part, paper
    Eq. (9) inversion, F-hat extraction, physical ordered flavour/charge
    assembly, and external comparison remain separately authorized
    downstream work.

### Accepted S11 artifacts and evidence

S11 is complete and accepted with stage schema `HqqprimeS11-v1`, result
schema version `1`, and this exact three-file artifact ledger:

- source `s11_calculate_collinear_counterterms_hqqprime.wl`: SHA-256
  `86725c6c85baf15f1d209e98a06ab7a7c7f28ffe4ec4fcb4efe59e77a3eafd03`,
  52,074 bytes / 1,676 lines;
- result `s11_result`: SHA-256
  `0c58e67a9d108de830768d5b04d4078fd6fd0265abdd03a54a2a1dec0b2c186b`,
  22,090 bytes;
- production log `s11_calculate_collinear_counterterms_hqqprime.log`:
  SHA-256
  `9550587e95dc8c1c340aa2bd5a1a7830b2f6ccf2dd5ec04f9f91778c6e205011`,
  6,704 bytes.

Engine 15 parsed all 163 source expressions under `Hold` before production.
The static audit found exactly one atomic `Put`, one `RenameFile`, two
temporary-cleanup `DeleteFile` calls, and no external process, local-kernel
launch, parallel mapping, machine real, `PowerExpand`, foreign-channel path,
or BigTMD dependency. One invalid outer-Association `All` selector was found
by a focused pre-execution semantic probe and corrected at the source before
any Born calculation ran. The corrected source was fully reparsed and
restatically accepted at the hash above.

The single production run used verified Wolfram Engine 15.0, an 8-GiB
process address-space ceiling, and one native math thread. It exited `0` in
about 24 seconds, printed exactly one
`S11_SUCCESS_SYMBOLIC_COUNTERTERMS`, atomically wrote and exact-reloaded the
result, and left all 37 saved checks literal `True`. The log has no S11 fatal,
abort, termination, timeout, kill, or memory-failure marker. Its only
diagnostics are the established FeynArts protected-`Discard` and
FeynArts/FeynCalc `FCGV` context-shadow startup notices. Consistent with the
explicit no-redundancy contract, no full no-write preflight, repeated Born
reconstruction, or S10 recalculation was run.

The program derived the complete Eq. (46) support rather than importing a
channel-specific list. The unique PDF route is
`HgqPrime^(LO) x Pgq`, owned by `PrimeChargeSquared`; the unique FF route is
`Hqg^(LO) x Pqg`, owned by `IncomingChargeSquared`. In the accepted charge
order, support is therefore incoming squared `PDF/FF -> 0/1`, prime squared
`1/0`, and mixed `0/0`. The two mixed projector totals are exact structural
zeros. They denote absent Born/splitting routes, not evaluated-zero
counterterms.

Both the reference and independent-charge generations measured exactly two
diagrams for Hqg and two for HgqPrime. The program derived the up/down strip
factors as reciprocals of accepted S01 model charges, obtained exact equality
of all stripped Pg/PPP Born pairs, and passed every reference and validation
Ward contraction. The initial average denominators are exactly
`2 SUNN` for Hqg and `(D-2)(SUNN^2-1)` for HgqPrime.

The four nonzero component expression identities are SHA-256 / leaf count /
in-memory byte count:

- Pg incoming-squared FF:
  `160bc062e519a73da1e81c21b71157264e008c05cae5df59124095fdb408569f /
  449 / 11,752`;
- Pg prime-squared PDF:
  `9695d99addacbea0de7564d02db888923235c5852ecd89202d2ff9c9011ba6a0 /
  302 / 8,144`;
- PPP incoming-squared FF:
  `d8128c67db46a67af68d5f9471d5dc5e61473c96a4433ab41f42181e54f788a4 /
  136 / 3,808`;
- PPP prime-squared PDF:
  `7bb8ad2553455a7a2e02a87dfce7970a813386bbf9fa359459812a8d75ffd01a /
  117 / 3,360`.

Each nonzero component contains exactly one ordinary inactive integral, one
projector-and-charge-labelled `S11ConvolutionTest`, symbolic
`S11SEpsilon/epsilon`, and exactly one absolute
``FeynCalc`ScaleMu^(2 epsilon)`` factor. Only the PPP PDF density has the
external-projector `1/y^2` conversion. No splitting distribution placeholder,
generic charge symbol, physical flavour weight, concrete PDF/FF, machine
number, nontrivial symmetry factor, virtual contribution, or S10 action is
present.

A fresh artifact-only Engine-15/FeynCalc validator did not invoke FeynArts or
rebuild any Born expression. All seven groups were exact `True`: live
disk/source-bound schema; all 37 checks and both orders; species/charge
routing; six-branch component shape and total equality; integral/scale/test
structure; unit/scale/symmetry/virtual/assembly bookkeeping; and production
log/downstream boundary. The exact S11 inventory remains only the source,
result, and production log. No cache, temporary, helper, runner, monitor,
preflight output, validator file, or surviving kernel exists.

Consumers must load FeynCalc before `Get`, then read the six ordered totals at
`s11Result["CountertermsByProjectorCharge",projector,chargeKey]` or their
separate PDF/FF entries at `s11Result["CountertermComponents",projector,
chargeKey]`. A separately authorized S12 must map each nonzero S11 test and
kinematics to its matching hash-pinned S10 `ResolvedAction`, preserve the two
mixed structural zeros and all inherited bookkeeping, expand the symbolic
MS-bar factor with Wolfram, and prove pole cancellation separately for every
projector/charge/action field before taking a finite limit. Paper Eq. (9),
F-hat extraction, physical ordered flavour/charge assembly, and external
comparison remain later work.

## S12 contract — charge-resolved factorization and finite actions

The authorized S12 entry point is
`s12_combine_factorization_hqqprime.wl`. Its outputs are the compact
`s12_result`, production log
`s12_combine_factorization_hqqprime.log`, and six projector/charge caches
named `s12_cache_hqqprime_<charge-key>_<projector>`.

1. Load FeynCalc before every serialized artifact. Pin the authoritative
   paper, accepted S10 and S11 sources/results, and all six S10 endpoint
   caches to the exact accepted SHA-256 identities above. Require complete
   schemas `HqqprimeS10-v1` and `HqqprimeS11-v1`, all accepted checks, exact
   projector order `{Pg,PPP}`, charge order `{IncomingChargeSquared,
   PrimeChargeSquared,MixedIncomingPrimeCharge}`, and their complete scale,
   charge, symmetry, virtual-absence, and physical-assembly deferrals.
2. Rebuild paper Eqs. (29)-(32) symbolically with `xHat=xB/xi`, the exact
   `zeta(xi,s23)`, `zHat=zH/zeta`, partonic transverse momentum, Jacobian, and
   interval `0<=s23<=B(xi)`. Wolfram must prove the Jacobian, Eq. (40),
   external-invariant identity, both Eq. (46) Born-shell identities, and both
   endpoint splitting-variable identities exactly.
3. Map every saved nonzero S11 inactive-integral density by removing only its
   matching three-label `S11ConvolutionTest`, applying the physical map and
   Jacobian, and adopting the matching three-label S10 test convention.
   Independently rebuild the same density from S11's saved `HgqPrime` or
   `Hqg` Born projection, saved two-body normalization, and printed `Pgq` or
   `Pqg` kernel. Require exact equality branch by branch. Only PPP PDF may
   receive `1/y^2`.
4. Preserve the tool-derived routing: the incoming-squared branch contains
   only `Hqg^(LO) x Pqg` FF subtraction, the prime-squared branch contains
   only `HgqPrime^(LO) x Pgq` PDF subtraction, and the mixed branch is an
   exact structural zero for both PDF and FF. No diagonal Hqqprime Born route
   or flavour-changing one-loop quark kernel may be introduced.
5. Use S11's positive Eq. (46) sign. Expand
   `S11SEpsilon -> (4 Pi)^epsilon/Gamma[1-epsilon]` with Wolfram `Series`;
   do not insert a hand-written finite constant. Retain the one Born
   ``FeynCalc`ScaleMu^(2 epsilon)`` in each nonzero counterterm and do not add
   a PDF/FF scale power. Do not reapply `S_epsilon` or the already present
   absolute ``FeynCalc`ScaleMu^(4 epsilon)`` to S10.
6. Derive the SU(N) conversion rules at runtime with FeynCalc's fundamental-
   generator trace and `SUNSimplify`, then canonicalize the combination
   boundary with ``FeynCalc`SUNN -> FeynCalc`CA``. Require the derivation and
   regression identities exactly; do not alter either accepted upstream
   artifact.
7. Load each `ResolvedAction` only from its compact-result-pinned S10 cache.
   Derive its three action fields and factor partition from the current
   expression. Runtime must remeasure one nonzero `IntegrandPhiS`, exact-zero
   `Endpoint` and `IntegrandPhi0`, one ordinary physical `s23` integral, and
   the cache-recorded source-term count. The accepted measured counts remain
   Pg `{17,13,28}` and PPP `{10,12,30}` in fixed charge order, all alpha one;
   these are gates on the current hash-pinned payload, not imported algebra.
8. Extract exact S10 coefficients at `epsilon^{-2}`, `epsilon^{-1}`, and
   `epsilon^0` by factorwise Wolfram series algebra on the current action.
   Expand each mapped S11 total through `epsilon^0`. For every projector,
   charge key, and action field separately, require the real double pole and
   real-plus-Eq.-(46) simple pole to reduce to exact zero. The two mixed
   simple poles must vanish with a literal-zero counterterm.
9. Only after all pole gates pass, save the exact finite coefficient pair and
   factorized action on
   `S10ConvolutionTest[projector,chargeKey,s23]`. They must contain no
   `epsilon`, `SeriesData`, `S11SEpsilon`, S11 test, S09 endpoint/distribution
   placeholder, `DiracDelta[s23]`, `SUNN`, `CF`, `TF`, machine number,
   infinity/failure object, or accidental Global-context QCD symbol. Every
   finite action retains exactly one ordinary physical `s23` integral.
10. Bind each branch cache to schema `HqqprimeS12Cache-v1`, the exact S12
    source, paper, S10/S11 sources/results, its exact S10 cache and resolved-
    action identity, projector, charge key, mapped-counterterm identity,
    measured partition, complete pole record, finite pair/action, and all
    inherited bookkeeping. Write caches and the compact schema
    `HqqprimeS12-v1` result through process-specific temporary Associations,
    exact-reload validate before atomic rename completion, recompute actual
    disk hashes, and refuse silent final-result overwrite.
11. The three charge keys are independent. Configure exactly three local
    workers in memory with the verified Engine-15 `WolframKernel`; assign one
    charge key to each worker and process Pg then PPP serially inside that
    worker. Workers return deterministic records and never write files; only
    the main kernel publishes caches/result. Intrabranch exact series and
    residual reduction remain serial.
12. After the held parse, perform exactly one complete no-write preflight of
    the same six-branch algebra and candidate-result gates, followed by
    exactly one production calculation with embedded atomic reload
    verification. Do not rerun S10/S11 or reconstruct S12 after production.
    S12 stops at exact finite charge-resolved Pg/PPP actions. Paper Eq. (9),
    F-hat extraction, physical ordered
    `q,qPrime!=q` flavour/charge assembly, and external comparison remain
    separately authorized later work.

## Accepted S12 artifacts and evidence

The accepted S12 source is `s12_combine_factorization_hqqprime.wl`, SHA-256
`e66cb95ce187146e7c5c356b0fd0b12e0c59202c31c38418dc21aa1662ecb76e`,
68,093 bytes / 2,041 lines. The compact schema-`HqqprimeS12-v1` result is
`s12_result`, SHA-256
`c7ba66cf0bb12cd77822d3831dbcf3e0ff64a1be18b28f040df6caf12ee19dbf`,
18,312 bytes. The production log is
`s12_combine_factorization_hqqprime.log`, SHA-256
`7b028a52f3c5c25f51501accdf1a476040da25dfbfd3f404791cda300d101840`,
12,905 bytes.

The six accepted schema-`HqqprimeS12Cache-v1` finite-action caches, in
projector-first and charge-second order, are:

- `s12_cache_hqqprime_incoming_charge_squared_pg`, SHA-256
  `f02f3c2868d86013d11d75a3faa4d64441b2b092a02f12951d59d4546e583073`,
  7,651,783 bytes;
- `s12_cache_hqqprime_prime_charge_squared_pg`, SHA-256
  `5fdab81e9aba825f637f7f207707b33f2d2e1bbdde688ad43c63538e4adba5a7`,
  11,642,495 bytes;
- `s12_cache_hqqprime_mixed_incoming_prime_charge_pg`, SHA-256
  `283246c13375c77a52da2351e18febe57a13593b79b9038478118f650ac64b02`,
  8,144,076 bytes;
- `s12_cache_hqqprime_incoming_charge_squared_ppp`, SHA-256
  `3556a2da658e3b856302890412db5bad11fd8c1b37b77144749b728ec0f5472e`,
  258,303 bytes;
- `s12_cache_hqqprime_prime_charge_squared_ppp`, SHA-256
  `961b388a5bde4b6edaea25bde101365e3aca53af9f63ba870a887495da78b558`,
  326,182 bytes;
- `s12_cache_hqqprime_mixed_incoming_prime_charge_ppp`, SHA-256
  `3329786307d17486a62f0ce0a887797f1b2ddfcd869bec06028030ff6d19d504`,
  9,685,754 bytes.

The single complete no-write preflight used the production source and the
same three-charge-worker layout, ignored S12 caches, validated all six branch
payloads and the compact result candidate, printed
`S12_PREFLIGHT_SUCCESS_NO_WRITE`, exited zero, and left no cache, result, or
diagnostic. Production then ran the unchanged source once, emitted exactly
six branch checkpoints, atomically wrote and exact-reloaded every cache and
the compact result, printed exactly one
`S12_SUCCESS_FINITE_FACTORIZED_HQQPRIME`, and exited zero. The result stores
30 literal-true checks; every cache stores 14 literal-true checks.

The production tool reported source-term counts Pg `{17,13,28}` and PPP
`{10,12,30}` in incoming/prime/mixed order. It reported exact zero for every
double- and simple-pole residual separately in `Endpoint`, `IntegrandPhiS`,
and `IntegrandPhi0` for all six branches. Its accepted bookkeeping preserves
the positive Eq. (46) convention, the Wolfram-expanded MS-bar S-epsilon
factor, PDF routing to `PrimeChargeSquared`, FF routing to
`IncomingChargeSquared`, structural-zero mixed counterterms, the accepted
``FeynCalc`SUNN -> FeynCalc`CA`` combination boundary, inherited real
`ScaleMu^(4 epsilon)` and counterterm-Born `ScaleMu^(2 epsilon)` factors, no
additional partonic-PD-for-FF mu-epsilon factor, unit additional and
final-state symmetry weights, three separate charge tensors, and the absent
virtual contribution at this order.

A separately requested read-only independent artifact validator exited zero
with `S12_INDEPENDENT_VALIDATION_SUCCESS`. All ten groups were literal true:
exact inventory/no temporary or diagnostic; result schema/source binding;
current upstream hashes; six cache schemas/source bindings; result-cache
path/hash/summary cross-links; stored map/counterterm/pole zero ledgers;
finite-payload hashes, sizes, and one-inactive-integral structure; complete
charge/scale/symmetry/virtual/parallel bookkeeping; exactly six production
checkpoints, one success, and no failure marker; and disk immutability during
validation. It did not evaluate the S12 source or reconstruct branch algebra.

The exact S12 inventory is the source, compact result, production log, and
six caches above. There is no temporary, disposable preflight output,
diagnostic, helper, runner, monitor, reconstruction, or persistent validator
file. Consumers must load FeynCalc before `Get`, verify `s12_result` and all
six disk hashes, preserve projector-first/charge-second ordering, and read
`FiniteCoefficientPair` or `FiniteFactorizedAction` only from the cache paths
pinned by `s12_result`. Paper Eq. (9), Pg/PPP inversion, F-hat extraction,
physical ordered `q,qPrime!=q` flavour/charge assembly, external comparison,
and numerical kinematics remain separately authorized later work.

## S13 contract: Eq. (9) extraction of charge-resolved F-hat actions

S13 is authorized to consume the accepted S12 finite Pg/PPP coefficient
pairs and perform only the paper's Eq. (9) extraction of `F1Hat` and
`F2Hat`. Its contract is:

1. The only mathematical payload inputs are `FiniteCoefficientPair` from the
   six accepted schema-`HqqprimeS12Cache-v1` caches above. Bind the exact
   paper, S12 source/result, and all six S12 cache paths and SHA-256 values.
   Load FeynCalc before deserialization, require all stored S12 checks, and
   never parse an S12 action or rerun S10, S11, or S12 algebra.
2. Enter the two D-dimensional paper Eq. (9) definitions in terms of symbolic
   Pg/PPP dummy contractions and derive every projector coefficient with
   Wolfram `Coefficient`. Substitute the already accepted partonic mapping
   `xHat=xB/xi` from `s12_result`; no matrix element may be transcribed as a
   precomputed literal.
3. Before taking `epsilon -> 0` in the Eq. (9) weights, require every stored
   S12 `Endpoint`, `IntegrandPhiS`, and `IntegrandPhi0` double- and simple-pole
   entry to be exact zero. Derive the finite weight matrix, its determinant,
   and its inverse with Wolfram; require exact reconstruction of both Eq. (9)
   definitions and exact left/right inverse identities on independent dummy
   structures.
4. Preserve fixed orders `F1Hat,F2Hat`,
   `IncomingChargeSquared,PrimeChargeSquared,MixedIncomingPrimeCharge`, and
   `Pg,PPP`. For each charge key and each coefficient-pair field, combine the
   current Pg/PPP values with the derived finite weights. Do not combine,
   factor out, or substitute physical electric charges.
5. Rebuild one exact ordinary physical-interval action for every
   structure-function/charge pair on
   `S13ConvolutionTest[structureFunction,chargeKey,s23]`. Each output must be
   derived from its pair, retain exactly one inactive `s23` integral, and
   have the pair/action hashes and sizes remeasured by the program. The
   currently observed zero endpoint and phi0 are runtime gates, not assumed
   literals.
6. Require every pair/action to be exact and free of `epsilon`, `SeriesData`,
   S09/S10/S11 placeholder or test heads, `DiracDelta[s23]`, `SUNN`, `CF`,
   `TF`, machine numbers, infinity/failure objects, accidental Global-context
   QCD symbols, physical charge symbols, and `Re`, `Im`, or `Conjugate`.
   Preserve the accepted physical `s23` lower/upper bounds and mapping
   certificates from S12.
7. Publish six caches in structure-function-first/charge-second order:
   `s13_cache_hqqprime_<charge>_f1hat` and
   `s13_cache_hqqprime_<charge>_f2hat`. Each schema-
   `HqqprimeS13Cache-v1` Association must bind the S13 source, paper, S12
   source/result, the two relevant Pg/PPP S12 cache identities and pair
   identities, its structure function and charge key, derived dimensional
   and finite weights, exact pair/action, checks, and inherited bookkeeping.
8. Publish compact schema `HqqprimeS13-v1` as `s13_result`. It stores only
   source/upstream identities, ordered cache paths and actual disk hashes,
   compact branch summaries, Eq. (9) derivation/inversion certificates,
   mapping, bookkeeping, and literal-true checks; it must not duplicate any
   finite pair or action payload. The production log is
   `s13_extract_fhat_hqqprime.log`.
9. Preserve S12's positive Eq. (46) result, separate charge tensors, accepted
   color basis, inherited scale dependence, unit additional and final-state
   symmetry weights, and absent virtual contribution. Introduce no new
   MS-bar, scale, color, channel, charge, or symmetry factor.
10. Configure exactly three local workers in memory with the verified
    Engine-15 `WolframKernel`, one independent charge key per worker. Each
    worker reads its Pg/PPP caches and computes `F1Hat` then `F2Hat` serially;
    workers write nothing. Preserve deterministic order and let only the main
    kernel atomically publish and exact-reload the six caches and compact
    result. Intrabranch combinations remain serial.
11. After one held source parse, run exactly one complete no-write preflight
    through the production entry point and validate all six candidate cache
    payloads plus the compact-result candidate. Then run the unchanged source
    exactly once in production with embedded atomic exact-reload validation.
    Do not add a reconstruction run or unsolicited independent validator.
12. Stop when production has emitted the terminal success marker and all six
    caches plus `s13_result` have passed embedded reload gates. Outer `xi`
    convolution, physical ordered `q,qPrime!=q` flavour/charge assembly,
    PDFs/FFs, other-channel assembly, external comparison, and numerical
    kinematics remain deferred.

## Accepted S13 artifacts and evidence

The accepted S13 source is `s13_extract_fhat_hqqprime.wl`, SHA-256
`80141cec99769c0e32324fffcfc1322b5751554bc5f73172d7801bfa6041789e`,
48,399 bytes / 1,484 lines. The compact schema-`HqqprimeS13-v1` result is
`s13_result`, SHA-256
`351f1cbb6995d479cac0087e1cfefb92885c1e1f7dfb362386ba7dfe5c7d4365`,
17,344 bytes. The production log is `s13_extract_fhat_hqqprime.log`,
SHA-256
`3b9abfdda9b531a23a4342bf1c2b3e316f88cf08397bfc7759a02b2e9b684d76`,
8,908 bytes.

The six accepted schema-`HqqprimeS13Cache-v1` caches, in structure-function-
first and charge-second order, are:

- `s13_cache_hqqprime_incoming_charge_squared_f1hat`, SHA-256
  `59cbf25b48e596d74b0541a1887f74a4256076002322cb4b110f078e3463adf0`,
  5,374,397 bytes;
- `s13_cache_hqqprime_prime_charge_squared_f1hat`, SHA-256
  `a755f32e6319c798fd24bdfdd2265b1d7adf88c7e203ca0d6c88995ae27f0d07`,
  8,150,711 bytes;
- `s13_cache_hqqprime_mixed_incoming_prime_charge_f1hat`, SHA-256
  `24caef792f819725d9d607e21d0528a77164a2d64dd04337fcedf493f2ac1682`,
  10,471,688 bytes;
- `s13_cache_hqqprime_incoming_charge_squared_f2hat`, SHA-256
  `6e07c2d9f20fbca5e038e127c932ba8e0f0c32e6c113ddadb430b22bb7a847d7`,
  5,469,108 bytes;
- `s13_cache_hqqprime_prime_charge_squared_f2hat`, SHA-256
  `716be770e25f9bec27127c1815c0ee4653b40b46b74c74753c95ef8a95445891`,
  8,326,903 bytes;
- `s13_cache_hqqprime_mixed_incoming_prime_charge_f2hat`, SHA-256
  `babc7fbc0692727e7f57a9d0cfd437ae5ed4cbb1f7e495a30321be4060a08f1d`,
  10,471,727 bytes.

The program transcribed only the two D-dimensional paper Eq. (9)
definitions, then used Wolfram `Coefficient`, `Limit`, `Det`, and `Inverse`.
It reconstructed both definitions exactly, gated every stored S12 pole field
at literal zero before the finite limit, and proved exact left/right inverse
and dummy-projector reconstruction identities. The tool-produced finite
weights after applying accepted `xHat=xB/xi` were Pg `-1/2` and PPP
`2 xB^2/(Q2 xi^2)` for F1Hat, and Pg `-xB/xi` and PPP
`12 xB^3/(Q2 xi^3)` for F2Hat.

The accepted corrected-source no-write preflight launched three verified
Engine-15 workers, returned three distinct worker IDs in deterministic charge
order, validated all six candidates with 15 literal-true checks apiece,
validated the compact-result candidate, printed
`S13_PREFLIGHT_SUCCESS_NO_WRITE`, exited zero, and left the S13 inventory
empty. A superseded source invocation had earlier caught only a too-narrow
action-symbol allow-list; a focused tool probe found the missing symbol was
the integration interval's `System`List` head, and the accepted source changed
only that allow-list entry before its held parse and successful preflight.

Production then ran the accepted source once. Workers wrote nothing; the main
kernel atomically wrote and exact-reloaded all six caches in the order above,
then atomically wrote and exact-reloaded the compact result. It printed six
cache checkpoints, one `S13_SUCCESS_FINITE_FHAT_HQQPRIME`, no fatal marker,
and exited zero. Every cache has all stored checks literal true and exactly
one inactive integral on the accepted physical `s23` interval; the compact
result has all stored checks literal true and contains no finite pair/action
payload.

The tool-produced finite pair/action identities are:

| Structure function | Charge key | Pair SHA-256 | Action SHA-256 |
|---|---|---|---|
| F1Hat | IncomingChargeSquared | `7f2303c53aabfac821e12e92f9121d09c64a38fc53053f78cf8bfaf7a7dea647` | `7ece6bb785554593bf3ef583ca58b5de698849b762c21fcac8ea03b775668450` |
| F1Hat | PrimeChargeSquared | `a0c5708a8a916ed0eceed868898972381dd24b0cba6018c9be9669001fc292fc` | `3e537828ab80fff696af1f36a3a0da48f950c305361566eab3287152ba319dbd` |
| F1Hat | MixedIncomingPrimeCharge | `7b0ea8d36efc991eff38a3ac88dd975e28be61971b237e31fffcf690f1359faa` | `a0b974c8555f6fa32764264c6ebfaee3a8d2cf2e90f5eb2220ca77114b9410d7` |
| F2Hat | IncomingChargeSquared | `d8cfe3974757c6244e9ace155737e97b8883ce69f2c60d91b90cd6b225d2b23e` | `01dd4fbf1dcf2234b9c0dc012223c87708ff9e3a308d78c9f1ddc3b4dcf51bf5` |
| F2Hat | PrimeChargeSquared | `98aeff60f18cf55e61319682b7699dd218b98524ddaa745b50a1f3fed4fa1dfe` | `bf1c0c28cab686a6a1c3b3e1f5872a24c4aebbbd19446b775a13cdfc9425618f` |
| F2Hat | MixedIncomingPrimeCharge | `cfbe4c8a317eb319f036bf1910e983dc2055ec4ec051706fe145938188a4c1dd` | `a7c8ed2ae28666284d7efaa548f2a7c4b81e1aed9add0eb5f87cf99911389547` |

S13 preserves the positive Eq. (46) finite S12 result, all three separate
charge tensors, the accepted color basis and scale dependence, unit
additional and final-state symmetry weights, and the absent virtual branch.
It introduces no new MS-bar, scale, color, charge, flavour, symmetry, or
Hermitian-projection factor. Physical ordered `q,qPrime!=q` charge/flavour
assembly is still unapplied.

Consumers must load FeynCalc before `Get`, verify `s13_result` and all six
disk hashes, preserve structure-function-first/charge-second order, and read
`FiniteCoefficientPair` or `FiniteHattedAction` only from the cache paths
pinned by `s13_result`. Outer `xi` convolution, physical ordered-flavour and
charge assembly, PDFs/FFs, other-channel assembly, external comparison, and
numerical kinematics remain separately authorized later work. No independent
reconstruction or post-production validator was run.

## BigTMD check contract — channel 6 A/B/C regular F-hat coefficients

The user authorized a self-contained `bigTMD_check/` sequence modelled on the
accepted Hqqbar comparison and explicitly authorized copying the pinned
BigTMD reference when applicable. This is an external numerical benchmark of
accepted S13; it is not S14 and it does not change, replace, or rederive any
accepted Hqqprime artifact.

The local mathematical expressions remain in the six accepted
schema-`HqqprimeS13Cache-v1` files listed above. Their exact coefficient pairs
and exact inactive actions are the cache fields `FiniteCoefficientPair` and
`FiniteHattedAction`. Compact `s13_result` deliberately contains only their
paths, disk hashes, branch summaries, bookkeeping, physical mapping, and
checks. The external mathematical expressions are the generated Python
functions `regular`, `delta`, `plus1B`, and `plus2B` in the copied reference
under `BigTMD_reference/NLO/Pg/` and `BigTMD_reference/NLO/Ppp/`. For BigTMD
driver channel 6 only `regular` is selected; the other three generated
functions remain reference material and are not comparison inputs.

The new sequence has exactly two task programs:

1. `bigTMD_check/s01_export_local_fhat_benchmarks.wl` validates the accepted
   Hqqprime and paper identities, loads each S13 cache through the compact
   result, proves that its endpoint and phi-zero fields are exact zero, and
   evaluates only `IntegrandPhiS` at three program-validated rational interior
   points. It keeps the local expression exact through substitution and calls
   numerical evaluation only for the final JSON value. It atomically writes
   `bigTMD_check/local_fhat_benchmarks.json` and logs to
   `bigTMD_check/s01_export_local_fhat_benchmarks.log`.
2. `bigTMD_check/s02_compare_bigtmd_fhat.py` validates that local export and
   the copied reference identities, imports the six selected generated
   channel-6 modules, evaluates their `regular` functions, applies the
   driver's matched variable-change Jacobian to the BigTMD side only, builds
   F1Hat and F2Hat with the paper Eq. (9) weights, and reports the signed
   difference `BigTMD - local`. It atomically writes
   `bigtmd_fhat_benchmarks.json`, `bigtmd_minus_local.json`, and
   `bigtmd_minus_local.md`, and logs to `s02_compare_bigtmd_fhat.log` in the
   same directory.

S01 must pin and validate:

- authoritative paper SHA-256
  `bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`;
- accepted S13 source `../s13_extract_fhat_hqqprime.wl`, SHA-256
  `80141cec99769c0e32324fffcfc1322b5751554bc5f73172d7801bfa6041789e`;
- accepted compact result `../s13_result`, SHA-256
  `351f1cbb6995d479cac0087e1cfefb92885c1e1f7dfb362386ba7dfe5c7d4365`;
- the six exact S13 cache paths and hashes recorded in the accepted S13
  section above, in structure-function-first and charge-second order.

The copied reference must remain at commit
`6e97635d21a63b7975b2e7f5891edc0c35c4dc0c`. S02 must pin the driver
`BigTMD_reference/sidis.py`, SHA-256
`150a4b66ce25c41178a51ef54989dc5a83d7a272678e1d4f95237ddb9758785d`,
and these generated channel-6 modules:

| BigTMD case | Pg module / SHA-256 | Ppp module / SHA-256 |
|---|---|---|
| A | `NLO/Pg/fchn6A.py` / `502dbfb704a85356d004dcc290604a85cbe6379d664d47e27968aea795e1f3dd` | `NLO/Ppp/fchn6A.py` / `2a3c88860a52be0946cd824cbb31fbc959d4384706cd9ac790a44f752d54dbd4` |
| B | `NLO/Pg/fchn6B.py` / `ce3bd5d92a0be6da8559f8c4daf629741dd52277cb0c1166b6b3286484a72fb9` | `NLO/Ppp/fchn6B.py` / `bd522acf18af68129a125ce69405ab8283d4a7f718d1ee1be6e068cc6ae9e761` |
| C | `NLO/Pg/fchn6C.py` / `81fe1c6c909148aef8cdfafff86552645a5df68049d088b1ff6a931eafae2326` | `NLO/Ppp/fchn6C.py` / `48bbba2e8c407665ed98824867a9e0f6429746803aaa8f9f59b8a4ab24ac6245` |

An Engine-15 symbolic permutation probe matched the accepted local charge
monomials to the channel-6 luminosity monomials in `sidis.py` and established
the complete one-to-one routing

| BigTMD case | Local S13 charge key |
|---|---|
| A | `IncomingChargeSquared` |
| B | `MixedIncomingPrimeCharge` |
| C | `PrimeChargeSquared` |

The same driver inspection established that channel 6 is active in the NLO
loop while delta/plus assembly is restricted to channels below 4. The check
therefore compares the regular contribution only for all three cases. It
must not evaluate or add the generated `delta`, `plus1B`, or `plus2B`
functions. The exact-zero S13 endpoint and phi-zero gates are the local
counterpart of that driver selection.

S01 uses the same three rational benchmark seeds as the accepted Hqqbar
check, derives every dependent invariant and the physical `s23` interval in
the program, and asserts that each point is interior under the accepted S13
map `xHat=xB/xi`. The local settings are `EL=1`, `gs=1`, `ScaleMu=Q`,
`CA=3`, `CF=4/3`, and `TF=1/2`. S02 evaluates the reference with `g=1`,
`gp=1`, `mu=Q`, and `nf=4` at the identical kinematics. These are benchmark
normalizations, not a physical flavour/charge assembly.

The S13 local action already includes its accepted `zeta`-to-`s23`
variable-change factor. S02 applies the matching driver Jacobian
`zeta*xHat/(Q2*((1-xHat)-xHat*s23/Q2))` only to the BigTMD regular
projectors, then constructs F1Hat and F2Hat from Pg and Ppp through the same
Eq. (9) definitions used by S13. The rest of the driver's luminosity/test
factor is deferred identically on both sides. No extra case weight,
symmetry factor, flavour multiplicity, charge sum, or physical luminosity is
allowed.

All three charge tensors remain separate: three benchmarks times three cases
times two structure functions give 18 signed comparisons. There is no A+B+C
sum. Each row uses tolerance
`1e-10 + 1e-7*max(abs(BigTMD),abs(local))`. Agreement or disagreement is a
valid completed benchmark; a numerical mismatch must be reported faithfully
and must not trigger edits to either source.

Both programs refuse pre-existing final or temporary outputs and write final
artifacts atomically. Before execution, each source is parsed once with its
native held/syntax parser. Then S01 is run once and S02 is run once. Their
embedded provenance, schema, structural, finiteness, and coverage gates are
the validation; no redundant local reconstruction, second production run,
or independent post-production validator is authorized. The check stops as
soon as the 18-row report has been produced and verified by those gates.
Outer `xi` convolution, physical ordered `q,qPrime!=q` charge/flavour
assembly, PDFs/FFs, cross-channel assembly, and any change to S13 remain
outside this task.

### Accepted BigTMD check result

The comparison sequence is complete. The accepted sources are:

- `bigTMD_check/s01_export_local_fhat_benchmarks.wl`, SHA-256
  `e80aa72f2efda1df010d51731ed92bd9101a99e42ea89f487f74693de1f53f82`,
  25,455 bytes / 691 lines;
- `bigTMD_check/s02_compare_bigtmd_fhat.py`, SHA-256
  `58b2fdb09ec5cb0198e5eac439284644ac67d79e5c6720f56e7abe3c121231ae`,
  26,919 bytes / 680 lines.

The accepted S01 local numerical export is
`bigTMD_check/local_fhat_benchmarks.json`, SHA-256
`a125d24e8d961c00805591d69dc638f606a22960e8d6422d9968238d5bbe1b21`,
10,648 bytes. Its successful canonical log is
`bigTMD_check/s01_export_local_fhat_benchmarks.log`, SHA-256
`2cb0856dc611f2b95ee45eef091505af0db56ce2b5f63ae5d974f008e54366d0`,
2,444 bytes.

The accepted S02 outputs are:

- `bigTMD_check/bigtmd_fhat_benchmarks.json`, SHA-256
  `98cad18e3303118e77e1a2afcbcba6295aa8474028d3aab597fbd62d9d8c23cf`,
  8,625 bytes;
- `bigTMD_check/bigtmd_minus_local.json`, SHA-256
  `a4b556f47590a5deec9982ece795b8d640458829737f2a092418bdd041d48431`,
  25,887 bytes;
- `bigTMD_check/bigtmd_minus_local.md`, SHA-256
  `6d63e5a2236c586bd0dcb84a8b14c3d4aff340ccec20f2357330c9ee6c94d649`,
  3,459 bytes;
- successful canonical log `bigTMD_check/s02_compare_bigtmd_fhat.log`,
  SHA-256
  `24b34c58edd5a71af6995569146b5e5de9ce50ad14b44f0c92246b2d713a85cc`,
  1,013 bytes.

S01 first failed at a deliberately strict compact-bookkeeping precheck
because its draft required the complete virtual ledger to be scalar zero.
The accepted S13 value is instead a structured not-applicable association
whose interference field is exact zero. S01 was corrected at that gate,
held-parsed again, and rerun; no cache, result, or mathematical expression was
written by the failed invocation, and the successful run replaced its
canonical log.

The accepted S02 run validated the copied commit, driver, all six module
hashes, S01 binding, all six S13 disk hashes, channel-6 A/B/C routing, exact
local endpoint/phi-zero fields, and complete 18-row coverage. It printed
`HQQPRIME_BIGTMD_S02_SUCCESS` and exited zero. The tool-produced result is a
numerical mismatch: all coefficients within tolerance is `False`, the maximum
absolute difference is `8.6667779893226411e-06`, and the maximum relative
difference is `1.7732370694828465`, under the recorded signed convention
`BigTMD - local`. This is the completed benchmark result; neither local S13
nor BigTMD was adjusted to force agreement.

For consumers, the exact local mathematical expressions continue to reside
only in the six accepted S13 caches under `FiniteCoefficientPair` and
`FiniteHattedAction`. The copied external expressions reside in
`bigTMD_check/BigTMD_reference/NLO/Pg/fchn6{A,B,C}.py` and
`NLO/Ppp/fchn6{A,B,C}.py`, principally their selected `regular` functions;
the copied but driver-unselected `delta`, `plus1B`, and `plus2B` functions are
not part of this comparison. The instantiated local and external numerical
values are in `local_fhat_benchmarks.json` and
`bigtmd_fhat_benchmarks.json`; every signed row and tolerance decision is in
`bigtmd_minus_local.json`, with the human-readable table in
`bigtmd_minus_local.md`.

No independent post-production reconstruction or redundant second
comparison run was performed. The embedded S01/S02 gates are the accepted
validation evidence, and this BigTMD check stops at its signed report.

## MadGraph check contract — different-flavour tree-real representative

The user authorized a following isolated `madgraph_check/` sequence using the
accepted Hqqbar method. This check targets the physical current-channel
representative with incoming up quark and fragmenting different-generation
up-type quark:

`e- u -> e- c u c~`

through a spacelike photon. Z and Higgs exchange are excluded. The accepted
local momentum order remains `c(k1), u(k2), cbar(k3)`, with `k1`
fragmenting. MadGraph may canonicalize its final-state PDG order; the bridge
must measure that order and map it explicitly to the local order rather than
assuming positional equality.

This is a read-only-upstream bare-tree check. Its mathematical inputs are
byte-identical copies of:

- `s01_calculate_hqqprime_tree.wl`, SHA-256
  `17ed0c69c0c440a63b93a41d7634eade24a948543618a09769eea937427877a4`;
- `s01_result`, SHA-256
  `842c6a1d06a9b0785e89e0230838891aedadc09bcf46a59a492c2e71dd77fb6b`;
- `s06_spin_color_sum_average_hqqprime.wl`, SHA-256
  `eef94883991b5fb6d10345f29943234f90c2da695879c4ca6f2ee99a4a970adc`;
- `s06_result`, SHA-256
  `92d3d912f69a251f4ba1c3709b768b50fadbb27f0c56d523c34b086e25fc4607`;
- `s07_contract_hqqprime_projectors.wl`, SHA-256
  `4ac73e5b846e088c7c92acfed2bb935ba969e9049d778f83e5f8cfa34fcab1e7`;
- `s07_result`, SHA-256
  `b59def6d8350183319dda98591e78e001ca3c1e5d2f2a9d0b5060927d4215026`.

The authoritative paper remains pinned at SHA-256
`bf36878f0b451c88322b9ec69fa19815930a6d171ac586be6712380a1d3c775b`.
No parent Hqqprime source, cache, result, or log may be modified. All copied
inputs, generated code, bridge code, samples, results, and logs live inside
`madgraph_check/`.

The check reuses the existing pinned MG5_aMC 3.7.0 executable at
`../Hqqbar/madgraph_check/software/MG5_aMC_v3_7_0/bin/mg5_aMC`, SHA-256
`d51e70db5c95fb72df985760819a0733c9bdb2401de3b27995d53788d2050a74`,
and its local `six.py`, SHA-256
`c51c91f703d3d4b3696c923cb5fec213e05e75d9215393befac7f2fa6a3904df`.
They are read-only dependencies: this sequence must not download, reinstall,
or modify MadGraph.

The valid comparison boundary is copied S06/S07 before angular/phase-space
integration. MadGraph supplies a four-dimensional bare tree matrix element;
raw S08/S10 still contains collinear singularities, while S11/S12 introduces
factorization counterterms and S13 is a finite F-hat action. Consequently no
S08, S10, S11, S12, S13, BigTMD output, or factorized coefficient is a
mathematical input to this check.

Normalization and bookkeeping are fixed as follows:

1. Copied S06 already sums every final fermion spin/color and applies the
   incoming-quark average `1/(2 Nc)` while retaining three charge-free tensor
   coefficients and the absolute tree scale factor.
2. The program must read the physical incoming-up and prime-charm charge
   assignments from copied S01 metadata and coherently combine
   `IncomingChargeSquared`, `PrimeChargeSquared`, and
   `MixedIncomingPrimeCharge`. It must not insert a charge weight from memory
   or collapse the result to an `Nf` or `Nf-1` multiplicity.
3. The local full-process reconstruction adds the spin-averaged electron
   tensor, electron electromagnetic vertex, and photon propagator exactly
   once. It uses the same `alpha_s`, `alpha_em`, and scale as the generated
   MadGraph parameter card.
4. All three final flavours/particle identities in the local ordered state
   are distinct, so the local final-state factor remains one. The program
   must derive the expected MadGraph `IDEN` from measured initial spin/color
   averages and generated final-state identity multiplicities, then require
   the generated matrix value to match; no `IDEN` number is copied from
   another channel.
5. The current MadGraph diagram count must be measured from the newly
   generated process and compared with the current copied-S01 representative
   inventory. No diagram count is hard-coded from Hqq or Hqqbar.
6. A fixed orientation tests the copied S06 open tensor. The copied S07 Pg
   and PPP projections test the azimuth-independent result against a
   four-angle MadGraph lepton-plane average at fixed hadronic invariants.
7. The production finite-bin comparison uses the same deterministic
   massless-RAMBO construction and invariant, azimuth-symmetric cuts as the
   accepted Hqqbar method, applied to the Hqqprime momentum map. Both sides
   receive identical rejected-event zeros, phase-space measure, flux, and
   unit conversion. Pointwise and integrated differences are reported with
   no adjustment of either source.

The new sequence is:

1. `s01_prepare_inputs.py`: hash-pin and atomically copy the six accepted
   parent artifacts, validate the two reused dependencies, and write
   `s01_input_manifest.json`.
2. `s02_generate_hqqprime_standalone.mg5`: generate only the photon-mediated
   `e- u -> e- c u c~` standalone source; generation and compilation logs
   remain local.
3. `s03_madgraph_c_bridge.f90`: expose initialization, evaluation, and
   generated metadata through ISO C.
4. `s04_direct_madgraph_reference.f90`: evaluate the unchanged generated
   routine directly at a deterministic physical point.
5. `s05_validate_madgraph_bridge.py`: prove bridge/direct identity,
   conservation, masslessness, PDG/momentum routing, generated diagram count,
   derived `IDEN`, and relevant permutation/identity properties.
6. `s06_inspect_copied_s07_schema.wl`: validate only the copied projector
   schema and inert propagator/coupling representation needed downstream.
7. `s07_validate_local_matrix_element.wl`: compare the copied-S06 fixed
   orientation and independently reconstruct copied-S07 Pg/PPP at the same
   point, preserving the three charge structures until the physical
   representative combination.
8. `s08_validate_azimuthal_average.py`: compare the four-angle MadGraph
   average with the projected local reference.
9. `s09_build_four_dimensional_evaluator.wl`: create the compact unit-coupling
   SU(3), `D=4` local evaluator with embedded equality gates.
10. `s10_generate_cut_bin_madgraph.py`: generate the deterministic common-bin
    sample and evaluate MadGraph for accepted rows.
11. `s11_evaluate_local_cut_bin.wl`: evaluate the local expression on exactly
    those rows and enforce complete pointwise coverage.
12. `s12_integrate_common_cut_bin.py`: apply the common phase-space/flux/unit
    normalization and write the correlated integrated comparison.

Every task source uses its sequential prefix, refuses silent overwrite, and
writes result artifacts atomically. Long-running stages use inline persistent
monitors. The calculation stops after S12 has produced and embedded-verified
the pointwise/integrated result. No redundant final reconstruction or second
production sample is authorized. A numerical disagreement is a valid result
and must be recorded without altering accepted Hqqprime or generated
MadGraph sources.

## Current status

S01 through S13 and the external BigTMD channel-6 A/B/C numerical benchmark
are complete and accepted at the hashes recorded above. The BigTMD result is
the measured 18-row mismatch, not an agreement claim. Hqqprime S13 itself
still stops at exact finite charge-resolved F1Hat/F2Hat actions; the physical
ordered-flavour/charge assembly and all other deferred work have not begun.

The separately authorized Hqqprime MadGraph check is complete and accepted
through its terminal S12 stage.
S01-S02 prepared the pinned copies and generated the photon-only
`e- u -> e- c u c~` process; S03-S05 accepted the direct shared-library
interface at measured diagram count 4 and derived/generated `IDEN=12`, with
exact bridge/direct equality. S06 source/log SHA-256 values are
`cefced1a0bc574c166beaed9b5ea93c8e4370bc53f20ecdba6229a4f609e5169` /
`021fd0e5f1c5caf2950ec0f4624e3ff21522793f1b7100bd8ef843f4c1b83b54`;
the copied projector-first, charge-second six-payload schema passed and the
log ends in `S06_SUCCESS`. S07 source/log/result SHA-256 values are
`9022e35ef9e4c6dd9aab121cf680a0d1b6c8b8c67457d7b37ba770c26ef3c5ad` /
`807864aebc155b4c9ac4655721b711bab81eb90e1a0a02a9d627c413a481bee0` /
`79cf7e55218025f35c601c5e08a688644347f227ecd3061aa9d95b03608b9b00`.
All six charge-resolved fresh/copy Pg/PPP comparisons reported zero relative
difference, and the coherent fixed-orientation copied-S06/MadGraph relative
difference was `5.530507946006608e-16`. S08 then exposed that the projected
field in that result was invalid: Wolfram parsed a missing explicit `*` across
a newline as two statements, omitting the second scalar product from the
leptonic `PPP` coefficient. The defect is corrected in S07 at its originating
line. The invalid predecessor result was deleted; corrected S07 regenerated
projected matrix `2.9608497009543090e-10` while preserving all earlier gates.
S08 source/log/result SHA-256 values are
`c1230b70ab07ef9137107576253fa42f06e6a99f169e053de9afc49154a84d45` /
`e5e77460dba74c9cc6495c7a356516c9b0fdcb17eb30bdb61393c7980612615d` /
`c869f3fa105253fb7aa6994fc21c29d696260e5087cbf322a767f00083670cfe`;
the four-angle average/local relative difference is
`2.26990328986545530e-15`. S09 compact evaluator construction is next. The
S09 source/log/result SHA-256 values are
`20974e815a97fe6d196a0fdc66a5b2772236779f8d8871f0b6fb9e9fbcb6a640` /
`0eb9f1c2d33f2a430ab7401f19b3945ea82e431642c710f0183a782f9e86ef2a` /
`51cb470c5309e06a8122dc48612078967a13b06710ff2b0784e553f755165722`;
its corrected-S07 Pg/PPP benchmark passed. S10 deterministic common-bin
S10 source/log/CSV/metadata SHA-256 values are
`73cbfc2434d3ef0dbaac971871b21ef54f3d22a237c775c18e64fae1a6096ad7` /
`142eddee1683eee49e7e16f6ea15fbda8914d309d724ee0c7832780ad70ae9d5` /
`acffeddd2c9c5d0da793cf192648dc5f8d093a7265d9b3d6234df7656e81ffdb` /
`ac6a208789613ffc39a2eca5a9c7a6ee3017d75e1388a6ca68252aeb30721350`;
S11 source/log/CSV/JSON SHA-256 values are
`72c0dcca68c57fd864942cd02a3864dbf8ac4b8afdd4e40171c33b688f57d1fc` /
`a589630e30ca02de0886110dbd30af3752ef54e478681c00506325a12dc820f3` /
`15d1fc2fa1bad06ddeaccecaed55d7627b3915e2bbe8140fc6e48e32c1e91f28` /
`27bd819e827041825c440449231f784797c8ac716c676d32561702beaf080ceb`;
all 27,851 pointwise rows passed. S12 source/log/result SHA-256 values are
`467929e82f13750f6d05de8de3475949dfd9f2c933c7655c01dff6d73e80efd9` /
`4753cb6029f05410263f1378d8ad91556fd250d6ef1e7229c574b2fd1b49dc89` /
`26a315d504b7c01974c91b9a7f5b431317eff03cf283f7e9ce3628192548082b`.
The final MadGraph/local values are `3.47132831771248661e-4 pb` and
`3.47132831771248499e-4 pb`, with integrated relative difference
`5.70033657988215510e-16` and paired correlation 1. Every embedded S12 check
passed. The workflow stops here without a redundant final validator or second
sample. The paused Hqq qgg audit is separate and remains paused at its
recorded boundary in `../progress.md`.
