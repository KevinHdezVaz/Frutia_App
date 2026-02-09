// lib/providers/daily_consumption_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DailyConsumptionProvider extends ChangeNotifier {
  final PlanService _planService = PlanService();

  // Estado actual
  int _caloriesConsumed = 0;
  int _proteinConsumed = 0;
  int _carbsConsumed = 0;
  int _fatsConsumed = 0;

  bool _isLoading = false;
  String? _error;

  // Getters
  int get caloriesConsumed => _caloriesConsumed;
  int get proteinConsumed => _proteinConsumed;
  int get carbsConsumed => _carbsConsumed;
  int get fatsConsumed => _fatsConsumed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData =>
      _caloriesConsumed > 0 ||
      _proteinConsumed > 0 ||
      _carbsConsumed > 0 ||
      _fatsConsumed > 0;

  /// Carga los macros consumidos del día actual
  /// Combina: comidas registradas en el backend + selecciones locales no enviadas aún
  Future<void> loadTodayConsumption({MealPlanData? currentPlan}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Obtener historial del día desde el backend
      final history = await _planService.getHistory();
      final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());

      int backendCalories = 0;
      int backendProtein = 0;
      int backendCarbs = 0;
      int backendFats = 0;

      for (var log in history) {
        final logDate = log.date.substring(0, 10);
        if (logDate == todayString) {
          for (var selection in log.selections) {
            backendCalories += selection.calories;
            backendProtein += selection.protein;
            backendCarbs += selection.carbs;
            backendFats += selection.fats;
          }
        }
      }

      // 2. Obtener selecciones locales pendientes (no registradas aún)
      int localCalories = 0;
      int localProtein = 0;
      int localCarbs = 0;
      int localFats = 0;

      final prefs = await SharedPreferences.getInstance();
      final todayKey = 'daily_selection_$todayString';
      final savedData = prefs.getString(todayKey);

      if (savedData != null) {
        try {
          final Map<String, dynamic> decoded = json.decode(savedData);
          decoded.values.forEach((selections) {
            (selections as Map<String, dynamic>).values.forEach((optionJson) {
              final option = MealOption.fromJson(optionJson);
              localCalories += option.calories;
              localProtein += option.protein;
              localCarbs += option.carbs;
              localFats += option.fats;
            });
          });
        } catch (e) {
          debugPrint('Error parsing local selections: $e');
        }
      }

      // 3. Sumar todo
      _caloriesConsumed = backendCalories + localCalories;
      _proteinConsumed = backendProtein + localProtein;
      _carbsConsumed = backendCarbs + localCarbs;
      _fatsConsumed = backendFats + localFats;

      debugPrint('Consumo hoy: '
          'Cal: $_caloriesConsumed | '
          'Prot: $_proteinConsumed | '
          'Carb: $_carbsConsumed | '
          'Fat: $_fatsConsumed');

      _error = null;
    } catch (e) {
      _error = 'Error al cargar consumo del día';
      debugPrint('Error en loadTodayConsumption: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refrescar manualmente (útil después de registrar una comida)
  Future<void> refresh() async {
    await loadTodayConsumption();
  }

  /// Limpiar datos (opcional, por si cambias de día o logout)
  void clear() {
    _caloriesConsumed = 0;
    _proteinConsumed = 0;
    _carbsConsumed = 0;
    _fatsConsumed = 0;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
