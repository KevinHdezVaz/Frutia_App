import 'dart:convert';
import 'package:Frutia/utils/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  Future<String> createPreference(String planId, {String? affiliateCode}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      throw Exception('Usuario no autenticado. No se puede crear el pago.');
    }

    final body = {
      'plan_id': planId,
    };
    
    if (affiliateCode != null && affiliateCode.isNotEmpty) {
      body['affiliate_code'] = affiliateCode;
    }

    print('🚀 Creating payment preference for plan: $planId');

    final response = await http.post(
      Uri.parse('$baseUrl/payment/create-preference'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // 🔥 Debugging
      print('🔍 Payment URL: ${data['init_point']}');
      print('🔍 Mode: ${data['mode']}');
      print('🔍 Preference ID: ${data['preference_id']}');
      
      if (data['init_point'] != null) {
        return data['init_point'];
      } else {
        throw Exception('La respuesta del servidor no contiene la URL de pago.');
      }
    } else {
      print('❌ Error response: ${response.body}');
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['error'] ?? 'Error al crear la preferencia de pago');
    }
  }
}