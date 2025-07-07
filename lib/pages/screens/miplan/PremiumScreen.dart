import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'annual'; // 'annual' o 'monthly'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo oscuro y elegante
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 66, 65, 65),
                  Color.fromARGB(255, 153, 153, 153)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildFeatureList(),
                    const SizedBox(height: 32),
                    _buildPlanSelection(),
                    const SizedBox(height: 32),
                    _buildCtaButton(),
                    const SizedBox(height: 16),
                    _buildFooterText(),
                  ],
                ),
              ),
            ),
          ),
          // Botón para cerrar
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.workspace_premium_rounded,
                color: FrutiaColors.accent, size: 60)
            .animate()
            .scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          'Eleva tu Experiencia Frutia',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.5, curve: Curves.easeOut),
        const SizedBox(height: 8),
        Text(
          'Desbloquea todas las funciones premium para alcanzar tus metas más rápido.',
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _FeatureListItem(
          icon: Icons.auto_awesome,
          title: 'Planes de Comida Avanzados',
          subtitle: 'Generados por IA y adaptados a ti cada semana.',
          delay: 500.ms,
        ),
        _FeatureListItem(
          icon: Icons.chat_bubble_rounded,
          title: 'Chat con Nutricionistas',
          subtitle: 'Resuelve tus dudas con nuestros expertos certificados.',
          delay: 600.ms,
        ),
        _FeatureListItem(
          icon: Icons.receipt_long_rounded,
          title: 'Recetas Exclusivas',
          subtitle: 'Accede a un recetario premium en constante crecimiento.',
          delay: 700.ms,
        ),
        _FeatureListItem(
          icon: Icons.analytics_rounded,
          title: 'Análisis de Progreso Detallado',
          subtitle: 'Gráficos y estadísticas avanzadas sobre tu evolución.',
          delay: 800.ms,
        ),
      ],
    );
  }

  Widget _buildPlanSelection() {
    return Row(
      children: [
        Expanded(
          child: _PlanOptionCard(
            title: 'Mensual',
            price: '\$9.99',
            period: '/mes',
            isSelected: _selectedPlan == 'monthly',
            onTap: () => setState(() => _selectedPlan = 'monthly'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _PlanOptionCard(
            title: 'Anual',
            price: '\$5.99',
            period: '/mes',
            originalPrice: '\$9.99',
            tag: 'MEJOR VALOR',
            isSelected: _selectedPlan == 'annual',
            onTap: () => setState(() => _selectedPlan = 'annual'),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms);
  }

  Widget _buildCtaButton() {
    return ElevatedButton(
      onPressed: () {
        // Lógica de compra
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 10,
        shadowColor: FrutiaColors.accent.withOpacity(0.5),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [FrutiaColors.accent, FrutiaColors.accent2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          height: 60,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_open_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Actualizar a Premium',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 2, delay: 1000.ms, curve: Curves.elasticOut);
  }

  Widget _buildFooterText() {
    return Text(
      'Cancela en cualquier momento. Tu suscripción se renovará automáticamente.',
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(
        fontSize: 12,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Duration delay;

  const _FeatureListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(icon, color: FrutiaColors.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.lato(
                      fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: -0.5, curve: Curves.easeOut);
  }
}

class _PlanOptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? originalPrice;
  final String? tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanOptionCard({
    required this.title,
    required this.price,
    required this.period,
    this.originalPrice,
    this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? FrutiaColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Text(title,
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                    Text(period,
                        style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14)),
                  ],
                ),
                if (originalPrice != null)
                  Text(
                    originalPrice!,
                    style: GoogleFonts.lato(
                      color: Colors.white.withOpacity(0.6),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            if (tag != null)
              Positioned(
                top: -28,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
