import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/onscreen/QuestionnairePage.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum PageState { loading, error, needsOnboarding, needsPlan, hasPlan }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  PageState _pageState = PageState.loading;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndCheckProfile();
    });
  }

  Future<void> _fetchAndCheckProfile() async {
    if (mounted) setState(() => _pageState = PageState.loading);

    try {
      final userData = await _authService.getProfile();
      if (!mounted) return;

      final profile = userData['profile'];

      if (profile == null || profile['height'] == null) {
        setState(() {
          _userData = userData;
          _pageState = PageState.needsOnboarding;
        });
        _showPersonalDataModal();
      } else if (profile['plan_setup_complete'] != true &&
          profile['plan_setup_complete'] != 1) {
        setState(() {
          _userData = userData;
          _pageState = PageState.needsPlan;
        });
      } else {
        setState(() {
          _userData = userData;
          _pageState = PageState.hasPlan;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _pageState = PageState.error);
    }
  }

  void _showPersonalDataModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PersonalDataPage(
          onSuccess: () {
            Navigator.of(dialogContext).pop();
            _fetchAndCheckProfile();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildUIForState(),
      ),
    );
  }

  Widget _buildUIForState() {
    switch (_pageState) {
      case PageState.loading:
      case PageState.needsOnboarding:
        return const Center(
            key: ValueKey('loader'),
            child: CircularProgressIndicator(color: FrutiaColors.accent));
      case PageState.error:
        return _buildErrorUI(key: const ValueKey('error'));
      case PageState.needsPlan:
      case PageState.hasPlan:
        return _DashboardView(
            key: const ValueKey('dashboard'), userData: _userData!);
    }
  }

  Widget _buildErrorUI({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off,
              size: 60, color: FrutiaColors.secondaryText),
          const SizedBox(height: 16),
          const Text('No se pudieron cargar tus datos.'),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _fetchAndCheckProfile,
              child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final Map<String, dynamic> userData;
  const _DashboardView({super.key, required this.userData});
  @override
  Widget build(BuildContext context) {
    final String userName = userData['name'] ?? 'Usuario';
    final profileData = userData['profile'];
    final bool hasPlan = profileData != null &&
        (profileData['plan_setup_complete'] == true ||
            profileData['plan_setup_complete'] == 1);
    final String currentWeight = profileData?['weight']?.toString() ?? '--';
    final String mainGoal = profileData?['goal'] ?? 'No definido';
    const int streakDays = 5; // Este dato aún es simulado

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Perfil',
                      style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText)),
                  IconButton(
                      icon: const Icon(Icons.settings,
                          color: FrutiaColors.primaryText),
                      onPressed: () {}),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: FrutiaColors.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                      radius: 40,
                      backgroundColor: FrutiaColors.accent,
                      child: Icon(Icons.person, color: Colors.white, size: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¡Hola, $userName!',
                            style: GoogleFonts.lato(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Racha: $streakDays días',
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText)),
                        Text('Peso actual: $currentWeight kg',
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText)),
                        Text('Objetivo: $mainGoal',
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText)),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.edit, color: FrutiaColors.accent),
                      onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                hasPlan ? 'Tu plan actual' : 'Crea tu plan',
                style:
                    GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: hasPlan
                  ? _buildPlanSection(userData['active_plan'])
                  : _buildCreatePlanCard(context),
            ),
            const SizedBox(height: 24),
            _buildAchievementsSection(),
            const SizedBox(height: 24),
          ],
        ).animate().fadeIn(duration: 800.ms),
      ),
    );
  }

  Widget _buildCreatePlanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: FrutiaColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('¡No tienes un plan activo!',
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(
              'Crea un plan personalizado para alcanzar tus metas de manera efectiva.',
              style: GoogleFonts.lato(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuestionnaireFlow()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FrutiaColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Crea tu plan ahora',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSection(Map<String, dynamic>? plan) {
    final planData = plan?['plan_data'];
    if (planData == null) {
      return const Card(child: ListTile(title: Text('Cargando plan...')));
    }

    final desayuno = (planData['desayuno'] as List?)
            ?.map((e) => e['opcion'] as String)
            .join(' / ') ??
        'No definido';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Text("Plan del día: $desayuno"),
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tus logros',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildAchievementCard('Racha de 5 días',
                  Icons.local_fire_department, Colors.orange),
              _buildAchievementCard(
                  'Primera semana', Icons.check_circle, Colors.green),
              _buildAchievementCard('Explorador', Icons.explore, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
