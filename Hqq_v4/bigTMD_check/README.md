# Hqq_v4 BigTMD comparison

Compare the accepted Hqq_v4 S10 F hats with the authors' channel-2 functions
from https://github.com/JeffersonLab/BigTMD at commit
`6e97635d21a63b7975b2e7f5891edc0c35c4dc0c` (the paper's reference 12).
Production inputs are read-only. Only ../../progress.md records live status.

## S01 contract: reference preparation

`s01_prepare_reference.py` fetches the pinned driver, its LO functions and
the six Hqq NLO modules. Extract only channel-2 PgA/PppA and fchn2A/B/C.
Read kinematics, coupling factors, projectors, active flavors, charge arrays
and luminosities from the driver AST. Evaluate its charge weights with exact
arithmetic and one incoming/observed flavor at a time. Preserve file hashes.

For symbolic endpoint limits, reconstruct short rationals from the authors'
printed decimal constants with denominator at most 1000000 and require a
relative/absolute source-token difference below 5e-15 for every literal.
This is an explicit reference reconstruction, not a change to production.
S03 separately evaluates the printed decimals. No fitted normalization or
local coefficient enters the reconstruction.

## S02 contract: common coefficients and direct hats

`s02_compare_coefficients.wl` verifies the frozen S10/S02 inputs and S01.
Derive the projector and coupling conversion from the imported driver and
require agreement with the current-channel Born/projector definitions.
Derive the change from the authors' raw Log[s23] plus basis to the saved
Hqq_v4 Log[s23/B] basis, including transport of nonconstant coefficients.
Take reference endpoint limits only after exact benchmark substitution.
Compare LO delta and NLO delta/L0/L1/regular coefficients at deterministic
physical points on both signs of s+t, for active up/down flavor charges.
Use the driver's fixed nf and color convention; do not claim other flavor
counts, colors, scales, or the coordinate boundary are covered.

Derive charge moments from S10's saved sums. Evaluate direct ordinary NLO
values from the final StructureFunctions as well as the coefficient table.
Require numerical finiteness and local reconstruction before accepting the
check's execution. Agreement with authors is reported, not assumed.
Independent points may use allocated kernels, with bounded operations,
separate writes, and the existing Hoffman2 memory/process monitors.

## S03 contract: published-decimal check and report

`s03_report_comparison.py` evaluates only the original Hqq return expressions
with mpmath and exact decimal source tokens. It compares direct ordinary
F hats against S02, records the effect of rational reconstruction, and
writes signed BigTMD-minus-local differences and an agreement summary.
The report distinguishes completion from agreement and states tolerance,
coverage, reconstruction assumptions, source hashes, and peak memory.
No comparison outcome authorizes modifying the accepted production result.

S01 accepted: Hoffman2 job 14691655, source SHA256 199f6664a897cbceb00d060d59f6645db117bd6ea9b012479e2643fb426fa9f9, result SHA256 f842004e1dc74c99196d495a80a86985361a7464886173c0a136fabe892fb160. Artifacts: s01_result.wl, s01_result.json, pinned reference/, s01_run.log and s01_execution.json. All numeric-token bounds and selected flavor definitions passed. Printed decimals remain available for S03.

S02 benchmark-domain correction: the first selector admitted Q=5,t=-25, where the pinned authors return expressions have explicit Q**2+t denominator factors. Physical support alone does not guarantee these unsimplified reference expressions are evaluable. Select candidates only when every actual imported denominator base evaluates to a finite nonzero number. This selects evaluable benchmarks before comparing any values; it is not a fit. Parallel worker failures must return an error to the main acceptance gate rather than terminating and replaying the task. The initial attempt is superseded and has no accepted comparison result.

S02 serialization contract: recursively evaluate conversions of rationals in
associations/lists before RawJSON export, and gate export/reimport before
printing success. Job 14691692 completed all six numerical points and all
reconstruction gates but failed the final JSON conversion. Its complete WL
snapshot and source are preserved under s02_previous_14691692. Reuse requires
their exact hashes, identical frozen inputs, identical numerical program
text, matching benchmark definitions and the source-bound success receipt.
Only this serialization resume runs serially; it has no remaining numerical
task for parallel kernels.

S02 accepted: export job 14691757, source SHA256 ab709b3b33665b4e371d8838f90498984c3a1d444a2fe321444b66fcb9dfa722, result SHA256 85b46dc70506b477940805244421b7414b4d831e4a58fdffe625bb28b1078261. Artifacts: s02_result.wl, valid s02_result.json, s02_run.log and s02_execution.json. Numerical snapshot job 14691692 passed all six benchmarks, source/Born/projector/charge/basis and direct-expression gates; its exact source/result and unchanged program passed serialization-resume gates. The JSON round trip and independent strict Python JSON read passed. Source-bound numerical snapshot, caches and receipt under s02_previous_14691692 remain mandatory resume provenance. The coefficient comparison uses fixed s,t and the saved Log[s23/B] plus convention; no convolution/Jacobian factor is part of these partonic hats. Agreement is determined by S03.

S03 accepted: Hoffman2 job 14691762, source SHA256 aeb0bad68e19dac8861987755d8e545b8efa578a4b2fc2402c0af07a39c56873. Result identities: {"s03_result.wl": "5d049be0b0b78f08707ba801f5d6a6c93e6356dc0214ba417cf4c728a12157f6", "s03_result.json": "c79e40bb3fe890f5f4d88e844fffb315901e0fd2e472f4084dc0f954ebb74040", "s03_result.md": "cc137072d8bdf9c7a90819f738fe5442704a1b5d696b921e11ebafd0321d3c4c"}. All 120 reconstructed-reference coefficient comparisons, all 24 direct reconstructed-reference comparisons and all 24 independently evaluated published-decimal direct comparisons passed. Published-decimal maximum relative difference 6.434401797943158e-14; maximum absolute difference 1.9216556972377208e-16. Tolerance is abs difference <= 1e-14 + 1e-9 times the larger absolute value. Both coordinate signs and up/down charge choices are covered for nf=4, SU(3), mu=Q, alphaS=1/5. Endpoint comparisons retain the documented short-rational reconstruction assumption. Full numbers and signed differences: s03_result.json; readable report: s03_result.md. The production hats are unchanged.

Memory evidence: accepted numerical job 14691692 peak combined RSS 3087552512 bytes; final export job 14691757 peak 502431744 bytes; S03 job 14691762 peak 91385856 bytes. No memory guard triggered. The obsolete initial failed-attempt point cache was deleted after the complete comparison superseded it; its source/log/accounting remain. Keep s02_previous_14691692 because the accepted serialization result verifies and consumes that complete numerical snapshot.
