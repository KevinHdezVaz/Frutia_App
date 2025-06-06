import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class SummaryScreen extends StatelessWidget {
  final int age;
  final String sex;
  final double weight;
  final bool hasConditions;
  final String conditions;
  final bool isSmoker;
  final bool isPregnant;
  final bool hasAllergies;
  final String allergies;
  final String dietStyle;
  final bool cooksForSelf;
  final bool eatsOutOften;
  final String budget;

  const SummaryScreen({
    Key? key,
    required this.age,
    required this.sex,
    required this.weight,
    required this.hasConditions,
    required this.conditions,
    required this.isSmoker,
    required this.isPregnant,
    required this.hasAllergies,
    required this.allergies,
    required this.dietStyle,
    required this.cooksForSelf,
    required this.eatsOutOften,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '¿Listo para un plan hecho solo para ti?',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD1B3), Color(0xFFFF6F61)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisa tu información y envíala para tu plan',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: FrutiaColors.secondaryText,
                  ),
                ).animate().fadeIn(duration: 800.ms),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
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
                          'Resumen',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Edad: $age años', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Sexo: $sex', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Peso: $weight kg', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        if (hasConditions) Text('Condiciones: $conditions', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Fumas: ${isSmoker ? 'Sí' : 'No'}', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Embarazada: ${isPregnant ? 'Sí' : 'No'}', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        if (hasAllergies) Text('Alergias: $allergies', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Estilo de dieta: $dietStyle', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Cocina por sí mismo: ${cooksForSelf ? 'Sí' : 'No'}', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Come fuera a menudo: ${eatsOutOften ? 'Sí' : 'No'}', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        Text('Presupuesto: $budget', style: GoogleFonts.lato(color: FrutiaColors.secondaryText)),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '¡Datos enviados a la IA para generar tu dieta!',
                                    style: GoogleFonts.lato(color: Colors.white),
                                  ),
                                  backgroundColor: FrutiaColors.accent,
                                ),
                              );
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FrutiaColors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Cuestionario finalizado',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryBackground,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Toca aquí para continuar',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: FrutiaColors.primaryBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 800.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}