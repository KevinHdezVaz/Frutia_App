import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/onscreen/QuestionnairePage.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/progress/ProgressPage.dart';
import 'package:Frutia/services/RachaProgreso.dart';
import 'package:Frutia/utils/PlanCarousel.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  bool _canCompleteStreakToday = false;
  bool _isStreakButtonLoading = false;
  Set<String> _streakHistory = {};
  int _daysSinceLastStreak = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndCheckProfile();
    });
  }

  void _checkIfStreakCanBeCompleted(Map<String, dynamic>? profile) {
    if (!mounted) return;

    if (profile == null) {
      setState(() {
        _canCompleteStreakToday = true;
        _daysSinceLastStreak = 0;
        _streakHistory.clear();
      });
      return;
    }

    if (profile['streak_history'] != null) {
      final history = List<String>.from(profile['streak_history']);
      setState(() => _streakHistory = history.toSet());
    }

    if (profile['ultima_fecha_racha'] == null) {
      setState(() {
        _canCompleteStreakToday = true;
        _daysSinceLastStreak = 0;
      });
      return;
    }

    final lastStreakUpdateDate = DateTime.parse(profile['ultima_fecha_racha']);
    final todayUTC = DateTime.now().toUtc();
    final difference = todayUTC.difference(lastStreakUpdateDate).inDays;

    setState(() {
      _daysSinceLastStreak = difference;
      _canCompleteStreakToday = difference >= 1;
    });
  }

  Future<void> _completeDayFromHome() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (!mounted) return;
    setState(() => _isStreakButtonLoading = true);

    try {
      await RachaProgresoService.marcarDiaCompleto();
      if (!mounted) return;
      await _fetchAndCheckProfile();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('¡Día completado! Tu racha continúa.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isStreakButtonLoading = false);
    }
  }

  Future<void> _fetchAndCheckProfile() async {
    if (!mounted) return;
    setState(() => _pageState = PageState.loading);
    final navigator = Navigator.of(context);

    try {
      final responseData = await RachaProgresoService.getProgresoWithUser();
      if (!mounted) return;

      final user = responseData['user'];
      final profile = responseData['profile'];
      final fullUserData = {'user': user, 'profile': profile};

      _checkIfStreakCanBeCompleted(profile);

      if (profile == null || profile['height'] == null) {
        await navigator.push(MaterialPageRoute(
            builder: (context) =>
                PersonalDataPage(onSuccess: _fetchAndCheckProfile)));
        if (mounted) {
          setState(() {
            _userData = fullUserData;
            _pageState = PageState.needsOnboarding;
          });
        }
      } else if (profile['plan_setup_complete'] != true &&
          profile['plan_setup_complete'] != 1) {
        setState(() {
          _userData = fullUserData;
          _pageState = PageState.needsPlan;
        });
      } else {
        setState(() {
          _userData = fullUserData;
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
                    end: Alignment.bottomRight))),
        title: Text('Perfil',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 24)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
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
        return const SizedBox.shrink(key: ValueKey('onboarding'));
      case PageState.needsPlan:
      case PageState.hasPlan:
        return _DashboardView(
          key: const ValueKey('dashboard'),
          userData: _userData!,
          canCompleteStreakToday: _canCompleteStreakToday,
          isStreakButtonLoading: _isStreakButtonLoading,
          onCompleteStreak: _completeDayFromHome,
          streakHistory: _streakHistory,
          daysSinceLastStreak: _daysSinceLastStreak,
        );
      case PageState.error:
        return _buildErrorUI(key: const ValueKey('error'));
    }
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
              style:
                  GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
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
  final bool canCompleteStreakToday;
  final bool isStreakButtonLoading;
  final VoidCallback onCompleteStreak;
  final Set<String> streakHistory;
  final int daysSinceLastStreak;

  const _DashboardView({
    super.key,
    required this.userData,
    required this.canCompleteStreakToday,
    required this.isStreakButtonLoading,
    required this.onCompleteStreak,
    required this.streakHistory,
    required this.daysSinceLastStreak,
  });

  String _getUpcomingMeal() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Desayuno';
    if (hour < 14) return 'Almuerzo';
    if (hour < 20) return 'Cena';
    return 'Desayuno';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> user = userData['user'] ?? {};
    final Map<String, dynamic> profileData = userData['profile'] ?? {};
    final String userName = user['name'] ?? 'Usuario';
    final bool hasPlan = profileData.isNotEmpty &&
        (profileData['plan_setup_complete'] == true ||
            profileData['plan_setup_complete'] == 1);
    final String currentWeight = profileData['weight']?.toString() ?? '--';
    final String mainGoal = profileData['goal'] ?? 'No definido';

    // CAMBIO: El valor de la racha ahora depende de si se perdió o no.
    final int streakDays =
        (daysSinceLastStreak >= 4) ? 0 : (profileData['racha_actual'] ?? 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(userName, context),
          const SizedBox(height: 24),
          if (hasPlan) ...[
            // CAMBIO: Se muestra el recordatorio siempre que haya plan, y su contenido cambia.
            _StreakReminderCard(
              streakCount: streakDays,
              isLoading: isStreakButtonLoading,
              onPressed: onCompleteStreak,
              daysSinceLastStreak: daysSinceLastStreak,
              canCompleteToday: canCompleteStreakToday,
            ),
            const SizedBox(height: 24),
          ],
          _buildWeekCalendar(context, streakHistory),
          const SizedBox(height: 24),
          _buildStatsRow(context, streakDays, currentWeight, mainGoal),
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
            child:
                hasPlan ? const PlanCarousel() : _buildCreatePlanCard(context),
          ),
          if (hasPlan) const SizedBox(height: 16),
          const SizedBox(height: 40),
          MembershipStatusWidget(isPremium: false, onUpgradePressed: () {}),
          const SizedBox(height: 40),
          _buildAchievementsSection(),
          const SizedBox(height: 24),
          _btnLogout(context),
          const SizedBox(height: 120),
        ],
      )
          .animate()
          .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms),
    );
  }

  Widget _buildProfileHeader(String userName, BuildContext context) {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(children: [
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
                            fontSize: 22, fontWeight: FontWeight.bold))
                  ])),
              IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: FrutiaColors.secondaryText),
                  onPressed: () {})
            ]))
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildStatsRow(BuildContext context, int streakDays,
      String currentWeight, String mainGoal) {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        value: '$streakDays días',
                        label: 'Racha',
                        color: Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        icon: Icons.monitor_weight_rounded,
                        value: '$currentWeight kg',
                        label: 'Peso actual',
                        color: Colors.blue))
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _StatCard(
                        icon: Icons.flag_rounded,
                        value: mainGoal,
                        label: 'Objetivo',
                        color: Colors.green)),
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProgressScreen()));
                        },
                        child: Container(
                            color: Colors.transparent,
                            child: const SizedBox(width: 12, height: 60))))
              ])
            ]))
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildWeekCalendar(BuildContext context, Set<String> history) {
    final today = DateTime.now();
    final startOfWindow = today.subtract(const Duration(days: 3));
    final ScrollController scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        const itemExtent = 60.0 + 12.0;
        final screenWidth = MediaQuery.of(context).size.width;
        final offset = (3 * itemExtent) - (screenWidth / 2) + (itemExtent / 2);
        scrollController.animateTo(
            offset.clamp(0.0, scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Tu semana',
                style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.primaryText))),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            itemCount: 7,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final day = startOfWindow.add(Duration(days: index));
              final dayString = DateFormat('yyyy-MM-dd').format(day);
              final isToday =
                  DateFormat('yyyy-MM-dd').format(today) == dayString;
              final didComply = history.contains(dayString);

              return Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  gradient: isToday
                      ? LinearGradient(
                          colors: [FrutiaColors.accent, FrutiaColors.accent2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)
                      : null,
                  color: isToday ? null : FrutiaColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: isToday
                      ? Border.all(color: Colors.white, width: 2)
                      : Border.all(
                          color: FrutiaColors.secondaryBackground
                              .withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                        color: isToday
                            ? FrutiaColors.accent.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        DateFormat('E', 'es_ES')
                            .format(day)
                            .substring(0, 3)
                            .toUpperCase(),
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? Colors.white
                                : FrutiaColors.secondaryText)),
                    const SizedBox(height: 6),
                    Text(day.day.toString(),
                        style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? Colors.white
                                : FrutiaColors.primaryText)),
                    const SizedBox(height: 6),
                    Icon(
                      didComply ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: isToday
                          ? Colors.white.withOpacity(0.8)
                          : (didComply ? Colors.green : Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ).animate().slideX(
        begin: 0.2,
        end: 0.0,
        delay: const Duration(milliseconds: 400),
        duration: 400.ms,
        curve: Curves.easeOut);
  }

  Widget _buildUpcomingMealCard() {
    final upcomingMeal = _getUpcomingMeal();
    String message;
    final hour = DateTime.now().hour;
    if (hour < 5)
      message = "Hora de dormir";
    else if (hour < 10)
      message = "Tu desayuno está por comenzar";
    else if (hour < 12)
      message = "Pronto será hora de almorzar";
    else if (hour < 14)
      message = "¡Es hora de almorzar!";
    else if (hour < 17)
      message = "Tu cena se acerca";
    else if (hour < 20)
      message = "¡Es hora de cenar!";
    else
      message = "Tu próxima comida será el desayuno";
    return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: FrutiaColors.progress.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: FrutiaColors.progress.withOpacity(0.2), width: 1)),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: FrutiaColors.progress.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.restaurant_menu_rounded,
                      color: FrutiaColors.progress, size: 28)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(message,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: FrutiaColors.primaryText)),
                    const SizedBox(height: 4),
                    Text('Próxima comida: ${upcomingMeal.toLowerCase()}',
                        style: GoogleFonts.lato(
                            color: FrutiaColors.secondaryText, fontSize: 14))
                  ]))
            ]))
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildCreatePlanCard(BuildContext context) {
    return Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: FrutiaColors.accent,
                borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                builder: (context) =>
                                    const QuestionnaireFlow()));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: FrutiaColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child:
                          Row(mainAxisSize: MainAxisSize.min, children: const [
                        Text('Crea tu plan ahora',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16)
                      ])))
            ]))
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildAchievementsSection() {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tus logros',
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold)),
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
                    _buildAchievementCard(
                        'Explorador', Icons.explore, Colors.blue)
                  ])
            ]))
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms);
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
            ]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(title,
              style:
                  GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center)
        ]));
  }
}

class _StreakReminderCard extends StatelessWidget {
  final int streakCount;
  final bool isLoading;
  final VoidCallback onPressed;
  final int daysSinceLastStreak;
  // CAMBIO: Se añade este booleano para decidir si el botón debe ser visible.
  final bool canCompleteToday;

  const _StreakReminderCard({
    required this.streakCount,
    required this.isLoading,
    required this.onPressed,
    required this.daysSinceLastStreak,
    required this.canCompleteToday,
  });

  @override
  Widget build(BuildContext context) {
    // CAMBIO: El widget entero se oculta si no se puede completar la racha hoy.
    if (!canCompleteToday) {
      return const SizedBox.shrink(); // No muestra nada si ya se cumplió hoy.
    }

    String title;
    String subtitle;
    List<Color> gradientColors;
    IconData icon;

    // Lógica para determinar el mensaje y estilo según los días de inactividad
    if (daysSinceLastStreak >= 4) {
      title = '¡Oh, no! Perdiste tu racha';
      subtitle = 'Llevabas $streakCount días. ¡Empieza una nueva hoy!';
      gradientColors = [Colors.blueGrey.shade400, Colors.blueGrey.shade600];
      icon = Icons.replay_circle_filled_rounded;
    } else if (daysSinceLastStreak == 3) {
      title = '¡Tu racha está en peligro!';
      subtitle = 'Hoy es el último día para salvarla.';
      gradientColors = [Colors.red.shade400, Colors.red.shade700];
      icon = Icons.warning_amber_rounded;
    } else if (daysSinceLastStreak == 2) {
      title = '¡No te olvides de tu racha!';
      subtitle = 'Te está esperando. ¡Sigue así!';
      gradientColors = [Colors.amber.shade600, Colors.orange.shade800];
      icon = Icons.notification_important_rounded;
    } else {
      title = '¡Completa tu día!';
      subtitle = streakCount > 0
          ? 'Vas por $streakCount días. ¡Vamos!'
          : '¡Es hora de empezar tu racha!';
      gradientColors = [Colors.orange.shade400, Colors.deepOrange.shade500];
      icon = Icons.local_fire_department_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: gradientColors[1].withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isLoading)
                const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3))
              else
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }
}

Widget _btnLogout(BuildContext context) {
  final AuthService authService = AuthService();
  return Center(
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4))
              ]),
          child: ElevatedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('¿Cerrar sesión?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text(
                                'Estás a punto de salir de tu cuenta.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar',
                                      style: TextStyle(color: Colors.grey))),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Salir',
                                      style: TextStyle(color: Colors.red)))
                            ]));
                if (confirm == true) {
                  if (!navigator.mounted) return;
                  try {
                    await authService.logout();
                    if (!navigator.mounted) return;
                    navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => AuthCheckMain()),
                        (Route<dynamic> route) => false);
                  } catch (e) {
                    if (navigator.mounted) {
                      scaffoldMessenger.showSnackBar(SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red));
                    }
                  }
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 22),
              label: const Text('Cerrar sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200, width: 1.5)),
                  elevation: 0))));
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: FrutiaColors.secondaryBackground,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: GoogleFonts.lato(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label,
                style: GoogleFonts.lato(
                    fontSize: 12, color: FrutiaColors.secondaryText))
          ])
        ]));
  }
}

class MembershipStatusWidget extends StatelessWidget {
  final bool isPremium;
  final VoidCallback? onUpgradePressed;
  const MembershipStatusWidget(
      {super.key, required this.isPremium, this.onUpgradePressed});
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
                    color: isPremium ? Colors.green : Colors.red, width: 1.5)),
            child: Row(children: [
              Icon(isPremium ? Icons.verified_user : Icons.card_membership,
                  color: isPremium ? Colors.green : Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        isPremium
                            ? "Membresía Premium"
                            : "Actualiza tu membresía",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPremium ? Colors.green : Colors.red)),
                    const SizedBox(height: 4),
                    Text(
                        isPremium
                            ? "Estás disfrutando de todos los beneficios premium"
                            : "Desbloquea todas las funciones premium",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87))
                  ])),
              if (!isPremium)
                Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16)
            ])));
  }
}
