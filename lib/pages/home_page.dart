import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/onscreen/QuestionnairePage.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanPage.dart';
import 'package:Frutia/utils/PlanCarousel.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

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
    if (!mounted) return;
    setState(() => _pageState = PageState.loading);

    try {
      final userData = await _authService.getProfile();
      if (!mounted) return;

      final profile = userData['profile'];

      if (profile == null || profile['height'] == null) {
        setState(() {
          _userData = userData;
          _pageState = PageState.needsOnboarding;
        });
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
      if (mounted) {
        setState(() {
          _pageState = PageState.error;
          _userData = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _buildUIForState(),
      ),
    );
  }

  Widget _buildUIForState() {
    switch (_pageState) {
      case PageState.loading:
        return const Center(
            key: ValueKey('loader'),
            child: CircularProgressIndicator(color: FrutiaColors.accent));
      case PageState.needsOnboarding:
        return _buildNeedsInfoUI(
          key: const ValueKey('onboarding'),
          title: "¡Bienvenido a Frutia!",
          subtitle:
              "Necesitamos algunos datos básicos para poder continuar y crear un perfil para ti.",
          buttonText: "Completar mis datos",
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PersonalDataPage(onSuccess: _fetchAndCheckProfile)));
          },
        );
      case PageState.needsPlan:
        return _DashboardView(
            key: const ValueKey('dashboard'), userData: _userData!);
      case PageState.error:
        return _buildErrorUI(key: const ValueKey('error'));
      case PageState.hasPlan:
        return _DashboardView(
            key: const ValueKey('dashboard'), userData: _userData!);
    }
  }

  Widget _buildNeedsInfoUI({
    required Key key,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search,
                size: 80, color: FrutiaColors.accent.withOpacity(0.7)),
            const SizedBox(height: 24),
            Text(title,
                style:
                    GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(subtitle,
                style: GoogleFonts.lato(
                    fontSize: 16, color: FrutiaColors.secondaryText),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                  backgroundColor: FrutiaColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400));
  }

  Widget _buildErrorUI({Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 80, color: Colors.red.withOpacity(0.7)),
            const SizedBox(height: 24),
            Text(
              '¡Algo salió mal!',
              style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar tu perfil. Por favor, intenta de nuevo.',
              style: GoogleFonts.lato(
                  fontSize: 16, color: FrutiaColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchAndCheckProfile,
              style: ElevatedButton.styleFrom(
                  backgroundColor: FrutiaColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400));
  }
}

class _DashboardView extends StatelessWidget {
  final Map<String, dynamic> userData;
  const _DashboardView({super.key, required this.userData});

  String _getUpcomingMeal() {
    final hour = DateTime.now().hour;

    if (hour < 10) {
      return 'Desayuno';
    } else if (hour < 14) {
      return 'Almuerzo';
    } else if (hour < 20) {
      return 'Cena';
    } else {
      return 'Desayuno';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName = userData['name'] ?? 'Usuario';
    final profileData = userData['profile'];
    final bool hasPlan = profileData != null &&
        (profileData['plan_setup_complete'] == true ||
            profileData['plan_setup_complete'] == 1);
    final String currentWeight = profileData?['weight']?.toString() ?? '--';
    final String mainGoal = profileData?['goal'] ?? 'No definido';
    const int streakDays = 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(userName, context),
          const SizedBox(height: 16),
          _buildWeekCalendar(),
          const SizedBox(height: 24),
          _buildStatsRow(streakDays, currentWeight, mainGoal),
          const SizedBox(height: 24),
          _buildUpcomingMealCard(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(hasPlan ? 'Tu plan de hoy' : 'Crea tu plan',
                style: GoogleFonts.lato(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: hasPlan ? const PlanCarousel() : _buildCreatePlanCard(context),
          ),
          if (hasPlan) ...[
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 40),
          MembershipStatusWidget(
            isPremium: false,
            onUpgradePressed: () {},
          ),
          const SizedBox(height: 40),
          _buildAchievementsSection(),
          const SizedBox(height: 24),
        ],
      ).animate().fadeIn(
          delay: const Duration(milliseconds: 400), duration: 500.ms),
    );
  }

  Widget _buildProfileHeader(String userName, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 30,
              backgroundColor: FrutiaColors.accent,
              child: Icon(Icons.person, color: Colors.white, size: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡Hola de nuevo,',
                    style: GoogleFonts.lato(
                        fontSize: 16, color: FrutiaColors.secondaryText)),
                Text(userName,
                    style: GoogleFonts.lato(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: FrutiaColors.secondaryText),
            onPressed: () {},
          ),
        ],
      ),
    ).animate().fadeIn(
        delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildStatsRow(int streakDays, String currentWeight, String mainGoal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streakDays días',
                  label: 'Racha',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.monitor_weight_rounded,
                  value: '$currentWeight kg',
                  label: 'Peso actual',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.flag_rounded,
                  value: mainGoal,
                  label: 'Objetivo',
                  color: Colors.green,
                ),
              ),
              const Expanded(child: SizedBox(width: 12)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
        delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildWeekCalendar() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final Map<int, bool> complianceData = {
      1: true,
      2: true,
      3: false,
      4: true,
      5: true
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Tu semana',
              style:
                  GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final day = startOfWeek.add(Duration(days: index));
              final isToday = day.day == today.day && day.month == today.month;
              final didComply = complianceData[day.weekday] ?? false;

              return Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isToday
                      ? FrutiaColors.accent
                      : FrutiaColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('E', 'es_ES').format(day),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? Colors.white
                                : FrutiaColors.secondaryText)),
                    const SizedBox(height: 4),
                    Text(day.day.toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? Colors.white
                                : FrutiaColors.primaryText)),
                    if (didComply) ...[
                      const SizedBox(height: 4),
                      Icon(Icons.check_circle,
                          size: 16,
                          color: isToday ? Colors.white : Colors.green),
                    ]
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    ).animate().slideX(
        begin: 0.2,
        delay: const Duration(milliseconds: 400),
        duration: 400.ms,
        curve: Curves.easeOut);
  }

  Widget _buildUpcomingMealCard() {
    final upcomingMeal = _getUpcomingMeal();
    final now = DateTime.now();
    final hour = now.hour;

    String message;
    if (hour >= 0 && hour < 5) {
      message = "Hora de dormir";
    } else if (hour < 10) {
      message = "Tu desayuno está por comenzar";
    } else if (hour < 12) {
      message = "Pronto será hora de almorzar";
    } else if (hour < 14) {
      message = "¡Es hora de almorzar!";
    } else if (hour < 17) {
      message = "Tu cena se acerca";
    } else if (hour < 20) {
      message = "¡Es hora de cenar!";
    } else {
      message = "Tu próxima comida será el desayuno";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FrutiaColors.progress.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FrutiaColors.progress.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FrutiaColors.progress.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_menu_rounded,
                color: FrutiaColors.progress, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: FrutiaColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Próxima comida: ${upcomingMeal.toLowerCase()}',
                  style: GoogleFonts.lato(
                    color: FrutiaColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
        delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildMealCard(String title, List<dynamic>? options) {
    if (options == null || options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.accent)),
          const SizedBox(height: 8),
          ...options.map((e) {
            final optionName = e['opcion'] as String? ?? 'Opción no definida';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right_rounded,
                      size: 20, color: FrutiaColors.secondaryText),
                  Expanded(
                      child: Text(optionName,
                          style: GoogleFonts.lato(fontSize: 14))),
                ],
              ),
            );
          }),
        ],
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
    ).animate().fadeIn(
        delay: const Duration(milliseconds: 400), duration: 500.ms);
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
    ).animate().fadeIn(
        delay: const Duration(milliseconds: 400), duration: 500.ms);
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 12, color: FrutiaColors.secondaryText)),
            ],
          )
        ],
      ),
    );
  }
}

class MembershipStatusWidget extends StatelessWidget {
  final bool isPremium;
  final VoidCallback? onUpgradePressed;

  const MembershipStatusWidget({
    super.key,
    required this.isPremium,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !isPremium ? onUpgradePressed : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPremium ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPremium ? Colors.green : Colors.red,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPremium ? Icons.verified_user : Icons.card_membership,
              color: isPremium ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? "Membresía Premium" : "Actualiza tu membresía",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPremium ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium
                        ? "Estás disfrutando de todos los beneficios premium"
                        : "Desbloquea todas las funciones premium",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.red,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}