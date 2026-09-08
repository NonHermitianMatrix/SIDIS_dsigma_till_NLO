"""Prepare isolated Hgq inputs and the existing generic MadGraph runtime."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
CHANNEL = ROOT.parent
SOFTWARE_SOURCE = CHANNEL.parent / "Hqg_v3/madgraph_check/software/MG5_aMC_v3_7_0"
SOFTWARE = ROOT / "software/MG5_aMC_v3_7_0"
sys.dont_write_bytecode = True


def sha(path):
    with path.open("rb") as stream:
        return hashlib.sha256(stream.read()).hexdigest()


manifest = {"Channel": "Hgq", "Inputs": {}}
(ROOT / "inputs").mkdir(exist_ok=True)
for name in ("s02_born_and_projectors.wl", "s02_result.wl",
             "s01_generate_amplitudes.wl", "s01_result.wl",
             "s03_contract_real.wl", "s03_result.wl", "s10_final_hats.wl", "s10_result.wl"):
    source, destination = CHANNEL / name, ROOT / "inputs" / name
    if destination.exists():
        assert sha(source) == sha(destination), "Changed prepared input " + name
    else:
        shutil.copy2(source, destination)
    assert sha(source) == sha(destination)
    manifest["Inputs"][name] = {"sha256": sha(destination), "bytes": destination.stat().st_size}
if not (SOFTWARE / "bin/mg5_aMC").is_file():
    shutil.copytree(SOFTWARE_SOURCE, SOFTWARE, dirs_exist_ok=True,
        ignore_dangling_symlinks=True, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
if not (ROOT / "software/six.py").is_file():
    subprocess.run([sys.executable, "-m", "pip", "install", "--no-deps",
                    "--target", str(ROOT / "software"), "six"], check=True)
manifest["Software"] = {"Version": (SOFTWARE / "VERSION").read_text(),
    "ExecutableSHA256": sha(SOFTWARE / "bin/mg5_aMC"),
    "SixSHA256": sha(ROOT / "software/six.py"), "SourceKind": "Generic MadGraph software; no channel process reused"}
sys.path[:0] = [str(ROOT / "software"), str(SOFTWARE)]
from models import import_ufo
model = import_ufo.import_model("sm")
manifest["Particles"] = {}
for name in ("e-", "u", "u~", "g"):
    particle = model.get_particle(name)
    assert particle is not None, name
    manifest["Particles"][name] = {key: particle.get(key)
        for key in ("spin", "mass")}
    manifest["Particles"][name].update({"name": name,
        "pdg_code": particle.get_pdg_code(), "color": particle.get_color(),
        "charge": particle.get_charge(), "helicities": particle.get_helicity_states()})
commands = ["set automatic_html_opening False", "set auto_update 0", "set nb_core 1",
    "import model sm", "generate e- g > e- u u~ / z h QED=2 QCD=1",
    "output standalone " + str(ROOT / "born"),
    "generate e- g > e- u u~ g / z h QED=2 QCD=2",
    "output standalone " + str(ROOT / "real"), "quit"]
(ROOT / "s02_generate_processes.mg5").write_text("\n".join(commands) + "\n")
manifest["SourceSHA256"] = sha(Path(__file__))
manifest["GeneratorCommandsSHA256"] = sha(ROOT / "s02_generate_processes.mg5")
(ROOT / "s01_result.json").write_text(json.dumps(manifest, indent=2) + "\n")
print("HGQ_MADGRAPH_S01_SUCCESS", flush=True)
