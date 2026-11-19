import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/customer/create_request/data/datasources/job_request_api.dart';
import 'package:frontend/features/customer/create_request/data/repositories/job_request_repository.dart';
import 'package:frontend/features/customer/create_request/presentation/bloc/create_request_bloc.dart';
import 'package:frontend/features/customer/create_request/presentation/bloc/create_request_event.dart';
import 'package:frontend/features/customer/create_request/presentation/bloc/create_request_state.dart';
import 'package:frontend/features/services/data/datasources/services_api.dart';
import 'package:frontend/features/services/data/repositories/services_repository.dart';

class _FakeServiceRepository extends ServiceRepository {
  _FakeServiceRepository(this.loadCategories) : super(ServiceApi(ApiClient()));

  final Future<List<String>> Function() loadCategories;

  @override
  Future<List<String>> getCategories() => loadCategories();
}

CreateRequestBloc _createBloc(Future<List<String>> Function() loadCategories) {
  return CreateRequestBloc(
    repository: JobRequestRepository(JobRequestApi(ApiClient())),
    serviceRepository: _FakeServiceRepository(loadCategories),
  );
}

void main() {
  test('uses standard categories when the server returns an empty list',
      () async {
    final bloc = _createBloc(() async => []);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CategoriesLoading>(),
        isA<CategoriesLoaded>().having(
          (state) => state.categories,
          'categories',
          defaultJobRequestCategories,
        ),
      ]),
    );

    bloc.add(LoadCategories());
    await expectation;
    await bloc.close();
  });

  test('reports category load failures', () async {
    final bloc =
        _createBloc(() async => throw Exception('network unavailable'));
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<CategoriesLoading>(),
        isA<CategoriesLoadFailed>().having(
          (state) => state.message,
          'message',
          contains('network unavailable'),
        ),
      ]),
    );

    bloc.add(LoadCategories());
    await expectation;
    await bloc.close();
  });
}
