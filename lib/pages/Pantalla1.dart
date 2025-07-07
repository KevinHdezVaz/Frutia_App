import 'dart:convert';

import 'package:Frutia/pages/screens/historyScreen.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:Frutia/utils/colors.dart'; // Asegúrate que esta ruta sea correcta
import 'package:Frutia/services/plan_service.dart'; // Asegúrate que esta ruta sea correcta
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Pantalla Principal (StatefulWidget) ---
class ProfessionalMiPlanDiarioScreen extends StatefulWidget {
  const ProfessionalMiPlanDiarioScreen({Key? key}) : super(key: key);

  @override
  _ProfessionalMiPlanDiarioScreenState createState() =>
      _ProfessionalMiPlanDiarioScreenState();
}

class _ProfessionalMiPlanDiarioScreenState
    extends State<ProfessionalMiPlanDiarioScreen> {
  // --- ESTADO Y SERVICIOS ---
  final PlanService _planService = PlanService();
  MealPlanData? _mealPlanData; // Contendrá todo el plan venido de la API
  bool _isLoading = true;
  String? _errorMessage;

  // Mapa para guardar las selecciones del usuario dinámicamente
  final Map<String, Map<String, MealOption>> _dailySelections = {};

  // Totales de macros calculados basados en la selección
  int _totalCalories = 0;
  int _totalProtein = 0;
  int _totalCarbs = 0;
  int _totalFats = 0;

  final Set<String> _registeringMeals = {};
  // Para saber qué comidas ya se completaron y cambiar su UI
  final Set<String> _completedMeals = {};

  @override
  void initState() {
    super.initState();
    _fetchPlanAndInitialState(); // Usaremos una nueva función de arranque
  }

  Future<void> _registerMeal(
      String mealTitle, List<MealOption> selections) async {
    // 1. Marcar la comida como "registrando" para mostrar un spinner
    setState(() {
      _registeringMeals.add(mealTitle);
    });

    try {
      // 2. Llamar al servicio que creamos para guardar en la BD
      await _planService.logMeal(
        date: DateTime.now(), // Usa la fecha actual
        mealType: mealTitle,
        selections: selections,
      );

      // 3. Si todo va bien, marca la comida como completada
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
      // 4. Quitar la comida del estado "registrando" sin importar el resultado
      setState(() {
        _registeringMeals.remove(mealTitle);
      });
    }
  }

  // ▼▼▼ FUNCIÓN PRINCIPAL DE CARGA (MODIFICADA) ▼▼▼
  Future<void> _fetchPlanAndInitialState() async {
    // Ponemos la pantalla en estado de carga
    if (mounted) setState(() => _isLoading = true);

    try {
      // 1. Obtenemos el plan y el historial al mismo tiempo
      final results = await Future.wait([
        _planService.getCurrentPlan(),
        _planService.getHistory(), // Obtenemos los registros de la BD
      ]);

      final plan = results[0] as MealPlanData?;
      final history = results[1] as List<MealLog>;

      if (plan == null) {
        if (mounted)
          setState(() {
            _errorMessage = "No tienes un plan activo.";
            _isLoading = false;
          });
        return;
      }

      // 2. Inicializamos las selecciones
      plan.nutritionPlan.meals.keys.forEach((mealTitle) {
        _dailySelections[mealTitle] = {};
      });

      // 3. Cargamos las selecciones guardadas en el dispositivo
      await _loadSelectionsFromLocal();

      // 4. Verificamos el historial para saber qué comidas ya se completaron HOY
      final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final completedToday = history
          .where((log) => log.date == todayString)
          .map((log) => log.mealType);

      _completedMeals.addAll(completedToday);

      // 5. Actualizamos el estado final de la UI
      if (mounted) {
        setState(() {
          _mealPlanData = plan;
          _isLoading = false;
          _calculateTotals(); // Calculamos macros con los datos cargados
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
    // No permitimos cambiar la selección si la comida ya fue completada
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
    // Convertimos el mapa de selecciones a un formato que se pueda guardar (JSON)
    final encodedData = json.encode(_dailySelections.map((meal, selections) =>
        MapEntry(
            meal,
            selections.map((cat, opt) => MapEntry(cat,
                opt.toJson())) // Necesitarás un método toJson() en MealOption
            )));
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

  // --- GENERACIÓN DE PDF (AHORA DINÁMICO) ---
  Future<void> _generateAndDownloadPDF() async {
    if (_mealPlanData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No hay datos del plan para generar el PDF.')),
      );
      return;
    }

    final plan = _mealPlanData!.nutritionPlan;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: FrutiaColors.accent),
        ),
      );

      final pdf = pw.Document();
      final logo = pw.MemoryImage(
        (await rootBundle.load('assets/images/fondoAppFrutia.webp'))
            .buffer
            .asUint8List(),
      );

      // --- PÁGINA 1: PLAN DE COMIDAS ---
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            // Encabezado
            pw.Row(children: [
              pw.SizedBox(height: 50, child: pw.Image(logo)),
              pw.SizedBox(width: 20),
              pw.Text('Tu Plan de Alimentación by Frutia',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ]),
            pw.SizedBox(height: 20),

            // Macros Objetivo
            pw.Text('Macros Objetivo:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Calorías: ${plan.targetMacros.calories} kcal'),
            pw.Text(
                'Proteínas: ${plan.targetMacros.protein}g / Grasas: ${plan.targetMacros.fats}g / Carbohidratos: ${plan.targetMacros.carbs}g'),
            pw.SizedBox(height: 20),

            // Comidas Seleccionadas (o las opciones si no se seleccionó)
            ..._dailySelections.entries.map((mealEntry) {
              final mealTitle = mealEntry.key;
              final selections = mealEntry.value;
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Header(level: 1, text: mealTitle),
                    pw.SizedBox(height: 5),
                    if (selections.isNotEmpty)
                      ...selections.values
                          .map((option) => pw.Text('- ${option.name}'))
                    else
                      // Muestra opciones generales si no hay selección
                      ...plan.meals[mealTitle]!.map((category) {
                        final optionsText =
                            category.options.map((o) => o.name).join(' o ');
                        return pw.Text('- ${category.title}: $optionsText');
                      }),
                    pw.SizedBox(height: 15),
                  ]);
            }),
          ],
        ),
      );

      // --- PÁGINA 2: RECOMENDACIONES ---
      pdf.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
                pw.Header(level: 0, text: 'Recomendaciones Generales'),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: plan.generalRecommendations
                      .map((rec) => pw.Bullet(text: rec))
                      .toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Header(level: 0, text: 'Recuerda'),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: plan.rememberRecommendations
                      .map((rec) => pw.Bullet(text: rec))
                      .toList(),
                ),
              ]));

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/Plan_Frutia_${DateTime.now().toIso8601String()}.pdf');
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

  // --- CONSTRUCCIÓN DE LA UI ---
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

    // Dentro del método _buildBody() de _ProfessionalMiPlanDiarioScreenState

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // El Dashboard de Métricas no cambia
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

          // Generación Dinámica de Tarjetas de Comida
          ...plan.meals.entries.map((entry) {
            final mealTitle = entry.key;
            final mealCategories = entry.value;
            final icon = _getIconForMeal(mealTitle);
            final delay =
                (plan.meals.keys.toList().indexOf(mealTitle) * 200).ms;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _MealCard(
                title: mealTitle,
                icon: icon,
                categories: mealCategories,
                selections: _dailySelections[mealTitle]!,
                onOptionSelected: (category, option) =>
                    _updateSelection(mealTitle, category, option),

                // ▼▼▼ INICIO DE LA MODIFICACIÓN ▼▼▼
                isRegistering: _registeringMeals.contains(mealTitle),
                isCompleted: _completedMeals.contains(mealTitle),
                onRegister: () {
                  // Extraemos las selecciones para esta comida específica
                  final selectionsForMeal =
                      _dailySelections[mealTitle]!.values.toList();
                  // Llamamos a la función principal para iniciar el registro
                  _registerMeal(mealTitle, selectionsForMeal);
                },
                // ▲▲▲ FIN DE LA MODIFICACIÓN ▲▲▲
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

// =========================================================================
// --- WIDGETS COMPONENTES (SIN CAMBIOS, YA ERAN DINÁMICOS) ---
// =========================================================================

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
                // Navegación a la pantalla de Historial
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
                // Estilo de botón "secundario" o "contorneado"
                backgroundColor: Colors.white,
                foregroundColor: FrutiaColors.accent,
                side: const BorderSide(color: FrutiaColors.accent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize:
                    const Size(double.infinity, 50), // Tamaño aumentado
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
  final Map<String, MealOption> selections;
  final Function(String, MealOption) onOptionSelected;
  final bool isRegistering;
  final bool isCompleted;
  final VoidCallback onRegister;

  const _MealCard({
    required this.title,
    required this.icon,
    required this.categories,
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
          // Las opciones de comida solo se muestran si la comida no está completada
          if (!isCompleted)
            ...categories.map((category) => _MealCategorySection(
                  category: category,
                  groupValue: selections[category.title],
                  onChanged: (option) =>
                      onOptionSelected(category.title, option),
                )),

          if (title != 'Shake' && !isCompleted) _FreeSaladInfo(),

          // Lógica condicional para el botón y el mensaje de completado
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
            // color: isSelected ? null : FrutiaColors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? FrutiaColors.accent
                  : FrutiaColors.secondaryText.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  option.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  // Widget de carga y error para la imagen
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
              Expanded(
                child: Text(
                  option.name,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                    color: FrutiaColors.primaryText,
                  ),
                ),
              ),
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
