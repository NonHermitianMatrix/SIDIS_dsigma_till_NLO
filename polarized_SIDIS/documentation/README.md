# Documentation artifacts

The report source and PDF are one level above this folder. All common stages and all six channels are explained in the report, including the general mathematical form of long expressions. Owner READMEs explain the directory interfaces and accepted execution paths.

- `reference_unpolarized.txt`: text extraction of the authoritative local SIDIS PDF, used when writing the report.
- `s01_latex_tool.json`: official portable Tectonic release identity and hashes; `tools/tectonic` is the compiler.
- `s02_stage_receipts.json`: copies of accepted stage receipts used to build the channel entry-point tables. These describe executed artifacts, not a live progress log.
- `s04_pdf_build.json` and `s04_pdf_build.log`: compiler execution and artifact identity, updated after the final build.
- `s05_source_manifest.json`: exact listed source/configuration bytes and original README identities; every block was parsed back from the generated README and compared byte-for-byte with its file or symlink target.
- `s06_documentation_checks.json`: exact source reconstruction, original-ledger preservation, 352 resolved guide links, all final-result hash comparisons, 26-page PDF and visual layout checks.
- `s07_report_text.txt`: extracted text of the final PDF, used to verify content and resolved references.
- `s04_latex.log`: native final compiler diagnostics.
- `tex_cache/`: compiler support files downloaded for this document; not physics inputs.

The source snapshot is an exact-code reproducibility aid. It does not embed large mathematical result files, production caches, licensed software or all external packages. Those dependencies remain explicitly bound by the actual source/configuration manifests. The only live status record is `scripts/progress.md`.
