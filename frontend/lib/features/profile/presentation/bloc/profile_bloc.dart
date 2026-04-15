import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repo;

  ProfileBloc(this.repo) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        // For demo purposes, use mock profile data
        await Future.delayed(const Duration(milliseconds: 500));
        
        final mockProfile = ProfileModel(
          id: 1,
          username: 'john_doe',
          role: 'customer',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        
        emit(ProfileLoaded(mockProfile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}