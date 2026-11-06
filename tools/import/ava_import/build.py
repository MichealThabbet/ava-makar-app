"""Build the content database, offline packs, manifest and import report.

    python3 -m ava_import.build --library <Library->/incoming --out build/content \
        [--manifest data/content/manifest.json] [--check] [--report docs/content/IMPORT_REPORT.md]

--check fails (exit 1) when any work checksum or source-file hash differs from the
committed manifest: a changed sacred text never passes silently.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import sys
from collections import Counter
from pathlib import Path

from . import books
from .model import Work
from .store import Store, build_pack
from .text import has_mojibake, sha256_bytes

APPROVAL = 'Owner approval for the whole Library (DEC-P0-17, DEC-P0-28, DEC-P0-30, DEC-P0-34); monastery text review pending'

SOURCES = {
    'ors-bible': dict(package='orsozxi', path='DECRYPTED_CONTENT/bible/Bible.sqlite',
                      title='الكتاب المقدس — نص عربي مشكول (73 سفراً)', language='ar',
                      edition='Orsozoxi Bible.sqlite; translation/edition not stated in the file — to confirm'),
    'kat-201': dict(package='katamars2', path='katamaras-2-0-1/assets/readings',
                    title='القطمارس 2.0.1 — جداول القراءات ومزامير القطمارس وقراءات البصخة', language='ar',
                    compiler='Eng. Mishel Thabet with Fr Ighnatios El-Anba Bishoy (DEC-P0-13/14)'),
    'ors-sanksar': dict(package='orsozxi', path='DECRYPTED_CONTENT/documents/sanksar2',
                        title='السنكسار', language='ar'),
    'ors-agpeya': dict(package='orsozxi', path='DECRYPTED_CONTENT/documents/agypa.txt',
                       title='الأجبية', language='ar'),
    'ors-rites': dict(package='orsozxi', path='DECRYPTED_CONTENT/documents/{kism,kandil,lakan,sagda,taks}.txt',
                      title='الطقوس: القسمة، القنديل، اللقان، السجدة، الطقس', language='ar+cop'),
    'ors-dallal': dict(package='orsozxi', path='DECRYPTED_CONTENT/documents/dallal',
                       title='دلال البصخة (أسبوع الآلام)', language='ar+cop'),
    'ors-kholagy': dict(package='orsozxi', path='DECRYPTED_CONTENT/spreadsheets/kholagy',
                        title='الخولاجي المقدس', language='ar+cop+cop-ar+en'),
    'ors-psalmody': dict(package='orsozxi', path='DECRYPTED_CONTENT/spreadsheets/psalmodySanawy',
                         title='الإبصلمودية السنوية', language='ar+cop+cop-ar+en+fr'),
    'ors-absalmody': dict(package='orsozxi', path='DECRYPTED_CONTENT/spreadsheets/absalmody',
                          title='الإبصلمودية الكيهكية', language='ar+cop+cop-ar'),
    'ors-shawahed': dict(package='orsozxi', path='DECRYPTED_CONTENT/spreadsheets/shawahed',
                         title='شواهد الكتاب المقدس (مراجع متقاطعة)', language='ar'),
}

WORKS = [
    (Work('bible-ar', 'الكتاب المقدس', 'Holy Bible (Arabic)', 'bible', 'ors-bible'), books.bible),
    (Work('katameros-psalms', 'مزامير القطمارس', 'Katameros psalm verses', 'liturgical', 'kat-201'), books.katameros),
    (Work('pascha-readings', 'قراءات البصخة', 'Holy Week readings', 'liturgical', 'kat-201'), books.holy_week),
    (Work('synaxarium-ar', 'السنكسار', 'Synaxarium', 'synaxarium', 'ors-sanksar'), books.synaxarium),
    (Work('agpeya-ar', 'الأجبية', 'Agpeya', 'liturgical', 'ors-agpeya'), books.agpeya),
    (Work('rites-ar', 'الطقوس', 'Rites', 'rite', 'ors-rites'), books.rites),
    (Work('pascha-dallal', 'دلال البصخة', 'Holy Week service book', 'liturgical', 'ors-dallal'), books.dallal),
    (Work('kholagy', 'الخولاجي المقدس', 'Euchologion', 'liturgical', 'ors-kholagy'), books.kholagy),
    (Work('psalmody-annual', 'الإبصلمودية السنوية', 'Annual Psalmody', 'liturgical', 'ors-psalmody'), books.psalmody_annual),
    (Work('psalmody-kiahk', 'الإبصلمودية الكيهكية', 'Kiahk Psalmody', 'liturgical', 'ors-absalmody'), books.psalmody_kiahk),
    (Work('crossrefs', 'الشواهد', 'Cross references', 'reference', 'ors-shawahed'), books.shawahed),
]


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--library', required=True, type=Path)
    ap.add_argument('--out', required=True, type=Path)
    ap.add_argument('--manifest', type=Path, default=Path('data/content/manifest.json'))
    ap.add_argument('--report', type=Path)
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--write-manifest', action='store_true')
    a = ap.parse_args(argv)

    imported_at = os.environ.get('AVA_IMPORT_DATE', dt.date.today().isoformat())
    ctx = books.Ctx(a.library)
    store = Store(a.out / 'content.db', imported_at)
    manifest: dict = {'works': {}, 'sources': {}}
    stats: dict = {}
    for work, fn in WORKS:
        before = len(ctx.files)
        units = fn(ctx)
        files = ctx.files[before:]
        src = SOURCES[work.source]
        if work.source not in manifest['sources']:
            store.add_source({'id': work.source, 'rights': 'owner-approved', 'approval_basis': APPROVAL, **src}, [])
            manifest['sources'][work.source] = {}
        blobs = [(f.relative_to(a.library).as_posix(), f.read_bytes()) for f in files]
        store.db.executemany('insert or ignore into source_file values (?,?,?,?)',
                             [(work.source, p, sha256_bytes(b), len(b)) for p, b in blobs])
        manifest['sources'][work.source].update({p: sha256_bytes(b) for p, b in blobs})
        wsum = store.add_work(work, units)
        segs = [s for u in units for s in u.segments]
        for u in units:
            for sg in u.segments:
                if has_mojibake(sg.text):
                    ctx.issue(work.id, u.key, 'error', f'mojibake: {sg.text[:40]!r}')
        stats[work.id] = {
            'units': len(units), 'segments': len(segs), 'files': len(files),
            'langs': dict(Counter(s.lang for s in segs).most_common()),
            'converted_coptic': sum(1 for s in segs if s.raw is not None),
            'unmapped_segments': sum(1 for s in segs if s.meta.get('unmapped')),
        }
        manifest['works'][work.id] = {'checksum': wsum, 'units': len(units), 'segments': len(segs)}
        print(f"✓ {work.id}: {len(units)} units, {len(segs)} segments", file=sys.stderr)

    store.db.executemany('insert into reading values (?,?,?,?,?,?,?,?)', ctx.readings)
    store.db.executemany('insert into crossref values (?,?,?,?,?)', ctx.crossrefs)
    store.db.executemany('insert or replace into structure values (?,?,?)',
                         [(w, k, json.dumps(d, ensure_ascii=False)) for w, k, d in ctx.structures])
    store.db.executemany('insert into issue values (?,?,?,?)',
                         [(i.work, i.key, i.severity, i.message) for i in ctx.issues])
    manifest['tables'] = {'reading': len(ctx.readings), 'crossref': len(ctx.crossrefs),
                          'structure': len(ctx.structures)}
    store.close()

    packs = {}
    for work, _ in WORKS:
        if manifest['works'][work.id]['segments']:
            packs[work.id] = build_pack(a.out / 'content.db', work.id, a.out / 'packs' / f'{work.id}.sqlite')
    (a.out / 'packs' / 'index.json').write_text(json.dumps(packs, ensure_ascii=False, indent=1))

    issues = Counter((i.work, i.severity) for i in ctx.issues)
    if a.report:
        write_report(a.report, stats, manifest, ctx, issues, imported_at)
    if a.write_manifest:
        a.manifest.parent.mkdir(parents=True, exist_ok=True)
        a.manifest.write_text(json.dumps(manifest, ensure_ascii=False, indent=1, sort_keys=True) + '\n')
    if a.check:
        ref = json.loads(a.manifest.read_text())
        diff = [k for k in set(ref['works']) | set(manifest['works'])
                if ref['works'].get(k) != manifest['works'].get(k)]
        for s in set(ref['sources']) | set(manifest['sources']):
            r, m = ref['sources'].get(s, {}), manifest['sources'].get(s, {})
            diff += [f'{s}:{p}' for p in set(r) | set(m) if r.get(p) != m.get(p)]
        if diff:
            print('✗ manifest mismatch: ' + ', '.join(sorted(diff)[:20]), file=sys.stderr)
            return 1
        print('✓ manifest matches', file=sys.stderr)
    errors = sum(n for (w, sev), n in issues.items() if sev == 'error')
    print(f'issues: {dict(issues)}; errors={errors}', file=sys.stderr)
    return 0


def write_report(path: Path, stats, manifest, ctx, issues, imported_at) -> None:
    L = ['# Import report', '',
         f'Generated by `tools/import` (`python3 -m ava_import.build`), import date {imported_at}.',
         'All records are status `imported`; nothing is `approved-by-monastery` yet.', '',
         '| Work | Units | Segments | Files | Languages | Coptic converted | Segments with unmapped chars |',
         '|---|---:|---:|---:|---|---:|---:|']
    for w, s in stats.items():
        langs = ', '.join(f'{k} {v}' for k, v in s['langs'].items())
        L.append(f"| `{w}` | {s['units']} | {s['segments']} | {s['files']} | {langs} | "
                 f"{s['converted_coptic']} | {s['unmapped_segments']} |")
    L += ['', f"Tables: readings {manifest['tables']['reading']}, cross references "
          f"{manifest['tables']['crossref']}, structure/order tables {manifest['tables']['structure']}.", '',
          '## Issues', '', '| Work | Severity | Count | First examples |', '|---|---|---:|---|']
    for (w, sev), n in sorted(issues.items()):
        ex = [f'{i.key}: {i.message}' for i in ctx.issues if i.work == w and i.severity == sev][:3]
        L.append(f"| `{w}` | {sev} | {n} | {'; '.join(ex).replace('|', '/')} |")
    errs = [i for i in ctx.issues if i.severity == 'error']
    if errs:
        L += ['', '## Errors to review (source errata — not corrected by the importer)', '',
              '| # | Work | Where | Problem |', '|---:|---|---|---|']
        L += [f'| {n} | `{i.work}` | `{i.key}` | {i.message} |' for n, i in enumerate(errs, 1)]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text('\n'.join(L) + '\n')


if __name__ == '__main__':
    sys.exit(main())
