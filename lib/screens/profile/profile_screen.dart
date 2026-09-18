import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import '../../widgets/neon/neon_field.dart';
import '../../widgets/neon/neon_progress_ring.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _fullNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  bool _saving = false;
  bool _edited = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _fullNameCtrl = TextEditingController(text: user.fullName ?? '');
    _emailCtrl = TextEditingController(text: user.email ?? '');
    _phoneCtrl = TextEditingController(text: user.phoneNumber ?? '');
    _bioCtrl = TextEditingController(text: user.bio ?? '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final updated = auth.currentUser!.copyWith(
      fullName:
          _fullNameCtrl.text.trim().isEmpty ? null : _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phoneNumber:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
    );
    await auth.updateProfile(updated);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _edited = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('پروفایل به‌روزرسانی شد ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final stats = context.watch<TaskProvider>().stats;
    final t = NeonTokens.of(context);
    final user = auth.currentUser!;

    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final progress = total == 0 ? 0.0 : completed / total;
    final initial = (user.fullName?.isNotEmpty == true
            ? user.fullName![0]
            : user.username[0])
        .toUpperCase();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 16,
          16,
          150,
        ),
        children: [
          FadeSlideIn(
            child: GlassCard(
              radius: AppRadius.lg,
              glow: NeonPalette.lime,
              glowOpacity: 0.18,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      NeonProgressRing(
                        value: progress,
                        size: 96,
                        stroke: 7,
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: NeonPalette.brand,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: NeonPalette.violet.withOpacity(0.45),
                              blurRadius: 22,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName?.trim().isNotEmpty == true
                              ? user.fullName!.trim()
                              : user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: t.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '@${user.username}',
                          style: TextStyle(fontSize: 12, color: t.inkMuted),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Pill(
                              label: 'کل',
                              value: total,
                              color: NeonPalette.violet,
                            ),
                            const SizedBox(width: 8),
                            _Pill(
                              label: 'انجام‌شده',
                              value: completed,
                              color: NeonPalette.lime,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delayMs: 90,
            child: GlassCard(
              radius: AppRadius.lg,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'اطلاعات من'),
                  NeonField(
                    controller: _fullNameCtrl,
                    label: 'نام و نام خانوادگی',
                    icon: Icons.badge_outlined,
                    accent: NeonPalette.violet,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _edited = true),
                  ),
                  const SizedBox(height: 16),
                  NeonField(
                    controller: _emailCtrl,
                    label: 'ایمیل',
                    icon: Icons.mail_outline_rounded,
                    accent: NeonPalette.cyan,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _edited = true),
                  ),
                  const SizedBox(height: 16),
                  NeonField(
                    controller: _phoneCtrl,
                    label: 'شماره تماس',
                    icon: Icons.phone_iphone_rounded,
                    accent: NeonPalette.magenta,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _edited = true),
                  ),
                  const SizedBox(height: 16),
                  NeonField(
                    controller: _bioCtrl,
                    label: 'درباره‌ی من',
                    icon: Icons.text_snippet_outlined,
                    accent: NeonPalette.lime,
                    maxLines: 3,
                    onChanged: (_) => setState(() => _edited = true),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    child: _edited
                        ? Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: NeonButton(
                              label: 'ذخیره تغییرات',
                              icon: Icons.save_rounded,
                              loading: _saving,
                              onPressed: _save,
                            ),
                          )
                        : const SizedBox(width: double.infinity, height: 0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FadeSlideIn(
            delayMs: 150,
            child: Row(
              children: [
                Expanded(
                  child: NeonOutlineButton(
                    label: 'تنظیمات',
                    icon: Icons.tune_rounded,
                    onPressed: () => Navigator.of(context)
                        .push(neonRoute(const SettingsScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeonOutlineButton(
                    label: 'خروج',
                    icon: Icons.logout_rounded,
                    color: NeonPalette.rose,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('خروج از حساب'),
                          content: const Text(
                            'آیا می‌خواهید از حساب کاربری خارج شوید؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('انصراف'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'خروج',
                                style: TextStyle(color: NeonPalette.rose),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Pill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            faNum(value),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 10.5, color: color.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }
}
