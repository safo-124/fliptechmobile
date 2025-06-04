import 'dart:io'; // For File type if needed for uploads
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart'; // For image picking

// Adjust import paths as per your project structure
import '../../../../data/models/category_model.dart';
import '../../../../data/models/product_listing_model.dart';
import '../../../../services/category_service.dart'; // Assuming CategoryService fetches categories
import '../../../../services/image_upload_service.dart'; // For uploading images
import '../../domain/repositories/product_repository.dart'; // For creating product
import '../../../auth/domain/repositories/auth_repository.dart'; // To get artisanId


part 'product_form_state.dart';

class ProductFormCubit extends Cubit<ProductFormState> {
  final CategoryService categoryRepository; // Or a dedicated CategoryRepository
  final ImageUploadService imageUploadService;
  final ProductRepository productRepository;
  final AuthRepository authRepository;

  List<XFile> _selectedImages = []; // Internal list to hold picked images

  ProductFormCubit({
    required this.categoryRepository,
    required this.imageUploadService,
    required this.productRepository,
    required this.authRepository,
  }) : super(ProductFormInitial()) {
    fetchCategories();
  }

  List<XFile> get selectedImages => _selectedImages;

  Future<void> fetchCategories() async {
    emit(ProductFormLoadingCategories());
    try {
      // Assuming CategoryService returns List<Category>
      // And filters by type 'PRODUCT'
      final categories = await categoryRepository.getCategories(type: "PRODUCT");
      emit(ProductFormCategoriesLoaded(categories));
    } catch (e) {
      emit(ProductFormError("Failed to load categories: ${e.toString()}"));
    }
  }

  Future<void> pickImages({ImageSource source = ImageSource.gallery, bool multiple = true}) async {
    emit(ProductFormImagePicking());
    try {
      final ImagePicker picker = ImagePicker();
      if (multiple) {
        final List<XFile> pickedFiles = await picker.pickMultiImage(imageQuality: 70);
        if (pickedFiles.isNotEmpty) {
          _selectedImages.addAll(pickedFiles);
        }
      } else {
        final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 70);
        if (pickedFile != null) {
          _selectedImages.add(pickedFile);
        }
      }
      // Limit number of images if needed
      // _selectedImages = _selectedImages.take(5).toList(); 
      emit(ProductFormImagesSelected(List.from(_selectedImages))); // Emit a new list instance
    } catch (e) {
      emit(ProductFormError("Failed to pick images: ${e.toString()}", categories: _getCurrentCategories()));
    }
  }

  void removeImage(XFile image) {
    _selectedImages.remove(image);
    emit(ProductFormImagesSelected(List.from(_selectedImages)));
  }

  List<Category>? _getCurrentCategories() {
    if (state is ProductFormCategoriesLoaded) {
      return (state as ProductFormCategoriesLoaded).categories;
    } else if (state is ProductFormError && (state as ProductFormError).categories != null) {
      return (state as ProductFormError).categories;
    }
    return null;
  }

  Future<void> createProduct(Map<String, dynamic> productData) async {
    emit(ProductFormSubmitting());
    try {
      final artisanId = await authRepository.getArtisanId();
      if (artisanId == null) {
        throw Exception("User not authenticated. Cannot create product.");
      }

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        // Upload images and get URLs
        // This is a simplified loop; consider parallel uploads or progress tracking for many images
        for (XFile imageFile in _selectedImages) {
          // The ImageUploadService should return the URL of the uploaded image
          final imageUrl = await imageUploadService.uploadImage(File(imageFile.path), 'products/${artisanId}');
          imageUrls.add(imageUrl);
        }
      }
      
      final Map<String, dynamic> completeProductData = {
        ...productData,
        'artisanId': artisanId, // Crucial: Add authenticated artisan's ID
        'images': imageUrls, // Add uploaded image URLs
        // Ensure materials are sent as an array if needed by backend:
        // 'materials': (productData['materials'] as String?)?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? [],
      };

      // Assuming productRepository has a createProduct method
      // This method should align with what the backend expects
      final newProduct = await productRepository.createProduct(completeProductData);
      emit(ProductFormSuccess(newProduct));
      _selectedImages.clear(); // Clear selected images after successful submission
    } catch (e) {
      emit(ProductFormError("Failed to create product: ${e.toString()}", categories: _getCurrentCategories()));
    }
  }
}