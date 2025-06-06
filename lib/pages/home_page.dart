import 'package:Frutia/pages/screens/createplan/CreatePlanScreen.dart';
import 'package:Frutia/pages/screens/datosPersonales/PersonalDataScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class HomePage extends StatelessWidget {
  // Datos del usuario (simulados)
  final String userName = 'John';
  final int streakDays = 5;
  final double currentWeight = 70.0;
  final String mainGoal = 'Pérdida de peso';
  final bool hasPlan = false; // Cambiar a true para simular un plan existente

  // Datos del plan actual (simulados, solo si hasPlan es true)
  final Map<String, dynamic> currentPlan = {
    'goal': 'Pérdida de peso',
    'dailyCalories': 2000,
    'dietPreferences': ['Sin gluten', 'Sin lácteos'],
  };

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar personalizado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Perfil',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings, color: FrutiaColors.primaryText),
                        onPressed: () {
                          // Navegar a pantalla de configuración
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms),

                // Sección de Perfil
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: FrutiaColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: FrutiaColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: FrutiaColors.accent,
                        child: Icon(
                          Icons.person,
                          color: FrutiaColors.primaryBackground,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola, $userName!',
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Racha: $streakDays días',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            Text(
                              'Peso actual: $currentWeight kg',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            Text(
                              'Objetivo: $mainGoal',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: FrutiaColors.accent),
                        onPressed: () {
                          // Navegar a pantalla de edición de perfil
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24),

                // Sección de Plan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    hasPlan ? 'Tu plan actual' : 'Crea tu plan',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideX(
                      begin: -0.2,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 8),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: FrutiaColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: FrutiaColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: hasPlan
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Objetivo: ${currentPlan['goal']}',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Calorías diarias: ${currentPlan['dailyCalories']} kcal',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Preferencias: ${currentPlan['dietPreferences'].join(', ')}',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CreatePlanScreen()),
  );
},
                                  child: Text(
                                    'Editar plan',
                                    style: GoogleFonts.lato(
                                      color: FrutiaColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                 onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CreatePlanScreen()),
  );
},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: FrutiaColors.accent,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Crear nuevo plan',
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: FrutiaColors.primaryBackground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡No tienes un plan activo!',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crea un plan personalizado para alcanzar tus metas de manera efectiva.',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                           onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PersonalDataScreen()),
  );
},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FrutiaColors.accent,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Crea tu plan ahora',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: FrutiaColors.primaryBackground,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: FrutiaColors.primaryBackground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideX(
                      begin: -0.2,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24),

                // Sección de Logros
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Tus logros',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideX(
                      begin: -0.2,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 8),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildAchievementCard('Racha de 5 días', Icons.local_fire_department),
                      _buildAchievementCard('Primera semana', Icons.check_circle),
                      _buildAchievementCard('Explorador', Icons.explore),
                    ],
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).slideX(
                      begin: -0.2,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: FrutiaColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: FrutiaColors.accent,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: FrutiaColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}