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

  Future<String> getUserName() async {
    try {
      final token = await _storage.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/name'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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

  Future<void> generatePlan() async {
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    final response = await http.post(
      Uri.parse('$baseUrl/plan/generate'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // El backend ahora devuelve 202 (Accepted) para indicar que el job ha empezado.
    if (response.statusCode == 202) {
      debugPrint("Solicitud para generar plan aceptada por el servidor.");
      // No hacemos nada más, la función termina exitosamente.
      return;
    } else {
      // Si algo sale mal al iniciar el job, lanzamos un error.
      throw Exception(
          'Error al iniciar la generación del plan. Código: ${response.statusCode}. Cuerpo: ${response.body}');
    }
  }

  Future<String> checkPlanStatus(DateTime requestTime) async {
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    // Convertimos la fecha a segundos desde la época (formato timestamp UNIX)
    final timestamp = requestTime.millisecondsSinceEpoch ~/ 1000;

    final response = await http.get(
      Uri.parse('$baseUrl/plan/status?generation_request_time=$timestamp'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Devuelve "ready" o "pending"
      return data['status'] as String? ?? 'pending';
    } else {
      // Si hay un error, asumimos que sigue pendiente para no romper el bucle de polling
      debugPrint("Error al chequear estado del plan, se reintentará.");
      return 'pending';
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
// En tu archivo services/plan_service.dart

  Future<MealPlanData?> getCurrentPlan() async {
    // --- Código para obtener el token y la URL ...
    final token = await _storage.getToken();
    if (token == null) throw Exception('No autenticado');
    final url = Uri.parse('$baseUrl/plan/current');

    final response = await http.get(url, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // ▼▼▼ INICIO DE LA CORRECCIÓN CON DEBUGGING ▼▼▼

    // 1. Imprimimos la respuesta CRUDA que llega del servidor
    debugPrint("--- PASO 1: RESPUESTA COMPLETA DEL SERVIDOR ---");
    debugPrint(response.body);
    debugPrint("-------------------------------------------");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // 2. Extraemos el objeto 'active_plan' que está anidado
      final activePlanJson = responseData['data']['active_plan'];

      if (activePlanJson == null) {
        debugPrint(
            "--- PASO 2: El plan activo es nulo. No hay nada que parsear. ---");
        return null;
      }

      // 3. Imprimimos SÓLO la parte del JSON que vamos a parsear
      debugPrint(
          "--- PASO 2: JSON DEL PLAN EXTRAÍDO (Lo que se va a parsear) ---");
      // Usamos un encoder para imprimirlo bonito
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      debugPrint(encoder.convert(activePlanJson));
      debugPrint("----------------------------------------------------------");

      try {
        // 4. Pasamos el JSON correcto al constructor del modelo
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

// Añade esta clase a tu archivo de modelos si no existe, o reemplázala.

class MealLog {
  final int id;
  final String date;
  final String mealType;
  // La clave está aquí: 'selections' es una lista de objetos MealOption
  final List<MealOption> selections;

  MealLog({
    required this.id,
    required this.date,
    required this.mealType,
    required this.selections,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    // Se parsea la lista de selecciones usando el modelo MealOption que ya tienes
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
