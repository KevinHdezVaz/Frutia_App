// ============================================
// WIDGETS PARA AGREGAR A TU HOMEPAGE
// ============================================

import 'dart:async';

import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalizedTipsCarousel extends StatefulWidget {
  final MealPlanData? mealPlanData;

  const PersonalizedTipsCarousel({
    Key? key,
    required this.mealPlanData,
  }) : super(key: key);

  @override
  State<PersonalizedTipsCarousel> createState() =>
      _PersonalizedTipsCarouselState();
}

class _PersonalizedTipsCarouselState extends State<PersonalizedTipsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Iniciar auto-avance después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    final tipsList = _buildTipsList();
    if (tipsList.isEmpty) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < tipsList.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<Map<String, dynamic>> _buildTipsList() {
    final tips = widget.mealPlanData?.nutritionPlan.personalizedTips;
    if (tips == null) return [];

    final List<Map<String, dynamic>> tipsList = [];

    if (tips.anthropometricGuidance.isNotEmpty) {
      tipsList.add({
        'title': '📊 Guía Personal',
        'content': tips.anthropometricGuidance,
        'color': Colors.blue,
        'icon': Icons.analytics_outlined,
      });
    }

    if (tips.difficultySupport.isNotEmpty) {
      tipsList.add({
        'title': '🤝 Apoyo para Dificultades',
        'content': tips.difficultySupport,
        'color': Colors.green,
        'icon': Icons.support_agent,
      });
    }

    if (tips.eatingOutGuidance.isNotEmpty) {
      tipsList.add({
        'title': '🍽️ Comer Fuera de Casa',
        'content': tips.eatingOutGuidance,
        'color': Colors.orange,
        'icon': Icons.restaurant,
      });
    }

    if (tips.motivationalElements.isNotEmpty) {
      tipsList.add({
        'title': '💪 Motivación',
        'content': tips.motivationalElements,
        'color': Colors.purple,
        'icon': Icons.favorite,
      });
    }

    if (tips.ageSpecificAdvice.isNotEmpty) {
      tipsList.add({
        'title': '🎯 Consejo por Edad',
        'content': tips.ageSpecificAdvice,
        'color': Colors.indigo,
        'icon': Icons.calendar_today,
      });
    }

    return tipsList;
  }

  void _showTipDialog(Map<String, dynamic> tip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (tip['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tip['icon'] as IconData,
                        color: tip['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: tip['color'] as Color,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tip['content'] as String,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: FrutiaColors.primaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tip['color'] as Color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Entendido',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipsList = _buildTipsList();
    if (tipsList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: FrutiaColors.accent, size: 22),
              const SizedBox(width: 8),
              Text(
                'Consejos Para Ti',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          // Aumenté la altura del contenedor del carousel de 140 a 180
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: tipsList.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final tip = tipsList[index];
              return GestureDetector(
                onTap: () => _showTipDialog(tip),
                child: Container(
                  width: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (tip['color'] as Color).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (tip['color'] as Color).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: (tip['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tip['icon'] as IconData,
                              color: tip['color'] as Color,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: tip['color'] as Color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          tip['content'] as String,
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            color: FrutiaColors.primaryText,
                            height: 1.4,
                          ),
                          // Aumenté el número máximo de líneas de 4 a 5
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores de página
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              tipsList.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? FrutiaColors.accent
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms);
  }
}

// 2. WIDGET DEL CARD DE PERFIL NUTRICIONAL
class NutritionalProfileCard extends StatelessWidget {
  final MealPlanData? mealPlanData;

  const NutritionalProfileCard({
    Key? key,
    required this.mealPlanData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mealPlanData?.nutritionPlan.anthropometricSummary == null) {
      return const SizedBox.shrink();
    }

    final anthro = mealPlanData!.nutritionPlan.anthropometricSummary!;
    final nutritionalSummary = mealPlanData!.nutritionPlan.nutritionalSummary;
    final targetMacros = mealPlanData!.nutritionPlan.targetMacros;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.05),
            Colors.indigo.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tu Perfil Nutricional",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      "Información nutricional.",
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: FrutiaColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Datos antropométricos en grid
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  "Edad",
                  "${anthro.age} años",
                  Icons.cake,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  "BMI",
                  "${anthro.bmi.toStringAsFixed(1)}",
                  Icons.monitor_weight,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  "Peso",
                  "${anthro.weight} kg",
                  Icons.fitness_center,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  "Estatura",
                  "${anthro.height.toInt()} cm",
                  Icons.height,
                  Colors.indigo,
                ),
              ),
            ],
          ),

          // Información nutricional si está disponible
          if (nutritionalSummary != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🎯 ${nutritionalSummary.goal}",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nutritionalSummary.monthlyProgression,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: FrutiaColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Macros resumen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroStat(
                  "Calorías", "${targetMacros.calories}", Colors.red),
              _buildMacroStat(
                  "Proteínas", "${targetMacros.protein}g", Colors.blue),
              _buildMacroStat(
                  "Carbos", "${targetMacros.carbs}g", Colors.orange),
              _buildMacroStat("Grasas", "${targetMacros.fats}g", Colors.purple),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  Widget _buildInfoChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: FrutiaColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 10,
            color: FrutiaColors.secondaryText,
          ),
        ),
      ],
    );
  }
}

// 3. MENSAJE PERSONALIZADO CARD
class PersonalizedMessageCard extends StatelessWidget {
  final MealPlanData? mealPlanData;

  const PersonalizedMessageCard({
    Key? key,
    required this.mealPlanData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = mealPlanData?.nutritionPlan.personalizedMessage;

    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FrutiaColors.accent.withOpacity(0.05),
            FrutiaColors.accent2.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FrutiaColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              color: FrutiaColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "💝 Mensaje Personal",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: FrutiaColors.primaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }
}
