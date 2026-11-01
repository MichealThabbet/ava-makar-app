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

## Assumptions
- The owner is the monastery's delegated approver (DEC-P0-07).
- No durations are set until the stack is decided.

## Blockers
- None for content (Difnar found in package 12).

## Next step
Owner reviews the web preview on GitHub Pages and chooses/refines the design; then P1 starts with the calendar engine.
