import 'dart:convert'; // Import para decodificar JSON

import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/onscreen/QuestionnairePage.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/drawer/HelpandSupport.dart';
import 'package:Frutia/pages/screens/drawer/PrivacyPolitice.dart';
import 'package:Frutia/pages/screens/drawer/TermsAndConditions.dart';
import 'package:Frutia/pages/screens/miplan/PremiumScreen.dart';
import 'package:Frutia/pages/screens/miplan/TrialExpiredDialog.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/pages/screens/progress/ProgressPage.dart';
import 'package:Frutia/services/RachaProgreso.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/PlanCarousel.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart'
    as http; // Asumiendo que usas http, para el tipo de excepción
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

enum PageState { loading, error, needsOnboarding, needsPlan, hasPlan }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final PlanService _planService = PlanService();
  PageState _pageState = PageState.loading;
  Map<String, dynamic>? _userData;
  MealPlanData? _mealPlanData;
  String? _userName;
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
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final name = await _planService.getUserName();
      if (mounted) {
        setState(() {
          _userName = name;
        });
      }
      debugPrint('User name loaded: $name');
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      if (mounted) {
        setState(() {
          _userName = 'Usuario'; // Valor por defecto en caso de error
        });
      }
    }
  }

  Future<void> _showTrialExpiredDialog() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrar el diálogo
      builder: (BuildContext dialogContext) {
        return const TrialExpiredDialog();
      },
    );
  }

  void _checkIfStreakCanBeCompleted(Map<String, dynamic>? profile) {
    if (!mounted || profile == null) return;

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
    final navigator = Navigator.of(context);
    if (!mounted) return;

    setState(() => _isStreakButtonLoading = true);

    try {
      await RachaProgresoService.marcarDiaCompleto();
      await _fetchAndCheckProfile();
      if (!mounted) return;

      await navigator.push(
        MaterialPageRoute(builder: (context) => const ProgressScreen()),
      );
      await _fetchAndCheckProfile();

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('¡Día completado! Tu racha continúa.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        // El error 403 del middleware se captura aquí.
        if (e is http.Response && e.statusCode == 403) {
          _showTrialExpiredDialog();
          return;
        }
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text('Error al completar el día: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStreakButtonLoading = false);
      }
    }
  }

  // --- INICIA NUEVA FUNCIÓN ---
  /// Revisa los datos del usuario para ver si su prueba ha expirado.
  bool _isTrialExpired(Map<String, dynamic>? user) {
    if (user == null) return false;

    // Solo nos importa si el estado es 'trial'
    if (user['subscription_status'] != 'trial') return false;

    final trialEndsAtString = user['trial_ends_at'];
    if (trialEndsAtString == null) {
      // Si es nulo pero el estado es 'trial', consideramos que expiró.
      return true;
    }

    try {
      final endDate = DateTime.parse(trialEndsAtString);
      // La prueba expira si la fecha actual es posterior a la fecha de finalización.
      return DateTime.now().isAfter(endDate);
    } catch (e) {
      // Si el formato de fecha es inválido, no podemos hacer nada.
      debugPrint("Error al parsear fecha de prueba: $e");
      return false;
    }
  }
  // --- TERMINA NUEVA FUNCIÓN ---

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

      debugPrint(
          "Datos del usuario recibidos del backend: ${jsonEncode(user)}");

      setState(() {
        _userData = fullUserData;
      });

      // --- INICIA CAMBIO LÓGICO ---
      // 1. Revisamos si la prueba ha expirado ANTES de hacer cualquier otra cosa.
      if (_isTrialExpired(user)) {
        _showTrialExpiredDialog();
        // Ponemos la UI en un estado válido pero sin intentar cargar el plan,
        // ya que sabemos que fallará.
        setState(() {
          _pageState = PageState.hasPlan; // Para que muestre el dashboard
          _mealPlanData = null; // Pero sin datos de plan
        });
        return; // Detenemos la ejecución aquí.
      }
      // --- TERMINA CAMBIO LÓGICO ---

      _checkIfStreakCanBeCompleted(profile);

      if (profile == null || profile['height'] == null) {
        await navigator.push(MaterialPageRoute(
            builder: (context) =>
                PersonalDataPage(onSuccess: _fetchAndCheckProfile)));
        if (mounted) {
          setState(() => _pageState = PageState.needsOnboarding);
        }
      } else if (profile['plan_setup_complete'] != true &&
          profile['plan_setup_complete'] != 1) {
        setState(() => _pageState = PageState.needsPlan);
      } else {
        // Si la prueba no ha expirado, intentamos cargar el plan.
        final plan = await _planService.getCurrentPlan();
        if (mounted) {
          setState(() {
            _mealPlanData = plan;
            _pageState = PageState.hasPlan;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // El catch ahora solo maneja errores inesperados.
        // El caso de 'trial_expired' se maneja proactivamente arriba.
        setState(() {
          _pageState = PageState.error;
          _userData = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPremium =
        _userData?['user']?['subscription_status'] == 'active';
    final bool isInTrial =
        _userData?['user']?['subscription_status'] == 'trial' &&
            !_isTrialExpired(_userData?['user']);

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
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
      drawer: _buildDrawer(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _buildUIForState(isPremium: isPremium, isInTrial: isInTrial),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: FrutiaColors.primaryBackground,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [FrutiaColors.accent, FrutiaColors.accent2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName ?? 'Usuario',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Mi cuenta',
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),
            ListTile(
              leading:
                  Icon(Icons.trending_up_rounded, color: FrutiaColors.accent),
              title: Text('Progreso',
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProgressScreen()));
              },
            ).animate().slideX(
                begin: -0.2,
                duration: 400.ms,
                delay: 200.ms,
                curve: Curves.easeOut),
            ListTile(
              leading:
                  Icon(Icons.description_rounded, color: FrutiaColors.accent),
              title: Text('Términos y condiciones',
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TermsAndConditionsScreen()));
              },
            ).animate().slideX(
                begin: -0.2,
                duration: 400.ms,
                delay: 500.ms,
                curve: Curves.easeOut),
            ListTile(
              leading:
                  Icon(Icons.privacy_tip_rounded, color: FrutiaColors.accent),
              title: Text('Política de privacidad',
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrivacyPolicyScreen()));
              },
            ).animate().slideX(
                begin: -0.2,
                duration: 400.ms,
                delay: 600.ms,
                curve: Curves.easeOut),
            ListTile(
              leading:
                  Icon(Icons.help_outline_rounded, color: FrutiaColors.accent),
              title: Text('Ayuda y soporte',
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HelpAndSupportScreen()));
              },
            ).animate().slideX(
                begin: -0.2,
                duration: 400.ms,
                delay: 700.ms,
                curve: Curves.easeOut),
            const Divider(
                color: Colors.grey,
                height: 20,
                thickness: 0.5,
                indent: 16,
                endIndent: 16),
            _btnLogout(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUIForState({required bool isPremium, required bool isInTrial}) {
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
          key: ValueKey('dashboard_${_pageState.name}'),
          userData: _userData!,
          mealPlanData: _mealPlanData,
          canCompleteStreakToday: _canCompleteStreakToday,
          isStreakButtonLoading: _isStreakButtonLoading,
          onCompleteStreak: _completeDayFromHome,
          streakHistory: _streakHistory,
          daysSinceLastStreak: _daysSinceLastStreak,
          shouldShowShowcase: true,
          isPremium: isPremium,
          isInTrial: isInTrial,
          userName: _userName,
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
            Text('¡Algo salió mal!',
                style:
                    GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
                'No pudimos cargar tu perfil. Por favor, intenta de nuevo o contacta a soporte si el problema persiste.',
                style: GoogleFonts.lato(
                    fontSize: 16, color: FrutiaColors.secondaryText),
                textAlign: TextAlign.center),
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

class _DashboardView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final MealPlanData? mealPlanData;
  final bool canCompleteStreakToday;
  final bool isStreakButtonLoading;
  final VoidCallback onCompleteStreak;
  final Set<String> streakHistory;
  final int daysSinceLastStreak;
  final bool shouldShowShowcase;
  final bool isPremium;
  final bool isInTrial;
  final String? userName;

  const _DashboardView({
    super.key,
    required this.userData,
    this.mealPlanData,
    required this.canCompleteStreakToday,
    required this.isStreakButtonLoading,
    required this.onCompleteStreak,
    required this.streakHistory,
    required this.daysSinceLastStreak,
    this.shouldShowShowcase = false,
    required this.isPremium,
    required this.isInTrial,
    required this.userName,
  });

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final GlobalKey _streakReminderKey =
      GlobalKey(debugLabel: 'homepageStreakReminderShowcase');
  final GlobalKey _weekCalendarKey =
      GlobalKey(debugLabel: 'homepageWeekCalendarShowcase');
  final GlobalKey _streakStatKey =
      GlobalKey(debugLabel: 'homepageStreakStatShowcase');
  final GlobalKey _weightStatKey =
      GlobalKey(debugLabel: 'homepageWeightStatShowcase');
  final GlobalKey _goalStatKey =
      GlobalKey(debugLabel: 'homepageGoalStatShowcase');
  final GlobalKey _createPlanCardKey =
      GlobalKey(debugLabel: 'homepageCreatePlanCardShowcase');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.shouldShowShowcase) {
        _showHomePageShowcase();
      }
    });
  }

  Future<void> _showHomePageShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final bool homePageShowcaseShown =
        prefs.getBool('homePageShowcaseShown') ?? false;

    if (!homePageShowcaseShown) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      List<GlobalKey> keysToShow = [];
      final bool hasPlan = widget.userData['profile'] != null &&
          (widget.userData['profile']['plan_setup_complete'] == true ||
              widget.userData['profile']['plan_setup_complete'] == 1);

      if (hasPlan && widget.canCompleteStreakToday) {
        keysToShow.add(_streakReminderKey);
      }
      keysToShow.add(_weekCalendarKey);
      keysToShow.add(_streakStatKey);
      if (!hasPlan) {
        keysToShow.add(_createPlanCardKey);
      }

      if (keysToShow.isNotEmpty &&
          mounted &&
          ShowCaseWidget.of(context).mounted) {
        ShowCaseWidget.of(context).startShowCase(keysToShow);
        await prefs.setBool('homePageShowcaseShown', true);
      }
    }
  }

  String _getUpcomingMeal() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Desayuno';
    if (hour < 14) return 'Almuerzo';
    if (hour < 20) return 'Cena';
    return 'Desayuno';
  }

  String _getTrialDaysRemaining() {
    if (!widget.isInTrial) return '';

    final trialEndsAtString = widget.userData['user']?['trial_ends_at'];
    if (trialEndsAtString == null) return 'N/A';

    try {
      final endDate = DateTime.parse(trialEndsAtString);
      final now = DateTime.now();
      final difference = endDate.difference(now);

      if (difference.isNegative) return '0 días';

      return '${difference.inDays + 1} días';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> user = widget.userData['user'] ?? {};
    final Map<String, dynamic> profileData = widget.userData['profile'] ?? {};
    final bool hasPlan = widget.mealPlanData != null;
    final String currentWeight = profileData['weight']?.toString() ?? '--';
    final String mainGoal = profileData['goal'] ?? 'No definido';
    final int streakDays = (widget.daysSinceLastStreak >= 4)
        ? 0
        : (profileData['racha_actual'] ?? 0);
    final String trialDaysRemaining = _getTrialDaysRemaining();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 24),
          if (hasPlan && widget.canCompleteStreakToday)
            Showcase(
              key: _streakReminderKey,
              title: 'Completa tu día',
              description:
                  'Toca aquí para marcar tu día como completado y mantener o iniciar tu racha. ¡Hazlo diario!',
              tooltipBackgroundColor: FrutiaColors.accent,
              targetShapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              titleTextStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              descTextStyle:
                  GoogleFonts.lato(color: Colors.white, fontSize: 14),
              disableMovingAnimation: true,
              disableScaleAnimation: true,
              child: _StreakReminderCard(
                streakCount: streakDays,
                isLoading: widget.isStreakButtonLoading,
                onPressed: widget.onCompleteStreak,
                daysSinceLastStreak: widget.daysSinceLastStreak,
                canCompleteToday: widget.canCompleteStreakToday,
              ),
            ),
          const SizedBox(height: 24),
          Showcase(
            key: _weekCalendarKey,
            title: 'Tu progreso semanal',
            description:
                'Aquí puedes ver los días que has completado tu plan y el estado de tu racha diaria.',
            tooltipBackgroundColor: FrutiaColors.accent,
            targetShapeBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            titleTextStyle: GoogleFonts.poppins(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            descTextStyle: GoogleFonts.lato(color: Colors.white, fontSize: 14),
            disableMovingAnimation: true,
            disableScaleAnimation: true,
            child: _buildWeekCalendar(context, widget.streakHistory),
          ),
          const SizedBox(height: 24),
          _buildStatsRow(
              context, streakDays, currentWeight, mainGoal, trialDaysRemaining),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(hasPlan ? 'Tus recetas de hoy' : 'Crea tu plan',
                style: GoogleFonts.lato(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: hasPlan
                ? PlanCarousel(recipes: widget.mealPlanData!.recipes)
                : Showcase(
                    key: _createPlanCardKey,
                    title: 'Crea tu plan de alimentación',
                    description:
                        'Toca aquí para iniciar tu viaje con un plan totalmente personalizado. ¡Es tu primer paso!',
                    tooltipBackgroundColor: FrutiaColors.accent,
                    targetShapeBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    titleTextStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    descTextStyle:
                        GoogleFonts.lato(color: Colors.white, fontSize: 14),
                    disableMovingAnimation: true,
                    disableScaleAnimation: true,
                    child: _buildCreatePlanCard(context),
                  ),
          ),
          if (hasPlan) const SizedBox(height: 16),
          const SizedBox(height: 40),
          _buildUpcomingMealCard(),
          const SizedBox(height: 24),
          MembershipStatusWidget(
            isPremium: widget.isPremium,
            isInTrial: widget.isInTrial,
            trialDaysRemaining: trialDaysRemaining,
          ),
          const SizedBox(height: 40),
          const SizedBox(height: 120),
        ],
      )
          .animate()
          .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: FrutiaColors.accent,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola de nuevo,',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: FrutiaColors.secondaryText,
                  ),
                ),
                Text(
                  widget.userName ?? 'Usuario',
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400), duration: 500.ms);
  }

  Widget _buildStatsRow(BuildContext context, int streakDays,
      String currentWeight, String mainGoal, String trialDaysRemaining) {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: Showcase(
                      key: _streakStatKey,
                      title: 'Tu racha actual',
                      description:
                          'Los días consecutivos que has completado tu plan.',
                      tooltipBackgroundColor: FrutiaColors.accent,
                      targetShapeBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      titleTextStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      descTextStyle:
                          GoogleFonts.lato(color: Colors.white, fontSize: 14),
                      disableMovingAnimation: true,
                      disableScaleAnimation: true,
                      child: _StatCard(
                          icon: Icons.local_fire_department_rounded,
                          value: '$streakDays días',
                          label: 'Racha',
                          color: Colors.orange)),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Showcase(
                        key: _weightStatKey,
                        title: 'Tu peso',
                        description:
                            'Consulta tu peso actual para seguir tu progreso.',
                        tooltipBackgroundColor: FrutiaColors.accent,
                        targetShapeBorder: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        titleTextStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        descTextStyle:
                            GoogleFonts.lato(color: Colors.white, fontSize: 14),
                        disableMovingAnimation: true,
                        disableScaleAnimation: true,
                        child: _StatCard(
                            icon: Icons.monitor_weight_rounded,
                            value: '$currentWeight kg',
                            label: 'Peso actual',
                            color: Colors.blue)))
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Showcase(
                        key: _goalStatKey,
                        title: 'Tu objetivo',
                        description: 'Tu meta de salud principal. ¡A por ella!',
                        tooltipBackgroundColor: FrutiaColors.accent,
                        targetShapeBorder: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        titleTextStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        descTextStyle:
                            GoogleFonts.lato(color: Colors.white, fontSize: 14),
                        disableMovingAnimation: true,
                        disableScaleAnimation: true,
                        child: _StatCard(
                            icon: Icons.flag_rounded,
                            value: mainGoal,
                            label: 'Objetivo',
                            color: Colors.green))),
                if (widget.isInTrial) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      value: trialDaysRemaining,
                      label: 'Prueba restante',
                      color: FrutiaColors.accent2,
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                ]
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
                    Icon(didComply ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: isToday
                            ? Colors.green.withOpacity(0.8)
                            : (didComply
                                ? Colors.green
                                : Colors.grey.shade400)),
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
}

class _StreakReminderCard extends StatelessWidget {
  final int streakCount;
  final bool isLoading;
  final VoidCallback onPressed;
  final int daysSinceLastStreak;
  final bool canCompleteToday;

  const _StreakReminderCard({
    super.key,
    required this.streakCount,
    required this.isLoading,
    required this.onPressed,
    required this.daysSinceLastStreak,
    required this.canCompleteToday,
  });

  @override
  Widget build(BuildContext context) {
    if (!canCompleteToday) {
      return const SizedBox.shrink();
    }

    String title;
    String subtitle;
    List<Color> gradientColors;
    IconData icon;

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
      subtitle = 'Te está esperando. Llevas 2 dias sin racha';
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
      {super.key,
      required this.icon,
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
  final bool isInTrial;
  final String trialDaysRemaining;

  const MembershipStatusWidget({
    Key? key,
    required this.isPremium,
    required this.isInTrial,
    required this.trialDaysRemaining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    Color color;
    IconData icon;
    bool isActionable = true;

    if (isPremium) {
      title = "Membresía Premium";
      subtitle = "Estás disfrutando de todos los beneficios";
      color = Colors.green;
      icon = Icons.verified_user;
      isActionable = false;
    } else if (isInTrial) {
      title = "En Período de Prueba";
      subtitle = "Te quedan $trialDaysRemaining de prueba gratuita";
      color = FrutiaColors.accent;
      icon = Icons.timer;
    } else {
      title = "Actualiza tu membresía";
      subtitle = "Desbloquea todas las funciones premium";
      color = Colors.red;
      icon = Icons.card_membership;
    }

    return GestureDetector(
      onTap: isActionable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  )
                ],
              ),
            ),
            if (isActionable)
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
