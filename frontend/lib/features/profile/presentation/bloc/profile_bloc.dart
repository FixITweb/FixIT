import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repo;

  ProfileBloc(this.repo) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        // Use real API instead of mock data
        final profile = await repo.getProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError('Failed to load profile: ${e.toString()}'));
      }
    });
  }
}