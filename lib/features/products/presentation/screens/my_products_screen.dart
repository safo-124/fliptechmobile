// lib/features/products/presentation/screens/my_products_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ----- NECESSARY IMPORTS -----
import '../cubit/product_list_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart'; // <-- ADD THIS IMPORT FOR AuthCubit
import '../../../auth/domain/repositories/auth_repository.dart'; // For AuthRepository type
// For ProductFormScreen and its Cubit (if navigating from here)
import 'product_form_screen.dart';
import '../cubit/product_form_cubit.dart';
// Models
import '../../../../data/models/product_listing_model.dart';
// Skeletons and Widgets
import '../../../../shared_widgets/product_card_skeleton.dart';
import '../widgets/artisan_product_card.dart';
// Services and Repos for providing to ProductFormCubit (example instantiation)
import '../../../../core/api/api_client.dart';
import '../../../../services/category_service.dart';
import '../../../../services/image_upload_service.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/datasources/product_remote_datasource.dart';


class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the screen loads
    // Ensure ProductListCubit is already provided if using context.read here directly,
    // or fetch within BlocProvider.create if setting it up for this screen specifically.
    // If BlocProvider is in this widget's build method or above, this is fine.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListCubit>().fetchArtisanProducts();
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.BOTTOM);
  }

  void _navigateToProductForm(BuildContext context) {
    // --- Dependency Resolution for ProductFormCubit ---
    // Option 1: Access globally provided repositories (Ideal)
    // final authRepository = context.read<AuthRepository>();
    // final categoryRepository = context.read<CategoryService>();
    // final imageUploadService = context.read<ImageUploadService>();
    // final productRepository = context.read<ProductRepository>();

    // Option 2: Example of direct instantiation (for now, if DI isn't fully set up)
    // Be cautious with creating new ApiClient instances like this in a real app.
    final apiClient = ApiClient(); 
    // Access AuthRepository from the already provided AuthCubit
    final authRepository = context.read<AuthCubit>().authRepository; 
    final categoryRepository = CategoryServiceImpl(apiClient: apiClient); // Use your actual implementation
    final imageUploadService = ImageUploadServiceImpl(); // This is a placeholder, needs real implementation
    final productRemoteDataSource = ProductRemoteDataSourceImpl(apiClient: apiClient);
    final productRepository = ProductRepositoryImpl(remoteDataSource: productRemoteDataSource);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (newContext) => ProductFormCubit(
            categoryRepository: categoryRepository,
            imageUploadService: imageUploadService,
            productRepository: productRepository,
            authRepository: authRepository,
          ),
          child: const ProductFormScreen(), // Navigate to create mode
        ),
      ),
    ).then((productCreatedSuccessfully) {
      if (productCreatedSuccessfully == true) {
        context.read<ProductListCubit>().fetchArtisanProducts(isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Product Listings'),
        // actions: [ // Optional: Add refresh button here too
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     onPressed: () => context.read<ProductListCubit>().fetchArtisanProducts(isRefresh: true),
        //   ),
        // ],
      ),
      backgroundColor: Colors.black,
      body: BlocConsumer<ProductListCubit, ProductListState>(
        listener: (context, state) {
          if (state is ProductListError) {
            _showToast('Error: ${state.message}');
          }
        },
        builder: (context, state) {
          // Show skeletons if it's the very first load or if refreshing the whole list
          if (state is ProductListLoading && state.isFirstFetch) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 5, // Number of skeleton items to show
              itemBuilder: (context, index) => ProductCardSkeleton(),
            );
          }

          // Handle loaded state (and loading more pages while showing existing data)
          if (state is ProductListLoaded || (state is ProductListLoading && state.currentProducts.isNotEmpty)) {
            final products = (state is ProductListLoaded) 
                              ? state.products 
                              : (state as ProductListLoading).currentProducts; // <-- CORRECTED to currentProducts

            if (products.isEmpty) { // This covers the case after loading if products list is empty
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[700]),
                    SizedBox(height: 16),
                    Text(
                      'No products listed yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('List Your First Product'),
                      onPressed: () => _navigateToProductForm(context),
                    )
                  ],
                ),
              );
            }
            // TODO: Implement pull-to-refresh and load-more for pagination
            return RefreshIndicator(
              onRefresh: () => context.read<ProductListCubit>().fetchArtisanProducts(isRefresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: products.length + ((state is ProductListLoaded && !state.hasReachedMax) ? 1 : 0), // +1 for load more indicator
                itemBuilder: (context, index) {
                  if (index >= products.length) {
                    // Optional: Load more indicator or button
                    // context.read<ProductListCubit>().fetchNextPage(); // Could auto-trigger here
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ));
                  }
                  final product = products[index];
                  return ArtisanProductCard(product: product);
                },
              ),
            );
          }
          
          // Handle error state specifically if it's not already covered or if products couldn't be shown
          if (state is ProductListError) {
             return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Failed to load products: ${state.message}', style: TextStyle(color: Colors.redAccent)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => context.read<ProductListCubit>().fetchArtisanProducts(isRefresh: true),
                        child: Text("Retry")
                      )
                    ],
                  )
                )
             );
          }

          // Fallback for ProductListInitial or other unhandled states (though ProductListLoading should cover initial)
          return Center(child: Text("Loading products...", style: TextStyle(color: Colors.white)));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToProductForm(context),
        label: Text('Add Product'),
        icon: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
      ),
    );
  }
}