#!/usr/bin/env python3
"""Recover the original NLO paths reused in arXiv:1808.04396, Fig. 3."""
from pathlib import Path
import os
import sys
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent / 'python_deps'))
import hashlib
import json
import re
from datetime import datetime, timezone
import numpy as np
from scipy.integrate import quad


def record(message):
    line = "SIDIS numerics S02 " + datetime.now(timezone.utc).isoformat() + ": " + message
    if os.environ.get("SIDIS_CLUSTER_RUN") == "1":
        print("PROGRESS " + line, flush=True)
        return
    with (Path(__file__).resolve().parents[3] / "progress.md").open("a") as stream:
        stream.write("\n" + line + "\n")

def main():
    record('Requested published-theory comparison. Starting EPS path extraction, '
           'axis calibration and bin integration; next save s02_result.')
    source = ROOT.parent / 'references/FIG4.eps'
    eps = source.read_text()
    assert '(KKP NLO)' in eps and '(K NLO)' in eps
    data = json.loads((ROOT / 's01_result').read_text())
    # These coordinates and labels are source observations, not theory inputs.
    x_ticks = np.array([549, 775, 950, 1093, 1215, 1319, 1412, 1495, 1813])
    x_labels = np.array([3, 4, 5, 6, 7, 8, 9, 10, 15])
    x_fit = np.polyfit(x_ticks, np.log(x_labels), 1)
    x_residual = np.max(np.abs(np.exp(np.polyval(x_fit, x_ticks))/x_labels-1))
    assert x_residual < 0.002
    y_ticks = [[1445, 1587, 1728], [878, 1020, 1162], [327, 485, 642]]
    curves = []
    paths = list(re.finditer(r'406\s+(-?\d+)\s+m\s+((?:-?\d+\s+-?\d+\s+d\s*){8,})s', eps))
    assert len(paths) == 12, len(paths)
    for panel in range(3):
        y_fit = np.polyfit(y_ticks[panel], np.log([1, 10, 100]), 1)
        panel_curves = {}
        # EPS legend: dashed [12 12] is K NLO; red solid is KKP NLO.
        for name, position in [('Kretzer', 0), ('KKP', 2)]:
            path = paths[panel*4 + position]
            start = np.array([406, int(path.group(1))])
            increments = np.array(re.findall(r'(-?\d+)\s+(-?\d+)\s+d', path.group(2)), int)
            xy = np.vstack([start, start + np.cumsum(increments, axis=0)])
            pt = np.exp(np.polyval(x_fit, xy[:, 0]))
            value = np.exp(np.polyval(y_fit, xy[:, 1]))
            assert np.all(np.diff(pt) > 0) and np.all(value > 0)
            panel_curves[name] = dict(pt_GeV=pt.tolist(),
                dsigma_dpt_pb_per_GeV=value.tolist(), eps_coordinates=xy.tolist(),
                interpolation='linear in log(pT), log(dsigma/dpT), as drawn by EPS segments',
                support_GeV=[float(pt[0]), float(pt[-1])])
        curves.append(dict(Q2_range_GeV2=data['tables'][panel]['Q2_range_GeV2'],
                           curves=panel_curves, y_axis_fit=y_fit.tolist()))
    result = dict(stage='s02', status='Complete',
        source='arXiv:hep-ph/0411212 source FIG4.eps, reproduced as arXiv:1808.04396 Fig. 3',
        source_url='https://arxiv.org/src/hep-ph/0411212',
        source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
        source_program_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        x_axis_fit=x_fit.tolist(), x_tick_max_relative_residual=float(x_residual),
        digitization='Original EPS vertices; axis coordinates rounded to EPS integer units.',
        panels=curves)
    (ROOT / 's02_result').write_text(json.dumps(result, indent=2)+'\n')
    record('EPS extraction completed: six NLO curves in the three Q-squared panels. '
           'Exact source vertices and fitted log-axis maps saved in s02_result. '
           'The vector archive has provenance value; no disposable cache. '
           'Next combine these with the executed six-channel prediction and H1 data.')
    print(json.dumps({'status':result['status'], 'support':[
        {k:v['support_GeV'] for k,v in p['curves'].items()} for p in curves]}, indent=2))


if __name__ == '__main__':
    main()
