import 'package:Frutia/pages/Pantalla2.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../pages/screens/miplan/plan_data.dart';

class PlanCarousel extends StatelessWidget {
  final List<InspirationRecipe> recipes;

  const PlanCarousel({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No hay recetas de inspiración en tu plan.",
            style: TextStyle(
              fontSize: 16,
              color: FrutiaColors.secondaryText,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200, // Increased from 180 to prevent overflow
      child: PageView.builder(
        controller: PageController(
            viewportFraction: 0.80), // Reduced from 0.85 for more spacing
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _PlanCarouselCard(recipe: recipe, index: index);
        },
      ),
    );
  }
}

class _PlanCarouselCard extends StatelessWidget {
  final InspirationRecipe recipe;
  final int index;

  const _PlanCarouselCard({required this.recipe, required this.index});

  IconData _getIconForRecipe(String mealType) {
    final typeLower = mealType.toLowerCase();
    if (typeLower.contains('desayuno')) {
      return Icons.free_breakfast_outlined;
    } else if (typeLower.contains('almuerzo')) {
      return Icons.restaurant_outlined;
    } else if (typeLower.contains('cena')) {
      return Icons.dinner_dining_outlined;
    } else if (typeLower.contains('shake') || typeLower.contains('batido')) {
      return Icons.blender_outlined;
    }
    return Icons.restaurant_menu_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe)));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0), // Increased horizontal margin, reduced vertical
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FrutiaColors.accent.withOpacity(0.1),
              FrutiaColors.accent2.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6, // Reduced blur to minimize overflow risk
              spreadRadius: 1,
              offset: const Offset(0, 2), // Adjusted offset
            ),
          ],
          border: Border.all(
            color: FrutiaColors.accent.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reduced padding slightly
          child: Row(
            children: [
              // Icon instead of image
              Container(
                padding: const EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: FrutiaColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForRecipe(recipe.mealType),
                  color: FrutiaColors.accent,
                  size: 30, // Slightly smaller icon
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FrutiaColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recipe.mealType,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16, // Slightly smaller to fit
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.description ?? 'Sin descripción',
                      style: GoogleFonts.lato(
                        fontSize: 13, // Slightly smaller to fit
                        color: FrutiaColors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${recipe.calories ?? '--'} kcal',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: FrutiaColors.accent,
                size: 18, // Slightly smaller
              ),
            ],
          ),
        ),
      ).animate().fadeIn(
          delay: Duration(milliseconds: 400 + (index * 100)), duration: 500.ms),
    );
  }
}
