// lib/utils/daily_consumption_utils.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart'; // MealPlanData y TargetMacros
import 'package:Frutia/utils/colors.dart';

class DailyConsumptionUtils {
  /// Widget principal: Tarjeta de resumen de macros consumidos hoy
  /// Se muestra en la HomePage justo después del saludo
  static Widget buildDailyConsumptionSummary({
    required BuildContext context,
    required MealPlanData? mealPlanData,
    required int caloriesConsumed,
    required int proteinConsumed,
    required int carbsConsumed,
    required int fatsConsumed,
  }) {
    final l10n = AppLocalizations.of(context)!;

    // Si no hay plan activo → no mostramos nada
    if (mealPlanData == null) {
      return const SizedBox.shrink();
    }

    final target = mealPlanData.nutritionPlan.targetMacros;

    // Porcentajes
    final calPercent = target.calories > 0
        ? (caloriesConsumed / target.calories * 100).round()
        : 0;
    final protPercent = target.protein > 0
        ? (proteinConsumed / target.protein * 100).round()
        : 0;
    final carbPercent =
        target.carbs > 0 ? (carbsConsumed / target.carbs * 100).round() : 0;
    final fatPercent =
        target.fats > 0 ? (fatsConsumed / target.fats * 100).round() : 0;

    // Detectar si se pasó en calorías (para color rojo)
    final overCalories = caloriesConsumed > target.calories;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FrutiaColors.accent.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(
                Icons.restaurant_rounded,
                color: FrutiaColors.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.consumptionToday, // "Hoy llevas consumido"
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: FrutiaColors.primaryText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calorías (destacadas - más grandes)
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic, // ← AGREGAR ESTA LÍNEA
              children: [
                Text(
                  '$caloriesConsumed',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: overCalories
                        ? Colors.red.shade700
                        : FrutiaColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ ${target.calories}',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: FrutiaColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: overCalories
                        ? Colors.red.withOpacity(0.15)
                        : Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$calPercent%',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: overCalories
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

// Después del Row de calorías
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.caloriesRemaining(target.calories - caloriesConsumed),
              style: GoogleFonts.lato(
                fontSize: 14,
                color:
                    overCalories ? Colors.red.shade600 : Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Macros en fila compacta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroPill(
                label: l10n.protein, // "Prot"
                value: proteinConsumed,
                percent: protPercent,
                color: Colors.blue,
                over: proteinConsumed > target.protein,
              ),
              _buildMacroPill(
                label: l10n.carbs, // "Carb"
                value: carbsConsumed,
                percent: carbPercent,
                color: Colors.orange,
                over: carbsConsumed > target.carbs,
              ),
              _buildMacroPill(
                label: l10n.fats, // "Grasa"
                value: fatsConsumed,
                percent: fatPercent,
                color: Colors.purple,
                over: fatsConsumed > target.fats,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget pequeño para cada macro (Proteínas, Carbs, Grasas)
  static Widget _buildMacroPill({
    required String label,
    required int value,
    required int percent,
    required Color color,
    required bool over,
  }) {
    return Column(
      children: [
        Text(
          '$value${over ? " ↑" : ""}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: over ? Colors.red.shade600 : color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 13,
            color: FrutiaColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$percent%',
          style: GoogleFonts.lato(
            fontSize: 12,
            color: over ? Colors.red.shade600 : color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
