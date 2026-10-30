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
- Coptic + Arabized Coptic columns now exist for: Holy Week, Psalmody, Basil and Gregory liturgies, Fractions, Raising of incense.
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
