/// Fixed feasts kept as data (Coptic month/day), resolved inside a Gregorian year.
///
/// Rule for the Nativity: in a Coptic year with year % 4 == 0 (the year after a
/// 6-day Nasie) the Church keeps the feast on 28 Koiak so that it stays on
/// 7 January. Source cited by the kiahk project: Roshdy Wasef Bahman,
/// «التقويم القبطي وحساب الأبقطي», ch. 13 (St-Takla.org). Every other fixed
/// feast follows its arithmetic date. Confirmed by the 2016–2030 agenda.
library;

import 'dates.dart';

class FixedFeast {
  const FixedFeast(this.id, this.nameAr, this.month, this.day, {this.dayAfterLeap});

  final String id;
  final String nameAr;
  final int month;
  final int day;

  /// Day observed instead of [day] when the Coptic year % 4 == 0.
  final int? dayAfterLeap;

  int observedDay(int copticYear) => (dayAfterLeap != null && copticYear % 4 == 0) ? dayAfterLeap! : day;
}

/// Initial set; the full list moves to the CMS as versioned data (AGENTS.md §3).
const fixedFeasts = <FixedFeast>[
  FixedFeast('nayrouz', 'عيد النيروز (رأس السنة القبطية)', 1, 1),
  FixedFeast('cross', 'عيد الصليب', 1, 17),
  FixedFeast('nativity_fast_start', 'بدء صوم الميلاد', 3, 16),
  FixedFeast('nativity', 'عيد الميلاد المجيد', 4, 29, dayAfterLeap: 28),
  FixedFeast('circumcision', 'عيد الختان', 5, 6),
  FixedFeast('epiphany', 'عيد الغطاس', 5, 11),
  FixedFeast('cana', 'عرس قانا الجليل', 5, 13),
  FixedFeast('presentation', 'دخول السيد المسيح الهيكل', 6, 8),
  FixedFeast('cross_apparition', 'عيد ظهور الصليب المقدس', 7, 10),
  FixedFeast('annunciation', 'عيد البشارة المجيد', 7, 29),
  FixedFeast('st_mark_martyrdom', 'استشهاد القديس مرقس الرسول', 8, 30),
  FixedFeast('entry_into_egypt', 'عيد دخول السيد المسيح أرض مصر', 9, 24),
  FixedFeast('apostles_martyrdom', 'عيد استشهاد القديسين بطرس وبولس', 11, 5),
  FixedFeast('virgin_fast_start', 'بدء صوم السيدة العذراء', 12, 1),
  FixedFeast('transfiguration', 'عيد التجلي', 12, 13),
  FixedFeast('assumption', 'عيد صعود جسد السيدة العذراء', 12, 16),
];

/// Gregorian date of [feast] inside [gregorianYear] (the Coptic year that
/// places it in that Gregorian year is chosen).
CalendarDate fixedFeastIn(FixedFeast feast, int gregorianYear) {
  for (final cy in [gregorianYear - 284, gregorianYear - 283]) {
    final g = copticToGregorian(CalendarDate(cy, feast.month, feast.observedDay(cy)));
    if (g.year == gregorianYear) return g;
  }
  throw StateError('${feast.id} not found in $gregorianYear');
}

/// Annunciation (29 Baramhat) is not celebrated, and not moved, when it falls
/// from Lazarus Saturday (Easter − 8) through Joyous Saturday (Easter − 1):
/// Palm Sunday and Holy Week. Owner's ruling as delegated approver,
/// 2026-11-02 (DEC-P0-23).
const annunciationSuppressedFrom = -8;
const annunciationSuppressedTo = -1;

bool annunciationCelebrated(int gregorianYear, int easterJdn) {
  final a = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == 'annunciation'), gregorianYear);
  final offset = gregorianToJdn(a.year, a.month, a.day) - easterJdn;
  return offset < annunciationSuppressedFrom || offset > annunciationSuppressedTo;
}
