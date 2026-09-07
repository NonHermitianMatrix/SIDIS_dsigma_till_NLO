#!/usr/bin/env python3
"""Derive flavor sums, H1 azimuthal acceptance, and distribution test actions."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'python_deps'))
import ast,json,hashlib
from datetime import datetime,timezone
import sympy as S
import numpy as np

def record(message):
    with (ROOT.parent/'progress.md').open('a') as f:
        f.write('\nNumerics S08 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    record('Starting tool-derived flavor luminosities, uniform-azimuth H1 acceptance and bounded-distribution actions. '
           'Next save s08_result only after reconstruction and numerical acceptance checks.')
    maps=json.loads((ROOT/'s04_result').read_text());inputs=json.loads((ROOT/'s06_result').read_text())
    assert maps['status']==inputs['status']=='Complete'
    model=ROOT.parent/'Hqqbar/madgraph_check/software/MG5_aMC_v3_7_0/models/sm/particles.py'
    model_charges={}
    for node in ast.parse(model.read_text()).body:
        if isinstance(node,ast.Assign) and isinstance(node.value,ast.Call) and getattr(node.value.func,'id',None)=='Particle':
            args={k.arg:k.value for k in node.value.keywords}
            name=ast.literal_eval(args['name'])
            if name in ['u','d','s','c','b']:
                model_charges[name]=S.sympify(ast.unparse(args['charge']))
    order=inputs['flavor_order'];f=S.symbols('f0:'+str(len(order)));d=S.symbols('d0:'+str(len(order)))
    charge={};species={}
    for i,name in enumerate(order):
        if name=='g':charge[i]=S.Integer(0);species[i]='g'
        else:
            species[i]=name.replace('bar','');charge[i]=model_charges[species[i]]*(-1 if 'bar' in name else 1)
    luminosities={};checks={}
    for active_names in [['u','d','s','c'],['u','d','s','c','b']]:
        active=[i for i in range(len(order)) if species[i] in active_names]
        quarks=[i for i in active if 'bar' not in order[i]]
        charge_types=list(dict.fromkeys(model_charges[name] for name in active_names))
        groups=[[i for i in active if model_charges[species[i]]==q] for q in charge_types]
        lum=dict(Hgg=sum(charge[i]**2 for i in quarks)*f[0]*d[0],
            Hgq_v3=f[0]*sum(charge[i]**2*d[i] for i in active),
            Hqg_v3=d[0]*sum(charge[i]**2*f[i] for i in active),
            Hqqbar=sum(charge[i]**2*f[i]*d[order.index(species[i] if 'bar' in order[i] else species[i]+'bar')] for i in active))
        hqq=[]
        for q,group in zip(charge_types,groups):
            other=[v for v in charge_types if v!=q];assert len(other)==1
            hqq.append(dict(charge=str(q),other_charge=str(other[0]),
                same_charge_flavor_count=sum(model_charges[name]==q for name in active_names),
                other_charge_flavor_count=sum(model_charges[name]!=q for name in active_names),
                expression=S.sstr(sum(f[i]*d[i] for i in group)),
                c_expression=S.ccode(sum(f[i]*d[i] for i in group))))
        pairs=[(i,j) for i in active for j in active if species[i]!=species[j]]
        for label,weight in [('IncomingChargeSquared',lambda i,j:charge[i]**2),
                             ('PrimeChargeSquared',lambda i,j:charge[j]**2),
                             ('MixedIncomingPrimeCharge',lambda i,j:charge[i]*charge[j])]:
            lum['Hqqprime_'+label]=sum(weight(i,j)*f[i]*d[j] for i,j in pairs)
        neutral_rules={d[i]:d[order.index(species[i])] for i in active if 'bar' in order[i]}
        checks['neutral_interference_cancellation_nf'+str(len(quarks))]=S.expand(lum['Hqqprime_MixedIncomingPrimeCharge'].subs(neutral_rules))==0
        checks['unique_ordered_flavor_pairs_nf'+str(len(quarks))]=len(pairs)==len(set(pairs)) and all(species[i]!=species[j] for i,j in pairs)
        luminosities[str(len(quarks))]=dict(active_indices=active,active_species=active_names,
            hqq_charge_groups=hqq,ordered_prime_pairs=pairs,
            expressions={k:S.sstr(v) for k,v in lum.items()},c_expressions={k:S.ccode(v) for k,v in lum.items()})
    symbols={name:S.Symbol(name,real=True) for name in ['Q2','Ee','Ep','y','pt','zH','phi']}
    E=S.sympify(maps['expressions']['pion_energy'],locals=symbols)
    pz=S.sympify(maps['expressions']['pion_pz'],locals=symbols)
    cphi,ctheta,Emin=S.symbols('cphi ctheta Emin',real=True)
    E=E.subs(S.cos(symbols['phi']),cphi);pz=pz.subs(S.cos(symbols['phi']),cphi)
    energy_root=S.factor(S.solve(S.Eq(E,Emin),cphi)[0])
    theta_root=S.factor(S.solve(S.Eq(pz/E,ctheta),cphi)[0])
    monotonic=S.factor(S.diff(pz/E,cphi))
    lo,hi=S.symbols('lo hi',real=True)
    phi=S.Symbol('angle',real=True)
    accepted_fraction=S.integrate(1/(2*S.pi),(phi,S.acos(hi),S.acos(lo)))+S.integrate(
        1/(2*S.pi),(phi,2*S.pi-S.acos(lo),2*S.pi-S.acos(hi)))
    keys=list(symbols);args=[symbols[k] for k in keys if k!='phi']
    er=S.lambdify(args+[Emin],energy_root,'numpy');tr=S.lambdify(args+[ctheta],theta_root,'numpy')
    evalE=S.lambdify(args+[cphi],E,'numpy');evalPz=S.lambdify(args+[cphi],pz,'numpy')
    deriv=S.lambdify(args+[cphi],monotonic,'numpy');fraction=S.lambdify([lo,hi],accepted_fraction,'numpy')
    acceptance_checks=[]
    angles=np.linspace(0,2*np.pi,100001,endpoint=False)
    for Q2 in [3.,10.,35.]:
        for z in [.005,.02,.1,.4]:
            physical=dict(Q2=Q2,Ee=27.6,Ep=820.,y=.3,pt=3.,zH=z)
            v=[physical[k] for k in keys if k!='phi'];emin=.01*physical['Ep']
            lower=max(-1.,float(er(*v,emin)),float(tr(*v,np.cos(np.deg2rad(25.)))))
            upper=min(1.,float(tr(*v,np.cos(np.deg2rad(5.)))))
            analytic=0. if lower>=upper else float(fraction(lower,upper))
            energies=evalE(*v,np.cos(angles));longitudinal=evalPz(*v,np.cos(angles))
            direct=np.mean((energies>emin)&(longitudinal/energies>np.cos(np.deg2rad(25.)))&
                           (longitudinal/energies<np.cos(np.deg2rad(5.))))
            assert float(deriv(*v,0))>0
            acceptance_checks.append(dict(inputs=physical,analytic=analytic,angular_quadrature=float(direct),difference=float(analytic-direct)))
    checks['azimuthal_acceptance']=all(abs(r['difference'])<3e-5 for r in acceptance_checks)
    B,ss=S.symbols('B ss',positive=True);a=S.symbols('a0:3');test=sum(a[k]*ss**k for k in range(len(a)))
    actions={}
    for convention,logarithm in [('Hqq_v2_and_Hgq_v3',S.log(ss)),('Hqg_v3',S.log(ss/B))]:
        actions[convention]={str(k):S.sstr(S.integrate(logarithm**k/ss*(test-test.subs(ss,0)),(ss,0,B))) for k in [0,1]}
        checks['constant_annihilation_'+convention]=all(S.sympify(v,locals={'B':B,**dict(zip(['a0','a1','a2'],a))}).subs({a[1]:0,a[2]:0})==0 for v in actions[convention].values())
    assert all(checks.values()),checks
    result=dict(stage='s08',status='Complete',producer_sha256=sha(Path(__file__)),
        inputs={p.name:sha(p) for p in [ROOT/'s04_result',ROOT/'s06_result',model]},
        model_charges={k:str(v) for k,v in model_charges.items()},flavor_order=order,luminosities=luminosities,
        azimuthal_acceptance=dict(energy_cosine_bound=S.sstr(energy_root),theta_cosine_bound=S.sstr(theta_root),
            fraction=S.sstr(accepted_fraction),monotonic_derivative=S.sstr(monotonic),
            c_energy_cosine_bound=S.ccode(energy_root),c_theta_cosine_bound=S.ccode(theta_root),
            c_fraction=S.ccode(accepted_fraction),validation=acceptance_checks),
        plus_distribution_actions=actions,
        distribution_policy='Each coefficient times its smooth luminosity/Jacobian test factor is endpoint-subtracted as one product. Delta and Born factors use s23=0. Included Jacobians are never applied again.',
        checks=checks)
    (ROOT/'s08_result').write_text(json.dumps(result,indent=2)+'\n')
    record('Flavor sums, pion interference identity, azimuthal acceptance and polynomial plus-distribution checks completed; '
           'all gates passed and exact generated definitions saved in s08_result. No cross section integrated yet. '
           'Next execute the six-channel PDF/FF convolution in the published H1 bins.')
    print(json.dumps({'status':result['status'],'checks':checks},indent=2))

if __name__=='__main__':
    try:main()
    except Exception as exc:record('Stage failed: '+repr(exc)+'. Next correct S08 before production integration.');raise
