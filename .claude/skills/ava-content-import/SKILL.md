---
name: ava-content-import
description: Import liturgical and Bible texts into Ava-Makar from the owner's Library repository and packages, with provenance, checksums, approval states, tashkeel and Coptic Unicode preserved. Use whenever any text (Bible, Katameros, Agpeya, Kholagy, Synaxarium, Psalmody, sayings, news) enters the project.
---

# Content import

## Sacred-text rules (AGENTS.md §2, non-negotiable)
- Never write, complete, paraphrase, translate or recite religious text from memory. Text enters only from source files.
- Each record carries:
  - `source_package`, `source_path`;
  - `edition` or `translator`, `language`;
  - `checksum` (sha256 of the normalised text), `imported_at`;
  - `status`: `imported` → `reviewed` → `approved-by-monastery`.
- Production shows only approved records.
- Keep exactly: tashkeel, punctuation, verse numbers, rubrics (red instructions), speaker roles, structure.
- Any edit is a new version with a diff.

## Sources
- `https://github.com/MichealThabbet/Library-` → `incoming/` (30 packages, all approved).
- **Clone sparsely:**
  ```bash
  GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --filter=blob:none --sparse https://github.com/MichealThabbet/Library- /home/user/michealthabbet/library-
  cd /home/user/michealthabbet/library- && git sparse-checkout set incoming/orsozxi/DECRYPTED_CONTENT/bible
  ```
  Do not run `ls-tree -l` on the whole repository: it fetches every blob and hangs.
- **Known structures:**
  - **Bible:** `orsozxi/DECRYPTED_CONTENT/bible/Bible.sqlite`.
    - Table `bible`: `book_index` (0-based: Psalms = 20, NT = 46…72), `chapter_index`, `ayah_index`, `ayah_name` (diacritised text, starting with its own verse number), `ayah_name_normalized`.
  - **Synaxarium:** `orsozxi/DECRYPTED_CONTENT/documents/sanksar2/<m>/0<m> (<d>).txt`. First line = heading; numbered title lines; then paragraphs.
  - **Katameros readings table (Katamaras 2.0.1):** `readings/Weekdays-<m>.txt`, lines `[d/m][O19_ch:vv][N1_ch:vv]…*`.
    - O19 = Psalms; N1..N27 = Matthew..Revelation.
    - Column order: Vespers psalm, Vespers gospel, Matins psalm, Matins gospel, Pauline, Catholic, Acts, Liturgy psalm, Liturgy gospel.
    - Plus `Sundays`, `Soam` (Lent), `50days` and `HolyWeek` tables.
  - **St Macarius sayings:** `defnar/bostan_al_rohban/sections/*/content.json`, field `secd` (diacritised).
  - **Fr Matta:** `som.db`, table `aqwal` (100 sayings), `all_w3zat` (186 sermons), `video` (100).
  - **Working example:** `tools/prototype/build_data.py` resolves a day's readings end to end.
- Full inventory of the earlier packages: `docs/content/INVENTORY.md`. Write the Library inventory to `docs/content/LIBRARY_INVENTORY.md`: per package — books, format, encoding, languages, counts, overlaps; then choose one canonical source per book.

## Built and tested (2026-11-06)
- **Pipeline:** `tools/import/` (usage in its README).
- **Build:** `python3 -m ava_import.build --library <lib>/incoming --out build/content --check`.
- **Tests:** `AVA_LIBRARY=<lib>/incoming python3 -m pytest -q` → 34 passing.
- **Inventory and canonical sources:** `docs/content/LIBRARY_INVENTORY.md`.
- **Legacy Coptic fonts:** `docs/content/COPTIC_LEGACY_FONTS.md`.
- **Traps already handled:**
  - Coptic is ASCII for the Avva Shenouda or Athanasius fonts. Detect the font per cell.
  - Katameros book codes ≠ Bible.sqlite indices. Use `books.BOOK_CODES`.
  - Katameros psalms use Coptic (LXX) numbering. Take the text from `*Psalms.txt`.
  - Bible.sqlite row index ≠ verse number. Use the printed number.
  - CSV columns:
    - Kholagy and annual Psalmody: ar=3, cop-ar=4, cop=5.
    - Kiahk Psalmody: ar=4, cop-ar=5, cop=6.
- **Changing a text or an importer on purpose:** rebuild with `--write-manifest` and commit the manifest with the reason.

## Pipeline (`tools/import/`)
1. **Detect encoding:** Windows-1256 → UTF-8; strip BOM; normalise Unicode NFC (do not strip tashkeel).
2. **Parse** each format: txt, xml, json, csv, xls via `xlrd`/`openpyxl`, htm via an HTML parser, sqlite.
3. **Legacy Coptic fonts** (Avva Shenouda, Athanasius…) → Unicode Coptic with a fixed, tested mapping table.
4. **Validate:**
   - verse counts per chapter against the Bible table;
   - non-empty segments;
   - no mojibake (regex for Ø/Ù sequences).
5. **Write** to the content database (PostgreSQL) and to per-book offline packs (SQLite FTS5 with Arabic normalisation for search: alef, ya, ta-marbuta, tashkeel-insensitive mode).
6. **Report:** counts per book, rejected rows with reasons; checksum manifest. The CI test fails on any mismatch.

## Never
- Decrypt protected files.
- Use credentials found in files (e.g. a `.env` inside an archive).
- Use decompiled code, DEX files or certificates.
