/// Liturgical day: from sunset to the next sunset (Gen 1:5). Vespers (رفع
/// بخور عشية), Midnight prayer and the Midnight Praise belong to the new day.
/// Owner's ruling 2026-11-02 (DEC-P0-24).
///
/// The caller supplies today's local sunset (from the device location); when
/// it is unknown the fixed cutoff [defaultCutoff] (18:00 local) is used.
library;

import 'dates.dart';

const defaultCutoff = Duration(hours: 18);

/// Civil date whose liturgical day is current at [localTime].
CalendarDate liturgicalDate(DateTime localTime, {DateTime? sunset}) {
  final midnight = DateTime(localTime.year, localTime.month, localTime.day);
  final cutoff = sunset ?? midnight.add(defaultCutoff);
  final day = localTime.isBefore(cutoff) ? midnight : DateTime(midnight.year, midnight.month, midnight.day + 1);
  return CalendarDate(day.year, day.month, day.day);
}

/// Coptic date of the current liturgical day.
CalendarDate liturgicalCopticDate(DateTime localTime, {DateTime? sunset}) =>
    gregorianToCoptic(liturgicalDate(localTime, sunset: sunset));
