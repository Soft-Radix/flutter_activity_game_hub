import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';
import '../../data/models/game_model.dart';
import '../../routes/app_pages.dart';
import '../../themes/app_theme.dart';
import '../../widgets/theme_toggle.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Game game = Get.arguments as Game;
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name, style: textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality would go here
              Get.snackbar(
                'Share',
                'Sharing functionality would be implemented here',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Share this game',
          ),
          const ThemeToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Image
            Stack(
              children: [
                Hero(
                  tag: 'game-image-${game.id}',
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: _buildGameImage(game.imageUrl, themeController),
                  ),
                ),
                if (game.isFeatured)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Featured',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Game Details
            Padding(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game category and info
                  Obx(() {
                    final isDarkMode = themeController.isDarkMode;
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? colorScheme.primary.withOpacity(0.2)
                                    : colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            game.category,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
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
                          '${game.minPlayers}-${game.maxPlayers} players',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.timer,
                          size: 16,
                          color:
                              isDarkMode
                                  ? AppTheme.lightTextColorDarkMode
                                  : AppTheme.lightTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text('${game.estimatedTimeMinutes} min', style: textTheme.bodySmall),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  // Description
                  Text('Description', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(game.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 24),

                  // How to play
                  Text('How to Play', style: textTheme.titleLarge),
                  const SizedBox(height: 12),

                  // Instructions list
                  _buildInstructionsList(context, game, themeController),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(Routes.TIMER_SCOREBOARD, arguments: game),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Game'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () => Get.toNamed(Routes.LEADERBOARD, arguments: {'gameId': game.id}),
                          icon: const Icon(Icons.leaderboard),
                          label: const Text('Leaderboard'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameImage(String imageUrl, ThemeController themeController) {
    return Obx(() {
      final isDarkMode = themeController.isDarkMode;
      final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

      if (imageUrl.toLowerCase().endsWith('.svg')) {
        return SvgPicture.asset(
          imageUrl,
          fit: BoxFit.cover,
          placeholderBuilder:
              (context) => Container(
                color: primaryColor.withOpacity(0.2),
                child: Center(
                  child: Icon(Icons.image_not_supported, size: 80, color: primaryColor),
                ),
              ),
        );
      } else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (ctx, error, stackTrace) => Container(
                color: primaryColor.withOpacity(0.2),
                child: Center(
                  child: Icon(Icons.image_not_supported, size: 80, color: primaryColor),
                ),
              ),
        );
      }
    });
  }

  Widget _buildInstructionsList(BuildContext context, Game game, ThemeController themeController) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;
      final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: game.instructions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(game.instructions[index], style: textTheme.bodyMedium)),
              ],
            ),
          );
        },
      );
    });
  }
}
