import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/ornaments.dart';
import '../design/tokens.dart';

/// Monastery services: not built yet; shown honestly as such.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WalnutBackdrop(
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: LeatherPanel(
                corners: true,
                padding: const EdgeInsets.fromLTRB(Space.xl, Space.xxxl, Space.xl, Space.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    MonasteryMark(size: 44),
                    SizedBox(height: Space.l),
                    Text('خدمات الدير', style: AppText.sectionTitle),
                    SizedBox(height: Space.s),
                    Text(
                      'الزيارة والخلوة والإصدارات والتواصل — قيد الإنشاء.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    SizedBox(height: Space.l),
                    OrnamentDivider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
