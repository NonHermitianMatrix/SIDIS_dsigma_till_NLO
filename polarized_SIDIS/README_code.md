# Code, execution and result-reading guide

This guide was added with the physics report. The original main README follows under **Preserved original technical ledger** without changes to its original text. The new [README.md](README.md) explains the folder layout. Each owner's original documentation is preserved in its own `README_code.md`; its new README identifies accepted current stages. Immutable imported reference READMEs keep their names and hashes.

## Read completed coefficients without rerunning the calculation

All six channels have accepted final `s15_result` records. Load one channel at a time; the large native expressions can require substantially more RAM than the compressed file size. Hgg loaders must remain beside all sibling `*_parts` directories. The short F1/F2 files contain only the hat association; the complete record carries conventions and the full photon tensor.

The following Wolfram commands load the complete Hqq result, check its acceptance flags, and select one matrix entry without printing the whole large tensor.

```wolfram
SetDirectory["/home/physics/projects/AI_Assisted_SIDIS/scripts/polarized_SIDIS"];
$HistoryLength = 0;
$FeynCalcStartupMessages = False;
Get["FeynCalc`"];
r = Get["Hqq/s15_result/s15_result.wl"];
{r["FiniteNLOFHatsComputed"], r["CompletePoleCancellationChecked"],
 r["FiniteAxialSchemeConversionApplied"]}
labels = r["SpinLabels"]; (* {"U", "X", "Y", "H"} *)
index[label_] := First[FirstPosition[labels, label]];
u = index["U"]; x = index["X"];
f1LO = r["Fhats"]["F1"]["LODelta"];
f1RegularPlusBranch = r["Fhats"]["F1"]["NLO"][1]["Regular"];
Dimensions[f1RegularPlusBranch] (* {4, 4}: outgoing, incoming *)
uu = f1RegularPlusBranch[[u, u]];
xx = f1RegularPlusBranch[[x, x]];
photonResponse = r["NLOResponse"][1]["Regular"];
Dimensions[photonResponse] (* {9, 4, 4} *)
(* Inspect a selected expression deliberately, e.g. InputForm[xx]. *)
Clear[r, f1LO, f1RegularPlusBranch, uu, xx, photonResponse];
ClearSystemCache[];
```

`1` selects `t=omega-s`, `-1` selects `t=-omega-s`, both with `omega>0`; `0` is the separately established `t=-s` boundary. Select the appropriate branch. The stored `Delta`, `L0`, `L1`, `Regular` entries multiply delta, plus, logarithmic-plus and ordinary functions of `s23` on `[0,B]`. Keep the defining test-function subtraction for plus distributions. Do not substitute the endpoint into an ordinary representation. The stored coupling and channel charge factors are already restored.

To load only the projected association, the next command avoids also retaining the full photon response, but the separate metadata must still be respected.

```wolfram
f1 = Get["Hqq/s15_result/s15_F1_hat.wl"];
Keys[f1] (* {"LODelta", "NLO"} *)
f1["NLO"][1]["Regular"][[1, 1]]
```

The verified local executable is `/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel`. Native production receipts record the runtime actually used. The cluster uses the pinned Mathematica 13.1 path where recorded; the explicit local Hgg adapters use Engine 15.0. Do not use the expired system `math` kernel or assume versions are interchangeable inside a hash-bound native proof.

## Required inputs and software

The local and pinned GitHub references provide amplitudes, scalar geometry, reductions, master expansions and normalization contracts. `common/s01_inputs.json` identifies the GitHub commit and imported inputs; subsequent `sNN_inputs.json` files bind stage-specific definitions. The standalone reference contributes the exact rational-reduction and factorization definitions preserved under common reference inputs. FeynArts, FeynCalc, Kira/Fermat and the recorded master/integration dependencies must be available in the versions and locations expected by the configuration. Source READMEs do not contain licensed software or the large mathematical datasets.

Read the owning channel README and the accepted entry-point table before choosing a stage. Shared S02/S04/S06/S10 work is reused where its input identities match. Real-only channels omit the direct virtual path. Hgg local S09/S11 have real-reduction/integration meanings; they are not the shared S09 virtual or S11 subtraction stages. The final Hqg and Hgq subtraction uses `s11_msbar_result`; Hgg uses `s11_native_result`.

## Reproduce a reviewed cluster stage

Use a fresh isolated run generation containing the pinned inputs and implementation dependencies. Preserve the original accepted outputs and receipts. `.cluster/s02_execute.py` refuses an existing execution receipt, and it also verifies every `reviewed_sha256` entry before launching. A fresh run directory can reuse unchanged input files, but the target stage's output receipt must belong to that new generation. Do not bypass these checks or manually forge a scheduler environment.

The channel stage tables link job configurations whose bytes match the accepted execution receipt. Their `command` arrays select the actual implementation; do not assume the nominal channel symlink was the last executed adapter. Configuration fields define isolated user-base paths, resource bounds, expected artifacts, acceptance markers and output receipt. If actual inputs or implementation change, review the change and generate new bound identities; do not rewrite a historic receipt to claim it ran new code.

For example, on a Hoffman2 compute allocation in an input-complete fresh generation, the following command executes the accepted Hqg final-export configuration. It is a reproduction example and is not being run by this documentation task.

```bash
python3 .cluster/s02_execute.py \
  --root "$PWD" \
  --job .cluster/s15_Hqg_all_routes_20260924_job.json
```

For a new batch submission from that same fresh generation, the following pattern supplies the recorded one-slot/two-hour Hqg final-export resource profile and runs the guarded executor on a compute node. Confirm the current account's scheduler access and resource needs when reproducing a historical run; the profile is evidence from this run, not a promise of queue start time.

```bash
qsub -terse -N pSIDIS_Hqg_s15_reproduce -S /bin/bash \
  -l h_rt=02:00:00,h_data=16G -cwd -j y <<'JOB'
#!/bin/bash
set -eu
exec python3 .cluster/s02_execute.py --root "$PWD" \
  --job .cluster/s15_Hqg_all_routes_20260924_job.json
JOB
```

The existing executor monitors memory, wall time, output progress and storage and writes the execution receipt. Also retain the scheduler identity and a persistent observer for completion/error/stall notification. Worker counts must fit the allocation; `h_data` is per slot. Production algebra runs on compute nodes, not login nodes. Current scheduler policy is available from the links in `.cluster/README_code.md`. Reconnecting SSH does not alter the scheduling priority of an already submitted job.

## Local Hgg reproduction boundary

The user authorized bounded local continuation when RAM and disk allowed it. `misc/s14_assemble_Hgg_finite.wls` and `misc/s15_finalize_Hgg_hats.wls` are explicit reviewed local adapters, with exact shared-source reconstruction and native storage checks. Their `s14_inputs.json` and `s15_inputs.json` bind the accepted inputs and local source. `POLARIZED_SIDIS_LOCAL_AUTHORIZED=1` enables those adapters; it is not a way to bypass a generic cluster-only script.

Their corresponding accepted execution receipts show the complete local command and resource limits. Reproduction needs a fresh output generation, those actual inputs and companion parts, the verified Engine 15.0 runtime and matching FeynCalc. Keep a persistent process-tree monitor, at least 4 GiB available RAM and 8 GiB free disk, and the native per-operation bounds. Avoid keeping several decoded full-channel tensors at once. The final published aliases in Hgg point to these local owners; copying a loader alone is incomplete.

## Interpreting success and diagnosing a failure

A generated integrand, Kira reduction, integrated real term or finite S14 tensor is not by itself a final F hat. Read the stage's `Checks`, matching `sNN_execution.json`, expected artifacts and output hashes. Final acceptance additionally requires the S15 finite flag, complete S14 pole cancellation and reference gates, and finite scheme conversion. The stage boundary in the common README tells which consumer is next.

If a native program stops at a named gate, use its actual input, source and output contract. Preserve valid source-bound checkpoints; invalidate results only when their mathematical dependencies changed. Do not set a missing component or integral to zero to force acceptance. The historical ledgers describe accepted corrections and superseded artifacts; their earlier interim wording does not supersede the final acceptance section.

## Reconstruct the listed code using only the README source appendices

Human explanations alone cannot specify byte-identical code. The `README_sources.md` appendices therefore include the literal UTF-8 source/configuration bytes, file mode, SHA-256, path and symlink target. They include retained source implementations read by current adapters. The scope is the listed text code/configuration files, not binary dependencies, large mathematical result payloads, or caches. The `documentation/s05_source_manifest.json` is a convenient inventory, but the reconstruction below uses only the READMEs.

Run the following Python example from the `polarized_SIDIS` root. It restores into a new directory inside `documentation`, never over the current production files. It checks every payload hash, validates path ownership and symlink bounds, then verifies restored file bytes and modes. Keep all the source appendix READMEs when sharing a code-only reconstruction package.

```python
from pathlib import Path
import hashlib, json, os, re

root = Path.cwd().resolve()
destination = root / "documentation" / "reconstructed_sources"
if destination.exists():
    raise RuntimeError("Use a fresh reconstruction destination")
appendices = sorted(root.glob("*/README_sources.md"))
records = []
for appendix in appendices:
    raw = appendix.read_bytes()
    for match in re.finditer(rb'<!-- SOURCE (\{[^\n]+\}) -->\n', raw):
        item = json.loads(match.group(1))
        start = raw.index(b"\n", match.end()) + 1
        payload = raw[start:start + item["bytes"]]
        assert hashlib.sha256(payload).hexdigest() == item["sha256"]
        assert raw[start + item["bytes"]:].startswith(
            ("\n" + item["fence"] + "\n<!-- END SOURCE -->").encode())
        relative = Path(item["path"])
        assert not relative.is_absolute() and ".." not in relative.parts
        target = destination / relative
        if item["kind"] == "symlink":
            assert payload.decode() == item["target"]
            resolved = (target.parent / item["target"]).resolve()
            assert resolved.is_relative_to(destination.resolve())
        records.append((item, payload, target))
assert records and len({r[0]["path"] for r in records}) == len(records)
for kind in ("file", "symlink"):
    for item, payload, target in records:
        if item["kind"] != kind:
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        if kind == "file":
            with target.open("xb") as stream:
                stream.write(payload)
            target.chmod(item["mode"])
        else:
            target.symlink_to(payload.decode())
for item, payload, target in records:
    restored = (os.readlink(target).encode() if item["kind"] == "symlink"
                else target.read_bytes())
    assert restored == payload
    if item["kind"] == "file":
        assert target.stat().st_mode & 0o7777 == item["mode"]
print("Reconstructed exact source/configuration entries:", len(records))
```

This restores code and configurations. Running them still requires the mathematical inputs and external tools identified by the restored manifests. Every listed symlink target is included, including the small native-validation JSON dependency. Do not treat a reconstructed source tree alone as a completed calculation.

## Rebuild the report

The portable compiler and its official-release hash are recorded under `documentation`. The following command rebuilds the report using a cache inside the authorized directory.

```bash
XDG_CACHE_HOME="$PWD/documentation/tex_cache" \
  documentation/tools/tectonic --keep-logs polarized_SIDIS_report.tex
```

The final compiler receipt and layout validation are recorded under `documentation`. This is documentation-only work; it neither reruns the physics nor changes a final coefficient.

---

# Preserved original technical ledger

# Polarized SIDIS partonic coefficients

This workspace belongs to the requested spin-dependent extension of the
GitHub SIDIS calculation. Numerical proton distributions, fragmentation
fits, cross-section convolutions, and plots are deferred until the
partonic calculation is accepted.

## Reference and scope

The reference is `NonHermitianMatrix/SIDIS_dsigma_till_NLO`, commit
`5062dcb2407594dafcc2f9f72800e96ff9e6d957`, SIDIS tree
`428a4eb2327589d067372a090d5ca33427108f45`. The reference keeps the
nonzero-transverse-momentum SIDIS coefficients through `alpha_s^2`.
The user selected the same large-transverse-momentum SIDIS measurement.
Jet matching and the electron–jet observable are explicitly deferred.

The reference's first channel label is the incoming parton and the second
is the tagged outgoing parton. The latter has momentum `k1`.

The requested output is a set of hard coefficients retaining incoming and
tagged outgoing spin information, with their unpolarized normalization.
Spin transfer must retain the interference between spin states. A normalized
outgoing polarization or a spin probability is not a substitute for the
unnormalized hard tensor.

The user selected all incoming/outgoing spin components, including quark
longitudinal/transverse polarization and gluon helicity/linear polarization.
Preserve a complete physical photon tensor as well as the legacy Pg/Ppp
projections; two spin-averaged hats cannot reconstruct the full response.
Use a physical spin density matrix for each resolved parton. Gluon linear
polarization is not a quark transverse-spin vector. The partonic basis does
not imply that every component has a leading-twist collinear distribution
in a spin-one-half proton.

The working regulator prescription is BMHV: resolved spin vectors and
photon polarization basis are four-dimensional; loop and unresolved
radiation algebra retains its regulator dependence. Keep evanescent
contributions and scheme conversion separate until checked. No NLO finite
export is accepted merely because the unpolarized reference is finite.

## Directory ownership

| Folder | Owner |
|---|---|
| `Hqq/` | Incoming quark, tagged same-flavor quark |
| `Hqg/` | Incoming quark, tagged gluon |
| `Hgq/` | Incoming gluon, tagged fixed-flavor quark |
| `Hgg/` | Incoming gluon, tagged gluon |
| `Hqqbar/` | Incoming quark, tagged same-flavor antiquark |
| `Hqqprime/` | Incoming quark, tagged distinct-flavor quark |
| `common/` | Shared source, reference contracts, and shared results |
| `mathPolycoms/` | Interface to the cluster's installed algebra/integration dependencies |
| `.cluster/` | Cluster execution and resource contract |
| `numerics/` | Reserved for the explicitly deferred numerical calculation |
| `bigTMD_comparison/` | Reserved comparison interface; unpolarized checks alone do not validate spin transfer |

Programs use `sNN_<description>` and their corresponding `sNN_result/`.
Shared implementations may have channel links, but shared work runs once
for its stated channel set. No mutable source or output link may point into
another active calculation.

## Changes required from the unpolarized calculation

1. Acquire and validate the original open amplitudes and their provenance.
2. Define the complete spin and measurement basis and derive its projectors.
3. Recompute Born, real, and virtual spin contractions and their Ward checks.
4. Determine the actual scalar targets and required regulator depths from
   the new numerators. Reuse an integral only with matching definitions,
   continuation, measure, and depth.
5. Implement spin-dependent collinear PDF/fragmentation subtraction and
   the required finite scheme conversions for the selected SIDIS observable.
6. Assemble every independent component and require the corresponding
   ultraviolet, infrared, and finite-export gates.
7. Validate spin-averaged reconstruction against the matching reference
   observable and export source-bound hard coefficients.

## Execution and retention

The table gives the baseline stage sequence. Each channel README records
the accepted entry point and matching job configuration, including verified
continuations. Channel entry links select shared implementations. Each
stage writes its own `sNN_result/`; later stages require the input's schema,
checks and recorded file identities.

| Stage | Shared entry point | Output contract |
|---|---|---|
| 01 | `s01_prepare_inputs.py` | Pinned original amplitudes and reference inputs |
| 02 | `s02_define_spin_basis.wls` | Spin and photon bases, normalization and projectors |
| 03 | `s03_born_spin_response.wls` | Born spin tensors for Hqq, Hqg and Hgq |
| 04 | `s04_transverse_angular_average.wls` | Unresolved angular moments |
| 05 | `s05_real_spin_response.wls` | Real-emission spin tensors |
| 06 | `s06_reuse_scalar_integrals.wls` | Verified original scalar reduction and master library |
| 07 | `s07_virtual_spin_response.wls` | Virtual spin integrands for the three Born channels |
| 08 | `s08_map_real_spin.wls` | Real integral targets and reduction coverage |
| 09 | `s09_map_virtual_spin.wls` | Virtual integral targets and reduction coverage |
| 10 | `s10_collinear_spin_kernels.wls` | Spin-dependent collinear kernels |
| 11 | `s11_collinear_spin_convolutions.wls` | PDF/FF counterterms for the three Born channels |
| 12 | `s12_assemble_real_spin.wls` | Integrated real terms and endpoint distributions |
| 13 | `s13_assemble_virtual_spin.wls` | Integrated, UV-renormalized virtual terms |
| 14 | `s14_assemble_finite_spin.wls` | Pole cancellation and original unpolarized-hat comparison |
| 15 | `s15_finalize_spin_coefficients.wls` | Finite scheme conversion and final coefficient export |

The small channels use `s11_small_collinear_spin.wls` and the auxiliary
Born tensors from `s03_auxiliary_born_spin.wls`. They do not require S07,
S09 or S13. S06 and S10 are independent reusable inputs. S15's
`s15_scheme_result/` is a conversion input, not the final coefficient file.

Run the shared entry points from the `polarized_SIDIS` root, selecting the
channel with `POLARIZED_SIDIS_CHANNEL`. S08 first saves the complete targets
with `s08_map_real_targets.wls`; uncovered targets use
`s08_extend_real_reduction.wls`, followed by coefficient assembly in
`s08_map_real_spin.wls`. Use the accepted implementation identified in the
channel README: the completed Hqqprime and Hqqbar S08 entries select
`s08_map_real_spin_streamed.wls`, and their S12 entries select their
respective accepted integration adapters.
S04, S06 and S10 links expose their shared programs and accepted results
without duplicating the calculation or its storage.

Hqqbar uses `s08_map_grouped_real_targets.wls` after the complete accepted
comparison recorded in its README. It applies the same reference mapper to
the actual denominator groups and retains the same S08 output contract.
Hqqprime resumes through `s08_map_targets_by_denominator.wls`, which retains
accepted original component checkpoints and applies those same verified
definitions to the remaining components. The source verifies all shared
physical inputs before accepting a channel's continuation.

S13 selects a completed virtual map through `POLARIZED_SIDIS_VIRTUAL_MAP`.
When its UV expansion records targets absent from the original auxiliary
table, `s13_extend_uv_reduction.wls` extends that table using the original
Kira workflow and requires exact agreement with every original rule.
Hqq's accepted extension is `Hqq/s13_uv_reduction_result/s13_result.wl`;
select it with `POLARIZED_SIDIS_UV_REDUCTION`. Its channel README records
the accepted input and result identities. The S13 reader verifies this
extension before reusing the successful original UV checkpoints.

Final consumers must use `<channel>/s15_result/s15_result.wl` only after
its `FiniteNLOFHatsComputed` flag is true. It contains the full photon/spin
response and the F1/F2 projections; the separate `s15_F1_hat.wl` and
`s15_F2_hat.wl` files retain those projections. This table describes the
stage contracts and does not certify an unexecuted stage.

The saved `PhysicalFrame` retains the formal coordinate `transverseK`.
Its defining rule is `TransverseSubstitution` in the channel's accepted
`s05_result/s05_result.wl`, also retained in `s08_result/s08_result.wl`.
Use that recorded rule when interpreting the frame, together with the
saved branch, physical-region and endpoint-distribution conventions.

Load FeynCalc with `Get["FeynCalc`"]` before reading Wolfram result files
with `Get`, preserving the color and Lorentz symbol contexts used by the
producer. S05 uses native compression inside its `.wl` file and checks
exact equality after reloading the saved result.

Hoffman2 production calculations use compute nodes; login nodes are used
for staging and scheduler operations only. The user subsequently authorized
local Hgg continuation when resources permit. Its accepted source and
results remain under `misc/`, with channel-owned links and genuine local
execution receipts. Local runs enforce process-tree memory and scratch
bounds, with at least 4 GiB available RAM and 8 GiB free disk reserved.
Transfers have explicit size bounds and hash checks. Preserve accepted
source/configuration generations, results, and caches needed to reproduce
or resume the calculation; remove disposable test caches after use.

The current supplied operating instructions require live execution updates
in `scripts/progress.md`. Channel READMEs retain accepted conventions and
artifact identities. Credentials are never stored in source, configuration,
README files, or result artifacts.

## Physics references

- [GitHub SIDIS reference](https://github.com/NonHermitianMatrix/SIDIS_dsigma_till_NLO/tree/5062dcb2407594dafcc2f9f72800e96ff9e6d957/SIDIS).
- [Spin density matrices for polarized SIDIS](https://arxiv.org/abs/1101.1011).
- [Electron–jet spin and fragmentation factorization](https://arxiv.org/abs/2106.15624).
- [Electron–jet Collins measurement](https://arxiv.org/abs/2007.07281).
- [The user's proton–proton Collins reference](https://arxiv.org/abs/1707.00913).


## Accepted final artifacts

All six channels have accepted final partonic exports. Their executed S15
checks pass and `finite_nlo_fhats_computed` is true. Each export inherits its
accepted componentwise pole cancellation and unpolarized-reference checks,
and retains its recorded finite-scheme conversion. Saved artifact hashes
were verified against the genuine execution receipts at publication.

| Channel | Full photon/spin response | F1 spin matrix | F2 spin matrix | Execution evidence |
|---|---|---|---|---|
| Hqq | [Full response](Hqq/s15_result/s15_result.wl) | [F1](Hqq/s15_result/s15_F1_hat.wl) | [F2](Hqq/s15_result/s15_F2_hat.wl) | [Receipt](Hqq/s15_result/s15_execution.json) |
| Hqg | [Full response](Hqg/s15_result/s15_result.wl) | [F1](Hqg/s15_result/s15_F1_hat.wl) | [F2](Hqg/s15_result/s15_F2_hat.wl) | [Receipt](Hqg/s15_result/s15_execution.json) |
| Hgq | [Full response](Hgq/s15_result/s15_result.wl) | [F1](Hgq/s15_result/s15_F1_hat.wl) | [F2](Hgq/s15_result/s15_F2_hat.wl) | [Receipt](Hgq/s15_result/s15_execution.json) |
| Hgg | [Full response](Hgg/s15_result/s15_result.wl) | [F1](Hgg/s15_result/s15_F1_hat.wl) | [F2](Hgg/s15_result/s15_F2_hat.wl) | [Receipt](Hgg/s15_result/s15_execution.json) |
| Hqqbar | [Full response](Hqqbar/s15_result/s15_result.wl) | [F1](Hqqbar/s15_result/s15_F1_hat.wl) | [F2](Hqqbar/s15_result/s15_F2_hat.wl) | [Receipt](Hqqbar/s15_result/s15_execution.json) |
| Hqqprime | [Full response](Hqqprime/s15_result/s15_result.wl) | [F1](Hqqprime/s15_result/s15_F1_hat.wl) | [F2](Hqqprime/s15_result/s15_F2_hat.wl) | [Receipt](Hqqprime/s15_result/s15_execution.json) |

The full record contains `NLOResponse`, `Fhats`, `SpinLabels`, `PhotonLabels`,
`IndexOrder`, and the branch, endpoint-distribution and normalization
conventions. Keep the complete photon/spin response for later observables;
the separate F1/F2 files contain the corresponding projected spin matrices.
Numerical convolutions and jet matching remain deferred.

From the `scripts/polarized_SIDIS` directory, load a result with:

```wolfram
Get["FeynCalc`"];
result = Get["Hgg/s15_result/s15_result.wl"];
result["Fhats"]["F1"]
result["Fhats"]["F2"]
```

Hgg's final files use a self-contained native loader that verifies the SHA256
of every data piece. **Keep each `.wl` file together with its sibling
`*_parts/` directory**, including the scheme artifact's own pieces. `Get`
returns the ordinary final-result schema. The Hgg channel paths link to the
accepted local results in `misc/s15_result/`; copying a symlink alone does
not copy those results. Preserve or dereference the link when transferring.

Hgg's accepted local entry points are `Hgg/s11_assemble_Hgg_real.wls`,
`Hgg/s14_assemble_Hgg_finite.wls` and `Hgg/s15_finalize_Hgg_hats.wls`.
Its local integrated and finite intermediate outputs are exposed through
`Hgg/s11_local_real_result/` and `Hgg/s14_local_finite_result/`.
The channel README records the accepted source, configuration and result
identities and preserves the distinction from the subtraction inputs.

| Channel | Full-result SHA256 |
|---|---|
| Hqq | `22dc3335d453d5e0318e6d8a294d1e128ec8fa85ef1c6f67bf90a84b8bf51d99` |
| Hqg | `5f4ab0cc6e4e05ba5c04058fd00ce7d1ed69e81b147e776178fa8ae782190948` |
| Hgq | `bc5a8cd2ec0a0c872f4038f51ad501b1ce823e9f956fb3ade997a5dddc8b3881` |
| Hgg | `8a15dc756ebe12d25d570c3c14df83c4f852087306885bc7d82bbc118fc7998d` |
| Hqqbar | `e51108ed10bce89526378cc6c29ae1b8fcfacfdd28c1c01c9a28cca573c78290` |
| Hqqprime | `1aecfea2bc55f095cb8f9c7285cb53212110d54263b2149a6b6e10e2792e551f` |

The explicitly supplied standalone reference also supplies the exact
rational-reduction and finite factorization contracts retained under
`common/s08_result/reference/` and `common/s15_result/reference/`.
Its source is `/home/physics/projects/AI_Assisted_SIDIS/standalone_nlo_qcd_reference/standalone_nlo_qcd-main/`.
These contracts supplement the pinned GitHub measurement and normalization.
