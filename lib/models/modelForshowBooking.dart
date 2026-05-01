class Booking {
  final String bookingDate;
  final int indexId;
  final String status;
  final String uid;

  Booking({required this.bookingDate, required this.indexId, required this.status, required this.uid});
}

class IndexData {
  final int indexId;
  final String serviceId;
  final String userId;

  IndexData({required this.indexId, required this.serviceId, required this.userId});
}
