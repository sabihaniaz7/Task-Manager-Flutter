import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/providers/tracker_provider.dart';
import 'package:taskmanager/utils/app_theme.dart';
import 'package:taskmanager/widgets/tracker_card.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackerProvider>(
      builder: (_, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = provider.entries;
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
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSizes.spacingM),
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
              color: theme.dividerColor.withOpacity(0.5),
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
