"""Records produced by the importers and written by the store."""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass
class Segment:
    kind: str                 # title | heading | rubric | text | verse | role | ref | item
    lang: str                 # ar | cop | cop-ar | en | fr | und
    text: str
    raw: str | None = None    # original legacy-encoded text when converted
    role: str | None = None   # speaker (priest, deacon, people …) as written in the source
    meta: dict[str, Any] = field(default_factory=dict)


@dataclass
class Unit:
    work: str
    key: str
    title: str
    source_path: str
    parent: str | None = None
    segments: list[Segment] = field(default_factory=list)
    meta: dict[str, Any] = field(default_factory=dict)


@dataclass
class Issue:
    work: str
    key: str
    severity: str             # error | warning | info
    message: str


@dataclass
class Work:
    id: str
    title_ar: str
    title_en: str
    kind: str                 # bible | liturgical | synaxarium | rite | table | reference
    source: str               # source id
