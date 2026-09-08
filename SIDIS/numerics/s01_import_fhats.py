#!/usr/bin/env python3
"""Freeze the new SIDIS hats and their executed pole records."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import shutil

ROOT=Path(__file__).resolve().parent
SIDIS=ROOT.parent
SCRIPTS=SIDIS.parent

def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream,'sha256').hexdigest()

def record(message):
    with (SCRIPTS/'progress.md').open('a') as stream:
        stream.write('\nSIDIS numerics S01 '+datetime.now(timezone.utc).isoformat()+': '+message+'\n')

def freeze(source,target,role,expected=None):
    digest=sha(source)
    if expected is not None:assert digest==expected,str(source)
    target.parent.mkdir(parents=True,exist_ok=True)
    if target.exists():assert sha(target)==digest,str(target)
    else:shutil.copyfile(source,target)
    assert sha(source)==sha(target)==digest
    return dict(source=str(source.relative_to(SCRIPTS)),copy=str(target.relative_to(ROOT)),
                sha256=digest,bytes=target.stat().st_size,role=role,source_copy_equal=True)

def main():
    record('Starting byte-preserving import of all six SIDIS hats and producer/pole evidence. Next derive their numerical consumer.')
    layout=json.loads((SIDIS/'common/s21_result/layout.json').read_text())
    comparison=json.loads((SIDIS/'bigTMD_comparison/s03_result.json').read_text())
    assert comparison['Completed'] and comparison['AllEqual']
    producer=SIDIS/'common/previous_runs/layout_sources/s20_final_hats.wl'
    producer_hash=layout['Sources']['s20_final_hats.wl']['OriginalSHA256']
    channels=[]
    for channel in ['Hqq','Hgg','Hqqbar','Hqqprime','Hgq','Hqg']:
        step=layout['ChannelStages'][channel]['s20']
        source=SIDIS/layout['Moves'][channel+'/s20_result.wl']
        destination=ROOT/'Fhats'/channel
        files=[freeze(source,destination/'result.wl','terminal_fhat_payload',comparison['Channels'][channel]['ProductionSHA256']),
               freeze(producer,destination/'s20_final_hats_executed.wl','producer_provenance_only',producer_hash),
               freeze(SIDIS/channel/'README.md',destination/'README.md','convention_ledger_snapshot')]
        cache=source.parent/(step+'_cache')
        poles=sorted(cache.glob('*/s20_'+channel+'_*.wl'))
        assert poles,channel
        for path in poles:files.append(freeze(path,destination/'poles'/path.relative_to(cache),'acceptance_provenance'))
        channels.append(dict(channel=channel,files=files,ledger_status='Accepted new Kira/SubTropica result; independent comparison caveats retained.'))
        print('S01_IMPORTED',channel,'pole records',len(poles),flush=True)
    reuse=json.loads((ROOT/'s01_reuse_manifest.json').read_text())
    assert all(sha(ROOT/name)==row['SHA256'] for name,row in reuse['CommonInputs'].items())
    result=dict(schema='SIDISNumericsImport-v2',stage='s01',status='Complete',producer_sha256=sha(Path(__file__)),
                channels=channels,common_inputs_sha256=sha(ROOT/'s01_reuse_manifest.json'),
                checks=dict(source_copy_equal=True,mathematical_payloads_modified=False,old_own_predictions_imported=False))
    target=ROOT/'s01_result';target.write_text(json.dumps(result,indent=2)+'\n')
    record('All six current SIDIS hats and pole/source snapshots copied with matching hashes. No old own coefficient or bin estimate was imported. Next S02/S03.')
    print('S01_SUCCESS',sha(target),flush=True)

if __name__=='__main__':main()
