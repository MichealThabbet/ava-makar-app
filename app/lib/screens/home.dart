import 'package:coptic_calendar/coptic_calendar.dart';
import 'package:flutter/material.dart';

import '../data/library.dart';
import '../design/book_cover.dart';
import '../design/components.dart';
import '../design/ornaments.dart';
import '../design/tokens.dart';
import 'book_detail.dart';
import 'reader.dart';
import 'search.dart';

const copticMonthsAr = [
  'توت', 'بابه', 'هاتور', 'كيهك', 'طوبه', 'أمشير', 'برمهات', //
  'برموده', 'بشنس', 'بؤونه', 'أبيب', 'مسرى', 'النسيء',
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.data, required this.onGoTo});

  final AppData data;

  /// Switches the bottom-bar section (1 prayers, 2 tour, 3 library, 4 services).
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    final bostan = data.sample['bostan'] as Map<String, dynamic>;
    final saying = (bostan['paragraph'] as Map<String, dynamic>)['text'] as String;
    final last = data.lastReadId;

    return WalnutBackdrop(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Hero(onGoTo: onGoTo, data: data),
          ),
          SliverToBoxAdapter(
            child: Reveal(
              index: 1,
              child: SectionHeader(eyebrow: 'استكشف', title: 'أبواب الدير الرقمية'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Space.l),
            sliver: SliverToBoxAdapter(
              child: Reveal(index: 2, child: _ExploreGrid(onGoTo: onGoTo)),
            ),
          ),
          if (last != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.l, Space.l, Space.l, 0),
                child: Reveal(
                  index: 3,
                  child: _ContinueReading(data: data, item: data.byId(last)),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SectionHeader(
              eyebrow: 'من رفوف المكتبة',
              title: 'مختارات المكتبة',
              action: 'كل الكتب',
              onAction: () => onGoTo(3),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 268,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Space.xl),
                itemCount: data.items.length,
                separatorBuilder: (_, _) => const SizedBox(width: Space.l),
                itemBuilder: (context, i) => SizedBox(
                  width: 144,
                  child: BookTile(
                    item: data.items[i],
                    heroTag: 'home-${data.items[i].id}',
                    favourite: data.isFavourite(data.items[i].id),
                    onTap: () => openBook(context, data, data.items[i], heroTag: 'home-${data.items[i].id}'),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(eyebrow: 'من بستان الرهبان', title: 'قول اليوم'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.l),
              child: _SayingCard(
                section: bostan['section'] as String,
                text: saying,
                onRead: () => openReader(context, data, data.byId('bostan')),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(eyebrow: 'التقويم القبطي', title: 'اليوم الطقسي'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.l),
              child: _TodayCard(onOpenReader: () => onGoTo(1)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.xl, Space.xxxl, Space.xl, Space.xl),
              child: Column(
                children: [
                  const OrnamentDivider(),
                  const SizedBox(height: Space.m),
                  Text(
                    'نسخة عرض للتصميم — النصوص منقولة كما هي من مصادرها ولم تُراجَع بعد',
                    textAlign: TextAlign.center,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onGoTo, required this.data});
  final ValueChanged<int> onGoTo;
  final AppData data;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final h = (size.height * 0.82).clamp(520.0, 760.0);
    final wide = size.width >= 900;
    return SizedBox(
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Stone composition until the monastery supplies a real photograph
          // (see docs/design/DESIGN_SYSTEM.md, «Hero photograph»).
          Image.asset(Textures.sandstone, fit: BoxFit.cover, alignment: Alignment.topCenter),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB314110F), Color(0x6614110F), Color(0xE614110F), AppColors.obsidian],
                stops: [0, 0.3, 0.72, 1],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: wide ? 0.45 : 0.86,
              heightFactor: 0.78,
              child: CustomPaint(painter: ArchFramePainter()),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.l, Space.s, Space.l, 0),
                child: Row(
                  children: [
                    const MonasteryMark(size: 34),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('دير القديس أنبا مقار', style: AppText.label, overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      tooltip: 'بحث',
                      onPressed: () => openSearch(context, data),
                      icon: const Icon(Icons.search, color: AppColors.goldHi),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: Space.xl,
            right: Space.xl,
            bottom: Space.xxl,
            child: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('برية شيهيت · وادي النطرون', style: AppText.eyebrow),
                  const SizedBox(height: Space.s),
                  Text('دير القديس العظيم\nأنبا مقار', style: AppText.heroTitle.copyWith(fontSize: wide ? 60 : 44)),
                  const SizedBox(height: Space.m),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: const Text(
                      'مكتبة الدير الرقمية: الصلوات والقراءات وتراث الآباء، ودليل لزيارة الدير.',
                      style: AppText.lead,
                    ),
                  ),
                  const SizedBox(height: Space.xl),
                  Wrap(
                    spacing: Space.m,
                    runSpacing: Space.m,
                    children: [
                      GoldButton(
                        label: 'استكشف المكتبة',
                        icon: Icons.auto_stories_outlined,
                        onPressed: () => onGoTo(3),
                      ),
                      GhostButton(label: 'جولة في الدير', icon: Icons.explore_outlined, onPressed: () => onGoTo(2)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid({required this.onGoTo});
  final ValueChanged<int> onGoTo;

  static const tiles = [
    (1, Icons.menu_book_outlined, 'الصلوات والقراءات', 'الخولاجي والقراءات بالعربي والقبطي'),
    (3, Icons.local_library_outlined, 'المكتبة والتراث', 'كتب الكنيسة وتراث الآباء'),
    (2, Icons.account_balance_outlined, 'جولة في الدير', 'مسار بين كنائس الدير ومعالمه'),
    (4, Icons.volunteer_activism_outlined, 'خدمات الدير', 'الزيارة والخلوة والتواصل'),
  ];

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.sizeOf(context).width >= 900 ? 4 : 2;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: Space.m,
      crossAxisSpacing: Space.m,
      childAspectRatio: cols == 4 ? 1.35 : 0.95,
      children: [
        for (final t in tiles)
          Pressable(
            onTap: () => onGoTo(t.$1),
            semanticLabel: t.$3,
            child: LeatherPanel(
              corners: true,
              padding: const EdgeInsets.fromLTRB(Space.l, Space.xl, Space.l, Space.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(t.$2, color: AppColors.goldHi, size: 26),
                  const Spacer(),
                  Text(t.$3, style: AppText.cardTitle.copyWith(fontSize: 19)),
                  const SizedBox(height: 2),
                  Text(t.$4, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.caption),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ContinueReading extends StatelessWidget {
  const _ContinueReading({required this.data, required this.item});
  final AppData data;
  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => openReader(context, data, item),
      semanticLabel: 'تابع القراءة: ${item.title}',
      child: LeatherPanel(
        texture: Textures.walnut,
        padding: const EdgeInsets.all(Space.m),
        child: Row(
          children: [
            SizedBox(width: 48, child: BookCover(item: item)),
            const SizedBox(width: Space.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تابع القراءة', style: AppText.eyebrow),
                  Text(item.title, style: AppText.cardTitle.copyWith(fontSize: 18)),
                  Text(item.subtitle, style: AppText.caption),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.goldHi),
          ],
        ),
      ),
    );
  }
}

class _SayingCard extends StatelessWidget {
  const _SayingCard({required this.section, required this.text, required this.onRead});
  final String section;
  final String text;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.card),
        image: const DecorationImage(image: AssetImage(Textures.parchment), repeat: ImageRepeat.repeat),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 18, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.xl, Space.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(section, style: AppText.eyebrow.copyWith(color: AppColors.rubric)),
          const SizedBox(height: Space.s),
          Text(
            text.trim(),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: Fonts.display, fontSize: 19, height: 1.9, color: AppColors.ink),
          ),
          const SizedBox(height: Space.m),
          const Center(child: OrnamentDivider(width: 160, onLight: true)),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onRead,
              child: Text('اقرأ القول كاملًا', style: AppText.button.copyWith(color: AppColors.burgundy)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.onOpenReader});
  final VoidCallback onOpenReader;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final g = liturgicalDate(now); // sunset rule with 18:00 fallback (DEC-P0-24)
    final jdn = gregorianToJdn(g.year, g.month, g.day);
    final c = jdnToCoptic(jdn);
    final rite = riteOn(jdn);
    final fast = fastOn(jdn);
    final tunes = rite.tunes.map((t) => tuneNamesAr[t]).join(' و');
    return LeatherPanel(
      corners: true,
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.xxl, Space.xl, Space.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${c.day} ${copticMonthsAr[c.month - 1]} ${c.year} للشهداء',
            style: AppText.cardTitle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: Space.xs),
          Text(rite.nameAr, style: AppText.body.copyWith(color: AppColors.goldHi)),
          const SizedBox(height: Space.m),
          Wrap(
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              Tag('النغمة: $tunes'),
              if (fast != null) Tag(fastNamesAr[fast]!),
              if (now.hour >= 18) const Tag('بعد الغروب: اليوم الطقسي التالي'),
            ],
          ),
          const SizedBox(height: Space.m),
          Text('صلاة اليوم: رفع بخور عشية', style: AppText.body),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onOpenReader,
              child: Text('افتح القارئ', style: AppText.button.copyWith(color: AppColors.goldHi)),
            ),
          ),
        ],
      ),
    );
  }
}

void openBook(BuildContext context, AppData data, LibraryItem item, {String? heroTag}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: Motion.reduced(context) ? Duration.zero : Motion.medium,
      reverseTransitionDuration: Motion.reduced(context) ? Duration.zero : Motion.medium,
      pageBuilder: (_, _, _) => BookDetailScreen(data: data, item: item, heroTag: heroTag ?? 'detail-${item.id}'),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

void openReader(BuildContext context, AppData data, LibraryItem item) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReaderPage(data: data, item: item),
    ),
  );
}
