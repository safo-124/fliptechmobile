// lib/features/auth/domain/repositories/auth_repository.dart
import '../../../../data/models/user_model.dart'; // Adjust import

abstract class AuthRepository {
  Future<User> loginArtisan(String email, String password); // Returns User object and handles token internally
  Future<User> registerArtisan(Map<String, dynamic> artisanData);
  Future<void> logout();
  Future<String?> getToken();
  Future<String?> getArtisanId(); // To store and retrieve artisanId
  Future<User?> getCurrentUser(); // Optionally fetch current user details
}