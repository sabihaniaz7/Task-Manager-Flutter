import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/providers/tracker_provider.dart';
import 'package:taskmanager/utils/app_theme.dart';
import 'package:taskmanager/widgets/tracker_card.dart';

enum TrackerSortOption { newest, streak, completion }

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => TrackerScreenState();
}

class TrackerScreenState extends State<TrackerScreen> {
  TrackerSortOption _sort = TrackerSortOption.newest;
  // Called from MainScreen via GlobalKey
  void showSortSheet([BuildContext? parentContext]) =>
      _showSortSheet(parentContext);

  List _sorted(List entries) {
    final list = List.of(entries);
    switch (_sort) {
      case TrackerSortOption.newest:
        list.sort((a, b) => b.startDate.compareTo(a.startDate));
      case TrackerSortOption.streak:
        list.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
      case TrackerSortOption.completion:
        list.sort((a, b) {
          final aRatio = a.totalDays == 0 ? 0.0 : a.doneDays / a.totalDays;
          final bRatio = b.totalDays == 0 ? 0.0 : b.doneDays / b.totalDays;
          return bRatio.compareTo(aRatio);
        });
    }
    return list;
  }

  void _showSortSheet([BuildContext? parentContext]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusSheet),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSizes.spacingXL,
            AppSizes.spacingM,
            AppSizes.spacingXL,
            AppSizes.spacingXXL +
                MediaQuery.of(parentContext ?? context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort Trackers',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              ...[
                (
                  TrackerSortOption.newest,
                  'Newest First',
                  Icons.access_time_rounded,
                ),
                (
                  TrackerSortOption.streak,
                  'Highest Streak',
                  Icons.local_fire_department_rounded,
                ),
                (
                  TrackerSortOption.completion,
                  'Best Completion',
                  Icons.bar_chart_rounded,
                ),
              ].map((opt) {
                final isSelected = _sort == opt.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() => _sort = opt.$1);
                    setModalState(() {});
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingL,
                      vertical: AppSizes.spacingM + 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.08)
                          : theme.dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusButton,
                      ),
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          opt.$3,
                          size: AppSizes.iconM,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.labelSmall?.color,
                        ),
                        const SizedBox(width: AppSizes.spacingM),
                        Expanded(
                          child: Text(
                            opt.$2,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            size: AppSizes.iconM,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackerProvider>(
      builder: (_, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = _sorted(provider.entries);
        if (entries.isEmpty) {
          return _emptyState(context);
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingXL,
            AppSizes.spacingL,
            AppSizes.spacingXL,
            120,
          ),
          itemBuilder: (ctx, i) => TrackerCard(trackerEntry: entries[i]),
          separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacingM),
          itemCount: entries.length,
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.repeat_rounded,
              size: 32,
              color: theme.textTheme.labelSmall?.color,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            'No Goals yet.\nTap + to create one!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
