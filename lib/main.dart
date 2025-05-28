// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Example for BLoC/Cubit
import 'app.dart';
import 'core/api/api_client.dart'; // Adjust
import 'features/auth/data/datasources/auth_remote_datasource.dart'; // Adjust
import 'features/auth/data/repositories/auth_repository_impl.dart'; // Adjust
import 'features/auth/domain/repositories/auth_repository.dart'; // Adjust
import 'features/auth/presentation/cubit/auth_cubit.dart'; // Adjust
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() {
  // Initialize dependencies (Dependency Injection setup)
  // This is a very basic setup. Consider using get_it or similar for larger apps.
  final apiClient = ApiClient();
  final secureStorage = FlutterSecureStorage();
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorage: secureStorage,
  );

  runApp(
    BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(authRepository: authRepository),
      child: MyApp(),
    ),
  );
}