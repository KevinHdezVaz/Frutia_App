import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

// Pantalla de detalles de una receta (placeholder)
class RecipeDetailScreen extends StatelessWidget {
  final String recipeName;

  const RecipeDetailScreen({required this.recipeName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipeName,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        child: SafeArea(
          child: Center(
            child: Text(
              'Detalles de la receta: $recipeName',
              style: GoogleFonts.lato(
                  fontSize: 24, color: FrutiaColors.primaryText),
            ),
          ),
        ),
      ),
    );
  }
}

// Pantalla principal de recetas
class RecetasScreen extends StatefulWidget {
  const RecetasScreen({Key? key}) : super(key: key);

  @override
  _RecetasScreenState createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> {
  // Lista de recetas favoritas
  late List<String> favoriteRecipes;

  // Lista de recetas disponibles
  final List<Map<String, dynamic>> recipes = const [
    {
      'name': 'Huevos con Tostada',
      'calories': '200 kcal',
      'image': 'assets/eggs_toast.jpg',
      'route': '/recipe/eggs_toast',
    },
    {
      'name': 'Proteína con Plátano',
      'calories': '250 kcal',
      'image': 'assets/protein_banana.jpg',
      'route': '/recipe/protein_banana',
    },
    {
      'name': 'Pancakes Proteicos',
      'calories': '300 kcal',
      'image': 'assets/protein_pancakes.jpg',
      'route': '/recipe/protein_pancakes',
    },
    {
      'name': 'Pollo con Camote',
      'calories': '500 kcal',
      'image': 'assets/chicken_sweetpotato.jpg',
      'route': '/recipe/chicken_sweetpotato',
    },
    {
      'name': 'Atún con Aguacate',
      'calories': '400 kcal',
      'image': 'assets/tuna_avocado.jpg',
      'route': '/recipe/tuna_avocado',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar lista de favoritos
    favoriteRecipes = [];
  }

  // Método para agregar o quitar una receta de favoritos
  void _toggleFavorite(String recipeName) {
    setState(() {
      if (favoriteRecipes.contains(recipeName)) {
        favoriteRecipes.remove(recipeName);
        _showSnackBar('$recipeName eliminada de favoritos');
      } else {
        favoriteRecipes.add(recipeName);
        _showSnackBar('$recipeName añadida a favoritos');
      }
    });
  }

  // Método para mostrar un SnackBar con mensaje
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: FrutiaColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con título y botón de retroceso
      appBar: AppBar(
        title: Text(
          'Recetas',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Cuerpo con gradiente y lista de recetas
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lista de recetas
                Expanded(
                  child: ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return _buildRecipeCard(recipe, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir una card de receta
  Widget _buildRecipeCard(Map<String, dynamic> recipe, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RecipeDetailScreen(recipeName: recipe['name']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen de la receta
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  recipe['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: FrutiaColors.secondaryBackground,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: FrutiaColors.disabledText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nombre y calorías de la receta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      recipe['name'],
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe['calories'],
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Botón de favorito
              IconButton(
                icon: Icon(
                  favoriteRecipes.contains(recipe['name'])
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoriteRecipes.contains(recipe['name'])
                      ? FrutiaColors.accent
                      : FrutiaColors.disabledText,
                ),
                onPressed: () => _toggleFavorite(recipe['name']),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: (200 + index * 200).ms).slideY(
          begin: 0.3,
          end: 0.0,
          duration: 800.ms,
          curve: Curves.easeOut,
        );
  }
}
