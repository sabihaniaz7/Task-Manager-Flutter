import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmanager/models/tracker.dart';
import 'package:taskmanager/services/notification_service.dart';
import 'package:taskmanager/utils/app_theme.dart';
import 'package:uuid/uuid.dart';

/// Provider class for managing tracker entries.
/// Handles persistence using [SharedPreferences] and provides methods to manipulate tracker data.
class TrackerProvider extends ChangeNotifier {
  /// Key used for storing tracking entries in SharedPreferences.
  static const _storageKey = 'tracking_entries';
  static const _widgetChannel = MethodChannel('com.example.taskmanager/widget');

  /// Utility for generating unique identifiers.
  final _uuid = const Uuid();
  final _notifications = NotificationService();

  /// List of all tracker entries (including archived ones).
  List<Tracker> _entries = [];

  /// Flag indicating if data is currently being loaded.
  bool _isLoading = false;

  /// Returns a list of active (non-archived) tracker entries.
  List<Tracker> get entries => _entries.where((t) => !t.isArchived).toList();

  /// Returns a list of archived tracker entries.
  List<Tracker> get archivedEntries =>
      _entries.where((t) => t.isArchived).toList();

  /// Returns true if the provider is currently loading data.
  bool get isLoading => _isLoading;

  Future<void> _refreshWidget() async {
    try {
      await _widgetChannel.invokeMethod('refreshTrackerWidget');
    } catch (_) {}
  }

  /// Loads tracking data from [SharedPreferences].
  Future<void> loadTrackingData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_storageKey) ?? [];
    _entries = list.map((s) => Tracker.fromJsonString(s)).toList();
    _isLoading = false;
    notifyListeners();
  }

  /// Saves the current list of entries to [SharedPreferences].
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _entries.map((t) => t.toJsonString()).toList(),
    );
    await _refreshWidget();
  }

  /// Determines the next available color index from the palette to ensure variety.
  int _nextColorIndex() {
    if (_entries.isEmpty) return 0;
    final used = _entries.map((t) => t.colorIndex).toSet();
    for (int i = 0; i < AppColors.cardPalette.length; i++) {
      if (!used.contains(i)) return i;
    }
    return (_entries.last.colorIndex + 1) % AppColors.cardPalette.length;
  }

  /// Adds a new tracker entry and saves it locally.
  Future<void> addEntry({
    required String title,
    String description = '',
    bool reminderEnabled = false,
    int reminderHour = 9,
    int reminderMinute = 0,
  }) async {
    // Generate a unique notification ID
    final notifId = DateTime.now().millisecondsSinceEpoch % 100000 + 200000;
    final entry = Tracker(
      id: _uuid.v4(),
      title: title,
      description: description,
      colorIndex: _nextColorIndex(),
      startDate: DateTime.now(),
      reminderEnabled: reminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      notificationId: notifId,
    );
    _entries.add(entry);
    await _save();
    notifyListeners();
  }

  /// Updates an existing tracker entry.
  Future<void> updateEntry(Tracker entry) async {
    final i = _entries.indexWhere((t) => t.id == entry.id);
    if (i != -1) {
      _entries[i] = entry;
      await _save();
      notifyListeners();
    }
  }

  /// Toggles the tracked status for a specific date on a tracker.
  Future<void> toggleDate(String id, DateTime date) async {
    final i = _entries.indexWhere((t) => t.id == id);
    if (i != -1) {
      _entries[i].toggleDate(date);
      await _save();
      notifyListeners();
    }
  }

  /// Deletes a tracker entry permanently.
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  /// Archives a tracker entry instead of deleting it.
  Future<void> archiveEntry(String id) async {
    final i = _entries.indexWhere((t) => t.id == id);
    if (i != -1) {
      _entries[i] = _entries[i].copyWith(isArchived: true);
      await _save();
      notifyListeners();
    }
  }
}
