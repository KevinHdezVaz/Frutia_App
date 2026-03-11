import 'package:flutter/material.dart';
import 'package:Frutia/l10n/app_localizations.dart';

class TranslationHelper {
  static String getLocalizedFoodName(
      BuildContext context, String backendName, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;

    // En español: devolvemos exactamente lo del backend
    if (locale == 'es') {
      return backendName.trim();
    }

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
      'Yogurt griego alto en proteína': 'High-protein Greek yogurt',
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
      'Hass': 'Hass avocado',
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

    // Buscamos en el mapa
    return esToEn[backendName.trim()] ?? backendName.trim();
  }

  /// Traduce el objetivo del usuario (que viene en español desde backend)
  /// a la cadena localizada correspondiente en AppLocalizations.
  static String getLocalizedGoal(
      BuildContext context, String backendGoal, AppLocalizations l10n) {
    if (backendGoal.isEmpty) return backendGoal;

    final normalized = backendGoal.trim();

    // Mapa de valores backend -> Getters de l10n
    // Incluye versiones con y sin emojis por robustez
    final Map<String, String> goalMap = {
      '🔥 Bajar grasa': l10n.loseBodyFat,
      'Bajar grasa': l10n.loseBodyFat,
      '💪 Aumentar músculo': l10n.gainMuscle,
      'Aumentar músculo': l10n.gainMuscle,
      '🥗 Comer más saludable': l10n.eatHealthier,
      'Comer más saludable': l10n.eatHealthier,
      '📈 Mejorar rendimiento': l10n.improvePerformance,
      'Mejorar rendimiento': l10n.improvePerformance,
    };

    return goalMap[normalized] ?? backendGoal;
  }
}
