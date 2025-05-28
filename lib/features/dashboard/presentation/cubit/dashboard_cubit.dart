import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// Import your product/service/training repositories or services later
// import '../../../products/domain/repositories/product_repository.dart'; 
// import '../../../../services/auth_service.dart'; // To get artisanId

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  // final ProductRepository productRepository; // Example
  // final AuthService authService; // Example
  
  DashboardCubit(/*{required this.productRepository, required this.authService}*/) : super(DashboardInitial()) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      // TODO: Fetch actual data using repositories/services
      // For now, using placeholder data after a simulated delay
      // final artisanId = await authService.getArtisanId();
      // if (artisanId == null) throw Exception("Artisan not authenticated");

      // final productCount = await productRepository.getActiveProductCount(artisanId);
      // final serviceCount = ...
      // final trainingCount = ...
      
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network call

      emit(const DashboardLoaded(
        activeProductCount: 0, // Replace with actual fetched data
        activeServiceCount: 0,
        activeTrainingCount: 0,
      ));
    } catch (e) {
      emit(DashboardError(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}