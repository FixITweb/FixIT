import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/data/datasources/auth_api.dart';
import 'package:frontend/features/auth/data/models/auth_model.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(this.authModel) : super(AuthApi(ApiClient()));

  final AuthModel authModel;
  bool profileRequested = false;

  @override
  Future<AuthModel> login(String username, String password) async => authModel;

  @override
  Future<Map<String, dynamic>> getProfile() async {
    profileRequested = true;
    throw Exception('Profile endpoint unavailable');
  }
}

void main() {
  test('uses the role returned by login without fetching the profile',
      () async {
    final repository = _FakeAuthRepository(
      AuthModel(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        role: 'worker',
      ),
    );
    final bloc = AuthBloc(repository);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((state) => state.role, 'role', 'worker'),
      ]),
    );

    bloc.add(LoginEvent('worker', 'password'));
    await expectation;

    expect(repository.profileRequested, isFalse);
    await bloc.close();
  });
}
