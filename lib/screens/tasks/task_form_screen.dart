import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../services/jalali_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/jalali_date_picker.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import '../../widgets/neon/neon_field.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;
  const TaskFormScreen({super.key, this.existingTask});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  int? _categoryId;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.pending;
  DateTime _dueDate = DateTime.now();
  TimeOfDay? _dueTime;
  final Set<int> _reminders = {15};
  bool _saving = false;

  bool get _isEdit => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _categoryId = t?.categoryId;
    _priority = t?.priority ?? TaskPriority.medium;
    _status = t?.status ?? TaskStatus.pending;
    _dueDate = t?.dueDate ?? DateTime.now();
    _dueTime = t?.dueTime;
    if (t != null) {
      _reminders
        ..clear()
        ..addAll(t.reminderOffsets);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked =
        await showJalaliDatePicker(context: context, initialDate: _dueDate);
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: NeonPalette.violet,
                surface: Theme.of(context).brightness == Brightness.dark
                    ? NeonPalette.night
                    : Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  void _quickDate(int daysFromNow) {
    final now = DateTime.now();
    setState(() => _dueDate = DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysFromNow)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    final ownerId = auth.currentUser!.id!;

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        final updated = widget.existingTask!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          categoryId: _categoryId,
          clearCategory: _categoryId == null,
          priority: _priority,
          status: _status,
          dueDate: _dueDate,
          dueTime: _dueTime,
          clearDueTime: _dueTime == null,
          reminderOffsets: _reminders.toList(),
        );
        await taskProvider.editTask(updated);
      } else {
        await taskProvider.addTask(
          Task(
            ownerId: ownerId,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            categoryId: _categoryId,
            priority: _priority,
            status: _status,
            dueDate: _dueDate,
            dueTime: _dueTime,
            reminderOffsets: _reminders.toList(),
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<TaskProvider>().categories;
    final jDue = Jalali.fromDateTime(_dueDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: _isEdit ? 'ویرایش وظیفه' : 'وظیفه‌ی جدید',
        showBack: true,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
            children: [
              FadeSlideIn(
                child: GlassCard(
                  radius: AppRadius.lg,
                  glow: _priority.color,
                  glowOpacity: 0.18,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    children: [
                      NeonField(
                        controller: _titleCtrl,
                        label: 'عنوان وظیفه',
                        icon: Icons.title_rounded,
                        accent: _priority.color,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'عنوان را وارد کنید'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      NeonField(
                        controller: _descCtrl,
                        label: 'توضیحات (اختیاری)',
                        icon: Icons.notes_rounded,
                        accent: NeonPalette.cyan,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delayMs: 80,
                child: _Block(
                  title: 'زمان انجام',
                  color: NeonPalette.cyan,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _PickerTile(
                              icon: Icons.calendar_month_rounded,
                              label: 'تاریخ',
                              value:
                                  '${faNum(jDue.day)} ${jDue.monthName} ${faNum(jDue.year)}',
                              color: NeonPalette.cyan,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PickerTile(
                              icon: Icons.schedule_rounded,
                              label: 'ساعت',
                              value: _dueTime == null
                                  ? 'بدون ساعت'
                                  : faTime(_dueTime!.hour, _dueTime!.minute),
                              color: NeonPalette.magenta,
                              onTap: _pickTime,
                              onClear: _dueTime == null
                                  ? null
                                  : () => setState(() => _dueTime = null),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _quickChip('امروز', 0),
                          const SizedBox(width: 8),
                          _quickChip('فردا', 1),
                          const SizedBox(width: 8),
                          _quickChip('هفته‌ی بعد', 7),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delayMs: 140,
                child: _Block(
                  title: 'اولویت',
                  color: _priority.color,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TaskPriority.values
                        .map(
                          (p) => NeonChip(
                            label: p.label,
                            color: p.color,
                            selected: _priority == p,
                            onTap: () => setState(() => _priority = p),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delayMs: 180,
                child: _Block(
                  title: 'دسته‌بندی',
                  color: NeonPalette.violet,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      NeonChip(
                        label: 'بدون دسته',
                        selected: _categoryId == null,
                        color: NeonPalette.violet,
                        onTap: () => setState(() => _categoryId = null),
                      ),
                      ...categories.map(
                        (c) => NeonChip(
                          label: c.name,
                          icon: c.iconData,
                          color: c.colorValue,
                          selected: _categoryId == c.id,
                          onTap: () => setState(() => _categoryId = c.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delayMs: 220,
                child: _Block(
                  title: 'وضعیت',
                  color: _status.color,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TaskStatus.values
                        .map(
                          (s) => NeonChip(
                            label: s.label,
                            color: s.color,
                            selected: _status == s,
                            onTap: () => setState(() => _status = s),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                delayMs: 260,
                child: _Block(
                  title: 'یادآوری‌ها',
                  color: NeonPalette.amber,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reminderOffsetChoices
                        .map(
                          (o) => NeonChip(
                            label: reminderOffsetLabel(o),
                            icon: Icons.notifications_active_outlined,
                            color: NeonPalette.amber,
                            selected: _reminders.contains(o),
                            onTap: () => setState(() {
                              if (_reminders.contains(o)) {
                                _reminders.remove(o);
                              } else {
                                _reminders.add(o);
                              }
                            }),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              NeonButton(
                label: _isEdit ? 'ذخیره تغییرات' : 'افزودن وظیفه',
                icon: _isEdit ? Icons.save_rounded : Icons.add_task_rounded,
                loading: _saving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickChip(String label, int days) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day)
        .add(Duration(days: days));
    final selected = _dueDate.year == target.year &&
        _dueDate.month == target.month &&
        _dueDate.day == target.day;
    return NeonChip(
      label: label,
      selected: selected,
      color: NeonPalette.cyan,
      onTap: () => _quickDate(days),
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const _Block({
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: AppRadius.lg,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, color: color),
          child,
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Material(
      color: color.withOpacity(t.isDark ? 0.08 : 0.10),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 10, color: t.inkFaint),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: t.ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: t.inkFaint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
