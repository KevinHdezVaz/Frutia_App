import 'dart:math';

import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/pages/screens/datosPersonales/PlanSummaryScreen.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/utils/ChoiceChipCard.dart';
import 'package:Frutia/utils/CustomTextField.dart';
import 'package:Frutia/utils/CustomTimePickerField.dart';
import 'package:Frutia/utils/LoadingMessagesWidget.dart';
import 'package:Frutia/utils/PlanGenerationDialog.dart';
import 'package:Frutia/utils/SelectionCard.dart';
import 'package:Frutia/utils/SportSelection.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// Importa tu QuestionnaireProvider (asegúrate de que la ruta sea correcta)
import 'package:Frutia/providers/QuestionnaireProvider.dart';

/// Widget que gestiona el flujo del cuestionario para crear o editar un plan personalizado.
class QuestionnaireFlow extends StatefulWidget {
  final bool isEditing;

  const QuestionnaireFlow({super.key, this.isEditing = false});

  @override
  State<QuestionnaireFlow> createState() => _QuestionnaireFlowState();
}

class _QuestionnaireFlowState extends State<QuestionnaireFlow> {
  final PageController _pageController = PageController();

  double _progress = 0;
  final int _numPages = 8;

  Map<String, String?> _validationErrors = {};

  /// Elimina emojis y normaliza caracteres especiales para estandarizar los datos guardados.
  String removeEmojis(String text) {
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    return text
        .replaceAll(emojiRegex, '')
        .replaceAll('\u2013', '-') // Guion largo
        .replaceAll('\u00ed', 'í') // i con acento
        .replaceAll('\u00e1', 'á') // a con acento
        .replaceAll('\u00f3', 'ó') // o con acento
        .replaceAll('\u00fa', 'ú') // u con acento
        .replaceAll('\u00e9', 'é') // e con acento
        .replaceAll('\u00f1', 'ñ') // ñ
        .replaceAll('\u00c1', 'Á') // A mayúscula con acento
        .replaceAll('\u00c9', 'É') // E mayúscula con acento
        .replaceAll('\u00cd', 'Í') // I mayúscula con acento
        .replaceAll('\u00d3', 'Ó') // O mayúscula con acento
        .replaceAll('\u00da', 'Ú') // U mayúscula con acento
        .replaceAll('\u00d1', 'Ñ') // Ñ mayúscula
        .trim();
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _progress = _pageController.page! / (_numPages - 1);
          _validationErrors = {};
        });
      }
    });

    if (widget.isEditing) {
      _loadProfileData();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<QuestionnaireProvider>().reset();
      });
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await ProfileService().getProfile();
      if (profile != null && mounted) {
        final provider = context.read<QuestionnaireProvider>();

        // --- Define ALL your maps in a consistent UI_KEY:DB_VALUE format ---
        final Map<String, String> goalMap = {
          '🔥 Bajar grasa': 'Bajar grasa',
          '💪 Aumentar músculo': 'Aumentar músculo',
          '🥗 Comer más saludable': 'Comer más saludable',
          '📈 Mejorar rendimiento': 'Mejorar rendimiento',
        };

        final Map<String, String> weeklyActivityMap = {
          'No me muevo y no entreno (Ej: oficina + sofá)':
              'No me muevo y no entreno',
          'Oficina + entreno 1-2 veces (Ej: gym lunes y jueves)':
              'Oficina + entreno 1-2 veces',
          'Oficina + entreno 3-4 veces (Ej: gym lunes a jueves)':
              'Oficina + entreno 3-4 veces',
          'Oficina + entreno 5-6 veces (Ej: gym casi todos los días)':
              'Oficina + entreno 5-6 veces',
          'Trabajo activo + entreno 1-2 veces (Ej: mozo + gym 2 días)':
              'Trabajo activo + entreno 1-2 veces',
          'Trabajo activo + entreno 3-4 veces (Ej: mozo + gym 4 días)':
              'Trabajo activo + entreno 3-4 veces',
          'Trabajo muy físico + entreno 5-6 veces (Ej: construcción + gym diario)':
              'Trabajo muy físico + entreno 5-6 veces',
        };

        final Map<String, String> mealCountMap = {
          '🥐 3 comidas principales (Desayuno, almuerzo y cena)':
              '3 comidas principales (Desayuno, almuerzo y cena)',
          '🥗 3 comidas + 1 o 2 snacks (Entre comidas o post entreno)':
              '3 comidas + 1 o 2 snacks (Entre comidas o post entreno)',
          '🤗 No tengo estructura fija': 'No tengo estructura fija',
        };

        final Map<String, String> dietaryStyleMap = {
          '🍖 Omnívoro': 'Omnívoro',
          '🥕 Vegetariano': 'Vegetariano',
          '🌱 Vegano': 'Vegano',
          '🥚 Keto': 'Keto',
        };

        final Map<String, String> budgetMap = {
          '💸 Bajo - Solo lo básico (Ej: arroz, huevo, lentejas)':
              'Bajo - Solo lo básico (Ej: arroz , huevo, lentejas',
          '💳 Alto - Sin restricciones (Ej: salmón, proteína, superfoods)':
              'Alto - Sin restricciones (Ej: salmón, proteína, superfoods)',
        };
        final Map<String, String> eatsOutMap = {
          '🍔 Casi todos los días': 'Casi todos los días',
          '🍎 A veces (2 a 4 veces por semana)':
              'A veces (2 a 4 veces por semana)',
          '🥗 Rara vez (1 vez por semana o menos)':
              'Rara vez (1 vez por semana o menos)',
          '🚫 Nunca': 'Nunca',
        };
        final Map<String, String> communicationStyleMap = {
          'Motivadora (que te empuje a dar más cuando lo necesites) 🏋️':
              'Motivadora (que te empuje a dar más cuando lo necesites)',
          'Cercana (como un amigo que te acompaña sin presión) 😊':
              'Cercana (como un amigo que te acompaña sin presión)',
          'Directa (clara, sin vueltas ni frases suaves) 🤗':
              'Directa (clara, sin vueltas ni frases suaves)',
          'Como te salga a ti, yo me adapto 🔄':
              'Como te salga a ti, yo me adapto',
        };
        final Map<String, String> difficultyMap = {
          'Mantenerme constante 🔄': 'Mantenerme constante',
          'Saber qué comer cuando no tengo lo del plan 🤔':
              'Saber qué comer cuando no tengo lo del plan',
          'Comer saludable fuera de casa 🍽️': 'Comer saludable fuera de casa',
          'Controlar los antojos 🍫': 'Controlar los antojos',
          'Preparar la comida 🧑‍🍳': 'Preparar la comida',
          'Otra ✍️': 'Otra',
        };
        final Map<String, String> motivationMap = {
          'Ver resultados rápidos ⚡': 'Ver resultados rápidos',
          'Sentirme mejor físicamente (energía, digestión, menos pesadez) 💪':
              'Sentirme mejor físicamente (energía, digestión, menos pesadez)',
          'Demostrarme que puedo lograrlo 💯': 'Demostrarme que puedo lograrlo',
          'Mejorar mi salud a largo plazo 🏥': 'Mejorar mi salud a largo plazo',
          'Aún no lo tengo claro ❓': 'Aún no lo tengo claro',
        };

        String? findUiKeyByCleanedDbValue(
            String? dbValue, Map<String, String> map) {
          if (dbValue == null || dbValue.isEmpty) return null;
          final cleanedDbValue = removeEmojis(dbValue).trim();
          final entry = map.entries.firstWhere(
            (e) => removeEmojis(e.value).trim() == cleanedDbValue,
            orElse: () => const MapEntry('', ''),
          );
          return entry.key.isNotEmpty ? entry.key : null;
        }

        provider.update(() {
          provider.favoriteProteins =
              Set<String>.from(profile['favorite_proteins'] ?? []);
          provider.favoriteCarbs =
              Set<String>.from(profile['favorite_carbs'] ?? []);
          provider.favoriteFats =
              Set<String>.from(profile['favorite_fats'] ?? []);
          provider.favoriteFruits =
              Set<String>.from(profile['favorite_fruits'] ?? []);
          provider.name = profile['name'] ?? '';
          provider.mainGoal =
              findUiKeyByCleanedDbValue(profile['goal'], goalMap);
          provider.weeklyActivity = findUiKeyByCleanedDbValue(
              profile[
                  'weekly_activity'], // Asegúrate que este sea el nombre del campo en tu DB
              weeklyActivityMap);
          provider.dietStyle = findUiKeyByCleanedDbValue(
              profile['dietary_style'], dietaryStyleMap);
          provider.weeklyBudget =
              findUiKeyByCleanedDbValue(profile['budget'], budgetMap);
          provider.eatsOut =
              findUiKeyByCleanedDbValue(profile['eats_out'], eatsOutMap);
          provider.dislikedFoods = profile['disliked_foods'] ?? '';
          provider.hasAllergies = profile['has_allergies'] ?? false;
          provider.allergyDetails = profile['allergies'] ?? '';
          provider.medicalConditionDetails = profile['medical_condition'] ?? '';
          provider.hasMedicalCondition =
              profile['has_medical_condition'] ?? false;
          provider.communicationTone = findUiKeyByCleanedDbValue(
              profile['communication_style'], communicationStyleMap);
          provider.preferredName = profile['preferred_name'] ?? '';
          provider.sport = List<String>.from(profile['sport'] ?? []);
          //  provider.trainingFrequency = findUiKeyByCleanedDbValue(profile['training_frequency'], trainingFrequencyMap);
          provider.preferredSnackTime = profile['preferred_snack_time'];

          provider.breakfastTime = _parseTimeOfDay(profile['breakfast_time']);
          provider.lunchTime = _parseTimeOfDay(profile['lunch_time']);
          provider.dinnerTime = _parseTimeOfDay(profile['dinner_time']);

          final Set<String> loadedDifficulties = {};
          List<dynamic>? rawDifficulties = profile['diet_difficulties'];
          if (rawDifficulties != null) {
            for (var item in rawDifficulties) {
              if (item is String) {
                if (item.startsWith('Otra:')) {
                  loadedDifficulties.add(item);
                } else {
                  final String? uiKey =
                      findUiKeyByCleanedDbValue(item, difficultyMap);
                  if (uiKey != null) loadedDifficulties.add(uiKey);
                }
              }
            }
          }
          provider.dietDifficulties = loadedDifficulties;

          final Set<String> loadedMotivations = {};
          List<dynamic>? rawMotivations = profile['diet_motivations'];
          if (rawMotivations != null) {
            for (var item in rawMotivations) {
              if (item is String) {
                final String? uiKey =
                    findUiKeyByCleanedDbValue(item, motivationMap);
                if (uiKey != null) loadedMotivations.add(uiKey);
              }
            }
          }
          provider.dietMotivations = loadedMotivations;
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('[QuestionnaireFlow] Error loading profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _validateCurrentPage() {
    final provider = context.read<QuestionnaireProvider>();
    final currentPage =
        _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;
    setState(() => _validationErrors = {});
    bool isValid = true;
    List<String> errorMessages = [];

    switch (currentPage) {
      case 1:
        if (provider.mainGoal == null) {
          errorMessages.add('Selecciona un objetivo principal.');
          isValid = false;
        }
        if (provider.hasMedicalCondition &&
            provider.medicalConditionDetails.isEmpty) {
          _validationErrors['medicalCondition'] =
              'Específica tu condición médica.';
          isValid = false;
        }
        break;
      case 2:
        if (provider.sport.isEmpty)
          errorMessages.add('Selecciona al menos un deporte.');

        isValid = errorMessages.isEmpty;
        break;

      case 3:
        if (provider.preferredSnackTime == null) {
          errorMessages.add('Selecciona cuándo prefieres tu snack.');
          isValid = false;
        }
        if (provider.eatsOut == null)
          errorMessages
              .add('Selecciona con qué frecuencia comes fuera de casa.');
        isValid = errorMessages.isEmpty;
        break;
      case 4:
        if (provider.dietStyle == null || provider.dietStyle!.isEmpty) {
          errorMessages.add('Selecciona un estilo de alimentación.');
        }
        if (provider.hasAllergies && provider.allergyDetails.isEmpty) {
          _validationErrors['allergyDetails'] =
              'Específica tus alergias alimentarias.';
          isValid = false;
        }
        if (provider.weeklyBudget == null)
          errorMessages.add('Selecciona tu presupuesto semanal.');
        isValid = errorMessages.isEmpty && _validationErrors.isEmpty;
        break;

      case 5:
        if (provider.favoriteFruits.isEmpty)
          errorMessages.add('Selecciona al menos un fruta favorita.');

        isValid = errorMessages.isEmpty;
        break;

      case 6:
        if (provider.communicationTone == null)
          errorMessages.add('Selecciona un estilo de comunicación.');
        isValid = errorMessages.isEmpty;
        break;
      case 7:
        if (provider.dietDifficulties.isEmpty)
          errorMessages.add('Selecciona al menos una dificultad en la dieta.');
        if (provider.dietDifficulties.contains('Otra ✍️')) {
          bool otraEspecificada = provider.dietDifficulties.any((item) =>
              item.startsWith('Otra: ') && item.length > 'Otra: '.length);
          if (!otraEspecificada) {
            _validationErrors['otraDificultad'] =
                'Por favor, especifica tu otra dificultad alimentaria.';
            isValid = false;
          }
        }
        if (provider.dietMotivations.isEmpty)
          errorMessages
              .add('Selecciona al menos una motivación para tu dieta.');
        isValid = errorMessages.isEmpty && _validationErrors.isEmpty;
        break;
    }

    if (!isValid && errorMessages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessages.join('\n')),
          backgroundColor: Colors.red,
        ),
      );
    }
    return isValid;
  }

  /// Maneja el avance a la siguiente página o el guardado final del cuestionario.
  void _handleNextOrFinish() async {
    if (!_validateCurrentPage()) {
      return;
    }

    if (_pageController.page!.round() == _numPages - 1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PlanGenerationDialog(isEditing: widget.isEditing),
      );

      try {
        final questionnaireProvider = context.read<QuestionnaireProvider>();

        final List<String> cleanDietDifficulties =
            questionnaireProvider.dietDifficulties.map((item) {
          if (item.startsWith('Otra: ')) {
            return item;
          }
          return removeEmojis(item);
        }).toList();

        final List<String> cleanDietMotivations = questionnaireProvider
            .dietMotivations
            .map((item) => removeEmojis(item))
            .toList();

        final profileData = {
          'name': questionnaireProvider.name.isNotEmpty
              ? questionnaireProvider.name
              : null,
          'goal': questionnaireProvider.mainGoal != null
              ? removeEmojis(questionnaireProvider.mainGoal!)
              : null,
          // 'activity_level': questionnaireProvider.dailyActivityLevel != null
          //    ? removeEmojis(questionnaireProvider.dailyActivityLevel!)
          //   : null,
          'favorite_proteins': questionnaireProvider.favoriteProteins.isNotEmpty
              ? questionnaireProvider.favoriteProteins
                  .map((item) => removeEmojis(item))
                  .toList()
              : null,
          'favorite_carbs': questionnaireProvider.favoriteCarbs.isNotEmpty
              ? questionnaireProvider.favoriteCarbs
                  .map((item) => removeEmojis(item))
                  .toList()
              : null,
          'favorite_fats': questionnaireProvider.favoriteFats.isNotEmpty
              ? questionnaireProvider.favoriteFats
                  .map((item) => removeEmojis(item))
                  .toList()
              : null,
          'favorite_fruits': questionnaireProvider.favoriteFruits.isNotEmpty
              ? questionnaireProvider.favoriteFruits
                  .map((item) => removeEmojis(item))
                  .toList()
              : null,

          'weekly_activity': questionnaireProvider.weeklyActivity != null
              ? removeEmojis(questionnaireProvider.weeklyActivity!)
              : null,
          'dietary_style': questionnaireProvider.dietStyle != null
              ? removeEmojis(questionnaireProvider.dietStyle!)
              : null,
          'budget': questionnaireProvider.weeklyBudget != null
              ? removeEmojis(questionnaireProvider.weeklyBudget!)
              : null,
          'eats_out': questionnaireProvider.eatsOut != null
              ? removeEmojis(questionnaireProvider.eatsOut!)
              : null,
          'disliked_foods': questionnaireProvider.dislikedFoods.isNotEmpty
              ? questionnaireProvider.dislikedFoods
              : null,
          'has_allergies': questionnaireProvider.hasAllergies,
          'allergies': questionnaireProvider.allergyDetails.isNotEmpty
              ? questionnaireProvider.allergyDetails
              : null,
          'has_medical_condition': questionnaireProvider.hasMedicalCondition,
          'medical_condition':
              questionnaireProvider.medicalConditionDetails.isNotEmpty
                  ? questionnaireProvider.medicalConditionDetails
                  : null,
          'communication_style': questionnaireProvider.communicationTone != null
              ? removeEmojis(questionnaireProvider.communicationTone!)
              : null,
          'preferred_name':
              questionnaireProvider.preferredName?.isNotEmpty ?? false
                  ? questionnaireProvider.preferredName
                  : null,
          'sport': questionnaireProvider.sport.isNotEmpty
              ? questionnaireProvider.sport
              : null,
          //   'training_frequency': questionnaireProvider.trainingFrequency != null
          //      ? removeEmojis(questionnaireProvider.trainingFrequency!)
          //     : null,
          'preferred_snack_time': questionnaireProvider.preferredSnackTime,

          'breakfast_time':
              formatTimeOfDay(questionnaireProvider.breakfastTime),
          'lunch_time': formatTimeOfDay(questionnaireProvider.lunchTime),
          'dinner_time': formatTimeOfDay(questionnaireProvider.dinnerTime),
          'diet_difficulties':
              cleanDietDifficulties.isNotEmpty ? cleanDietDifficulties : null,
          'diet_motivations':
              cleanDietMotivations.isNotEmpty ? cleanDietMotivations : null,
          'plan_setup_complete': true,
        };

        await ProfileService().saveProfile(profileData);

        // 2. Guardamos el momento exacto en que pedimos el plan.
        //    Este timestamp se enviará al backend para saber si el plan es nuevo.
        final requestTime = DateTime.now();
        await PlanService().generatePlan();

        bool isPlanReady = false;
        // 3. Definimos un tiempo máximo de espera (ej. 3 minutos) para no dejar al usuario esperando indefinidamente.
        const maxWaitTime = Duration(minutes: 10);
        final stopwatch = Stopwatch()..start();

        // 4. Bucle de sondeo (Polling): se ejecuta mientras el plan no esté listo y no se haya superado el tiempo de espera.
        do {
          // Esperamos 5 segundos antes de volver a preguntar al servidor.
          await Future.delayed(const Duration(seconds: 3));

          // Verificamos el estado del plan en el backend.
          final status = await PlanService().checkPlanStatus(requestTime);

          debugPrint(
              '[Polling] Chequeando estado del plan... Respuesta: $status');

          if (status == 'ready') {
            isPlanReady = true;
            break; // Salimos del bucle si el plan está listo.
          }

          // Si excedimos el tiempo de espera, también salimos.
          if (stopwatch.elapsed > maxWaitTime) {
            debugPrint(
                '[Polling] Timeout: Se superó el tiempo máximo de espera.');
            break;
          }
        } while (!isPlanReady);

        stopwatch.stop();

        // --- FIN CORRECCIÓN ---

        if (mounted) {
          Navigator.of(context).pop();
        }

        if (!mounted) return;

        if (isPlanReady) {
          // CASO 1: Éxito. El plan está listo.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const PlanSummaryScreen()),
            (route) => false,
          );
        } else {
          // CASO 2: Timeout. El plan no se generó a tiempo.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Tu plan está tardando más de lo esperado. Revisa en unos minutos desde la pantalla principal.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => const AuthCheckMain()), // O tu HomePage
            (route) => false,
          );
        }
        // ▲▲▲ FIN DE LA CORRECCIÓN ▲▲▲
      } catch (e, stackTrace) {
        debugPrint(
            '--- ¡ERROR ATRAPADO DURANTE LA ${widget.isEditing ? "ACTUALIZACIÓN" : "GENERACIÓN"} DEL PLAN! ---');
        debugPrint('Error: $e');
        debugPrint('Stack trace: $stackTrace');

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error al ${widget.isEditing ? "actualizar" : "generar"} tu plan: ${e.toString().replaceFirst("Exception: ", "")}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOut);
    }
  }

  // --- SE ELIMINA LA FUNCIÓN _hasSignificantChanges ---

  String? formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // CAMBIO 1: Mover la pantalla de presupuesto ANTES de la pantalla de alimentos favoritos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: FrutiaColors.disabledText.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ).animate().fadeIn(duration: 500.ms),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WelcomeScreen(isEditing: widget.isEditing),
                  const PersonalInfoScreen(),
                  const RoutineScreen(),
                  const AlimentacionScreen(),
                  const GustosScreen(), // ← AQUÍ está el presupuesto
                  const PreferredFoodsScreen(), // ← DESPUÉS los alimentos favoritos (usa el presupuesto)
                  const PreferencesScreen(),
                  const PersonalizacionScreen(),
                ],
              ),
            ),
            NavigationControls(
              pageController: _pageController,
              totalPages: _numPages,
              onPreviousPressed: () {
                if (_pageController.page! > 0) {
                  _pageController.previousPage(
                      duration: 400.ms, curve: Curves.easeOut);
                }
              },
              onNextOrFinishPressed: _handleNextOrFinish,
              isEditing: widget.isEditing,
            ),
          ],
        ),
      ),
    );
  }
}

class PreferredFoodsScreen extends StatefulWidget {
  const PreferredFoodsScreen({super.key});

  @override
  State<PreferredFoodsScreen> createState() => _PreferredFoodsScreenState();
}

class _PreferredFoodsScreenState extends State<PreferredFoodsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();

    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(
              title: 'Alimentos que más te gustan 🍴'),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selecciona tus favoritos para que aparezcan más en tu plan',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PROTEÍNAS
          _buildCategorySection(
            title: 'Proteínas',
            subtitle: 'Elige al menos 3',
            emoji: '🥩',
            selectedItems: provider.favoriteProteins,
            items: _getProteinOptions(provider.weeklyBudget),
            onToggle: (item) => setState(() {
              if (provider.favoriteProteins.contains(item)) {
                provider.update(() => provider.favoriteProteins.remove(item));
              } else {
                provider.update(() => provider.favoriteProteins.add(item));
              }
            }),
            selectAll: () => setState(() {
              provider.update(() => provider.favoriteProteins
                  .addAll(_getProteinOptions(provider.weeklyBudget)));
            }),
          ),

          const SizedBox(height: 24),

          // CARBOHIDRATOS
          _buildCategorySection(
            title: 'Carbohidratos',
            subtitle: 'Elige al menos 3',
            emoji: '🍚',
            selectedItems: provider.favoriteCarbs,
            items: _getCarbOptions(provider.weeklyBudget),
            onToggle: (item) => setState(() {
              if (provider.favoriteCarbs.contains(item)) {
                provider.update(() => provider.favoriteCarbs.remove(item));
              } else {
                provider.update(() => provider.favoriteCarbs.add(item));
              }
            }),
            selectAll: () => setState(() {
              provider.update(() => provider.favoriteCarbs
                  .addAll(_getCarbOptions(provider.weeklyBudget)));
            }),
          ),

          const SizedBox(height: 24),

          // GRASAS
          _buildCategorySection(
            title: 'Grasas',
            subtitle: 'Elige al menos 2',
            emoji: '🥑',
            selectedItems: provider.favoriteFats,
            items: _getFatOptions(provider.weeklyBudget),
            onToggle: (item) => setState(() {
              if (provider.favoriteFats.contains(item)) {
                provider.update(() => provider.favoriteFats.remove(item));
              } else {
                provider.update(() => provider.favoriteFats.add(item));
              }
            }),
            selectAll: () => setState(() {
              provider.update(() => provider.favoriteFats
                  .addAll(_getFatOptions(provider.weeklyBudget)));
            }),
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 24),

// FRUTAS (PARA SNACKS)
          _buildCategorySection(
            title: 'Frutas (para Snacks)',
            subtitle: 'Opcional',
            emoji: '🍓',
            selectedItems: provider.favoriteFruits, // ⭐ NUEVO CAMPO
            items: const [
              'Fresas',
              'Arándanos',
              'Moras',
              'Plátano',
              'Manzana',
              'Mango',
              'Sandía',
              'Pera',
            ],
            onToggle: (item) => setState(() {
              if (provider.favoriteFruits.contains(item)) {
                provider.update(() => provider.favoriteFruits.remove(item));
              } else {
                provider.update(() => provider.favoriteFruits.add(item));
              }
            }),
            selectAll: () => setState(() {
              provider.update(() => provider.favoriteFruits.addAll(const [
                    'Fresas',
                    'Arándanos',
                    'Moras',
                    'Plátano',
                    'Manzana',
                    'Mango',
                    'Sandía',
                    'Pera',
                  ]));
            }),
          ),

          const SizedBox(height: 24),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    required String subtitle,
    required String emoji,
    required Set<String> selectedItems,
    required List<String> items,
    required Function(String) onToggle,
    required VoidCallback selectAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: FrutiaColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: selectAll,
              child: Text(
                'Seleccionar todo',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return GestureDetector(
              onTap: () => onToggle(item),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? FrutiaColors.accent.withOpacity(0.1)
                      : FrutiaColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? FrutiaColors.accent : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: isSelected
                          ? FrutiaColors.accent
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? FrutiaColors.accent
                            : FrutiaColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> _getProteinOptions(String? budget) {
    final isLowBudget = budget?.toLowerCase().contains('bajo') ?? false;

    if (isLowBudget) {
      return const [
        'Huevo Entero',
        'Pollo Pechuga O Muslo',
        'Atún En Lata',
        'Carne Magra De Res',
        'Pescado Blanco',
      ];
    } else {
      return const [
        'Claras + Huevo Entero',
        'Pechuga De Pollo',
        'Filete Pavita',
        'Salmón Fresco',
        'Pescado Blanco',
        'Carne De Res Magra / Lomo Fino',
        'Yogurt Griego',
        'Proteína Whey',
        'Caseína',
      ];
    }
  }

  List<String> _getCarbOptions(String? budget) {
    final isLowBudget = budget?.toLowerCase().contains('bajo') ?? false;

    if (isLowBudget) {
      return const [
        'Arroz Blanco',
        'Papa',
        'Avena Tradicional',
        'Tortillas De Maíz',
        'Fideos/Pasta Básica',
        'Frijoles',
        'Camote',
        'Galleta De Arroz',
        'Crema De Arroz',
      ];
    } else {
      return const [
        'Quinua',
        'Arroz Blanco',
        'Avena Orgánica',
        'Pan Integral Artesanal',
        'Camote',
        'Papa',
        'Tortilla De Maíz',
        'Galleta De Arroz',
        'Crema De Arroz',
      ];
    }
  }

  List<String> _getFatOptions(String? budget) {
    final isLowBudget = budget?.toLowerCase().contains('bajo') ?? false;

    if (isLowBudget) {
      return const [
        'Aceite de oliva', // ⭐ CAMBIADO de 'Aceite Vegetal'
        'Maní / Mantequilla De Maní',
        'Aguacate Pequeño',
        'Semillas De Ajonjolí',
        'Aceitunas',
      ];
    } else {
      return const [
        'Aceite De Oliva Extra Virgen',
        'Aceite De Palta/Aguacate',
        'Almendras',
        'Nueces',
        'Aguacate Hass / Palta Hass',
        'Chía/Linaza Orgánicas',
        'Frutos Secos Premium',
        'Miel',
        'Chocolate 70%',
      ];
    }
  }
}

// --- RESTO DE LOS WIDGETS DE PANTALLA Y AYUDA ---
// (NavigationControls, WelcomeScreen, PersonalInfoScreen, etc. se quedan igual)

class NavigationControls extends StatelessWidget {
  final PageController pageController;
  final int totalPages;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextOrFinishPressed;
  final bool isEditing;

  const NavigationControls({
    super.key,
    required this.pageController,
    required this.totalPages,
    required this.onPreviousPressed,
    required this.onNextOrFinishPressed,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage =
        pageController.hasClients ? (pageController.page?.round() ?? 0) : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onPreviousPressed,
            child: Text(
              'Atrás',
              style: TextStyle(
                  color: currentPage > 0
                      ? FrutiaColors.secondaryText
                      : Colors.transparent),
            ),
          ),
          ElevatedButton(
            onPressed: onNextOrFinishPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: FrutiaColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(currentPage < totalPages - 1
                ? 'Continuar'
                : isEditing
                    ? 'Guardar Cambios'
                    : 'Finalizar'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class WelcomeScreen extends StatelessWidget {
  final bool isEditing;
  const WelcomeScreen({super.key, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    return QuestionnaireScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            isEditing
                ? '¡Modifica tu plan personalizado! 🌟'
                : '¡Listo para un plan hecho solo para ti! 🌟',
            style: GoogleFonts.lato(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText),
          ),
          const SizedBox(height: 16),
          Text(
            isEditing
                ? 'Actualiza tus respuestas para ajustar tu plan a tus nuevas necesidades. 📋'
                : 'Responde estas preguntas para armar tu plan ideal según tu vida real. 📋',
            style: GoogleFonts.lato(
                fontSize: 18, color: FrutiaColors.secondaryText, height: 1.5),
          ),
          Center(
            child: Lottie.asset(
              'assets/images/animacionPlan.json',
              width: 400,
              height: 400,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Desliza o presiona 'Continuar' ➡️",
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.disabledText),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(
          begin: -0.2,
          curve: Curves.easeOut,
        );
  }
}

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();
    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(title: 'Sobre ti 👤'),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('¿Tienes alguna condición médica? 🩺'),
            value: provider.hasMedicalCondition,
            onChanged: (val) => setState(() =>
                provider.update(() => provider.hasMedicalCondition = val)),
            activeColor: FrutiaColors.accent,
            secondary: const Text('👨‍⚕️', style: TextStyle(fontSize: 24)),
          ),
          if (provider.hasMedicalCondition)
            CustomTextField(
              label: 'Específica (ej. diabetes)',
              initialValue: provider.medicalConditionDetails,
              onChanged: (val) =>
                  provider.update(() => provider.medicalConditionDetails = val),
              errorText: validationErrors['medicalCondition'],
            ).animate().fadeIn(),
          const SizedBox(height: 24),
          const QuestionnaireTitle(title: 'Objetivo Principal', isSub: true),
          ..._buildGoalOptions(provider),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildGoalOptions(QuestionnaireProvider provider) {
    const goals = {
      '🔥 Bajar grasa',
      '💪 Aumentar músculo',
      '🥗 Comer más saludable',
      '📈 Mejorar rendimiento',
    };
    return goals
        .map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                  title: goal,
                  value: goal,
                  groupValue: provider.mainGoal,
                  onTap: (val) => setState(
                      () => provider.update(() => provider.mainGoal = val))),
            ))
        .toList();
  }
}

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});
  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(title: 'Tu Rutina 🏃‍♂️'),
          const SizedBox(height: 16),
          Text(
            '¿Qué deporte practicas? (puedes seleccionar varios) 🏀',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600, // Consistente con QuestionnaireTitle
              color: FrutiaColors.primaryText, // Usar color del tema
            ),
          ),
          const SizedBox(height: 16),
          SportSelection(
            name: 'sport',
            initialValue: provider.sport,
            onChanged: (List<String>? values) {
              provider.update(() => provider.sport = values ?? []);
            },
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24), // Consistente con otras pantallas
          const QuestionnaireTitle(
            title: '¿Cuál se parece más a tu semana?',
            isSub: true,
          ),
          const SizedBox(height: 12), // Consistente con otras pantallas
          ..._buildWeeklyActivityOptions(provider),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildWeeklyActivityOptions(QuestionnaireProvider provider) {
    const options = [
      'No me muevo y no entreno (Ej: oficina + sofá)',
      'Oficina + entreno 1-2 veces (Ej: gym lunes y jueves)',
      'Oficina + entreno 3-4 veces (Ej: gym lunes a jueves)',
      'Oficina + entreno 5-6 veces (Ej: gym casi todos los días)',
      'Trabajo activo + entreno 1-2 veces (Ej: mozo + gym 2 días)',
      'Trabajo activo + entreno 3-4 veces (Ej: mozo + gym 4 días)',
      'Trabajo muy físico + entreno 5-6 veces (Ej: construcción + gym diario)',
    ];
    return options
        .map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: opt,
                value: opt,
                groupValue: provider.weeklyActivity,
                onTap: (val) => setState(
                    () => provider.update(() => provider.weeklyActivity = val)),
              ),
            ))
        .toList();
  }

  Widget _buildChipOptions(
      List<String> options, String? groupValue, Function(String) updateFn) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8.0,
            runSpacing: 12.0,
            children: options.map((opt) {
              return ChoiceChip(
                label: Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        constraints.maxWidth * 0.9, // Limita el ancho máximo
                  ),
                  child: Text(
                    opt,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 3, // Permite hasta 3 líneas de texto
                    overflow: TextOverflow.ellipsis, // Maneja el desbordamiento
                    style: TextStyle(
                      fontSize: 14,
                      color: groupValue == opt
                          ? Colors.white
                          : FrutiaColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                selected: groupValue == opt,
                onSelected: (isSelected) => isSelected ? updateFn(opt) : null,
                backgroundColor: Colors.grey[200],
                selectedColor: FrutiaColors.accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class AlimentacionScreen extends StatefulWidget {
  const AlimentacionScreen({super.key});

  @override
  State<AlimentacionScreen> createState() => _AlimentacionScreenState();
}

class _AlimentacionScreenState extends State<AlimentacionScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(title: 'Tu Estructura de Comidas 🍽️'),
          const SizedBox(height: 16),
          const QuestionnaireTitle(
            title: '¿Cuándo prefieres tu snack? 🍎',
            isSub: true,
          ),
          const SizedBox(height: 8),
          Text(
            'Tu plan incluirá SOLO UN snack. Elige cuándo lo prefieres:',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: FrutiaColors.secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildSnackTimeOptions(provider),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: '¿A qué hora sueles comer? (opcional)', isSub: true),
          TimeSelectorCard(
            label: 'Desayuno',
            icon: Icons.light_mode_rounded,
            selectedTime: provider.breakfastTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.breakfastTime = time),
          ),
          const SizedBox(height: 16),
          TimeSelectorCard(
            label: 'Almuerzo',
            icon: Icons.wb_sunny_rounded,
            selectedTime: provider.lunchTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.lunchTime = time),
          ),
          const SizedBox(height: 16),
          TimeSelectorCard(
            label: 'Cena',
            icon: Icons.dark_mode_rounded,
            selectedTime: provider.dinnerTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.dinnerTime = time),
          ),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: '¿Con qué frecuencia comes fuera de casa? 🍔',
              isSub: true),
          ..._buildEatOutOptions(provider),
        ],
      ),
    );
  }

  List<Widget> _buildSnackTimeOptions(QuestionnaireProvider provider) {
    final options = [
      {
        'value': 'Snack AM',
        'title': 'Media mañana (Snack AM)',
        'subtitle': 'Entre desayuno y almuerzo',
      },
      {
        'value': 'Snack PM',
        'title': 'Media tarde (Snack PM)',
        'subtitle': 'Entre almuerzo y cena',
      },
    ];

    return options.map((option) {
      final isSelected = provider.preferredSnackTime == option['value'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: InkWell(
          onTap: () => setState(() => provider.update(
              () => provider.preferredSnackTime = option['value'] as String)),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? FrutiaColors.accent.withOpacity(0.1)
                  : FrutiaColors.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? FrutiaColors.accent : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? FrutiaColors.accent : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['title'] as String,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? FrutiaColors.accent
                              : FrutiaColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['subtitle'] as String,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: FrutiaColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildEatOutOptions(QuestionnaireProvider provider) {
    const options = {
      '🍔 Casi todos los días',
      '🍎 A veces (2 a 4 veces por semana)',
      '🥗 Rara vez (1 vez por semana o menos)',
      '🚫 Nunca',
    };
    return options
        .map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: opt,
                value: opt,
                groupValue: provider.eatsOut,
                onTap: (val) => setState(
                    () => provider.update(() => provider.eatsOut = val)),
              ),
            ))
        .toList();
  }
}

class GustosScreen extends StatefulWidget {
  const GustosScreen({super.key});
  @override
  State<GustosScreen> createState() => _GustosScreenState();
}

class _GustosScreenState extends State<GustosScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<QuestionnaireProvider>();
    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(
              title: 'Gustos, alergias y estilo alimentario 🥗'),
          const QuestionnaireTitle(
              title: '¿Qué alimentos NO te gusta?', isSub: true),
          CustomTextField(
            label: 'Ej: brócoli, hígado, etc.',
            initialValue: provider.dislikedFoods,
            onChanged: (val) =>
                provider.update(() => provider.dislikedFoods = val),
            emoji: "🚫",
          ),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: '¿Tienes alguna alergia alimentaria? 🚨', isSub: true),
          SwitchListTile.adaptive(
            title: Text(provider.hasAllergies
                ? 'Sí, tengo alergias 😷'
                : 'No, ninguna ✅'),
            value: provider.hasAllergies,
            onChanged: (val) {
              setState(() {
                provider.update(() {
                  provider.hasAllergies = val;
                  if (!val) provider.allergyDetails = '';
                });
              });
            },
            activeColor: FrutiaColors.accent,
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.warning_amber),
          ),
          if (provider.hasAllergies)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomTextField(
                label: 'Especifícalas aquí',
                initialValue: provider.allergyDetails,
                onChanged: (val) =>
                    provider.update(() => provider.allergyDetails = val),
                errorText: validationErrors['allergyDetails'],
              ),
            ).animate().fadeIn(),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: '¿Sigues algún estilo de alimentación?', isSub: true),
          _DietaryStyleSelection(),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title:
                  '¿Con qué tipo de presupuesto cuentas para tu alimentación semanal? 💰',
              isSub: true),
          ..._buildBudgetOptions(provider),
        ],
      ),
    );
  }

  List<Widget> _buildBudgetOptions(QuestionnaireProvider provider) {
    const options = [
      '💸 Bajo - Solo lo básico (Ej: arroz, huevo, lentejas)',
      '💳 Alto - Sin restricciones (Ej: salmón, proteína, superfoods)',
    ];
    return options
        .map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: option,
                value: option,
                groupValue: provider.weeklyBudget,
                onTap: (val) => setState(
                    () => provider.update(() => provider.weeklyBudget = val)),
              ),
            ))
        .toList();
  }
}

class _DietaryStyleSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();
    final _flowState =
        context.findAncestorStateOfType<_QuestionnaireFlowState>();
    const predefinedStyles = {
      '🍖 Omnívoro': 'Omnívoro',
      '🥕 Vegetariano': 'Vegetariano',
      '🌱 Vegano': 'Vegano',
      '🥚 Keto': 'Keto',
    };
    bool isOtherSelected = provider.dietStyle != null &&
        !predefinedStyles.keys.contains(provider.dietStyle!);
    String? customDietStyleText = isOtherSelected ? provider.dietStyle : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ...predefinedStyles.entries.map((entry) {
              return ChoiceChipCard(
                label: entry.key,
                isSelected: provider.dietStyle == entry.key,
                onTap: () =>
                    provider.update(() => provider.dietStyle = entry.key),
              );
            }).toList(),
            ChoiceChipCard(
              label: '✍️ Otro',
              isSelected: isOtherSelected,
              onTap: () => provider.update(() => provider.dietStyle = ''),
            ),
          ],
        ),
        if (isOtherSelected)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CustomTextField(
              label: '✏️ Especifica tu estilo',
              initialValue: customDietStyleText,
              onChanged: (newValue) =>
                  provider.update(() => provider.dietStyle = newValue),
              errorText: _flowState?._validationErrors['dietaryStyle'],
            ),
          ),
      ],
    );
  }
}

class PersonalizacionScreen extends StatefulWidget {
  const PersonalizacionScreen({super.key});
  @override
  State<PersonalizacionScreen> createState() => _PersonalizacionScreenState();
}

class _PersonalizacionScreenState extends State<PersonalizacionScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<QuestionnaireProvider>();
    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};
    String? initialOtraDificultad = provider.dietDifficulties
        .firstWhere((item) => item.startsWith('Otra: '), orElse: () => '');
    String cleanedOtraDificultad = initialOtraDificultad.isNotEmpty
        ? initialOtraDificultad.replaceFirst('Otra: ', '')
        : '';

    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(
              title: 'Personalización emocional (opcional) 🌟'),
          const QuestionnaireTitle(
              title:
                  '¿Qué es lo que más te cuesta mantener en un plan de alimentación?',
              isSub: true),
          ..._buildCheckboxOptions(
            provider.dietDifficulties,
            {
              'Mantenerme constante 🔄': 'Mantenerme constante',
              'Saber qué comer cuando no tengo lo del plan 🤔':
                  'Saber qué comer cuando no tengo lo del plan',
              'Comer saludable fuera de casa 🍽️':
                  'Comer saludable fuera de casa',
              'Controlar los antojos 🍫': 'Controlar los antojos',
              'Preparar la comida 🧑‍🍳': 'Preparar la comida',
              'Otra ✍️': 'Otra',
            },
            validationErrors['otraDificultad'],
          ),
          if (provider.dietDifficulties.contains('Otra ✍️'))
            Padding(
              padding: const EdgeInsets.only(left: 28.0, top: 8.0),
              child: CustomTextField(
                label: 'Especifica',
                initialValue: cleanedOtraDificultad,
                onChanged: (val) => provider.update(() {
                  provider.dietDifficulties
                      .removeWhere((item) => item.startsWith('Otra: '));
                  if (val.isNotEmpty) {
                    provider.dietDifficulties.add('Otra: $val');
                  }
                }),
                errorText: validationErrors['otraDificultad'],
              ),
            ).animate().fadeIn(),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title:
                  '¿Qué es lo que más te motiva a seguir un plan de alimentación?',
              isSub: true),
          ..._buildCheckboxOptions(
            provider.dietMotivations,
            {
              'Ver resultados rápidos ⚡': 'Ver resultados rápidos',
              'Sentirme mejor físicamente (energía, digestión, menos pesadez) 💪':
                  'Sentirme mejor físicamente (energía, digestión, menos pesadez)',
              'Demostrarme que puedo lograrlo 💯':
                  'Demostrarme que puedo lograrlo',
              'Mejorar mi salud a largo plazo 🏥':
                  'Mejorar mi salud a largo plazo',
              'Aún no lo tengo claro ❓': 'Aún no lo tengo claro',
            },
            null,
          ),
          const SizedBox(height: 24),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildCheckboxOptions(
    Set<String> selectedValues,
    Map<String, String> optionMap,
    String? errorText,
  ) {
    return optionMap.entries
        .map((entry) => CheckboxListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(entry.key),
              value: selectedValues.contains(entry.key),
              onChanged: (value) {
                setState(() {
                  context.read<QuestionnaireProvider>().update(() {
                    if (value ?? false) {
                      selectedValues.add(entry.key);
                    } else {
                      selectedValues.remove(entry.key);
                      if (entry.key == 'Otra ✍️') {
                        selectedValues
                            .removeWhere((item) => item.startsWith('Otra: '));
                      }
                    }
                  });
                });
              },
              activeColor: FrutiaColors.accent,
            ))
        .toList();
  }
}

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<QuestionnaireProvider>();
    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(title: 'Tus Preferencias 🌟'),
          const QuestionnaireTitle(
              title: '¿Cómo prefieres que me comunique contigo?', isSub: true),
          ..._buildSelectionCards(provider.communicationTone,
              (val) => provider.update(() => provider.communicationTone = val)),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: '¿Cómo te gustaría que te llame?', isSub: true),
          CustomTextField(
            label: 'Tu nombre o apodo',
            initialValue: provider.preferredName,
            onChanged: (val) =>
                provider.update(() => provider.preferredName = val),
            errorText: validationErrors['preferredName'],
          ),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildSelectionCards(
      String? groupValue, Function(String?) updateFn) {
    const optionMap = {
      'Motivadora (que te empuje a dar más cuando lo necesites) 🏋️':
          'Motivadora (que te empuje a dar más cuando lo necesites)',
      'Cercana (como un amigo que te acompaña sin presión) 😊':
          'Cercana (como un amigo que te acompaña sin presión)',
      'Directa (clara, sin vueltas ni frases suaves) 🤗':
          'Directa (clara, sin vueltas ni frases suaves)',
      'Como te salga a ti, yo me adapto 🔄': 'Como te salga a ti, yo me adapto',
    };
    return optionMap.entries
        .map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: entry.key,
                value: entry.key,
                groupValue: groupValue,
                onTap: (val) => setState(() => updateFn(val)),
              ),
            ))
        .toList();
  }
}

class QuestionnaireScreen extends StatelessWidget {
  final Widget child;
  const QuestionnaireScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _FloatingParticles()),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: child,
        ),
      ],
    );
  }
}

final Color titleColor = const Color.fromARGB(221, 205, 104, 104);

class QuestionnaireTitleARRIBA extends StatefulWidget {
  final String title;
  final bool isSub;

  const QuestionnaireTitleARRIBA({
    Key? key,
    required this.title,
    this.isSub = false,
  }) : super(key: key);

  @override
  _QuestionnaireTitleARRIBAState createState() =>
      _QuestionnaireTitleARRIBAState();
}

class _QuestionnaireTitleARRIBAState extends State<QuestionnaireTitleARRIBA>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: widget.isSub ? 12 : 24, top: widget.isSub ? 10 : 0),
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade100,
                Colors.orange.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (Colors.orange).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            widget.title,
            style: GoogleFonts.lato(
              fontSize: widget.isSub ? 20 : 24,
              fontWeight: widget.isSub ? FontWeight.w600 : FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionnaireTitle extends StatelessWidget {
  final String title;
  final bool isSub;
  const QuestionnaireTitle({Key? key, required this.title, this.isSub = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSub ? 12 : 24, top: isSub ? 10 : 0),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: isSub ? 20 : 24,
          fontWeight: isSub ? FontWeight.w600 : FontWeight.bold,
          color: titleColor,
        ),
      ),
    );
  }
}

class OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(String) onTap;
  const OptionChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? Colors.white : FrutiaColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: selected ? FrutiaColors.accent : Colors.grey[200]!,
        side: BorderSide(
          color: selected ? FrutiaColors.accent : Colors.grey[300]!,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles({Key? key}) : super(key: key);

  @override
  __FloatingParticlesState createState() => __FloatingParticlesState();
}

class __FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 2,
        speed: _random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlesPainter(_particles, _controller.value),
        );
      },
    );
  }
}

class Particle {
  double x, y, size, speed;
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double time;

  _ParticlesPainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final x = (particle.x + time * particle.speed) % 1.0 * size.width;
      final y = (particle.y + time * particle.speed * 0.5) % 1.0 * size.height;
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
