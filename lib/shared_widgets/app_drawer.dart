// lib/shared_widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Adjust import paths based on your actual file structure
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/products/presentation/screens/my_products_screen.dart';
import '../features/products/presentation/cubit/product_list_cubit.dart';
import '../features/products/domain/repositories/product_repository.dart';
import '../features/products/data/repositories/product_repository_impl.dart';
import '../features/products/data/datasources/product_remote_datasource.dart';
import '../features/services/presentation/screens/my_services_screen.dart';
import '../features/services/presentation/cubit/service_list_cubit.dart';
import '../features/services/domain/repositories/service_repository.dart';
import '../features/services/data/repositories/service_repository_impl.dart';
import '../features/services/data/datasources/service_remote_datasource.dart';
import '../core/api/api_client.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.85),
        textColor: Colors.white,
        fontSize: 15.0);
  }

  Widget _buildDrawerHeader(BuildContext context, String name, String email) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.0,
        bottom: 20.0,
        left: 20.0,
        right: 20.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "A",
              style: TextStyle(fontSize: 30.0, color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            email,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Corrected _buildDrawerItem to accept iconColor and textColor
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    bool isSelected = false,
    Color? iconColor, // Added back
    Color? textColor, // Added back
  }) {
    final theme = Theme.of(context);
    final Color selectedColor = theme.colorScheme.primary; 
    
    // Use passed-in colors if provided, otherwise use defaults based on selection state
    final Color effectiveIconColor = iconColor ?? (isSelected ? selectedColor : Colors.grey[400]!);
    final Color effectiveTextColor = textColor ?? (isSelected ? selectedColor : Colors.grey[200]!);

    return Material(
      color: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: effectiveIconColor, size: 22),
        title: Text(
          text,
          style: TextStyle(
            color: effectiveTextColor, 
            fontSize: 15.5, 
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal
          ),
        ),
        onTap: onTap,
        dense: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String artisanName = "Artisan";
    String artisanEmail = "artisan@example.com";

    if (authState is Authenticated) {
      artisanName = authState.user.name?.isNotEmpty == true ? authState.user.name! : "Artisan";
      artisanEmail = authState.user.email;
    }

    return Drawer(
      backgroundColor: Colors.grey[900], 
      child: Column(
        children: [
          _buildDrawerHeader(context, artisanName, artisanEmail),
          Divider(color: Colors.grey[800], height: 1, thickness: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              children: <Widget>[
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  text: 'Dashboard',
                  onTap: () {
                    Navigator.of(context).pop();
                    // Add navigation logic if not already on dashboard
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.storefront_rounded,
                  text: 'My Products',
                  onTap: () {
                    Navigator.of(context).pop();
                    final apiClient = ApiClient(); 
                    final authRepository = context.read<AuthCubit>().authRepository;
                    final productRepository = ProductRepositoryImpl(
                        remoteDataSource: ProductRemoteDataSourceImpl(apiClient: apiClient)
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => ProductListCubit(
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
                  context: context,
                  icon: Icons.construction_rounded,
                  text: 'My Services',
                  onTap: () {
                    Navigator.of(context).pop();
                    final apiClient = ApiClient();
                    final authRepository = context.read<AuthCubit>().authRepository;
                    final serviceRepository = ServiceRepositoryImpl(
                        remoteDataSource: ServiceRemoteDataSourceImpl(apiClient: apiClient)
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => ServiceListCubit(
                            serviceRepository: serviceRepository,
                            authRepository: authRepository,
                          ),
                          child: const MyServicesScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.school_rounded,
                  text: 'My Training Offers',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showToast("My Training Offers (TBD)");
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.receipt_long_rounded,
                  text: 'Orders & Bookings',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showToast("Orders & Bookings (TBD)");
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.chat_bubble_outline_rounded,
                  text: 'Messages',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showToast("Messages (TBD)");
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Divider(color: Colors.grey[800], height: 1, thickness: 1),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.account_circle_rounded,
                  text: 'Manage Profile',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showToast("Manage Profile (TBD)");
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  text: 'Settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    _showToast("Settings (TBD)");
                  },
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1.0))
            ),
            child: _buildDrawerItem( // This call site was causing the error
              context: context,
              icon: Icons.exit_to_app_rounded,
              text: 'Logout',
              iconColor: Colors.orangeAccent[200], // Now valid
              textColor: Colors.orangeAccent[200], // Now valid
              onTap: () {
                Navigator.of(context).pop(); 
                context.read<AuthCubit>().logout();
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}