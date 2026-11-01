import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/ornament.dart';

/// Parallel reader concept: Arabic / Arabized Coptic / Coptic, rubrics in red.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.palette, required this.data});

  final Palette palette;
  final Map<String, dynamic> data;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final shown = {'ar': true, 'cp': true, 'co': true};
  double scale = 1.0;

  static const speakers = {'priest': 'الكاهن', 'deacon': 'الشماس', 'people': 'الشعب'};
  static const columnNames = {'ar': 'عربي', 'cp': 'قبطي معرّب', 'co': 'قبطي'};

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final k = widget.data['kholagy'] as Map<String, dynamic>;
    final segs = (k['segments'] as List).cast<Map<String, dynamic>>();
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final cols = ['ar', 'cp', 'co'].where((c) => shown[c]!).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final c in columnNames.keys)
                FilterChip(
                  label: Text(columnNames[c]!, style: TextStyle(color: p.ink)),
                  selected: shown[c]!,
                  selectedColor: p.gold.withValues(alpha: 0.2),
                  checkmarkColor: p.lapis,
                  backgroundColor: p.surface,
                  side: BorderSide(color: p.line),
                  onSelected: (v) => setState(() {
                    if (!v && shown.values.where((x) => x).length == 1) return;
                    shown[c] = v;
                  }),
                ),
              IconButton(
                tooltip: 'تصغير الخط',
                onPressed: () => setState(() => scale = (scale - 0.1).clamp(0.8, 1.6)),
                icon: Icon(Icons.text_decrease, color: p.inkSoft),
              ),
              IconButton(
                tooltip: 'تكبير الخط',
                onPressed: () => setState(() => scale = (scale + 0.1).clamp(0.8, 1.6)),
                icon: Icon(Icons.text_increase, color: p.inkSoft),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Text(k['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26 * scale, fontWeight: FontWeight.w700, color: p.rubric)),
              const SizedBox(height: 10),
              Headpiece(color: p.gold),
              const SizedBox(height: 14),
              for (var i = 0; i < segs.length; i++) ...[
                Text('يقول ${speakers[segs[i]['who']] ?? ''}:',
                    style: TextStyle(fontSize: 15 * scale, color: p.rubric, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final c in cols)
                        Expanded(child: _segment(p, c, segs[i][c] as String, first: i == 0)),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [for (final c in cols) _segment(p, c, segs[i][c] as String, first: i == 0)],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: p.line, height: 1),
                ),
              ],
              Text('المصدر: ${k['source']}',
                  style: TextStyle(fontSize: 12, color: p.inkSoft)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _segment(Palette p, String col, String text, {required bool first}) {
    final coptic = col == 'co';
    final style = TextStyle(
      fontFamily: coptic ? Fonts.coptic : Fonts.arabic,
      fontSize: (coptic ? 19 : 20) * scale,
      height: coptic ? 1.7 : 1.95,
      color: col == 'cp' ? p.lapis : p.ink,
    );
    final body = first && col == 'ar'
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IlluminatedInitial(letter: text.characters.first, gold: p.gold, ink: p.rubric, fontFamily: Fonts.arabic),
              Expanded(child: Text(text.characters.skip(1).toString(), style: style)),
            ],
          )
        : Text(text, style: style, textDirection: coptic ? TextDirection.ltr : TextDirection.rtl);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(columnNames[col]!, style: TextStyle(fontSize: 11 * scale, color: p.inkSoft)),
          body,
        ],
      ),
    );
  }
}
