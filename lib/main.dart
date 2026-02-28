import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/providers/task_provider.dart';
import 'package:taskmanager/providers/tracker_provider.dart';
import 'package:taskmanager/screens/splash_screen.dart';
import 'package:taskmanager/services/notification_service.dart';
import 'package:taskmanager/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  final saved = await ThemeModeNotifier.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(
          create: (_) => TrackerProvider()..loadTrackingData(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeModeNotifier(saved)),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeModeNotifier>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.mode,
      builder: (context, child) {
        // Resolve actual brightness for AnimatedTheme
        final brightness = themeNotifier.mode == ThemeMode.system
            ? MediaQuery.platformBrightnessOf(context)
            : themeNotifier.mode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light;
        return AnimatedTheme(
          data: brightness == Brightness.dark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
