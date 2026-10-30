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
**Provenance:** to be recorded (source not stated in the files).

## Coverage after packages 1–4
- Coptic + Arabized Coptic columns now exist for: Holy Week, Psalmody, Basil and Gregory liturgies, Fractions, Raising of incense.
- Still missing: Difnar; Coptic columns for Agpeya, Cyril liturgy, Kiahk Psalmody (to be confirmed inside the Psalmody folder).
