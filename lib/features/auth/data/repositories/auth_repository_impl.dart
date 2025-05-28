// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart'; // Abstract repository
import '../../../../data/models/user_model.dart'; // Your User Dart model

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({required this.remoteDataSource, required this.secureStorage});

  Future<void> _storeAuthData(Map<String, dynamic> responseData) async {
    if (responseData['token'] != null) {
      await secureStorage.write(key: 'authToken', value: responseData['token']);
    }
    if (responseData['user'] != null && responseData['user']['id'] != null) {
      await secureStorage.write(key: 'artisanId', value: responseData['user']['id']);
      // Optionally store entire user object in SharedPreferences (not for sensitive data)
      // or rely on fetching it when needed via a '/auth/me' endpoint.
    }
  }

  @override
  Future<User> loginArtisan(String email, String password) async {
    final responseData = await remoteDataSource.loginArtisan(email, password);
    await _storeAuthData(responseData);
    return User.fromJson(responseData['user']);
  }

  @override
  Future<User> registerArtisan(Map<String, dynamic> artisanData) async {
    final responseData = await remoteDataSource.registerArtisan(artisanData);
    await _storeAuthData(responseData); // Store token and ID after successful registration
    return User.fromJson(responseData['user']);
  }
  
  @override
  Future<void> logout() async {
    await secureStorage.delete(key: 'authToken');
    await secureStorage.delete(key: 'artisanId');
    // TODO: Optionally call a backend logout endpoint if you implement one
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'authToken');
  }

  @override
  Future<String?> getArtisanId() async {
    return await secureStorage.read(key: 'artisanId');
  }
  
  @override
  Future<User?> getCurrentUser() async {
    // This should ideally call a backend '/api/auth/me' endpoint using the stored token
    // For now, it's a placeholder. If you stored user details in SharedPreferences:
    // final prefs = await SharedPreferences.getInstance();
    // final String? userJson = prefs.getString('currentUserDetails');
    // if (userJson != null) {
    //   return User.fromJson(jsonDecode(userJson));
    // }
    // If not, and token exists, fetch from backend:
    final token = await getToken();
    if (token != null) {
        // Example: make a call to your backend to get user details
        // final response = await ApiClient().get('/auth/me', requiresAuth: true); // Assuming ApiClient is accessible or passed in
        // if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body)['user']);
    }
    return null; 
  }
}