// lib/pages/screens/datosPersonales/QuestionnaireFlow.dart

import 'dart:math';

import 'package:Frutia/auth/auth_check.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:Frutia/pages/screens/datosPersonales/PlanSummaryScreen.dart';
import 'package:Frutia/pages/screens/datosPersonales/SuccessScreen.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:Frutia/providers/QuestionnaireProvider.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart'; // Asegúrate de tener form_builder en pubspec.yaml
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Asegúrate de tener lottie en pubspec.yaml
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Para firstWhereOrNull

// WIDGET PRINCIPAL CON NAVEGACIÓN Y BARRA DE PROGRESO
class QuestionnaireFlow extends StatefulWidget {
  final Map<String, dynamic>? initialProfileData;

  const QuestionnaireFlow({super.key, this.initialProfileData});

  @override
  State<QuestionnaireFlow> createState() => _QuestionnaireFlowState();
}

class _QuestionnaireFlowState extends State<QuestionnaireFlow> {
  final PageController _pageController = PageController();
  final _allergyController = TextEditingController();
  final _otraDificultadController =
      TextEditingController(); // Controlador para "Otra" dificultad

  double _progress = 0;
  final int _numPages = 7;

  Map<String, String?> _validationErrors = {};

  // Función auxiliar para eliminar emojis de una cadena
  String removeEmojis(String text) {
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    return text.replaceAll(emojiRegex, '').trim();
  }

  // Helper para parsear TimeOfDay desde string "HH:MM"
  TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {
      print('Error parsing time string "$timeStr": $e');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // <--- CAMBIO CLAVE AQUÍ ---
    // Usamos addPostFrameCallback para ejecutar la lógica de precarga
    // después de que el frame actual haya terminado de construirse.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviderData();
    });

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _progress = _pageController.page! / (_numPages - 1);
          _validationErrors = {};
        });
      }
    });
  }

  void _initializeProviderData() {
    final provider = context.read<QuestionnaireProvider>();

    if (widget.initialProfileData != null) {
      final data = widget.initialProfileData!;
      debugPrint('Pre-cargando datos de perfil: $data');

      provider.update(() {
        provider.name = data['name'] as String? ?? '';
        provider.mainGoal = data['goal'] as String?;
        provider.dailyActivityLevel = data['activity_level'] as String?;
        provider.dietStyle = data['dietary_style'] as String?;
        provider.weeklyBudget = data['budget'] as String?;
        provider.eatsOut = data['eats_out'] as String?;
        provider.dislikedFoods = data['disliked_foods'] as String? ?? '';
        provider.hasAllergies = data['has_allergies'] as bool? ?? false;
        provider.allergyDetails = data['allergies'] as String? ?? '';
        provider.hasMedicalCondition =
            data['has_medical_condition'] as bool? ?? false;
        provider.medicalConditionDetails =
            data['medical_condition'] as String? ?? '';
        provider.communicationTone = data['communication_style'] as String?;
        provider.preferredName = data['preferred_name'] as String? ?? '';

        if (data['sport'] is String && (data['sport'] as String).isNotEmpty) {
          provider.sport = (data['sport'] as String)
              .split(',')
              .map((s) => s.trim())
              .toList();
        } else if (data['sport'] is List) {
          provider.sport =
              (data['sport'] as List<dynamic>).cast<String>().toList();
        } else {
          provider.sport = [];
        }

        provider.trainingFrequency = data['training_frequency'] as String?;
        provider.mealCount = data['meal_count'] as String?;

        provider.breakfastTime =
            _parseTimeOfDay(data['breakfast_time'] as String?);
        provider.lunchTime = _parseTimeOfDay(data['lunch_time'] as String?);
        provider.dinnerTime = _parseTimeOfDay(data['dinner_time'] as String?);

        if (data['diet_difficulties'] is List) {
          provider.dietDifficulties =
              (data['diet_difficulties'] as List<dynamic>)
                  .cast<String>()
                  .toSet();
        } else {
          provider.dietDifficulties = {};
        }

        if (data['diet_motivations'] is List) {
          provider.dietMotivations = (data['diet_motivations'] as List<dynamic>)
              .cast<String>()
              .toSet();
        } else {
          provider.dietMotivations = {};
        }

        final existingOtraDifficulty = provider.dietDifficulties
            .firstWhereOrNull((d) => d.startsWith('Otra: '));
        if (existingOtraDifficulty != null) {
          _otraDificultadController.text =
              existingOtraDifficulty.replaceFirst('Otra: ', '');
          provider.dietDifficulties.remove(existingOtraDifficulty);
          if (!provider.dietDifficulties.contains('Otra')) {
            provider.dietDifficulties.add('Otra');
          }
        } else if (provider.dietDifficulties.contains('Otra')) {
          _otraDificultadController.clear();
        }
      });

      // Asegurarse de que los TextEditingControllers reflejen los datos cargados
      _allergyController.text = provider.allergyDetails;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _allergyController.dispose();
    _otraDificultadController.dispose();
    super.dispose();
  }

  // Valida los campos de la página actual antes de avanzar
  bool _validateCurrentPage() {
    final provider = context.read<QuestionnaireProvider>();
    final currentPage =
        _pageController.hasClients ? (_pageController.page?.round() ?? 0) : 0;

    setState(() {
      _validationErrors = {}; // Limpia errores previos
    });

    bool isValid = true;
    List<String> errorMessages = [];

    switch (currentPage) {
      case 0: // WelcomeScreen
        return true; // No se necesita validación en la pantalla de bienvenida
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
        // Puedes agregar validaciones para edad, peso, altura, sexo, país aquí si los incluyes
        break;
      case 2: // RoutineScreen
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
        if (provider.weeklyBudget == null) {
          errorMessages.add('Selecciona tu presupuesto semanal');
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
        // Validación para "Otra" dificultad
        final hasOtraSelected = provider.dietDifficulties.contains('Otra');
        final hasOtraDetailed =
            provider.dietDifficulties.any((item) => item.startsWith('Otra: '));

        if (hasOtraSelected &&
            !hasOtraDetailed &&
            _otraDificultadController.text.isEmpty) {
          _validationErrors['otraDificultad'] =
              'Específica tu otra dificultad alimentaria';
          isValid = false;
        } else if (!hasOtraSelected && hasOtraDetailed) {
          provider.dietDifficulties
              .removeWhere((item) => item.startsWith('Otra:'));
          _otraDificultadController.clear();
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

  // Maneja la navegación a la siguiente página o finaliza el cuestionario
  void _handleNextOrFinish() async {
    if (!_validateCurrentPage()) {
      return; // No avanza si la validación de la página actual falla
    }

    if (_pageController.page! < _numPages - 1) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOut);
      return;
    }

    // --- LÓGICA FINAL DE GUARDADO Y GENERACIÓN DE PLAN ---
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
                'Generando tu plan personalizado... Espere un momento.',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.primaryText,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(duration: 300.ms, curve: Curves.easeOut),
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
              )
            ],
          ),
        ),
      ),
    );

    try {
      final questionnaireProvider = context.read<QuestionnaireProvider>();

      // --- Lógica para preparar dietDifficulties antes de guardar ---
      final currentDietDifficultiesForSave =
          Set<String>.from(questionnaireProvider.dietDifficulties);

      // Eliminar cualquier "Otra: detalle" existente para evitar duplicados en el proceso de guardado
      currentDietDifficultiesForSave
          .removeWhere((item) => item.startsWith('Otra: '));

      // Si 'Otra' está seleccionada Y el controlador de texto tiene contenido
      if (questionnaireProvider.dietDifficulties.contains('Otra') &&
          _otraDificultadController.text.isNotEmpty) {
        currentDietDifficultiesForSave
            .add('Otra: ${_otraDificultadController.text}');
      } else if (questionnaireProvider.dietDifficulties.contains('Otra') &&
          _otraDificultadController.text.isEmpty) {
        currentDietDifficultiesForSave.remove('Otra');
      }
      // --- Fin Lógica para preparar dietDifficulties ---

      final profileData = {
        'name': questionnaireProvider.name,
        'goal': questionnaireProvider.mainGoal != null
            ? removeEmojis(questionnaireProvider.mainGoal!)
            : '',
        'activity_level': questionnaireProvider.dailyActivityLevel != null
            ? removeEmojis(questionnaireProvider.dailyActivityLevel!)
            : '',
        'dietary_style': questionnaireProvider.dietStyle != null
            ? removeEmojis(questionnaireProvider.dietStyle!)
            : '',
        'budget': questionnaireProvider.weeklyBudget !=
                null // Envía 'weeklyBudget' a 'budget' del backend
            ? removeEmojis(questionnaireProvider.weeklyBudget!)
            : '',
        'eats_out': questionnaireProvider.eatsOut != null
            ? removeEmojis(questionnaireProvider.eatsOut!)
            : '',
        'disliked_foods': questionnaireProvider.dislikedFoods,
        'has_allergies': questionnaireProvider.hasAllergies,
        'allergies': questionnaireProvider.allergyDetails,
        'has_medical_condition': questionnaireProvider.hasMedicalCondition,
        'medical_condition': questionnaireProvider.medicalConditionDetails,
        'communication_style': questionnaireProvider.communicationTone != null
            ? removeEmojis(questionnaireProvider.communicationTone!)
            : '',
        'preferred_name': questionnaireProvider.preferredName ?? '',
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
        'diet_difficulties':
            currentDietDifficultiesForSave.toList(), // Usa el Set preparado
        'diet_motivations': questionnaireProvider.dietMotivations.toList(),
        'plan_setup_complete': true,
        // Si tienes edad, peso, altura, sexo, país en el backend y los quieres aquí,
        // asegúrate de añadirlos al provider y a este map.
        // 'age': questionnaireProvider.age,
        // 'weight': questionnaireProvider.weight,
        // 'height': questionnaireProvider.height,
        // 'sex': questionnaireProvider.sex,
        // 'pais': questionnaireProvider.country,
      };

      questionnaireProvider.printSummary();

      await ProfileService().saveProfile(profileData);
      await PlanService().generatePlan();

      if (mounted) {
        Navigator.of(context).pop();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PlanSummaryScreen()),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('--- ¡ERROR ATRAPADO DURANTE LA GENERACIÓN DEL PLAN! ---');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error al generar tu plan: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Formatea un objeto TimeOfDay a una cadena "HH:MM"
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
                  const WelcomeScreen(),
                  const PersonalInfoScreen(),
                  const RoutineScreen(),
                  const AlimentacionScreen(),
                  const GustosScreen(),
                  const PreferencesScreen(),
                  PersonalizacionScreen(
                    otraDificultadController: _otraDificultadController,
                  ),
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
          // Si tienes edad, peso, altura, sexo, país en tu provider y backend,
          // asegúrate de que sus CustomTextField, SelectionCard o GenderCard estén aquí
          // y se sincronicen con el provider (ej. provider.age = ...).
          // Aquí puedes agregar campos para edad, peso, altura, sexo y país.
          // Por ejemplo:
          // CustomTextField(
          //   label: 'Edad',
          //   initialValue: provider.age?.toString(),
          //   onChanged: (val) => provider.update(() => provider.age = int.tryParse(val)),
          //   keyboardType: TextInputType.number,
          // ),
          // const SizedBox(height: 16),
          // CustomTextField(
          //   label: 'Peso (kg)',
          //   initialValue: provider.weight?.toStringAsFixed(1),
          //   onChanged: (val) => provider.update(() => provider.weight = double.tryParse(val)),
          //   keyboardType: TextInputType.number,
          // ),
          // const SizedBox(height: 16),
          // CustomTextField(
          //   label: 'Altura (cm)',
          //   initialValue: provider.height?.toStringAsFixed(0),
          //   onChanged: (val) => provider.update(() => provider.height = double.tryParse(val)),
          //   keyboardType: TextInputType.number,
          // ),
          // const SizedBox(height: 16),
          // GenderSelectionCard(
          //   selectedGender: provider.sex,
          //   onGenderSelected: (gender) => provider.update(() => provider.sex = gender),
          // ),
          // const SizedBox(height: 16),
          // CustomTextField(
          //   label: 'País',
          //   initialValue: provider.country,
          //   onChanged: (val) => provider.update(() => provider.country = val),
          // ),
          const SizedBox(
              height:
                  16), // Mantiene un espacio si no agregas los campos de arriba
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
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => context
                  .read<QuestionnaireProvider>()
                  .update(() => updateFn(opt))),
              child: Chip(
                label: Flexible(
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: groupValue == opt
                          ? Colors.white
                          : FrutiaColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
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
          CustomTimePickerField(
            label: 'Desayuno',
            icon: Icons.light_mode_rounded,
            selectedTime: provider.breakfastTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.breakfastTime = time),
          ),
          const SizedBox(height: 16),
          CustomTimePickerField(
            label: 'Almuerzo',
            icon: Icons.wb_sunny_rounded,
            selectedTime: provider.lunchTime,
            onTimeSelected: (time) =>
                provider.update(() => provider.lunchTime = time),
          ),
          const SizedBox(height: 16),
          CustomTimePickerField(
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
              title:
                  'Con qué tipo de presupuesto cuentas para tu alimentación semanal? 💰',
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
                groupValue:
                    provider.weeklyBudget, // Usa weeklyBudget del provider
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
      initialValue: '',
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
                    label: entry.key,
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

class PersonalizacionScreen extends StatefulWidget {
  final TextEditingController otraDificultadController;
  const PersonalizacionScreen(
      {super.key, required this.otraDificultadController});
  @override
  State<PersonalizacionScreen> createState() => _PersonalizacionScreenState();
}

class _PersonalizacionScreenState extends State<PersonalizacionScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final provider = context.read<QuestionnaireProvider>();
    final existingOtra = provider.dietDifficulties
        .firstWhereOrNull((d) => d.startsWith('Otra: '));
    if (existingOtra != null) {
      widget.otraDificultadController.text =
          existingOtra.replaceFirst('Otra: ', '');
      provider.dietDifficulties.remove(existingOtra);
      if (!provider.dietDifficulties.contains('Otra')) {
        provider.dietDifficulties.add('Otra');
      }
    }
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
          ..._buildCheckboxOptions({
            'Mantenerme constante 🔄',
            'Saber qué comer cuando no tengo lo del plan 🤔',
            'Comer saludable fuera de casa 🍽️',
            'Controlar los antojos 🍫',
            'Preparar la comida 🧑‍🍳',
          }, provider.dietDifficulties),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Row(
              children: [
                Checkbox(
                  value: provider.dietDifficulties.contains('Otra'),
                  onChanged: (value) {
                    setState(() {
                      provider.update(() {
                        if (value ?? false) {
                          provider.dietDifficulties.add('Otra');
                        } else {
                          provider.dietDifficulties.remove('Otra');
                          provider.dietDifficulties
                              .removeWhere((item) => item.startsWith('Otra:'));
                          widget.otraDificultadController.clear();
                        }
                      });
                    });
                  },
                  activeColor: FrutiaColors.accent,
                ),
                const Text('Otra:'),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    controller: widget.otraDificultadController,
                    label: 'Especifica',
                    onChanged: (val) => provider.update(() {
                      provider.dietDifficulties
                          .removeWhere((item) => item.startsWith('Otra:'));
                      if (val.isNotEmpty) {
                        provider.dietDifficulties.add('Otra: $val');
                        if (!provider.dietDifficulties.contains('Otra')) {
                          provider.dietDifficulties.add('Otra');
                        }
                      } else {
                        // Si el texto se vacía y 'Otra' está seleccionada, la desmarcamos lógicamente para el envío
                        // Esto se manejará en _handleNextOrFinish para el guardado final
                      }
                    }),
                    errorText: validationErrors['otraDificultad'],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const QuestionnaireTitle(
              title:
                  '¿Qué es lo que más te motiva a seguir un plan de alimentación?',
              isSub: true),
          ..._buildCheckboxOptions({
            'Ver resultados rápidos ⚡',
            'Sentirme mejor físicamente (energía, digestión, menos pesadez) 💪',
            'Demostrarme que puedo lograrlo 💯',
            'Mejorar mi salud a largo plazo 🏥',
            'Aún no lo tengo claro ❓',
          }, provider.dietMotivations),
          const SizedBox(height: 24),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
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
            ' Motivadora (que te empuje a dar más cuando lo necesites) 🏋️',
            'Cercana (como un amigo que te acompaña sin presión) 😊',
            'Directa (clara, sin vueltas ni frases suaves) 🤗',
            'Como te salga a ti, yo me adapto 🔄'
          }, provider.communicationTone,
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

// ***************************************************************
// Las siguientes clases son widgets de utilidad que tu código original
// utilizaba y que se incluyen aquí para hacer el archivo autocontenido.
// Si ya las tienes en sus propios archivos 'utils/', asegúrate de
// no duplicar su definición.
// ***************************************************************

/// Widget para campos de texto personalizados con estilos de la aplicación.
class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? emoji;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    this.initialValue,
    this.onChanged,
    this.errorText,
    this.emoji,
    this.controller,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller ?? TextEditingController(text: initialValue),
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: GoogleFonts.lato(color: FrutiaColors.primaryText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: FrutiaColors.secondaryText),
          errorText: errorText,
          prefixText: emoji != null ? '$emoji ' : null,
          prefixStyle: const TextStyle(fontSize: 20),
          filled: true,
          fillColor: FrutiaColors.overlay,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: FrutiaColors.disabledText.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: FrutiaColors.accent, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
      ),
    );
  }
}

/// Widget para seleccionar un deporte (multi-selección).
class SportSelection extends StatefulWidget {
  final String name;
  final List<String> initialValue;
  final ValueChanged<List<String>?> onChanged;

  const SportSelection({
    Key? key,
    required this.name,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SportSelectionState createState() => _SportSelectionState();
}

class _SportSelectionState extends State<SportSelection> {
  late List<String> _selectedSports;

  final List<Map<String, String>> _sportOptions = const [
    {'label': 'Fútbol ⚽', 'value': 'Fútbol'},
    {'label': 'Baloncesto 🏀', 'value': 'Baloncesto'},
    {'label': 'Natación 🏊‍♀️', 'value': 'Natación'},
    {'label': 'Ciclismo 🚴‍♂️', 'value': 'Ciclismo'},
    {'label': 'Correr 🏃‍♀️', 'value': 'Correr'},
    {
      'label': 'Levantamiento de pesas 🏋️‍♂️',
      'value': 'Levantamiento de pesas'
    },
    {'label': 'Yoga 🧘‍♀️', 'value': 'Yoga'},
    {'label': 'Baile 🕺', 'value': 'Baile'},
    {'label': 'CrossFit 🤸‍♂️', 'value': 'CrossFit'},
    {'label': 'Artes marciales 🥋', 'value': 'Artes marciales'},
    {'label': 'Senderismo ⛰️', 'value': 'Senderismo'},
    {'label': 'Ninguno / Otro 🚶‍♂️', 'value': 'Ninguno / Otro'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedSports = List.from(widget.initialValue);
  }

  void _toggleSport(String sportValue) {
    setState(() {
      if (_selectedSports.contains(sportValue)) {
        _selectedSports.remove(sportValue);
      } else {
        _selectedSports.add(sportValue);
      }
      widget.onChanged(_selectedSports);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _sportOptions.map((option) {
        final label = option['label']!;
        final value = option['value']!;
        final isSelected = _selectedSports.contains(value);

        return ChoiceChipCard(
          label: label,
          isSelected: isSelected,
          onTap: () => _toggleSport(value),
        );
      }).toList(),
    );
  }
}

/// Widget para seleccionar un horario (hora del día).
class CustomTimePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const CustomTimePickerField({
    Key? key,
    required this.label,
    required this.icon,
    required this.selectedTime,
    required this.onTimeSelected,
  }) : super(key: key);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: FrutiaColors
                  .accent, // Color de los botones y textos seleccionados
              onSurface: FrutiaColors.primaryText, // Color del texto del reloj
              surface: FrutiaColors.primaryBackground, // Fondo del dialog
            ),
            dialogBackgroundColor:
                FrutiaColors.overlay, // Color de fondo del picker
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: FrutiaColors.overlay,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FrutiaColors.disabledText.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: FrutiaColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.lato(
                  color: FrutiaColors.primaryText,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              selectedTime?.format(context) ?? 'Seleccionar hora',
              style: GoogleFonts.lato(
                color: selectedTime == null
                    ? FrutiaColors.secondaryText
                    : FrutiaColors.primaryText,
                fontSize: 16,
                fontWeight:
                    selectedTime == null ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const Icon(Icons.keyboard_arrow_right,
                color: FrutiaColors.secondaryText),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de selección simple (radio-like)
class SelectionCard extends StatelessWidget {
  final String title;
  final String value;
  final String? groupValue;
  final ValueChanged<String> onTap;

  const SelectionCard({
    Key? key,
    required this.title,
    required this.value,
    this.groupValue,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? FrutiaColors.accent : FrutiaColors.overlay,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? FrutiaColors.accent
                : FrutiaColors.disabledText.withOpacity(0.3),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: FrutiaColors.accent.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : FrutiaColors.secondaryText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lato(
                  color: isSelected ? Colors.white : FrutiaColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de tipo ChoiceChipCard para selecciones múltiples o únicas con estilo de chip.
class ChoiceChipCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceChipCard({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: GoogleFonts.lato(
            color: isSelected ? Colors.white : FrutiaColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isSelected ? FrutiaColors.accent : Colors.grey[200]!,
        side: BorderSide(
          color: isSelected ? FrutiaColors.accent : Colors.grey[300]!,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// Widget para seleccionar el género.
class GenderSelectionCard extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderSelectionCard({
    Key? key,
    required this.selectedGender,
    required this.onGenderSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Sexo:',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: SelectionCard(
                title: 'Hombre 👨',
                value: 'Masculino',
                groupValue: selectedGender,
                onTap: onGenderSelected,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SelectionCard(
                title: 'Mujer 👩',
                value: 'Femenino',
                groupValue: selectedGender,
                onTap: onGenderSelected,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
