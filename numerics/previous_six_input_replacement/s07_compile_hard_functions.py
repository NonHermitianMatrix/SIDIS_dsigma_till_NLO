#!/usr/bin/env python3
"""Translate Wolfram CSE expressions into a native checked operation table."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'python_deps'))
import argparse,ctypes as C,hashlib,json,re,struct,subprocess,functools,time
from datetime import datetime,timezone
import numpy as np
import mpmath as mp
import sympy as S

def record(message):
    with (ROOT.parent/'progress.md').open('a') as f:
        f.write('\nNumerics S07 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
OPS={'constant':0,'input':1,'+':2,'-':3,'*':4,'/':5,'Power':6,'negative':7,
     'Log':8,'Sqrt':9,'PolyLog':10,'pax':11,'Re':12,'Im':13,'Abs':14,
     'Conjugate':15,'ArcTan':16,'ArcTanh':17,'ArcCoth':18,'Exp':19,'Complex':20,'ArcTan2':21,'pack':22}
TOKEN=re.compile(r'\s*(?:((?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?)|([A-Za-z_$][A-Za-z_\d$]*)|(.))')

class Program:
    math_definitions={}
    canonical_inputs={}
    def initial_inputs(self,spec):
        self.names={k:self.add('input',i) for i,k in enumerate(spec['Arguments'])}
        for name,expression in self.canonical_inputs.items():self.names[name]=self.expression(expression)
    def __init__(self,spec):
        self.spec=spec;self.ops=[];self.memo={};self.constants=[];self.constants_index={}
        self.initial_inputs(spec)
        for lhs,rhs in spec['Assignments']:self.names[lhs]=self.expression(rhs)
        self.result=self.expression(spec['ReturnC'])
    def append_hat(self,spec):
        first=self.result
        self.initial_inputs(spec)
        for lhs,rhs in spec['Assignments']:self.names[lhs]=self.expression(rhs)
        second=self.expression(spec['ReturnC'])
        self.result=self.add('pack',first,second)
    def add(self,op,a=-1,b=-1):
        key=(OPS[op],a,b)
        if key not in self.memo:self.memo[key]=len(self.ops);self.ops.append(key)
        return self.memo[key]
    def const(self,value):
        if value not in self.constants_index:
            self.constants_index[value]=len(self.constants);self.constants.append(value)
        return self.add('constant',self.constants_index[value])
    def expression(self,source):
        self.tokens=[next(x for x in m.groups() if x is not None) for m in TOKEN.finditer(source)];self.pos=0
        def atom():
            t=self.tokens[self.pos];self.pos+=1
            if t in ['+','-']:
                v=atom();return self.add('negative',v) if t=='-' else v
            if t=='(':
                v=expr(0);assert self.tokens[self.pos]==')';self.pos+=1;return v
            if re.fullmatch(r'(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?',t):return self.const(t)
            if self.pos<len(self.tokens) and self.tokens[self.pos]=='(':
                self.pos+=1;args=[expr(0)]
                while self.tokens[self.pos]==',':self.pos+=1;args.append(expr(0))
                assert self.tokens[self.pos]==')';self.pos+=1
                if t=='rational':
                    assert len(args)==2
                    return self.add('/',*args)
                if t=='ArcTan' and len(args)==2:t='ArcTan2'
                assert t in OPS and len(args) in [1,2],(t,args)
                if t in self.math_definitions and len(args)==1:
                    saved=self.tokens,self.pos,self.names.get('x')
                    self.names['x']=args[0];result=self.expression(self.math_definitions[t])
                    self.tokens,self.pos,old_x=saved
                    if old_x is None:self.names.pop('x')
                    else:self.names['x']=old_x
                    return result
                return self.add(t,*args)
            if t in ['Pi','EulerGamma','E']:return self.const(t)
            assert t in self.names,(t,source[:150]);return self.names[t]
        precedence={'+':1,'-':1,'*':2,'/':2}
        def expr(minimum):
            left=atom()
            while self.pos<len(self.tokens) and self.tokens[self.pos] in precedence and precedence[self.tokens[self.pos]]>=minimum:
                op=self.tokens[self.pos];self.pos+=1;right=expr(precedence[op]+1);left=self.add(op,left,right)
            return left
        result=expr(0);assert self.pos==len(self.tokens),(self.pos,len(self.tokens),source[:100]);return result
    def write(self,path):
        constants=('\n'.join(self.constants)+'\n').encode()
        path.write_bytes(struct.pack('<5i',len(self.ops),len(self.constants),self.result,
                         self.spec['PaxPositiveDirectionImagSign'],len(constants))+
                         constants+np.asarray(self.ops,dtype='<i4').tobytes())

DILOG_CALLBACK=C.CFUNCTYPE(C.c_int,C.c_char_p,C.c_char_p,C.c_void_p,C.c_void_p,C.c_size_t)
def install_dilog(lib):
    """Keep the returned callback alive as long as the native library is evaluated."""
    @functools.lru_cache(maxsize=2048)
    def compute(re,im):
        with mp.workdps(115):
            value=mp.polylog(2,mp.mpc(re.decode(),im.decode()))
            return tuple(mp.nstr(v,108).encode() for v in [mp.re(value),mp.im(value)])
    @DILOG_CALLBACK
    def callback(re,im,outre,outim,capacity):
        try:
            real,imag=compute(re,im)
            if max(len(real),len(imag))+1>capacity:return 1
            C.memmove(outre,real+b'\0',len(real)+1);C.memmove(outim,imag+b'\0',len(imag)+1)
            return 0
        except Exception:return 2
    lib.sidis_set_dilog.argtypes=[DILOG_CALLBACK];lib.sidis_set_dilog.restype=None
    lib.sidis_set_dilog(callback)
    return callback

NATIVE=r'''
#include <boost/multiprecision/cpp_complex.hpp>
#include <cmath>
#include <vector>
#include <array>
#include <string>
#include <sstream>
#include <fstream>
#include <algorithm>
#include <stdexcept>
#include <limits>
#include <cstdint>
using Z=boost::multiprecision::cpp_complex_100;
using R=boost::multiprecision::cpp_bin_float_100;
struct Op {int op,a,b;};
struct V {Z value;int jet;V(Z x=0,int j=-1):value(x),jet(j){} };
struct Program {
 std::vector<Op> ops;std::vector<Z> constants;std::vector<V> values;std::vector<uint32_t> dependencies;
 std::array<double,19> previous{};bool valid=false;int result,sign;
};
static std::vector<Program> programs;
using DilogCallback=int(*)(const char*,const char*,char*,char*,size_t);
static DilogCallback dilog_callback=nullptr;
extern "C" void sidis_set_dilog(DilogCallback f){dilog_callback=f;}
static thread_local std::vector<std::array<Z,2>> jets;
static Z principal(const Z&x){return x.imag()==0?Z(x.real(),R(0)):x;}
static Z product(const Z&x,const Z&y){return x.imag()==0&&y.imag()==0?Z(R(x.real()*y.real())):Z(x*y);}
static Z quotient(const Z&x,const Z&y){return x.imag()==0&&y.imag()==0?Z(R(x.real()/y.real())):Z(x/y);}
static Z coeff(const V&v,int degree){return degree==0?v.value:(v.jet<0?Z(0):jets[v.jet][degree-1]);}
static V with_jet(Z x,Z c1,Z c2){
 if(c1==0&&c2==0)return V(x);
 int index=jets.size();jets.push_back({c1,c2});return V(x,index);
}
static V multiply(const V&a,const V&b){
 if(a.jet<0&&b.jet<0)return V(product(a.value,b.value));
 Z c[3]={0,0,0};
 for(int i=0;i<3;i++)for(int j=0;j<3;j++){
  Z term=coeff(a,i)*coeff(b,j);
  if(i+j<3)c[i+j]+=term;else if(term!=0)throw std::runtime_error("singular-log degree");
 }return with_jet(c[0],c[1],c[2]);
}
static Z ipow(Z x,int n){
 if(x.imag()==0)return Z(R(pow(x.real(),n)));
 if(n<0)return Z(1)/ipow(x,-n);
 Z value=1;while(n){if(n&1)value*=x;n>>=1;if(n)x*=x;}return value;
}
static Z dilog(const Z&a){
 if(!dilog_callback)throw std::runtime_error("missing arbitrary-precision dilogarithm callback");
 std::string re=a.real().str(108,std::ios_base::scientific),im=a.imag().str(108,std::ios_base::scientific);
 char outr[256],outi[256];
 if(dilog_callback(re.c_str(),im.c_str(),outr,outi,sizeof(outr)))throw std::runtime_error("dilog callback");
 return Z(R(outr),R(outi));
}
extern "C" int sidis_load_program(const char*path){
 try{
  std::ifstream in(path,std::ios::binary);int h[5];in.read((char*)h,sizeof(h));
  if(!in||h[0]<1||h[0]>2000000||h[1]<1||h[4]<1||h[4]>10000000)return -1;
  Program p;p.result=h[2];p.sign=h[3];std::string text(h[4],'\0');in.read(text.data(),h[4]);
  std::istringstream stream(text);std::string s;
  for(int i=0;i<h[1];i++){
   std::getline(stream,s);
   if(s=="Pi")s="@@PI@@";
   else if(s=="EulerGamma")s="@@EULER@@";
   else if(s=="E")s="@@E@@";
   p.constants.emplace_back(R(s));
  }
  p.ops.resize(h[0]);in.read((char*)p.ops.data(),sizeof(Op)*h[0]);if(!in)return -1;
  for(size_t n=0;n<p.ops.size();n++){
   const auto&o=p.ops[n];uint32_t mask=0;
   if(o.op==1){if(o.a<0||o.a>=19)return -1;mask=uint32_t(1)<<o.a;}
   else if(o.op!=0){if(o.a<0||o.a>=int(n)||o.b>=int(n))return -1;mask=p.dependencies[o.a];if(o.b>=0)mask|=p.dependencies[o.b];}
   p.dependencies.push_back(mask);
  }
  programs.push_back(std::move(p));return programs.size()-1;
 }catch(...){return -1;}
}
extern "C" int sidis_eval(int id,const double*input,double*output){
 try{
  auto&p=programs.at(id);auto&v=p.values;v.resize(p.ops.size());jets.clear();
  uint32_t changed=0;for(size_t j=0;j<p.previous.size();j++)if(input[j]!=p.previous[j])changed|=uint32_t(1)<<j;
  bool reusable=p.valid;p.valid=false;
  for(size_t n=0;n<p.ops.size();n++){
   if(reusable && !(p.dependencies[n]&changed))continue;
   const Op&o=p.ops[n];V r;
   if(o.op==0)r=V(p.constants[o.a]);
   else if(o.op==1)r=V(Z(R(input[o.a])));
   else{
    const V&a=v[o.a];const V&b=o.b>=0?v[o.b]:a;
    const Z&x=a.value;const Z&y=b.value;
    if(o.op==2||o.op==3){
     if(a.jet<0&&b.jet<0)r=V(o.op==2?Z(x+y):Z(x-y));
     else if(o.op==2)r=with_jet(x+y,coeff(a,1)+coeff(b,1),coeff(a,2)+coeff(b,2));
     else r=with_jet(x-y,coeff(a,1)-coeff(b,1),coeff(a,2)-coeff(b,2));
    }
    else if(o.op==4)r=multiply(a,b);
    else if(o.op==5){if(b.jet>=0)throw std::runtime_error("log denominator");r=a.jet<0?V(quotient(x,y)):with_jet(x/y,coeff(a,1)/y,coeff(a,2)/y);}
    else if(o.op==7)r=a.jet<0?V(-x):with_jet(-x,-coeff(a,1),-coeff(a,2));
    else if(o.op==22)r=a.jet<0&&b.jet<0?V(Z(x.real(),y.real())):with_jet(Z(x.real(),y.real()),Z(abs(coeff(a,1)),abs(coeff(b,1))),Z(abs(coeff(a,2)),abs(coeff(b,2))));
    else if(o.op==6&&a.jet>=0){
      if(b.jet>=0||y.imag()!=0||y.real()<0||y.real()>2||y.real()!=floor(y.real()))throw std::runtime_error("log power");
      r=V(1);for(int j=0;j<y.real().convert_to<int>();j++)r=multiply(r,a);
    }else {
     if(a.jet>=0||(o.b>=0&&b.jet>=0))throw std::runtime_error("nonlinear singular log");
     switch(o.op){
      case 6:if(y.imag()==0&&abs(y.real())<100&&y.real()==floor(y.real()))r=V(ipow(x,y.real().convert_to<int>()));else r=V(pow(principal(x),principal(y)));break;
      case 8:if(x==0)r=with_jet(0,1,0);else r=V(log(principal(x)));break;
      case 9:r=V(sqrt(principal(x)));break;
      case 10:if(x!=2)throw std::runtime_error("polylog order");r=V(dilog(y));break;
      case 11:{Z w=dilog(x);if(x.imag()==0&&x.real()>1)w=Z(w.real(),R(abs(w.imag())*p.sign*(y.real()>0?1:-1)));r=V(w);break;}
      case 12:r=V(x.real());break;case 13:r=V(x.imag());break;
      case 14:r=V(abs(x));break;case 15:r=V(conj(x));break;
      case 16:case 17:case 18:throw std::runtime_error("unexpanded elementary function");
      case 19:r=V(exp(x));break;
      case 20:r=V(Z(x.real(),y.real()));break;
      case 21:if(x.imag()!=0||y.imag()!=0)throw std::runtime_error("complex atan2");r=V(atan2(y.real()==0?R(0):R(y.real()),x.real()==0?R(0):R(x.real())));break;
      default:throw std::runtime_error("opcode");
     }
    }
   }v[n]=r;
  }
  const V&r=v[p.result];output[0]=r.value.real().convert_to<double>();output[1]=r.value.imag().convert_to<double>();
  R residual=std::max(R(abs(coeff(r,1))),R(abs(coeff(r,2))));output[2]=residual.convert_to<double>();
  if(!std::isfinite(output[0])||!std::isfinite(output[1])||residual>R("1e-50")*std::max(R(1),R(abs(r.value))))return 1;
  std::copy(input,input+p.previous.size(),p.previous.begin());p.valid=jets.empty();
  return 0;
 }catch(...){output[0]=output[1]=NAN;output[2]=INFINITY;return 2;}
}
'''

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--channels',nargs='+',default=['Hqq_v2','Hgg','Hqqbar','Hqqprime','Hgq_v4','Hqg_v3'])
    parser.add_argument('--workers',type=int,default=2,help='operation translation is serial')
    options=parser.parse_args();cache=ROOT/'s07_cache';cache.mkdir(exist_ok=True)
    record('Starting compact native operation-table build and direct-Wolfram checks for '+','.join(options.channels)+
           '. Next accept only finite values and cancelled singular-log coefficients.')
    specs=[]
    definitions=cache/'s07_function_definitions.json'
    code='Export['+json.dumps(str(definitions))+',<|"ArcTan"->ToString[TrigToExp[ArcTan[x]],CForm],"ArcTanh"->ToString[TrigToExp[ArcTanh[x]],CForm],"ArcCoth"->ToString[TrigToExp[ArcCoth[x]],CForm]|>,"RawJSON"];Quit[];'
    derive=subprocess.run(['/home/physics/wolframengine/opt/Wolfram/WolframEngine/15.0/Executables/WolframKernel','-noinit','-noprompt','-run',code],capture_output=True,text=True,timeout=30)
    assert derive.returncode==0 and definitions.exists(),derive.stderr
    Program.math_definitions=json.loads(definitions.read_text())
    contract_path=ROOT/'s10_cache/s10_invariant_contract_result'
    contract=json.loads(contract_path.read_text())
    assert contract['status']=='Complete' and all(contract['checks'].values())
    assert contract['input_sha256']==sha(ROOT/'s04_result')
    Program.canonical_inputs={name:S.ccode(S.sympify(expression)).replace('pow(','Power(')
        for name,expression in contract['expressions'].items()}
    Program.canonical_inputs.update(xB='xi*xh',omega='Abs(s+t)')
    for channel in options.channels:
        result=json.loads((ROOT/'s05_cache'/(channel+'_result')).read_text());assert result['Status']=='ExportComplete';specs.extend(result['Functions'])
    for producer in {s['ProducerSHA256'] for s in specs}:
        assert sha(ROOT/'s05_cache'/('s05_source_'+producer+'.wl'))==producer
    if len(options.channels)==6:
        overview=dict(stage='s05',status='Complete',channels=options.channels,
            inputs={channel:sha(ROOT/'s05_cache'/(channel+'_result')) for channel in options.channels},
            source_snapshots=sorted({s['ProducerSHA256'] for s in specs}),
            function_count=len(specs),checks=dict(exact_rational_export=all(s['CFormExactRationals'] for s in specs),
                original_expression_comparison=all(c['InvariantReconstruction'] for s in specs for c in s['Checks'])))
        assert all(overview['checks'].values())
        (ROOT/'s05_result').write_text(json.dumps(overview,indent=2)+'\n')
    assert len({s['SpecialCForms']['ArcCoth'] for s in specs})==1
    native=NATIVE
    with mp.workdps(115):
        for name,value in [('PI',mp.pi),('EULER',mp.euler),('E',mp.e)]:native=native.replace('@@'+name+'@@',mp.nstr(value,110))
    source=cache/'s07_evaluator.cpp';source.write_text(native)
    libpath=cache/'s07_evaluator.so'
    run=subprocess.run(['g++','-std=c++20','-O3','-shared','-fPIC',str(source),'-o',str(libpath)],capture_output=True,text=True,timeout=60)
    (cache/'s07_build.log').write_text(run.stdout+run.stderr);assert run.returncode==0,run.stderr
    lib=C.CDLL(str(libpath));lib.sidis_load_program.argtypes=[C.c_char_p];lib.sidis_load_program.restype=C.c_int
    callback=install_dilog(lib)
    arr=np.ctypeslib.ndpointer(dtype=np.float64,ndim=1,flags='C_CONTIGUOUS')
    lib.sidis_eval.argtypes=[C.c_int,arr,arr];lib.sidis_eval.restype=C.c_int
    checks=[];functions=[]
    for spec in specs:
        assert spec['CFormExactRationals'] and (spec['RationalCoefficientReconstruction'] or spec['PreparationMethod']=='ExactUncollected')
        assert spec['InvariantContractSHA256']==sha(contract_path)
        print('S07_TRANSLATE',spec['Name'],flush=True)
        program=Program(spec);path=cache/('s07_'+spec['Name']+'.dat');program.write(path)
        index=lib.sidis_load_program(str(path).encode());assert index>=0
        for sample in spec['Checks']:
            args=np.asarray(sample['Arguments'],dtype=float);output=np.empty(3);status=lib.sidis_eval(index,args,output)
            expected=np.array([sample['Real'],sample['Imaginary']]);passed=bool(status==0 and np.allclose(output[:2],expected,rtol=2e-8,atol=1e-11))
            checks.append(dict(name=spec['Name'],arguments=args.tolist(),native=output.tolist(),wolfram=expected.tolist(),native_status=status,passed=passed))
        f={k:spec[k] for k in ['Name','Channel','Label','Branch','Endpoint','ChargeCase','JacobianAlreadyIncluded','Arguments']}
        f.update(Index=index,Program=str(path.relative_to(ROOT)),ProgramSHA256=sha(path),OperationCount=len(program.ops),S05ProducerSHA256=spec['ProducerSHA256'])
        functions.append(f);print('S07_CHECKED',spec['Name'],'operations',len(program.ops),'passed',all(c['passed'] for c in checks if c['name']==spec['Name']),flush=True)
    groups={}
    for spec in specs:
        label=re.sub(r'^F[12](?:Hat|hat)?_','',spec['Label'])
        groups.setdefault((spec['Channel'],label,spec['Branch']),[]).append(spec)
    bundles=[]
    for (channel,label,branch),pair in groups.items():
        pair.sort(key=lambda s:s['Label']);assert len(pair)==2 and pair[0]['Arguments']==pair[1]['Arguments']
        program=Program(pair[0]);program.append_hat(pair[1]);name=f'{channel}_{label}_{branch}'.replace('-','m')
        path=cache/('s07_pair_'+name+'.dat');program.write(path)
        index=lib.sidis_load_program(str(path).encode());assert index>=0
        for a,b in zip(pair[0]['Checks'],pair[1]['Checks']):
            assert a['Arguments']==b['Arguments'];arguments=np.asarray(a['Arguments'],dtype=float);output=np.empty(3)
            status=lib.sidis_eval(index,arguments,output);expected=np.array([a['Real'],b['Real']])
            passed=bool(status==0 and np.allclose(output[:2],expected,rtol=2e-8,atol=1e-11))
            checks.append(dict(name='pair_'+name,native=output.tolist(),wolfram=expected.tolist(),passed=passed))
        bundles.append(dict(Name=name,Channel=channel,Label=label,Branch=branch,Index=index,
            ChargeCase=pair[0]['ChargeCase'],JacobianAlreadyIncluded=pair[0]['JacobianAlreadyIncluded'],
            Program=str(path.relative_to(ROOT)),ProgramSHA256=sha(path),OperationCount=len(program.ops)))
        print('S07_PAIRED',name,'operations',len(program.ops),flush=True)
    suffix='all' if len(options.channels)==6 else '_'.join(options.channels)
    result=dict(stage='s07',status='Complete' if all(c['passed'] for c in checks) else 'ValidationFailed',producer_sha256=sha(Path(__file__)),
        channels=options.channels,library=str(libpath.relative_to(ROOT)),library_sha256=sha(libpath),functions=functions,bundles=bundles,checks=checks,
        representation='Exact-rational Wolfram CSE operation tables; Boost complex 100 decimal digits; 115-digit mpmath dilogarithms; exact canonical kinematics',
        decimal_precision=100,canonical_inputs=Program.canonical_inputs,invariant_contract_sha256=sha(contract_path),
        singular_logs='Formal polynomial tracking through every operation; residual coefficients checked at every point')
    dest=ROOT/('s07_result' if len(options.channels)==6 else 's07_cache/s07_'+suffix+'_result');dest.write_text(json.dumps(result,indent=2)+'\n')
    assert result['status']=='Complete',[c for c in checks if not c['passed']][:4]
    record('Native evaluator completed for '+','.join(options.channels)+'; all '+str(len(checks))+' direct-Wolfram comparisons passed. '
           'Operation tables, source and checks retain production/provenance value. Next complete remaining channels and run the full convolution.')
    print('S07_SUCCESS',suffix,len(checks),flush=True)

if __name__=='__main__':
    try:main()
    except Exception as exc:record('Stage failed: '+str(exc)[:600]+'. Next correct the originating issue before convolution.');raise
