import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

extension TaskPriorityX on TaskPriority {
  String get value => toString().split('.').last;

  static TaskPriority fromValue(String v) {
    switch (v) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'کم';
      case TaskPriority.medium:
        return 'متوسط';
      case TaskPriority.high:
        return 'زیاد';
      case TaskPriority.urgent:
        return 'فوری';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF22C55E); // green
      case TaskPriority.medium:
        return const Color(0xFF3B82F6); // blue
      case TaskPriority.high:
        return const Color(0xFFFF6B6B); // coral
      case TaskPriority.urgent:
        return const Color(0xFFA855F7); // purple
    }
  }
}

extension TaskStatusX on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.inProgress:
        return 'in_progress';
      default:
        return toString().split('.').last;
    }
  }

  static TaskStatus fromValue(String v) {
    switch (v) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'در انتظار';
      case TaskStatus.inProgress:
        return 'در حال انجام';
      case TaskStatus.completed:
        return 'تکمیل شده';
      case TaskStatus.cancelled:
        return 'لغو شده';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return const Color(0xFFC0C0C6);
      case TaskStatus.inProgress:
        return const Color(0xFF3B82F6); // blue
      case TaskStatus.completed:
        return const Color(0xFF22C55E); // green
      case TaskStatus.cancelled:
        return const Color(0xFF6E6E75);
    }
  }
}

class Task {
  final int? id;
  final int ownerId;
  final String title;
  final String description;
  final int? categoryId;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate; // فقط تاریخ (بدون ساعت معتبر)
  final TimeOfDay? dueTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<int> reminderOffsets; // دقیقه قبل از موعد

  Task({
    this.id,
    required this.ownerId,
    required this.title,
    this.description = '',
    this.categoryId,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    required this.dueDate,
    this.dueTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completedAt,
    this.reminderOffsets = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DateTime get dueDateTime {
    if (dueTime != null) {
      return DateTime(dueDate.year, dueDate.month, dueDate.day, dueTime!.hour, dueTime!.minute);
    }
    return DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59);
  }

  bool get isOverdue {
    if (status == TaskStatus.completed || status == TaskStatus.cancelled) return false;
    return dueDateTime.isBefore(DateTime.now());
  }

  /// وضعیت مؤثر برای نمایش (در نظر گرفتن عقب‌افتادگی)
  TaskStatus get effectiveStatus => isOverdue ? TaskStatus.pending : status;

  /// نام دسته‌بندی — برای نمایش آسان (TaskProvider باید آن را فراهم کند)
  String get categoryName => 'شخصی';

  Task copyWith({
    String? title,
    String? description,
    int? categoryId,
    bool clearCategory = false,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool clearDueTime = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<int>? reminderOffsets,
  }) =>
      Task(
        id: id,
        ownerId: ownerId,
        title: title ?? this.title,
        description: description ?? this.description,
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        priority: priority ?? this.priority,
        status: status ?? this.status,
        dueDate: dueDate ?? this.dueDate,
        dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
        reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'owner_id': ownerId,
        'title': title,
        'description': description,
        'category_id': categoryId,
        'priority': priority.value,
        'status': status.value,
        'due_date': dueDate.toIso8601String().split('T').first,
        'due_time': dueTime != null
            ? '${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> map, {List<int> reminderOffsets = const []}) {
    TimeOfDay? t;
    final ts = map['due_time'] as String?;
    if (ts != null && ts.isNotEmpty) {
      final parts = ts.split(':');
      t = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return Task(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      categoryId: map['category_id'] as int?,
      priority: TaskPriorityX.fromValue(map['priority'] as String? ?? 'medium'),
      status: TaskStatusX.fromValue(map['status'] as String? ?? 'pending'),
      dueDate: DateTime.parse(map['due_date'] as String),
      dueTime: t,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'] as String) : null,
      reminderOffsets: reminderOffsets,
    );
  }
}

const List<int> reminderOffsetChoices = [0, 5, 15, 30, 60, 1440];

String reminderOffsetLabel(int minutes) {
  switch (minutes) {
    case 0:
      return 'دقیقاً هنگام انجام کار';
    case 5:
      return '۵ دقیقه قبل';
    case 15:
      return '۱۵ دقیقه قبل';
    case 30:
      return '۳۰ دقیقه قبل';
    case 60:
      return '۱ ساعت قبل';
    case 1440:
      return '۱ روز قبل';
    default:
      return '$minutes دقیقه قبل';
  }
}
