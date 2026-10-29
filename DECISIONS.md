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
| DEC-P0-09 | Arabized Coptic in two pronunciations, user-selectable: modern first, Old Bohairic when available | 2026-10-29 | Owner |

## Open architecture decisions
- ADR-001 Stack (app, backend, database, search, CMS, hosting): pending comparison. Initial recommendation: Flutter + API + PostgreSQL + on-device SQLite FTS5.
