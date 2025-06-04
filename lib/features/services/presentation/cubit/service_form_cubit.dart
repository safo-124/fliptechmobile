// lib/features/services/presentation/cubit/service_form_cubit.dart
// No longer need 'dart:io' or 'image_picker' here if not used for anything else
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Adjust import paths
import '../../../../data/models/category_model.dart';
import '../../../../data/models/service_listing_model.dart';
import '../../../../services/category_service.dart';
// import '../../../../services/image_upload_service.dart'; // REMOVED ImageUploadService
import '../../domain/repositories/service_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

part 'service_form_state.dart';

class ServiceFormCubit extends Cubit<ServiceFormState> {
  final CategoryService categoryRepository;
  // final ImageUploadService imageUploadService; // REMOVED
  final ServiceRepository serviceRepository;
  final AuthRepository authRepository;

  // List<XFile> _selectedImages = []; // REMOVED

  ServiceFormCubit({
    required this.categoryRepository,
    // required this.imageUploadService, // REMOVED
    required this.serviceRepository,
    required this.authRepository,
  }) : super(ServiceFormInitial()) {
    fetchCategories();
  }

  // List<XFile> get selectedImages => _selectedImages; // REMOVED

  Future<void> fetchCategories() async {
    emit(ServiceFormLoadingCategories());
    try {
      final categories = await categoryRepository.getCategories(type: "SERVICE");
      emit(ServiceFormCategoriesLoaded(categories));
    } catch (e) {
      emit(ServiceFormError("Failed to load service categories: ${e.toString().replaceFirst("Exception: ", "")}"));
    }
  }

  // pickImages method REMOVED
  // removeImage method REMOVED

  List<Category>? _getCurrentCategories() {
    if (state is ServiceFormCategoriesLoaded) {
      return (state as ServiceFormCategoriesLoaded).categories;
    } else if (state is ServiceFormError && (state as ServiceFormError).categories != null) {
      return (state as ServiceFormError).categories;
    }
    return null;
  }

  Future<void> createService(Map<String, dynamic> serviceData) async {
    emit(ServiceFormSubmitting());
    try {
      final artisanId = await authRepository.getArtisanId();
      if (artisanId == null) {
        throw Exception("User not authenticated. Cannot create service.");
      }
      
      final Map<String, dynamic> completeServiceData = {
        ...serviceData,
        // 'artisanId': artisanId, // Backend should derive this from authenticated user
        'images': [], // Send an empty list for images
      };

      final newService = await serviceRepository.createService(completeServiceData);
      emit(ServiceFormSuccess(newService));
    } catch (e) {
      emit(ServiceFormError("Failed to create service: ${e.toString().replaceFirst("Exception: ", "")}", categories: _getCurrentCategories()));
    }
  }
}