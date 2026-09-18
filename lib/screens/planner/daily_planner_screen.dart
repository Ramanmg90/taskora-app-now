import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../services/jalali_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../calendar/calendar_screen.dart';
import '../tasks/task_detail_screen.dart';
import '../timer/focus_timer_screen.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  late Jalali _selectedDay;
  late List<Jalali> _strip;

  @override
  void initState() {
    super.initState();
    _selectedDay = Jalali.now();
    _strip = List.generate(5, (i) {
      final g = DateTime.now().add(Duration(days: i));
      return Jalali.fromDateTime(DateTime(g.year, g.month, g.day));
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final t = NeonTokens.of(context);
    final isToday = _selectedDay.isSameDate(Jalali.now());

    final selectedG = _selectedDay.toDateTime();
    final dayTasks = taskProvider.tasks.where((x) {
      final d = x.dueDate;
      return d.year == selectedG.year &&
          d.month == selectedG.month &&
          d.day == selectedG.day;
    }).toList();
    final timed = dayTasks.where((x) => x.dueTime != null).toList()
      ..sort((a, b) {
        final am = a.dueTime!.hour * 60 + a.dueTime!.minute;
        final bm = b.dueTime!.hour * 60 + b.dueTime!.minute;
        return am.compareTo(bm);
      });
    final untimed = dayTasks.where((x) => x.dueTime == null).toList();

    final nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;
    int? nowInsertIndex;
    if (isToday) {
      for (int i = 0; i < timed.length; i++) {
        final m = timed[i].dueTime!.hour * 60 + timed[i].dueTime!.minute;
        if (m > nowMinutes) {
          nowInsertIndex = i;
          break;
        }
      }
      nowInsertIndex ??= timed.isEmpty ? null : timed.length;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: FadeSlideIn(
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.coral,
                      tooltip: 'تقویم ماهانه',
                      onTap: () => Navigator.of(context)
                          .push(neonRoute(const CalendarScreen())),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'برنامه‌ی روزانه',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: t.ink,
                            ),
                          ),
                          Text(
                            'جدول زمان‌بندی امروز',
                            style: TextStyle(fontSize: 11.5, color: t.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 74,
              child: FadeSlideIn(
                delayMs: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _strip.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _DayCell(
                    day: _strip[i],
                    selected: _strip[i].isSameDate(_selectedDay),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDay = _strip[i]);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: (timed.isEmpty && untimed.isEmpty)
                  ? ListView(
                      children: const [
                        SizedBox(height: 30),
                        EmptyState(
                          icon: Icons.free_breakfast_rounded,
                          message: 'برای این روز چیزی زمان‌بندی نشده',
                          hint: 'یک وظیفه با ساعت مشخص بساز',
                          color: AppColors.coral,
                        ),
                      ],
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
                      children: [
                        for (int i = 0; i < timed.length; i++) ...[
                          if (nowInsertIndex == i) const _NowDivider(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FadeSlideIn(
                              delayMs: 40 * (i < 8 ? i : 8),
                              child: _ScheduleBlock(
                                task: timed[i],
                                category:
                                    taskProvider.categoryById(timed[i].categoryId),
                                onTap: () => Navigator.of(context).push(
                                  neonRoute(TaskDetailScreen(taskId: timed[i].id!)),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (nowInsertIndex == timed.length) const _NowDivider(),
                        if (untimed.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'بدون ساعت مشخص',
                            style: TextStyle(fontSize: 11.5, color: t.inkFaint),
                          ),
                          const SizedBox(height: 10),
                          for (final tk in untimed)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ScheduleBlock(
                                task: tk,
                                category: taskProvider.categoryById(tk.categoryId),
                                onTap: () => Navigator.of(context).push(
                                  neonRoute(TaskDetailScreen(taskId: tk.id!)),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'planner-focus-fab',
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.bolt_rounded),
        label: const Text(
          'شروع تمرکز',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        onPressed: () =>
            Navigator.of(context).push(neonRoute(const FocusTimerScreen())),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final Jalali day;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell({required this.day, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.green.withOpacity(0.14)
              : (t.isDark ? AppColors.surfaceCard : Colors.white),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.green : t.glassBorder,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              jalaliWeekdayShort[day.weekday],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.green : t.inkMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              faNum(day.day),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: selected ? AppColors.green : t.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NowDivider extends StatelessWidget {
  const _NowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.coral,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.coral.withOpacity(0.5)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'الان',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.coral,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: AppColors.coral.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

class _ScheduleBlock extends StatelessWidget {
  final Task task;
  final dynamic category;
  final VoidCallback onTap;

  const _ScheduleBlock({required this.task, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final color = category?.colorValue ?? task.priority.color;
    final completed = task.status == TaskStatus.completed;

    String timeRange = 'بدون ساعت';
    if (task.dueTime != null) {
      final start = task.dueTime!;
      final endMinutes = (start.hour * 60 + start.minute + 60) % (24 * 60);
      final end = TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);
      timeRange =
          '${faTime(start.hour, start.minute)} - ${faTime(end.hour, end.minute)}';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: t.isDark ? AppColors.surfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border(
              right: BorderSide(color: color, width: 4),
              top: BorderSide(color: t.glassBorder),
              bottom: BorderSide(color: t.glassBorder),
              left: BorderSide(color: t.glassBorder),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: completed ? t.inkFaint : t.ink,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category?.name ?? 'شخصی',
                      style: TextStyle(fontSize: 11, color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeRange,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
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
