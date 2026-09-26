# Hoffman2 execution contract

Use an isolated remote directory for polarized SIDIS. Reuse installed
software and authenticated access without modifying another calculation's
jobs, control connection, code, caches, or results.

Run task programs on compute nodes under scheduler allocations. Limit
per-process memory, combined process-tree RSS, concurrency, runtime, and
scratch use. Observe scheduler/process state, output progress, and memory
with a persistent monitor; completion requires the stage's own acceptance
marker and expected result artifacts.

Transfer only explicitly selected final source/configuration files and
corresponding results. Check sizes and free space before transfer and
verify hashes afterward. Large integration and reduction caches remain
remote. Do not store credentials in any artifact. Follow the current user
AGENTS.md policy for the live record in `scripts/progress.md`.

The accepted runtime probe is `.cluster/s02_result/s02_runtime.wl`
(job `14773392`, Mathematica 13.1). The executor sets both historical and
current Wolfram user-base environment variables to the task's scratch
cache. Programs run with the calculation root as their working directory.
Resource caps must be clipped to inherited scheduler hard limits. Live RSS
uses procfs as well as ps and must fail closed if neither reports memory.
Use separate `ps -o` arguments for PID, parent PID, and RSS: the installed
compute-node ps interprets a comma after an empty header as header text.
The separate-argument form was checked against the running main kernel
and all four local subkernels on n7441. The earlier executor is preserved
under `s01_result/reference/` for receipts that bind that source.
Watchers compare successive heartbeat contents using a monotonic clock;
cross-node filesystem modification times are not an inactivity clock.

## Scheduling and resource selection

Use the production Grid Engine shared batch environment. The account's
`myresources` output on 2026-09-18 identifies `campus` access, no `highp`
access, and a maximum 24-hour shared-job runtime. Do not request purchased
resources, exclusive nodes, fixed hosts, or processor models without a
demonstrated requirement and confirmed access.

Match scheduler slots to the program's worker count and keep library
threading bounded. `h_data` is per slot. Use completed-job `qacct -j`
maximum virtual memory and current `check_usage` evidence when selecting
memory, including headroom for any increased worker count. Shared queues
have no guaranteed start time.

The measured continuation profiles for S05 are four slots with `h_data=4G`
for Hqq, `5G` for Hqg, and `6G` for Hgg. Their process-tree RSS guards are
15, 18 and 22 GiB respectively. The Hgq serial assembly continuation uses one
slot with `h_data=20G` and an 18 GiB RSS guard after the previous 12 GiB
process address-space cap proved insufficient. Hqqprime S08 continuation uses four slots with `h_data=6G`
and a 22 GiB RSS guard. These continuation jobs request four hours and
preserve completed native checkpoints. Allocation metadata and the previous
configurations are stored beside the corresponding `sNN_result/`
submission records in this directory.

Change pending resource requests with `qalter` after holding the job and
verifying it has not started. Update and verify the executor resource
configuration before release, and use that same configuration for later
checkpoint resumes. Never modify a running job's configuration. Select
shorter runtimes for measured short validation or administration jobs.
Run substantial cache compression through a compute allocation.

References: [scheduling policy](https://www.hoffman2.idre.ucla.edu/Policies/Job-scheduling.html),
[production computing guide](https://www.hoffman2.idre.ucla.edu/Using-H2/Computing/Computing-Altair-production.html),
[resource-request guidance](https://support.idre.ucla.edu/KB/View/2049342-requesting-the-appropriate-amount-of-resources-for-jobs-on-the-hoffman2-cluster),
and [login-node policy](https://www.hoffman2.idre.ucla.edu/Policies/Role-of-login-nodes.html).

## S02 executor storage-monitor contract

`s02_execute.py` preserves the S01 source/input verification, native command,
resource ceilings, expected artifacts, exit checks and acceptance markers.
It moves the unchanged scratch-size and free-space measurements to one daemon
thread, with at least 60 seconds between completed scans. Process-tree RSS,
wall-time and output-inactivity checks do not wait for that directory scan.
A pending first measurement is recorded as null, never as zero usage. A
storage error or measurement age beyond the configured inactivity bound
(with a 300-second minimum) stops a still-running program explicitly.
Completed programs do not wait for a pending scan; the receipt records its
measurement availability and age. Native per-process/per-file scheduler
limits continue to apply.

The preceding `s01_execute.py` remains unchanged because running and queued
jobs bind its exact source. New submissions must explicitly invoke S02 and
bind its source hash. This separates execution versions without changing
any physics program or declaring earlier mathematical results invalid.

The local non-physics fault-injection checks are recorded in
`s02_result/s02_storage_checks.json`, binding source SHA256
`e990f6fb14efddc603affef591c0fad7c18ba8b2b1ed152fd30f0e2ba544d6eb`.
They verified unchanged existing helper functions and exact storage counting,
a single scan in flight, nonblocking polls while the scan is blocked,
retention of completed measurements, visible storage failures and process
exit while a daemon scan is pending. Temporary test data was removed.
These checks validate the runtime change only; production acceptance still
requires an authentic compute-allocation receipt and each native stage's
unchanged scientific gates.
