import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/focus_stats_provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/neon/neon_progress_ring.dart';
import '../tasks/task_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final focusStats = context.watch<FocusStatsProvider>();
    final t = NeonTokens.of(context);
    
    final user = authProvider.currentUser;
    final tasks = taskProvider.tasks;
    final completed = tasks.where((x) => x.status == TaskStatus.completed).length;
    final active = tasks.where((x) => x.status == TaskStatus.inProgress).length;
    final total = tasks.length;
    final streak = taskProvider.completionStreakDays;

    final upcoming = tasks
        .where((x) =>
            x.status != TaskStatus.completed &&
            x.status != TaskStatus.cancelled &&
            x.dueDate.isAfter(DateTime.now()))
        .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final recentCompleted = taskProvider.completedTasks;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 4,
            16,
            150,
          ),
          children: [
            // Header
            FadeSlideIn(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.teal],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        (user?.name ?? 'کاربر').characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سلام، ${user?.name ?? 'کاربر'}! 👋',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'یک روز فعال و سازنده داشته باش',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Stats Grid
            FadeSlideIn(
              delayMs: 60,
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1 / 1.15,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    label: 'وظیفه‌های تولید شده',
                    value: faNum(total),
                    icon: Icons.dashboard_rounded,
                    color: AppColors.purple,
                  ),
                  StatCard(
                    label: 'وظیفه‌های فعال',
                    value: faNum(active),
                    icon: Icons.flash_on_rounded,
                    color: AppColors.coral,
                  ),
                  StatCard(
                    label: 'تکمیل شده',
                    value: faNum(completed),
                    icon: Icons.check_circle_rounded,
                    color: AppColors.green,
                  ),
                  StatCard(
                    label: 'روز‌های متوالی',
                    value: faNum(streak),
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Focus Stats Card (اگر امروز جلسه‌ای داشته باشد)
            if (focusStats.sessionsToday > 0)
              FadeSlideIn(
                delayMs: 120,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green.withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.timer_rounded,
                          size: 20,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جلسات تمرکز امروز',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: t.ink,
                              ),
                            ),
                            Text(
                              '${faNum(focusStats.sessionsToday)} جلسه برای ${faNum(focusStats.todayMinutes)} دقیقه',
                              style:
                                  TextStyle(fontSize: 10.5, color: t.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (focusStats.sessionsToday > 0) const SizedBox(height: 18),
            // Upcoming Tasks
            if (upcoming.isNotEmpty) ...[
              FadeSlideIn(
                delayMs: 140,
                child: SectionHeader(title: 'وظیفه‌های پیش رو', color: AppColors.blue),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                upcoming.take(3).length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FadeSlideIn(
                    delayMs: 160 + 40 * i,
                    child: _UpcomingTaskTile(
                      task: upcoming[i],
                      onTap: () => Navigator.of(context).push(
                        neonRoute(TaskDetailScreen(taskId: upcoming[i].id!)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (upcoming.isNotEmpty) const SizedBox(height: 18),
            // Recent Completed
            if (recentCompleted.isNotEmpty) ...[
              FadeSlideIn(
                delayMs: 180,
                child: SectionHeader(
                  title: 'اخیراً تکمیل شده',
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                recentCompleted.take(3).length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FadeSlideIn(
                    delayMs: 200 + 40 * i,
                    child: _RecentTaskTile(task: recentCompleted[i]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UpcomingTaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const _UpcomingTaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;
    String timeLabel;
    if (daysLeft == 0) {
      timeLabel = 'امروز';
    } else if (daysLeft == 1) {
      timeLabel = 'فردا';
    } else {
      timeLabel = '${faNum(daysLeft)} روز دیگر';
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
            border: Border.all(color: t.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.priority.color.withOpacity(0.15),
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.priority.color,
                  ),
                ),
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
                        fontWeight: FontWeight.w800,
                        color: t.ink,
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
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: task.priority.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: task.priority.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTaskTile extends StatelessWidget {
  final Task task;

  const _RecentTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.isDark ? AppColors.surfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.green.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.inkMuted,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
