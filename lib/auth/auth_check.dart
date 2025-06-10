// lib/auth/auth_check_main.dart

import 'package:flutter/material.dart';
import 'package:Frutia/auth/auth_page_check.dart';
import 'package:Frutia/pages/bottom_nav.dart'; // O directamente HomePage si prefieres
import 'package:Frutia/services/storage_service.dart';

class AuthCheckMain extends StatelessWidget {
  const AuthCheckMain({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // 1. Revisa si existe un token guardado
      future: StorageService().getToken(),
      builder: (context, snapshot) {
        // Mientras espera, muestra un indicador de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si HAY un token, el usuario está logueado
        if (snapshot.hasData && snapshot.data != null) {
          // Lo mandamos a la app principal (que contiene la HomePage)
          return const BottomNavBar(); // O la HomePage directamente
        }

        // 3. Si NO hay token, lo mandamos a la página de autenticación
        return const AuthPageCheck();
      },
    );
  }
}
