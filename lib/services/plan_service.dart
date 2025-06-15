import 'dart:convert';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/model/MealPlanData.dart';
import 'package:Frutia/model/Recipe.dart';
import 'package:Frutia/pages/screens/datosPersonales/PlanSummaryScreen.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;

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

  Future<MealPlanData> generatePlan() async {
    // Cambiado el tipo de retorno a MealPlanData
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    final response = await http.post(
      Uri.parse('$baseUrl/plan/generate'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      // Asumiendo que el 'data' del backend ahora contiene directamente el plan_data
      if (responseData.containsKey('data')) {
        return MealPlanData.fromJson(responseData['data']);
      } else {
        throw Exception('Respuesta inesperada: campo "data" no encontrado.');
      }
    } else {
      throw Exception(
          'Error al generar el plan. Código: ${response.statusCode}. Mensaje: ${json.decode(response.body)['message'] ?? 'Error desconocido'}');
    }
  }

  Future<MealPlanData> getCurrentPlan() async {
    // <--- NUEVA FUNCIÓN
    final token = await _storage.getToken();
    if (token == null) throw AuthException('No autenticado.');

    final response = await http.get(
      Uri.parse('$baseUrl/plan/current'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('data')) {
        return MealPlanData.fromJson(responseData['data']);
      } else {
        throw Exception('Respuesta inesperada: campo "data" no encontrado.');
      }
    } else if (response.statusCode == 404) {
      // No se encontró un plan, podrías manejar esto de forma específica
      throw Exception('No se encontró un plan activo para este usuario.');
    } else {
      throw Exception(
          'Error al obtener el plan. Código: ${response.statusCode}. Mensaje: ${json.decode(response.body)['message'] ?? 'Error desconocido'}');
    }
  }
}
