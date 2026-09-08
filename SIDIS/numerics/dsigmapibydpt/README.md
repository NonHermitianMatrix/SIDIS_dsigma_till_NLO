# H1 plots using the SIDIS F hats

Both figure sets were generated from the final [SIDIS bin predictions](../s09_result):

| Figure | PDF | PNG |
|---|---|---|
| Cross sections in three Q2 intervals | [Cross sections](s03_cross_section.pdf) | [Cross sections](s03_cross_section.png) |
| Theory/H1 ratios in three Q2 intervals | [Ratios](s03_ratios.pdf) | [Ratios](s03_ratios.png) |

Both KKP and Kretzer use the same H1 bins, scales, cuts and plotting definitions as the original numerics figures. “This calculation” denotes the newly integrated six-channel SIDIS prediction. The H1 data, published paper curves and existing complete BigTMD overlay are unchanged. Numerical integration errors are shown; the data use their total experimental errors.

`s01_result` and `s02_result` retain the accepted experimental/paper carriers and their original preparation scripts. `s04_bigtmd_result` supplies the unchanged reference overlay only. No reference coefficient or bin estimate supplies the new SIDIS prediction. Paper ratios use curves evaluated at bin centres; SIDIS and BigTMD use bin averages.

To render the accepted results again, run the existing plotting program from the numerical environment:

```bash
python dsigmapibydpt/s03_plot_comparison.py
```

Run that command from the parent `numerics` folder. The program requires accepted numerical results, complete bin matching and matching shared physical inputs. [s03_result](s03_result) contains every plotted value and the exact source/input/figure hashes. All shared physical-setting checks passed, both figures were visually inspected, and the local files match those hashes. The source is [s03_plot_comparison.py](s03_plot_comparison.py).

The exact producer conventions, validation evidence, runtime and inherited Hgq sign/azimuth limitations are in [the numerical README](../README.md). Only [scripts/progress.md](../../../progress.md) is the live progress record.
