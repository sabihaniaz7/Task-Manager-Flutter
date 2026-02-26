import 'dart:convert';

import 'package:flutter/material.dart';

// Reminder mode
enum ReminderMode {
  none, //No reminder
  onceDayBefore, // 1 reminder: day before at chosen time
  onDueDate, // 1-day tasks: reminder at due date at chosen time
  daily, //every day from start until end at chosen time
  customDays, //X days before due date at chosen time
}

class Task {
  final String id;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  bool isCompleted;
  int colorIndex;
  int notificationStartId;
  int notificationReminderId;
  // Reminder fields--------------------------------
  ReminderMode reminderMode;
  int reminderHour; // 0-23,default 9
  int reminderMinute; // 0-59,default 0
  int customDaysBefore; // only used when mode == customDays

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.isCompleted = false,
    this.colorIndex = 0,
    this.notificationStartId = 0,
    this.notificationReminderId = 0,
    this.reminderMode = ReminderMode.none,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.customDaysBefore = 1,
  });

  bool get isOverdue {
    final now = DateTime.now();
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return !isCompleted && now.isAfter(end);
  }

  bool get isSingleDay =>
      startDate.year == endDate.year &&
      startDate.month == endDate.month &&
      startDate.day == endDate.day;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    bool? isCompleted,
    int? colorIndex,
    int? notificationStartId,
    int? notificationReminderId,
    ReminderMode? reminderMode,
    int? reminderHour,
    int? reminderMinute,
    int? customDaysBefore,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      colorIndex: colorIndex ?? this.colorIndex,
      notificationStartId: notificationStartId ?? this.notificationStartId,
      notificationReminderId:
          notificationReminderId ?? this.notificationReminderId,
      reminderMode: reminderMode ?? this.reminderMode,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      customDaysBefore: customDaysBefore ?? this.customDaysBefore,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
    'colorIndex': colorIndex,
    'notificationStartId': notificationStartId,
    'notificationReminderId': notificationReminderId,
    'reminderMode': reminderMode.index,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'customDaysBefore': customDaysBefore,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    createdAt: DateTime.parse(json['createdAt']),
    isCompleted: json['isCompleted'] ?? false,
    colorIndex: json['colorIndex'] ?? 0,
    notificationStartId: json['notificationStartId'] ?? 0,
    notificationReminderId: json['notificationReminderId'] ?? 0,
    reminderMode: ReminderMode.values[json['reminderMode'] ?? 0],
    reminderHour: json['reminderHour'] ?? 9,
    reminderMinute: json['reminderMinute'] ?? 0,
    customDaysBefore: json['customDaysBefore'] ?? 1,
  );

  String toJsonString() => jsonEncode(toJson());
  factory Task.fromJsonString(String s) => Task.fromJson(jsonDecode(s));
}
