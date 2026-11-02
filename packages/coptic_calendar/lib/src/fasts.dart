/// Fasting days, kept as rules over the engine's dates.
///
/// Source: official site of the Coptic Orthodox Church, page «طقس الكنيسة»
/// (copticorthodox.church/…/coptic-rites, saved 2026-11-02 in
/// docs/content/sources/). Rules used:
///  • Wednesdays and Fridays, except the Holy Fifty days and the feasts of
///    Nativity and Epiphany;
///  • Nineveh: 3 days, two weeks before Great Lent;
///  • Paramoun of Nativity and Epiphany: 1 day before the feast; if the feast
///    falls on Sunday, 2 days (Friday–Saturday); on Monday, 3 days (Friday–Sunday);
///  • Apostles: from the day after Pentecost until the feast on 5 Epip;
///  • Virgin: 1 Mesra for 15 days, ending with the feast on 16 Mesra.
/// Nativity fast from 16 Hatour and Great Lent 55 days (−55 … −1) follow the
/// church agenda and the published calendars used in the tests.
library;

import 'dates.dart';
import 'easter.dart';
import 'fixed.dart';

enum Fast { nativity, paramounNativity, paramounEpiphany, nineveh, greatLent, apostles, virgin, wednesdayFriday }

const fastNamesAr = {
  Fast.nativity: 'صوم الميلاد',
  Fast.paramounNativity: 'برمون عيد الميلاد',
  Fast.paramounEpiphany: 'برمون عيد الغطاس',
  Fast.nineveh: 'صوم نينوى',
  Fast.greatLent: 'الصوم الكبير',
  Fast.apostles: 'صوم الرسل',
  Fast.virgin: 'صوم السيدة العذراء',
  Fast.wednesdayFriday: 'صوم الأربعاء والجمعة',
};

/// JDN of a fixed feast inside Coptic year [am].
int _feastJdn(String id, int am) {
  final f = fixedFeasts.firstWhere((f) => f.id == id);
  return copticToJdn(am, f.month, f.observedDay(am));
}

/// Paramoun days (JDNs) before a feast on [feastJdn].
List<int> paramounDays(int feastJdn) {
  final wd = weekdayOfJdn(feastJdn); // 0 = Monday … 6 = Sunday
  final n = wd == 6 ? 2 : (wd == 0 ? 3 : 1);
  return [for (var i = n; i >= 1; i--) feastJdn - i];
}

/// The fast observed on [jdn], or null. When periods overlap the more specific
/// one is returned (paramoun before Nativity fast; seasonal fasts before
/// Wednesday/Friday).
Fast? fastOn(int jdn) {
  final g = jdnToGregorian(jdn);
  final c = jdnToCoptic(jdn);
  final easter = copticEasterJdn(g.year);
  final off = jdn - easter;

  final nativity = _feastJdn('nativity', c.year);
  final epiphany = _feastJdn('epiphany', c.year);
  if (paramounDays(nativity).contains(jdn)) return Fast.paramounNativity;
  if (paramounDays(epiphany).contains(jdn)) return Fast.paramounEpiphany;
  if (jdn == nativity || jdn == epiphany) return null;

  if (off >= -69 && off <= -67) return Fast.nineveh;
  if (off >= -55 && off <= -1) return Fast.greatLent;
  if (off >= 0 && off <= 49) return null; // Holy Fifty
  final apostlesEnd = copticToJdn(jdnToCoptic(easter).year, 11, 4);
  if (off >= 50 && jdn <= apostlesEnd) return Fast.apostles;
  if (c.month == 12 && c.day <= 15) return Fast.virgin;
  if ((c.month == 3 && c.day >= 16) || (c.month == 4 && jdn < nativity)) return Fast.nativity;

  final wd = weekdayOfJdn(jdn);
  if (wd == 2 || wd == 4) return Fast.wednesdayFriday;
  return null;
}
