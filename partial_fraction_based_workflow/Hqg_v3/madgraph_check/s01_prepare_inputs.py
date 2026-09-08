"""Prepare isolated Hqg inputs and the existing generic MadGraph runtime."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
CHANNEL = ROOT.parent
SOFTWARE_SOURCE = CHANNEL.parent / "Hqqbar/madgraph_check/software/MG5_aMC_v3_7_0"
SOFTWARE = ROOT / "software/MG5_aMC_v3_7_0"
sys.dont_write_bytecode = True


def sha(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


manifest = {"Channel": "Hqg", "Inputs": {}}
(ROOT / "inputs").mkdir(exist_ok=True)
for name in ("s02_born_and_projectors.wl", "s02_result.wl",
             "s04_generate_amplitudes.wl", "s04_result.wl",
             "s05_contract_real.wl", "s05_result.wl"):
    source, destination = CHANNEL / name, ROOT / "inputs" / name
    if destination.exists():
        assert sha(source) == sha(destination), "Changed prepared input " + name
    else:
        shutil.copy2(source, destination)
    assert sha(source) == sha(destination)
    manifest["Inputs"][name] = {"sha256": sha(destination), "bytes": destination.stat().st_size}
shutil.copytree(SOFTWARE_SOURCE, SOFTWARE, dirs_exist_ok=True,
    ignore_dangling_symlinks=True, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
if not (ROOT / "software/six.py").is_file():
    subprocess.run([sys.executable, "-m", "pip", "install", "--no-deps",
                    "--target", str(ROOT / "software"), "six"], check=True)
manifest["Software"] = {"Version": (SOFTWARE / "VERSION").read_text(),
    "ExecutableSHA256": sha(SOFTWARE / "bin/mg5_aMC"),
    "SixSHA256": sha(ROOT / "software/six.py"), "CopiedFrom": str(SOFTWARE_SOURCE)}
sys.path[:0] = [str(ROOT / "software"), str(SOFTWARE)]
from models import import_ufo
model = import_ufo.import_model("sm")
manifest["Particles"] = {}
for name in ("e-", "u", "g"):
    particle = next(p for p in model.get("particles") if p.get("name") == name)
    manifest["Particles"][name] = {key: particle.get(key)
        for key in ("name", "pdg_code", "spin", "color", "charge", "mass")}
commands = ["set automatic_html_opening False", "set auto_update 0", "set nb_core 1",
    "import model sm", "generate e- u > e- u g / z h QED=2 QCD=1",
    "output standalone " + str(ROOT / "born"),
    "generate e- u > e- u g g / z h QED=2 QCD=2",
    "output standalone " + str(ROOT / "real"), "quit"]
(ROOT / "s02_generate_processes.mg5").write_text("\n".join(commands) + "\n")
manifest["SourceSHA256"] = sha(Path(__file__))
manifest["GeneratorCommandsSHA256"] = sha(ROOT / "s02_generate_processes.mg5")
(ROOT / "s01_result.json").write_text(json.dumps(manifest, indent=2) + "\n")
print("HQG_MADGRAPH_S01_SUCCESS", flush=True)
