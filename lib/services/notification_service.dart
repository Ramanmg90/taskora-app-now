import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../db/db_helper.dart';
import '../models/task_model.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// سوییچ سراسری اعلان‌ها — از تنظیمات خوانده و همگام می‌شود.
  bool notificationsEnabled = true;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Tehran'));
    } catch (_) {
      // در صورت نبود دیتابیس منطقه زمانی، از محلی پیش‌فرض دستگاه استفاده می‌شود
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'taskora_reminders',
      'یادآوری وظایف تسکورا',
      description: 'اعلان‌های یادآوری برای وظایف تسکورا',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const timerChannel = AndroidNotificationChannel(
      'taskora_timer',
      'تایمر تمرکز تسکورا',
      description: 'اعلان پایان تایمر تمرکز',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(timerChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  int _notifIdFor(int taskId, int offsetMinutes) => (taskId * 10000) + offsetMinutes;

  /// اعلان فوری (بدون زمان‌بندی) — برای پایان تایمر تمرکز
  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!notificationsEnabled) return;
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'taskora_timer',
          'تایمر تمرکز تسکورا',
          channelDescription: 'اعلان پایان تایمر تمرکز',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleForTask(Task task) async {
    await cancelForTask(task.id!);
    if (!notificationsEnabled) return;
    if (task.status == TaskStatus.completed || task.status == TaskStatus.cancelled) return;

    for (final offset in task.reminderOffsets) {
      final fireTime = task.dueDateTime.subtract(Duration(minutes: offset));
      if (fireTime.isBefore(DateTime.now())) continue;

      final id = _notifIdFor(task.id!, offset);
      final scheduled = tz.TZDateTime.from(fireTime, tz.local);

      await _plugin.zonedSchedule(
        id,
        'یادآوری: ${task.title}',
        offset == 0
            ? 'الان موعد انجام این وظیفه است'
            : 'تا ${reminderOffsetLabel(offset)} موعد این وظیفه فرا می‌رسد',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'taskora_reminders',
            'یادآوری وظایف تسکورا',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelForTask(int taskId) async {
    for (final offset in reminderOffsetChoices) {
      await _plugin.cancel(_notifIdFor(taskId, offset));
    }
  }

  /// دوباره زمان‌بندی همه یادآوری‌های فعال کاربر (مثلاً بعد از باز شدن مجدد اپ)
  Future<void> rescheduleAll(int ownerId) async {
    if (!notificationsEnabled) return;
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'tasks',
      where: "owner_id = ? AND status NOT IN ('completed','cancelled')",
      whereArgs: [ownerId],
    );
    for (final row in rows) {
      final remRows =
          await db.query('reminders', where: 'task_id = ?', whereArgs: [row['id']]);
      final offsets = remRows.map((r) => r['offset_minutes'] as int).toList();
      if (offsets.isEmpty) continue;
      final task = Task.fromMap(row, reminderOffsets: offsets);
      await scheduleForTask(task);
    }
  }
}
