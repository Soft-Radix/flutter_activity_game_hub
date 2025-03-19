import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../data/models/game_model.dart';
import '../../routes/app_pages.dart';
import '../../themes/app_theme.dart';

class RandomPickerScreen extends StatefulWidget {
  const RandomPickerScreen({super.key});

  @override
  State<RandomPickerScreen> createState() => _RandomPickerScreenState();
}

class _RandomPickerScreenState extends State<RandomPickerScreen> with TickerProviderStateMixin {
  final AppController _controller = Get.find<AppController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  late AnimationController _animationController;
  late Game _selectedGame;
  bool _isAnimationComplete = false;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimationComplete = true;
          _isSpinning = false;
        });
      }
    });

    // Initialize with a random game
    _selectedGame = _controller.getRandomGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    setState(() {
      _isAnimationComplete = false;
      _isSpinning = true;
      _selectedGame = _controller.getRandomGame();
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = _themeController.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Random Game Picker',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [
                      AppTheme.backgroundColorDarkMode,
                      Color.lerp(
                            AppTheme.backgroundColorDarkMode,
                            AppTheme.primaryColorDarkMode,
                            0.15,
                          ) ??
                          AppTheme.backgroundColorDarkMode,
                    ]
                    : [
                      AppTheme.backgroundColor,
                      Color.lerp(AppTheme.backgroundColor, AppTheme.primaryColor, 0.12) ??
                          AppTheme.backgroundColor,
                    ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Text(
                'Tap the wheel to pick a random game!',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Spinning Wheel Animation
            GestureDetector(
              onTap: _isSpinning ? null : _spinWheel,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning wheel
                  RotationTransition(
                    turns: Tween(
                      begin: 0.0,
                      end: 2.0,
                    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_animationController),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? AppTheme.primaryColorDarkMode.withOpacity(0.95)
                                : AppTheme.primaryColor.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDarkMode
                                    ? AppTheme.primaryColorDarkMode.withOpacity(0.6)
                                    : AppTheme.primaryColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(
                          color:
                              isDarkMode
                                  ? AppTheme.primaryColorLight.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        gradient: RadialGradient(
                          colors:
                              isDarkMode
                                  ? [
                                    AppTheme.primaryColorDarkMode,
                                    Color.lerp(AppTheme.primaryColorDarkMode, Colors.blue, 0.3) ??
                                        AppTheme.primaryColorDarkMode,
                                  ]
                                  : [
                                    AppTheme.primaryColor.withOpacity(0.9),
                                    Color.lerp(AppTheme.primaryColor, Colors.blue, 0.4) ??
                                        AppTheme.primaryColor,
                                  ],
                          radius: 0.85,
                          focal: Alignment.center,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.casino,
                            size: 50,
                            color:
                                _isSpinning
                                    ? AppTheme.accentColor
                                    : isDarkMode
                                    ? AppTheme.primaryColorDarkMode
                                    : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Indicator triangle
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Selected Game Display
            AnimatedOpacity(
              opacity: _isAnimationComplete ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.padding),
                padding: const EdgeInsets.all(AppTheme.padding),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardColorDarkMode : Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  border:
                      isDarkMode
                          ? Border.all(
                            color: AppTheme.primaryColorDarkMode.withOpacity(0.3),
                            width: 1,
                          )
                          : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Game name
                    Text(
                      _selectedGame.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Game info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? colorScheme.primary.withOpacity(0.2)
                                    : colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? colorScheme.primary.withOpacity(0.5)
                                      : colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _selectedGame.category,
                            style: textTheme.bodySmall?.copyWith(
                              color:
                                  isDarkMode
                                      ? colorScheme.primary.withOpacity(0.9)
                                      : colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people,
                          size: 16,
                          color:
                              isDarkMode
                                  ? AppTheme.lightTextColorDarkMode
                                  : AppTheme.lightTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_selectedGame.minPlayers}-${_selectedGame.maxPlayers} players',
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                isDarkMode
                                    ? AppTheme.lightTextColorDarkMode
                                    : AppTheme.lightTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.timer,
                          size: 16,
                          color:
                              isDarkMode
                                  ? AppTheme.lightTextColorDarkMode
                                  : AppTheme.lightTextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_selectedGame.estimatedTimeMinutes} min',
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                isDarkMode
                                    ? AppTheme.lightTextColorDarkMode
                                    : AppTheme.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      _selectedGame.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),

                    // View details button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(Routes.GAME_DETAILS, arguments: _selectedGame),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('View Game Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          ),
                          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
