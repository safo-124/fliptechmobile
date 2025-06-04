// lib/features/services/data/repositories/service_repository_impl.dart
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_datasource.dart';
import '../../../../data/models/service_listing_model.dart'; // Adjust path

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ServiceListing> createService(Map<String, dynamic> serviceData) async {
    // ... (createService implementation as before)
    final serviceJson = await remoteDataSource.createService(serviceData);
    return ServiceListing.fromJson(serviceJson);
  }

  @override
  Future<Map<String, dynamic>> getArtisanServices(
    String artisanId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final result = await remoteDataSource.getArtisanServices(
      artisanId,
      page: page,
      limit: limit,
      status: status,
    );
    final servicesJson = result['services'] as List<dynamic>? ?? []; // Key should match API response
    final services = servicesJson.map((json) => ServiceListing.fromJson(json)).toList();

    return {
      'services': services, // Key for the list of services
      'totalItems': result['totalItems'] as int? ?? 0,
      'totalPages': result['totalPages'] as int? ?? 0,
      'currentPage': result['currentPage'] as int? ?? 1,
    };
  }
  // Implement other methods
}