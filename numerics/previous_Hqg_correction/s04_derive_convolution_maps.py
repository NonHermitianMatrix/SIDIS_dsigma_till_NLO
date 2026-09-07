#!/usr/bin/env python3
"""Tool-derived massless SIDIS maps, from Eqs. 2–18 of the reference paper."""
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT/'python_deps'))
import sympy as S
import json
import hashlib
from datetime import datetime, timezone


def record(message):
    with (ROOT.parent/'progress.md').open('a') as f:
        f.write('\nNumerics S04 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')


def main():
    record('Requested common six-channel convolution. Starting symbolic derivation '
           'of laboratory and partonic maps and Jacobians from the paper definitions. '
           'Next gate these identities and save s04_result.')
    Ee, Ep, Q2, y, xB, xi, zH, zeta, pt, s23, alphaEM = S.symbols(
        'Ee Ep Q2 y xB xi zH zeta pt s23 alphaEM', positive=True)
    phi = S.Symbol('phi', real=True)
    metric = S.diag(1,-1,-1,-1)
    dot = lambda a,b:S.factor(S.trigsimp((a.T*metric*b)[0]))
    P, ell = S.Matrix([Ep,0,0,Ep]), S.Matrix([Ee,0,0,-Ee])
    q0,qz,qTlab2 = S.symbols('q0 qz qTlab2', real=True)
    q = S.Matrix([q0,S.sqrt(qTlab2),0,qz])
    photon_definitions = [dot(q,q)+Q2, dot(P,q)-y*dot(P,ell), dot(ell-q,ell-q)]
    qr = S.solve(photon_definitions,[q0,qz,qTlab2],dict=True)
    assert len(qr)==1
    q = S.simplify(q.subs(qr[0]))
    e0,ez = S.symbols('e0 ez',real=True)
    e1 = S.Matrix([e0,1,0,ez])
    er = S.solve([dot(P,e1),dot(q,e1)],[e0,ez],dict=True)
    assert len(er)==1
    e1 = S.simplify(e1.subs(er[0]))
    e2 = S.Matrix([0,0,1,0])
    r = pt*(S.cos(phi)*e1+S.sin(phi)*e2)
    a,b = S.symbols('a b',real=True)
    PH = a*P+b*q+r
    hr = S.solve([dot(P,PH)-zH*dot(P,q),dot(PH,PH)],[a,b],dict=True)
    assert len(hr)==1
    PH = S.simplify(PH.subs(hr[0]))
    xb_def = S.factor(Q2/(2*dot(P,q)))
    beam_energy_product_rule = S.solve(S.Eq(xB,xb_def),Ep)[0]
    p,k1 = xi*P,PH/zeta
    invariants = {name:S.factor(value.subs(Ep,beam_energy_product_rule)) for name,value in {
        's':dot(p+q,p+q), 't':dot(q-k1,q-k1), 'u':dot(p-k1,p-k1),
        'recoil_mass2':dot(p+q-k1,p+q-k1),
        'xHat':Q2/(2*dot(p,q)), 'zHat':dot(p,k1)/dot(p,q)}.items()}
    zr = S.solve(S.Eq(invariants['recoil_mass2'],s23),zeta)
    assert len(zr)==1
    zeta_map = S.factor(zr[0])
    partonic = {k:S.factor(v.subs(zeta,zeta_map)) for k,v in invariants.items()}
    B = S.factor(S.solve(S.Eq(zeta_map,1),s23)[0])
    xi_min = S.factor(S.solve(S.Eq(B,0),xi)[0])
    z_roots = S.solve(S.Eq(B.subs(xi,1),0),zH)
    assert len(z_roots)==2
    root_probe={xB:S.Rational(1,1000),Q2:17,pt:3}
    z_roots.sort(key=lambda expression:float(expression.subs(root_probe)))
    J = S.factor(S.diff(zeta_map,s23))
    xy_jacobian = S.factor(S.det(S.Matrix([xb_def,y]).jacobian([Q2,y])))
    pt_jacobian = S.diff(pt**2,pt)
    # Eq. (6) is the defining cross section in the paper's W normalization.
    F1,F2 = S.symbols('F1 F2')
    sigma_density = S.pi**2*alphaEM**2/(zH*xB*y*Q2)*(xB*y**2*F1+(1-y)*F2)
    sigma_Q2_y_pt = S.factor((sigma_density*xy_jacobian*pt_jacobian).subs(xB,xb_def))
    W = (-metric+q*q.T/dot(q,q))*F1 + (
        P-q*dot(P,q)/dot(q,q))*(P-q*dot(P,q)/dot(q,q)).T/dot(P,q)*F2
    Pg = S.factor(S.trace(metric*W))
    Ppp = S.factor((P.T*metric*W*metric*P)[0])
    contraction_matrix = S.Matrix([Pg,Ppp]).jacobian([F1,F2])
    inverse = S.simplify(contraction_matrix.inv())
    checks = {
        'photon_virtuality':S.simplify(dot(q,q)+Q2)==0,
        'scattered_lepton_mass_shell':S.simplify(dot(ell-q,ell-q))==0,
        'pion_mass_shell':S.simplify(S.trigsimp(dot(PH,PH)))==0,
        'pion_z_definition':S.simplify(dot(P,PH)/dot(P,q)-zH)==0,
        'transverse_basis':S.simplify(dot(e1,e1)+1)==0 and dot(e1,e2)==0,
        'recoil_definition':S.simplify(partonic['recoil_mass2']-s23)==0,
        'mandelstam_sum':S.simplify(partonic['s']+partonic['t']+partonic['u']+Q2-s23)==0,
        'fragmentation_upper_limit':S.simplify(zeta_map.subs(s23,B)-1)==0,
        'incoming_lower_limit':S.simplify(B.subs(xi,xi_min))==0,
        'projector_inverse':S.simplify(inverse*contraction_matrix)==S.eye(2),
        'ordered_hadron_fraction_bounds':0<float(z_roots[0].subs(root_probe))<float(z_roots[1].subs(root_probe))<1,
    }
    assert all(checks.values()), checks
    # Original neutral-pion FF relation, also used by the EPHOX interface.
    D0,Dplus,Dminus = S.symbols('D0 Dplus Dminus')
    neutral = S.solve(S.Eq(D0,(Dplus+Dminus)/len([Dplus,Dminus])),D0)[0]
    expressions = dict(partonic, xB=xb_def, zeta=zeta_map, zeta0=zeta_map.subs(s23,0),
        B=B, xi_min=xi_min, jacobian=J, jacobian0=J.subs(s23,0),
        z_lower=z_roots[0], z_upper=z_roots[1],
        sigma_weight_F1=S.diff(sigma_Q2_y_pt,F1),
        sigma_weight_F2=S.diff(sigma_Q2_y_pt,F2),
        mu2=(Q2+pt**2)/len([Q2,pt**2]),
        pion_energy=PH[0],pion_px=PH[1],pion_py=PH[2],pion_pz=PH[3],
        neutral_pion_FF=neutral)
    benchmark_seeds=[{xB:S.Rational(23,100),xi:S.Rational(61,100),zH:S.Rational(37,100),
                      Q2:S.Integer(17),pt:S.Rational(37,100)*S.sqrt(S.Rational(31,10))},
                     {xB:S.Rational(1,1000),xi:S.Rational(14,10000),zH:S.Rational(2,5),
                      Q2:S.Integer(70),pt:S.Rational(5,2)}]
    benchmark_rows=[]
    for seed in benchmark_seeds:
        bv=S.factor(B.subs(seed))
        assert bv>0
        for fraction in [S.Rational(1,4),S.Rational(3,5)]:
            for endpoint in [True,False]:
                sr=S.Integer(0) if endpoint else fraction*bv
                sub=dict(seed);sub[s23]=sr
                row={str(k):v for k,v in seed.items()}
                row.update({k:v.subs(sub) for k,v in partonic.items() if k in ['s','t','u','xHat']})
                row.update(s23=sr,B=bv,mu2=expressions['mu2'].subs(seed),PHT2=seed[pt]**2)
                benchmark_rows.append(dict(endpoint=endpoint,
                    branch=int(S.sign(row['s']+row['t'])),
                    exact={k:S.sstr(v) for k,v in row.items()},
                    numeric={k:float(v) for k,v in row.items()}))
    assert {r['branch'] for r in benchmark_rows}=={-1,1}
    result = dict(stage='s04',status='Complete', checks=checks,
        producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        reference='authoritative SIDIS paper Eqs. (2)–(18); original theory common scale; H1 beam and pion cuts',
        defining_physics_inputs=dict(Ee_GeV='27.6',Ep_GeV='820',
            lab_theta_degrees=['5','25'],lab_Epi_over_Ep_min='0.01',
            massless_kinematics=True, azimuth='uniform, as the authoritative F1/F2 calculation omits azimuth-dependent terms',
            common_scale='(Q2+pT**2)/2',PDF='MRST2002 NLO',FF=['KKP NLO pi0','Kretzer NLO neutral-pion isospin average']),
        expressions={k:S.sstr(v) for k,v in expressions.items()},
        c_expressions={k:S.ccode(v) for k,v in expressions.items()},
        benchmark_rows=benchmark_rows,
        tensor_projector_inverse=[[S.sstr(v) for v in row] for row in inverse.tolist()])
    (ROOT/'s04_result').write_text(json.dumps(result,indent=2)+'\n')
    record('Symbolic maps completed with every embedded identity check passing; '
           'definitions, generated expressions and C expressions saved in s04_result. '
           'No numerical cross section produced. Next prepare the common hard-function evaluator '
           'and original PDF/FF library, then perform convolution.')
    print(json.dumps({'status':result['status'],'checks':checks},indent=2))


if __name__=='__main__':
    try:
        main()
    except Exception as exc:
        record('Stage failed: '+repr(exc)+'. No dependent convolution authorized by this stage; next fix and rerun S04.')
        raise
