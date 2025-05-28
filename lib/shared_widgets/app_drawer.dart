// lib/shared_widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Using fluttertoast

// Assuming AuthCubit and its states (including Authenticated with User model) are here:
import '../features/auth/presentation/cubit/auth_cubit.dart'; // Adjust path as needed

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
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state; // Listen to AuthCubit state
    String artisanName = "Artisan User";
    String artisanEmail = "artisan@example.com"; // Placeholder

    if (authState is Authenticated) {
      artisanName = authState.user.name ?? "Artisan"; // Use null-aware operator
      artisanEmail = authState.user.email;
    }

    return Drawer(
      backgroundColor: Colors.grey[900], // Dark background for the drawer
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
              color: Colors.black54, // Slightly different header background
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            text: 'Dashboard',
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              // If already on dashboard, do nothing. 
              // You might want to use named routes and check current route.
              // For now, just pop. If dashboard is home, it's fine.
            },
          ),
          _buildDrawerItem(
            icon: Icons.inventory_2_outlined,
            text: 'My Products',
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Navigate to My Products Screen
              _showToast("Navigate to My Products (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.build_circle_outlined,
            text: 'My Services',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Navigate to My Services (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.school_outlined,
            text: 'My Training Offers',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Navigate to My Training (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.receipt_long_outlined,
            text: 'Orders & Bookings',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Navigate to Orders (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.message_outlined,
            text: 'Messages',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Navigate to Messages (TBD)");
            },
          ),
          Divider(color: Colors.grey[700]),
          _buildDrawerItem(
            icon: Icons.account_circle_outlined,
            text: 'Manage Profile',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Navigate to Manage Profile (TBD)");
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            text: 'Settings',
            onTap: () {
              Navigator.of(context).pop();
              _showToast("Navigate to Settings (TBD)");
            },
          ),
          Divider(color: Colors.grey[700]),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Logout',
            iconColor: Colors.orangeAccent[100], // Different color for logout icon
            textColor: Colors.orangeAccent[100], // Different color for logout text
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer first
              context.read<AuthCubit>().logout();
              // AuthWrapper in app.dart should handle navigation to LoginScreen
            },
          ),
        ],
      ),
    );
  }
}