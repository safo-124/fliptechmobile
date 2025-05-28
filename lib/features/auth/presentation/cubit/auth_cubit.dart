// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Adjust import paths based on your actual file structure
import '../../../../data/models/user_model.dart'; // Your User Dart model
import '../../domain/repositories/auth_repository.dart'; // Abstract repository

part 'auth_state.dart'; // Defines AuthState and its subclasses (AuthInitial, AuthLoading, Authenticated, etc.)

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    checkAuthStatus(); // Check authentication status when the Cubit is created
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    print("[AuthCubit] Checking auth status...");
    try {
      final token = await authRepository.getToken();
      if (token != null && token.isNotEmpty) {
        // Token exists, now try to get user details from the backend.
        // This assumes authRepository.getCurrentUser() makes an API call
        // to something like GET /api/auth/me using the stored token.
        print("[AuthCubit] Token found. Fetching current user details...");
        final User? currentUser = await authRepository.getCurrentUser(); 
        
        if (currentUser != null) {
          print("[AuthCubit] User details fetched successfully: ${currentUser.name} (Role: ${currentUser.role})");
          // Crucial: Ensure the fetched user is an ARTISAN if this cubit is for artisan app context
          if (currentUser.role == "ARTISAN") {
            emit(Authenticated(currentUser));
          } else {
            print("[AuthCubit] User role is not ARTISAN (${currentUser.role}). Logging out.");
            await authRepository.logout(); // Clear token for non-artisan user
            emit(Unauthenticated());
          }
        } else {
          // Token might be invalid, expired, or user details not fetchable from backend
          print("[AuthCubit] Token found but user details could not be fetched or user is null. Logging out.");
          await authRepository.logout(); // Clear invalid token
          emit(Unauthenticated());
        }
      } else {
        print("[AuthCubit] No token found. User is unauthenticated.");
        emit(Unauthenticated());
      }
    } catch (e) {
      print("[AuthCubit] Error during checkAuthStatus: ${e.toString()}");
      await authRepository.logout(); // Attempt to clear token on error too
      emit(Unauthenticated()); // Fallback to unauthenticated on any error during check
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    print("[AuthCubit] Attempting login for email: $email");
    try {
      final user = await authRepository.loginArtisan(email, password); // This should ensure role is ARTISAN
      print("[AuthCubit] Login successful, user: ${user.name}. Emitting Authenticated.");
      emit(Authenticated(user));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      print("[AuthCubit] Login error: $errorMessage");
      emit(AuthError(errorMessage));
    }
  }

  Future<void> register(Map<String, dynamic> artisanData) async {
    emit(AuthLoading());
    print("[AuthCubit] Attempting registration with data: $artisanData");
    try {
      final user = await authRepository.registerArtisan(artisanData); // This should create an ARTISAN user
      print("[AuthCubit] Registration successful, user: ${user.name}. Emitting Authenticated.");
      emit(Authenticated(user)); // Auto-login by emitting Authenticated state
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      print("[AuthCubit] Registration error: $errorMessage");
      emit(AuthError(errorMessage));
    }
  }

  Future<void> logout() async {
    // No need to emit AuthLoading here if logout is quick, or can add if API call is made
    print("[AuthCubit] Attempting logout.");
    try {
      await authRepository.logout();
      print("[AuthCubit] Logout successful. Emitting Unauthenticated.");
      emit(Unauthenticated());
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      print("[AuthCubit] Logout error: $errorMessage");
      // Even if logout API call fails, force unauthenticated state on client
      emit(Unauthenticated());
    }
  }
}