"""Content database (SQLite, same shape as the planned PostgreSQL schema) and offline packs."""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path

from .model import Unit, Work
from .text import checksum, normalise_search, sha256_bytes

SCHEMA = """
CREATE TABLE source (
  id TEXT PRIMARY KEY, package TEXT NOT NULL, path TEXT NOT NULL, title TEXT NOT NULL,
  edition TEXT, compiler TEXT, language TEXT, rights TEXT NOT NULL, approval_basis TEXT,
  notes TEXT);
CREATE TABLE source_file (
  source_id TEXT NOT NULL REFERENCES source(id), path TEXT NOT NULL, sha256 TEXT NOT NULL,
  bytes INTEGER NOT NULL, PRIMARY KEY (source_id, path));
CREATE TABLE work (
  id TEXT PRIMARY KEY, title_ar TEXT NOT NULL, title_en TEXT NOT NULL, kind TEXT NOT NULL,
  source_id TEXT NOT NULL REFERENCES source(id), checksum TEXT);
CREATE TABLE unit (
  id INTEGER PRIMARY KEY, work_id TEXT NOT NULL REFERENCES work(id), key TEXT NOT NULL,
  parent_key TEXT, ord INTEGER NOT NULL, title TEXT NOT NULL, source_path TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'imported'
    CHECK (status IN ('draft','imported','reviewed','approved-by-monastery')),
  version INTEGER NOT NULL DEFAULT 1, imported_at TEXT NOT NULL, checksum TEXT NOT NULL,
  meta TEXT, UNIQUE (work_id, key));
CREATE TABLE segment (
  id INTEGER PRIMARY KEY, unit_id INTEGER NOT NULL REFERENCES unit(id), ord INTEGER NOT NULL,
  kind TEXT NOT NULL, lang TEXT NOT NULL, role TEXT, text TEXT NOT NULL, raw TEXT,
  checksum TEXT NOT NULL, meta TEXT);
CREATE INDEX segment_unit ON segment(unit_id, ord);
CREATE TABLE reading (
  table_name TEXT NOT NULL, day_key TEXT NOT NULL, ord INTEGER NOT NULL, slot TEXT NOT NULL,
  book_code TEXT NOT NULL, book_index INTEGER NOT NULL, ref TEXT NOT NULL, title TEXT,
  PRIMARY KEY (table_name, day_key, ord));
CREATE TABLE crossref (
  book_no INTEGER NOT NULL, chapter INTEGER NOT NULL, verse INTEGER NOT NULL, word TEXT,
  refs TEXT NOT NULL);
CREATE TABLE structure (work_id TEXT NOT NULL, key TEXT NOT NULL, data TEXT NOT NULL,
  PRIMARY KEY (work_id, key));
CREATE TABLE issue (work_id TEXT NOT NULL, key TEXT NOT NULL, severity TEXT NOT NULL,
  message TEXT NOT NULL);
"""


def unit_checksum(u: Unit) -> str:
    parts = [u.key, u.title] + [f'{s.kind}|{s.lang}|{s.role or ""}|{checksum(s.text)}' for s in u.segments]
    return checksum('\n'.join(parts))


class Store:
    def __init__(self, path: Path, imported_at: str):
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            path.unlink()
        self.db = sqlite3.connect(path)
        self.db.executescript(SCHEMA)
        self.imported_at = imported_at

    def add_source(self, s: dict, files: list[tuple[str, bytes]]) -> None:
        self.db.execute('insert into source values (?,?,?,?,?,?,?,?,?,?)',
                        (s['id'], s['package'], s['path'], s['title'], s.get('edition'),
                         s.get('compiler'), s.get('language'), s['rights'], s.get('approval_basis'),
                         s.get('notes')))
        self.db.executemany('insert or ignore into source_file values (?,?,?,?)',
                            [(s['id'], p, sha256_bytes(b), len(b)) for p, b in files])

    def add_work(self, w: Work, units: list[Unit]) -> str:
        sums = []
        self.db.execute('insert into work (id,title_ar,title_en,kind,source_id) values (?,?,?,?,?)',
                        (w.id, w.title_ar, w.title_en, w.kind, w.source))
        for n, u in enumerate(units):
            cs = unit_checksum(u)
            sums.append(f'{u.key}:{cs}')
            cur = self.db.execute(
                'insert into unit (work_id,key,parent_key,ord,title,source_path,imported_at,checksum,meta)'
                ' values (?,?,?,?,?,?,?,?,?)',
                (w.id, u.key, u.parent, n, u.title, u.source_path, self.imported_at, cs,
                 json.dumps(u.meta, ensure_ascii=False) if u.meta else None))
            uid = cur.lastrowid
            self.db.executemany(
                'insert into segment (unit_id,ord,kind,lang,role,text,raw,checksum,meta) values (?,?,?,?,?,?,?,?,?)',
                [(uid, i, s.kind, s.lang, s.role, s.text, s.raw, checksum(s.text),
                  json.dumps(s.meta, ensure_ascii=False) if s.meta else None)
                 for i, s in enumerate(u.segments)])
        wsum = checksum('\n'.join(sums))
        self.db.execute('update work set checksum=? where id=?', (wsum, w.id))
        return wsum

    def close(self) -> None:
        self.db.commit()
        self.db.execute('vacuum')
        self.db.close()


def build_pack(content_db: Path, work_id: str, out: Path) -> dict:
    """Offline pack for one work: its units and segments plus an FTS5 search index.

    The index holds normalised keys only (tashkeel-insensitive); the displayed text is
    always the stored original.
    """
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()
    db = sqlite3.connect(out)
    db.execute('attach database ? as src', (str(content_db),))
    db.executescript(f"""
      create table work as select * from src.work where id='{work_id}';
      create table unit as select * from src.unit where work_id='{work_id}';
      create table segment as select s.* from src.segment s join src.unit u on u.id=s.unit_id
        where u.work_id='{work_id}';
      create index segment_unit on segment(unit_id, ord);
      create virtual table search using fts5(norm, tokenize='unicode61 remove_diacritics 0');
    """)
    rows = db.execute('select id, text from segment').fetchall()
    db.executemany('insert into search(rowid, norm) values (?, ?)',
                   [(i, normalise_search(t)) for i, t in rows])
    meta = dict(db.execute('select id, checksum from work').fetchall())
    db.commit()
    db.execute('detach database src')
    db.execute('vacuum')
    db.close()
    return {'work': work_id, 'checksum': meta.get(work_id), 'segments': len(rows),
            'sha256': sha256_bytes(out.read_bytes())}
