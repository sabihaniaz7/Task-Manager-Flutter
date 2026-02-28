import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/providers/tracker_provider.dart';
import 'package:taskmanager/utils/app_theme.dart';

class AddTrackerScreen extends StatefulWidget {
  const AddTrackerScreen({super.key});

  @override
  State<AddTrackerScreen> createState() => _AddTrackerScreenState();
}

class _AddTrackerScreenState extends State<AddTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await context.read<TrackerProvider>().addEntry(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      reminderEnabled: _reminderEnabled,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Goal',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const .all(AppSizes.spacingXL),
          children: [
            const SizedBox(height: AppSizes.spacingS),
            _label(context, 'TITLE *'),
            const SizedBox(height: AppSizes.spacingXS),
            TextFormField(
              controller: _titleController,
              autofocus: false,
              style: theme.textTheme.titleMedium,
              textCapitalization: TextCapitalization.sentences,

              decoration: InputDecoration(hintText: 'Drink water, Exercise...'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSizes.spacingL),

            _label(context, 'DESCRIPTION'),
            const SizedBox(height: AppSizes.spacingS),
            TextFormField(
              controller: _descriptionController,
              style: theme.textTheme.bodyMedium,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: InputDecoration(hintText: 'Optional Details...'),
            ),
            const SizedBox(height: AppSizes.spacingL),
            // Reminder Section
            _label(context, 'DAILY REMINDER'),
            const SizedBox(height: AppSizes.spacingS),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                border: Border.all(
                  color: _reminderEnabled
                      ? theme.colorScheme.primary.withValues(alpha: 0.35)
                      : theme.dividerColor,
                  width: _reminderEnabled ? 1.5 : 1,
                ),
              ),

              child: Column(
                mainAxisSize: .min,
                children: [
                  Padding(
                    padding: const .symmetric(
                      horizontal: AppSizes.spacingL,
                      vertical: AppSizes.spacingM,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _reminderEnabled
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  )
                                : theme.dividerColor.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_rounded,
                            size: 18,
                            color: _reminderEnabled
                                ? theme.colorScheme.primary
                                : theme.textTheme.labelSmall?.color,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Text(
                                'Daily Reminder',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                ),
                              ),

                              Text(
                                _reminderEnabled
                                    ? 'Every day at ${_formatTime(_reminderTime)}'
                                    : 'Tap to enable',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _reminderEnabled
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.8,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _reminderEnabled,
                          onChanged: (v) =>
                              setState(() => _reminderEnabled = v),
                          activeThumbColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  if (_reminderEnabled) ...[
                    Divider(height: 1, color: theme.dividerColor),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Padding(
                        padding: const .symmetric(
                          horizontal: AppSizes.spacingL,
                          vertical: AppSizes.spacingM,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppSizes.spacingS),
                            Text(
                              _formatTime(_reminderTime),
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              'Tap to change',
                              style: theme.textTheme.labelSmall,
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: theme.textTheme.labelSmall?.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: AppSizes.fontTitle,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.labelMedium);
}
