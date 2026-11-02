/// Traditional Coptic epacts (الأبقطي), as stated by Roshdy Wasef Bahman,
/// «التقويم القبطي وحساب الأبقطي» (St-Takla.org), via the owner's research
/// package «Coptic_Research_v2» (2026-11-02):
///
///   solar cycle  (دور الشمس)   = (AM − 4) mod 28
///   solar epact  (أبقطي الشمس) = (cycle + ⌊cycle / 4⌋) mod 7
///   lunar cycle  (دور القمر)   = (AM − 1) mod 19
///   lunar epact  (أبقطي القمر) = (11 × cycle) mod 30
///
/// AM is the Coptic year current at Easter.
///
/// Easter by the traditional method (Bahman ch. 15–16, from the owner's study
/// «Epact_Bahman_Calculation_Study», 2026-11-02):
///   K = 40 − lunar epact;  K 25–30 → K Baramhat;  K > 30 → (K − 30) Barmouda;
///   otherwise K Barmouda. That is the Passover (الفصح) of the computus.
///   Weekdays come from the solar epact: 1..7 → 1 Thout falls on
///   Wednesday … Tuesday (0 counts as 7). Easter is the first Sunday after
///   the Passover. No JDN or other calendar is used: it is independent of
///   methods A–C in easter.dart.
library;

import 'dates.dart';

class Epacts {
  const Epacts(this.solarCycle, this.solarEpact, this.lunarCycle, this.lunarEpact);

  final int solarCycle;
  final int solarEpact;
  final int lunarCycle;
  final int lunarEpact;
}

Epacts epactsForCopticYear(int am) {
  final solar = (am - 4) % 28;
  final lunar = (am - 1) % 19;
  return Epacts(solar, (solar + solar ~/ 4) % 7, lunar, (11 * lunar) % 30);
}


/// Weekday of 1 Thout from the solar epact, 0 = Monday … 6 = Sunday.
int thoutWeekday(Epacts e) {
  final s = e.solarEpact == 0 ? 7 : e.solarEpact; // 1 = Wednesday … 7 = Tuesday
  return (s + 1) % 7; // Wednesday is 2 in the 0 = Monday scheme
}

/// Passover of the computus as a Coptic (month, day) in year [am].
CalendarDate traditionalPassover(int am) {
  final k = 40 - epactsForCopticYear(am).lunarEpact;
  if (k > 30) return CalendarDate(am, 8, k - 30);
  if (k >= 25) return CalendarDate(am, 7, k);
  return CalendarDate(am, 8, k);
}

/// Method D — Coptic Easter by the traditional epacts, as a Coptic date.
CalendarDate traditionalEaster(int am) {
  final e = epactsForCopticYear(am);
  final p = traditionalPassover(am);
  final dayOfYear = 30 * (p.month - 1) + p.day - 1;
  final wd = (thoutWeekday(e) + dayOfYear) % 7;
  final toSunday = wd == 6 ? 7 : 6 - wd; // first Sunday strictly after
  final d = dayOfYear + toSunday;
  return CalendarDate(am, d ~/ 30 + 1, d % 30 + 1);
}

/// Days of the Apostles' fast by Bahman's rule (Easter on day d):
/// Barmouda → (30 − d) + 15, Baramhat → (30 − d) + 45.
int apostlesFastDaysTraditional(CalendarDate copticEaster) =>
    (30 - copticEaster.day) + (copticEaster.month == 8 ? 15 : 45);
