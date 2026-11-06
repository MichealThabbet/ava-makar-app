"""Parser for the Orsozoxi / Katamaras plain-text markup.

Markup seen in the source files (documented in docs/content/LIBRARY_INVENTORY.md):
  +++ or ++++…   section break          +Title   heading
  +              paragraph break        ** text  rubric (instruction)
  & / &&         language-block markers (no text; ignored)
Everything else is a text line. Latin-script lines are legacy-encoded Coptic unless
they read as English/French.
"""
from __future__ import annotations

import re

from . import coptic_legacy as cl
from .model import Segment, Unit
from .text import clean_controls, script_of

_REF = re.compile(r'^\(.*\d+\s*:\s*\d+.*\)$')


def line_segment(line: str, kind: str, default_font: str) -> Segment:
    script = script_of(line)
    if script == 'latin':
        lang = cl.latin_language(line)
        if lang == 'cop-legacy':
            font = cl.detect_font(line, default_font)
            conv = cl.convert(line, font)
            meta = {'font': font}
            if conv.unmapped:
                meta['unmapped'] = ''.join(sorted(set(conv.unmapped)))
            return Segment(kind, 'cop', conv.text, raw=line, meta=meta)
        return Segment(kind, lang, line)
    if script == 'coptic':
        return Segment(kind, 'cop', line)
    return Segment(kind, 'ar' if script == 'arabic' else 'und', line)


def parse_sections(text: str, work: str, doc: str, source_path: str,
                   default_font: str = 'avva') -> list[Unit]:
    units: list[Unit] = []
    cur: Unit | None = None

    def start() -> Unit:
        u = Unit(work, f'{doc}/{len(units) + 1:03d}', '', source_path, parent=doc)
        units.append(u)
        return u

    for rawline in text.splitlines():
        line = clean_controls(rawline).strip()
        if not line or line in ('&', '&&', '+'):
            continue
        if re.fullmatch(r'\+{3,}', line):
            cur = None
            continue
        if cur is None:
            cur = start()
        if line.startswith('**'):
            seg = line_segment(line.lstrip('*').strip(), 'rubric', default_font)
        elif line.startswith('+'):
            seg = line_segment(line[1:].strip(), 'heading', default_font)
            if not cur.title:
                cur.title = seg.text
        elif _REF.match(line):
            seg = line_segment(line, 'ref', default_font)
        else:
            seg = line_segment(line, 'text', default_font)
        cur.segments.append(seg)
    for u in units:
        if not u.title and u.segments:
            u.title = u.segments[0].text[:80]
    return [u for u in units if u.segments]
