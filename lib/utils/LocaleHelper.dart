import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleHelper {
  /// Obtiene el código de idioma del dispositivo ('es' o 'en')
  static String getDeviceLanguageCode() {
    try {
      final String systemLocale = Platform.localeName; // 'en_US', 'es_MX'
      final String languageCode = systemLocale.split('_')[0]; // 'en', 'es'

      // ⭐ NUEVO: LOG DE DEBUG
      print('🔍 DEBUG LOCALE:');
      print('   System locale: $systemLocale');
      print('   Language code: $languageCode');

      // Validar que sea soportado
      if (languageCode == 'en' || languageCode == 'es') {
        print('   ✅ Locale válido: $languageCode');
        return languageCode;
      }

      print('   ⚠️ Locale no soportado, usando fallback: es');
      return 'es'; // Fallback
    } catch (e) {
      print('❌ Error getting device language: $e');
      return 'es';
    }
  }

  /// ⭐ NUEVO: Obtiene el código de idioma de la APP (con preferencia sobre el dispositivo)
  /// Este método lee el idioma que el usuario seleccionó en la app desde SharedPreferences
  /// Si no hay idioma guardado, usa el idioma del dispositivo como fallback
  static Future<String> getAppLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? languageCode = prefs.getString('language_code');

      if (languageCode != null) {
        print('🌐 Usando idioma de la app: $languageCode');
        return languageCode;
      }

      // Fallback al idioma del dispositivo
      final deviceLanguage = getDeviceLanguageCode();
      print(
          '🌐 No hay idioma guardado, usando idioma del dispositivo: $deviceLanguage');
      return deviceLanguage;
    } catch (e) {
      print('❌ Error getting app language: $e');
      return getDeviceLanguageCode();
    }
  }
}
