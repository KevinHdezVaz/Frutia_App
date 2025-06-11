import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/pages/screens/datosPersonales/SuccessScreen.dart';

// Modelo simple para los datos del plan
class MealPlanData {
  final String summaryTitle;
  final String summaryText;
  final Map<String, dynamic> mealPlan;

  MealPlanData({
    required this.summaryTitle,
    required this.summaryText,
    required this.mealPlan,
  });

  factory MealPlanData.fromJson(Map<String, dynamic> json) {
    return MealPlanData(
      summaryTitle: json['summary_title'] ?? 'Resumen de tu Plan',
      summaryText: json['summary_text'] ?? 'Hemos creado este plan basado en tus respuestas.',
      mealPlan: json['meal_plan'] ?? {},
    );
  }
}

class PlanSummaryScreen extends StatelessWidget {
  final MealPlanData planData;

  const PlanSummaryScreen({Key? key, required this.planData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extraemos las listas de comidas
    final desayunos = (planData.mealPlan['desayuno'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final almuerzos = (planData.mealPlan['almuerzo'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final cenas = (planData.mealPlan['cena'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Encabezado fijo con título
            SliverAppBar(
              backgroundColor: FrutiaColors.primaryBackground,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Tu Plan Frutia",
                  style: GoogleFonts.lato(
                    color: FrutiaColors.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Resumen
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [FrutiaColors.accent, FrutiaColors.accent.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 28),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  planData.summaryTitle,
                                  style: GoogleFonts.lato(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            planData.summaryText,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                    const SizedBox(height: 24),

                    // Título de Comidas
                    Text(
                      "¿Qué incluye tu plan?",
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // Categorías de Comidas
                    _buildMealCategory(context, "🍳 Desayunos", desayunos),
                    const SizedBox(height: 20),
                    _buildMealCategory(context, "☀️ Almuerzos", almuerzos),
                    const SizedBox(height: 20),
                    _buildMealCategory(context, "🌙 Cenas", cenas),

                    const SizedBox(height: 40),

                    // Recomendaciones Generales
                    if (planData.mealPlan['recomendaciones'] != null && (planData.mealPlan['recomendaciones'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Consejos para el éxito",
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.accent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...((planData.mealPlan['recomendaciones'] as List).cast<String>()).map((recommendation) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.star, color: FrutiaColors.accent, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        recommendation,
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: FrutiaColors.secondaryText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                        ],
                      ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 40),

                    // Botón de Continuar
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const SuccessScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FrutiaColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_forward, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "¡Empecemos!",
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 800.ms).scale(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCategory(BuildContext context, String title, List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.accent,
              ),
            ),
            const Spacer(),
            Icon(
              title.contains("Desayunos")
                  ? Icons.free_breakfast
                  : title.contains("Almuerzos")
                      ? Icons.lunch_dining
                      : Icons.dinner_dining,
              color: FrutiaColors.accent,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildMealCard(context, item)).toList(),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Podrías implementar navegación a una pantalla de detalles de la receta
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Miniatura representativa
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: FrutiaColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  color: FrutiaColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['opcion'] ?? 'Opción',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['details']?['description'] ?? 'Recomendado por nuestros expertos.',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${item['details']?['calories'] ?? 'N/A'} kcal • ${item['details']?['prep_time_minutes'] ?? 'N/A'} min",
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: FrutiaColors.secondaryText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1);
  }
}