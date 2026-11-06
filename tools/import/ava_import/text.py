"""Text reading, provenance checksums, search normalisation and integrity checks."""
from __future__ import annotations

import hashlib
import re
import unicodedata
from pathlib import Path

_BIDI = re.compile('[‎‏‪-‮⁦-⁩﻿]')
_TASHKEEL = re.compile('[ؐ-ًؚ-ٰٟۖ-ۭـ]')
_MOJIBAKE = re.compile(r'(Ã[\x80-\xbf]|Ø[\xa7-\xbf]|Ù[\x80-\xbf‘-›€]|ï»¿|�)')
_ARABIC = re.compile('[؀-ۿ]')
_COPTIC = re.compile('[Ⲁ-⳿Ϣ-ϯ]')


def read_text(path: Path) -> tuple[str, str]:
    """Return (text, encoding). UTF-8 (with or without BOM) first, then Windows-1256."""
    raw = path.read_bytes()
    for enc in ('utf-8-sig', 'cp1256'):
        try:
            text = raw.decode(enc)
            return unicodedata.normalize('NFC', text), enc
        except UnicodeDecodeError:
            continue
    raise ValueError(f'unknown encoding: {path}')


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def checksum(text: str) -> str:
    """Checksum of a stored text: sha256 of its NFC form (tashkeel kept)."""
    return sha256_bytes(unicodedata.normalize('NFC', text).encode('utf-8'))


def clean_controls(text: str) -> str:
    """Remove BOM and bidi control marks only; every visible character stays."""
    return _BIDI.sub('', text)


def normalise_search(text: str) -> str:
    """Search key: tashkeel-insensitive Arabic, mark-free Coptic, case-folded Latin.

    Never stored as the text itself; only used for the FTS index.
    """
    t = clean_controls(text)
    t = _TASHKEEL.sub('', t)
    t = (t.replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا').replace('ٱ', 'ا')
          .replace('ى', 'ي').replace('ة', 'ه').replace('ؤ', 'و').replace('ئ', 'ي'))
    t = unicodedata.normalize('NFD', t)
    t = ''.join(c for c in t if not unicodedata.combining(c))
    t = t.casefold()
    t = re.sub(r'[^\w\s]', ' ', t)
    return re.sub(r'\s+', ' ', t).strip()


def has_mojibake(text: str) -> bool:
    return bool(_MOJIBAKE.search(text))


def script_of(text: str) -> str:
    if _ARABIC.search(text):
        return 'arabic'
    if _COPTIC.search(text):
        return 'coptic'
    if re.search('[A-Za-z]', text):
        return 'latin'
    return 'other'
