// lib/features/services/domain/repositories/service_repository.dart
import '../../../../data/models/service_listing_model.dart'; // Adjust path

abstract class ServiceRepository {
  Future<ServiceListing> createService(Map<String, dynamic> serviceData);
  Future<Map<String, dynamic>> getArtisanServices(
    String artisanId, {
    int page = 1,
    int limit = 10,
    String? status,
  });
  // TODO: Add getServiceById, updateService, deleteService
}