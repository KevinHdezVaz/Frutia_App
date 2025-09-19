import 'dart:convert';
import 'dart:io';
import 'package:Frutia/pages/Pantalla2.dart';
import 'package:Frutia/pages/screens/historyScreen.dart';
import 'package:Frutia/pages/screens/miplan/DescargarPDFDialog.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class ProfessionalMiPlanDiarioScreen extends StatefulWidget {
  const ProfessionalMiPlanDiarioScreen({Key? key}) : super(key: key);

  @override
  _ProfessionalMiPlanDiarioScreenState createState() =>
      _ProfessionalMiPlanDiarioScreenState();
}

class _ProfessionalMiPlanDiarioScreenState
    extends State<ProfessionalMiPlanDiarioScreen> {
  final PlanService _planService = PlanService();
  MealPlanData? _mealPlanData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userName;
  Map<String, dynamic>? _userProfile;
  final ProfileService _profileService = ProfileService();
  final Map<String, Map<String, MealOption>> _dailySelections = {};
  int _totalCalories = 0;
  int _totalProtein = 0;
  int _totalCarbs = 0;
  int _totalFats = 0;
   final Map<String, List<String>> _validationWarnings = {};
  final Map<String, bool> _hasEggSelection = {};
  String? _userBudget;
  final Set<String> _registeringMeals = {};
  final Set<String> _completedMeals = {};

  @override
  void initState() {
    super.initState();
    _fetchPlanAndInitialState();
    _fetchUserName();
        _extractUserBudget(); // NUEVO

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

  // NUEVO: Extraer el presupuesto del usuario
  void _extractUserBudget() {
    if (_userProfile != null) {
      _userBudget = _userProfile!['budget']?.toString().toLowerCase();
      debugPrint('Presupuesto del usuario: $_userBudget');
    }
  }



// MODIFICAR: Actualizar método de selección con validación
  void _updateSelection(String mealTitle, String categoryTitle, MealOption option) {
    if (_completedMeals.contains(mealTitle)) return;

    // Validar antes de actualizar
    final warnings = _validateOption(mealTitle, categoryTitle, option);
    
    setState(() {
      _dailySelections[mealTitle]![categoryTitle] = option;
      _validationWarnings[mealTitle] = warnings;
      
      // Verificar si hay huevos en esta comida
      if (option.isEgg) {
        _hasEggSelection[mealTitle] = true;
      }
      
      _calculateTotals();
    });

    // Mostrar warnings si existen
    if (warnings.isNotEmpty) {
      _showValidationWarning(warnings);
    }
  }



  // NUEVO: Método de validación
  List<String> _validateOption(String mealTitle, String categoryTitle, MealOption option) {
    List<String> warnings = [];
    
    // 1. Validar presupuesto
    if (_userBudget != null) {
      bool isLowBudget = _userBudget!.contains('bajo');
      
      if (isLowBudget && option.isHighBudget) {
        warnings.add('⚠️ "${option.name}" es de presupuesto alto, pero tu plan es económico');
      } else if (!isLowBudget && option.isLowBudget) {
        warnings.add('💡 Tienes presupuesto alto, podrías elegir opciones premium');
      }
    }
    
    // 2. Validar repetición de huevos
    if (option.isEgg) {
      // Verificar si ya hay huevos en otras comidas
      int eggCount = 0;
      _hasEggSelection.forEach((meal, hasEgg) {
        if (meal != mealTitle && hasEgg) eggCount++;
      });
      
      if (eggCount > 0) {
        warnings.add('🥚 Ya seleccionaste huevos en otra comida. Máximo 1 vez al día');
      }
    }
     
    
    return warnings;
  }



 

  // NUEVO: Obtener porcentaje de macros por comida
  double _getMealPercentage(String mealTitle) {
    switch (mealTitle.toLowerCase()) {
      case 'desayuno': return 0.30;
      case 'almuerzo': return 0.40;
      case 'cena': return 0.30;
      default: return 0.33;
    }
  }


  void _showValidationWarning(List<String> warnings) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: warnings.map((w) => Text(w)).toList(),
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Entendido',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }


  Future<void> _registerMeal(
      String mealTitle, List<MealOption> selections) async {
    setState(() {
      _registeringMeals.add(mealTitle);
    });

    try {
      await _saveSelections();
      await _planService.logMeal(
        date: DateTime.now(),
        mealType: mealTitle,
        selections: selections,
      );
      setState(() {
        _completedMeals.add(mealTitle);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mealTitle registrado con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _registeringMeals.remove(mealTitle);
      });
    }
  }

  bool get _isUserPremium {
    if (_userProfile == null) return false;
    final status = _userProfile?['subscription_status']?.toLowerCase();
    return status == 'active' || status == 'premium';
  }

  Future<void> _fetchUserNews() async {
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
          _userName = 'Usuario';
        });
      }
    }
  }

  Future<void> _fetchPlanAndInitialState() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _planService.getCurrentPlan(),
        _planService.getHistory(),
        _profileService.getProfile(),
      ]);

      final plan = results[0] as MealPlanData?;
      final history = results[1] as List<MealLog>;
      final profile = results[2] as Map<String, dynamic>?;

      if (plan == null) {
        if (mounted) {
          setState(() {
            _errorMessage = "No tienes un plan activo.";
            _isLoading = false;
          });
        }
        return;
      }

      plan.nutritionPlan.meals.keys.forEach((mealTitle) {
        _dailySelections[mealTitle] = {};
      });

      await _loadSelectionsFromLocal();

      final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final completedToday = history
          .where((log) => log.date == todayString)
          .map((log) => log.mealType);

      _completedMeals.addAll(completedToday);

      if (mounted) {
        setState(() {
          _mealPlanData = plan;
          _userProfile = profile;
          _isLoading = false;
          _calculateTotals();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar tus datos: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSelectionsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedData = prefs.getString('daily_selection_$today');

    if (savedData != null) {
      final decodedData = json.decode(savedData) as Map<String, dynamic>;

      decodedData.forEach((meal, selections) {
        if (_dailySelections.containsKey(meal)) {
          final Map<String, MealOption> loadedSelections = {};
          (selections as Map<String, dynamic>).forEach((cat, optJson) {
            loadedSelections[cat] = MealOption.fromJson(optJson);
          });
          _dailySelections[meal] = loadedSelections;
        }
      });
    }
  }
   

  Future<void> _saveSelections() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final encodedData = json.encode(_dailySelections.map((meal, selections) =>
        MapEntry(
            meal, selections.map((cat, opt) => MapEntry(cat, opt.toJson())))));
    await prefs.setString('daily_selection_$today', encodedData);
  }

  void _calculateTotals() {
    int tempCalories = 0, tempProtein = 0, tempCarbs = 0, tempFats = 0;
    _dailySelections.forEach((mealTitle, selections) {
      selections.values.forEach((option) {
        tempCalories += option.calories;
        tempProtein += option.protein;
        tempCarbs += option.carbs;
        tempFats += option.fats;
      });
    });
    setState(() {
      _totalCalories = tempCalories;
      _totalProtein = tempProtein;
      _totalCarbs = tempCarbs;
      _totalFats = tempFats;
    });
  }

  Future<void> _generateAndDownloadPDF() async {
    if (_mealPlanData == null || _userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No hay datos del plan o perfil para generar el PDF.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent)),
    );

    try {
      final pdf = pw.Document();
      final plan = _mealPlanData!.nutritionPlan;
      final profile = _userProfile!;
      final ByteData imageData =
          await rootBundle.load('assets/images/fondoAppFrutia.webp');
      final Uint8List imageBytes = imageData.buffer.asUint8List();

      final List<String> additionalRecommendations = [
        'Proteínas: se pesan crudas. Si están cocidas, resta 20 g al peso indicado.',
        'Carbohidratos: se pesan crudos',
        'Vegetales: son libres, úsalos con variedad para sumar fibra.',
        'Agua: Consume entre 30 a 40 ml por cada kg de peso corporal al día.',
        'Usa balanza digital y cucharas medidoras para mayor precisión.',
        'Cocina con aceite sin calorías o aceite de oliva extra virgen en mínima cantidad.',
      ];

      final List<String> additionalReminders = [
        'Establece horarios fijos de comida y respétalos todos los días.',
        'Varía tus recetas e innova en la cocina para evitar la monotonía.',
        'Prepara salsas caseras a base de vegetales como ají, rocoto, albahaca, tomate, pimientos, champiñones, entre otros.',
        'Si sabes que tendrás un día complicado, adelanta tus comidas o llévalas contigo. ¡Planifica con tiempo para no romper tu ritmo!',
      ];

      final allGeneralRecommendations = [
        ...plan.generalRecommendations,
        ...additionalRecommendations
      ];
      final allRememberRecommendations = [
        ...plan.rememberRecommendations,
        ...additionalReminders
      ];

      final font =
          pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
      final boldFont =
          pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
      final pw.ThemeData theme =
          pw.ThemeData.withFont(base: font, bold: boldFont);

      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) =>
              _buildPdfHeader(profile['name'] ?? 'Usuario', imageBytes),
          build: (pw.Context context) => [
            _buildProfileInfo(profile['profile']),
            pw.SizedBox(height: 20),
            _buildMacrosInfo(plan.targetMacros),
            pw.SizedBox(height: 20),
            if (plan.recommendation.isNotEmpty) ...[
              pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blueGrey50,
                    border:
                        pw.Border.all(color: PdfColors.blueGrey100, width: 1),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('¡Hola!:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(plan.recommendation,
                            style: pw.TextStyle(
                                color: PdfColors.grey800, lineSpacing: 2)),
                      ])),
              pw.SizedBox(height: 20),
            ],
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.yellow50,
                border: pw.Border.all(color: PdfColors.amber300, width: 1),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text(
                'Instrucción Importante: De cada comida, escoge solo UNA opción del grupo de Proteínas, UNA de Carbohidratos y UNA de Grasas para cumplir tus macros.',
                style: pw.TextStyle(color: PdfColors.grey800, fontSize: 17),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 15),
            ...plan.meals.entries.map((mealEntry) =>
                _buildMealPdfSection(mealEntry.key, mealEntry.value)),
          ],
        ),
      );

      pdf.addPage(pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) =>
              _buildPdfHeader(profile['name'] ?? 'Usuario', imageBytes),
          build: (pw.Context context) => [
                _buildRecommendationsSection(
                    'Recomendaciones Generales', allGeneralRecommendations),
                _buildRecommendationsSection(
                    'Recuerda', allRememberRecommendations),
              ]));

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/Plan_Frutia_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) Navigator.of(context).pop();
      OpenFile.open(file.path);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: ${e.toString()}')),
      );
    }
  }

  pw.Widget _buildPdfHeader(String userName, Uint8List imageBytes) {
    return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(bottom: 20.0),
        child: pw.Column(children: [
          pw.Text('Frutia',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 24,
                  color: PdfColors.red)),
          pw.Image(pw.MemoryImage(imageBytes), height: 60),
          pw.Text('Plan de Alimentación Personalizado para $userName',
              style: pw.TextStyle(fontSize: 18)),
          pw.Divider(color: PdfColors.grey400),
        ]));
  }

  pw.Widget _buildProfileInfo(Map<String, dynamic> profile) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Peso: ${profile['weight'] ?? 'N/A'} kg'),
          pw.Text('Talla: ${profile['height'] ?? 'N/A'} cm'),
          pw.Text('Edad: ${profile['age'] ?? 'N/A'} años'),
        ]);
  }

  pw.Widget _buildMacrosInfo(TargetMacros macros) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 1, text: 'Macros Objetivo'),
          pw.Text('Calorías: ${macros.calories} kcal'),
          pw.Text(
              'Proteínas: ${macros.protein}g / Grasas: ${macros.fats}g / Carbohidratos: ${macros.carbs}g'),
        ]);
  }

  pw.Widget _buildMealPdfSection(String mealTitle, Meal meal) {
    final List<List<String>> tableData = [
      <String>['Componente', 'Opción de Alimento', 'Porción Sugerida'],
    ];

    for (var category in meal.components) {
      for (var option in category.options) {
        tableData.add([category.title, option.name, option.portion]);
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(level: 2, text: mealTitle),
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(5),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          data: tableData,
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
          },
        ),
        if (meal.suggestedRecipes.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text('Recetas Sugeridas:',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 5),
          ...meal.suggestedRecipes.take(2).map((recipe) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                child: pw.Text(
                    '• ${recipe.title} (${recipe.readyInMinutes} min)',
                    style:
                        pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              )),
        ],
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildRecommendationsSection(String title, List<String> items) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 1, text: title),
          ...items.map((item) => pw.Bullet(text: item)),
          pw.SizedBox(height: 20),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Mi Plan de Hoy',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildUserInfoHeader() {
    final plan = _mealPlanData!.nutritionPlan;
    if (plan.anthropometricSummary == null) return const SizedBox.shrink();

    final anthro = plan.anthropometricSummary!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FrutiaColors.accent.withOpacity(0.1),
            FrutiaColors.accent2.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FrutiaColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FrutiaColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: FrutiaColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hola, ${anthro.clientName}! 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    Text(
                      "${anthro.age} años • BMI: ${anthro.bmi.toStringAsFixed(1)} • ${anthro.weightStatus}",
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    if (_mealPlanData == null) {
      return const Center(
          child: Text("No se encontró un plan de alimentación."));
    }

    final plan = _mealPlanData!.nutritionPlan;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricsDashboard(
            calories: _totalCalories,
            targetCalories: plan.targetMacros.calories,
            protein: _totalProtein,
            targetProtein: plan.targetMacros.protein,
            carbs: _totalCarbs,
            targetCarbs: plan.targetMacros.carbs,
            fats: _totalFats,
            targetFats: plan.targetMacros.fats,
            onDownloadPDF: _generateAndDownloadPDF,
            isPremium: _isUserPremium,
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 24),
          ...plan.meals.entries.map((entry) {
            final mealTitle = entry.key;
            final meal = entry.value;
            final icon = _getIconForMeal(mealTitle);
            final delay =
                (plan.meals.keys.toList().indexOf(mealTitle) * 200).ms;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _MealCard(
                title: mealTitle,
                icon: icon,
                categories: meal.components,
                suggestedRecipes: meal.suggestedRecipes,
                selections: _dailySelections[mealTitle]!,
                onOptionSelected: (category, option) =>
                    _updateSelection(mealTitle, category, option),
                isRegistering: _registeringMeals.contains(mealTitle),
                isCompleted: _completedMeals.contains(mealTitle),
                onRegister: () {
                  final selectionsForMeal =
                      _dailySelections[mealTitle]!.values.toList();
                  _registerMeal(mealTitle, selectionsForMeal);
                },
              ).animate().fadeIn(duration: 500.ms, delay: delay),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getIconForMeal(String mealTitle) {
    switch (mealTitle.toLowerCase()) {
      case 'almuerzo':
        return Icons.restaurant_outlined;
      case 'cena':
        return Icons.dinner_dining_outlined;
      case 'shake':
        return Icons.blender_outlined;
      case 'desayuno':
        return Icons.free_breakfast_outlined;
      default:
        return Icons.lunch_dining_outlined;
    }
  }
}

class _MetricsDashboard extends StatelessWidget {
  final int calories,
      targetCalories,
      protein,
      targetProtein,
      carbs,
      targetCarbs,
      fats,
      targetFats;
  final VoidCallback onDownloadPDF;
  final bool isPremium;

  const _MetricsDashboard({
    required this.calories,
    required this.targetCalories,
    required this.protein,
    required this.targetProtein,
    required this.carbs,
    required this.targetCarbs,
    required this.fats,
    required this.targetFats,
    required this.onDownloadPDF,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: FrutiaColors.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Resumen de tu Día",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FrutiaColors.primaryText),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 30.0,
              runSpacing: 20.0,
              children: [
                _MacroStatCard(
                  label: 'Proteínas',
                  value: protein,
                  target: targetProtein,
                  color: Colors.blue,
                  icon: Icons.egg_alt_outlined,
                ),
                _MacroStatCard(
                  label: 'Carbs',
                  value: carbs,
                  target: targetCarbs,
                  color: Colors.orange,
                  icon: Icons.local_fire_department_outlined,
                ),
                _MacroStatCard(
                  label: 'Grasas',
                  value: fats,
                  target: targetFats,
                  color: Colors.purple,
                  icon: Icons.water_drop_outlined,
                ),
              ],
            ),
            const SizedBox(height: 55),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()));
              },
              icon: const Icon(Icons.history, color: FrutiaColors.accent),
              label: Text(
                'Ver Historial',
                style: GoogleFonts.poppins(
                    color: FrutiaColors.accent, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FrutiaColors.accent,
                side: const BorderSide(color: FrutiaColors.accent, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (isPremium) {
                  onDownloadPDF();
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => const PremiumFeatureDialog());
                }
              },
              icon: Icon(isPremium ? Icons.download : Icons.lock,
                  color: Colors.white),
              label: Text(
                'Descargar PDF',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? FrutiaColors.accent : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroStatCard extends StatelessWidget {
  final String label;
  final int value, target;
  final Color color;
  final IconData icon;

  const _MacroStatCard({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    double progress = target > 0 ? value / target : 0;
    return Column(
      children: [
        CircleAvatar(
            radius: 40,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 32)),
        const SizedBox(height: 8),
        Text(
          '${value}g / ${target}g',
          style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText),
        ),
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 12, color: FrutiaColors.secondaryText)),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: FrutiaColors.secondaryText.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}

class _MealCategorySection extends StatelessWidget {
  final MealCategory category;
  final MealOption? groupValue;
  final ValueChanged<MealOption> onChanged;

  const _MealCategorySection({
    required this.category,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: FrutiaColors.primaryText),
          ),
          const SizedBox(height: 12),
          ...category.options.map((option) => _MealOptionTile(
                option: option,
                isSelected: groupValue == option,
                onTap: () => onChanged(option),
              )),
        ],
      ),
    );
  }
}

class _MealOptionTile extends StatelessWidget {
  final MealOption option;
  final bool isSelected;
  final VoidCallback onTap;
    final String? userBudget; // NUEVO


  const _MealOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
        this.userBudget,

  });

  @override
  Widget build(BuildContext context) {

      bool budgetMismatch = false;
    if (userBudget != null) {
      bool isLowBudget = userBudget!.contains('bajo');
      budgetMismatch = (isLowBudget && option.isHighBudget) || 
                      (!isLowBudget && option.isLowBudget);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      FrutiaColors.accent.withOpacity(0.1),
                      FrutiaColors.accent2.withOpacity(0.1)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? FrutiaColors.accent
                  : FrutiaColors.secondaryText.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [

                if (option.isHighBudget)
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, size: 16, color: Colors.amber),
                ),
              

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: option.name,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: FrutiaColors.primaryText),
                        children: [
                          TextSpan(
                            text: ' ${option.portion}',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: FrutiaColors.primaryText.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatPill(
                            label: '~${option.calories} kcal',
                            color: Colors.orange.shade700),
                        _StatPill(
                            label: '${option.protein}g Proteina',
                            color: Colors.blue.shade700),
                        _StatPill(
                            label: '${option.carbs}g Carbohidrato',
                            color: Colors.green.shade700),
                        _StatPill(
                            label: '${option.fats}g Grasas',
                            color: Colors.purple.shade700),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? FrutiaColors.accent
                    : FrutiaColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: GoogleFonts.lato(
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.bold,
            fontSize: 12),
      ),
    );
  }
}

class _FreeSaladInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              FrutiaColors.accent.withOpacity(0.1),
              FrutiaColors.accent2.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.eco_rounded, color: FrutiaColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Acompañar con Ensalada LIBRE',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600, color: FrutiaColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<MealCategory> categories;
  final List<InspirationRecipe> suggestedRecipes;
  final Map<String, MealOption> selections;
  final Function(String, MealOption) onOptionSelected;
  final bool isRegistering;
  final bool isCompleted;
    final List<String>? validationWarnings; // NUEVO

  final VoidCallback onRegister;

  const _MealCard({
    required this.title,
    required this.icon,
    required this.categories,
    required this.suggestedRecipes,
    required this.selections,
    required this.onOptionSelected,
    required this.isRegistering,
    required this.isCompleted,
        this.validationWarnings,

    required this.onRegister,
  });

  int get _totalCalories =>
      selections.values.fold(0, (sum, item) => sum + item.calories);
  bool get _isSelectionComplete => selections.length == categories.length;

  @override
  Widget build(BuildContext context) {
    final cardColor = isCompleted
        ? Colors.green.withOpacity(0.05)
        : FrutiaColors.secondaryBackground;
    final borderColor = isCompleted
        ? Colors.green.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),

         border: validationWarnings != null && validationWarnings!.isNotEmpty
            ? Border.all(color: Colors.orange, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: borderColor,
            blurRadius: 8,
            offset: const Offset(0, 4)
          )
        ],
      ),

      
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: FrutiaColors.accent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     
                     if (validationWarnings != null && validationWarnings!.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, 
                        color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sugerencias',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...validationWarnings!.map((warning) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      warning,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProgressColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selections.length}/${categories.length}',
                    style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor()),
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted) ...[
            const Divider(indent: 16, endIndent: 16, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selecciona UNA opción de cada grupo para completar tu $title',
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...categories.map((category) => _MealCategorySection(
                  category: category,
                  groupValue: selections[category.title],
                  onChanged: (option) =>
                      onOptionSelected(category.title, option),
                )),
            if (title != 'Shake') _FreeSaladInfo(),
            if (suggestedRecipes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.restaurant_menu,
                            color: FrutiaColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Ideas de Recetas para $title",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: FrutiaColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Usa los ingredientes de arriba para crear estas deliciosas recetas",
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          color: FrutiaColors.secondaryText,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    ...suggestedRecipes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final recipe = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _RecipeCard(recipe: recipe, index: index + 1),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle,
                        color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$title Completado ✨',
                        style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        'Regresa mañana para un nuevo día',
                        style: GoogleFonts.lato(
                            color: Colors.green.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else if (_isSelectionComplete)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: isRegistering ? null : onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrutiaColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: isRegistering
                    ? Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle,
                        color: Colors.white, size: 22),
                label: Text(
                  isRegistering
                      ? 'Registrando $title...'
                      : '¡Confirmar $title! ($_totalCalories kcal)',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (selections.length == 0) return Colors.grey;
    if (selections.length < categories.length) return Colors.orange;
    return Colors.green;
  }
}

class _RecipeCard extends StatelessWidget {
  final InspirationRecipe recipe;
  final int index;

  const _RecipeCard({required this.recipe, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FrutiaColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: FrutiaColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: FrutiaColors.primaryText,
                  ),
                ),
                Text(
                  '${recipe.readyInMinutes} min',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: FrutiaColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
