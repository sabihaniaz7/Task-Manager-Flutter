import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  Color _barColor(BuildContext context, Task task) {
    final base = Color(
      AppColors.cardPalette[task.colorIndex % AppColors.cardPalette.length],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness(isDark ? 0.46 : 0.50)
        .withSaturation(0.68)
        .toColor();
  }

  Color _subtextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B8D0) : const Color(0xFF3A4255);
  }

  String _reminderModeLabel(Task task) {
    switch (task.reminderMode) {
      case ReminderMode.none:
        return 'No reminder';
      case ReminderMode.onDueDate:
        return 'At ${_fmtTime(task.reminderHour, task.reminderMinute)}';
      case ReminderMode.onceDayBefore:
        return '1 day before at ${_fmtTime(task.reminderHour, task.reminderMinute)}';
      case ReminderMode.daily:
        return 'Daily at ${_fmtTime(task.reminderHour, task.reminderMinute)}';
      case ReminderMode.customDays:
        return '${task.customDaysBefore} days before at ${_fmtTime(task.reminderHour, task.reminderMinute)}';
    }
  }

  String _fmtTime(int h, int m) {
    final period = h < 12 ? 'AM' : 'PM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    final min = m.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  String _daysStatus(Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(
      task.endDate.year,
      task.endDate.month,
      task.endDate.day,
    );
    final diff = end.difference(today).inDays;
    if (task.isCompleted) return 'Completed ✓';
    if (diff < 0) return 'Overdue by ${-diff} day${-diff == 1 ? '' : 's'}';
    if (diff == 0) return 'Due today';
    return '$diff day${diff == 1 ? '' : 's'} remaining';
  }

  double _progressValue(Task task) {
    if (task.isSingleDay) return task.isCompleted ? 1.0 : 0.0;
    final now = DateTime.now();
    final start = task.startDate;
    final end = task.endDate;
    final total = end.difference(start).inDays;
    if (total <= 0) return task.isCompleted ? 1.0 : 0.0;
    final elapsed = now.difference(start).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (_, provider, _) {
        // Always get fresh task from provider
        final t = provider.allTasks.firstWhere(
          (e) => e.id == task.id,
          orElse: () => task,
        );
        return _buildScreen(context, t, provider);
      },
    );
  }

  Widget _buildScreen(BuildContext context, Task t, TaskProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final barColor = _barColor(context, t);
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final progress = _progressValue(t);
    final statusText = _daysStatus(t);
    final isOverdue = t.isOverdue;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall + 2,
                        ),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditTaskScreen(task: t),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusButton,
                        ),
                        border: Border.all(color: theme.dividerColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: AppSizes.fontCaption,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Body ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Mark Complete card ───────────────
                    GestureDetector(
                      onTap: () => provider.toggleComplete(t.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: t.isCompleted
                              ? barColor.withValues(alpha: isDark ? 0.18 : 0.12)
                              : surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusCard,
                          ),
                          border: Border.all(
                            color: t.isCompleted
                                ? barColor.withValues(alpha: 0.45)
                                : theme.dividerColor,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (t.isCompleted ? barColor : Colors.black)
                                  .withValues(alpha: isDark ? 0.2 : 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Animated circle icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.isCompleted
                                    ? barColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: t.isCompleted
                                      ? barColor
                                      : _subtextColor(
                                          context,
                                        ).withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                t.isCompleted
                                    ? Icons.check_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: t.isCompleted
                                    ? Colors.white
                                    : _subtextColor(context),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.isCompleted
                                        ? 'Completed!'
                                        : 'Mark as Complete',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: t.isCompleted
                                          ? barColor
                                          : theme.textTheme.titleMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.isCompleted
                                        ? 'Tap to mark as incomplete'
                                        : 'Tap to complete this task',
                                    style: TextStyle(
                                      fontSize: AppSizes.fontCaption,
                                      color: _subtextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Progress + Status ────────────────
                    if (!t.isSingleDay) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusCard,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.05,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontSize: AppSizes.fontCaption,
                                    fontWeight: FontWeight.w700,
                                    color: _subtextColor(context),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (isOverdue
                                                ? AppColors.danger
                                                : t.isCompleted
                                                ? barColor
                                                : barColor)
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isOverdue
                                          ? AppColors.danger
                                          : t.isCompleted
                                          ? barColor
                                          : barColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: t.isCompleted ? 1.0 : progress,
                                minHeight: 8,
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isOverdue
                                      ? AppColors.danger
                                      : t.isCompleted
                                      ? barColor
                                      : barColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Info card ────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusCard,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.05,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            context,
                            icon: Icons.calendar_today_rounded,
                            label: 'Start Date',
                            value: DateHelper.formatShort(t.startDate),
                            barColor: theme.colorScheme.primary,
                          ),
                          _divider(context),
                          _infoRow(
                            context,
                            icon: Icons.event_rounded,
                            label: 'Due Date',
                            value: DateHelper.formatShort(t.endDate),
                            barColor: theme.colorScheme.primary,
                          ),
                          if (t.reminderMode != ReminderMode.none) ...[
                            _divider(context),
                            _infoRow(
                              context,
                              icon: Icons.notifications_rounded,
                              label: 'Reminder',
                              value: _reminderModeLabel(t),
                              barColor: theme.colorScheme.primary,
                            ),
                          ],
                          if (t.isSingleDay) ...[
                            _divider(context),
                            _infoRow(
                              context,
                              icon: Icons.flag_rounded,
                              label: 'Status',
                              value: statusText,
                              barColor: isOverdue
                                  ? AppColors.danger
                                  : theme.colorScheme.primary,
                              valueColor: isOverdue
                                  ? AppColors.danger
                                  : t.isCompleted
                                  ? barColor
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Description ──────────────────────
                    if (t.description.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusCard,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.05,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOTES',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _subtextColor(context),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color barColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: barColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontCaption,
                fontWeight: FontWeight.w600,
                color: _subtextColor(context),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.fontCaption,
              fontWeight: FontWeight.w700,
              color:
                  valueColor ?? Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(height: 1, color: Theme.of(context).dividerColor);
  }
}
