import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanager/models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> tasksStrings = prefs.getStringList(_tasksKey) ?? [];
    return tasksStrings
        .map((taskString) => Task.fromJsonString(taskString))
        .toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final taskStrings = tasks.map((task) => task.toJsonString()).toList();
    await prefs.setStringList(_tasksKey, taskStrings);
  }
}
