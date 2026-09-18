import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';

/// حلقه‌ی پیشرفت نئونی با انیمیشن پرشدن و درصد وسط
class NeonProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double stroke;
  final String? caption;

  const NeonProgressRing({
    super.key,
    required this.value,
    this.size = 116,
    this.stroke = 11,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final safe = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: safe),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, stroke, t.isDark),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${faNum((v * 100).round())}٪',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w900,
                    color: t.ink,
                    height: 1.1,
                  ),
                ),
                if (caption != null)
                  Text(
                    caption!,
                    style: TextStyle(fontSize: 10.5, color: t.inkMuted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// حلقه‌ی شمارش‌معکوس تایمر — بدون انیمیشن ورودی خودکار (چون هر تیک
/// ثانیه‌شمار خودش مقدار را عوض می‌کند)، با متن دلخواه در وسط.
class NeonCountdownRing extends StatelessWidget {
  final double value; // 0..1 — کسر زمان سپری‌شده
  final double size;
  final double stroke;
  final Widget center;
  final Color? tint;

  const NeonCountdownRing({
    super.key,
    required this.value,
    required this.center,
    this.size = 240,
    this.stroke = 16,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final safe = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(safe, stroke, t.isDark, tint: tint),
        child: Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final bool isDark;
  final Color? tint;
  _RingPainter(this.value, this.stroke, this.isDark, {this.tint});

  List<Color> get _colors => tint != null
      ? [tint!, tint!.withOpacity(0.55), tint!]
      : const [
          NeonPalette.violet,
          NeonPalette.cyan,
          NeonPalette.lime,
          NeonPalette.violet,
        ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = (isDark ? Colors.white : NeonPalette.inkLight)
          .withOpacity(isDark ? 0.07 : 0.08);
    canvas.drawCircle(center, radius, track);

    if (value <= 0) return;

    final sweep = 2 * math.pi * value;
    const start = -math.pi / 2;
    final colors = _colors;

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: colors,
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep, false, glow);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: colors,
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.isDark != isDark || old.tint != tint;
}
