import 'package:flutter/material.dart';
import 'package:user_auth_crudd10/auth/auth_page_check.dart';
import 'package:user_auth_crudd10/onscreen/QuestionnairePage.dart';
import 'package:user_auth_crudd10/pages/bottom_nav.dart';
import 'package:user_auth_crudd10/services/storage_service.dart';

class AuthCheckMain extends StatelessWidget {
  const AuthCheckMain({super.key});

  // Bandera estática para controlar si el modal ya se mostró
  static bool _hasShownModal = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: StorageService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data != null) {
          // Mostrar el modal solo si no se ha mostrado antes
          if (!_hasShownModal) {
            _hasShownModal = true; // Marcar que el modal ya se mostró
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PersonalDataPage(
                  showLoginPage: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AuthPageCheck()),
                    );
                  },
                ),
              ).then((_) {
                // No recargamos AuthCheckMain, ya que BottomNavBar ya está debajo
              });
            });
          }
          return const BottomNavBar();
        }
        return AuthPageCheck();
      },
    );
  }
}
