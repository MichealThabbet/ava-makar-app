# ADR-001 — Technology stack
Status: **Approved** (2026-11-01, DEC-P0-21). Decision owner: Eng. Mishel Thabet.
Goal set by the owner: a world-class, luxurious, innovative app worthy of a monastery of global archaeological value; features no other Coptic app has.
Exact library versions are fixed at the start of P1 from official documentation (AGENTS.md §5); none are stated here from memory.

## Drivers
1. Visual quality: custom, calm, luxurious UI identical on Android, iOS and web; smooth motion.
2. Complex text: Arabic with full tashkeel, Unicode Coptic with combining marks, RTL/LTR mixed, three parallel columns.
3. Offline-first reading for the whole library.
4. One calendar engine as the single source of truth for app and server (retreat blocking in fasts, notifications).
5. Transactional bookings and store; payments through a certified gateway.
6. Content workflow: import → review → owner approval → publish, with versions and audit.
7. Special features: «مرشدك» (location, 2.5D/3D, later AR), «رفيق القداس» (live sync), home-screen widgets.
8. Small team, long life: boring, maintainable technology.

## 1. App (Android, iOS, web)
| Option | Strengths | Weaknesses |
|---|---|---|
| **Flutter** | Own rendering engine → pixel-identical luxury design on every platform; strong RTL and custom typography; one codebase for mobile + web; proven for this domain (Kaneesty is Flutter) | 3D/AR ecosystem less mature than native; widgets and live activities need small native modules |
| React Native | Large ecosystem; native UI components | Look differs per platform; complex-script rendering and custom motion need more native work for this level of finish |
| Native (Swift + Kotlin) + separate web | Best per-platform depth (ARKit/ARCore, widgets) | Two or three codebases: 2–3× cost and slower delivery |

**Recommendation: Flutter**, with small native modules only where the platform requires it (home-screen widgets, iOS Live Activity / Android live notification for «رفيق القداس», AR in «مرشدك» V3).

## 2. «مرشدك» 3D
| Option | Note |
|---|---|
| 3D inside Flutter (glTF renderer) | One codebase; maturity to be proven by a prototype |
| Unity embedded as a module | Most capable 3D; adds a second engine and app size |
| 2.5D illustrated map (V1) | Lightest, fully Flutter, ships first |

**Recommendation:** V1 2.5D in Flutter (P4). The 3D engine for V2 is decided by a measured prototype on mid-range phones (ADR-002), not now.

## 3. Calendar engine
Written once in **Dart** as a standalone package with golden tests. CI exports the computed calendar (2000–2100) as versioned data tables that the server reads. **One engine, no second implementation to drift.**

## 4. Backend, database, admin
| Option | Strengths | Weaknesses |
|---|---|---|
| **PostgreSQL + Directus (admin/CMS) + small TypeScript service (NestJS)** | Directus gives roles, revisions, audit and an admin UI on our own Postgres schema; the service holds only critical logic (retreat state machine, store, payments, live liturgy) | Two server components to run |
| Supabase (managed Postgres, auth, storage, realtime) + custom admin | Fast start, realtime built in | Admin/approval workflow still to be built; vendor coupling |
| Django (Python) all-in-one | Mature admin, one framework | Admin look and workflow need heavy customisation for content approval |

**Recommendation:** **PostgreSQL** as the single source of data; **Directus** for content, approvals and admin; **NestJS** service for bookings (transactions, idempotency, no double booking), store, payment webhooks and the WebSocket channel of «رفيق القداس».

## 5. Offline content and search
- Content is compiled in CI from approved sources into **signed, versioned SQLite packs with FTS5**, checksum per text (AGENTS.md §2); delivered through a CDN as delta updates without app releases.
- Search on device: FTS5 with an Arabic normalisation layer (tashkeel/hamza-insensitive and exact modes) and Coptic normalisation. Web uses PostgreSQL full-text search with the same rules.

## 6. Delivery and operations
- GitHub Actions CI (tests, golden calendar tests, content checksums); iOS builds on a macOS runner; store uploads automated (Fastlane or Codemagic, chosen in P1).
- Hosting: managed PostgreSQL + containers, region close to Egypt/Europe; chosen with costs in P1.
- Crash reporting and opt-in, privacy-respecting analytics; no tracking of worship behaviour.

## 7. What makes it world-class (technical side)
- Motion and micro-interactions designed in Rive, restrained and reverent.
- Parallel reader with shared `segment_id` across Arabic / Arabized / Coptic / English, two Arabized pronunciations.
- «رفيق القداس»: live text sync over WebSocket + lock-screen live activity.
- Home-screen widgets: today's Katameros, commemoration, «قول اليوم» from Bostan Al Rohban.
- «مرشدك»: on-device location, geofences, beacons, offline tour packs.
- Full accessibility: screen readers, dynamic type, high contrast, five UI languages.

## Consequences
- Team skills needed: Dart/Flutter, TypeScript, PostgreSQL.
- ADR-002 (3D engine) and the hosting choice follow in P1–P4 with measurements.
