import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/models/tracker.dart';
import 'package:taskmanager/providers/tracker_provider.dart';
import 'package:taskmanager/screens/edit_tracker_screen.dart';
import 'package:taskmanager/utils/app_theme.dart';

class TrackerCard extends StatefulWidget {
  final Tracker trackerEntry;
  const TrackerCard({super.key, required this.trackerEntry});

  @override
  State<TrackerCard> createState() => _TrackerCardState();
}

class _TrackerCardState extends State<TrackerCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    _isExpanded ? _controller.forward() : _controller.reverse();
  }

  // Colors
  Color _cardColor(BuildContext context) {
    final base = Color(
      AppColors.cardPalette[widget.trackerEntry.colorIndex %
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

  Color _barColor(BuildContext context) {
    final base = Color(
      AppColors.cardPalette[widget.trackerEntry.colorIndex %
          AppColors.cardPalette.length],
    );
    final hsl = HSLColor.fromColor(base);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return hsl
        .withLightness(isDark ? 0.46 : 0.50)
        .withSaturation(0.68)
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.trackerEntry;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(entry.id),
      background: _swipBg(isDelete: false),
      secondaryBackground: _swipBg(isDelete: true),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          // Archieve(complete)
          context.read<TrackerProvider>().archiveEntry(entry.id);
          return false;
        }
        return await _confirmDelete(context);
      },
      onDismissed: (dir) {
        if (dir == DismissDirection.endToStart) {
          context.read<TrackerProvider>().deleteEntry(entry.id);
        }
      },
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: _isExpanded ? 18 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // left bar with streak ratio
                _streakBar(context, entry),

                //Card content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.fontCaption),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _collapsableContent(context, entry, theme),
                        SizeTransition(
                          sizeFactor: _expandAnimation,
                          axisAlignment: -1,
                          child: _expandedContent(context, entry, theme),
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

  Widget _swipBg({required bool isDelete}) {
    return Container(
      decoration: BoxDecoration(
        color: isDelete ? AppColors.danger : AppColors.success,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      ),
      alignment: isDelete ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        isDelete ? Icons.delete_rounded : Icons.check_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  //Left bar with streak ratio
  Widget _streakBar(BuildContext context, Tracker entry) {
    final barColor = _barColor(context);
    return Container(
      width: 42,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(AppSizes.radiusCard),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${entry.doneDays}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Container(
            width: 16,
            height: 1.5,
            margin: const EdgeInsets.symmetric(vertical: 3),
            color: Colors.white38,
          ),
          Text(
            '${entry.totalDays}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expandedContent(
    BuildContext context,
    Tracker entry,
    ThemeData theme,
  ) {
    return Padding(
      padding: const .only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: Colors.black.withOpacity(0.08), height: 1),
          const SizedBox(height: 12),
          //stats row
          Row(
            children: [
              _statChip(
                context,
                label: 'Done',
                value: '${entry.doneDays}',
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _statChip(
                context,
                label: 'Missed',
                value: '${entry.totalDays - entry.doneDays}',
                color: AppColors.danger,
              ),
              const SizedBox(width: 8),
              _statChip(
                context,
                label: 'Streak',
                value: '${entry.currentStreak}',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          //// Calendar label
          ///
          Text('TAP A DAY TO TOGGLE', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          // Calendar grid
          _calendarGrid(context, entry),
          const SizedBox(height: 10),

          // Action row: archive + edit
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      context.read<TrackerProvider>().archiveEntry(entry.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: entry.isArchived
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.actionBg(context),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusSmall + 2,
                      ),
                      border: entry.isArchived
                          ? Border.all(
                              color: AppColors.success.withOpacity(0.4),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          entry.isArchived
                              ? Icons.check_circle_rounded
                              : Icons.archive_rounded,
                          size: 17,
                          color: entry.isArchived
                              ? AppColors.success
                              : AppColors.actionIconColor(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.isArchived ? 'Completed' : 'Mark Complete',
                          style: TextStyle(
                            fontSize: AppSizes.fontCaption,
                            fontWeight: FontWeight.w700,
                            color: entry.isArchived
                                ? AppColors.success
                                : AppColors.actionIconColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTrackerScreen(trackerEntry: entry),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.actionBg(context),
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusSmall + 2,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 17,
                    color: AppColors.actionIconColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _statChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _collapsableContent(
    BuildContext context,
    Tracker entry,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: entry.isArchived
                      ? TextDecoration.lineThrough
                      : null,
                ),
                maxLines: 1,
                overflow: .ellipsis,
              ),
            ),
            // Streak Fire Badge
            if (entry.currentStreak > 0) ...[
              const SizedBox(width: 6),
              _streakBadge(entry.currentStreak),
            ],
          ],
        ),
        if (entry.description.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            entry.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.subtextColor(context),
            ),
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        // 7 days strip
        _sevenDayStrip(context, entry),
      ],
    );
  }

  Widget _streakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sevenDayStrip(BuildContext context, Tracker entry) {
    final days = entry.last7Days.reversed.toList();
    return Row(
      children: days.map((d) {
        final date = d['date'] as DateTime;
        final done = d['done'] as bool;
        final isBeforeStart = d['isBeforeStart'] as bool;
        final isFuture = d['isFuture'] as bool;
        final isToday =
            Tracker.dateKey(date) == Tracker.dateKey(DateTime.now());
        // Day label
        const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        final dayLabel = dayNames[date.weekday - 1];

        // done = bar color, missed = bar color 20% opacity border
        final barColor = _barColor(context);
        final doneColor = barColor;
        final missedBorderColor = barColor.withOpacity(0.5);
        final missedBgColor = barColor.withOpacity(0.12);
        return Expanded(
          child: Column(
            children: [
              Text(
                dayLabel,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  color: isToday ? barColor : AppColors.subtextColor(context),
                ),
              ),
              const SizedBox(height: 3),
              GestureDetector(
                onTap: isBeforeStart || isFuture
                    ? null
                    : () => context.read<TrackerProvider>().toggleDate(
                        entry.id,
                        date,
                      ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 26,
                  width: 26,
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: isBeforeStart || isFuture
                        ? Colors.transparent
                        : done
                        ? doneColor
                        : missedBgColor,
                    border: isToday || isFuture
                        ? null
                        : Border.all(
                            color: done ? doneColor : missedBorderColor,
                            width: isToday ? 2 : 1.5,
                          ),
                  ),
                  child: isBeforeStart || isFuture
                      ? null
                      : Icon(
                          done ? Icons.check_rounded : Icons.close_rounded,
                          size: 13,
                          color: done ? Colors.white : missedBorderColor,
                        ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _calendarGrid(BuildContext context, Tracker entry) {
    final days = entry.calendarDays;
    if (days.isEmpty) {
      return Center(
        child: Text(
          'Start tracking from today!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    // Fill leading empty cells so first day aligns to correct weekday
    final firstDate = days.first['date'] as DateTime;
    final leadingEmpties = firstDate.weekday - 1; // Mon=1

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekday headers
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: leadingEmpties + days.length,
          itemBuilder: (ctx, i) {
            if (i < leadingEmpties) return const SizedBox();
            final day = days[i - leadingEmpties];
            final date = day['date'] as DateTime;
            final done = day['done'] as bool;
            final isToday = day['isToday'] as bool;
            return GestureDetector(
              onTap: () =>
                  context.read<TrackerProvider>().toggleDate(entry.id, date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.success
                      : AppColors.danger.withOpacity(0.15),
                  border: isToday
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.close_rounded,
                  size: 12,
                  color: done
                      ? Colors.white
                      : AppColors.danger.withOpacity(0.5),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        title: const Text('Delete Tracker?'),
        content: Text(
          'Delete "${widget.trackerEntry.title}"? All history will be lost.',
        ),
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
