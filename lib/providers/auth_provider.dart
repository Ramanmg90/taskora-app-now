import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../db/db_helper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _currentUser;
  bool _loading = true;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get loading => _loading;

  static const _prefKey = 'taskora_current_user_id';

  Future<void> restoreSession() async {
    _loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_prefKey);
    if (userId != null) {
      final db = await DBHelper.instance.database;
      final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
      if (rows.isNotEmpty) {
        _currentUser = AppUser.fromMap(rows.first);
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final user = await _authService.login(username: username, password: password);
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, user.id!);
    notifyListeners();
  }

  Future<void> register({
    required String username,
    required String password,
    String? email,
    String? fullName,
  }) async {
    final user = await _authService.register(
      username: username,
      password: password,
      email: email,
      fullName: fullName,
    );
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, user.id!);
    notifyListeners();
  }

  Future<void> updateProfile(AppUser user) async {
    _currentUser = await _authService.updateProfile(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_currentUser?.id == null) return;
    await _authService.deleteAccount(_currentUser!.id!);
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    notifyListeners();
  }
}
