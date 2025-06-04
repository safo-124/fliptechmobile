// lib/features/products/domain/repositories/product_repository.dart
import '../../../../data/models/product_listing_model.dart'; // Adjust path as needed

abstract class ProductRepository {
  /// Fetches products for a specific artisan, with pagination and status filter.
  /// Returns a map containing 'products' (List<ProductListing>) and pagination data.
  Future<Map<String, dynamic>> getArtisanProducts(
    String artisanId, {
    int page = 1,
    int limit = 10,
    String? status, // e.g., "ALL", "ACTIVE", "DRAFT"
  });

  /// Creates a new product listing.
  /// [productData] is a map containing all necessary product details,
  /// including artisanId and an array of image URLs.
  /// Returns the created [ProductListing].
  Future<ProductListing> createProduct(Map<String, dynamic> productData);

  // TODO: Define methods for:
  // Future<ProductListing?> getProductById(String productId);
  // Future<ProductListing> updateProduct(String productId, Map<String, dynamic> productUpdateData);
  // Future<void> deleteProduct(String productId);
}