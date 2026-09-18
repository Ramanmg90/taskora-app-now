import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// لبه‌ی بِول فلزی: یک قاب گرادیانی روشن→تیره که دور هر GlassCard کشیده
/// می‌شود تا حس «پنل فلز صیقلی» بدهد. تماس‌ها از زیرش رد می‌شوند.
class MetalBevelPainter extends CustomPainter {
  final double radius;
  final double width;
  final Color highlight;
  final Color shadow;
  final Color? tint;

  MetalBevelPainter({
    required this.radius,
    required this.width,
    required this.highlight,
    required this.shadow,
    this.tint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      width / 2,
      width / 2,
      size.width - width,
      size.height - width,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final hi = tint != null ? Color.lerp(highlight, tint, 0.35)! : highlight;
    final lo = tint != null ? Color.lerp(shadow, tint, 0.20)! : shadow;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [hi, lo.withOpacity(lo.opacity * 0.55), lo],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant MetalBevelPainter old) =>
      old.radius != radius ||
      old.highlight != highlight ||
      old.shadow != shadow ||
      old.tint != tint;
}

/// کارت شیشه‌ای پایه‌ی کل دیزاین‌سیستم.
/// بلور واقعی (BackdropFilter) + لبه‌ی بِول فلزی + گلوی رنگی اختیاری.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final Color? glow;
  final double glowOpacity;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool dense;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = AppRadius.md,
    this.blur = 18,
    this.glow,
    this.glowOpacity = 0.28,
    this.onTap,
    this.onLongPress,
    this.dense = false,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final radius = BorderRadius.circular(widget.radius);

    Widget content = Stack(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [t.glassTop, t.glassBottom],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: radius,
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  onHighlightChanged: (v) => setState(() => _pressed = v),
                  child: Padding(
                    padding: widget.dense
                        ? const EdgeInsets.all(12)
                        : widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: MetalBevelPainter(
                radius: widget.radius,
                width: 1.3,
                highlight: t.metalHighlight,
                shadow: t.metalShadow,
                tint: widget.glow,
              ),
            ),
          ),
        ),
      ],
    );

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: widget.glow != null
              ? t.glow(widget.glow!, opacity: widget.glowOpacity)
              : t.softShadow,
        ),
        child: content,
      ),
    );
  }
}

/// نوار بالای صفحه به‌صورت شیشه‌ای (جایگزین AppBar).
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;
  final Widget? leading;

  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBack = false,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: SizedBox(
          height: 58,
          child: GlassCard(
            radius: AppRadius.lg,
            blur: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                if (showBack)
                  _RoundGlassButton(
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  )
                else if (leading != null)
                  leading!
                else
                  const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: t.ink,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: t.inkMuted),
                        ),
                    ],
                  ),
                ),
                if (actions.isEmpty)
                  const SizedBox(width: 40)
                else
                  Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundGlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GlassIconButton(icon: icon, onTap: onTap);
}

/// دکمه‌ی آیکونی گرد شیشه‌ای با لبه‌ی فلزی
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 40,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final c = color ?? t.ink;
    final button = SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Material(
            color: t.isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.55),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Icon(icon, size: size * 0.46, color: c),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: MetalBevelPainter(
                  radius: size / 2,
                  width: 1.1,
                  highlight: t.metalHighlight,
                  shadow: t.metalShadow,
                  tint: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// چیپ نئونی (فیلترها، دسته‌بندی‌ها، اولویت‌ها)
class NeonChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final IconData? icon;

  const NeonChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = NeonPalette.violet,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [color.withOpacity(0.95), color.withOpacity(0.55)],
              )
            : null,
        color: selected
            ? null
            : (t.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.55)),
        border: Border.all(
          color: selected ? color.withOpacity(0.9) : t.glassBorder,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.40),
                  blurRadius: 18,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: selected ? Colors.white : t.inkMuted,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : t.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// برچسب کوچک نئونی (اولویت / وضعیت / دسته)
class NeonTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const NeonTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withOpacity(0.45), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// عنوان بخش با خط نئونی کنارش
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailingText;
  final Color color;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailingText,
    this.color = NeonPalette.cyan,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 2),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.7),
                  blurRadius: 12,
                  spreadRadius: -1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: t.ink,
            ),
          ),
          const Spacer(),
          if (trailingText != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailingText!,
                style: TextStyle(fontSize: 11.5, color: t.inkMuted),
              ),
            ),
        ],
      ),
    );
  }
}
