import 'package:flutter/material.dart';

import '../data/library.dart';
import 'ornaments.dart';
import 'tokens.dart';

/// Leather-bound cover with gilt tooling. A design placeholder, labelled as such:
/// it never imitates a manuscript photograph.
class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.item, this.large = false});
  final LibraryItem item;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final titleSize = large ? 30.0 : 19.0;
    return AspectRatio(
      aspectRatio: 0.7,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(Radii.cover), right: Radius.circular(3)),
          boxShadow: [
            BoxShadow(color: Color(0xAA000000), blurRadius: 16, offset: Offset(0, 10)),
            BoxShadow(color: Color(0x55000000), blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(Radii.cover), right: Radius.circular(3)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(Textures.leather, fit: BoxFit.cover),
              // Light falls from the upper spine side.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.3, -0.6),
                    radius: 1.3,
                    colors: [Color(0x22FFE9C0), Color(0x00000000), Color(0x99000000)],
                    stops: [0, 0.5, 1],
                  ),
                ),
              ),
              // Spine (on the right in RTL binding) with raised bands.
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: large ? 22 : 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),
              // Blind-tooled double frame.
              Padding(
                padding: EdgeInsets.fromLTRB(large ? 18 : 10, large ? 18 : 10, large ? 34 : 18, large ? 18 : 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.75), width: large ? 1.4 : 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(large ? 6 : 3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35), width: 0.7),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: large ? 14 : 8, vertical: large ? 18 : 10),
                        child: Column(
                          children: [
                            OrnamentDivider(width: large ? 140 : 70),
                            Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: large ? 220 : 110),
                                    child: ShaderMask(
                                      shaderCallback: (r) => Gilt.gradient.createShader(r),
                                      child: Text(
                                        item.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: Fonts.display,
                                          fontSize: titleSize,
                                          height: 1.35,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          shadows: const [
                                            Shadow(color: Color(0xCC000000), blurRadius: 2, offset: Offset(0, 1)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            OrnamentDivider(width: large ? 140 : 70),
                          ],
                        ),
                      ),
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

/// Cover plus caption, as shown in grids and carousels.
class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.item, required this.onTap, required this.heroTag, this.favourite = false});
  final LibraryItem item;
  final String heroTag;
  final VoidCallback onTap;
  final bool favourite;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.title,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: BookCover(item: item),
                ),
                if (favourite)
                  const Positioned(top: 6, left: 6, child: Icon(Icons.bookmark, size: 18, color: AppColors.goldHi)),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.label.copyWith(fontSize: 14)),
            Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
