// lib/features/dashboard/presentation/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../../../../shared_widgets/app_drawer.dart'; // Adjust path if needed

import 'package:flutter/cupertino.dart'; // For CupertinoIcons

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

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2.0,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Slightly less rounding
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Keep padding reasonable
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // This is good if content fits
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12, // Further reduced title font
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22), // Further reduced icon
                ],
              ),
              // SizedBox(height: 4), // Reduced space, or let spaceBetween handle it
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Further reduced value font size
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

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
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
              SizedBox(height: 8), // Reduced space
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13, // Slightly reduced
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
              // _showToast("Refreshing dashboard..."); // Optional: Toast on refresh start
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
                    childAspectRatio: 2.2, // Increased height relative to width (width / height)
                                           // Smaller number = more height. Let's try 2.2 (was 1.9, then 2.0)
                                           // If cell width is ~160, height would be 160/2.2 = ~72px
                    crossAxisSpacing: 10, // Slightly reduced spacing
                    mainAxisSpacing: 10,  // Slightly reduced spacing
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(3, (index) => _buildStatCard(context, title: "Loading...", value: "...", icon: Icons.hourglass_empty_rounded)),
                  )
                else if (state is DashboardLoaded)
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2, // Consistent aspect ratio
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard(context, title: "Active Products", value: state.activeProductCount.toString(), icon: CupertinoIcons.cube_box_fill, onTap: () { _showToast("My Products (TBD)"); }),
                      _buildStatCard(context, title: "Active Services", value: state.activeServiceCount.toString(), icon: CupertinoIcons.wrench_fill, onTap: () { _showToast("My Services (TBD)"); }),
                      _buildStatCard(context, title: "Training Offers", value: state.activeTrainingCount.toString(), icon: CupertinoIcons.book_fill, onTap: () { _showToast("My Training (TBD)"); }),
                    ],
                  )
                else if (state is DashboardError)
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 20.0),
                     child: Center(child: Text("Could not load dashboard stats. Pull to refresh.", style: TextStyle(color: Colors.orangeAccent))),
                   ),

                SizedBox(height: 24), // Adjusted spacing
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18, // Slightly reduced
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12), // Reduced spacing
          
                // Actions Section
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10, // Slightly reduced
                  mainAxisSpacing: 10,  // Slightly reduced
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2, // Adjusted aspect ratio
                  children: [
                    _buildActionCard(context, title: 'Add New Product', icon: Icons.add_shopping_cart, onTap: () { _showToast('Navigate to Add Product (TBD)'); }),
                    _buildActionCard(context, title: 'View My Listings', icon: Icons.inventory_2_outlined, onTap: () { _showToast('Navigate to My Listings (TBD)'); }),
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