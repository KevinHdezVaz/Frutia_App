// ============================================
// WIDGETS PARA AGREGAR A TU HOMEPAGE
// ============================================

import 'dart:async';

import 'package:Frutia/l10n/app_localizations.dart';
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
  final Map<String, dynamic>? profileData; // ✅ NUEVO: Recibir profileData

  const NutritionalProfileCard({
    Key? key,
    required this.mealPlanData,
    this.profileData, // ✅ NUEVO
  }) : super(key: key);

  double _calculateBMI(double? weight, double? height) {
    if (weight == null || height == null || height == 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ Agregar esto al inicio

    if (mealPlanData == null) {
      return const SizedBox.shrink();
    }

    final anthro = mealPlanData!.nutritionPlan.anthropometricSummary;
    final nutritionalSummary = mealPlanData!.nutritionPlan.nutritionalSummary;
    final targetMacros = mealPlanData!.nutritionPlan.targetMacros;

    // ✅ NUEVO: Obtener datos del perfil si anthro es null
    final double? weight = anthro?.weight ??
        (profileData?['weight'] != null
            ? double.tryParse(profileData!['weight'].toString())
            : null);
    final double? height = anthro?.height ??
        (profileData?['height'] != null
            ? double.tryParse(profileData!['height'].toString())
            : null);
    final int? age = anthro?.age ?? profileData?['age'];
    final double bmi = anthro?.bmi ?? _calculateBMI(weight, height);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16), // ✅ Reducido de 20 a 16
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
          // Header - MÁS COMPACTO
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
                child: Text(
                  l10n.yourNutritionalProfile, // ✅ CAMBIO
                  style: GoogleFonts.poppins(
                    fontSize: 16, // ✅ Reducido de 18 a 16
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // ✅ Reducido de 20 a 12

          // ✅ NUEVO: Mostrar datos antropométricos si están disponibles
          if (weight != null || height != null || age != null || bmi > 0) ...[
            // Grid 2x2 más compacto
            Row(
              children: [
                if (age != null)
                  Expanded(
                    child: _buildCompactInfoChip(
                      l10n.age, // ✅ CAMBIO
                      l10n.ageYears(age), // ✅ CAMBIO
                      Icons.cake_outlined,
                      Colors.green,
                    ),
                  ),
                if (age != null && bmi > 0) const SizedBox(width: 8),
                if (bmi > 0)
                  Expanded(
                    child: _buildCompactInfoChip(
                      l10n.bmi, // ✅ CAMBIO
                      bmi.toStringAsFixed(1),
                      Icons.monitor_weight_outlined,
                      Colors.orange,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                if (weight != null)
                  Expanded(
                    child: Builder(builder: (context) {
                      final isEnglish =
                          Localizations.localeOf(context).languageCode == 'en';
                      String weightText;
                      if (isEnglish) {
                        // Convert kg to lbs: 1 kg = 2.20462 lbs
                        final lbs = (weight * 2.20462).round();
                        weightText = '$lbs lbs';
                      } else {
                        weightText = l10n.weightKg(weight.toStringAsFixed(0));
                      }

                      return _buildCompactInfoChip(
                        l10n.weight,
                        weightText,
                        Icons.fitness_center_outlined,
                        Colors.purple,
                      );
                    }),
                  ),
                if (weight != null && height != null) const SizedBox(width: 8),
                if (height != null)
                  Expanded(
                    child: Builder(builder: (context) {
                      final isEnglish =
                          Localizations.localeOf(context).languageCode == 'en';
                      String heightText;
                      if (isEnglish) {
                        // Convert cm to ft/in
                        final inchesTotal = height / 2.54;
                        final feet = (inchesTotal / 12).floor();
                        final inches = (inchesTotal % 12).round();
                        heightText = "$feet' $inches\"";
                      } else {
                        heightText = l10n.heightCm(height.toInt().toString());
                      }

                      return _buildCompactInfoChip(
                        l10n.height,
                        heightText,
                        Icons.height,
                        Colors.indigo,
                      );
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Divider sutil
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.blue.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactMacro(
                l10n.calories, // ✅ CAMBIO
                "${targetMacros.calories}",
                Colors.red,
              ),
              _buildVerticalDivider(),
              _buildCompactMacro(
                l10n.protein, // ✅ CAMBIO
                "${targetMacros.protein}g",
                Colors.blue,
              ),
              _buildVerticalDivider(),
              _buildCompactMacro(
                l10n.carbs, // ✅ CAMBIO
                "${targetMacros.carbs}g",
                Colors.orange,
              ),
              _buildVerticalDivider(),
              _buildCompactMacro(
                l10n.fats, // ✅ CAMBIO
                "${targetMacros.fats}g",
                Colors.purple,
              ),
            ],
          ),

          // Información nutricional del objetivo
          if (nutritionalSummary != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10), // ✅ Reducido de 12 a 10
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    "🎯",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nutritionalSummary.goal,
                          style: GoogleFonts.lato(
                            fontSize: 13, // ✅ Reducido de 14 a 13
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          nutritionalSummary.monthlyProgression,
                          style: GoogleFonts.lato(
                            fontSize: 11, // ✅ Reducido de 12 a 11
                            color: FrutiaColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
  }

  // ✅ NUEVO: Widget más compacto para info chips
  Widget _buildCompactInfoChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 9,
                    color: FrutiaColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NUEVO: Widget más compacto para macros
  Widget _buildCompactMacro(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.circle,
            color: color,
            size: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 9,
            color: FrutiaColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // ✅ NUEVO: Divisor vertical
  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}

// 3. MENSAJE PERSONALIZADO CARD
class PersonalizedMessageCard extends StatelessWidget {
  final MealPlanData? mealPlanData;
  final String userName;

  const PersonalizedMessageCard({
    Key? key,
    required this.mealPlanData,
    this.userName = '',
  }) : super(key: key);

  // ⭐ TRADUCE LA CLAVE Y REEMPLAZA :name POR EL NOMBRE REAL
  String getTranslatedPersonalizedMessage(String? key, AppLocalizations l10n) {
    String message;
    switch (key) {
      case 'personalized_message_am':
        message = l10n.personalizedMessageAM;
        break;
      case 'personalized_message_pm':
        message = l10n.personalizedMessagePM;
        break;
      case 'personalized_message_default':
      default:
        message = l10n.personalizedMessageDefault;
    }
    return message.replaceAll(':name', userName);
  }

  // Lógica simple para determinar la clave basada en los datos del plan
  String _deriveMessageKey() {
    if (mealPlanData == null) return 'personalized_message_default';

    // Buscar snacks en los horarios o comidas
    bool hasAMSnack = false;
    bool hasPMSnack = false;

    // Opción 1: Verificar el horario de comidas si existe
    if (mealPlanData!.nutritionPlan.mealSchedule != null) {
      final schedule = mealPlanData!.nutritionPlan.mealSchedule!;
      // Claves típicas que podrían indicar snacks (ajustar según backend real)
      hasAMSnack = schedule.keys.any((k) =>
          k.toLowerCase().contains('media mañana') ||
          k.toLowerCase().contains('mid-morning'));
      hasPMSnack = schedule.keys.any((k) =>
          k.toLowerCase().contains('media tarde') ||
          k.toLowerCase().contains('mid-afternoon') ||
          k.toLowerCase().contains('merienda'));
    }

    // Opción 2: Verificar las comidas (Meal objects) si la opción 1 no funcionó o para complementar
    if (!hasAMSnack && !hasPMSnack) {
      final meals = mealPlanData!.nutritionPlan.meals;
      // Iterar keys del mapa de comidas
      for (var key in meals.keys) {
        final lowerKey = key.toLowerCase();
        if (lowerKey.contains('media mañana') || lowerKey.contains('am'))
          hasAMSnack = true;
        if (lowerKey.contains('media tarde') ||
            lowerKey.contains('pm') ||
            lowerKey.contains('merienda')) hasPMSnack = true;
      }
    }

    if (hasPMSnack) return 'personalized_message_pm';
    if (hasAMSnack) return 'personalized_message_am';

    return 'personalized_message_default';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Usar el mensaje del backend si existe Y no queremos forzar la traducción,
    // PERO el usuario pidió explícitamente usar la traducción cliente.
    // Así que ignoramos el mensaje del backend y generamos uno nuevo.
    // O podríamos usar el del backend solo si está en el idioma correcto... pero eso es difícil de saber.
    // Implementamos la lógica solicitada:

    final messageKey = _deriveMessageKey();
    final message = getTranslatedPersonalizedMessage(messageKey, l10n);

    if (message.isEmpty) {
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
                  l10n.personalMessage,
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
