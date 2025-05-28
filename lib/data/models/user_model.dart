// lib/data/models/user_model.dart
class User {
  final String id;
  final String? name;
  final String email;
  final String role; // e.g., "ARTISAN", "CUSTOMER"
  final bool isActive;
  // Add other relevant fields like lastLogin, createdAt, etc.

  User({
    required this.id,
    this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'] ?? true, // Handle potential nulls
    );
  }
}