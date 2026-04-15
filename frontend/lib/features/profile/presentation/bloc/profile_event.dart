import '../../data/models/profile_model.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;
  UpdateProfile(this.profile);
}