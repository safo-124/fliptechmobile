// lib/features/products/data/repositories/product_repository_impl.dart
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart'; // You'll create this
import '../../../../data/models/product_listing_model.dart'; // Adjust path

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> getArtisanProducts(
    String artisanId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getArtisanProducts(
        artisanId,
        page: page,
        limit: limit,
        status: status,
      );
      // Assuming result from datasource is Map<String, dynamic> with 'products' list and pagination info
      final productsJson = result['products'] as List<dynamic>? ?? [];
      final products = productsJson.map((json) => ProductListing.fromJson(json)).toList();
      
      return {
        'products': products,
        'totalItems': result['totalItems'] as int? ?? 0,
        'totalPages': result['totalPages'] as int? ?? 0,
        'currentPage': result['currentPage'] as int? ?? 1,
      };
    } catch (e) {
      print('[ProductRepositoryImpl] Error fetching artisan products: ${e.toString()}');
      // Rethrow a more domain-specific error or handle as needed
      rethrow; 
    }
  }

  @override
  Future<ProductListing> createProduct(Map<String, dynamic> productData) async {
    try {
      // The remoteDataSource's createProduct method will handle the API call
      // and should return the JSON of the created product.
      final productJson = await remoteDataSource.createProduct(productData);
      return ProductListing.fromJson(productJson);
    } catch (e) {
      print('[ProductRepositoryImpl] Error creating product: ${e.toString()}');
      rethrow;
    }
  }

  // Implement other methods (getProductById, updateProduct, deleteProduct) here later
}