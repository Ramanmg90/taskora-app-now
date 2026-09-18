import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/focus_stats_provider.dart';
import '../../models/task_model.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import '../../widgets/neon/neon_progress_ring.dart';

class FocusTimerScreen extends StatefulWidget {
  final Task? linkedTask;
  const FocusTimerScreen({super.key, this.linkedTask});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  late int _totalSeconds;
  late int _remainingSeconds;
  late bool _isFocus;
  late bool _isRunning;
  Task? _selectedTask;

  @override
  void initState() {
    super.initState();
    _selectedTask = widget.linkedTask;
    _isFocus = true;
    _isRunning = false;
    _update();
  }

  void _update() {
    final settingsProvider = context.read<AppSettingsProvider>();
    _totalSeconds = (_isFocus ? settingsProvider.focusMinutes : settingsProvider.restMinutes) * 60;
    if (!_isRunning) {
      _remainingSeconds = _totalSeconds;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);

    var ticks = _remainingSeconds;
    Future.doWhile(() async {
      if (!mounted || !_isRunning) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() => _remainingSeconds = ticks--);

      if (_remainingSeconds <= 0) {
        _complete();
        return false;
      }

      if (mounted && _remainingSeconds <= 5) {
        HapticFeedback.heavyImpact();
      }

      return true;
    });
  }

  void _complete() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();

    final focusStats = context.read<FocusStatsProvider>();
    final durationMinutes = _isFocus
        ? context.read<AppSettingsProvider>().focusMinutes
        : context.read<AppSettingsProvider>().restMinutes;

    focusStats.recordSession(
      minutes: durationMinutes,
      taskTitle: _isFocus ? _selectedTask?.title : null,
    );

    if (_isFocus && _selectedTask != null) {
      context.read<TaskProvider>().editTask(_selectedTask!.copyWith(
            status: TaskStatus.completed,
            completedAt: DateTime.now(),
          ));
    }

    NotificationService.instance.showInstant(
      id: 9999,
      title: _isFocus ? 'جلسه‌ی تمرکز تمام شد!' : 'وقت‌ی برای شروع دوباره!',
      body: _isFocus ? 'وقتی برای استراحت' : 'می‌تونی دوباره تمرکز کنی',
    );

    setState(() {
      _isFocus = !_isFocus;
      _isRunning = false;
      _update();
    });
  }

  void _pause() => setState(() => _isRunning = false);

  void _reset() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  String get _display {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${faNum(mins.toString().padLeft(2, '0'))}:${faNum(secs.toString().padLeft(2, '0'))}';
  }

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final progress = _remainingSeconds / _totalSeconds;
    final color = _isFocus ? AppColors.green : AppColors.blue;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            FadeSlideIn(
              child: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_ios_rounded,
                    color: AppColors.teal,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFocus ? 'تایمر تمرکز' : 'زمان استراحت',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: t.ink,
                          ),
                        ),
                        Text(
                          'کنترل بهتری بر زمان خود داشته باش',
                          style: TextStyle(fontSize: 10.5, color: t.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_isFocus && _selectedTask == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FadeSlideIn(
                  delayMs: 80,
                  child: _TaskSelectCard(onTap: () => _showTaskPicker()),
                ),
              ),
            if (_selectedTask != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FadeSlideIn(
                  delayMs: 80,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedTask!.priority.color.withOpacity(0.2),
                          ),
                          child: Icon(Icons.task_rounded, size: 14, color: _selectedTask!.priority.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedTask!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: t.ink,
                                ),
                              ),
                              Text(
                                'فوکس فعلی',
                                style: TextStyle(fontSize: 10, color: t.inkMuted),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedTask = null),
                          child: Icon(Icons.close_rounded, size: 18, color: t.inkFaint),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            FadeSlideIn(
  delayMs: 120,
  child: Center(
    child: NeonCountdownRing(
      value: progress,
      size: 220,
      stroke: 8,
      tint: color,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _display,
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: t.ink,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isFocus ? 'تمرکز' : 'استراحت',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
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
              ),
            ),
            const SizedBox(height: 28),
            FadeSlideIn(
              delayMs: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning)
                    Opacity(
                      opacity: _remainingSeconds == _totalSeconds ? 0.5 : 1,
                      child: GestureDetector(
                        onTap: _remainingSeconds == _totalSeconds ? null : _reset,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: t.inkFaint, width: 1.2),
                          ),
                          child: Icon(Icons.refresh_rounded, size: 18, color: t.inkMuted),
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _isRunning ? _pause : _startTimer,
                    child: Container(
                      width: 68,
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: -6)],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!_isRunning)
                    GestureDetector(
                      onTap: _complete,
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: t.inkFaint, width: 1.2),
                        ),
                        child: Icon(Icons.check_rounded, size: 18, color: AppColors.green),
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

  void _showTaskPicker() {
    final taskProvider = context.read<TaskProvider>();
    final pending = taskProvider.tasks
        .where((t) => t.status != TaskStatus.completed && t.status != TaskStatus.cancelled)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassCard(
        radius: AppRadius.xl,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: pending.length,
          itemBuilder: (_, i) {
            final task = pending[i];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedTask = task);
                  Navigator.pop(sheetCtx);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, 12, 14, i == pending.length - 1 ? 14 : 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: task.priority.color, width: 1.2),
                        ),
                        child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: task.priority.color)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TaskSelectCard extends StatelessWidget {
  final VoidCallback onTap;
  const _TaskSelectCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            children: [
              Icon(Icons.task_rounded, size: 18, color: t.inkMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'انتخاب وظیفه‌ای برای تمرکز',
                  style: TextStyle(fontSize: 13, color: t.inkMuted),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: t.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}
