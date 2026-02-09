import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/l10n/food_translations.dart';
import 'package:Frutia/pages/screens/datosPersonales/SuccessScreen.dart';
import 'package:Frutia/pages/screens/miplan/plan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Frutia/services/plan_service.dart';
import 'package:Frutia/utils/colors.dart';

class PlanSummaryScreen extends StatefulWidget {
  final String userName; // ⭐ RECIBE EL NOMBRE REAL

  const PlanSummaryScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<PlanSummaryScreen> createState() => _PlanSummaryScreenState();
}

class _PlanSummaryScreenState extends State<PlanSummaryScreen> {
  final PlanService _planService = PlanService();
  late Future<MealPlanData?> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture = _planService.getCurrentPlan();
  }

  String translateMeal(String key, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    // Normalizamos la clave (quitamos mayúsculas y espacios extra)
    final normalizedKey = key.toLowerCase().trim();

    // Mapeo completo español → inglés / español (según locale)
    final Map<String, String> translations = {
      // Español (backend) → traducción según idioma
      'desayuno': locale == 'es' ? l10n.breakfast ?? 'Desayuno' : 'Breakfast',
      'almuerzo': locale == 'es' ? l10n.lunch ?? 'Almuerzo' : 'Lunch',
      'cena': locale == 'es' ? l10n.dinner ?? 'Cena' : 'Dinner',
      'snack am': locale == 'es' ? l10n.snackAM ?? 'Snack AM' : 'Morning Snack',
      'snack_am': locale == 'es' ? l10n.snackAM ?? 'Snack AM' : 'Morning Snack',
      'snack pm':
          locale == 'es' ? l10n.snackPM ?? 'Snack PM' : 'Afternoon Snack',
      'snack_pm':
          locale == 'es' ? l10n.snackPM ?? 'Snack PM' : 'Afternoon Snack',
      'snack de frutas': locale == 'es'
          ? l10n.mealSnackFruit ?? 'Snack de frutas'
          : 'Fruit Snack',
      'shake': locale == 'es' ? l10n.mealShake ?? 'Shake' : 'Shake',
    };

    // Buscamos coincidencia exacta o parcial
    String? translated = translations[normalizedKey];

    // Si no coincide exactamente, intentamos coincidencia parcial
    if (translated == null) {
      if (normalizedKey.contains('desayuno') ||
          normalizedKey.contains('breakfast')) {
        translated =
            locale == 'es' ? l10n.breakfast ?? 'Desayuno' : 'Breakfast';
      } else if (normalizedKey.contains('almuerzo') ||
          normalizedKey.contains('lunch')) {
        translated = locale == 'es' ? l10n.lunch ?? 'Almuerzo' : 'Lunch';
      } else if (normalizedKey.contains('cena') ||
          normalizedKey.contains('dinner')) {
        translated = locale == 'es' ? l10n.dinner ?? 'Cena' : 'Dinner';
      } else if (normalizedKey.contains('snack am') ||
          normalizedKey.contains('morning')) {
        translated =
            locale == 'es' ? l10n.snackAM ?? 'Snack AM' : 'Morning Snack';
      } else if (normalizedKey.contains('snack pm') ||
          normalizedKey.contains('afternoon')) {
        translated =
            locale == 'es' ? l10n.snackPM ?? 'Snack PM' : 'Afternoon Snack';
      } else {
        // Capitalizamos la clave original como fallback
        translated = key[0].toUpperCase() + key.substring(1).toLowerCase();
      }
    }

    return translated;
  }

// 1. Traducción de categorías (Proteínas → Proteins, etc.)
  String translateCategory(String backendCategory, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    // Siempre intentamos traducir si no es español
    if (locale != 'es') {
      switch (backendCategory.trim()) {
        case 'Proteínas':
          return l10n.proteins ?? 'Proteins';
        case 'Carbohidratos':
          return l10n.carbs ?? l10n.carbohydrates ?? 'Carbohydrates';
        case 'Grasas':
          return l10n.fats ?? 'Fats';
        case 'Vegetales':
          return l10n.vegetables ?? 'Vegetables';
        case 'Frutas':
          return l10n.fruits ?? 'Fruits';
        default:
          return backendCategory; // fallback
      }
    }

    // En español devolvemos exactamente lo que manda el backend
    return backendCategory;
  }

  String translateVegetable(String englishName, AppLocalizations l10n) {
    final map = {
      'Complete mixed salad': l10n.completeMixedSalad,
      'Steamed vegetables bowl': l10n.steamedVegetablesBowl,
      'Mediterranean salad': l10n.mediterraneanSalad,
      'Sautéed vegetables': l10n.sauteedVegetables,
      'Large mixed green salad': l10n.largeMixedGreenSalad,
      'Cruciferous vegetables salad': l10n.cruciferousVegetablesSalad,
      'Low-carb vegetables mix': l10n.lowCarbVegetablesMix,
    };
    return map[englishName] ?? englishName;
  }

  // ⭐ TRADUCE LA CLAVE Y REEMPLAZA :name POR EL NOMBRE REAL
  String getTranslatedPersonalizedMessage(String? key, AppLocalizations l10n) {
    if (key == null || key.isEmpty) return '';
    String message;
    switch (key) {
      case 'personalized_message_am':
        message = l10n.personalizedMessageAM;
        break;
      case 'personalized_message_pm':
        message = l10n.personalizedMessagePM;
        break;
      case 'personalized_message_default':
      default:
        message = l10n.personalizedMessageDefault;
    }
    return message.replaceAll(':name', widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<MealPlanData?>(
        future: _planFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: FrutiaColors.accent));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: FrutiaColors.accent, size: 48),
                    const SizedBox(height: 16),
                    Text(snapshot.error.toString(),
                        style: GoogleFonts.lato(
                            fontSize: 18, color: FrutiaColors.primaryText)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FrutiaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.backButton,
                          style: GoogleFonts.lato(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final planData = snapshot.data!;
            final nutritionPlan = planData.nutritionPlan;

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, nutritionPlan),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⭐ MENSAJE PERSONALIZADO TRADUCIDO + NOMBRE
                        _buildPersonalizedMessageCard(context, planData),
                        const SizedBox(height: 20),
                        if (nutritionPlan.anthropometricSummary != null)
                          _buildAnthropometricCard(
                              context, nutritionPlan.anthropometricSummary!),
                        const SizedBox(height: 20),
                        _buildSummarySection(
                            context, nutritionPlan.targetMacros),
                        const SizedBox(height: 30),
                        _buildMealOptionsWithExchanges(
                            context, nutritionPlan.meals, l10n, locale),
                        const SizedBox(height: 30),
                        _buildRecipesSection(context, nutritionPlan.meals),
                        const SizedBox(height: 20),
                        if (nutritionPlan.personalizedTips != null)
                          _buildPersonalizedTips(
                              context, nutritionPlan.personalizedTips!),
                        const SizedBox(height: 20),
                        _buildRecommendationsSection(
                            context, nutritionPlan.generalRecommendations),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const SuccessScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FrutiaColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 8,
                              shadowColor:
                                  FrutiaColors.primary.withOpacity(0.5),
                              minimumSize: const Size.fromHeight(60),
                            ),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 24, color: Colors.white),
                            label: Text(
                              l10n.readyToStartButton,
                              style: GoogleFonts.lato(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 800.ms)
                              .scale(duration: 500.ms),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, NutritionPlan nutritionPlan) {
    final l10n = AppLocalizations.of(context)!;

    // ⭐ USA EL NOMBRE PASADO COMO PRIORIDAD
    String clientName = nutritionPlan.anthropometricSummary?.clientName ??
        widget.userName ??
        l10n.user;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 170.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FrutiaColors.accent.withOpacity(0.9),
                    FrutiaColors.accent2,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/frutaProgreso4.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nutritionPlan.anthropometricSummary?.clientName ??
                            widget.userName ??
                            l10n.user,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        stretchModes: const [StretchMode.zoomBackground],
      ),
    );
  }

  String translatePortion(String portion, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    // En español: devolvemos exactamente lo que llega (sin cambios)
    if (locale == 'es') {
      return portion.trim();
    }

    // En inglés: traducimos todo lo posible
    String translated = portion.trim();

    // 1. Reemplazos de frases comunes de peso/estado
    translated = translated
        .replaceAll('peso en crudo', 'raw weight')
        .replaceAll('(peso en crudo)', '(raw weight)')
        .replaceAll('peso crudo', 'raw weight')
        .replaceAll('(peso crudo)', '(raw weight)')
        .replaceAll('peso en seco', 'dry weight')
        .replaceAll('(peso en seco)', '(dry weight)')
        .replaceAll('peso seco', 'dry weight')
        .replaceAll('(peso seco)', '(dry weight)')
        .replaceAll('peso cocido', 'cooked weight')
        .replaceAll('(peso cocido)', '(cooked weight)')
        .replaceAll('escurrido', 'drained')
        .replaceAll('y escurrido', 'drained')
        .replaceAll('escurridas', 'drained');

    // 2. Unidades comunes → plural/singular en inglés
    translated = translated
        .replaceAllMapped(RegExp(r'(\d+)\s*rebanada(s)?'), (match) {
          final num = match.group(1);
          return '$num slice${int.parse(num!) > 1 ? 's' : ''}';
        })
        .replaceAllMapped(RegExp(r'(\d+)\s*unidad(es)?'), (match) {
          final num = match.group(1);
          return '$num unit${int.parse(num!) > 1 ? 's' : ''}';
        })
        .replaceAllMapped(
          RegExp(r'(\d+)\s*tortilla(s)?\b', caseSensitive: false),
          (match) {
            final count = int.tryParse(match.group(1) ?? '0') ?? 0;
            final plural = count != 1 ? 's' : '';
            return '$count tortillas$plural';
          },
        )
        .replaceAll('unidad', 'unit')
        .replaceAll('unidades', 'units')
        .replaceAll('pieza', 'piece')
        .replaceAll('piezas', 'pieces')
        .replaceAll('porción', 'serving')
        .replaceAll('porciones', 'servings')
        .replaceAll('taza', 'cup')
        .replaceAll('tazas', 'cups')
        .replaceAll('tazas grandes', 'large cups')
        .replaceAll('cucharada', 'tablespoon')
        .replaceAll('cucharadas', 'tablespoons')
        .replaceAll('cucharadita', 'teaspoon')
        .replaceAll('cucharaditas', 'teaspoons')
        .replaceAll('puñado', 'handful')
        .replaceAll('puñados', 'handfuls')
        .replaceAll('rama', 'stalk')
        .replaceAll('ramas', 'stalks')
        .replaceAll('hoja', 'leaf')
        .replaceAll('hojas', 'leaves')
        .replaceAll('diente', 'clove')
        .replaceAll('dientes', 'cloves');

    // 3. Casos especiales de combinaciones (claras + huevos, etc.)
    translated = translated
        .replaceAll('claras + huevo entero', 'egg whites + whole egg')
        .replaceAll('claras + huevos enteros', 'egg whites + whole eggs')
        .replaceAll('claras + huevo', 'egg whites + egg')
        .replaceAllMapped(RegExp(r'(\d+)\s*claras?\s*\+\s*(\d+)\s*huevo(s)?'),
            (match) {
      final whites = match.group(1);
      final whole = match.group(2);
      final plural = int.parse(whole!) > 1 ? 's' : '';
      return '$whites egg whites + $whole whole egg$plural';
    }).replaceAllMapped(RegExp(r'(\d+)\s*claras?\s*\+\s*(\d+)\s*entero(s)?'),
            (match) {
      final whites = match.group(1);
      final whole = match.group(2);
      final plural = int.parse(whole!) > 1 ? 's' : '';
      return '$whites egg whites + $whole whole egg$plural';
    });

    // 4. Capitalización inteligente (primera letra de cada palabra importante)
    translated = translated.split(' ').map((word) {
      if (word.isEmpty) return word;
      // No capitalizamos preposiciones cortas ni paréntesis si es posible
      if (['and', 'or', 'with', 'of', 'in', 'to']
          .contains(word.toLowerCase())) {
        return word.toLowerCase();
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    // 5. Limpieza final: quitar espacios dobles y ajustar paréntesis
    translated = translated.replaceAll(RegExp(r'\s+'), ' ').trim();

    return translated;
  }

  String getLocalizedFoodName(String backendName, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    // En español: devolvemos exactamente lo que manda el backend
    if (locale == 'es') {
      return backendName.trim();
    }

// En inglés: mapa explícito de español → inglés (más confiable que FoodTranslations si falla)
    const Map<String, String> esToEn = {
      // ─────────────────────────────────────────────────────────────
      // Proteínas
      // ─────────────────────────────────────────────────────────────
      'Huevo entero': 'Whole egg',
      'Huevos enteros': 'Whole eggs',
      'Claras + Huevo Entero': 'Egg whites + Whole egg',
      'Claras + Huevo entero': 'Egg whites + Whole egg',
      'Claras pasteurizadas': 'Pasteurized egg whites',
      'Pechuga de pollo': 'Chicken breast',
      'Pollo muslo': 'Chicken thigh',
      'Pollo muslo con piel': 'Chicken thigh with skin',
      'Carne molida': 'Ground beef',
      'Carne molida 80/20': 'Ground beef 80/20',
      'Carne de res magra': 'Lean beef',
      'Atún en lata': 'Canned tuna',
      'Atún fresco': 'Fresh tuna',
      'Salmón fresco': 'Fresh salmon',
      'Pescado blanco': 'White fish',
      'Pechuga de pavo': 'Turkey breast',
      'Yogurt griego': 'Greek yogurt',
      'Yogurt griego alto en proteínas': 'High-protein Greek yogurt',
      'Proteína whey': 'Whey protein',
      'Proteína en polvo': 'Protein powder',
      'Caseína': 'Casein',
      'Tofu firme': 'Firm tofu',
      'Tempeh': 'Tempeh',
      'Seitán': 'Seitan',
      'Queso panela': 'Panela cheese',
      'Ricotta': 'Ricotta',
      'Hamburguesa de lentejas': 'Lentil burger',
      'Claras de huevo': 'Egg whites',

      // ─────────────────────────────────────────────────────────────
      // Carbohidratos
      // ─────────────────────────────────────────────────────────────
      'Papa': 'Potato',
      'Arroz blanco': 'White rice',
      'Camote': 'Sweet potato',
      'Fideo': 'Noodles',
      'Frijoles': 'Beans',
      'Quinua': 'Quinoa',
      'Quinoa': 'Quinoa',
      'Avena': 'Oats',
      'Avena orgánica': 'Organic oats',
      'Pan integral': 'Whole wheat bread',
      'Pan integral artesanal': 'Artisan whole wheat bread',
      'Tortilla de maíz': 'Corn tortilla',
      'Tortillas de maíz': 'Corn tortillas',
      'Galletas de arroz': 'Rice crackers',
      'Crema de arroz': 'Cream of rice',
      'Cereal de maíz': 'Corn cereal',
      'Pasta integral': 'Whole wheat pasta',

      // ─────────────────────────────────────────────────────────────
      // Grasas
      // ─────────────────────────────────────────────────────────────
      'Aceite de oliva': 'Olive oil',
      'Aceite de oliva extra virgen': 'Extra virgin olive oil',
      'Aceite de oliva / extra virgen': 'Olive oil / Extra virgin',
      'Aceite de palta': 'Avocado oil',
      'Aceite vegetal': 'Vegetable oil',
      'Maní': 'Peanuts',
      'Mantequilla de maní': 'Peanut butter',
      'Mantequilla de maní casera': 'Homemade peanut butter',
      'Almendras': 'Almonds',
      'Nueces': 'Walnuts',
      'Pistachos': 'Pistachios',
      'Pecanas': 'Pecans',
      'Aguacate': 'Avocado',
      'Palta': 'Avocado',
      'Aguacate hass': 'Hass avocado',
      'Has': 'Hass avocado',
      'Semillas de chía orgánicas': 'Organic chia seeds',
      'Linaza orgánica': 'Organic flaxseed',
      'Semillas de ajonjolí': 'Sesame seeds',
      'Aceitunas': 'Olives',
      'Miel': 'Honey',
      'Chocolate negro 70%': '70% Dark chocolate',
      'Mantequilla': 'Butter',
      'Manteca de cerdo': 'Lard',

      // ─────────────────────────────────────────────────────────────
      // Frutas
      // ─────────────────────────────────────────────────────────────
      'Plátano': 'Banana',
      'Manzana': 'Apple',
      'Naranja': 'Orange',
      'Berries (mix orgánico)': 'Berries (organic mix)',
      'Mango': 'Mango',
      'Papaya': 'Papaya',
      'Sandia': 'Watermelon',
      'Sandía': 'Watermelon',
      'Melón': 'Melon',
      'Fresas': 'Strawberries',
      'Arándanos': 'Blueberries',
      'Moras': 'Blackberries',
      'Pera': 'Pear',

      // ─────────────────────────────────────────────────────────────
      // Vegetales
      // ─────────────────────────────────────────────────────────────
      'Ensalada mixta': 'Mixed salad',
      'Ensalada completa mixta': 'Complete mixed salad',
      'Brócoli': 'Broccoli',
      'Zanahoria': 'Carrot',
      'Ejotes': 'Green beans',
      'Espinaca': 'Spinach',
      'Espinacas salteadas': 'Sautéed spinach',
      'Lechuga': 'Lettuce',
      'Pimiento': 'Bell pepper',
      'Calabacín': 'Zucchini',
      'Tomate': 'Tomato',
      'Pepino': 'Cucumber',
      'Coliflor': 'Cauliflower',
      'Champiñones': 'Mushrooms',
      'Bowl de vegetales al vapor': 'Steamed vegetables bowl',
      'Ensalada mediterránea': 'Mediterranean salad',
      'Vegetales salteados': 'Sautéed vegetables',
      'Ensalada verde mixta grande': 'Large mixed green salad',
      'Ensalada de vegetales crucíferos': 'Cruciferous vegetables salad',
      'Mix de vegetales bajos en carbos': 'Low-carb vegetables mix',

      // ─────────────────────────────────────────────────────────────
      // Otros
      // ─────────────────────────────────────────────────────────────
      'Tortillas integrales': 'Whole wheat tortillas',
    };

    // Intentamos traducción explícita primero
    final translated = esToEn[backendName.trim()];
    if (translated != null) {
      return translated;
    }

    // Si no está en el mapa, intentamos con FoodTranslations como fallback
    final fromLib = FoodTranslations.listToDisplayNames([backendName], locale);
    if (fromLib.isNotEmpty && fromLib.first != backendName) {
      return fromLib.first;
    }

    // Último fallback: devolvemos limpio (en inglés si es posible)
    return backendName.trim();
  }

  String formatRecipeInstructions(
      String rawInstructions, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale != 'es') return rawInstructions;

    // Traducciones de pasos y frases comunes
    final Map<String, String> stepTranslations = {
      'step_1_instruction': 'Paso 1:',
      'step_2_next': 'Paso 2:',
      'step_3_completion': 'Paso 3:',
      'personal_tip': '💡 Consejo personalizado:',
    };

    String formatted = rawInstructions;
    stepTranslations.forEach((key, translation) {
      formatted = formatted.replaceAll(key, translation);
    });

    return formatted
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .join('\n\n');
  }

  Widget _buildPersonalizedMessageCard(
      BuildContext context, MealPlanData? planData) {
    final l10n = AppLocalizations.of(context)!;

    final messageKey = _deriveMessageKey(planData);
    final message = _getTranslatedPersonalizedMessage(messageKey, l10n);

    if (message.isEmpty || message.trim() == ':name') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FrutiaColors.accent.withOpacity(0.1),
            FrutiaColors.accent2.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: FrutiaColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              color: FrutiaColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.personalMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    color: FrutiaColors.primaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
  }

  String _deriveMessageKey(MealPlanData? planData) {
    final nutritionPlan = planData?.nutritionPlan;
    if (nutritionPlan == null) return 'personalized_message_default';

    bool hasAMSnack = false;
    bool hasPMSnack = false;

    // Opción 1: revisar mealSchedule
    final schedule = nutritionPlan.mealSchedule;
    if (schedule != null) {
      hasAMSnack = schedule.keys.any((k) =>
          k.toLowerCase().contains('media mañana') ||
          k.toLowerCase().contains('mid-morning') ||
          k.toLowerCase().contains('snack am') ||
          k.toLowerCase().contains('snack_am'));
      hasPMSnack = schedule.keys.any((k) =>
          k.toLowerCase().contains('media tarde') ||
          k.toLowerCase().contains('mid-afternoon') ||
          k.toLowerCase().contains('merienda') ||
          k.toLowerCase().contains('snack pm') ||
          k.toLowerCase().contains('snack_pm'));
    }

    // Opción 2: revisar keys de meals
    if (!hasAMSnack && !hasPMSnack) {
      final meals = nutritionPlan.meals;
      for (var key in meals.keys) {
        final lower = key.toLowerCase();
        if (lower.contains('media mañana') ||
            lower.contains('am') ||
            lower.contains('morning') ||
            lower.contains('desayuno')) {
          hasAMSnack = true;
        }
        if (lower.contains('media tarde') ||
            lower.contains('pm') ||
            lower.contains('merienda') ||
            lower.contains('afternoon') ||
            lower.contains('tarde')) {
          hasPMSnack = true;
        }
      }
    }

    if (hasPMSnack) return 'personalized_message_pm';
    if (hasAMSnack) return 'personalized_message_am';
    return 'personalized_message_default';
  }

  String _getTranslatedPersonalizedMessage(String key, AppLocalizations l10n) {
    String message;
    switch (key) {
      case 'personalized_message_am':
        message = l10n.personalizedMessageAM;
        break;
      case 'personalized_message_pm':
        message = l10n.personalizedMessagePM;
        break;
      default:
        message = l10n.personalizedMessageDefault;
    }
    return message.replaceAll(':name', widget.userName);
  }

  Widget _buildAnthropometricCard(
      BuildContext context, AnthropometricSummary anthropometricSummary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.nutritionalProfileTitle,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                    AppLocalizations.of(context)!.ageLabel,
                    AppLocalizations.of(context)!
                        .ageYears(anthropometricSummary.age)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                    "BMI", "${anthropometricSummary.bmi.toStringAsFixed(1)}"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                    AppLocalizations.of(context)!.weightLabel,
                    AppLocalizations.of(context)!
                        .weightKg(anthropometricSummary.weight.toString())),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoChip(
                    AppLocalizations.of(context)!.heightLabel,
                    AppLocalizations.of(context)!.heightCm(
                        anthropometricSummary.height.toInt().toString())),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: FrutiaColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, TargetMacros macros) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context, l10n.dailyMacrosTitle, Icons.pie_chart_outline_rounded),
        const SizedBox(height: 15),
        _buildSummaryCard(
          context,
          icon: Icons.local_fire_department_outlined,
          title: l10n.caloriesLabel,
          text: '${macros.calories} kcal',
          delay: 200.ms,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: Icons.egg_alt_outlined,
                title: l10n.proteinLabel,
                text: '~${macros.protein}g',
                delay: 300.ms,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: Icons.local_pizza_outlined,
                title: l10n.carbsLabel,
                text: '~${macros.carbs}g',
                delay: 400.ms,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: Icons.water_drop_outlined,
                title: l10n.fatsLabel,
                text: '~${macros.fats}g',
                delay: 500.ms,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
    required Duration delay,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: FrutiaColors.accent, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: FrutiaColors.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: delay)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildMealOptionsWithExchanges(BuildContext context,
      Map<String, Meal> meals, AppLocalizations l10n, String locale) {
    if (meals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("No hay comidas disponibles en el plan",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            l10n.foodExchangesTitle ?? "Food Exchanges",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText,
            ),
          ),
        ),
        Text(
          l10n.foodExchangesSubtitle ??
              "You can swap options within each category while maintaining macros",
          style:
              GoogleFonts.lato(fontSize: 14, color: FrutiaColors.secondaryText),
        ),
        const SizedBox(height: 20),
        ...meals.entries.map((entry) {
          final mealKey = entry.key; // ej: "Desayuno", "Almuerzo"
          final meal = entry.value;

          // Traduce el título de la comida (Desayuno, Almuerzo, etc.)
          final translatedMealTitle = translateMeal(mealKey, l10n);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              title: Text(
                translatedMealTitle,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.accent,
                ),
              ),
              subtitle: Text(
                "Tap to view exchanges",
                style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600]),
              ),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                if (meal.components.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No hay opciones disponibles para esta comida",
                        style: TextStyle(color: Colors.grey)),
                  )
                else
                  ...meal.components.map((category) {
                    // Traduce la categoría (Proteínas → Proteins si en inglés)
                    final translatedCategory =
                        translateCategory(category.title, l10n);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título de categoría
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: FrutiaColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              translatedCategory,
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: FrutiaColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Opciones dentro de la categoría
                          ...category.options.map((option) {
                            // Traduce el nombre del alimento
                            final translatedName =
                                getLocalizedFoodName(option.name, l10n);
                            final translatedPortion =
                                translatePortion(option.portion, l10n);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.circle,
                                      size: 8, color: FrutiaColors.accent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: FrutiaColors.primaryText,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: translatedName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                              text: " - $translatedPortion"),
                                          TextSpan(
                                            text: " (${option.calories} kcal)",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: FrutiaColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String translateMealTiming(String? timingKey, AppLocalizations l10n) {
    if (timingKey == null || timingKey.isEmpty) return '';

    final locale = Localizations.localeOf(context).languageCode;

    // Si NO es español, devolver la clave original (inglés del backend)
    if (locale != 'es') {
      return timingKey;
    }

    final Map<String, String> timingTranslations = {
      // ⭐ Las que ya tenías o comunes
      'balanced_dinner_for_optimal_night_recovery':
          'Cena balanceada para recuperación nocturna óptima',
      'your_main_meal_of_the_day_with_40%_of_your_nutrients':
          'Tu comida principal del día con el 40% de tus nutrientes',
      'breakfast_designed_for_sustained_energy_until_lunch':
          'Desayuno diseñado para darte energía sostenida hasta el almuerzo',

      // ⭐ Si aparecen más en el futuro, agrégalas aquí fácilmente
      // 'another_key_example': 'Otra traducción',
    };

    return timingTranslations[timingKey] ??
        timingKey; // fallback: muestra la clave si no está en el mapa
  }

  Widget _buildMealExchangeCard(BuildContext context, String mealTitle,
      Meal meal, AppLocalizations l10n, String locale) {
    String? mealTime = meal.mealTiming;
    String subtitleText = mealTime != null
        ? "${l10n.mealTimeLabel}: $mealTime - ${l10n.tapToViewExchanges}"
        : l10n.tapToViewExchanges;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          mealTitle,
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.accent),
        ),
        subtitle: Text(
          subtitleText,
          style:
              GoogleFonts.lato(fontSize: 12, color: FrutiaColors.secondaryText),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...meal.components.map((category) {
                  final translatedCategory =
                      translateCategory(category.title, l10n);
                  return _buildExchangeGroup(
                      context, translatedCategory, category, l10n, locale);
                }),
                if (meal.personalizedTips != null &&
                    meal.personalizedTips!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FrutiaColors.accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: FrutiaColors.accent.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tipsForMeal,
                          style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.accent),
                        ),
                        const SizedBox(height: 4),
                        ...meal.personalizedTips!.map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                "• ${translateMealTiming(tip, l10n)}",
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: FrutiaColors.primaryText,
                                  height: 1.3,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeGroup(BuildContext context, String categoryTitle,
      MealCategory category, AppLocalizations l10n, String locale) {
    // Traducimos la categoría (Proteínas → Proteins si está en inglés)
    final translatedCategory = translateCategory(category.title, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FrutiaColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              translatedCategory,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: FrutiaColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...category.options.map((option) {
            // Traducimos el nombre del alimento según el idioma actual
            final translatedName = getLocalizedFoodName(option.name, l10n);
            final translatedPortion = translatePortion(option.portion, l10n);

            return _buildExchangeOption(
                context, translatedName, option, translatedPortion, l10n);
          }),
        ],
      ),
    );
  }

  Widget _buildExchangeOption(
    BuildContext context,
    String name,
    MealOption option,
    String translatedPortion,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: FrutiaColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lato(
                    fontSize: 14, color: FrutiaColors.primaryText),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: " - $translatedPortion"),
                  TextSpan(
                    text: " (${option.calories} kcal)",
                    style: TextStyle(
                        fontSize: 12, color: FrutiaColors.secondaryText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesSection(BuildContext context, Map<String, Meal> meals) {
    List<InspirationRecipe> allRecipes = [];
    meals.forEach((mealName, meal) {
      allRecipes.addAll(meal.suggestedRecipes);
    });

    if (allRecipes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context,
            AppLocalizations.of(context)!.suggestedRecipesTitle,
            Icons.restaurant_menu),
        const SizedBox(height: 15),
        Text(
          AppLocalizations.of(context)!.suggestedRecipesSubtitle,
          style: GoogleFonts.lato(
              fontSize: 14,
              color: FrutiaColors.secondaryText,
              fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 15),
        ...allRecipes.map((recipe) => _buildRecipeCard(context, recipe)),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, InspirationRecipe recipe) {
    final l10n = AppLocalizations.of(context)!;

    // Traducimos el título de la receta si está en inglés
    final translatedTitle = getLocalizedFoodName(recipe.title, l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: FrutiaColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.restaurant, color: FrutiaColors.accent, size: 24),
        ),
        title: Text(
          translatedTitle,
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.mealType != null)
              Text(
                "${l10n.recipeFor} ${translateMeal(recipe.mealType!, l10n)}",
                style:
                    GoogleFonts.lato(fontSize: 12, color: FrutiaColors.accent),
              ),
            Text(
              "${recipe.readyInMinutes} min • ${recipe.calories} kcal",
              style: GoogleFonts.lato(
                  fontSize: 12, color: FrutiaColors.secondaryText),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: FrutiaColors.secondaryText),
        onTap: () => _showRecipeDetail(context, recipe),
      ),
    );
  }

  void _showRecipeDetail(BuildContext context, InspirationRecipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    // Traducimos título de la receta
    final translatedTitle = getLocalizedFoodName(recipe.title, l10n);

    // Traducimos instrucciones
    final translatedInstructions =
        formatRecipeInstructions(recipe.instructions, l10n);

    // Traducimos cada ingrediente (si es lista de Map o strings)
    final translatedIngredients = recipe.extendedIngredients.map((ing) {
      String name = '';
      if (ing is Map<String, dynamic>) {
        name = ing['name'] as String? ?? ing['original'] as String? ?? '';
      } else if (ing is String) {
        name = ing;
      }
      return getLocalizedFoodName(name, l10n);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header con título y cerrar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      translatedTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Info rápida (tiempo, calorías, dificultad)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRecipeInfoChip(
                    "${recipe.readyInMinutes} min",
                    Icons.timer_outlined,
                  ),
                  _buildRecipeInfoChip(
                    "${recipe.calories} kcal",
                    Icons.local_fire_department_outlined,
                  ),
                  if (recipe.difficultyLevel != null)
                    _buildRecipeInfoChip(
                      recipe.difficultyLevel!,
                      Icons.star_outline,
                    ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Contenido principal (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nota personalizada (si existe)
                    if (recipe.personalizedNote != null &&
                        recipe.personalizedNote!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FrutiaColors.accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: FrutiaColors.accent.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nota personalizada',
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: FrutiaColors.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipe.personalizedNote!,
                              style:
                                  GoogleFonts.lato(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Ingredientes
                    Text(
                      l10n.ingredientsTitle ?? 'Ingredientes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...translatedIngredients.map((ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: FrutiaColors.accent)),
                              Expanded(
                                  child: Text(ing,
                                      style: GoogleFonts.lato(fontSize: 14))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),

                    // Instrucciones
                    Text(
                      l10n.instructionsTitle ?? 'Preparación',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      translatedInstructions,
                      style: GoogleFonts.lato(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 24),

                    // Alineación con meta y soporte deportivo (si existe)
                    if (recipe.goalAlignment != null ||
                        recipe.sportsSupport != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe.goalAlignment != null) ...[
                              Text(
                                l10n.goalAlignmentTitle ??
                                    'Alineación con tu meta',
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                recipe.goalAlignment!,
                                style: GoogleFonts.lato(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (recipe.sportsSupport != null) ...[
                              Text(
                                l10n.sportsSupportTitle ??
                                    'Soporte para deportes',
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                recipe.sportsSupport!,
                                style: GoogleFonts.lato(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FrutiaColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FrutiaColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
                fontSize: 12,
                color: FrutiaColors.accent,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTips(
      BuildContext context, PersonalizedTips personalizedTips) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context, l10n.personalizedTipsTitle, Icons.lightbulb_outline),
        const SizedBox(height: 15),
        if (personalizedTips.anthropometricGuidance.isNotEmpty)
          _buildTipCard(
            context,
            l10n.anthropometricGuidanceTitle,
            personalizedTips.anthropometricGuidance,
            Icons.analytics,
            Colors.blue,
          ),
        if (personalizedTips.difficultySupport.isNotEmpty)
          _buildTipCard(
            context,
            l10n.difficultySupportTitle,
            personalizedTips.difficultySupport,
            Icons.support_agent,
            Colors.green,
          ),
        if (personalizedTips.eatingOutGuidance.isNotEmpty)
          _buildTipCard(
            context,
            l10n.eatingOutGuidanceTitle,
            personalizedTips.eatingOutGuidance,
            Icons.restaurant,
            Colors.orange,
          ),
        if (personalizedTips.motivationalElements.isNotEmpty)
          _buildTipCard(
            context,
            l10n.motivationTitle,
            personalizedTips.motivationalElements,
            Icons.favorite,
            Colors.pink,
          ),
        if (personalizedTips.ageSpecificAdvice.isNotEmpty)
          _buildTipCard(
            context,
            l10n.ageSpecificAdviceTitle,
            personalizedTips.ageSpecificAdvice,
            Icons.calendar_today,
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context, String title, String content,
      IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: GoogleFonts.lato(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection(
      BuildContext context, List<String> recommendations,
      {String? title}) {
    final l10n = AppLocalizations.of(context)!;
    final displayTitle = title ?? l10n.recommendationsTitle;

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, displayTitle, Icons.lightbulb_outline),
        const SizedBox(height: 10),
        ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                        color: FrutiaColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Expanded(
                    child: Text(
                      rec,
                      style: GoogleFonts.lato(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: FrutiaColors.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }
}
