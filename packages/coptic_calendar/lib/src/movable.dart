/// Movable days derived from Coptic Easter, kept as data (offset in days).
///
/// Offsets were checked against the 2016–2030 church agenda in tests; they
/// stay data so the CMS can version them (AGENTS.md §3).
library;

import 'dates.dart';
import 'easter.dart';

class MovableDay {
  const MovableDay(this.id, this.nameAr, this.offset);

  final String id;
  final String nameAr;

  /// Days relative to Easter Sunday.
  final int offset;
}

const movableDays = <MovableDay>[
  MovableDay('nineveh_fast_start', 'بدء صوم يونان', -69),
  MovableDay('nineveh_passover', 'فصح يونان', -66),
  MovableDay('great_lent_start', 'بدء الصوم الأربعيني المقدس', -55),
  MovableDay('great_lent_end', 'ختام الصوم الأربعيني المقدس', -9),
  MovableDay('lazarus_saturday', 'سبت لعازر', -8),
  MovableDay('palm_sunday', 'أحد الشعانين', -7),
  MovableDay('covenant_thursday', 'خميس العهد', -3),
  MovableDay('good_friday', 'الجمعة العظيمة', -2),
  MovableDay('joyous_saturday', 'سبت الفرح', -1),
  MovableDay('easter', 'عيد القيامة المجيد', 0),
  MovableDay('sham_el_nessim', 'شم النسيم', 1),
  MovableDay('thomas_sunday', 'أحد توما', 7),
  MovableDay('ascension', 'عيد الصعود المجيد', 39),
  MovableDay('pentecost', 'عيد حلول الروح القدس', 49),
  MovableDay('apostles_fast_start', 'بدء صوم الرسل', 50),
];

/// All movable days of a Gregorian year, as Gregorian dates.
Map<String, CalendarDate> movableDaysFor(int gregorianYear) {
  final easter = copticEasterJdn(gregorianYear);
  return {for (final m in movableDays) m.id: jdnToGregorian(easter + m.offset)};
}
