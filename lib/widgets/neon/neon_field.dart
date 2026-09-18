import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// فیلد ورودی نئونی: لیبل شناور، حلقه‌ی نوری که با فوکوس شدت می‌گیرد،
/// آیکون رنگ‌پذیر، و لرزش کوتاه هنگام بروز خطا — همه با انیمیشن.
///
/// روی `FormField<String>` ساخته شده تا با `Form.validate()` بیرونی هم
/// (مثل فرم‌های ورود/ثبت‌نام) کاملاً سازگار باشد.
class NeonField extends FormField<String> {
  NeonField({
    super.key,
    required TextEditingController controller,
    required String label,
    IconData? icon,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    TextInputAction? textInputAction,
    Color accent = NeonPalette.cyan,
    bool autofocus = false,
    super.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(
          initialValue: controller.text,
          autovalidateMode: autovalidateMode,
          builder: (field) {
            return _NeonFieldBody(
              controller: controller,
              label: label,
              icon: icon,
              suffix: suffix,
              obscureText: obscureText,
              keyboardType: keyboardType,
              maxLines: maxLines,
              accent: accent,
              autofocus: autofocus,
              textInputAction: textInputAction,
              errorText: field.errorText,
              onChanged: (v) {
                field.didChange(v);
                onChanged?.call(v);
              },
              onSubmitted: onSubmitted,
            );
          },
        );
}

class _NeonFieldBody extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final Color accent;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  const _NeonFieldBody({
    required this.controller,
    required this.label,
    required this.icon,
    required this.suffix,
    required this.obscureText,
    required this.keyboardType,
    required this.maxLines,
    required this.accent,
    required this.autofocus,
    required this.textInputAction,
    required this.errorText,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_NeonFieldBody> createState() => _NeonFieldBodyState();
}

class _NeonFieldBodyState extends State<_NeonFieldBody>
    with TickerProviderStateMixin {
  late final FocusNode _node = FocusNode();
  late final AnimationController _focusCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {});
    if (_node.hasFocus) {
      _focusCtrl.forward();
    } else {
      _focusCtrl.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant _NeonFieldBody old) {
    super.didUpdateWidget(old);
    if (old.errorText == null && widget.errorText != null) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _node.dispose();
    _focusCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final hasError = widget.errorText != null;
    final color = hasError ? NeonPalette.rose : widget.accent;

    return AnimatedBuilder(
      animation: Listenable.merge([_focusCtrl, _shakeCtrl]),
      builder: (context, _) {
        final f = _focusCtrl.value; // 0..1
        final mixAmt = hasError ? 1.0 : f;
        // لرزش کوتاه و میراشونده هنگام بروز خطا
        final dx = math.sin(_shakeCtrl.value * math.pi * 5) *
            (1 - _shakeCtrl.value) *
            7;

        return Transform.translate(
          offset: Offset(_shakeCtrl.isAnimating ? dx : 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: t.fieldFill,
                  border: Border.all(
                    color: Color.lerp(t.glassBorder, color, mixAmt)!,
                    width: 1 + f * 0.6,
                  ),
                  boxShadow: (f > 0 || hasError)
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.30 * mixAmt),
                            blurRadius: 20 * mixAmt,
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: widget.maxLines > 1
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    if (widget.icon != null)
                      Padding(
                        padding: EdgeInsets.only(
                          right: 14,
                          left: 4,
                          top: widget.maxLines > 1 ? 16 : 0,
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: f),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, v, child) => Transform.scale(
                            scale: 1 + v * 0.12,
                            child: Icon(
                              widget.icon,
                              size: 19,
                              color: Color.lerp(t.inkMuted, color, hasError ? 1 : v),  // v تراکینگ محلی برای آیکون
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 14),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: widget.maxLines > 1 ? 22 : 22,
                              bottom: widget.maxLines > 1 ? 10 : 8,
                            ),
                            child: TextField(
                              controller: widget.controller,
                              focusNode: _node,
                              autofocus: widget.autofocus,
                              obscureText: widget.obscureText,
                              keyboardType: widget.keyboardType,
                              maxLines: widget.obscureText ? 1 : widget.maxLines,
                              textInputAction: widget.textInputAction,
                              onChanged: widget.onChanged,
                              onSubmitted: widget.onSubmitted,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: t.ink,
                              ),
                              cursorColor: color,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          // لیبل شناور
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            top: (f > 0 || widget.controller.text.isNotEmpty)
                                ? 4
                                : 18,
                            right: 0,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: (f > 0 || widget.controller.text.isNotEmpty)
                                    ? 10.5
                                    : 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color.lerp(t.inkFaint, color, hasError ? 1 : f),
                              ),
                              child: Text(widget.label),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.suffix != null) widget.suffix!,
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.topCenter,
                child: hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 13,
                              color: NeonPalette.rose,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                widget.errorText!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: NeonPalette.rose,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity, height: 0),
              ),
            ],
          ),
        );
      },
    );
  }
}
