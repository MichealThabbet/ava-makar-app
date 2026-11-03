import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/library.dart';
import 'design/tokens.dart';
import 'screens/home.dart';
import 'screens/library.dart';
import 'screens/reader.dart';
import 'screens/services.dart';
import 'screens/tour.dart';

void main() => runApp(const AvaMakarApp());

class AvaMakarApp extends StatelessWidget {
  const AvaMakarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دير القديس أنبا مقار',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildTheme(),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  late final Future<AppData> data = AppData.load();

  static const sections = [
    (Icons.home_outlined, Icons.home, 'الرئيسية'),
    (Icons.menu_book_outlined, Icons.menu_book, 'الصلوات والقراءات'),
    (Icons.account_balance_outlined, Icons.account_balance, 'جولة في الدير'),
    (Icons.local_library_outlined, Icons.local_library, 'المكتبة والتراث'),
    (Icons.volunteer_activism_outlined, Icons.volunteer_activism, 'خدمات الدير'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final t in [Textures.leather, Textures.walnut, Textures.sandstone, Textures.parchment]) {
      precacheImage(AssetImage(t), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppData>(
      future: data,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            body: Center(child: Text('تعذّر تحميل البيانات: ${snap.error}', style: AppText.body)),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final d = snap.data!;
        final pages = [
          HomeScreen(data: d, onGoTo: (i) => setState(() => index = i)),
          ReaderView(data: d, item: d.byId('kholagy')),
          const TourScreen(),
          LibraryScreen(data: d),
          const ServicesScreen(),
        ];
        return Scaffold(
          body: ListenableBuilder(
            listenable: d,
            builder: (_, _) => IndexedStack(index: index, children: pages),
          ),
          bottomNavigationBar: _BottomBar(index: index, onTap: (i) => setState(() => index = i)),
        );
      },
    );
  }
}

/// Quiet walnut bar; the active item is marked in aged gold. Respects the
/// iPhone home-indicator inset and never covers content (it is the scaffold's bar).
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.obsidian,
        border: Border(top: BorderSide(color: AppColors.hairline)),
        image: DecorationImage(
          image: AssetImage(Textures.walnut),
          repeat: ImageRepeat.repeat,
          opacity: 0.25,
          scale: 1.4,
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _ShellState.sections.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == index,
                    button: true,
                    child: InkResponse(
                      onTap: () => onTap(i),
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: Motion.fast,
                            width: i == index ? 22 : 0,
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: const BoxDecoration(gradient: Gilt.gradient),
                          ),
                          Icon(
                            i == index ? _ShellState.sections[i].$2 : _ShellState.sections[i].$1,
                            size: 22,
                            color: i == index ? AppColors.goldHi : AppColors.ivorySoft,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _ShellState.sections[i].$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption.copyWith(
                              fontSize: 10.5,
                              color: i == index ? AppColors.goldHi : AppColors.ivorySoft,
                              fontWeight: i == index ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
