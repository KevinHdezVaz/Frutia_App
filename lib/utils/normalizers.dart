/// Elimina emojis y normaliza caracteres especiales para estandarizar los datos guardados.
String removeEmojis(String text) {
  final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
      unicode: true);
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
      .trim();
}

String normalizeToSpanish(String? value, String field) {
  if (value == null || value.trim().isEmpty) {
    switch (field) {
      case 'goal':
        return 'Bajar grasa';
      case 'weekly_activity':
        return 'No me muevo y no entreno';
      case 'dietary_style':
        return 'Omnívoro';
      case 'budget':
        return 'Medio';
      case 'eats_out':
        return 'A veces (2 a 4 veces por semana)';
      case 'communication_style':
        return 'Cercana (como un amigo que te acompaña sin presión)';
      case 'sex':
        return 'masculino';
      default:
        return '';
    }
  }

  String cleaned = removeEmojis(value).trim();
  String lower = cleaned.toLowerCase();

  if (field == 'goal') {
    if (lower.contains('bajar') ||
        lower.contains('lose') ||
        lower.contains('fat') ||
        lower.contains('grasa')) return 'Bajar grasa';
    if (lower.contains('aumentar') ||
        lower.contains('gain') ||
        lower.contains('muscle') ||
        lower.contains('músculo')) return 'Aumentar músculo';
    if (lower.contains('salud') ||
        lower.contains('health') ||
        lower.contains('healthier') ||
        lower.contains('saludable')) return 'Comer más saludable';
    if (lower.contains('rendimiento') ||
        lower.contains('performance') ||
        lower.contains('mejorar')) return 'Mejorar rendimiento';
    return 'Bajar grasa';
  }

  if (field == 'weekly_activity') {
    if (lower.contains('no me muevo') ||
        lower.contains("don't move") ||
        lower.contains('sofa') ||
        lower.contains('couch') ||
        lower.contains('sedentario')) return 'No me muevo y no entreno';
    if (lower.contains('oficina') || lower.contains('office')) {
      if (lower.contains('1-2') ||
          lower.contains('uno-dos') ||
          lower.contains('one-two')) return 'Oficina + entreno 1-2 veces';
      if (lower.contains('3-4') ||
          lower.contains('tres-cuatro') ||
          lower.contains('three-four')) return 'Oficina + entreno 3-4 veces';
      if (lower.contains('5-6') ||
          lower.contains('cinco-seis') ||
          lower.contains('five-six')) return 'Oficina + entreno 5-6 veces';
    }
    if (lower.contains('trabajo activo') || lower.contains('active work')) {
      if (lower.contains('1-2')) return 'Trabajo activo + entreno 1-2 veces';
      if (lower.contains('3-4')) return 'Trabajo activo + entreno 3-4 veces';
    }
    if (lower.contains('físico') ||
        lower.contains('physical') ||
        lower.contains('construcción') ||
        lower.contains('muy físico'))
      return 'Trabajo muy físico + entreno 5-6 veces';
    return 'No me muevo y no entreno';
  }

  if (field == 'dietary_style') {
    if (lower.contains('omnívoro') ||
        lower.contains('omni') ||
        lower.contains('everything')) return 'Omnívoro';
    if (lower.contains('vegetari') || lower.contains('vegetarian'))
      return 'Vegetariano';
    if (lower.contains('vegano') || lower.contains('vegan')) return 'Vegano';
    if (lower.contains('keto')) return 'Keto';
    return 'Omnívoro';
  }

  if (field == 'budget') {
    if (lower.contains('bajo') ||
        lower.contains('low') ||
        lower.contains('básico')) return 'Bajo';
    if (lower.contains('alto') ||
        lower.contains('high') ||
        lower.contains('sin restricción')) return 'Alto';
    return 'Medio';
  }

  if (field == 'eats_out') {
    if (lower.contains('casi todos') || lower.contains('almost'))
      return 'Casi todos los días';
    if (lower.contains('a veces') ||
        lower.contains('sometimes') ||
        lower.contains('2 a 4')) return 'A veces (2 a 4 veces por semana)';
    if (lower.contains('rara vez') ||
        lower.contains('rarely') ||
        lower.contains('1 vez')) return 'Rara vez (1 vez por semana o menos)';
    if (lower.contains('nunca') || lower.contains('never')) return 'Nunca';
    return 'A veces (2 a 4 veces por semana)';
  }

  if (field == 'communication_style') {
    if (lower.contains('motiv') ||
        lower.contains('motivadora') ||
        lower.contains('push'))
      return 'Motivadora (que te empuje a dar más cuando lo necesites)';
    if (lower.contains('cercana') ||
        lower.contains('close') ||
        lower.contains('amigo'))
      return 'Cercana (como un amigo que te acompaña sin presión)';
    if (lower.contains('directa') ||
        lower.contains('direct') ||
        lower.contains('sin vueltas'))
      return 'Directa (clara, sin vueltas ni frases suaves)';
    return 'Como te salga a ti, yo me adapto';
  }

  if (field == 'sex') {
    if (lower.contains('masculino') ||
        lower.contains('male') ||
        lower.contains('hombre') ||
        lower == 'm') return 'masculino';
    if (lower.contains('femenino') ||
        lower.contains('female') ||
        lower.contains('mujer') ||
        lower == 'f') return 'femenino';
    return 'masculino';
  }

  if (field.startsWith('favorite_') ||
      field == 'diet_difficulties' ||
      field == 'diet_motivations' ||
      field == 'sport') {
    const Map<String, String> map = {
      'gym': 'Gimnasio',
      'soccer': 'Fútbol',
      'running': 'Running',
      'tennis': 'Tenis',
      'none': 'Ninguno', // Removido 'other' de aquí para manejarlo por campo
      'whole egg': 'Huevo entero',
      'egg whites + whole egg': 'Claras + Huevo entero',
      'canned tuna': 'Atún en lata',
      'chicken thigh with skin': 'Muslo de pollo con piel',
      'chicken breast or thigh': 'Pechuga o muslo de pollo',
      'chicken breast': 'Pechuga de pollo',
      'ground beef 80/20': 'Carne molida 80/20',
      'lean beef': 'Carne magra de res',
      'white fish': 'Pescado blanco',
      'salmon': 'Salmón',
      'fresh salmon': 'Salmón',
      'ribeye': 'Ribeye',
      'duck breast': 'Pechuga de pato',
      'aged cheese': 'Queso añejo',
      'turkey fillet': 'Filete de pavo',
      'turkey breast': 'Pechuga de pavo',
      'greek yogurt': 'Yogur griego',
      'whey protein': 'Proteína whey',
      'casein': 'Caseína',
      'tofu': 'Tofu',
      'tempeh': 'Tempeh',
      'seitan': 'Seitan',
      'lentils': 'Lentejas',
      'chickpeas': 'Garbanzos',
      'beans': 'Frijoles',
      'plant protein powder': 'Proteína vegetal en polvo',
      'natural yogurt': 'Yogur natural',
      'fresh cheese': 'Queso fresco',
      'cottage cheese': 'Queso cottage',
      'panela cheese': 'Queso panela',
      'ricotta': 'Ricotta',
      'white rice': 'Arroz blanco',
      'potato': 'Papa',
      'sweet potato': 'Camote',
      'traditional oats': 'Avena tradicional',
      'organic oats': 'Avena orgánica',
      'quinoa': 'Quinua',
      'corn tortillas': 'Tortillas de maíz',
      'basic noodles/pasta': 'Fideos/pasta básica',
      'artisan whole wheat bread': 'Pan integral artesanal',
      'rice crackers': 'Galletas de arroz',
      'cream of rice': 'Crema de arroz',
      'broccoli': 'Brócoli',
      'cauliflower': 'Coliflor',
      'spinach': 'Espinaca',
      'lettuce': 'Lechuga',
      'zucchini': 'Calabacín',
      'olive oil': 'Aceite de oliva',
      'extra virgin olive oil': 'Aceite de oliva extra virgen',
      'avocado oil': 'Aceite de aguacate',
      'peanuts / peanut butter': 'Maní / Mantequilla de maní',
      'small avocado': 'Aguacate pequeño',
      'hass avocado': 'Aguacate hass',
      'avocado': 'Aguacate hass',
      'almonds': 'Almendras',
      'walnuts': 'Nueces',
      'sesame seeds': 'Semillas de sésamo',
      'olives': 'Aceitunas',
      'organic chia/flax': 'Chía/linaza orgánica',
      'premium nuts': 'Nueces premium',
      'lard': 'Manteca',
      'butter': 'Mantequilla',
      'mct oil': 'Aceite MCT',
      'ghee butter': 'Mantequilla ghee',
      'honey': 'Miel',
      '70% chocolate': 'Chocolate 70%',
      'strawberries': 'Fresas',
      'blueberries': 'Arándanos',
      'blackberries': 'Moras',
      'banana': 'Plátano',
      'apple': 'Manzana',
      'mango': 'Mango',
      'watermelon': 'Sandía',
      'pear': 'Pera',
      'know what to eat when i don\'t have the plan':
          'Saber qué comer cuando no tengo lo del plan',
      'know what to eat': 'Saber qué comer cuando no tengo lo del plan',
      'eat healthy outside home': 'Comer saludable fuera de casa',
      'control cravings': 'Controlar los antojos',
      'prepare meals': 'Preparar la comida',
      'stay consistent': 'Mantenerme constante',
      'other': 'Otra',
      'see quick results': 'Ver resultados rápidos',
      'feel better physically':
          'Sentirme mejor físicamente (energía, digestión, menos pesadez)',
      'prove to myself i can do it': 'Demostrarme que puedo lograrlo',
      'improve my health in the long term': 'Mejorar mi salud a largo plazo',
      'not clear yet': 'Aún no lo tengo claro',
    };
    String key =
        lower.replaceAll('️', '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (key == 'other') {
      return field == 'sport' ? 'Otro' : 'Otra';
    }
    return map[key] ?? cleaned;
  } else if (field == 'disliked_foods') {
    // ⭐ NUEVO: Mapeo específico para disliked_foods (inglés/español → español estandarizado)
    final Map<String, String> dislikedMap = {
      // Inglés a Español
      'white rice': 'Arroz blanco',
      'chicken': 'Pollo',
      'beef': 'Carne de res',
      'salmon': 'Salmón',
      'tuna': 'Atún',
      'avocado': 'Aguacate',
      'sweet potato': 'Camote',
      'broccoli': 'Brócoli',
      'liver': 'Hígado',
      'pork': 'Cerdo',
      'fish': 'Pescado',
      'quinoa': 'Quinua',
      'oats': 'Avena',
      'bread': 'Pan integral',
      'potato': 'Papa',
      // Español (normaliza variaciones)
      'arroz blanco': 'Arroz blanco',
      'pollo': 'Pollo',
      'carne de res': 'Carne de res',
      'salmon': 'Salmón', // Sin acento
      'atun': 'Atún',
      'aguacate': 'Aguacate',
      'camote': 'Camote',
      'brocoli': 'Brócoli',
      'higado': 'Hígado',
      // Agrega más basados en FOOD_PREFERENCES (top alimentos que podrían disliked)
      'huevo': 'Huevo entero',
      'yogur': 'Yogur griego',
      'frijoles': 'Frijoles',
      // Si no match, retorna el cleaned (back intentará filtrar por similitud)
    };

    return dislikedMap[lower] ?? cleaned;
  }

  return cleaned;
}
