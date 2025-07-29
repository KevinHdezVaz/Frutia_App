import 'package:Frutia/pages/Pantalla2.dart';
import 'package:Frutia/pages/screens/datosPersonales/SuccessScreen.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/pages/Pantalla1.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';

class PlanSummaryScreen extends StatefulWidget {
  const PlanSummaryScreen({Key? key}) : super(key: key);

  @override
  State<PlanSummaryScreen> createState() => _PlanSummaryScreenState();
}

class _PlanSummaryScreenState extends State<PlanSummaryScreen> {
  final PlanService _planService = PlanService();
  late Future<MealPlanData?> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = _planService.getCurrentPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<MealPlanData?>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: FrutiaColors.accent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: FrutiaColors.accent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString(),
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FrutiaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Volver',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final planData = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 170.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FrutiaColors.accent.withOpacity(0.9),
                                FrutiaColors.accent2,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(30)),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20.0, bottom: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/images/frutaProgreso4.png',
                                    width: 120,
                                    height: 120,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tu Plan Frutia",
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 6.0,
                                          color: Colors.black.withOpacity(0.4),
                                          offset: const Offset(2.0, 2.0),
                                        ),
                                      ],
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 800.ms)
                                      .slideY(begin: 0.2, end: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    stretchModes: const [StretchMode.zoomBackground],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummarySection(
                            context, planData.nutritionPlan.targetMacros),
                        const SizedBox(height: 30),
                        _buildMealOptionsSummary(
                            context, planData.nutritionPlan.meals),
                        const SizedBox(height: 15),
                        _buildRecommendationsSection(context,
                            planData.nutritionPlan.generalRecommendations),
                        const SizedBox(height: 20), // Espacio antes del botón
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const SuccessScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FrutiaColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 8,
                              shadowColor:
                                  FrutiaColors.primary.withOpacity(0.5),
                              minimumSize: const Size.fromHeight(60),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 24,
                              color: Colors.white,
                            ),
                            label: Text(
                              "¡Listo para empezar!",
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 800.ms)
                              .scale(duration: 500.ms),
                        ),
                        const SizedBox(
                            height: 40), // AÑADIDO: más espacio abajo
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, color: FrutiaColors.primary, size: 24),
      const SizedBox(width: 10),
      Text(
        title,
        style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: FrutiaColors.primaryText),
      ),
    ],
  ).animate().fadeIn(delay: 300.ms);
}

Widget _buildMealOptionsSummary(BuildContext context, Map<String, Meal> meals) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader(
          context, "Tus Opciones de Comida", Icons.food_bank_outlined),
      const SizedBox(height: 15),
      ...meals.entries.map((entry) {
        final mealTitle = entry.key;
        final meal = entry
            .value; // 'meal' es el objeto que contiene componentes y recetas
        return _buildSingleMealSummaryCard(context, mealTitle, meal);
      }).toList(),
    ],
  ).animate().fadeIn(delay: 400.ms);
}
// En PlanSummaryScreen.dart

// En PlanSummaryScreen.dart

Widget _buildSingleMealSummaryCard(
    BuildContext context, String mealTitle, Meal meal) {
  final categories = meal.components;
  final recipes = meal.suggestedRecipes;

  return Card(
    margin: const EdgeInsets.only(bottom: 15),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // Eliminamos el SingleChildScrollView que no es necesario
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealTitle,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.accent),
          ),
          const Divider(height: 15, thickness: 1),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${category.title}:",
                      style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    // ESTA PARTE YA MUESTRA LOS "INGREDIENTES" CORRECTAMENTE
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0, // Añadido para mejor espaciado vertical
                      children: category.options
                          .map((opt) => Text(
                                opt.name,
                                style: GoogleFonts.lato(
                                    color: FrutiaColors.secondaryText),
                              ))
                          .toList(),
                    ),
                    // ▼▼▼ SE ELIMINÓ LA SECCIÓN REDUNDANTE DE AQUÍ ▼▼▼
                  ],
                ),
              )),
          if (recipes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),
            Text(
              "Recetas Sugeridas",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            ...recipes.map((recipe) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.arrow_right_alt,
                      color: FrutiaColors.accent),
                  title: Text(
                    recipe.title,
                    style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                )),
          ],
        ],
      ),
    ),
  );
}

Widget _buildSummarySection(BuildContext context, TargetMacros macros) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader(
          context, "Tus Macros Diarios", Icons.pie_chart_outline_rounded),
      const SizedBox(height: 15),
      _buildSummaryCard(context,
          icon: Icons.local_fire_department_outlined,
          title: 'Calorías',
          text: '${macros.calories} kcal',
          delay: 200.ms),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
              child: _buildSummaryCard(context,
                  icon: Icons.egg_alt_outlined,
                  title: 'Proteínas',
                  text: '~${macros.protein}g',
                  delay: 300.ms)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard(context,
                  icon: Icons.local_pizza_outlined,
                  title: 'Carbs',
                  text: '~${macros.carbs}g',
                  delay: 400.ms)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard(context,
                  icon: Icons.water_drop_outlined,
                  title: 'Grasas',
                  text: '~${macros.fats}g',
                  delay: 500.ms)),
        ],
      ),
    ],
  );
}

Widget _buildSummaryCard(BuildContext context,
    {required IconData icon,
    required String title,
    required String text,
    required Duration delay}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        children: [
          Icon(icon, color: FrutiaColors.accent, size: 24),
          const SizedBox(height: 8),
          Text(title,
              style: GoogleFonts.lato(
                  fontSize: 13, color: FrutiaColors.secondaryText)),
          const SizedBox(height: 4),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  ).animate().fadeIn(duration: 600.ms, delay: delay).slideY(begin: 0.2, end: 0);
}

Widget _buildRecipesSection(
    BuildContext context, List<InspirationRecipe> recipes) {
  if (recipes.isEmpty) return const SizedBox.shrink();
  return Column(
    children: recipes
        .map((recipe) => _buildMealExpansionTile(context, recipe))
        .toList(),
  );
}

Widget _buildMealExpansionTile(BuildContext context, InspirationRecipe recipe) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      title: Text(recipe.title,
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700)),
      subtitle: Text(recipe.mealType!,
          style: GoogleFonts.lato(fontSize: 14, color: FrutiaColors.accent)),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          recipe.image!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: const Icon(Icons.restaurant_menu)),
        ),
      ),
      children: [
        /*
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text("Ingredientes:",
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                ...recipe.planComponents.map((ing) => Text("• $ing")),
                if (recipe.additionalIngredients.isNotEmpty)
                  ...recipe.additionalIngredients.map((ing) =>
                      Text("• ${ing.name} ${ing.quantity ?? ''}".trim())),
                const SizedBox(height: 12),
                Text("Instrucciones:",
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                ...recipe.steps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("${entry.key + 1}. ${entry.value}"),
                    )),
              ],
            ),
          )
          */
      ],
    ),
  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1);
}

Widget _buildRecommendationsSection(
    BuildContext context, List<String> recomendaciones,
    {String title = "Recomendaciones",
    IconData icon = Icons.lightbulb_outline}) {
  if (recomendaciones.isEmpty) return const SizedBox.shrink();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader(context, title, icon),
      const SizedBox(height: 10),
      ...recomendaciones.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ",
                    style: TextStyle(
                        color: FrutiaColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Expanded(
                    child: Text(rec,
                        style: GoogleFonts.lato(fontSize: 15, height: 1.4))),
              ],
            ),
          )),
    ],
  );
}
