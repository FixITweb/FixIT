abstract class CreateServiceState {}

class CreateServiceInitial extends CreateServiceState {}

class CreateServiceLoading extends CreateServiceState {}

class CreateServiceSuccess extends CreateServiceState {
  final String message;
  CreateServiceSuccess(this.message);
}

class CreateServiceError extends CreateServiceState {
  final String message;
  CreateServiceError(this.message);
}