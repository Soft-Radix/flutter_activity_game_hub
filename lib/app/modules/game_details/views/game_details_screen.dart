import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/theme_controller.dart';
import '../../../data/models/game_model.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/dark_mode_check.dart';

class GameDetailsScreen extends StatelessWidget {
  const GameDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Game game = Get.arguments as Game;
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Scaffold(
            backgroundColor: isDarkMode ? const Color(0xFF1A1C2A) : AppTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor: isDarkMode ? const Color(0xFF252842) : Colors.white,
              elevation: isDarkMode ? 0 : 2,
              shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
                onPressed: () => Get.back(),
              ),
              title: Text(
                game.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppTheme.textColorDarkMode : AppTheme.textColor,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share, color: isDarkMode ? Colors.white : Colors.black87),
                  onPressed: () {
                    Get.snackbar(
                      'Share',
                      'Sharing functionality would be implemented here',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                      colorText: isDarkMode ? Colors.white : Colors.black87,
                    );
                  },
                  tooltip: 'Share this game',
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Image with blue background
                  Stack(
                    children: [
                      Container(
                        height: 200, // Reduced height
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [const Color(0xFF4A6FFF), const Color(0xFF3051D3)],
                          ),
                        ),
                        child: Hero(
                          tag: 'game-image-${game.id}',
                          child: Center(
                            child: SizedBox(
                              height: 120,
                              width: 120,
                              child: _buildGameImage(game.imageUrl, isDarkMode),
                            ),
                          ),
                        ),
                      ),
                      // Rating and difficulty display as overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Rating
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 22),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${game.rating}',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                // Difficulty badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(game.difficultyLevel),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getDifficultyIcon(game.difficultyLevel),
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        game.difficultyLevel,
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (game.isFeatured)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
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

                  // Game info card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Game title and category
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF1FD),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    game.category,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF4A6FFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Game info - players and time
                                      Row(
                                        children: [
                                          _buildInfoItem(
                                            Icons.people_outline,
                                            '${game.minPlayers}-${game.maxPlayers} players',
                                            Colors.blueGrey,
                                            textTheme,
                                            isDarkMode,
                                          ),
                                          const SizedBox(width: 16),
                                          _buildInfoItem(
                                            Icons.timer_outlined,
                                            '${game.estimatedTimeMinutes} min',
                                            Colors.orange,
                                            textTheme,
                                            isDarkMode,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                          ),
                          // Game features
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildFeatureItem(
                                  Icons.category_outlined,
                                  game.gameType,
                                  Colors.blue,
                                  textTheme,
                                  isDarkMode,
                                ),
                                _buildFeatureItem(
                                  game.isTimeBound ? Icons.timer : Icons.timer_off,
                                  game.isTimeBound ? 'Time Bound' : 'No Time Limit',
                                  game.isTimeBound ? Colors.orange : Colors.grey,
                                  textTheme,
                                  isDarkMode,
                                ),
                                _buildFeatureItem(
                                  game.teamBased ? Icons.group : Icons.person,
                                  game.teamBased ? 'Team Based' : 'Individual',
                                  game.teamBased ? Colors.green : Colors.purple,
                                  textTheme,
                                  isDarkMode,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Materials Required & Description
                  if (game.materialsRequired.isNotEmpty || game.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (game.description.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      game.description,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (game.materialsRequired.isNotEmpty)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                ),
                            ],
                            if (game.materialsRequired.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Materials Required',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          game.materialsRequired.map((material) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isDarkMode
                                                        ? const Color(0xFF3051D3).withOpacity(0.2)
                                                        : const Color(0xFFEFF1FD),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color:
                                                      isDarkMode
                                                          ? const Color(0xFF3051D3).withOpacity(0.3)
                                                          : const Color(
                                                            0xFF4A6FFF,
                                                          ).withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    size: 16,
                                                    color:
                                                        isDarkMode
                                                            ? Colors.white70
                                                            : Colors.blue.shade700,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    material,
                                                    style: textTheme.bodyMedium?.copyWith(
                                                      color:
                                                          isDarkMode
                                                              ? Colors.white
                                                              : Colors.black87,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // How to Play & Rules
                  if (game.instructions.isNotEmpty || game.rules.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF252842) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (game.instructions.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'How to Play',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInstructionsList(
                                      game.instructions,
                                      textTheme,
                                      isDarkMode,
                                    ),
                                  ],
                                ),
                              ),
                              if (game.rules.isNotEmpty)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                                ),
                            ],
                            if (game.rules.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rules',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildRulesList(game.rules, textTheme, isDarkMode),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => Get.toNamed(AppRoutes.TIMER_SCOREBOARD, arguments: game),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start Game'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A6FFF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    () => Get.toNamed(
                                      AppRoutes.LEADERBOARD,
                                      arguments: {'gameId': game.id},
                                    ),
                                icon: const Icon(Icons.leaderboard),
                                label: const Text('Leaderboard'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF4A6FFF),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(color: Color(0xFF4A6FFF), width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildGameImage(String imageUrl, bool isDarkMode) {
    // Handle SVG files (local assets)
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imageUrl,
        fit: BoxFit.contain,
        placeholderBuilder:
            (context) => Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(Icons.hide_image, size: 80, color: Color(0xFF4A6FFF)),
              ),
            ),
      );
    }
    // Handle remote URLs
    else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder:
            (ctx, error, stackTrace) => Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(Icons.hide_image, size: 80, color: Color(0xFF4A6FFF)),
              ),
            ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            color: Colors.transparent,
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF4A6FFF))),
          );
        },
      );
    }
    // Handle local asset images
    else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder:
            (ctx, error, stackTrace) => Container(
              color: Colors.transparent,
              child: const Center(
                child: Icon(Icons.hide_image, size: 80, color: Color(0xFF4A6FFF)),
              ),
            ),
      );
    }
  }

  Widget _buildInstructionsList(List<String> instructions, TextTheme textTheme, bool isDarkMode) {
    return Column(
      children: List.generate(instructions.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == instructions.length - 1 ? 0 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF3051D3).withOpacity(0.2)
                          : const Color(0xFFEFF1FD),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: textTheme.titleSmall?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    instructions[index],
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRulesList(List<String> rules, TextTheme textTheme, bool isDarkMode) {
    return Column(
      children: List.generate(rules.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == rules.length - 1 ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: isDarkMode ? Colors.white70 : Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rules[index],
                  style: textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _getDifficultyColor(String difficultyLevel) {
    // Implement your logic to determine the color based on the difficulty level
    // For example, you can use a switch statement or a map to return the appropriate color
    switch (difficultyLevel) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon(String difficultyLevel) {
    // Implement your logic to determine the icon based on the difficulty level
    // For example, you can use a switch statement or a map to return the appropriate icon
    switch (difficultyLevel) {
      case 'Easy':
        return Icons.check_circle;
      case 'Medium':
        return Icons.help;
      case 'Hard':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    Color color,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String label,
    Color color,
    TextTheme textTheme,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
      ],
    );
  }
}
