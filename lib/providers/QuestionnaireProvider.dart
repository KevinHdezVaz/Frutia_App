import 'package:flutter/material.dart';

class QuestionnaireProvider extends ChangeNotifier {
  // --- Pantalla 1: Sobre ti ---
  String name = '';
  bool hasMedicalCondition = false;
  String medicalConditionDetails = '';
  String? mainGoal;
  String? sex; // ⭐ AGREGADO: variable para sexo (masculino/femenino)

  // --- Pantalla 2: Tu Rutina ---
  List<String> sport = [];
  String? weeklyActivity; // ya la tenías

  // --- Favoritos ---
  Set<String> favoriteProteins = {};
  Set<String> favoriteCarbs = {};
  Set<String> favoriteFats = {};
  Set<String> favoriteFruits = {};

  // --- Horarios de comidas ---
  TimeOfDay? breakfastTime;
  TimeOfDay? lunchTime;
  TimeOfDay? dinnerTime;

  // --- Alimentación ---
  String? eatsOut;
  String dislikedFoods = '';
  bool hasAllergies = false;
  String allergyDetails = '';
  String? dietStyle;
  String? weeklyBudget;
  String? _preferredSnackTime; // ya lo tenías

  // --- Preferencias ---
  String? communicationTone;
  String? preferredName;
  Set<String> dietDifficulties = {};
  Set<String> dietMotivations = {};

  // Getter y setter para preferredSnackTime
  String? get preferredSnackTime => _preferredSnackTime;
  set preferredSnackTime(String? value) {
    _preferredSnackTime = value;
    notifyListeners();
  }

  // Método para actualizar y notificar
  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  void reset() {
    name = '';
    hasMedicalCondition = false;
    medicalConditionDetails = '';
    mainGoal = null;
    sex = null; // ⭐ AGREGADO: limpiar sexo

    sport = [];
    weeklyActivity = null;

    favoriteProteins = {};
    favoriteCarbs = {};
    favoriteFats = {};
    favoriteFruits = {};

    breakfastTime = null;
    lunchTime = null;
    dinnerTime = null;

    eatsOut = null;
    dislikedFoods = '';
    hasAllergies = false;
    allergyDetails = '';
    dietStyle = null;
    weeklyBudget = null;

    communicationTone = null;
    preferredName = null;
    dietDifficulties = {};
    dietMotivations = {};

    _preferredSnackTime = null;

    notifyListeners();
  }

  // Para debugging (muy útil)
  void printSummary() {
    debugPrint('----- RESUMEN COMPLETO DEL CUESTIONARIO -----');
    debugPrint('Nombre: $name');
    debugPrint('Sexo: $sex'); // ⭐ AGREGADO
    debugPrint(
        'Condición Médica: $hasMedicalCondition, Detalles: $medicalConditionDetails');
    debugPrint('Objetivo Principal: $mainGoal');
    debugPrint('Deporte: $sport');
    debugPrint('Actividad Semanal: $weeklyActivity');
    debugPrint('Horarios: D: $breakfastTime, A: $lunchTime, C: $dinnerTime');
    debugPrint('Come fuera: $eatsOut');
    debugPrint('No le gusta: $dislikedFoods');
    debugPrint('Alergias: $hasAllergies, Detalles: $allergyDetails');
    debugPrint('Estilo Dieta: $dietStyle, Presupuesto: $weeklyBudget');
    debugPrint('Tono: $communicationTone, Nombre preferido: $preferredName');
    debugPrint('Dificultades: $dietDifficulties');
    debugPrint('Motivaciones: $dietMotivations');
    debugPrint('Snack preferido: $preferredSnackTime');
    debugPrint('Favoritos:');
    debugPrint('  Proteínas: $favoriteProteins');
    debugPrint('  Carbos: $favoriteCarbs');
    debugPrint('  Grasas: $favoriteFats');
    debugPrint('  Frutas: $favoriteFruits');
    debugPrint('------------------------------------------');
  }
}
