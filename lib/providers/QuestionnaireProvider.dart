import 'package:flutter/material.dart';

class QuestionnaireProvider extends ChangeNotifier {
  // --- Pantalla 1: Sobre ti ---
  String name = '';
  bool hasMedicalCondition = false;
  String medicalConditionDetails = '';
  String? mainGoal;

  // --- Pantalla 2: Tu Rutina ---
  String sport = ''; // Initialized to empty string
  String? trainingFrequency;
  String? dailyActivityLevel;
  String? whoCooks;
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
  Set<String> preferredMessageTypes = {};
  String? preferredName;
  String thingsToAvoid = '';

  // Método para actualizar y notificar
  void update(VoidCallback callback) {
    callback();
    notifyListeners();
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
    debugPrint('Nivel Actividad: $dailyActivityLevel, Quién cocina: $whoCooks');
    debugPrint('Horarios: D: $breakfastTime, A: $lunchTime, C: $dinnerTime');
    debugPrint('Come fuera: $eatsOut');
    debugPrint('---');
    debugPrint('No le gusta: $dislikedFoods');
    debugPrint('Alergias: $hasAllergies, Detalles: $allergyDetails');
    debugPrint('Estilo Dieta: $dietStyle, Presupuesto: $weeklyBudget');
    debugPrint('Comidas al día: $mealCount');
    debugPrint('---');
    debugPrint('Tono: $communicationTone, Nombre preferido: $preferredName');
    debugPrint('Mensajes preferidos: $preferredMessageTypes');
    debugPrint('A evitar: $thingsToAvoid');
    debugPrint('------------------------------------------');
  }
}
