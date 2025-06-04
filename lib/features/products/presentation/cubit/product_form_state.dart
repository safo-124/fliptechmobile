part of 'product_form_cubit.dart';

abstract class ProductFormState extends Equatable {
  const ProductFormState();

  @override
  List<Object?> get props => [];
}

class ProductFormInitial extends ProductFormState {}

class ProductFormLoadingCategories extends ProductFormState {}

class ProductFormCategoriesLoaded extends ProductFormState {
  final List<Category> categories; // Assuming Category model from lib/data/models/category_model.dart
  const ProductFormCategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class ProductFormImagePicking extends ProductFormState {}
class ProductFormImagesSelected extends ProductFormState {
  final List<XFile> images; // From image_picker
  const ProductFormImagesSelected(this.images);
  @override
  List<Object?> get props => [images];
}

class ProductFormSubmitting extends ProductFormState {}

class ProductFormSuccess extends ProductFormState {
  final ProductListing product; // The newly created product
  const ProductFormSuccess(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductFormError extends ProductFormState {
  final String message;
  final List<Category>? categories; // Optionally carry over categories if loaded

  const ProductFormError(this.message, {this.categories});

  @override
  List<Object?> get props => [message, categories];
}