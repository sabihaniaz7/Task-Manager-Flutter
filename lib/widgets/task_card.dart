import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../utils/date_helper.dart';
import '../screens/edit_task_screen.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  // ── Card background color ──────────────────────────────────
  Color _cardColor(BuildContext context) {
    final base = Color(
      AppColors.cardPalette[widget.task.colorIndex %
          AppColors.cardPalette.length],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return base;
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness(0.17)
        .withSaturation(hsl.saturation * 0.5)
        .toColor();
  }

  // ── Left bar accent color (richer shade of card color) ─────
  Color _barColor(BuildContext context) {
    final base = Color(
      AppColors.cardPalette[widget.task.colorIndex %
          AppColors.cardPalette.length],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness(isDark ? 0.46 : 0.50)
        .withSaturation(0.68)
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      background: _swipeBg(isComplete: true),
      secondaryBackground: _swipeBg(isComplete: false),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          context.read<TaskProvider>().toggleComplete(task.id);
          return false;
        }
        return await _confirmDelete(context);
      },
      onDismissed: (dir) {
        if (dir == DismissDirection.endToStart) {
          context.read<TaskProvider>().deleteTask(task.id);
        }
      },
      child: GestureDetector(
        onTap: _toggleExpand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: _isExpanded ? 18 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _durationBar(context, task),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _collapsedContent(context, task),
                        SizeTransition(
                          sizeFactor: _expandAnimation,
                          axisAlignment: -1,
                          child: _expandedContent(context, task),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Left duration bar ──────────────────────────────────────
  Widget _durationBar(BuildContext context, Task task) {
    final barColor = _barColor(context);
    final sameDay =
        task.startDate.year == task.endDate.year &&
        task.startDate.month == task.endDate.month &&
        task.startDate.day == task.endDate.day;
    return Container(
      width: 58,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(AppSizes.radiusCard),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spacingL - 2,
          horizontal: AppSizes.spacingS,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _barDate(
              DateHelper.formatDay(task.startDate),
              DateHelper.formatMonth(task.startDate),
            ),
            if (!sameDay) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(width: 16, height: 1.5, color: Colors.white30),
              ),
              _barDate(
                DateHelper.formatDay(task.endDate),
                DateHelper.formatMonth(task.endDate),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _barDate(String day, String month) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: day,
            style: const TextStyle(
              fontSize: AppSizes.fontBody + 1,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: month.toUpperCase(),
            style: const TextStyle(
              fontSize: AppSizes.fontLabel - 1,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  // ── Collapsed card content ─────────────────────────────────
  Widget _collapsedContent(BuildContext context, Task task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.titleColor(context, task.isCompleted),
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: AppColors.titleColor(
                    context,
                    task.isCompleted,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (task.isCompleted) ...[
              const SizedBox(width: AppSizes.spacingS + 2),
              _completedChip(),
            ] else if (task.isOverdue) ...[
              const SizedBox(width: AppSizes.spacingS + 2),
              _overdueChip(),
            ],
          ],
        ),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacingXS + 2),
          Text(
            task.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.bodyColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // const SizedBox(height: AppSizes.spacingS),
        // Row(
        //   children: [
        //     // Icon(
        //     //   Icons.calendar_today_rounded,
        //     //   size: AppSizes.iconS,
        //     //   color: _dateColor(context),
        //     // ),
        //     // const SizedBox(width: AppSizes.spacingXS),
        //     Text(
        //       DateHelper.formatRange(task.startDate, task.endDate),
        //       style: Theme.of(context).textTheme.labelSmall?.copyWith(
        //         color: AppColors.dateColor(context),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _completedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_rounded, size: 9, color: AppColors.success),
          SizedBox(width: 3),
          Text(
            'Done',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overdueChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingS,
        vertical: AppSizes.spacingXS - 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: const Text(
        'Overdue',
        style: TextStyle(
          fontSize: AppSizes.fontMicro,
          fontWeight: FontWeight.w800,
          color: AppColors.danger,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Expanded card content ──────────────────────────────────
  Widget _expandedContent(BuildContext context, Task task) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: .min,
        children: [
          Divider(color: Colors.black.withValues(alpha: 0.08), height: 1),
          // Action row: complete + edit
          Row(
            children: [
              // Mark complete button
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<TaskProvider>().toggleComplete(task.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingM,
                      vertical: AppSizes.spacingS + 2,
                    ),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.actionBg(context),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusSmall + 2,
                      ),
                      border: task.isCompleted
                          ? Border.all(
                              color: AppColors.success.withValues(alpha: 0.4),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          task.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: AppSizes.iconM,
                          color: task.isCompleted
                              ? AppColors.success
                              : AppColors.actionIconColor(context),
                        ),
                        const SizedBox(width: AppSizes.spacingXS + 2),
                        Text(
                          task.isCompleted ? 'Completed' : 'Mark Complete',
                          style: TextStyle(
                            fontSize: AppSizes.fontCaption,
                            fontWeight: FontWeight.w700,
                            color: task.isCompleted
                                ? AppColors.success
                                : AppColors.actionIconColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              // Edit button
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.spacingS + 2),
                  decoration: BoxDecoration(
                    color: AppColors.actionBg(context),
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusSmall + 2,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: AppSizes.iconM,
                    color: AppColors.actionIconColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXS),
        ],
      ),
    );
  }

  Widget _swipeBg({required bool isComplete}) {
    return Container(
      decoration: BoxDecoration(
        color: isComplete ? AppColors.success : AppColors.danger,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      ),
      alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXXL),
      child: Icon(
        isComplete ? Icons.check_rounded : Icons.delete_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        title: const Text('Delete Task?'),
        content: Text('Delete "${widget.task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
