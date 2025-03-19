import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/models/category_model.dart';
import '../../../themes/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final GameCategory category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [category.color.withOpacity(0.7), category.color],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    category.iconPath,
                    width: 32,
                    height: 32,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),

                // Name and description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.9)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
