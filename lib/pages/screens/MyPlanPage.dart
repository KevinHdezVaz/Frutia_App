import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class MyPlanPage extends StatelessWidget {
  const MyPlanPage({super.key});

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
                // Encabezado
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Mi Plan',
                    style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideX(
                      begin: -0.2,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut),
                ),
                const SizedBox(height: 16),

                // Sección Desayuno
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: FrutiaColors.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.free_breakfast,
                            color: FrutiaColors.accent,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Desayuno',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Avena con frutas y nueces (300 kcal)',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: FrutiaColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(
                    begin: 0.3,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 16),

                // Sección Comida
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: FrutiaColors.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lunch_dining,
                            color: FrutiaColors.accent,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comida',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pechuga a la plancha con ensalada (500 kcal)',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: FrutiaColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(
                    begin: 0.3,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 16),

                // Sección Cena
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: FrutiaColors.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.dinner_dining,
                            color: FrutiaColors.accent,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cena',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Salmón con verduras al vapor (400 kcal)',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: FrutiaColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(
                    begin: 0.3,
                    end: 0.0,
                    duration: 800.ms,
                    curve: Curves.easeOut),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
