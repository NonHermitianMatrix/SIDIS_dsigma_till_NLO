#!/usr/bin/env python3
"""Freeze new SIDIS outputs and the existing pinned comparison inputs."""
from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parent
SIDIS = ROOT.parent
SCRIPTS = SIDIS.parent
PREVIOUS = SCRIPTS / 'bigTMD_comparison'
CHANNELS = {'Hqq': 'Hqq_v4', 'Hqg': 'Hqg_v3', 'Hgq': 'Hgq_v4',
            'Hgg': 'Hgg_v2', 'Hqqbar': 'Hqqbar_v2', 'Hqqprime': 'Hqqprime_v2'}


def sha(path):
    return hashlib.file_digest(path.open('rb'), 'sha256').hexdigest()


def copy(source, destination):
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        assert sha(source) == sha(destination), str(destination)
    else:
        shutil.copy2(source, destination)
    assert sha(source) == sha(destination)
    return {'Source': str(source), 'SHA256': sha(destination)}


def production_file(channel, name):
    base = SIDIS / channel
    if (base / name).is_file():
        return base / name
    return base / (name.split('_')[0] + '_result') / name


def main():
    records = {}
    for channel, previous in CHANNELS.items():
        target = ROOT / channel / 's01_result'
        entries = {}
        entries['production.wl'] = copy(production_file(channel, 's20_result.wl'), target / 'production.wl')
        old = PREVIOUS / previous
        names = ['s01_inputs.json', 's01_driver.wl', 's01_literal.wl', 's01_reconstructed.wl']
        if channel in ['Hqq', 'Hgq']:
            names += ['s02_born_reference.wl', 's02_born_reference.json']
            names += [f's02_{mode}_{sign}_canonical.wl' for mode in ['Pg', 'Ppp'] for sign in [1, -1]]
        for name in names:
            entries[name] = copy(old / name, target / 'reference' / name)
        if channel in ['Hqq', 'Hqg', 'Hgq']:
            born = SIDIS / channel / 's01_inputs' / 's02_result.wl'
            if not born.is_file():
                born = SIDIS / channel / 's01_result' / 's01_inputs' / 's02_result.wl'
            entries['born.wl'] = copy(born, target / 'born.wl')
        else:
            entries['subtraction.wl'] = copy(production_file(channel, 's16_result.wl'), target / 'subtraction.wl')
        if channel == 'Hqg':
            packets = sorted(old.glob('s13_cache_*/s13_result.wl'))
            assert packets
            for packet in packets:
                label = packet.parent.name.removeprefix('s13_cache_')
                name = 'reference/' + label + '.wl'
                entries[name] = copy(packet, target / name)
            entries['comparison_receipt.json'] = copy(old / 's13_result.json', target / 'reference' / 'comparison_receipt.json')
        (target / 'manifest.json').write_text(json.dumps(entries, indent=2) + '\n')
        records[channel] = entries
    reference = ROOT / 'reference'
    helpers = {}
    for name in ['s03_compare_regular.wl', 's05_compare_distributions.wl', 's10_compare_regular_in_field.wl']:
        helpers[name] = copy(PREVIOUS / name, reference / name)
    for name in ['s13_dilogarithms.wl', 's13_dilogarithm_identities.wl']:
        helpers[name] = copy(SCRIPTS / 'Hqg_v3' / name, reference / name)
    result = {'Accepted': True, 'Channels': records, 'Helpers': helpers,
              'ReferenceCommit': '6e97635d21a63b7975b2e7f5891edc0c35c4dc0c',
              'ReferenceInterpretation': 'Same explicitly labelled rational reconstruction of printed decimals as the previous comparison; literal expressions retained.',
              'SourceSHA256': sha(Path(__file__))}
    (ROOT / 's01_result.json').write_text(json.dumps(result, indent=2) + '\n')
    print('S01_SUCCESS: frozen six new SIDIS outputs and pinned comparison inputs.')


if __name__ == '__main__':
    main()
