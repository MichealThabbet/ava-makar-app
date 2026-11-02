# Content inventory — owner's package (Orsozoxi 13.10.0 extract, 7 parts)
Date: 2026-10-29. Method: unzip each part, count files per folder and type, sample at most 5–6 files per group, test Excel cells for encryption. The extracted files are not committed (size and rights); only this inventory is.

## Result
| Content | Files | Format | State | Usable |
|---|---|---|---|---|
| Arabic Bible, 46 OT + 27 NT books, with tashkeel | ~1,330 | txt | Plain. Wording matches Smith–Van Dyck (public domain) | Yes |
| English Bible, 66 books | 66 | xml | Plain. Wording matches NKJV (copyrighted) | No (DEC-P0-10: KJV instead) |
| Madayeh (praises), Arabic + Arabized Coptic | 279 | html | Plain | Yes, after review |
| Daily reading references (`Daily_katamars.xml`): section code + book + chapter + verses per Coptic day | 1 | xml | Plain | Yes, as reference data for the engine |
| Feast agenda 2015–2030 | 16 | htm | Plain | Yes, as a cross-check for the calendar engine (not an official source) |
| Katamars: days 366, Sundays 52, Pentecost 50, Great Lent 55, Jonah 4 | ~527 | xls | **Encrypted at cell level** | No |
| Psalmody (absalmody 213, annual 286) | 499 | xls | **Encrypted at cell level** | No |
| Kholagy: Baker 263, occasions 387, normal 122, Basil 12, Gregory 12 | 1,036 | xls | **Encrypted at cell level** | No |
| Sagda prayers 98, Bible cross-references 66 | 164 | xls | **Encrypted at cell level** | No |
| Agpeya, Kandil, Laqqan, Qisma, Dallal, Synaxarium (392), Lent Katamars commentary (49) | ~545 | .orso | Encrypted file format | No |
| CSV copies of the Excel first sheets (part 7) | 1,089 | csv | Same encrypted cells | No |
| Coptic fonts in package | 3 | ttf | Legacy, non-Unicode; rights with the Patriarchate | No (DEC-P0-12) |
| `arial.ttf` | 1 | ttf | Microsoft license | No (DEC-P0-11) |
| Huawei/HMS config, app UI images and layouts, ICU, time zones, libraries, notes SQL | ~7,500 | various | Not content | No |

## Conclusion
- Usable now: Arabic Bible (Van Dyck), madayeh, the daily reading reference table, and the 2015–2030 agenda as a test cross-check.
- Every liturgical book (Katameros, Agpeya, Kholagy, Psalmody, Synaxarium, Pascha, Difnar) is encrypted by the original app. Decryption is out of scope: the publisher protected it deliberately (DEC-P0-08 note).

## Sources for the encrypted books (in order)
1. The owner's own Katameros working files (made with Fr. Ignatius of Anba Bishoy).
2. The monastery's printed editions (also match the Old Bohairic pronunciation, DEC-P0-06).
3. A written license from the Orsozoxi developer for the decrypted content.

---

# Package 2 — Katamaras 2.0.1 (`coptic.avabishoy.katamars`), owner's own work
Date: 2026-10-29. 1,947 files. All text files are **plain UTF-8** (random sample of 40: 40 Arabic, 0 encrypted).

| Content | Files | Notes | Usable |
|---|---|---|---|
| Katameros reading table: weekdays per Coptic month 1–13, Sundays, Great Lent, Pentecost (50 days), Holy Week, plus psalm tables | 24 + 10 | One line per day: `[day/month][book_chapter:verses]×9[title]`. References only; text resolved from the Bible | Yes — primary Katameros source |
| Synaxarium, 13 months + special days | 370 | Plain Arabic | Yes — replaces the encrypted Orsozoxi Synaxarium |
| Arabic Bible, 73 books | 1,335 | Van Dyck wording, without tashkeel | Yes |
| Qisma (fractions) | 40 | Plain Arabic | Yes |
| Taks (rite notes) | 20 | Plain Arabic | Yes |
| Kandil | 8 | Plain Arabic | Yes |
| Laqqan and Sagda | 8 | Plain Arabic | Yes |

## Coverage after both packages
- Covered: Bible (Arabic), Katameros (references + Bible text), Synaxarium, Qisma, Taks, Kandil, Laqqan, Sagda, Madayeh, Holy Week readings.
- Still missing (needs a source): Agpeya, Kholagy (liturgy texts), Annual and Kiahk Psalmody, Difnar, Pascha book texts beyond the readings, all Coptic and Arabized Coptic columns.

---

# Package 3 — `churchbooks*.doc` (6 Word files from the owner)
Date: 2026-10-29. Converted to UTF-8 text with LibreOffice; profiled by character ranges and key headings. Edition and publisher are not stated in the files (to be recorded when known).

| File | Book | Lines | Script | Notes |
|---|---|---|---|---|
| churchbooks3 | Annual Psalmody / Tasbeha, with an introduction | 4,806 | Arabic | |
| churchbooks4 | Kiahk Psalmody | 4,189 | Arabic | Near-duplicate of churchbooks5 (3,861 shared lines) |
| churchbooks5 | Kiahk Psalmody | 4,186 | Arabic | Kept as the working copy; churchbooks4 used for comparison only |
| churchbooks7 | Agpeya | 678 | Arabic | |
| churchbooks23 | Kholagy: raising of incense, Basil, Gregory, Cyril liturgies | 9,823 | Arabic + Arabized responses | |
| churchbooks24 | Lazarus Saturday, Palm Sunday, Holy Week (Pascha) services | 1,623 | Arabic | |

No Unicode Coptic and no legacy-font Coptic text in any of the six files.

## Coverage after packages 1–3
- Covered (Arabic): Bible, Katameros, Synaxarium, Agpeya, Kholagy, Annual Psalmody, Kiahk Psalmody, Holy Week services, Qisma, Taks, Kandil, Laqqan, Sagda, Madayeh.
- Still missing: Difnar; the Coptic column of every book; a complete Arabized Coptic column (DEC-P0-03, DEC-P0-09).

---

# Package 4 — `Archive.zip` (owner), trilingual
Date: 2026-10-30. 2,379 plain UTF-8 text files. Each text unit is a folder holding up to three parallel files: `N_arabic.txt`, `N_arabic_coptic.txt` (Arabized Coptic), `N_coptic.txt`.

| Folder | Files | Content |
|---|---|---|
| holyweek | 853 | Holy Week (Pascha) by day and hour: prophecies, psalms, gospels, homilies, hymns |
| السنكسار | 872 | Synaxarium, 13 months |
| الإبصلمودية المقدسة | 251 | Psalmody, 103 units |
| القداس الباسيلى | 130 | Liturgy of St Basil, 51 units |
| Prayers | 134 | Prayers (`prayer_N.txt`) |
| القداس الغريغوري | 49 | Liturgy of St Gregory, 26 units |
| القسمة | 47 | Fractions |
| رفع بخور عشية و رفع بخور باكر | 43 | Raising of incense, 16 units |

Files by language: Arabic 399+, Arabized Coptic 140, Coptic 314.

**Coptic encoding:** the `coptic.txt` files use the legacy Latin-mapped Coptic font encoding (e.g. `)wk te 5gom nem piwov`), not Unicode. Conversion to Unicode with a fixed, tested mapping is required (DEC-P0-12).
**Pronunciation of the Arabized Coptic:** to be classified (modern vs Old Bohairic) during import (DEC-P0-09).
**Provenance:** the owner's own work (about six months), declared 2026-10-30 (DEC-P0-15).

## Coverage after packages 1–4
- Coptic column now exists for: Holy Week (314 units), Psalmody (148), Basil (79), Gregory (23), Raising of incense (27).
- Arabized Coptic exists only for Holy Week (140 of 314 units). *(Corrected 2026-10-30; the earlier line overstated Arabized coverage.)*
- Still missing: Difnar; Coptic columns for Agpeya, Cyril liturgy, Kiahk Psalmody (to be confirmed inside the Psalmody folder).

---

# Package 5 — `apk-katamaras-mishel.zip` («قطمارس ميشيل»)
Date: 2026-10-30. 1,522 files in 15 folders. A merged library of earlier sources.

| Folder | Files | Finding | Decision |
|---|---|---|---|
| القطمارس, السنكسار, الكتاب المقدس, القسمة, اللقان, السجدة, القنديل, الطقوس, القراءات اليومية, الأجندة | ~970 | Same content as packages 1–2 (plain) | Already covered; no new import |
| المدائح | 281 | Same as package 1 madayeh (plain html) | Already covered |
| الإبصلمودية | 214 | Orsozoxi xls, cell-encrypted | Not usable |
| الأجبية (`agypa.txt`, 486 KB, with tashkeel) | 1 | Plain text whose name matches the encrypted Orsozoxi asset `agypa.orso` | **Excluded**: decrypted third-party content |
| دلال أسبوع الآلام | 62 | 51 of 56 text files share names with encrypted Orsozoxi `dallal/*.orso` | **Excluded**: decrypted third-party content |
| التفاسير (`1.txt`, Windows-1256) | 1 | Commentary; Orsozoxi's Lent commentary was encrypted | **Excluded** unless its origin is shown to be different |

**Update 2026-10-30 (DEC-P0-14):** the owner declared that this package is his own work with Fr. Ignatius of Anba Bishoy, and approved its use. The three items above are reinstated as usable, with provenance recorded as «owner's declaration». The file-name overlap with Orsozoxi assets is kept on record. Commentary `1.txt` is Windows-1256 and must be converted to UTF-8 on import.

---

# Package 6 — `com.Fr_matta_meskin` (app about Fr. Matta El-Meskin)
Date: 2026-10-30. Plain content in `assets/` (HTML, SQLite `som.sqlite`). New material for 04.06 «مؤلفات وعظات آباء الدير» and 03.11 «قديسو الدير وآباؤه».

| Content | Count | Form | Note |
|---|---|---|---|
| Biography (`nabza.htm`) | 1 | Arabic HTML | Usable after review |
| Articles (`maqal1..26`) | 26 | Arabic HTML | Usable after review |
| Sayings (`aqwal`) | 100 | SQLite text | Usable after review |
| Sermons (audio) | 186 | Links to mp3 on a third-party site (music.beinlive24.com) | Titles usable as a catalogue; audio should come from the monastery's own copies, not hot-linked |
| Videos | 100 | YouTube IDs | Can be embedded through YouTube's player |
| Books (PDF) | 130 | Google Drive file IDs of an unknown owner | Titles usable as a catalogue; files should come from the monastery |
| `som - Copy.sqlite` | 1 | Duplicate of `som.sqlite` | Ignored |

Rights: Fr. Matta El-Meskin's writings are published by St Macarius Monastery; under DEC-P0-07 the owner approves their use.

---

# Package 7 — `com.stmacarius.khelwa` (existing St Macarius retreat-house app)
Date: 2026-10-30. 1,024 files. **No liturgical content.** A booking client (Kotlin, Firebase, OkHttp) whose backend URL is `https://api.test.baramous.com/`; UI fonts: Cairo (OFL), Roboto.

Reference value for P5 «بيت الخلوة» — fields and states found in the app's labels:
- Applicant: full four-part name, national ID, birth date, address, email, job, education, own church, confession father, confession father's church, username/password.
- Booking: «جدول بيت الخلوة», booking date, start/end date, departure date, booking status, «حجوزاتي», cancel booking, personal items list («المستلزمات الشخصية»).
- Monastery label: «دير القديس مكاريوس الكبير».

Owner decision 2026-10-30 (DEC-P0-16): rarely used; reference only. Ava-Makar builds its own retreat system to a much higher standard; no integration with this backend.

---

# Packages 8–10 (2026-10-30) — content extracted from three third-party apps
| Package | Content | Coptic | Value |
|---|---|---|---|
| 01 Coptic Prayers Swedish | CSV: Agpeya 357 sentences, Dallal 1,216, Kholagy 1,680, Katameros tables (days, Sundays, Lent, Pentecost, psalms 507), Bible 35,780 verses + 74 book names; Arabic + Swedish | None (Kholagy `coptic` column empty) | Low for content (Swedish is not a UI language; Arabic duplicates sources already held). High as a data-model reference: `sentences` + `prays_relations` ordering tables |
| 02 Holy Week Dallal | CSV: 1,216 sentences, 1,046 reading lines, 22 days, relations; Arabic | None (`hasCoptic` never set) | Second, independent Dallal source: cross-check for the Dallal approved under DEC-P0-14 |
| 03 Colored Kholagy | Audit only: 0 content files in the APK | — | None |

Not imported. Use as cross-check/reference only unless the owner decides otherwise.

---

# Package 11 — Kaneesty (Flutter app), 7-part archive
Date: 2026-10-30. 1,988 files, plain data in `assets/flutter_assets/assets/`. Each data file states its own sources:

| Content | Form | Languages | Stated source |
|---|---|---|---|
| Kholagy: incense, Basil, Gregory, **Cyril**, fractions | JSON (1 MB) | Arabic, Arabized Coptic, **Unicode Coptic** (57,633 Coptic chars), English | Coptic from st-takla.org; English from Anba Bishoy Church Canada books (Fr. Jacob Nadian), copticchurch.net, St-Takla |
| Agpeya | JSON ×2 | Arabic (some Unicode Coptic), **English** | st-takla.org (corrections from orsozox.org) |
| Holy Week (Pascha) | JSON (2.7 MB) | Arabic, English | Arabic from an app DB; English from «The Rite of Holy Week» (St Damiana & St Athanasius, Sydney) |
| Synaxarium | JSON + SQLite (867 events) | **English** (+ Arabic DB) | katameros.app |
| English Bible | SQLite, 35,448 verses | English | WEBBE + KJV fill, both public domain (eBible.org) |
| Arabic Bible | SQLite, 73 books / 35,784 verses | Arabic | — |
| Church feasts | JSON | — | Useful as a calendar cross-check |
| Kids content, games | JSON | Arabic, English | Not in scope (no gamification of worship, vision §7) |

**Security note:** the archive contains `assets/flutter_assets/.env` with the original developer's live API keys. Not opened, not used; the archive must not be published.

**Value:** fills the Coptic column for the Cyril liturgy and the English column for Kholagy, Agpeya, Pascha and Synaxarium. These are third-party compilations of other sites' texts: approved by the owner (DEC-P0-17), with attribution to each stated source.

---

# Package 12 — GitHub `MichealThabbet/defnar` (owner)
Date: 2026-10-30. 6,073 files, 170 MB: 5,764 XML documents, images, fonts, gzip search indexes. XML namespace `http://www.suscopts.org/CopticReader` — the data set of the **Coptic Reader** app (Coptic Orthodox Diocese of the Southern United States). All text is plain, **Unicode Coptic**.

Languages across all documents (paragraph counts): English 95,026 · Arabic 93,371 · Coptic 24,512 · CopticReading 18,429 (Coptic-script scripture readings). **No Arabized Coptic.**

| Folder | XML | Notes |
|---|---|---|
| antiphonary | 22 | **Difnar: all 13 months** (Thoout … Nesi), Adam and Watos tunes, introduction. Coptic + English + Arabic |
| readings | 3,043 | Readings |
| include | 1,928 | Shared blocks used by other documents |
| pascha | 204 | Holy Week |
| liturgies | 168 | Liturgies |
| melodies | 142 | Hymns |
| bible | 74 | Bible |
| consecrations, funeral, papal, clergy, crowning, baptism, unction, lakkan, prostration, veneration, praises, raisingOfIncense | 168 | Rites and services |
| agpeya | 14 | Agpeya |

**Value:** closes the last content gap — the Difnar — and gives Unicode Coptic (no font conversion) plus English for most books; also adds rite books not held before (sacraments, funeral, consecrations).
**Provenance:** approved by the owner under DEC-P0-17; source attribution: Coptic Reader / suscopts.org.

---

# Arabized Coptic coverage (all packages, 2026-10-30)
| Book | Arabized source | State |
|---|---|---|
| Kholagy: incense, Basil, Gregory, Cyril, fractions | Kaneesty `kholagy_ar.json` field `cp` (467 segments); churchbooks23 (responses) | Covered |
| Holy Week | Archive (140 of 314 Coptic units) | Partial |
| Madayeh | Madayeh html | Covered |
| Difnar | — | Missing |
| Annual Psalmody / Tasbeha | — | Missing |
| Kiahk Psalmody | — | Missing |
| Agpeya (Coptic parts) | — | Missing |
| Rites and sacraments, hymns (Coptic Reader) | — | Missing |

---

# Package 13 — `defnar/bostan_al_rohban` (owner, added 2026-10-30, commit 8b806db)
**بستان الرهبان** (sayings of the Desert Fathers): 1,226 paragraphs in 114 sections, Arabic **with and without tashkeel**. Data as JSON, CSV and an open SQLite file; one Markdown + JSON file per section.
- Sections 002 «القديس مقاريوس الكبير» and 003 «انبا مقار» belong directly to the monastery's patron saint (01.05).
- Fonts in the package: Amiri, Lateef, Scheherazade New, Noto Naskh Arabic, Tajawal (all OFL) — usable candidates for the Arabic reading font.
- UI images (222) belong to the original app: not used.
- Approved by the owner under DEC-P0-17.

---

# Package 14 — `defnar/orsozox` (owner, commit bfbf735, 2026-10-31)
7,007 files: Orsozoxi content reorganised by subject (TXT/CSV). Its own README states: 35,784 Bible verses (73 books, with/without tashkeel), 544 open documents, 1,750 originally unencrypted text files, and **2,229 spreadsheet groups whose encrypted cells were decrypted**.

| Section | Files |
|---|---|
| الخولاجي | 2,094 |
| الكتاب المقدس | 1,594 |
| القطمارس | 1,150 |
| الإبصلمودية | 1,010 |
| السنكسار | 397 |
| المدائح | 282 |
| الصلوات والطقوس | 206 |
| الشواهد | 135 |
| الدلال | 94 |
| الأجندة / آيات وتأملات / البصخة / ملحق الخطوط | 40 |

**Update 2026-10-31 (DEC-P0-19):** the owner states that the Orsozoxi developer agreed and provided the files and key; the whole library is approved for use, attributed to Orsozoxi. A written copy of the permission is to be kept on file.

**Earlier handling (superseded):** the originally plain parts follow DEC-P0-17. The decrypted parts are kept as a **cross-check reference only**: every one of these books is already held from approved sources (packages 2, 3, 4, 11, 12), so the app does not need to publish Orsozoxi's decrypted text. Publishing it would need the Orsozoxi developer's permission (request drafted 2026-10-29).

---

# Coptic and Arabized Coptic coverage by book (all packages, 2026-10-31)
Arabized share for Orsozoxi = files containing Arabized Coptic markers / all files in that book (some files are Arabic-only by nature).

| Book | Coptic (Unicode or convertible) | Arabized Coptic (modern) |
|---|---|---|
| Kholagy (incense, Basil, Gregory, Cyril, fractions) | Yes — Kaneesty (Unicode), Archive, Coptic Reader | Yes — Kaneesty (467 segments), Orsozoxi |
| Annual Psalmody / Tasbeha | Yes — Archive (148), Coptic Reader | Partial — Orsozoxi `psalmodySanawy` 133/286 |
| Kiahk Psalmody | Yes — Coptic Reader (Kiahk blocks), Orsozoxi | Partial — Orsozoxi `absalmody` 69/213 |
| Difnar | Yes — Coptic Reader, 13 months | **None** |
| Holy Week (Pascha) | Yes — Coptic Reader (2,601 paragraphs), Archive (314) | Partial — Archive 140/314 |
| Holy Week Dallal | — | Mostly — Orsozoxi 76/92 |
| Agpeya (Coptic parts only) | Yes — Kaneesty (Unicode) | To be checked at import |
| Rites and sacraments | Yes — Coptic Reader | Partial — Orsozoxi 48/104 |
| Madayeh | — | Yes |
| Old Bohairic pronunciation (DEC-P0-06/09) | — | **None for any book** |

---

# Package 15 — `jonathanslote/psalmody` (public GitHub, shared by the owner's friend), 2026-11-01
«New English Translation of the Coptic Orthodox Psalmody». License file: **GNU GPL v2**. 1,958 files, 685 MB (Word, PDF, audio, fonts and installers).

| Content | Languages | Note |
|---|---|---|
| Psalmody (working volumes 1–2, intro, TOC) | **English + Unicode Coptic** (69,349 Coptic chars in `Psalmody.docx`) | Alternative English translation; no Arabic |
| Doxologies (43) and saints' doxologies, Psalis | English + Coptic | |
| Euchologion (English, «Ottawa 2025» edition) | English | Patriarchate edition text; rights not covered by the repo's GPL by itself |
| Agpeya / Psalter sources | English | |
| Audio: 793 WAV in `katamarous source/Coptic` | Coptic readings audio | Possible source for «اسمع النطق» (modern pronunciation); origin of recordings not stated |
| Fonts, `.EXE`, `.DLL` | — | Not used |

**Arabized Coptic: none.** Does not close the Arabized gap.
**Value:** a second English translation for Psalmody and Doxologies (alongside Coptic Reader), and Coptic readings audio. GPL v2 texts must keep their license notice and attribution if shipped.

---

# Package 16 — `coptic-orthodox-ministry-main.zip`, 2026-11-01
An open-source **AI toolkit** (220 Markdown files): prompts and «skills» for AI assistants to prepare lessons, deacon guides, iconography notes and outreach material, in English. **No liturgical texts.** Not used as app content: AI-prepared religious text conflicts with AGENTS.md §2. Its `shared-references/` (source-discovery notes) may help later research only. Scripts not run.

---

# Package 17 — `abanobmikaeel/coptic.io` (public GitHub, MIT), 2026-11-02
TypeScript monorepo: calendar/liturgy logic (`packages/core`) and an offline data bundle (`packages/data`). Code under MIT; each data set states its own source and license.

| Data | Size | Source / license (as stated in the repo) | Value for Ava-Makar |
|---|---|---|---|
| **Coptic Bible — Bohairic** (+ Sahidic) | 4.2 MB (+0.5 MB) | Coptic SCRIPTORIUM, CC BY 4.0; Psalms 1–151 from Marcion / Hany Takla, CC BY 4.0 | **New:** Coptic text of the readings (Katameros Coptic column), openly licensed |
| Arabic Bible | 9.1 MB | to be checked | Cross-check of verse numbering |
| English / Spanish Bible | 5.7 / 5.6 MB | to be checked | Spanish not in scope |
| Synaxarium (ar, en) | 1.8 / 1.5 MB | to be checked | Cross-check |
| Liturgy St Basil, Raising of incense, Tasbeha, Agpeya (cop/ar/en, aligned rows) | 0.04–0.13 MB each | Tasbeha.org and others; repo notes reuse terms «still need confirming» | Cross-check of alignment |
| Logic: Coptic conversion, Easter, movable days, seasons, fasting, festive days, reading cycle | — | MIT | **Third independent Easter implementation** and a reference for fixed feasts/fasting rules (P1 item 6) |

Handling: Coptic Bible imported with CC BY 4.0 attribution; other data sets used as cross-checks unless their licenses are confirmed (DEC-P0-17 covers the owner's own files; this is a public third-party repo).

---

# Package 18 — calendar references from the owner (2026-11-02)
| Item | Use |
|---|---|
| `kiahk` (MIT): `algorithms.md`, `feasts.json`, `test-vectors.json` | Algorithms and vectors cross-checked; Nativity 28/29 Koiak rule adopted with its cited source (Roshdy Wasef Bahman, «التقويم القبطي وحساب الأبقطي», St-Takla) |
| `new-coptic-calendar`: `easter_2020-2070.csv` | Eastern Easter 2020–2070 used as a test table. The project itself proposes a *new* calendar; its other data is not used |
| `dateutil` (BSD/Apache): `easter.py` | Orthodox formula re-implemented as Easter method C (code read, not executed) |
| `katameros-web-app` (MIT) | Synaxarium in Arabic, English, **French**, Dutch, Italian (`assets/synax-days-*.json`) — French is a UI language (DEC-P0-02): candidate source, license of the texts to be checked |
| `katameros` (README only) | Points to the toutbabahator.com API; no data |

---

# Package 19 — `Coptic_Research_v2.zip` (owner research, 2026-11-02)
Traditional epact research: 60-year table 1997–2056 (solar/lunar cycles and epacts, Easter, movable days), 19- and 28-year cycle tables, Excel workbooks, annotated bibliography (17 records: Bahman, «أساس التقاويم» 1915 on NYU, Abu Shakir ibn al-Rahib, Mosshammer, academic PDF), list of public projects, and Python/JS reference code (read, not run).
Used: the epact rules and the 60-year table as a test fixture (all rows match the engine). Pending: Bahman's chapter on deriving Easter from the epacts (site blocked here).
