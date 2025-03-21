import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/game_model.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/dark_mode_check.dart';
import '../controllers/random_picker_controller.dart';

class RandomPickerScreen extends StatefulWidget {
  const RandomPickerScreen({super.key});

  @override
  State<RandomPickerScreen> createState() => _RandomPickerScreenState();
}

class _RandomPickerScreenState extends State<RandomPickerScreen> with TickerProviderStateMixin {
  final RandomPickerController _controller = Get.find<RandomPickerController>();
  late AnimationController _animationController;
  Game? _selectedGame;
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
    _initializeRandomGame();
  }

  Future<void> _initializeRandomGame() async {
    final game = await _controller.pickRandomGame();
    setState(() {
      _selectedGame = game;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _spinWheel() async {
    setState(() {
      _isAnimationComplete = false;
      _isSpinning = true;
    });

    // Fetch a random game
    final game = await _controller.pickRandomGame();

    setState(() {
      _selectedGame = game;
    });

    _animationController.reset();
    _animationController.forward();
  }

  // Helper method to get difficulty color
  Color _getDifficultyColor(String difficultyLevel, bool isDarkMode) {
    switch (difficultyLevel) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.amber;
      case 'Hard':
        return Colors.red;
      default:
        return isDarkMode ? Colors.white : Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: context.backgroundColor,
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
              title: Text(
                'Random Game Picker',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors:
                      isDarkMode
                          ? [const Color(0xFF1A1C2A), const Color(0xFF252842)]
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
                        color: context.textColor,
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
                          turns: Tween(begin: 0.0, end: 2.0)
                              .chain(CurveTween(curve: Curves.elasticOut))
                              .animate(_animationController),
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
                                          Color.lerp(
                                                AppTheme.primaryColorDarkMode,
                                                Colors.blue,
                                                0.3,
                                              ) ??
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
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border:
                            isDarkMode ? Border.all(color: Colors.grey.shade800, width: 1) : null,
                      ),
                      child:
                          _selectedGame != null
                              ? Column(
                                children: [
                                  Text(
                                    'Your Random Game is',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: context.textColor.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Game title
                                  Text(
                                    _selectedGame!.name,
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),

                                  // Game image and details in row
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Game image on left
                                      _buildGameImage(_selectedGame!.imageUrl, isDarkMode),

                                      const SizedBox(width: 16),

                                      // Game details on right
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Rating and difficulty row
                                            Row(
                                              children: [
                                                // Rating display
                                                Icon(Icons.star, color: Colors.amber, size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${_selectedGame!.rating}',
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isDarkMode ? Colors.white : Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Difficulty level
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getDifficultyColor(
                                                      _selectedGame!.difficultyLevel,
                                                      isDarkMode,
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    _selectedGame!.difficultyLevel,
                                                    style: textTheme.bodySmall?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 12),

                                            // Game type (if available)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: (isDarkMode
                                                        ? AppTheme.primaryColorDarkMode
                                                        : AppTheme.primaryColor)
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _selectedGame!.gameType,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      isDarkMode
                                                          ? AppTheme.primaryColorDarkMode
                                                          : AppTheme.primaryColor,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            // Player count and time info
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.people,
                                                  size: 16,
                                                  color:
                                                      isDarkMode
                                                          ? AppTheme.lightTextColorDarkMode
                                                          : AppTheme.lightTextColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${_selectedGame!.minPlayers}-${_selectedGame!.maxPlayers} players',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: context.textColor.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 4),

                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.timer,
                                                  size: 16,
                                                  color:
                                                      isDarkMode
                                                          ? AppTheme.lightTextColorDarkMode
                                                          : AppTheme.lightTextColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${_selectedGame!.estimatedTimeMinutes} min',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: context.textColor.withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _spinWheel,
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: AppTheme.accentColor,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text('Spin Again'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.toNamed(
                                              AppRoutes.GAME_DETAILS,
                                              arguments: _selectedGame,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor:
                                                isDarkMode
                                                    ? AppTheme.primaryColorDarkMode
                                                    : AppTheme.primaryColor,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text('View Game'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                              : Center(
                                child: CircularProgressIndicator(color: colorScheme.primary),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildGameImage(String imageUrl, bool isDarkMode) {
    final Widget placeholder = Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.casino_rounded,
          size: 50,
          color:
              isDarkMode
                  ? AppTheme.primaryColorDarkMode.withOpacity(0.7)
                  : AppTheme.primaryColor.withOpacity(0.7),
        ),
      ),
    );

    if (imageUrl.isEmpty) {
      return placeholder;
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Remote image from URL with improved error handling
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return placeholder;
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor,
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
      );
    } else if (imageUrl.startsWith('assets/')) {
      // Local asset image
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            return placeholder;
          },
        ),
      );
    } else {
      // Fallback to placeholder image
      return placeholder;
    }
  }
}
