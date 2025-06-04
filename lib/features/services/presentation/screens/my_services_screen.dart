// lib/features/services/presentation/screens/my_services_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Adjust paths
import '../cubit/service_list_cubit.dart';
import '../widgets/artisan_service_card.dart';
import '../../../../shared_widgets/service_card_skeleton.dart';
import 'service_form_screen.dart'; // For navigation to create new service
import '../cubit/service_form_cubit.dart';
import '../../../../core/api/api_client.dart';
import '../../../../services/category_service.dart';
import '../../../../services/image_upload_service.dart';
import '../../domain/repositories/service_repository.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceListCubit>().fetchArtisanServices(isRefresh: true);
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  void _navigateToServiceForm(BuildContext context) {
    // IMPORTANT: Replace with your actual dependency resolution strategy
    final apiClient = ApiClient(); 
    final authRepository = context.read<AuthCubit>().authRepository; 
    final categoryRepository = CategoryServiceImpl(apiClient: apiClient);
    final imageUploadService = ImageUploadServiceImpl(); 
    final serviceRepository = ServiceRepositoryImpl(
        remoteDataSource: ServiceRemoteDataSourceImpl(apiClient: apiClient));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (newContext) => ServiceFormCubit(
            categoryRepository: categoryRepository,
            
            serviceRepository: serviceRepository,
            authRepository: authRepository,
          ),
          child: const ServiceFormScreen(), // Navigate to create mode
        ),
      ),
    ).then((serviceCreatedSuccessfully) {
      if (serviceCreatedSuccessfully == true) {
        context.read<ServiceListCubit>().fetchArtisanServices(isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Service Listings'),
      ),
      backgroundColor: Colors.black,
      body: BlocConsumer<ServiceListCubit, ServiceListState>(
        listener: (context, state) {
          if (state is ServiceListError) {
            _showToast('Error: ${state.message}');
          }
        },
        builder: (context, state) {
          if (state is ServiceListLoading && state.isFirstFetch) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 5,
              itemBuilder: (context, index) => ServiceCardSkeleton(),
            );
          }
          if (state is ServiceListLoaded || (state is ServiceListLoading && state.currentServices.isNotEmpty)) {
            final services = (state is ServiceListLoaded) 
                              ? state.services 
                              : (state as ServiceListLoading).currentServices;

            if (services.isEmpty && state is! ServiceListLoading) {
              return Center(
                child: Column( /* ... Empty state UI ... */ 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.design_services_outlined, size: 80, color: Colors.grey[700]),
                    SizedBox(height: 16),
                    Text('No services listed yet.', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('List Your First Service'),
                      onPressed: () => _navigateToServiceForm(context),
                    )
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ServiceListCubit>().fetchArtisanServices(isRefresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: services.length, // TODO: Add +1 for load more indicator if not hasReachedMax
                itemBuilder: (context, index) {
                  // if (index >= services.length) { /* ... load more indicator ... */ }
                  final service = services[index];
                  return ArtisanServiceCard(service: service);
                },
              ),
            );
          }
          if (state is ServiceListError) { /* ... Error UI with Retry ... */ }
          return Center(child: Text("Loading services...", style: TextStyle(color: Colors.white)));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToServiceForm(context),
        label: Text('Add Service'),
        icon: Icon(Icons.add),
      ),
    );
  }
}