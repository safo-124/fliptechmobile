// lib/features/auth/presentation/cubit/auth_state.dart
part of 'auth_cubit.dart'; // If using Freezed or similar for sealed classes

abstract class AuthState {} // Or use an enum

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}