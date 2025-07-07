import 'dart:convert';
import 'dart:typed_data';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/model/Recipe.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PlanService {
  final StorageService _storage = StorageService();

  Future<List<Recipe>> getRecipes(
      {String? mealType, List<String>? tags}) async {
    try {
      final token = await _storage.getToken();
      final response = await http.get(
        Uri.parse('https://tuapi.com/api/recipes'),
        headers: {'Authorization': 'Bearer $token'},
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

  Future<List<String>> getShoppingListIngredients() async {
    // Nuevo método
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    final response = await http.get(
      Uri.parse('$baseUrl/plan/ingredients'), // Nueva URL
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data')) {
        return List<String>.from(responseData[
            'data']); // La data es directamente la lista de strings
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

  Future<MealPlanData> generatePlan() async {
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    final response = await http.post(
      Uri.parse('$baseUrl/plan/generate'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Código de estado: ${response.statusCode}');
    print('Cuerpo de la respuesta: ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('data')) {
        return MealPlanData.fromJson(responseData['data']);
      } else {
        throw Exception('Respuesta inesperada: campo "data" no encontrado.');
      }
    } else {
      throw Exception(
          'Error al generar el plan. Código: ${response.statusCode}. Cuerpo: ${response.body}');
    }
  }

  Future<Uint8List> getIngredientImage(String ingredientName) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw AuthException('No autenticado.');
    }

    // Construimos la URL al endpoint del IngredientController
    final url = Uri.parse(
        '$baseUrl/ingredient-image/${Uri.encodeComponent(ingredientName)}');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'image/png,image/jpeg', // Indicamos que esperamos una imagen
      },
    );

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, devolvemos los bytes de la imagen
      return response.bodyBytes;
    } else {
      // Si el servidor devuelve un error (ej. 404), lanzamos una excepción
      throw Exception(
          'No se pudo cargar la imagen del ingrediente. Status: ${response.statusCode}');
    }
  }
// services/plan_service.dart

  Future<MealPlanData?> getCurrentPlan() async {
    _log('Iniciando getCurrentPlan...');
    try {
      final token = await _storage.getToken();
      if (token == null) {
        _log('Error: No se encontró token de autenticación.');
        throw AuthException('No autenticado.');
      }

      final url = Uri.parse('$baseUrl/plan/current');
      _log('Llamando a URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _log('--- Respuesta del Servidor (getCurrentPlan) ---');
      _log('Status Code: ${response.statusCode}');
      _log('Response Body: ${response.body}');
      _log('-------------------------------------------');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data') && responseData['data'] != null) {
          // <-- INICIO DE LA CORRECCIÓN
          // 1. Extraemos específicamente el objeto del plan activo
          final planJson = responseData['data']['active_plan'];

          // 2. Comprobamos si el plan es nulo (caso válido para usuarios nuevos)
          if (planJson == null) {
            _log('Info: No se encontró un plan activo (active_plan es nulo).');
            return null; // Devolvemos null para indicar que no hay plan
          }

          // 3. Si no es nulo, lo pasamos al constructor
          _log('Campo "active_plan" encontrado. Parseando MealPlanData...');
          return MealPlanData.fromJson(planJson);
          // <-- FIN DE LA CORRECCIÓN
        } else {
          _log(
              'Error: Respuesta 200 pero el campo "data" no existe o es nulo.');
          throw Exception(
              'Respuesta inesperada: campo "data" no encontrado o nulo.');
        }
      } else if (response.statusCode == 404) {
        _log(
            'Info: El servidor devolvió 404. No se encontró un plan activo para este usuario.');
        return null;
      } else {
        _log('Error en la respuesta del servidor.');
        final errorBody = json.decode(response.body);
        throw Exception(
            'Error al obtener el plan. Código: ${response.statusCode}. Mensaje: ${errorBody['message'] ?? 'Error desconocido'}');
      }
    } catch (e, stacktrace) {
      _log('EXCEPCIÓN en getCurrentPlan: $e');
      _log('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  Future<void> logMeal({
    required DateTime date,
    required String mealType,
    required List<MealOption> selections,
  }) async {
    _log('Iniciando logMeal para: $mealType');
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    // Convertimos la lista de objetos MealOption a un JSON que el backend espera
    final selectionsJson = selections.map((opt) => opt.toJson()).toList();

    final url = Uri.parse('$baseUrl/history/log');
    _log('Llamando a URL: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    final url = Uri.parse('$baseUrl/history');
    _log('Llamando a URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
    // debugPrint solo imprime en modo debug, no en producción
    debugPrint('[PlanService] $message');
  }
}

class MealLog {
  final String date;
  final String mealType;
  final List<MealOption> selections;

  MealLog({
    required this.date,
    required this.mealType,
    required this.selections,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    final selectionsList = json['selections'] as List? ?? [];
    return MealLog(
      date: json['date'] ?? '',
      mealType: json['meal_type'] ?? 'Comida Desconocida',
      selections: selectionsList.map((s) => MealOption.fromJson(s)).toList(),
    );
  }
}
