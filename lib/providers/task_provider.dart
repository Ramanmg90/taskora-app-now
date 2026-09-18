import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  List<TaskCategory> _categories = [];
  Map<String, int> _stats = {'total': 0, 'completed': 0, 'pending': 0, 'overdue': 0};
  bool _loading = false;
  int? _ownerId;

  List<Task> get tasks => _tasks;
  List<TaskCategory> get categories => _categories;
  Map<String, int> get stats => _stats;
  bool get loading => _loading;

  TaskCategory? categoryById(int? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks
        .where((t) =>
            t.status != TaskStatus.completed &&
            DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day) == today)
        .toList();
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final list = _tasks
        .where((t) =>
            t.status != TaskStatus.completed &&
            DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day).isAfter(today))
        .toList();
    list.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    return list.take(15).toList();
  }

  List<Task> get overdueTasks => _tasks.where((t) => t.isOverdue).toList();

  List<Task> get completedTasks {
    final list = _tasks.where((t) => t.status == TaskStatus.completed).toList();
    list.sort((a, b) => (b.completedAt ?? b.updatedAt).compareTo(a.completedAt ?? a.updatedAt));
    return list.take(15).toList();
  }

  /// تعداد روزهای متوالی (تا امروز یا دیروز) که حداقل یک وظیفه تکمیل شده —
  /// مبنای «روز متوالی» در داشبورد و «رکورد تمرکز» در صفحه‌ی آمار.
  int get completionStreakDays {
    final doneDates = _tasks
        .where((t) => t.status == TaskStatus.completed && t.completedAt != null)
        .map((t) {
      final d = t.completedAt!;
      return DateTime(d.year, d.month, d.day);
    }).toSet();
    if (doneDates.isEmpty) return 0;

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    if (!doneDates.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!doneDates.contains(cursor)) return 0;
    }
    int streak = 0;
    while (doneDates.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// تعداد وظایف تکمیل‌شده در هر یک از ۷ روز اخیر (برای نمودار میله‌ای آمار)،
  /// از شنبه تا جمعه بر اساس ایندکس هفته‌ی جلالی (۰=شنبه … ۶=جمعه).
  List<int> get weeklyCompletedCounts {
    final counts = List<int>.filled(7, 0);
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    for (final t in _tasks) {
      if (t.status != TaskStatus.completed || t.completedAt == null) continue;
      final d = t.completedAt!;
      final day = DateTime(d.year, d.month, d.day);
      final diff = startOfToday.difference(day).inDays;
      if (diff < 0 || diff > 6) continue;
      // تبدیل weekday میلادی (Mon=1..Sun=7) به ایندکس هفته‌ی شنبه‌محور
      final map = {6: 0, 7: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6};
      final idx = map[day.weekday]!;
      counts[idx] += 1;
    }
    return counts;
  }

  Future<void> load(int ownerId) async {
    _ownerId = ownerId;
    _loading = true;
    notifyListeners();
    _categories = await _service.getCategories(ownerId);
    _tasks = await _service.getTasks(ownerId);
    _stats = await _service.getStats(ownerId);
    _loading = false;
    notifyListeners();
    NotificationService.instance.rescheduleAll(ownerId);
  }

  Future<void> _refreshStats() async {
    if (_ownerId == null) return;
    _stats = await _service.getStats(_ownerId!);
  }

  Future<void> addTask(Task task) async {
    final created = await _service.createTask(task);
    await NotificationService.instance.scheduleForTask(created);
    await load(task.ownerId);
  }

  Future<void> editTask(Task task) async {
    final updated = await _service.updateTask(task);
    await NotificationService.instance.scheduleForTask(updated);
    await load(task.ownerId);
  }

  Future<void> deleteTask(Task task) async {
    await NotificationService.instance.cancelForTask(task.id!);
    await _service.deleteTask(task.id!);
    await load(task.ownerId);
  }

  Future<void> toggleCompleted(Task task) async {
    final completed = task.status != TaskStatus.completed;
    await _service.markCompleted(task.id!, completed: completed);
    if (completed) {
      await NotificationService.instance.cancelForTask(task.id!);
    } else {
      final refreshed = await _service.getTaskById(task.id!);
      if (refreshed != null) await NotificationService.instance.scheduleForTask(refreshed);
    }
    await load(task.ownerId);
  }

  Future<void> addCategory(TaskCategory category) async {
    await _service.createCategory(category);
    if (_ownerId != null) await load(_ownerId!);
  }

  Future<void> removeCategory(TaskCategory category) async {
    if (category.id == null) return;
    await _service.deleteCategory(category.id!);
    if (_ownerId != null) await load(_ownerId!);
  }
}
