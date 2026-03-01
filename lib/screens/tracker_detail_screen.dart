import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracker.dart';
import '../providers/tracker_provider.dart';
import '../utils/app_theme.dart';
import 'edit_tracker_screen.dart';

class TrackerDetailScreen extends StatefulWidget {
  final Tracker trackerEntry;
  const TrackerDetailScreen({super.key, required this.trackerEntry});

  @override
  State<TrackerDetailScreen> createState() => _TrackerDetailScreenState();
}

class _TrackerDetailScreenState extends State<TrackerDetailScreen> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() => setState(
    () => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1),
  );

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_displayMonth.year, _displayMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() => _displayMonth = next);
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _displayMonth.isBefore(DateTime(now.year, now.month));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final barColor = _barColor(context);
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Consumer<TrackerProvider>(
      builder: (_, provider, __) {
        // Always get fresh entry from provider
        final entry = provider.entries.firstWhere(
          (e) => e.id == widget.trackerEntry.id,
          orElse: () => widget.trackerEntry,
        );

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                  child: Row(
                    children: [
                      // Back button
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
                      // Title
                      Expanded(
                        child: Text(
                          entry.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Edit button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditTrackerScreen(trackerEntry: entry),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: barColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusButton,
                            ),
                            border: Border.all(
                              color: barColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: barColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: AppSizes.fontCaption,
                                  fontWeight: FontWeight.w700,
                                  color: barColor,
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

                // ── Scrollable body ───────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stats row ───────────────────────
                        Row(
                          children: [
                            _statCard(
                              context,
                              icon: '🔥',
                              label: 'Current Streak',
                              value: '${entry.currentStreak} days',
                              color: AppColors.warning,
                              surface: surface,
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              context,
                              icon: '✅',
                              label: 'Total Done',
                              value: '${entry.doneDays} / ${entry.totalDays}',
                              color: AppColors.success,
                              surface: surface,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Calendar card ───────────────────
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
                                color: Colors.black.withOpacity(
                                  isDark ? 0.3 : 0.06,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Month navigation
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _monthNavBtn(
                                    context,
                                    icon: Icons.chevron_left_rounded,
                                    onTap: _prevMonth,
                                    enabled: true,
                                    surface: surface,
                                    theme: theme,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        _monthName(_displayMonth.month),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontSize: 18),
                                      ),
                                      Text(
                                        '${_displayMonth.year}',
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                  _monthNavBtn(
                                    context,
                                    icon: Icons.chevron_right_rounded,
                                    onTap: _canGoNext ? _nextMonth : null,
                                    enabled: _canGoNext,
                                    surface: surface,
                                    theme: theme,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Weekday headers
                              Row(
                                children:
                                    [
                                          'Mon',
                                          'Tue',
                                          'Wed',
                                          'Thu',
                                          'Fri',
                                          'Sat',
                                          'Sun',
                                        ]
                                        .map(
                                          (d) => Expanded(
                                            child: Center(
                                              child: Text(
                                                d,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: _subtextColor(context),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),

                              const SizedBox(height: 10),

                              // Calendar grid
                              _buildCalendarGrid(context, entry, barColor),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Legend ──────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusButton,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _legendItem(barColor, 'Done'),
                              const SizedBox(width: 20),
                              _legendItem(
                                AppColors.danger.withOpacity(0.4),
                                'Missed',
                              ),
                              const SizedBox(width: 20),
                              _legendItem(
                                isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                                'Future / N/A',
                              ),
                            ],
                          ),
                        ),

                        if (entry.description.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusButton,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notes',
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.description,
                                  style: theme.textTheme.bodyMedium,
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
      },
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    Tracker entry,
    Color barColor,
  ) {
    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstDay = DateTime(year, month, 1);
    final leadingEmpties = (firstDay.weekday - 1) % 7; // Mon = 0
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      entry.startDate.year,
      entry.startDate.month,
      entry.startDate.day,
    );

    final totalCells = leadingEmpties + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              if (cellIndex < leadingEmpties ||
                  cellIndex >= leadingEmpties + daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final dayNum = cellIndex - leadingEmpties + 1;
              final date = DateTime(year, month, dayNum);
              final isToday = date == today;
              final isFuture = date.isAfter(today);
              final isBeforeStart = date.isBefore(startDate);
              final done = entry.isDayOn(date);
              final isCurrentMonth = date.month == _displayMonth.month;

              return Expanded(
                child: GestureDetector(
                  onTap: isBeforeStart || isFuture || !isCurrentMonth
                      ? null
                      : () => context.read<TrackerProvider>().toggleDate(
                          entry.id,
                          date,
                        ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isBeforeStart || isFuture
                          ? Colors.transparent
                          : done
                          ? barColor.withOpacity(0.85)
                          : AppColors.danger.withOpacity(0.12),
                      border: isToday
                          ? Border.all(color: barColor, width: 2)
                          : isBeforeStart || isFuture
                          ? null
                          : Border.all(
                              color: done
                                  ? barColor.withOpacity(0.6)
                                  : AppColors.danger.withOpacity(0.25),
                              width: 1,
                            ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.w900
                                : FontWeight.w600,
                            color: isBeforeStart || isFuture
                                ? _subtextColor(context).withOpacity(0.3)
                                : done
                                ? Colors.white
                                : isToday
                                ? barColor
                                : _subtextColor(context),
                          ),
                        ),
                        if (!isBeforeStart && !isFuture)
                          Icon(
                            done ? Icons.check_rounded : Icons.close_rounded,
                            size: 9,
                            color: done
                                ? Colors.white70
                                : AppColors.danger.withOpacity(0.4),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required Color color,
    required Color surface,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _monthNavBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
    required Color surface,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall + 2),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _subtextColor(context),
          ),
        ),
      ],
    );
  }

  Color _subtextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF8890B0) : const Color(0xFF606878);
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
