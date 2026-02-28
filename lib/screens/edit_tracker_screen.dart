import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/models/tracker.dart';
import 'package:taskmanager/providers/tracker_provider.dart';
import 'package:taskmanager/utils/app_theme.dart';

class EditTrackerScreen extends StatefulWidget {
  final Tracker trackerEntry;
  const EditTrackerScreen({super.key, required this.trackerEntry});

  @override
  State<EditTrackerScreen> createState() => _EditTrackerScreenState();
}

class _EditTrackerScreenState extends State<EditTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.trackerEntry.title);
    _descController = TextEditingController(
      text: widget.trackerEntry.description,
    );
    _reminderEnabled = widget.trackerEntry.reminderEnabled;
    _reminderTime = TimeOfDay(
      hour: widget.trackerEntry.reminderHour,
      minute: widget.trackerEntry.reminderMinute,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
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
    final updated = widget.trackerEntry.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      reminderEnabled: _reminderEnabled,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
    );
    await context.read<TrackerProvider>().updateEntry(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Tracker',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.spacingXL),
          children: [
            const SizedBox(height: AppSizes.spacingS),
            _label(context, 'TRACKER TITLE *'),
            const SizedBox(height: AppSizes.spacingS),
            TextFormField(
              controller: _titleController,
              style: theme.textTheme.titleMedium,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Tracker title...'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSizes.spacingXL),
            _label(context, 'DESCRIPTION'),
            const SizedBox(height: AppSizes.spacingS),
            TextFormField(
              controller: _descController,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Optional details...',
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),
            _label(context, 'DAILY REMINDER'),
            const SizedBox(height: AppSizes.spacingS),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSizes.radiusButton),
                border: Border.all(
                  color: _reminderEnabled
                      ? theme.colorScheme.primary.withOpacity(0.35)
                      : theme.dividerColor,
                  width: _reminderEnabled ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
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
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : theme.dividerColor.withOpacity(0.5),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      ? theme.colorScheme.primary.withOpacity(
                                          0.8,
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
                          activeColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  if (_reminderEnabled) ...[
                    Divider(height: 1, color: theme.dividerColor),
                    GestureDetector(
                      onTap: _pickTime,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
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
            const SizedBox(height: AppSizes.spacingXXL + 8),
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
                        'Save Changes',
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
