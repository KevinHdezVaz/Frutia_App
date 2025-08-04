import 'package:Frutia/pages/Pantalla2.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanCarousel extends StatelessWidget {
  final List<InspirationRecipe> recipes;

  const PlanCarousel({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            "No hay recetas de inspiración en tu plan.",
            style: TextStyle(fontSize: 16, color: FrutiaColors.secondaryText),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
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

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.network(
                  recipe.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator(
                            color: FrutiaColors.accent));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const _GeneratingImagePlaceholder(isError: true),
                )
              else
                const _GeneratingImagePlaceholder(),
              if (hasImage) ...[
                Container(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),
              ],
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.7),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.readyInMinutes} min',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '~${recipe.calories} kcal',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(1, 1),
                              ),
                            ],
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
      ).animate().fadeIn(
          delay: Duration(milliseconds: 400 + (index * 100)), duration: 500.ms),
    );
  }
}

class _GeneratingImagePlaceholder extends StatelessWidget {
  final bool isError;
  const _GeneratingImagePlaceholder({Key? key, this.isError = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/fondoAppFrutia.webp',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isError)
                  const Icon(Icons.error_outline, color: Colors.white, size: 28)
                else
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  isError ? 'Error al cargar' : 'Cargando imagen...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.6),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
