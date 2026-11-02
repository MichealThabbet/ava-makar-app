/// Coptic Easter — three independent computations that must agree.
///
/// The Coptic Church keeps the Alexandrian computus on the Julian calendar.
/// Method A follows Meeus' Julian algorithm; method B Gauss' formula for the
/// Julian calendar; method C the Tøndering Orthodox formula (Gregorian
/// output, 1583–4099). Different arithmetic, same rule: a disagreement in any
/// year is a bug (AGENTS.md §3). The traditional Coptic epact (الأبقطي)
/// method will be added as a fourth check once the reference text is
/// supplied (P0 addendum §3).
library;

import 'dates.dart';

/// Method C — Tøndering / GM Arts Orthodox formula, which returns the
/// Gregorian date directly (as in python-dateutil, EASTER_ORTHODOX).
/// Valid for Gregorian years 1583–4099.
CalendarDate orthodoxEasterTondering(int y) {
  final g = y % 19;
  final i = (19 * g + 15) % 30;
  final j = (y + y ~/ 4 + i) % 7;
  var e = 10;
  if (y > 1600) e = e + y ~/ 100 - 16 - (y ~/ 100 - 16) ~/ 4;
  final p = i - j + e;
  final d = 1 + (p + 27 + (p + 6) ~/ 40) % 31;
  final m = 3 + (p + 26) ~/ 30;
  return CalendarDate(y, m, d);
}

/// Method A — Meeus, «Astronomical Algorithms», Julian calendar Easter.
CalendarDate julianEasterMeeus(int year) {
  final a = year % 4;
  final b = year % 7;
  final c = year % 19;
  final d = (19 * c + 15) % 30;
  final e = (2 * a + 4 * b - d + 34) % 7;
  final month = (d + e + 114) ~/ 31;
  final day = (d + e + 114) % 31 + 1;
  return CalendarDate(year, month, day);
}

/// Method B — Gauss' Easter formula for the Julian calendar (M = 15, N = 6).
CalendarDate julianEasterGauss(int year) {
  final a = year % 19;
  final b = year % 4;
  final c = year % 7;
  final d = (19 * a + 15) % 30;
  final e = (2 * b + 4 * c + 6 * d + 6) % 7;
  final days = 22 + d + e; // days after 1 March minus 1 … counted from March 22
  return days <= 31 ? CalendarDate(year, 3, days) : CalendarDate(year, 4, days - 31);
}

/// Coptic Easter Sunday as a JDN for the given Gregorian year.
/// Throws [StateError] if the methods disagree.
int copticEasterJdn(int gregorianYear) {
  final a = julianEasterMeeus(gregorianYear);
  final b = julianEasterGauss(gregorianYear);
  if (a != b) {
    throw StateError('Easter methods disagree for $gregorianYear: A=$a B=$b');
  }
  final jdn = julianToJdn(a.year, a.month, a.day);
  if (gregorianYear >= 1583 && gregorianYear <= 4099) {
    final c = orthodoxEasterTondering(gregorianYear);
    if (gregorianToJdn(c.year, c.month, c.day) != jdn) {
      throw StateError('Easter methods disagree for $gregorianYear: A/B=${jdnToGregorian(jdn)} C=$c');
    }
  }
  return jdn;
}

CalendarDate copticEaster(int gregorianYear) => jdnToGregorian(copticEasterJdn(gregorianYear));
