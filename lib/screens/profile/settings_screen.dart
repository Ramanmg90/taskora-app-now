import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';

class SettingsScreen extends StatefulWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _focusMinutes;
  late int _restMinutes;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettingsProvider>();
    _focusMinutes = settings.focusMinutes;
    _restMinutes = settings.restMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<AppSettingsProvider>();
    final t = NeonTokens.of(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.embedded
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: GlassIconButton(
                icon: Icons.arrow_back_ios_rounded,
                color: AppColors.teal,
                onTap: () => Navigator.pop(context),
              ),
            ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            widget.embedded ? MediaQuery.of(context).padding.top + 4 : 16,
            16,
            150,
          ),
          children: [
            FadeSlideIn(
              child: Text(
                widget.embedded ? 'پروفایل' : 'تنظیمات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: t.ink,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Profile Section
            FadeSlideIn(
              delayMs: 60,
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.green, AppColors.teal],
                        ),
                      ),
                      child: Text(
                        (user?.fullName ?? 'K').characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'کاربر',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: t.ink,
                            ),
                          ),
                          Text(
                            user?.email ?? 'unknown@example.com',
                            style: TextStyle(
                              fontSize: 11,
                              color: t.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Settings Sections
            FadeSlideIn(
              delayMs: 80,
              child: const _SettingsSection(
                title: 'عمومی',
                color: AppColors.green,
              ),
            ),
            FadeSlideIn(
              delayMs: 100,
              child: GlassCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    _SettingItem(
                      icon: Icons.notifications_rounded,
                      label: 'اعلان‌ها',
                      trailing: Switch(
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (v) =>
                            settingsProvider.setNotificationsEnabled(v),
                        activeColor: AppColors.green,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: NeonTokens.of(context).glassBorder,
                      indent: 50,
                    ),
                    _SettingItem(
                      icon: Icons.language_rounded,
                      label: 'زبان',
                      trailing: Text(
                        'فارسی',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NeonTokens.of(context).inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delayMs: 120,
              child: const _SettingsSection(
                title: 'تایمر تمرکز',
                color: AppColors.blue,
              ),
            ),
            FadeSlideIn(
              delayMs: 140,
              child: GlassCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    _SettingItemWithSlider(
                      icon: Icons.lightning_bolt_rounded,
                      label: 'مدت‌ زمان تمرکز',
                      value: _focusMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      onChanged: (v) async {
                        setState(() => _focusMinutes = v.toInt());
                        await settingsProvider.setFocusMinutes(v.toInt());
                      },
                      unit: 'دقیقه',
                    ),
                    Divider(
                      height: 1,
                      color: NeonTokens.of(context).glassBorder,
                      indent: 50,
                    ),
                    _SettingItemWithSlider(
                      icon: Icons.coffee_rounded,
                      label: 'مدت‌ زمان استراحت',
                      value: _restMinutes.toDouble(),
                      min: 1,
                      max: 60,
                      onChanged: (v) async {
                        setState(() => _restMinutes = v.toInt());
                        await settingsProvider.setRestMinutes(v.toInt());
                      },
                      unit: 'دقیقه',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delayMs: 160,
              child: const _SettingsSection(
                title: 'حساب کاربری',
                color: AppColors.coral,
              ),
            ),
            FadeSlideIn(
              delayMs: 180,
              child: GlassCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    _SettingItem(
                      icon: Icons.logout_rounded,
                      label: 'خروج از حساب',
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: NeonTokens.of(context).inkFaint,
                      ),
                      onTap: () => _showLogoutDialog(context),
                    ),
                    Divider(
                      height: 1,
                      color: NeonTokens.of(context).glassBorder,
                      indent: 50,
                    ),
                    _SettingItem(
                      icon: Icons.delete_forever_rounded,
                      label: 'حذف حساب کاربری',
                      labelColor: AppColors.coral,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.coral,
                      ),
                      onTap: () => _showDeleteDialog(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delayMs: 200,
              child: Center(
                child: Text(
                  'تسکورا v1.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: NeonTokens.of(context).inkFaint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => GlassDialog(
        title: 'خروج از حساب',
        message: 'مطمئنی که می‌خوای از حسابت خارج شوی؟',
        actions: [
          GlassButton(
            label: 'انصراف',
            onPressed: () => Navigator.pop(dialogCtx),
            color: AppColors.teal,
          ),
          GlassButton(
            label: 'خروج',
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(dialogCtx);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            color: AppColors.coral,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => GlassDialog(
        title: 'حذف حساب کاربری',
        message:
            'این کار برگشت‌پذیر نیست. تمام وظایف و داده‌های تو حذف می‌شوند.',
        actions: [
          GlassButton(
            label: 'انصراف',
            onPressed: () => Navigator.pop(dialogCtx),
            color: AppColors.blue,
          ),
          GlassButton(
            label: 'حذف',
            onPressed: () {
              context.read<AuthProvider>().deleteAccount();
              Navigator.pop(dialogCtx);
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            color: AppColors.coral,
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Color color;

  const _SettingsSection({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: t.inkMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? labelColor;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: labelColor ?? t.inkMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: labelColor ?? t.ink,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingItemWithSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String unit;

  const _SettingItemWithSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: t.inkMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                  ),
                ),
              ),
              Text(
                '${faNum(value.toInt())} $unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 7,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.green,
              inactiveTrackColor: t.inkFaint.withOpacity(0.2),
              thumbColor: AppColors.green,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<GlassButton> actions;

  const GlassDialog({
    required this.title,
    required this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        radius: AppRadius.lg,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: t.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(fontSize: 12.5, color: t.inkMuted),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions
                  .map((a) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: a,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const GlassButton({
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: color, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
