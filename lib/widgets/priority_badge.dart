import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import 'neon/glass.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge({super.key, required this.priority});

  IconData get _icon {
    switch (priority) {
      case TaskPriority.low:
        return Icons.south_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.high:
        return Icons.north_rounded;
      case TaskPriority.urgent:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) =>
      NeonTag(label: priority.label, color: priority.color, icon: _icon);
}

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool isOverdue;
  const StatusBadge({super.key, required this.status, this.isOverdue = false});

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? NeonPalette.rose : status.color;
    final label = isOverdue ? 'عقب‌افتاده' : status.label;
    final icon = isOverdue
        ? Icons.error_outline_rounded
        : switch (status) {
            TaskStatus.pending => Icons.schedule_rounded,
            TaskStatus.inProgress => Icons.autorenew_rounded,
            TaskStatus.completed => Icons.check_circle_outline_rounded,
            TaskStatus.cancelled => Icons.block_rounded,
          };
    return NeonTag(label: label, color: color, icon: icon);
  }
}
