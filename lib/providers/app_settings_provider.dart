import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

/// تنظیمات کلی اپ که در صفحه‌ی «تنظیمات» ویرایش می‌شوند: اعلان‌ها و
/// مدت زمان‌های پیش‌فرض تایمر تمرکز — روی همه‌ی صفحات مؤثرند.
class AppSettingsProvider extends ChangeNotifier {
  static const _kNotifications = 'settings_notifications_enabled';
  static const _kFocusMinutes = 'settings_focus_minutes';
  static const _kRestMinutes = 'settings_rest_minutes';

  bool _notificationsEnabled = true;
  int _focusMinutes = 25;
  int _restMinutes = 5;

  bool get notificationsEnabled => _notificationsEnabled;
  int get focusMinutes => _focusMinutes;
  int get restMinutes => _restMinutes;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_kNotifications) ?? true;
    _focusMinutes = prefs.getInt(_kFocusMinutes) ?? 25;
    _restMinutes = prefs.getInt(_kRestMinutes) ?? 5;
    NotificationService.instance.notificationsEnabled = _notificationsEnabled;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    NotificationService.instance.notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
    notifyListeners();
  }

  Future<void> setFocusMinutes(int value) async {
    _focusMinutes = value.clamp(5, 120);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFocusMinutes, _focusMinutes);
    notifyListeners();
  }

  Future<void> setRestMinutes(int value) async {
    _restMinutes = value.clamp(1, 60);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRestMinutes, _restMinutes);
    notifyListeners();
  }
}
