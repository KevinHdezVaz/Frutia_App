import 'dart:convert';
import 'dart:math';

import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/l10n/food_translations.dart';
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
import 'package:Frutia/utils/normalizers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// Importa tu QuestionnaireProvider (asegúrate de que la ruta sea correcta)
import 'package:Frutia/providers/QuestionnaireProvider.dart';
import 'package:Frutia/providers/locale_provider.dart'; // ⭐ NUEVO: Importar LocaleProvider
import 'package:Frutia/utils/LocaleHelper.dart'; // ⭐ NUEVO: Importar LocaleHelper

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
        final locale =
            Localizations.localeOf(context).languageCode; // ⭐ OBTENER LOCALE

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
          provider.favoriteProteins = Set<String>.from(
              FoodTranslations.listToDisplayNames(
                  List<String>.from(profile['favorite_proteins'] ?? []),
                  locale));

          provider.favoriteCarbs = Set<String>.from(
              FoodTranslations.listToDisplayNames(
                  List<String>.from(profile['favorite_carbs'] ?? []), locale));

          provider.favoriteFats = Set<String>.from(
              FoodTranslations.listToDisplayNames(
                  List<String>.from(profile['favorite_fats'] ?? []), locale));

          provider.favoriteFruits = Set<String>.from(
              FoodTranslations.listToDisplayNames(
                  List<String>.from(profile['favorite_fruits'] ?? []), locale));
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    setState(() => _validationErrors = {});
    bool isValid = true;
    List<String> errorMessages = [];

    switch (currentPage) {
      case 1:
        if (provider.mainGoal == null) {
          errorMessages.add(l10n.selectMainGoal); // ⭐ TRADUCIDO
          isValid = false;
        }
        if (provider.hasMedicalCondition &&
            provider.medicalConditionDetails.isEmpty) {
          _validationErrors['medicalCondition'] =
              l10n.specifyMedicalCondition; // ⭐ TRADUCIDO
          isValid = false;
        }
        break;
      case 2:
        if (provider.sport.isEmpty) {
          errorMessages.add(l10n.selectAtLeastOneSport); // ⭐ TRADUCIDO
        }
        isValid = errorMessages.isEmpty;
        break;

      case 3:
        if (provider.preferredSnackTime == null) {
          errorMessages.add(l10n.selectWhenPreferSnack); // ⭐ TRADUCIDO
          isValid = false;
        }
        if (provider.eatsOut == null) {
          errorMessages.add(l10n.selectHowOftenEatOut); // ⭐ TRADUCIDO
        }
        isValid = errorMessages.isEmpty;
        break;
      case 4:
        if (provider.dietStyle == null || provider.dietStyle!.isEmpty) {
          errorMessages.add(l10n.selectDietaryStyle); // ⭐ TRADUCIDO
        }
        if (provider.hasAllergies && provider.allergyDetails.isEmpty) {
          _validationErrors['allergyDetails'] =
              l10n.specifyFoodAllergies; // ⭐ TRADUCIDO
          isValid = false;
        }
        if (provider.weeklyBudget == null) {
          errorMessages.add(l10n.selectWeeklyBudget); // ⭐ TRADUCIDO
        }
        isValid = errorMessages.isEmpty && _validationErrors.isEmpty;
        break;

      case 5:
        if (provider.favoriteFruits.isEmpty) {
          errorMessages.add(l10n.selectAtLeastOneFavoriteFruit); // ⭐ TRADUCIDO
        }
        isValid = errorMessages.isEmpty;
        break;

      case 6:
        if (provider.communicationTone == null) {
          errorMessages.add(l10n.selectCommunicationStyle); // ⭐ TRADUCIDO
        }
        isValid = errorMessages.isEmpty;
        break;
      case 7:
        if (provider.dietDifficulties.isEmpty) {
          errorMessages.add(l10n.selectAtLeastOneDifficulty); // ⭐ TRADUCIDO
        }
        if (provider.dietDifficulties.contains('Otra ✍️')) {
          bool otraEspecificada = provider.dietDifficulties.any((item) =>
              item.startsWith('Otra: ') && item.length > 'Otra: '.length);
          if (!otraEspecificada) {
            _validationErrors['otraDificultad'] =
                l10n.specifyOtherDifficulty; // ⭐ TRADUCIDO
            isValid = false;
          }
        }
        if (provider.dietMotivations.isEmpty) {
          errorMessages.add(l10n.selectAtLeastOneMotivation); // ⭐ TRADUCIDO
        }
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

  void _handleNextOrFinish() async {
    if (!_validateCurrentPage()) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    if (_pageController.page!.round() == _numPages - 1) {
      final locale = Localizations.localeOf(context).languageCode;
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
        final List<String> normalizedDifficulties =
            cleanDietDifficulties.map((item) {
          if (item.startsWith('Otra: ')) return item;
          return normalizeToSpanish(item, 'diet_difficulties');
        }).toList();
        final List<String> normalizedMotivations =
            cleanDietMotivations.map((item) {
          return normalizeToSpanish(item, 'diet_motivations');
        }).toList();
        final List<String> normalizedProteins =
            questionnaireProvider.favoriteProteins.map((item) {
          return normalizeToSpanish(item, 'favorite_proteins');
        }).toList();
        final List<String> normalizedCarbs =
            questionnaireProvider.favoriteCarbs.map((item) {
          return normalizeToSpanish(item, 'favorite_carbs');
        }).toList();
        final List<String> normalizedFats =
            questionnaireProvider.favoriteFats.map((item) {
          return normalizeToSpanish(item, 'favorite_fats');
        }).toList();
        final List<String> normalizedFruits =
            questionnaireProvider.favoriteFruits.map((item) {
          return normalizeToSpanish(item, 'favorite_fruits');
        }).toList();
        final String? normalizedDisliked = questionnaireProvider
                .dislikedFoods.isNotEmpty
            ? normalizeToSpanish(
                questionnaireProvider.dislikedFoods.trim(), 'disliked_foods')
            : null;
        final profileData = {
          'name': (questionnaireProvider.name ?? '').trim().isNotEmpty
              ? (questionnaireProvider.name ?? '').trim()
              : null,
          'goal': normalizeToSpanish(questionnaireProvider.mainGoal, 'goal'),
          'weekly_activity': normalizeToSpanish(
              questionnaireProvider.weeklyActivity, 'weekly_activity'),
          'dietary_style': normalizeToSpanish(
              questionnaireProvider.dietStyle, 'dietary_style'),
          'budget':
              normalizeToSpanish(questionnaireProvider.weeklyBudget, 'budget'),
          'eats_out':
              normalizeToSpanish(questionnaireProvider.eatsOut, 'eats_out'),
          'communication_style': normalizeToSpanish(
              questionnaireProvider.communicationTone, 'communication_style'),
          'sex': normalizeToSpanish(
              questionnaireProvider.sex ?? 'masculino', 'sex'),
          'favorite_proteins':
              normalizedProteins.isNotEmpty ? normalizedProteins : null,
          'favorite_carbs': normalizedCarbs.isNotEmpty ? normalizedCarbs : null,
          'favorite_fats': normalizedFats.isNotEmpty ? normalizedFats : null,
          'favorite_fruits':
              normalizedFruits.isNotEmpty ? normalizedFruits : null,
          'diet_difficulties':
              normalizedDifficulties.isNotEmpty ? normalizedDifficulties : null,
          'diet_motivations':
              normalizedMotivations.isNotEmpty ? normalizedMotivations : null,
          'disliked_foods': normalizedDisliked,
          'has_allergies': questionnaireProvider.hasAllergies,
          'allergies': questionnaireProvider.allergyDetails.isNotEmpty
              ? questionnaireProvider.allergyDetails.trim()
              : null,
          'has_medical_condition': questionnaireProvider.hasMedicalCondition,
          'medical_condition':
              questionnaireProvider.medicalConditionDetails.isNotEmpty
                  ? questionnaireProvider.medicalConditionDetails.trim()
                  : null,
          'preferred_name':
              questionnaireProvider.preferredName?.trim().isNotEmpty == true
                  ? questionnaireProvider.preferredName!.trim()
                  : null,
          'sport': questionnaireProvider.sport.isNotEmpty
              ? questionnaireProvider.sport
                  .map((s) => normalizeToSpanish(s, 'sport'))
                  .toList()
              : null,
          'preferred_snack_time': questionnaireProvider.preferredSnackTime,
          'breakfast_time':
              formatTimeOfDay(questionnaireProvider.breakfastTime),
          'lunch_time': formatTimeOfDay(questionnaireProvider.lunchTime),
          'dinner_time': formatTimeOfDay(questionnaireProvider.dinnerTime),
          'plan_setup_complete': true,
        };
        debugPrint(
            '📤 Enviando al backend (normalizado): ${jsonEncode(profileData)}');
        await ProfileService().saveProfile(profileData);
        final requestTime = DateTime.now();
        await PlanService().generatePlan(languageCode: locale);
        bool isPlanReady = false;
        const maxWaitTime = Duration(minutes: 10);
        final stopwatch = Stopwatch()..start();
        do {
          await Future.delayed(const Duration(seconds: 3));
          final status = await PlanService().checkPlanStatus(requestTime);
          debugPrint(
              '[Polling] Chequeando estado del plan... Respuesta: $status');
          if (status == 'ready') {
            isPlanReady = true;
            break;
          }
          if (stopwatch.elapsed > maxWaitTime) {
            debugPrint(
                '[Polling] Timeout: Se superó el tiempo máximo de espera.');
            break;
          }
        } while (!isPlanReady);
        stopwatch.stop();
        if (mounted) {
          Navigator.of(context).pop();
        }
        if (!mounted) return;
        if (isPlanReady) {
          final String userDisplayName =
              questionnaireProvider.preferredName?.isNotEmpty == true
                  ? questionnaireProvider.preferredName!
                  : questionnaireProvider.name.isNotEmpty
                      ? questionnaireProvider.name
                      : 'Usuario';
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => PlanSummaryScreen(userName: userDisplayName),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.planTakingLonger),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthCheckMain()),
            (route) => false,
          );
        }
      } catch (e, stackTrace) {
        debugPrint(
            '--- ¡ERROR ATRAPADO DURANTE LA ${widget.isEditing ? "ACTUALIZACIÓN" : "GENERACIÓN"} DEL PLAN! ---');
        debugPrint('Error: $e');
        debugPrint('Stack trace: $stackTrace');
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? l10n.errorUpdatingPlan(
                      e.toString().replaceFirst("Exception: ", ""))
                  : l10n.errorGeneratingPlan(
                      e.toString().replaceFirst("Exception: ", ""))),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOut);
    }
  }

  String normalizeSexForBackend(String? sex) {
    if (sex == null || sex.isEmpty) return 'masculino'; // default

    final s = sex.toLowerCase().trim();

    if (['masculino', 'male', 'hombre', 'm', 'man'].any((v) => s.contains(v))) {
      return 'masculino';
    }

    if (['femenino', 'female', 'mujer', 'f', 'woman']
        .any((v) => s.contains(v))) {
      return 'femenino';
    }

    return 'masculino'; // default seguro
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES
    final locale =
        Localizations.localeOf(context).languageCode; // ⭐ OBTENER LOCALE

    final budget = provider.weeklyBudget;
    final dietStyle = provider.dietStyle;

    if (budget == null || dietStyle == null) {
      return QuestionnaireScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuestionnaireTitleARRIBA(
                title: l10n.foodsYouLikemost), // ⭐ TRADUCIDO

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Por favor, completa las pantallas anteriores primero:\n• Presupuesto\n• Estilo alimentario',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionnaireTitleARRIBA(title: l10n.foodsYouLikemost), // ⭐ TRADUCIDO

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
                    l10n.selectFavoritesToAppearMore, // ⭐ TRADUCIDO
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
          _buildCategorySection(
            title: l10n.proteins, // ⭐ TRADUCIDO
            subtitle: l10n.chooseAtLeastThree, // ⭐ TRADUCIDO
            emoji: '🥩',
            selectedItems: provider.favoriteProteins,
            items:
                _getProteinOptions(budget, dietStyle, locale), // ⭐ PASAR LOCALE
            onToggle: (item) => setState(() {
              if (provider.favoriteProteins.contains(item)) {
                provider.update(() => provider.favoriteProteins.remove(item));
              } else {
                provider.update(() => provider.favoriteProteins.add(item));
              }
            }),
            selectAll: () => setState(() {
              provider.update(() => provider.favoriteProteins
                  .addAll(_getProteinOptions(budget, dietStyle, locale)));
            }),
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            title: l10n.carbohydrates, // ⭐ TRADUCIDO
            subtitle: l10n.chooseAtLeastThree, // ⭐ TRADUCIDO
            emoji: '🍚',
            selectedItems: provider.favoriteCarbs,
            items: _getCarbOptions(budget, dietStyle, locale), // ⭐ PASAR LOCALE
            onToggle: (item) => setState(() {
              if (provider.favoriteCarbs.contains(item)) {
                provider.update(() => provider.favoriteCarbs.remove(item));
              } else {
                provider.update(() => provider.favoriteCarbs.add(item));
              }
            }),
            selectAll: () => setState(() {
              provider.update(() => provider.favoriteCarbs
                  .addAll(_getCarbOptions(budget, dietStyle, locale)));
            }),
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            title: l10n.fats, // ⭐ TRADUCIDO
            subtitle: l10n.chooseAtLeastTwo, // ⭐ TRADUCIDO
            emoji: '🥑',
            selectedItems: provider.favoriteFats,
            items: _getFatOptions(budget, dietStyle, locale), // ⭐ PASAR LOCALE
            onToggle: (item) => setState(() {
              if (provider.favoriteFats.contains(item)) {
                provider.update(() => provider.favoriteFats.remove(item));
              } else {
                provider.update(() => provider.favoriteFats.add(item));
              }
            }),
            selectAll: () => setState(() {
              provider.update(() => provider.favoriteFats
                  .addAll(_getFatOptions(budget, dietStyle, locale)));
            }),
          ),
          const SizedBox(height: 24),
          _buildCategorySection(
            title: l10n.fruitsForSnacks, // ⭐ TRADUCIDO
            subtitle: l10n.optional, // ⭐ TRADUCIDO
            emoji: '🍓',
            selectedItems: provider.favoriteFruits,
            items: _getFruitOptions(locale), // ⭐ NUEVO MÉTODO
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
    final l10n = AppLocalizations.of(context)!;

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
                l10n.selectAll, // ⭐ TRADUCIDO

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

  List<String> _getProteinOptions(
      String budget, String dietStyle, String locale) {
    final l10n = AppLocalizations.of(context)!;
    final isLowBudget = budget.toLowerCase().contains('bajo') ||
        budget.toLowerCase().contains('low');
    final dietLower = dietStyle.toLowerCase();

    if (dietLower.contains('vegano') || dietLower.contains('vegan')) {
      return [
        l10n.tofu,
        l10n.tempeh,
        l10n.seitan,
        l10n.lentils,
        l10n.chickpeas,
        l10n.beans,
        l10n.plantProteinPowder,
      ];
    } else if (dietLower.contains('vegetariano') ||
        dietLower.contains('vegetarian')) {
      if (isLowBudget) {
        return [
          l10n.wholeEgg,
          l10n.naturalYogurt,
          l10n.freshCheese,
          l10n.lentils,
          l10n.chickpeas,
          l10n.beans,
        ];
      } else {
        return [
          l10n.wholeEgg,
          l10n.greekYogurt,
          l10n.cottageCheese,
          l10n.panelaCheese,
          l10n.ricotta,
          l10n.tempeh,
          l10n.tofu,
          l10n.plantProteinPowder,
        ];
      }
    } else if (dietLower.contains('keto')) {
      if (isLowBudget) {
        return [
          l10n.wholeEgg,
          l10n.chickenThighWithSkin,
          l10n.groundBeef8020,
        ];
      } else {
        return [
          l10n.salmon,
          l10n.ribeye,
          l10n.duckBreast,
          l10n.wholeEgg,
          l10n.agedCheese,
        ];
      }
    } else {
      // Omnívoro
      if (isLowBudget) {
        return [
          l10n.wholeEgg,
          l10n.chickenBreastOrThigh,
          l10n.cannedTuna,
          l10n.leanBeef,
          l10n.whiteFish,
        ];
      } else {
        return [
          l10n.eggWhitesWholeEgg,
          l10n.chickenBreast,
          l10n.turkeyBreast,
          l10n.freshSalmon,
          l10n.whiteFish,
          l10n.leanBeef,
          l10n.greekYogurt,
          l10n.wheyProtein,
          l10n.casein,
        ];
      }
    }
  }

  List<String> _getCarbOptions(String budget, String dietStyle, String locale) {
    final l10n = AppLocalizations.of(context)!;
    final isLowBudget = budget.toLowerCase().contains('bajo') ||
        budget.toLowerCase().contains('low');
    final dietLower = dietStyle.toLowerCase();

    if (dietLower.contains('keto')) {
      return [
        l10n.broccoli,
        l10n.cauliflower,
        l10n.spinach,
        l10n.lettuce,
        l10n.zucchini,
      ];
    } else if (isLowBudget) {
      return [
        l10n.whiteRice,
        l10n.potato,
        l10n.traditionalOats,
        l10n.cornTortillas,
        l10n.basicNoodlesPasta,
        l10n.beans,
        l10n.sweetPotato,
        l10n.riceCrackers,
        l10n.creamOfRice,
      ];
    } else {
      return [
        l10n.quinoa,
        l10n.whiteRice,
        l10n.organicOats,
        l10n.artisanWholeWheatBread,
        l10n.sweetPotato,
        l10n.potato,
        l10n.cornTortillas,
        l10n.riceCrackers,
        l10n.creamOfRice,
      ];
    }
  }

  List<String> _getFatOptions(String budget, String dietStyle, String locale) {
    final l10n = AppLocalizations.of(context)!;
    final isLowBudget = budget.toLowerCase().contains('bajo') ||
        budget.toLowerCase().contains('low');
    final dietLower = dietStyle.toLowerCase();

    if (dietLower.contains('vegano') || dietLower.contains('vegan')) {
      if (isLowBudget) {
        return [
          l10n.oliveOil,
          l10n.peanutsPeanutButter,
          l10n.smallAvocado,
          l10n.sesameSeeds,
        ];
      } else {
        return [
          l10n.extraVirginOliveOil,
          l10n.avocadoOil,
          l10n.almonds,
          l10n.walnuts,
          l10n.hassAvocado,
          l10n.organicChiaFlax,
          l10n.premiumNuts,
        ];
      }
    } else if (dietLower.contains('keto')) {
      if (isLowBudget) {
        return [
          l10n.lard,
          l10n.butter,
          l10n.avocado,
          l10n.oliveOil,
        ];
      } else {
        return [
          l10n.mctOil,
          l10n.gheeButter,
          l10n.hassAvocado,
          l10n.extraVirginOliveOil,
          l10n.agedCheese,
        ];
      }
    } else {
      if (isLowBudget) {
        return [
          l10n.oliveOil,
          l10n.peanutsPeanutButter,
          l10n.smallAvocado,
          l10n.sesameSeeds,
          l10n.olives,
        ];
      } else {
        return [
          l10n.extraVirginOliveOil,
          l10n.avocadoHassAvocado,
          l10n.almonds,
          l10n.walnuts,
          l10n.organicChiaFlax,
          l10n.premiumNuts,
          l10n.honey,
          l10n.darkChocolate70,
        ];
      }
    }
  }

  // ⭐ NUEVO MÉTODO: Frutas traducidas
  List<String> _getFruitOptions(String locale) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.strawberries,
      l10n.blueberries,
      l10n.blackberries,
      l10n.banana,
      l10n.apple,
      l10n.mango,
      l10n.watermelon,
      l10n.pear,
    ];
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

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
              l10n.back, // ⭐ TRADUCIDO
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
                    ? l10n.continue_ // ⭐ TRADUCIDO
                    : isEditing
                        ? l10n.saveChanges // ⭐ TRADUCIDO
                        : l10n.finish // ⭐ TRADUCIDO
                ),
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    return QuestionnaireScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            isEditing
                ? l10n.modifyYourPersonalizedPlan // ⭐ TRADUCIDO
                : l10n.readyForPersonalizedPlan,
            style: GoogleFonts.lato(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText),
          ),
          const SizedBox(height: 16),
          Text(
            isEditing
                ? l10n.updateAnswersToAdjust // ⭐ TRADUCIDO
                : l10n.answerQuestionsForIdealPlan,
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
              l10n.swipeOrPressContinue, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionnaireTitleARRIBA(title: l10n.aboutYou), // ⭐ TRADUCIDO
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.doYouHaveMedicalCondition), // ⭐ TRADUCIDO
            value: provider.hasMedicalCondition,
            onChanged: (val) => setState(() =>
                provider.update(() => provider.hasMedicalCondition = val)),
            activeColor: FrutiaColors.accent,
            secondary: const Text('👨‍⚕️', style: TextStyle(fontSize: 24)),
          ),
          if (provider.hasMedicalCondition)
            CustomTextField(
              label: l10n.specifySuchAs, // ⭐ TRADUCIDO
              initialValue: provider.medicalConditionDetails,
              onChanged: (val) =>
                  provider.update(() => provider.medicalConditionDetails = val),
              errorText: validationErrors['medicalCondition'],
            ).animate().fadeIn(),
          const SizedBox(height: 24),
          QuestionnaireTitle(title: l10n.mainGoal, isSub: true), // ⭐ TRADUCIDO
          ..._buildGoalOptions(provider),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildGoalOptions(QuestionnaireProvider provider) {
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final goals = {
      l10n.loseBodyFat, // ⭐ TRADUCIDO
      l10n.gainMuscle, // ⭐ TRADUCIDO
      l10n.eatHealthier, // ⭐ TRADUCIDO
      l10n.improvePerformance, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionnaireTitleARRIBA(title: l10n.yourRoutine), // ⭐ TRADUCIDO
          const SizedBox(height: 16),
          Text(
            l10n.whatSportsDoYouPractice, // ⭐ TRADUCIDO
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
          QuestionnaireTitle(
            title: l10n.whichMostLikeYourWeek, // ⭐ TRADUCIDO
            isSub: true,
          ),
          const SizedBox(height: 12), // Consistente con otras pantallas
          ..._buildWeeklyActivityOptions(provider),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildWeeklyActivityOptions(QuestionnaireProvider provider) {
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES
    final options = [
      l10n.noMoveNoTrain, // ⭐ TRADUCIDO
      l10n.officeTrainOneTwoTimes, // ⭐ TRADUCIDO
      l10n.officeTrainThreeFourTimes, // ⭐ TRADUCIDO
      l10n.officeTrainFiveSixTimes, // ⭐ TRADUCIDO
      l10n.activeWorkTrainOneTwoTimes, // ⭐ TRADUCIDO
      l10n.activeWorkTrainThreeFourTimes, // ⭐ TRADUCIDO
      l10n.veryPhysicalWorkTrainFiveSixTimes, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionnaireTitleARRIBA(
              title: l10n.yourMealStructure), // ⭐ TRADUCIDO
          const SizedBox(height: 16),
          QuestionnaireTitle(
            title: l10n.whenPreferSnack, // ⭐ TRADUCIDO
            isSub: true,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.planIncludesOneSnack, // ⭐ TRADUCIDO

            style: GoogleFonts.lato(
              fontSize: 14,
              color: FrutiaColors.secondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildSnackTimeOptions(provider),
          const SizedBox(height: 24),
          QuestionnaireTitle(
            title: l10n.whatTimeDoYouUsuallyEat, // ⭐ TRADUCIDO
            isSub: true,
          ),
          TimeSelectorCard(
            label: l10n.breakfast, // ⭐ TRADUCIDO
            icon: Icons.light_mode_rounded,
            selectedTime: provider.breakfastTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.breakfastTime = time),
          ),
          const SizedBox(height: 16),
          TimeSelectorCard(
            label: l10n.lunch, // ⭐ TRADUCIDO
            icon: Icons.wb_sunny_rounded,
            selectedTime: provider.lunchTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.lunchTime = time),
          ),
          const SizedBox(height: 16),
          TimeSelectorCard(
            label: l10n.dinner, // ⭐ TRADUCIDO
            icon: Icons.dark_mode_rounded,
            selectedTime: provider.dinnerTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.dinnerTime = time),
          ),
          const SizedBox(height: 24),
          QuestionnaireTitle(
            title: l10n.howOftenEatOut, // ⭐ TRADUCIDO
            isSub: true,
          ),
          ..._buildEatOutOptions(provider),
        ],
      ),
    );
  }

  List<Widget> _buildSnackTimeOptions(QuestionnaireProvider provider) {
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final options = [
      {
        'value': 'Snack AM',
        'title': l10n.midMorningSnackAM, // ⭐ TRADUCIDO
        'subtitle': l10n.betweenBreakfastLunch, // ⭐ TRADUCIDO
      },
      {
        'value': 'Snack PM',
        'title': l10n.midAfternoonSnackPM, // ⭐ TRADUCIDO
        'subtitle': l10n.betweenLunchDinner, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final options = {
      l10n.almostEveryDay, // ⭐ TRADUCIDO
      l10n.sometimesTwoToFourTimesWeek, // ⭐ TRADUCIDO
      l10n.rarelyOnceWeekOrLess, // ⭐ TRADUCIDO
      l10n.never, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionnaireTitleARRIBA(
              title: l10n.tasteAllergiesDietaryStyle), // ⭐ TRADUCIDO
          QuestionnaireTitle(
              title: l10n.whatFoodsDontYouLike, isSub: true), // ⭐ TRADUCIDO

          CustomTextField(
            label: l10n.exampleBroccoliLiver, // ⭐ TRADUCIDO
            initialValue: provider.dislikedFoods,
            onChanged: (val) =>
                provider.update(() => provider.dislikedFoods = val),
            emoji: "🚫",
          ),
          const SizedBox(height: 24),
          QuestionnaireTitle(
              title: l10n.doYouHaveFoodAllergies, // ⭐ TRADUCIDO
              isSub: true), // ⭐ TRADUCIDO
          SwitchListTile.adaptive(
            title: Text(provider.hasAllergies
                    ? l10n.yesIHaveAllergies // ⭐ TRADUCIDO
                    : l10n.noNone // ⭐ TRADUCIDO
                ),
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
                label: l10n.specifyHere, // ⭐ TRADUCIDO
                initialValue: provider.allergyDetails,
                onChanged: (val) =>
                    provider.update(() => provider.allergyDetails = val),
                errorText: validationErrors['allergyDetails'],
              ),
            ).animate().fadeIn(),
          const SizedBox(height: 24),
          QuestionnaireTitle(
              title: l10n.doYouFollowDietaryStyle, // ⭐ TRADUCIDO
              isSub: true), // ⭐ TRADUCIDO
          _DietaryStyleSelection(),
          const SizedBox(height: 24),
          QuestionnaireTitle(
              title: l10n.whatBudgetForWeeklyFood, // ⭐ TRADUCIDO
              isSub: true),
          ..._buildBudgetOptions(provider),
        ],
      ),
    );
  }

  List<Widget> _buildBudgetOptions(QuestionnaireProvider provider) {
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final options = [
      l10n.lowOnlyBasics, // ⭐ TRADUCIDO
      l10n.highNoRestrictions, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final _flowState =
        context.findAncestorStateOfType<_QuestionnaireFlowState>();

    final predefinedStyles = {
      l10n.omnivore: 'Omnivore', // ⭐ TRADUCIDO
      l10n.vegetarian: 'Vegetarian', // ⭐ TRADUCIDO
      l10n.vegan: 'Vegan', // ⭐ TRADUCIDO
      l10n.keto: 'Keto', // ⭐ TRADUCIDO
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
              label: l10n.other, // ⭐ TRADUCIDO
              isSelected: isOtherSelected,
              onTap: () => provider.update(() => provider.dietStyle = ''),
            ),
          ],
        ),
        if (isOtherSelected)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: CustomTextField(
              label: l10n.specifyYourStyle, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

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
          QuestionnaireTitleARRIBA(
              title: l10n.emotionalPersonalization), // ⭐ TRADUCIDO

          QuestionnaireTitle(
              title: l10n.whatHardestMaintainInPlan, // ⭐ TRADUCIDO

              isSub: true),
          ..._buildCheckboxOptions(
            provider.dietDifficulties,
            {
              l10n.stayConsistent: 'Stay consistent', // ⭐ TRADUCIDO
              l10n.knowWhatToEatWhenDontHavePlan:
                  'Know what to eat', // ⭐ TRADUCIDO
              l10n.eatHealthyOutsideHome: 'Eat healthy outside', // ⭐ TRADUCIDO
              l10n.controlCravings: 'Control cravings', // ⭐ TRADUCIDO
              l10n.prepareMeals: 'Prepare meals', // ⭐ TRADUCIDO
              l10n.other: 'Other', // ⭐ TRADUCIDO
            },
            validationErrors['otraDificultad'],
          ),
          if (provider.dietDifficulties.contains(l10n.other)) // ⭐ TRADUCIDO
            Padding(
              padding: const EdgeInsets.only(left: 28.0, top: 8.0),
              child: CustomTextField(
                label: l10n.specify, // ⭐ TRADUCIDO
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
          QuestionnaireTitle(
              title: l10n.whatMotivatesYouMostToFollowPlan, // ⭐ TRADUCIDO
              isSub: true),
          ..._buildCheckboxOptions(
            provider.dietMotivations,
            {
              l10n.seeQuickResults: 'See quick results', // ⭐ TRADUCIDO
              l10n.feelBetterPhysically:
                  'Feel better physically', // ⭐ TRADUCIDO
              l10n.proveToMyselfICanDoIt: 'Prove to myself', // ⭐ TRADUCIDO
              l10n.improveHealthLongTerm:
                  'Improve health long term', // ⭐ TRADUCIDO
              l10n.notClearYet: 'Not clear yet', // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionnaireTitleARRIBA(title: l10n.yourPreferences), // ⭐ TRADUCIDO
          QuestionnaireTitle(
              title: l10n.howPreferICommunicateWithYou, // ⭐ TRADUCIDO
              isSub: true),
          ..._buildSelectionCards(provider.communicationTone,
              (val) => provider.update(() => provider.communicationTone = val)),
          const SizedBox(height: 24),
          QuestionnaireTitle(
              title: l10n.whatWouldYouLikeToCallYou, // ⭐ TRADUCIDO
              isSub: true),
          CustomTextField(
            label: l10n.yourNameOrNickname, // ⭐ TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    final optionMap = {
      l10n.motivational: 'Motivational', // ⭐ TRADUCIDO
      l10n.close: 'Close', // ⭐ TRADUCIDO
      l10n.direct: 'Direct', // ⭐ TRADUCIDO
      l10n.whateverWorksForYou: 'Adaptive', // ⭐ TRADUCIDO
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
