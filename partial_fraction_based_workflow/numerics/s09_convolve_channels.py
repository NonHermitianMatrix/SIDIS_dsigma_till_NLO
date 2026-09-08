#!/usr/bin/env python3
"""Execute the supplied six-channel hats in the H1 neutral-pion bins."""
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'python_deps'))
import argparse, ctypes as C, hashlib, json, os, pickle, subprocess, time, importlib.util
from concurrent.futures import ProcessPoolExecutor, as_completed
from datetime import datetime, timezone
import numpy as np
import sympy as S
import vegas, gvar
from scipy.stats import chi2

CHANNELS = ['Hqq_v4', 'Hgg_v2', 'Hqqbar_v2', 'Hqqprime_v2', 'Hgq_v4', 'Hqg_v3']
FFS = ['KKP', 'Kretzer']
CACHE = ROOT/'s09_cache'


def record(message):
    with (ROOT.parent/'progress.md').open('a') as f:
        f.write('\nNumerics S09 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path, value):
    temporary = path.with_name(path.name+'.tmp')
    temporary.write_text(json.dumps(value, indent=2, allow_nan=False)+'\n')
    temporary.replace(path)


def finite_json(value):
    if isinstance(value, dict):
        return {k: finite_json(v) for k, v in value.items()}
    if isinstance(value, list):
        return [finite_json(v) for v in value]
    if isinstance(value, float) and not np.isfinite(value):
        return None
    return value


def load(name):
    return json.loads((ROOT/name).read_text())


def derive_and_build():
    CACHE.mkdir(exist_ok=True)
    maps, inputs, kernels, actions = [load('s%02d_result'%n) for n in [4, 6, 7, 8]]
    for obj, source in zip([maps, inputs, kernels, actions], [
            's04_derive_convolution_maps.py', 's06_prepare_pdf_ff.py',
            's07_compile_hard_functions.py', 's08_derive_consumer_actions.py']):
        assert obj['status'] == 'Complete' and obj['producer_sha256'] == sha(ROOT/source)
        checks = obj['checks']
        assert all(checks.values()) if isinstance(checks, dict) else all(c['passed'] for c in checks)
    assert kernels['s01_result_sha256']==sha(ROOT/'s01_result')
    for obj in [inputs, kernels]:
        assert sha(ROOT/obj['library']) == obj['library_sha256']
    for bundle in kernels['bundles']:
        assert sha(ROOT/bundle['Program']) == bundle['ProgramSHA256']
    assert load('s02_result')['convolution_authorized_by_this_gate']
    precision = load('s10_result')
    assert precision['status'] == 'Complete' and all(c['passed'] for c in precision['checks'])
    assert precision['s07_result_sha256'] == sha(ROOT/'s07_result'), 'Repeat S10 after changing the coefficient backend'
    for channel in CHANNELS:
        measure_contract=load('s03_cache/'+channel+'_consumer_contract')
        assert measure_contract['Status']=='Complete' and all(measure_contract['Checks'].values())
        assert measure_contract['JacobianAlreadyIncluded'] is False
    assert all(not b['JacobianAlreadyIncluded'] for b in kernels['bundles'])

    # MRST's returned valence and sea definitions are solved for this flavor order.
    flavors = inputs['flavor_order']; raw_names = inputs['raw_pdf_order']
    f = S.symbols('f0:'+str(len(flavors))); raw = S.symbols('r0:'+str(len(raw_names)))
    xi = S.Symbol('xi', positive=True)
    index = {name: i for i, name in enumerate(flavors)}
    equations = []
    for name, value in zip(raw_names, raw):
        name = name.removeprefix('x_')
        if name in ['uv', 'dv']:
            q = name.removesuffix('v')
            equations.append(S.Eq(value, xi*(f[index[q]]-f[index[q+'bar']])))
        else:
            equations.append(S.Eq(value, xi*f[index[name]]))
    for name in ['s', 'c', 'b']:
        equations.append(S.Eq(f[index[name]], f[index[name+'bar']]))
    solved = S.solve(equations, f, dict=True)
    assert len(solved) == 1 and all(S.simplify((eq.lhs-eq.rhs).subs(solved[0])) == 0 for eq in equations)
    pdf_code = '\n'.join(' f[%d]=%s;'%(i, S.ccode(solved[0][v])) for i, v in enumerate(f))
    raw_code = ','.join('r%d=raw[%d]'%(i, i) for i in range(len(raw)))
    Dplus, Dminus, Dsum = S.symbols('Dplus Dminus Dsum')
    neutral = S.sympify(maps['expressions']['neutral_pion_FF'])
    neutral_sum = S.simplify(neutral.subs(Dminus, S.solve(S.Eq(Dsum, Dplus+Dminus), Dminus)[0]))
    neutral_factor = S.diff(neutral_sum, Dsum)
    assert S.simplify(neutral_sum-neutral_factor*Dsum) == 0

    u, low, high = S.symbols('coordinate lower upper', positive=True)
    linear = low+(high-low)*u
    logarithmic = low*S.exp(u*S.log(high/low))
    transforms = {}
    for name, value in [('linear', linear), ('logarithmic', logarithmic)]:
        jacobian = S.diff(value, u)
        assert S.simplify(value.subs(u, 0)-low) == 0 and S.simplify(value.subs(u, 1)-high) == 0
        transforms[name] = dict(expression=str(value), jacobian=str(jacobian))
    c_maps = maps['c_expressions']
    map_functions = []
    for name in ['s', 't', 'u', 'xHat', 'xB', 'zeta', 'B', 'xi_min', 'jacobian',
                 'z_lower', 'z_upper', 'sigma_weight_F1', 'sigma_weight_F2', 'mu2']:
        map_functions.append('static double map_%s(double Q2,double y,double pt,double zH,double xi,double s23){return %s;}'%
                             (name, c_maps[name].replace('xB', '('+c_maps['xB']+')')))
    lum_code = []
    lum_labels = ['Hqq_group0', 'Hqq_group1', 'Hgg_v2', 'Hqqbar_v2',
                  'Hqqprime_v2_IncomingChargeSquared', 'Hqqprime_v2_PrimeChargeSquared',
                  'Hqqprime_v2_MixedIncomingPrimeCharge', 'Hgq_v4', 'Hqg_v3']
    for nf, data in actions['luminosities'].items():
        statements = []
        exprs = [g['c_expression'] for g in data['hqq_charge_groups']]
        exprs += [data['c_expressions'][name] for name in lum_labels[2:]]
        for i, expression in enumerate(exprs):
            statements.append(' v[%d]=%s;'%(i, expression))
        for i, group in enumerate(data['hqq_charge_groups']):
            statements.append(' charges[%d][0]=%s;charges[%d][1]=%s;charges[%d][2]=%s;charges[%d][3]=0;'%(
                i,S.ccode(S.sympify(group['charge'])),i,S.ccode(S.sympify(group['other_moment1'])),
                i,S.ccode(S.sympify(group['other_moment2'])),i))
        lum_code.append('if(nf==%s){%s}else '%(nf, '\n'.join(statements)))
    bundle_code = []
    label_ids = {'LODelta': 0, 'Delta': 1, 'L0': 2, 'L1': 3, 'Regular': 4,
                 'IncomingChargeSquared_Regular': 5, 'PrimeChargeSquared_Regular': 6,
                 'MixedIncomingPrimeCharge_Regular': 7}
    for b in kernels['bundles']:
        bundle_code.append('ids[%d][%d][%d]=sidis_load_program(%s);included[%d][%d]=%s;'%(
            CHANNELS.index(b['Channel']), label_ids[b['Label']], {-1:0,1:1,0:2}[b['Branch']],
            json.dumps(str(ROOT/b['Program'])), CHANNELS.index(b['Channel']), label_ids[b['Label']],
            str(b['JacobianAlreadyIncluded']).lower()))
    alpha = inputs['alpha']; physical = maps['defining_physics_inputs']
    accepted = actions['azimuthal_acceptance']
    theta = [S.pi*S.Rational(v)/S.Integer(180) for v in physical['lab_theta_degrees']]
    substitutions = {
        '@@MAP_FUNCTIONS@@': '\n'.join(map_functions), '@@PDF_MAP@@': pdf_code,
        '@@RAW_DECLARATIONS@@': raw_code,
        '@@LUMINOSITY_DECLARATIONS@@': ','.join('%s%d=%s[%d]'%(v, i, v, i) for v in ['f', 'd'] for i in range(len(flavors))),
        '@@LUMINOSITIES@@': ''.join(lum_code)+'{throw std::runtime_error("unsupported active flavors");}',
        '@@PROGRAMS@@': '\n'.join(bundle_code),
        '@@NEUTRAL_FACTOR@@': S.ccode(neutral_factor),
        '@@ENERGY_BOUND@@': accepted['c_energy_cosine_bound'],
        '@@THETA_BOUND@@': accepted['c_theta_cosine_bound'], '@@AZIMUTH_FRACTION@@': accepted['c_fraction'],
        '@@THETA_MIN@@': S.ccode(theta[0]), '@@THETA_MAX@@': S.ccode(theta[1]),
        '@@E_FRAC@@': physical['lab_Epi_over_Ep_min'],
        '@@EE@@': physical['Ee_GeV'], '@@EP@@': physical['Ep_GeV'],
        '@@ALPHA_EM@@': repr(inputs['alpha_EM']), '@@PB@@': repr(inputs['GeV_minus2_to_pb']),
        '@@MC2@@': repr(alpha['mc2_GeV2']), '@@MB2@@': repr(alpha['mb2_GeV2']),
        '@@LAMBDA2@@': repr(alpha['lambda4_squared_GeV2']),
        '@@LOG_MAP@@': S.ccode(logarithmic), '@@LOG_JAC@@': S.ccode(S.diff(logarithmic, u)),
        '@@LIN_MAP@@': S.ccode(linear), '@@LIN_JAC@@': S.ccode(S.diff(linear, u)),
        '@@PLUS_LOGARITHMS@@': ''.join('if(ch==%d)return %s;'%(CHANNELS.index(channel),
            S.ccode(S.log(S.sympify(argument)))) for channel,argument in actions['plus_log_arguments'].items()),
        '@@BOUNDARY_CHANNELS@@': ' || '.join('ch==%d'%CHANNELS.index(channel) for channel in
            sorted({b['Channel'] for b in kernels['bundles'] if b['Branch']==0})),
    }
    source = NATIVE
    for key, value in substitutions.items():
        source = source.replace(key, value)
    assert '@@' not in source
    path = CACHE/'s09_integrand.cpp'; path.write_text(source)
    libpath = CACHE/'s09_integrand.so'
    build = subprocess.run(['g++', '-std=c++20', '-O3', '-shared', '-fPIC', str(path),
        str(ROOT/kernels['library']), str(ROOT/inputs['library']), '-o', str(libpath)], capture_output=True, text=True, timeout=60)
    (CACHE/'s09_build.log').write_text(build.stdout+build.stderr)
    assert build.returncode == 0, build.stderr
    contract = dict(stage='s09', status='IntegrandBuilt', producer_sha256=sha(Path(__file__)),
        input_hashes={name: sha(ROOT/name) for name in ['s01_result', 's02_result', 's04_result', 's06_result', 's07_result', 's08_result', 's10_result', 's03_result', 'dsigmapibydpt/s01_result']},
        native_source_sha256=sha(path), native_library_sha256=sha(libpath),
        pdf_map={str(v): str(solved[0][v]) for v in f}, neutral_sum=str(neutral_sum), transforms=transforms,
        channels=CHANNELS, FFs=FFS, numerical_zero_policy='Only exact cut rejection and absent LO/interference sectors return zero; native failures raise.',
        components=[dict(FF=ff, channel=ch, order=order) for ff in FFS for ch in CHANNELS for order in ['LO', 'NLO_correction']],
        caveats=[physical['azimuth'], 'Hgq_v4 retains its documented unresolved MadGraph real-emission comparison; supplied coefficients are unchanged.',
                 'Central common scale only; errors are integration errors, not theoretical uncertainty.'])
    write_json(CACHE/'s09_build_result', contract)
    return contract


NATIVE = r'''
#include <cmath>
#include <algorithm>
#include <string>
#include <sstream>
#include <stdexcept>
#include <cstring>
extern "C" int sidis_load_program(const char*);
extern "C" int sidis_eval(int,const double*,double*);
extern "C" void sidis_pdf(double,double,double*);
extern "C" void sidis_kkp(double,double,int,double*);
extern "C" void sidis_kretzer(double,double,int,double*);
extern "C" void sidis_set_alpha(double,double,double);
extern "C" double sidis_alpha(double);
static constexpr double Ee=@@EE@@,Ep=@@EP@@,alphaEM=@@ALPHA_EM@@,pb=@@PB@@;
static int ids[6][8][3];static bool included[6][8];
static unsigned channelMask=(1u<<6)-1;
extern "C" void sidis_channel_mask(unsigned mask){channelMask=mask;}
static bool initialized=false;
static std::string failure;
@@MAP_FUNCTIONS@@
static double plusLogarithm(int ch,double ss,double B){@@PLUS_LOGARITHMS@@throw std::runtime_error("missing plus convention");}
static double linmap(double coordinate,double lower,double upper,double& jac){jac=@@LIN_JAC@@;return @@LIN_MAP@@;}
static double logmap(double coordinate,double lower,double upper,double& jac){jac=@@LOG_JAC@@;return @@LOG_MAP@@;}
static void luminosity(int nf,const double*f,const double*d,double*v,double charges[2][4]){
 const double @@LUMINOSITY_DECLARATIONS@@;
 @@LUMINOSITIES@@
}
static void pdf(double xi,double mu2,double*f){
 if(!(xi>=1e-5 && xi<=1 && mu2>=1.25 && mu2<=1e7))throw std::runtime_error("MRST grid range");
 double raw[8];sidis_pdf(xi,sqrt(mu2),raw);const double @@RAW_DECLARATIONS@@;
 @@PDF_MAP@@
}
static void ff(double z,double mu2,int set,double*d){
 if(!(z>=0.01 && z<=1 && mu2>=1 && mu2<=1e6))throw std::runtime_error("FF grid range");
 if(set==0)sidis_kkp(z,sqrt(mu2),5,d);
 else {sidis_kretzer(z,mu2,3,d);for(int i=0;i<11;i++)d[i]*=@@NEUTRAL_FACTOR@@;}
 for(int i=1;i<11;i+=2)if(std::abs(d[i]-d[i+1])>1e-12*std::max(1.,std::abs(d[i])))throw std::runtime_error("neutral FF conjugation");
}
static double acceptance(double Q2,double y,double pt,double zH){
 double Emin=@@E_FRAC@@*Ep;
 double lo=std::max(-1.,@@ENERGY_BOUND@@);
 double ctheta=cos(@@THETA_MAX@@);
 lo=std::max(lo,@@THETA_BOUND@@);
 ctheta=cos(@@THETA_MIN@@);
 double hi=std::min(1.,@@THETA_BOUND@@);
 if(lo>=hi)return 0.;
 return @@AZIMUTH_FRACTION@@;
}
extern "C" int sidis_init(){
 try{if(initialized)return 0;std::fill(&ids[0][0][0],&ids[0][0][0]+6*8*3,-1);
 @@PROGRAMS@@
 sidis_set_alpha(@@MC2@@,@@MB2@@,@@LAMBDA2@@);initialized=true;return 0;
 }catch(...){return 1;}
}
extern "C" const char* sidis_error(){return failure.c_str();}
struct Point{
 double Q2,y,pt,zH,xi,ss,B,mu2,zeta,J,s,t,w1,w2,args[19];int nf,branch;
 Point(double Q,double yy,double pp,double z,double xx,double recoil):Q2(Q),y(yy),pt(pp),zH(z),xi(xx),ss(recoil){
  B=map_B(Q2,y,pt,zH,xi,ss);mu2=map_mu2(Q2,y,pt,zH,xi,ss);
  zeta=map_zeta(Q2,y,pt,zH,xi,ss);J=map_jacobian(Q2,y,pt,zH,xi,ss);
  s=map_s(Q2,y,pt,zH,xi,ss);t=map_t(Q2,y,pt,zH,xi,ss);
  nf=mu2<@@MB2@@?4:5;branch=s+t>0;
  if(!(s>0 && t<0 && B>0 && zeta>0 && zeta<1 && J>0 && mu2>@@MC2@@))throw std::runtime_error("partonic map domain");
  w1=map_sigma_weight_F1(Q2,y,pt,zH,xi,ss)/xi;
  w2=map_sigma_weight_F2(Q2,y,pt,zH,xi,ss);
  const double a[]={Q2,s,t,ss,B,mu2,map_xHat(Q2,y,pt,zH,xi,ss),zH,pt*pt,map_xB(Q2,y,pt,zH,xi,ss),xi,sidis_alpha(mu2),1,1,0,0,double(nf),1,std::abs(s+t)};
  std::copy(a,a+19,args);
 }
 double coefficient(int ch,int label,const double*charge=nullptr){
  int routed=(s+t==0 && (@@BOUNDARY_CHANNELS@@))?2:branch;
  int id=ids[ch][label][routed];if(id<0)throw std::runtime_error("missing hard function");
  if(charge)std::copy(charge,charge+4,args+12);else {args[12]=args[13]=1;args[14]=args[15]=0;}
  double out[3];int status=sidis_eval(id,args,out);
  if(status){std::ostringstream os;os<<"hard function status="<<status<<" channel="<<ch<<" label="<<label<<" branch="<<branch<<" output="<<out[0]<<","<<out[1]<<","<<out[2]<<" args=";os.precision(17);for(auto v:args)os<<v<<",";throw std::runtime_error(os.str());}
  return (out[0]*w1+out[1]*w2)*(included[ch][label]?1.:J)/(zeta*zeta);
 }
};
extern "C" int sidis_integrand(const double*unit,const double*bounds,double*out,double*diagnostics){
 try{
  std::fill(out,out+24,0.);std::fill(diagnostics,diagnostics+10,0.);
  double jq,jy,jp,jz,jxi,jss;
  double Q2=logmap(unit[0],bounds[0],bounds[1],jq),y=linmap(unit[1],bounds[2],bounds[3],jy),pt=logmap(unit[2],bounds[4],bounds[5],jp);
  double zl=map_z_lower(Q2,y,pt,0,0,0),zh=map_z_upper(Q2,y,pt,0,0,0);
  if(!(std::isfinite(zl)&&zl>0&&zh>zl&&zh<1))throw std::runtime_error("hadron z bounds");
  double zH=logmap(unit[3],zl,zh,jz);
  double acc=acceptance(Q2,y,pt,zH);diagnostics[0]=acc;
  if(acc==0)return 0;
  double xmin=map_xi_min(Q2,y,pt,zH,0,0);
  double xi=logmap(unit[4],xmin,1.,jxi),B=map_B(Q2,y,pt,zH,xi,0);
  double ss=linmap(unit[5],0.,B,jss);
  Point end(Q2,y,pt,zH,xi,0),cur(Q2,y,pt,zH,xi,ss);
  double weight=jq*jy*jp*jz*jxi*acc*pb;
  diagnostics[1]=xi;diagnostics[2]=end.zeta;diagnostics[3]=cur.zeta;
  diagnostics[4]=Q2;diagnostics[5]=y;diagnostics[6]=pt;diagnostics[7]=zH;diagnostics[8]=ss;diagnostics[9]=B;
  double f[11],d[11],lum[2][2][9],charges[2][4];pdf(xi,end.mu2,f);
  for(int set=0;set<2;set++)for(int pos=0;pos<2;pos++){
   ff(pos?cur.zeta:end.zeta,end.mu2,set,d);luminosity(end.nf,f,d,lum[set][pos],charges);
   if(std::abs(lum[set][pos][6])>1e-10*std::max(1.,std::abs(lum[set][pos][4])))throw std::runtime_error("prime interference identity");
  }
  for(int ch=0;ch<6;ch++){
   if(!(channelMask&(1u<<ch)))continue;
   if(ch==1||ch==2||ch==3){
    if(ch==3){for(int basis=0;basis<2;basis++){
     double h=cur.coefficient(ch,5+basis);
     for(int set=0;set<2;set++)out[set*12+ch*2+1]+=h*lum[set][1][4+basis]*jss*weight;
    }}else {
     double h=cur.coefficient(ch,4);int which=ch+1;
     for(int set=0;set<2;set++)out[set*12+ch*2+1]=h*lum[set][1][which]*jss*weight;
    }
    continue;
   }
   for(int group=0;group<(ch==0?2:1);group++){
    const double*charge=ch==0?charges[group]:nullptr;
    int which=ch==0?group:ch+3;
    double born=end.coefficient(ch,0,charge),delta=end.coefficient(ch,1,charge),reg=cur.coefficient(ch,4,charge);
    double p0=end.coefficient(ch,2,charge),p1=cur.coefficient(ch,2,charge);
    double l0=end.coefficient(ch,3,charge),l1=cur.coefficient(ch,3,charge);
    double logarithm=plusLogarithm(ch,ss,B);
    for(int set=0;set<2;set++){
     double e=lum[set][0][which],c=lum[set][1][which];
     out[set*12+ch*2]+=born*e*weight;
     out[set*12+ch*2+1]+=(delta*e+(reg*c+(p1*c-p0*e)/ss+(l1*c-l0*e)*logarithm/ss)*jss)*weight;
    }
   }
  }
  for(int i=0;i<24;i++)if(!std::isfinite(out[i]))throw std::runtime_error("nonfinite convolution");
  return 0;
 }catch(const std::exception&e){failure=e.what();return 1;}
}
'''


class Evaluator:
    def __init__(self, bounds, channels=None):
        self.bounds = np.ascontiguousarray(bounds, dtype=float)
        spec = importlib.util.spec_from_file_location('sidis_s07', ROOT/'s07_compile_hard_functions.py')
        module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
        self.hard_library = C.CDLL(str(ROOT/load('s07_result')['library']))
        self.dilog_callback = module.install_dilog(self.hard_library)
        self.lib = C.CDLL(str(CACHE/'s09_integrand.so'))
        self.lib.sidis_init.restype = C.c_int
        assert self.lib.sidis_init() == 0
        self.lib.sidis_channel_mask.argtypes=[C.c_uint]
        self.lib.sidis_channel_mask(sum(1<<CHANNELS.index(c) for c in (channels or CHANNELS)))
        arr = np.ctypeslib.ndpointer(dtype=np.float64, ndim=1, flags='C_CONTIGUOUS')
        self.lib.sidis_integrand.argtypes = [arr, arr, arr, arr]
        self.lib.sidis_integrand.restype = C.c_int
        self.lib.sidis_error.restype = C.c_char_p
        self.calls = self.accepted = 0; self.last_print = time.monotonic()

    def evaluate(self, unit):
        unit = np.ascontiguousarray(unit, dtype=float)
        out = np.empty(24); diagnostics = np.empty(10)
        status = self.lib.sidis_integrand(unit, self.bounds, out, diagnostics)
        if status:
            details = dict(unit=unit.tolist(), bounds=self.bounds.tolist(), diagnostics=diagnostics.tolist(),
                           error=self.lib.sidis_error().decode(), pid=os.getpid())
            write_json(CACHE/('s09_failure_%d.json'%os.getpid()), details)
            raise RuntimeError(details)
        self.calls += 1; self.accepted += int(diagnostics[0] > 0)
        if time.monotonic()-self.last_print > 30:
            print('S09_EVALUATIONS', os.getpid(), self.calls, 'accepted', self.accepted, flush=True)
            self.last_print = time.monotonic()
        return out, diagnostics

    def __call__(self, unit):
        out, _ = self.evaluate(unit)
        # The first component controls adaptation and bounds every signed component.
        return np.r_[np.sum(np.abs(out)), out.reshape(2, 12).sum(axis=1), out]


def bins():
    result = []
    for panel, table in enumerate(load('dsigmapibydpt/s01_result')['tables']):
        for number, b in enumerate(table['bins']):
            result.append(dict(id='q%d_p%d'%(panel, number), panel=panel, bin=number,
                bounds=list(map(float, table['Q2_range_GeV2']+table['y_range']+[b['pt_low_GeV'], b['pt_high_GeV']])),
                experimental_dsigma_dpt=float(b['dsigma_dpt_pb_per_GeV'])))
    return result


def smoke(count):
    rng = np.random.default_rng(904731)
    evaluator = Evaluator(bins()[0]['bounds']); rows = []; start = time.monotonic()
    for i in range(count):
        unit = rng.uniform(1e-5, 1-1e-5, 6); out, diag = evaluator.evaluate(unit)
        rows.append(dict(unit=unit.tolist(), diagnostics=diag.tolist(), components=out.tolist()))
        print('S09_SMOKE', i, 'acceptance', diag[0], 'totals', out.reshape(2, 12).sum(axis=1).tolist(), flush=True)
    result = dict(status='SmokePassed', points=rows, calls=evaluator.calls, accepted=evaluator.accepted,
                  wall_seconds=time.monotonic()-start, source_sha256=sha(Path(__file__)))
    write_json(CACHE/'s09_smoke_result', result)
    record('S09 smoke completed at '+str(count)+' sampled points; '+str(evaluator.accepted)+
           ' pass laboratory cuts. Results and timing saved; no integrated prediction yet. Next run convergence-gated bin integrations.')
    return result


class RestoredRAvgArray(vegas.RAvgArray):
    def __setstate__(self, state):
        # The installed unweighted loader omits this required bookkeeping field.
        self._mlist=[]
        return super().__setstate__(state)


class CheckpointReader(pickle.Unpickler):
    def find_class(self, module, name):
        if module=='vegas._vegas' and name=='RAvgArray':return RestoredRAvgArray
        return super().find_class(module,name)


def prepare_reuse(folder):
    """Accept unchanged channels only after identity and full-statistics checks."""
    folder=ROOT/folder
    previous=json.loads((folder/'s09_result').read_text())
    old_kernels=json.loads((folder/'s07_result').read_text())
    current=load('s07_result');build=load('s09_cache/s09_build_result')
    unchanged=[c for c in CHANNELS if c!='Hgq_v4']
    assert previous['status']=='Complete' and previous['FFs']==FFS
    assert sha(folder/'s07_cache/s07_evaluator.cpp')==sha(ROOT/'s07_cache/s07_evaluator.cpp')
    for name in ['s04_result','s06_result','dsigmapibydpt/s01_result','s03_result']:
        assert previous['input_hashes'][name]==sha(ROOT/name),name
    for channel in unchanged:
        assert sha(folder/'s05_cache'/(channel+'_result'))==sha(ROOT/'s05_cache'/(channel+'_result'))
        before={(b['Label'],b['Branch']):(b['ProgramSHA256'],b['JacobianAlreadyIncluded'])
                for b in old_kernels['bundles'] if b['Channel']==channel}
        after={(b['Label'],b['Branch']):(b['ProgramSHA256'],b['JacobianAlreadyIncluded'])
               for b in current['bundles'] if b['Channel']==channel}
        assert before==after,channel
    assert all(load('s08_result')['checks']['unchanged_flavor_actions_nf'+nf] for nf in ['4','5'])
    old_smoke=json.loads((folder/'s09_cache/s09_smoke_result').read_text())
    assert old_smoke['source_sha256']==previous['producer_sha256']
    evaluator=Evaluator(bins()[0]['bounds'])
    indices=[i for i,c in enumerate(build['components']) if c['channel'] in unchanged]
    for row in old_smoke['points']:
        out,diagnostics=evaluator.evaluate(row['unit'])
        np.testing.assert_allclose(out[indices],np.asarray(row['components'])[indices],rtol=2e-10,atol=1e-10)
        np.testing.assert_allclose(diagnostics,row['diagnostics'],rtol=2e-12,atol=1e-12)
    # Generate the projection from component labels; discard every old Hgq entry.
    projection=np.zeros((len(build['components'])+3,len(previous['components'])+3))
    for j,component in enumerate(build['components']):
        if component['channel'] not in unchanged:continue
        k=previous['components'].index(component)
        projection[j+3,k+3]=1
        projection[1+FFS.index(component['FF']),k+3]=1
    excluded=[i+3 for i,c in enumerate(previous['components']) if c['channel'] not in unchanged]
    assert not np.any(projection[:,excluded])
    recovered={}
    for old in previous['bins']:
        assert old['status']=='Complete' and all(old['checks'].values())
        path=folder/'s09_cache'/(old['id']+'_vegas.pkl')
        with path.open('rb') as f:objects=CheckpointReader(f).load()
        raw=next(x for x in objects if hasattr(x,'itn_results'))
        restored=vegas.ravg(raw.itn_results,weighted=False)
        np.testing.assert_allclose(gvar.mean(restored),old['full_mean'],rtol=1e-12,atol=1e-12)
        np.testing.assert_allclose(gvar.evalcov(restored),old['full_covariance'],rtol=1e-12,atol=1e-12)
        assert len(raw.itn_results)==old['nitn']
        means=[(projection@np.asarray(gvar.mean(r))).tolist() for r in raw.itn_results]
        covariances=[(projection@np.asarray(gvar.evalcov(r))@projection.T).tolist() for r in raw.itn_results]
        recovered[old['id']]=dict(iteration_means=means,iteration_covariances=covariances,
            checkpoint_sha256=sha(path),old_seed=old['seed'],bounds=old['bounds'])
    result=dict(status='Complete',previous_result_sha256=sha(folder/'s09_result'),
        previous_folder=str(folder.relative_to(ROOT)),build_sha256=sha(CACHE/'s09_build_result'),
        unchanged_channels=unchanged,excluded_previous_channels=sorted({c['channel'] for c in previous['components'] if c['channel'] not in unchanged}),
        projection=projection.tolist(),bins=recovered,
        checks=dict(unchanged_inputs=True,unchanged_programs=True,unchanged_integrand_samples=True,
                    full_iteration_statistics_reproduced=True,old_Hgq_removed=True))
    write_json(CACHE/'s09_reuse_result',result)
    record('Unchanged-channel reuse accepted for every saved bin: input/program identities, recorded integrand samples and full iteration means/covariances pass. The generated projection excludes every old Hgq component. Next integrate v4 with independent seeds and retain the existing total precision/stability gates.')
    return result


def integrate_bin(task):
    spec, neval, nitn, seed, build_hash, refinements, reuse_hash = task
    destination = CACHE/(spec['id']+'_result')
    if destination.exists():
        old = json.loads(destination.read_text())
        if old['build_sha256'] == build_hash and old.get('reuse_sha256')==reuse_hash and old.get('initial_neval') == neval and old['nitn'] == nitn and old['status'] == 'Complete':
            print('S09_RESUME', spec['id'], flush=True); return old
        destination.unlink()
    gvar.ranseed(seed)
    baseline=None
    if reuse_hash:
        assert sha(CACHE/'s09_reuse_result')==reuse_hash
        reuse=load('s09_cache/s09_reuse_result');assert reuse['build_sha256']==build_hash
        baseline=reuse['bins'][spec['id']]
        assert baseline['old_seed']!=seed and baseline['bounds']==spec['bounds']
        assert len(baseline['iteration_means'])==nitn
    evaluator = Evaluator(spec['bounds'],['Hgq_v4'] if baseline else None)
    integrator = vegas.Integrator([[0., 1.]]*6)
    print('S09_BIN_START', spec['id'], 'seed', seed, 'neval', neval, 'nitn', nitn, flush=True)
    width = np.diff(spec['bounds'][-2:]).item()
    history = []
    for level in range(refinements+1):
        calls = neval*2**level
        warm = integrator(evaluator, nitn=3, neval=max(300, calls//2), adapt=True)
        print('S09_WARMUP', spec['id'], level, str(warm[1:3]), flush=True)
        raw = integrator(evaluator, nitn=nitn, neval=calls, adapt=False,
                         saveall=str(CACHE/(spec['id']+'_vegas.pkl')))
        full_iterations=list(raw.itn_results)
        if baseline:
            full_iterations=[r+gvar.gvar(mean,np.asarray(covariance)) for r,mean,covariance in
                zip(full_iterations,baseline['iteration_means'],baseline['iteration_covariances'])]
        result = vegas.ravg(full_iterations, weighted=False)
        means = np.asarray(gvar.mean(result)); cov = np.asarray(gvar.evalcov(result))
        iterations = np.array([np.asarray(gvar.mean(r))[1:3] for r in full_iterations])
        variances = np.array([np.diag(np.asarray(gvar.evalcov(r)))[1:3] for r in full_iterations])
        finite = bool(np.all(np.isfinite(means)) and np.all(np.isfinite(cov)) and
                      np.all(np.isfinite(variances)) and np.all(variances > 0) and np.all(np.diag(cov) >= 0))
        if not finite:
            write_json(CACHE/(spec['id']+'_statistics_failure'), finite_json(dict(mean=means.tolist(), covariance=cov.tolist(), iterations=iterations.tolist(), variances=variances.tolist())))
            raise RuntimeError('Nonfinite or invalid Monte Carlo statistics in '+spec['id'])
        totals = means[1:3]; errors = np.sqrt(np.diag(cov)[1:3])
        midpoint = len(iterations)//2
        first, second = iterations[:midpoint], iterations[midpoint:]
        half_variance = variances[:midpoint].sum(axis=0)/len(first)**2+variances[midpoint:].sum(axis=0)/len(second)**2
        pulls = np.abs(first.mean(axis=0)-second.mean(axis=0))/np.sqrt(half_variance)
        precision_target = np.maximum(.05*np.abs(totals), .005*spec['experimental_dsigma_dpt']*width)
        weights = np.reciprocal(variances)
        diagnostic_mean = (weights*iterations).sum(axis=0)/weights.sum(axis=0)
        chi_squared = np.sum((iterations-diagnostic_mean)**2/variances, axis=0)
        probabilities = chi2.sf(chi_squared, len(iterations)-1)
        gates = dict(finite_statistics=finite, requested_precision=bool(np.all(errors <= precision_target)),
                     independent_iteration_groups=bool(np.all(pulls <= 3)),
                     iteration_consistency=bool(np.all(probabilities >= .001)),
                     channel_sum=bool(np.allclose(means[3:].reshape(2, 12).sum(axis=1), totals, rtol=1e-10, atol=1e-10)))
        history.append(dict(level=level, neval=calls, sigma_pb=totals.tolist(), sigma_error_pb=errors.tolist(),
                            half_sample_pulls=pulls.tolist(), Q_per_FF=probabilities.tolist(), checks=gates))
        record_value = dict(**spec, status='Complete' if all(gates.values()) else 'ConvergenceNotAccepted',
            initial_neval=neval, neval=calls, nitn=nitn, seed=seed,
            build_sha256=build_hash,reuse_sha256=reuse_hash,
            integrated_channels=['Hgq_v4'] if baseline else CHANNELS,
            calls=evaluator.calls, accepted=evaluator.accepted,
            sigma_pb=totals.tolist(), sigma_error_pb=errors.tolist(),
            dsigma_dpt_pb_per_GeV=(totals/width).tolist(), dsigma_error_pb_per_GeV=(errors/width).tolist(),
            component_sigma_pb=means[3:].reshape(2, 6, 2).tolist(), full_mean=means.tolist(), full_covariance=cov.tolist(),
            Q_per_FF=probabilities.tolist(), checks=gates, refinement_history=history,
            iteration_means_pb=iterations.tolist(), iteration_variances_pb2=variances.tolist(),
            full_iteration_means=[np.asarray(gvar.mean(r)).tolist() for r in full_iterations],
            full_iteration_covariances=[np.asarray(gvar.evalcov(r)).tolist() for r in full_iterations],
            relative_error=(errors/np.maximum(np.abs(totals), 1e-100)).tolist(),
            precision_policy='Error <= max(5% of prediction, 0.5% of measured bin cross section); independent-half pull <=3; per-FF iteration Q >=0.001.')
        write_json(CACHE/(spec['id']+'_level%d_result'%level), record_value)
        print('S09_BIN_LEVEL', spec['id'], level, record_value['dsigma_dpt_pb_per_GeV'], 'errors', record_value['dsigma_error_pb_per_GeV'], 'checks', gates, flush=True)
        if all(gates.values()):
            break
        record('Bin '+spec['id']+' needs more samples after level '+str(level)+': '+str(gates)+'. Next double the sampling budget within the configured refinement limit.')
    write_json(destination, record_value)
    if record_value['status']!='Complete' and baseline:
        record('Reused-channel composition did not meet the unchanged final gates in '+spec['id']+
            '. Next integrate all channels for this bin with the same gates; no tolerance is relaxed.')
        destination.unlink()
        return integrate_bin((spec,neval,nitn,seed,build_hash,refinements,None))
    assert record_value['status'] == 'Complete', 'Integration did not converge in '+spec['id']
    print('S09_BIN_DONE', spec['id'], record_value['dsigma_dpt_pb_per_GeV'], 'errors', record_value['dsigma_error_pb_per_GeV'], flush=True)
    return record_value


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode', choices=['build', 'smoke', 'integrate'], default='smoke')
    parser.add_argument('--points', type=int, default=16)
    parser.add_argument('--neval', type=int, default=1000)
    parser.add_argument('--nitn', type=int, default=8)
    parser.add_argument('--workers', type=int, default=8)
    parser.add_argument('--refinements', type=int, default=3)
    parser.add_argument('--bins', nargs='*')
    parser.add_argument('--reuse-unchanged-from')
    options = parser.parse_args()
    record('Starting S09 '+options.mode+' with exact frozen inputs and generated transformations. Next inspect numerical gates and retain all signed channel contributions.')
    if options.mode == 'build':
        derive_and_build(); record('Native integrand built and input hashes gated. Next execute phase-space smoke checks.'); return
    contract = load('s09_cache/s09_build_result')
    assert contract['producer_sha256'] == sha(Path(__file__)), 'Rebuild S09 after a source change'
    if options.mode == 'smoke':
        print(json.dumps({k: v for k, v in smoke(options.points).items() if k != 'points'}, indent=2)); return
    selected = [b for b in bins() if not options.bins or b['id'] in options.bins]
    reuse_hash=None
    if options.reuse_unchanged_from:
        reuse_path=CACHE/'s09_reuse_result'
        if not reuse_path.exists() or load('s09_cache/s09_reuse_result')['build_sha256']!=sha(CACHE/'s09_build_result'):
            prepare_reuse(options.reuse_unchanged_from)
        reuse_hash=sha(reuse_path)
    def independent_seed(b):
        payload=(sha(CACHE/'s09_build_result')+b['id']+'six-current joint').encode()
        seed=int.from_bytes(hashlib.sha256(payload).digest()[:4],'big')
        assert not reuse_hash or seed!=load('s09_cache/s09_reuse_result')['bins'][b['id']]['old_seed']
        return seed
    tasks = [(b, options.neval, options.nitn, independent_seed(b), sha(CACHE/'s09_build_result'), options.refinements,reuse_hash) for b in selected]
    assert len({t[3] for t in tasks})==len(tasks)
    if reuse_hash:
        assert not {t[3] for t in tasks}&{b['old_seed'] for b in load('s09_cache/s09_reuse_result')['bins'].values()}
    results = []
    with ProcessPoolExecutor(max_workers=min(options.workers, len(tasks))) as pool:
        futures = [pool.submit(integrate_bin, task) for task in tasks]
        for future in as_completed(futures):
            result = future.result(); results.append(result)
            record('Bin '+result['id']+' integrated; values and covariance saved. Next complete remaining bins and check convergence.')
    results.sort(key=lambda r: (r['panel'], r['bin']))
    complete = len(results) == len(bins())
    result = dict(contract, status='Complete' if complete else 'IntegratedSelectedBins', bins=results,
                  reuse_sha256=reuse_hash,
                  neval=options.neval, nitn=options.nitn,
                  total_sigma_pb=np.sum([r['sigma_pb'] for r in results], axis=0).tolist(),
                  total_sigma_error_pb=np.sqrt(np.sum(np.square([r['sigma_error_pb'] for r in results]), axis=0)).tolist())
    result['panel_integrals'] = [dict(panel=panel, sigma_pb=np.sum([r['sigma_pb'] for r in results if r['panel']==panel],axis=0).tolist(),
        sigma_error_pb=np.sqrt(np.sum(np.square([r['sigma_error_pb'] for r in results if r['panel']==panel]),axis=0)).tolist())
        for panel in sorted({r['panel'] for r in results})]
    path = ROOT/'s09_result' if complete else CACHE/'s09_selected_result'
    write_json(path, result)
    record('S09 integrated '+str(len(results))+' bins with every precision and stability gate passing; results saved in '+str(path.relative_to(ROOT))+'. Next generate the requested cross-section and ratio plots when all 17 bins are present.')


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        record('S09 failed: '+repr(exc)[:1500]+'. No failed coefficient is replaced by zero. Next diagnose the originating failure and rerun dependent results.')
        raise
