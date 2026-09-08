#!/usr/bin/env python3
"""Load the exact Singular 4.1.1 runtime required by the pinned Polymake."""
import hashlib
import json
import os
import shlex
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parent
libraries = root / 'singular41/usr/lib/x86_64-linux-gnu'
package = root / 'libsingular4m1_4.1.1-p2+ds-4+b2_amd64.deb'
expected = 'a104b9b1452562b8a49047d9e9cc854dac7edd937d961a49215d25ec468210bd'
assert hashlib.sha256(package.read_bytes()).hexdigest() == expected
# Debian prefixes the upstream library filename; retain its exact 4.1.1 ABI.
aliases = {
    'libSingular-4.1.1.so': 'libsingular-Singular-4.1.1.so',
    'libsingular_resources-4.1.1.so': 'libsingular-resources-4.1.1.so',
    'libpolys-4.1.1.so': 'libsingular-polys-4.1.1.so',
    'libomalloc-0.9.6.so': 'libsingular-omalloc-4.1.1+0.9.6.so',
}
for name, target_name in aliases.items():
    alias, target = libraries / name, libraries / target_name
    assert target.is_file()
    if not alias.exists():
        alias.symlink_to(target.name)
library_path = ':'.join(str(p) for p in
    [root / 'ppl14/usr/lib/x86_64-linux-gnu', root / 's04_scip_build/lib', libraries, root / 'libflint14/usr/lib/x86_64-linux-gnu'])
command = ['/u/local/apps/apptainer/1.2.2/bin/apptainer', 'exec', '--cleanenv',
           '--bind', str(root.parent) + ':' + str(root.parent),
           '--env', 'POLYMAKE_USER_DIR=' + str(root / 'polymake_user'),
           '--env', 'LD_LIBRARY_PATH=' + library_path,
           str(root / 'polymake-4.4-rootfs')]
wrapper = root / 's01_polymake'
wrapper.write_text('#!/bin/sh\nexec ' + ' '.join(shlex.quote(x) for x in
    command + ['/usr/local/bin/polymake']) + ' "$@"\n')
wrapper.chmod(0o755)
environment = os.environ.copy()
environment.update(LC_ALL='C', LANG='C')
checks = {}
for name, arguments in [
    ('ideal_module_dependencies', command + ['ldd', '/usr/local/lib/polymake/lib/ideal.so']),
    ('ideal_module_load', [str(wrapper),
      'use application "ideal"; print "SIDIS_POLYMAKE_MODULE_OK\\n";'])]:
    run = subprocess.run(arguments, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                         universal_newlines=True, env=environment, timeout=90)
    checks[name] = dict(exit_code=run.returncode, stdout=run.stdout, stderr=run.stderr)
    print(name, run.returncode, run.stdout, run.stderr, flush=True)
    (root / 's03_checks.json').write_text(json.dumps(checks, indent=2) + '\n')
    assert run.returncode == 0 and 'not found' not in run.stdout and 'ERROR' not in run.stderr
assert 'SIDIS_POLYMAKE_MODULE_OK' in checks['ideal_module_load']['stdout']
result = {'accepted': True, 'package': package.name, 'package_sha256': expected,
          'url': 'https://archive.debian.org/debian/pool/main/s/singular/' + package.name,
          'wrapper_sha256': hashlib.sha256(wrapper.read_bytes()).hexdigest(),
          'libraries': {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in libraries.glob('*.so')}, 'checks': checks}
(root / 's03_result.json').write_text(json.dumps(result, indent=2) + '\n')
print('S03_SUCCESS: required Polymake Singular module loaded.', flush=True)
