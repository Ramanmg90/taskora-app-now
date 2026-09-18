import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Subtask {
  final String id;
  final String title;
  final bool done;
  const Subtask({required this.id, required this.title, this.done = false});

  Subtask copyWith({String? title, bool? done}) =>
      Subtask(id: id, title: title ?? this.title, done: done ?? this.done);

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
  factory Subtask.fromJson(Map<String, dynamic> j) => Subtask(
        id: j['id'] as String,
        title: j['title'] as String,
        done: j['done'] as bool? ?? false,
      );
}

/// چک‌لیست زیروظایف — سبک، بدون نیاز به تغییر schema دیتابیس؛
/// هر وظیفه یک کلید مستقل در SharedPreferences دارد.
class SubtaskService {
  String _key(int taskId) => 'subtasks_task_$taskId';

  Future<List<Subtask>> load(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key(taskId)) ?? const [];
    return raw
        .map((s) {
          try {
            return Subtask.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Subtask>()
        .toList();
  }

  Future<void> save(int taskId, List<Subtask> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key(taskId),
      items.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
