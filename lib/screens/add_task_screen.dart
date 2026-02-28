import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/models/task.dart';
import 'package:taskmanager/providers/task_provider.dart';
import 'package:taskmanager/services/notification_service.dart';
import 'package:taskmanager/utils/app_theme.dart';
import 'package:taskmanager/widgets/reminder_section.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;
  //Reminder State
  ReminderMode _reminderMode = ReminderMode.none;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _customDays = 1;
  bool get _isSingleDay =>
      _startDate.year == _endDate.year &&
      _startDate.month == _endDate.month &&
      _startDate.day == _endDate.day;
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Called when the user taps Save.
  // Flow: explain notifications → request permission → save task.
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Only ask for permission if we haven't already obtained it.
    final notifService = NotificationService();
    if (!notifService.permissionGranted && _reminderMode != ReminderMode.none) {
      // Show our own explanation dialog BEFORE triggering the OS prompt.
      // This is the recommended UX pattern: give users context first so
      // they understand *why* the app needs the permission and are more
      // likely to tap Allow on the real system dialog that follows.
      final shouldRequest = await _showPermissionRationale();
      if (shouldRequest == true) {
        await notifService.requestPermission();
        // Note: if they deny, _permissionGranted stays false and
        // scheduleTaskNotifications() will simply skip scheduling.
        // The task is still saved — notifications are optional.
      }
    }

    if (!mounted) return;

    await context.read<TaskProvider>().addTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      reminderMode: _reminderMode,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
      customDaysBefore: _customDays,
    );

    if (mounted) Navigator.pop(context);
  }

  // Our custom rationale dialog — shown BEFORE the OS permission prompt.
  // Returns true if user wants to proceed, false/null if they skip.
  Future<bool?> _showPermissionRationale() async {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSizes.spacingXL,
          AppSizes.spacingXL,
          AppSizes.spacingXL,
          0,
        ),
        content: Column(
          mainAxisSize: .min,
          children: [
            //Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'Enable Reminders?',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              'Allow notifications so your task reminders arrive on time.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingS),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSizes.spacingL,
          AppSizes.spacingS,
          AppSizes.spacingL,
          AppSizes.spacingL,
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          // "Skip" — task saves without notifications
          TextButton(
            child: Text(
              'Skip',
              style: TextStyle(color: theme.textTheme.labelSmall?.color),
            ),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          // "Allow" — triggers the OS permission prompt
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall + 2),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacingXL,
                vertical: AppSizes.spacingM,
              ),
            ),
            child: Text(
              'Allow Notifications',
              style: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkBg
                    : Colors.white,
                fontWeight: .w700,
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Task",
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
            _fieldLabel(context, 'TASK TITLE *'),
            const SizedBox(height: AppSizes.spacingS),
            TextFormField(
              controller: _titleController,
              autofocus: false,
              decoration: _inputDecoration(context, 'Enter task title...'),
              style: theme.textTheme.titleMedium,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSizes.spacingXL),
            _fieldLabel(context, "DESCRIPTION"),
            const SizedBox(height: AppSizes.spacingS),
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(context, 'Add a description...'),
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.spacingXL),
            // --Date Pickers --
            _fieldLabel(context, 'DURATION'),
            const SizedBox(height: AppSizes.spacingS),
            Row(
              children: [
                Expanded(
                  child: _buildDateTile(
                    context,
                    'START DATE',
                    _startDate,
                    true,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingXL),
                Expanded(
                  child: _buildDateTile(context, 'END DATE', _endDate, false),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingXL),
            // --Reminder --
            _fieldLabel(context, 'REMINDER'),
            const SizedBox(height: AppSizes.spacingS),
            ReminderSection(
              isSingleDay: _isSingleDay,
              initialMode: _reminderMode,
              initialTime: _reminderTime,
              initialCustomDays: _customDays,
              onChanged: (config) {
                setState(() {
                  _reminderMode = config.mode;
                  _reminderTime = config.time;
                  _customDays = config.customDays;
                });
              },
            ),
            const SizedBox(height: AppSizes.spacingXL),

            /// Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.brightness == Brightness.dark
                      ? AppColors.darkBg
                      : Colors.white,
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
                        'Save Task',
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

  Widget _fieldLabel(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingM + 2,
      ),
    );
  }

  Widget _buildDateTile(
    BuildContext context,
    String label,
    DateTime date,
    bool isStart,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _pickDate(isStart),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingM + 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSizes.spacingS),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: AppSizes.iconS,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.spacingXS + 2),
                Text(_formatDate(date), style: theme.textTheme.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
