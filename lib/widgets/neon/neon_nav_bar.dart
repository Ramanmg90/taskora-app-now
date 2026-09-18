import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'glass.dart';

class NeonNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  const NeonNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

/// نوار ناوبری شیشه‌ای با اندیکاتور نئونی متحرک
class NeonNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NeonNavItem> items;

  const NeonNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final active = items[currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: active.color.withOpacity(t.isDark ? 0.28 : 0.18),
              blurRadius: 34,
              spreadRadius: -10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [t.glassTop, t.glassBottom],
                ),
              ),
              child: Stack(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        for (int i = 0; i < items.length; i++)
                          Expanded(
                            child: _NavCell(
                              item: items[i],
                              selected: i == currentIndex,
                              onTap: () {
                                if (i != currentIndex) {
                                  HapticFeedback.selectionClick();
                                }
                                onTap(i);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: MetalBevelPainter(
                          radius: AppRadius.xl,
                          width: 1.2,
                          highlight: t.metalHighlight,
                          shadow: t.metalShadow,
                          tint: active.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final NeonNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: selected ? item.color.withOpacity(0.16) : Colors.transparent,
          border: Border.all(
            color: selected ? item.color.withOpacity(0.45) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                key: ValueKey(selected),
                size: 21,
                color: selected ? item.color : t.inkFaint,
                shadows: selected
                    ? [
                        Shadow(
                          color: item.color.withOpacity(0.9),
                          blurRadius: 14,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: selected ? 10.5 : 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? item.color : t.inkFaint,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
