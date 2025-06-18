// lib/model/MealPlanData.dart (o el nombre de tu archivo)

// --- Nuevo modelo para el detalle de un precio de ingrediente ---
class PriceDetail {
  final String store;
  final double price;
  final String currency;

  PriceDetail({
    required this.store,
    required this.price,
    required this.currency,
  });

  factory PriceDetail.fromJson(Map<String, dynamic> json) {
    return PriceDetail(
      store: json['store'] as String? ?? 'Tienda Desconocida',
      price:
          (json['price'] as num?)?.toDouble() ?? 0.0, // Asegura que sea double
      currency: json['currency'] as String? ?? '',
    );
  }

  // Opcional: para convertir a Map si necesitas pasar esto directamente
  Map<String, dynamic> toJson() {
    return {
      'store': store,
      'price': price,
      'currency': currency,
    };
  }
}

// --- Nuevo modelo para un ingrediente completo ---
class Ingredient {
  final String item;
  final String quantity;
  final List<PriceDetail> prices; // Ahora es una lista de PriceDetail

  Ingredient({
    required this.item,
    this.quantity = '',
    required this.prices,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      item: json['item'] as String? ?? 'Ingrediente Desconocido',
      quantity: json['quantity'] as String? ?? '',
      // Mapea la lista de mapas a una lista de PriceDetail
      prices: (json['prices'] as List<dynamic>?)
              ?.map((p) => PriceDetail.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Opcional: para convertir a Map si necesitas pasar esto directamente
  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'quantity': quantity,
      'prices': prices
          .map((p) => p.toJson())
          .toList(), // Convierte cada PriceDetail a Map
    };
  }
}

// --- Modelo para un solo item de comida/snack (MealItem) ---
class MealItem {
  final String option;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final List<Ingredient>
      ingredients; // <--- ¡CAMBIO CLAVE AQUÍ! Ahora es List<Ingredient>
  final List<String> instructions;
  final Map<String, dynamic>?
      details; // Mantenerlo para pasar los 'details' brutos si es necesario

  MealItem({
    required this.option,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    required this.ingredients,
    required this.instructions,
    this.details,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    // Para los ingredientes, mapeamos la lista de objetos JSON a una lista de objetos Ingredient
    final List<Ingredient> parsedIngredients =
        (json['details']?['ingredients'] as List<dynamic>?)
                ?.map((itemJson) =>
                    Ingredient.fromJson(itemJson as Map<String, dynamic>))
                .toList() ??
            [];

    return MealItem(
      option: json['opcion'] ?? 'Receta sin título',
      description:
          json['details']?['description'] ?? 'Descubriendo una nueva receta...',
      calories: json['details']?['calories'] ?? 0,
      prepTimeMinutes: json['details']?['prep_time_minutes'] ?? 0,
      ingredients:
          parsedIngredients, // Asignamos la lista de objetos Ingredient
      instructions: (json['details']?['instructions'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      details: json[
          'details'], // Pasamos los detalles completos si es necesario en otro lugar
    );
  }

  // Método para convertir MealItem a un Map<String, dynamic> compatible
  // con MyPlanDetailsScreen, que espera esta estructura.
  Map<String, dynamic> toRecipeDataMap() {
    return {
      'opcion': option,
      // Aunque no hay 'image_url' en MealItem directamente,
      // MyPlanDetailsScreen tiene un placeholder. Podrías añadirlo aquí si tu modelo
      // lo tuviera o si lo obtuvieras de otro lado.
      'image_url':
          'https://placehold.co/600x400/cccccc/ffffff?text=Imagen+Generica',
      'details': {
        'description': description,
        'calories': calories,
        'prep_time_minutes': prepTimeMinutes,
        // Convertimos List<Ingredient> a List<Map<String, dynamic>>
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'instructions': instructions,
      },
    };
  }
}

// --- Modelo para los datos completos del plan ---
class MealPlanData {
  final String summaryTitle;
  final String summaryText1;
  final String summaryText2;
  final String summaryText3;
  final String? summaryText4;
  final List<MealItem> desayunos;
  final List<MealItem> almuerzos;
  final List<MealItem> cenas;
  final List<MealItem> snacks;
  final List<String> recomendaciones;

  MealPlanData({
    required this.summaryTitle,
    required this.summaryText1,
    required this.summaryText2,
    required this.summaryText3,
    this.summaryText4,
    required this.desayunos,
    required this.almuerzos,
    required this.cenas,
    required this.snacks,
    required this.recomendaciones,
  });

  factory MealPlanData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> mealPlanMap = json['meal_plan'] ?? {};

    // Función auxiliar para parsear listas de MealItem
    List<MealItem> parseMealList(String key) {
      return (mealPlanMap[key] as List<dynamic>?)
              ?.map((item) => MealItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
    }

    return MealPlanData(
      summaryTitle: json['summary_title'] ?? 'Resumen de tu Plan',
      summaryText1: json['summary_text_1'] ??
          'Hemos creado este plan basado en tus objetivos.',
      summaryText2: json['summary_text_2'] ??
          'Tu plan está personalizado según tus necesidades.',
      summaryText3: json['summary_text_3'] ??
          'Te ayudamos a superar tus retos y mantenerte motivado.',
      summaryText4: json['summary_text_4'],
      desayunos: parseMealList('desayuno'),
      almuerzos: parseMealList('almuerzo'),
      cenas: parseMealList('cena'),
      snacks: parseMealList('snacks'), // Asegúrate de incluir los snacks aquí
      recomendaciones:
          (json['recomendaciones'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
