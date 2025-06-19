import 'dart:math';

import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/pages/screens/datosPersonales/PlanSummaryScreen.dart';
import 'package:Frutia/pages/screens/datosPersonales/SuccessScreen.dart';
import 'package:Frutia/providers/QuestionnaireProvider.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/utils/ChoiceChipCard.dart';
import 'package:Frutia/utils/CustomTextField.dart';
import 'package:Frutia/utils/CustomTimePickerField.dart';
import 'package:Frutia/utils/SelectionCard.dart';
import 'package:Frutia/utils/SportSelection.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/utils/gender_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

/// Widget que gestiona el flujo del cuestionario para crear o editar un plan personalizado.
class QuestionnaireFlow extends StatefulWidget {
  final bool isEditing;

  const QuestionnaireFlow({super.key, this.isEditing = false});

  @override
  State<QuestionnaireFlow> createState() => _QuestionnaireFlowState();
}

class _QuestionnaireFlowState extends State<QuestionnaireFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _allergyController = TextEditingController();

  double _progress = 0;
  final int _numPages = 7;

  Map<String, String?> _validationErrors = {};

  /// Elimina emojis y normaliza caracteres especiales para estandarizar los datos guardados.
  String removeEmojis(String text) {
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    // Normaliza caracteres como '–' a '-' y asegura codificación correcta
    return text
        .replaceAll(emojiRegex, '')
        .replaceAll('\u2013', '-')
        .replaceAll('\u00ed', 'í')
        .replaceAll('\u00e1', 'á')
        .replaceAll('\u00f3', 'ó')
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

    // Cargar datos del perfil si está en modo edición
    if (widget.isEditing) {
      _loadProfileData();
    }
  }

  /// Carga los datos del perfil existente en modo edición, mapeando valores sin emojis a valores con emojis para la UI.
  Future<void> _loadProfileData() async {
    try {
      final profile = await ProfileService().getProfile();
      if (profile != null && mounted) {
        final provider = context.read<QuestionnaireProvider>();
        // Mapas para traducir valores de la base de datos a valores con emojis en la UI
        final goalMap = {
          'Bajar grasa': '🔥 Bajar grasa',
          'Aumentar músculo': '💪 Aumentar músculo',
          'Comer más saludable': '🥗 Comer más saludable',
          'Mejorar rendimiento': '📈 Mejorar rendimiento',
        };
        final activityLevelMap = {
          'Sedentario (casi todo el día sentado - oficina)': 'Sedentario (casi todo el día sentado - oficina)',
          'Moderado (caminas o haces tareas del hogar)': 'Moderado (caminas o haces tareas del hogar)',
          'Muy activo (te mueves todo el día por trabajo)': 'Muy activo (te mueves todo el día por trabajo)',
        };
        final trainingFrequencyMap = {
          'No entreno': 'No entreno 🚶',
          '1-2 días/semana (ocasional)': '1-2 días/semana (ocasional)🏋️',
          '3-4 veces por semana (regular)': '3–4 veces por semana (regular) 💪',
          '5-6 veces por semana (frecuente)': '5–6 veces por semana (frecuente) 🔥',
          'Todos los días (alta frecuencia)': 'Todos los días (alta frecuencia) 🏃‍♂️',
        };
        final mealCountMap = {
          '2 comidas principales (Ej: almuerzo y cena)': '🍽️ 2 comidas principales (Ej: almuerzo y cena)',
          '3 comidas principales (Desayuno, almuerzo y cena)': '🥐 3 comidas principales (Desayuno, almuerzo y cena)',
          '3 comidas + 1 o 2 snacks (Entre comidas o post entreno)': '🥗 3 comidas + 1 o 2 snacks (Entre comidas o post entreno)',
          'No tengo estructura fija': '🤗 No tengo estructura fija',
        };
        final dietaryStyleMap = {
          'Omnívoro': '🍖 Omnívoro',
          'Vegetariano': '🥕 Vegetariano',
          'Vegano': '🌱 Vegano',
          'Keto / Low carb': '🥚 Keto / Low carb',
        };
        final budgetMap = {
          'Bajo - Solo lo básico (Ej: arroz, huevo, lentejas)': '💸 Bajo - Solo lo básico (Ej: arroz, huevo, lentejas)',
          'Medio - Balanceado y variado (Ej: frutas, yogur, pescado)': '💵 Medio - Balanceado y variado (Ej: frutas, yogur, pescado)',
          'Alto - Sin restricciones (Ej: salmón, proteína, superfoods)': '💳 Alto - Sin restricciones (Ej: salmón, proteína, superfoods)',
        };
        final eatsOutMap = {
          'Casi todos los días': '🍔 Casi todos los días',
          'A veces (2 a 4 veces por semana)': '🍎 A veces (2 a 4 veces por semana)',
          'Rara vez (1 vez por semana o menos)': '🥗 Rara vez (1 vez por semana o menos)',
          'Nunca': '🚫 Nunca',
        };
        final communicationStyleMap = {
          'Motivadora (que te empuje a dar más cuando lo necesites)': 'Motivadora (que te empuje a dar más cuando lo necesites) 🏋️',
          'Cercana (como un amigo que te acompaña sin presión)': 'Cercana (como un amigo que te acompaña sin presión) 😊',
          'Directa (clara, sin vueltas ni frases suaves)': 'Directa (clara, sin vueltas ni frases suaves) 🤗',
          'Como te salga a ti, yo me adapto': 'Como te salga a ti, yo me adapto 🔄',
        };
        final difficultyMap = {
          'Mantenerme constante': 'Mantenerme constante 🔄',
          'Saber qué comer cuando no tengo lo del plan': 'Saber qué comer cuando no tengo lo del plan 🤔',
          'Comer saludable fuera de casa': 'Comer saludable fuera de casa 🍽️',
          'Controlar los antojos': 'Controlar los antojos 🍫',
          'Preparar la comida': 'Preparar la comida 🧑‍🍳',
          'Otra': 'Otra ✍️',
        };
        final motivationMap = {
          'Ver resultados rápidos': 'Ver resultados rápidos ⚡',
          'Sentirme mejor físicamente (energía, digestión, menos pesadez)': 'Sentirme mejor físicamente (energía, digestión, menos pesadez) 💪',
          'Demostrarme que puedo lograrlo': 'Demostrarme que puedo lograrlo 💯',
          'Mejorar mi salud a largo plazo': 'Mejorar mi salud a largo plazo 🏥',
          'Aún no lo tengo claro': 'Aún no lo tengo claro ❓',
        };

        provider.update(() {
          provider.name = profile['name'] ?? '';
          provider.mainGoal = profile['goal'] != null
              ? goalMap[removeEmojis(profile['goal'])] ?? profile['goal']
              : null;
          provider.dailyActivityLevel = profile['activity_level'] != null
              ? activityLevelMap[removeEmojis(profile['activity_level'])] ??
                  profile['activity_level']
              : null;
          provider.dietStyle = profile['dietary_style'] != null
              ? dietaryStyleMap[removeEmojis(profile['dietary_style'])] ??
                  profile['dietary_style']
              : null;
          provider.weeklyBudget = profile['budget'] != null
              ? budgetMap[removeEmojis(profile['budget'])] ?? profile['budget']
              : null;
          provider.eatsOut = profile['eats_out'] != null
              ? eatsOutMap[removeEmojis(profile['eats_out'])] ??
                  profile['eats_out']
              : null;
          provider.dislikedFoods = profile['disliked_foods'] ?? '';
          provider.hasAllergies = profile['has_allergies'] ?? false;
          provider.allergyDetails = profile['allergies'] ?? '';
          provider.hasMedicalCondition =
              profile['has_medical_condition'] ?? false;
          provider.medicalConditionDetails = profile['medical_condition'] ?? '';
          provider.communicationTone = profile['communication_style'] != null
              ? communicationStyleMap[
                      removeEmojis(profile['communication_style'])] ??
                  profile['communication_style']
              : null;
          provider.preferredName = profile['preferred_name'] ?? '';
          provider.sport = List<String>.from(profile['sport'] ?? []);
          provider.trainingFrequency = profile['training_frequency'] != null
              ? trainingFrequencyMap[
                      removeEmojis(profile['training_frequency'])] ??
                  profile['training_frequency']
              : null;
          provider.mealCount = profile['meal_count'] != null
              ? mealCountMap[removeEmojis(profile['meal_count'])] ??
                  profile['meal_count']
              : null;
          provider.breakfastTime = _parseTimeOfDay(profile['breakfast_time']);
          provider.lunchTime = _parseTimeOfDay(profile['lunch_time']);
          provider.dinnerTime = _parseTimeOfDay(profile['dinner_time']);
          provider.dietDifficulties = Set<String>.from(profile[
                      'diet_difficulties']
                  ?.map((item) => difficultyMap[removeEmojis(item)] ?? item) ??
              []);
          provider.dietMotivations = Set<String>.from(
              profile['diet_motivations']
                      ?.map((item) => motivationMap[removeEmojis(item)] ?? item) ??
                  []);
        });
        _allergyController.text = provider.allergyDetails;
      }
    } catch (e) {
      if (mounted) {
        print('[QuestionnaireFlow] Error loading profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Parsea un string de tiempo (HH:MM) a TimeOfDay.
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
    _allergyController.dispose();
    super.dispose();
  }

  /// Valida los datos de la página actual del cuestionario.
  bool _validateCurrentPage() {
    final provider = context.read<QuestionnaireProvider>();
    final currentPage =
        _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;

    setState(() {
      _validationErrors = {};
    });

    bool isValid = true;
    List<String> errorMessages = [];

    switch (currentPage) {
      case 0: // WelcomeScreen
        return true;
      case 1: // PersonalInfoScreen
        if (provider.name.isEmpty) {
          _validationErrors['name'] = 'Por favor, ingresa tu nombre';
          isValid = false;
        }
        if (provider.mainGoal == null) {
          errorMessages.add('Selecciona un objetivo principal');
          isValid = false;
        }
        if (provider.hasMedicalCondition &&
            provider.medicalConditionDetails.isEmpty) {
          _validationErrors['medicalCondition'] =
              'Específica tu condición médica';
          isValid = false;
        }
        break;
      case 2: // RoutineScreen
        if (provider.sport.isEmpty) {
          errorMessages.add('Selecciona un deporte');
          isValid = false;
        }
        if (provider.trainingFrequency == null) {
          errorMessages.add('Selecciona tu frecuencia de entrenamiento');
          isValid = false;
        }
        if (provider.dailyActivityLevel == null) {
          errorMessages.add('Selecciona tu nivel de actividad diaria');
          isValid = false;
        }
        break;
      case 3: // AlimentacionScreen
        if (provider.mealCount == null) {
          errorMessages.add('Selecciona cuántas veces al día quieres comer');
          isValid = false;
        }
        break;
      case 4: // GustosScreen
        if (provider.dietStyle == null) {
          errorMessages.add('Selecciona un estilo de alimentación');
          isValid = false;
        }
        if (provider.hasAllergies && provider.allergyDetails.isEmpty) {
          _validationErrors['allergyDetails'] =
              'Específica tus alergias alimentarias';
          isValid = false;
        }
        break;
      case 5: // PreferencesScreen
        if (provider.communicationTone == null) {
          errorMessages.add('Selecciona un estilo de comunicación');
          isValid = false;
        }
        break;
      case 6: // PersonalizacionScreen
        if (provider.dietDifficulties.contains('Otra ✍️') &&
            !provider.dietDifficulties
                .any((item) => item.startsWith('Otra: '))) {
          _validationErrors['otraDificultad'] =
              'Específica tu otra dificultad alimentaria';
          isValid = false;
        }
        break;
    }

    if (errorMessages.isNotEmpty) {
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

    if (_pageController.page! < _numPages - 1) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOut);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FrutiaColors.secondaryBackground.withOpacity(0.9),
                FrutiaColors.primaryBackground.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[300],
                      value: null,
                    ),
                  ),
                  Lottie.asset(
                    'assets/images/loaderFruta.json',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.isEditing
                    ? 'Actualizando tu plan personalizado...'
                    : 'Generando tu plan personalizado...',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.primaryText,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 300.ms).scale(
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 10),
              Text(
                'Espere un momento.',
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.primaryText,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms),
    );

    try {
      final questionnaireProvider = context.read<QuestionnaireProvider>();
      final profileData = {
        'name': questionnaireProvider.name.isNotEmpty ? questionnaireProvider.name : null,
        'goal': questionnaireProvider.mainGoal != null
            ? removeEmojis(questionnaireProvider.mainGoal!)
            : null,
        'activity_level': questionnaireProvider.dailyActivityLevel != null
            ? removeEmojis(questionnaireProvider.dailyActivityLevel!)
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
        'medical_condition': questionnaireProvider.medicalConditionDetails.isNotEmpty
            ? questionnaireProvider.medicalConditionDetails
            : null,
        'communication_style': questionnaireProvider.communicationTone != null
            ? removeEmojis(questionnaireProvider.communicationTone!)
            : null,
        'preferred_name': questionnaireProvider.preferredName?.isNotEmpty ?? false
            ? questionnaireProvider.preferredName
            : null,
        'sport': questionnaireProvider.sport.isNotEmpty
            ? questionnaireProvider.sport
            : null,
        'training_frequency': questionnaireProvider.trainingFrequency != null
            ? removeEmojis(questionnaireProvider.trainingFrequency!)
            : null,
        'meal_count': questionnaireProvider.mealCount != null
            ? removeEmojis(questionnaireProvider.mealCount!)
            : null,
        'breakfast_time': formatTimeOfDay(questionnaireProvider.breakfastTime),
        'lunch_time': formatTimeOfDay(questionnaireProvider.lunchTime),
        'dinner_time': formatTimeOfDay(questionnaireProvider.dinnerTime),
        'diet_difficulties': questionnaireProvider.dietDifficulties.isNotEmpty
            ? questionnaireProvider.dietDifficulties
                .map((item) => removeEmojis(item))
                .toList()
            : null,
        'diet_motivations': questionnaireProvider.dietMotivations.isNotEmpty
            ? questionnaireProvider.dietMotivations
                .map((item) => removeEmojis(item))
                .toList()
            : null,
        'plan_setup_complete': true,
      };

      questionnaireProvider.printSummary();

      // Guardar o actualizar el perfil
      await ProfileService().saveProfile(profileData);

      // Generar o regenerar el plan si es necesario
      if (!widget.isEditing || await _hasSignificantChanges(profileData)) {
        await PlanService().generatePlan();
      }

      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PlanSummaryScreen()),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      print('--- ¡ERROR ATRAPADO DURANTE LA ${widget.isEditing ? "ACTUALIZACIÓN" : "GENERACIÓN"} DEL PLAN! ---');
      print('Error: $e');
      print('Stack trace: $stackTrace');

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
  }

  /// Verifica si los cambios en el perfil requieren regenerar el plan.
  Future<bool> _hasSignificantChanges(Map<String, dynamic> newProfileData) async {
    try {
      final currentProfile = await ProfileService().getProfile();
      if (currentProfile == null) return true;

      const significantFields = [
        'goal',
        'activity_level',
        'dietary_style',
        'budget',
        'eats_out',
        'disliked_foods',
        'has_allergies',
        'allergies',
        'has_medical_condition',
        'medical_condition',
        'sport',
        'training_frequency',
        'meal_count',
        'breakfast_time',
        'lunch_time',
        'dinner_time',
        'diet_difficulties',
        'diet_motivations',
      ];

      for (var field in significantFields) {
        final newValue = newProfileData[field];
        final currentValue = currentProfile[field];
        if (newValue is List && currentValue is List) {
          if (newValue.length != currentValue.length ||
              !newValue.every((item) => currentValue.contains(item))) {
            print('[QuestionnaireFlow] Cambio detectado en $field');
            return true;
          }
        } else if (newValue != currentValue) {
          print('[QuestionnaireFlow] Cambio detectado en $field');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('[QuestionnaireFlow] Error al comparar cambios: $e');
      return true; // Regenerar por seguridad si hay error
    }
  }

  /// Formatea TimeOfDay a string HH:MM.
  String? formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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
                children: [
                  WelcomeScreen(isEditing: widget.isEditing),
                  const PersonalInfoScreen(),
                  const RoutineScreen(),
                  const AlimentacionScreen(),
                  const GustosScreen(),
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

// Resto de las clases (sin cambios significativos)
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
            child: Text(
                currentPage < totalPages - 1
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
                fontSize: 18,
                color: FrutiaColors.secondaryText,
                height: 1.5),
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
          const QuestionnaireTitleARRIBA(
            title: 'Sobre ti 👤',
          ),
          const QuestionnaireTitle(
              title: 'Primero lo primero. Escribe tu nombre. ', isSub: true),
          CustomTextField(
            label: 'Nombre',
            initialValue: provider.name,
            onChanged: (val) => provider.update(() => provider.name = val),
            errorText: validationErrors['name'],
          ),
          const SizedBox(height: 16),
          Row(children: []),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('¿Tienes alguna condición médica? 🩺'),
            value: provider.hasMedicalCondition,
            onChanged: (val) => setState(() =>
                provider.update(() => provider.hasMedicalCondition = val)),
            activeColor: FrutiaColors.accent,
            secondary: const Text('👨‍⚕️',
                style: TextStyle(fontSize: 24)), // Emoji de médico
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
  final Color titleColor = const Color.fromARGB(221, 205, 104, 104);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionnaireProvider>();
    return QuestionnaireScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QuestionnaireTitleARRIBA(title: 'Tu Rutina 🏃‍♂️'),
          Text('¿Qué deporte practicas? (puedes seleccionar varios)🏀',
              style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor)),
          const SizedBox(height: 16),
          SportSelection(
            name: 'sport',
            initialValue: provider.sport ?? [],
            onChanged: (List<String>? values) {
              provider.update(() => provider.sport = values ?? []);
            },
          ),
          const SizedBox(height: 40),
          const QuestionnaireTitle(
              title:
                  '¿Con qué frecuencia entrenas o haces ejercicio físico en una semana?',
              isSub: true),
          ..._buildChipOptions([
            'No entreno 🚶',
            '1-2 días/semana (ocasional)🏋️',
            '3–4 veces por semana (regular) 💪',
            '5–6 veces por semana (frecuente) 🔥',
            'Todos los días (alta frecuencia) 🏃‍♂️'
          ], provider.trainingFrequency,
              (val) => provider.trainingFrequency = val),
          const SizedBox(height: 40),
          const QuestionnaireTitle(
              title:
                  '¿Cómo es tu nivel de actividad diaria (fuera del entrenamiento)?',
              isSub: true),
          ..._buildChipOptions(
            [
              'Sedentario (casi todo el día sentado - oficina)',
              'Moderado (caminas o haces tareas del hogar)',
              'Muy activo (te mueves todo el día por trabajo)',
            ],
            provider.dailyActivityLevel,
            (val) => provider.update(() => provider.dailyActivityLevel = val),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildChipOptions(
      List<String> options, String? groupValue, Function(String) updateFn) {
    return [
      Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Espacio vertical entre chips
            child: GestureDetector(
              onTap: () => setState(() => context
                  .read<QuestionnaireProvider>()
                  .update(() => updateFn(opt))),
              child: Chip(
                label: Flexible(
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: groupValue == opt ? Colors.white : FrutiaColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true, // Permite que el texto se divida en varias líneas
                    overflow: TextOverflow.visible, // Evita que se corte
                  ),
                ),
                backgroundColor: groupValue == opt ? FrutiaColors.accent : Colors.grey[200]!,
                side: BorderSide(
                  color: groupValue == opt ? FrutiaColors.accent : Colors.grey[300]!,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          );
        }).toList(),
      )
    ];
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
          const QuestionnaireTitle(
              title: '¿Cómo sueles organizar tus comidas en el día?',
              isSub: true),
          ..._buildMealCountOptions(provider),
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

  List<Widget> _buildMealCountOptions(QuestionnaireProvider provider) {
    const options = {
      '🍽️ 2 comidas principales (Ej: almuerzo y cena)',
      '🥐 3 comidas principales (Desayuno, almuerzo y cena)',
      '🥗 3 comidas + 1 o 2 snacks (Entre comidas o post entreno)',
      '🤗 No tengo estructura fija',
    };
    return options
        .map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: opt,
                value: opt,
                groupValue: provider.mealCount,
                onTap: (val) => setState(
                    () => provider.update(() => provider.mealCount = val)),
              ),
            ))
        .toList();
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
 

/// Pantalla para personalizar dificultades y motivaciones alimentarias.
class PersonalizacionScreen extends StatefulWidget {
  const PersonalizacionScreen({super.key});

  @override
  State<PersonalizacionScreen> createState() => _PersonalizacionScreenState();
}

class _PersonalizacionScreenState extends State<PersonalizacionScreen> {
  final TextEditingController _otraDificultadController = TextEditingController();

  @override
  void dispose() {
    _otraDificultadController.dispose();
    super.dispose();
  }

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
              title: 'Personalización emocional (opcional) 🌟'),
          const QuestionnaireTitle(
              title:
                  '¿Qué es lo que más te cuesta mantener en un plan de alimentación?',
              isSub: true),
          ..._buildCheckboxOptions(
            provider.dietDifficulties,
            {
              'Mantenerme constante 🔄': 'Mantenerme constante',
              'Saber qué comer cuando no tengo lo del plan 🤔': 'Saber qué comer cuando no tengo lo del plan',
              'Comer saludable fuera de casa 🍽️': 'Comer saludable fuera de casa',
              'Controlar los antojos 🍫': 'Controlar los antojos',
              'Preparar la comida 🧑‍🍳': 'Preparar la comida',
              'Otra ✍️': 'Otra',
            },
          ),
          if (provider.dietDifficulties.contains('Otra ✍️'))
            Padding(
              padding: const EdgeInsets.only(left: 28.0, top: 8.0),
              child: CustomTextField(
                controller: _otraDificultadController,
                label: 'Especifica',
                errorText: validationErrors['otraDificultad'],
                onChanged: (val) => provider.update(() {
                  provider.dietDifficulties
                      .removeWhere((item) => item.startsWith('Otra:'));
                  if (val.isNotEmpty) {
                    provider.dietDifficulties.add('Otra: $val');
                  }
                }),
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
              'Sentirme mejor físicamente (energía, digestión, menos pesadez) 💪': 'Sentirme mejor físicamente (energía, digestión, menos pesadez)',
              'Demostrarme que puedo lograrlo 💯': 'Demostrarme que puedo lograrlo',
              'Mejorar mi salud a largo plazo 🏥': 'Mejorar mi salud a largo plazo',
              'Aún no lo tengo claro ❓': 'Aún no lo tengo claro',
            },
          ),
          const SizedBox(height: 24),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  /// Construye las opciones de selección múltiple para dificultades o motivaciones.
  List<Widget> _buildCheckboxOptions(
      Set<String> selectedValues, Map<String, String> optionMap) {
    return optionMap.entries
        .map((entry) => CheckboxListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(entry.key), // Mostrar con emoji
              value: selectedValues.contains(entry.key),
              onChanged: (value) {
                setState(() {
                  context.read<QuestionnaireProvider>().update(() {
                    if (value ?? false) {
                      selectedValues.add(entry.key);
                    } else {
                      selectedValues.remove(entry.key);
                      if (entry.value == 'Otra') {
                        _otraDificultadController.clear();
                        selectedValues
                            .removeWhere((item) => item.startsWith('Otra:'));
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

 
/// Pantalla para configurar las preferencias de comunicación y nombre preferido.
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

  /// Construye las tarjetas de selección para el tono de comunicación.
  List<Widget> _buildSelectionCards(String? groupValue, Function(String) updateFn) {
    const optionMap = {
      'Motivadora (que te empuje a dar más cuando lo necesites) 🏋️': 'Motivadora (que te empuje a dar más cuando lo necesites)',
      'Cercana (como un amigo que te acompaña sin presión) 😊': 'Cercana (como un amigo que te acompaña sin presión)',
      'Directa (clara, sin vueltas ni frases suaves) 🤗': 'Directa (clara, sin vueltas ni frases suaves)',
      'Como te salga a ti, yo me adapto 🔄': 'Como te salga a ti, yo me adapto',
    };
    return optionMap.entries
        .map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: entry.key, // Mostrar con emoji en la UI
                value: entry.value, // Usar sin emoji para comparación
                groupValue: groupValue,
                onTap: (val) => setState(() => updateFn(val)),
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
  final TextEditingController _allergyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allergyController.text =
        context.read<QuestionnaireProvider>().allergyDetails;
  }

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

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
                  if (!val) {
                    provider.allergyDetails = '';
                    _allergyController.clear();
                  }
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
                controller: _allergyController,
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
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildBudgetOptions(QuestionnaireProvider provider) {
    const options = [
      '💸 Bajo - Solo lo básico (Ej: arroz, huevo, lentejas)',
      '💵 Medio - Balanceado y variado (Ej: frutas, yogur, pescado)',
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
    const predefinedStyles = {
      '🍖 Omnívoro': 'Omnívoro',
      '🥕 Vegetariano': 'Vegetariano',
      '🌱 Vegano': 'Vegano',
      '🥚 Keto / Low carb': 'Keto / Low carb',
    };

    return FormBuilderField<String>(
      name: 'dietary_style',
      initialValue: '', // Set to empty string to default to "Otro"
      onChanged: (val) => context
          .read<QuestionnaireProvider>()
          .update(() => context.read<QuestionnaireProvider>().dietStyle = val),
      builder: (FormFieldState<String> field) {
        bool isOtherSelected = field.value != null &&
            !predefinedStyles.values.contains(field.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ...predefinedStyles.entries.map((entry) {
                  return ChoiceChipCard(
                    label: entry.key, // Usamos la clave que contiene el emoji
                    isSelected: field.value == entry.value,
                    onTap: () => field.didChange(entry.value),
                  );
                }).toList(),
                ChoiceChipCard(
                  label: '✍️ Otro',
                  isSelected: isOtherSelected,
                  onTap: () => field.didChange(''),
                ),
              ],
            ),
            if (isOtherSelected)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CustomTextField(
                  label: '✏️ Especifica tu estilo',
                  initialValue: field.value,
                  onChanged: (newValue) => field.didChange(newValue),
                ),
              ),
          ],
        );
      },
    );
  }
}

class QuestionnaireScreen extends StatelessWidget {
  final Widget child;
  const QuestionnaireScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background particles
        const Positioned.fill(child: _FloatingParticles()),
        // Foreground content
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
      begin: const Offset(1.0, 0.0), // Comienza desde la derecha
      end: Offset.zero, // Termina en la posición original
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward(); // Inicia la animación al cargar el widget
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
              color: Colors.black, // Letras blancas
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

    // Generar partículas con velocidades más visibles
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