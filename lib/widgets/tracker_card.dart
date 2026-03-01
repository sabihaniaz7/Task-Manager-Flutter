import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/models/tracker.dart';
import 'package:taskmanager/providers/tracker_provider.dart';
import 'package:taskmanager/screens/tracker_detail_screen.dart';
import 'package:taskmanager/utils/app_theme.dart';

class TrackerCard extends StatelessWidget {
  final Tracker trackerEntry;
  const TrackerCard({super.key, required this.trackerEntry});

  // Colors
  Color _cardColor(BuildContext context) {
    final base = Color(
      AppColors.cardPalette[trackerEntry.colorIndex %
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
      AppColors.cardPalette[trackerEntry.colorIndex %
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
    final entry = trackerEntry;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final barColor = _barColor(context);

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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackerDetailScreen(trackerEntry: entry),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // streak bar positioned to stretch
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: _streakBar(context, entry),
              ),
              // Main content shifted to the right
              Padding(
                padding: const EdgeInsets.only(left: 42),
                // padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.fontCaption),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title row + streak badge
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.currentStreak > 0) ...[
                            const SizedBox(width: 8),
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 10),

                      // ── 7-day strip ──────────────────
                      _sevenDayStrip(context, entry, barColor),
                    ],
                  ),
                ),
              ),

              // ── Right arrow hint ─────────────────────
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.subtextColor(context).withValues(alpha: 0.5),
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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

  Widget _streakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
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

  Widget _sevenDayStrip(BuildContext context, Tracker entry, Color barColor) {
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
        final doneColor = barColor;
        final missedBorderColor = barColor.withValues(alpha: 0.5);
        final missedBgColor = barColor.withValues(alpha: 0.12);
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
              const SizedBox(height: 4),
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
                    shape: BoxShape.circle,
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
                          size: 14,
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

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        title: const Text('Delete Tracker?'),
        content: Text(
          'Delete "${trackerEntry.title}"? All history will be lost.',
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
