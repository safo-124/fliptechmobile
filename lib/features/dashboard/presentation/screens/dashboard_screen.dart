// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Core & Service imports
import '../../../../core/api/api_client.dart';
import '../../../../services/category_service.dart';
import '../../../../services/image_upload_service.dart';

// Auth feature imports
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

// Product feature imports
import '../../../products/presentation/screens/my_products_screen.dart';
import '../../../products/presentation/screens/product_form_screen.dart';
import '../../../products/presentation/cubit/product_list_cubit.dart';
import '../../../products/presentation/cubit/product_form_cubit.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/data/datasources/product_remote_datasource.dart';

// Dashboard feature imports
import '../cubit/dashboard_cubit.dart';

// Shared Widgets
import '../../../../shared_widgets/app_drawer.dart';

// Example Icons
import 'package:flutter/cupertino.dart';

class ArtisanDashboardScreen extends StatelessWidget {
  const ArtisanDashboardScreen({super.key});

  void _showToast(String message, {Color backgroundColor = Colors.black87, Color textColor = Colors.white}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: 16.0);
  }

  // Helper widget for Stat Cards
  Widget _buildStatCard(BuildContext context, { // Added context here
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1.5,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 20),
                ],
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for Action Cards - Ensure signature is correct
  Widget _buildActionCard(
    BuildContext context, // Positional parameter first
    { // Named parameters follow
      required String title,
      required IconData icon,
      VoidCallback? onTap,
    }
  ) {
    return Card(
      elevation: 2.0,
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Theme.of(context).colorScheme.secondary),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                 maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductForm(BuildContext context) {
    final apiClient = ApiClient(); 
    final authRepository = context.read<AuthCubit>().authRepository; 
    final categoryRepository = CategoryServiceImpl(apiClient: apiClient);
    final imageUploadService = ImageUploadServiceImpl(); 
    final productRepository = ProductRepositoryImpl(
        remoteDataSource: ProductRemoteDataSourceImpl(apiClient: apiClient));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (newContext) => ProductFormCubit(
            categoryRepository: categoryRepository,
            imageUploadService: imageUploadService,
            productRepository: productRepository,
            authRepository: authRepository,
          ),
          child: const ProductFormScreen(),
        ),
      ),
    ).then((productCreatedSuccessfully) {
        if (productCreatedSuccessfully == true) {
            context.read<DashboardCubit>().loadDashboardData();
        }
    });
  }

  void _navigateToMyProducts(BuildContext context) {
    final apiClient = ApiClient();
    final authRepository = context.read<AuthCubit>().authRepository;
    final productRepository = ProductRepositoryImpl(
        remoteDataSource: ProductRemoteDataSourceImpl(apiClient: apiClient));

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
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String artisanDisplayName = "Artisan";
    if (authState is Authenticated) {
      artisanDisplayName = authState.user.name?.isNotEmpty == true 
                           ? authState.user.name! 
                           : authState.user.email; 
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: const AppDrawer(),
      backgroundColor: Colors.black,
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            _showToast(state.message, backgroundColor: Colors.redAccent[700]!);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<DashboardCubit>().loadDashboardData();
            },
            backgroundColor: Colors.grey[800],
            color: Theme.of(context).colorScheme.primary,
            child: ListView( 
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Welcome back, $artisanDisplayName!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  "Here's an overview of your artisan space.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                SizedBox(height: 20), 
          
                // Stats Section
                if (state is DashboardLoading || state is DashboardInitial)
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2, // Adjusted for potentially more card height
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(3, (index) => _buildStatCard(context, title: "Loading...", value: "...", icon: Icons.hourglass_empty_rounded)),
                  )
                else if (state is DashboardLoaded)
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2, 
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard(context, title: "Active Products", value: state.activeProductCount.toString(), icon: CupertinoIcons.cube_box_fill, onTap: () => _navigateToMyProducts(context)),
                      _buildStatCard(context, title: "Active Services", value: state.activeServiceCount.toString(), icon: CupertinoIcons.wrench_fill, onTap: () { _showToast("My Services (TBD)"); }),
                      _buildStatCard(context, title: "Training Offers", value: state.activeTrainingCount.toString(), icon: CupertinoIcons.book_fill, onTap: () { _showToast("My Training (TBD)"); }),
                    ],
                  )
                else if (state is DashboardError)
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 20.0),
                     child: Center(child: Text("Could not load dashboard stats. Pull to refresh.", style: TextStyle(color: Colors.orangeAccent))),
                   ),

                SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
          
                // Actions Section
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.15, 
                  children: [
                    // Calls to _buildActionCard are now correct
                    _buildActionCard(context, title: 'Add New Product', icon: Icons.add_shopping_cart, onTap: () => _navigateToProductForm(context)),
                    _buildActionCard(context, title: 'View My Listings', icon: Icons.inventory_2_outlined, onTap: () => _navigateToMyProducts(context)),
                    _buildActionCard(context, title: 'Manage Profile', icon: Icons.account_circle_outlined, onTap: () { _showToast('Navigate to Manage Profile (TBD)'); }),
                    _buildActionCard(context, title: 'View Orders', icon: Icons.receipt_long_outlined, onTap: () { _showToast('Navigate to View Orders (TBD)'); }),
                  ],
                ),
                SizedBox(height: 20), 
              ],
            ),
          );
        },
      ),
    );
  }
}