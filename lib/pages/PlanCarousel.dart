import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart'; // Asegúrate que la ruta sea correcta
// Si RecipeDetailScreen está en otro archivo, impórtalo también
// import 'package:Frutia/pages/screens/recetas/premium_recetas_screen.dart';

class PlanCarousel extends StatelessWidget {
  // 1. AÑADIMOS EL PARÁMETRO PARA RECIBIR LAS RECETAS
  final List<InspirationRecipe> recipes;

  const PlanCarousel({Key? key, required this.recipes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      // Mensaje por si el plan no tuviera recetas de inspiración
      return const Center(
          child: Text("No hay recetas de inspiración en tu plan."));
    }

    return SizedBox(
      height: 220, // Altura fija para el carrusel
      child: PageView.builder(
        controller: PageController(
            viewportFraction: 0.85), // Efecto de ver la tarjeta siguiente
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
        // Si no la tienes, puedes comentar esta línea por ahora.
        // Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Navegando a ${recipe.title}")));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(recipe.imageUrl!!),
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
