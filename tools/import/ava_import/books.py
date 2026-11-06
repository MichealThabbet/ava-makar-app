"""Book importers. Each yields Units (and fills tables) from one canonical source.

Paths are relative to the Library `incoming/` folder.
"""
from __future__ import annotations

import csv
import io
import re
import sqlite3
from pathlib import Path

from . import coptic_legacy as cl
from .markup import line_segment, parse_sections
from .model import Issue, Segment, Unit
from .text import clean_controls, read_text, script_of

ORS = 'orsozxi/DECRYPTED_CONTENT'
KAT = 'katamars2/katamaras-2-0-1/assets'

# Katamaras book codes -> Bible.sqlite book_index, with the chapter count that proves
# the match (Katamaras `assets/Bible/<code>/` file count == Bible.sqlite chapters).
# The two sources order the Old Testament differently (Tobit, Judith, Wisdom, Sirach,
# Baruch), so the code number is never used as an index directly.
OT_CODES = {
    'O1': (0, 50), 'O2': (1, 40), 'O3': (2, 27), 'O4': (3, 36), 'O5': (4, 34), 'O6': (5, 24),
    'O7': (6, 21), 'O8': (7, 4), 'O9': (8, 31), 'O10': (9, 24), 'O11': (10, 22), 'O12': (11, 25),
    'O13': (12, 29), 'O14': (13, 36), 'O15': (14, 10), 'O16': (15, 13), 'O17': (18, 16),
    'O18': (19, 42), 'O19': (20, 151), 'O20': (21, 31), 'O21': (22, 12), 'O22': (23, 8),
    'O23': (26, 66), 'O24': (27, 52), 'O25': (28, 5), 'O26': (30, 48), 'O27': (31, 14),
    'O28': (32, 14), 'O29': (33, 3), 'O30': (34, 9), 'O31': (35, 1), 'O32': (36, 4),
    'O33': (37, 7), 'O34': (38, 3), 'O35': (39, 3), 'O36': (40, 3), 'O37': (41, 2),
    'O38': (42, 14), 'O39': (43, 4), 'O40': (16, 14), 'O41': (17, 16), 'O42': (24, 19),
    'O43': (25, 51), 'O44': (29, 6), 'O45': (44, 16), 'O46': (45, 15),
}
NT_CHAPTERS = [28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13, 5, 5, 3, 5, 1, 1, 1, 22]
NT_CODES = {f'N{i + 1}': (46 + i, n) for i, n in enumerate(NT_CHAPTERS)}
BOOK_CODES = {**OT_CODES, **NT_CODES}

SLOTS = ['vespers_psalm', 'vespers_gospel', 'matins_psalm', 'matins_gospel', 'pauline',
         'catholic', 'acts', 'liturgy_psalm', 'liturgy_gospel']
SLOT_BOOKS = {
    'vespers_psalm': {'O19'}, 'matins_psalm': {'O19'}, 'liturgy_psalm': {'O19'},
    'vespers_gospel': {'N1', 'N2', 'N3', 'N4'}, 'matins_gospel': {'N1', 'N2', 'N3', 'N4'},
    'liturgy_gospel': {'N1', 'N2', 'N3', 'N4'}, 'pauline': {f'N{i}' for i in range(6, 20)},
    'catholic': {f'N{i}' for i in range(20, 27)}, 'acts': {'N5'},
}


class Ctx:
    def __init__(self, lib: Path):
        self.lib = lib
        self.files: list[Path] = []          # every source file read, for the manifest
        self.issues: list[Issue] = []
        self.readings: list[tuple] = []
        self.crossrefs: list[tuple] = []
        self.structures: list[tuple] = []
        self.verses: dict[tuple[int, int, int], str] = {}
        self.chapters: dict[int, int] = {}

    def p(self, rel: str) -> Path:
        return self.lib / rel

    def read(self, path: Path) -> tuple[str, str]:
        self.files.append(path)
        return read_text(path)

    def issue(self, work: str, key: str, sev: str, msg: str) -> None:
        self.issues.append(Issue(work, key, sev, msg))


# ---------------------------------------------------------------- Bible

def bible(ctx: Ctx) -> list[Unit]:
    path = ctx.p(f'{ORS}/bible/Bible.sqlite')
    ctx.files.append(path)
    db = sqlite3.connect(f'file:{path}?mode=ro', uri=True)
    rows = db.execute('select book_index, book_name, chapter_index, chapter_name, ayah_index, '
                      'ayah_name from bible order by book_index, chapter_index, ayah_index').fetchall()
    units: dict[str, Unit] = {}
    expect: dict[tuple[int, int], int] = {}
    gaps: dict[str, list[str]] = {}
    headings: dict[str, int] = {}
    for b, bname, c, cname, a, text in rows:
        bname = clean_controls(bname).strip()
        bkey = f'{b:02d}'
        if bkey not in units:
            units[bkey] = Unit('bible-ar', bkey, bname, path.name)
        key = f'{b:02d}/{c + 1:03d}'
        if key not in units:
            units[key] = Unit('bible-ar', key, f'{bname} — {clean_controls(cname).strip()}',
                              path.name, parent=bkey)
        t = clean_controls(text).strip()
        if not t:
            ctx.issue('bible-ar', key, 'error', f'row {a + 1} empty')
            continue
        m = re.match(r'^(\d+)\s', t)
        if m:
            v = int(m.group(1))
            last = expect.get((b, c), 0)
            if v != last + 1:
                gaps.setdefault(key, []).append(f'{last}->{v}')
            expect[(b, c)] = v
            units[key].segments.append(Segment('verse', 'ar', t, meta={'v': v}))
            ctx.verses[(b, c + 1, v)] = t
        else:
            units[key].segments.append(Segment('heading', 'ar', t))
            headings[key] = headings.get(key, 0) + 1
        ctx.chapters[b] = max(ctx.chapters.get(b, 0), c + 1)
    for key, g in gaps.items():
        ctx.issue('bible-ar', key, 'warning', f'verse numbering jumps (merged or missing verses): {", ".join(g[:8])}')
    for key, n in headings.items():
        ctx.issue('bible-ar', key, 'info', f'{n} unnumbered rows kept as headings')
    for code, (idx, n) in BOOK_CODES.items():
        if ctx.chapters.get(idx) != n:
            ctx.issue('bible-ar', f'{idx:02d}', 'error',
                      f'{code}: expected {n} chapters, Bible.sqlite has {ctx.chapters.get(idx)}')
    return list(units.values())


# ---------------------------------------------------------------- Katameros

def parse_ref(ref: str) -> list[tuple[int, int, int, int]]:
    """'5:11-6:13' / '96:1,2' / '32:11,33:1' -> [(c1, v1, c2, v2), …]."""
    out, chap = [], None
    for part in ref.split(','):
        part = part.strip()
        a, _, z = part.partition('-')
        z = z or a
        if ':' in a:
            chap, va = map(int, a.split(':'))
        else:
            va = int(a)
        if ':' in z:
            zc, vz = map(int, z.split(':'))
        else:
            zc, vz = chap, int(z)
        out.append((chap, va, zc, vz))
        chap = zc
    return out


def _check_ref(ctx: Ctx, table: str, day: str, code: str, ref: str) -> None:
    idx = BOOK_CODES[code][0]
    for c1, v1, c2, v2 in parse_ref(ref):
        for c, v in ((c1, v1), (c2, v2)):
            if (idx, c, v) not in ctx.verses:
                ctx.issue('katameros', f'{table}/{day}', 'error', f'{code}_{ref}: {c}:{v} not in Bible.sqlite')


def _kind(code: str) -> str:
    if code == 'O19':
        return 'P'
    if code in ('N1', 'N2', 'N3', 'N4'):
        return 'G'
    if code == 'N5':
        return 'A'
    if code.startswith('N') and code[1:].isdigit():
        return 'R' if int(code[1:]) <= 19 else 'C'
    return 'O'


def name_slots(refs: list[str]) -> list[str]:
    """Name each reading by its book type and order, not by its column position.

    Before the Pauline epistle: one psalm/gospel pair = matins, two = vespers + matins.
    After it: catholic, acts, liturgy psalm + gospel, then any further pair = evening
    (Lent Sundays). Non-psalm Old Testament readings are prophecies.
    """
    kinds = [_kind(r.split('_', 1)[0]) for r in refs]
    names = ['unknown'] * len(refs)
    try:
        cut = kinds.index('R')
    except ValueError:
        cut = next((i for i, k in enumerate(kinds) if k in 'CA'), len(kinds))
    pre = [i for i in range(cut) if kinds[i] in 'PG']
    pre_names = {4: ['vespers_psalm', 'vespers_gospel', 'matins_psalm', 'matins_gospel'],
                 2: ['matins_psalm', 'matins_gospel']}.get(len(pre))
    if pre_names is None and len(pre) == 1:
        pre_names = ['matins_psalm' if kinds[pre[0]] == 'P' else 'matins_gospel']
    for i, n in zip(pre, pre_names or []):
        names[i] = n
    after = {'R': 'pauline', 'C': 'catholic', 'A': 'acts'}
    pairs = iter(['liturgy', 'evening', 'extra'])
    stage = None
    for i in range(cut, len(kinds)):
        k = kinds[i]
        if k in after:
            names[i] = after[k]
        elif k == 'P':
            stage = next(pairs, 'extra')
            names[i] = f'{stage}_psalm'
        elif k == 'G':
            if stage is None or names[i - 1] != f'{stage}_psalm':
                stage = next(pairs, 'extra')
            names[i] = f'{stage}_gospel'
    for i, k in enumerate(kinds):
        if k == 'O':
            names[i] = 'prophecy'
    return names


def katameros(ctx: Ctx) -> list[Unit]:
    units: list[Unit] = []
    psalm_keys: dict[str, set[str]] = {}
    for table in ('Weekdays', 'Sundays', 'Soam', '50days'):
        path = ctx.p(f'{KAT}/readings/{table}Psalms.txt')
        text, _ = ctx.read(path)
        keys = set()
        for line in text.splitlines():
            m = re.match(r'^\[([^\]]+)\]\[(.*)\]\*?\s*$', clean_controls(line).strip())
            if not m:
                continue
            ref, body = m.group(1).strip(), m.group(2).strip()
            if ref in keys:
                ctx.issue('katameros-psalms', f'{table}/{ref}', 'warning', 'duplicate psalm key')
                continue
            keys.add(ref)
            units.append(Unit('katameros-psalms', f'{table}/{ref}', f'مزمور {ref}', path.name,
                              segments=[Segment('text', 'ar', body, meta={'ref': ref})]))
        psalm_keys[table] = keys
    files = [(f'Weekdays-{m}', 'Weekdays') for m in range(1, 14)] + \
            [('Sundays', 'Sundays'), ('Soam', 'Soam'), ('50days', '50days')]
    for name, ptable in files:
        path = ctx.p(f'{KAT}/readings/{name}.txt')
        text, _ = ctx.read(path)
        for line in text.splitlines():
            groups = re.findall(r'\[([^\]]*)\]', clean_controls(line))
            if len(groups) < 2:
                continue
            day, rest = groups[0].strip(), groups[1:]
            refs = [r.strip() for g in rest if re.match(r'^[ON0]\d+_', g) for r in g.split(';') if r.strip()]
            title = next((g for g in rest if not re.match(r'^[ON0]\d+_', g)), None)
            for i, (r, slot) in enumerate(zip(refs, name_slots(refs))):
                code, ref = r.split('_', 1)
                if code not in BOOK_CODES:
                    ctx.issue('katameros', f'{name}/{day}', 'error', f'unknown book code in {r!r} (source typo?)')
                    continue
                if slot == 'unknown':
                    ctx.issue('katameros', f'{name}/{day}', 'warning', f'cannot place {r} in the reading order')
                try:
                    parse_ref(ref)
                except ValueError:
                    ctx.issue('katameros', f'{name}/{day}', 'error', f'unparseable reference {r!r} (source typo?)')
                    continue
                if code == 'O19':
                    if ref not in psalm_keys[ptable]:
                        ctx.issue('katameros', f'{name}/{day}', 'error', f'psalm {ref} missing in {ptable}Psalms')
                else:
                    _check_ref(ctx, name, day, code, ref)
                ctx.readings.append((name, day, i, slot, code, BOOK_CODES[code][0], ref, title))
    return units


def holy_week(ctx: Ctx) -> list[Unit]:
    units = []
    base = ctx.p(f'{KAT}/readings/HolyWeek')
    for path in sorted(base.rglob('*.txt')):
        rel = path.relative_to(base).with_suffix('').as_posix()
        text, _ = ctx.read(path)
        lines = [clean_controls(x).strip() for x in text.splitlines()]
        lines = [x for x in lines if x]
        if not lines:
            ctx.issue('pascha-readings', rel, 'warning', 'empty file')
            continue
        u = Unit('pascha-readings', rel, lines[0], path.name)
        for i, x in enumerate(lines):
            kind = 'heading' if i == 0 else ('ref' if re.match(r'^\(.*\d.*\)$', x) else 'text')
            u.segments.append(line_segment(x, kind, 'avva'))
        units.append(u)
    return units


# ---------------------------------------------------------------- Synaxarium

def synaxarium(ctx: Ctx) -> list[Unit]:
    units = []
    base = ctx.p(f'{ORS}/documents/sanksar2')
    for path in sorted(base.rglob('*.txt'), key=lambda p: p.relative_to(base).as_posix()):
        folder = path.parent.name
        md = re.search(r'\((\d+)\)', path.name)
        if folder == 'special':
            m, d, key = 0, int(path.stem), f'special/{path.stem}'   # movable feasts (1, 40, 50)
        elif md:
            m, d = int(folder), int(md.group(1))
            key = f'{m:02d}/{d:02d}'
        else:
            m, d, key = -1, 0, f'{folder}/{path.stem}'
        text, _ = ctx.read(path)
        lines = [clean_controls(x).strip() for x in text.splitlines()]
        lines = [x for x in lines if x]
        if not lines:
            ctx.issue('synaxarium-ar', key, 'info', 'empty file in source, skipped')
            continue
        u = Unit('synaxarium-ar', key, lines[0] if lines else key, path.name, meta={'month': m, 'day': d})
        for i, x in enumerate(lines):
            if i == 0:
                kind = 'heading'
            elif re.match(r'^\d+\s*[–-]\s*', x):
                kind = 'item'
            else:
                kind = 'text'
            u.segments.append(Segment(kind, 'ar', x))
        if len(u.segments) < 2:
            ctx.issue('synaxarium-ar', key, 'warning', 'day has no body')
        units.append(u)
    days = {(u.meta['month'], u.meta['day']) for u in units}
    for m in range(1, 13):
        for d in range(1, 31):
            if (m, d) not in days:
                ctx.issue('synaxarium-ar', f'{m:02d}/{d:02d}', 'error', 'missing day')
    return units


# ---------------------------------------------------------------- Plus-markup books

def markup_doc(ctx: Ctx, work: str, rel: str, doc: str, font: str) -> list[Unit]:
    path = ctx.p(rel)
    text, _ = ctx.read(path)
    units = parse_sections(text, work, doc, path.name, font)
    return units


def agpeya(ctx: Ctx) -> list[Unit]:
    units = markup_doc(ctx, 'agpeya-ar', f'{ORS}/documents/agypa.txt', 'agpeya', 'avva')
    if units and all(s.kind == 'text' for s in units[0].segments):
        toc = units.pop(0)       # first block is the list of hours
        ctx.structures.append(('agpeya-ar', 'toc', [s.text for s in toc.segments]))
    return units


def rites(ctx: Ctx) -> list[Unit]:
    out = []
    for doc in ('kism', 'kandil', 'lakan', 'sagda', 'taks'):
        out += markup_doc(ctx, 'rites-ar', f'{ORS}/documents/{doc}.txt', doc, 'avva')
    return out


def dallal(ctx: Ctx) -> list[Unit]:
    out = []
    for path in sorted(ctx.p(f'{ORS}/documents/dallal').glob('*.txt')):
        out += markup_doc(ctx, 'pascha-dallal', str(path.relative_to(ctx.lib)), path.stem, 'avva')
    return out


# ---------------------------------------------------------------- CSV books (kholagy, psalmody)

def _num(c: str) -> bool:
    return bool(re.fullmatch(r'\d+(\.0)?', c.strip()))


def csv_book(ctx: Ctx, work: str, folder: str, default_font: str, copar_col: int) -> list[Unit]:
    """copar_col: column holding Arabized Coptic (checked by column statistics per book)."""
    base = ctx.p(f'{ORS}/spreadsheets/{folder}')
    units = []
    for path in sorted(base.rglob('*.csv')):
        key = path.relative_to(base).with_suffix('').as_posix()
        text, _ = ctx.read(path)
        rows = list(csv.reader(io.StringIO(text)))
        widths = {len(r) for r in rows}
        if not rows:
            continue
        if max(widths) >= 27 or all(len([c for c in r if c.strip()]) <= 2 and _num(r[0]) for r in rows if r):
            ctx.structures.append((work, key, rows))     # ordering table / sequence of piece ids
            continue
        u = Unit(work, key, '', path.name)
        for r in rows:
            cells = [(i, clean_controls(c).strip()) for i, c in enumerate(r)]
            cells = [(i, c) for i, c in cells if c]
            if not cells:
                continue
            if _num(r[0]) and len(r) > 1:
                u.meta.setdefault('piece_ids', []).append(int(float(r[0])))
                for i, c in cells[1:]:
                    kind = 'title' if i == 1 else 'rubric'
                    seg = line_segment(c, kind, default_font)
                    seg.meta['col'] = i
                    u.segments.append(seg)
                    if kind == 'title' and not u.title:
                        u.title = seg.text
                continue
            role = None
            content = [(i, c) for i, c in cells if i >= 3]
            if any(i == 2 for i, _ in cells) and content:
                role = dict(cells)[2]
            elif any(i == 2 for i, _ in cells):
                content = [(i, c) for i, c in cells if i >= 2]
            for i, c in content:
                mark = None
                if c.startswith('#'):
                    mark, c = '#', c.lstrip('#').strip()
                    if not c:
                        continue
                sc = script_of(c)
                if sc == 'arabic':
                    seg = Segment('text', 'cop-ar' if i == copar_col else 'ar', c)
                else:
                    seg = line_segment(c, 'text', default_font)
                    if i == 10 and seg.lang == 'en' and len(c) < 25 and any(j == 11 for j, _ in content):
                        seg.kind = 'role'      # English speaker label (Priest, Deacon, People)
                seg.role = role
                seg.meta['col'] = i
                if mark:
                    seg.meta['mark'] = mark
                if seg.meta.get('unmapped'):
                    ctx.issue(work, key, 'info', f"unmapped legacy chars {seg.meta['unmapped']!r} col {i}")
                u.segments.append(seg)
        if not u.title:
            u.title = key
        if u.segments:
            units.append(u)
    return units


def kholagy(ctx: Ctx) -> list[Unit]:
    return csv_book(ctx, 'kholagy', 'kholagy', 'athanasius', 4)


def psalmody_annual(ctx: Ctx) -> list[Unit]:
    return csv_book(ctx, 'psalmody-annual', 'psalmodySanawy', 'athanasius', 4)


def psalmody_kiahk(ctx: Ctx) -> list[Unit]:
    return csv_book(ctx, 'psalmody-kiahk', 'absalmody', 'athanasius', 5)


# ---------------------------------------------------------------- Cross references

def shawahed(ctx: Ctx) -> list[Unit]:
    base = ctx.p(f'{ORS}/spreadsheets/shawahed')
    for path in sorted(base.rglob('*.csv'), key=lambda p: int(p.parent.name)):
        text, _ = ctx.read(path)
        for r in csv.reader(io.StringIO(text)):
            if len(r) < 4 or not _num(r[0]) or not _num(r[1]):
                continue
            refs = [clean_controls(c).strip() for c in r[3:] if c.strip()]
            ctx.crossrefs.append((int(path.parent.name), int(float(r[0])), int(float(r[1])),
                                  clean_controls(r[2]).strip(), ' | '.join(refs)))
    return []
