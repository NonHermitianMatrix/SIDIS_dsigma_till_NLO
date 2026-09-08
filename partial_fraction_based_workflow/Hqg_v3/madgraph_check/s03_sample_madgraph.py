"""Reconstruct Hqg Pg/Ppp from fresh photon-only MadGraph matrix elements."""
from pathlib import Path
from collections import Counter
import ctypes as ct
import hashlib
import json
import math
import os
import random
import re
import subprocess
import sys

for name in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS"):
    os.environ[name] = "1"
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent
sys.path[:0] = [str(ROOT / "software"), str(ROOT / "software/MG5_aMC_v3_7_0")]
import numpy as np
import sympy as sp
from sympy.physics.matrices import mgamma
from madgraph.various import rambo

manifest = json.loads((ROOT / "s01_result.json").read_text())
particles = manifest["Particles"]
eta = np.diag([1., -1., -1., -1.])
gamma = [np.array(mgamma(i)).astype(complex) for i in range(eta.shape[0])]
lower_gamma = [sum(eta[i, j] * gamma[j] for j in range(len(gamma))) for i in range(len(gamma))]
SEED, POINTS_PER_PROCESS, ENERGY = 20260905, 8, 100.
random.seed(SEED)


def sha(path):
    with path.open("rb") as f:
        return hashlib.file_digest(f, "sha256").hexdigest()


def gate(test, label):
    if not test:
        raise RuntimeError(label)
    print("PASS:", label, flush=True)


def dot(a, b):
    return float(a @ eta @ b)


def slash(v):
    return sum((eta @ v)[i] * gamma[i] for i in range(len(gamma)))


def lepton_tensor(lin, lout):
    value = np.array([[np.trace(slash(lout) @ lower_gamma[i] @ slash(lin) @ lower_gamma[j])
                       for j in range(len(gamma))] for i in range(len(gamma))])
    gate(np.max(np.abs(value.imag)) <= 1e-12 * max(np.max(np.abs(value.real)), 1e-30),
         "lepton trace is real")
    return value.real / particles["e-"]["spin"]


# Solve the defining lepton mass-shell and p.l conditions in the p,q transverse basis.
a, b, rho, pq, qq, pl = sp.symbols("a b rho pq qq pl", real=True)
gram = sp.Matrix([[0, pq, 0, 0], [pq, qq, 0, 0], [0, 0, -1, 0], [0, 0, 0, -1]])
p_basis, q_basis = sp.eye(4)[:, 0], sp.eye(4)[:, 1]
l_basis = sp.Matrix([a, b, sp.sqrt(rho), 0])
sdot = lambda v, w: (v.T * gram * w)[0]
solutions = sp.solve([sdot(l_basis, p_basis)-pl, sdot(l_basis, l_basis),
                      sdot(l_basis-q_basis, l_basis-q_basis)], [a, b, rho], dict=True)
gate(len(solutions) == 1, "unique lepton mass-shell map")
lepton_map = solutions[0]
lepton_parameters = sp.lambdify((pq, qq, pl), [lepton_map[x] for x in (a, b, rho)], "numpy")
gate(all(sp.simplify(e.subs(lepton_map)) == 0 for e in
         [sdot(l_basis, p_basis)-pl, sdot(l_basis, l_basis),
          sdot(l_basis-q_basis, l_basis-q_basis)]), "lepton map reconstructs defining constraints")

# The actual trace is bilinear in two vectors, each linear in cos(phi),sin(phi).
c, sn, phi = sp.symbols("c sn phi", real=True)
x = sp.symbols("x:6")
azimuth_polynomial = sp.Poly((x[0]+x[1]*c+x[2]*sn)*(x[3]+x[4]*c+x[5]*sn), c, sn)
n_angles = azimuth_polynomial.total_degree() + 2
angles = [2*sp.pi*k/n_angles for k in range(n_angles)]
for i, j in azimuth_polynomial.monoms():
    integrand = sp.cos(phi)**i * sp.sin(phi)**j
    continuous = sp.integrate(integrand, (phi, 0, 2*sp.pi))/(2*sp.pi)
    discrete = sum(integrand.subs(phi, angle) for angle in angles)/len(angles)
    gate(sp.simplify(continuous-discrete) == 0, "exact azimuth quadrature " + str((i, j)))
angles_numeric = np.array([float(angle) for angle in angles])


def build_process(kind):
    process = ROOT / kind
    directories = [p for p in (process / "SubProcesses").glob("P*") if p.is_dir()]
    gate(len(directories) == 1, kind + " single subprocess")
    directory = directories[0]
    matrix = (directory / "matrix.f").read_text()
    description = re.search(r"Process:\s*(.*?)\n", matrix).group(1).strip()
    order_text = re.search(r"QCD<=\d+.*", description).group(0)
    process_text = description[:description.index(" QCD")]
    incoming, outgoing = [part.strip().split() for part in process_text.split(">")]
    nexternal = int(re.search(r"NEXTERNAL\s*=\s*(\d+)", matrix).group(1))
    iden = int(re.search(r"DATA\s+IDEN\s*/\s*(\d+)\s*/", matrix, re.I).group(1))
    diagrams = int(re.search(r"N_MAX_CG\s*=\s*(\d+)", (directory / "ngraphs.inc").read_text()).group(1))
    gate(nexternal == len(incoming+outgoing) and incoming == ["e-", "u"], kind + " leg ordering")
    gate(Counter(outgoing) == Counter(["e-", "u"] + ["g"] * (1 if kind == "born" else 2)),
         kind + " final species")
    counts = Counter(outgoing)
    symmetry = math.prod(math.factorial(count) for count in counts.values())
    initial_average = math.prod(particles[name]["spin"] * abs(particles[name]["color"]) for name in incoming)
    gate(iden == initial_average*symmetry, kind + " generated spin/color/symmetry denominator")
    tags = counts["g"]
    tag_weight = sp.Rational(tags, symmetry)
    tagged_conversion = tag_weight*sp.Rational(iden, initial_average)
    gate(tagged_conversion == tags, kind + " tagged-gluon normalization")
    gate(all(value == "ZERO" for value in re.findall(r"PMASS\(\d+\)\s*=\s*(\w+)",
                                                     (directory / "pmass.inc").read_text())),
         kind + " massless generated external states")
    bridge = directory / "s03_bridge.f"
    bridge.write_text("""      SUBROUTINE HQG_INIT(EEOUT,GSOUT,QUOUT,QEOUT)
     & BIND(C,NAME='hqg_init')
      USE ISO_C_BINDING
      IMPLICIT NONE
      INCLUDE 'coupl.inc'
      INCLUDE 'input.inc'
      REAL(C_DOUBLE), INTENT(OUT) :: EEOUT,GSOUT,QUOUT,QEOUT
      CALL SETPARA('param_card.dat')
      EEOUT=DBLE(MDL_EE)
      GSOUT=G
      QUOUT=ABS(GC_2/MDL_EE)
      QEOUT=ABS(GC_3/MDL_EE)
      END
      SUBROUTINE HQG_MATRIX(P,ANS) BIND(C,NAME='hqg_matrix')
      USE ISO_C_BINDING
      IMPLICIT NONE
      INCLUDE 'nexternal.inc'
      REAL(C_DOUBLE), INTENT(IN) :: P(0:3,NEXTERNAL)
      REAL(C_DOUBLE), INTENT(OUT) :: ANS
      CALL SMATRIX(P,ANS)
      END
""")
    libraries = [str(process / "lib/libdhelas.a"), str(process / "lib/libmodel.a")]
    flags = ["gfortran", "-O2", "-fPIC", "-ffixed-line-length-132", "-I.",
             "-I" + str(process / "Source/MODEL")]
    subprocess.run(flags + ["-c", "matrix.f", "-o", "matrix.o"], cwd=directory, check=True)
    library_path = directory / "s03_matrix.so"
    subprocess.run(flags + ["-shared", str(bridge), "matrix.o", *libraries, "-o", str(library_path)],
                   cwd=directory, check=True)
    library = ct.CDLL(str(library_path), mode=os.RTLD_LOCAL)
    library.hqg_init.argtypes = [ct.POINTER(ct.c_double)] * 4
    library.hqg_matrix.argtypes = [ct.POINTER(ct.c_double), ct.POINTER(ct.c_double)]
    constants = [ct.c_double() for _ in range(4)]
    previous = Path.cwd()
    os.chdir(directory)
    try:
        library.hqg_init(*(ct.byref(v) for v in constants))
    finally:
        os.chdir(previous)
    ee, gs, charge_u, charge_e = [v.value for v in constants]
    gate(all(math.isfinite(v) and v > 0 for v in [ee, gs, charge_u, charge_e]), kind + " runtime couplings")
    gate(math.isclose(charge_u, abs(particles["u"]["charge"]), rel_tol=1e-14), kind + " generated quark charge")
    gate(math.isclose(charge_e, abs(particles["e-"]["charge"]), rel_tol=1e-14), kind + " generated electron charge")

    def evaluate(momenta):
        array = np.ascontiguousarray(momenta, dtype=np.float64)
        answer = ct.c_double()
        library.hqg_matrix(array.ctypes.data_as(ct.POINTER(ct.c_double)), ct.byref(answer))
        gate(math.isfinite(answer.value) and answer.value >= 0, kind + " finite positive matrix element")
        return answer.value

    # Compare the C interface with the generated standalone driver at the same printed point.
    direct_source = (directory / "check_sa.f").read_text()
    gate("5e15.7" in direct_source, kind + " direct-driver precision format")
    (directory / "s03_direct_check.f").write_text(direct_source.replace("5e15.7", "5e26.17"))
    subprocess.run(flags + ["s03_direct_check.f", "matrix.o", *libraries, "-o", "s03_direct_check"],
                   cwd=directory, check=True)
    direct_output = subprocess.check_output([str(directory / "s03_direct_check")], cwd=directory, text=True)
    (directory / "s03_direct_check.log").write_text(direct_output)
    direct_momenta = []
    for line in direct_output.splitlines():
        fields = line.split()
        if len(fields) == 6 and fields[0].isdigit():
            direct_momenta.append([float(v.replace("D", "E")) for v in fields[1:5]])
    direct_value = float(re.search(r"Matrix element\s*=\s*([\d.+EeDd-]+)", direct_output).group(1).replace("D", "E"))
    gate(len(direct_momenta) == nexternal, kind + " direct-driver momentum coverage")
    bridge_value = evaluate(direct_momenta)
    gate(math.isclose(direct_value, bridge_value, rel_tol=1e-12, abs_tol=0), kind + " direct/bridge equality")
    info = {"Process": description, "Incoming": incoming, "Outgoing": outgoing,
            "PDGs": [particles[name]["pdg_code"] for name in incoming+outgoing],
            "DiagramCount": diagrams, "IDEN": iden, "InitialAverageDenominator": initial_average,
            "FinalSymmetryDenominator": symmetry, "GluonTags": tags,
            "TagWeight": str(tag_weight), "TaggedMadGraphFactor": float(tagged_conversion),
            "CouplingOrders": {name: int(re.search(name+r"<=(\d+)", order_text).group(1)) for name in ["QED", "QCD"]},
            "Couplings": {"e": ee, "gs": gs, "QuarkChargeAbs": charge_u, "ElectronChargeAbs": charge_e},
            "DirectBridgeRelativeDifference": abs(direct_value-bridge_value)/max(abs(direct_value),abs(bridge_value)),
            "Files": {str(path.relative_to(ROOT)): sha(path) for path in
                      [directory / "matrix.f", bridge, library_path, process / "Cards/param_card.dat"]}}
    return evaluate, info


def check_momenta(momenta, nin, label):
    scale = max(np.max(np.abs(momenta)), 1.)
    gate(np.max(np.abs(np.sum(momenta[:nin], axis=0)-np.sum(momenta[nin:], axis=0))) < 1e-10*scale,
         label + " conservation")
    gate(max(abs(dot(v, v)) for v in momenta) < 1e-10*scale**2, label + " masslessness")
    gate(np.min(momenta[:, 0]) > 0, label + " positive energies")


def sample(kind, evaluate, info):
    rows, trials = [], 0
    incoming, outgoing = info["Incoming"], info["Outgoing"]
    nfinal, nin = len(outgoing), len(incoming)
    indices = {"lin": incoming.index("e-"), "p": incoming.index("u"),
               "lout": nin+outgoing.index("e-"), "k2": nin+outgoing.index("u")}
    gluons = [nin+i for i, name in enumerate(outgoing) if name == "g"]
    while len(rows) < POINTS_PER_PROCESS:
        trials += 1
        gate(trials <= 10000, kind + " finite sampling budget")
        rambo_point, _ = rambo.RAMBO(nfinal, ENERGY, rambo.FortranList(nfinal))
        final = np.array([[rambo_point[j, i] for j in [4, 1, 2, 3]] for i in range(1, nfinal+1)])
        beam_energy = ENERGY/nin
        momenta = np.vstack([[beam_energy, 0, 0, beam_energy], [beam_energy, 0, 0, -beam_energy], final])
        lin, p, lout = [momenta[indices[name]] for name in ["lin", "p", "lout"]]
        q = lin-lout
        pair_scales = [abs(dot(v+w, v+w)) for i, v in enumerate(momenta) for w in momenta[i+1:]]
        if -dot(q, q) < .05*ENERGY**2 or min(pair_scales) < .001*ENERGY**2:
            continue
        check_momenta(momenta, nin, kind + " base")
        aa, bb, rr = lepton_parameters(dot(p, q), dot(q, q), dot(p, lin))
        gate(rr > 0, kind + " transverse lepton norm")
        e1 = (lin-aa*p-bb*q)/np.sqrt(rr)
        e2 = np.r_[0., np.cross(p[1:], q[1:])]
        e2 /= np.sqrt(-dot(e2, e2))
        gate(max(abs(dot(e1, p)), abs(dot(e1, q)), abs(dot(e2, p)), abs(dot(e2, q)),
                 abs(dot(e1, e2)), abs(dot(e1, e1)+1), abs(dot(e2, e2)+1)) < 1e-9,
             kind + " transverse basis")
        pcov, qcov = eta @ p, eta @ q
        basis = np.column_stack([v.ravel() for v in
            [eta, np.outer(pcov, pcov), np.outer(qcov, qcov),
             np.outer(pcov, qcov)+np.outer(qcov, pcov)]])
        basis_scales = np.linalg.norm(basis, axis=0)
        weights, averages, orientations = [], [], []
        for pl_multiplier in [1, 2]:
            aa, bb, rr = lepton_parameters(dot(p, q), dot(q, q), pl_multiplier*dot(p, lin))
            gate(rr > 0, kind + " alternative lepton kinematics")
            tensors, values = [], []
            for angle in angles_numeric:
                rotated_in = aa*p+bb*q+np.sqrt(rr)*(np.cos(angle)*e1+np.sin(angle)*e2)
                rotated_out = rotated_in-q
                current = momenta.copy()
                current[indices["lin"]], current[indices["lout"]] = rotated_in, rotated_out
                check_momenta(current, nin, kind + " rotated")
                tensors.append(lepton_tensor(rotated_in, rotated_out))
                values.append(evaluate(current))
            average_tensor = np.mean(tensors, axis=0)
            coefficients = np.linalg.lstsq(basis/basis_scales, average_tensor.ravel(), rcond=None)[0]/basis_scales
            residual = np.linalg.norm(basis @ coefficients-average_tensor.ravel())/np.linalg.norm(average_tensor)
            gate(residual < 1e-11, kind + " averaged lepton projector decomposition")
            weights.append(coefficients[:2].tolist())
            averages.append(float(np.mean(values))*info["TaggedMadGraphFactor"])
            orientations.append({"PLMultiplier": pl_multiplier, "MadGraph": values,
                                 "LeptonDecompositionResidual": float(residual)})
        weights = np.array(weights)
        scales = np.linalg.norm(weights, axis=0)
        condition = np.linalg.cond(weights/scales)
        gate(condition < 1e6, kind + " independent lepton settings")
        projections = np.linalg.solve(weights/scales, averages)/scales
        hadrons = {"p": p.tolist(), "q": q.tolist(), "k1": momenta[gluons[0]].tolist(),
                   "k2": momenta[indices["k2"]].tolist()}
        if len(gluons) > 1:
            hadrons["k3"] = momenta[gluons[1]].tolist()
        rows.append({"ID": kind+"_"+str(len(rows)+1).zfill(2), "Kind": kind,
                     "HadronMomenta": hadrons, "LeptonWeights": weights.tolist(),
                     "TaggedAzimuthAverages": averages, "MadGraphScaledPg": float(projections[0]),
                     "MadGraphScaledPpp": float(projections[1]), "LeptonSettings": orientations,
                     "ProjectionConditionNumber": float(condition)})
        print("SAMPLE", rows[-1]["ID"], flush=True)
    return rows, trials


results, process_info, attempts = [], {}, {}
for kind in ["born", "real"]:
    evaluate, info = build_process(kind)
    rows, trials = sample(kind, evaluate, info)
    results.extend(rows)
    process_info[kind], attempts[kind] = info, trials
gate(len(results) == POINTS_PER_PROCESS*len(process_info), "complete deterministic sample")
result = {"Channel": "Hqg", "SourceSHA256": sha(Path(__file__)), "InputManifestSHA256": sha(ROOT / "s01_result.json"),
          "Seed": SEED, "Energy": ENERGY, "PointsPerProcess": POINTS_PER_PROCESS,
          "AzimuthAngles": [str(angle) for angle in angles], "AzimuthQuadratureExact": True,
          "DerivedLeptonMap": {str(k): str(v) for k, v in lepton_map.items()},
          "Processes": process_info, "Attempts": attempts, "Rows": results}
temporary = ROOT / "s03_result.json.tmp"
gate(not (ROOT / "s03_result.json").exists(), "new sample result")
temporary.write_text(json.dumps(result, indent=2) + "\n")
gate(len(json.loads(temporary.read_text())["Rows"]) == len(results), "sample reload")
temporary.rename(ROOT / "s03_result.json")
print("HQG_MADGRAPH_S03_SUCCESS", flush=True)
