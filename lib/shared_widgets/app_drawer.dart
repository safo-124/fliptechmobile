// lib/shared_widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Adjust import paths based on your actual file structure
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/products/presentation/screens/my_products_screen.dart';
import '../features/products/presentation/cubit/product_list_cubit.dart';
import '../features/products/domain/repositories/product_repository.dart'; // For type
import '../features/products/data/repositories/product_repository_impl.dart'; // For impl
import '../features/products/data/datasources/product_remote_datasource.dart'; // For impl
import '../core/api/api_client.dart'; // For ApiClient if instantiating directly

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[300]),
      title: Text(
        text,
        style: TextStyle(color: textColor ?? Colors.grey[100], fontSize: 15),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String artisanName = "Artisan User";
    String artisanEmail = "artisan@example.com"; // Placeholder

    if (authState is Authenticated) {
      artisanName = authState.user.name?.isNotEmpty == true ? authState.user.name! : "Artisan";
      artisanEmail = authState.user.email;
    }

    return Drawer(
      backgroundColor: Colors.grey[900], 
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              artisanName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            accountEmail: Text(
              artisanEmail,
              style: TextStyle(color: Colors.grey[300]),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                artisanName.isNotEmpty ? artisanName[0].toUpperCase() : "A",
                style: TextStyle(fontSize: 24.0, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            text: 'Dashboard',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              // If using named routes and dashboard is '/', or if it's already the current root.
              // For simplicity, assuming dashboard is home or handled by router.
              // If not, use Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          _buildDrawerItem(
            icon: Icons.inventory_2_outlined,
            text: 'My Products',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer first

              // Example: Direct instantiation (improve with DI)
              final apiClient = ApiClient(); 
              final authRepository = context.read<AuthCubit>().authRepository;
              final productRepository = ProductRepositoryImpl(
                  remoteDataSource: ProductRemoteDataSourceImpl(apiClient: apiClient)
              );

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (newContext) => ProductListCubit(
                      productRepository: productRepository,
                      authRepository: authRepository,
                    ),
                    child: const MyProductsScreen(),
                  ),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.build_circle_outlined,
            text: 'My Services',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("My Services (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.school_outlined,
            text: 'My Training Offers',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("My Training Offers (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_outlined,
            text: 'Orders & Bookings',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Orders & Bookings (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.message_outlined,
            text: 'Messages',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Messages (TBD)");
            },
          ),
          Divider(color: Colors.grey[700], height: 1),
          _buildDrawerItem(
            icon: Icons.account_circle_outlined,
            text: 'Manage Profile',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Manage Profile (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Settings',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Settings (TBD)");
            },
          ),
          Divider(color: Colors.grey[700], height: 1),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            iconColor: Colors.orangeAccent[100],
            textColor: Colors.orangeAccent[100],
            onTap: () {
              Navigator.of(context).pop(); 
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
    );
  }
}