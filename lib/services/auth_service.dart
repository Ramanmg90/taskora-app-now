import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db/db_helper.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  static String _hash(String password) {
    // نمک ثابت ساده برای اپ محلی تک‌کاربره روی دستگاه (کافی برای ذخیره‌سازی محلی، نه یک سرویس آنلاین)
    final bytes = utf8.encode('taskora_salt_v1::$password');
    return sha256.convert(bytes).toString();
  }

  Future<AppUser> register({
    required String username,
    required String password,
    String? email,
    String? fullName,
  }) async {
    final db = await DBHelper.instance.database;
    final existing = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (existing.isNotEmpty) {
      throw AuthException('این نام کاربری قبلاً ثبت شده است');
    }
    if (username.trim().length < 3) {
      throw AuthException('نام کاربری باید حداقل ۳ کاراکتر باشد');
    }
    if (password.length < 6) {
      throw AuthException('رمز عبور باید حداقل ۶ کاراکتر باشد');
    }

    final user = AppUser(
      username: username.trim(),
      passwordHash: _hash(password),
      email: email,
      fullName: fullName,
    );
    final id = await db.insert('users', user.toMap()..remove('id'));
    await db.insert('notification_settings', {
      'user_id': id,
      'local_notifications_enabled': 1,
      'default_reminder_minutes': 15,
    });
    return AppUser.fromMap({...user.toMap(), 'id': id});
  }

  Future<AppUser> login({required String username, required String password}) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username.trim()]);
    if (rows.isEmpty) {
      throw AuthException('نام کاربری یا رمز عبور اشتباه است');
    }
    final user = AppUser.fromMap(rows.first);
    if (user.passwordHash != _hash(password)) {
      throw AuthException('نام کاربری یا رمز عبور اشتباه است');
    }
    return user;
  }

  Future<AppUser> updateProfile(AppUser user) async {
    final db = await DBHelper.instance.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
    return user;
  }

  Future<void> changePassword(int userId, String newPassword) async {
    if (newPassword.length < 6) {
      throw AuthException('رمز عبور باید حداقل ۶ کاراکتر باشد');
    }
    final db = await DBHelper.instance.database;
    await db.update('users', {'password_hash': _hash(newPassword)},
        where: 'id = ?', whereArgs: [userId]);
  }

  /// حذف کامل حساب کاربری و تمام داده‌های وابسته (وظایف، دسته‌بندی‌ها،
  /// یادآوری‌ها) — به لطف ON DELETE CASCADE در schema، فقط حذف ردیف
  /// کاربر برای پاک‌سازی کامل کافی است.
  Future<void> deleteAccount(int userId) async {
    final db = await DBHelper.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<bool> getNotificationsEnabled(int userId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'notification_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (rows.isEmpty) return true;
    return (rows.first['local_notifications_enabled'] as int? ?? 1) == 1;
  }

  Future<void> setNotificationsEnabled(int userId, bool enabled) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'notification_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (rows.isEmpty) {
      await db.insert('notification_settings', {
        'user_id': userId,
        'local_notifications_enabled': enabled ? 1 : 0,
        'default_reminder_minutes': 15,
      });
    } else {
      await db.update(
        'notification_settings',
        {'local_notifications_enabled': enabled ? 1 : 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
  }
}
