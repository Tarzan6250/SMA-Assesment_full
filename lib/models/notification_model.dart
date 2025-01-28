class NotificationModel {
  final String title;
  final String message;
  final DateTime time;
  final String? icon;
  final bool isToday;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    this.icon,
    required this.isToday,
  });
}
