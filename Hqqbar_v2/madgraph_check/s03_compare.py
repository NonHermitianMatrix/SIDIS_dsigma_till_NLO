"""Compare MadGraph's explicit photon currents with the saved Hqqbar tensor."""
import hashlib
import itertools
import json
import math
import os
from pathlib import Path
import re
import resource
import subprocess
import time

HERE = Path(__file__).resolve().parent
os.chdir(HERE)
resource.setrlimit(resource.RLIMIT_AS, (3 * 1024**3, 3 * 1024**3))
started = time.monotonic()
sha = lambda path: hashlib.sha256(Path(path).read_bytes()).hexdigest()
generated = json.loads(Path("s01_result.json").read_text())
benchmark = json.loads(Path("s02_result.json").read_text())
matrix = Path(generated["matrix"])
assert sha(matrix) == generated["generated_matrix_sha256"]
for file, key in [("../s02_result/real.wl", "production_tensor_sha256"),
                  ("../s05_result/Fhats.wl", "production_hats_sha256")]:
    assert sha(file) == benchmark[key], "Production input changed"
source = matrix.read_text()
helicities = [tuple(map(int, row.split(','))) for row in
             re.findall(r"DATA \(NHEL\(I,\s*\d+\),I=1,5\) /([^/]+)/", source)]
assert set(helicities) == set(itertools.product((-1, 1), repeat=5))
photon_states = len({row[0] for row in helicities})
denominator = int(re.search(r"DATA IDEN/(\d+)/", source)[1])
quark_average = denominator / photon_states * benchmark["symmetry_weight"]
assert quark_average == len({row[1] for row in helicities}) * benchmark["Nc"]
diagrams = int(re.search(r"PARAMETER \(NGRAPHS=(\d+)\)", source)[1])
assert diagrams == benchmark["diagram_count"]
photon_call = "      CALL VXXXXX(P(0,1),ZERO,NHEL(1),-1*IC(1),W(1,1))"
assert source.count(photon_call) == 1
Path("s03_matrix.f").write_text(source.replace(
    photon_call, photon_call + "\n      CALL HQQBAR_CURRENT(W(1,1))"))

driver = '''      PROGRAM HQQBAR_CHECK
      IMPLICIT NONE
      INCLUDE 'coupl.inc'
      REAL*8 P(0:3,5), EPS(0:3), ANS
      INTEGER I,J,K,POINT,NPOINTS
      LOGICAL HELRESET
      COMMON/HQQBAR_INPUT_CURRENT/EPS
      COMMON/HELRESET/HELRESET
      CALL SETPARA('standalone/Cards/param_card.dat')
      WRITE(*,'(A,3(1X,ES25.16))') 'COUPLINGS',
     $ DBLE(GC_2*DCONJG(GC_2))*G**4,G,ABS(GC_2)
      OPEN(11,FILE='s03_momenta.dat',STATUS='OLD')
      READ(11,*) NPOINTS
      DO POINT=1,NPOINTS
        DO J=1,5
          READ(11,*) (P(I,J),I=0,3)
        ENDDO
        DO K=0,5
          EPS=0D0
          IF(K.LE.3) EPS(K)=1D0
          IF(K.EQ.4) EPS=P(:,2)
          IF(K.EQ.5) EPS=P(:,1)
C         Evaluate every helicity for every supplied current.
          HELRESET=.TRUE.
          CALL SMATRIX(P,ANS)
          WRITE(*,'(A,2(1X,I3),1X,ES25.16)')
     $      'CURRENT',POINT,K,ANS
        ENDDO
      ENDDO
      CLOSE(11)
      END

      SUBROUTINE HQQBAR_CURRENT(W)
      IMPLICIT NONE
      COMPLEX*16 W(*)
      REAL*8 EPS(0:3)
      INTEGER I
      COMMON/HQQBAR_INPUT_CURRENT/EPS
C     Preserve the HELAS momentum entries; replace polarization only.
      DO I=0,3
        W(I+3)=DCMPLX(EPS(I),0D0)
      ENDDO
      END
'''
Path("s03_driver.f").write_text(driver)
points = benchmark["points"]
with Path("s03_momenta.dat").open("w") as stream:
    stream.write(str(len(points)) + "\n")
    for point in points:
        for momentum in point["momenta"]:
            stream.write(" ".join(format(x, ".17e") for x in momentum) + "\n")
with Path("s03_build.log").open("w") as log:
    if not all(Path("standalone/lib", name).is_file() for name in
               ["libdhelas.a", "libmodel.a"]):
        subprocess.run(["make", "-C", "standalone/Source", "-j2"],
                       stdout=log, stderr=subprocess.STDOUT, check=True, timeout=120)
    subprocess.run(["gfortran", "-O2", "-ffixed-line-length-none", "-I", str(matrix.parent),
                    "s03_driver.f", "s03_matrix.f", "-Lstandalone/lib", "-ldhelas", "-lmodel",
                    "-o", "s03_current_check"], stdout=log, stderr=subprocess.STDOUT,
                   check=True, timeout=120)
run = subprocess.run([str(HERE / "s03_current_check")], capture_output=True,
                     text=True, check=True, timeout=30)
Path("s03_currents.log").write_text(run.stdout + run.stderr)
couplings = [line.split()[1:] for line in run.stdout.splitlines() if line.startswith("COUPLINGS")]
assert len(couplings) == 1
coupling_norm, strong_coupling, photon_coupling = map(float, couplings[0])
assert coupling_norm > 0
currents = {(int(words[1]), int(words[2])): float(words[3])
            for line in run.stdout.splitlines() if line.startswith("CURRENT")
            for words in [line.split()]}
assert len(currents) == len(points) * 6
comparisons = []
ward_checks = []
relative_tolerance = 2e-9
ward_squared_tolerance = 1e-20
for index, point in enumerate(points, 1):
    values = [currents[index, mode]/coupling_norm/benchmark["symmetry_weight"] for mode in range(6)]
    mg = {"g": math.fsum(sign*value for sign, value in zip((1,-1,-1,-1), values)),
          "pp": values[4]}
    for name in ("g", "pp"):
        local = point[name]
        relative = abs(mg[name]-local)/max(abs(local), abs(mg[name]), 1e-300)
        comparisons.append({"point": index, "projection": name,
                            "local": local, "madgraph": mg[name],
                            "relative_difference": relative,
                            "pass": relative <= relative_tolerance})
    ward_scale = math.fsum(values[:4]) * math.fsum(x*x for x in point["momenta"][0])
    residual = abs(values[5])/max(abs(ward_scale), 1e-300)
    ward_checks.append({"point": index, "normalized_squared_residual": residual,
                        "pass": residual <= ward_squared_tolerance})
result = {"all_pass": all(row["pass"] for row in comparisons+ward_checks),
          "process": generated["process"], "version": generated["version"],
          "diagrams": diagrams, "points": len(points),
          "comparisons": comparisons, "ward_checks": ward_checks,
          "relative_tolerance": relative_tolerance,
          "ward_squared_tolerance": ward_squared_tolerance,
          "max_relative_difference": max(row["relative_difference"] for row in comparisons),
          "max_ward_squared_residual": max(row["normalized_squared_residual"] for row in ward_checks),
          "generated_initial_denominator": denominator,
          "photon_helicity_multiplicity": photon_states,
          "incoming_quark_average_denominator": quark_average,
          "removed_final_symmetry_weight": benchmark["symmetry_weight"],
          "coupling_norm": coupling_norm, "strong_coupling": strong_coupling,
          "photon_quark_coupling_magnitude": photon_coupling,
          "production_tensor_sha256": benchmark["production_tensor_sha256"],
          "production_hats_sha256": benchmark["production_hats_sha256"],
          "patched_matrix_sha256": sha("s03_matrix.f")}
assert sha("../s05_result/Fhats.wl") == result["production_hats_sha256"]
Path("s03_result.json").write_text(json.dumps(result, indent=2) + "\n")
Path("s03_resources.json").write_text(json.dumps({
    "elapsed_seconds": time.monotonic()-started,
    "peak_child_RSS_KiB": resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,
    "address_space_limit_GiB": 3}, indent=2) + "\n")
report = ["# MadGraph comparison", "", f"All checks pass: **{result['all_pass']}**.", "",
          f"Fresh MadGraph {generated['version'].splitlines()[0]}: {diagrams} diagrams; "
          f"{len(points)} spacelike-photon points, {len(comparisons)} contractions.", "",
          f"Maximum relative difference: `{result['max_relative_difference']:.16e}`.",
          f"Maximum normalized squared Ward residual: `{result['max_ward_squared_residual']:.16e}`.", "",
          "| Point | Contraction | Local | MadGraph | Relative difference |",
          "|---:|:---|---:|---:|---:|"]
report += [f"| {r['point']} | {r['projection']} | {r['local']:.15g} | "
           f"{r['madgraph']:.15g} | {r['relative_difference']:.3e} |" for r in comparisons]
report += ["", "This checks the unintegrated tree-level current tensor in four dimensions.",
           "The symbolic phase-space integration and MSbar subtraction are covered by",
           "the production checks and the separate BigTMD comparison.", "",
           "The photon polarization is explicit; no photon spin average is applied.",
           "The generated photon-helicity multiplicity cancels its average in SMATRIX.",
           "The generated quark spin/color average is checked directly. The spectator",
           "symmetry weight is removed to match the unweighted production square. The common",
           "coupling factor is read from the initialized MadGraph model and divided out",
           "to compare with the saved expression at eq = gs = 1 and Nc = 3.", "",
           "Production hats SHA256: `" + result["production_hats_sha256"] + "`.", ""]
Path("madgraph_minus_local.md").write_text("\n".join(report))
print(("PASS" if result["all_pass"] else "FAIL") + ": "
      + str(len(comparisons)) + " contractions; max relative difference "
      + str(result["max_relative_difference"]) + "; Ward "
      + str(result["max_ward_squared_residual"]), flush=True)
raise SystemExit(0 if result["all_pass"] else 1)
