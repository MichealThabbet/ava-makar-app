# Fixtures

`agenda_2015_2030.csv` — 428 dated church events for 2016–2030 (the 2015 page has no table), parsed verbatim from the feast agenda pages shipped (unencrypted) in the Orsozoxi app (`assets/Agenda/*.htm`, Windows-1256). Third-party table: used as a cross-check, **not** an official golden source. Official church tables are still required (AGENTS.md §3).

Findings from the tests:
- 426 of 428 Gregorian↔Coptic pairs match the engine exactly; 2 rows have typos in the Coptic column (listed in the test, confirmed by the Easter-derived Gregorian dates).
- All 15 Easter dates and every movable day in the table match the engine.
- 3 rows carry a wrong weekday label (1 June 2016, 2017, 2023 labelled Sunday).
