// lib/features/services/presentation/cubit/service_form_state.dart
part of 'service_form_cubit.dart';

abstract class ServiceFormState extends Equatable {
  const ServiceFormState();
  @override
  List<Object?> get props => [];
}

class ServiceFormInitial extends ServiceFormState {}

class ServiceFormLoadingCategories extends ServiceFormState {}

class ServiceFormCategoriesLoaded extends ServiceFormState {
  final List<Category> categories; // Assuming Category model from lib/data/models/category_model.dart
  const ServiceFormCategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

// Removed ServiceFormImagePicking and ServiceFormImagesSelected states

class ServiceFormSubmitting extends ServiceFormState {}

class ServiceFormSuccess extends ServiceFormState {
  final ServiceListing service; // The newly created service
  const ServiceFormSuccess(this.service);
  @override
  List<Object?> get props => [service];
}

class ServiceFormError extends ServiceFormState {
  final String message;
  final List<Category>? categories; // Optionally carry over categories if loaded

  const ServiceFormError(this.message, {this.categories});

  @override
  List<Object?> get props => [message, categories];
}