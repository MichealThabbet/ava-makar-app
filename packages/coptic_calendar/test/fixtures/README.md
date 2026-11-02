# Fixtures (third-party tables — cross-checks, not official golden sources)

| File | Content | Source |
|---|---|---|
| `agenda_2015_2030.csv` | 446 dated church events 2016–2030 (no 2015 table) | Feast agenda pages shipped unencrypted in the Orsozoxi app (`assets/Agenda/*.htm`, Windows-1256), parsed verbatim |
| `easter_eastern_2020_2070.csv` | Eastern (Julian computus) Easter 2020–2070, 51 years | «new-coptic-calendar» project, `easter_2020-2070.csv`, column «Eastern Easter» |
| `epact_1997_2056.csv` | Solar/lunar cycles and epacts, Easter, movable days and Coptic date of Easter, 60 years | Owner's research package «Coptic_Research_v2» (`traditional_tables/combined_60_years.csv`); epact rules from Roshdy Wasef Bahman (St-Takla.org) |
| `kiahk_test_vectors.json` | Conversions, Easter 2025–2037, movable and fixed feasts, invalid dates | «kiahk» project (MIT), `test-vectors.json` |

Official church tables (20+ years) are still required (AGENTS.md §3).

Findings from the tests:
- 444 of 446 agenda Gregorian↔Coptic pairs match exactly; 2 rows have Coptic-column typos (listed in the test, confirmed by the Easter-derived Gregorian dates).
- All agenda Easter dates, movable days and named fixed feasts match the engine.
- 3 agenda rows carry a wrong weekday label (1 June 2016, 2017, 2023 labelled Sunday).
- The Eastern Easter table (51 years) and all kiahk vectors match.
- Epact table 1997–2056: all 60 rows match (epacts, Easter, 8 movable days, Coptic date of Easter — the last column was marked «not independently verified» in the package; it is now verified by the engine).
- Easter methods A, B and C agree for every year tested (A/B: 1–4000; C: 1583–4099).
