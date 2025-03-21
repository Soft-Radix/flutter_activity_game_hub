import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';
import '../themes/app_theme.dart';
import '../widgets/dark_mode_check.dart';
import 'home/views/home_screen.dart';
import 'leaderboard/views/leaderboard_screen.dart';
import 'random_picker/views/random_picker_screen.dart';
import 'settings/views/settings_screen.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final colorScheme = Theme.of(context).colorScheme;

    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: context.backgroundColor,
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
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
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
                    backgroundColor: context.cardColor,
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
                        label: 'Game History',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_rounded),
                        label: 'Settings',
                      ),
                    ],
                    onTap: (index) => navigationController.changePage(index),
                  ),
                ),
              );
            }),
          ),
    );
  }
}
