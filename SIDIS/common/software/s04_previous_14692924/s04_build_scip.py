#!/usr/bin/env python3
"""Build the pinned runtime dependency of Polymake's polytope module."""
import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parent
commit = 'e639a0059d28e97a67f62f7764f49626d4054e9c'
archive = root / 'scip-v602.tar.gz'
assert hashlib.sha256(archive.read_bytes()).hexdigest() == '87327461e6e8a16a0707e0079b6df5244dece171d424398f4acc7e0f8dc8bfb2'
source = root / 'scip-source' / ('scip-' + commit)
build = root / 's04_scip_build'
build.mkdir(exist_ok=True)
cmake = '/u/local/apps/cmake/3.19.5/gcc-4.8.5/bin/cmake'
assert Path(cmake).is_file(), 'verified cluster CMake must be available'
configuration = [cmake, str(source), '-DCMAKE_BUILD_TYPE=Release', '-DSHARED=ON',
                 '-DLPS=none', '-DSYM=none', '-DEXPRINT=none', '-DIPOPT=OFF',
                 '-DZIMPL=OFF', '-DREADLINE=OFF', '-DGMP=OFF', '-DZLIB=OFF',
                 '-DCMAKE_C_FLAGS_RELEASE=-O1 -DNDEBUG',
                 '-DCMAKE_CXX_FLAGS_RELEASE=-O1 -DNDEBUG']
print('Configure pinned SCIP 6.0.2 shared runtime', flush=True)
subprocess.run(configuration, cwd=str(build), check=True)
print('Compile with two threads; optional SCIP LP/NLP solvers are not used by the Newton-polytope calculation', flush=True)
subprocess.run([cmake, '--build', '.', '--target', 'libscip', '--', '-j2'],
               cwd=str(build), check=True)
libraries = list((build / 'lib').glob('libscip.so*'))
assert libraries
library_dir = str(build / 'lib')
wrapper = root / 's01_polymake'
text = wrapper.read_text()
assert 'LD_LIBRARY_PATH=' in text
if library_dir not in text:
    wrapper.write_text(text.replace('LD_LIBRARY_PATH=', 'LD_LIBRARY_PATH=' + library_dir + ':'))
probe = subprocess.run([str(wrapper),
    'use application "ideal"; print "SIDIS_POLYMAKE_MODULE_OK\\n";'],
    stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, timeout=90)
print(probe.stdout, probe.stderr, flush=True)
result = {'commit': commit, 'source_url': 'https://github.com/scipopt/scip/tree/v602',
          'configuration': configuration,
          'libraries': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in libraries},
          'probe': {'exit_code': probe.returncode, 'stdout': probe.stdout, 'stderr': probe.stderr},
          'wrapper_sha256': hashlib.sha256(wrapper.read_bytes()).hexdigest()}
result['accepted'] = probe.returncode == 0 and 'SIDIS_POLYMAKE_MODULE_OK' in probe.stdout and 'ERROR' not in probe.stderr
(root / 's04_result.json').write_text(json.dumps(result, indent=2) + '\n')
assert result['accepted'], 'Polymake module test failed'
print('S04_SUCCESS: pinned runtime built and Polymake modules loaded.', flush=True)
