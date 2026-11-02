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
}
