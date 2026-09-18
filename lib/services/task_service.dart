import '../db/db_helper.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

class TaskService {
  Future<List<int>> _remindersFor(int taskId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('reminders', where: 'task_id = ?', whereArgs: [taskId]);
    return rows.map((r) => r['offset_minutes'] as int).toList();
  }

  Future<List<Task>> getTasks(int ownerId, {String? statusFilter, int? categoryId}) async {
    final db = await DBHelper.instance.database;
    final where = StringBuffer('owner_id = ?');
    final args = <dynamic>[ownerId];
    if (statusFilter != null) {
      where.write(' AND status = ?');
      args.add(statusFilter);
    }
    if (categoryId != null) {
      where.write(' AND category_id = ?');
      args.add(categoryId);
    }
    final rows = await db.query('tasks',
        where: where.toString(), whereArgs: args, orderBy: 'due_date ASC, due_time ASC');
    final tasks = <Task>[];
    for (final row in rows) {
      final reminders = await _remindersFor(row['id'] as int);
      tasks.add(Task.fromMap(row, reminderOffsets: reminders));
    }
    return tasks;
  }

  Future<Task?> getTaskById(int id) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final reminders = await _remindersFor(id);
    return Task.fromMap(rows.first, reminderOffsets: reminders);
  }

  Future<Task> createTask(Task task) async {
    final db = await DBHelper.instance.database;
    final map = task.toMap()..remove('id');
    final id = await db.insert('tasks', map);
    for (final offset in task.reminderOffsets) {
      await db.insert('reminders', {'task_id': id, 'offset_minutes': offset, 'is_sent': 0});
    }
    return (await getTaskById(id))!;
  }

  Future<Task> updateTask(Task task) async {
    final db = await DBHelper.instance.database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
    await db.delete('reminders', where: 'task_id = ?', whereArgs: [task.id]);
    for (final offset in task.reminderOffsets) {
      await db.insert('reminders', {'task_id': task.id, 'offset_minutes': offset, 'is_sent': 0});
    }
    return (await getTaskById(task.id!))!;
  }

  Future<void> deleteTask(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markCompleted(int id, {required bool completed}) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'tasks',
      {
        'status': completed ? 'completed' : 'pending',
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getStats(int ownerId) async {
    final tasks = await getTasks(ownerId);
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == TaskStatus.completed).length;
    final pending = tasks.where((t) => t.status == TaskStatus.pending).length;
    final overdue = tasks.where((t) => t.isOverdue).length;
    return {'total': total, 'completed': completed, 'pending': pending, 'overdue': overdue};
  }

  // ---- دسته‌بندی‌ها ----

  Future<List<TaskCategory>> getCategories(int ownerId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'categories',
      where: 'owner_id IS NULL OR owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'owner_id IS NULL DESC, name ASC',
    );
    return rows.map((r) => TaskCategory.fromMap(r)).toList();
  }

  Future<TaskCategory> createCategory(TaskCategory category) async {
    final db = await DBHelper.instance.database;
    final id = await db.insert('categories', category.toMap()..remove('id'));
    return TaskCategory.fromMap({...category.toMap(), 'id': id});
  }

  Future<void> deleteCategory(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('categories', where: 'id = ? AND owner_id IS NOT NULL', whereArgs: [id]);
  }
}
