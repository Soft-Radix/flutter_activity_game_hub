import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';
import '../themes/app_theme.dart';
import 'home/home_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'random_picker/random_picker_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: navigationController.selectedIndex.value,
          children: const [
            HomeScreen(),
            RandomPickerScreen(),
            LeaderboardScreen(),
            SettingsScreen(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final isDarkMode = themeController.isDarkMode;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.cardBorderRadius),
              topRight: Radius.circular(AppTheme.cardBorderRadius),
            ),
            child: BottomNavigationBar(
              currentIndex: navigationController.selectedIndex.value,
              backgroundColor: isDarkMode ? AppTheme.cardColorDarkMode : Colors.white,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor:
                  isDarkMode ? AppTheme.lightTextColorDarkMode : AppTheme.lightTextColor,
              type: BottomNavigationBarType.fixed,
              elevation: AppTheme.defaultElevation,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.casino_rounded), label: 'Random'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard_rounded),
                  label: 'Leaderboard',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
              ],
              onTap: (index) => navigationController.changePage(index),
            ),
          ),
        );
      }),
    );
  }
}
