# tools/import — content import pipeline

Turns the owner's Library (`MichealThabbet/Library-/incoming`) into one content database and per-book offline packs, with provenance, checksums and approval status on every record. Python 3.11+ standard library only (tests: `pytest`).

```bash
# 1. Library, only the folders the importers read (≈60 MB)
git clone --depth 1 --filter=blob:none --sparse https://github.com/MichealThabbet/Library- /home/user/library
cd /home/user/library && git sparse-checkout set --no-cone \
  'incoming/orsozxi/DECRYPTED_CONTENT/bible/' 'incoming/orsozxi/DECRYPTED_CONTENT/documents/' \
  'incoming/orsozxi/DECRYPTED_CONTENT/spreadsheets/' 'incoming/katamars2/katamaras-2-0-1/assets/readings/'

# 2. Build (content.db + packs/*.sqlite) and verify against the committed manifest
cd tools/import
python3 -m ava_import.build --library /home/user/library/incoming --out ../../build/content \
  --manifest ../../data/content/manifest.json --check --report ../../docs/content/IMPORT_REPORT.md

# 3. Tests (unit tests always; integration tests when AVA_LIBRARY is set)
AVA_LIBRARY=/home/user/library/incoming python3 -m pytest -q
```

After an intended change (new source file, importer fix), rebuild with `--write-manifest` instead of `--check`. Then commit the manifest together with the reason. A changed text never passes silently.

| Module | Role |
|---|---|
| `ava_import/text.py` | encoding (UTF-8 → Windows-1256), NFC, checksums, search normaliser, mojibake check |
| `ava_import/coptic_legacy.py` | Avva Shenouda / Athanasius → Unicode Coptic (`docs/content/COPTIC_LEGACY_FONTS.md`) |
| `ava_import/markup.py` | the `+` / `+++` / `**` / `&` text markup |
| `ava_import/books.py` | one importer per book + Katameros table + Bible book-code map |
| `ava_import/store.py` | SQLite content DB (same shape as the PostgreSQL schema of stage B), FTS5 packs |
| `ava_import/build.py` | orchestration, manifest, `IMPORT_REPORT.md` |

Output schema:
- `source`, `source_file`: sha256 of every file read.
- `work`.
- `unit`: status `imported` → `reviewed` → `approved-by-monastery`, version, checksum.
- `segment`: kind, lang, role, text, raw, checksum.
- `reading`: Katameros table with named slots.
- `crossref`, `structure`: Kholagy/Psalmody order tables.
- `issue`.

Packs:
- One SQLite file per work, with an FTS5 `search` table over normalised text (tashkeel-insensitive Arabic, mark-free Coptic).
- The displayed text is always the stored original.
