/// Liturgical periods: tune, Agpeya hours prayed in the Liturgy, and the
/// Alleluia, per day.
///
/// Source: official page «الطقوس القبطية» (copticorthodox.church), saved
/// 2026-11-02 in `docs/content/sources/` (owner's file). Each [RiteDay]
/// carries the page's section number (1–42). Only what the page states is
/// encoded; where the page gives no hours (Holy Week, the great feasts without
/// Agpeya) [RiteDay.hours] is null or empty, never guessed.
///
/// Precedence when two sections fall on one day (most specific first):
/// Holy Week, Lazarus Saturday and Palm Sunday → Easter, Ascension, Pentecost →
/// Nativity, Epiphany, Annunciation (when celebrated, DEC-P0-23) → Friday
/// ending Lent → minor feasts and the Nativity octave → the 29th of the month →
/// Nineveh, Lent, Holy Fifty, Apostles' fast → paramouns → fixed periods.
library;

import 'dates.dart';
import 'easter.dart';
import 'fasts.dart' show paramounDays;
import 'fixed.dart';

enum Tune { annual, joyful, palm, kiahk, fasting, fastingWeekend, mourning, joyousSaturday }

const tuneNamesAr = {
  Tune.annual: 'سنوي',
  Tune.joyful: 'فرايحي',
  Tune.palm: 'شعانيني',
  Tune.kiahk: 'كيهكي',
  Tune.fasting: 'صيامي',
  Tune.fastingWeekend: 'صيامي (سبوت وآحاد)',
  Tune.mourning: 'حزايني',
  Tune.joyousSaturday: 'مزيج بين الحزايني والسنوي',
};

/// Agpeya hours prayed in the Liturgy.
enum LiturgyHour { third, sixth, ninth, vespers, compline }

const liturgyHourNamesAr = {
  LiturgyHour.third: 'الثالثة',
  LiturgyHour.sixth: 'السادسة',
  LiturgyHour.ninth: 'التاسعة',
  LiturgyHour.vespers: 'الغروب',
  LiturgyHour.compline: 'النوم',
};

enum Alleluia { faiBebi, jeEfmevi, eeIkhon }

const alleluiaNamesAr = {
  Alleluia.faiBebi: 'الليلويا فاي بى بي وطاي شوري',
  Alleluia.jeEfmevi: 'الليلويا جى إفميفي وتي شوري',
  Alleluia.eeIkhon: 'الليلويا إي إي إيخون',
};

class RiteDay {
  const RiteDay(
    this.section,
    this.nameAr,
    this.tunes, {
    this.hours,
    this.alleluia,
    this.monasteryUntilVeil = false,
    this.noteAr,
  });

  /// Section number on the official page (1–42).
  final int section;
  final String nameAr;
  final List<Tune> tunes;

  /// Hours prayed in the Liturgy; empty = no Agpeya in the Liturgy;
  /// null = not stated on the page for this day.
  final List<LiturgyHour>? hours;
  final Alleluia? alleluia;

  /// «وفي الأديرة إلي الستار»: monasteries pray up to the Veil.
  final bool monasteryUntilVeil;
  final String? noteAr;
}

const _h36 = [LiturgyHour.third, LiturgyHour.sixth];
const _h369 = [LiturgyHour.third, LiturgyHour.sixth, LiturgyHour.ninth];
const _hFull = [LiturgyHour.third, LiturgyHour.sixth, LiturgyHour.ninth, LiturgyHour.vespers, LiturgyHour.compline];

bool _weekend(int jdn) => weekdayOfJdn(jdn) >= 5; // Saturday, Sunday
bool _wedFri(int jdn) {
  final wd = weekdayOfJdn(jdn);
  return wd == 2 || wd == 4;
}

RiteDay _feast(int s, String name, [List<Tune> tunes = const [Tune.joyful], String? note]) =>
    RiteDay(s, name, tunes, hours: _h36, alleluia: Alleluia.faiBebi, noteAr: note);

/// Annual pattern: 3rd and 6th with فاي بى بي; Wednesday/Friday to the 9th
/// with جى إفميفي.
RiteDay _annual(int s, String name, int jdn) => _wedFri(jdn)
    ? RiteDay(s, name, const [Tune.annual], hours: _h369, alleluia: Alleluia.jeEfmevi)
    : RiteDay(s, name, const [Tune.annual], hours: _h36, alleluia: Alleluia.faiBebi);

/// Fast pattern (Nativity fast, Kiahk, Apostles, Virgin): to the 9th with
/// جى إفميفي; Saturday/Sunday 3rd and 6th with فاي بى بي.
RiteDay _fast(int s, String name, Tune tune, int jdn) => _weekend(jdn)
    ? RiteDay(s, name, [tune], hours: _h36, alleluia: Alleluia.faiBebi)
    : RiteDay(s, name, [tune], hours: _h369, alleluia: Alleluia.jeEfmevi);

/// Paramoun: to Compline (monasteries to the Veil) with جى إفميفي;
/// Saturday/Sunday 3rd and 6th with فاي بى بي.
RiteDay _paramoun(int s, String name, int jdn) => _weekend(jdn)
    ? RiteDay(s, name, const [Tune.annual], hours: _h36, alleluia: Alleluia.faiBebi)
    : RiteDay(s, name, const [Tune.annual], hours: _hFull, alleluia: Alleluia.jeEfmevi, monasteryUntilVeil: true);

int _fixed(String id, int am) {
  final f = fixedFeasts.firstWhere((f) => f.id == id);
  return copticToJdn(am, f.month, f.observedDay(am));
}

/// Rite of the liturgical day [jdn]. For the sunset rule, pass the JDN of
/// [liturgicalDate] (DEC-P0-24).
RiteDay riteOn(int jdn) {
  final g = jdnToGregorian(jdn);
  final c = jdnToCoptic(jdn);
  final easter = copticEasterJdn(g.year);
  final off = jdn - easter;
  final m = c.month, d = c.day;

  // Holy Week, Lazarus Saturday, Palm Sunday.
  switch (off) {
    case -8:
      return const RiteDay(
        23,
        'سبت لعازر',
        [Tune.annual],
        hours: _h36,
        alleluia: Alleluia.faiBebi,
        noteAr: 'تُقرأ النبوات في رفع بخور باكر ولا تُعمل الميطانيات',
      );
    case -7:
      return _feast(24, 'أحد الشعانين', const [
        Tune.palm,
        Tune.joyful,
      ], 'دورة الـ12 إنجيل في باكر؛ بعد التناول يُصلى الجناز العام بالنغمة الحزايني');
    case -6 || -5 || -4:
      return const RiteDay(25, 'إثنين وثلاثاء وأربعاء البصخة', [
        Tune.mourning,
      ], noteAr: 'بصخة نهارية وليلية، خمس ساعات لكل منهما');
    case -3:
      return const RiteDay(26, 'خميس العهد', [Tune.mourning], noteAr: 'تتغير النغمة إلى سنوي في اللقان والقداس فقط');
    case -2:
      return const RiteDay(27, 'الجمعة العظيمة', [Tune.mourning]);
    case -1:
      return const RiteDay(28, 'سبت الفرح (سبت النور)', [Tune.joyousSaturday]);
    case 0:
      return RiteDay(
        29,
        'عيد القيامة المجيد',
        const [Tune.joyful],
        hours: const [],
        alleluia: Alleluia.faiBebi,
        noteAr:
            'لا تُصلى الأجبية؛ يدخل الحمل أثناء لحن إبؤرو'
            '${m == 7 && d == 29 ? '؛ ويُحتفل معه بعيد البشارة (DEC-P0-23)' : ''}',
      );
    case 39:
      return _feast(31, 'عيد الصعود المجيد');
    case 49:
      return const RiteDay(
        33,
        'عيد العنصرة المجيد',
        [Tune.joyful],
        hours: [LiturgyHour.third],
        alleluia: Alleluia.faiBebi,
        noteAr: 'الساعة الثالثة فقط وبدون القطع؛ يختم اليوم بالنغمة السنوي بدايةً من مرد إنجيل السجدة الثانية',
      );
  }

  // Great fixed feasts.
  final nativity = _fixed('nativity', c.year);
  final epiphany = _fixed('epiphany', c.year);
  if (jdn == nativity) {
    return const RiteDay(
      7,
      'عيد الميلاد المجيد',
      [Tune.joyful],
      hours: [],
      alleluia: Alleluia.faiBebi,
      noteAr: 'لا تُصلى الأجبية؛ يدخل الحمل أثناء لحن إبؤرو',
    );
  }
  if (jdn == epiphany) {
    return const RiteDay(
      12,
      'عيد الغطاس المجيد',
      [Tune.joyful],
      hours: [],
      alleluia: Alleluia.faiBebi,
      noteAr: 'لقان الغطاس قبل باكر؛ لا تُصلى الأجبية؛ يدخل الحمل أثناء لحن إبؤرو',
    );
  }
  if (m == 7 && d == 29 && annunciationCelebrated(g.year, easter)) {
    return _feast(21, 'عيد البشارة المجيد');
  }
  if (off == -9) {
    return const RiteDay(
      22,
      'جمعة ختام الصوم',
      [Tune.fastingWeekend],
      hours: _hFull,
      alleluia: Alleluia.eeIkhon,
      monasteryUntilVeil: true,
      noteAr: 'صلاة القنديل بعد رفع بخور باكر',
    );
  }

  // Minor feasts and the Nativity octave.
  if (m == 1 && d >= 17 && d <= 19) return _feast(2, 'عيد الصليب', const [Tune.palm, Tune.joyful]);
  if (jdn > nativity && (m == 4 || (m == 5 && d <= 5))) return _feast(8, 'أيام عيد الميلاد');
  if (m == 5 && d == 6) return _feast(9, 'عيد الختان المجيد');
  if (m == 5 && d == 12) return _feast(13, 'ثاني أيام عيد الغطاس');
  if (m == 5 && d == 13) return _feast(14, 'عيد عرس قانا الجليل المجيد');
  if (m == 6 && d == 8) return _feast(17, 'عيد دخول السيد المسيح الهيكل');
  if (m == 7 && d == 10) return _feast(20, 'عيد الصليب', const [Tune.palm, Tune.joyful]);
  if (m == 9 && d == 24) return _feast(34, 'عيد دخول السيد المسيح أرض مصر');
  if (m == 11 && d == 5) return _annual(36, 'عيد الرسل', jdn);
  if (m == 12 && d == 13) return _feast(39, 'عيد التجلي المجيد');
  if (m == 12 && d == 16) return _annual(40, 'عيد السيدة العذراء مريم', jdn);

  // 29th of each Coptic month except Tobe and Amshir.
  if (d == 29 && m != 5 && m != 6) {
    return _feast(42, 'تذكار الأعياد الثلاثة: البشارة والميلاد والقيامة');
  }

  // Movable periods.
  if (off >= -69 && off <= -67) {
    return const RiteDay(
      16,
      'صوم نينوى',
      [Tune.fasting],
      hours: _hFull,
      alleluia: Alleluia.eeIkhon,
      monasteryUntilVeil: true,
      noteAr: 'يُقرأ سفر يونان في النبوات',
    );
  }
  if (off >= -66 && off <= -56) return _annual(18, 'من فصح نينوى إلى رفاع الصوم الكبير', jdn);
  if (off >= -55 && off <= -10) {
    return _weekend(jdn)
        ? const RiteDay(
            19,
            'الصوم الكبير',
            [Tune.fastingWeekend],
            hours: _h36,
            alleluia: Alleluia.jeEfmevi,
            noteAr: 'لا تُقرأ النبوات ولا تُعمل الميطانيات',
          )
        : const RiteDay(
            19,
            'الصوم الكبير',
            [Tune.fasting],
            hours: _hFull,
            alleluia: Alleluia.eeIkhon,
            monasteryUntilVeil: true,
          );
  }
  if (off >= 1 && off <= 38) return _feast(30, 'الخمسين المقدسة', const [Tune.joyful], 'دورة القيامة بعد الإبركسيس');
  if (off >= 40 && off <= 48)
    return _feast(32, 'الخمسين المقدسة بعد الصعود', const [Tune.joyful], 'دورة الصعود بعد الإبركسيس');
  final apostlesEnd = copticToJdn(jdnToCoptic(easter).year, 11, 4);
  if (off >= 50 && jdn <= apostlesEnd) return _fast(35, 'صوم الرسل', Tune.annual, jdn);

  // Paramouns.
  if (paramounDays(nativity).contains(jdn)) return _paramoun(6, 'برمون الميلاد', jdn);
  if (paramounDays(epiphany).contains(jdn)) return _paramoun(11, 'برمون الغطاس', jdn);

  // Fixed periods.
  if (m == 1 && d <= 16) return _feast(1, 'النيروز', const [Tune.joyful], 'ألحان ومردات عيد النيروز');
  if (m == 1 || m == 2 || (m == 3 && d <= 15)) return _annual(3, 'من 20 توت إلى 15 هاتور', jdn);
  if (m == 3) return _fast(4, 'صوم الميلاد', Tune.annual, jdn);
  if (m == 4) return _fast(5, 'شهر كيهك', Tune.kiahk, jdn);
  if (m == 5 && jdn < epiphany) return _annual(10, 'من 7 طوبة إلى برمون الغطاس', jdn);
  if (off < -69 && (m == 5 || m == 6 || m == 7)) return _annual(15, 'من 14 طوبة إلى صوم نينوى', jdn);
  if (m == 11) return _annual(37, 'من 6 أبيب إلى 30 أبيب', jdn);
  if (m == 12 && d <= 15) return _fast(38, 'صوم السيدة العذراء', Tune.annual, jdn);
  if (m == 12 || m == 13) return _annual(41, 'من 17 مسرى إلى آخر النسيء', jdn);
  throw StateError('No rite for Coptic $c (Easter offset $off)');
}
