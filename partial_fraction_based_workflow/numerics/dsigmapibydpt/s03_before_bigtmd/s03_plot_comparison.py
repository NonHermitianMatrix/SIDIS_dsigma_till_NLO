#!/usr/bin/env python3
"""Plot executed bin predictions, H1 data, original paper curves and ratios."""
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent/'python_deps'))
import hashlib, json, os
os.environ.setdefault('MPLCONFIGDIR', str(ROOT.parent/'tmp/matplotlib'))
from datetime import datetime, timezone
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import NullFormatter
from scipy.interpolate import interp1d


def record(message):
    with (ROOT.parent.parent/'progress.md').open('a') as f:
        f.write('\ndsigmapibydpt S03 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    record('Starting the requested three-Q2 cross-section and theory/data plots from executed numerical results, HEPData and original EPS curves. Next verify complete bin matching and save figures plus ratio values.')
    inputs = [ROOT.parent/'s09_result', ROOT/'s01_result', ROOT/'s02_result']
    theory, experiment, paper = [json.loads(p.read_text()) for p in inputs]
    assert theory['status'] == 'Complete', 'Numerical precision and convergence must be accepted before final plots'
    assert len(theory['bins']) == sum(len(t['bins']) for t in experiment['tables'])
    plt.rcParams.update({'font.size': 10, 'axes.labelsize': 12, 'figure.dpi': 140,
                         'savefig.dpi': 220, 'pdf.fonttype': 42, 'ps.fonttype': 42})
    fig, axes = plt.subplots(3, 1, figsize=(8.3, 11), sharex=True)
    ratios_fig, ratio_axes = plt.subplots(3, 1, figsize=(8.3, 11), sharex=True)
    colors = {'KKP': '#0072B2', 'Kretzer': '#D55E00'}
    ratio_results = []
    for panel, (table, published, ax, rx) in enumerate(zip(experiment['tables'], paper['panels'], axes, ratio_axes)):
        assert table['Q2_range_GeV2'] == published['Q2_range_GeV2']
        data = table['bins']; low = np.array([float(b['pt_low_GeV']) for b in data])
        high = np.array([float(b['pt_high_GeV']) for b in data]); centers = np.mean([low, high], axis=0)
        values = np.array([float(b['dsigma_dpt_pb_per_GeV']) for b in data])
        errors = np.array([float(b['total_pb_per_GeV']) for b in data])
        edges = np.r_[low, high[-1]]
        rows = sorted([b for b in theory['bins'] if b['panel'] == panel], key=lambda r: r['bin'])
        assert np.allclose([r['bounds'][-2:] for r in rows], np.array([low, high]).T)
        own = np.array([r['dsigma_dpt_pb_per_GeV'] for r in rows]); own_error = np.array([r['dsigma_error_pb_per_GeV'] for r in rows])
        ax.errorbar(centers, values, yerr=errors, xerr=np.array([centers-low, high-centers]),
                    fmt='o', color='black', ms=4, capsize=2, label='H1 data (total error)', zorder=5)
        rx.stairs(1+errors/values, edges, baseline=1-errors/values, fill=True, alpha=.16,
                  color='gray', label='H1 relative total error')
        rx.axhline(1, color='black', lw=.8)
        saved_panel = dict(Q2_range_GeV2=table['Q2_range_GeV2'], bins=[])
        for j, name in enumerate(theory['FFs']):
            color = colors[name]
            ax.stairs(own[:, j], edges, baseline=None, color=color, lw=1.7, label='This calculation, '+name)
            ax.errorbar(centers, own[:, j], yerr=own_error[:, j], fmt='s', color=color, ms=3, capsize=2)
            curve = published['curves'][name]
            px = np.array(curve['pt_GeV']); py = np.array(curve['dsigma_dpt_pb_per_GeV'])
            ax.plot(px, py, color=color, ls='--', lw=1.5, label='Paper NLO, '+name)
            interpolation = interp1d(np.log(px), np.log(py), bounds_error=True)
            assert np.all(centers >= px[0]) and np.all(centers <= px[-1])
            paper_centers = np.exp(interpolation(np.log(centers)))
            rx.errorbar(centers, own[:, j]/values, yerr=own_error[:, j]/values,
                        color=color, fmt='s-', lw=1.3, ms=3, capsize=2, label='This calculation / H1, '+name)
            rx.plot(centers, paper_centers/values, color=color, ls='--', marker='D', ms=3,
                    label='Paper at bin centres / H1, '+name)
            for k in range(len(data)):
                if j == 0:
                    saved_panel['bins'].append(dict(pt_low_GeV=float(low[k]), pt_high_GeV=float(high[k]),
                        pt_center_GeV=float(centers[k]), experimental_value=float(values[k]),
                        experimental_total_error=float(errors[k]), FFs={}))
                saved_panel['bins'][k]['FFs'][name] = dict(
                    calculation_bin_average=float(own[k, j]), integration_error=float(own_error[k, j]),
                    calculation_over_data=float(own[k, j]/values[k]), integration_ratio_error=float(own_error[k, j]/values[k]),
                    paper_curve_at_bin_center=float(paper_centers[k]), paper_center_over_data=float(paper_centers[k]/values[k]))
        negative = np.any(own-own_error <= 0)
        ax.set_yscale('symlog' if negative else 'log', **({'linthresh': float(values.min()/10)} if negative else {}))
        ratio_values = own/values[:, None]
        if np.any(ratio_values <= 0) or np.max(np.abs(ratio_values)) > 15:
            rx.set_yscale('symlog', linthresh=1)
        label = '$'+table['Q2_range_GeV2'][0]+r' < Q^2 < '+table['Q2_range_GeV2'][1]+r'\;\mathrm{GeV}^2$'
        for a in [ax, rx]:
            label_x, label_align = (.03, 'left') if a is rx else (.97, 'right')
            a.text(label_x, .94, label, ha=label_align, va='top', transform=a.transAxes,
                   bbox={'facecolor': 'white', 'edgecolor': 'none', 'alpha': .85})
            a.grid(True, which='major', alpha=.2); a.set_xscale('log'); a.set_xlim(2.5, 15)
        ax.set_ylabel(r'$d\sigma^{\pi^0}/dp_T\;[\mathrm{pb/GeV}]$')
        rx.set_ylabel('Theory / H1')
        ratio_results.append(saved_panel)
    for figure, axs in [(fig, axes), (ratios_fig, ratio_axes)]:
        axs[-1].set_xlabel(r'$p_T\;[\mathrm{GeV}]$ (photon–proton centre-of-mass frame)')
        axs[-1].set_xticks([2.5, 3, 4, 5, 7, 10, 15], labels=['2.5', '3', '4', '5', '7', '10', '15'])
        axs[-1].xaxis.set_minor_formatter(NullFormatter())
        handles, labels = axs[0].get_legend_handles_labels()
        figure.legend(handles, labels, loc='upper center', ncol=2, frameon=False, fontsize=9,
                      bbox_to_anchor=(.5, .976))
        figure.tight_layout(rect=(0, .13, 1, .88), h_pad=1.0)
    fig.suptitle(r'Neutral-pion SIDIS: supplied six-channel LO + NLO, $\mu^2=(Q^2+p_T^2)/2$', y=.995, fontsize=12)
    ratios_fig.suptitle('Neutral-pion SIDIS: theory-to-data comparison', y=.995, fontsize=12)
    fig.text(.13, .035, 'MRST2002 NLO; H1 forward-pion cuts. Error bars on this calculation: integration only.\n'
             'Hgq_v4 input; unresolved MadGraph real comparison retained; uniform azimuth.\n'
             'Paper curves: original EPS vertices, hep-ph/0411212 Fig. 4 / 1808.04396 Fig. 3.', fontsize=8)
    ratios_fig.text(.13, .035, 'This calculation uses bin averages; paper values are interpolated at bin centres.\n'
                    'Paper-centre ratios are curve-to-bin comparisons, not paper bin-integrated predictions.\n'
                    'Gray band: experimental total error. Theory error bars: numerical integration only.', fontsize=8)
    paths = []
    for figure, stem in [(fig, 's03_cross_section'), (ratios_fig, 's03_ratios')]:
        for ext in ['pdf', 'png']:
            path = ROOT/(stem+'.'+ext); figure.savefig(path); paths.append(path)
    result = dict(stage='s03', status='Complete', producer_sha256=sha(Path(__file__)),
        inputs={str(p.relative_to(ROOT.parent)): sha(p) for p in inputs}, panels=ratio_results,
        paper_ratio_policy='Original log-axis EPS curves evaluated at bin centers inside their support; no extrapolation. These are curve-to-bin ratios, not bin-integrated paper predictions.',
        artifacts={p.name: sha(p) for p in paths}, caveats=theory['caveats'])
    (ROOT/'s03_result').write_text(json.dumps(result, indent=2, allow_nan=False)+'\n')
    record('All three Q2 panels and both ratio comparisons written to s03_result, s03_cross_section.{pdf,png}, and s03_ratios.{pdf,png}. Next visually inspect the exported figures.')


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        record('Plot stage failed: '+repr(exc)+'. Next correct the input or plotting issue before claiming final figures.')
        raise
