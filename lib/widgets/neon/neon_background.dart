import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart'; // AppColors, NeonPalette

/// پس‌زمینه‌ی «فلز مایع نئونی»: پایه‌ی گان‌متال + خط‌های برس‌شده‌ی مورب
/// + یک نوار نور شناور (specular sweep) + شفق‌های نئونی رنگی + نویز شبکه‌ای.
/// یک‌بار در ریشه‌ی اپ قرار می‌گیرد و همه‌ی صفحه‌ها روی آن شناورند.
class NeonBackground extends StatefulWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});

  @override
  State<NeonBackground> createState() => _NeonBackgroundState();
}

class _NeonBackgroundState extends State<NeonBackground>
    with TickerProviderStateMixin {
  late final AnimationController _aurora = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat();

  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _aurora.dispose();
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        // پس‌زمینه‌ی تخت و تیره — مطابق پالت رسمی (بدون گرادیان بنفش)
        color: isDark ? AppColors.surfaceBase : const Color(0xFFF4F4F6),
      ),
      child: Stack(
        children: [
          // شفق‌های نئونی رنگی — بسیار کم‌رنگ، فقط برای عمق ظریف
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.10 : 0.06,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _aurora,
                  builder: (_, __) => CustomPaint(
                      painter: _AuroraPainter(_aurora.value, isDark)),
                ),
              ),
            ),
          ),
          // برس فلزی مورب — خیلی محو، فقط بافت ظریف
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: CustomPaint(painter: _BrushedMetalPainter(isDark)),
                ),
              ),
            ),
          ),
          // نوار نور شناور — محو
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sheen,
                  builder: (_, __) =>
                      CustomPaint(painter: _SheenPainter(_sheen.value, isDark)),
                ),
              ),
            ),
          ),
          // شبکه‌ی ظریف + وینیت
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GridPainter(isDark)),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  final bool isDark;
  _AuroraPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = <_Blob>[
      _Blob(NeonPalette.violet, 0.22, 0.16, 0.52, 0.0),
      _Blob(NeonPalette.cyan, 0.84, 0.28, 0.40, 0.35),
      _Blob(NeonPalette.magenta, 0.72, 0.84, 0.46, 0.62),
      _Blob(NeonPalette.indigo, 0.16, 0.74, 0.38, 0.85),
    ];

    for (final b in blobs) {
      final phase = (t + b.phase) * 2 * math.pi;
      final dx = math.cos(phase) * size.width * 0.09;
      final dy = math.sin(phase * 0.8) * size.height * 0.06;
      final radius = size.width * b.scale * (0.86 + 0.14 * math.sin(phase));

      final paint = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 95)
        ..shader = RadialGradient(
          colors: [
            b.color.withOpacity(isDark ? 0.34 : 0.24),
            b.color.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * b.x + dx, size.height * b.y + dy),
            radius: radius,
          ),
        );

      canvas.drawCircle(
        Offset(size.width * b.x + dx, size.height * b.y + dy),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.isDark != isDark;
}

class _Blob {
  final Color color;
  final double x, y, scale, phase;
  _Blob(this.color, this.x, this.y, this.scale, this.phase);
}

/// خط‌های نامنظم مورب — بافت فلز برس‌خورده (brushed metal)
class _BrushedMetalPainter extends CustomPainter {
  final bool isDark;
  _BrushedMetalPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7); // ثابت، تا هر فریم یکسان بماند
    final baseOpacity = isDark ? 0.05 : 0.045;
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(-0.42); // مورب ۲۴ درجه‌ای
    canvas.translate(-size.width * 0.5, -size.height * 0.5);

    final diag = size.width + size.height;
    double x = -size.height.toDouble();
    while (x < diag) {
      final w = 0.6 + rnd.nextDouble() * 1.8;
      final o = baseOpacity * (0.4 + rnd.nextDouble() * 0.9);
      final paint = Paint()
        ..color = (isDark ? Colors.white : NeonPalette.inkLight).withOpacity(o)
        ..strokeWidth = w;
      canvas.drawLine(
        Offset(x, -size.height),
        Offset(x, size.height * 2),
        paint,
      );
      x += 2.4 + rnd.nextDouble() * 4.5;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrushedMetalPainter old) =>
      old.isDark != isDark;
}

/// نوار نور مورب شناور — مثل انعکاس نور روی سطح فلزی صیقلی
class _SheenPainter extends CustomPainter {
  final double t; // 0..1
  final bool isDark;
  _SheenPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final diag = size.width + size.height;
    // موقعیت نوار از گوشه‌ای به گوشه‌ی دیگر، با یک وقفه‌ی نامحسوس
    final travel = (t < 0.6) ? (t / 0.6) : 1.0;
    final pos = -diag * 0.3 + travel * diag * 1.3;

    canvas.save();
    canvas.translate(size.width, 0);
    canvas.rotate(0.52);

    final band = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(isDark ? 0.05 : 0.10),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(pos - 90, -diag, 180, diag * 2));

    canvas.drawRect(Rect.fromLTWH(pos - 90, -diag, 180, diag * 2), band);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SheenPainter old) =>
      old.t != t || old.isDark != isDark;
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : NeonPalette.violet)
          .withOpacity(isDark ? 0.020 : 0.028)
      ..strokeWidth = 1;

    const step = 34.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // وینیت ملایم برای عمق بیشتر
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          (isDark ? Colors.black : NeonPalette.inkLight)
              .withOpacity(isDark ? 0.38 : 0.05),
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.isDark != isDark;
}

/// یک هاله‌ی نئونی ملایم که پشت هر ویجتی می‌نشیند.
class NeonHalo extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blur;
  final double opacity;

  const NeonHalo({
    super.key,
    required this.child,
    this.color = NeonPalette.violet,
    this.blur = 40,
    this.opacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  heightFactor: 0.7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(opacity),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
