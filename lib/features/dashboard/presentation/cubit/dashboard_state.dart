part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int activeProductCount;
  final int activeServiceCount;
  final int activeTrainingCount;
  // Add more stats as needed

  const DashboardLoaded({
    required this.activeProductCount,
    required this.activeServiceCount,
    required this.activeTrainingCount,
  });

  @override
  List<Object> get props => [activeProductCount, activeServiceCount, activeTrainingCount];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}