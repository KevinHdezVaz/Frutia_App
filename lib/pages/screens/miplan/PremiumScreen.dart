import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/pages/home_page.dart';
import 'package:Frutia/services/MercadoPagoCheckoutScreen.dart';
import 'package:Frutia/services/PaymentService.dart';
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
  String _selectedPlan = 'annual';
  bool _isLoading = false;
  final PaymentService _paymentService = PaymentService();

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthCheckMain()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _initiatePayment() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 1. Llama a tu backend para obtener la URL de pago (init_point)
      final checkoutUrl = await _paymentService.createPreference(_selectedPlan);

      if (!mounted) return;

      // 2. Navega a la pantalla del WebView y espera un resultado
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MercadoPagoCheckoutScreen(checkoutUrl: checkoutUrl),
        ),
      );

      // 3. Maneja el resultado devuelto por la pantalla del WebView
      if (result == 'success') {
        _showPaymentSuccessDialog();
      } else if (result == 'failure') {
        _showPaymentMessage(
            'El pago fue rechazado. Por favor, intenta de nuevo.', Colors.red);
      } else if (result == 'pending') {
        _showPaymentMessage(
            'Tu pago está pendiente de aprobación.', Colors.orange);
      } else {
        // El usuario cerró la pantalla de pago sin completar
        _showPaymentMessage('El proceso de pago fue cancelado.', Colors.grey);
      }
    } catch (e) {
      if (mounted) {
        _showPaymentMessage('Error: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPaymentMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Pago Exitoso!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                '¡Felicidades! Tu suscripción Premium ha sido activada.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              const Text(
                'La app se reiniciará para aplicar los cambios.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _navigateToHome,
                  child: const Text(
                    'GENIAL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... El resto de tu widget build y los métodos _build... se quedan exactamente igual que antes.
    // No es necesario volver a pegarlos todos aquí. Solo asegúrate de que el onPressed del
    // botón de pago llame a la nueva función _initiatePayment.
    return WillPopScope(
      onWillPop: () async {
        _navigateToHome();
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/fondoPantalla1.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
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
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: _navigateToHome,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: FrutiaColors.accent, // Color del borde circular
              width: 2.0, // Grosor del borde
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/fondoAppFrutia.webp',
              width: 56, // Un poco menos para compensar el borde
              height: 56,
              fit: BoxFit.cover, // Para que la imagen llene el círculo
            ),
          ),
        )
            .animate()
            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        // ... (el resto de tu código permanece igual)
        Text(
          'Eleva tu Experiencia Frutia',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2.0, 2.0),
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CON FRUTIA PREMIUM OBTIENES:',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          _FeatureListItem(
            icon: Icons.auto_awesome,
            title: 'Planes de Comida Avanzados',
            subtitle: 'Generados por IA y adaptados 100% a ti.',
            delay: 500.ms,
          ),
          _FeatureListItem(
            icon: Icons.chat_bubble_rounded,
            title: 'Chat ilimitado con FRUTIA',
            subtitle: 'Resuelve tus dudas nutricionales al instante.',
            delay: 600.ms,
          ),
          _FeatureListItem(
            icon: Icons.shopping_cart_checkout_rounded,
            title: 'Lista de Compras Automática',
            subtitle: 'Genera tu lista de súper con un solo toque.',
            delay: 700.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelection() {
    return Row(
      children: [
        Expanded(
          child: _PlanOptionCard(
            title: 'Mensual',
            price: '\$10.99',
            period: '/mes',
            isSelected: _selectedPlan == 'monthly',
            onTap: () => setState(() => _selectedPlan = 'monthly'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _PlanOptionCard(
            title: 'Anual',
            price: '\$7.99',
            period: '/mes',
            originalPrice: '\$131.88',
            tag: 'AHORRA 27%',
            isSelected: _selectedPlan == 'annual',
            onTap: () => setState(() => _selectedPlan = 'annual'),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms);
  }

  Widget _buildCtaButton() {
    return ElevatedButton(
      onPressed: _initiatePayment,
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
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(
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
        padding:
            const EdgeInsets.fromLTRB(12, 20, 12, 12), // Reducido el padding
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.black.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? FrutiaColors.accent
                : Colors.white.withOpacity(0.2),
            width: 2.5,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16, // Reducido de 18 a 16
                    fontWeight: FontWeight.bold,
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Evita desbordamiento del texto
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        price,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      period,
                      style: GoogleFonts.lato(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
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
                top: -40,
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
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
