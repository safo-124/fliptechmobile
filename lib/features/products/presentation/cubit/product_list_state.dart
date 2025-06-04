// lib/features/products/presentation/cubit/product_list_state.dart
part of 'product_list_cubit.dart'; // For BLoC, ensures this is part of the cubit file

abstract class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object?> get props => []; // Added '?' to Object for null safety with props
}

class ProductListInitial extends ProductListState {}

class ProductListLoading extends ProductListState {
  // Optionally, carry previous products for a better UX while loading more
  final List<ProductListing> currentProducts;
  final bool isFirstFetch;

  const ProductListLoading({this.currentProducts = const [], this.isFirstFetch = false});

  @override
  List<Object?> get props => [currentProducts, isFirstFetch];
}

class ProductListLoaded extends ProductListState {
  final List<ProductListing> products;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax; // For pagination

  const ProductListLoaded({
    required this.products,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    this.hasReachedMax = false,
  });

  ProductListLoaded copyWith({
    List<ProductListing>? products,
    int? totalItems,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      totalItems: totalItems ?? this.totalItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [products, totalItems, currentPage, totalPages, hasReachedMax];
}

class ProductListError extends ProductListState {
  final String message;

  const ProductListError(this.message);

  @override
  List<Object?> get props => [message];
}