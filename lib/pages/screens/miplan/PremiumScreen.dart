import 'dart:convert';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/services/MercadoPagoCheckoutScreen.dart';
import 'package:Frutia/services/PaymentService.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:Frutia/utils/constantes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'annual';
  bool _isLoading = false;
  final PaymentService _paymentService = PaymentService();

  final _affiliateCodeController = TextEditingController();
  bool _isCodeValidating = false;
  double? _discountPercentage;
  String? _validatedCode;
  String _codeMessage = '';
  Color _messageColor = Colors.red;

  bool _isLoadingPrices = true;
  Map<String, double> _fetchedPrices = {
    'monthly': 9.99,
    'annual': 69.99,
  };

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _loadAffiliateCodeFromProfile();
  }

  @override
  void dispose() {
    _affiliateCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchPlans() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/plans'));

      if (mounted && response.statusCode == 200) {
        final List<dynamic> plans = jsonDecode(response.body);
        final Map<String, double> prices = {};

        for (var plan in plans) {
          prices[plan['plan_id']] =
              double.tryParse(plan['price'].toString()) ?? 0.0;
        }

        setState(() {
          _fetchedPrices = prices;
          _isLoadingPrices = false;
        });
      } else {
        setState(() {
          _isLoadingPrices = false;
        });
      }
    } catch (e) {
      print("Error al obtener los planes: $e");
      if (mounted) {
        setState(() {
          _isLoadingPrices = false;
        });
      }
    }
  }

  Future<void> _loadAffiliateCodeFromProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (mounted && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final String? affiliateCode = user['applied_affiliate_code'];

        if (affiliateCode != null && affiliateCode.isNotEmpty) {
          _affiliateCodeController.text = affiliateCode;
          await _validateAffiliateCode();
        }
      }
    } catch (e) {
      print("Error al cargar el perfil para el código de afiliado: $e");
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthCheckMain()),
        (Route<dynamic> route) => false,
      );
    }
  }

  String? _getDiscountTag() {
    if (_discountPercentage != null) {
      // Si hay un descuento, muestra la etiqueta
      return 'AHORRA ${_discountPercentage!.toStringAsFixed(0)}%';
    }
    // Si no hay descuento, no devuelve nada (la etiqueta no se mostrará)
    return null;
  }

  Map<String, String?> _getPlanPrice(String planKey, double originalPrice) {
    double finalPrice = originalPrice;
    String? originalPriceStr;

    if (_discountPercentage != null) {
      final discountAmount = (originalPrice * _discountPercentage!) / 100;
      finalPrice = originalPrice - discountAmount;
      originalPriceStr = '\$${originalPrice.toStringAsFixed(2)}';
    }

    // Lógica simplificada: ya no se divide entre 12
    String priceStr = '\$${finalPrice.toStringAsFixed(2)}';

    return {
      'price': priceStr,
      'originalPrice': originalPriceStr,
    };
  }

  Future<void> _validateAffiliateCode() async {
    final code = _affiliateCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isCodeValidating = true;
      _codeMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/affiliates/validate-code'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code}),
      );

      final data = jsonDecode(response.body);

      if (mounted && response.statusCode == 200 && data['valid'] == true) {
        setState(() {
          _discountPercentage =
              double.tryParse(data['discount_percentage'].toString());
          _validatedCode = code;
          _codeMessage =
              '¡Código aplicado! Tienes un ${_discountPercentage?.toStringAsFixed(0)}% de descuento.';
          _messageColor = Colors.green;
        });
      } else {
        setState(() {
          _discountPercentage = null;
          _validatedCode = null;
          _codeMessage = data['message'] ?? 'El código no es válido.';
          _messageColor = Colors.redAccent;
        });
      }
    } catch (e) {
      setState(() {
        _discountPercentage = null;
        _validatedCode = null;
        _codeMessage = 'Error al validar el código. Intenta de nuevo.';
        _messageColor = Colors.redAccent;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCodeValidating = false;
        });
      }
    }
  }

  Future<void> _initiatePayment() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final checkoutUrl = await _paymentService.createPreference(
        _selectedPlan,
        affiliateCode: _validatedCode,
      );

      if (!mounted) return;

      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MercadoPagoCheckoutScreen(checkoutUrl: checkoutUrl),
        ),
      );

      if (result == 'success') {
        _showPaymentSuccessDialog();
      } else if (result == 'failure') {
        _showPaymentMessage(
            'El pago fue rechazado. Por favor, intenta de nuevo.', Colors.red);
      } else if (result == 'pending') {
        _showPaymentMessage(
            'Tu pago está pendiente de aprobación.', Colors.orange);
      } else {
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showPaymentSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text('¡Pago Exitoso!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const SizedBox(height: 15),
              const Text(
                  '¡Felicidades! Tu suscripción Premium ha sido activada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 5),
              const Text('La app se reiniciará para aplicar los cambios.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _navigateToHome,
                  child: const Text('GENIAL',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
                      Colors.black.withOpacity(0.1), BlendMode.darken),
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
                      _buildAffiliateCodeInput(),
                      const SizedBox(height: 24),
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

  Widget _buildAffiliateCodeInput() {
    IconData statusIcon = Icons.star_border_rounded;
    Color iconColor = FrutiaColors.secondaryText;

    if (_validatedCode != null) {
      statusIcon = Icons.check_circle_outline_rounded;
      iconColor = Colors.green;
    } else if (_codeMessage.isNotEmpty && _validatedCode == null) {
      statusIcon = Icons.error_outline_rounded;
      iconColor = Colors.red;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _affiliateCodeController,
                style: const TextStyle(
                    color: FrutiaColors.primaryText,
                    fontWeight: FontWeight.bold),
                cursorColor: FrutiaColors.accent,
                decoration: InputDecoration(
                  prefixIcon: Icon(statusIcon, color: iconColor),
                  labelText: '¿Tienes un código de descuento?',
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 142, 140, 140), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: FrutiaColors.accent, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isCodeValidating ? null : _validateAffiliateCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                minimumSize: const Size(60, 60),
              ),
              child: _isCodeValidating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white),
            ),
          ],
        ),
        if (_codeMessage.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              _codeMessage,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: _messageColor, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    ).animate().fadeIn(delay: 950.ms);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: FrutiaColors.accent,
              width: 2.0,
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
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
        )
            .animate()
            .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
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
    if (_isLoadingPrices) {
      return const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent));
    }

    final monthlyPriceDetails =
        _getPlanPrice('monthly', _fetchedPrices['monthly']!);
    final annualPriceDetails =
        _getPlanPrice('annual', _fetchedPrices['annual']!);
    final String? discountTag =
        _getDiscountTag(); // Obtenemos la etiqueta de descuento

    return Row(
      children: [
        Expanded(
          child: _PlanOptionCard(
            title: 'Mensual',
            price: monthlyPriceDetails['price'] ?? '',
            period: '/mes', // El periodo del plan mensual sigue siendo por mes
            originalPrice: monthlyPriceDetails['originalPrice'],
            tag: discountTag, // La etiqueta de descuento se muestra si existe
            isSelected: _selectedPlan == 'monthly',
            onTap: () => setState(() => _selectedPlan = 'monthly'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _PlanOptionCard(
            title: 'Anual',
            price: annualPriceDetails['price'] ?? '',
            period: '/año', // CAMBIO: El periodo ahora es por año
            originalPrice: annualPriceDetails['originalPrice'],
            tag: discountTag, // La etiqueta de descuento se muestra si existe
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
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Sección del precio en dos filas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Fila 1: El Precio
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Fila 2: La Moneda y el Periodo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'USD',
                          style: GoogleFonts.lato(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                    )
                  ],
                ),

                if (originalPrice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      originalPrice!,
                      style: GoogleFonts.lato(
                        color: Colors.white.withOpacity(0.6),
                        decoration: TextDecoration.lineThrough,
                      ),
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
