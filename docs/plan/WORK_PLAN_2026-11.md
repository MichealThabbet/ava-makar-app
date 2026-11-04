# Work plan — programming, sections, content, database (from 2026-11-04)

Owner's order: while the visual design moves to Cowork, build the programming, all sections, the content, the monastery tour (placeholder images), the retreat house with bookings, and the complete database for the site and apps.
Sources: `MichealThabbet/Library-` → `incoming/` (30 packages; main one `incoming/orsozxi`). Approved by the owner in full (DEC-P0-17, DEC-P0-28, DEC-P0-30). Limits that stay: no decryption of protected content, no use of credentials found in files, decompiled code / DEX / certificates not used.

## Stack (ADR-001, approved)
Flutter app (web, Android, iOS) · Dart calendar engine (done, 36 tests) · PostgreSQL · Directus (CMS / admin) · NestJS service (bookings, store, payments, notifications) · signed offline content packs (SQLite FTS5).

## Phase A — Content inventory and import pipeline (first; everything depends on it)
1. Inventory every package in `incoming/`: content type, books covered, format, encoding, languages, overlaps; pick one canonical source per book and record the others as cross-checks (`docs/content/LIBRARY_INVENTORY.md`).
2. Import pipeline (`tools/import/`): parsers per format (txt, xml, json, csv, xls, htm, sqlite), Windows-1256 → UTF-8, legacy Coptic fonts → Unicode, tashkeel kept, verse numbering kept.
3. Every record carries provenance: source package and path, edition, language, checksum, import date, approval state (`imported` → `reviewed` → `approved-by-monastery`).
4. Output: one normalised content database + per-book offline packs; checksum test fails the build on any change.
Exit: every book in section 02 has a canonical source loaded, counts reported, round-trip tests green.

## Phase B — Database (site + apps)
Schema in PostgreSQL (migrations, seed, tests):
- Content: books, sections, segments (ar / cp / co / en columns), Bible (books, chapters, verses), readings table (day → references), Synaxarium, sayings, provenance, versions, approvals.
- Calendar: rules for fixed feasts and fasts as data (engine reads them).
- Monastery: news, guidance notices, publications, products, fathers and saints, tour stations, media.
- Retreat house: houses, rooms / beds, rules, availability, booking requests, approval flow, status history.
- Users and roles: visitor, member, editor, reviewer, approver, booking manager, store manager, admin; audit log.
- Store (P6 later): products, variants, stock, orders — schema ready, payments not connected.
Exit: migrations run on a clean database, seed loads, constraint and concurrency tests green.

## Phase C — Sections in the app (all of them)
1. Home (owner's order, design from Cowork).
2. Prayers and readings: today's readings (engine + readings table), Coptic calendar (day / month, feasts, fasts, periods), Katameros, Agpeya, Kholagy, Synaxarium, Bible (search with and without tashkeel, references), Psalmody (annual / Kiahk chosen by the engine), Holy Week, other rites. Unified reader: ar / cp / co columns, font size, night mode, saved position, offline.
3. Monastery tour «مرشدك»: all stations from the blueprint (churches, fortress, arch, Myron dome, cells, refectory, museum, fathers), each with a page, map position, route; **placeholder images** clearly marked «صورة مؤقتة» until the monastery's photos arrive; GPS / QR hooks.
4. Library and heritage: monastery library, manuscripts, writings about the monastery, publications, Morcos magazine, fathers' works, digital library (from the Library catalogue already in the repo).
5. Services: retreat house, prayer requests, donations information, visits, products.
6. Cross-cutting: unified search, account, notifications (quiet by default), five UI languages (strings), report-an-error.
Exit per section: real data shown, widget tests, offline check, RTL check at 360 / 390 / 430.

## Phase D — Retreat house and bookings (NestJS + Directus)
Request form → availability calendar → submit → status tracking; admin approval, rooms / beds assignment by the monastery (not chosen by the visitor), cancellation and change, notifications. No double booking under concurrent requests (transaction + unique constraint + test with parallel requests); idempotent submissions; minimum personal data; youth-safe.
Exit: end-to-end test (request → approve → confirm → cancel), concurrency test, admin screens.

## Phase E — CMS and admin
Directus over the same database: roles, editorial workflow (draft → review → approval), news, notices, publications, tour stations, retreat house management, audit log.

## Order and evidence
A → B → C (readings first, then the rest) and D in parallel with C → E. Each slice: commit on `codex/p0-plan`, tests run, evidence in `GOAL.md`.

## Needs from the owner (only these)
1. Hosting for the backend and database (account and payment) — needed only to publish bookings and admin online; everything is built and tested locally until then.
2. The monastery's rules for the retreat house (who can book, ages, durations, capacity, documents).
3. Real photos for the tour stations (placeholders until then).
