"""Generate this channel directly with the installed MadGraph package."""
import hashlib
import json
import os
from pathlib import Path
import resource
import subprocess
import sys

HERE = Path(__file__).resolve().parent
os.chdir(HERE)
default = HERE.parents[1] / "Hgq_v4/madgraph_check/software/MG5_aMC_v3_7_0"
mg = Path(os.environ.get("MG5_PATH", str(default))).resolve()
assert (mg / "bin/mg5_aMC").is_file(), "Set MG5_PATH to the MadGraph installation"
target = HERE / "standalone"
assert not target.exists(), "Remove this check's standalone directory before regenerating"
card = HERE / "s01_process.mg5"
process = "a u > d u d~ QCD=2 QED=1"
card.write_text("set automatic_html_opening False\nset notification_center False\n"
                "import model sm\ngenerate " + process + "\noutput standalone "
                + str(target) + " -f\nquit\n")

def limit_memory():
    resource.setrlimit(resource.RLIMIT_AS, (3 * 1024**3, 3 * 1024**3))

with (HERE / "s01_result.log").open("w") as log:
    subprocess.run([os.environ.get("MG5_PYTHON", "/usr/bin/python3"), str(mg / "bin/mg5_aMC"), str(card)],
                   cwd=HERE, stdout=log, stderr=subprocess.STDOUT,
                   preexec_fn=limit_memory, check=True, timeout=120)
matrices = list(target.glob("SubProcesses/P*/matrix.f"))
assert len(matrices) == 1, matrices
result = {"process": process, "version": (mg / "VERSION").read_text().strip(),
          "matrix": str(matrices[0].relative_to(HERE)),
          "generated_matrix_sha256": hashlib.sha256(matrices[0].read_bytes()).hexdigest(),
          "memory_limit_GiB": 3}
(HERE / "s01_result.json").write_text(json.dumps(result, indent=2) + "\n")
print("PASS: fresh MadGraph subprocess generated", flush=True)
