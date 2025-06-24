import 'package:Frutia/model/MealPlanData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/pages/screens/datosPersonales/SuccessScreen.dart';
import 'package:Frutia/services/plan_service.dart';

class PlanSummaryScreen extends StatelessWidget {
  const PlanSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlanService planService = PlanService();

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<MealPlanData>(
        future: planService.getCurrentPlan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: FrutiaColors.primary,
              ),
            );
          } else if (snapshot.hasError) {
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
                  expandedHeight: 220.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/fondoPantalla1.png',
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.3),
                          colorBlendMode: BlendMode.darken,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FrutiaColors.accent.withOpacity(0.9),
                                FrutiaColors.accentLight,
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
                                    width: 48,
                                    height: 48,
                                    color: Colors.white.withOpacity(0.8),
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
                        _buildSummarySection(context, planData),
                        const SizedBox(height: 30),
                        Text(
                          "¿Qué incluye tu plan?",
                          style: GoogleFonts.lato(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: FrutiaColors.primaryText,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 20),
                        _buildMealCategory(context, "🍳 Desayunos",
                            planData.desayunos, Icons.free_breakfast),
                        const SizedBox(height: 20),
                        _buildMealCategory(context, "☀️ Almuerzos",
                            planData.almuerzos, Icons.lunch_dining),
                        const SizedBox(height: 20),
                        _buildMealCategory(context, "🌙 Cenas", planData.cenas,
                            Icons.dinner_dining),
                        const SizedBox(height: 20),
                        _buildMealCategory(context, "🍏 Snacks Saludables",
                            planData.snacks, Icons.fastfood),
                        const SizedBox(height: 40),
                        if (planData.recomendaciones.isNotEmpty)
                          _buildRecommendationsSection(
                                  context, planData.recomendaciones)
                              .animate()
                              .fadeIn(delay: 600.ms),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: ElevatedButton(
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
                        shadowColor: FrutiaColors.primary.withOpacity(0.5),
                        minimumSize: const Size.fromHeight(60),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "¡Listo para empezar!",
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms).scale(duration: 500.ms),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('No se encontraron datos del plan.'),
            );
          }
        },
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, MealPlanData planData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          planData.summaryTitle,
          style: GoogleFonts.lato(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: FrutiaColors.primaryText,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 20),
        _buildSummaryCard(
          icon: Icons.fitness_center,
          title: "Tu Objetivo",
          text: planData.summaryText1,
          delay: 100.ms,
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          icon: Icons.tune,
          title: "Personalización",
          text: planData.summaryText2,
          delay: 200.ms,
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(
          icon: Icons.star,
          title: "Motivación",
          text: planData.summaryText3,
          delay: 300.ms,
        ),
        if (planData.summaryText4 != null) ...[
          const SizedBox(height: 16),
          _buildSummaryCard(
            icon: Icons.celebration,
            title: "Beneficios",
            text: planData.summaryText4!,
            delay: 400.ms,
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String text,
    required Duration delay,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FrutiaColors.secondaryBackground,
              FrutiaColors.secondaryBackground.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FrutiaColors.accent.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FrutiaColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: FrutiaColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        color: FrutiaColors.secondaryText,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildMealCategory(
      BuildContext context, String title, List<MealItem> items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: FrutiaColors.accent, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.accent,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 15),
        ...items.map((item) => _buildMealExpansionTile(context, item)).toList(),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildMealExpansionTile(BuildContext context, MealItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            item.option,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FrutiaColors.primaryText,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                item.description,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.local_fire_department,
                      size: 16,
                      color: FrutiaColors.secondaryText.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    "${item.calories} kcal",
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: FrutiaColors.secondaryText.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time,
                      size: 16,
                      color: FrutiaColors.secondaryText.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    "${item.prepTimeMinutes} min",
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: FrutiaColors.secondaryText.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.ingredients.isNotEmpty) ...[
                    const Divider(
                        height: 20,
                        thickness: 1,
                        color: FrutiaColors.tertiaryBackground),
                    Text(
                      "Ingredientes:",
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    ...item.ingredients.map((ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "• $ing",
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText),
                          ),
                        )),
                  ],
                  if (item.instructions.isNotEmpty) ...[
                    const Divider(
                        height: 20,
                        thickness: 1,
                        color: FrutiaColors.tertiaryBackground),
                    Text(
                      "Instrucciones:",
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    ...item.instructions.asMap().entries.map((entry) {
                      int index = entry.key;
                      String instr = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "${index + 1}. $instr",
                          style: GoogleFonts.lato(
                              fontSize: 14, color: FrutiaColors.secondaryText),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05);
  }

  Widget _buildRecommendationsSection(
      BuildContext context, List<String> recomendaciones) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              Icon(Icons.lightbulb_outline,
                  color: FrutiaColors.primary, size: 28),
              const SizedBox(width: 10),
              Text(
                "Consejos para el éxito",
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...recomendaciones
              .map((recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.check_circle_outline,
                              color: FrutiaColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: GoogleFonts.lato(
                              fontSize: 15,
                              color: FrutiaColors.primaryText,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
