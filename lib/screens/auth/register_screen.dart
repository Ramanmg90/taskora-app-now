import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import '../../widgets/neon/neon_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  /// قدرت رمز عبور: 0..1
  double get _strength {
    final p = _passwordCtrl.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 6) s += 0.34;
    if (p.length >= 10) s += 0.22;
    if (RegExp(r'[0-9]').hasMatch(p)) s += 0.22;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s += 0.22;
    return s.clamp(0.0, 1.0);
  }

  Color get _strengthColor {
    final s = _strength;
    if (s < 0.4) return NeonPalette.rose;
    if (s < 0.75) return NeonPalette.amber;
    return NeonPalette.lime;
  }

  String get _strengthLabel {
    final s = _strength;
    if (s == 0) return '';
    if (s < 0.4) return 'ضعیف';
    if (s < 0.75) return 'متوسط';
    return 'قوی';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _password2Ctrl.text) {
      setState(() => _error = 'رمز عبور و تکرار آن یکسان نیستند');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().register(
            username: _usernameCtrl.text,
            password: _passwordCtrl.text,
            email: _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
            fullName: _fullNameCtrl.text.isEmpty ? null : _fullNameCtrl.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() =>
          _error = e.toString().replaceFirst('Exception: ', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'ساخت حساب', showBack: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          child: FadeSlideIn(
            child: GlassCard(
              radius: AppRadius.lg,
              glow: NeonPalette.magenta,
              glowOpacity: 0.18,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NeonField(
                      controller: _usernameCtrl,
                      label: 'نام کاربری',
                      icon: Icons.alternate_email_rounded,
                      accent: NeonPalette.violet,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'حداقل ۳ کاراکتر'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    NeonField(
                      controller: _fullNameCtrl,
                      label: 'نام و نام خانوادگی (اختیاری)',
                      icon: Icons.badge_outlined,
                      accent: NeonPalette.indigo,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    NeonField(
                      controller: _emailCtrl,
                      label: 'ایمیل (اختیاری)',
                      icon: Icons.mail_outline_rounded,
                      accent: NeonPalette.magenta,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    NeonField(
                      controller: _passwordCtrl,
                      label: 'رمز عبور',
                      icon: Icons.lock_outline_rounded,
                      accent: NeonPalette.cyan,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 18,
                          color: t.inkMuted,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'حداقل ۶ کاراکتر' : null,
                    ),
                    if (_strengthLabel.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: _strength),
                                duration: const Duration(milliseconds: 320),
                                builder: (_, v, __) => LinearProgressIndicator(
                                  value: v,
                                  minHeight: 5,
                                  backgroundColor: t.glassBorder,
                                  valueColor:
                                      AlwaysStoppedAnimation(_strengthColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _strengthColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    NeonField(
                      controller: _password2Ctrl,
                      label: 'تکرار رمز عبور',
                      icon: Icons.lock_reset_rounded,
                      accent: NeonPalette.lime,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'رمز عبور را تکرار کنید'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: NeonPalette.rose,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    NeonButton(
                      label: 'ایجاد حساب کاربری',
                      icon: Icons.auto_awesome_rounded,
                      loading: _loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
