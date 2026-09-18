import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// یک جلسه‌ی تمرکز تکمیل‌شده — برای نمودار هفتگی و فید فعالیت
class FocusSession {
  final DateTime time;
  final int minutes;
  final String? taskTitle;
  FocusSession({required this.time, required this.minutes, this.taskTitle});

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String(),
        'm': minutes,
        'k': taskTitle,
      };

  factory FocusSession.fromJson(Map<String, dynamic> j) => FocusSession(
        time: DateTime.parse(j['t'] as String),
        minutes: j['m'] as int,
        taskTitle: j['k'] as String?,
      );
}

/// آمار تمرکز کاربر — دقایق امروز، مجموع کل، میانگین روزانه و رکورد
/// روزهای متوالی؛ همه به‌صورت محلی و پایدار (SharedPreferences).
class FocusStatsProvider extends ChangeNotifier {
  static const _kTodayDate = 'focus_today_date';
  static const _kTodayMinutes = 'focus_today_minutes';
  static const _kSessionsToday = 'focus_sessions_today';
  static const _kTotalMinutes = 'focus_total_minutes';
  static const _kActiveDays = 'focus_active_days';
  static const _kRecordStreak = 'focus_record_streak';
  static const _kLog = 'focus_log';

  String _todayDate = '';
  int _todayMinutes = 0;
  int _sessionsToday = 0;
  int _totalMinutes = 0;
  int _activeDays = 0;
  int _recordStreak = 0;
  List<FocusSession> _log = [];

  int get todayMinutes => _todayMinutes;
  int get sessionsToday => _sessionsToday;
  double get totalHours => _totalMinutes / 60.0;
  int get recordStreak => _recordStreak;
  double get averageDailyMinutes =>
      _activeDays == 0 ? 0 : _totalMinutes / _activeDays;
  List<FocusSession> get recentSessions => List.unmodifiable(_log.reversed);

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final storedDate = prefs.getString(_kTodayDate) ?? '';

    _totalMinutes = prefs.getInt(_kTotalMinutes) ?? 0;
    _activeDays = prefs.getInt(_kActiveDays) ?? 0;
    _recordStreak = prefs.getInt(_kRecordStreak) ?? 0;

    if (storedDate == today) {
      _todayDate = storedDate;
      _todayMinutes = prefs.getInt(_kTodayMinutes) ?? 0;
      _sessionsToday = prefs.getInt(_kSessionsToday) ?? 0;
    } else {
      // روز عوض شده — شمارنده‌ی امروز صفر می‌شود
      _todayDate = today;
      _todayMinutes = 0;
      _sessionsToday = 0;
    }

    final rawLog = prefs.getStringList(_kLog) ?? const [];
    _log = rawLog
        .map((s) {
          try {
            return FocusSession.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<FocusSession>()
        .toList();

    notifyListeners();
  }

  Future<void> recordSession({required int minutes, String? taskTitle}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());

    if (_todayDate != today) {
      _todayDate = today;
      _todayMinutes = 0;
      _sessionsToday = 0;
      _activeDays += 1;
    } else if (_sessionsToday == 0) {
      // اولین جلسه‌ی همین امروز (بعد از بارگذاری اپ)
      _activeDays += 1;
    }

    _todayMinutes += minutes;
    _sessionsToday += 1;
    _totalMinutes += minutes;

    _log.add(FocusSession(
      time: DateTime.now(),
      minutes: minutes,
      taskTitle: taskTitle,
    ));
    if (_log.length > 60) {
      _log = _log.sublist(_log.length - 60);
    }

    await prefs.setString(_kTodayDate, _todayDate);
    await prefs.setInt(_kTodayMinutes, _todayMinutes);
    await prefs.setInt(_kSessionsToday, _sessionsToday);
    await prefs.setInt(_kTotalMinutes, _totalMinutes);
    await prefs.setInt(_kActiveDays, _activeDays);
    await prefs.setStringList(
      _kLog,
      _log.map((s) => jsonEncode(s.toJson())).toList(),
    );

    notifyListeners();
  }

  /// اگر رکورد روز متوالی جدیدی (از TaskProvider) بزرگ‌تر از رکورد
  /// ذخیره‌شده باشد، آن را به‌روزرسانی می‌کند.
  Future<void> registerStreak(int currentStreak) async {
    if (currentStreak <= _recordStreak) return;
    _recordStreak = currentStreak;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRecordStreak, _recordStreak);
    notifyListeners();
  }
}
