# GOAL — Ava-Makar

Plan: `docs/plan/MASTER_PLAN.md`. Decisions: `DECISIONS.md` and `docs/plan/P0_ADDENDUM.md`. Rules: `AGENTS.md`.

## Current phase: P0 — Discovery and plan

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Master plan | Approved by owner 2026-10-29 | `docs/plan/MASTER_PLAN.md` |
| 2 | P0 addendum (Orsozoxi merge, languages, Tour Guide, store, ideas) | Approved by owner 2026-10-29 | `docs/plan/P0_ADDENDUM.md` |
| 3 | Inventory of the owner's content package | Done 2026-10-29 | `docs/content/INVENTORY.md` |
| 4 | Stack comparison (ADR-001) | Approved 2026-11-01 | `docs/adr/ADR-001-stack.md` |
| 5 | Visual identity | Direction approved; concept screens pending | `docs/design/DESIGN_DIRECTION.md` |
| 6 | Payment gateway research | Moved to P6 (needed only for the store) | — |
| 7 | Web design preview (home, parallel reader, «مرشدك»; parchment and candle modes) | Built; `flutter analyze` clean, 1 widget test passing, web build OK, screenshots checked | `app/`, `.github/workflows/web-preview.yml` |

## P1 — Foundation (started 2026-11-02)
| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Calendar engine: Gregorian / Julian / Coptic conversions via JDN | Done; checked against `DateTime` for every day 1900–2100, Coptic round-trip 1600–1900 AM, Nayrouz 1901–2099 | `packages/coptic_calendar`, 17 tests passing |
| 2 | Easter, three independent methods | Done; A/B agree 1–4000, C agrees 1583–4099; matches Eastern Easter table 2020–2070 (51 years) | same |
| 3 | Movable days (15) as data | Done; all match the 2016–2030 agenda | same |
| 4 | Cross-checks: agenda 2016–2030, Easter 2020–2070, kiahk vectors | 444/446 agenda pairs (2 agenda typos); all Easter and feast dates match | `test/fixtures/README.md` |
| 5 | Traditional epact (الأبقطي) as third method; official golden tables (20+ years) | Pending: needs reference text and official tables | — |
| 6 | Fixed feasts as data (12) with the Nativity 28/29 Koiak rule | Done; Nativity = 7 Jan for 1901–2099; matches agenda and vectors | `lib/src/fixed.dart` |
| 6b | Fasts (Advent, Apostles' end, Virgin, Wednesdays/Fridays, fast-free periods); day-rollover rule | Next | — |
| 7 | Content import pipeline (provenance, checksums, approval states) | Pending | — |

## Assumptions
- The owner is the monastery's delegated approver (DEC-P0-07).
- No durations are set until the stack is decided.

## Blockers
- None for content (Difnar found in package 12).

## Next step
P1: fixed feasts/fasts data, then the content import pipeline. Owner: enable GitHub Pages (gh-pages branch) to view the preview.
