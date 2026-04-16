abstract class ServiceDetailEvent {}

class LoadServiceDetail extends ServiceDetailEvent {
  final String serviceId;

  LoadServiceDetail(this.serviceId);
}
