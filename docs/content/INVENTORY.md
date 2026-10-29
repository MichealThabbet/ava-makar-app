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
