# GOAL — Ava-Makar

Plan: `docs/plan/MASTER_PLAN.md`. Decisions: `DECISIONS.md` and `docs/plan/P0_ADDENDUM.md`. Rules: `AGENTS.md`.

## Current phase: P0 — Discovery and plan

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Master plan | Approved by owner 2026-10-29 | `docs/plan/MASTER_PLAN.md` |
| 2 | P0 addendum (Orsozoxi merge, languages, Tour Guide, store, ideas) | Approved by owner 2026-10-29 | `docs/plan/P0_ADDENDUM.md` |
| 3 | Inventory of the owner's content package | Done 2026-10-29 | `docs/content/INVENTORY.md` |
| 4 | Stack comparison (ADR-001) | Approved 2026-11-01 | `docs/adr/ADR-001-stack.md` |
| 5 | Visual identity | Redesign built 2026-11-03 (DEC-P0-27): home, library, book detail, reader, tour; hero photo and official emblem pending from the monastery | `docs/design/DESIGN_SYSTEM.md`, `app/lib/design/` |
| 6 | Payment gateway research | Moved to P6 (needed only for the store) | — |
| 7 | Web design preview (home, parallel reader, «مرشدك»; parchment and candle modes) | Built; `flutter analyze` clean, 1 widget test passing, web build OK, screenshots checked | `app/`, `.github/workflows/web-preview.yml` |

## P1 — Foundation (started 2026-11-02)
| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Calendar engine: Gregorian / Julian / Coptic conversions via JDN | Done; checked against `DateTime` for every day 1900–2100, Coptic round-trip 1600–1900 AM, Nayrouz 1901–2099 | `packages/coptic_calendar` |
| 2 | Easter, four independent methods (A Meeus, B Gauss, C Tøndering, D traditional epact) | Done; A/B agree 1–4000, C and D agree 1584–4099; matches Eastern Easter table 2020–2070 (51 years) | same |
| 3 | Movable days (15) as data | Done; all match the 2016–2030 agenda | same |
| 4 | Cross-checks: agenda 2016–2030, Easter 2020–2070, kiahk vectors | 444/446 agenda pairs (2 agenda typos); all Easter and feast dates match | `test/fixtures/README.md` |
| 5 | Traditional epacts (الأبقطي): solar/lunar cycles and epacts | Done; 60/60 years match the owner's research table 1997–2056 | `lib/src/epact.dart` |
| 5b | Easter from the epacts (method D, Bahman ch. 15–16) + book example AM 1705 + Apostles' fast rule | Done; equals A–C for 1584–4099; Apostles' fast rule = engine 1901–2099 | `lib/src/epact.dart` |
| 5c | Published church tables | Midlands diocese 2022–2027: 31/36 (5 diocese errata). Southern US deacons calendar 2020–2100: 2,310/2,343, the 33 others explained calendar errata (year-1800 shift, 2100 century rule, 2 typos) | `test/fixtures/` |
| 6 | Fixed feasts as data (16) with the Nativity 28/29 Koiak rule | Done; Nativity = 7 Jan for 1901–2099; matches agenda and vectors | `lib/src/fixed.dart` |
| 6b | Fasts: Nativity, paramoun (1/2/3-day rule), Nineveh, Great Lent, Apostles, Virgin, Wednesday/Friday with Holy Fifty and Nativity/Epiphany exceptions | Done per the official rites page; lengths checked 1990–2100 | `lib/src/fasts.dart` |
| 6d | Liturgical day from sunset (DEC-P0-24) | Done in the engine; sunset value from the device in the app | `lib/src/liturgical_day.dart` |
| 6e | Liturgical periods (tune, hours, alleluia) from the official rites page: 42 sections, precedence rules (DEC-P0-25) | Done; every day 1901–2099 resolves, all 42 sections occur, Lent/Fifty/Holy Week/Annunciation checked 1990–2100 | `lib/src/rites.dart`, 36 tests passing |
| 6c | Annunciation not celebrated on Palm Sunday / Holy Week (DEC-P0-23) | Done; −9 and Easter Day celebrated (owner) | `lib/src/fixed.dart` |
| 7 | Content import pipeline (provenance, checksums, approval states) | Done 2026-11-06 (stage A slice 1): Library inventory of 30 packages; 10 books imported (106,145 segments: Bible 35,784 verses, Katameros table 4,626 readings + 538 psalm verses, Holy Week readings and service book, Synaxarium, Agpeya, rites, Kholagy, annual and Kiahk Psalmody) + 39,464 cross references; legacy Coptic → Unicode (11,436 segments) verified; 17 source errata reported; 34 tests passing (29 unit + 5 integration incl. manifest check) | `docs/content/LIBRARY_INVENTORY.md`, `docs/content/IMPORT_REPORT.md`, `docs/content/COPTIC_LEGACY_FONTS.md`, `tools/import/`, `data/content/manifest.json`, `.github/workflows/content-import.yml` |
| 7b | Next imports: Katameros full texts, services, deacon/people responses, English texts after edition check, commentary, hymn audio | Pending | `LIBRARY_INVENTORY.md` §4 |

## Assumptions
- The owner is the monastery's delegated approver (DEC-P0-07).
- No durations are set until the stack is decided.

## Blockers
- None for content (Difnar found in package 12).

## Next step
Stage B: PostgreSQL schema + migrations + seed from `content.db` (content, calendar rules, monastery, retreat house, users/roles, audit log, store tables), with tests. Owner to review the 17 Katameros errata in `docs/content/IMPORT_REPORT.md`. Home page visual design is with the owner (branch `codex/home-design`).
