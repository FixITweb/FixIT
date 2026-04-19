abstract class CreateRequestState {}

class CreateRequestInitial extends CreateRequestState {}

class CreateRequestLoading extends CreateRequestState {}

class CreateRequestSuccess extends CreateRequestState {
  final String message;

  CreateRequestSuccess(this.message);
}

class CreateRequestError extends CreateRequestState {
  final String message;

  CreateRequestError(this.message);
}

class CategoriesLoaded extends CreateRequestState {
  final List<String> categories;
  CategoriesLoaded(this.categories);
}
