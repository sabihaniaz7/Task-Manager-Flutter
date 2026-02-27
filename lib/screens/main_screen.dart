import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanager/screens/add_task_screen.dart';
import 'package:taskmanager/screens/home_screen.dart';
import 'package:taskmanager/utils/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    // TrackerScreen(),
  ];
  void _onAddPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final inactiveColor = isDark
        ? AppColors.darkSubtext
        : AppColors.lightSubtext;
    final activeColor = theme.colorScheme.primary;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      // Bottom nav
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTabChanged: (i) => setState(() => _currentIndex = i),
        onAddPressed: _onAddPressed,
        bgColor: bgColor,
        inactiveColor: inactiveColor,
        activeColor: activeColor,
        isDark: isDark,
      ),
    );
  }
}

// Custom NavBar
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddPressed;
  final Color bgColor;
  final Color inactiveColor;
  final Color activeColor;
  final bool isDark;
  const _BottomNav({
    required this.currentIndex,
    required this.onTabChanged,
    required this.onAddPressed,
    required this.bgColor,
    required this.inactiveColor,
    required this.activeColor,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      // Outer padding for floating effect
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 12),
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Nav Bar Background
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusSheet),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                //Tasks Tab
                Expanded(
                  child: _NavItem(
                    icon: Icons.task_alt_rounded,
                    label: 'Tasks',
                    inactiveColor: inactiveColor,
                    activeColor: activeColor,
                    onTap: () => onTabChanged(0),
                    isActive: currentIndex == 0,
                  ),
                ),
                // Center space for FAB
                const SizedBox(width: 72),
                //Tracker Tab
                Expanded(
                  child: _NavItem(
                    icon: Icons.show_chart_rounded,
                    label: 'Tracker',
                    inactiveColor: inactiveColor,
                    activeColor: activeColor,
                    onTap: () => onTabChanged(1),
                    isActive: currentIndex == 1,
                  ),
                ),
              ],
            ),
          ),
          // Center FAB above nav
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: onAddPressed,
              child: Consumer<ThemeModeNotifier>(
                builder: (_, notifier, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: isDark ? AppColors.darkBg : AppColors.lightBg,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.inactiveColor,
    required this.activeColor,
    required this.onTap,
    required this.isActive,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: .center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusButton),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
