import 'dart:convert';
import 'dart:io';

import 'package:coptic_calendar/coptic_calendar.dart';
import 'package:test/test.dart';

/// Rows of the 2016–2030 church agenda (third-party table, see fixture source note).
class AgendaRow {
  AgendaRow(List<String> c)
      : weekday = c[0],
        g = CalendarDate(int.parse(c[1]), int.parse(c[2]), int.parse(c[3])),
        c = CalendarDate(int.parse(c[4]), int.parse(c[5]), int.parse(c[6])),
        event = c[7];
  final String weekday;
  final CalendarDate g;
  final CalendarDate c;
  final String event;
}

List<AgendaRow> loadAgenda() {
  final lines = File('test/fixtures/agenda_2015_2030.csv').readAsLinesSync().skip(1);
  return [
    for (final l in lines)
      if (l.trim().isNotEmpty) AgendaRow(_csv(l)),
  ];
}

List<String> _csv(String line) {
  final out = <String>[];
  final buf = StringBuffer();
  var quoted = false;
  for (final ch in line.split('')) {
    if (ch == '"') {
      quoted = !quoted;
    } else if (ch == ',' && !quoted) {
      out.add(buf.toString());
      buf.clear();
    } else {
      buf.write(ch);
    }
  }
  out.add(buf.toString());
  return out;
}

void main() {
  group('Gregorian', () {
    test('matches DateTime for every day 1900-01-01 … 2100-12-31', () {
      var day = DateTime.utc(1900, 1, 1);
      final base = gregorianToJdn(1900, 1, 1);
      var i = 0;
      while (day.year <= 2100) {
        final jdn = gregorianToJdn(day.year, day.month, day.day);
        expect(jdn, base + i);
        expect(jdnToGregorian(jdn), CalendarDate(day.year, day.month, day.day));
        expect(weekdayOfJdn(jdn), day.weekday - 1);
        day = day.add(const Duration(days: 1));
        i++;
      }
    });
  });

  group('Julian', () {
    test('is 13 days behind Gregorian from 1900-03-01 to 2100-02-28', () {
      for (var jdn = gregorianToJdn(1900, 3, 1); jdn <= gregorianToJdn(2100, 2, 28); jdn++) {
        final j = jdnToJulian(jdn);
        expect(julianToJdn(j.year, j.month, j.day), jdn);
        final g = jdnToGregorian(jdn);
        expect(gregorianToJdn(g.year, g.month, g.day) - julianToJdn(g.year, g.month, g.day), -13);
      }
    });
  });

  group('Coptic', () {
    test('round-trips every day of years 1600–1900 and month lengths are 30 / 5–6', () {
      for (var y = 1600; y <= 1900; y++) {
        var prev = copticToJdn(y, 1, 1) - 1;
        for (var m = 1; m <= 13; m++) {
          for (var d = 1; d <= copticMonthLength(y, m); d++) {
            final jdn = copticToJdn(y, m, d);
            expect(jdn, prev + 1);
            expect(jdnToCoptic(jdn), CalendarDate(y, m, d));
            prev = jdn;
          }
        }
        expect(copticToJdn(y + 1, 1, 1), prev + 1);
      }
    });

    test('Nasie has 6 days only when year % 4 == 3', () {
      expect(copticMonthLength(1739, 13), 6);
      expect(copticMonthLength(1740, 13), 5);
      expect(() => copticToJdn(1740, 13, 6), throwsArgumentError);
    });

    test('1 Thout falls on 11 September, or 12 September before a Gregorian leap year (1901–2099)', () {
      for (var gy = 1901; gy <= 2099; gy++) {
        final cy = gy - 283;
        final g = copticToGregorian(CalendarDate(cy, 1, 1));
        final nextIsLeap = (gy + 1) % 4 == 0;
        expect(g, CalendarDate(gy, 9, nextIsLeap ? 12 : 11), reason: 'Coptic year $cy');
      }
    });
  });

  group('Agenda 2016–2030 (third-party table)', () {
    final rows = loadAgenda();

    test('fixture loaded', () => expect(rows.length, greaterThan(400)));

    // Coptic-column typos in the agenda. In both rows the Gregorian date is
    // confirmed by the movable-day test (Ascension = Easter+39, Thomas = Easter+7),
    // so the engine's Coptic date stands. Any other mismatch fails the build.
    const knownAgendaErrata = {
      '2018-05-17', // agenda 29 Bashans 1734, correct 9 Bashans
      '2022-05-01', // agenda 24 Bashans 1738, correct 23 Paremoude
    };

    test('every Gregorian ↔ Coptic pair converts exactly (except listed errata)', () {
      final bad = <String>[];
      final errataSeen = <String>{};
      for (final r in rows) {
        if (gregorianToCoptic(r.g) == r.c) continue;
        if (knownAgendaErrata.contains('${r.g}')) {
          errataSeen.add('${r.g}');
        } else {
          bad.add('${r.g} → ${gregorianToCoptic(r.g)} (agenda ${r.c}) ${r.event}');
        }
      }
      expect(bad, isEmpty, reason: bad.take(10).join('\n'));
      expect(errataSeen, knownAgendaErrata);
    });

    test('agenda weekday labels (report only)', () {
      const names = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
      final off = [
        for (final r in rows)
          if (names[weekdayOfJdn(gregorianToJdn(r.g.year, r.g.month, r.g.day))] !=
              r.weekday.replaceAll('الإثنين', 'الاثنين').replaceAll('الاربعاء', 'الأربعاء'))
            '${r.g} ${r.weekday}',
      ];
      printOnFailure('weekday label mismatches: ${off.length}');
      // ignore: avoid_print
      print('agenda weekday label mismatches: ${off.length} ${off.take(5).toList()}');
    });

    test('every Easter equals both methods', () {
      final easters = rows.where((r) => r.event.contains('عيد القيامة'));
      expect(easters.length, greaterThanOrEqualTo(14));
      for (final r in easters) {
        expect(copticEaster(r.g.year), r.g, reason: r.event);
      }
    });

    test('movable days match the agenda', () {
      final byName = {for (final m in movableDays) m.nameAr: m};
      var checked = 0;
      final bad = <String>[];
      for (final r in rows) {
        final m = byName[r.event];
        if (m == null) continue;
        checked++;
        final got = movableDaysFor(r.g.year)[m.id];
        if (got != r.g) bad.add('${r.event} ${r.g.year}: engine $got agenda ${r.g}');
      }
      expect(checked, greaterThan(100));
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });

  group('Easter', () {
    test('methods A and B agree for years 1–4000', () {
      for (var y = 1; y <= 4000; y++) {
        expect(julianEasterMeeus(y), julianEasterGauss(y), reason: 'year $y');
      }
    });

    test('is a Sunday between 4 April and 8 May (Gregorian) for 1900–2099', () {
      for (var y = 1900; y <= 2099; y++) {
        final jdn = copticEasterJdn(y);
        expect(weekdayOfJdn(jdn), 6, reason: 'year $y');
        final g = jdnToGregorian(jdn);
        expect(jdn, inInclusiveRange(gregorianToJdn(y, 4, 4), gregorianToJdn(y, 5, 8)), reason: '$g');
      }
    });
  });

  group('Third-party Easter tables and vectors', () {
    test('method C agrees with A/B for 1583–4099', () {
      for (var y = 1583; y <= 4099; y++) {
        final c = orthodoxEasterTondering(y);
        expect(gregorianToJdn(c.year, c.month, c.day), copticEasterJdn(y), reason: 'year $y');
      }
    });

    test('Eastern Easter 2020–2070 table (51 years)', () {
      final lines = File('test/fixtures/easter_eastern_2020_2070.csv').readAsLinesSync().skip(1);
      var n = 0;
      for (final l in lines.where((l) => l.trim().isNotEmpty)) {
        final p = l.split(',').map(int.parse).toList();
        expect(copticEaster(p[0]), CalendarDate(p[0], p[1], p[2]), reason: l);
        n++;
      }
      expect(n, 51);
    });

    test('kiahk test vectors: conversions, Easter, movable and fixed feasts', () {
      final v = jsonDecode(File('test/fixtures/kiahk_test_vectors.json').readAsStringSync()) as Map;
      CalendarDate d(Map m) => CalendarDate(m['year'] as int, m['month'] as int, m['day'] as int);
      for (final r in v['gregorian_to_coptic'] as List) {
        expect(gregorianToCoptic(d(r['gregorian'] as Map)), d(r['coptic'] as Map));
      }
      for (final r in v['coptic_to_gregorian'] as List) {
        expect(copticToGregorian(d(r['coptic'] as Map)), d(r['gregorian'] as Map));
      }
      for (final r in v['easter'] as List) {
        expect(copticEaster(r['gregorian_year'] as int), d(r['date'] as Map));
      }
      const ids = {'nineveh_fast': 'nineveh_fast_start'};
      for (final r in v['moveable_feasts'] as List) {
        final id = ids[r['feast_id']] ?? r['feast_id'] as String;
        expect(movableDaysFor(r['gregorian_year'] as int)[id], d(r['date'] as Map), reason: '$id');
      }
      for (final r in v['fixed_feasts'] as List) {
        final f = fixedFeasts.firstWhere((x) => x.id == r['feast_id']);
        expect(fixedFeastIn(f, r['gregorian_year'] as int), d(r['date'] as Map), reason: '${f.id} ${r['gregorian_year']}');
      }
      for (final r in v['invalid_coptic_dates'] as List) {
        expect(() => copticToJdn(r['year'] as int, r['month'] as int, r['day'] as int), throwsArgumentError);
      }
    });

    test('Nativity is 7 January every year 1901–2099', () {
      final nativity = fixedFeasts.firstWhere((f) => f.id == 'nativity');
      for (var y = 1901; y <= 2099; y++) {
        expect(fixedFeastIn(nativity, y), CalendarDate(y, 1, 7), reason: 'year $y');
      }
    });

    test('fixed feasts match the 2016–2030 agenda where named', () {
      final rows = loadAgenda();
      var checked = 0;
      final bad = <String>[];
      for (final f in fixedFeasts) {
        for (final r in rows.where((r) => r.event.contains(f.nameAr.split(' (').first))) {
          checked++;
          final got = fixedFeastIn(f, r.g.year);
          if (got != r.g) bad.add('${f.id} ${r.g.year}: engine $got agenda ${r.g}');
        }
      }
      expect(checked, greaterThan(50));
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  });

  group('Traditional epact table 1997–2056 (owner research v2)', () {
    final rows = File('test/fixtures/epact_1997_2056.csv')
        .readAsLinesSync()
        .skip(1)
        .where((l) => l.trim().isNotEmpty)
        .map((l) => l.replaceAll('\uFEFF', '').split(','))
        .toList();

    CalendarDate iso(String s) {
      final p = s.split('-').map(int.parse).toList();
      return CalendarDate(p[0], p[1], p[2]);
    }

    test('60 years: epacts, Easter, movable days and Coptic date of Easter', () {
      expect(rows.length, 60);
      for (final r in rows) {
        final y = int.parse(r[0]);
        final am = int.parse(r[1]);
        final e = epactsForCopticYear(am);
        expect([e.solarCycle, e.solarEpact, e.lunarCycle, e.lunarEpact],
            [int.parse(r[2]), int.parse(r[3]), int.parse(r[4]), int.parse(r[5])], reason: 'year $y');
        final m = movableDaysFor(y);
        expect(m['easter'], iso(r[7]), reason: 'Easter $y');
        expect(m['great_lent_start'], iso(r[8]));
        expect(m['palm_sunday'], iso(r[9]));
        expect(m['covenant_thursday'], iso(r[10]));
        expect(m['good_friday'], iso(r[11]));
        expect(m['thomas_sunday'], iso(r[12]));
        expect(m['ascension'], iso(r[13]));
        expect(m['pentecost'], iso(r[14]));
        final c = r[15].split('/').map(int.parse).toList();
        expect(gregorianToCoptic(m['easter']!), CalendarDate(c[2], c[1], c[0]), reason: 'Coptic date $y');
        expect(gregorianToCoptic(m['easter']!).year, am);
      }
    });
  });

  group('Method D — traditional epact Easter (Bahman)', () {
    test('book example: AM 1705 → Passover 17 Barmouda, Easter 22 Barmouda, 1 Thout on Sunday', () {
      final e = epactsForCopticYear(1705);
      expect([e.solarCycle, e.solarEpact, e.lunarCycle, e.lunarEpact], [21, 5, 13, 23]);
      expect(thoutWeekday(e), 6);
      expect(traditionalPassover(1705), const CalendarDate(1705, 8, 17));
      expect(traditionalEaster(1705), const CalendarDate(1705, 8, 22));
    });

    test('1 Thout weekday from the solar epact equals the computed weekday (AM 1600–1900)', () {
      for (var am = 1600; am <= 1900; am++) {
        expect(thoutWeekday(epactsForCopticYear(am)), weekdayOfJdn(copticToJdn(am, 1, 1)), reason: 'AM $am');
      }
    });

    test('method D equals methods A–C for Gregorian 1584–4099', () {
      for (var y = 1584; y <= 4099; y++) {
        final d = traditionalEaster(y - 284);
        expect(copticToJdn(d.year, d.month, d.day), copticEasterJdn(y), reason: 'year $y');
      }
    });

    test('Apostles fast length (rule) equals Pentecost Monday … 4 Epip (engine), 1901–2099', () {
      for (var y = 1901; y <= 2099; y++) {
        final easter = gregorianToCoptic(copticEaster(y));
        final start = copticEasterJdn(y) + 50;
        final end = copticToJdn(easter.year, 11, 4);
        expect(end - start + 1, apostlesFastDaysTraditional(easter), reason: 'year $y');
      }
    });

    test('book example: rafaa of Nineveh 12 Amshir and of Great Lent 26 Amshir for Easter 22 Barmouda 1705', () {
      final easter = copticToJdn(1705, 8, 22);
      expect(jdnToCoptic(easter - 70), const CalendarDate(1705, 6, 12));
      expect(jdnToCoptic(easter - 56), const CalendarDate(1705, 6, 26));
      expect(jdnToCoptic(easter + 39), const CalendarDate(1705, 10, 1));
      expect(jdnToCoptic(easter + 49), const CalendarDate(1705, 10, 11));
    });
  });

  group('Published table — Coptic Diocese of the Midlands (UK), 2022–2027', () {
    test('every date matches except the documented diocese errata', () {
      const ids = ['nineveh_fast_start', 'great_lent_start', 'easter', 'ascension', 'pentecost', 'apostles_fast_start'];
      final lines = File('test/fixtures/midlands_diocese_2022_2027.csv').readAsLinesSync().skip(1).where((l) => l.trim().isNotEmpty);
      final mismatches = <String>{};
      var checked = 0;
      for (final l in lines) {
        final c = l.split(',');
        final y = int.parse(c[0]);
        final m = movableDaysFor(y);
        for (var i = 0; i < ids.length; i++) {
          final p = c[i + 1].split('-').map(int.parse).toList();
          checked++;
          if (m[ids[i]] != CalendarDate(p[0], p[1], p[2])) mismatches.add('$y ${ids[i]}');
        }
      }
      expect(checked, 36);
      // Diocese errata: the 2025 row is one day early from Easter on (Saturday 19 April);
      // 2022 lists Nineveh as 13–15 Feb (Sunday–Tuesday) while Lent 28 Feb and Easter 24 Apr
      // on the same row give Monday 14 Feb.
      expect(mismatches, {
        '2025 easter', '2025 ascension', '2025 pentecost', '2025 apostles_fast_start', '2022 nineveh_fast_start',
      });
    });
  });

  group('Published calendar — Diocese of the Southern US deacons, 2020–2100 (ICS)', () {
    const movable = {
      "Jonah's (Nineveh) Fast Begins": 'nineveh_fast_start',
      "Jonah's (Nineveh) Feast": 'nineveh_passover',
      'Holy Great Fast Begins': 'great_lent_start',
      'Lazarus Saturday': 'lazarus_saturday',
      'Entry of our Lord into Jerusalem (Hosanna Sunday)': 'palm_sunday',
      'Holy Pascha Begins': 'pascha_start',
      'Holy Pascha': 'pascha_start',
      'Covenant Thursday': 'covenant_thursday',
      'Good Friday': 'good_friday',
      'Glorious Feast of the Resurrection': 'easter',
      'Thomas’ Sunday': 'thomas_sunday',
      'The Holy Feast of Ascension': 'ascension',
      'The Holy Pentecost Feast': 'pentecost',
      "The Apostles' Fast Begins": 'apostles_fast_start',
    };
    const fixed = {
      'The Nayrouz Feast (Coptic New Year)': 'nayrouz',
      'The Feast of the Cross (Three days)': 'cross',
      'The Holy Nativity Fast Begins': 'nativity_fast_start',
      'The Holy Nativity Feast': 'nativity',
      'The Circumcision Feast': 'circumcision',
      'The Holy Epiphany': 'epiphany',
      'Feast of the Wedding of Cana of Galilee': 'cana',
      'Presentation of the Lord into the Temple': 'presentation',
      'The Feast of the Cross': 'cross_apparition',
      'Annunciation Feast': 'annunciation',
      'Annunciation Feast (Not celebrated this year)': 'annunciation',
      'Martyrdom of St. Mark the Evangelist': 'st_mark_martyrdom',
      'Entry of the Lord into Egypt': 'entry_into_egypt',
      "The Apostles' Feast (Martyrdom of St. Peter & St. Paul)": 'apostles_martyrdom',
      "St. Mary's Fast Begins": 'virgin_fast_start',
      'Transfiguration Feast': 'transfiguration',
      "Assumption of St. Mary's Body": 'assumption',
    };

    test('2,343 events: every movable and fixed date matches except documented calendar errata', () {
      final lines = File('test/fixtures/suscopts_deacons_2020_2100.csv').readAsLinesSync().skip(1).where((l) => l.trim().isNotEmpty);
      var checked = 0;
      final bad = <String>[];
      for (final l in lines) {
        final i = l.indexOf(',');
        final p = l.substring(0, i).split('-').map(int.parse).toList();
        var summary = l.substring(i + 1);
        if (summary.startsWith('"')) summary = summary.substring(1, summary.length - 1).replaceAll('""', '"');
        final date = CalendarDate(p[0], p[1], p[2]);
        CalendarDate? expected;
        if (movable.containsKey(summary)) {
          expected = movableDaysFor(date.year)[movable[summary]];
        } else if (fixed.containsKey(summary)) {
          expected = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == fixed[summary]), date.year);
        }
        expect(expected, isNotNull, reason: 'unmapped: $summary');
        checked++;
        if (expected != date) bad.add('$date $summary (engine $expected)');
      }
      expect(checked, 2343);
      // Calendar errata, all explained (33 of 2,343):
      //  • Coptic year 1800 (Sep 2083 – Sep 2084): the calendar starts it on 11 Sep 2083, but
      //    AM 1799 is a 6-day-Nasie year so 1 Thout 1800 is 12 Sep 2083 (13 fixed days, all 1 day early);
      //  • 2100: the calendar keeps the 13-day Julian offset after 28 Feb 2100; Gregorian 2100 is not a
      //    leap year, so the offset becomes 14 days (18 events from March 2100 on, all 1 day early);
      //  • two isolated typos: 2069 Cross (three days) on 29 Sep; 2095 «Holy Pascha Begins» on Wednesday.
      final yearShift1800 = bad.where((b) => b.startsWith('2083-') || b.startsWith('2084-')).length;
      final century2100 = bad.where((b) => b.startsWith('2100-')).length;
      final isolated = bad.where((b) => !b.startsWith('2083-') && !b.startsWith('2084-') && !b.startsWith('2100-')).toList();
      expect([yearShift1800, century2100], [13, 18], reason: bad.where((b) => b.startsWith('2100-')).join('\n'));
      expect(isolated, [
        '2069-09-29 The Feast of the Cross (Three days) (engine 2069-09-27)',
        '2095-04-20 Holy Pascha Begins (engine 2095-04-18)',
      ]);
      for (final b in bad.where((b) => !isolated.contains(b))) {
        final dates = RegExp(r'(\d{4})-(\d\d)-(\d\d)').allMatches(b).toList();
        DateTime d(RegExpMatch m) => DateTime.utc(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
        expect(d(dates[1]).difference(d(dates[0])).inDays, 1, reason: b);
      }
    });
  });

  group('Annunciation not celebrated in Palm Sunday / Holy Week (DEC-P0-23)', () {
    test('engine rule vs Southern US deacons calendar 2020–2100', () {
      final lines = File('test/fixtures/suscopts_deacons_2020_2100.csv').readAsLinesSync().skip(1);
      final differ = <String>[];
      for (final l in lines.where((l) => l.contains('Annunciation'))) {
        final y = int.parse(l.substring(0, 4));
        final calendarSaysCelebrated = !l.contains('Not celebrated');
        final engine = annunciationCelebrated(y, copticEasterJdn(y));
        if (engine != calendarSaysCelebrated) {
          final a = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == 'annunciation'), y);
          differ.add('$y offset ${gregorianToJdn(a.year, a.month, a.day) - copticEasterJdn(y)}');
        }
      }
      // All five are calendar errata under DEC-P0-23:
      //  −9 (Friday ending Lent) and 0 (Easter Day): celebrated — the suppression window is
      //  Lazarus Saturday … Joyous Saturday only, and the Coptic rite does not transfer feasts;
      //  2058 at −7 (Palm Sunday): not celebrated, as the same calendar has it in 2069/2080.
      expect(differ.toSet(), {
        '2023 offset -9', '2028 offset -9', '2075 offset 0', '2086 offset 0', '2058 offset -7',
      });
    });
  });

  group('Fasts (official rites page)', () {
    test('paramoun: 1 day, Sunday feast → Fri–Sat, Monday feast → Fri–Sun', () {
      for (var y = 1990; y <= 2100; y++) {
        for (final id in ['nativity', 'epiphany']) {
          final d = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == id), y);
          final feast = gregorianToJdn(d.year, d.month, d.day);
          final p = paramounDays(feast);
          final wd = weekdayOfJdn(feast);
          expect(p.length, wd == 6 ? 2 : (wd == 0 ? 3 : 1), reason: '$id $y');
          expect(p.last, feast - 1);
          if (p.length > 1) expect(weekdayOfJdn(p.first), 4, reason: 'starts Friday');
        }
      }
    });

    test('season lengths 1990–2100: Nineveh 3, Lent 55, Virgin 15, Apostles = Bahman rule, no fast in the Holy Fifty', () {
      for (var y = 1990; y <= 2100; y++) {
        final e = copticEasterJdn(y);
        int count(Fast f, int from, int to) => [for (var j = from; j <= to; j++) j].where((j) => fastOn(j) == f).length;
        expect(count(Fast.nineveh, e - 80, e - 56), 3, reason: 'Nineveh $y');
        expect(count(Fast.greatLent, e - 60, e), 55, reason: 'Lent $y');
        expect([for (var j = e; j <= e + 49; j++) fastOn(j)].whereType<Fast>(), isEmpty, reason: 'Fifty $y');
        final eC = gregorianToCoptic(jdnToGregorian(e));
        expect(count(Fast.apostles, e + 50, e + 110), apostlesFastDaysTraditional(eC), reason: 'Apostles $y');
        final mesra1 = copticToJdn(eC.year, 12, 1);
        expect(count(Fast.virgin, mesra1 - 2, mesra1 + 20), 15, reason: 'Virgin $y');
      }
    });

    test('Nativity and Epiphany break Wednesday/Friday; Nativity fast runs 16 Hatour to the paramoun', () {
      for (var y = 1990; y <= 2100; y++) {
        for (final id in ['nativity', 'epiphany']) {
          final d = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == id), y);
          expect(fastOn(gregorianToJdn(d.year, d.month, d.day)), isNull, reason: '$id $y');
        }
        final start = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == 'nativity_fast_start'), y);
        final s = gregorianToJdn(start.year, start.month, start.day);
        expect(fastOn(s), Fast.nativity, reason: 'start $y');
        expect(fastOn(s - 1) == Fast.nativity, isFalse);
      }
    });
  });

  group('Liturgical day starts at sunset (DEC-P0-24)', () {
    test('before the cutoff it is today, from the cutoff on it is tomorrow', () {
      expect(liturgicalDate(DateTime(2026, 11, 6, 17, 59)), const CalendarDate(2026, 11, 6));
      expect(liturgicalDate(DateTime(2026, 11, 6, 18, 0)), const CalendarDate(2026, 11, 7));
      expect(liturgicalDate(DateTime(2026, 11, 6, 23, 59)), const CalendarDate(2026, 11, 7));
      expect(liturgicalDate(DateTime(2026, 11, 7, 0, 30)), const CalendarDate(2026, 11, 7));
    });

    test('a supplied sunset replaces the fixed cutoff; month and year roll over', () {
      final sunset = DateTime(2026, 12, 31, 17, 6);
      expect(liturgicalDate(DateTime(2026, 12, 31, 17, 5), sunset: sunset), const CalendarDate(2026, 12, 31));
      expect(liturgicalDate(DateTime(2026, 12, 31, 17, 6), sunset: sunset), const CalendarDate(2027, 1, 1));
    });

    test('Coptic date of the evening is the next Coptic day (eve of Nayrouz)', () {
      // 10 Sep 2026 evening (after 18:00) → 1 Thout 1743 (11 Sep 2026).
      expect(liturgicalCopticDate(DateTime(2026, 9, 10, 19)), const CalendarDate(1743, 1, 1));
    });
  });
}
