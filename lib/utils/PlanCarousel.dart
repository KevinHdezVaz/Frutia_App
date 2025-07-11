// lib/utils/PlanCarousel.dart

import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/screens/miplan/plan_data.dart';
// import 'package:Frutia/pages/screens/recetas/premium_recetas_screen.dart'; // Asegúrate de tener esta pantalla

class PlanCarousel extends StatelessWidget {
  // 1. AHORA RECIBE LA LISTA DE RECETAS, YA NO CARGA NADA
  final List<InspirationRecipe> recipes;

  const PlanCarousel({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. COMPRUEBA SI LA LISTA ESTÁ VACÍA
    if (recipes.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text("No hay recetas de inspiración en tu plan.")),
      );
    }

    // 3. CONSTRUYE EL CARRUSEL CON LOS DATOS RECIBIDOS
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _PlanCarouselCard(recipe: recipe);
        },
      ),
    );
  }
}

class _PlanCarouselCard extends StatelessWidget {
  final InspirationRecipe recipe;
  const _PlanCarouselCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Esta navegación requiere que tengas la pantalla RecipeDetailScreen
        // Si la moviste de premium_recetas_screen, ajusta el import
        // Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Navegando a ${recipe.title}")));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(recipe.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recipe.mealType,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      const Shadow(blurRadius: 2, color: Colors.black54)
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
}
