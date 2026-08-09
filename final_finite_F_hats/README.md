# Final finite partonic F-hats

This folder collects the accepted finite results without changing algebraic
representation.

- Hgg, Hqqbar, Hqqp: one exact Mathematica expression per F-hat.
- Hgq: separate exact distribution-sector `.m` and regular-sector `.pkl`
  files per F-hat.
- Hqg: separate distribution-sector F-hats plus the accepted Wolfram
  `F12hat_Hqg_regular.mx` container. The container defines both regular-sector
  symbols and is preserved byte-for-byte because no licensed local Wolfram
  kernel is available to split it safely.
- Hqq: one verified pickle per F-hat, each containing all four sectors.

`MANIFEST.json` records sizes and hashes; `SHA256SUMS` verifies every result.
These are partonic `F1hat`/`F2hat`, not the hadronic PDF/FF convolutions.

