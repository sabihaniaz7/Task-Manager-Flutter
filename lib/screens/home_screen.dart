import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/providers/task_provider.dart';
import 'package:taskmanager/screens/add_task_screen.dart';
import 'package:taskmanager/utils/app_theme.dart';
import 'package:taskmanager/widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildTabBar(context),
                Expanded(child: _buildTabViews()),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            ),
            child: const Icon(Icons.add_rounded, size: AppSizes.iconL),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: .fromLTRB(
        AppSizes.spacingXL,
        AppSizes.spacingXL,
        AppSizes.spacingM,
        AppSizes.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Task Manager', style: theme.textTheme.displaySmall),
                const SizedBox(height: AppSizes.spacingXS),
                Text('Stay Organized', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          // Dark/Light mode toggle
          _HeaderIconButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: () => context.read<ThemeModeNotifier>().toggle(),
          ),
          const SizedBox(width: AppSizes.spacingXS),
          // Sort button
          _HeaderIconButton(
            icon: Icons.tune_rounded,
            onTap: () => _showSortSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXL),
      child: TabBar(
        tabs: const [
          Tab(text: 'All Tasks'),
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
        ],
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.5, color: theme.colorScheme.primary),
          insets: .symmetric(horizontal: 0),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        // labelStyle: const TextStyle(fontSize: 14, fontWeight: .w600),
        // unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: .w400),
        // labelColor: theme.tabBarTheme.labelColor,
        // unselectedLabelColor: theme.tabBarTheme.unselectedLabelColor,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      children: [
        _TaskList(type: _TaskListType.all),
        _TaskList(type: _TaskListType.active),
        _TaskList(type: _TaskListType.completed),
      ],
    );
  }

  void _showSortSheet(BuildContext context) {
    final provider = context.read<TaskProvider>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      // shape: const RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      // ),
      builder: (ctx) => Consumer<TaskProvider>(
        builder: (_, p, _) {
          final theme = Theme.of(ctx);
          return Padding(
            padding: const .fromLTRB(
              AppSizes.spacingXL,
              AppSizes.spacingM,
              AppSizes.spacingXL,
              AppSizes.spacingXXL,
            ),
            child: Column(
              mainAxisSize: .min,
              // crossAxisAlignment: .start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      //  Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),
                Row(
                  children: [
                    Text(
                      'Sort Tasks',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                // const Divider(),
                const SizedBox(height: AppSizes.spacingM),
                ..._sortOptions.map((opt) {
                  final isSelected = p.sortOption == opt['value'];
                  return GestureDetector(
                    onTap: () {
                      provider.setSortOption(opt['value'] as SortOptions);
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
                            opt['icon'] as IconData,
                            size: AppSizes.iconM,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.textTheme.labelSmall?.color,
                          ),
                          const SizedBox(width: AppSizes.spacingM),
                          Expanded(
                            child: Text(
                              opt['label'] as String,
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
          );
        },
      ),
    );
  }

  static const _sortOptions = [
    {
      'label': 'By Start Date',
      'value': SortOptions.startDate,
      'icon': Icons.calendar_today_rounded,
    },
    {
      'label': 'By End Date',
      'value': SortOptions.endDate,
      'icon': Icons.event_rounded,
    },
    {
      'label': 'By Created Date',
      'value': SortOptions.createdDate,
      'icon': Icons.access_time_rounded,
    },
    {
      'label': 'Overdue First',
      'value': SortOptions.overdueFirst,
      'icon': Icons.priority_high_rounded,
    },
  ];
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall + 2),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Icon(
          icon,
          size: AppSizes.iconM,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

enum _TaskListType { all, active, completed }

class _TaskList extends StatelessWidget {
  final _TaskListType type;
  const _TaskList({required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (_, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final tasks = switch (type) {
          _TaskListType.all => provider.allTasks,
          _TaskListType.active => provider.activeTasks,
          _TaskListType.completed => provider.completedTasks,
        };
        if (tasks.isEmpty) {
          return _buildEmptyState(context, type);
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingXL,
            AppSizes.spacingL,
            AppSizes.spacingXL,
            100,
          ),
          itemCount: tasks.length,
          itemBuilder: (ctx, i) => TaskCard(task: tasks[i]),
          separatorBuilder: (_, _) => const SizedBox(height: AppSizes.spacingM),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, _TaskListType type) {
    final theme = Theme.of(context);
    final (icon, message) = switch (type) {
      _TaskListType.all => (
        Icons.task_alt_rounded,
        'No tasks yet.\nTap + to add one!',
      ),
      _TaskListType.active => (
        Icons.check_circle_outline_rounded,
        'No active tasks.\nAll done!',
      ),
      _TaskListType.completed => (
        Icons.history_rounded,
        'No completed tasks yet.',
      ),
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.5),
              shape: .circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: theme.textTheme.labelSmall?.color,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
