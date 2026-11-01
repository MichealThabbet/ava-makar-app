import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ornament.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.palette, required this.data, required this.onOpenReader});

  final Palette palette;
  final Map<String, dynamic> data;
  final VoidCallback onOpenReader;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final bostan = data['bostan'] as Map<String, dynamic>;
    final saying = (bostan['paragraph'] as Map<String, dynamic>)['text'] as String;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Center(child: CrossMark(color: p.gold, size: 28)),
        const SizedBox(height: 10),
        Text('يومك مع دير أنبا مقار',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: p.ink)),
        const SizedBox(height: 4),
        Text('التاريخ القبطي يُحسب من محرك التقويم في المرحلة P1',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: p.inkSoft)),
        const SizedBox(height: 16),
        Headpiece(color: p.gold),
        const SizedBox(height: 16),
        _Card(
          palette: p,
          title: 'قول اليوم — بستان الرهبان',
          subtitle: bostan['section'] as String,
          footer: bostan['source'] as String,
          child: Text(saying,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 19, height: 1.9, color: p.ink)),
        ),
        _Card(
          palette: p,
          title: 'صلاة اليوم',
          subtitle: 'رفع بخور عشية',
          action: TextButton(
            onPressed: onOpenReader,
            child: Text('افتح القارئ', style: TextStyle(color: p.lapis, fontSize: 17)),
          ),
          child: Text('القارئ المتوازي: عربي / قبطي معرّب / قبطي، والتعليمات بالأحمر كما في الكتب الطقسية.',
              style: TextStyle(fontSize: 17, height: 1.8, color: p.inkSoft)),
        ),
        _Card(
          palette: p,
          title: 'مرشدك',
          subtitle: 'جولة داخل دير أبو مقار',
          child: Text('جولة موجهة بالمكان والصوت بين معالم الدير — المرحلة P4.',
              style: TextStyle(fontSize: 17, height: 1.8, color: p.inkSoft)),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.action,
  });

  final Palette palette;
  final String title;
  final String subtitle;
  final Widget child;
  final String? footer;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.line),
        boxShadow: [BoxShadow(color: p.ink.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: p.rubric, letterSpacing: 0.2)),
          Text(subtitle, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: p.ink)),
          const SizedBox(height: 10),
          child,
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(footer!, style: TextStyle(fontSize: 12, color: p.inkSoft)),
          ],
          if (action != null) Align(alignment: AlignmentDirectional.centerEnd, child: action),
        ],
      ),
    );
  }
}
