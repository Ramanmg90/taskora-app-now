import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/jalali_helper.dart';
import '../theme/app_theme.dart';
import '../utils/fa_num.dart';
import 'neon/glass.dart';
import 'priority_badge.dart';

/// کارت وظیفه‌ی شیشه‌ای با ریل نئونی اولویت و چک‌باکس انیمیشنی
class TaskCard extends StatelessWidget {
  final Task task;
  final TaskCategory? category;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.category,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final completed = task.status == TaskStatus.completed;
    final overdue = task.isOverdue;
    final accent = overdue
        ? NeonPalette.rose
        : (completed ? NeonPalette.lime : task.priority.color);

    return GlassCard(
      onTap: onTap,
      radius: AppRadius.md,
      padding: EdgeInsets.zero,
      glow: overdue ? NeonPalette.rose : null,
      glowOpacity: 0.20,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ریل نئونی سمت راست (RTL)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent.withOpacity(completed ? 0.4 : 1),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(completed ? 0.15 : 0.55),
                    blurRadius: 14,
                    spreadRadius: -1,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NeonCheck(
                      checked: completed,
                      color: NeonPalette.lime,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggle(!completed);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              color: completed ? t.inkFaint : t.ink,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: t.inkFaint,
                            ),
                            child: Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: t.inkFaint,
                              ),
                            ),
                          ],
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (category != null)
                                NeonTag(
                                  label: category!.name,
                                  color: category!.colorValue,
                                  icon: category!.iconData,
                                ),
                              PriorityBadge(priority: task.priority),
                              StatusBadge(
                                status: task.status,
                                isOverdue: overdue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 13,
                                color: overdue ? NeonPalette.rose : t.inkFaint,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _dateLabel(task),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: overdue
                                      ? NeonPalette.rose
                                      : t.inkFaint,
                                ),
                              ),
                              if (task.reminderOffsets.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.notifications_active_outlined,
                                  size: 13,
                                  color: NeonPalette.amber.withOpacity(0.9),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  faNum(task.reminderOffsets.length),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: NeonPalette.amber.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(Task t) {
    final j = Jalali.fromDateTime(t.dueDate);
    final today = Jalali.now();
    String datePart;
    if (j.isSameDate(today)) {
      datePart = 'امروز';
    } else if (j.isSameDate(Jalali.fromDateTime(
        DateTime.now().add(const Duration(days: 1))))) {
      datePart = 'فردا';
    } else if (j.isSameDate(Jalali.fromDateTime(
        DateTime.now().subtract(const Duration(days: 1))))) {
      datePart = 'دیروز';
    } else {
      datePart = '${faNum(j.day)} ${j.monthName}';
    }
    final time = t.dueTime != null
        ? ' · ${faTime(t.dueTime!.hour, t.dueTime!.minute)}'
        : '';
    return '$datePart$time';
  }
}

/// چک‌باکس دایره‌ای با انیمیشن پرشدن نئونی
class _NeonCheck extends StatelessWidget {
  final bool checked;
  final Color color;
  final VoidCallback onTap;

  const _NeonCheck({
    required this.checked,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? color : Colors.transparent,
          border: Border.all(
            color: checked ? color : t.inkFaint.withOpacity(0.6),
            width: 1.8,
          ),
          boxShadow: checked
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.55),
                    blurRadius: 16,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: AnimatedScale(
          scale: checked ? 1 : 0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: const Icon(
            Icons.check_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
