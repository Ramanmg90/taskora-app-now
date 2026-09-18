import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/focus_stats_provider.dart';
import 'providers/app_settings_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تجربه‌ی لبه‌به‌لبه تا شفق نئونی پشت نوارهای سیستم دیده شود
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await NotificationService.instance.init();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  final settingsProvider = AppSettingsProvider();
  await settingsProvider.load();

  final focusStatsProvider = FocusStatsProvider();
  await focusStatsProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: focusStatsProvider),
      ],
      child: const TaskoraApp(),
    ),
  );
}
