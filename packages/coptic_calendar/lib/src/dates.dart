/// Calendar dates and conversions through the Julian Day Number (JDN).
///
/// Every calendar converts to and from a JDN; conversions between calendars
/// always pass through it. Correctness is checked in tests against Dart's own
/// proleptic Gregorian `DateTime` and against the 2016–2030 church agenda.
library;

/// A day in the Gregorian, Julian or Coptic calendar.
class CalendarDate {
  const CalendarDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  @override
  bool operator ==(Object other) =>
      other is CalendarDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

int _div(int a, int b) => (a / b).floor();

// ---------------------------------------------------------------- Gregorian

int gregorianToJdn(int y, int m, int d) {
  final a = _div(14 - m, 12);
  final yy = y + 4800 - a;
  final mm = m + 12 * a - 3;
  return d + _div(153 * mm + 2, 5) + 365 * yy + _div(yy, 4) - _div(yy, 100) + _div(yy, 400) - 32045;
}

CalendarDate jdnToGregorian(int jdn) {
  final a = jdn + 32044;
  final b = _div(4 * a + 3, 146097);
  final c = a - _div(146097 * b, 4);
  final d = _div(4 * c + 3, 1461);
  final e = c - _div(1461 * d, 4);
  final m = _div(5 * e + 2, 153);
  final day = e - _div(153 * m + 2, 5) + 1;
  final month = m + 3 - 12 * _div(m, 10);
  final year = 100 * b + d - 4800 + _div(m, 10);
  return CalendarDate(year, month, day);
}

// ------------------------------------------------------------------- Julian

int julianToJdn(int y, int m, int d) {
  final a = _div(14 - m, 12);
  final yy = y + 4800 - a;
  final mm = m + 12 * a - 3;
  return d + _div(153 * mm + 2, 5) + 365 * yy + _div(yy, 4) - 32083;
}

CalendarDate jdnToJulian(int jdn) {
  final c = jdn + 32082;
  final d = _div(4 * c + 3, 1461);
  final e = c - _div(1461 * d, 4);
  final m = _div(5 * e + 2, 153);
  final day = e - _div(153 * m + 2, 5) + 1;
  final month = m + 3 - 12 * _div(m, 10);
  final year = d - 4800 + _div(m, 10);
  return CalendarDate(year, month, day);
}

// ------------------------------------------------------------------- Coptic

/// JDN of 1 Thout, year 1 of the Era of the Martyrs, minus one.
/// Verified in tests against the 2016–2030 agenda (428 dated events).
const int _copticEpochMinus1 = 1825029;

/// 12 months of 30 days and the Nasie (month 13) of 5 days, or 6 in a
/// Coptic leap year (the year before a Julian leap year: year % 4 == 3).
bool isCopticLeapYear(int y) => y % 4 == 3;

int copticMonthLength(int y, int m) => m < 13 ? 30 : (isCopticLeapYear(y) ? 6 : 5);

int copticToJdn(int y, int m, int d) {
  if (m < 1 || m > 13 || d < 1 || d > copticMonthLength(y, m)) {
    throw ArgumentError('Invalid Coptic date $y/$m/$d');
  }
  return _copticEpochMinus1 + 365 * (y - 1) + _div(y, 4) + 30 * (m - 1) + d;
}

CalendarDate jdnToCoptic(int jdn) {
  final n = jdn - _copticEpochMinus1 - 1;
  final y = _div(4 * n + 1463, 1461);
  final start = copticToJdn(y, 1, 1);
  final dayOfYear = jdn - start;
  return CalendarDate(y, dayOfYear ~/ 30 + 1, dayOfYear % 30 + 1);
}

// ---------------------------------------------------------------- helpers

CalendarDate gregorianToCoptic(CalendarDate g) => jdnToCoptic(gregorianToJdn(g.year, g.month, g.day));

CalendarDate copticToGregorian(CalendarDate c) => jdnToGregorian(copticToJdn(c.year, c.month, c.day));

/// 0 = Monday … 6 = Sunday, same as `DateTime.weekday - 1`.
int weekdayOfJdn(int jdn) => jdn % 7;
