import 'package:Frutia/pages/screens/miplan/PremiumScreen.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Un diálogo con diseño mejorado que se muestra cuando el período de prueba ha expirado.
class TrialExpiredDialog extends StatelessWidget {
  const TrialExpiredDialog({super.key});

  // --- WIDGET INTERNO PARA CREAR FILAS DE BENEFICIOS ---
  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: FrutiaColors.accent, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 15,
                color: FrutiaColors.secondaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // --- FIN DEL WIDGET ---

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetAnimationDuration: const Duration(milliseconds: 500),
      insetAnimationCurve: Curves.easeOut,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 15,
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenSize.width * 0.85,
        // Usamos un tamaño flexible para que se adapte al contenido
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FrutiaColors.primaryBackground.withOpacity(0.98),
              FrutiaColors.primaryBackground,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              // Elementos decorativos
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FrutiaColors.accent.withOpacity(0.05),
                  ),
                ),
              ),

              // Contenido principal envuelto en SingleChildScrollView
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Imagen con efecto flotante
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: FrutiaColors.accent.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/frutaProgresoSad1.png',
                          height: screenSize.height * 0.18,
                          fit: BoxFit.contain,
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .scaleXY(
                                begin: 1,
                                end: 1.55,
                                duration: 3000.ms,
                                curve: Curves.easeInOut)
                            .then(delay: 3000.ms)
                            .scaleXY(begin: 1.05, end: 1, duration: 3000.ms),
                      ),

                      const SizedBox(height: 25),

                      // Título con animación
                      Text(
                        '¡Tu Prueba Terminó!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: FrutiaColors.primaryText,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.5, curve: Curves.easeOut),

                      const SizedBox(height: 15),

                      // Lista de beneficios
                      _buildBenefitRow(
                        Icons.restaurant_menu_rounded,
                        'Planes de alimentación personalizados.',
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),
                      _buildBenefitRow(
                        Icons.auto_awesome_rounded,
                        'Recetas exclusivas y deliciosas.',
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),
                      _buildBenefitRow(
                        Icons.show_chart_rounded,
                        'Seguimiento detallado de tu progreso.',
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2),

                      const SizedBox(height: 30),

                      // Botón premium con gradiente
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [
                              FrutiaColors.accent,
                              FrutiaColors.accent2,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FrutiaColors.accent.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const PremiumScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Centra el contenido de la fila
                            children: [
                              Flexible(
                                child: Text(
                                  'VER PLANES PREMIUM',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .scale(delay: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 20),

                      // Texto pequeño
                      Text(
                        '7 días de garantía de devolución',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: FrutiaColors.secondaryText.withOpacity(0.7),
                        ),
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
