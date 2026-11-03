"""Build app/web/prototype/data.js for the home-page prototype.

Sources (owner's files, approved — DEC-P0-17, DEC-P0-19, DEC-P0-28):
- Reading references: Katamaras 2.0.1 `readings/Weekdays-<month>.txt` (owner's work).
- Verse text with tashkeel: Orsozoxi `DECRYPTED_CONTENT/bible/Bible.sqlite` (Library- repo).
- Synaxarium: Orsozoxi `DECRYPTED_CONTENT/documents/sanksar2/<m>/0<m> (<d>).txt`.
- St Macarius sayings: defnar/bostan_al_rohban (diacritised field `secd`).
- Fr Matta sayings: Fr Matta app `som.db`, table `aqwal`.
- News: tools/prototype/content/news.md (owner, verbatim).

Usage: python3 build_data.py <katamaras_assets> <library_orsozxi> <bostan_sections> <matta_db> <news.md> <out.js> <coptic_month> <coptic_day>
"""
import json
import re
import sqlite3
import sys

KAT, LIB, BOSTAN, MATTA, NEWS, OUT = sys.argv[1:7]
CM, CD = int(sys.argv[7]), int(sys.argv[8])

db = sqlite3.connect(f'file:{LIB}/DECRYPTED_CONTENT/bible/Bible.sqlite?mode=ro', uri=True)
names = dict(db.execute('select book_index, book_name from bible group by book_index'))


def book_index(code):
    # Katamaras: O19 = Psalms (index 20 here); N1..N27 = Matthew..Revelation (46..72).
    if code == 'O19':
        return 20
    if code.startswith('N'):
        return 45 + int(code[1:])
    raise ValueError(code)


def verses(code, ref):
    """ref like '32:11,33:1' or '3:20-4:9' or '33:1,12'."""
    b = book_index(code)
    out, chap = [], None
    for part in ref.split(','):
        if '-' in part:
            a, z = part.split('-')
        else:
            a = z = part
        if ':' in a:
            chap, va = map(int, a.split(':'))
        else:
            va = int(a)
        if ':' in z:
            zc, vz = map(int, z.split(':'))
        else:
            zc, vz = chap, int(z)
        rows = db.execute(
            'select chapter_index+1, ayah_index+1, ayah_name from bible where book_index=? and '
            '((chapter_index+1)*1000+ayah_index+1) between ? and ? order by chapter_index, ayah_index',
            (b, chap * 1000 + va, zc * 1000 + vz)).fetchall()
        chap = zc
        out += [[c, v, re.sub(r'^\s*\d+\s*', '', t).strip()] for c, v, t in rows]
    return names[b].strip(), out


labels = ['مزمور عشية', 'إنجيل عشية', 'مزمور باكر', 'إنجيل باكر', 'البولس', 'الكاثوليكون',
          'الإبركسيس', 'مزمور القداس', 'إنجيل القداس']
line = next(l for l in open(f'{KAT}/readings/Weekdays-{CM}.txt', encoding='utf-8-sig')
            if l.startswith(f'[{CD}/{CM}]'))
refs = re.findall(r'\[([ON]\d+)_([^\]]+)\]', line)
readings = []
for lab, (code, ref) in zip(labels, refs):
    book, vv = verses(code, ref)
    readings.append({'label': lab, 'book': book, 'ref': ref, 'verses': vv})

sx = open(f'{LIB}/DECRYPTED_CONTENT/documents/sanksar2/{CM}/{CM:02d} ({CD}).txt', encoding='utf-8-sig').read().strip()
sx_lines = [l.strip() for l in sx.split('\n') if l.strip()]
titles = []
for l in sx_lines[1:]:
    if re.match(r'^\d+ –', l) and len(l) < 120:
        titles.append(l)
    else:
        break
synax = {'heading': sx_lines[0], 'titles': titles, 'text': sx_lines[1 + len(titles):]}

mac = []
for sec in ['002_القديس_مقاريوس_الكبير', '014_من_اقوال_القديس_مقاريوس']:
    j = json.load(open(f'{BOSTAN}/{sec}/content.json', encoding='utf-8'))
    for p in j['paragraphs']:
        t = (p.get('secd') or p.get('sec') or '').strip()
        if 60 < len(t) <= 900:
            mac.append({'id': p['_id'], 'text': t})

m = sqlite3.connect(f'file:{MATTA}?mode=ro', uri=True)
mac.sort(key=lambda x: 0 if x['text'].lstrip().startswith('قال') else 1)
matta = [t.strip() for (t,) in m.execute('select title from aqwal order by id') if t and t.strip()]

news = []
for block in open(NEWS, encoding='utf-8').read().split('\n===\n'):
    block = re.sub(r'^<!--.*?-->\n', '', block, flags=re.S)
    head, body = block.split('\n---\n', 1)
    item = dict(l.split(': ', 1) for l in head.strip().split('\n'))
    item['images'] = item.get('images', '').split('|') if item.get('images') else []
    item['facts'] = item['facts'].split('|') if item.get('facts') else []
    item['body'] = [p.strip() for p in body.strip().split('\n\n') if p.strip()]
    news.append(item)

data = {
    'day': {'gregorian': '2026-11-03', 'weekday': 'الثلاثاء', 'label': 'الثلاثاء الموافق ٣ نوفمبر ٢٠٢٦ م ، ٢٤ بابه ١٧٤٣ ش'},
    'readings': readings,
    'synaxarium': synax,
    'macarius': mac,
    'matta': matta,
    'news': news,
    'sources': {
        'readings': 'جدول قراءات قطمارس 2.0.1 — نص الكتاب المقدس المشكول (فاندايك)',
        'synaxarium': 'السنكسار — حزمة أرثوذكسي',
        'macarius': 'بستان الرهبان',
        'matta': 'من أقوال الأب متى المسكين — تطبيق الأب متى المسكين',
    },
}
open(OUT, 'w', encoding='utf-8').write('window.AVA_DATA = ' + json.dumps(data, ensure_ascii=False) + ';\n')
print(len(readings), 'readings;', sum(len(r['verses']) for r in readings), 'verses;', len(mac), 'macarius;', len(matta), 'matta;', len(news), 'news')
