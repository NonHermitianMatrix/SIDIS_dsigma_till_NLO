# Cluster execution files

This directory holds reviewed job configurations, generated Grid Engine submissions, runtime probes and the executor that binds a job to its inputs. It does not define a different physical calculation. See [README_code.md](README_code.md) for preserved allocation and monitor details and [README_sources.md](README_sources.md) for every included source/configuration byte.

## How a stage is executed

A stage configuration provides `command`, `environment`, `reviewed_sha256`, `expected_results`, `success_marker`, `execution_result`, `log`, `heartbeat` and resource `limits`. The executor checks the reviewed files, runs from the polarized_SIDIS root in an isolated Wolfram user base, monitors process-tree memory, time, output inactivity and storage, and records command, input/output hashes, native exit, elapsed time and acceptance. Process exit zero alone is not a scientific acceptance gate.

`s02_execute.py` is the current guarded executor. `s01_execute.py` and prior variants remain because historic receipts bind their hashes. The S02 storage scan runs in one daemon thread so it cannot block process monitoring. An unavailable or stale measurement is reported as unavailable, not zero use. The executor still requires the configured scientific success marker and result files.

The accepted channel guides link receipt-matching configurations. Their paired scheduler scripts specify the corresponding slots, wall time and per-slot `h_data`; inspect both together. Execute production work only on allocated compute nodes, with matching worker counts and total memory. The root [README_code.md](../README_code.md) gives command examples and their prerequisites. These are reproduction instructions; this documentation task does not submit a job.

## Ownership and resources

Keep the task in its own scratch directory. Do not change another calculation's jobs or caches. Submit only through resources available to the account and the current Hoffman2 policies. Shared queues do not guarantee immediate starts. Reconnecting SSH does not by itself change scheduler priority. Configure the job for its measured work rather than assuming more slots or memory means faster algebra.

Stage receipts and configuration files are provenance. Source listings reconstruct them, but historic absolute runtime paths must be mapped through the existing `{root}` mechanism when supported, and genuinely changed inputs require new reviewed hashes. Never weaken hash checks or insert a fake scheduler identity to make a local run pass. Hgg has explicit accepted local adapters under misc for the user-authorized local continuation.
