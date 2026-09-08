# Hqg_v3

Requested channel: incoming quark, observed gluon, through order alpha_s^2.
Definitions follow Wang et al., arXiv:1903.01529, especially Eqs. (9), (19),
(21)-(27), (34), (39), (46), and Table I.

This calculation uses the paper authors' published, already combined finite
NLO tensor coefficients from JeffersonLab/BigTMD, channel 3A. It is a symbolic
reproduction of that result, rather than a new integration of the diagrams.
The standalone NLO QCD reference supplies the symbolic workflow pattern.
No other project calculation code is used.

The published coefficients fix SU(3). The quark charge, alpha_s, nf, common
scale mu, and kinematic variables remain symbolic. Separate renormalization,
PDF, and fragmentation scales are not supplied by these published inputs.

1. `s01_import_published.py` checks the downloaded source identities, converts
   the coefficient expressions to Wolfram Language without executing their
   numerical implementation, reconstructs long rounded decimal coefficients
   within a documented rational denominator bound, and writes `s01_result.wl`.
2. `s02_born_and_projectors.wl` calculates the two Born contractions with
   FeynCalc, checks both Ward identities and the published Born normalization,
   and derives the structure-function projectors from the tensor decomposition.
3. `s03_assemble_fhats.wl` takes exact analytic endpoints, checks the endpoint
   against the plus terms for each contraction, restores the coupling and
   quark charge, applies the projectors, and writes `s03_result.wl`.

## Result and use

`s03_result.wl` is the self-contained final result. It includes **both the
order-alpha_s Born term and the order-alpha_s^2 correction**. Load it with:

```wolfram
result = Get["scripts/Hqg_v3/comparison/s03_result.wl"];
fhat1 = result["Fhat1"];
fhat2 = result["Fhat2"];
```

`result["NLOCoefficients"]["Fhat1"]` and the corresponding `Fhat2` entry
give the `delta`, `plus0`, `plus1`, and `regular` coefficients separately.
`result["BornDeltaCoefficients"]` gives the Born coefficients. All these
coefficients already include their powers of `alphaS` and the charge `eq^2`.
`eq` is the quark charge in units of the positron charge; electromagnetic
couplings from the leptonic cross-section prefactor are not part of Fhat.

The symbols are `Q` (positive photon virtuality scale), `s,t,s23` (the paper's
invariants), `xh` (xhat), `mu` (the published common scale), `nf`, `alphaS`,
`eq`, and `B` (the positive upper endpoint of the recoil invariant).
`XhatRule` supplies the defining relation between `xh` and `s`.
`KinematicRules` expresses `s,t,u,zh` through `xh,Q,qT2,s23`, with `qT2=qT^2`.
`PhysicalSupport` records the physical region of the expressions.

`PlusDistribution[n,r,B,M2]` is a symbolic distribution, defined by its action
on a smooth test function:

```wolfram
Integrate[Log[r/M2]^n (f[r] - f[0])/r, {r, 0, B}]
```

For a multiplying coefficient `C[r]`, subtract `C[0] f[0]` from `C[r] f[r]`.
The result uses `M2=Q^2` and `n=0,1`. The published `Log[s23]/s23` basis is
converted exactly to this basis, including the compensating plus0 term.
Apply `KinematicRules` before evaluating the endpoint of the complete test
function: `t` varies with `s23` at fixed `xh,Q,qT2`. The delta coefficients
have already been evaluated at exactly `s23=0`; no small numerical cutoff
is used. Delta and plus terms must use the same `B`.

## Executed checks

- The five downloaded source files match their pinned Git blob hashes.
- The 31 distinct long decimal literals reconstruct uniquely within the
  stated denominator bound.
- FeynCalc gives zero for the photon and gluon Born Ward identities.
- Both calculated Born contractions match the published ones exactly.
- The tensor-derived projectors equal paper Eq. (9) in symbolic dimension.
- Each NLO contraction passes the exact relation between its delta
  coefficient's B dependence and its two plus coefficients at the endpoint.
- The final expressions have no floating-point numbers or unevaluated
  integrals or limits.

The calculation logs are `s02_run.log` and `s03_run.log`. Wolfram reported
peak kernel memory below 180 MB in each accepted run; each process was also
run with a 6 GiB address-space ceiling.

## Reproduction commands

Run the exact import first:

```bash
python3 scripts/Hqg_v3/comparison/s01_import_published.py
```

Then run the Born and projector calculation with a 6 GiB memory ceiling:

```bash
prlimit --as=6442450944 -- /home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel -noinit -noprompt -script scripts/Hqg_v3/comparison/s02_born_and_projectors.wl
```

Finally assemble the structure functions with the same ceiling:

```bash
prlimit --as=6442450944 -- /home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel -noinit -noprompt -script scripts/Hqg_v3/comparison/s03_assemble_fhats.wl
```

Published source identity and rational reconstruction details are recorded in
`s01_result.json`. Short terminating decimals are interpreted exactly; long
decimals use the unique rational with denominator at most 10^6 within the
printed rounding interval. This bound is an explicit reconstruction assumption,
not access to the authors' original exact algebra files.

All results are symbolic. `PolyLog[2,z]` replaces the public numerical series.
No PDFs, fragmentation functions, numerical quadrature, or other project
channel files are loaded.

The original real-emission integration, virtual integration, and pole
cancellation are **inherited from the published finite NLO inputs**, and
were not independently rerun here. The independent calculation in this
directory covers the Born contractions and projector derivation. No claim
of a new diagram-to-NLO derivation or general-color result is made.

Published inputs: [BigTMD channel-3 Pg](https://raw.githubusercontent.com/JeffersonLab/BigTMD/6e97635d21a63b7975b2e7f5891edc0c35c4dc0c/NLO/Pg/fchn3A.py),
[BigTMD channel-3 Ppp](https://raw.githubusercontent.com/JeffersonLab/BigTMD/6e97635d21a63b7975b2e7f5891edc0c35c4dc0c/NLO/Ppp/fchn3A.py),
and [the paper](https://arxiv.org/abs/1903.01529).


## Physical endpoint correction

S03 now resolves each sign of s+t before accepting a direct s23 endpoint. Any resulting nonfinite term is instead evaluated from the original finite-recoil expression using a one-sided Limit with the physical branch assumptions. Every term must be finite and evaluated; the endpoint/plus cutoff identity is rerun. The comparison representation explicitly excludes s+t=0. Previous S03 outputs and their source are preserved in `s03_pre_physical_endpoints_82c3febca531`; they must not be used as accepted author endpoints. This correction affects only the authors reconstruction, not the independent production result.


Accepted corrected author S03: `comparison/s03_assemble_fhats.wl`, `comparison/s03_result.wl`, `comparison/s03_tensor_Pg.wl`, `comparison/s03_tensor_Ppp.wl`, both zero cutoff files, and `s13_author_endpoints_run.log`. Each physical-branch endpoint is finite and both endpoint/plus cutoff identities passed. Source SHA256 450b0bc6e7d1e4eccc7528405d36e4d75df78223b8865ca2924b936e0fc29f27; result SHA256 a0a0cecffaf068a7ace491b1b623f10f15913be45c1be03ded0d2c27a719f464. The author representation excludes s+t=0. The guarded run exited 0 with peak RSS 690.2 MiB. These remain author-derived comparison data; independent S12 is unchanged.
