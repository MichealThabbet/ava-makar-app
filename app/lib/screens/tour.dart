import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/ornaments.dart';
import '../design/tokens.dart';

/// «مرشدك»: route of stations; map and positioning arrive in P4.
class TourScreen extends StatelessWidget {
  const TourScreen({super.key});

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
    return WalnutBackdrop(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.xl, Space.xxxl),
          children: [
            const Text('مرشدك', style: AppText.eyebrow),
            const Text('جولة في الدير', style: AppText.sectionTitle),
            const SizedBox(height: Space.xs),
            const Text(
              'مسار تجريبي — الترتيب النهائي يعتمده الدير. الخريطة وتحديد الموقع في المرحلة P4.',
              style: AppText.body,
            ),
            const SizedBox(height: Space.xl),
            for (var i = 0; i < stations.length; i++)
              Reveal(
                index: i,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: i == 0 ? Gilt.gradient : null,
                              color: i == 0 ? null : AppColors.obsidian,
                              border: Border.all(color: AppColors.gold, width: 1.2),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: AppText.label.copyWith(
                                color: i == 0 ? AppColors.obsidian : AppColors.goldHi,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (i < stations.length - 1)
                            Expanded(child: Container(width: 1, color: AppColors.gold.withValues(alpha: 0.5))),
                        ],
                      ),
                      const SizedBox(width: Space.l),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: Space.l),
                          child: LeatherPanel(
                            padding: const EdgeInsets.symmetric(horizontal: Space.l, vertical: Space.m),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stations[i], style: AppText.cardTitle.copyWith(fontSize: 19)),
                                Text(i == 0 ? 'نقطة البداية' : 'المحطة ${i + 1}', style: AppText.caption),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: Space.l),
            const Center(child: OrnamentDivider()),
          ],
        ),
      ),
    );
  }
}
