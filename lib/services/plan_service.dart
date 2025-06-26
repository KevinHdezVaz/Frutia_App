import 'dart:convert';
import 'dart:typed_data';
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
    final url = Uri.parse('$baseUrl/ingredient-image/${Uri.encodeComponent(ingredientName)}');

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
      throw Exception('No se pudo cargar la imagen del ingrediente. Status: ${response.statusCode}');
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
