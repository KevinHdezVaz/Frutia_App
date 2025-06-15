import 'dart:async';
import 'dart:convert'; // For jsonDecode
import 'dart:io';
import 'package:Frutia/services/storage_service.dart'; // To get authentication token
import 'package:Frutia/utils/constantes.dart'; // To get baseUrl
import 'package:flutter/material.dart'; // For debugPrint
import 'package:http/http.dart' as http; // For HTTP requests

class PlanService {
  final StorageService _storage = StorageService(); // Use _ for private fields

  // Re-use the authenticated request logic for consistency and avoid duplication
  Future<dynamic> _authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw Exception('No autenticado: Token no encontrado.');
    }

    final uri = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParams != null
          ? {for (var e in queryParams.entries) e.key: e.value.toString()}
          : null,
    );
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) {
        debugPrint('PlanService Request body: $body');
        request.body = jsonEncode(body);
      }

      final streamedResponse = await request.send().timeout(
          const Duration(seconds: 20)); // Increased timeout for AI calls
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint(
          'PlanService [$method] $endpoint - Status: ${response.statusCode}');
      debugPrint('PlanService Response: ${response.body}');

      if (response.statusCode == 401) {
        await _storage.removeToken(); // Clear invalid token
        throw Exception(
            'Sesión expirada o token inválido, por favor vuelve a iniciar sesión.');
      }

      if (response.statusCode >= 400) {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
              errorData['message'] ?? 'Error en la solicitud al plan.');
        } catch (e) {
          // Fallback if response body is not valid JSON
          throw Exception(
              'Error en la solicitud al plan: ${response.statusCode} - ${response.body}');
        }
      }

      // Check if response body is empty before decoding
      if (response.body.isEmpty) {
        return {}; // Return an empty map for successful 200/201 responses with no content
      }
      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception(
          'Tiempo de espera agotado al obtener o generar el plan. Intenta de nuevo.');
    } on SocketException {
      throw Exception('No hay conexión a internet. Verifica tu conexión.');
    } catch (e) {
      debugPrint('PlanService Error de conexión o inesperado: $e');
      throw Exception('Ocurrió un error inesperado: ${e.toString()}');
    }
  }

  /// Fetches the current active meal plan for the authenticated user.
  /// This does NOT call the AI and is cheaper.
  Future<Map<String, dynamic>> getCurrentMealPlan() async {
    try {
      final response = await _authenticatedRequest(
        method: 'GET',
        endpoint: 'plan/current',
      );
      return response; // This should be the direct plan_data object
    } catch (e) {
      debugPrint('Error en getCurrentMealPlan: $e');
      rethrow;
    }
  }

  /// Generates a new meal plan using AI and stores it in the database.
  /// This CALLS the AI and can be costly. It should be explicitly triggered by the user.
  Future<Map<String, dynamic>> generateNewMealPlan() async {
    try {
      final response = await _authenticatedRequest(
        method: 'POST',
        endpoint: 'plan/generate',
        // If your generate endpoint expects a body (e.g., profile updates), add it here
        // body: {'some_profile_field': 'updated_value'},
      );
      // Assuming the backend returns the plan_data directly inside a 'data' key
      if (response != null && response['data'] != null) {
        return response['data'];
      } else {
        throw Exception('Formato de respuesta inesperado al generar plan.');
      }
    } catch (e) {
      debugPrint('Error en generateNewMealPlan: $e');
      rethrow;
    }
  }

  // You can add other plan-related methods here, e.g., to update a plan, delete, etc.
  // Future<void> updateMealPlan(int planId, Map<String, dynamic> updatedData) async {
  //   await _authenticatedRequest(
  //     method: 'PUT',
  //     endpoint: 'plan/$planId',
  //     body: updatedData,
  //   );
  // }
}
