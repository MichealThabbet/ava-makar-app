"""Unit tests for the import pipeline (no Library checkout needed).

Expected Coptic strings below are conversions of strings that occur in the Library
sources, checked against the Arabized-Coptic column of the same rows and against the
legacy fonts rendered side by side with Noto Sans Coptic.
"""
import sqlite3

import pytest

from ava_import import coptic_legacy as cl
from ava_import.books import BOOK_CODES, name_slots, parse_ref
from ava_import.markup import parse_sections
from ava_import.text import checksum, clean_controls, has_mojibake, normalise_search

G, O = '̀', '̅'


@pytest.mark.parametrize('raw,font,expected', [
    # kholagy row: «إيبي إبروس إفكي إسطاثيتي»
    ('~Epi `proceuxh `ctaqhte', 'athanasius', f'Ⲉ{G}ⲡⲓ ⲡ{G}ⲣⲟⲥⲉⲩⲭⲏ ⲥ{G}ⲧⲁⲑⲏⲧⲉ'),
    # kholagy row: «إيريني باسي»
    ('`Irhnh paci', 'athanasius', f'Ⲓ{G}ⲣⲏⲛⲏ ⲡⲁⲥⲓ'),
    # «إن جوم» / «اوصاﭽي»: j = ϫ in Athanasius
    ('`njom oucaji', 'athanasius', f'ⲛ{G}ϫⲟⲙ ⲟⲩⲥⲁϫⲓ'),
    ("Do[a Patri 'en ]omt", 'athanasius', 'Ⲇⲟⲝⲁ Ⲡⲁⲧⲣⲓ ϧⲉⲛ ϣⲟⲙⲧ'),
    # overline after the letter in Athanasius
    ('Px?c?', 'athanasius', f'Ⲡⲭ{O}ⲥ{O}'),
    ('pentaf;', 'athanasius', 'ⲡⲉⲛⲧⲁϥϯ'),
    # dallal (Avva Shenouda): «ak2an`i qen tekmetovro»
    ('ak2an`i qen tekmetovro', 'avva', f'ⲁⲕϣⲁⲛⲓ{G} ϧⲉⲛ ⲧⲉⲕⲙⲉⲧⲟⲩⲣⲟ'),
    ('do7oloji`a', 'avva', f'ⲇⲟⲝⲟⲗⲟⲅⲓⲁ{G}'),
    ('`wPasoic', 'avva', f'ⲱ{G}Ⲡⲁϭⲟⲓⲥ'),
    # overline before the letter in Avva, invisible glyphs dropped
    ('P=xc.', 'avva', f'Ⲡⲭ{O}ⲥ.'),
    ('(pasoic', 'avva', 'ⲡⲁϭⲟⲓⲥ'),
])
def test_convert(raw, font, expected):
    assert cl.convert(raw, font).text == expected


def test_unverified_glyphs_are_kept_and_reported():
    c = cl.convert('ni=%', 'athanasius')
    assert c.unmapped == ['=']
    assert '=' in c.text


@pytest.mark.parametrize('text,font', [
    ('a42wpi `n5ek`kl3ci`a', 'avva'),
    ("Kata `vr\\q `etafjoc% `nje pi`'", 'athanasius'),
    ('`p]omt>', 'athanasius'),
])
def test_detect_font(text, font):
    assert cl.detect_font(text) == font


@pytest.mark.parametrize('text,lang', [
    ('Evajjelion kata Markon Kef =i=e =a - =e', 'cop-legacy'),
    ("Anon ‘'a peklaoc.", 'cop-legacy'),
    ('#  Agioc o Qeoc. agioc Icxuroc.', 'cop-legacy'),
    ('So you may be counted with the believers,', 'en'),
    ("The Lord's prayer", 'en'),
    ('Le prêtre', 'fr'),
])
def test_latin_language(text, lang):
    assert cl.latin_language(text) == lang


def test_search_normalisation_ignores_tashkeel_and_letter_forms():
    a = normalise_search('فِي الْبَدْءِ خَلَقَ اللهُ السَّمَاوَاتِ وَالأَرْضَ.')
    assert a == normalise_search('في البدء خلق الله السماوات والارض')
    assert normalise_search('مُعلِّمنا إنجيل') == normalise_search('معلمنا انجيل')
    assert normalise_search(f'Ⲡ{G}ⲛⲉⲩⲙⲁ') == normalise_search('ⲡⲛⲉⲩⲙⲁ')


def test_checksum_keeps_tashkeel():
    assert checksum('خَلَقَ') != checksum('خلق')
    assert clean_controls('﻿نص‮') == 'نص'


def test_mojibake_detector():
    assert has_mojibake('Ø§Ù„Ù„Ù‡')
    assert not has_mojibake('الله')


def test_parse_ref():
    assert parse_ref('13:44-52') == [(13, 44, 13, 52)]
    assert parse_ref('5:11-6:13') == [(5, 11, 6, 13)]
    assert parse_ref('96:1,2') == [(96, 1, 96, 1), (96, 2, 96, 2)]
    assert parse_ref('32:11,33:1') == [(32, 11, 32, 11), (33, 1, 33, 1)]
    with pytest.raises(ValueError):
        parse_ref('10:34:42')


def test_book_codes_are_a_bijection_onto_73_books():
    assert len(BOOK_CODES) == 73
    assert sorted(i for i, _ in BOOK_CODES.values()) == list(range(73))
    assert BOOK_CODES['O19'][0] == 20 and BOOK_CODES['O17'][0] == 18 and BOOK_CODES['O40'][0] == 16
    assert BOOK_CODES['N1'][0] == 46 and BOOK_CODES['N27'][0] == 72


def test_slot_names():
    lent_sunday = 'O19_a N2_a O19_b N3_b N8_c N22_c N5_c O19_d N1_d O19_e N3_e'.split()
    assert name_slots(lent_sunday) == [
        'vespers_psalm', 'vespers_gospel', 'matins_psalm', 'matins_gospel', 'pauline', 'catholic',
        'acts', 'liturgy_psalm', 'liturgy_gospel', 'evening_psalm', 'evening_gospel']
    lent_weekday = 'O19_a N1_a N6_b N20_b N5_b O19_c N2_c O2_d O23_d'.split()
    assert name_slots(lent_weekday)[:2] == ['matins_psalm', 'matins_gospel']
    assert name_slots(lent_weekday)[-2:] == ['prophecy', 'prophecy']


def test_markup_sections():
    src = 'الفهرس\n++++++++++\n+صلاة باكر\n** رتبت الكنيسة\n+\n+++\n+الصلاة الربانية\n\nأبانا الذي\n&\n`Aripamev`i `wPasoic\n'
    units = parse_sections(src, 'w', 'doc', 'f.txt', 'avva')
    assert [u.title for u in units] == ['الفهرس', 'صلاة باكر', 'الصلاة الربانية']
    assert [s.kind for s in units[1].segments] == ['heading', 'rubric']
    cop = units[2].segments[-1]
    assert cop.lang == 'cop' and cop.raw == '`Aripamev`i `wPasoic' and cop.text.startswith('Ⲁ')


def test_fts5_available():
    db = sqlite3.connect(':memory:')
    db.execute("create virtual table t using fts5(x, tokenize='unicode61 remove_diacritics 0')")
