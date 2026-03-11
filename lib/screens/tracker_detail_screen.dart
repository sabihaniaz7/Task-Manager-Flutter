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
  late PageController _pageController;
  late int _pageIndex;
  // Months available: from tracker startDate month up to current month
  late List<DateTime> _months;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final start = DateTime(
      widget.trackerEntry.startDate.year,
      widget.trackerEntry.startDate.month,
    );
    final current = DateTime(now.year, now.month);

    // Build list of all months from start → now
    _months = [];
    DateTime m = start;
    while (!m.isAfter(current)) {
      _months.add(m);
      m = DateTime(m.year, m.month + 1);
    }
    if (_months.isEmpty) _months = [current];

    _pageIndex = _months.length - 1; // Start at current month
    _displayMonth = _months[_pageIndex];
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      builder: (_, provider, _) {
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
                            color: surface,
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusButton,
                            ),
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

                              label: 'Current Streak',
                              value: '${entry.currentStreak}',
                              color: AppColors.warning,
                              surface: surface,
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              context,

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
                          // padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusCard,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.3 : 0.06,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Month Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: _pageIndex > 0
                                          ? () => _pageController.previousPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            )
                                          : null,
                                      child: AnimatedOpacity(
                                        opacity: _pageIndex > 0 ? 1.0 : 0.25,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: surface,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: theme.dividerColor,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.chevron_left_rounded,
                                            size: 20,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _monthName(_displayMonth.month),
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(fontSize: 17),
                                        ),
                                        Text(
                                          '${_displayMonth.year}',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _pageIndex < _months.length - 1
                                          ? () => _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                            )
                                          : null,
                                      child: AnimatedOpacity(
                                        opacity: _pageIndex < _months.length - 1
                                            ? 1.0
                                            : 0.25,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: surface,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: theme.dividerColor,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            size: 20,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Weekday headers
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
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
                                                    color: _subtextColor(
                                                      context,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Calendar Pages Swipable
                              SizedBox(
                                height: _calendarHeight(),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _months.length,
                                  onPageChanged: (i) => setState(() {
                                    _pageIndex = i;
                                    _displayMonth = _months[i];
                                  }),
                                  itemBuilder: (_, i) => _buildCalendarPage(
                                    context,
                                    entry,
                                    barColor,
                                    _months[i],
                                  ),
                                ),
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

  // Calculate a fixed height that fits 6 rows max
  double _calendarHeight() => 6 * 48.0;

  Widget _buildCalendarPage(
    BuildContext context,
    Tracker entry,
    Color barColor,
    DateTime monthDate,
  ) {
    final year = monthDate.year;
    final month = monthDate.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstDay = DateTime(year, month, 1);
    // Sunday = 0 offset
    final leadingEmpties = firstDay.weekday % 7;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      entry.startDate.year,
      entry.startDate.month,
      entry.startDate.day,
    );

    final totalCells = leadingEmpties + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          // Collect all 7 cells info for this row (needed for connector logic)
          final cells = List.generate(7, (colIndex) {
            final cellIndex = rowIndex * 7 + colIndex;
            if (cellIndex < leadingEmpties ||
                cellIndex >= leadingEmpties + daysInMonth) {
              return null; // empty cell
            }
            final dayNum = cellIndex - leadingEmpties + 1;
            final date = DateTime(year, month, dayNum);
            final isToday = date == today;
            final isFuture = date.isAfter(today);
            final isBeforeStart = date.isBefore(startDate);
            final done = entry.isDayOn(date);
            return {
              'dayNum': dayNum,
              'date': date,
              'isToday': isToday,
              'isFuture': isFuture,
              'isBeforeStart': isBeforeStart,
              'done': done,
            };
          });

          return SizedBox(
            height: 48,
            child: Row(
              children: List.generate(7, (colIndex) {
                final cell = cells[colIndex];
                if (cell == null) return const Expanded(child: SizedBox());

                final dayNum = cell['dayNum'] as int;
                final date = cell['date'] as DateTime;
                final isToday = cell['isToday'] as bool;
                final isFuture = cell['isFuture'] as bool;
                final isBeforeStart = cell['isBeforeStart'] as bool;
                final done = cell['done'] as bool;
                final inactive = isBeforeStart || isFuture;

                // Determine left/right connectors for done dates
                final prevCell = colIndex > 0 ? cells[colIndex - 1] : null;
                final nextCell = colIndex < 6 ? cells[colIndex + 1] : null;
                final prevDone =
                    prevCell != null &&
                    (prevCell['done'] as bool) &&
                    !(prevCell['isBeforeStart'] as bool) &&
                    !(prevCell['isFuture'] as bool);
                final nextDone =
                    nextCell != null &&
                    (nextCell['done'] as bool) &&
                    !(nextCell['isBeforeStart'] as bool) &&
                    !(nextCell['isFuture'] as bool);

                final showLeftConnector = done && prevDone && !inactive;
                final showRightConnector = done && nextDone && !inactive;

                return Expanded(
                  child: GestureDetector(
                    onTap: inactive
                        ? null
                        : () => context.read<TrackerProvider>().toggleDate(
                            entry.id,
                            date,
                          ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left connector bar
                        if (showLeftConnector)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Container(
                                height: 34,
                                color: barColor.withValues(alpha: 0.25),
                              ),
                            ),
                          ),

                        // Right connector bar
                        if (showRightConnector)
                          Align(
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Container(
                                height: 34,
                                color: barColor.withValues(alpha: 0.25),
                              ),
                            ),
                          ),

                        // The circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()
                            ..scaleByDouble(
                              done ? 1.05 : 1.0,
                              done ? 1.05 : 1.0,
                              1.0,
                              1.0,
                            ),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: inactive
                                ? Colors.transparent
                                : done
                                ? barColor
                                : Colors.transparent,
                            border: isToday && !done
                                ? Border.all(
                                    color: barColor.withValues(alpha: 0.8),
                                    width: 1.8,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: inactive
                                    ? _subtextColor(
                                        context,
                                      ).withValues(alpha: 0.3)
                                    : done
                                    ? Colors.white
                                    : isToday
                                    ? barColor
                                    : _subtextColor(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
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
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.3
                    : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _subtextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B8D0) : const Color(0xFF3A4255);
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
