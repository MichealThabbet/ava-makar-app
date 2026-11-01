import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ornament.dart';

/// «مرشدك» concept: route of stations; map and positioning arrive in P4.
class TourScreen extends StatelessWidget {
  const TourScreen({super.key, required this.palette});
  final Palette palette;

  // Station names from the approved section list (Blueprint 03.xx); route order is a placeholder
  // until the monastery approves the visitor route.
  static const stations = [
    'كنيسة القديس أنبا مقار',
    'كنيسة أبا سخيرون القليني',
    'كنيسة الشهداء التسعة والأربعين',
    'الحصن',
    'المائدة',
    'متحف الدير',
  ];

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Text('مرشدك', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: p.ink)),
        Text('مسار تجريبي — الترتيب النهائي يعتمده الدير',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: p.inkSoft)),
        const SizedBox(height: 14),
        Headpiece(color: p.gold),
        const SizedBox(height: 18),
        for (var i = 0; i < stations.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == 0 ? p.gold : p.surface,
                      border: Border.all(color: p.gold, width: 1.4),
                    ),
                    child: Text('${i + 1}',
                        style: TextStyle(color: i == 0 ? p.background : p.ink, fontWeight: FontWeight.w700)),
                  ),
                  if (i < stations.length - 1) Container(width: 1.4, height: 46, color: p.line),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stations[i], style: TextStyle(fontSize: 19, color: p.ink, fontWeight: FontWeight.w700)),
                      Text(i == 0 ? 'أنت هنا — امشِ للأمام قليلًا' : 'المحطة التالية',
                          style: TextStyle(fontSize: 14, color: i == 0 ? p.rubric : p.inkSoft)),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
