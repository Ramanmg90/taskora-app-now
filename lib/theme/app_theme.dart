import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// ─────────────────────────────────────────────────────────────
///  Taskora · Neon Glassmorphism Design System
///  همه‌ی رنگ‌ها، گرادیان‌ها، شعاع‌ها و گلوها از اینجا می‌آیند.
/// ─────────────────────────────────────────────────────────────

/// ─────────────────────────────────────────────────────────────
///  پالت رسمی تسکورا — دقیقاً همان ۱۱ رنگی که کارفرما تعیین کرده.
///  هیچ رنگ دیگری در اپ استفاده نمی‌شود؛ همه‌ی نام‌های قدیمی
///  (violet/indigo/cyan/…) روی همین‌ها نگاشت شده‌اند تا بقیه‌ی
///  فایل‌ها بدون تغییر گسترده، پالت جدید را بگیرند.
class AppColors {
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFC0C0C6);
  static const Color textFaint = Color(0xFF6E6E75);
  static const Color surfaceCard = Color(0xFF2E2E35);
  static const Color surfaceBase = Color(0xFF1E1E22);
  static const Color border = Color(0xFF40404A);

  static const Color green = Color(0xFF22C55E);
  static const Color blue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFFA855F7);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color teal = Color(0xFF00D4AA);
}

class NeonPalette {
  // رنگ‌های برند — نگاشت‌شده روی پالت رسمی
  static const Color violet = AppColors.green; // رنگ اصلی/برند
  static const Color indigo = AppColors.blue;
  static const Color cyan = AppColors.teal;
  static const Color magenta = AppColors.purple;
  static const Color lime = AppColors.green;
  static const Color amber = AppColors.coral;
  static const Color rose = AppColors.coral;

  // پس‌زمینه‌های تیره
  static const Color abyss = AppColors.surfaceBase;
  static const Color deep = AppColors.surfaceBase;
  static const Color night = AppColors.surfaceCard;

  // پس‌زمینه‌های روشن (فقط برای سازگاری تم روشن)
  static const Color mist = Color(0xFFF4F4F6);
  static const Color cloud = Color(0xFFE9E9EC);

  static const Color inkDark = AppColors.textPrimary;
  static const Color inkLight = Color(0xFF1E1E22);

  /// گرادیان اصلی برند
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [teal, blue],
  );

  static const Color teal = AppColors.teal;
  static const Color blue = AppColors.blue;

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [green, teal],
  );

  static const Color green = AppColors.green;

  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [coral, purple],
  );

  static const Color coral = AppColors.coral;
  static const Color purple = AppColors.purple;
}

/// توکن‌های وابسته به تم (تیره / روشن)
class NeonTokens {
  final bool isDark;
  const NeonTokens(this.isDark);

  static NeonTokens of(BuildContext context) =>
      NeonTokens(Theme.of(context).brightness == Brightness.dark);

  Color get ink => isDark ? AppColors.textPrimary : NeonPalette.inkLight;
  Color get inkMuted =>
      isDark ? AppColors.textMuted : const Color(0xFF54545C);
  Color get inkFaint =>
      isDark ? AppColors.textFaint : const Color(0xFF8A8A92);

  /// رنگ پایه‌ی کارت‌ها — تخت و تیره، دقیقاً مطابق پالت
  Color get glassTop =>
      isDark ? AppColors.surfaceCard : Colors.white.withOpacity(0.92);
  Color get glassBottom =>
      isDark ? AppColors.surfaceCard : Colors.white.withOpacity(0.80);
  Color get glassBorder =>
      isDark ? AppColors.border : const Color(0xFFE2E2E6);
  Color get glassStroke =>
      isDark ? AppColors.border.withOpacity(0.6) : const Color(0xFFE2E2E6);

  Color get fieldFill =>
      isDark ? AppColors.surfaceBase : const Color(0xFFF4F4F6);

  /// روکش فلزی — در طرح تخت جدید بسیار کم‌رنگ (فقط یک خط ظریف مرزی)
  Color get metalHighlight =>
      isDark ? AppColors.border.withOpacity(0.5) : Colors.white;
  Color get metalShadow =>
      isDark ? Colors.black.withOpacity(0.35) : const Color(0xFFDADAE0);

  List<BoxShadow> glow(Color color, {double opacity = 0.35, double blur = 28, double spread = -6}) => [
        BoxShadow(
          color: color.withOpacity(isDark ? opacity * 0.5 : opacity * 0.3),
          blurRadius: blur * 0.6,
          spreadRadius: spread,
          offset: const Offset(0, 8),
        ),
      ];

  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.35) : const Color(0xFFD6D6DC),
          blurRadius: 18,
          spreadRadius: -10,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppRadius {
  static const double xs = 12;
  static const double sm = 18;
  static const double md = 24;
  static const double lg = 30;
  static const double xl = 36;
  static const double pill = 999;
}

class AppTheme {
  static const Color primary = NeonPalette.violet;
  static const Color primaryDark = NeonPalette.indigo;

  /// اگر فونت وزیرمتن را به assets اضافه کنید، خودکار استفاده می‌شود.
  static const String? fontFamily = 'Vazirmatn';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final t = NeonTokens(isDark);
    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final scheme = base.colorScheme.copyWith(
      primary: AppColors.green,
      secondary: AppColors.blue,
      tertiary: AppColors.purple,
      error: AppColors.coral,
      surface: isDark ? AppColors.surfaceCard : Colors.white,
      onSurface: t.ink,
    );

    final textTheme = base.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: t.ink,
      displayColor: t.ink,
    );

    return base.copyWith(
      colorScheme: scheme,
      brightness: brightness,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // پس‌زمینه شفاف است؛ لایه‌ی Aurora زیر همه چیز کشیده می‌شود.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      highlightColor: NeonPalette.violet.withOpacity(0.06),
      splashColor: NeonPalette.violet.withOpacity(0.10),
      dividerTheme: DividerThemeData(
        color: t.glassBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: t.ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? NeonPalette.night.withOpacity(0.92)
            : Colors.white.withOpacity(0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: t.glassBorder),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? NeonPalette.night.withOpacity(0.96)
            : NeonPalette.inkLight.withOpacity(0.94),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonPalette.violet,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NeonPalette.cyan,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          side: BorderSide(color: t.glassBorder),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.fieldFill,
        hintStyle: TextStyle(color: t.inkFaint, fontSize: 13),
        labelStyle: TextStyle(color: t.inkMuted, fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: NeonPalette.cyan,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: t.inkMuted,
        suffixIconColor: t.inkMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: t.glassBorder, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: t.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: NeonPalette.cyan, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: NeonPalette.rose, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: NeonPalette.rose, width: 1.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : t.inkFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? NeonPalette.violet
              : (isDark ? Colors.white10 : Colors.black12),
        ),
        trackOutlineColor:
            WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.green
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: t.inkFaint, width: 1.4),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NeonPalette.cyan,
        linearTrackColor: Colors.white12,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.inkMuted,
        textColor: t.ink,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: NeonPalette.night.withOpacity(0.95),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
