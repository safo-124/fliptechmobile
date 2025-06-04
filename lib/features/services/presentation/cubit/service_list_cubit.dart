// lib/features/services/presentation/cubit/service_list_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/service_listing_model.dart'; // Adjust path
import '../../domain/repositories/service_repository.dart';   // Adjust path
import '../../../auth/domain/repositories/auth_repository.dart'; // To get artisanId

part 'service_list_state.dart';

class ServiceListCubit extends Cubit<ServiceListState> {
  final ServiceRepository serviceRepository;
  final AuthRepository authRepository;

  ServiceListCubit({required this.serviceRepository, required this.authRepository}) : super(ServiceListInitial());

  int _currentPage = 1;
  final int _limit = 10; // Services per page
  bool _isFetching = false;

  Future<void> fetchArtisanServices({bool isRefresh = false}) async {
    if (_isFetching && !isRefresh) return;

    _isFetching = true;
    if (isRefresh) {
      _currentPage = 1;
      emit(ServiceListLoading(isFirstFetch: true));
    } else if (state is ServiceListInitial) {
      emit(ServiceListLoading(isFirstFetch: true));
    } else if (state is ServiceListLoaded) {
      final currentState = state as ServiceListLoaded;
      emit(ServiceListLoading(currentServices: currentState.services));
    }
    
    try {
      final artisanId = await authRepository.getArtisanId();
      if (artisanId == null) {
        throw Exception("Artisan not authenticated. Cannot fetch services.");
      }

      final result = await serviceRepository.getArtisanServices(
        artisanId,
        page: _currentPage,
        limit: _limit,
        status: "ALL", // Fetch all statuses for the artisan's view
      );

      final List<ServiceListing> fetchedServices = result['services'];
      final int totalItems = result['totalItems'];
      final int totalPages = result['totalPages'];
      bool hasReachedMax = (_currentPage >= totalPages);

      if (isRefresh || _currentPage == 1) {
        emit(ServiceListLoaded(
          services: fetchedServices,
          totalItems: totalItems,
          currentPage: _currentPage,
          totalPages: totalPages,
          hasReachedMax: hasReachedMax,
        ));
      } else if (state is ServiceListLoaded || (state is ServiceListLoading && (state as ServiceListLoading).currentServices.isNotEmpty)) {
        List<ServiceListing> currentServices = (state is ServiceListLoaded) 
                                              ? (state as ServiceListLoaded).services 
                                              : (state as ServiceListLoading).currentServices;
        emit(ServiceListLoaded(
          services: List.from(currentServices)..addAll(fetchedServices),
          totalItems: totalItems,
          currentPage: _currentPage,
          totalPages: totalPages,
          hasReachedMax: hasReachedMax,
        ));
      } else {
         emit(ServiceListLoaded(
          services: fetchedServices,
          totalItems: totalItems,
          currentPage: _currentPage,
          totalPages: totalPages,
          hasReachedMax: hasReachedMax,
        ));
      }
      
      if (!hasReachedMax) {
        _currentPage++;
      }
    } catch (e) {
      emit(ServiceListError(e.toString().replaceFirst("Exception: ", "")));
    } finally {
      _isFetching = false;
    }
  }
  
  void refreshServiceList() {
    fetchArtisanServices(isRefresh: true);
  }

  void fetchNextPage() {
    if (state is ServiceListLoaded && !(state as ServiceListLoaded).hasReachedMax && !_isFetching) {
      fetchArtisanServices();
    }
  }
}