#!/usr/bin/env python3
"""Compile S05 common-subexpression output and compare to Wolfram values."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'python_deps'))
import argparse
import concurrent.futures
import ctypes as C
import hashlib
import json
import re
import subprocess
from datetime import datetime,timezone
import numpy as np


def record(message):
    with (ROOT.parent/'progress.md').open('a') as f:
        f.write('\nNumerics S07 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def cpp(expression):
    # Use extended-precision scalar literals with complex<long double> arithmetic.
    expression=re.sub(r'(?<![A-Za-z_\d])(?:\d+\.\d*|\.\d+|\d+)(?:[eE][+-]?\d+)?(?![A-Za-z_\d])',
        lambda m: m.group(0)+('L' if any(c in m.group(0) for c in '.eE') else '.0L'),expression)
    return expression


def compile_one(spec,cache):
    name=spec['Name'];dest=cache/('s07_'+name+'.cpp');obj=dest.with_suffix('.o')
    arc=cpp(spec['SpecialCForms']['ArcCoth'])
    code='''#include <complex>
#include <cmath>
#include <numbers>
#include <gsl/gsl_sf_dilog.h>
#include <gsl/gsl_errno.h>
using Z=std::complex<long double>;
static constexpr long double Pi=std::numbers::pi_v<long double>;
static constexpr long double EulerGamma=std::numbers::egamma_v<long double>;
static Z Complex(long double a,long double b){return Z(a,b);}
static Z Power(Z a,Z b){return std::pow(a,b);}
static Z Sqrt(Z a){return std::sqrt(a);}
static Z Log(Z a){return std::log(a);}
static Z Exp(Z a){return std::exp(a);}
static Z ArcTan(Z a){return std::atan(a);}
static Z ArcTanh(Z a){return std::atanh(a);}
static Z Re(Z a){return Z(a.real(),0);}
static Z Im(Z a){return Z(a.imag(),0);}
static Z Abs(Z a){return Z(std::abs(a),0);}
static Z Conjugate(Z a){return std::conj(a);}
static Z PolyLog(long double order,Z a){
 if(order!=2) return Z(NAN,NAN);
 gsl_sf_result re,im;
 gsl_sf_complex_dilog_xy_e((double)a.real(),(double)a.imag(),&re,&im);
 return Z(re.val,im.val);
}
'''
    code+='static Z ArcCoth(Z aa){return '+arc+';}\n'
    code+='static Z pax(Z a,Z direction){Z v=PolyLog(2,a); if(a.imag()==0 && a.real()>1) '
    code+='v=Z(v.real(),std::abs(v.imag())*('+str(spec['PaxPositiveDirectionImagSign'])+'.0L)*(direction.real()>0?1.0L:-1.0L)); return v;}\n'
    code+='extern "C" void '+name+'(const double *input,double *output){\n'
    for i,par in enumerate(spec['Arguments']):code+=f' const Z {par}=input[{i}];\n'
    for lhs,rhs in spec['Assignments']:code+=' const Z '+lhs+'='+cpp(rhs)+';\n'
    code+=' const Z answer='+cpp(spec['ReturnC'])+';\n output[0]=answer.real();output[1]=answer.imag();\n}\n'
    target_hash=hashlib.sha256(code.encode()).hexdigest()
    hashfile=dest.with_suffix('.sha256')
    if obj.exists() and hashfile.exists() and hashfile.read_text()==target_hash:
        return spec,obj
    dest.write_text(code)
    print('S07_COMPILE',name,flush=True)
    run=subprocess.run(['g++','-std=c++20','-O1','-fPIC','-c',str(dest),'-o',str(obj)],
                       text=True,capture_output=True,timeout=300)
    dest.with_suffix('.log').write_text(run.stdout+run.stderr)
    if run.returncode:raise RuntimeError(name+': '+run.stderr[:3500])
    hashfile.write_text(target_hash)
    return spec,obj


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--channels',nargs='+',default=['Hqq_v2','Hgg','Hqqbar','Hqqprime','Hgq_v3','Hqg_v3'])
    parser.add_argument('--workers',type=int,default=2)
    options=parser.parse_args()
    record('Requested native six-channel evaluator. Starting C++ compilation and '
           'direct-Wolfram sample comparisons for '+','.join(options.channels)+'. Next '
           'save the source-bound library only if every comparison passes.')
    cache=ROOT/'s07_cache';cache.mkdir(exist_ok=True)
    specs=[]
    for channel in options.channels:
        result=json.loads((ROOT/'s05_cache'/(channel+'_result')).read_text())
        assert result['Status']=='ExportComplete'
        specs.extend(result['Functions'])
    with concurrent.futures.ThreadPoolExecutor(max_workers=min(8,options.workers)) as pool:
        compiled=list(pool.map(lambda s:compile_one(s,cache),specs))
    suffix='all' if len(options.channels)==6 else '_'.join(options.channels)
    libpath=cache/('s07_'+suffix+'.so')
    link=subprocess.run(['g++','-shared',*[str(o) for _,o in compiled],'-lgsl','-lgslcblas','-o',str(libpath)],
                        capture_output=True,text=True,timeout=60)
    (cache/('s07_'+suffix+'_link.log')).write_text(link.stdout+link.stderr)
    assert link.returncode==0,link.stderr
    lib=C.CDLL(str(libpath))
    C.CDLL('libgsl.so.27').gsl_set_error_handler_off()
    arr=np.ctypeslib.ndpointer(dtype=np.float64,ndim=1,flags='C_CONTIGUOUS')
    checks=[]
    for spec,_ in compiled:
        function=getattr(lib,spec['Name']);function.argtypes=[arr,arr];function.restype=None
        for sample in spec['Checks']:
            args=np.array(sample['Arguments']);out=np.zeros(2);function(args,out)
            expected=np.array([sample['Real'],sample['Imaginary']])
            # The accepted tensor projection is real. Record the branch imaginary
            # diagnostic without reinterpreting it as an additional observable.
            difference=float(out[0]-expected[0])
            passed=bool(np.isfinite(out).all() and np.isclose(out[0],expected[0],rtol=2e-8,atol=1e-11))
            checks.append(dict(name=spec['Name'],arguments=args.tolist(),native=out.tolist(),
                               wolfram=expected.tolist(),real_difference=difference,passed=passed))
        print('S07_CHECKED',spec['Name'],flush=True)
    result=dict(stage='s07',status='Complete' if all(x['passed'] for x in checks) else 'ValidationFailed',
        producer_sha256=sha(Path(__file__)),channels=options.channels,
        library=str(libpath.relative_to(ROOT)),library_sha256=sha(libpath),
        functions=[{k:s[k] for k in ['Name','Channel','Label','Branch','Endpoint','ChargeCase','JacobianAlreadyIncluded','Arguments']}
                   for s in specs],checks=checks)
    outpath=ROOT/('s07_result' if len(options.channels)==6 else 's07_cache/s07_'+suffix+'_result')
    outpath.write_text(json.dumps(result,indent=2)+'\n')
    assert result['status']=='Complete',[x for x in checks if not x['passed']]
    record('Compilation and native-vs-Wolfram checks completed for '+','.join(options.channels)+
           '; all '+str(len(checks))+' real-projection comparisons passed. Results in '+
           str(outpath.relative_to(ROOT))+'. Source files, objects and checks retain production/provenance value. '
           'Next complete any remaining channels, then convolve the complete library.')
    print('S07_SUCCESS',suffix,len(checks),flush=True)


if __name__=='__main__':
    try:main()
    except Exception as exc:
        record('Stage failed: '+str(exc)[:500]+'. Next correct the originating export/build/evaluation issue before convolution.');raise
