class WorkerBookingModel {
  final String id;
  final String serviceTitle;
  final String customerName;
  final DateTime scheduledDate;
  final String status;
  final double price;

  WorkerBookingModel({
    required this.id,
    required this.serviceTitle,
    required this.customerName,
    required this.scheduledDate,
    required this.status,
    required this.price,
  });

  WorkerBookingModel copyWith({
    String? id,
    String? serviceTitle,
    String? customerName,
    DateTime? scheduledDate,
    String? status,
    double? price,
  }) {
    return WorkerBookingModel(
      id: id ?? this.id,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      customerName: customerName ?? this.customerName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      price: price ?? this.price,
    );
  }
}

abstract class WorkerBookingsState {}

class WorkerBookingsInitial extends WorkerBookingsState {}

class WorkerBookingsLoading extends WorkerBookingsState {}

class WorkerBookingsLoaded extends WorkerBookingsState {
  final List<WorkerBookingModel> bookings;
  WorkerBookingsLoaded(this.bookings);
}

class WorkerBookingUpdated extends WorkerBookingsState {
  final String message;
  WorkerBookingUpdated(this.message);
}

class WorkerBookingsError extends WorkerBookingsState {
  final String message;
  WorkerBookingsError(this.message);
}