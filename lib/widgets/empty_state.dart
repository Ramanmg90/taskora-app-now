import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// حالت خالی با هاله‌ی نئونی تپنده
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String message;
  final String? hint;
  final Color color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.hint,
    this.color = NeonPalette.violet,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) => Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.10),
                border: Border.all(
                  color: widget.color.withOpacity(0.25 + _c.value * 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.12 + _c.value * 0.18),
                    blurRadius: 26 + _c.value * 10,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: child,
            ),
            child: Icon(widget.icon, size: 30, color: widget.color),
          ),
          const SizedBox(height: 14),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.inkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.hint != null) ...[
            const SizedBox(height: 5),
            Text(
              widget.hint!,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.inkFaint, fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}
