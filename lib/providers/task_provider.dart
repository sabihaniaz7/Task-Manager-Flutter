import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskmanager/models/task.dart';
import 'package:taskmanager/services/notification_service.dart';
import 'package:taskmanager/services/storage_service.dart';
import 'package:uuid/uuid.dart';

enum SortOptions { startDate, endDate, createdDate, overdueFirst }

class TaskProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  final _uuid = const Uuid();
  static const _widgetChannel = MethodChannel('com.example.taskmanager/widget');

  // Tells Android to refresh all home screen widgets
  Future<void> _refreshWidget() async {
    try {
      await _widgetChannel.invokeMethod('refreshWidget');
    } catch (_) {}
  }

  List<Task> _tasks = [];
  SortOptions _sortOption = SortOptions.createdDate;
  bool _isLoading = false;

  List<Task> get allTasks => _sortedTasks(_tasks);
  List<Task> get activeTasks =>
      _sortedTasks(_tasks.where((t) => !t.isCompleted).toList());
  List<Task> get completedTasks =>
      _sortedTasks(_tasks.where((t) => t.isCompleted).toList());
  SortOptions get sortOption => _sortOption;
  bool get isLoading => _isLoading;

  //
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await _storage.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  List<Task> _sortedTasks(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    switch (_sortOption) {
      case SortOptions.startDate:
        sorted.sort((a, b) => a.startDate.compareTo(b.startDate));
      case SortOptions.endDate:
        sorted.sort((a, b) => a.endDate.compareTo(b.endDate));
      case SortOptions.createdDate:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOptions.overdueFirst:
        sorted.sort((a, b) {
          if (a.isOverdue && !b.isOverdue) return -1;
          if (!a.isOverdue && b.isOverdue) return 1;
          return a.endDate.compareTo(b.endDate);
        });
    }
    return sorted;
  }

  int _nextColorIndex() {
    if (_tasks.isEmpty) return 0;
    final palette = 8;
    final usedIndices = _tasks.map((t) => t.colorIndex).toSet();
    for (int i = 0; i < palette; i++) {
      if (!usedIndices.contains(i)) {
        return i;
      }
    }
    final lastColor = _tasks.last.colorIndex;
    return (lastColor + 1) % palette;
  }

  Future<void> addTask({
    required String title,
    String description = '',
    required DateTime startDate,
    required DateTime endDate,
    ReminderMode reminderMode = ReminderMode.none,
    int reminderHour = 9,
    int reminderMinute = 0,
    int customDaysBefore = 1,
  }) async {
    final id = _uuid.v4();
    final notifStartId = DateTime.now().millisecondsSinceEpoch % 100000;
    // Leave a gap of 50 between tasks so daily reminders (up to 31 IDs)
    // never collide with the next task's IDs.
    final notifRemindId = notifStartId + 50;

    final task = Task(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      colorIndex: _nextColorIndex(),
      notificationStartId: notifStartId,
      notificationReminderId: notifRemindId,
      reminderMode: reminderMode,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      customDaysBefore: customDaysBefore,
    );
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    await _notifications.scheduleTaskNotifications(task);
    await _refreshWidget();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _storage.saveTasks(_tasks);
      if (!task.isCompleted) {
        await _notifications.scheduleTaskNotifications(task);
      } else {
        await _notifications.cancelTaskNotifications(task);
      }
      await _refreshWidget();
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await _storage.saveTasks(_tasks);
      if (_tasks[index].isCompleted) {
        await _notifications.cancelTaskNotifications(_tasks[index]);
      } else {
        await _notifications.scheduleTaskNotifications(_tasks[index]);
      }
      await _refreshWidget();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _notifications.cancelTaskNotifications(task);
    _tasks.removeWhere((t) => t.id == id);
    await _storage.saveTasks(_tasks);
    await _refreshWidget();
    notifyListeners();
  }

  void setSortOption(SortOptions option) {
    _sortOption = option;
    notifyListeners();
  }
}
