#!/usr/bin/env python3
"""Copy unchanged renormalization fields without copying integrated tensors."""
import hashlib
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parent
channels = {'Hqq': ('Hqq_v4', 's07_result.wl', 's07_renormalize_virtual.wl'),
            'Hqg': ('Hqg_v3', 's09_result.wl', 's09_renormalize_virtual.wl'),
            'Hgq': ('Hgq_v4', 's07_result.wl', 's07_renormalize_virtual.wl')}
keys = ['CouplingResidue', 'ExternalFieldCounts', 'ExternalInterference',
        'CouplingWeight', 'Regulator', 'MSPole', 'CouplingsRemoved',
        'InputHashes', 'SourceHash']

def field_text(text, key):
    matches = list(re.finditer('"' + re.escape(key) + r'"\s*->\s*', text))
    assert len(matches) == 1, (key, len(matches))
    start = matches[0].start()
    i = matches[0].end()
    stack, in_string, escaped = [], False, False
    while i < len(text):
        char, pair = text[i], text[i:i+2]
        if in_string:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == '"':
                in_string = False
        elif char == '"':
            in_string = True
        elif pair == '<|':
            stack.append('|>'); i += 1
        elif pair == '|>':
            if not stack:
                return text[start:i].strip()
            assert stack.pop() == '|>'
            i += 1
        elif char in '([{':
            stack.append({'(': ')', '[': ']', '{': '}'}[char])
        elif char in ')]}':
            assert stack and stack.pop() == char
        elif char == ',' and not stack:
            return text[start:i].strip()
        i += 1
    raise ValueError('Unclosed field: ' + key)

manifest = {}
for channel, (original, filename, source_name) in channels.items():
    path = root.parent / original / filename
    source = root.parent / original / source_name
    text = path.read_text()
    fields = [field_text(text, key) for key in keys]
    assert all('RenormalizedVirtual' not in field for field in fields)
    folder = root / channel / 's17_inputs'
    folder.mkdir(exist_ok=True)
    selected = folder / 'renormalization.wl'
    selected.write_text('<|' + ',\n '.join(fields) + '|>\n')
    receipt = {'original_result': str(path),
               'original_result_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
               'original_source': str(source),
               'original_source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
               'selected_keys': keys,
               'selected_sha256': hashlib.sha256(selected.read_bytes()).hexdigest()}
    (folder / 's17_manifest.json').write_text(json.dumps(receipt, indent=2) + '\n')
    manifest[channel] = receipt
    print(channel, 'copied unchanged counterterm fields', receipt['selected_sha256'])
(root / 's17_import_result.json').write_text(json.dumps(manifest, indent=2) + '\n')
print('S17_IMPORT_SUCCESS')
