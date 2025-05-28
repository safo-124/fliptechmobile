// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'dart:convert';
import '../../../../core/api/api_client.dart'; // Adjust path if your ApiClient is elsewhere

// You might import your User model here if you were to map to it directly in the datasource,
// but typically the repository layer does that. For returning Map<String, dynamic>, it's not strictly needed here.
// import '../../../../data/models/user_model.dart'; 

abstract class AuthRemoteDataSource {
  /// Logs in an artisan user.
  /// Throws an [Exception] if login fails or if the response is not as expected.
  Future<Map<String, dynamic>> loginArtisan(String email, String password);

  /// Registers a new artisan user.
  /// [artisanData] should be a map containing fields like name, email, password, phoneNumber, nationalId.
  /// Throws an [Exception] if registration fails or if the response is not as expected.
  Future<Map<String, dynamic>> registerArtisan(Map<String, dynamic> artisanData);
  
  // You can add other auth-related methods here in the future, e.g.:
  // Future<void> forgotPassword(String email);
  // Future<void> resetPassword(String token, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> loginArtisan(String email, String password) async {
    final String endpoint = '/auth/artisan/login'; // Dedicated artisan login endpoint
    print('[AuthRemoteDataSource] Attempting login to: $endpoint');

    try {
      final response = await apiClient.post(endpoint, {
        'email': email,
        'password': password,
      });

      print('[AuthRemoteDataSource] Login Response Status Code: ${response.statusCode}');
      print('[AuthRemoteDataSource] Login Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // The backend should already verify the role for this dedicated endpoint.
        // A client-side check can be an additional safeguard.
        if (responseData['user'] != null && responseData['user']['role'] == 'ARTISAN' && responseData['token'] != null) {
          return responseData; // Expected: { message: "...", user: { ... }, token: "..." }
        } else {
          // This case indicates an unexpected successful response format or role mismatch not caught by backend.
          throw Exception(responseData['error'] ?? 'Login failed: Invalid user data or not an artisan account.');
        }
      } else {
        // Handle API errors (e.g., 400, 401, 403, 500)
        throw Exception(responseData['error'] ?? 'Failed to login. Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      // Catches network errors from ApiClient or jsonDecode errors if response isn't JSON
      print('[AuthRemoteDataSource] Login Exception: ${e.toString()}');
      // Rethrow a more generic or specific error message
      if (e is Exception && e.toString().contains("Failed to login")) {
        rethrow; // Rethrow specific exception from above
      }
      throw Exception('An error occurred during login. Please try again. (${e.toString()})');
    }
  }

  @override
  Future<Map<String, dynamic>> registerArtisan(Map<String, dynamic> artisanData) async {
    final String endpoint = '/auth/artisan/register';
    print('[AuthRemoteDataSource] Attempting registration to: $endpoint with data: $artisanData');

    try {
      final response = await apiClient.post(endpoint, artisanData);
      
      print('[AuthRemoteDataSource] Registration Response Status Code: ${response.statusCode}');
      print('[AuthRemoteDataSource] Registration Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Backend returns 201 Created for successful registration
      if (response.statusCode == 201) {
        if (responseData['user'] != null && responseData['token'] != null) {
          return responseData; // Expected: { message: "...", user: { ... }, token: "..." }
        } else {
          throw Exception('Registration failed: Invalid response data from server.');
        }
      } else {
        // Handle API errors (e.g., 400, 409, 500)
        throw Exception(responseData['error'] ?? 'Failed to register. Server responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('[AuthRemoteDataSource] Registration Exception: ${e.toString()}');
      if (e is Exception && e.toString().contains("Failed to register")) {
        rethrow;
      }
      throw Exception('An error occurred during registration. Please try again. (${e.toString()})');
    }
  }
}