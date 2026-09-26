# Algebra and integration dependencies

This folder is the interface to the existing native algebra/integration tools, not a vendored replacement. The accepted workflow uses FeynArts/FeynCalc for amplitudes and traces, Kira/Fermat for reductions, and the pinned master/integration inputs and associated SubTropica workflow where recorded. The Wolfram/FeynCalc runtime versions and native paths are bound by stage receipts and job configurations. Use the dependency records in common and .cluster when reproducing a stage; do not infer compatibility merely from an installed executable name.

The original folder note is preserved in [README_code.md](README_code.md). Return to the [main guide](../README.md) or [physics report](../polarized_SIDIS_report.pdf). There is no additional completed stage or numerical result hidden in this directory.
