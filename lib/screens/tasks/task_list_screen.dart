import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final int? initialCategoryId;
  const TaskListScreen({super.key, this.initialCategoryId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _filter = 'همه';

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final t = NeonTokens.of(context);

    var tasks = taskProvider.tasks;
    if (widget.initialCategoryId != null) {
      tasks = tasks.where((x) => x.categoryId == widget.initialCategoryId).toList();
    }

    switch (_filter) {
      case 'فعال':
        tasks = tasks
            .where((x) =>
                x.status == TaskStatus.inProgress ||
                x.status == TaskStatus.pending)
            .toList();
        break;
      case 'تکمیل شده':
        tasks = tasks.where((x) => x.status == TaskStatus.completed).toList();
        break;
      case 'اولویت':
        tasks = tasks
            .where((x) =>
                x.status != TaskStatus.completed &&
                x.status != TaskStatus.cancelled)
            .toList();
        tasks.sort((a, b) {
          const order = {
            TaskPriority.urgent: 0,
            TaskPriority.high: 1,
            TaskPriority.medium: 2,
            TaskPriority.low: 3,
          };
          return order[a.priority]!.compareTo(order[b.priority]!);
        });
        break;
    }

    final grouped = <String, List<Task>>{};
    for (final task in tasks) {
      final key = task.status.label;
      (grouped[key] ??= []).add(task);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: FadeSlideIn(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'وظایف',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: t.ink,
                            ),
                          ),
                          Text(
                            '${faNum(tasks.length)} وظیفه فیلتر شده',
                            style: TextStyle(fontSize: 10.5, color: t.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    GlassIconButton(
                      icon: Icons.tune_rounded,
                      color: AppColors.blue,
                      onTap: () => _showFilterMenu(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const ListView(
                      children: [
                        SizedBox(height: 40),
                        EmptyState(
                          icon: Icons.inbox_rounded,
                          message: 'هیچ وظیفه‌ای یافت نشد',
                          hint: 'یک وظیفه‌ی جدید بساز',
                          color: AppColors.blue,
                        ),
                      ],
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
                      children: [
                        for (final status in grouped.keys)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FadeSlideIn(
                              child: _TaskGroup(
                                status: status,
                                tasks: grouped[status]!,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterMenu() {
    final filters = ['همه', 'فعال', 'تکمیل شده', 'اولویت'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassCard(
        radius: AppRadius.lg,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: filters.asMap().entries.map((e) {
            final i = e.key;
            final filter = e.value;
            final selected = filter == _filter;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _filter = filter);
                  Navigator.pop(sheetCtx);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, 13, 14,
                      i == filters.length - 1 ? 14 : 13),
                  child: Row(
                    children: [
                      if (selected)
                        const Icon(Icons.check_rounded,
                            size: 16, color: AppColors.green)
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.green
                                : NeonTokens.of(context).ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TaskGroup extends StatelessWidget {
  final String status;
  final List<Task> tasks;

  const _TaskGroup({required this.status, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final colors = {
      'معلق': AppColors.coral,
      'در حال انجام': AppColors.blue,
      'تکمیل شده': AppColors.green,
      'لغو شده': AppColors.purple,
    };
    final color = colors[status] ?? AppColors.teal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: t.inkMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                faNum(tasks.length),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        ...List.generate(
          tasks.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: FadeSlideIn(
              delayMs: 40 * (i < 8 ? i : 8),
              child: _TaskItem(
                task: tasks[i],
                onTap: () => Navigator.of(context).push(
                  neonRoute(TaskDetailScreen(taskId: tasks[i].id!)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _TaskItem({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final isDone = task.status == TaskStatus.completed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: t.isDark ? AppColors.surfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: t.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone ? AppColors.green : t.inkFaint,
                    width: 1.4,
                  ),
                  color: isDone ? AppColors.green : Colors.transparent,
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDone ? t.inkFaint : t.ink,
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      task.categoryName,
                      style: TextStyle(fontSize: 10, color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.priority.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
