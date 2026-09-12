enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  failed;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.failed:
        return 'Failed';
    }
  }
}
