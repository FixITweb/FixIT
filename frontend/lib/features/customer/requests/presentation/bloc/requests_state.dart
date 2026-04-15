abstract class RequestsState {}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<dynamic> requests; // You can create a proper RequestModel later
  RequestsLoaded(this.requests);
}

class RequestsError extends RequestsState {
  final String message;
  RequestsError(this.message);
}