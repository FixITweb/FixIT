import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());
      try {
        // Simulate API call delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Mock data - replace with actual API call
        emit(DashboardLoaded(
          totalEarnings: 2450.0,
          activeBookings: 8,
          completedJobs: 45,
          rating: 4.8,
        ));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });

    on<RefreshDashboard>((event, emit) async {
      if (state is DashboardLoaded) {
        emit(DashboardLoading());
        try {
          await Future.delayed(const Duration(milliseconds: 300));
          
          // Mock refreshed data
          emit(DashboardLoaded(
            totalEarnings: 2475.0, // Slightly updated
            activeBookings: 9,
            completedJobs: 45,
            rating: 4.8,
          ));
        } catch (e) {
          emit(DashboardError(e.toString()));
        }
      }
    });
  }
}