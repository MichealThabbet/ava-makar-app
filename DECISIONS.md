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
| DEC-P0-16 | Existing app `com.stmacarius.khelwa` is reference only (rarely used). Ava-Makar builds its own retreat-house system, no integration with its backend | 2026-10-30 | Owner |
| DEC-P0-17 | Kaneesty content approved for use, with each text attributed to its stated source. Standing rule: every file the owner sends is approved by the owner for use; provenance = owner's declaration plus the source named in the file. Limits that stay: no decryption of protected content, no use of credentials/secrets found in files | 2026-10-30 | Owner |
| DEC-P0-18 | Rites and services (sacraments, funerals, consecrations and ordinations, papal, Laqqan, prostration, priest prayers) are shown to all users without restriction; they sit in 02.10 «كتب وخدمات طقسية أخرى» | 2026-10-30 | Owner |
| DEC-P0-19 | Orsozoxi library (`defnar/orsozox`) approved for use in full: the owner states the Orsozoxi developer agreed and provided the files. Attribution: Orsozoxi. Keep a written copy of the permission (store review and future disputes) | 2026-10-31 | Owner |
| DEC-P0-20 | Orsozoxi developer donated the content to the monastery (per owner). Store accounts (Google Play, Apple) will be opened in the monastery's name with a dedicated Google e-mail | 2026-10-31 | Owner |
| DEC-P0-21 | ADR-001 stack approved. Design direction «Old Coptic Luxury»: monastic, archaeological, premium; see `docs/design/DESIGN_DIRECTION.md` | 2026-11-01 | Owner |
| DEC-P0-22 | Delivery order: web app first, published from GitHub (GitHub Pages, `gh-pages` branch) for the owner to view and test; the same Flutter code is then built for Android and iOS. Flutter pinned to stable 3.47.9 (installed 2026-11-01) | 2026-11-01 | Owner |
| DEC-P0-23 | Annunciation (29 Baramhat) is not celebrated and not moved when it falls on Palm Sunday or in Holy Week (Lazarus Saturday … Joyous Saturday, Easter −8 … −1). Open: Friday ending Lent (−9) and Easter Day (0), which the Southern US calendar also marks «not celebrated» | 2026-11-02 | Owner |
| DEC-P0-09 | Arabized Coptic in two pronunciations, user-selectable: modern first, Old Bohairic when available | 2026-10-29 | Owner |

## Open architecture decisions
- ADR-001 Stack: proposed in `docs/adr/ADR-001-stack.md` (Flutter; PostgreSQL + Directus + NestJS; Dart calendar engine; signed SQLite FTS5 packs). Approved 2026-11-01 (DEC-P0-21).
