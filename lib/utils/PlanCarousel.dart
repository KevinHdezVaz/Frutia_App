import 'package:Frutia/pages/Pantalla2.dart'; // Asumo que esta es tu pantalla de detalles
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/screens/miplan/plan_data.dart'; // Asegúrate que la ruta a tu modelo sea correcta

class PlanCarousel extends StatelessWidget {
  final List<InspirationRecipe> recipes;

  const PlanCarousel({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const SizedBox(
        height: 220, // Aumentamos un poco la altura para consistencia
        child: Center(
          child: Text(
            "No hay recetas de inspiración en tu plan.",
            style: TextStyle(fontSize: 16, color: FrutiaColors.secondaryText),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220, // Aumentamos la altura para un mejor aspecto visual
      child: PageView.builder(
        controller:
            PageController(viewportFraction: 0.85), // Un poco más grande
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
              Image.asset(
                'assets/images/fondoAppFrutia.webp',
                fit: BoxFit.cover,
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FrutiaColors.accent
                          .withOpacity(0.2), // Color principal de tu app
                      FrutiaColors.error
                          .withOpacity(0.5), // Color secundario/acento
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // --- 2. DEGRADADO OSCURO PARA LEGIBILIDAD ---
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

              // --- 3. CONTENIDO DE TEXTO ---
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
                          const Shadow(blurRadius: 4, color: Colors.black54)
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
                              fontWeight: FontWeight.w600),
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
                              fontWeight: FontWeight.w600),
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
