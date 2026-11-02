# Fixtures (third-party tables — cross-checks, not official golden sources)

| File | Content | Source |
|---|---|---|
| `agenda_2015_2030.csv` | 446 dated church events 2016–2030 (no 2015 table) | Feast agenda pages shipped unencrypted in the Orsozoxi app (`assets/Agenda/*.htm`, Windows-1256), parsed verbatim |
| `easter_eastern_2020_2070.csv` | Eastern (Julian computus) Easter 2020–2070, 51 years | «new-coptic-calendar» project, `easter_2020-2070.csv`, column «Eastern Easter» |
| `epact_1997_2056.csv` | Solar/lunar cycles and epacts, Easter, movable days and Coptic date of Easter, 60 years | Owner's research package «Coptic_Research_v2» (`traditional_tables/combined_60_years.csv`); epact rules from Roshdy Wasef Bahman (St-Takla.org) |
| `midlands_diocese_2022_2027.csv` | **Published church table**: Nineveh, Great Lent, Easter, Ascension, Pentecost, Apostles' fast, 2022–2027 | Coptic Orthodox Diocese of the Midlands (UK), ukmidcopts.org/coptic/calendar, transcribed in the owner's research «Coptic_Official_Tables_Research_1997_2056» |
| `kiahk_test_vectors.json` | Conversions, Easter 2025–2037, movable and fixed feasts, invalid dates | «kiahk» project (MIT), `test-vectors.json` |

A first published church table (Midlands diocese, 6 years) is now in the tests; a longer official series remains welcome.

Findings from the tests:
- 444 of 446 agenda Gregorian↔Coptic pairs match exactly; 2 rows have Coptic-column typos (listed in the test, confirmed by the Easter-derived Gregorian dates).
- All agenda Easter dates, movable days and named fixed feasts match the engine.
- 3 agenda rows carry a wrong weekday label (1 June 2016, 2017, 2023 labelled Sunday).
- The Eastern Easter table (51 years) and all kiahk vectors match.
- Epact table 1997–2056: all 60 rows match (epacts, Easter, 8 movable days, Coptic date of Easter — the last column was marked «not independently verified» in the package; it is now verified by the engine).
- Easter methods A, B and C agree for every year tested (A/B: 1–4000; C: 1583–4099).
- Midlands diocese 2022–2027: 31 of 36 dates match; the 5 others are diocese errata (2025 row one day early from Easter on — Saturday 19 April; 2022 Nineveh listed as Sunday 13 Feb).
