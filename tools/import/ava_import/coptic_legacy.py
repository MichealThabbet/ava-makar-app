"""Legacy Coptic font encodings -> Unicode Coptic.

The Library texts store Coptic as ASCII typed for two legacy fonts. The tables below
were read glyph by glyph from the fonts themselves (Library- `orsozxi/RECOVERED_CODE/
resources/assets/Avva_Shenouda.ttf` and `Athanasius.TTF`), rendered next to Noto Sans
Coptic, and cross-checked against the Arabized-Coptic column of the same rows
(e.g. «إسطاثيتي» = `ctaqhte` in Athanasius = ⲥⲧⲁⲑⲏⲧⲉ). See docs/content/COPTIC_LEGACY_FONTS.md.

Rule: convert exactly what the font displays. A character whose glyph is empty in the
font is dropped (it was invisible to readers). A character whose glyph is not verified
is kept as-is and reported as `unmapped`; it is never guessed.
"""
from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass, field

GRAVE = '̀'      # jinkim
OVERLINE = '̅'   # abbreviation / numeral line
ACUTE = '́'

_LOWER = {
    'a': 'ⲁ', 'b': 'ⲃ', 'c': 'ⲥ', 'd': 'ⲇ', 'e': 'ⲉ', 'i': 'ⲓ', 'k': 'ⲕ', 'l': 'ⲗ',
    'm': 'ⲙ', 'n': 'ⲛ', 'o': 'ⲟ', 'p': 'ⲡ', 'r': 'ⲣ', 's': 'ϭ', 't': 'ⲧ', 'w': 'ⲱ',
    'x': 'ⲭ', 'y': 'ⲯ', 'z': 'ⲍ',
}


def _with_upper(m: dict[str, str]) -> dict[str, str]:
    out = dict(m)
    for k, v in m.items():
        if k.isalpha() and k.islower():
            out[k.upper()] = v.upper()
    return out


# Avva Shenouda (CS) layout.
AVVA_BASE = _with_upper({**_LOWER, 'f': 'ⲫ', 'g': 'ϫ', 'h': 'ϩ', 'j': 'ⲅ', 'q': 'ϧ', 'v': 'ⲩ'})
AVVA_BASE.update({
    '0': 'ⲑ', ')': 'Ⲑ', '2': 'ϣ', '@': 'Ϣ', '3': 'ⲏ', '#': 'Ⲏ', '4': 'ϥ', '$': 'Ϥ',
    '5': 'ϯ', '%': 'Ϯ', '6': 'ⲋ', '^': 'Ⲋ', '7': 'ⲝ', '&': 'Ⲝ',
    'u': 'ⲟ' + OVERLINE + 'ⲥ' + OVERLINE, '!': 'Ⲭ' + OVERLINE + 'ⲉ' + OVERLINE,
    '/': '✥', '\\': '✝', '[': '✟', ']': '✟',
    ':': ':', ';': ';', '.': '.', '-': '-', '?': '?', '*': '*', ' ': ' ',
})
AVVA_PREFIX_MARK = {'`': GRAVE, '~': GRAVE, '=': OVERLINE, "'": ACUTE}
AVVA_SUFFIX_MARK: dict[str, str] = {}
AVVA_EMPTY = set(',>189(){}|_"<')  # glyphs with no outline in the font
AVVA_UNVERIFIED = {'U', '+'}

# Athanasius layout.
ATH_BASE = _with_upper({**_LOWER, 'f': 'ϥ', 'g': 'ⲅ', 'h': 'ⲏ', 'j': 'ϫ', 'q': 'ⲑ', 'u': 'ⲩ', 'v': 'ⲫ'})
ATH_BASE.update({
    '[': 'ⲝ', '{': 'Ⲝ', '\\': 'ϩ', '|': 'Ϩ', ']': 'ϣ', '}': 'Ϣ', "'": 'ϧ', '"': 'Ϧ',
    ';': 'ϯ', ':': 'Ϯ', ',': 'ⲋ', '<': 'Ⲋ', '_': 'ⲟ' + OVERLINE + 'ⲥ' + OVERLINE,
    '>': ':', '^': ';', '%': ',', '&': '?',
    '!': '✠', '#': '✣', '$': '✝', '@': '✠',
    '.': '.', '-': '-', '(': '(', ')': ')', '*': '*', ' ': ' ',
    **{d: d for d in '0123456789'},
})
ATH_PREFIX_MARK = {'`': GRAVE, '~': GRAVE}
ATH_SUFFIX_MARK = {'/': OVERLINE, '?': OVERLINE}
ATH_EMPTY: set[str] = set()
ATH_UNVERIFIED = {'=', '+'}

FONTS = {
    'avva': (AVVA_BASE, AVVA_PREFIX_MARK, AVVA_SUFFIX_MARK, AVVA_EMPTY, AVVA_UNVERIFIED),
    'athanasius': (ATH_BASE, ATH_PREFIX_MARK, ATH_SUFFIX_MARK, ATH_EMPTY, ATH_UNVERIFIED),
}

_ATH_SIGNS = re.compile(r"[\[\]\\{}|]|'[a-z]|[a-z]>|[a-z][/?](?=[a-z]|\W|$)")
_AVVA_SIGNS = re.compile(r"[a-zA-Z`][02345@#$%&)7]|[02345@#$%&)7][a-zA-Z`]")


def detect_font(text: str, default: str = 'athanasius') -> str:
    """Pick the legacy font of one Coptic string from encoding-specific signs."""
    ath = len(_ATH_SIGNS.findall(text))
    avva = len(_AVVA_SIGNS.findall(text))
    if avva > ath:
        return 'avva'
    if ath > avva:
        return 'athanasius'
    return default


@dataclass
class Converted:
    text: str
    font: str
    unmapped: list[str] = field(default_factory=list)
    dropped: int = 0


def convert(text: str, font: str) -> Converted:
    base, prefix, suffix, empty, unverified = FONTS[font]
    out: list[str] = []
    pending: list[str] = []
    unmapped: list[str] = []
    dropped = 0
    for ch in text:
        if ch in prefix:
            pending.append(prefix[ch])
            continue
        if ch in suffix:
            out.append(suffix[ch])
            continue
        if ch in empty:
            dropped += 1
            continue
        if ch in unverified or (ch not in base and ord(ch) < 0x80 and not ch.isspace()):
            unmapped.append(ch)
            out.append(ch)
        else:
            out.append(base.get(ch, ch))
        if pending and not ch.isspace():
            out.append(''.join(pending))
            pending = []
    if pending:
        out.append(''.join(pending))
    return Converted(unicodedata.normalize('NFC', ''.join(out)), font, unmapped, dropped)


# Function words only; short words that are also Coptic (a, o, on, pe, te, ne, nem …) are excluded.
_EN = set('the and of to is that for with his this are which your you who our all from have was they '
          'them unto shall will lord god him her thee thy thou priest deacon people we us by it be'.split())
_FR = set('le la les des et du une est pour dans que qui nous notre vous votre sur pas aux cette par '
          'seigneur prêtre diacre peuple'.split())
_LATIN_WORD = re.compile(r"[A-Za-zÀ-ÿ]+")
_LEGACY_SIGNS = re.compile(r"[`~\[\]\\{}|]|=[A-Za-z0-9]|(^|[\s‘])'[A-Za-z]|[a-z]>|[a-z];[a-z]")


def latin_language(text: str) -> str:
    """Classify a Latin-script cell: 'cop-legacy', 'en' or 'fr'."""
    if _LEGACY_SIGNS.search(text) or _AVVA_SIGNS.search(text):
        return 'cop-legacy'
    words = [w.lower() for w in _LATIN_WORD.findall(text)]
    if not words:
        return 'cop-legacy'
    en = sum(w in _EN for w in words)
    fr = sum(w in _FR for w in words) + len(re.findall(r'[éèêàçùâîôû]', text))
    if max(en, fr) == 0:
        return 'cop-legacy'
    return 'fr' if fr > en else 'en'
