import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/models/game_model.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/shadow_utils.dart';
import '../../../widgets/dark_mode_check.dart';

class FeaturedGameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const FeaturedGameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Card(
            clipBehavior: Clip.antiAlias,
            color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              side:
                  isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
            ),
            elevation: isDarkMode ? 8 : 0, // No elevation in light mode, we'll use custom shadow
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2D3142) : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                boxShadow:
                    isDarkMode
                        ? []
                        : ShadowUtils.getEnhancedContainerShadow(
                          opacity: 0.08,
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
              ),
              child: InkWell(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Image with blue background
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(color: const Color(0xFFD6E0FF)),
                          child: Center(
                            child: SizedBox(
                              height: 120,
                              width: 120,
                              child: _buildGameImage(game.imageUrl, isDarkMode),
                            ),
                          ),
                        ),
                        // Featured badge
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A6FFF),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 3),
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
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          // Game name
                          Text(
                            game.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isDarkMode ? Colors.white : AppTheme.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Game category
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? const Color(0xFF3051D3).withOpacity(0.2)
                                          : const Color(0xFF4A6FFF).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow:
                                      isDarkMode
                                          ? null
                                          : ShadowUtils.getSubtleShadow(
                                            opacity: 0.03,
                                            blurRadius: 4,
                                          ),
                                ),
                                child: Text(
                                  game.category,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color:
                                        isDarkMode
                                            ? AppTheme.primaryColorDarkMode
                                            : AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
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
                              Text(
                                '${game.estimatedTimeMinutes} min',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Rating display
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${game.rating}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Show difficulty level
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(game.difficultyLevel, isDarkMode),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  game.difficultyLevel,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Game description
                          Text(
                            game.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black87.withOpacity(0.9),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),

                          // Play button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: onTap,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('View Game'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isDarkMode
                                          ? AppTheme.primaryColorDarkMode
                                          : const Color(0xFF3051D3),
                                  foregroundColor: Colors.white,
                                  elevation: isDarkMode ? 4 : 0,
                                  shadowColor:
                                      isDarkMode
                                          ? Colors.black.withOpacity(0.3)
                                          : const Color(0xFF3051D3).withOpacity(0.3),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                child: Icon(Icons.hide_image, size: 50, color: Color(0xFF4A6FFF)),
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
                child: Icon(Icons.hide_image, size: 50, color: Color(0xFF4A6FFF)),
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
                child: Icon(Icons.hide_image, size: 50, color: Color(0xFF4A6FFF)),
              ),
            ),
      );
    }
  }

  Color _getDifficultyColor(String difficultyLevel, bool isDarkMode) {
    // Implement your logic to determine the color based on the difficulty level
    // For example, you can use a switch statement or a map to return the appropriate color
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
}
