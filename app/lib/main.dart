import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home.dart';
import 'screens/reader.dart';
import 'screens/tour.dart';
import 'theme.dart';

void main() => runApp(const AvaMakarApp());

class AvaMakarApp extends StatefulWidget {
  const AvaMakarApp({super.key});

  @override
  State<AvaMakarApp> createState() => _AvaMakarAppState();
}

class _AvaMakarAppState extends State<AvaMakarApp> {
  bool candle = false;

  @override
  Widget build(BuildContext context) {
    final palette = candle ? Palette.candle : Palette.parchment;
    return MaterialApp(
      title: 'دير القديس أنبا مقار',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildTheme(palette, candle ? Brightness.dark : Brightness.light),
      home: Shell(
        palette: palette,
        candle: candle,
        onToggleCandle: () => setState(() => candle = !candle),
      ),
    );
  }
}

class PreviewData {
  PreviewData(this.raw);
  final Map<String, dynamic> raw;

  static Future<PreviewData> load() async {
    final s = await rootBundle.loadString('assets/data/preview_sample.json');
    return PreviewData(jsonDecode(s) as Map<String, dynamic>);
  }
}

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.palette,
    required this.candle,
    required this.onToggleCandle,
  });

  final Palette palette;
  final bool candle;
  final VoidCallback onToggleCandle;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  late final Future<PreviewData> data = PreviewData.load();

  static const sections = [
    (Icons.home_outlined, 'الرئيسية'),
    (Icons.menu_book_outlined, 'الصلوات والقراءات'),
    (Icons.account_balance_outlined, 'جولة في الدير'),
    (Icons.local_library_outlined, 'المكتبة والتراث'),
    (Icons.volunteer_activism_outlined, 'خدمات الدير'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return FutureBuilder<PreviewData>(
      future: data,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator(color: p.gold)));
        }
        final d = snap.data!;
        final pages = [
          HomeScreen(palette: p, data: d.raw, onOpenReader: () => setState(() => index = 1)),
          ReaderScreen(palette: p, data: d.raw),
          TourScreen(palette: p),
          _Placeholder(palette: p, title: 'المكتبة والتراث والإصدارات'),
          _Placeholder(palette: p, title: 'خدمات الدير'),
        ];
        return Scaffold(
          appBar: AppBar(
            backgroundColor: p.background,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Text('دير القديس العظيم أنبا مقار',
                style: TextStyle(color: p.ink, fontSize: 19, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                tooltip: widget.candle ? 'وضع الرق' : 'وضع الشموع',
                icon: Icon(widget.candle ? Icons.wb_sunny_outlined : Icons.local_fire_department_outlined,
                    color: p.gold),
                onPressed: widget.onToggleCandle,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: p.line),
            ),
          ),
          body: Column(
            children: [
              _PreviewBanner(palette: p),
              Expanded(child: pages[index]),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: p.surface,
            indicatorColor: p.gold.withValues(alpha: 0.18),
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final s in sections)
                NavigationDestination(
                  icon: Icon(s.$1, color: p.inkSoft),
                  selectedIcon: Icon(s.$1, color: p.lapis),
                  label: s.$2,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner({required this.palette});
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: palette.rubric.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Text(
        'نسخة عرض للتصميم — النصوص منقولة كما هي من المصادر ولم تُراجَع بعد',
        textAlign: TextAlign.center,
        style: TextStyle(color: palette.rubric, fontSize: 13),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.palette, required this.title});
  final Palette palette;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$title\nقيد الإنشاء',
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.inkSoft, fontSize: 18, height: 1.8)),
    );
  }
}
