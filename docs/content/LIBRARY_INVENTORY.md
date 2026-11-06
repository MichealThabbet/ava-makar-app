# Library inventory — `MichealThabbet/Library-` / `incoming/`

Stage A of the work plan. Surveyed 2026-11-06 from the repository tree (84,301 files) and from samples of every package; the texts marked **Imported** were parsed completely by `tools/import` (see `IMPORT_REPORT.md`).
All packages are approved by the owner (DEC-P0-17, 28, 30, 34). Decompiled code, DEX files, certificates (`orsozxi/DECRYPTED_CONTENT/certificates`) and any credentials are **not used**.

Legend for Status:
- **Imported**: in the content DB now.
- **Candidate**: usable text, to be imported in a later slice.
- **Cross-check**: a second source used to verify an imported book.
- **Reference**: ideas or code only.
- **Empty**: archive not extracted, or nothing uploaded.

## 1. Packages

| # | Package | What it holds (texts) | Format / encoding | Languages | Files | Status |
|---|---|---|---|---|---:|---|
| 1 | `orsozxi` | **Main source.** `DECRYPTED_CONTENT`: Bible (73 books, diacritised), Agpeya, Synaxarium (`sanksar2`), Katameros texts (`katamars`: Sundays, weekdays, Lent with commentary, Fifty days, Jonah), Holy-week service book (`dallal`), rites (`kism`, `kandil`, `lakan`, `sagda`, `taks`), Kholagy, annual and Kiahk Psalmody, Bible cross references (`shawahed`), daily verses (`random`); plus Ipsaltos 8.1 files merged in | SQLite, UTF-8 txt/csv (BOM in csv) | ar, cop (legacy fonts), cop-ar, en, fr (+ nl in a few cells) | 26,063 | **Imported** (all except `documents/katamars`, `random`, `mybible`) |
| 2 | `katamars2` | **Katamaras 2.0.1** (the owner's work with Fr Ighnatios El-Anba Bishoy): reading tables `readings/Weekdays-1..13`, `Sundays`, `Soam`, `50days` with their psalm texts, Holy Week readings per hour, Synaxarium (`sneksar`), Kandil, Kisma, Lakkan/Sagda, Taks, partial Bible (`Bible/O*`, `N*`) | UTF-8 txt | ar, cop-ar | 1,949 | **Imported**: tables, psalms, Holy Week. Cross-check: the rest |
| 3 | `katamars` | Psalmody from Orsozoxi plus Katameros 10.0.1: 213 original XLS + `all.xml` | BIFF `.xls` (binary) | ar, cop | 220 | Cross-check (same Psalmody as orsozxi `absalmody`) |
| 4 | `katamars3` | Owner's Katamaras APK, split zip (`.part1/.part2`), not extracted | zip | — | 4 | Empty (extract on request) |
| 5 | `Ipsaltos_8.1` | Psalmody/hymns app: 461 htm, 224 txt, 150 mp3 hymn recordings, tables | htm (Excel export, Windows-1256), UTF-8 txt | ar, cop-ar, cop | 2,333 | Candidate (text already merged into orsozxi; **mp3 = hymn audio**, idea 3) |
| 6 | `khoras` | Deacons' book family: deacon rite, responses (`files1..5`: 3,500 txt + 1,650 htm) | UTF-8 txt/htm | ar, cop-ar, cop | 7,233 | Candidate (deacon responses) |
| 7 | `shehood` | Martyrs / Synaxarium by day (`01tout01_sen.htm` …), txt, csv | htm (Excel export, Windows-1256), txt, csv | ar | 1,570 | Cross-check for the Synaxarium |
| 8 | `soteria` | Same app family as `khoras`/Ipsaltos: liturgy htm with Coptic/Arabized/Arabic columns, 57 csv | UTF-8 htm, csv | ar, cop-ar, cop | 1,969 | Candidate |
| 9 | `mordat` | Responses of the people (مردات), tasbeha tables, 67 mp3 | UTF-8 txt/csv, mp3 | ar, cop-ar | 892 | Candidate (+ audio) |
| 10 | `catena` | Catena commentary app: 3,972 JSON chapters, NKJV/RSV bible zips | JSON | en, ar | 10,594 | Candidate for commentary (Bible module A). NKJV not used (DEC-P0-10) |
| 11 | `agiosbible` | Agios Bible: 240 txt in `assets/public` | UTF-8 txt | en | 1,794 | Candidate (English Bible; check edition = KJV, DEC-P0-10) |
| 12 | `copticprayer` | Coptic Prayers Swedish, extracted to CSV: Bible, Agpeya, Holy Week, Kholagy, Katameros | UTF-8 csv + index json | ar, sv, cop | 28 | Cross-check (Arabic) |
| 13 | `copticprayer2` | Same app as APK splits | apk / data | — | 2,500 | Reference |
| 14 | `hollyweak` | Holy Week (دلال) app extracted to CSV: prayers, texts, days, books, links | UTF-8 csv | ar (+ Coptic flags) | 11 | Cross-check for `pascha-dallal` |
| 15 | `fathermatta` | Fr Matta Meskin app resources (xml, ogg) | Android res | ar | 2,495 | Reference (sayings already from `som.db`, earlier package) |
| 16 | `digitalchurch` | Church Digital app resources | Android res | ar | 2,231 | Reference |
| 17 | `Ekklesia_8.9.45` | Ekklesia app: 2021 calendar htm, about pages, images | UTF-8 htm | ar | 932 | Reference |
| 18 | `ivalley` | Flutter app assets (fonts, animations) | json | — | 375 | Reference |
| 19 | `popeshenouda` | Pope Shenouda app shell (manifest, DEX) | binary | — | 35 | Reference (no text) |
| 20 | `salawatelkhedma` | Services: crowning, engagement, marriage, second marriage, myron, sick, water, home, baptism bath (`hamem`) | UTF-8 txt | ar | 79 | Candidate (rites module I) |
| 21 | `copticlab` | Coptic Library APK splits | apk | — | 48 | Reference |
| 22 | `orthodox-presenter-master` | Presenter JSON: Book of Hours (53 + 81 psalms), hymns, prayers, Pascha readings | UTF-8 JSON | en | 398 | Candidate (English texts, check edition) |
| 23 | `Coptic-Liturgy-App-main` | Flutter app with 21 JSON slide files | JSON | ar, cop-ar | 212 | Reference (UI ideas) |
| 24 | `katameros-api-master` | C# Katameros API with feast factories and a `.db` | C#, SQLite | en, ar | 126 | Cross-check (feast rules vs the calendar engine) |
| 25 | `coptic-orthodox-ministry-main` | Agent skill files (Markdown) for lessons and iconography | md | en | 229 | Reference only (not liturgical text) |
| 26 | `copticEaster-master` | Python Coptic Easter algorithm | py | — | 7 | Cross-check (engine already verified 4 ways) |
| 27 | `derasat` | `bible1part1-3.zip` (study Bible), not extracted | zip | — | 4 | Empty (extract on request) |
| 28 | `Tafseer_bible` | Only an empty `readme`; report says split archive was extracted, but no files are in the tree | — | — | 1 | Empty |
| 29 | `ishlil` | Only an empty `readme` | — | — | 1 | Empty |
| 30 | `kanestyprayer` | Only an empty `readme` | — | — | 1 | Empty |

## 2. Canonical source per book

| Book (work id) | Canonical source | Why | Cross-check source |
|---|---|---|---|
| Bible, Arabic (`bible-ar`) | `orsozxi/DECRYPTED_CONTENT/bible/Bible.sqlite` | Full 73 books, diacritised, the text the prototype already uses | `katamars2/assets/Bible`, `copticprayer/Bible` |
| Katameros reading table (`reading`) | `katamars2` `readings/*.txt` | Owner's own work (DEC-P0-13/14) | `orsozxi/documents/katamars`, `katameros-api` |
| Katameros psalm verses (`katameros-psalms`) | `katamars2` `readings/*Psalms.txt` | Psalm references use the Coptic (LXX) numbering, which the Arabic Bible does not, so the psalm text must come with the table | — |
| Holy Week readings (`pascha-readings`) | `katamars2` `readings/HolyWeek` | Owner's work, every hour with its readings | `hollyweak`, `copticprayer/Dlal` |
| Holy Week service book (`pascha-dallal`) | `orsozxi/documents/dallal` | Full service with Coptic | `hollyweak` |
| Synaxarium (`synaxarium-ar`) | `orsozxi/documents/sanksar2` | Every day + movable feasts | `katamars2/sneksar`, `shehood` |
| Agpeya (`agpeya-ar`) | `orsozxi/documents/agypa.txt` | Diacritised, full | `copticprayer/Agpeya`, `orthodox-presenter` (en) |
| Rites (`rites-ar`) | `orsozxi/documents/{kism,kandil,lakan,sagda,taks}.txt` | Same text as Katamaras folders | `katamars2/{Kisma,Kandil,Lakkan_Sagda,Taks}` |
| Kholagy (`kholagy`) | `orsozxi/spreadsheets/kholagy` | 4 languages in columns + order tables | `soteria`, `copticprayer/Kholagy` |
| Psalmody annual / Kiahk | `orsozxi/spreadsheets/psalmodySanawy`, `absalmody` | Columns + occasion tables (165 occasions) | `katamars/*.xls`, `Ipsaltos_8.1`, `mordat` |
| Bible cross references (`crossref`) | `orsozxi/spreadsheets/shawahed` | 39,464 word-level references | — |

## 3. Findings that change the work

1. **The Coptic in the Library is not Unicode.** It is ASCII typed for two legacy fonts, sometimes mixed in one file:
   - `dallal` uses **Avva Shenouda**.
   - Kholagy and Psalmody use **Athanasius**, with some cells in Avva.
   - The converter detects the font per cell. The mapping was read from the fonts themselves and verified visually and against the Arabized column (`COPTIC_LEGACY_FONTS.md`).
2. **The Katameros and the Bible order the Old Testament differently.**
   - Katamaras puts Tobit, Judith, Wisdom, Sirach and Baruch after Malachi; `Bible.sqlite` puts them in the middle.
   - Using the book code as an index would read prophecies from the wrong book.
   - Fixed with an explicit 73-book map, proved by matching chapter counts.
3. **Psalm numbers in the Katameros are Coptic (LXX), not the Arabic Bible's numbering.**
   - Example: `[101:11,14]` does not exist in `Bible.sqlite` Psalm 101.
   - Psalm text now comes from the Katameros psalm files.
   - ⚠ The home-page prototype (`tools/prototype/build_data.py`) still takes psalms from `Bible.sqlite` by number, so on some days it can show the wrong psalm. Fix when the readings section is rebuilt (stage C).
4. **`Bible.sqlite` row index ≠ verse number** in 11 chapters.
   - Psalm 119 has 22 Hebrew-letter heading rows.
   - Some verses are merged (e.g. Matthew 17:26).
   - Two chapters have a row numbered 0 (Baruch 6, Matthew 21).
   - Verse numbers are taken from the number printed at the start of each verse; unnumbered rows are kept as headings.
5. **Source errata in the Katameros tables (17)**, listed in `IMPORT_REPORT.md`. Not corrected by the importer; each needs the owner's review. Examples:
   - `N1_10:34:42` (should probably read `10:34-42`).
   - `023_` instead of `O23_`.
   - `N16_5:17-6:2` (2 Timothy has 4 chapters; 1 Timothy is `N15`).
   - `N24_2:7-17` (2 John has 1 chapter).
6. **Excel HTML exports** (`shehood`, `Ipsaltos` htm) are Windows-1256 and **`katamars/*.xls`** is binary BIFF. Both need their own parsers (later slice).

## 4. Next imports (ordered)

1. Katameros full texts with commentary (`orsozxi/documents/katamars`).
2. Services (`salawatelkhedma`).
3. Deacon responses (`khoras`).
4. People's responses (`mordat`).
5. English texts after edition check: `agiosbible` (KJV?), `orthodox-presenter`.
6. Commentary (`catena`).
7. Hymn audio (`Ipsaltos` mp3).
