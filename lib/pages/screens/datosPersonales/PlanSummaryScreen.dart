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
            final nutritionPlan = planData.nutritionPlan;

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, nutritionPlan),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MENSAJE PERSONALIZADO
                        _buildPersonalizedMessageCard(
                            context, nutritionPlan.personalizedMessage),
                        const SizedBox(height: 20),

                        // RESUMEN ANTROPOMÉTRICO
                        if (nutritionPlan.anthropometricSummary != null)
                          _buildAnthropometricCard(
                              context, nutritionPlan.anthropometricSummary!),
                        const SizedBox(height: 20),

                        // MACROS OBJETIVO
                        _buildSummarySection(
                            context, nutritionPlan.targetMacros),
                        const SizedBox(height: 30),

                        // ESTRUCTURA DE COMIDAS CON INTERCAMBIOS
                        _buildMealOptionsWithExchanges(
                            context, nutritionPlan.meals),
                        const SizedBox(height: 30),

                        // RECETAS SUGERIDAS
                        _buildRecipesSection(context, nutritionPlan.meals),
                        const SizedBox(height: 20),

                        // CONSEJOS PERSONALIZADOS
                        if (nutritionPlan.personalizedTips != null)
                          _buildPersonalizedTips(
                              context, nutritionPlan.personalizedTips!),
                        const SizedBox(height: 20),

                        // RECOMENDACIONES GENERALES
                        _buildRecommendationsSection(
                            context, nutritionPlan.generalRecommendations),
                        const SizedBox(height: 30),

                        // BOTÓN DE FINALIZAR
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
                        const SizedBox(height: 40),
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

  SliverAppBar _buildAppBar(BuildContext context, NutritionPlan nutritionPlan) {
    // Obtener nombre del cliente del anthropometricSummary o usar por defecto
    String clientName =
        nutritionPlan.anthropometricSummary?.clientName ?? "Tu Plan Frutia";

    return SliverAppBar(
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
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
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
                        "Plan de $clientName",
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 28,
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
    );
  }

  Widget _buildPersonalizedMessageCard(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FrutiaColors.accent.withOpacity(0.1),
            FrutiaColors.accent2.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: FrutiaColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              color: FrutiaColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mensaje Personal",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: FrutiaColors.primaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildAnthropometricCard(
      BuildContext context, AnthropometricSummary anthropometricSummary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "Tu Perfil Nutricional",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child:
                    _buildInfoChip("Edad", "${anthropometricSummary.age} años"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                    "BMI", "${anthropometricSummary.bmi.toStringAsFixed(1)}"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                    "Peso", "${anthropometricSummary.weight} kg"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                    "Estatura", "${anthropometricSummary.height.toInt()} cm"),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: FrutiaColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealOptionsWithExchanges(
      BuildContext context, Map<String, Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context, "Tus Intercambios de Alimentos", Icons.swap_horiz),
        const SizedBox(height: 15),
        Text(
          "Puedes intercambiar cualquier alimento del mismo grupo por otro. ¡Flexibilidad total!",
          style: GoogleFonts.lato(
            fontSize: 14,
            color: FrutiaColors.secondaryText,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 15),
        ...meals.entries.map((entry) {
          return _buildMealExchangeCard(context, entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildMealExchangeCard(
      BuildContext context, String mealTitle, Meal meal) {
    // Obtener el horario de la comida si está disponible
    String? mealTime = meal.mealTiming;
    String subtitleText = mealTime != null
        ? "Horario: $mealTime - Toca para ver opciones de intercambio"
        : "Toca para ver opciones de intercambio";

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          mealTitle,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: FrutiaColors.accent,
          ),
        ),
        subtitle: Text(
          subtitleText,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: FrutiaColors.secondaryText,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...meal.components
                    .map((category) => _buildExchangeGroup(context, category)),

                // Mostrar tips personalizados si existen
                if (meal.personalizedTips != null &&
                    meal.personalizedTips!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FrutiaColors.accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: FrutiaColors.accent.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "💡 Consejos para esta comida:",
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: FrutiaColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...meal.personalizedTips!.map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                "• $tip",
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: FrutiaColors.primaryText,
                                  height: 1.3,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeGroup(BuildContext context, MealCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category.title,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...category.options
              .map((option) => _buildExchangeOption(context, option)),
        ],
      ),
    );
  }

  Widget _buildExchangeOption(BuildContext context, MealOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: FrutiaColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.primaryText,
                ),
                children: [
                  TextSpan(
                    text: option.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: " - ${option.portion}"),
                  TextSpan(
                    text: " (${option.calories} kcal)",
                    style: TextStyle(
                      fontSize: 12,
                      color: FrutiaColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesSection(BuildContext context, Map<String, Meal> meals) {
    // Recopilar todas las recetas de todas las comidas
    List<InspirationRecipe> allRecipes = [];
    meals.forEach((mealName, meal) {
      allRecipes.addAll(meal.suggestedRecipes);
    });

    if (allRecipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context, "Recetas Sugeridas", Icons.restaurant_menu),
        const SizedBox(height: 15),
        Text(
          "Ideas de cómo preparar tus alimentos de forma deliciosa",
          style: GoogleFonts.lato(
            fontSize: 14,
            color: FrutiaColors.secondaryText,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 15),
        ...allRecipes.map((recipe) => _buildRecipeCard(context, recipe)),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, InspirationRecipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: FrutiaColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant,
            color: FrutiaColors.accent,
            size: 24,
          ),
        ),
        title: Text(
          recipe.title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.mealType != null)
              Text(
                "Para ${recipe.mealType}",
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: FrutiaColors.accent,
                ),
              ),
            Text(
              "${recipe.readyInMinutes} min • ${recipe.calories} kcal",
              style: GoogleFonts.lato(
                fontSize: 12,
                color: FrutiaColors.secondaryText,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: FrutiaColors.secondaryText,
        ),
        onTap: () {
          // Navegar a detalle de receta
          _showRecipeDetail(context, recipe);
        },
      ),
    );
  }

  void _showRecipeDetail(BuildContext context, InspirationRecipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildRecipeInfoChip(
                      "${recipe.readyInMinutes} min", Icons.timer),
                  const SizedBox(width: 8),
                  _buildRecipeInfoChip(
                      "${recipe.calories} kcal", Icons.local_fire_department),
                  const SizedBox(width: 8),
                  if (recipe.difficultyLevel != null)
                    _buildRecipeInfoChip(recipe.difficultyLevel!, Icons.star),
                ],
              ),
              const SizedBox(height: 15),

              // Nota personalizada si existe
              if (recipe.personalizedNote != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recipe.personalizedNote!,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: FrutiaColors.primaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              Text(
                "Instrucciones:",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    recipe.instructions,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              // Información adicional si existe
              if (recipe.goalAlignment != null ||
                  recipe.sportsSupport != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.goalAlignment != null) ...[
                        Text(
                          "🎯 Alineación con tu objetivo:",
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          recipe.goalAlignment!,
                          style: GoogleFonts.lato(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (recipe.sportsSupport != null) ...[
                        Text(
                          "🏃 Apoyo deportivo:",
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          recipe.sportsSupport!,
                          style: GoogleFonts.lato(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FrutiaColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FrutiaColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: FrutiaColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTips(
      BuildContext context, PersonalizedTips personalizedTips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context, "Consejos Personalizados", Icons.lightbulb_outline),
        const SizedBox(height: 15),
        if (personalizedTips.anthropometricGuidance.isNotEmpty)
          _buildTipCard(
            context,
            "Guía Antropométrica",
            personalizedTips.anthropometricGuidance,
            Icons.analytics,
            Colors.blue,
          ),
        if (personalizedTips.difficultySupport.isNotEmpty)
          _buildTipCard(
            context,
            "Apoyo para Dificultades",
            personalizedTips.difficultySupport,
            Icons.support_agent,
            Colors.green,
          ),
        if (personalizedTips.eatingOutGuidance.isNotEmpty)
          _buildTipCard(
            context,
            "Comer Fuera de Casa",
            personalizedTips.eatingOutGuidance,
            Icons.restaurant,
            Colors.orange,
          ),
        if (personalizedTips.motivationalElements.isNotEmpty)
          _buildTipCard(
            context,
            "Motivación",
            personalizedTips.motivationalElements,
            Icons.favorite,
            Colors.pink,
          ),
        if (personalizedTips.ageSpecificAdvice.isNotEmpty)
          _buildTipCard(
            context,
            "Consejo por Edad",
            personalizedTips.ageSpecificAdvice,
            Icons.calendar_today,
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context, String title, String content,
      IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares que ya tenías...
  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: FrutiaColors.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: FrutiaColors.primaryText,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildSummarySection(BuildContext context, TargetMacros macros) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context, "Tus Macros Diarios", Icons.pie_chart_outline_rounded),
        const SizedBox(height: 15),
        _buildSummaryCard(
          context,
          icon: Icons.local_fire_department_outlined,
          title: 'Calorías',
          text: '${macros.calories} kcal',
          delay: 200.ms,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: Icons.egg_alt_outlined,
                title: 'Proteínas',
                text: '~${macros.protein}g',
                delay: 300.ms,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: Icons.local_pizza_outlined,
                title: 'Carbs',
                text: '~${macros.carbs}g',
                delay: 400.ms,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: Icons.water_drop_outlined,
                title: 'Grasas',
                text: '~${macros.fats}g',
                delay: 500.ms,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
    required Duration delay,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: FrutiaColors.accent, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: FrutiaColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildRecommendationsSection(
    BuildContext context,
    List<String> recomendaciones, {
    String title = "Recomendaciones",
    IconData icon = Icons.lightbulb_outline,
  }) {
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
                  const Text(
                    "• ",
                    style: TextStyle(
                      color: FrutiaColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rec,
                      style: GoogleFonts.lato(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
