import 'package:flutter/material.dart';

import 'ornaments.dart';
import 'tokens.dart';

/// Leather-bound surface: real (procedural) grain, vignette, gilt hairline.
class LeatherPanel extends StatelessWidget {
  const LeatherPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.l),
    this.radius = Radii.card,
    this.corners = false,
    this.texture = Textures.leather,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool corners;
  final String texture;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: const [
          BoxShadow(color: Color(0x99000000), blurRadius: 18, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(texture, repeat: ImageRepeat.repeat, fit: BoxFit.none, scale: 1.6),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.4),
                    radius: 1.2,
                    colors: [Colors.transparent, AppColors.obsidian.withValues(alpha: 0.55)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: br,
                  border: Border.all(color: AppColors.goldHi.withValues(alpha: 0.22), width: 1),
                ),
              ),
            ),
            if (corners) ...[
              const Positioned(top: 6, right: 6, child: CornerOrnament(size: 30, quarterTurns: 1)),
              const Positioned(top: 6, left: 6, child: CornerOrnament(size: 30)),
            ],
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Subtle press feedback (scale 0.97); disabled under reduced motion.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap, this.semanticLabel});
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => down = true),
          onTapCancel: () => setState(() => down = false),
          onTapUp: (_) => setState(() => down = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: down && !reduced ? 0.97 : 1,
            duration: Motion.fast,
            curve: Motion.curve,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Primary action in aged gold. A single short sheen runs across it on press.
class GoldButton extends StatefulWidget {
  const GoldButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController sheen = AnimationController(vsync: this, duration: Motion.slow);

  @override
  void dispose() {
    sheen.dispose();
    super.dispose();
  }

  void _tap() {
    if (!Motion.reduced(context)) sheen.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: _tap,
      semanticLabel: widget.label,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: Gilt.gradient,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: AppColors.goldHi.withValues(alpha: 0.9), width: 0.8),
          boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: sheen,
                builder: (context, _) => sheen.isAnimating
                    ? Positioned.fill(
                        child: FractionalTranslation(
                          translation: Offset(-1.2 + sheen.value * 2.4, 0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.45),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: AppColors.obsidian),
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label, style: AppText.button.copyWith(color: AppColors.obsidian)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary action: hairline gilt outline on dark.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.obsidian.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: AppColors.goldHi.withValues(alpha: 0.55), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: AppColors.goldHi), const SizedBox(width: 8)],
            Text(label, style: AppText.button.copyWith(color: AppColors.goldHi)),
          ],
        ),
      ),
    );
  }
}

/// Staggered fade-and-rise on first build; instant under reduced motion.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  // The stagger is part of the animation (an Interval), so no timers are left behind.
  late final int delayMs = 70 * widget.index.clamp(0, 8);
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: Motion.slow + Duration(milliseconds: delayMs),
  );
  bool started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    Motion.reduced(context) ? c.value = 1 : c.forward();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = c.duration!.inMilliseconds;
    final a = CurvedAnimation(
      parent: c,
      curve: Interval(delayMs / total, 1, curve: Motion.curve),
    );
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(a),
        child: widget.child,
      ),
    );
  }
}

/// Small classification badge (مخطوطة، كتاب، دراسة، قبطي، عربي …).
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.onLight = false});
  final String text;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final fg = onLight ? AppColors.inkSoft : AppColors.goldHi;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: onLight ? AppColors.ink.withValues(alpha: 0.05) : AppColors.obsidian.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: fg.withValues(alpha: 0.45), width: 0.7),
      ),
      child: Text(text, style: AppText.caption.copyWith(color: fg, fontSize: 11, height: 1.4)),
    );
  }
}

/// Section heading: eyebrow, title, optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.eyebrow, required this.title, this.action, this.onAction});
  final String eyebrow;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.xxl, Space.xl, Space.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow, style: AppText.eyebrow),
                const SizedBox(height: 2),
                Text(title, style: AppText.sectionTitle),
              ],
            ),
          ),
          if (action != null)
            Pressable(
              onTap: onAction,
              semanticLabel: action,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(action!, style: AppText.label.copyWith(color: AppColors.goldHi)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Walnut page background with a soft top light — for dark screens.
class WalnutBackdrop extends StatelessWidget {
  const WalnutBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.obsidian)),
        Positioned.fill(
          child: Opacity(
            opacity: 0.35,
            child: Image.asset(Textures.walnut, repeat: ImageRepeat.repeat, fit: BoxFit.none, scale: 1.4),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.obsidian.withValues(alpha: 0.55), AppColors.obsidian.withValues(alpha: 0.85)],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
