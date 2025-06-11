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

// WIDGET PRINCIPAL CON NAVEGACIÓN Y BARRA DE PROGRESO
class QuestionnaireFlow extends StatefulWidget {
  const QuestionnaireFlow({super.key});

  @override
  State<QuestionnaireFlow> createState() => _QuestionnaireFlowState();
}

class _QuestionnaireFlowState extends State<QuestionnaireFlow> {
  final PageController _pageController = PageController();
  final _allergyController = TextEditingController();

  double _progress = 0;
  final int _numPages = 6;

  // Validation errors for text fields
  Map<String, String?> _validationErrors = {};

  // Helper function to remove emojis from a string
  String removeEmojis(String text) {
    // Regex to match Unicode emojis
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    return text.replaceAll(emojiRegex, '').trim();
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _progress = _pageController.page! / (_numPages - 1);
          _validationErrors = {}; // Clear errors when page changes
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  // Update _validateCurrentPage in _QuestionnaireFlowState
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
        return true; // No validation needed
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
          // Allow "Ninguno" or non-empty custom input
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
        if (provider.whoCooks == null) {
          errorMessages.add('Selecciona quién cocina');
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
        if (provider.preferredMessageTypes.isEmpty) {
          errorMessages.add('Selecciona al menos un tipo de mensaje');
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
// En _QuestionnaireFlowState dentro de questionnaire_flow.dart

  void _handleNextOrFinish() async {
    if (!_validateCurrentPage()) {
      return; // No avanza si la validación de la página actual falla
    }

    // Si no es la última página, solo avanza
    if (_pageController.page! < _numPages - 1) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOut);
      return;
    }

    // --- LÓGICA FINAL DE GUARDADO Y GENERACIÓN DE PLAN ---
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Guardar el perfil del usuario con los datos del cuestionario
      final questionnaireProvider = context.read<QuestionnaireProvider>();
      final profileData = {
        'goal': questionnaireProvider.mainGoal != null
            ? removeEmojis(questionnaireProvider.mainGoal!)
            : '',
        'activity_level': questionnaireProvider.dailyActivityLevel != null
            ? removeEmojis(questionnaireProvider.dailyActivityLevel!)
            : '',
        'dietary_style': questionnaireProvider.dietStyle != null
            ? removeEmojis(questionnaireProvider.dietStyle!)
            : '',
        'budget': questionnaireProvider.weeklyBudget != null
            ? removeEmojis(questionnaireProvider.weeklyBudget!)
            : '',
        'cooking_habit': questionnaireProvider.whoCooks != null
            ? removeEmojis(questionnaireProvider.whoCooks!)
            : '',
        'eats_out': questionnaireProvider.eatsOut != null
            ? removeEmojis(questionnaireProvider.eatsOut!)
            : '',
        'disliked_foods': questionnaireProvider.dislikedFoods,
        'allergies': questionnaireProvider.allergyDetails,
        'medical_condition': questionnaireProvider.medicalConditionDetails,
        'communication_style': questionnaireProvider.communicationTone != null
            ? removeEmojis(questionnaireProvider.communicationTone!)
            : '',
        'motivation_style': questionnaireProvider.preferredMessageTypes
            .map((type) => removeEmojis(type))
            .join(','),
        'preferred_name': questionnaireProvider.preferredName ?? '',
        'things_to_avoid': questionnaireProvider.thingsToAvoid,
        'sport': questionnaireProvider.sport,
        'training_frequency': questionnaireProvider.trainingFrequency != null
            ? removeEmojis(questionnaireProvider.trainingFrequency!)
            : '',
        'meal_count': questionnaireProvider.mealCount != null
            ? removeEmojis(questionnaireProvider.mealCount!)
            : '',
        'breakfast_time': formatTimeOfDay(questionnaireProvider.breakfastTime),
        'lunch_time': formatTimeOfDay(questionnaireProvider.lunchTime),
        'dinner_time': formatTimeOfDay(questionnaireProvider.dinnerTime),
        'plan_setup_complete': true,
      };

      await ProfileService().saveProfile(profileData);

      // 2. CAPTURAMOS LA RESPUESTA QUE CONTIENE EL PLAN
      final newPlanResponse = await PlanService().generatePlan();

      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo de carga

        // --- PASOS CORREGIDOS ---

        // 2.1. Extraemos el mapa de datos crudo del plan desde la respuesta de la API.
        final planJson = newPlanResponse['data']['plan_data'];

        // 2.2. Usamos el constructor de fábrica para convertir el mapa en un objeto MealPlanData.
        final planDataObject = MealPlanData.fromJson(planJson);

        // 3. Navegamos a la pantalla de resumen, pasándole el OBJETO ya construido.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PlanSummaryScreen(
                planData: planDataObject), // <- Le pasamos el objeto
          ),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      print('--- ¡ERROR ATRAPADO DURANTE LA GENERACIÓN DEL PLAN! ---');
      print('Error: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        Navigator.of(context).pop(); // Cierra el diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Muestra un mensaje de error claro al usuario
            content: Text(
                'Error al generar tu plan: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Asegúrate de tener estas funciones auxiliares disponibles en el scope de tu clase
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
                children: const [
                  WelcomeScreen(),
                  PersonalInfoScreen(),
                  RoutineScreen(),
                  AlimentacionScreen(),
                  GustosScreen(),
                  PreferencesScreen(),
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
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationControls extends StatelessWidget {
  final PageController pageController;
  final int totalPages;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextOrFinishPressed;

  const NavigationControls({
    super.key,
    required this.pageController,
    required this.totalPages,
    required this.onPreviousPressed,
    required this.onNextOrFinishPressed,
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
            child:
                Text(currentPage < totalPages - 1 ? 'Continuar' : 'Finalizar'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return QuestionnaireScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Text('¡Listo para un plan hecho solo para ti! 🌟',
              style: GoogleFonts.lato(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText)),
          const SizedBox(height: 16),
          Text(
              'Responde estas preguntas para armar tu plan ideal según tu vida real. 📋',
              style: GoogleFonts.lato(
                  fontSize: 18,
                  color: FrutiaColors.secondaryText,
                  height: 1.5)),
          const SizedBox(height: 60),
          // Animación Lottie con efectos
          Center(
            child: Lottie.asset(
              'assets/images/animacionPlan.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),

          const SizedBox(height: 40),
          Center(
              child: Text("Desliza o presiona 'Continuar' ➡️",
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: FrutiaColors.disabledText))),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.2, curve: Curves.easeOut);
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
      '🔥  Bajar grasa',
      '💪  Aumentar músculo',
      '🥗  Comer más saludable',
      '📈  Mejorar rendimiento',
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
          Text('¿Qué deporte practicas? 🏀',
              style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor)),
          const SizedBox(height: 16),
          SportSelection(
            name: 'sport',
            initialValue: provider.sport,
            onChanged: (value) =>
                provider.update(() => provider.sport = value ?? ''),
          ),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: 'Frecuencia de entrenamiento', isSub: true),
          ..._buildChipOptions([
            'No entreno 🚶',
            '1-2 días/semana 🏋️',
            '3-5 días/semana 💪',
            'Todos los días 🏃‍♂️'
          ], provider.trainingFrequency,
              (val) => provider.trainingFrequency = val),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: 'Nivel de actividad diaria (fuera del entreno)',
              isSub: true),
          ..._buildChipOptions(
              ['Sedentario (oficina) 💼', 'Activo 🚴', 'Muy Activo 🏃‍♀️'],
              provider.dailyActivityLevel,
              (val) => provider.dailyActivityLevel = val),
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
        children: options
            .map((opt) => OptionChip(
                  label: opt,
                  selected: groupValue == opt, // Changed isSelected to selected
                  onTap: (val) => setState(() => context
                      .read<QuestionnaireProvider>()
                      .update(() => updateFn(val))),
                ))
            .toList(),
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
              title: '¿Cuántas veces al día te gustaría comer?', isSub: true),
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
              title: '¿Cocinas tú o alguien más?', isSub: true),
          ..._buildCookingHabitOptions(provider),
          const QuestionnaireTitle(
              title: '¿Sueles comer fuera de casa? 🍔', isSub: true),
          ..._buildEatOutOptions(provider),
        ],
      ),
    );
  }

  List<Widget> _buildMealCountOptions(QuestionnaireProvider provider) {
    const options = {
      '🍽️  3 comidas principales',
      '🥐  3 comidas + 1 snack',
      '🥗  5 comidas pequeñas',
      '🤗  Lo que sea más práctico',
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

  List<Widget> _buildCookingHabitOptions(QuestionnaireProvider provider) {
    const options = {'👨 Cocino yo ', '👨‍🍳 Alguien más cocina'};
    return options
        .map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: opt,
                value: opt,
                groupValue: provider.whoCooks,
                onTap: (val) => setState(
                    () => provider.update(() => provider.whoCooks = val)),
              ),
            ))
        .toList();
  }

  List<Widget> _buildEatOutOptions(QuestionnaireProvider provider) {
    const options = {
      '✅ Sí',
      '🚫 No',
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
  final _allergyController = TextEditingController();

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
              title: '¿Cuánto puedes gastar en comida por semana? 💰',
              isSub: true),
          ..._buildBudgetOptions(provider),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildBudgetOptions(QuestionnaireProvider provider) {
    const options = [
      '💸  Menos de S/50 ',
      '💵  Entre S/50 y S/100 ',
      '💳  Más de S/100 ',
      '❓  No estoy seguro'
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
          ..._buildSelectionCards({
            'Como un coach, directo 🏋️',
            'Relajado, como un amigo 😊',
            'Me da igual 🔄'
          }, provider.communicationTone,
              (val) => provider.update(() => provider.communicationTone = val)),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: '¿Qué tipo de mensajes prefieres recibir?', isSub: true),
          ..._buildCheckboxOptions({
            'Mensajes de ánimo y energía 🥗',
            'Información y datos 📊',
            'Datos duros (si no sigo el plan) ⚠️'
          }, provider.preferredMessageTypes),
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
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title: '¿Hay algo que deba evitar mencionar?', isSub: true),
          CustomTextField(
            label: 'Escríbelo aquí (opcional)',
            initialValue: provider.thingsToAvoid,
            onChanged: (val) =>
                provider.update(() => provider.thingsToAvoid = val),
          ),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  List<Widget> _buildSelectionCards(
      Set<String> options, String? groupValue, Function(String) updateFn) {
    return options
        .map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SelectionCard(
                title: option,
                value: option,
                groupValue: groupValue,
                onTap: (val) => setState(() => updateFn(val)),
              ),
            ))
        .toList();
  }

  List<Widget> _buildCheckboxOptions(
      Set<String> options, Set<String> selectedValues) {
    return options
        .map((option) => CheckboxListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(option),
              value: selectedValues.contains(option),
              onChanged: (value) {
                setState(() {
                  context.read<QuestionnaireProvider>().update(() {
                    if (value ?? false) {
                      selectedValues.add(option);
                    } else {
                      selectedValues.remove(option);
                    }
                  });
                });
              },
              activeColor: FrutiaColors.accent,
            ))
        .toList();
  }
}

class QuestionnaireScreen extends StatelessWidget {
  final Widget child;
  const QuestionnaireScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: child,
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
            color: Colors.redAccent, // Fondo negro
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(8), // Esquinas redondeadas
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            widget.title,
            style: GoogleFonts.lato(
              fontSize: widget.isSub ? 20 : 24,
              fontWeight: widget.isSub ? FontWeight.w600 : FontWeight.bold,
              color: Colors.white, // Letras blancas
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
  final bool selected; // Changed isSelected to selected
  final Function(String) onTap;
  const OptionChip({
    Key? key,
    required this.label,
    required this.selected, // Changed isSelected to selected
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
