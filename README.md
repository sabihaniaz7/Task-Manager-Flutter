# Task Manager

 A clean, minimal Flutter task manager with smart reminders, dark mode, and a home screen widget

![Flutter](https://img.shields.io/badge/Flutter-3.38.6-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10.7-0175C2?style=flat-square&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-6.0+%20(API%2023+)-3DDC84?style=flat-square&logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

---

## Preview

<!-- markdownlint-disable MD033 -->
| | |
| :---: | :---: |
| **Add Task (Dark)** | **Add Task (Light)** |
| <img src="images/addDark.png" width="270" alt="Add Task Dark Mode"> | <img src="images/addLight.png" width="270" alt="Add Task Light Mode"> |
| **Reminder System** | |
| <img src="images/reminder.png" width="270" alt="Reminder System"> | |
<!-- markdownlint-enable MD033 -->

---

## Features

- **Task Management** — Create, edit, delete tasks with title, description, and date range
- **Smart Reminders** — Per-task custom reminders with 4 modes:
  - On due day (single-day tasks)
  - Day before due
  - Daily reminders until due date
  - Custom X days before due
- **Pick your reminder time** — Time picker per task, not a global setting
- **Dark / Light Mode** — Toggle instantly from the home screen header
- **Color-coded Cards** — 8 pastel colors auto-assigned uniquely per task
- **Swipe Gestures** — Swipe right to complete, swipe left to delete
- **Expandable Cards** — Tap any card to expand and see full details + actions
- **Home Screen Widget** — Glanceable widget showing your latest active task and count
- **Overdue Detection** — Overdue tasks get a badge automatically
- **Sort Options** — Sort by start date, end date, created date, or overdue first
- **Persistent Storage** — All tasks saved locally using SharedPreferences
- **Tabs** — All Tasks / Active / Completed views

---

## Screenshots

| Light Mode | Dark Mode | Add Task | Reminder |
| --- | --- | --- | --- |
| ![light]() | ![dark]() | ![add]() | ![reminder]() |

---

## Architecture

```dart
lib/
├── main.dart                  # App entry + ThemeModeNotifier
├── models/
│   └── task.dart              # Task model + ReminderMode enum
├── providers/
│   └── task_provider.dart     # State management (Provider pattern)
├── screens/
│   ├── home_screen.dart       # Main screen with tabs + sort sheet
│   ├── add_task_screen.dart   # Create new task
│   └── edit_task_screen.dart  # Edit existing task
├── services/
│   ├── notification_service.dart  # Local notifications + scheduling
│   └── storage_service.dart       # SharedPreferences persistence
├── utils/
│   ├── app_theme.dart         # All colors, sizes, themes (no hardcoding)
│   └── date_helper.dart       # Date formatting helpers
└── widgets/
    ├── task_card.dart         # Expandable task card with swipe gestures
    └── reminder_section.dart  # Collapsible reminder picker UI

android/app/src/main/
├── kotlin/.../TaskWidgetProvider.kt   # Home screen widget
└── res/
    ├── layout/task_widget.xml         # Widget layout
    ├── xml/task_widget_info.xml       # Widget metadata
    └── drawable/widget_background.xml # Widget background shape
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0` (Used 3.10.7)
- Android Studio or VS Code
- Android device / emulator (Android 6.0+ / API 23+)

### Installation

#### 1. Clone the repo

```bash
git clone https://github.com/sabihaniaz7/task-manager.git
cd task-manager
```

#### 2. Install dependencies

```bash
flutter pub get
```

#### 3. Run the app

```bash
flutter run
```

---

## 📦 Dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| `provider` | ^6.1.5+1 | State management |
| `shared_preferences` | ^2.5.4 | Local data persistence |
| `flutter_local_notifications` | ^20.1.0 | Scheduled notifications |
| `flutter_timezone` | ^5.0.1 | Device timezone detection |
| `timezone` | ^0.10.1 | Timezone-aware scheduling |
| `uuid` | ^4.5.3 | Unique task IDs |
| `intl` | ^0.20.2 | Date formatting |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## Notification System

Every task gets up to 2 notifications:

| Trigger | What fires |
| --- | --- |
| Task created | Instant confirmation (3 sec delay) |
| Single-day task | Reminder at your chosen time on due day |
| Multi-day — Day before | 9 AM (or chosen time) the day before due |
| Multi-day — Daily | Every day from start to due at chosen time |
| Multi-day — Custom | X days before due at chosen time |

Notifications are automatically cancelled when a task is completed or deleted.

---

## Home Screen Widget

Add the widget from your launcher's widget picker. It displays:

- Your latest active task title
- Due date
- Total active task count

Tapping the widget opens the app directly.

---

## Theming

All colors, font sizes, spacing, and border radii are defined centrally in `app_theme.dart` — nothing is hardcoded in widgets. The app supports both light and dark themes with smooth animated transitions.

---

## License

```text
MIT License — free to use, modify, and distribute.
```

---

## Built With

- [Flutter](https://flutter.dev)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [provider](https://pub.dev/packages/provider)

---

Made with ❤️ using Flutter
