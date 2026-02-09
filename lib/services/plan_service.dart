import 'dart:convert';
import 'dart:typed_data';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/model/Recipe.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/LocaleHelper.dart'; // ⭐ IMPORTAR
import 'package:Frutia/utils/constantes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PlanService {
  final StorageService _storage = StorageService();

  // ⭐ NUEVO: Método para obtener headers con idioma
  Future<Map<String, String>> _getHeaders({String? languageCode}) async {
    final token = await _storage.getToken();
    final code = languageCode ??
        await LocaleHelper.getAppLanguageCode(); // ⭐ USAR IDIOMA DE LA APP

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept-Language': code, // ⭐ AGREGAR HEADER DE IDIOMA
    };
  }

  Future<List<Recipe>> getRecipes(
      {String? mealType, List<String>? tags}) async {
    try {
      final headers = await _getHeaders(); // ⭐ USAR HEADERS
      final response = await http.get(
        Uri.parse('https://tuapi.com/api/recipes'),
        headers: headers, // ⭐ CAMBIAR
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Recipe.fromJson(json)).toList();
      }
      throw Exception('Error al cargar recetas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTodayHistory() async {
    final headers = await _getHeaders(); // ⭐ USAR HEADERS

    final response = await http.get(
      Uri.parse('$baseUrl/history/today'),
      headers: headers, // ⭐ CAMBIAR
    );

    _log('--- Respuesta getTodayHistory ---');
    _log('Status Code: ${response.statusCode}');
    _log('Response Body: ${response.body}');
    _log('-----------------------------------');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> historyList = responseData['data'] ?? [];

      return historyList.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al cargar historial del día');
    }
  }

  Future<String> getUserName() async {
    try {
      final headers = await _getHeaders(); // ⭐ USAR HEADERS
      final response = await http.get(
        Uri.parse('$baseUrl/user/name'),
        headers: headers, // ⭐ CAMBIAR
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('--- RESPUESTA DEL ENDPOINT /user/name ---');
        debugPrint(jsonEncode(jsonResponse));
        debugPrint('---------------------------------------');

        return jsonResponse['name'] as String;
      } else {
        throw Exception(
            'Error al obtener el nombre del usuario: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateMealSelection({
    required List<MealOption> selections,
    required String mealType,
    required TargetMacros targetMacros,
  }) async {
    final headers = await _getHeaders(); // ⭐ USAR HEADERS

    final url = Uri.parse('$baseUrl/meal-plans/validate-selection');

    final response = await http.post(
      url,
      headers: headers, // ⭐ CAMBIAR
      body: json.encode({
        'selections': selections.map((s) => s.toJson()).toList(),
        'meal_type': mealType,
        'target_macros': {
          'protein': targetMacros.protein,
          'carbs': targetMacros.carbs,
          'fats': targetMacros.fats,
          'calories': targetMacros.calories,
        }
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al validar selección');
    }
  }

  Future<List<String>> getShoppingListIngredients() async {
    final headers = await _getHeaders(); // ⭐ USAR HEADERS

    final response = await http.get(
      Uri.parse('$baseUrl/plan/ingredients'),
      headers: headers, // ⭐ CAMBIAR
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data')) {
        return List<String>.from(responseData['data']);
      } else {
        throw Exception(
            'Respuesta inesperada: campo "data" no encontrado en ingredientes.');
      }
    } else if (response.statusCode == 404) {
      throw Exception(
          'No se encontró un plan activo para generar la lista de compras.');
    } else {
      throw Exception(
          'Error al obtener la lista de ingredientes. Código: ${response.statusCode}. Mensaje: ${json.decode(response.body)['message'] ?? 'Error desconocido'}');
    }
  }

// ⭐ CRÍTICO: Este es el método que genera el plan
  Future<void> generatePlan({String? languageCode}) async {
    final headers = await _getHeaders(
        languageCode: languageCode); // ⭐ USAR HEADERS CON IDIOMA

    // ⭐ LOGS DETALLADOS
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 GENERANDO PLAN');
    debugPrint('   Accept-Language: ${headers['Accept-Language']}');
    debugPrint('   Headers completos:');
    headers.forEach((key, value) {
      debugPrint('      $key: $value');
    });
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final response = await http.post(
      Uri.parse('$baseUrl/plan/generate'),
      headers: headers,
    );

    if (response.statusCode == 202) {
      debugPrint("✅ Solicitud para generar plan aceptada por el servidor.");
      debugPrint("📋 Respuesta del servidor:");
      debugPrint(response.body);
      return;
    } else {
      throw Exception(
          'Error al iniciar la generación del plan. Código: ${response.statusCode}. Cuerpo: ${response.body}');
    }
  }

  Future<String> checkPlanStatus(DateTime requestTime) async {
    final headers = await _getHeaders(); // ⭐ USAR HEADERS
    final timestamp = requestTime.millisecondsSinceEpoch ~/ 1000;

    final response = await http.get(
      Uri.parse('$baseUrl/plan/status?generation_request_time=$timestamp'),
      headers: headers, // ⭐ CAMBIAR
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] as String? ?? 'pending';
    } else {
      debugPrint("Error al chequear estado del plan, se reintentará.");
      return 'pending';
    }
  }

  Future<Uint8List> getIngredientImage(String ingredientName) async {
    final headers = await _getHeaders(); // ⭐ USAR HEADERS

    final url = Uri.parse(
        '$baseUrl/ingredient-image/${Uri.encodeComponent(ingredientName)}');

    final response = await http.get(
      url,
      headers: {
        ...headers,
        'Accept': 'image/png,image/jpeg', // ⭐ OVERRIDE para imágenes
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
          'No se pudo cargar la imagen del ingrediente. Status: ${response.statusCode}');
    }
  }

  // ⭐ CRÍTICO: Este método obtiene el plan generado
  Future<MealPlanData?> getCurrentPlan() async {
    final headers = await _getHeaders(); // ⭐ USAR HEADERS
    final url = Uri.parse('$baseUrl/plan/current');

    debugPrint(
        '🌐 Obteniendo plan con locale: ${headers['Accept-Language']}'); // ⭐ LOG

    final response = await http.get(
      url,
      headers: headers, // ⭐ CAMBIAR
    );

    debugPrint("--- PASO 1: RESPUESTA COMPLETA DEL SERVIDOR ---");
    debugPrint(response.body);
    debugPrint("-------------------------------------------");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final activePlanJson = responseData['data']['active_plan'];

      if (activePlanJson == null) {
        debugPrint(
            "--- PASO 2: El plan activo es nulo. No hay nada que parsear. ---");
        return null;
      }

      debugPrint(
          "--- PASO 2: JSON DEL PLAN EXTRAÍDO (Lo que se va a parsear) ---");
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      debugPrint(encoder.convert(activePlanJson));
      debugPrint("----------------------------------------------------------");

      try {
        final mealPlan =
            MealPlanData.fromJson(activePlanJson as Map<String, dynamic>);
        debugPrint(
            "--- PASO 3: ¡ÉXITO! El JSON se ha parseado correctamente. ---");
        return mealPlan;
      } catch (e, s) {
        debugPrint("--- ¡ERROR AL PARSEAR! ---");
        debugPrint("El error es: $e");
        debugPrint("Stacktrace: $s");
        debugPrint("-------------------------");
        throw Exception("Error al procesar los datos del plan.");
      }
    } else {
      debugPrint("Error de servidor: ${response.statusCode}");
      throw Exception('Error al cargar el plan desde el servidor.');
    }
  }

  Future<void> logMeal({
    required DateTime date,
    required String mealType,
    required List<MealOption> selections,
  }) async {
    _log('Iniciando logMeal para: $mealType');
    final headers = await _getHeaders(); // ⭐ USAR HEADERS

    final selectionsJson = selections.map((opt) => opt.toJson()).toList();
    final url = Uri.parse('$baseUrl/history/log');
    _log('Llamando a URL: $url');

    final response = await http.post(
      url,
      headers: headers, // ⭐ CAMBIAR
      body: json.encode({
        'date': DateFormat('yyyy-MM-dd').format(date),
        'meal_type': mealType,
        'selections': selectionsJson,
      }),
    );

    _log('--- Respuesta del Servidor (logMeal) ---');
    _log('Status Code: ${response.statusCode}');
    _log('Response Body: ${response.body}');
    _log('---------------------------------------');

    if (response.statusCode != 200) {
      throw Exception('Error al guardar el registro en el servidor.');
    }
    _log('Comida registrada exitosamente en el backend.');
  }

  Future<List<MealLog>> getHistory() async {
    _log('Iniciando getHistory...');
    final headers = await _getHeaders(); // ⭐ USAR HEADERS

    final url = Uri.parse('$baseUrl/history');
    _log('Llamando a URL: $url');

    final response = await http.get(
      url,
      headers: headers, // ⭐ CAMBIAR
    );

    _log('--- Respuesta del Servidor (getHistory) ---');
    _log('Status Code: ${response.statusCode}');
    _log('Response Body: ${response.body}');
    _log('-------------------------------------------');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> logsList = responseData['data'] ?? [];
      return logsList.map((log) => MealLog.fromJson(log)).toList();
    } else {
      throw Exception('Error al cargar el historial.');
    }
  }

  void _log(String message) {
    debugPrint('[PlanService] $message');
  }
}

class MealLog {
  final int id;
  final String date;
  final String mealType;
  final List<MealOption> selections;

  MealLog({
    required this.id,
    required this.date,
    required this.mealType,
    required this.selections,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    var selectionsList = json['selections'] as List? ?? [];

    return MealLog(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? 'Comida Desconocida',
      selections: selectionsList
          .map((s) => MealOption.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
