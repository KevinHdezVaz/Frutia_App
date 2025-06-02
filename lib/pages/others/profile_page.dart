import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_auth_crudd10/auth/auth_check.dart';
import 'package:user_auth_crudd10/auth/auth_service.dart';
import 'package:user_auth_crudd10/pages/InvitationsScreen.dart';
import 'package:user_auth_crudd10/pages/VerifyProfilePage.dart';
import 'package:user_auth_crudd10/pages/WalletScreen.dart';
import 'package:user_auth_crudd10/pages/others/StatsTab.dart';
import 'package:user_auth_crudd10/pages/screens/Equipos/NotificationHistoryScreen.dart';
import 'package:user_auth_crudd10/pages/screens/Equipos/detalle_equipo.screen.dart';
import 'package:user_auth_crudd10/pages/screens/Equipos/lista_equipos_screen.dart';
import 'package:user_auth_crudd10/pages/screens/UpdateProfileScreen.dart';
import 'package:user_auth_crudd10/pages/screens/bookin/booking_screen.dart';
import 'package:user_auth_crudd10/services/equipo_service.dart';
import 'package:user_auth_crudd10/utils/colors.dart'; // Import FrutiaColors

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  Map<String, dynamic>? userData;
  final _equipoService = EquipoService();
  bool _isLoadingEquipos = false;
  int _invitacionesPendientes = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _authService.getProfile();
      setState(() => userData = response);
    } catch (e) {
      print('Error cargando perfil: $e');
    }
  }

  Future<void> _logout() async {
    try {
      showDialog(
          context: context,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()));
      await _authService.logout();
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthCheckMain()),
          (route) => false);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Error cerrando sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: FrutiaColors.primaryBackground,
        body: userData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  ProfilePic(userData: userData),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              FrutiaColors.accent.withOpacity(0.7),
                              FrutiaColors.secondaryText.withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: Colors.white, size: 24),
                                  const SizedBox(width: 20),
                                  Text(
                                    userData!['name'] ?? '',
                                    style: GoogleFonts.inter(
                                      color: FrutiaColors.primaryBackground,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (userData!['is_verified'] == true)
                                    const SizedBox(width: 8),
                                  if (userData!['is_verified'] == true)
                                    const Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.email,
                                      color: Colors.white, size: 24),
                                  const SizedBox(width: 20),
                                  Text(
                                    userData!['email'] ?? '',
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: userData!['is_verified'] == true
                                    ? SizedBox.shrink()
                                    : ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VerifyProfilePage(),
                                            ),
                                          ).then((_) {
                                            _loadUserProfile();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: FrutiaColors.accent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 17, vertical: 12),
                                        ),
                                        child: Text(
                                          'Verificar Perfil',
                                          style: GoogleFonts.inter(
                                            color:
                                                FrutiaColors.primaryBackground,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    tabs: [
                      Tab(
                          child: Text('PROGRESO',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: FrutiaColors.accent))),
                      Tab(
                          child: Text('OPCIONES',
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: FrutiaColors.accent))),
                    ],
                    indicatorColor: FrutiaColors.accent,
                    labelColor: FrutiaColors.accent,
                    unselectedLabelColor: FrutiaColors.secondaryText,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // OPCIONES Tab: Calorie Chart, Weight Goal, Daily Streak
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Calorie Burn Chart
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: FrutiaColors.secondaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FrutiaColors.shadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Calorías Quemadas',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: FrutiaColors.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 150,
                                      child: CustomPaint(
                                        painter: CalorieChartPainter(),
                                        child: Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Weight Goal
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: FrutiaColors.secondaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FrutiaColors.shadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Peso Meta',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: FrutiaColors.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Meta: 70 kg (Progreso: 65 kg)',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: FrutiaColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: 0.65, // 65% progress
                                      backgroundColor:
                                          FrutiaColors.secondaryText,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          FrutiaColors.success),
                                      minHeight: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Daily Streak
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: FrutiaColors.secondaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FrutiaColors.shadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Racha Diaria',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: FrutiaColors.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Image.asset(
                                      'assets/images/daily_streak.png', // Placeholder image
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ESTADÍSTICAS Tab: Menu Items
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                icon: Icons.person,
                                title: 'Editar Perfil',
                                subtitle: 'Datos de usuario',
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateProfileScreen())),
                              ),
                              _buildMenuItem(
                                icon: Icons.notifications,
                                title: 'Invitaciones',
                                subtitle: 'Ver invitaciones',
                                count: _invitacionesPendientes,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            InvitationsScreen())),
                              ),
                              _buildMenuItem(
                                icon: Icons.monetization_on,
                                title: 'Monedero',
                                subtitle: 'Ver mi Monedero',
                                count: _invitacionesPendientes,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WalletScreen())),
                              ),
                              _buildMenuItem(
                                icon: Icons.exit_to_app,
                                title: 'Cerrar sesión',
                                subtitle: 'Salir',
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int count = 0,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: FrutiaColors.primaryBackground,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: FrutiaColors.secondaryText.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1))
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: FrutiaColors.accent),
            if (count > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: FrutiaColors.accent, shape: BoxShape.circle),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(count.toString(),
                        style: TextStyle(
                            color: FrutiaColors.primaryBackground,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
      title: Text(title,
          style: GoogleFonts.inter(
              color: FrutiaColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: GoogleFonts.inter(
              fontSize: 14, color: FrutiaColors.secondaryText)),
      trailing: const Icon(Icons.chevron_right, color: FrutiaColors.accent),
      onTap: onTap,
    );
  }
}

// Custom Painter for Calorie Chart (Simple Bar Chart)
class CalorieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FrutiaColors.success
      ..style = PaintingStyle.fill;

    final List<double> data = [
      200,
      350,
      150,
      400
    ]; // Sample calorie data (daily)
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / data.length * 0.6;
    final spacing = size.width / data.length * 0.4;

    for (var i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * (size.height - 20);
      final left = i * (barWidth + spacing);
      final rect =
          Rect.fromLTWH(left, size.height - barHeight, barWidth, barHeight);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfilePic extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const ProfilePic({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? imageUrl = userData != null && userData!['profile_image'] != null
        ? 'https://proyect.aftconta.mx/storage/${userData!['profile_image']}'
        : null;
    return SafeArea(
      child: SizedBox(
        height: 115,
        width: 115,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl)
                  : const AssetImage('assets/icons/jugadore.png')
                      as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) =>
                  print('Error loading image: $exception'),
            ),
          ],
        ),
      ),
    );
  }
}
