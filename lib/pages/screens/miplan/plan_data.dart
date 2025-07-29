import 'dart:convert';
import 'package:flutter/material.dart';

// --- Helper Functions para convertir Strings a Widgets ---

IconData _iconFromString(String iconName) {
  switch (iconName) {
    case 'wb_sunny_outlined':
      return Icons.wb_sunny_outlined;
    case 'nightlight_round':
      return Icons.nightlight_round;
    case 'blender_outlined':
      return Icons.blender_outlined;
    case 'fastfood_outlined':
      return Icons.fastfood_outlined;
    case 'set_meal_outlined':
      return Icons.set_meal_outlined;
    case 'eco_outlined':
      return Icons.eco_outlined;
    case 'rice_bowl_outlined':
      return Icons.rice_bowl_outlined;
    case 'spa_outlined':
      return Icons.spa_outlined;
    case 'water_drop_outlined':
      return Icons.water_drop_outlined;
    case 'cake_outlined':
      return Icons.cake_outlined;
    case 'grain_outlined':
      return Icons.grain_outlined;
    case 'science_outlined':
      return Icons.science_outlined;
    case 'breakfast_dining_outlined':
      return Icons.breakfast_dining_outlined;
    default:
      return Icons.help_outline;
  }
}

Color _colorFromString(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'orange':
      return Colors.orange;
    case 'indigo':
      return Colors.indigo;
    case 'pink':
      return Colors.pink;
    default:
      return Colors.grey;
  }
}

class MealPlanData {
  final NutritionPlan nutritionPlan;
  final List<InspirationRecipe>
      recipes; // Para la lista de inspiración que viene del backend

  const MealPlanData({
    required this.nutritionPlan,
    required this.recipes,
  });

  factory MealPlanData.fromJson(Map<String, dynamic> json) {
    // Parsea la lista de recetas de inspiración si el backend la envía
    final parsedRecipes = (json['recipes'] as List<dynamic>? ?? [])
        .map((r) => InspirationRecipe.fromJson(r as Map<String, dynamic>))
        .toList();

    return MealPlanData(
      nutritionPlan: NutritionPlan.fromJson(json['nutritionPlan'] ?? {}),
      recipes: parsedRecipes,
    );
  }
}

// ==========================================================
// 2. MODELOS PARA 'nutritionPlan'
// ==========================================================

// --- Añade esta nueva clase ---
class PriceInfo {
  final String store;
  final double price;
  final String? currency;

  const PriceInfo({required this.store, required this.price, this.currency});

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      store: json['store'] as String? ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'store': store,
        'price': price,
        'currency': currency,
      };
}

class NutritionPlan {
  final TargetMacros targetMacros;
  final Map<String, Meal> meals;
  final List<String> generalRecommendations;
  final List<String> rememberRecommendations;

  const NutritionPlan({
    required this.targetMacros,
    required this.meals,
    required this.generalRecommendations,
    required this.rememberRecommendations,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    final mealsData = json['meals'] as Map<String, dynamic>? ?? {};
    final Map<String, Meal> parsedMeals = {};

    mealsData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        // Estructura nueva con 'components' y 'suggested_recipes'
        parsedMeals[key] = Meal.fromJson(value);
      } else if (value is List) {
        // Estructura antigua o para comidas sin recetas (ej. Snacks)
        parsedMeals[key] = Meal(
          components: value.map((c) => MealCategory.fromJson(c)).toList(),
          suggestedRecipes: [], // Se asigna una lista vacía
        );
      }
    });

    final recommendations =
        json['recommendations'] as Map<String, dynamic>? ?? {};
    final general = recommendations['general'] as List? ?? [];
    final remember = recommendations['remember'] as List? ?? [];

    return NutritionPlan(
      targetMacros: TargetMacros.fromJson(json['targetMacros'] ?? {}),
      meals: parsedMeals,
      generalRecommendations: List<String>.from(general),
      rememberRecommendations: List<String>.from(remember),
    );
  }
}

// Esto es un ejemplo de cómo debería verse tu clase en plan_data.dart

class TargetMacros {
  final int calories;
  final int protein;
  final int fats; // Tu propiedad se llama 'fats'
  final int carbs; // Tu propiedad se llama 'carbs'

  TargetMacros({
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
  });

  factory TargetMacros.fromJson(Map<String, dynamic> json) {
    return TargetMacros(
      // ▼▼▼ APLICA LA MISMA CORRECCIÓN AQUÍ ▼▼▼
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbohydrates'] as num?)?.toInt() ??
          0, // Nota: Tu JSON usa 'carbohydrates'
      fats: (json['fat'] as num?)?.toInt() ?? 0, // Nota: Tu JSON usa 'fat'
    );
  }
}

class MealCategory {
  final String title;
  final List<MealOption> options;

  const MealCategory({required this.title, required this.options});

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    // Mapea la lista a objetos MealOption, que es lo correcto para tu JSON
    List<MealOption> parsedOptions =
        optionsList.map((i) => MealOption.fromJson(i)).toList();

    return MealCategory(
      title: json['title'] ?? 'Sin título',
      options: parsedOptions,
    );
  }
}
// --- Reemplaza tu clase MealOption por esta ---

class MealOption {
  final String name;
  final String imageUrl;
  final int calories;
  final int protein;
  final String portion; // <-- AÑADIDO

  final int carbs;
  final int fats;
  final List<PriceInfo> prices;
  final List<String> ingredients; // Nuevo campo para ingredientes

  const MealOption({
    required this.name,
    required this.imageUrl,
    required this.portion, // <-- AÑADIDO

    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.prices,
    required this.ingredients, // Añadido
  });

  // En plan_data.dart

  factory MealOption.fromJson(Map<String, dynamic> json) {
    var pricesList = json['prices'] as List? ?? [];
    var ingredientsList = json['ingredients'] as List? ?? [];
    return MealOption(
      name: json['name'] as String? ?? 'Sin nombre',
      imageUrl: json['imageUrl'] as String? ?? '',
      portion: json['portion'] as String? ?? 'N/A',

      // ▼▼▼ CAMBIO IMPORTANTE AQUÍ ▼▼▼
      // Aceptamos cualquier tipo de número (num) y lo convertimos a entero (int)
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbohydrates'] as num?)?.toInt() ??
          0, // Nota: Tu JSON usa 'carbohydrates'
      fats: (json['fat'] as num?)?.toInt() ??
          0, // Nota: Tu JSON usa 'fat' en singular a veces

      prices: pricesList
          .map((p) => PriceInfo.fromJson(p as Map<String, dynamic>))
          .toList(),
      ingredients: List<String>.from(ingredientsList),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'portion': portion, // <-- AÑADIDO

      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'prices': prices.map((p) => p.toJson()).toList(),
      'ingredients': ingredients, // Añadido
    };
  }
}

// ==========================================================
// 3. MODELOS PARA 'recipes'
// ==========================================================

class RecipeIngredient {
  final String name;
  final String? quantity;

  const RecipeIngredient({required this.name, this.quantity});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] ?? '',
      quantity: json['quantity'],
    );
  }
}

// Modelo actualizado para las recetas de Spoonacular
class InspirationRecipe {
  final String title;
  final String? image;
  final int readyInMinutes;
  String? mealType; // <-- AÑADE ESTE CAMPO

  final int servings;
  final String instructions;
  final List<dynamic>
      extendedIngredients; // Lista de ingredientes para el súper
  final List<dynamic> analyzedInstructions; // Pasos detallados
  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  InspirationRecipe({
    required this.title,
    this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.instructions,
    required this.extendedIngredients,
    required this.analyzedInstructions,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.mealType = 'General', // Asignación por defecto
  });

  factory InspirationRecipe.fromJson(Map<String, dynamic> json) {
    // Función para determinar el tipo de comida
    String determineMealType(String title) {
      title = title.toLowerCase();
      if (title.contains('desayuno') ||
          title.contains('breakfast') ||
          title.contains('avena')) {
        return 'Desayuno';
      }
      if (title.contains('almuerzo') ||
          title.contains('lunch') ||
          title.contains('ensalada')) {
        return 'Almuerzo';
      }
      if (title.contains('cena') ||
          title.contains('dinner') ||
          title.contains('sopa')) {
        return 'Cena';
      }
      return 'General'; // Por defecto
    }

    return InspirationRecipe(
      title: json['name'] ?? 'Sin título',
      image: json['image'],
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 1,
      instructions: json['instructions'] ?? 'No hay instrucciones.',
      extendedIngredients: json['extendedIngredients'] as List<dynamic>? ?? [],
      analyzedInstructions:
          json['analyzedInstructions'] as List<dynamic>? ?? [],
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      mealType: determineMealType(json['name'] ?? ''),
    );
  }
}

// --- AÑADE ESTA NUEVA CLASE ---

class Meal {
  final List<MealCategory> components;
  final List<InspirationRecipe> suggestedRecipes;

  const Meal({required this.components, required this.suggestedRecipes});

  factory Meal.fromJson(Map<String, dynamic> json) {
    final componentsList = json['components'] as List? ?? [];
    final parsedComponents =
        componentsList.map((c) => MealCategory.fromJson(c)).toList();

    // Se parsea la LISTA de recetas sugeridas
    final recipesList = json['suggested_recipes'] as List? ?? [];
    final parsedRecipes = recipesList
        .map((r) => InspirationRecipe.fromJson(r as Map<String, dynamic>))
        .toList();

    return Meal(
      components: parsedComponents,
      suggestedRecipes: parsedRecipes,
    );
  }
}

class FormulaOption {
  final String description;
  final IconData icon;

  const FormulaOption({required this.description, required this.icon});

  factory FormulaOption.fromJson(Map<String, dynamic> json) {
    return FormulaOption(
      description: json['description'] ?? '',
      icon: _iconFromString(json['icon'] ?? ''),
    );
  }
}

class FormulaCategory {
  final String title;
  final List<FormulaOption> options;

  const FormulaCategory({required this.title, required this.options});

  factory FormulaCategory.fromJson(Map<String, dynamic> json) {
    final optionsList = json['options'] as List? ?? [];
    return FormulaCategory(
      title: json['title'] ?? 'Sin Título',
      options: optionsList.map((o) => FormulaOption.fromJson(o)).toList(),
    );
  }
}

class MealFormula {
  final String title;
  final String mealType;
  final IconData icon;
  final Color color;
  final List<FormulaCategory> categories;

  const MealFormula({
    required this.title,
    required this.mealType,
    required this.icon,
    required this.color,
    required this.categories,
  });

  factory MealFormula.fromJson(Map<String, dynamic> json) {
    final categoriesList = json['categories'] as List? ?? [];
    return MealFormula(
      title: json['title'] ?? 'Sin Título',
      mealType: json['mealType'] ?? '',
      icon: _iconFromString(json['icon'] ?? ''),
      color: _colorFromString(json['color'] ?? 'grey'),
      categories:
          categoriesList.map((c) => FormulaCategory.fromJson(c)).toList(),
    );
  }
}
