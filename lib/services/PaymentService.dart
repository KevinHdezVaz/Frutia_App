import 'dart:convert';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  /// Llama al backend para crear una preferencia de pago en MercadoPago.
  ///
  /// Devuelve la [initPointUrl] completa para lanzar el checkout en una Custom Tab.
  Future<String> createPreference(String planId) async {
    // Obtiene el token de autenticación del usuario guardado localmente.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Usuario no autenticado. No se puede crear el pago.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/payment/create-preference'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'plan_id': planId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // El backend ahora devuelve la URL de 'init_point'.
      if (data['init_point'] != null) {
        return data['init_point'];
      } else {
        throw Exception(
            'La respuesta del servidor no contiene la URL de pago (init_point).');
      }
    } else {
      final errorData = jsonDecode(response.body);
      // Si hay un error, lo lanzamos para que la UI pueda mostrarlo.
      throw Exception(
          errorData['error'] ?? 'Error al crear la preferencia de pago');
    }
  }
}
