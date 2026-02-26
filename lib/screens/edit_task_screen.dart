import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:taskmanager/widgets/reminder_section.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSaving = false;

  late ReminderMode _reminderMode;
  late TimeOfDay _reminderTime;
  late int _customDays;
  bool get _isSingleDay =>
      _startDate.year == _endDate.year &&
      _startDate.month == _endDate.month &&
      _startDate.day == _endDate.day;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
    _reminderMode = widget.task.reminderMode;
    _reminderTime = TimeOfDay(
      hour: widget.task.reminderHour,
      minute: widget.task.reminderMinute,
    );
    _customDays = widget.task.customDaysBefore;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) => DateFormat('d MMM yyyy').format(date);

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      reminderMode: _reminderMode,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
      customDaysBefore: _customDays,
    );
    await context.read<TaskProvider>().updateTask(updated);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Task',
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
            _label(context, 'TASK TITLE *'),
            const SizedBox(height: AppSizes.spacingS),
            TextFormField(
              controller: _titleController,
              style: theme.textTheme.titleMedium,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Task title...'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSizes.spacingXL),
            _label(context, 'DESCRIPTION'),
            const SizedBox(height: AppSizes.spacingS),
            TextFormField(
              controller: _descriptionController,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Description...'),
            ),
            const SizedBox(height: AppSizes.spacingXL),
            _label(context, 'DURATION'),
            const SizedBox(height: AppSizes.spacingS),
            Row(
              children: [
                Expanded(
                  child: _dateTile(context, 'START DATE', _startDate, true),
                ),
                const SizedBox(width: AppSizes.spacingXL),
                Expanded(
                  child: _dateTile(context, 'END DATE', _endDate, false),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingXL),
            // Reminder Section
            _label(context, 'REMINDER'),
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
            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
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

  Widget _label(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }

  Widget _dateTile(
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
            Text(label, style: theme.textTheme.labelMedium),
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
