// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Adjust import paths based on your actual file structure
import 'features/auth/presentation/cubit/auth_cubit.dart';
// Assuming AuthState is defined in auth_cubit.dart or a separate auth_state.dart
// import 'features/auth/presentation/cubit/auth_state.dart'; // Needed if AuthState is separate
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
// Import DashboardCubit if providing it here
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
// Import repositories if providing them here for DashboardCubit
// import 'features/auth/domain/repositories/auth_repository.dart'; // Example dependency
// import 'features/products/domain/repositories/product_repository.dart'; // Example dependency


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artisan Hub GH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.tealAccent[400],
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent[400]!,
          secondary: Colors.tealAccent[200]!,
          surface: Colors.grey[900]!,
          background: Colors.black,
          error: Colors.redAccent[400]!,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIconColor: Colors.grey[500],
          suffixIconColor: Colors.grey[500],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.tealAccent[400]!, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.redAccent[400]!, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.redAccent[400]!, width: 2.0),
          ),
          errorStyle: TextStyle(color: Colors.redAccent[100]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent[400],
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.tealAccent[200],
            textStyle: const TextStyle(fontWeight: FontWeight.w600)
          )
        ),
      ),
      // Removed Sonner Toaster from builder. Fluttertoast doesn't need it.
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          print('[App.dart AuthWrapper] Current AuthState: $state');
          if (state is Authenticated) {
            print('[App.dart AuthWrapper] Authenticated state detected, showing Dashboard.');
            // Provide DashboardCubit here if this is its main entry point
            return BlocProvider(
              create: (context) => DashboardCubit(
                // TODO: Pass actual repositories here once they are set up for DI
                // authRepository: context.read<AuthCubit>().authRepository, // Example
                // productRepository: YourProductRepositoryImplementation(),
              ),
              child: const ArtisanDashboardScreen(),
            );
          }
          if (state is Unauthenticated || state is AuthError || state is AuthInitial) {
            print('[App.dart AuthWrapper] Unauthenticated/Error/Initial state, showing Login.');
            return const LoginScreen();
          }
          print('[App.dart AuthWrapper] AuthLoading state, showing global CircularProgressIndicator.');
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.tealAccent))
          );
        },
      ),
      // Define other named routes here if needed
      // routes: {
      //   '/login': (context) => LoginScreen(),
      //   '/register': (context) => RegisterScreen(),
      // },
    );
  }
}