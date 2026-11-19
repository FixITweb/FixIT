abstract class CreateRequestState {}

class CreateRequestInitial extends CreateRequestState {}

class CategoriesLoading extends CreateRequestState {}

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

class CategoriesLoadFailed extends CreateRequestState {
  final String message;

  CategoriesLoadFailed(this.message);
}

const defaultJobRequestCategories = <String>[
  'Plumbing',
  'Electrical',
  'Cleaning',
  'Carpentry',
  'Painting',
  'Moving',
  'Gardening',
  'Appliance Repair',
  'HVAC',
  'Roofing',
  'Other',
];
