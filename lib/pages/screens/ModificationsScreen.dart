import 'package:Frutia/pages/screens/ModificationScreenProfile.dart';
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
                // --- Tarjeta para Editar Plan ---
                _buildInfoCard(
                  icon: Icons.restaurant_menu,
                  title: 'Editar mi Plan',
                  description:
                      'Aquí puedes ajustar tus preferencias de alimentación, objetivos, hábitos y más. Esto generará un plan nuevo basado en tus cambios.',
                  buttonText: 'Editar Plan',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const QuestionnaireFlow(isEditing: true),
                      ),
                    );
                  },
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24), // Espacio entre las tarjetas

                // --- NUEVA Tarjeta para Actualizar Perfil ---
                _buildInfoCard(
                  icon: Icons.trending_up, // Icono relevante para progreso
                  title: 'Actualizar Perfil',
                  description:
                      'Aquí puedes actualizar tu peso corporal y medir tu % de grasa. Esto ayudará a medir tu progreso.',
                  buttonText: 'Actualizar Perfil',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateProfileScreen()),
                    );
                  },
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(
                      // Añadí un pequeño delay para efecto escalonado
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // He movido la lógica de la tarjeta a su propio método para evitar duplicar código
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 8,
      shadowColor: FrutiaColors.accent.withOpacity(0.2),
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
              FrutiaColors.accent.withOpacity(0.03), // Sutil gradiente
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
                    child: Icon(icon, color: FrutiaColors.accent, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: FrutiaColors.primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              _buildButton(
                text: buttonText,
                color: FrutiaColors.accent,
                textColor: Colors.white,
                onPressed: onPressed,
              ),
            ],
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
        minimumSize: const Size(double.infinity, 56), // Ocupa todo el ancho
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
