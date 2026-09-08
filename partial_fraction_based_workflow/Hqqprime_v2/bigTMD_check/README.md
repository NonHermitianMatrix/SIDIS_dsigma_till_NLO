# Hqqprime BigTMD check

The production result is saved and hashed before fetching the pinned
JeffersonLab/BigTMD channel-6 coefficients. Each of the A, B, C charge
coefficients is compared separately at the same 18 physical points used
for the preceding channels. The driver's charge mapping is evaluated
directly on single-flavour inputs and checked symbolically.

The published plus-coefficient endpoints must vanish before they are
included in an ordinary finite density. Regular-only and complete
coefficient comparisons are retained separately. The driver includes
channel 6, but its plus selection is restricted to channels below 4.

Run s01_prepare_reference.py, s02_benchmarks.wls with Wolfram Engine 15,
then s03_compare.py. No downloaded coefficient is an input to production.

Accepted check artifacts

All 108 comparisons of complete supplied coefficients passed for
A, B and C separately. Maximum relative difference: `4.097914501943293e-13`.
The twelve published plus-coefficient endpoints vanish exactly in
`s02_endpoint_result.wl`; their ordinary contributions are included in
the complete comparison. The measured driver luminosities reconstruct
all four charge samples with the identity charge mapping.

The regular-only result differs (36/108 comparisons pass).
The pinned driver includes channel 6 but omits its plus contributions.
This acceptance concerns the complete supplied coefficient functions;
no claim is made that the unchanged driver matches the complete result.
The comparison is numerical at the listed points, not a symbolic
identity proof against the published decimal functions.

Reference source and hashes: `reference/` and `s01_result.json`; exact
endpoint input: `s01_auxiliary.wl`; 60-digit local benchmarks and charge
transport: `s02_result.json`; comparisons and signed differences:
`s03_result.json` and `bigtmd_minus_local.md`. Each stage has its matching
`sNN_result.log` and `sNN_resources.json`. The checked production hash is
`4aee27e2d6b9decefce735ecb94536a71f4be0f09352cf5a538fd3b27d504cf6`. All reference fixtures are retained for reproduction.
