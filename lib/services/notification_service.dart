import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const _permKey = 'notif_permission_granted';
  //Tracks whether the user has granted permission to receive notifications- consulted before scheduling notifications
  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  // INIT - call once from main()
  Future<void> init() async {
    // load the full timezone database
    tz.initializeTimeZones();
    // Ask the device which timezone it's actually in, then tell the
    // timezone package. Without this, tz.local defaults to UTC and
    // alarms will drift by your UTC offset during DST transitions.
    // final String deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimeZone.identifier));

    //  Wire up the plugin. On iOS, we pass false for all permission flags
    //    here — we'll ask explicitly via requestPermission() at a better
    //    moment (after the user has context), not cold on app launch.

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    // Restore persisted permission state so scheduling works after restart
    final prefs = await SharedPreferences.getInstance();
    _permissionGranted = prefs.getBool(_permKey) ?? false;

    // 4. On Android we can also verify the actual current permission state
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      final granted = await androidImpl.areNotificationsEnabled() ?? false;
      _permissionGranted = granted;
      await prefs.setBool(_permKey, granted);
    }
  }
  // ─────────────────────────────────────────────
  // PERMISSION — call this at a contextual moment
  // (e.g. when user creates their first task, or
  //  from a Settings screen with an explanation).
  // Returns true if permission was granted.
  // ─────────────────────────────────────────────

  Future<bool> requestPermission() async {
    bool granted = false;
    // Android 13+ (API 33+)
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      final result = await androidImplementation
          .requestNotificationsPermission();
      granted = result ?? false;
      // Exact alarm permission (Android 12+). Without this, alarms can be
      // delayed by the system when the device is in battery saver mode.
      await androidImplementation.requestExactAlarmsPermission();
    }

    // Request permissions for iOS explicitly
    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      final result = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    }
    _permissionGranted = granted;
    // Persist so we don't ask again and scheduling works after restart
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permKey, granted);
    return granted;
  }

  // ─────────────────────────────────────────────
  // SCHEDULE
  // Always fires: creation confirmation (3 sec after save)
  //
  // Then based on reminderMode:
  //
  //  ReminderMode.none
  //    → No extra reminders
  //
  //  ReminderMode.onDueDay  (single-day tasks)
  //    → 1 reminder at chosen time on the due day
  //
  //  ReminderMode.onceDayBefore  (multi-day tasks)
  //    → 1 reminder at chosen time, 1 day before end date
  //
  //  ReminderMode.daily  (multi-day tasks)
  //    → Reminder every day from startDate until endDate at chosen time
  //    → Each day gets its own notification ID (startId + day offset)
  //
  //  ReminderMode.customDays  (multi-day tasks)
  //    → 1 reminder at chosen time, N days before end date
  //
  // ─────────────────────────────────────────────
  Future<void> scheduleTaskNotifications(Task task) async {
    await cancelTaskNotifications(task);

    // Don't schedule if the user explicitly denied permission.
    if (!_permissionGranted) return;
    final now = DateTime.now();

    // ── Notification 1: Immediate creation confirmation ──
    // Fires ~3 seconds after task is saved, regardless of time of day.
    // Gives user immediate feedback that the task was created successfully.
    final creationNotifyTime = now.add(const Duration(seconds: 3));

    await _scheduleNotification(
      id: task.notificationStartId,
      title: 'Task Manager',
      body: '"${task.title}" — Due ${_formatDate(task.endDate)}',
      scheduledDate: creationNotifyTime,
    );
    if (task.reminderMode == ReminderMode.none) return;

    final h = task.reminderHour;
    final m = task.reminderMinute;

    switch (task.reminderMode) {
      // Sindgle day: remind at chosen time on due day
      case ReminderMode.onDueDate:
        final remind = DateTime(
          task.endDate.year,
          task.endDate.month,
          task.endDate.day,
          h,
          m,
        );
        if (remind.isAfter(now)) {
          await _scheduleNotification(
            id: task.notificationReminderId,
            title: 'Task Due Today!',
            body: '"${task.title}" is due today.',
            scheduledDate: remind,
          );
        }
        break;
      // ── Multi-day: 1 day before due at chosen time ──
      case ReminderMode.onceDayBefore:
        final dayBefore = task.endDate.subtract(const Duration(days: 1));
        final remind = DateTime(
          dayBefore.year,
          dayBefore.month,
          dayBefore.day,
          h,
          m,
        );
        if (remind.isAfter(now)) {
          await _scheduleNotification(
            id: task.notificationReminderId,
            title: 'Due Tomorrow!',
            body: '"${task.title}" is due tomorrow.',
            scheduledDate: remind,
          );
        }
        break;
      // ── Multi-day: daily reminder from start until due ──
      // Schedule one notification per day in the range.
      // IDs: reminderId + day offset (0, 1, 2, ...)
      // Max 30 days to avoid notification ID exhaustion.
      case ReminderMode.daily:
        final duration = task.endDate.difference(task.startDate).inDays;
        final days = duration.clamp(0, 30);
        for (int i = 0; i < days; i++) {
          final day = task.startDate.add(Duration(days: i));
          final remind = DateTime(day.year, day.month, day.day, h, m);
          if (remind.isAfter(now)) {
            await _scheduleNotification(
              id: task.notificationReminderId + i,
              title: i == days ? 'Task Due Today!' : 'Task Reminder',
              body: i == days
                  ? '"${task.title}" is due today!'
                  : '"${task.title}"  — due ${_formatDate(task.endDate)}.',
              scheduledDate: remind,
            );
          }
        }
        break;

      // ── Multi-day: X days before due at chosen time ──
      case ReminderMode.customDays:
        final daysBefore = task.customDaysBefore.clamp(1, 365);
        final targetDay = task.endDate.subtract(Duration(days: daysBefore));
        final remind = DateTime(
          targetDay.year,
          targetDay.month,
          targetDay.day,
          h,
          m,
        );
        if (remind.isAfter(now)) {
          await _scheduleNotification(
            id: task.notificationReminderId,
            title: 'Task Due in $daysBefore day${daysBefore > 1 ? "s" : ""}',
            body: '"${task.title}" is due on ${_formatDate(task.endDate)}.',
            scheduledDate: remind,
          );
        }
        break;
      case ReminderMode.none:
        break;
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        // tz.local is now correctly set to the device's real timezone,
        // so DST transitions are handled automatically by the package.
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_manager_channel',
            'Task Manager',
            channelDescription: 'Task reminders and notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Scheduling can fail if exact alarm permission was revoked mid-session.
      // Fail silently — the task is still saved, just without a notification.
      debugPrint('[NotificationService] Schedule failed id=$id: $e');
    }
  }
  // ── CANCEL ───────────────────────────────────────────────
  // Cancel creation notif + all reminder notifs (daily can have up to 31)

  Future<void> cancelTaskNotifications(Task task) async {
    await _plugin.cancel(id: task.notificationStartId);
    // Cancel up to 31 daily IDs (reminderId + 0..30)
    for (int i = 0; i <= 30; i++) {
      await _plugin.cancel(id: task.notificationReminderId + i);
    }
  }

  // ═══════════════════════════════════════════════════════
  // TRACKER NOTIFICATIONS
  // ═══════════════════════════════════════════════════════
  //
  // Each tracker has one notificationId.
  // - Creation confirmation fires 3 seconds after save (id)
  // - If reminderEnabled: 30 daily reminders at
  //   reminderHour:reminderMinute (ids: id+1 .. id+30)
  Future<void> scheduleTrackerNotifications(dynamic tracker) async {
    await cancelTrackerNotifications(tracker);
    if (!_permissionGranted) return;

    final now = DateTime.now();
    final id = tracker.notificationId as int;

    // ── Creation confirmation ──
    await _scheduleNotification(
      id: id,
      title: 'Task Manager',
      body: '"${tracker.title}" — tracking starts today!',
      scheduledDate: now.add(const Duration(seconds: 3)),
    );

    if (!(tracker.reminderEnabled as bool)) return;

    final h = tracker.reminderHour as int;
    final m = tracker.reminderMinute as int;

    // ── Schedule 30 upcoming daily reminders ──
    int scheduled = 0;
    for (int i = 0; scheduled < 30; i++) {
      final day = now.add(Duration(days: i));
      final remind = DateTime(day.year, day.month, day.day, h, m);
      if (remind.isAfter(now)) {
        await _scheduleNotification(
          id: id + 1 + scheduled,
          title: 'Task Manager',
          body: '"${tracker.title}"',
          scheduledDate: remind,
        );
        scheduled++;
      }
    }
  }

  Future<void> cancelTrackerNotifications(dynamic tracker) async {
    final id = tracker.notificationId as int;
    await _plugin.cancel(id: id);
    for (int i = 1; i <= 30; i++) {
      await _plugin.cancel(id: id + i);
    }
  }
}
