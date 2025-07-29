import 'dart:convert';

import 'package:Frutia/pages/Pantalla2.dart';
import 'package:Frutia/pages/screens/historyScreen.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:Frutia/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:pdf/pdf.dart';
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

  final Set<String> _registeringMeals = {};
  final Set<String> _completedMeals = {};

  @override
  void initState() {
    super.initState();
    _fetchPlanAndInitialState();
    _fetchUserName();
  }

  Future<void> _registerMeal(
      String mealTitle, List<MealOption> selections) async {
    setState(() {
      _registeringMeals.add(mealTitle);
    });

    try {
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
      print("Selecciones locales cargadas!");
    }
  }

  void _updateSelection(
      String mealTitle, String categoryTitle, MealOption option) {
    if (_completedMeals.contains(mealTitle)) return;

    setState(() {
      _dailySelections[mealTitle]![categoryTitle] = option;
      _calculateTotals();
      _saveSelections();
    });
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

      // Cargar la imagen del logo
      final ByteData imageData =
          await rootBundle.load('assets/images/fondoAppFrutia.webp');
      final Uint8List imageBytes = imageData.buffer.asUint8List();

      // Nuevas recomendaciones y recordatorios
      final List<String> additionalRecommendations = [
        'PROTEÍNAS se pesan CRUDAS, si la pesa cocida QUITAR 20g al gramaje indicado',
        'CARBOHIDRATOS se pesan COCIDOS, excepto la avena que se pesa CRUDA',
        'Consumir una adecuada cantidad de agua al día (3.2 litros) – Cuantifícala',
        'Utiliza una balanza electrónica para pesar las comidas',
        'Utiliza cucharas medidoras para mayor exactitud',
        'Utiliza Pam (aceite en spray) o sino utiliza el aceite de oliva extra virgen',
        'Los vegetales son LIBRES, dales variedad a tus comidas (Recuerda que aportan fibra)',
      ];

      final List<String> additionalReminders = [
        'Pon horarios de comida y respétalos',
        'Busca recetas e inventa platos nuevos para no aburrirte',
        'Prepara salsas en base a vegetales (Ají, rocoto, albahaca, tomate, pimientos, champiñones, etc.)',
        'Organiza tus comidas en adelantado si vas a tener un día atípico (Piensa en adelantado)',
      ];

      // Combinar las recomendaciones y recordatorios existentes con los nuevos
      final allGeneralRecommendations = [
        ...plan.generalRecommendations,
        ...additionalRecommendations,
      ];
      final allRememberRecommendations = [
        ...plan.rememberRecommendations,
        ...additionalReminders,
      ];

      // Cargar las fuentes desde los assets
      final font =
          pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
      final boldFont =
          pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));

      final pw.ThemeData theme =
          pw.ThemeData.withFont(base: font, bold: boldFont);

      // PÁGINA 1: PLAN DE COMIDAS
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) =>
              _buildPdfHeader(profile['name'] ?? 'Usuario', imageBytes),
          build: (pw.Context context) => [
            _buildProfileInfo(profile),
            pw.SizedBox(height: 20),
            _buildMacrosInfo(plan.targetMacros),
            pw.SizedBox(height: 20),
            ...plan.meals.entries.map((mealEntry) {
              return _buildMealPdfSection(mealEntry.key, mealEntry.value);
            }),
          ],
        ),
      );

      // PÁGINA 2: RECOMENDACIONES
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
          // Imagen del logo

          pw.Text('Frutia',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 24,
                  color: PdfColors.red)),
          pw.Image(
            pw.MemoryImage(imageBytes),
            height: 60,
          ),

          pw.Text('Plan de Alimentación Personalizado para $_userName',
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

  // En el archivo ProfessionalMiPlanDiarioScreen.dart

  pw.Widget _buildMealPdfSection(String mealTitle, Meal meal) {
    // ▼▼▼ INICIO DE LA CORRECCIÓN ▼▼▼

    // 1. Creamos la cabecera de nuestra nueva tabla de 3 columnas
    final List<List<String>> tableData = [
      <String>['Componente', 'Opción de Alimento', 'Porción Sugerida'],
    ];

    // 2. Recorremos cada categoría y cada opción para crear una fila para cada alimento
    for (var category in meal.components) {
      for (var option in category.options) {
        tableData.add([
          category
              .title, // Columna 1: El título del componente (ej: "Proteínas")
          option
              .name, // Columna 2: El nombre del alimento (ej: "Tortilla de Claras")
          option.portion, // Columna 3: La porción (ej: "4 claras")
        ]);
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

          // 3. Usamos los nuevos datos y ajustamos el ancho de las columnas
          data: tableData,
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
          },
        ),

        // La sección de recetas sugeridas se queda igual, ya estaba bien
        if (meal.suggestedRecipes.isNotEmpty)
          pw.Padding(
              padding: const pw.EdgeInsets.only(top: 15, bottom: 5),
              child: pw.Text('Recetas de Inspiración:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
        ...meal.suggestedRecipes.map((recipe) {
          return pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, bottom: 8),
              child: pw.Bullet(text: recipe.title));
        }),
        pw.SizedBox(height: 20),
      ],
    );
    // ▲▲▲ FIN DE LA CORRECCIÓN ▲▲▲
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
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: _buildBody(),
    );
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
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
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
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 24),

          // ▼▼▼ INICIO DE LA CORRECCIÓN PRINCIPAL ▼▼▼
          // Dentro de tu método _buildBody en ProfessionalMiPlanDiarioScreen

          ...plan.meals.entries.map((entry) {
            final mealTitle = entry.key;
            final meal = entry.value; // 'meal' es ahora un objeto Meal
            final icon = _getIconForMeal(mealTitle);
            final delay =
                (plan.meals.keys.toList().indexOf(mealTitle) * 200).ms;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _MealCard(
                title: mealTitle,
                icon: icon,
                categories: meal.components, // Pasamos los componentes
                suggestedRecipes: meal
                    .suggestedRecipes, // <-- ASÍ QUEDA LA LLAMADA CORRECTA (en plural)
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Resumen de tu Día",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.primaryText,
              ),
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
                      builder: (context) => const HistoryScreen()),
                );
              },
              icon: const Icon(Icons.history, color: FrutiaColors.accent),
              label: Text(
                'Ver Historial',
                style: GoogleFonts.poppins(
                  color: FrutiaColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FrutiaColors.accent,
                side: const BorderSide(color: FrutiaColors.accent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onDownloadPDF,
              icon: const Icon(Icons.download, color: Colors.white),
              label: Text(
                'Descargar PDF',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: FrutiaColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          '${value}g / ${target}g',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: FrutiaColors.primaryText,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: FrutiaColors.secondaryText,
          ),
        ),
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

class _MealCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<MealCategory> categories;
  // CAMBIO: Ahora recibe una LISTA de recetas
  final List<InspirationRecipe> suggestedRecipes;
  final Map<String, MealOption> selections;
  final Function(String, MealOption) onOptionSelected;
  final bool isRegistering;
  final bool isCompleted;
  final VoidCallback onRegister;

  const _MealCard({
    required this.title,
    required this.icon,
    required this.categories,
    required this.suggestedRecipes, // Constructor actualizado
    required this.selections,
    required this.onOptionSelected,
    required this.isRegistering,
    required this.isCompleted,
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
        boxShadow: [
          BoxShadow(
            color: borderColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: FrutiaColors.accent, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: FrutiaColors.primaryText,
                  ),
                ),
                const Spacer(),
                Text(
                  '~$_totalCalories kcal',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: FrutiaColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          if (!isCompleted)
            ...categories.map((category) => _MealCategorySection(
                  category: category,
                  groupValue: selections[category.title],
                  onChanged: (option) =>
                      onOptionSelected(category.title, option),
                )),
          if (suggestedRecipes.isNotEmpty && !isCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recetas Sugeridas",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Creamos un botón por cada receta en la lista
                  ...suggestedRecipes
                      .map((recipe) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.menu_book_outlined,
                                  size: 18),
                              label: Text(recipe.title,
                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: FrutiaColors.accent,
                                  side: const BorderSide(
                                      color: FrutiaColors.accent),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size(double.infinity, 45)),
                              onPressed: () {
                                // Navega a la pantalla de detalle que ya tienes
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          if (title != 'Shake' && !isCompleted) _FreeSaladInfo(),
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '$title Registrado, \nregresa mañana.',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: isRegistering
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  isRegistering ? 'Registrando...' : 'Registrar $title',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
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
              color: FrutiaColors.primaryText,
            ),
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

  const _MealOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                      FrutiaColors.accent2.withOpacity(0.1),
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
              // IMAGE COMMENTED OUT: Network image for meal option
              /*
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  option.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Center(
                          child: Icon(Icons.image, color: Colors.grey)),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              */
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // ▼▼▼ CAMBIO AQUÍ ▼▼▼
                      // Unimos el nombre con la porción para que se vea claro
                      '${option.name} (${option.portion})',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Proteina: ${option.protein}g   Carbohidrato: ${option.carbs}g   Grasas: ${option.fats}g',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: FrutiaColors.secondaryText,
                      ),
                    ),
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
              FrutiaColors.accent2.withOpacity(0.1),
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
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
