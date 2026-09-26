# Bounded local checks

The user authorized short local calculations here on 2026-09-24 while the
production Hoffman2 jobs continue. Use the explicitly configured Wolfram
Engine 15.0, one kernel on one CPU, an 8 GiB address-space limit, a 3 GiB disk reserve,
and a ten-minute wall limit for S01. Native individual operations are bounded.
The RSS guard is 3 GiB and the available-RAM reserve is 6 GiB. Address space
is a separate limit: the first attempt hit 4 GiB virtual address space with
less than 400 MB measured RSS. Retain its receipt/log under `reference`.

`s01_check_Hqg_residual.wls` reads the actual saved Hqg residuals, current and
archived S11 counterterms, and the accepted native gluon-transfer result.
It reuses the original normalization and residual comparison equations.
It also reconstructs the old completion's transfer matrix from its saved
conversion and kernel, and compares its E-to-U soft coefficient with the
saved native one. All algebra is executed by Wolfram.

Inputs and implementation are bound in `s01_inputs.json`. The preserved
14884507 diagnostic output has native reconstruction checks but no successful
wrapper receipt. S01 records that provenance explicitly and independently
checks the equations it uses; it does not relabel that old execution as
accepted. Local and cluster Wolfram versions are recorded separately.

Results belong to `s01_result`. This stage can establish or reject the
proposed explanation of the saved residual. It does not export final F hats
or replace the cluster subtraction, pole-cancellation and all-reference gates.
Current execution status belongs only to `scripts/progress.md`.

S01 accepted its diagnostic gates with Wolfram15.0/FeynCalc10.2.1 in10.03s
wall,411918336bytes peak child RSS. Both saved positive-branch Delta residuals
minus the actual S11 completion change are exactly zero. The source SHA256 is
`25189bb520af738dc5d4276d30611d1d500eea2c80c45b2f7abdef33ea58da8a`;
result SHA256 is
`22c2d9ede4bf5f53558fea27f952451c0c184c6db51e92a6c92930e6ce361b1f`.
The receipt and complete input manifest are beside the result. These are
diagnostic acceptance identities, not final-hat acceptance.

`s02_finalize_Hqg_subtraction.wls` reuses the complete prepared cluster
`common/s11_finalize_Hqg_subtraction.wls` and its original convolution
implementation. Adaptations are confined to the authorized local runtime,
explicit S01 proof/receipt and input-version provenance, hash-checked copied
checkpoints, and isolated `s02_result` output paths. The native kernel,
Gram-dual, regulator, convolution, and all24 original finite-reference gates
remain. The local proof and imported cluster versions are checked separately;
no cluster job ID or receipt is invented. Inputs are bound by `s02_inputs.json`.
The full1728-file checkpoint set occupies150612082bytes; its5399911-byte compressed
transfer is retained with the exact manifest for provenance. S02 is subject
to the same one-CPU/RAM/disk limits as S01 and a ten-minute wall limit.

The local S02 expansion may reuse the accepted pre-completion counterterms
only after exact reconstruction of the candidate convolution. It expands
the additional operator with the original Series definition and requires
direct original full-Series comparisons for each distribution before the
finite and24-reference gates. FeynCalc is loaded before the reused prefix
is parsed; saved-amplitude convolution does not load FeynArts. The local
full-expansion attempt and receipt are retained under
`s02_result/reference/local_attempt_full_expansion` for timing/provenance.


## Bounded local Hgg scheme preparation

The user-authorized `misc/s05_prepare_Hgg_scheme.wls` executes the complete existing Hgg S15 entry in scheme-only mode, changing only local runtime checks, output paths and explicit execution provenance. It requires the accepted native S11 receipt and the archived accepted scheme receipt, preserves every original scheme gate and the full prior-tensor comparison, and records the actual local Wolfram/FeynCalc versions separately from imported cluster commands. Outputs remain under misc/s05_result until the executed checks and exact native reload pass. It does not export finite hats or bypass the unfinished S08/S12/S14 work. One kernel is limited to8GiB tree RSS,12GiB virtual address space,4GiB available-RAM and disk reserves,32MiB outputs and600seconds. The larger virtual-address allowance is not a RAM reservation. After acceptance the source link and result/check/receipt copies belong to Hgg/s15_prepare_native_scheme.wls and Hgg/s15_local_scheme_result; final production export must still verify the actual complete S14 tensor.

S05 local Hgg scheme preparation passed all original gates and exact native reload in8.012012seconds, peak335728640bytes. Accepted source/output identities and channel copies are recorded in Hgg/README.md under Accepted local Hgg finite-scheme preparation. No disposable physics cache was produced.

## Bounded local Hgg mapping

`s06_map_Hgg_local.wls` executes the accepted Hgg map with one local kernel.
The complete contract is in Hgg/README.md; `s06_inputs.json` binds the source,
accepted algorithm records, native inputs and imported component38 groups.
It first compares a fresh whole component8 with its accepted coefficients.
The actual local runtime is retained separately from cluster input provenance.
`s06_result` holds local accepted component maps and receipts; `s06_work` holds
resumable production checkpoints. Preserve those checkpoints until the full
Hgg map is accepted. No finite F hats are produced by this mapping-only stage.
