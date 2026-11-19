import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/services/data/datasources/services_api.dart';
import 'package:frontend/features/services/data/models/service_model.dart';
import 'package:frontend/features/services/data/repositories/services_repository.dart';
import 'package:frontend/features/worker/services/presentation/bloc/worker_services_bloc.dart';
import 'package:frontend/features/worker/services/presentation/bloc/worker_services_event.dart';
import 'package:frontend/features/worker/services/presentation/bloc/worker_services_state.dart';

class _FakeServiceRepository extends ServiceRepository {
  _FakeServiceRepository() : super(ServiceApi(ApiClient()));

  double? latitude;
  double? longitude;

  @override
  Future<void> createService({
    required String title,
    required String description,
    required String category,
    required double price,
    required double latitude,
    required double longitude,
  }) async {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  @override
  Future<void> updateService({
    required int id,
    required String title,
    required String description,
    required String category,
    required double price,
    required double latitude,
    required double longitude,
  }) async {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  @override
  Future<List<ServiceModel>> getMyServices() async => [];
}

void main() {
  test('forwards the selected location when adding a service', () async {
    final repository = _FakeServiceRepository();
    final bloc = WorkerServicesBloc(repository);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<WorkerServicesLoading>(),
        isA<WorkerServiceAdded>(),
        isA<WorkerServicesLoaded>(),
      ]),
    );

    bloc.add(
      AddWorkerService(
        title: 'Repair',
        category: 'Other',
        price: 20,
        description: 'Repairs',
        latitude: 9.02,
        longitude: 38.75,
      ),
    );
    await expectation;

    expect(repository.latitude, 9.02);
    expect(repository.longitude, 38.75);
    await bloc.close();
  });

  test('forwards the selected location when updating a service', () async {
    final repository = _FakeServiceRepository();
    final bloc = WorkerServicesBloc(repository);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<WorkerServicesLoading>(),
        isA<WorkerServiceUpdated>(),
        isA<WorkerServicesLoaded>(),
      ]),
    );

    bloc.add(
      UpdateWorkerService(
        id: 1,
        title: 'Repair',
        category: 'Other',
        price: 20,
        description: 'Repairs',
        latitude: 9.02,
        longitude: 38.75,
      ),
    );
    await expectation;

    expect(repository.latitude, 9.02);
    expect(repository.longitude, 38.75);
    await bloc.close();
  });
}
