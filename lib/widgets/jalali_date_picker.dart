import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/jalali_helper.dart';
import '../theme/app_theme.dart';
import '../utils/fa_num.dart';
import 'neon/glass.dart';
import 'neon/neon_button.dart';

Future<DateTime?> showJalaliDatePicker({
  required BuildContext context,
  DateTime? initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) => _JalaliDatePickerDialog(initialDate: initialDate),
  );
}

class _JalaliDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  const _JalaliDatePickerDialog({this.initialDate});

  @override
  State<_JalaliDatePickerDialog> createState() =>
      _JalaliDatePickerDialogState();
}

class _JalaliDatePickerDialogState extends State<_JalaliDatePickerDialog> {
  late Jalali _displayedMonth;
  late Jalali _selected;

  @override
  void initState() {
    super.initState();
    _selected = Jalali.fromDateTime(widget.initialDate ?? DateTime.now());
    _displayedMonth = Jalali(_selected.year, _selected.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    final firstOfMonth = Jalali(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = firstOfMonth.monthLength;
    final leadingEmpty = firstOfMonth.weekday;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: GlassCard(
        radius: AppRadius.lg,
        blur: 28,
        glow: NeonPalette.violet,
        glowOpacity: 0.26,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GlassIconButton(
                  icon: Icons.chevron_right_rounded,
                  size: 34,
                  onTap: () => setState(
                    () => _displayedMonth = _displayedMonth.addMonths(-1),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_displayedMonth.monthName} ${faNum(_displayedMonth.year)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: t.ink,
                    ),
                  ),
                ),
                GlassIconButton(
                  icon: Icons.chevron_left_rounded,
                  size: 34,
                  onTap: () => setState(
                    () => _displayedMonth = _displayedMonth.addMonths(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: [
                for (final d in jalaliWeekdayShort)
                  Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 11,
                        color: t.inkFaint,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                for (int i = 0; i < leadingEmpty; i++) const SizedBox.shrink(),
                for (int day = 1; day <= daysInMonth; day++) _dayCell(day),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: NeonOutlineButton(
                    label: 'انصراف',
                    color: NeonPalette.rose,
                    height: 46,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeonButton(
                    label: 'تأیید',
                    height: 46,
                    onPressed: () =>
                        Navigator.pop(context, _selected.toDateTime()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(int day) {
    final t = NeonTokens.of(context);
    final jd = Jalali(_displayedMonth.year, _displayedMonth.month, day);
    final isSelected = jd.isSameDate(_selected);
    final isToday = jd.isSameDate(Jalali.now());

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selected = jd);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: isSelected ? NeonPalette.brand : null,
          border: Border.all(
            color: isToday && !isSelected
                ? NeonPalette.cyan.withOpacity(0.8)
                : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: NeonPalette.violet.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: -3,
                  ),
                ]
              : null,
        ),
        child: Text(
          faNum(day),
          style: TextStyle(
            fontSize: 12.5,
            fontWeight:
                isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? Colors.white : t.ink,
          ),
        ),
      ),
    );
  }
}
