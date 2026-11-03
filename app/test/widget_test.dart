import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ava_makar/main.dart';

Future<void> _start(WidgetTester tester, Size size) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const AvaMakarApp());
  for (var i = 0; i < 200 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2)); // staggered reveals
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shell shows the five sections and the reader opens from today’s card', (tester) async {
    await _start(tester, const Size(1200, 4000));
    for (final s in ['الرئيسية', 'الصلوات والقراءات', 'جولة في الدير', 'المكتبة والتراث', 'خدمات الدير']) {
      expect(find.text(s), findsWidgets);
    }
    expect(find.text('استكشف المكتبة'), findsOneWidget);
    await tester.ensureVisible(find.text('افتح القارئ'));
    await tester.tap(find.text('افتح القارئ'));
    await tester.pumpAndSettle();
    expect(find.text('رفع بخور عشية'), findsWidgets);
    expect(find.text('قبطي معرّب'), findsWidgets);
  });

  testWidgets('library: open a book, add to favourites, filter favourites', (tester) async {
    await _start(tester, const Size(390, 844));
    await tester.tap(find.text('استكشف المكتبة'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('بستان الرهبان').last);
    await tester.pumpAndSettle();
    expect(find.text('غلاف تصميمي بديل — ليس صورة مخطوطة'), findsOneWidget);
    await tester.ensureVisible(find.text('أضف للمفضلة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف للمفضلة'));
    await tester.pumpAndSettle();
    expect(find.text('في المفضلة'), findsOneWidget);
  });
}
