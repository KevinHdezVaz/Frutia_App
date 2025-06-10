import 'dart:convert';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;

class PlanService {
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> generatePlan() async {
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
      return json.decode(response.body);
    } else {
      throw Exception(
          'Error al generar el plan. Código: ${response.statusCode}');
    }
  }
}
