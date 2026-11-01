import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ava_makar/main.dart';

void main() {
  testWidgets('shell shows the five sections and the reader opens', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const AvaMakarApp());
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الصلوات والقراءات'), findsOneWidget);
    expect(find.text('جولة في الدير'), findsOneWidget);
    expect(find.text('المكتبة والتراث'), findsOneWidget);
    expect(find.text('خدمات الدير'), findsOneWidget);

    await tester.tap(find.text('افتح القارئ'));
    await tester.pumpAndSettle();
    expect(find.text('رفع بخور عشية'), findsWidgets);
    expect(find.text('قبطي معرّب'), findsWidgets);
  });
}
