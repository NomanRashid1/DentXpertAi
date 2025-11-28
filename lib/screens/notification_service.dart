Future<void> sendAppointmentNotification({
  required String patientName,
  required String status,
  required String fcmToken,
}) async {
  // Placeholder – won't actually send notification yet
  print('Send notification to $fcmToken: $patientName - $status');
}
