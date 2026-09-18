import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon/neon_nav_bar.dart';
import '../widgets/neon/neon_button.dart';
import '../widgets/neon/motion.dart';
import 'dashboard/dashboard_screen.dart';
import 'tasks/task_list_screen.dart';
import 'tasks/task_form_screen.dart';
import 'projects/projects_screen.dart';
import 'planner/daily_planner_screen.dart';
import 'profile/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _dataLoaded = false;

  final _screens = const [
    DashboardScreen(),
    TaskListScreen(),
    ProjectsScreen(),
    DailyPlannerScreen(),
    SettingsScreen(embedded: true),
  ];

  static const _items = [
    NeonNavItem(
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      label: 'خانه',
      color: AppColors.green,
    ),
    NeonNavItem(
      icon: Icons.checklist_rounded,
      activeIcon: Icons.checklist_rtl_rounded,
      label: 'وظایف',
      color: AppColors.blue,
    ),
    NeonNavItem(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'پروژه‌ها',
      color: AppColors.purple,
    ),
    NeonNavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer_rounded,
      label: 'تایمر',
      color: AppColors.coral,
    ),
    NeonNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'پروفایل',
      color: AppColors.teal,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _dataLoaded = true;
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        Future.microtask(() => context.read<TaskProvider>().load(userId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: _index, children: _screens),
          ),
          // دکمه‌ی شناور «وظیفه‌ی جدید» — فقط روی تب‌های خانه/وظایف/پروژه‌ها
          if (_index <= 2)
            Positioned(
              left: 22,
              bottom: 104 + MediaQuery.of(context).padding.bottom,
              child: NeonFab(
                onPressed: () => Navigator.of(context)
                    .push(neonRoute(const TaskFormScreen())),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NeonNavBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: _items,
        ),
      ),
    );
  }
}
