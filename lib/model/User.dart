class User {
  final int id;
  final String name;
  final String? email; // Cambiar a opcional

  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    this.email, // Opcional

    this.createdAt,
    this.updatedAt,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
