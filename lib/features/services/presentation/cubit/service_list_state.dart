// lib/features/services/presentation/cubit/service_list_state.dart
part of 'service_list_cubit.dart';

abstract class ServiceListState extends Equatable {
  const ServiceListState();
  @override
  List<Object?> get props => [];
}

class ServiceListInitial extends ServiceListState {}

class ServiceListLoading extends ServiceListState {
  final List<ServiceListing> currentServices;
  final bool isFirstFetch;
  const ServiceListLoading({this.currentServices = const [], this.isFirstFetch = false});
  @override
  List<Object?> get props => [currentServices, isFirstFetch];
}

class ServiceListLoaded extends ServiceListState {
  final List<ServiceListing> services;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  const ServiceListLoaded({
    required this.services,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    this.hasReachedMax = false,
  });
  @override
  List<Object?> get props => [services, totalItems, currentPage, totalPages, hasReachedMax];
}

class ServiceListError extends ServiceListState {
  final String message;
  const ServiceListError(this.message);
  @override
  List<Object?> get props => [message];
}