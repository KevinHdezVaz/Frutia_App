import 'dart:math';

import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/pages/screens/datosPersonales/PlanSummaryScreen.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/utils/ChoiceChipCard.dart';
import 'package:Frutia/utils/CustomTextField.dart';
import 'package:Frutia/utils/CustomTimePickerField.dart';
import 'package:Frutia/utils/LoadingMessagesWidget.dart';
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
  final int _numPages = 7;

  Map<String, String?> _validationErrors = {};

  /// Elimina emojis y normaliza caracteres especiales para estandarizar los datos guardados.
  String removeEmojis(String text) {
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    // Normaliza caracteres como '–' a '-' y asegura codificación correcta
    // Mantenemos la conversión para caracteres especiales comunes en español
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
        .trim(); // Trim to remove any leading/trailing spaces
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
        // UI_KEY: The string shown in the user interface (with emojis).
        // DB_VALUE: The exact string as stored/retrieved from the database (may contain unicode escapes, no emojis).
        // The `removeEmojis` function will be used to clean `DB_VALUE` for comparison.
        final Map<String, String> goalMap = {
          '🔥 Bajar grasa': 'Bajar grasa',
          '💪 Aumentar músculo': 'Aumentar músculo',
          '🥗 Comer más saludable': 'Comer más saludable',
          '📈 Mejorar rendimiento': 'Mejorar rendimiento',
        };
        final Map<String, String> activityLevelMap = {
          'Sedentario (casi todo el día sentado - oficina)':
              'Sedentario (casi todo el día sentado - oficina)',
          'Moderado (caminas o haces tareas del hogar)':
              'Moderado (caminas o haces tareas del hogar)',
          'Muy activo (te mueves todo el día por trabajo)':
              'Muy activo (te mueves todo el dia por trabajo)',
        };
        final Map<String, String> trainingFrequencyMap = {
          'No entreno 🚶': 'No entreno',
          '1-2 días/semana (ocasional)🏋️': '1-2 días/semana (ocasional)',
          '3–4 veces por semana (regular) 💪': '3-4 veces por semana (regular)',
          '5–6 veces por semana (frecuente) 🔥':
              '5–6 veces por semana (frecuente)', // Matches DB value from SQL dump
          'Todos los días (alta frecuencia) 🏃‍♂️':
              'Todos los días (alta frecuencia)',
        };
        final Map<String, String> mealCountMap = {
          '🍽️ 2 comidas principales (Ej: almuerzo y cena)':
              '2 comidas principales (Ej: almuerzo y cena)',
          '🥐 3 comidas principales (Desayuno, almuerzo y cena)':
              '3 comidas principales (Desayuno, almuerzo y cena)',
          '🥗 3 comidas + 1 o 2 snacks (Entre comidas o post entreno)':
              '3 comidas + 1 o 2 snacks (Entre comidas o post entreno)',
          '🤗 No tengo estructura fija': 'No tengo estructura fija',
        };

        // DENTRO DE _loadProfileData()

        final Map<String, String> dietaryStyleMap = {
          // La clave (con emoji) es para la UI, el valor es para comparar con la DB.
          '🍖 Omnívoro':
              'Omnívoro', // <-- CORREGIDO: Añadido el acento a 'Omnívoro'
          '🥕 Vegetariano': 'Vegetariano',
          '🌱 Vegano': 'Vegano',
          '🥚 Keto / Low carb': 'Keto / Low carb',
        };

        final Map<String, String> budgetMap = {
          '💸 Bajo - Solo lo básico (Ej: arroz, huevo, lentejas)':
              'Bajo - Solo lo básico (Ej: arroz, huevo, lentejas', // Corrected to match DB value from SQL dump
          '💵 Medio - Balanceado y variado (Ej: frutas, yogur, pescado)':
              'Medio - Balanceado y variado (Ej: frutas, yogur, pescado)',
          '💳 Alto - Sin restricciones (Ej: salmón, proteína, superfoods)':
              'Alto - Sin restricciones (Ej: salmón, proteína, superfoods)', // Corrected to match DB value from SQL dump
        };
        final Map<String, String> eatsOutMap = {
          '🍔 Casi todos los días':
              'Casi todos los días', // Corrected to match DB value 'Casi todos los días' (with accent)
          '🍎 A veces (2 a 4 veces por semana)':
              'A veces (2 a 4 veces por semana)',
          '🥗 Rara vez (1 vez por semana o menos)':
              'Rara vez (1 vez por semana o menos)',
          '🚫 Nunca': 'Nunca',
        };
        final Map<String, String> communicationStyleMap = {
          'Motivadora (que te empuje a dar más cuando lo necesites) 🏋️':
              'Motivadora (que te empuje a dar más cuando lo necesites)', // Corrected: Match DB value
          'Cercana (como un amigo que te acompaña sin presión) 😊':
              'Cercana (como un amigo que te acompaña sin presión)', // Corrected: Match DB value
          'Directa (clara, sin vueltas ni frases suaves) 🤗':
              'Directa (clara, sin vueltas ni frases suaves)', // Matches DB value
          'Como te salga a ti, yo me adapto 🔄':
              'Como te salga a ti, yo me adapto',
        };
        final Map<String, String> difficultyMap = {
          'Mantenerme constante 🔄': 'Mantenerme constante',
          'Saber qué comer cuando no tengo lo del plan 🤔':
              'Saber qué comer cuando no tengo lo del plan', // Corrected: Match DB value
          'Comer saludable fuera de casa 🍽️': 'Comer saludable fuera de casa',
          'Controlar los antojos 🍫': 'Controlar los antojos',
          'Preparar la comida 🧑‍🍳': 'Preparar la comida',
          'Otra ✍️': 'Otra',
        };
        final Map<String, String> motivationMap = {
          'Ver resultados rápidos ⚡':
              'Ver resultados rápidos', // Corrected: Match DB value
          'Sentirme mejor físicamente (energía, digestión, menos pesadez) 💪':
              'Sentirme mejor físicamente (energía, digestión, menos pesadez)', // Corrected: Match DB value
          'Demostrarme que puedo lograrlo 💯':
              'Demostrarme que puedo lograrlo', // Matches DB value
          'Mejorar mi salud a largo plazo 🏥': 'Mejorar mi salud a largo plazo',
          'Aún no lo tengo claro ❓': 'Aún no lo tengo claro',
        };

        // Helper function to find UI key from cleaned DB value
        // DENTRO DE _loadProfileData()
        String? findUiKeyByCleanedDbValue(
            String? dbValue, Map<String, String> map) {
          if (dbValue == null || dbValue.isEmpty) return null;

          // Limpia el valor de la base de datos
          final cleanedDbValue = removeEmojis(dbValue).trim();

          // ----- INICIO DE CÓDIGO DE DEPURACIÓN -----
          // Imprime el valor de la DB que estás buscando
          debugPrint("--- BUSCANDO VALOR DE DB ---");
          debugPrint("Original DB: '$dbValue'");
          debugPrint("Limpio   DB: '$cleanedDbValue'");
          debugPrint(
              "Buscando en el mapa: ${map.keys.first}"); // Para saber en qué mapa estamos
          // ----- FIN DE CÓDIGO DE DEPURACIÓN -----

          final entry = map.entries.firstWhere(
            (e) {
              final cleanedMapValue = removeEmojis(e.value).trim();

              // ----- INICIO DE CÓDIGO DE DEPURACIÓN -----
              // Imprime el valor del mapa que se está comparando
              if (cleanedMapValue.contains('Directa')) {
                // Filtra para que no imprima todo
                debugPrint("Comparando con MAPA: '$cleanedMapValue'");
              }
              // ----- FIN DE CÓDIGO DE DEPURACIÓN -----

              return cleanedMapValue == cleanedDbValue;
            },
            orElse: () => const MapEntry('', ''),
          );

          if (entry.key.isEmpty) {
            debugPrint(
                ">>> ¡NO SE ENCONTRÓ COINCIDENCIA PARA '$cleanedDbValue'!");
          }

          return entry.key.isNotEmpty ? entry.key : null;
        }

        provider.update(() {
          provider.name = profile['name'] ?? '';
          provider.mainGoal =
              findUiKeyByCleanedDbValue(profile['goal'], goalMap);
          provider.dailyActivityLevel = findUiKeyByCleanedDbValue(
              profile['activity_level'], activityLevelMap);

          String? loadedDietStyle = profile['dietary_style'];
          if (loadedDietStyle != null && loadedDietStyle.isNotEmpty) {
            String? uiStyle =
                findUiKeyByCleanedDbValue(loadedDietStyle, dietaryStyleMap);
            if (uiStyle != null) {
              provider.dietStyle = uiStyle;
            } else {
              provider.dietStyle =
                  loadedDietStyle; // Keep original if it's a custom 'Otro'
            }
          } else {
            provider.dietStyle = null;
          }

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
          provider.trainingFrequency = findUiKeyByCleanedDbValue(
              profile['training_frequency'], trainingFrequencyMap);
          provider.mealCount =
              findUiKeyByCleanedDbValue(profile['meal_count'], mealCountMap);

          provider.breakfastTime = _parseTimeOfDay(profile['breakfast_time']);
          provider.lunchTime = _parseTimeOfDay(profile['lunch_time']);
          provider.dinnerTime = _parseTimeOfDay(profile['dinner_time']);

          // Handle diet_difficulties loading
          final Set<String> loadedDifficulties = {};
          List<dynamic>? rawDifficulties = profile['diet_difficulties'];
          if (rawDifficulties != null) {
            for (var item in rawDifficulties) {
              if (item is String) {
                if (item.startsWith('Otra:')) {
                  loadedDifficulties.add(item); // Keep original "Otra: " string
                } else {
                  final String cleanItem = removeEmojis(item);
                  final MapEntry<String, String> foundEntry =
                      difficultyMap.entries.firstWhere(
                    (entry) =>
                        removeEmojis(entry.value).trim() ==
                        cleanItem.trim(), // Trim here too for consistency
                    orElse: () => const MapEntry('', ''),
                  );
                  if (foundEntry.key.isNotEmpty) {
                    loadedDifficulties.add(foundEntry.key);
                  }
                }
              }
            }
          }
          provider.dietDifficulties = loadedDifficulties;

          // Handle diet_motivations loading
          final Set<String> loadedMotivations = {};
          List<dynamic>? rawMotivations = profile['diet_motivations'];
          if (rawMotivations != null) {
            for (var item in rawMotivations) {
              if (item is String) {
                final String cleanItem = removeEmojis(item);
                final MapEntry<String, String> foundEntry =
                    motivationMap.entries.firstWhere(
                  (entry) =>
                      removeEmojis(entry.value).trim() ==
                      cleanItem.trim(), // Trim here too for consistency
                  orElse: () => const MapEntry('', ''),
                );
                if (foundEntry.key.isNotEmpty) {
                  loadedMotivations.add(foundEntry.key);
                }
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
      case 1: // PersonalInfoScreen: name, mainGoal, hasMedicalCondition, medicalConditionDetails
        if (provider.name.isEmpty) {
          _validationErrors['name'] = 'Por favor, ingresa tu nombre.';
          isValid = false;
        }
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
      case 2: // RoutineScreen: sport, trainingFrequency, dailyActivityLevel
        if (provider.sport.isEmpty) {
          errorMessages.add('Selecciona al menos un deporte.');
          isValid = false;
        }
        if (provider.trainingFrequency == null) {
          errorMessages.add('Selecciona tu frecuencia de entrenamiento.');
          isValid = false;
        }
        if (provider.dailyActivityLevel == null) {
          errorMessages.add('Selecciona tu nivel de actividad diaria.');
          isValid = false;
        }
        break;
      case 3: // AlimentacionScreen: breakfastTime, lunchTime, dinnerTime, eatsOut, mealCount
        if (provider.mealCount == null) {
          errorMessages.add('Selecciona cuántas veces al día quieres comer.');
          isValid = false;
        }
        if (provider.eatsOut == null) {
          errorMessages
              .add('Selecciona con qué frecuencia comes fuera de casa.');
          isValid = false;
        }
        break;
      case 4: // GustosScreen: dislikedFoods, hasAllergies, allergyDetails, dietStyle, weeklyBudget
        if (provider.dietStyle == null || provider.dietStyle!.isEmpty) {
          errorMessages.add('Selecciona un estilo de alimentación.');
          isValid = false;
        } else {
          final Map<String, String> predefinedStylesValues = {
            'Omnívoro': 'Omnívoro',
            'Vegetariano': 'Vegetariano',
            'Vegano': 'Vegano',
            'Keto / Low carb': 'Keto / Low carb',
          };
          if (!predefinedStylesValues.values
                  .contains(removeEmojis(provider.dietStyle!)) &&
              provider.dietStyle!.trim().isEmpty) {
            _validationErrors['dietaryStyle'] =
                'Por favor, especifica tu estilo de alimentación "Otro".';
            isValid = false;
          }
        }
        if (provider.hasAllergies && provider.allergyDetails.isEmpty) {
          _validationErrors['allergyDetails'] =
              'Específica tus alergias alimentarias.';
          isValid = false;
        }
        if (provider.weeklyBudget == null) {
          errorMessages.add('Selecciona tu presupuesto semanal.');
          isValid = false;
        }
        break;
      case 5: // PreferencesScreen: communicationTone, preferredName
        if (provider.communicationTone == null) {
          errorMessages.add('Selecciona un estilo de comunicación.');
          isValid = false;
        }
        break;
      case 6: // PersonalizacionScreen: dietDifficulties, dietMotivations
        if (provider.dietDifficulties.isEmpty) {
          errorMessages.add('Selecciona al menos una dificultad en la dieta.');
          isValid = false;
        }
        if (provider.dietDifficulties.contains('Otra ✍️')) {
          bool otraEspecificada = provider.dietDifficulties.any((item) =>
              item.startsWith('Otra: ') && item.length > 'Otra: '.length);
          if (!otraEspecificada) {
            _validationErrors['otraDificultad'] =
                'Por favor, especifica tu otra dificultad alimentaria.';
            isValid = false;
          }
        }
        if (provider.dietMotivations.isEmpty) {
          errorMessages
              .add('Selecciona al menos una motivación para tu dieta.');
          isValid = false;
        }
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
        builder: (_) => Dialog(
          backgroundColor: Colors.white,
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
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
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
                const SizedBox(height: 16),
                const LoadingMessagesWidget(), //
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms),
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
          'training_frequency': questionnaireProvider.trainingFrequency != null
              ? removeEmojis(questionnaireProvider.trainingFrequency!)
              : null,
          'meal_count': questionnaireProvider.mealCount != null
              ? removeEmojis(questionnaireProvider.mealCount!)
              : null,
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

        questionnaireProvider.printSummary();

        await ProfileService().saveProfile(profileData);

        if (!widget.isEditing || await _hasSignificantChanges(profileData)) {
          debugPrint(
              '[QuestionnaireFlow] Se detectaron cambios significativos o no es edición. Generando/Regenerando plan...');
          await PlanService().generatePlan();
        } else {
          debugPrint(
              '[QuestionnaireFlow] No se detectaron cambios significativos. No se regenera el plan.');
        }

        // ESTE ES EL BLOQUE CORREGIDO QUE DEBES USAR
        if (mounted) {
          // 1. Cierra el diálogo de "Cargando..."
          Navigator.of(context).pop();

          // 2. SIN PREGUNTAR NADA, siempre navega a la pantalla del plan.
          //    Esto funciona tanto para crear por primera vez como para editar.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const PlanSummaryScreen()),
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

  /// Verifica si los cambios en el perfil requieren regenerar el plan.
  Future<bool> _hasSignificantChanges(
      Map<String, dynamic> newProfileData) async {
    try {
      final currentProfile = await ProfileService().getProfile();
      if (currentProfile == null) return true;

      const significantFields = [
        'name',
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
        dynamic newValue = newProfileData[field];
        dynamic currentValue = currentProfile[field];

        if (newValue is String) {
          newValue = removeEmojis(newValue);
        }
        if (currentValue is String) {
          currentValue = removeEmojis(currentValue);
        }

        if (newValue is List && currentValue is List) {
          final newSet = newValue
              .whereType<String>()
              .map((item) => removeEmojis(item))
              .toSet();
          final currentSet = currentValue
              .whereType<String>()
              .map((item) => removeEmojis(item))
              .toSet();

          if (newSet.length != currentSet.length ||
              !newSet.every((element) => currentSet.contains(element))) {
            debugPrint(
                '[QuestionnaireFlow] Cambio detectado en $field (List). Nuevo: $newSet, Anterior: $currentSet');
            return true;
          }
        } else if (newValue != currentValue) {
          debugPrint(
              '[QuestionnaireFlow] Cambio detectado en $field (Single Value). Nuevo: $newValue, Anterior: $currentValue');
          return true;
        }
      }
      debugPrint(
          '[QuestionnaireFlow] No se detectaron cambios significativos en el perfil.');
      return false;
    } catch (e) {
      debugPrint('[QuestionnaireFlow] Error al comparar cambios: $e');
      return true;
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
                physics:
                    const NeverScrollableScrollPhysics(), // Deshabilita el deslizamiento manual
                children: [
                  WelcomeScreen(isEditing: widget.isEditing),
                  const PersonalInfoScreen(),
                  const RoutineScreen(),
                  const AlimentacionScreen(),
                  const GustosScreen(), // Pantalla de Gustos con dietStyle y budget
                  const PreferencesScreen(), // Pantalla de Preferencias
                  const PersonalizacionScreen(), // Pantalla de Personalización con dificultades y motivaciones
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

// -----------------------------------------------------------------------------
// SECCIONES DE PANTALLA INDIVIDUALES
// -----------------------------------------------------------------------------

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
          const QuestionnaireTitleARRIBA(
            title: 'Sobre ti 👤',
          ),

          /*   const QuestionnaireTitle(
              title: 'Primero lo primero. Escribe tu nombre. ', isSub: true),
          CustomTextField(
            label: 'Nombre',
            initialValue: provider.name,
            onChanged: (val) => provider.update(() => provider.name = val),
            errorText: validationErrors['name'],
          ),
          */
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
            initialValue: provider.sport,
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
              (val) => provider.update(() => provider.trainingFrequency = val)),
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
            padding: const EdgeInsets.only(
                bottom: 8.0), // Espacio vertical entre chips
            child: GestureDetector(
              onTap: () => setState(() => context
                  .read<QuestionnaireProvider>()
                  .update(() => updateFn(opt))),
              child: Chip(
                label: Text(
                  opt,
                  style: TextStyle(
                    color: groupValue == opt
                        ? Colors.white
                        : FrutiaColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap:
                      true, // Permite que el texto se divida en varias líneas
                  overflow: TextOverflow.visible, // Evita que se corte
                ),
                backgroundColor:
                    groupValue == opt ? FrutiaColors.accent : Colors.grey[200]!,
                side: BorderSide(
                  color: groupValue == opt
                      ? FrutiaColors.accent
                      : Colors.grey[300]!,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

class GustosScreen extends StatefulWidget {
  const GustosScreen({super.key});
  @override
  State<GustosScreen> createState() => _GustosScreenState();
}

class _GustosScreenState extends State<GustosScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
    final provider = context.watch<QuestionnaireProvider>();
    final _flowState =
        context.findAncestorStateOfType<_QuestionnaireFlowState>();

    const predefinedStyles = {
      '🍖 Omnívoro': 'Omnívoro',
      '🥕 Vegetariano': 'Vegetariano',
      '🌱 Vegano': 'Vegano',
      '🥚 Keto / Low carb': 'Keto / Low carb',
    };

    // Esta lógica para 'Otro' ya es correcta y no necesita cambios.
    bool isOtherSelected = provider.dietStyle != null &&
        !predefinedStyles.keys // Comparamos con las claves ahora
            .contains(provider.dietStyle!);

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
                // CORRECCIÓN 1: Compara el valor del provider con la CLAVE del mapa.
                isSelected: provider.dietStyle == entry.key,
                // CORRECCIÓN 2: Al tocar, guarda la CLAVE del mapa en el provider.
                onTap: () =>
                    provider.update(() => provider.dietStyle = entry.key),
              );
            }).toList(),
            ChoiceChipCard(
              label: '✍️ Otro',
              isSelected: isOtherSelected,
              onTap: () => provider.update(() => provider.dietStyle =
                  ''), // Esto está bien para indicar "Otro"
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

/// Pantalla para personalizar dificultades y motivaciones alimentarias.
class PersonalizacionScreen extends StatefulWidget {
  const PersonalizacionScreen({super.key});

  @override
  State<PersonalizacionScreen> createState() => _PersonalizacionScreenState();
}

class _PersonalizacionScreenState extends State<PersonalizacionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<QuestionnaireProvider>();
    final validationErrors = context
            .findAncestorStateOfType<_QuestionnaireFlowState>()
            ?._validationErrors ??
        {};

    // Determine the initial value for the "Otra" text field for difficulties
    String? initialOtraDificultad = provider.dietDifficulties.firstWhere(
      (item) => item.startsWith('Otra: '),
      orElse: () => '',
    );
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

  /// Construye las opciones de selección múltiple para dificultades o motivaciones.
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

  // DENTRO DE LA CLASE _PreferencesScreenState

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
                value: entry
                    .key, // <-- CORREGIDO: Cambiado de entry.value a entry.key
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
