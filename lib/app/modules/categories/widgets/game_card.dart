import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/theme_controller.dart';
import '../../../data/models/game_model.dart';
import '../../../themes/app_theme.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isDarkMode = themeController.isDarkMode;

      return Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        elevation: 3,
        shadowColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Image
              Hero(
                tag: 'game-image-${game.id}',
                child: SizedBox(
                  width: 120,
                  height: 130,
                  child: _buildGameImage(game.imageUrl, themeController),
                ),
              ),

              // Game Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game name with category
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.name,
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          game.category,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Game info
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
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
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color:
                                isDarkMode
                                    ? AppTheme.lightTextColorDarkMode
                                    : AppTheme.lightTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text('${game.estimatedTimeMinutes} min', style: textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Game description
                      Text(
                        game.description,
                        style: textTheme.bodySmall?.copyWith(
                          height: 1.3,
                          color:
                              isDarkMode
                                  ? AppTheme.textColorDarkMode.withOpacity(0.8)
                                  : AppTheme.textColor.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Featured badge
                      if (game.isFeatured)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(12),
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
                                  const Icon(Icons.star, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Featured',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Arrow icon
              Container(
                height: 130,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color:
                          isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildGameImage(String imageUrl, ThemeController themeController) {
    return Obx(() {
      final isDarkMode = themeController.isDarkMode;
      final primaryColor = isDarkMode ? AppTheme.primaryColorDarkMode : AppTheme.primaryColor;

      if (imageUrl.toLowerCase().endsWith('.svg')) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.05)],
            ),
          ),
          child: SvgPicture.asset(
            imageUrl,
            fit: BoxFit.cover,
            placeholderBuilder:
                (context) => Container(
                  color: primaryColor.withOpacity(0.1),
                  child: Center(
                    child: Icon(Icons.image_not_supported_rounded, size: 40, color: primaryColor),
                  ),
                ),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor.withOpacity(0.05), primaryColor.withOpacity(0.2)],
            ),
          ),
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (ctx, error, stackTrace) => Container(
                  color: primaryColor.withOpacity(0.1),
                  child: Center(
                    child: Icon(Icons.image_not_supported_rounded, size: 40, color: primaryColor),
                  ),
                ),
          ),
        );
      }
    });
  }
}
