import 'package:flutter/material.dart';

class QuestionnaireProvider extends ChangeNotifier {
  // --- Pantalla 1: Sobre ti ---
  String name = '';
  bool hasMedicalCondition = false;
  String medicalConditionDetails = '';
  String? mainGoal;

  // --- Pantalla 2: Tu Rutina ---
  List<String> sport = [];
  String? trainingFrequency;
  String? dailyActivityLevel;
  TimeOfDay? breakfastTime;
  TimeOfDay? lunchTime;
  TimeOfDay? dinnerTime;
  String? eatsOut;

  // --- Pantalla 3: Tu Alimentación ---
  String dislikedFoods = '';
  bool hasAllergies = false;
  String allergyDetails = '';
  String? dietStyle;
  String? weeklyBudget;
  String? mealCount;

  // --- Pantalla 4: Tus Preferencias ---
  String? communicationTone;
  String? preferredName;
  Set<String> dietDifficulties =
      {}; // Nuevo: Dificultades en el plan alimenticio
  Set<String> dietMotivations = {}; // Nuevo: Motivaciones para seguir el plan

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
    sport = [];
    trainingFrequency = null;
    dailyActivityLevel = null;
    breakfastTime = null;
    lunchTime = null;
    dinnerTime = null;
    eatsOut = null;
    dislikedFoods = '';
    hasAllergies = false;
    allergyDetails = '';
    dietStyle = null;
    weeklyBudget = null;
    mealCount = null;
    communicationTone = null;
    preferredName = null;
    dietDifficulties = {};
    dietMotivations = {};
    notifyListeners(); // Important: Notify listeners after resetting
  }

  // Para debugging
  void printSummary() {
    debugPrint('----- RESUMEN COMPLETO DEL CUESTIONARIO -----');
    debugPrint('Nombre: $name');
    debugPrint(
        'Condición Médica: $hasMedicalCondition, Detalles: $medicalConditionDetails');
    debugPrint('Objetivo Principal: $mainGoal');
    debugPrint('---');
    debugPrint('Deporte: $sport, Frecuencia: $trainingFrequency');
    debugPrint('Horarios: D: $breakfastTime, A: $lunchTime, C: $dinnerTime');
    debugPrint('Come fuera: $eatsOut');
    debugPrint('---');
    debugPrint('No le gusta: $dislikedFoods');
    debugPrint('Alergias: $hasAllergies, Detalles: $allergyDetails');
    debugPrint('Estilo Dieta: $dietStyle, Presupuesto: $weeklyBudget');
    debugPrint('Comidas al día: $mealCount');
    debugPrint('---');
    debugPrint('Tono: $communicationTone, Nombre preferido: $preferredName');
    debugPrint('Dificultades: $dietDifficulties'); // Nuevo
    debugPrint('Motivaciones: $dietMotivations'); // Nuevo
    debugPrint('------------------------------------------');
  }
}
