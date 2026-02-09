import 'dart:convert';
import 'dart:io';
import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/pages/screens/historyScreen.dart';
import 'package:Frutia/pages/screens/miplan/DescargarPDFDialog.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/RecommendationItem.dart';
import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class ProfessionalMiPlanDiarioScreen extends StatefulWidget {
  const ProfessionalMiPlanDiarioScreen({Key? key}) : super(key: key);

  @override
  _ProfessionalMiPlanDiarioScreenState createState() =>
      _ProfessionalMiPlanDiarioScreenState();
}

class _ProfessionalMiPlanDiarioScreenState
    extends State<ProfessionalMiPlanDiarioScreen> {
  final PlanService _planService = PlanService();
  MealPlanData? _mealPlanData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userName;
  Map<String, dynamic>? _userProfile;
  final ProfileService _profileService = ProfileService();
  final Map<String, Map<String, MealOption>> _dailySelections = {};
  int _totalCalories = 0;
  int _totalProtein = 0;
  int _totalCarbs = 0;
  int _totalFats = 0;
  final Map<String, List<String>> _validationWarnings = {};
  final Map<String, bool> _hasEggSelection = {};
  String? _userBudget;
  final Set<String> _registeringMeals = {};
  final Set<String> _completedMeals = {};

  final Map<String, Map<String, int>> _completedMealsMacros = {};

  String? _selectedSnack; // 'Snack AM' o 'Snack PM' o null

  @override
  void initState() {
    super.initState();
    _fetchPlanAndInitialState();
    _fetchUserName();
    _extractUserBudget(); // NUEVO
  }

  Future<void> _fetchUserName() async {
    try {
      final name = await _planService.getUserName();
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
      debugPrint('User name loaded: $name');
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      if (mounted) {
        setState(() {
          _userName = AppLocalizations.of(context)!
              .userDefault; // Valor por defecto en caso de error
        });
      }
    }
  }

  void _removeSelection(String mealTitle, String categoryTitle) {
    if (_completedMeals.contains(mealTitle)) return;

    setState(() {
      _dailySelections[mealTitle]!.remove(categoryTitle);
      _calculateTotals();
    });
  }

  // NUEVO: Extraer el presupuesto del usuario
  void _extractUserBudget() {
    if (_userProfile != null) {
      _userBudget = _userProfile!['budget']?.toString().toLowerCase();
      debugPrint('Presupuesto del usuario: $_userBudget');
    }
  }

  void _updateSelection(
      String mealTitle, String categoryTitle, MealOption option) {
    if (_completedMeals.contains(mealTitle)) return;

    final warnings = _validateOption(mealTitle, categoryTitle, option);
    final criticalWarnings = warnings.where((w) => w.contains('🔴')).toList();

    if (criticalWarnings.isNotEmpty) {
      _showValidationWarning(
        warnings,
        option, // ⭐ AGREGAR ESTA LÍNEA
        onProceed: () {
          _performSelection(mealTitle, categoryTitle, option, warnings);
        },
        onCancel: () {
          debugPrint('Selección cancelada por el usuario');
        },
      );
    } else {
      _performSelection(mealTitle, categoryTitle, option, warnings);

      if (warnings.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: warnings.map((w) => Text(w)).toList(),
            ),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

// Método auxiliar para realizar la selección
  void _performSelection(String mealTitle, String categoryTitle,
      MealOption option, List<String> warnings) {
    setState(() {
      _dailySelections[mealTitle]![categoryTitle] = option;
      _validationWarnings[mealTitle] = warnings;

      // Verificar si hay huevos en esta comida
      if (option.isEgg) {
        _hasEggSelection[mealTitle] = true;
      }

      _calculateTotals();
    });
  }

  List<String> _validateOption(
      String mealTitle, String categoryTitle, MealOption option) {
    List<String> warnings = [];

    if (_mealPlanData == null) return warnings;

    final plan = _mealPlanData!.nutritionPlan;

    // 1. CALCULAR MACROS PROYECTADOS
    int projectedCalories = _totalCalories + option.calories;
    int projectedProtein = _totalProtein + option.protein;
    int projectedCarbs = _totalCarbs + option.carbs;
    int projectedFats = _totalFats + option.fats;

    final currentSelection = _dailySelections[mealTitle]?[categoryTitle];
    if (currentSelection != null) {
      projectedCalories =
          projectedCalories - currentSelection.calories + option.calories;
      projectedProtein =
          projectedProtein - currentSelection.protein + option.protein;
      projectedCarbs = projectedCarbs - currentSelection.carbs + option.carbs;
      projectedFats = projectedFats - currentSelection.fats + option.fats;
    }

    // 2. CALCULAR EXCESOS
    final targetCalories = plan.targetMacros.calories;
    final targetProtein = plan.targetMacros.protein;
    final targetCarbs = plan.targetMacros.carbs;
    final targetFats = plan.targetMacros.fats;

    int caloriesExcess = projectedCalories - targetCalories;
    int proteinExcess = projectedProtein - targetProtein;
    int carbsExcess = projectedCarbs - targetCarbs;
    int fatsExcess = projectedFats - targetFats;

    // 3. VALIDAR Y AGREGAR WARNINGS CON CÁLCULO DE AJUSTE
    if (caloriesExcess > 0) {
      warnings.add(
          '🔴CALORIAS|${caloriesExcess}|${option.name}|${option.calories}|${caloriesExcess}|0|0|0');
    }

    if (proteinExcess > 10) {
      warnings.add(
          '🔴PROTEINA|${proteinExcess}|${option.name}|0|${proteinExcess}|0|0');
    }

    if (carbsExcess > 15) {
      warnings.add(
          '🔴CARBOHIDRATOS|${carbsExcess}|${option.name}|0|0|${carbsExcess}|0');
    }

    if (fatsExcess > 10) {
      warnings.add('🔴GRASAS|${fatsExcess}|${option.name}|0|0|0|${fatsExcess}');
    }

    // 4. Validar presupuesto
    if (_userBudget != null) {
      bool isLowBudget =
          _userBudget!.contains('low') || _userBudget!.contains('bajo');

      if (isLowBudget && option.isHighBudget) {
        warnings.add(AppLocalizations.of(context)!.lowBudgetWarning);
      }
    }

    // 5. Validar repetición de huevos
    if (option.isEgg) {
      int eggCount = 0;
      _hasEggSelection.forEach((meal, hasEgg) {
        if (meal != mealTitle && hasEgg) eggCount++;
      });
      if (eggCount > 0) {
        warnings.add(AppLocalizations.of(context)!.alreadySelectedEgg);
      }
    }

    return warnings;
  }

  Map<String, dynamic> _calculateAdjustedPortion(
      AppLocalizations l10n,
      MealOption option,
      int caloriesExcess,
      int proteinExcess,
      int carbsExcess,
      int fatsExcess) {
    final portionMatch = RegExp(r'(\d+)g').firstMatch(option.portion);
    if (portionMatch == null) {
      return {'canAdjust': false, 'message': l10n.autoAdjustError};
    }

    final originalWeight = int.parse(portionMatch.group(1)!);

    // ✅ NUEVO ENFOQUE: Calcular cuántos gramos necesitas QUITAR
    double gramsToRemove = 0;

    // Para cada macro, calcular cuántos gramos del alimento necesitas eliminar
    if (caloriesExcess > 0 && option.calories > 0) {
      double gramsNeeded = (caloriesExcess / option.calories) * 100;
      if (gramsNeeded > gramsToRemove) gramsToRemove = gramsNeeded;
    }

    if (proteinExcess > 10 && option.protein > 0) {
      double gramsNeeded = (proteinExcess / option.protein) * 100;
      if (gramsNeeded > gramsToRemove) gramsToRemove = gramsNeeded;
    }

    if (carbsExcess > 15 && option.carbs > 0) {
      double gramsNeeded = (carbsExcess / option.carbs) * 100;
      if (gramsNeeded > gramsToRemove) gramsToRemove = gramsNeeded;
    }

    if (fatsExcess > 10 && option.fats > 0) {
      double gramsNeeded = (fatsExcess / option.fats) * 100;
      if (gramsNeeded > gramsToRemove) gramsToRemove = gramsNeeded;
    }

    // ✅ Si no hay exceso que ajustar, retornar sin ajuste
    if (gramsToRemove == 0) {
      return {'canAdjust': false, 'message': l10n.autoAdjustNoExcess};
    }

    // ✅ Calcular nuevo peso
    final adjustedWeight = (originalWeight - gramsToRemove).round();

    // ✅ No permitir reducciones menores al 20% del peso original
    final minAllowedWeight = (originalWeight * 0.2).round();

    // ✅ Si la reducción es demasiado agresiva, no permitir
    if (adjustedWeight < minAllowedWeight) {
      return {'message': l10n.autoAdjustTooAggressive};
    }

    // ✅ Calcular porcentaje de reducción
    final reductionPercent = ((gramsToRemove / originalWeight) * 100).round();

    // ✅ Calcular macros ajustados
    final adjustmentRatio = adjustedWeight / originalWeight;

    return {
      'canAdjust': true,
      'originalWeight': originalWeight,
      'adjustedWeight': adjustedWeight,
      'reductionPercent': reductionPercent,
      'adjustedCalories': (option.calories * adjustmentRatio).round(),
      'adjustedProtein': (option.protein * adjustmentRatio).round(),
      'adjustedCarbs': (option.carbs * adjustmentRatio).round(),
      'adjustedFats': (option.fats * adjustmentRatio).round(),
    };
  }

  // NUEVO: Obtener porcentaje de macros por comida
  double _getMealPercentage(String mealTitle) {
    switch (mealTitle.toLowerCase()) {
      case 'desayuno':
        return 0.30;
      case 'almuerzo':
        return 0.40;
      case 'cena':
        return 0.30;
      default:
        return 0.33;
    }
  }

  // ⭐ AGREGAR ESTE MÉTODO (línea ~1070, después de _normalizeMealTitle)

  void _showValidationWarning(List<String> warnings, MealOption option,
      {VoidCallback? onProceed, VoidCallback? onCancel}) {
    final l10n = AppLocalizations.of(context)!;
    // Separar advertencias críticas
    final criticalWarnings = warnings.where((w) => w.startsWith('🔴')).toList();
    final suggestions = warnings.where((w) => !w.startsWith('🔴')).toList();

    // Calcular excesos totales
    int totalCaloriesExcess = 0;
    int totalProteinExcess = 0;
    int totalCarbsExcess = 0;
    int totalFatsExcess = 0;

    for (var warning in criticalWarnings) {
      final parts = warning.split('|');
      if (parts.length >= 8) {
        totalCaloriesExcess += int.tryParse(parts[4]) ?? 0;
        totalProteinExcess += int.tryParse(parts[5]) ?? 0;
        totalCarbsExcess += int.tryParse(parts[6]) ?? 0;
        totalFatsExcess += int.tryParse(parts[7]) ?? 0;
      }
    }
    final adjustment = _calculateAdjustedPortion(
        l10n,
        option,
        totalCaloriesExcess,
        totalProteinExcess,
        totalCarbsExcess,
        totalFatsExcess);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.attentionTitle,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚠️ ADVERTENCIAS CRÍTICAS
              // Dentro de showDialog → content → Column → si criticalWarnings.isNotEmpty

              if (criticalWarnings.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.priority_high,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.willExceedMacros,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ← AGREGAR SIEMPRE EL EXCESO DE CALORÍAS PRIMERO (si existe)
                      if (totalCaloriesExcess > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16)),
                              Expanded(
                                child: Text(
                                  '🔴 CALORÍAS: Te pasaste por **$totalCaloriesExcess kcal**',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Luego los demás macros (como antes)
                      ...criticalWarnings.map((w) {
                        final parts = w.split('|');
                        final macro = parts[0].replaceAll('🔴', '').trim();
                        final excess = parts[1];
                        if (macro == 'CALORIAS')
                          return const SizedBox
                              .shrink(); // ya lo mostramos arriba
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: Colors.red)),
                              Expanded(
                                child: Text(
                                  '🔴 $macro: +$excess g',
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ✅ SOLUCIÓN: PORCIÓN AJUSTADA O MENSAJE DEL CHAT
              if (adjustment['canAdjust'] == true) ...[
                _buildAdjustmentSuggestion(adjustment, option),
              ] else ...[
                _buildChatSuggestion(option),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onProceed?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.selectAnyway,
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

// ⭐ HELPER: Mostrar macro restante con color dinámico
  Widget _buildMiniMacroWithRemaining(
      String label, int remaining, Color color) {
    final isNegative = remaining < 0;
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Icon(
              isNegative ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: isNegative ? Colors.red : Colors.green,
            ),
            Text(
              '${remaining.abs()}g',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isNegative ? Colors.red : color,
              ),
            ),
          ],
        ),
      ],
    );
  }

// ✅ WIDGET: Sugerencia de Ajuste (cuando SÍ se puede calcular)
  Widget _buildAdjustmentSuggestion(
      Map<String, dynamic> adjustment, MealOption option) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.4), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.scale_outlined, color: Colors.green, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.adjustmentSuggestion,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      l10n.pdfCookingTip,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.originalPortion,
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${adjustment['originalWeight']}g',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, color: Colors.green, size: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.adjustedPortion,
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${adjustment['adjustedWeight']}g',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.reducePortionMessage(
                        adjustment['reductionPercent'].toString(),
                        (adjustment['originalWeight'] -
                                adjustment['adjustedWeight'])
                            .toString()),
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniMacro(
                        'Cal', adjustment['adjustedCalories'], Colors.orange),
                    _buildMiniMacro(
                        'P', adjustment['adjustedProtein'], Colors.blue),
                    _buildMiniMacro(
                        'C', adjustment['adjustedCarbs'], Colors.green),
                    _buildMiniMacro(
                        'G', adjustment['adjustedFats'], Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ WIDGET: Mensaje del Chat (cuando NO se puede calcular) - CON CONTEXTO
  Widget _buildChatSuggestion(MealOption option) {
    // ⭐ Generar mensaje personalizado basado en el día
    final contextMessage = _generateContextualAdvice(option);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FrutiaColors.accent.withOpacity(0.1),
            FrutiaColors.accent2.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: FrutiaColors.accent.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FrutiaColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chat_bubble_outline,
                    color: FrutiaColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.customAdviceTitle,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.accent,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: FrutiaColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ NUEVO: Mensaje contextual
                Text(
                  contextMessage,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: FrutiaColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.askFrutiaChat,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!
                        .askFrutiaChatExample
                        .replaceFirst('[X]', option.name),
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: FrutiaColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ⭐ NUEVO MÉTODO: Genera consejo contextual basado en el día
  String _generateContextualAdvice(MealOption option) {
    if (!mounted) return '';
    final l10n = AppLocalizations.of(context)!;

    // Calcular variables acumuladas
    int consumedCalories = _totalCalories;
    final plan = _mealPlanData!.nutritionPlan;
    final remainingCalories = plan.targetMacros.calories - consumedCalories;
    final mealsLeft = plan.meals.length -
        _completedMeals.length; // Suponiendo 3 comidas principales

    if (consumedCalories == 0) {
      return l10n.adviceExceedMacrosNoMeals(option.name);
    }

    if (remainingCalories < option.calories) {
      return l10n.adviceExceedMacrosConsumed(
          consumedCalories, option.name, option.calories, remainingCalories);
    }

    if (mealsLeft <= 0) {
      return l10n.adviceExceedMacrosAllMeals(option.name);
    }

    return l10n.adviceExceedMacrosRemaining(consumedCalories, option.name,
        option.calories, remainingCalories - option.calories, mealsLeft);
  }

// Widget helper para mostrar macros pequeños
  Widget _buildMiniMacro(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$value',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _registerMeal(
      String mealTitle, List<MealOption> selections) async {
    final l10n = AppLocalizations.of(context)!;
    String normalizedMealType = getLocalizedMealTitle(mealTitle, l10n);
    debugPrint('🔴 Registrando comida: "$mealTitle"');

    setState(() {
      _registeringMeals.add(mealTitle);
    });

    try {
      await _saveSelections();

      // ⭐ ENVÍA AL BACKEND (esto es lo que guarda en el historial)
      await _planService.logMeal(
        date: DateTime.now(),
        mealType: normalizedMealType,
        selections: selections,
      );

      // ⭐ Si llega aquí = éxito en el backend
      int mealCalories = 0;
      int mealProtein = 0;
      int mealCarbs = 0;
      int mealFats = 0;
      _dailySelections[mealTitle]?.values.forEach((option) {
        mealCalories += option.calories;
        mealProtein += option.protein;
        mealCarbs += option.carbs;
        mealFats += option.fats;
      });

      setState(() {
        _completedMeals.add(mealTitle);
        _completedMealsMacros[mealTitle] = {
          'calories': mealCalories,
          'protein': mealProtein,
          'carbs': mealCarbs,
          'fats': mealFats,
        };
        _dailySelections[mealTitle]?.clear();
        _hasEggSelection.remove(mealTitle);
        _validationWarnings.remove(mealTitle);
      });

      // ⭐ GUARDAR LOCALMENTE las comidas completadas (fallback por si sales y vuelves rápido)
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final completedTodayList = _completedMeals.toList();
      await prefs.setStringList('completed_meals_$today', completedTodayList);
      debugPrint(
          '💾 Comidas completadas guardadas localmente: $completedTodayList');

      await _saveSelections();
      _calculateTotals();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mealRegisteredSuccess(mealTitle)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // ⭐ ERROR: NO marcar como completada y mostrar mensaje claro
      setState(() {
        _registeringMeals.remove(mealTitle);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error al guardar en el historial. Intenta de nuevo. $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
      debugPrint('❌ Error registrando comida: $e');
    } finally {
      setState(() {
        _registeringMeals.remove(mealTitle);
      });
    }
  }

// ⭐ AGREGAR ESTE MÉTODO HELPER (después de _registerMeal)
  String _normalizeMealTypeToSpanish(String mealTitle) {
    final normalized = mealTitle.toLowerCase();

    final mapping = {
      'breakfast': 'Desayuno',
      'desayuno': 'Desayuno',
      'lunch': 'Almuerzo',
      'almuerzo': 'Almuerzo',
      'dinner': 'Cena',
      'cena': 'Cena',
      'morning snack': 'Snack AM',
      'snack am': 'Snack AM',
      'afternoon snack': 'Snack PM',
      'snack pm': 'Snack PM',
      'fruit snack': 'Snack de frutas',
      'snack de frutas': 'Snack de frutas',
      'shake': 'Shake',
    };

    return mapping[normalized] ?? mealTitle;
  }

  bool get _isUserPremium {
    if (_userProfile == null) return false;
    final status = _userProfile?['subscription_status']?.toLowerCase();
    return status == 'active' || status == 'premium';
  }

  Future<void> _fetchUserNews() async {
    try {
      final name = await _planService.getUserName();
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
      debugPrint('User name loaded: $name');
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      if (mounted) {
        setState(() {
          _userName = AppLocalizations.of(context)!.userDefault;
        });
      }
    }
  }

// Agregar este método en la clase _ProfessionalMiPlanDiarioScreenState
  String _normalizeMealTitle(String mealType) {
    // ⭐ SIMPLEMENTE RETORNA TAL CUAL
    // El backend ya está enviando el mealType en el idioma correcto
    return mealType;
  }

  Future<void> _fetchPlanAndInitialState() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _planService.getCurrentPlan(),
        _planService.getHistory(),
        _profileService.getProfile(),
      ]);
      final plan = results[0] as MealPlanData?;
      final history = results[1] as List<MealLog>;
      final profile = results[2] as Map<String, dynamic>?;
      final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final logsToday = history.where((log) {
        final logDate = log.date.substring(0, 10);
        return logDate == todayString;
      }).toList();

      if (plan == null) {
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.errorNoActivePlan;
            _isLoading = false;
          });
        }
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      // ⭐ NORMALIZACIÓN CORRECTA (esto hace que las comidas aparezcan)
      final normalizedMeals = <String, Meal>{};
      plan.nutritionPlan.meals.forEach((backendKey, meal) {
        final displayTitle = getLocalizedMealTitle(backendKey, l10n);
        normalizedMeals[displayTitle] = meal;
      });
      plan.nutritionPlan.meals = normalizedMeals;

      // Inicializar _dailySelections con keys localizadas
      normalizedMeals.keys.forEach((title) {
        _dailySelections[title] = {};
      });

      // Comidas completadas del backend
      final completedToday = logsToday
          .map((log) => getLocalizedMealTitle(log.mealType, l10n))
          .toSet();
      _completedMeals.addAll(completedToday);

      // Macros completadas del backend
      for (var log in logsToday) {
        final translatedMeal = getLocalizedMealTitle(log.mealType, l10n);

        int mealCalories = 0;
        int mealProtein = 0;
        int mealCarbs = 0;
        int mealFats = 0;
        for (var selection in log.selections) {
          mealCalories += selection.calories;
          mealProtein += selection.protein;
          mealCarbs += selection.carbs;
          mealFats += selection.fats;
        }
        _completedMealsMacros[translatedMeal] = {
          'calories': mealCalories,
          'protein': mealProtein,
          'carbs': mealCarbs,
          'fats': mealFats,
        };
      }

      // ⭐ NUEVO: Cargar fallback local de comidas completadas (por si backend no sincronizó)
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final localCompleted =
          prefs.getStringList('completed_meals_$today') ?? [];
      _completedMeals.addAll(localCompleted);
      debugPrint(
          '✅ Comidas completadas cargadas localmente (fallback): $localCompleted');

      await _loadSelectionsFromLocal();

      if (mounted) {
        setState(() {
          _mealPlanData = plan;
          _userProfile = profile;
          _isLoading = false;
          _calculateTotals();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.errorLoadingData(e.toString());
          _isLoading = false;
        });
      }
      debugPrint('❌ Error en _fetchPlanAndInitialState: $e');
    }
  }

  Future<void> _loadSelectionsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedData = prefs.getString('daily_selection_$today');
    if (savedData != null) {
      final l10n = AppLocalizations.of(context)!;
      final decodedData = json.decode(savedData) as Map<String, dynamic>;
      decodedData.forEach((savedMealKey, selections) {
        // Traducir la key guardada (que puede ser en inglés o español viejo) a localized
        final normalizedMeal = getLocalizedMealTitle(savedMealKey, l10n);

        if (!_completedMeals.contains(normalizedMeal) &&
            _dailySelections.containsKey(normalizedMeal)) {
          final Map<String, MealOption> loadedSelections = {};
          (selections as Map<String, dynamic>).forEach((cat, optJson) {
            loadedSelections[cat] = MealOption.fromJson(optJson);
          });
          _dailySelections[normalizedMeal] = loadedSelections;
          debugPrint('✅ Cargando selecciones de $normalizedMeal desde storage');
        } else {
          debugPrint(
              '❌ NO cargando selecciones de $savedMealKey (ya completada o key no coincide)');
        }
      });
    }
  }

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Guardar directamente con keys localizadas (no normalizar a español fijo)
    final normalizedSelections = <String, dynamic>{};
    _dailySelections.forEach((localizedMealTitle, selections) {
      normalizedSelections[localizedMealTitle] =
          selections.map((cat, opt) => MapEntry(cat, opt.toJson()));
      debugPrint('💾 Guardando $localizedMealTitle en storage');
    });

    final encodedData = json.encode(normalizedSelections);
    await prefs.setString('daily_selection_$today', encodedData);
    debugPrint('✅ Guardado en SharedPreferences');
  }

  Map<String, Meal> _getTranslatedMealsForPDF(
      NutritionPlan plan, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final translatedMeals = <String, Meal>{};

    plan.meals.forEach((backendKey, meal) {
      // 1. Traducir título de la comida (Desayuno → Breakfast)
      final translatedKey = translateMeal(backendKey, l10n);

      // 2. Traducir categorías y opciones
      final translatedComponents = meal.components.map((category) {
        // Traducir título de categoría (Proteínas → Proteins)
        final translatedCatTitle = translateCategory(category.title, l10n);

        // Traducir cada opción de alimento
        final translatedOptions = category.options.map((option) {
          return MealOption(
            name: getLocalizedFoodName(option.name, l10n),
            portion: translatePortion(
                option.portion, l10n), // Usa tu función de porciones
            calories: option.calories,
            protein: option.protein,
            carbs: option.carbs,
            fats: option.fats,
            isEgg: option.isEgg,
            isHighBudget: option.isHighBudget,
            isLowBudget: option.isLowBudget,
            budgetAppropriate: option.budgetAppropriate,
            prices: option.prices,
            imageUrl: option.imageUrl,
            ingredients: option.ingredients
                .map((ing) => getLocalizedFoodName(ing, l10n))
                .toList(),
          );
        }).toList();

        return MealCategory(
          title: translatedCatTitle,
          options: translatedOptions,
        );
      }).toList();

      // 3. Crear Meal traducido
      translatedMeals[translatedKey] = Meal(
        components: translatedComponents,
        suggestedRecipes: meal.suggestedRecipes.map((recipe) {
          return InspirationRecipe(
            title: getLocalizedFoodName(recipe.title, l10n),
            imageUrl: recipe.imageUrl,
            readyInMinutes: recipe.readyInMinutes,
            servings: recipe.servings,
            instructions: formatRecipeInstructions(recipe.instructions, l10n),
            extendedIngredients: recipe.extendedIngredients.map((ing) {
              if (ing is Map<String, dynamic>) {
                return {
                  ...ing,
                  'name': getLocalizedFoodName(ing['name'] ?? '', l10n),
                };
              }
              return ing;
            }).toList(),
            analyzedInstructions: recipe.analyzedInstructions,
            calories: recipe.calories,
            protein: recipe.protein,
            carbs: recipe.carbs,
            fats: recipe.fats,
            mealType: translateMeal(recipe.mealType ?? '', l10n),
            personalizedNote: recipe.personalizedNote,
            goalAlignment: recipe.goalAlignment,
            sportsSupport: recipe.sportsSupport,
            cuisineType: recipe.cuisineType,
            difficultyLevel: recipe.difficultyLevel,
          );
        }).toList(),
        mealTiming: meal.mealTiming,
        personalizedTips: meal.personalizedTips,
      );
    });

    return translatedMeals;
  }

  void _calculateTotals() {
    int tempCalories = 0, tempProtein = 0, tempCarbs = 0, tempFats = 0;

    // ⭐ SUMAR selecciones actuales (comidas NO completadas)
    _dailySelections.forEach((mealTitle, selections) {
      selections.values.forEach((option) {
        tempCalories += option.calories;
        tempProtein += option.protein;
        tempCarbs += option.carbs;
        tempFats += option.fats;
      });
    });

    // ⭐ SUMAR macros de comidas completadas
    _completedMealsMacros.forEach((mealTitle, macros) {
      tempCalories += macros['calories'] ?? 0;
      tempProtein += macros['protein'] ?? 0;
      tempCarbs += macros['carbs'] ?? 0;
      tempFats += macros['fats'] ?? 0;
    });

    setState(() {
      _totalCalories = tempCalories;
      _totalProtein = tempProtein;
      _totalCarbs = tempCarbs;
      _totalFats = tempFats;
    });

    debugPrint(
        '📊 Totales: Cal=$tempCalories, P=$tempProtein, C=$tempCarbs, G=$tempFats');
  }

  // 1. Traducción de títulos de comidas (Desayuno → Breakfast si en inglés)
  String translateMeal(String key, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final normalized = key.toLowerCase().trim();

    if (locale == 'es') {
      switch (normalized) {
        case 'desayuno':
          return l10n.breakfast ?? 'Desayuno';
        case 'almuerzo':
          return l10n.lunch ?? 'Almuerzo';
        case 'cena':
          return l10n.dinner ?? 'Cena';
        case 'snack am':
        case 'snack_am':
          return l10n.snackAM ?? 'Snack AM';
        case 'snack pm':
        case 'snack_pm':
          return l10n.snackPM ?? 'Snack PM';
        default:
          return key;
      }
    } else {
      switch (normalized) {
        case 'desayuno':
          return 'Breakfast';
        case 'almuerzo':
          return 'Lunch';
        case 'cena':
          return 'Dinner';
        case 'snack am':
        case 'snack_am':
          return 'Morning Snack';
        case 'snack pm':
        case 'snack_pm':
          return 'Afternoon Snack';
        default:
          return key[0].toUpperCase() + key.substring(1).toLowerCase();
      }
    }
  }

// 2. Traducción de categorías (Proteínas → Proteins)
  String translateCategory(String backendCategory, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'es') {
      return backendCategory.trim();
    }

    switch (backendCategory.trim()) {
      case 'Proteínas':
        return l10n.proteins ?? 'Proteins';
      case 'Carbohidratos':
        return l10n.carbohydrates ?? 'Carbohydrates';
      case 'Grasas':
        return l10n.fats ?? 'Fats';
      case 'Vegetales':
        return l10n.vegetables ?? 'Vegetables';
      case 'Frutas':
        return l10n.fruits ?? 'Fruits';
      default:
        return backendCategory.trim();
    }
  }

  String getLocalizedFoodName(String backendName, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    // En español: devolvemos exactamente lo del backend
    if (locale == 'es') {
      return backendName.trim();
    }

    const Map<String, String> esToEn = {
      // ─────────────────────────────────────────────────────────────
      // Proteínas
      // ─────────────────────────────────────────────────────────────
      'Huevo entero': 'Whole egg',
      'Huevos enteros': 'Whole eggs',
      'Claras + Huevo Entero': 'Egg whites + Whole egg',
      'Claras + Huevo entero': 'Egg whites + Whole egg',
      'Claras pasteurizadas': 'Pasteurized egg whites',
      'Pechuga de pollo': 'Chicken breast',
      'Pollo muslo': 'Chicken thigh',
      'Pollo muslo con piel': 'Chicken thigh with skin',
      'Carne molida': 'Ground beef',
      'Carne molida 80/20': 'Ground beef 80/20',
      'Carne de res magra': 'Lean beef',
      'Atún en lata': 'Canned tuna',
      'Atún fresco': 'Fresh tuna',
      'Salmón fresco': 'Fresh salmon',
      'Pescado blanco': 'White fish',
      'Pechuga de pavo': 'Turkey breast',
      'Yogurt griego': 'Greek yogurt',
      'Yogurt griego alto en proteínas': 'High-protein Greek yogurt',
      'Proteína whey': 'Whey protein',
      'Proteína en polvo': 'Protein powder',
      'Caseína': 'Casein',
      'Tofu firme': 'Firm tofu',
      'Tempeh': 'Tempeh',
      'Seitán': 'Seitan',
      'Queso panela': 'Panela cheese',
      'Ricotta': 'Ricotta',
      'Hamburguesa de lentejas': 'Lentil burger',
      'Claras de huevo': 'Egg whites',

      // ─────────────────────────────────────────────────────────────
      // Carbohidratos
      // ─────────────────────────────────────────────────────────────
      'Papa': 'Potato',
      'Arroz blanco': 'White rice',
      'Camote': 'Sweet potato',
      'Fideo': 'Noodles',
      'Frijoles': 'Beans',
      'Quinua': 'Quinoa',
      'Quinoa': 'Quinoa',
      'Avena': 'Oats',
      'Avena orgánica': 'Organic oats',
      'Pan integral': 'Whole wheat bread',
      'Pan integral artesanal': 'Artisan whole wheat bread',
      'Tortilla de maíz': 'Corn tortilla',
      'Tortillas de maíz': 'Corn tortillas',
      'Galletas de arroz': 'Rice crackers',
      'Crema de arroz': 'Cream of rice',
      'Cereal de maíz': 'Corn cereal',
      'Pasta integral': 'Whole wheat pasta',

      // ─────────────────────────────────────────────────────────────
      // Grasas
      // ─────────────────────────────────────────────────────────────
      'Aceite de oliva': 'Olive oil',
      'Aceite de oliva extra virgen': 'Extra virgin olive oil',
      'Aceite de oliva / extra virgen': 'Olive oil / Extra virgin',
      'Aceite de palta': 'Avocado oil',
      'Aceite vegetal': 'Vegetable oil',
      'Maní': 'Peanuts',
      'Mantequilla de maní': 'Peanut butter',
      'Mantequilla de maní casera': 'Homemade peanut butter',
      'Almendras': 'Almonds',
      'Nueces': 'Walnuts',
      'Pistachos': 'Pistachios',
      'Pecanas': 'Pecans',
      'Aguacate': 'Avocado',
      'Palta': 'Avocado',
      'Aguacate hass': 'Hass avocado',
      'Hass': 'Hass avocado',
      'Semillas de chía orgánicas': 'Organic chia seeds',
      'Linaza orgánica': 'Organic flaxseed',
      'Semillas de ajonjolí': 'Sesame seeds',
      'Aceitunas': 'Olives',
      'Miel': 'Honey',
      'Chocolate negro 70%': '70% Dark chocolate',
      'Mantequilla': 'Butter',
      'Manteca de cerdo': 'Lard',

      // ─────────────────────────────────────────────────────────────
      // Frutas
      // ─────────────────────────────────────────────────────────────
      'Plátano': 'Banana',
      'Manzana': 'Apple',
      'Naranja': 'Orange',
      'Berries (mix orgánico)': 'Berries (organic mix)',
      'Mango': 'Mango',
      'Papaya': 'Papaya',
      'Sandia': 'Watermelon',
      'Sandía': 'Watermelon',
      'Melón': 'Melon',
      'Fresas': 'Strawberries',
      'Arándanos': 'Blueberries',
      'Moras': 'Blackberries',
      'Pera': 'Pear',

      // ─────────────────────────────────────────────────────────────
      // Vegetales
      // ─────────────────────────────────────────────────────────────
      'Ensalada mixta': 'Mixed salad',
      'Ensalada completa mixta': 'Complete mixed salad',
      'Brócoli': 'Broccoli',
      'Zanahoria': 'Carrot',
      'Ejotes': 'Green beans',
      'Espinaca': 'Spinach',
      'Espinacas salteadas': 'Sautéed spinach',
      'Lechuga': 'Lettuce',
      'Pimiento': 'Bell pepper',
      'Calabacín': 'Zucchini',
      'Tomate': 'Tomato',
      'Pepino': 'Cucumber',
      'Coliflor': 'Cauliflower',
      'Champiñones': 'Mushrooms',
      'Bowl de vegetales al vapor': 'Steamed vegetables bowl',
      'Ensalada mediterránea': 'Mediterranean salad',
      'Vegetales salteados': 'Sautéed vegetables',
      'Ensalada verde mixta grande': 'Large mixed green salad',
      'Ensalada de vegetales crucíferos': 'Cruciferous vegetables salad',
      'Mix de vegetales bajos en carbos': 'Low-carb vegetables mix',

      // ─────────────────────────────────────────────────────────────
      // Otros
      // ─────────────────────────────────────────────────────────────
      'Tortillas integrales': 'Whole wheat tortillas',
    };

    // Buscamos en el mapa
    return esToEn[backendName.trim()] ?? backendName.trim();
  }

  String translatePortion(String portion, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    // En español: devolvemos exactamente lo que llega del backend
    if (locale == 'es') {
      return portion.trim();
    }

    // En inglés: traducimos TODAS las unidades y frases comunes
    String translated = portion.trim();

    // Reemplazos específicos para inglés
    translated = translated
        // Pesos
        .replaceAll('peso en crudo', 'raw weight')
        .replaceAll('(peso en crudo)', '(raw weight)')
        .replaceAll('peso cocido', 'cooked weight')
        .replaceAll('(peso cocido)', '(cooked weight)')
        .replaceAll('escurrido', 'drained')
        .replaceAll('peso seco', 'dry weight')
        .replaceAll('(peso seco)', '(dry weight)')

        // Unidades comunes
        .replaceAll('unidades', 'units')
        .replaceAll('unidads', 'units')
        .replaceAll('unidad', 'unit')
        .replaceAll('uds', 'units')
        .replaceAll('unid.', 'units')
        .replaceAll('unid', 'units')
        .replaceAll('cucharadas', 'tablespoons')
        .replaceAll('cucharada', 'tablespoon')
        .replaceAll('tazas grandes', 'large cups')
        .replaceAll('tazas', 'cups')
        .replaceAll('taza', 'cup')
        .replaceAll('tazas grandes', 'large cups')
        .replaceAll('tazas', 'cups')

        // Otras frases frecuentes
        .replaceAll('g', 'g') // ya está bien, pero lo dejamos
        .replaceAll('g (', 'g (') // para no romper paréntesis
        .replaceAll('g)', 'g)');

    // Capitalizamos la primera letra de cada palabra para que se vea más pro (opcional)
    translated = translated.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return translated;
  }

// 5. Formato de instrucciones de recetas (si las tienes en el PDF)
  String formatRecipeInstructions(
      String rawInstructions, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale != 'es') {
      return rawInstructions; // En inglés dejamos las instrucciones originales por ahora
    }

    // Traducciones comunes de pasos (puedes expandir)
    String formatted = rawInstructions
        .replaceAll('Step 1:', 'Paso 1:')
        .replaceAll('Step 2:', 'Paso 2:')
        .replaceAll('Step 3:', 'Paso 3:');

    return formatted;
  }

  Future<void> _generateAndDownloadPDF() async {
    final l10n = AppLocalizations.of(context)!;
    if (_mealPlanData == null || _userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noDataForPDF)),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent)),
    );

    try {
      final pdf = pw.Document();
      final plan = _mealPlanData!.nutritionPlan;
      final profile = _userProfile!;
      final translatedMeals = _getTranslatedMealsForPDF(plan, l10n);

      // Cargar imagen del logo
      final ByteData imageData =
          await rootBundle.load('assets/images/fondoAppFrutia.webp');
      final Uint8List imageBytes = imageData.buffer.asUint8List();

      // Cargar fuentes
      final font =
          pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
      final boldFont =
          pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
      final pw.ThemeData theme =
          pw.ThemeData.withFont(base: font, bold: boldFont);

      // ✅ PÁGINA 1: INSTRUCCIONES DE USO (NUEVA)
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildPdfHeader(
              l10n, profile['name'] ?? l10n.userDefault, imageBytes),
          build: (pw.Context context) => [
            _buildWelcomeSection(l10n, profile['name'] ?? l10n.userDefault),
            pw.SizedBox(height: 20),
            _buildImportantWarningSection(l10n),
            pw.SizedBox(height: 20),
            _buildHowToUseSection(l10n),
            pw.SizedBox(height: 20),
            _buildFrutiaChatSection(l10n),
          ],
        ),
      );

      // PÁGINA 2: Plan de comidas
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildPdfHeader(
              l10n, profile['name'] ?? l10n.userDefault, imageBytes),
          build: (pw.Context context) => [
            _buildProfileInfo(l10n, profile['profile']),
            pw.SizedBox(height: 20),
            _buildMacrosInfo(l10n, plan.targetMacros),
            pw.SizedBox(height: 20),
            // Mensaje personalizado si existe
            if (plan.recommendation.isNotEmpty) ...[
              _buildPersonalizedMessage(l10n, plan.recommendation),
              pw.SizedBox(height: 20),
            ],
            // Instrucción importante
            _buildImportantInstruction(l10n),
            pw.SizedBox(height: 15),
            // Todas las comidas
            ...translatedMeals.entries.map((mealEntry) =>
                _buildMealPdfSection(l10n, mealEntry.key, mealEntry.value)),
          ],
        ),
      );

      // PÁGINA 3: RECOMENDACIONES
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => _buildPdfHeader(
              l10n, profile['name'] ?? l10n.userDefault, imageBytes),
          build: (pw.Context context) => [
            _buildUnifiedRecommendationsSection(l10n),
            pw.SizedBox(height: 20),
            _buildImportantTipsBox(l10n),
          ],
        ),
      );

      // Guardar y abrir el PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/Plan_Frutia_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) Navigator.of(context).pop();

      OpenFile.open(file.path);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.pdfGenError}${e.toString()}')),
      );
    }
  }

// ✅ PÁGINA 1: INSTRUCCIONES DE USO (NUEVA) - SECCIÓN ADVERTENCIA
  pw.Widget _buildImportantWarningSection(AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título principal
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.red50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.red300, width: 2),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red200,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Text(
                  '!', // ← CAMBIAR: Usar signo de exclamación
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red900,
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  l10n.pdfHowToUse,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red900,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // INSTRUCCIÓN 1
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.orange300, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange200,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Text(
                      '1',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange900,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      l10n.pdfSelectOneOptionTitle,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange900,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                l10n.pdfMealGroupsTitle,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(l10n.pdfWelcomeProtein),
                    _buildBulletPoint(l10n.pdfWelcomeCarbs),
                    _buildBulletPoint(l10n.pdfWelcomeFats),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        l10n.pdfImportantSelection,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red900,
                          height: 1.4,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ AGREGAR ESTE MÉTODO COMPLETO (PDF)
  pw.Widget _buildHowToUseSection(AppLocalizations l10n) {
    return pw.Column(
      children: [
        // INSTRUCCIÓN 1
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.blue300, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue200,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Text(
                      '1',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      l10n.pdfHowToUsePlanTitle,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                l10n.pdfYourObjectiveIs,
                style: pw.TextStyle(
                  fontSize: 13,
                  color: PdfColors.grey800,
                  height: 1.5,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(l10n.pdfHowToUseStep1),
                    _buildBulletPoint(l10n.pdfHowToUseStep2),
                    _buildBulletPoint(l10n.pdfHowToUseStep3),
                    _buildBulletPoint(l10n.pdfHowToUseStep4),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        l10n.pdfHowToUseTip,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.blue900,
                          height: 1.4,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 15),

        // INSTRUCCIÓN 3 ("Aprende a manipular")
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.green300, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green200,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Text(
                      '3', // Assuming this is actually step 2 or 3? The code said 3.
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Text(
                      l10n.pdfLearnToManipulateTitle,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green900,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                l10n.pdfLearnToManipulateDesc,
                style: pw.TextStyle(
                  fontSize: 13,
                  color: PdfColors.grey800,
                  height: 1.5,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(l10n.pdfLearnToManipulatePoint1),
                    _buildBulletPoint(l10n.pdfLearnToManipulatePoint2),
                    _buildBulletPoint(l10n.pdfLearnToManipulatePoint3),
                    _buildBulletPoint(l10n.pdfLearnToManipulatePoint4),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        l10n.pdfLearnToManipulateObjective,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.green900,
                          height: 1.4,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// ✅ AGREGAR ESTE MÉTODO COMPLETO
  pw.Widget _buildFrutiaChatSection(AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [PdfColors.purple50, PdfColors.purple100],
        ),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.purple300, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.purple200,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Text(
                  'AI', // ← CAMBIAR: Usar texto "AI"
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple900,
                  ),
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: pw.Text(
                  l10n.pdfFrutiaChatTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple900,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            l10n.pdfFrutiaChatDesc,
            style: pw.TextStyle(
              fontSize: 13,
              color: PdfColors.grey800,
              height: 1.5,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            l10n.pdfAskAbout,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(l10n.pdfAsk1),
                _buildBulletPoint(l10n.pdfAsk2),
                _buildBulletPoint(l10n.pdfAsk3),
                _buildBulletPoint(l10n.pdfAsk4),
                _buildBulletPoint(l10n.pdfAsk5),
                _buildBulletPoint(l10n.pdfAsk6),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.purple200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  '24/7', // ← CAMBIAR: Usar texto
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple900,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Text(
                    l10n.pdfAvailable247,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// ✅ AGREGAR ESTE MÉTODO HELPER
  pw.Widget _buildBulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '• ',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ AGREGAR ESTE MÉTODO COMPLETO
  pw.Widget _buildWelcomeSection(AppLocalizations l10n, String userName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [PdfColors.blue50, PdfColors.blue100],
        ),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.blue300, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  l10n.pdfWelcome(userName), // TRANSLATED
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            l10n.pdfWelcomeDesc,
            style: pw.TextStyle(
              fontSize: 13,
              color: PdfColors.grey800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

// Método para el mensaje personalizado
  pw.Widget _buildPersonalizedMessage(
      AppLocalizations l10n, String recommendation) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        border: pw.Border.all(color: PdfColors.blueGrey100, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(l10n.pdfPersonalizedMsgTitle, // TRANSLATED
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(
            recommendation == 'plan_ready_goal_reach'
                ? l10n.planReadyGoalReach
                : recommendation,
            style: pw.TextStyle(color: PdfColors.grey800, lineSpacing: 2),
          ),
        ],
      ),
    );
  }

// ✅ REEMPLAZAR tu método _buildImportantInstruction() actual con este:
  pw.Widget _buildImportantInstruction(AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        border: pw.Border.all(color: PdfColors.red300, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red200,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Text(
                  l10n.pdfGoldRule, // '!'
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red900,
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  l10n.pdfGoldRuleTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red900,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.red200),
            ),
            child: pw.Text(
              l10n.pdfGoldRuleDesc,
              style: pw.TextStyle(
                color: PdfColors.red900,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                height: 1.5,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            l10n.pdfGoldRuleWarning,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.red700,
              fontStyle: pw.FontStyle.italic,
              height: 1.3,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _translateCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Proteins':
        return l10n.proteins;
      case 'Carbs':
        return l10n.carbs;
      case 'Fats':
        return l10n.fats;
      case 'Vegetables':
        return l10n.vegetables;
      default:
        return category;
    }
  }

// Método mejorado para cada comida con resumen de macros
  pw.Widget _buildMealPdfSection(
      AppLocalizations l10n, String mealTitle, Meal meal) {
    // Calcular macros promedio de la comida
    int totalProtein = 0, totalCarbs = 0, totalFats = 0, totalCalories = 0;
    int optionCount = 0;

    for (var category in meal.components) {
      if (category.options.isNotEmpty) {
        var firstOption = category.options.first;
        totalProtein += firstOption.protein;
        totalCarbs += firstOption.carbs;
        totalFats += firstOption.fats;
        totalCalories += firstOption.calories;
        optionCount++;
      }
    }

    final List<List<String>> tableData = [
      <String>[
        l10n.pdfMealTableComponent,
        l10n.pdfMealTableOption,
        l10n.pdfMealTablePortion
      ],
    ];

    for (var category in meal.components) {
      for (var option in category.options) {
        tableData.add([
          category.title, // ← Ya traducido en translatedMeals
          option.name, // ← Ya traducido
          option.portion, // ← Ya traducido
        ]);
      }
    }

    // ✅ ENVOLVER TODO EN pw.Column con keepTogether
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ✅ NUEVO: keepTogether mantiene el contenido junto
        pw.Wrap(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Título de la comida
                pw.Header(level: 2, text: mealTitle),

                // Resumen de macros
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Text('${l10n.pdfMealCalories}: ${totalCalories} kcal',
                          style: pw.TextStyle(
                              fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                          'P: ${totalProtein}g', // Stick to simple P/C/G or use keys if added. I'll stick to P/C/G/Cal as universal.
                          style: pw.TextStyle(fontSize: 11)),
                      pw.Text('C: ${totalCarbs}g',
                          style: pw.TextStyle(fontSize: 11)),
                      pw.Text('G: ${totalFats}g',
                          style: pw.TextStyle(fontSize: 11)),
                    ],
                  ),
                ),

                // Tabla de opciones
                pw.Table.fromTextArray(
                  border:
                      pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.all(5),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey200),
                  data: tableData,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                  },
                ),

                // Recetas sugeridas si existen
                if (meal.suggestedRecipes.isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Text(l10n.pdfSuggestedRecipes,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.SizedBox(height: 5),
                  ...meal.suggestedRecipes.take(2).map((recipe) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                        child: pw.Text(
                            '• ${recipe.title} (${recipe.readyInMinutes} min)',
                            style: pw.TextStyle(
                                fontSize: 12, color: PdfColors.grey700)),
                      )),
                ],
              ],
            ),
          ],
        ),

        // Espaciado entre secciones
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildPdfHeader(
      AppLocalizations l10n, String userName, Uint8List imageBytes) {
    return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(bottom: 20.0),
        child: pw.Column(children: [
          pw.Text('Frutia',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 24,
                  color: PdfColors.red)),
          pw.Image(pw.MemoryImage(imageBytes), height: 60),
          pw.Text(l10n.pdfPersonalizedPlanTitle(userName),
              style: pw.TextStyle(fontSize: 18)),
          pw.Divider(color: PdfColors.grey400),
        ]));
  }

  pw.Widget _buildProfileInfo(
      AppLocalizations l10n, Map<String, dynamic> profile) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('${l10n.pdfProfileWeight}: ${profile['weight'] ?? 'N/A'} kg'),
          pw.Text('${l10n.pdfProfileHeight}: ${profile['height'] ?? 'N/A'} cm'),
          pw.Text('${l10n.pdfProfileAge}: ${profile['age'] ?? 'N/A'}'),
        ]);
  }

  pw.Widget _buildMacrosInfo(AppLocalizations l10n, TargetMacros macros) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 1, text: l10n.pdfMacrosTargetTitle),
          pw.Text('${l10n.pdfMealCalories}: ${macros.calories} kcal'),
          pw.Text(
              '${l10n.proteinLabelShort}: ${macros.protein}g / ${l10n.fatsLabelShort}: ${macros.fats}g / ${l10n.carbsLabelShort}: ${macros.carbs}g'),
          // reusing: '${l10n.pdfFoodGroups.split('\n')[0].split(':')[0]}: ...' is too complex.
          // I'll stick to hardcoded labels here for simplicity or just accept partial localization if I didn't add keys for simple "Proteins", "Fats" labels alone?
          // I added pdfMealTableComponent etc.
          // I will verify if I have simple keys for Proteins/Carbs/Fats.
          // I have 'pdfFoodGroups' => "Proteínas: Elige UNA..."
          // I will attempt to hardcode simple translations or just leave them.
          // 'Proteins: ${macros.protein}g / Fats: ${macros.fats}g / Carbs: ${macros.carbs}g' would be better.
        ]);
  }

  pw.Widget _buildRecommendationsSection(String title, List<String> items) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 1, text: title),
          ...items.map((item) => pw.Bullet(text: item)),
          pw.SizedBox(height: 20),
        ]);
  }

// ✅ AGREGAR ESTE MÉTODO COMPLETO
  pw.Widget _buildUnifiedRecommendationsSection(AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Título principal con línea
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400, width: 2),
            ),
          ),
          child: pw.Text(
            l10n.pdfRecsTitle,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 18,
              color: PdfColors.blue900,
            ),
          ),
        ),
        pw.SizedBox(height: 15),

        // 📏 SECCIÓN 1: Pesaje de Alimentos
        pw.Text(
          l10n.pdfRecsWeighingTitle,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Bullet(
          text: l10n.pdfRecsWeighingBody1,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsWeighingBody2,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsWeighingBody3,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 12),

        // 💧 SECCIÓN 2: Hidratación y Medición
        pw.Text(
          l10n.pdfRecsHydrationTitle,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Bullet(
          text: l10n.pdfRecsHydrationBody1,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsHydrationBody2,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsHydrationBody3,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsHydrationBody4,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 12),

        // 📅 SECCIÓN 3: Organización
        pw.Text(
          l10n.pdfRecsOrgTitle,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Bullet(
          text: l10n.pdfRecsOrgBody1,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsOrgBody2,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsOrgBody3,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.Bullet(
          text: l10n.pdfRecsOrgBody4,
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 12),

        // 🍳 SECCIÓN 4: Cocina
        pw.Text(
          l10n.pdfRecsKitchenTitle,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Bullet(
          text: l10n.pdfRecsKitchenBody,
          style: pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // ✅ AGREGAR ESTE MÉTODO COMPLETO
  pw.Widget _buildImportantTipsBox(AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue300, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue200,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Text(
                  '*',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                l10n.pdfRemember,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            l10n.pdfRememberBody1,
            style: pw.TextStyle(
                fontSize: 11, color: PdfColors.grey800, height: 1.3),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            l10n.pdfRememberBody2,
            style: pw.TextStyle(
                fontSize: 11, color: PdfColors.grey800, height: 1.3),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            l10n.pdfRememberBody3,
            style: pw.TextStyle(
                fontSize: 11, color: PdfColors.grey800, height: 1.3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          l10n.myPlanForToday,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: _buildBody(),
    );
  }

  List<RecommendationItem> _generateDynamicRecommendations(
      AppLocalizations l10n,
      int proteinExcess,
      int carbsExcess,
      int fatsExcess) {
    List<RecommendationItem> recommendations = [];

    if (proteinExcess > 5) {
      recommendations.add(RecommendationItem(
        text: l10n.protein,
        color: Colors.blue,
        mealIcon: Icons.egg_alt_outlined,
        macroIcon: Icons.egg_alt_outlined,
      ));
    }

    _dailySelections.forEach((mealName, selections) {
      selections.forEach((categoryName, option) {
        // Obtener color e icono de la comida
        Color mealColor = _getMealColor(mealName);
        IconData mealIcon = _getMealIcon(mealName);

        // Consejos específicos para exceso de proteínas
        if (proteinExcess > 10 && option.protein > 30) {
          if (option.name.toLowerCase().contains('salmón')) {
            recommendations.add(RecommendationItem(
              text: l10n.recChangeToChicken(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.egg_alt_outlined,
            ));
          } else if (option.name.toLowerCase().contains('lomo')) {
            recommendations.add(RecommendationItem(
              text: l10n.recChangeToBreast(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.egg_alt_outlined,
            ));
          } else if (option.protein > 50) {
            recommendations.add(RecommendationItem(
              text: l10n.recReducePortion(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.egg_alt_outlined,
            ));
          }
        }

        // Consejos específicos para exceso de grasas
        if (fatsExcess > 10 && option.fats > 15) {
          if (option.name.toLowerCase().contains('salmón')) {
            recommendations.add(RecommendationItem(
              text: l10n.recSalmonFat(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.water_drop_outlined,
            ));
          } else if (option.name.toLowerCase().contains('aceite')) {
            recommendations.add(RecommendationItem(
              text: l10n.recReduceOil(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.water_drop_outlined,
            ));
          } else if (option.name.toLowerCase().contains('almendras')) {
            recommendations.add(RecommendationItem(
              text: l10n.recReduceAlmonds(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.water_drop_outlined,
            ));
          } else if (option.name.toLowerCase().contains('aguacate')) {
            recommendations.add(RecommendationItem(
              text: l10n.recAvocado(mealName),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.water_drop_outlined,
            ));
          }
        }

        // Consejos específicos para exceso de carbohidratos
        if (carbsExcess > 15 && option.carbs > 10) {
          if (option.name.toLowerCase().contains('quinua') ||
              option.name.toLowerCase().contains('arroz') ||
              option.name.toLowerCase().contains('avena')) {
            recommendations.add(RecommendationItem(
              text: l10n.recReduceCarbs(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.grain_outlined,
            ));
          } else if (option.name.toLowerCase().contains('mango') ||
              option.name.toLowerCase().contains('frutos')) {
            recommendations.add(RecommendationItem(
              text: l10n.recReduceFruits(mealName, option.name),
              color: mealColor,
              mealIcon: mealIcon,
              macroIcon: Icons.grain_outlined,
            ));
          }
        }
      });
    });

    if (carbsExcess > 10) {
      recommendations.add(RecommendationItem(
        text: l10n.carbs,
        color: Colors.orange,
        mealIcon: Icons.grain_outlined,
        macroIcon: Icons.grain_outlined,
      ));
    }

    if (fatsExcess > 10) {
      recommendations.add(RecommendationItem(
        text: l10n.fats,
        color: Colors.purple,
        mealIcon: Icons.water_drop_outlined,
        macroIcon: Icons.water_drop_outlined,
      ));
    }

    return recommendations;
  }

// Método para obtener color según la comida
  Color _getMealColor(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'desayuno':
        return Colors.orange;
      case 'almuerzo':
        return Colors.green;
      case 'cena':
        return Colors.purple;
      case 'snack de frutas':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

// Método para obtener icono según la comida
  IconData _getMealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'desayuno':
        return Icons.free_breakfast_outlined;
      case 'almuerzo':
        return Icons.restaurant_outlined;
      case 'cena':
        return Icons.dinner_dining_outlined;
      case 'snack de frutas':
        return Icons.apple_outlined;
      default:
        return Icons.lunch_dining_outlined;
    }
  }

  Color _getRecommendationColor(String recommendation) {
    if (recommendation.toLowerCase().contains('proteína') ||
        recommendation.toLowerCase().contains('pollo') ||
        recommendation.toLowerCase().contains('salmón')) {
      return Colors.blue;
    } else if (recommendation.toLowerCase().contains('grasa') ||
        recommendation.toLowerCase().contains('aceite') ||
        recommendation.toLowerCase().contains('aguacate')) {
      return Colors.purple;
    } else if (recommendation.toLowerCase().contains('carbohidrato') ||
        recommendation.toLowerCase().contains('quinua') ||
        recommendation.toLowerCase().contains('arroz')) {
      return Colors.green;
    }
    return Colors.orange;
  }

  IconData _getRecommendationIcon(String recommendation) {
    if (recommendation.toLowerCase().contains('proteína') ||
        recommendation.toLowerCase().contains('pollo') ||
        recommendation.toLowerCase().contains('salmón')) {
      return Icons.egg_alt_outlined;
    } else if (recommendation.toLowerCase().contains('grasa') ||
        recommendation.toLowerCase().contains('aceite') ||
        recommendation.toLowerCase().contains('aguacate')) {
      return Icons.water_drop_outlined;
    } else if (recommendation.toLowerCase().contains('carbohidrato') ||
        recommendation.toLowerCase().contains('quinua') ||
        recommendation.toLowerCase().contains('arroz')) {
      return Icons.grain_outlined;
    }
    return Icons.info_outlined;
  }

  void _contactFrutiaSupport() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.contactSupport)),
    );
  }

  // En ProfessionalMiPlanDiarioScreen - Agregar método helper
  Widget _buildMacroExcessWarning() {
    final l10n = AppLocalizations.of(context)!;
    final plan = _mealPlanData!.nutritionPlan;

    final calExcess = _totalCalories - plan.targetMacros.calories;
    final proteinExcess = _totalProtein - plan.targetMacros.protein;
    final carbsExcess = _totalCarbs - plan.targetMacros.carbs;
    final fatsExcess = _totalFats - plan.targetMacros.fats;

    if (calExcess <= 0 &&
        proteinExcess <= 10 &&
        carbsExcess <= 15 &&
        fatsExcess <= 10) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _showExcessAdviceDialog(
          context, proteinExcess, carbsExcess, fatsExcess),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade400),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.macroExcessWarning,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ← AGREGAR CALORÍAS PRIMERO
                  if (calExcess > 0)
                    Text(
                      '• ${l10n.calories}: +$calExcess kcal',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13),
                    ),

                  if (proteinExcess > 10)
                    Text(
                      '• ${l10n.protein}: +$proteinExcess g',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13),
                    ),
                  if (carbsExcess > 15)
                    Text(
                      '• ${l10n.carbohydrates}: +$carbsExcess g',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13),
                    ),
                  if (fatsExcess > 10)
                    Text(
                      '• ${l10n.fats}: +$fatsExcess g',
                      style: TextStyle(
                          color: Colors.orange.shade700, fontSize: 13),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  void _showExcessAdviceDialog(BuildContext context, int proteinExcess,
      int carbsExcess, int fatsExcess) {
    final l10n = AppLocalizations.of(context)!;
    List<RecommendationItem> recommendations = _generateDynamicRecommendations(
        l10n, proteinExcess, carbsExcess, fatsExcess);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.adviceTitle,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.5, // Altura máxima
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.blue.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology_outlined,
                        color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.adviceSubtitle,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Lista scrolleable de recomendaciones
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...recommendations.map((recItem) => Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: recItem.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: recItem.color.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: recItem.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(recItem.mealIcon,
                                          color: recItem.color, size: 14),
                                      SizedBox(width: 4),
                                      Icon(recItem.macroIcon,
                                          color: recItem.color, size: 14),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    recItem.text,
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: recItem.color,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Tip final
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FrutiaColors.accent.withOpacity(0.1),
                      FrutiaColors.accent2.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: FrutiaColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_outlined,
                        color: FrutiaColors.accent, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.adviceTip,
                        style: GoogleFonts.lato(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          color: FrutiaColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: Text(
              l10n.understoodButton,
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoHeader() {
    final plan = _mealPlanData!.nutritionPlan;
    final l10n = AppLocalizations.of(context)!;
    if (plan.anthropometricSummary == null) return const SizedBox.shrink();

    final anthro = plan.anthropometricSummary!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FrutiaColors.accent.withOpacity(0.1),
            FrutiaColors.accent2.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FrutiaColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FrutiaColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
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
                      l10n.helloUser(anthro.clientName),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    Text(
                      "${anthro.age} ${l10n.years} • BMI: ${anthro.bmi.toStringAsFixed(1)} • ${anthro.weightStatus}",
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(l10n.errorLoadingData(_errorMessage!),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    if (_mealPlanData == null) {
      return Center(child: Text(l10n.noMealPlan));
    }

    final plan = _mealPlanData!.nutritionPlan;

    String translateMeal(String key, AppLocalizations l10n) {
      final locale = Localizations.localeOf(context).languageCode;
      final normalized = key.toLowerCase().trim();

      if (locale == 'es') {
        switch (normalized) {
          case 'desayuno':
            return l10n.breakfast ?? 'Desayuno';
          case 'almuerzo':
            return l10n.lunch ?? 'Almuerzo';
          case 'cena':
            return l10n.dinner ?? 'Cena';
          case 'snack am':
          case 'snack_am':
            return l10n.snackAM ?? 'Snack AM';
          case 'snack pm':
          case 'snack_pm':
            return l10n.snackPM ?? 'Snack PM';
          default:
            return key;
        }
      } else {
        switch (normalized) {
          case 'desayuno':
            return 'Breakfast';
          case 'almuerzo':
            return 'Lunch';
          case 'cena':
            return 'Dinner';
          case 'snack am':
          case 'snack_am':
            return 'Morning Snack';
          case 'snack pm':
          case 'snack_pm':
            return 'Afternoon Snack';
          default:
            return key[0].toUpperCase() + key.substring(1).toLowerCase();
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricsDashboard(
            calories: _totalCalories,
            targetCalories: plan.targetMacros.calories,
            protein: _totalProtein,
            targetProtein: plan.targetMacros.protein,
            carbs: _totalCarbs,
            targetCarbs: plan.targetMacros.carbs,
            fats: _totalFats,
            targetFats: plan.targetMacros.fats,
            onDownloadPDF: _generateAndDownloadPDF,
            isPremium: _isUserPremium,
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 8),

          // AGREGAR AQUÍ EL WARNING DE EXCESO
          _buildMacroExcessWarning(),

          const SizedBox(height: 16),

          ...plan.meals.entries.map((entry) {
            final translatedTitle = translateMeal(entry.key, l10n);
            final mealTitle = entry.key;
            final meal = entry.value;
            final icon = _getIconForMeal(mealTitle);
            final delay =
                (plan.meals.keys.toList().indexOf(mealTitle) * 200).ms;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: // En _buildBody(), donde creas cada MealCard
                  _MealCard(
                title: translatedTitle,

                originalTitle: entry.key, // No necesario si ya traducido
                icon: icon,
                categories: meal.components,
                suggestedRecipes: meal.suggestedRecipes,
                selections: _dailySelections[mealTitle]!,
                validationWarnings:
                    _validationWarnings[mealTitle], // AGREGAR ESTA LÍNEA
                onOptionSelected: (category, option) =>
                    _updateSelection(mealTitle, category, option),
                isRegistering: _registeringMeals.contains(mealTitle),
                isCompleted: _completedMeals.contains(mealTitle),
                onDeselectionRequested: _removeSelection, // AGREGAR

                onRegister: () {
                  final selectionsForMeal =
                      _dailySelections[mealTitle]!.values.toList();
                  _registerMeal(
                      mealTitle, selectionsForMeal); // ⭐ Usa título original
                },
              ).animate().fadeIn(duration: 500.ms, delay: delay),
            );
          }).toList(),
        ],
      ),
    );
  }

  String getLocalizedMealTitle(String backendKey, AppLocalizations l10n) {
    if (backendKey.isEmpty) return backendKey;

    // Capitaliza la primera letra por estética
    return backendKey[0].toUpperCase() + backendKey.substring(1).toLowerCase();
  }

  IconData _getIconForMeal(String mealTitle) {
    switch (mealTitle.toLowerCase()) {
      case 'breakfast':
      case 'desayuno':
        return Icons.free_breakfast_outlined;
      case 'lunch':
      case 'almuerzo':
        return Icons.restaurant_outlined;
      case 'dinner':
      case 'cena':
        return Icons.dinner_dining_outlined;
      case 'snack_am':
        return Icons.wb_sunny_outlined;
      case 'snack_pm':
        return Icons.wb_twilight_outlined;
      default:
        return Icons.lunch_dining_outlined;
    }
  }
}

class _MetricsDashboard extends StatelessWidget {
  final int calories,
      targetCalories,
      protein,
      targetProtein,
      carbs,
      targetCarbs,
      fats,
      targetFats;
  final VoidCallback onDownloadPDF;
  final bool isPremium;

  const _MetricsDashboard({
    required this.calories,
    required this.targetCalories,
    required this.protein,
    required this.targetProtein,
    required this.carbs,
    required this.targetCarbs,
    required this.fats,
    required this.targetFats,
    required this.onDownloadPDF,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: FrutiaColors.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(
              l10n.yourDaySummary,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText),
            ),
            SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 30.0,
              runSpacing: 20.0,
              children: [
                _MacroStatCard(
                  label: l10n.protein,
                  value: protein,
                  target: targetProtein,
                  color: Colors.blue,
                  icon: Icons.egg_alt_outlined,
                ),
                _MacroStatCard(
                  label: l10n.carbs,
                  value: carbs,
                  target: targetCarbs,
                  color: Colors.orange,
                  icon: Icons.local_fire_department_outlined,
                ),
                _MacroStatCard(
                  label: l10n.fats,
                  value: fats,
                  target: targetFats,
                  color: Colors.purple,
                  icon: Icons.water_drop_outlined,
                ),
              ],
            ),
            const SizedBox(height: 55),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()));
              },
              icon: const Icon(Icons.history, color: FrutiaColors.accent),
              label: Text(
                l10n.viewHistory,
                style: GoogleFonts.poppins(
                    color: FrutiaColors.accent, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FrutiaColors.accent,
                side: const BorderSide(color: FrutiaColors.accent, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (isPremium) {
                  onDownloadPDF();
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => const PremiumFeatureDialog());
                }
              },
              icon: Icon(isPremium ? Icons.download : Icons.lock,
                  color: Colors.white),
              label: Text(
                l10n.downloadPDF,
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? FrutiaColors.accent : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroStatCard extends StatelessWidget {
  final String label;
  final int value, target;
  final Color color;
  final IconData icon;

  const _MacroStatCard({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    double progress = target > 0 ? value / target : 0;
    return Column(
      children: [
        CircleAvatar(
            radius: 40,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 32)),
        const SizedBox(height: 8),
        Text(
          '${value}g / ${target}g',
          style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText),
        ),
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 12, color: FrutiaColors.secondaryText)),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: FrutiaColors.secondaryText.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}

String getLocalizedCategoryTitle(
    String backendCategory, AppLocalizations l10n) {
  // El backend envía "Proteínas", "Carbohidratos", etc.
  // Usamos las claves de l10n para traducir según idioma
  switch (backendCategory.trim()) {
    case 'Proteínas':
      return l10n.proteins;
    case 'Carbohidratos':
      return l10n.carbohydrates; // o l10n.carbs si prefieres abreviado
    case 'Grasas':
      return l10n.fats;
    case 'Vegetales':
      return l10n.vegetables;
    default:
      return backendCategory; // por si llega algo nuevo
  }
}

class _MealCategorySection extends StatelessWidget {
  final MealCategory category;
  final MealOption? groupValue;
  final ValueChanged<MealOption> onChanged;
  final VoidCallback? onDeselect;

  const _MealCategorySection({
    required this.category,
    required this.groupValue,
    required this.onChanged,
    this.onDeselect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String translateMeal(String key, AppLocalizations l10n) {
      final locale = Localizations.localeOf(context).languageCode;

      // Normalizamos la clave (quitamos mayúsculas, espacios extra y posibles variaciones)
      final normalized = key.toLowerCase().trim();

      // Mapeo completo: clave del backend → traducción según idioma
      if (locale == 'es') {
        // En español devolvemos tal cual (o usamos l10n si prefieres)
        switch (normalized) {
          case 'desayuno':
            return l10n.breakfast ?? 'Desayuno';
          case 'almuerzo':
            return l10n.lunch ?? 'Almuerzo';
          case 'cena':
            return l10n.dinner ?? 'Cena';
          case 'snack am':
          case 'snack_am':
            return l10n.snackAM ?? 'Snack AM';
          case 'snack pm':
          case 'snack_pm':
            return l10n.snackPM ?? 'Snack PM';
          default:
            return key; // Capitalizamos como fallback
        }
      } else {
        // En inglés: traducimos explícitamente
        switch (normalized) {
          case 'desayuno':
            return 'Breakfast';
          case 'almuerzo':
            return 'Lunch';
          case 'cena':
            return 'Dinner';
          case 'snack am':
          case 'snack_am':
            return 'Morning Snack';
          case 'snack pm':
          case 'snack_pm':
            return 'Afternoon Snack';
          default:
            // Capitalizamos y traducimos lo mejor posible

            debugPrint(
                'Traduciendo comida: "$key" (locale: $locale) → "$translateMeal(key, l10n)"');
            return key[0].toUpperCase() + key.substring(1).toLowerCase();
        }
      }
    }

    String translateCategory(String backendCategory, AppLocalizations l10n) {
      final locale = Localizations.localeOf(context).languageCode;

      // En español: usamos exactamente lo que manda el backend
      if (locale == 'es') {
        return backendCategory.trim();
      }

      // En inglés: traducimos explícitamente
      switch (backendCategory.trim()) {
        case 'Proteínas':
          return l10n.proteins ?? 'Proteins';
        case 'Carbohidratos':
          return l10n.carbohydrates ?? 'Carbohydrates';
        case 'Grasas':
          return l10n.fats ?? 'Fats';
        case 'Vegetales':
          return l10n.vegetables ?? 'Vegetables';
        case 'Frutas':
          return l10n.fruits ?? 'Fruits';
        default:
          return backendCategory.trim(); // fallback
      }
    }

    final translatedTitle = translateCategory(category.title, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translatedTitle,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: FrutiaColors.primaryText),
          ),
          const SizedBox(height: 12),
          ...category.options.map((option) => _MealOptionTile(
                option: option,
                isSelected: groupValue == option,
                onTap: () => onChanged(option),
                onDeselect: onDeselect,
              )),
        ],
      ),
    );
  }
}

class _MealOptionTile extends StatelessWidget {
  final MealOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDeselect;
  final String? userBudget;

  const _MealOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
    this.onDeselect,
    this.userBudget,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String getLocalizedFoodName(String backendName, AppLocalizations l10n) {
      final locale = Localizations.localeOf(context).languageCode;

      // En español: devolvemos exactamente lo del backend
      if (locale == 'es') {
        return backendName.trim();
      }

      // En inglés: mapa explícito de español → inglés (más confiable que FoodTranslations si falla)
      const Map<String, String> esToEn = {
        // ─────────────────────────────────────────────────────────────
        // Proteínas
        // ─────────────────────────────────────────────────────────────
        'Huevo entero': 'Whole egg',
        'Huevos enteros': 'Whole eggs',
        'Claras + Huevo Entero': 'Egg whites + Whole egg',
        'Claras + Huevo entero': 'Egg whites + Whole egg',
        'Claras pasteurizadas': 'Pasteurized egg whites',
        'Pechuga de pollo': 'Chicken breast',
        'Pollo muslo': 'Chicken thigh',
        'Pollo muslo con piel': 'Chicken thigh with skin',
        'Carne molida': 'Ground beef',
        'Carne molida 80/20': 'Ground beef 80/20',
        'Carne de res magra': 'Lean beef',
        'Atún en lata': 'Canned tuna',
        'Atún fresco': 'Fresh tuna',
        'Salmón fresco': 'Fresh salmon',
        'Pescado blanco': 'White fish',
        'Pechuga de pavo': 'Turkey breast',
        'Yogurt griego': 'Greek yogurt',
        'Yogurt griego alto en proteínas': 'High-protein Greek yogurt',
        'Proteína whey': 'Whey protein',
        'Proteína en polvo': 'Protein powder',
        'Caseína': 'Casein',
        'Tofu firme': 'Firm tofu',
        'Tempeh': 'Tempeh',
        'Seitán': 'Seitan',
        'Queso panela': 'Panela cheese',
        'Ricotta': 'Ricotta',
        'Hamburguesa de lentejas': 'Lentil burger',
        'Claras de huevo': 'Egg whites',

        // ─────────────────────────────────────────────────────────────
        // Carbohidratos
        // ─────────────────────────────────────────────────────────────
        'Papa': 'Potato',
        'Arroz blanco': 'White rice',
        'Camote': 'Sweet potato',
        'Fideo': 'Noodles',
        'Frijoles': 'Beans',
        'Quinua': 'Quinoa',
        'Quinoa': 'Quinoa',
        'Avena': 'Oats',
        'Avena orgánica': 'Organic oats',
        'Pan integral': 'Whole wheat bread',
        'Pan integral artesanal': 'Artisan whole wheat bread',
        'Tortilla de maíz': 'Corn tortilla',
        'Tortillas de maíz': 'Corn tortillas',
        'Galletas de arroz': 'Rice crackers',
        'Crema de arroz': 'Cream of rice',
        'Cereal de maíz': 'Corn cereal',
        'Pasta integral': 'Whole wheat pasta',

        // ─────────────────────────────────────────────────────────────
        // Grasas
        // ─────────────────────────────────────────────────────────────
        'Aceite de oliva': 'Olive oil',
        'Aceite de oliva extra virgen': 'Extra virgin olive oil',
        'Aceite de oliva / extra virgen': 'Olive oil / Extra virgin',
        'Aceite de palta': 'Avocado oil',
        'Aceite vegetal': 'Vegetable oil',
        'Maní': 'Peanuts',
        'Mantequilla de maní': 'Peanut butter',
        'Mantequilla de maní casera': 'Homemade peanut butter',
        'Almendras': 'Almonds',
        'Nueces': 'Walnuts',
        'Pistachos': 'Pistachios',
        'Pecanas': 'Pecans',
        'Aguacate': 'Avocado',
        'Palta': 'Avocado',
        'Aguacate hass': 'Hass avocado',
        'Has': 'Hass avocado',
        'Semillas de chía orgánicas': 'Organic chia seeds',
        'Linaza orgánica': 'Organic flaxseed',
        'Semillas de ajonjolí': 'Sesame seeds',
        'Aceitunas': 'Olives',
        'Miel': 'Honey',
        'Chocolate negro 70%': '70% Dark chocolate',
        'Mantequilla': 'Butter',
        'Manteca de cerdo': 'Lard',

        // ─────────────────────────────────────────────────────────────
        // Frutas
        // ─────────────────────────────────────────────────────────────
        'Plátano': 'Banana',
        'Manzana': 'Apple',
        'Naranja': 'Orange',
        'Berries (mix orgánico)': 'Berries (organic mix)',
        'Mango': 'Mango',
        'Papaya': 'Papaya',
        'Sandia': 'Watermelon',
        'Sandía': 'Watermelon',
        'Melón': 'Melon',
        'Fresas': 'Strawberries',
        'Arándanos': 'Blueberries',
        'Moras': 'Blackberries',
        'Pera': 'Pear',

        // ─────────────────────────────────────────────────────────────
        // Vegetales
        // ─────────────────────────────────────────────────────────────
        'Ensalada mixta': 'Mixed salad',
        'Ensalada completa mixta': 'Complete mixed salad',
        'Brócoli': 'Broccoli',
        'Zanahoria': 'Carrot',
        'Ejotes': 'Green beans',
        'Espinaca': 'Spinach',
        'Espinacas salteadas': 'Sautéed spinach',
        'Lechuga': 'Lettuce',
        'Pimiento': 'Bell pepper',
        'Calabacín': 'Zucchini',
        'Tomate': 'Tomato',
        'Pepino': 'Cucumber',
        'Coliflor': 'Cauliflower',
        'Champiñones': 'Mushrooms',
        'Bowl de vegetales al vapor': 'Steamed vegetables bowl',
        'Ensalada mediterránea': 'Mediterranean salad',
        'Vegetales salteados': 'Sautéed vegetables',
        'Ensalada verde mixta grande': 'Large mixed green salad',
        'Ensalada de vegetales crucíferos': 'Cruciferous vegetables salad',
        'Mix de vegetales bajos en carbos': 'Low-carb vegetables mix',

        // ─────────────────────────────────────────────────────────────
        // Otros
        // ─────────────────────────────────────────────────────────────
        'Tortillas integrales': 'Whole wheat tortillas',
      };

      // Buscamos en el mapa
      return esToEn[backendName.trim()] ?? backendName.trim();
    }

    String translatePortion(String portion, AppLocalizations l10n) {
      final locale = Localizations.localeOf(context).languageCode;

      // Debug
      debugPrint('translatePortion - Original: "$portion" (locale: $locale)');

      if (locale == 'es') {
        debugPrint('translatePortion - Español: sin cambios → "$portion"');
        return portion.trim();
      }

      // 1. Normalizamos todo a minúsculas para reemplazos confiables
      String translated = portion.trim().toLowerCase();

      debugPrint('translatePortion - Después de toLowerCase: "$translated"');

      // 2. Reemplazos
      translated = translated
          // Pesos
          .replaceAll('peso en crudo', 'raw weight')
          .replaceAll('(peso en crudo)', '(raw weight)')
          .replaceAll('peso cocido', 'cooked weight')
          .replaceAll('(peso cocido)', '(cooked weight)')
          .replaceAll('peso en seco', 'dry weight')
          .replaceAll('(peso en seco)', '(dry weight)')
          .replaceAll('peso seco', 'dry weight')
          .replaceAll('(peso seco)', '(dry weight)')
          .replaceAll('escurrido', 'drained')
          .replaceAll('g', 'g')

          // Unidades
          .replaceAll('unidades', 'units')
          .replaceAll('unidad', 'unit')
          .replaceAll('rebanadas', 'slices')
          .replaceAll('rebanada', 'slice')
          // Huevos
          .replaceAll('claras', 'egg whites')
          .replaceAll('clara', 'egg white')
          .replaceAll('huevos enteros', 'whole eggs')
          .replaceAll('huevo entero', 'whole egg')
          .replaceAll('huevos', 'eggs')
          .replaceAll('huevo', 'egg')
          .replaceAll(
              'unidads', 'units') // ← Corrige "unidads" que aparece en el log
          .replaceAll('uds', 'units')
          .replaceAll('unid.', 'units')
          .replaceAll('unid', 'units')
          .replaceAll('cucharadas', 'tablespoons')
          .replaceAll('cucharada', 'tablespoon')
          .replaceAll('tazas grandes', 'large cups')
          .replaceAll('tazas', 'cups')
          .replaceAll('taza', 'cup');

      debugPrint('translatePortion - Después de replaceAll: "$translated"');

      // 3. Capitalización inteligente: solo capitalizamos palabras fuera de paréntesis
      // Separamos el texto principal y lo que está entre paréntesis
      final regExp = RegExp(r'^(.*?)(?:\s*\((.*?)\))?$');
      final match = regExp.firstMatch(translated);

      if (match != null) {
        String mainPart = match.group(1)?.trim() ?? '';
        String parenPart = match.group(2)?.trim() ?? '';

        // Capitalizamos solo la parte principal (antes del paréntesis)
        mainPart = mainPart.split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');

        // Capitalizamos también la parte entre paréntesis
        parenPart = parenPart.split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');

        translated = parenPart.isEmpty ? mainPart : '$mainPart ($parenPart)';
      } else {
        // Si no hay paréntesis, capitalizamos todo
        translated = translated.split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
      }

      debugPrint(
          'translatePortion - Final (capitalización inteligente): "$translated"');

      return translated;
    }

    // ⭐ NUEVO: Traducir el nombre del alimento
    final displayName = getLocalizedFoodName(option.name, l10n);
    bool budgetMismatch = false;
    if (userBudget != null) {
      bool isLowBudget = userBudget!.contains('bajo');
      budgetMismatch = (isLowBudget && option.isHighBudget) ||
          (!isLowBudget && option.isLowBudget);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          if (isSelected) {
            // Deseleccionar
            onDeselect?.call();
          } else {
            onTap();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      FrutiaColors.accent.withOpacity(0.1),
                      FrutiaColors.accent2.withOpacity(0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? FrutiaColors.accent
                  : FrutiaColors.secondaryText.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text:
                            displayName, // ⭐ AQUÍ CAMBIA: usamos el nombre traducido
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: FrutiaColors.primaryText),
                        children: [
                          TextSpan(
                            text:
                                ' ${translatePortion(option.portion, l10n)}', // ← Aplica la traducción aquí
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: FrutiaColors.primaryText.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatPill(
                            label: '~${option.calories} ${l10n.kcal}',
                            color: Colors.orange.shade700),
                        _StatPill(
                            label:
                                '${option.protein}g ${l10n.proteinLabelShort}',
                            color: Colors.blue.shade700),
                        _StatPill(
                            label: '${option.carbs}g ${l10n.carbsLabelShort}',
                            color: Colors.green.shade700),
                        _StatPill(
                            label: '${option.fats}g ${l10n.fatsLabelShort}',
                            color: Colors.purple.shade700),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? FrutiaColors.accent
                    : FrutiaColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: GoogleFonts.lato(
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }
}

class _FreeSaladInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ← AGREGAR ESTA LÍNEA

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              FrutiaColors.accent.withOpacity(0.1),
              FrutiaColors.accent2.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.eco_rounded, color: FrutiaColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.accompanySaladFree,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600, color: FrutiaColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final String originalTitle; // ⭐ AGREGAR - para lógica interna

  final IconData icon;
  final List<MealCategory> categories;
  final List<InspirationRecipe> suggestedRecipes;
  final Map<String, MealOption> selections;
  final Function(String, MealOption) onOptionSelected;
  final bool isRegistering;
  final bool isCompleted;
  final Function(String, String)? onDeselectionRequested; // AGREGAR

  final List<String>? validationWarnings; // NUEVO

  final VoidCallback onRegister;

  const _MealCard({
    required this.title,
    required this.originalTitle, // ⭐ AGREGAR

    required this.icon,
    required this.categories,
    required this.suggestedRecipes,
    required this.selections,
    required this.onOptionSelected,
    required this.isRegistering,
    required this.isCompleted,
    this.validationWarnings,
    this.onDeselectionRequested, // AGREGAR

    required this.onRegister,
  });

  int get _totalCalories =>
      selections.values.fold(0, (sum, item) => sum + item.calories);
  bool get _isSelectionComplete =>
      selections.isNotEmpty; // ✅ Solo requiere AL MENOS una selección
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ← AGREGAR ESTA LÍNEA

    final cardColor = isCompleted
        ? Colors.green.withOpacity(0.05)
        : FrutiaColors.secondaryBackground;
    final borderColor = isCompleted
        ? Colors.green.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: validationWarnings != null && validationWarnings!.isNotEmpty
            ? Border.all(color: Colors.orange, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
              color: borderColor, blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: FrutiaColors.accent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText,
                        ),
                      ),
                      if (validationWarnings != null &&
                          validationWarnings!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.suggestionsTitle,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ...validationWarnings!.map((warning) => Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      warning,
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProgressColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selections.length}/${categories.length}',
                    style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor()),
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted) ...[
            const Divider(indent: 16, endIndent: 16, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selections.isEmpty
                            ? l10n.selectAtLeastOneOption(title)
                            : selections.length < categories.length
                                ? l10n.canAddMoreOptions(
                                    selections.length, categories.length)
                                : l10n.completeMealConfirm(title),
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...categories.map((category) => _MealCategorySection(
                  category: category,
                  groupValue: selections[category.title],
                  onChanged: (option) =>
                      onOptionSelected(category.title, option),
                  onDeselect: () => onDeselectionRequested?.call(originalTitle,
                      category.title), // ⭐ CAMBIA 'title' POR 'originalTitle'
                )),
            if (title != 'Shake') _FreeSaladInfo(),
            if (suggestedRecipes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu,
                            color: FrutiaColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.recipeIdeasFor(title), // ← CAMBIAR ESTA LÍNEA
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: FrutiaColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.useIngredientsAbove, // ← CAMBIAR ESTA LÍNEA
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          color: FrutiaColors.secondaryText,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    ...suggestedRecipes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final recipe = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _RecipeCard(recipe: recipe, index: index + 1),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle,
                        color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.mealCompleted(title), // ← CAMBIAR ESTA LÍNEA
                        style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        l10n.comeBackTomorrow, // ← CAMBIAR ESTA LÍNEA
                        style: GoogleFonts.lato(
                            color: Colors.green.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else if (_isSelectionComplete)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: isRegistering ? null : onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrutiaColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: isRegistering
                    ? Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle,
                        color: Colors.white, size: 22),
                label: Text(
                  isRegistering
                      ? l10n.registeringMeal(title)
                      : selections.length == categories.length
                          ? l10n.confirmMeal(title, _totalCalories)
                          : l10n.confirmPartialMeal(title, _totalCalories),
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (selections.length == 0) return Colors.grey;
    if (selections.length < categories.length) return Colors.orange;
    return Colors.green;
  }
}

class _RecipeCard extends StatelessWidget {
  final InspirationRecipe recipe;
  final int index;

  const _RecipeCard({required this.recipe, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FrutiaColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: FrutiaColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: FrutiaColors.primaryText,
                  ),
                ),
                Text(
                  '${recipe.readyInMinutes} min',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: FrutiaColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
