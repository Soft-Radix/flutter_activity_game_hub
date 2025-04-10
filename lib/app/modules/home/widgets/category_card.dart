import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/models/category_model.dart';
import '../../../themes/app_theme.dart';
import '../../../utils/shadow_utils.dart';
import '../../../widgets/dark_mode_check.dart';

class CategoryCard extends StatelessWidget {
  final GameCategory category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CategoryCard({super.key, required this.category, required this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return DarkModeCheck(
      builder:
          (context, isDarkMode) => Card(
            clipBehavior: Clip.antiAlias,
            elevation: isDarkMode ? 8 : 0, // No elevation in light mode, we'll use custom shadow
            color: isDarkMode ? context.cardColor : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              side:
                  isDarkMode ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
            ),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color.withOpacity(isDarkMode ? 0.5 : 0.7),
                      category.color.withOpacity(isDarkMode ? 0.8 : 1.0),
                    ],
                  ),
                  boxShadow:
                      isDarkMode
                          ? [
                            BoxShadow(
                              color: category.color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : ShadowUtils.getColoredShadow(
                            color: category.color,
                            opacity: 0.4,
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isDarkMode ? 0.2 : 0.3),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              isDarkMode
                                  ? null
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: SvgPicture.asset(
                          category.iconPath,
                          width: 28,
                          height: 28,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Name and description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.4),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                category.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.4),
                                      offset: const Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
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
          ),
    );
  }
}
