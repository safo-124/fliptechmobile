// lib/features/products/data/datasources/product_remote_datasource.dart
import 'dart:convert';
import '../../../../core/api/api_client.dart'; // Adjust path

abstract class ProductRemoteDataSource {
  Future<Map<String, dynamic>> getArtisanProducts(
    String artisanId, {
    int page = 1,
    int limit = 10,
    String? status,
  });

  /// Calls the POST /api/products endpoint.
  /// [productData] should include artisanId (from auth) and image URLs.
  /// Returns the JSON response of the created product from the API.
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData);

  // TODO: Add methods for getProductById, updateProduct, deleteProduct API calls
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getArtisanProducts(
    String artisanId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final queryParams = {
      'artisanId': artisanId,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    // Default to fetching "ALL" statuses for the artisan's own view,
    // or you can make "ACTIVE" the default and explicitly pass "ALL" if needed.
    if (status != null && status.isNotEmpty && status.toUpperCase() != "ALL") {
      queryParams['status'] = status.toUpperCase();
    } else {
       queryParams['status'] = "ALL"; // Fetch all statuses for this artisan
    }

    // This endpoint needs authentication
    final response = await apiClient.get('/products', queryParams: queryParams, requiresAuth: true);
    
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return responseData; // Expected: { products: [...], totalItems: ..., totalPages: ..., currentPage: ... }
    } else {
      throw Exception(responseData['error'] ?? 'Failed to fetch artisan products');
    }
  }

  @override
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    print('[ProductRemoteDataSource] Creating product with data: $productData');
    // This endpoint requires authentication (artisan token will be added by ApiClient)
    final response = await apiClient.post('/products', productData, requiresAuth: true);

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) { // 201 Created
      print('[ProductRemoteDataSource] Product created successfully: $responseData');
      return responseData; // This should be the created product object
    } else {
      print('[ProductRemoteDataSource] Failed to create product. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception(responseData['error'] ?? 'Failed to create product. Server error.');
    }
  }
}