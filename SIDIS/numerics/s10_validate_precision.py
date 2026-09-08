#!/usr/bin/env python3
"""Independent arbitrary-precision evaluation of exported hard-function tables."""
from pathlib import Path
import os
import sys
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'python_deps'))
import argparse,ctypes as C,hashlib,json,struct,time,pickle,importlib.util,re,subprocess
from datetime import datetime,timezone
import numpy as np
import mpmath as mp
import sympy as S

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def record(message):
    line = "SIDIS numerics S10 " + datetime.now(timezone.utc).isoformat() + ": " + message
    if os.environ.get("SIDIS_CLUSTER_RUN") == "1":
        print("PROGRESS " + line, flush=True)
        return
    with (Path(__file__).resolve().parents[2] / "progress.md").open("a") as stream:
        stream.write("\n" + line + "\n")

def reference(path,inputs,dps):
    program_hash=sha(path)
    argument_bytes=np.asarray(inputs,dtype='<f8').tobytes()
    key=hashlib.sha256(program_hash.encode()+argument_bytes+str(dps).encode()).hexdigest()
    destination=ROOT/'s10_cache'/('s10_reference_'+key+'.json')
    if destination.exists():
        saved=json.loads(destination.read_text())
        assert saved['program_sha256']==program_hash and saved['dps']==dps and saved['arguments']==list(inputs)
        return saved['values'],saved['small_denominators']
    trace=[];values=evaluate(path,inputs,dps,trace)
    destination.write_text(json.dumps(dict(program_sha256=program_hash,arguments=list(inputs),dps=dps,
        values=values,small_denominators=trace),indent=2)+'\n')
    return values,trace

class Jet:
    def __init__(self,c):self.c=c
def coeff(x):return x.c if isinstance(x,Jet) else [x,mp.mpf(0),mp.mpf(0)]
def real(x):return Jet([mp.re(v) for v in x.c]) if isinstance(x,Jet) else mp.re(x)

def evaluate(path,inputs,dps,trace=None):
    with mp.workdps(dps):
        binary=path.read_bytes();n,nconst,result,sign,nbytes=struct.unpack('<5i',binary[:20])
        constants=[]
        for text in binary[20:20+nbytes].decode().splitlines():
            constants.append({'Pi':mp.pi,'EulerGamma':mp.euler,'E':mp.e}.get(text, None) if text in ['Pi','EulerGamma','E'] else mp.mpf(text))
        ops=np.frombuffer(binary[20+nbytes:],dtype='<i4').reshape(n,3)
        v=[None]*n;inputs=[mp.mpf(x if isinstance(x,str) else float(x)) for x in inputs]
        for k,(op,ia,ib) in enumerate(ops):
            if op==0:r=constants[ia]
            elif op==1:r=inputs[ia]
            else:
                a=v[ia];b=v[ib] if ib>=0 else a
                if op in [2,3]:
                    if isinstance(a,Jet) or isinstance(b,Jet):
                        ac,bc=coeff(a),coeff(b);r=Jet([x+y if op==2 else x-y for x,y in zip(ac,bc)])
                    else:r=a+b if op==2 else a-b
                elif op==4:
                    if isinstance(a,Jet) or isinstance(b,Jet):
                        ac,bc=coeff(a),coeff(b);rc=[mp.mpf(0)]*3
                        for i in range(3):
                            for j in range(3):
                                term=ac[i]*bc[j]
                                if i+j<3:rc[i+j]+=term
                                else:assert term==0
                        r=Jet(rc)
                    else:r=a*b
                elif op==5:
                    assert not isinstance(b,Jet)
                    r=Jet([x/b for x in a.c]) if isinstance(a,Jet) else a/b
                elif op==7:r=Jet([-x for x in a.c]) if isinstance(a,Jet) else -a
                elif op==22:
                    ac,bc=coeff(a),coeff(b)
                    r=(mp.re(ac[0]),mp.re(bc[0]),max(abs(x) for x in ac[1:]+bc[1:]))
                elif op==6 and isinstance(a,Jet):
                    assert not isinstance(b,Jet) and b in [0,1,2]
                    if b==0:r=mp.mpf(1)
                    elif b==1:r=a
                    else:r=Jet([a.c[0]**2,2*a.c[0]*a.c[1],a.c[1]**2+2*a.c[0]*a.c[2]])
                else:
                    assert not isinstance(a,Jet) and not isinstance(b,Jet),(op,k)
                    if op==6:r=mp.power(a,b)
                    elif op==8:r=mp.log(a) if a!=0 else Jet([mp.mpf(0),mp.mpf(1),mp.mpf(0)])
                    elif op==9:r=mp.sqrt(a)
                    elif op==10:assert a==2;r=mp.polylog(a,b)
                    elif op==11:
                        r=mp.polylog(2,a)
                        if mp.im(a)==0 and mp.re(a)>1:r=mp.mpc(mp.re(r),abs(mp.im(r))*sign*(1 if mp.re(b)>0 else -1))
                    elif op==12:r=mp.re(a)
                    elif op==13:r=mp.im(a)
                    elif op==14:r=abs(a)
                    elif op==15:r=mp.conj(a)
                    elif op==16:r=mp.atan(a)
                    elif op==17:r=mp.atanh(a)
                    elif op==18:r=mp.acoth(a)
                    elif op==19:r=mp.exp(a)
                    elif op==20:r=mp.mpc(mp.re(a),mp.re(b))
                    elif op==21:r=mp.atan2(mp.re(b),mp.re(a))
                    else:raise ValueError(op)
            v[k]=r
            if trace is not None and op in [5,6]:
                denominator=b if op==5 else a
                if not isinstance(denominator,Jet) and not isinstance(b,Jet) and (op==5 or (mp.im(b)==0 and mp.re(b)<0)) and 0<abs(denominator)<mp.mpf('1e-9'):
                    trace.append(dict(node=int(k),op=int(op),denominator_node=int(ib if op==5 else ia),value=mp.nstr(denominator,30),power=mp.nstr(b,12) if op==6 else '-1'))
        output=v[result]
        if not isinstance(output,tuple):
            c=coeff(output);output=(mp.re(c[0]),mp.im(c[0]),max(abs(x) for x in c[1:]))
        return [mp.nstr(x,dps) for x in output]


def scan_pilot():
    record('Starting a scan of the pilot-adapted grids to locate the numerical fluctuations. Failed pilot estimates are diagnostic only. Next compare the dominant coefficient samples at arbitrary precision.')
    spec=importlib.util.spec_from_file_location('sidis_s09',ROOT/'s09_convolve_channels.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    all_rows=[];rng=np.random.default_rng(171734)
    for bin_spec in [b for b in module.bins() if b['id'] in ['q0_p0','q1_p0','q2_p0']]:
        path=ROOT/'s09_cache'/(bin_spec['id']+'_vegas.pkl')
        with path.open('rb') as f:estimate,integrator=pickle.load(f)
        uniforms=rng.uniform(1e-6,1-1e-6,(32,6));mapped=np.empty_like(uniforms);jac=np.empty(len(uniforms))
        integrator.map.map(uniforms,mapped,jac)
        evaluator=module.Evaluator(bin_spec['bounds'])
        for i,unit in enumerate(mapped):
            out,diag=evaluator.evaluate(unit)
            row=dict(bin=bin_spec['id'],bounds=bin_spec['bounds'],unit=unit.tolist(),diagnostics=diag.tolist(),components=out.tolist(),sampling_jacobian=float(jac[i]))
            all_rows.append(row)
            if i%8==0:print('S10_SCAN',bin_spec['id'],i,float(np.max(np.abs(out))),diag.tolist(),flush=True)
    all_rows.sort(key=lambda row:np.max(np.abs(row['components'])),reverse=True)
    path=ROOT/'s10_cache/s10_pilot_scan';path.parent.mkdir(exist_ok=True);path.write_text(json.dumps(all_rows,indent=2)+'\n')
    print('S10_SCAN_MAX',json.dumps(all_rows[:3],indent=2),flush=True)
    record('Pilot-grid scan completed; all sampled coordinates and signed components saved in s10_cache/s10_pilot_scan. Next inspect the dominant points and endpoint dependence.')

def consumer_contract():
    record('Starting the Hqq_v2 measure contract: inspect the source-bound S04 measures and differentiate its own soft/Born coefficient ratio with respect to the hadronic variables. Next resolve the legacy Jacobian claim without changing any supplied coefficient.')
    cache=ROOT/'s10_cache';cache.mkdir(exist_ok=True)
    maps=json.loads((ROOT/'s04_result').read_text())
    from sympy.printing.mathematica import mathematica_code
    J=S.sympify(maps['expressions']['jacobian'])
    Jwl=mathematica_code(J.subs(S.Symbol('pt')**2,S.Symbol('PHT2')))
    path=cache/'s10_check_hqq_measures.wl';out=cache/'s10_hqq_measures_result'
    code='''$HistoryLength=0;$LoadAddOns={};$FeynCalcStartupMessages=False;Get["FeynCalc`"];
d=Get[INPUT];
require[x_,m_]:=If[!TrueQ[x],Print["S10_FATAL ",m];Quit[1]];
require[And@@Values[d["Checks"]],"accepted S04 checks"];
j=d["VariableMap","Dzetads23"]/.{xHat->xB/xi,z->zH};
measures=<|"BornInvariant"->(d["PhaseSpace","TwoBody","InvariantMeasure"]/.DiracDelta[_]->1),
"RealAngular"->d["PhaseSpace","ThreeBody","HardPartTimesAngularPrefactor"]|>;
checks=<|"JacobianAgreesWithNumericsS04"->(Cancel[Together[j-(JACOBIAN)]]===0),
"PartonicMeasuresIndependentOfHadronicVariables"->FreeQ[measures,z|zH|PHT2|xi|xB|zeta],
"FragmentationJacobianDependsOnHadronicVariables"->(!TrueQ[Cancel[Together[D[j,zH]]]===0])|>;
Print["S10_MEASURE_CHECKS ",checks];require[And@@Values[checks],"measure contract"];
Export[OUTPUT,<|"Checks"->checks,"Measures"->Map[ToString[#,InputForm]&,measures],
"FragmentationJacobian"->ToString[j,InputForm],"InputSHA256"->FileHash[INPUT,"SHA256","HexString"]|>,"RawJSON"];
Print["S10_MEASURE_CONTRACT ",checks];Quit[];
'''.replace('INPUT',json.dumps(str(ROOT.parent/'Hqq_v2/s04_result.wl'))).replace('OUTPUT',json.dumps(str(out))).replace('JACOBIAN',Jwl)
    path.write_text(code)
    run=subprocess.run([os.environ.get('WOLFRAM_KERNEL','/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel'),'-noinit','-noprompt','-script',str(path)],capture_output=True,text=True,timeout=60)
    (cache/'s10_hqq_measures.log').write_text(run.stdout+run.stderr)
    assert run.returncode==0 and out.exists(),run.stdout+run.stderr
    measured=json.loads(out.read_text());assert all(measured['Checks'].values())
    def expression(label):
        source=ROOT/'s05_cache'/('Hqq_v2_F1Hat_'+label+'_1.json')
        spec=json.loads(source.read_text());assert spec['CFormExactRationals']
        names={'Power':S.Pow,'Log':S.log,'Pi':S.pi,'rational':lambda a,b:a/b,'aS':S.Symbol('aS')}
        def parse(text):return S.sympify(re.sub(r'\bas\b','aS',text),locals=names,rational=True)
        for lhs,rhs in spec['Assignments']:names[lhs]=parse(rhs)
        return parse(spec['ReturnC']),source
    born,born_path=expression('LODelta');soft,soft_path=expression('L1')
    ratio=S.factor(S.cancel(soft/born));hadronic=S.symbols('zH PHT2 xi xB')
    bare_independent=all(S.simplify(S.diff(ratio,v))==0 for v in hadronic)
    jacobian_included=all(S.simplify(S.diff(ratio/J,v))==0 for v in hadronic)
    checks=dict(measured['Checks'],SoftBornRatioIndependentOfHadronicVariables=bare_independent,
                JacobianAlreadyIncludedClaimFails=not jacobian_included)
    assert all(checks.values())
    sources=[ROOT.parent/'Hqq'/s for s in ['s04_integrate_hqq_phase_space.wl','s05_expand_hqq_endpoints.wl',
        's06_evaluate_hqq_virtual.wl','s07_factorize_hqq_msbar.wl','s07_combine_hqq_from_cache.wl','s08_extract_hqq_fhats.wl']]
    result=dict(stage='s10_consumer_contract',status='Complete',producer_sha256=sha(Path(__file__)),
        channel='Hqq',jacobian_already_included=jacobian_included,checks=checks,
        source_trace={str(p.relative_to(ROOT.parent)):sha(p) for p in sources+[born_path,soft_path,path]},
        measure_result_sha256=sha(out),soft_over_born=S.sstr(ratio),
        consumer='Apply numerics S04 d(zeta)/d(s23) once to every Hqq_v2 perturbative/distribution component.',
        conflict='The older Hqq_v2/bigTMD_check README claims the local fragmentation Jacobian is included. The source-bound partonic measure and current-channel soft/Born checks contradict that claim. Its comparison convention must not be used to omit the Jacobian here.')
    (cache/'s10_consumer_contract_result').write_text(json.dumps(result,indent=2)+'\n')
    record('Hqq_v2 measure and soft/Born contract passed; s10_cache/s10_consumer_contract_result requires one external fragmentation Jacobian for Hqq_v2. This supersedes the older benchmark ledger claim for this consumer. Next correct S05 metadata at origin, retain expression identities, and regenerate S07/S09.')
    print(json.dumps(result,indent=2))

def invariant_contract():
    record('Starting an inverse kinematic map from the accepted S04 defining relations. Next gate s,t,B reconstruction and provide exact Wolfram substitution rules for stable coefficient preparation.')
    maps=json.loads((ROOT/'s04_result').read_text())
    from sympy.printing.mathematica import mathematica_code
    Q2,xi,xB,xh,zH,pt,PHT2,s23,sh,th,BB=S.symbols('Q2 xi xB xh zH pt PHT2 s23 sh th BB')
    def get(name):return S.factor(S.sympify(maps['expressions'][name]).subs({xB:xi*xh,pt**2:PHT2}))
    xr=S.solve(S.Eq(get('s'),sh),xh);assert len(xr)==1
    solutions=S.solve([S.together(get('t').subs(xh,xr[0])-th),S.together(get('B').subs(xh,xr[0])-BB)],[zH,PHT2],dict=True)
    assert len(solutions)==1
    rules=dict(solutions[0]);rules[xh]=xr[0]
    checks={name:S.factor(get(name).subs(rules,simultaneous=True)-target)==0 for name,target in [('s',sh),('t',th),('B',BB)]}
    assert all(checks.values())
    canonical={sh:S.Symbol('s'),th:S.Symbol('t'),BB:S.Symbol('B'),s23:S.Symbol('ss')}
    values={str(k):S.factor(v.subs(canonical)) for k,v in rules.items()}
    transformed={k:S.factor(get(k).subs(rules,simultaneous=True).subs(canonical)) for k in ['zeta','jacobian']}
    sample_path=ROOT/'references/s01_validation_coordinates.json'
    samples=[r for r in json.loads(sample_path.read_text())['points'] if r['diagnostics'][0]>0]
    assert samples, 'No physical validation coordinates'
    benchmark_rows=[]
    for sample in samples:
        diag=sample['diagnostics']
        base={S.Symbol(k):S.Rational(str(v)) for k,v in dict(Q2=diag[4],y=diag[5],pt=diag[6],zH=diag[7],xi=diag[1],
            Ee=maps['defining_physics_inputs']['Ee_GeV'],Ep=maps['defining_physics_inputs']['Ep_GeV']).items()}
        base[xB]=S.factor(S.sympify(maps['expressions']['xB']).subs(base))
        bv=S.factor(S.sympify(maps['expressions']['B']).subs(base));assert bv>0
        for endpoint in [True,False]:
            sub=dict(base);sub[s23]=S.Integer(0) if endpoint else S.Rational(str(sample['unit'][5]))*bv
            row={k:sub[S.Symbol(k)] for k in ['Q2','xi','xB','zH']}
            row.update({k:S.factor(S.sympify(maps['expressions'][k]).subs(sub)) for k in ['s','t','u','xHat','mu2']})
            row.update(s23=sub[s23],B=bv,PHT2=base[pt]**2)
            benchmark_rows.append(dict(endpoint=endpoint,branch=int(S.sign(row['s']+row['t'])),
                exact={k:str(v) for k,v in row.items()},numeric={k:float(v) for k,v in row.items()}))
    result=dict(stage='s10_invariant_contract',status='Complete',producer_sha256=sha(Path(__file__)),
        input_sha256=sha(ROOT/'s04_result'),checks=checks,
        expressions={k:str(v) for k,v in values.items()},wolfram={k:mathematica_code(v) for k,v in values.items()},
        transformed_maps={k:str(v) for k,v in transformed.items()},
        benchmark_rows=benchmark_rows,
        policy='Exact relations on the S04 physical manifold; Wolfram must compare each transformed coefficient with the original expression at physical benchmark points.')
    path=ROOT/'s10_cache/s10_invariant_contract_result';path.parent.mkdir(exist_ok=True);path.write_text(json.dumps(result,indent=2)+'\n')
    record('Inverse invariant map completed with every reconstruction check passing; exact rules saved in s10_cache/s10_invariant_contract_result. Next consume them in S05 and require direct original-versus-transformed comparisons.')
    print(json.dumps(result,indent=2))

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--dps',nargs='+',type=int,default=[100,140]);parser.add_argument('--scan-pilot',action='store_true');parser.add_argument('--use-pilot',action='store_true');parser.add_argument('--consumer-contract',action='store_true');parser.add_argument('--invariant-contract',action='store_true');parser.add_argument('--channels',nargs='+',default=['Hqq','Hgg','Hqqbar','Hqqprime','Hgq','Hqg']);parser.add_argument('--kernels-result',default='s07_result');parser.add_argument('--sample-source');options=parser.parse_args()
    if options.scan_pilot:scan_pilot();return
    if options.consumer_contract:consumer_contract();return
    if options.invariant_contract:invariant_contract();return
    record('Pilot fluctuations require an independent precision check. Starting arbitrary-precision evaluation of the unchanged native operation tables at actual accepted H1 phase-space samples. Next compare precision levels and native arithmetic before accepting integration.')
    kernel_path=ROOT/options.kernels_result
    kernels=json.loads(kernel_path.read_text());maps=json.loads((ROOT/'s04_result').read_text())
    assert kernels['status']=='Complete' and kernels['library_sha256']==sha(ROOT/kernels['library'])
    actions=json.loads((ROOT/'s08_result').read_text());inputs=json.loads((ROOT/'s06_result').read_text())
    native=C.CDLL(str(ROOT/kernels['library']));native.sidis_load_program.argtypes=[C.c_char_p];native.sidis_load_program.restype=C.c_int
    callback_spec=importlib.util.spec_from_file_location('sidis_s07',ROOT/'s07_compile_hard_functions.py')
    callback_module=importlib.util.module_from_spec(callback_spec);callback_spec.loader.exec_module(callback_module)
    callback=callback_module.install_dilog(native)
    arr=np.ctypeslib.ndpointer(dtype=np.float64,ndim=1,flags='C_CONTIGUOUS')
    native.sidis_eval.argtypes=[C.c_int,arr,arr];native.sidis_eval.restype=C.c_int
    pdf=C.CDLL(str(ROOT/inputs['library']));pdf.sidis_alpha.argtypes=[C.c_double];pdf.sidis_alpha.restype=C.c_double
    pdf.sidis_set_alpha.argtypes=[C.c_double]*3;a=inputs['alpha'];pdf.sidis_set_alpha(a['mc2_GeV2'],a['mb2_GeV2'],a['lambda4_squared_GeV2'])
    sample_path=ROOT/(options.sample_source or ('s10_cache/s10_pilot_scan' if options.use_pilot else 's09_cache/s09_smoke_result'))
    sample_data=json.loads(sample_path.read_text())
    rows=sample_data[:2] if isinstance(sample_data,list) else sample_data['points']
    checks=[]
    for row_index,row in enumerate(rows):
        if row['diagnostics'][0]<=0:continue
        _,xi,zeta0,zeta,Q2,y,pt,zH,ss,B=row['diagnostics']
        for channel,label in [(c,l) for c in options.channels for l in sorted({b['Label'] for b in kernels['bundles'] if b['Channel']==c and (b['Label'] in ['Delta','Regular','L0'] or b['Label'].endswith('_Regular'))})]:
            sub=dict(Q2=Q2,y=y,pt=pt,zH=zH,xi=xi,s23=0 if label=='Delta' else ss,
                     Ee=float(maps['defining_physics_inputs']['Ee_GeV']),Ep=float(maps['defining_physics_inputs']['Ep_GeV']))
            sub['xB']=float(S.sympify(maps['expressions']['xB']).subs(sub))
            values={k:float(S.sympify(maps['expressions'][k]).subs(sub)) for k in ['s','t','mu2','xHat']}
            nf=4 if values['mu2']<a['mb2_GeV2'] else 5;group=actions['luminosities'][str(nf)]['hqq_charge_groups'][0]
            branch=1 if values['s']+values['t']>0 else -1
            bundle=next(b for b in kernels['bundles'] if b['Channel']==channel and b['Label']==label and b['Branch']==branch)
            active=actions['luminosities'][str(nf)]['active_species']
            model={k:S.sympify(v) for k,v in actions['model_charges'].items()}
            if channel=='Hqq':
                coupling_arguments=[S.sympify(group['charge']),S.sympify(group['other_moment1']),S.sympify(group['other_moment2']),S.Integer(0)]
            else:
                coupling_arguments=[model[active[0]],model[active[1]],S.Integer(0),S.Integer(0)]
            charge_sum=sum(model[name]**2 for name in active)
            arguments=np.array([Q2,values['s'],values['t'],sub['s23'],B,values['mu2'],values['xHat'],zH,pt**2,sub['xB'],xi,
                pdf.sidis_alpha(values['mu2']),*map(float,coupling_arguments),nf,float(charge_sum),abs(values['s']+values['t'])],dtype=float)
            path=ROOT/bundle['Program'];assert sha(path)==bundle['ProgramSHA256']
            index=native.sidis_load_program(str(path).encode());out=np.empty(3);status=native.sidis_eval(index,arguments,out)
            result=dict(row=row_index,bundle=bundle['Name'],arguments=arguments.tolist(),program_sha256=sha(path),native_status=status,native=out.tolist(),arbitrary_precision={})
            for dps in options.dps:
                start=time.monotonic();precise,trace=reference(path,arguments,dps)
                result['arbitrary_precision'][str(dps)]=precise
                if options.use_pilot:result['small_denominators']=trace
                print('S10_PRECISION',row_index,channel,label,dps,'native',out.tolist(),'output',precise,'seconds',time.monotonic()-start,flush=True)
            reference_values=np.array([float(x) for x in result['arbitrary_precision'][str(max(options.dps))][:2]])
            result['native_relative_difference']=(np.abs(out[:2]-reference_values)/np.maximum(np.abs(reference_values),1e-100)).tolist()
            result['passed']=bool(status==0 and np.allclose(out[:2],reference_values,rtol=2e-8,atol=1e-11) and
                all(np.allclose([float(x) for x in values[:2]],reference_values,rtol=2e-8,atol=1e-11)
                    and abs(float(values[2]))<1e-40 for values in result['arbitrary_precision'].values()))
            checks.append(result)
            (ROOT/'s10_cache').mkdir(exist_ok=True)
            (ROOT/'s10_cache/s10_precision_samples').write_text(json.dumps(checks,indent=2)+'\n')
    result=dict(stage='s10',status='Complete' if checks and all(c['passed'] for c in checks) else 'ValidationFailed',
        producer_sha256=sha(Path(__file__)),s07_result_sha256=sha(kernel_path),kernel_receipt=options.kernels_result,sample_source=str(sample_path.relative_to(ROOT)),sample_source_sha256=sha(sample_path),checks=checks)
    targets=([ROOT/'s10_result']+([ROOT/'s10_cache/s10_pilot_precision_result'] if options.use_pilot else [])) if options.kernels_result=='s07_result' else [ROOT/'s10_cache'/('s10_'+kernel_path.name+'_precision_result')]
    for target in targets:
        if target.exists():
            archive=ROOT/'s10_cache'/('s10_previous_'+sha(target));
            if not archive.exists():archive.write_bytes(target.read_bytes())
        target.write_text(json.dumps(result,indent=2)+'\n')
    assert result['status']=='Complete',[c for c in checks if not c['passed']]
    record('Independent H1 sample precision/native comparisons for '+','.join(options.channels)+' completed with every gate passing in '+','.join(str(p.relative_to(ROOT)) for p in targets)+'. Next require the full six-channel kernel receipt before convolution.')

if __name__=='__main__':
    try:main()
    except Exception as exc:record('Precision validation failed: '+repr(exc)+'. Next correct this validation stage before using its output.');raise
