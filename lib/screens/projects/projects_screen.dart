import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/category_model.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import '../../widgets/neon/neon_field.dart';
import '../tasks/task_list_screen.dart';

const List<String> _projectPaletteHex = [
  '#22C55E',
  '#3B82F6',
  '#A855F7',
  '#FF6B6B',
  '#00D4AA',
];

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final t = NeonTokens.of(context);
    final categories = taskProvider.categories;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 4,
            16,
            150,
          ),
          children: [
            FadeSlideIn(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'پروژه‌ها',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: t.ink,
                      ),
                    ),
                  ),
                  _NewProjectButton(),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (categories.isEmpty)
              const EmptyState(
                icon: Icons.folder_off_outlined,
                message: 'هنوز پروژه‌ای نساخته‌ای',
                hint: 'با دکمه‌ی «پروژه جدید» شروع کن',
                color: AppColors.purple,
              )
            else
              ...List.generate(categories.length, (i) {
                final cat = categories[i];
                final tasks =
                    taskProvider.tasks.where((x) => x.categoryId == cat.id).toList();
                final done =
                    tasks.where((x) => x.status == TaskStatus.completed).length;
                final progress = tasks.isEmpty ? 0.0 : done / tasks.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FadeSlideIn(
                    delayMs: 50 * (i < 8 ? i : 8),
                    child: _ProjectCard(
                      category: cat,
                      total: tasks.length,
                      done: done,
                      progress: progress,
                      onTap: () => Navigator.of(context).push(
                        neonRoute(TaskListScreen(initialCategoryId: cat.id)),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final TaskCategory category;
  final int total;
  final int done;
  final double progress;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.category,
    required this.total,
    required this.done,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final color = category.colorValue;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: t.isDark ? AppColors.surfaceCard : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border(
              right: BorderSide(color: color, width: 4),
              top: BorderSide(color: t.glassBorder),
              bottom: BorderSide(color: t.glassBorder),
              left: BorderSide(color: t.glassBorder),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    total == 0 ? '۰/۰ وظیفه' : '${faNum(done)}/${faNum(total)} وظیفه',
                    style: TextStyle(fontSize: 11, color: t.inkMuted),
                  ),
                  const Spacer(),
                  Icon(Icons.north_west_rounded, size: 16, color: t.inkFaint),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: t.ink,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: t.isDark
                      ? Colors.white.withOpacity(0.07)
                      : const Color(0xFFEDEDF0),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${faNum((progress * 100).round())}٪ تکمیل شده',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: t.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewProjectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: Icons.add_rounded,
      color: AppColors.green,
      onTap: () => _showAddProjectSheet(context),
    );
  }

  void _showAddProjectSheet(BuildContext context) {
    final ctrl = TextEditingController();
    String selectedHex = _projectPaletteHex.first;
    final ownerId = context.read<AuthProvider>().currentUser?.id;
    if (ownerId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => GlassCard(
            radius: AppRadius.lg,
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'پروژه‌ی جدید', color: AppColors.purple),
                NeonField(
                  controller: ctrl,
                  label: 'نام پروژه',
                  icon: Icons.folder_open_rounded,
                  accent: AppColors.purple,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _projectPaletteHex.map((hex) {
                    final color = Color(
                      int.parse('FF${hex.replaceFirst('#', '')}', radix: 16),
                    );
                    final selected = selectedHex == hex;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedHex = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                NeonButton(
                  label: 'ایجاد پروژه',
                  icon: Icons.add_rounded,
                  gradient: const LinearGradient(
                    colors: [AppColors.green, AppColors.teal],
                  ),
                  glowColor: AppColors.green,
                  onPressed: () {
                    final name = ctrl.text.trim();
                    if (name.isEmpty) return;
                    context.read<TaskProvider>().addCategory(
                          TaskCategory(
                            name: name,
                            color: selectedHex,
                            icon: 'project',
                            ownerId: ownerId,
                          ),
                        );
                    Navigator.pop(sheetCtx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
