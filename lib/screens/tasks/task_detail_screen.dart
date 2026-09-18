import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../services/subtask_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import '../../widgets/neon/neon_field.dart';
import '../timer/focus_timer_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _subtaskService = SubtaskService();
  late List<Subtask> _subtasks;
  final _newSubtaskCtrl = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  void _loadSubtasks() async {
    final subs = await _subtaskService.load(widget.taskId);
    setState(() => _subtasks = subs);
  }

  void _saveSubtasks() async {
    await _subtaskService.save(widget.taskId, _subtasks);
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(
        done: !_subtasks[index].done,
      );
    });
    _saveSubtasks();
  }

  void _addSubtask() {
    final title = _newSubtaskCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _subtasks.add(Subtask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        done: false,
      ));
    });
    _saveSubtasks();
    _newSubtaskCtrl.clear();
  }

  void _deleteSubtask(int index) {
    setState(() => _subtasks.removeAt(index));
    _saveSubtasks();
  }

  @override
  void dispose() {
    _newSubtaskCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final task = taskProvider.tasks.firstWhere(
      (x) => x.id == widget.taskId,
      orElse: () => Task(
        id: widget.taskId,
        title: 'وظیفه پیدا نشد',
        ownerId: 0,
        dueDate: DateTime.now(),
      ),
    );
    final category = taskProvider.categoryById(task.categoryId);
    final t = NeonTokens.of(context);
    final isDone = task.status == TaskStatus.completed;

    final doneCount = _subtasks.where((s) => s.done).length;
    final subtaskProgress =
        _subtasks.isEmpty ? 0.0 : doneCount / _subtasks.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 180),
              children: [
                FadeSlideIn(
                  child: Row(
                    children: [
                      GlassIconButton(
                        icon: Icons.arrow_back_ios_rounded,
                        color: AppColors.teal,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      GlassIconButton(
                        icon: Icons.edit_rounded,
                        color: AppColors.blue,
                        onTap: () {
                          // TODO: open task edit screen
                        },
                      ),
                      const SizedBox(width: 8),
                      GlassIconButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.coral,
                        onTap: () => _showDeleteConfirm(context, taskProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delayMs: 60,
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                final newStatus = isDone
                                    ? TaskStatus.pending
                                    : TaskStatus.completed;
                                taskProvider.editTask(
                                  task.copyWith(
                                    status: newStatus,
                                    completedAt: newStatus ==
                                            TaskStatus.completed
                                        ? DateTime.now()
                                        : null,
                                  ),
                                );
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDone
                                        ? AppColors.green
                                        : t.inkFaint,
                                    width: 1.4,
                                  ),
                                  color: isDone
                                      ? AppColors.green
                                      : Colors.transparent,
                                ),
                                child: isDone
                                    ? const Icon(Icons.check_rounded,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w900,
                                      color: isDone ? t.inkFaint : t.ink,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 2, horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: task.priority.color
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          task.priority.label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: task.priority.color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (category != null)
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 2, horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: category.colorValue
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(99),
                                          ),
                                          child: Text(
                                            category.name,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: category.colorValue,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (task.description.isNotEmpty)
                  FadeSlideIn(
                    delayMs: 80,
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'توضیحات',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: t.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: t.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (task.description.isNotEmpty) const SizedBox(height: 18),
                FadeSlideIn(
                  delayMs: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'زیروظایف',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: t.inkMuted,
                            ),
                          ),
                          if (_subtasks.isNotEmpty)
                            Text(
                              '${faNum(doneCount)}/${faNum(_subtasks.length)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_subtasks.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: subtaskProgress,
                            minHeight: 6,
                            backgroundColor: t.isDark
                                ? Colors.white.withOpacity(0.07)
                                : const Color(0xFFEDEDF0),
                            valueColor:
                                const AlwaysStoppedAnimation(AppColors.green),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ..._subtasks.asMap().entries.map((e) {
                        final i = e.key;
                        final subtask = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _SubtaskTile(
                            subtask: subtask,
                            onToggle: () => _toggleSubtask(i),
                            onDelete: () => _deleteSubtask(i),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      NeonField(
                        controller: _newSubtaskCtrl,
                        label: 'زیروظیفه‌ی جدید',
                        icon: Icons.check_circle_outline_rounded,
                        accent: AppColors.green,
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              left: 16,
              right: 16,
              child: FadeSlideIn(
                delayMs: 200,
                child: NeonButton(
                  label: 'شروع تمرکز',
                  icon: Icons.flash_on_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.teal],
                  ),
                  glowColor: AppColors.green,
                  onPressed: () => Navigator.of(context).push(
                    neonRoute(FocusTimerScreen(linkedTask: task)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (dialogCtx) => GlassCard(
        radius: AppRadius.lg,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'حذف وظیفه',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: NeonTokens.of(context).ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'این کار برگشت‌پذیر نیست.',
              style: TextStyle(
                fontSize: 12.5,
                color: NeonTokens.of(context).inkMuted,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(dialogCtx),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppColors.blue,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: const Text(
                          'انصراف',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        taskProvider.deleteTask(task);
                        Navigator.pop(dialogCtx);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppColors.coral,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: const Text(
                          'حذف',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.coral,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtaskTile extends StatelessWidget {
  final Subtask subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubtaskTile({
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: subtask.done ? AppColors.green : t.inkFaint,
                    width: 1.4,
                  ),
                  color: subtask.done ? AppColors.green : Colors.transparent,
                ),
                child: subtask.done
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  subtask.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: subtask.done ? t.inkFaint : t.ink,
                    decoration:
                        subtask.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close_rounded, size: 16, color: t.inkFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
