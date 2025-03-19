import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/models/game_model.dart';
import '../../../themes/app_theme.dart';

class FeaturedGameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const FeaturedGameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game Image
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: _buildGameImage(game.imageUrl),
                ),
                // Featured badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(20),
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
                  Text(game.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),

                  // Game category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          game.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.people, size: 16, color: AppTheme.lightTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${game.minPlayers}-${game.maxPlayers} players',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.timer, size: 16, color: AppTheme.lightTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${game.estimatedTimeMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Game description
                  Text(
                    game.description,
                    style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildGameImage(String imageUrl) {
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imageUrl,
        fit: BoxFit.cover,
        placeholderBuilder:
            (context) => Container(
              color: AppTheme.primaryColor.withOpacity(0.2),
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 50, color: AppTheme.primaryColor),
              ),
            ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (ctx, error, stackTrace) => Container(
              color: AppTheme.primaryColor.withOpacity(0.2),
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 50, color: AppTheme.primaryColor),
              ),
            ),
      );
    }
  }
}
