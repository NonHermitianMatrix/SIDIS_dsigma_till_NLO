#!/usr/bin/env python3
"""Export reports from the executed symbolic comparisons; no new algebra."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json

ROOT = Path(__file__).resolve().parent
SIDIS = ROOT.parent
PREVIOUS = {'Hqq': 'Hqq_v4', 'Hqg': 'Hqg_v3', 'Hgq': 'Hgq_v4',
            'Hgg': 'Hgg_v2', 'Hqqbar': 'Hqqbar_v2', 'Hqqprime': 'Hqqprime_v2'}


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def read(path):
    return json.loads(path.read_text())


def main():
    result = read(ROOT / 's03_result.json')
    run = read(ROOT / 's03_execution.json')
    imports = read(ROOT / 's01_result.json')
    layout = read(SIDIS / 'common/s21_result/layout.json')
    assert result['Completed'] and result['AllEqual']
    assert run['accepted_execution'] and run['guard'] is None
    assert sha(ROOT / 's03_result.wl') == result['ResultSHA256']
    assert sha(ROOT / run['source']) == run['source_sha256']
    assert sha(ROOT / 's01_result/s01_import_inputs_executed.py') == imports['SourceSHA256']
    original_source = ROOT / 's01_result/path_adapter.json'
    original_source.write_text(json.dumps({
        'ExecutedSourceSHA256': imports['SourceSHA256'],
        'CurrentSourceSHA256': sha(ROOT / 's01_import_inputs.py'),
        'Meaning': 'Only moved production-file lookup and immutable-input resume handling changed.'
    }, indent=2) + '\n')
    reference_scope = (
        'The exact claim uses the same declared rational reconstruction of printed '
        'BigTMD decimals as the existing all-channel comparison. It is conditional '
        'on that reconstruction; it does not recover the unavailable original '
        'exact coefficients. Literal imports are preserved. The comparison fixes '
        'SU(3), matches the common scale and charges, and transports the same '
        'delta and plus-distribution convention. Production F hats retain their '
        'symbolic color, flavor, charge and scale dependence.'
    )
    reports = {}
    table = ['| Channel | Exact comparisons | Numerical comparisons | F1 and F2 |',
             '|---|---:|---:|---|']
    for channel, row in result['Channels'].items():
        assert row['Completed'] and row['AllEqual'] and row['AllNumericalEqual']
        production_relative = layout['Moves'][channel + '/s20_result.wl']
        production = SIDIS / production_relative
        assert sha(production) == row['ProductionSHA256']
        assert sha(ROOT / channel / 's01_result/production.wl') == row['ProductionSHA256']
        if channel in ('Hqq', 'Hgq'):
            coverage = ('The two Born hats and all delta/L0/L1/regular tensor '
                        'coefficients on both open coordinate branches agree. '
                        'S02 exactly replays the saved F-hat projections and '
                        'checks the reference projector matrix, so these tensor '
                        'comparisons cover both final hats.')
        elif channel == 'Hqg':
            coverage = ('Both Born hats and every F1/F2 delta/L0/L1/regular '
                        'coefficient on both open coordinate branches agree.')
        else:
            coverage = ('Both complete finite NLO hats agree as symbolic functions. '
                        'Independent charge symbols remain formal. Finite ordinary remainders '
                        'from the reference plus functions are included.')
            if channel == 'Hqqprime':
                coverage += ' All three charge sectors are included.'
        if channel in ('Hgg', 'Hqqprime'):
            driver = ('The existing source-bound comparison records that the '
                      'pinned public driver skips nonzero ordinary remainders '
                      'from this channel\'s plus functions. This report compares '
                      'the complete coefficient files.')
        elif channel == 'Hqqbar':
            driver = ('The existing source-bound comparison records that the '
                      'pinned public driver omits this channel from its NLO '
                      'channel list. This report compares its coefficient files.')
        else:
            driver = 'The existing comparison records this channel and all coefficient classes in the pinned driver.'
        n, nn = row['CoefficientChecks'], row['NumericalChecks']
        text = (
            f'# {channel}: new SIDIS F hats versus BigTMD\n\n'
            f'**Both F hats agree: {n}/{n} exact comparisons and {nn}/{nn} '
            '90-digit physical-point checks passed.**\n\n'
            f'{coverage}\n\n{reference_scope}\n\n'
            f'Reference commit: `{imports["ReferenceCommit"]}`. '
            'Difference direction: new SIDIS minus reconstructed BigTMD.\n\n'
            'S02 uses the existing checked reference conversion and normalizer. '
            'S03 completes the twelve finite-delta identities across the actual '
            'dilogarithm argument sign regions and their separating boundary. '
            'The S02 residuals required further simplification; no production '
            'coefficient was changed. The 90-digit checks evaluate the original '
            'expressions at two exact physical points per comparison with the '
            'stored relative/absolute tolerance of 10^-60.\n\n'
            f'{driver} See the [existing driver finding]'
            f'(../../../bigTMD_comparison/{PREVIOUS[channel]}/s04_result.md).\n\n'
        )
        if channel == 'Hgq':
            text += ('The inherited independent MadGraph real-emission sign '
                     'comparison remains unresolved. This coefficient comparison '
                     'does not close that separate check.\n\n')
        text += (
            f'- [Current production result](../../{production_relative}).\n'
            '- [Frozen input manifest](s01_result/manifest.json).\n'
            '- [Exact differences and numerical evidence](s03_result.wl).\n'
            '- [S02 proof caches](s02_result/).\n'
            '- [S03 delta proofs](s03_result/).\n\n'
            f'Production SHA256: `{row["ProductionSHA256"]}`.\n\n'
            f'Comparison SHA256: `{sha(ROOT / channel / "s03_result.wl")}`.\n\n'
            f'Final identity job `{run["job_id"]}` on `{run["host"]}` completed '
            f'with peak process-tree RSS {run["peak_rss_bytes"]} bytes and no memory-guard stop. '
            'The source, log and execution receipt are in the parent comparison folder.\n'
        )
        if not (ROOT / channel / 's03_result').is_dir():
            text = text.replace('- [S03 delta proofs](s03_result/).\n', '')
        report = ROOT / channel / 's04_result.md'
        report.write_text(text)
        receipt = dict(row, ReportSHA256=sha(report),
                       ComparisonSHA256=sha(ROOT / channel / 's03_result.wl'),
                       ProductionFile=production_relative)
        (ROOT / channel / 's04_result.json').write_text(json.dumps(receipt, indent=2) + '\n')
        reports[channel] = receipt
        table.append(f'| [{channel}]({channel}/s04_result.md) | {n}/{n} | {nn}/{nn} | Agree |')
    total = sum(r['CoefficientChecks'] for r in result['Channels'].values())
    numerical = sum(r['NumericalChecks'] for r in result['Channels'].values())
    summary = ('# New SIDIS comparison with BigTMD\n\n'
               f'All six channels agree: **{total}/{total} exact comparisons** '
               f'and **{numerical}/{numerical} high-precision checks passed**.\n\n'
               + '\n'.join(table) + '\n\n' + reference_scope + '\n\n'
               'For Hqq/Hgq, the coefficient count includes the checked tensor '
               'projection into both hats; Hqg is compared directly by F-hat '
               'coefficient. The remaining channels are compared as complete '
               'symbolic finite hats. The reports retain the existing Hgg, '
               'Hqqprime and Hqqbar public-driver omissions and the separate '
               'Hgq MadGraph caveat.\n\n'
               'S03 resolved the finite-delta identity normalizations without '
               'changing production results. [Full symbolic output](s03_result.wl), '
               '[machine-readable summary](s03_result.json), '
               '[cluster receipt](s03_execution.json).\n')
    (ROOT / 's04_result.md').write_text(summary)
    final = {'Completed': True, 'AllEqual': True, 'CoefficientChecks': total,
             'NumericalChecks': numerical, 'Channels': reports,
             'SourceSHA256': sha(Path(__file__)), 'S03ResultSHA256': result['ResultSHA256'],
             'ReportSHA256': sha(ROOT / 's04_result.md'),
             'ReferenceCommit': imports['ReferenceCommit']}
    (ROOT / 's04_result.json').write_text(json.dumps(final, indent=2) + '\n')
    with (SIDIS.parent / 'progress.md').open('a') as stream:
        stream.write('\nSIDIS comparison reports complete ' + datetime.now(timezone.utc).isoformat()
                     + f': S04 verified current production/input/result identities and exported all six reports; '
                     f'{total}/{total} exact and {numerical}/{numerical} high-precision checks pass. '
                     'Reference reconstruction and inherited driver/MadGraph caveats remain explicit. '
                     'Next complete README/current-layout links and final structural validation.\n')
    print(f'S04_SUCCESS: {total}/{total} exact and {numerical}/{numerical} numerical comparisons.')


if __name__ == '__main__':
    main()
