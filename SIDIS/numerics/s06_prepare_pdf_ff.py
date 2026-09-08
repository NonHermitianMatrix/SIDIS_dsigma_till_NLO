#!/usr/bin/env python3
"""Build and validate the original-paper PDF/FF library under scripts/."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'python_deps'))
import ctypes as C
import hashlib
import json
import os
import re
import shutil
import subprocess
import tarfile
from datetime import datetime,timezone
import numpy as np
from scipy.integrate import quad
from scipy.optimize import brentq
from scipy import constants


def record(message):
    line = "SIDIS numerics S06 " + datetime.now(timezone.utc).isoformat() + ": " + message
    if os.environ.get("SIDIS_CLUSTER_RUN") == "1":
        print("PROGRESS " + line, flush=True)
        return
    with (Path(__file__).resolve().parents[2] / "progress.md").open("a") as stream:
        stream.write("\n" + line + "\n")

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    record('Requested original Fig. 3 PDF/FF inputs. Starting original Fortran '
           'library build, PDF/FF convention gates and coupling calibration. '
           'Next save s06_result only after the checks pass.')
    vendor=ROOT/'vendor'; ephox=vendor/'ephox'; mrst=vendor/'mrst2002'
    cache=ROOT/'s06_cache'
    for p in [vendor,ephox,mrst,cache]:p.mkdir(exist_ok=True)
    archive=ROOT/'references/ephox_1.1.tar.gz'
    with tarfile.open(archive) as tf:
        for name in ['frag/hadron/kkp.f','frag/hadron/pkhff.f','frag/hadron/pnlo.grid',
                     'src/miscel/alfab.f','src/main/fragfun_all.f']:
            (ephox/Path(name).name).write_bytes(tf.extractfile('ephox_1.1/'+name).read())
    reuse=json.loads((ROOT/'s01_reuse_manifest.json').read_text())
    for name in ['vendor/model/parameters.py','vendor/mrst2002/mrst2002.f',
                 'vendor/mrst2002/jeppe02.f','vendor/mrst2002/mrst2002nlo.dat',
                 'references/original_s06_result.json']:
        assert sha(ROOT/name)==reuse['CommonInputs'][name]['SHA256'],name
    previous=json.loads((ROOT/'references/original_s06_result.json').read_text())
    assert previous['status']=='Complete' and all(previous['checks'].values())
    reader=(mrst/'mrst2002.f').read_text()
    assert '0.1197' in reader and float((mrst/'mrst2002nlo.dat').read_text().split()[0])==0.00949
    mc2=float(re.search(r'emc2\s*=\s*([.\d]+)',reader).group(1))
    mb2=float(re.search(r'emb2\s*=\s*([.\d]+)',reader).group(1))
    smparams=(vendor/'model/parameters.py').read_text()
    mz=float(re.search(r'^MZ\s*=\s*Parameter\(.*?value\s*=\s*([.\d]+)',smparams,re.M|re.S).group(1))
    adapted=(ephox/'pkhff.f').read_text().replace("'../frag/hadron/", "'"+str(ephox)+'/')
    (cache/'s06_pkhff_adapted.f').write_text(adapted)
    # Only file-path adaptation is made to the original interpolation routine.
    assert adapted.replace("'"+str(ephox)+'/',"'../frag/hadron/")==(ephox/'pkhff.f').read_text()
    bridge=f'''subroutine OpenData(filename)
  implicit none
  character(*) filename
  integer IU
  common /IU/ IU
  open(newunit=IU,file='{mrst}/'//trim(filename),status='old',action='read')
end subroutine
subroutine sidis_pdf(x,q,output) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: x,q
  real(c_double) :: output(8),xx,qq
  integer mode
  xx=x
  qq=q
  mode=1
  call mrst2002(xx,qq,mode,output(1),output(2),output(3),output(4), &
                output(5),output(6),output(7),output(8))
end subroutine
subroutine sidis_kkp(z,q,ih,output) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: z,q
  integer(c_int),value :: ih
  real(c_double) :: output(0:10),zz,qq
  integer iset,hadron
  zz=z
  qq=q
  hadron=ih
  iset=1
  call kkp(hadron,iset,zz,qq,output)
end subroutine
subroutine sidis_kretzer(z,q2,charge,output) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: z,q2
  integer(c_int),value :: charge
  real(c_double) :: output(0:10),zz,qq2
  integer iset,icharge
  zz=z
  qq2=q2
  iset=2
  icharge=charge
  call pkhff(iset,icharge,zz,qq2,output(1:2),output(3:4), &
             output(5:6),output(7:8),output(9:10),output(0))
end subroutine
subroutine sidis_set_alpha(mc2,mb2,lambda2) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: mc2,mb2,lambda2
  real(c_double) :: masch2,masbo2,masto2,lambda4square
  common /alfa/ masch2,masbo2,masto2,lambda4square
  masch2=mc2
  masbo2=mb2
  masto2=huge(masto2)
  lambda4square=lambda2
end subroutine
function sidis_alpha(q2) result(a) bind(C)
  use iso_c_binding
  implicit none
  real(c_double),value :: q2
  real(c_double) :: a,alfas,qq2
  integer loops
  external alfas
  qq2=q2
  loops=2
  a=alfas(loops,qq2)
end function
'''
    (cache/'s06_interface.f90').write_text(bridge)
    library=cache/'s06_pdf_ff.so'
    command=[os.environ.get('FC','gfortran'),'-shared','-fPIC','-O2','-std=legacy','-ffixed-line-length-none',
             '-ffree-line-length-none','-fallow-argument-mismatch',str(mrst/'mrst2002.f'),
             str(mrst/'jeppe02.f'),str(ephox/'kkp.f'),str(cache/'s06_pkhff_adapted.f'),
             str(ephox/'alfab.f'),str(cache/'s06_interface.f90'),'-o',str(library)]
    build=subprocess.run(command,cwd=cache,text=True,capture_output=True,timeout=50)
    (cache/'s06_build.log').write_text(build.stdout+build.stderr)
    assert build.returncode==0,build.stderr
    lib=C.CDLL(str(library)); arr=np.ctypeslib.ndpointer(dtype=np.float64,ndim=1,flags='C_CONTIGUOUS')
    lib.sidis_pdf.argtypes=[C.c_double,C.c_double,arr]
    lib.sidis_kkp.argtypes=lib.sidis_kretzer.argtypes=[C.c_double,C.c_double,C.c_int,arr]
    lib.sidis_alpha.argtypes=[C.c_double];lib.sidis_alpha.restype=C.c_double
    lib.sidis_set_alpha.argtypes=[C.c_double,C.c_double,C.c_double]
    def raw_pdf(x,q):
        v=np.empty(8);lib.sidis_pdf(x,q,v);return v
    def raw_ff(name,z,q,charge):
        v=np.empty(11);getattr(lib,'sidis_'+name)(z,q,charge,v);return v
    def alphafit(lambda2):
        lib.sidis_set_alpha(mc2,mb2,lambda2)
        return lib.sidis_alpha(mz*mz)-0.1197
    lambda2=brentq(alphafit,0.001,0.5,xtol=1e-13)
    lib.sidis_set_alpha(mc2,mb2,lambda2)
    checks={'alpha_at_MZ':abs(lib.sidis_alpha(mz*mz)-0.1197)<1e-10}
    qprobe=10.
    # The native MRST interface returns x*f; valence-count checks establish this.
    valence=[quad(lambda lx:raw_pdf(np.exp(lx),qprobe)[i],np.log(1e-5),0,
                  epsabs=0.002,limit=150)[0] for i in [0,1]]
    proton_valence=['u','u','d']
    low_x=np.array([1e-5,2e-5,4e-5,6e-5])
    small_x_fits=[np.polyfit(np.log(low_x),np.log([raw_pdf(x,qprobe)[i] for x in low_x]),1)
                  for i in [0,1]]
    omitted_valence=[quad(lambda lx:np.exp(np.polyval(fit,lx)),-np.inf,np.log(low_x[0]))[0]
                     for fit in small_x_fits]
    checks['valence_number_sum_rules']=all(abs(v+tail-proton_valence.count(flavor))<0.02
                                         for v,tail,flavor in zip(valence,omitted_valence,['u','d']))
    def momentum_density(x):
        v=raw_pdf(x,qprobe)
        return v[0]+v[1]+v[-1]+len(['q','qbar'])*sum(v[2:-1])
    momentum=quad(momentum_density,1e-5,1,epsabs=.002,limit=150)[0]
    checks['momentum_sum_rule']=abs(momentum-1)<.025
    probes=[]
    for z,q in [(.1,3.),(.3,5.),(.7,10.)]:
        kkp=raw_ff('kkp',z,q,5)
        kkp_iso=raw_ff('kkp',z,q,1)
        plus=raw_ff('kretzer',z,q*q,1);minus=raw_ff('kretzer',z,q*q,2)
        charged=raw_ff('kretzer',z,q*q,3)
        checks[f'KKP_pi0_identity_{z}']=bool(np.allclose(kkp,kkp_iso,rtol=1e-12,atol=1e-14))
        checks[f'Kretzer_charge_sum_{z}']=bool(np.allclose(plus+minus,charged,rtol=1e-12,atol=1e-14))
        checks[f'finite_FFs_{z}']=bool(np.isfinite(kkp).all() and np.isfinite(charged).all())
        probes.append(dict(z=z,Q_GeV=q,KKP_pi0=kkp.tolist(),Kretzer_charged_sum=charged.tolist()))
    assert all(checks.values()),(checks,valence,momentum)
    inputs=[p for p in [archive,vendor/'model/parameters.py',*ephox.iterdir(),*mrst.iterdir()] if p.is_file()]
    result=dict(stage='s06',status='Complete',producer_sha256=sha(Path(__file__)),
        input_hashes={str(p.relative_to(ROOT.parent)):sha(p) for p in inputs},
        library=str(library.relative_to(ROOT)),library_sha256=sha(library),
        PDF='MRST2002 mode=1 NLO original interpolation; x*f output',
        FFs=['KKP ih=5 iset=1 (pi0)','Kretzer iset=2, (pi+ + pi-)/2'],
        flavor_order=['g','u','ubar','d','dbar','s','sbar','c','cbar','b','bbar'],
        raw_pdf_order=['x_uv','x_dv','x_ubar','x_dbar','x_s','x_c','x_b','x_g'],
        alpha=dict(prescription='original EPHOX implicit two-loop running with continuous bottom threshold, calibrated to MRST alpha_s(MZ)',
            alpha_MZ=.1197,MZ_GeV=mz,mc2_GeV2=mc2,mb2_GeV2=mb2,lambda4_squared_GeV2=lambda2,
            samples={str(q):lib.sidis_alpha(q*q) for q in [2.5,5.,10.,mz]}),
        alpha_EM=previous['alpha_EM'],
        GeV_minus2_to_pb=previous['GeV_minus2_to_pb'],
        unchanged_constants_source_sha256=sha(ROOT/'references/original_s06_result.json'),
        checks=checks,validation=dict(valence_above_grid_xmin=valence,
            small_x_tail_estimate=omitted_valence,
            tail_policy='log-power extrapolation used only for this sum-rule diagnostic, never for production PDFs',
            momentum=momentum,FF_probes=probes),
        sources=['https://lapth.cnrs.fr/PHOX_FAMILY/src/ephox_1.1.tar.gz',
                 'https://arxiv.org/abs/hep-ph/0211080','https://arxiv.org/abs/hep-ph/0411212'])
    (ROOT/'s06_result').write_text(json.dumps(result,indent=2)+'\n')
    record('Original PDF/FF library completed; all sum-rule, pion-charge and coupling checks passed. '
           's06_result binds vendor hashes, compiled library and numeric validation. '
           'Vendor copies and build products have production/provenance value. '
           'Next use this library with validated imported hard functions in the convolution.')
    print(json.dumps({'status':result['status'],'checks':checks,'valence':valence,'momentum':momentum},indent=2))


if __name__=='__main__':
    try:main()
    except Exception as exc:
        record('Stage failed: '+repr(exc)+'. Next correct S06 before using the library.');raise
