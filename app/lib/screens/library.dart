import 'package:flutter/material.dart';

import '../data/library.dart';
import '../design/book_cover.dart';
import '../design/components.dart';
import '../design/tokens.dart';
import 'home.dart' show openBook;

enum _Filter { all, book, manuscript, study, favourites }

const _filterAr = {
  _Filter.all: 'الكل',
  _Filter.book: 'كتب',
  _Filter.manuscript: 'مخطوطات',
  _Filter.study: 'دراسات',
  _Filter.favourites: 'المفضلة',
};

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.data});
  final AppData data;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _Filter filter = _Filter.all;
  String query = '';

  bool _match(LibraryItem i) {
    final ok = switch (filter) {
      _Filter.all => true,
      _Filter.book => i.type == ItemType.book,
      _Filter.manuscript => i.type == ItemType.manuscript,
      _Filter.study => i.type == ItemType.study,
      _Filter.favourites => widget.data.isFavourite(i.id),
    };
    return ok && (query.isEmpty || i.title.contains(query) || i.subtitle.contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1200 ? 6 : (w >= 900 ? 5 : (w >= 600 ? 3 : 2));
    return WalnutBackdrop(
      child: ListenableBuilder(
        listenable: widget.data,
        builder: (context, _) {
          final items = widget.data.items.where(_match).toList();
          return CustomScrollView(
            slivers: [
              SliverSafeArea(
                bottom: false,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.xl, Space.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('مكتبة الدير', style: AppText.eyebrow),
                        const Text('المكتبة والتراث', style: AppText.sectionTitle),
                        const SizedBox(height: Space.l),
                        _SearchField(onChanged: (v) => setState(() => query = v.trim())),
                        const SizedBox(height: Space.m),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final f in _Filter.values)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Space.s),
                                  child: _FilterPill(
                                    label: _filterAr[f]!,
                                    selected: filter == f,
                                    onTap: () => setState(() => filter = f),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(Space.xxl),
                    child: Text(
                      switch (filter) {
                        _Filter.manuscript => 'لم تُضف مخطوطات بعد. تُضاف من أرشيف الدير بصورها وأرقام حفظها.',
                        _Filter.study => 'لم تُضف دراسات بعد.',
                        _Filter.favourites => 'لا توجد كتب في المفضلة. افتح كتابًا واضغط «أضف للمفضلة».',
                        _ => 'لا نتائج.',
                      },
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xxxl),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: Space.xl,
                      crossAxisSpacing: Space.l,
                      childAspectRatio: 0.56,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Reveal(
                        index: i,
                        child: BookTile(
                          item: items[i],
                          heroTag: 'lib-${items[i].id}',
                          favourite: widget.data.isFavourite(items[i].id),
                          onTap: () => openBook(context, widget.data, items[i], heroTag: 'lib-${items[i].id}'),
                        ),
                      ),
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppText.body.copyWith(color: AppColors.ivory),
      decoration: InputDecoration(
        hintText: 'ابحث عن كتاب',
        hintStyle: AppText.body,
        prefixIcon: const Icon(Icons.search, color: AppColors.goldHi),
        filled: true,
        fillColor: AppColors.obsidian.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.pill),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.pill),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? Gilt.gradient : null,
          color: selected ? null : AppColors.obsidian.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: selected ? AppColors.goldHi : AppColors.hairline),
        ),
        child: Text(label, style: AppText.label.copyWith(color: selected ? AppColors.obsidian : AppColors.ivory)),
      ),
    );
  }
}
