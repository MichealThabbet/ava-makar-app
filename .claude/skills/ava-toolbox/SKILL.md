---
name: ava-toolbox
description: Find, install, pin and create the tools Ava-Makar needs — Flutter/Dart packages, web animation and 3D libraries, backend (NestJS, PostgreSQL, Directus), image/video/PDF tooling, testing, and new project skills. Use whenever a task would go better with a library, a tool or a reusable skill that is not set up yet.
---

# Toolbox: add what the work needs, on your own

The owner expects you to bring in the right tools yourself, not to wait to be told.

## Rules
- **Free and open source first;** check the licence (MIT, BSD, Apache, OFL fine; GPL only for tools that are not shipped; record anything else in DECISIONS).
- **Never a paid service, API key or hosting** without the owner's yes.
- **Pin exact versions;** prefer stable releases at least a few weeks old; verify current versions from the official registry or docs (Context7 MCP or the registry), not from memory.
- **Vendor web libraries** into the repo (no runtime CDN); keep a `NOTICE` with licence and version.
- **New dependency in existing working code** = a small decision row in DECISIONS (what, why, alternatives).
- **Make installs survive the session:** after a set-up works, offer it as the environment setup script (`get_environment` → `update_environment` with `setup_script`). The owner approves the prompt.
- **Package registries** (npm, PyPI, pub.dev, crates) are reachable. Another host needs `get_environment` then `update_environment`, approved by the owner.

## Shortlist by need (check versions before adding)
| Need | First choice | Notes |
|---|---|---|
| Web motion | GSAP + ScrollTrigger (vendored) | Already in `app/web/prototype/vendor/`; Flip, MotionPath, SplitText-like effects by hand |
| Web 3D / page curl / candle light | three.js | Page curl, light, particles; lazy-load; reduced-motion fallback |
| Smooth scroll | Lenis | Only if it does not hurt iOS |
| Vector animation | Lottie (lottie-web / `lottie` Flutter) or Rive | Only from the owner's art |
| Flutter state / routing | Riverpod, go_router | |
| Flutter local DB, offline | drift (SQLite) with FTS5 | Offline content packs |
| Flutter SVG / animations | flutter_svg, flutter_animate, rive | |
| Flutter PDF | `pdf` + `printing` | Retreat confirmation |
| Arabic text search | SQLite FTS5 + normaliser (alef, ya, ta-marbuta, tashkeel) | Write a tested normaliser |
| Backend | NestJS + Prisma or TypeORM + PostgreSQL; Directus for admin | Docker Compose for local |
| Server PDF | pdfkit (Node) or Playwright `page.pdf()` with an HTML template | Arabic shaping: use the HTML route |
| Encryption of attachments | Node `crypto` AES-256-GCM, envelope keys | Master key outside the database |
| E-mail | Nodemailer (SMTP) | Provider chosen with the owner |
| WhatsApp outbound | WhatsApp Business Cloud API | Needs the monastery's Meta account |
| Images | Pillow, NumPy (installed); `sharp` or `libvips` for batch; `cwebp` / `avifenc` | See `ava-asset-prep` |
| Video (from the owner's photos or art, never generated religious imagery) | ffmpeg (Ken Burns, crossfades, MP4/WebM loops for intros) | `apt-get install -y ffmpeg` if missing |
| Fonts | `fonttools` (pyftsubset) for Arabic subsets to WOFF2 | Smaller downloads |
| Excel / legacy files | openpyxl, xlrd, `chardet` / `charset-normalizer` | Windows-1256 |
| Manuscripts (Vatican) | IIIF viewer: OpenSeadragon or Mirador | After written permission and network access |
| Testing | Dart test, flutter_test, Jest or Vitest, Playwright (pre-installed: do not reinstall) | |
| Quality | Lighthouse (Chromium at `/opt/pw-browsers/chromium`), axe-core | Performance and accessibility |

## Creating a new skill
When a method works and will repeat (a component, an effect, an import format, a review step):
1. Write it to `.claude/skills/ava-<name>/SKILL.md`. The frontmatter has `name` and a precise `description` of when to use it.
2. In the body: steps, tested commands and code, checks.
3. Put any script in `tools/` and test it once.
4. Add a row for it in HANDOFF §15ب.
