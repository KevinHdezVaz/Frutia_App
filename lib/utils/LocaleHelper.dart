import 'dart:io';
import 'package:flutter/material.dart';

class LocaleHelper {
  /// Obtiene el código de idioma del dispositivo ('es' o 'en')
  static String getDeviceLanguageCode() {
    try {
      final String systemLocale = Platform.localeName; // 'en_US', 'es_MX'
      final String languageCode = systemLocale.split('_')[0]; // 'en', 'es'

      // Validar que sea soportado
      if (languageCode == 'en' || languageCode == 'es') {
        return languageCode;
      }

      return 'es'; // Fallback
    } catch (e) {
      print('Error getting device language: $e');
      return 'es';
    }
  }
}
