#!/usr/bin/env python3
"""Install the pinned polymake runtime and check the dedicated integral tools."""
import hashlib
import json
import os
import shlex
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parent
apptainer = "/u/local/apps/apptainer/1.2.2/bin/apptainer"
image_uri = "docker://polymake/release@sha256:fa640521d6bf46d645b166e0f3d5bc34819cafa73f5545149d5fa2aeacdb6fdf"
image = root / "polymake-4.4.sif"
sandbox = root / "polymake-4.4-rootfs"
environment = os.environ.copy()
environment["PATH"] = str(root / "bin") + os.pathsep + environment.get("PATH", "")
for key in ["LANG", "LC_ALL"]:
    environment[key] = "C"
for key in ["OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS",
            "APPTAINER_MKSQUASHFS_PROCS"]:
    environment[key] = "1"
environment["APPTAINER_MKSQUASHFS_MEM"] = "512M"
for key, name in [("APPTAINER_TMPDIR", "image_tmp"),
                  ("APPTAINER_CACHEDIR", "image_cache"), ("TMPDIR", "tmp")]:
    directory = root / name
    directory.mkdir(exist_ok=True)
    environment[key] = str(directory)

if not image.exists():
    print("Pulling pinned polymake 4.4 image", flush=True)
    subprocess.run([apptainer, "pull", "--disable-cache", str(image), image_uri],
                   env=environment, check=True)

if not sandbox.exists():
    print("Extracting the image once for repeated polymake calls", flush=True)
    subprocess.run([apptainer, "build", "--sandbox", str(sandbox), str(image)],
                   env=environment, check=True)

wrapper = root / "s01_polymake"
bind = str(root.parent) + ":" + str(root.parent)
user_directory = root / "polymake_user"
user_directory.mkdir(exist_ok=True)
wrapper.write_text("#!/bin/sh\nexec " + " ".join(shlex.quote(x) for x in
                   [apptainer, "exec", "--cleanenv", "--bind", bind,
                    "--env", "POLYMAKE_USER_DIR=" + str(user_directory),
                    "--env", "LD_LIBRARY_PATH=" + str(root / "singular41" / "usr" / "lib" / "x86_64-linux-gnu") + ":" + str(root / "libflint14" / "usr" / "lib" / "x86_64-linux-gnu"),
                    str(sandbox), "/usr/local/bin/polymake"]) + ' "$@"\n')
wrapper.chmod(0o755)

versions = {}
for name, command in [("Kira", [str(root / "kira-3.1"), "--version"]),
                      ("polymake", [str(wrapper), "--version"])]:
    run = subprocess.run(command, env=environment, stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT, universal_newlines=True,
                         timeout=120, check=False)
    versions[name] = run.stdout.strip()
    print(name, versions[name], flush=True)
    run.check_returncode()

subprocess.run(["/u/local/apps/mathematica/13.1/Executables/WolframKernel",
                "-noprompt", "-script", str(root / "s02_package_probe.wl")],
               env=environment, cwd=str(root), check=True)

def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(data)
    return h.hexdigest()

result = {"versions": versions, "polymake_image": image_uri,
          "sha256": {p.name: digest(p) for p in
                     [image, root / "kira-3.1", root / "SubTropica-1.2.10.tar.gz",
                      root / "bin" / "unsquashfs", root / "squashfs-tools-el7.rpm"]},
          "additional_runtime_library": {
              "package": "libflint-2.6.3_2.6.3-3_amd64.deb",
              "url": "https://archive.debian.org/debian/pool/main/f/flint/libflint-2.6.3_2.6.3-3_amd64.deb",
              "sha256": digest(root / "libflint-2.6.3_2.6.3-3_amd64.deb")},
          "subtropica_probe": "s02_result.wl", "accepted": True}
(root / "s01_result.json").write_text(json.dumps(result, indent=2) + "\n")
print("S01_SUCCESS", flush=True)
