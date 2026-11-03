import 'package:flutter/material.dart';

import '../data/library.dart';
import '../design/book_cover.dart';
import '../design/components.dart';
import '../design/ornaments.dart';
import '../design/tokens.dart';
import 'home.dart' show openReader;

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.data, required this.item, required this.heroTag});
  final AppData data;
  final LibraryItem item;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: WalnutBackdrop(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: data,
            builder: (context, _) {
              final fav = data.isFavourite(item.id);
              final cover = Hero(
                tag: heroTag,
                child: BookCover(item: item, large: true),
              );
              final info = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemTypeAr[item.type]!, style: AppText.eyebrow),
                  const SizedBox(height: Space.xs),
                  Text(item.title, style: AppText.heroTitle.copyWith(fontSize: 36)),
                  Text(item.subtitle, style: AppText.lead),
                  const SizedBox(height: Space.l),
                  Wrap(spacing: Space.s, runSpacing: Space.s, children: [for (final b in item.badges) Tag(b)]),
                  const SizedBox(height: Space.xl),
                  const OrnamentDivider(),
                  const SizedBox(height: Space.l),
                  _Meta('المصدر', item.source),
                  if (item.shelfMark != null) _Meta('رقم الحفظ', item.shelfMark!),
                  if (item.holdingLibrary != null) _Meta('المكتبة الحافظة', item.holdingLibrary!),
                  _Meta(
                    'الحالة',
                    item.readable ? 'عينة متاحة للقراءة — لم تُراجَع بعد' : 'النص قيد الاستيراد والمراجعة',
                  ),
                  _Meta('الغلاف', 'غلاف تصميمي بديل — ليس صورة مخطوطة'),
                  const SizedBox(height: Space.xl),
                  Wrap(
                    spacing: Space.m,
                    runSpacing: Space.m,
                    children: [
                      if (item.readable)
                        GoldButton(
                          label: 'اقرأ',
                          icon: Icons.chrome_reader_mode_outlined,
                          onPressed: () => openReader(context, data, item),
                        ),
                      GhostButton(
                        label: fav ? 'في المفضلة' : 'أضف للمفضلة',
                        icon: fav ? Icons.bookmark : Icons.bookmark_border,
                        onPressed: () => data.toggleFavourite(item.id),
                      ),
                    ],
                  ),
                ],
              );
              return ListView(
                padding: const EdgeInsets.fromLTRB(Space.xl, Space.s, Space.xl, Space.xxxl),
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      tooltip: 'رجوع',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.goldHi),
                    ),
                  ),
                  const SizedBox(height: Space.m),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 320, child: cover),
                        const SizedBox(width: Space.xxxl),
                        Expanded(child: info),
                      ],
                    )
                  else ...[
                    Center(child: SizedBox(width: 230, child: cover)),
                    const SizedBox(height: Space.xxl),
                    info,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Space.m),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: AppText.caption.copyWith(color: AppColors.goldHi)),
        ),
        Expanded(child: Text(value, style: AppText.body.copyWith(fontSize: 14))),
      ],
    ),
  );
}
