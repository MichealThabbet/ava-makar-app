"""Integration test against a Library- checkout (set AVA_LIBRARY=<path>/incoming).

Rebuilds every work and compares it with the committed manifest, so any change to a
source file or to the importers that alters stored text fails here.
"""
import json
import os
import sqlite3
from pathlib import Path

import pytest

from ava_import import build
from ava_import.text import normalise_search

LIB = os.environ.get('AVA_LIBRARY')
ROOT = Path(__file__).resolve().parents[3]
pytestmark = pytest.mark.skipif(not LIB, reason='AVA_LIBRARY not set')


@pytest.fixture(scope='module')
def out(tmp_path_factory):
    d = tmp_path_factory.mktemp('content')
    rc = build.main(['--library', LIB, '--out', str(d), '--manifest',
                     str(ROOT / 'data/content/manifest.json'), '--check'])
    assert rc == 0, 'manifest mismatch: a source text or an importer changed'
    return d


def test_counts(out):
    db = sqlite3.connect(out / 'content.db')
    n = dict(db.execute('select u.work_id, count(*) from segment s join unit u on u.id=s.unit_id group by 1'))
    assert n['bible-ar'] == 35784
    assert db.execute("select count(*) from unit where work_id='synaxarium-ar' and key like '__/__'").fetchone()[0] >= 365
    assert db.execute('select count(distinct day_key) from reading where table_name like "Weekdays-%"').fetchone()[0] >= 30


def test_every_unit_is_imported_not_approved(out):
    db = sqlite3.connect(out / 'content.db')
    assert db.execute("select distinct status from unit").fetchall() == [('imported',)]


def test_search_pack_finds_genesis_without_tashkeel(out):
    db = sqlite3.connect(out / 'packs' / 'bible-ar.sqlite')
    q = normalise_search('في البدء خلق الله')
    rows = db.execute('select s.text from search join segment s on s.id=search.rowid '
                      'where search match ? limit 3', (f'"{q}"',)).fetchall()
    assert rows and rows[0][0].startswith('1 فِي الْبَدْءِ')


def test_no_unconverted_legacy_coptic_left(out):
    db = sqlite3.connect(out / 'content.db')
    bad = db.execute("select count(*) from segment where lang='cop' and text glob '*[a-z]*' "
                     "and meta not like '%unmapped%'").fetchone()[0]
    assert bad == 0


def test_manifest_is_committed():
    m = json.loads((ROOT / 'data/content/manifest.json').read_text())
    assert m['works']['bible-ar']['segments'] == 35784
