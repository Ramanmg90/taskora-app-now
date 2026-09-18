import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../services/jalali_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../tasks/task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Jalali _displayedMonth;
  late Jalali _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = Jalali.now();
    _displayedMonth = Jalali(_selectedDay.year, _selectedDay.month, 1);
  }

  Map<String, List<Task>> _tasksByDate(List<Task> tasks) {
    final map = <String, List<Task>>{};
    for (final t in tasks) {
      final key = '${t.dueDate.year}-${t.dueDate.month}-${t.dueDate.day}';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final t = NeonTokens.of(context);
    final tasksByDate = _tasksByDate(taskProvider.tasks);

    final firstOfMonth = Jalali(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = firstOfMonth.monthLength;
    final leadingEmpty = firstOfMonth.weekday;

    final selectedG = _selectedDay.toDateTime();
    final selectedKey =
        '${selectedG.year}-${selectedG.month}-${selectedG.day}';
    final dayTasks = [...(tasksByDate[selectedKey] ?? <Task>[])]
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FadeSlideIn(
              child: GlassCard(
                radius: AppRadius.lg,
                glow: NeonPalette.magenta,
                glowOpacity: 0.18,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GlassIconButton(
                          icon: Icons.chevron_right_rounded,
                          size: 36,
                          onTap: () => setState(() =>
                              _displayedMonth = _displayedMonth.addMonths(-1)),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${_displayedMonth.monthName} ${faNum(_displayedMonth.year)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: t.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _selectedDay = Jalali.now();
                                  _displayedMonth = Jalali(
                                    _selectedDay.year,
                                    _selectedDay.month,
                                    1,
                                  );
                                }),
                                child: const Text(
                                  'پرش به امروز',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: NeonPalette.cyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GlassIconButton(
                          icon: Icons.chevron_left_rounded,
                          size: 36,
                          onTap: () => setState(() =>
                              _displayedMonth = _displayedMonth.addMonths(1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1,
                      children: [
                        for (final d in jalaliWeekdayShort)
                          Center(
                            child: Text(
                              d,
                              style: TextStyle(
                                fontSize: 11,
                                color: t.inkFaint,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        for (int i = 0; i < leadingEmpty; i++)
                          const SizedBox.shrink(),
                        for (int day = 1; day <= daysInMonth; day++)
                          _dayCell(day, tasksByDate),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(
              title: _selectedDay.isSameDate(Jalali.now())
                  ? 'وظایف امروز'
                  : 'وظایف ${faNum(_selectedDay.day)} ${_selectedDay.monthName}',
              color: NeonPalette.magenta,
              trailingText:
                  dayTasks.isEmpty ? null : '${faNum(dayTasks.length)} مورد',
            ),
          ),
          Expanded(
            child: dayTasks.isEmpty
                ? ListView(
                    children: const [
                      EmptyState(
                        icon: Icons.nights_stay_rounded,
                        message: 'این روز خالی است',
                        hint: 'روز آزاد هم بخشی از برنامه است',
                        color: NeonPalette.magenta,
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
                    itemCount: dayTasks.length,
                    itemBuilder: (context, i) {
                      final task = dayTasks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FadeSlideIn(
                          delayMs: 40 * (i < 8 ? i : 8),
                          child: TaskCard(
                            task: task,
                            category:
                                taskProvider.categoryById(task.categoryId),
                            onTap: () => Navigator.of(context).push(
                              neonRoute(TaskDetailScreen(taskId: task.id!)),
                            ),
                            onToggle: (_) =>
                                taskProvider.toggleCompleted(task),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(int day, Map<String, List<Task>> tasksByDate) {
    final t = NeonTokens.of(context);
    final jd = Jalali(_displayedMonth.year, _displayedMonth.month, day);
    final g = jd.toDateTime();
    final key = '${g.year}-${g.month}-${g.day}';
    final dayTasks = tasksByDate[key] ?? const <Task>[];
    final hasOverdue = dayTasks.any((x) => x.isOverdue);
    final allDone = dayTasks.isNotEmpty &&
        dayTasks.every((x) => x.status == TaskStatus.completed);
    final isSelected = jd.isSameDate(_selectedDay);
    final isToday = jd.isSameDate(Jalali.now());

    final dotColor = allDone
        ? NeonPalette.lime
        : (hasOverdue ? NeonPalette.rose : NeonPalette.cyan);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedDay = jd);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? NeonPalette.brand : null,
          border: Border.all(
            color: isToday && !isSelected
                ? NeonPalette.cyan.withOpacity(0.8)
                : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: NeonPalette.violet.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              faNum(day),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected || isToday
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: isSelected ? Colors.white : t.ink,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 5,
              child: dayTasks.isEmpty
                  ? null
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        dayTasks.length > 3 ? 3 : dayTasks.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : dotColor,
                            boxShadow: isSelected
                                ? null
                                : [
                                    BoxShadow(
                                      color: dotColor.withOpacity(0.8),
                                      blurRadius: 6,
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
