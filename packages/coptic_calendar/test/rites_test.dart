import 'package:coptic_calendar/coptic_calendar.dart';
import 'package:test/test.dart';

int j(int y, int m, int d) => gregorianToJdn(y, m, d);

void main() {
  group('Liturgical periods (official rites page)', () {
    test('every day 1901–2099 resolves and all 42 sections occur', () {
      final seen = <int>{};
      for (var jdn = j(1901, 1, 1); jdn <= j(2099, 12, 31); jdn++) {
        final r = riteOn(jdn);
        expect(r.section, inInclusiveRange(1, 42));
        expect(r.tunes, isNotEmpty);
        seen.add(r.section);
      }
      expect(seen, {for (var i = 1; i <= 42; i++) i});
    });

    test('Holy Fifty is joyful; Lent weekdays to Compline with إي إي إيخون; Holy Week has no Liturgy hours', () {
      for (var y = 1990; y <= 2100; y++) {
        final e = copticEasterJdn(y);
        for (var o = 1; o <= 48; o++) {
          expect(riteOn(e + o).tunes.first, Tune.joyful, reason: '$y +$o');
        }
        for (var o = -55; o <= -10; o++) {
          final r = riteOn(e + o);
          if (r.section != 19) continue; // feast or 29th inside Lent
          final weekend = weekdayOfJdn(e + o) >= 5;
          expect(r.alleluia, weekend ? Alleluia.jeEfmevi : Alleluia.eeIkhon, reason: '$y $o');
          expect(r.monasteryUntilVeil, !weekend);
        }
        for (var o = -6; o <= -1; o++) {
          expect(riteOn(e + o).hours, isNull, reason: '$y $o');
          expect(riteOn(e + o).section, inInclusiveRange(25, 28));
        }
        expect(riteOn(e).hours, isEmpty);
        expect(riteOn(e + 49).hours, [LiturgyHour.third]);
      }
    });

    test('annual Wednesday/Friday to the 9th; fasts relax on Saturday/Sunday', () {
      // 2026-11-02 = 23 Paopi 1743, Monday; 2026-11-04 Wednesday.
      expect(riteOn(j(2026, 11, 2)).section, 3);
      expect(riteOn(j(2026, 11, 2)).hours, [LiturgyHour.third, LiturgyHour.sixth]);
      expect(riteOn(j(2026, 11, 4)).alleluia, Alleluia.jeEfmevi);
      // Kiahk 2026: 13 Dec Sunday, 14 Dec Monday.
      expect(riteOn(j(2026, 12, 13)).tunes, [Tune.kiahk]);
      expect(riteOn(j(2026, 12, 13)).alleluia, Alleluia.faiBebi);
      expect(riteOn(j(2026, 12, 14)).hours!.length, 3);
    });

    test('Annunciation follows DEC-P0-23; Nativity and Epiphany pray no Agpeya', () {
      for (var y = 1990; y <= 2100; y++) {
        final e = copticEasterJdn(y);
        final a = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == 'annunciation'), y);
        final r = riteOn(j(a.year, a.month, a.day));
        final onEaster = j(a.year, a.month, a.day) == e;
        expect(r.section == (onEaster ? 29 : 21), annunciationCelebrated(y, e), reason: '$y');
        if (onEaster) expect(r.noteAr, contains('البشارة'));
        for (final id in ['nativity', 'epiphany']) {
          final d = fixedFeastIn(fixedFeasts.firstWhere((f) => f.id == id), y);
          expect(riteOn(j(d.year, d.month, d.day)).hours, isEmpty, reason: '$id $y');
        }
      }
    });
  });
}
