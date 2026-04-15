import '../models/profile_model.dart';
import '../datasources/profile_api.dart';

class ProfileRepository {
  final ProfileApi api;

  ProfileRepository(this.api);

  Future<ProfileModel> getProfile() async {
    final data = await api.fetchProfile();
    return ProfileModel.fromJson(data);
  }
}