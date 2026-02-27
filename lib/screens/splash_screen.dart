import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskmanager/screens/main_screen.dart';
import 'package:taskmanager/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _creditFadeAnimation;

  @override
  void initState() {
    super.initState();
    // Hide status bar for full immersive splash
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    // App names fades + slide up
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );
    //credit fade in slighlty after
    _creditFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();

    // Navigate after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // Restore system UI
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const MainScreen(),
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ── Subtle background glow ──────────────────
          Positioned(
            top: -100,
            left: -80,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (_, _) => Opacity(
                opacity: _fadeAnimation.value * 0.15,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -60,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (_, _) => Opacity(
                opacity: _fadeAnimation.value * 0.1,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
          // Center : App Name
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: _slideAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App icon placeholder — replace with icon later
                      // Container(
                      //   width: 72,
                      //   height: 72,
                      //   decoration: BoxDecoration(
                      //     color: primary.withValues(alpha: 0.12),
                      //     borderRadius: BorderRadius.circular(
                      //       AppSizes.radiusCard,
                      //     ),
                      //     border: Border.all(
                      //       color: primary.withValues(alpha: 0.2),
                      //       width: 1.5,
                      //     ),
                      //   ),
                      //   child: Icon(
                      //     Icons.task_alt_rounded,
                      //     size: 40,
                      //     color: primary,
                      //   ),
                      // ),
                      // const SizedBox(height: AppSizes.spacingXL),
                      Text(
                        'Task Manager',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        'Stay Organized. Stay Ahead.',
                        style: TextStyle(
                          fontSize: AppSizes.fontBody,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkSecondary
                              : AppColors.lightSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _creditFadeAnimation,
              builder: (_, _) => Opacity(
                opacity: _creditFadeAnimation.value,
                child: Column(
                  children: [
                    Text(
                      'Developed By',
                      style: TextStyle(
                        fontSize: AppSizes.fontBody,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkSecondary
                            : AppColors.lightSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXS),
                    Text(
                      'Sabiha Niaz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
