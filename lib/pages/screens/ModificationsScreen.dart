import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class ModificationsScreen extends StatefulWidget {
  const ModificationsScreen({Key? key}) : super(key: key);

  @override
  _ModificationsScreenState createState() => _ModificationsScreenState();
}

class _ModificationsScreenState extends State<ModificationsScreen> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FrutiaColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Modificaciones',
          style: GoogleFonts.lato(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: FrutiaColors.primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajusta tu plan de alimentación y registra tu progreso.',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: FrutiaColors.secondaryText,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 24),
                Card(
                  elevation: 8, // Aumenté la elevación
                  shadowColor: FrutiaColors.accent
                      .withOpacity(0.2), // Color de sombra más personalizado
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          FrutiaColors.accent
                              .withOpacity(0.03), // Sutil gradiente
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FrutiaColors.accent.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: FrutiaColors.accent.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.restaurant_menu,
                                    color: FrutiaColors.accent, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Editar mi Plan',
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800, // Más grueso
                                    color: FrutiaColors.primaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aquí puedes ajustar tus preferencias de alimentación, objetivos, hábitos y más. Esto generará un plan nuevo basado en tus cambios.',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                              height: 1.6, // Mejor interlineado
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildButton(
                            text: 'Editar Plan',
                            color: FrutiaColors.accent,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const QuestionnaireFlow(isEditing: true),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
