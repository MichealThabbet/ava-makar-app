# DECISIONS — Ava-Makar

Full wording and reasons: `docs/plan/P0_ADDENDUM.md` §1.

| ID | Decision | Date | By |
|---|---|---|---|
| DEC-P0-01 | Merge Orsozoxi's functions into Ava-Makar with a simpler, more refined experience | 2026-10-29 | Owner |
| DEC-P0-02 | UI languages: Arabic (RTL, primary), English, German, French, Russian | 2026-10-29 | Owner |
| DEC-P0-03 | Text display: Arabic / Arabized Coptic / Coptic; optional English / Latin-transliterated Coptic / Coptic | 2026-10-29 | Owner |
| DEC-P0-04 | Tour Guide module («مرشدك») | 2026-10-29 | Owner |
| DEC-P0-05 | Online store inside the app | 2026-10-29 | Owner |
| DEC-P0-06 | Bohairic Coptic; Old Bohairic pronunciation of St. Macarius Monastery; liturgical Greek tagged separately | 2026-10-29 | Owner |
| DEC-P0-07 | Owner is the monastery's delegated approver (`approved-by-monastery`) | 2026-10-29 | Owner |
| DEC-P0-08 | Text source: the owner's files (texts currently approved in the Church); Katameros by the owner with Fr. Ignatius of Anba Bishoy | 2026-10-29 | Owner |
| DEC-P0-10 | English Bible: KJV (public domain outside the UK; verify the UK Crown rights before UK store release). The NKJV found in the package is not used | 2026-10-29 | Owner |
| DEC-P0-11 | Latin UI font: Arimo (Apache 2.0), metric-compatible with Arial. `arial.ttf` from the package is not shipped (Microsoft license). Coptic fonts in the package (Avva Shenouda, Athanasius, Abraam): license to be verified before use | 2026-10-29 | Owner |
| DEC-P0-12 | Coptic font: Noto Sans Coptic (OFL, Unicode) for the first release; request written permission for CS Ava Veni (© 2023 Ashraf Joseph, Beshoy Magdy) to make it the primary font if granted. Legacy (non-Unicode) Coptic fonts are not shipped; Coptic text in the package is converted to Unicode with a fixed, tested mapping | 2026-10-29 | Owner |
| DEC-P0-13 | Canonical source for Katameros, Synaxarium, Qisma, Taks, Kandil, Laqqan and Sagda: Katamaras 2.0.1 (owner's work with Fr. Ignatius of Anba Bishoy). Arabic Bible: tashkeel Van Dyck text from package 1 as primary, Katamaras 2.0.1 text as cross-check of verse numbering | 2026-10-29 | Claude (delegated) |
| DEC-P0-14 | Package «قطمارس ميشيل» declared by the owner as his own work with Fr. Ignatius of Anba Bishoy; Agpeya (`agypa.txt`), Holy Week Dallal and the commentary are approved for use. Provenance: owner's declaration; legal responsibility with the owner (AGENTS.md §1). The file-name overlap with Orsozoxi encrypted assets is recorded in INVENTORY.md | 2026-10-30 | Owner |
| DEC-P0-15 | `Archive.zip` (trilingual Arabic / Arabized Coptic / Coptic) is the owner's own work (about six months); canonical source for the Coptic and Arabized Coptic columns of the books it covers | 2026-10-30 | Owner |
| DEC-P0-09 | Arabized Coptic in two pronunciations, user-selectable: modern first, Old Bohairic when available | 2026-10-29 | Owner |

## Open architecture decisions
- ADR-001 Stack (app, backend, database, search, CMS, hosting): pending comparison. Initial recommendation: Flutter + API + PostgreSQL + on-device SQLite FTS5.
