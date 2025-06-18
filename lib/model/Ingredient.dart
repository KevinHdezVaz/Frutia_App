// lib/model/ingredient.dart

class Ingredient {
  final String item;
  final String quantity;
  final List<PriceDetail> prices; // Nueva lista de precios

  Ingredient({
    required this.item,
    this.quantity = '',
    required this.prices,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      item: json['item'] as String? ?? 'Desconocido',
      quantity: json['quantity'] as String? ?? '',
      prices: (json['prices'] as List<dynamic>?)
              ?.map((p) => PriceDetail.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Opcional: Para depuración
  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'quantity': quantity,
      'prices': prices.map((p) => p.toJson()).toList(),
    };
  }
}

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
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '',
    );
  }

  // Opcional: Para depuración
  Map<String, dynamic> toJson() {
    return {
      'store': store,
      'price': price,
      'currency': currency,
    };
  }
}
