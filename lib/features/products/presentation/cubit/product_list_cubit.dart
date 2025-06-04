// lib/features/products/presentation/cubit/product_list_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Adjust import paths as per your project structure
import '../../../../data/models/product_listing_model.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart'; // To get artisanId

part 'product_list_state.dart'; // Contains ProductListState definitions

class ProductListCubit extends Cubit<ProductListState> {
  final ProductRepository productRepository;
  final AuthRepository authRepository; // To get current artisan's ID

  ProductListCubit({
    required this.productRepository,
    required this.authRepository,
  }) : super(ProductListInitial());

  // Variables for pagination
  int _currentPage = 1;
  final int _limit = 10; // Products per page
  bool _isFetching = false; // To prevent multiple simultaneous fetches

  Future<void> fetchArtisanProducts({bool isRefresh = false}) async {
    if (_isFetching && !isRefresh) return; // Prevent concurrent fetches unless it's a refresh

    _isFetching = true;
    if (isRefresh) {
      _currentPage = 1; // Reset page for refresh
      emit(ProductListLoading(isFirstFetch: true));
    } else if (state is ProductListInitial) {
      emit(ProductListLoading(isFirstFetch: true));
    } else if (state is ProductListLoaded) {
      // If loading more, emit loading but keep current products for better UX
      final currentState = state as ProductListLoaded;
      emit(ProductListLoading(currentProducts: currentState.products));
    }


    try {
      final artisanId = await authRepository.getArtisanId();
      if (artisanId == null) {
        throw Exception("Artisan not authenticated. Cannot fetch products.");
      }

      final result = await productRepository.getArtisanProducts(
        artisanId,
        page: _currentPage,
        limit: _limit,
        status: "ALL", // Fetch all statuses (DRAFT, ACTIVE, INACTIVE etc.) for artisan's view
      );

      final List<ProductListing> fetchedProducts = result['products'];
      final int totalItems = result['totalItems'];
      final int totalPages = result['totalPages'];

      bool hasReachedMax = (_currentPage >= totalPages);

      if (isRefresh || _currentPage == 1) {
        // If it's a refresh or the first page load
        emit(ProductListLoaded(
          products: fetchedProducts,
          totalItems: totalItems,
          currentPage: _currentPage,
          totalPages: totalPages,
          hasReachedMax: hasReachedMax,
        ));
      } else if (state is ProductListLoaded || (state is ProductListLoading && (state as ProductListLoading).currentProducts.isNotEmpty)) {
        // Append new products if loading more pages
        List<ProductListing> currentProducts = (state is ProductListLoaded) 
                                                ? (state as ProductListLoaded).products 
                                                : (state as ProductListLoading).currentProducts;
        
        emit(ProductListLoaded(
          products: List.from(currentProducts)..addAll(fetchedProducts),
          totalItems: totalItems,
          currentPage: _currentPage,
          totalPages: totalPages,
          hasReachedMax: hasReachedMax,
        ));
      } else {
         // Fallback for unexpected previous state, treat as first load
         emit(ProductListLoaded(
          products: fetchedProducts,
          totalItems: totalItems,
          currentPage: _currentPage,
          totalPages: totalPages,
          hasReachedMax: hasReachedMax,
        ));
      }
      
      if (!hasReachedMax) {
        _currentPage++; // Increment page for next fetch if more items are available
      }

    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      print('[ProductListCubit] Error fetching products: $errorMessage');
      emit(ProductListError(errorMessage));
    } finally {
      _isFetching = false;
    }
  }

  // Call this method when a product is successfully created, updated, or deleted
  // to refresh the list from the first page.
  void refreshProductList() {
    fetchArtisanProducts(isRefresh: true);
  }

  // Call this method to fetch the next page of products (for infinite scrolling or a "Load More" button)
  void fetchNextPage() {
    if (state is ProductListLoaded && !(state as ProductListLoaded).hasReachedMax && !_isFetching) {
      fetchArtisanProducts();
    }
  }
}