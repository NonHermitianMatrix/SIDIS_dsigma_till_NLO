#!/usr/bin/env python3
"""Derive flavor sums, H1 azimuthal acceptance, and distribution test actions."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'python_deps'))
import ast,json,hashlib
from datetime import datetime,timezone
import sympy as S
from sympy.printing.mathematica import mathematica_code
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
    names=['Hqq_v4','Hgg_v2','Hqqbar_v2','Hqqprime_v2','Hgq_v4','Hqg_v3']
    contract_paths={ch:ROOT/'s03_cache'/(ch+'_consumer_contract') for ch in names}
    contracts={ch:json.loads(p.read_text()) for ch,p in contract_paths.items()}
    manifest=json.loads((ROOT/'s01_result').read_text())
    for ch,c in contracts.items():
        assert c['Status']=='Complete' and all(c['Checks'].values()) and c['JacobianAlreadyIncluded'] is False
        payload=next(f for row in manifest['channels'] if row['channel']==ch for f in row['files'] if f['role']=='terminal_fhat_payload')
        assert c['InputSHA256']==sha(ROOT/payload['copy'])
    contract=contracts['Hgq_v4']
    model=ROOT.parent/'Hgq_v4/madgraph_check/software/MG5_aMC_v3_7_0/models/sm/particles.py'
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
        lum=dict(Hgg_v2=sum(charge[i]**(2*contracts["Hgg_v2"]["ChargeParameterDegree"]) for i in quarks)*f[0]*d[0],
            Hgq_v4=f[0]*sum(charge[i]**contracts["Hgq_v4"]["ChargeDegree"]*d[i] for i in active),
            Hqg_v3=d[0]*sum(charge[i]**contracts["Hqg_v3"]["ChargeDegree"]*f[i] for i in active),
            Hqqbar_v2=sum(charge[i]**(2*contracts["Hqqbar_v2"]["ChargeParameterDegree"])*f[i]*d[order.index(species[i] if 'bar' in order[i] else species[i]+'bar')] for i in active))
        moments=[]
        charge_values={S.Symbol('charge'+str(i+1)):model_charges[name] for i,name in enumerate(active_names)}
        for row in contracts['Hqq_v4']['FlavorMoments'][str(len(quarks))]:
            values={k:S.sympify(v).subs(charge_values) for k,v in row['Moments'].items()}
            observed=row['ObservedIndex']
            checks['hqq_moment_sum_nf%d_flavor%d'%(len(quarks),observed)]=all(
                S.simplify(values[k]-sum(model_charges[name]**int(k) for j,name in enumerate(active_names) if j!=observed))==0 for k in values)
            moments.append(values)
        hqq=[]
        for q,group in zip(charge_types,groups):
            indices=[j for j,name in enumerate(active_names) if model_charges[name]==q]
            assert all(moments[j]==moments[indices[0]] for j in indices)
            hqq.append(dict(charge=str(q),other_moment1=str(moments[indices[0]]['1']),
                other_moment2=str(moments[indices[0]]['2']),
                expression=S.sstr(sum(f[i]*d[i] for i in group)),
                c_expression=S.ccode(sum(f[i]*d[i] for i in group))))
        pairs=[(i,j) for i in active for j in active if species[i]!=species[j]]
        eq,eqp=S.symbols('eq eqp')
        for label,key in [('IncomingChargeSquared','eq2'),('PrimeChargeSquared','eqp2'),('MixedIncomingPrimeCharge','eq_eqp')]:
            monomial=S.sympify(contracts['Hqqprime_v2']['ChargeMonomials'][key])
            lum['Hqqprime_v2_'+label]=sum(monomial.subs({eq:charge[i],eqp:charge[j]})*f[i]*d[j] for i,j in pairs)
        neutral_rules={d[i]:d[order.index(species[i])] for i in active if 'bar' in order[i]}
        checks['neutral_interference_cancellation_nf'+str(len(quarks))]=S.expand(lum['Hqqprime_v2_MixedIncomingPrimeCharge'].subs(neutral_rules))==0
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
    plus_arguments={ch:S.sympify(contracts[ch]['PlusLogArgument'],locals={'ss':ss,'B':B}) for ch in ['Hqq_v4','Hqg_v3','Hgq_v4']}
    for convention,argument in plus_arguments.items():
        logarithm=S.log(argument)
        actions[convention]={str(k):S.sstr(S.integrate(logarithm**k/ss*(test-test.subs(ss,0)),(ss,0,B))) for k in [0,1]}
        checks['constant_annihilation_'+convention]=all(S.sympify(v,locals={'B':B,**dict(zip(['a0','a1','a2'],a))}).subs({a[1]:0,a[2]:0})==0 for v in actions[convention].values())
    # Derive coordinates on the saved v4 branch boundary from S04 relations.
    symbols0={name:S.Symbol(name) for name in ['Q2','xi','xB','zH','pt','s23']}
    expression={name:S.sympify(value) for name,value in maps['expressions'].items()}
    boundary_rows=[]
    for seed_row in maps['benchmark_rows']:
        seed={symbols0[k]:S.sympify(seed_row['exact'][k]) for k in ['Q2','xB','zH','pt']}
        fraction=S.sympify(seed_row['exact']['s23'])/S.sympify(seed_row['exact']['B'])
        solutions=S.solve([S.Eq((expression['s']+expression['t']).subs(seed),0),
            S.Eq(symbols0['s23'],fraction*expression['B'].subs(seed))],
            [symbols0['xi'],symbols0['s23']],dict=True)
        for solution in solutions:
            incoming=solution[symbols0['xi']]
            if not (incoming.is_real and 0<incoming<1):continue
            base={**seed,**solution}
            bound=S.factor(expression['B'].subs(base))
            if not bound>0:continue
            recoil=solution[symbols0['s23']]
            base[symbols0['s23']]=recoil
            row={k:base[symbols0[k]] for k in ['Q2','xi','xB','zH','pt']}
            row.update({k:S.factor(expression[k].subs(base)) for k in ['s','t','u','xHat','mu2']})
            row.update(s23=recoil,B=bound,PHT2=base[symbols0['pt']]**2)
            assert S.simplify(row['s']+row['t'])==0 and row['s']>0 and row['t']<0
            boundary_rows.append(dict(endpoint=seed_row['endpoint'],branch=0,
                exact={k:mathematica_code(v) for k,v in row.items()},numeric={k:float(v) for k,v in row.items()}))
    checks['v4_boundary_coordinates']=bool(boundary_rows) and {r['endpoint'] for r in boundary_rows}=={True,False}
    assert all(checks.values()),checks
    result=dict(stage='s08',status='Complete',producer_sha256=sha(Path(__file__)),
        inputs={p.name:sha(p) for p in [ROOT/'s04_result',ROOT/'s06_result',model,*contract_paths.values()]},
        model_charges={k:str(v) for k,v in model_charges.items()},flavor_order=order,luminosities=luminosities,
        azimuthal_acceptance=dict(energy_cosine_bound=S.sstr(energy_root),theta_cosine_bound=S.sstr(theta_root),
            fraction=S.sstr(accepted_fraction),monotonic_derivative=S.sstr(monotonic),
            c_energy_cosine_bound=S.ccode(energy_root),c_theta_cosine_bound=S.ccode(theta_root),
            c_fraction=S.ccode(accepted_fraction),validation=acceptance_checks),
        plus_distribution_actions=actions,
        plus_log_arguments={k:S.sstr(v) for k,v in plus_arguments.items()},
        v4_boundary_benchmark_rows=boundary_rows,
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
