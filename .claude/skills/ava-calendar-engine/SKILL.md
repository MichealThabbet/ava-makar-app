---
name: ava-calendar-engine
description: Use the Ava-Makar Coptic calendar engine (packages/coptic_calendar, Dart) for any date, liturgical day, Easter and movable feasts, fixed feasts, fasts, rite periods (tune, hours, alleluia), Annunciation rule and sunset day change. Use whenever a feature depends on the church calendar.
---

# Coptic calendar engine

**Location:** `packages/coptic_calendar/` (Dart).
**Tests:** `cd packages/coptic_calendar && /home/user/flutter/bin/dart test` → 36 passing. Keep them green; add a test with every rule change.

## API (`lib/coptic_calendar.dart` exports)
- **`dates.dart`:**
  - `gregorianToJdn`, `jdnToGregorian`, `julianToJdn`, `jdnToJulian`, `copticToJdn`, `jdnToCoptic`;
  - `gregorianToCoptic`, `copticToGregorian`;
  - `isCopticLeapYear`; `weekdayOfJdn` (0 = Monday … 6 = Sunday).
- **`easter.dart`:**
  - `copticEasterJdn(gregorianYear)` — throws if the 4 independent methods disagree;
  - `copticEaster`.
- **`epact.dart`:** traditional epacts, `traditionalEaster` (method D), `apostlesFastDaysTraditional`.
- **`movable.dart`:** `movableDays` (offsets from Easter: Nineveh −69, Lent −55…, Palm −7, Ascension +39, Pentecost +49, Apostles +50, …), `movableDaysFor(year)`.
- **`fixed.dart`:**
  - `fixedFeasts` (16, with the Nativity 28/29 Koiak rule), `fixedFeastIn`;
  - `annunciationCelebrated(year, easterJdn)` (DEC-23: suppressed from −8 to −1).
- **`fasts.dart`:** `fastOn(jdn)` returns a `Fast?`:
  - nativity, paramounNativity, paramounEpiphany, nineveh, greatLent, apostles, virgin, wednesdayFriday;
  - `paramounDays`; Arabic names in `fastNamesAr`.
- **`liturgical_day.dart`:** `liturgicalDate(localTime, {sunset})` with an 18:00 fallback (DEC-24); `liturgicalCopticDate`.
- **`rites.dart`:**
  - `riteOn(jdn)` returns a `RiteDay` (section 1–42 of the official rites page, nameAr, tunes, hours, alleluia, monasteryUntilVeil, noteAr);
  - precedence in DEC-25; name maps `tuneNamesAr`, `liturgyHourNamesAr`, `alleluiaNamesAr`.

## Rules
- Never hard-code dates or rules from memory. New rules go in as data, with a source and a golden test.
- Golden fixtures are in `test/fixtures/`: the agenda 2016–2030, Easter 2020–2070, epacts 1997–2056, the Midlands diocese and Southern US calendars with documented errata.
- The liturgical day changes at sunset. Midnight prayer and the praise belong to the new day.
- Retreat blackouts and fast-based age rules (`data/rules/retreat_rules.json`) are evaluated with this engine:
  - Jan 1 → Epiphany;
  - Nineveh = `nineveh_fast_start` + 0…2;
  - `great_lent_end` (−9) → `thomas_sunday` (+7);
  - fasts lifting the age limit: nativity, paramounNativity, paramounEpiphany, greatLent.

## Port to the backend
- Expose the engine through a small Dart service, or compile the same rules to TypeScript with a shared golden test file.
- Never keep two diverging implementations without the same golden tests passing on both.
