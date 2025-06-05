import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD1B3), // Naranja suave
              Color(0xFFFF6F61), // Rojo cálido
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Imagen de Frutia
                Center(
                  child: Image.asset(
                    'assets/images/fruta22.png', // Placeholder para la imagen de Frutia
                    height: 200,
                    fit: BoxFit.contain,
                  ).animate().fadeIn(duration: 300.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 300.ms,
                      curve: Curves.easeOut),
                ),
                const SizedBox(height: 24),

                // Contenedor de texto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: FrutiaColors.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nosotros',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.primaryText,
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
                          const SizedBox(height: 16),
                          Text(
                            'Creamos esta app con una idea clara: la nutrición no debería sentirse como una carga, ni depender de planes genéricos que no se adaptan a tu vida. Por eso combinamos ciencia, tecnología e inteligencia artificial para ofrecerte un acompañamiento real, sin fórmulas mágicas, sin promesas vacías, y sin complicarte el día a día.',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                            ),
                          ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                          const SizedBox(height: 16),
                          Text(
                            'Cada cuerpo es distinto, y creemos que tu alimentación debe respetarlo. Por eso, nuestro sistema se adapta a tus metas, tus gustos, tu rutina y hasta tu presupuesto. No importa si entrenas en el gimnasio, juegas fútbol los domingos o simplemente quieres comer mejor sin gastar de más: tu plan es tuyo y evoluciona contigo.',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                            ),
                          ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
                          const SizedBox(height: 16),
                          Text(
                            'Nos mueve la idea de que la tecnología puede humanizarse. Por eso nuestra IA, Frutia, no es solo un robot que te lanza datos. Puedes decidir cómo quieres que te trate: motivadora, relajada o directa. Como si tuvieras un nutricionista virtual que sí te entiende.',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                            ),
                          ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
                          const SizedBox(height: 16),
                          Text(
                            'Somos un equipo de nutricionistas, desarrolladores, diseñadores y soñadores, comprometidos con una nutrición accesible, realista y personalizada. Y lo más importante: hecha para durar.',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                            ),
                          ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
