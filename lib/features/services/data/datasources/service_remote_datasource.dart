// lib/features/services/data/datasources/service_remote_datasource.dart
import 'dart:convert';
import '../../../../core/api/api_client.dart'; // Adjust path as needed

abstract class ServiceRemoteDataSource {
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData);
  
  Future<Map<String, dynamic>> getArtisanServices(
    String artisanId, {
    int page = 1,
    int limit = 10,
    String? status, // e.g., "ALL", "ACTIVE", "DRAFT"
  });
  // TODO: Add methods for getServiceById, updateService, deleteService
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiClient apiClient;

  ServiceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData) async {
    // ... (createService implementation as before)
    final response = await apiClient.post('/services', serviceData, requiresAuth: true);
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return responseData;
    } else {
      throw Exception(responseData['error'] ?? 'Failed to create service');
    }
  }

  @override
  Future<Map<String, dynamic>> getArtisanServices(
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
    if (status != null && status.isNotEmpty && status.toUpperCase() != "ALL") {
      queryParams['status'] = status.toUpperCase();
    } else {
      queryParams['status'] = "ALL"; // Fetch all statuses for the artisan's own view by default
    }

    // This endpoint likely needs authentication
    final response = await apiClient.get('/services', queryParams: queryParams, requiresAuth: true);
    
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // Backend API should return { services: [...], totalItems: ..., totalPages: ..., currentPage: ... }
      return responseData; 
    } else {
      throw Exception(responseData['error'] ?? 'Failed to fetch artisan services');
    }
  }
}