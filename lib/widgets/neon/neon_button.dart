import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// دکمه‌ی اصلی: گرادیان نئونی + گلو + فشرده‌شدن لمسی + حالت لودینگ
class NeonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final Gradient gradient;
  final Color glowColor;
  final double height;
  final bool expand;

  const NeonButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.gradient = NeonPalette.brand,
    this.glowColor = NeonPalette.violet,
    this.height = 54,
    this.expand = true,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;

    return AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.55,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown:
              enabled ? (_) => setState(() => _down = true) : null,
          onTapCancel: () {
            if (mounted) setState(() => _down = false);
          },
          onTapUp: (_) {
            if (mounted) setState(() => _down = false);
          },
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  widget.onPressed!.call();
                }
              : null,
          child: Container(
            width: widget.expand ? double.infinity : null,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(enabled ? 0.45 : 0.15),
                  blurRadius: 26,
                  spreadRadius: -6,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                // جلای فلزی بالای دکمه (شبیه نور روی فلز صیقلی)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.55,
                          widthFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.30),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: widget.loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: Colors.white, size: 19),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
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
    );
  }
}

/// دکمه‌ی ثانویه (شیشه‌ای با حاشیه‌ی نئونی)
class NeonOutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final double height;

  const NeonOutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = NeonPalette.cyan,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: color.withOpacity(t.isDark ? 0.08 : 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: color.withOpacity(0.55)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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

/// دکمه‌ی شناور «+» با هاله‌ی تپنده
class NeonFab extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const NeonFab({super.key, required this.onPressed, this.icon = Icons.add_rounded});

  @override
  State<NeonFab> createState() => _NeonFabState();
}

class _NeonFabState extends State<NeonFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = 0.30 + _c.value * 0.35;
        return Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: NeonPalette.brand,
            boxShadow: [
              BoxShadow(
                color: NeonPalette.violet.withOpacity(v),
                blurRadius: 30 + _c.value * 12,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: NeonPalette.cyan.withOpacity(v * 0.6),
                blurRadius: 40,
                spreadRadius: -8,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onPressed();
          },
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
