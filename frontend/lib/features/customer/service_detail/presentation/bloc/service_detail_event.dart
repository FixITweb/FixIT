abstract class ServiceDetailEvent {}

class LoadServiceDetail extends ServiceDetailEvent {
  final String serviceId;
  LoadServiceDetail(this.serviceId);
}

class BookService extends ServiceDetailEvent {
  final int serviceId;
  BookService(this.serviceId);
}
