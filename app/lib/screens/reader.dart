import 'package:flutter/material.dart';

import '../data/library.dart';
import '../design/ornaments.dart';
import '../design/tokens.dart';
import '../widgets/ornament.dart' show IlluminatedInitial;

/// Reading surface: calm ivory parchment or a dark candle mode. No wood or moving
/// gold behind the text. Parallel columns: Arabic / Arabized Coptic / Coptic.
class ReaderView extends StatefulWidget {
  const ReaderView({super.key, required this.data, required this.item, this.showBack = false});

  final AppData data;
  final LibraryItem item;
  final bool showBack;

  @override
  State<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<ReaderView> {
  final shown = {'ar': true, 'cp': true, 'co': true};
  double scale = 1.0;
  double leading = 1.0;
  bool candle = false;
  late final ScrollController scroll = ScrollController(initialScrollOffset: widget.data.offsetFor(widget.item.id));

  static const speakers = {'priest': 'الكاهن', 'deacon': 'الشماس', 'people': 'الشعب'};
  static const columnNames = {'ar': 'عربي', 'cp': 'قبطي معرّب', 'co': 'قبطي'};

  Color get bg => candle ? AppColors.candleBg : AppColors.parchment;
  Color get ink => candle ? AppColors.candleText : AppColors.ink;
  Color get soft => candle ? AppColors.ivorySoft : AppColors.inkSoft;
  Color get rubric => candle ? const Color(0xFFD98C84) : AppColors.rubric;
  Color get accent => candle ? AppColors.goldHi : AppColors.burgundy;

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.hasClients) widget.data.saveProgress(widget.item.id, scroll.offset);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.data.saveProgress(widget.item.id, scroll.offset));
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKholagy = widget.item.reader == 'kholagy';
    return AnimatedContainer(
      duration: Motion.medium,
      decoration: BoxDecoration(
        color: bg,
        image: candle ? null : const DecorationImage(image: AssetImage(Textures.parchment), repeat: ImageRepeat.repeat),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _toolbar(isKholagy),
            _notice(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isKholagy ? _kholagy() : _bostan(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(bool isKholagy) {
    Widget btn(String tip, IconData icon, VoidCallback onTap) => IconButton(
      tooltip: tip,
      onPressed: onTap,
      icon: Icon(icon, color: soft, size: 21),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s, Space.xs, Space.s, 0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          if (widget.showBack) btn('رجوع', Icons.arrow_back, () => Navigator.of(context).pop()),
          if (isKholagy)
            for (final c in columnNames.keys)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Semantics(
                  button: true,
                  selected: shown[c]!,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (shown[c]! && shown.values.where((x) => x).length == 1) return;
                      shown[c] = !shown[c]!;
                    }),
                    child: AnimatedContainer(
                      duration: Motion.fast,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: shown[c]! ? accent.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(Radii.pill),
                        border: Border.all(color: shown[c]! ? accent : soft.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        columnNames[c]!,
                        style: AppText.label.copyWith(color: shown[c]! ? ink : soft, fontSize: 12.5),
                      ),
                    ),
                  ),
                ),
              ),
          btn('تصغير الخط', Icons.text_decrease, () => setState(() => scale = (scale - 0.1).clamp(0.8, 1.6))),
          btn('تكبير الخط', Icons.text_increase, () => setState(() => scale = (scale + 0.1).clamp(0.8, 1.6))),
          btn(
            'تباعد السطور',
            Icons.format_line_spacing,
            () => setState(() => leading = leading >= 1.3 ? 0.9 : leading + 0.2),
          ),
          btn(
            candle ? 'وضع الرق' : 'وضع الشموع',
            candle ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
            () => setState(() => candle = !candle),
          ),
        ],
      ),
    );
  }

  Widget _notice() => Container(
    margin: const EdgeInsets.fromLTRB(Space.l, Space.xs, Space.l, 0),
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: Space.m),
    decoration: BoxDecoration(
      border: BorderDirectional(start: BorderSide(color: rubric, width: 2)),
      color: rubric.withValues(alpha: 0.06),
    ),
    child: Text('نص منقول كما هو من مصدره ولم يُراجَع بعد', style: AppText.caption.copyWith(color: rubric)),
  );

  TextStyle _text(String col) {
    final coptic = col == 'co';
    return TextStyle(
      fontFamily: coptic ? Fonts.coptic : Fonts.display,
      fontSize: (coptic ? 19 : 20.5) * scale,
      height: (coptic ? 1.7 : 1.95) * leading,
      color: col == 'cp' ? accent : ink,
    );
  }

  Widget _kholagy() {
    final k = widget.data.sample['kholagy'] as Map<String, dynamic>;
    final segs = (k['segments'] as List).cast<Map<String, dynamic>>();
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final cols = ['ar', 'cp', 'co'].where((c) => shown[c]!).toList();
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.xl, 120),
      children: [
        Text(
          k['title'] as String,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: Fonts.display, fontSize: 30 * scale, fontWeight: FontWeight.w700, color: rubric),
        ),
        const SizedBox(height: Space.s),
        Center(child: OrnamentDivider(width: 200, onLight: !candle)),
        const SizedBox(height: Space.l),
        for (var i = 0; i < segs.length; i++) ...[
          Row(
            children: [
              Text(
                'يقول ${speakers[segs[i]['who']] ?? ''}:',
                style: AppText.label.copyWith(fontSize: 14 * scale, color: rubric),
              ),
              const Spacer(),
              Text('المقطع ${i + 1} من ${segs.length}', style: AppText.caption.copyWith(color: soft)),
            ],
          ),
          const SizedBox(height: Space.s),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final c in cols) Expanded(child: _segment(c, segs[i][c] as String, first: i == 0))],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final c in cols) _segment(c, segs[i][c] as String, first: i == 0)],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.l),
            child: Divider(color: soft.withValues(alpha: 0.25), height: 1),
          ),
        ],
        Text('المصدر: ${k['source']}', style: AppText.caption.copyWith(color: soft)),
      ],
    );
  }

  Widget _segment(String col, String text, {required bool first}) {
    final coptic = col == 'co';
    final style = _text(col);
    final body = first && col == 'ar'
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IlluminatedInitial(
                letter: text.characters.first,
                gold: candle ? AppColors.gold : AppColors.goldDeep,
                ink: rubric,
                fontFamily: Fonts.display,
              ),
              Expanded(child: Text(text.characters.skip(1).toString(), style: style)),
            ],
          )
        : Text(text, style: style, textDirection: coptic ? TextDirection.ltr : TextDirection.rtl);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            columnNames[col]!,
            style: AppText.caption.copyWith(color: soft, fontSize: 11 * scale),
          ),
          body,
        ],
      ),
    );
  }

  Widget _bostan() {
    final b = widget.data.sample['bostan'] as Map<String, dynamic>;
    final para = b['paragraph'] as Map<String, dynamic>;
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.xl, 120),
      children: [
        Text(
          widget.item.title,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: Fonts.display, fontSize: 30 * scale, fontWeight: FontWeight.w700, color: rubric),
        ),
        Text(
          b['section'] as String,
          textAlign: TextAlign.center,
          style: AppText.label.copyWith(color: soft),
        ),
        const SizedBox(height: Space.s),
        Center(child: OrnamentDivider(width: 200, onLight: !candle)),
        const SizedBox(height: Space.xl),
        Text(
          (para['text'] as String).trim(),
          style: TextStyle(fontFamily: Fonts.display, fontSize: 20.5 * scale, height: 2.0 * leading, color: ink),
        ),
        const SizedBox(height: Space.xl),
        Text('الفقرة ${para['id']} — المصدر: ${b['source']}', style: AppText.caption.copyWith(color: soft)),
      ],
    );
  }
}

/// Reader opened as its own page (from the library or «continue reading»).
class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key, required this.data, required this.item});
  final AppData data;
  final LibraryItem item;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ReaderView(data: data, item: item, showBack: true),
  );
}
