#!/usr/bin/env python3
"""Aggregate accepted replacement bins, including any full-bin fallbacks."""
from pathlib import Path
import sys, json, hashlib, importlib.util
from datetime import datetime, timezone
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'python_deps'))
import numpy as np


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def record(message):
    with (ROOT.parent/'progress.md').open('a') as f:
        f.write('\nNumerics S11 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')


def main():
    record('Starting final replacement aggregation from accepted bin receipts. Next verify all identities, numerical gates and experimental-bin coverage before writing the hadronic total.')
    spec=importlib.util.spec_from_file_location('sidis_s09',ROOT/'s09_convolve_channels.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    cache=ROOT/'s09_cache'
    build_path=cache/'s09_build_result'
    build=json.loads(build_path.read_text())
    preserved_path=cache/'s09_preserved_bins_receipt'
    preserved=json.loads(preserved_path.read_text())
    reuse_path=cache/'s09_reuse_result'
    reuse=json.loads(reuse_path.read_text())
    assert build['producer_sha256']==sha(ROOT/'s09_convolve_channels.py')
    assert preserved['build_sha256']==reuse['build_sha256']==sha(build_path)
    assert reuse['status']=='Complete' and all(reuse['checks'].values())
    for name,value in build['input_hashes'].items():assert sha(ROOT/name)==value,name
    results=[];input_hashes={}
    for expected in module.bins():
        path=cache/(expected['id']+'_result')
        row=json.loads(path.read_text());input_hashes[str(path.relative_to(ROOT))]=sha(path)
        assert row['status']=='Complete' and all(row['checks'].values()),expected['id']
        assert row['build_sha256']==sha(build_path)
        assert all(row[k]==value for k,value in expected.items())
        if expected['id'] in preserved['full_bins']:
            assert row['reuse_sha256'] is None and row['integrated_channels']==build['channels']
        else:
            assert sha(path)==preserved['accepted_bin_sha256'][path.name]
            assert row['reuse_sha256']==sha(reuse_path) and row['integrated_channels']==['Hgq_v4']
        means=np.asarray(row['full_mean']);cov=np.asarray(row['full_covariance'])
        components=means[3:].reshape(len(build['FFs']),len(build['channels']),-1)
        np.testing.assert_allclose(components.sum(axis=(1,2)),row['sigma_pb'],rtol=1e-10,atol=1e-10)
        np.testing.assert_allclose(np.sqrt(np.diag(cov)[1:3]),row['sigma_error_pb'],rtol=1e-12,atol=1e-12)
        np.testing.assert_allclose(components,row['component_sigma_pb'],rtol=1e-12,atol=1e-12)
        assert np.all(np.isfinite(means)) and np.all(np.isfinite(cov))
        results.append(row)
    assert len({row['seed'] for row in results})==len(results)
    result=dict(build,status='Complete',bins=results,reuse_sha256=sha(reuse_path),
        full_bin_fallbacks=preserved['full_bins'],
        neval=sorted({row['initial_neval'] for row in results}),nitn=sorted({row['nitn'] for row in results}),
        aggregation_producer_sha256=sha(Path(__file__)),bin_result_hashes=input_hashes,
        total_sigma_pb=np.sum([row['sigma_pb'] for row in results],axis=0).tolist(),
        total_sigma_error_pb=np.sqrt(np.sum(np.square([row['sigma_error_pb'] for row in results]),axis=0)).tolist())
    result['panel_integrals']=[dict(panel=panel,
        sigma_pb=np.sum([row['sigma_pb'] for row in results if row['panel']==panel],axis=0).tolist(),
        sigma_error_pb=np.sqrt(np.sum(np.square([row['sigma_error_pb'] for row in results if row['panel']==panel]),axis=0)).tolist())
        for panel in sorted({row['panel'] for row in results})]
    result['numerical_zero_policy']='Cut rejection and absent perturbative sectors return zero; native coefficient failures raise. In replacement runs masked channels are omitted from the partial estimate and restored only through the accepted covariance-preserving composition.'
    module.write_json(ROOT/'s09_result',result)
    receipt=dict(stage='s11',status='Complete',producer_sha256=sha(Path(__file__)),
        inputs={**input_hashes,**{str(p.relative_to(ROOT)):sha(p) for p in [build_path,preserved_path,reuse_path]}},
        checks=dict(complete_bin_coverage=True,preserved_bin_identity=True,full_bin_fallbacks=True,
                    convergence_gates=True,component_sums=True,covariance_errors=True,distinct_bin_seeds=True),
        output='s09_result',output_sha256=sha(ROOT/'s09_result'),
        FFs=build['FFs'],total_sigma_pb=result['total_sigma_pb'],total_sigma_error_pb=result['total_sigma_error_pb'])
    module.write_json(ROOT/'s11_result',receipt)
    record('All '+str(len(results))+' bins accepted and aggregated with preserved identities and full numerical checks. Current hadronic cross section saved in s09_result and bound by s11_result. Next regenerate and visually inspect both requested figure sets.')
    print(json.dumps(receipt,indent=2),flush=True)


if __name__=='__main__':
    try:main()
    except Exception as exc:
        record('Aggregation failed: '+repr(exc)+'. Next correct the originating issue before publishing the total or plots.')
        raise
