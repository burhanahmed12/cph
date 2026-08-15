class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? requestId;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.requestId,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      requestId: requestId,
      isRead: isRead ?? this.isRead,
    );
  }
}
