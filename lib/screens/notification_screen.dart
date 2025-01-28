import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({Key? key}) : super(key: key);

  final List<NotificationModel> notifications = [
    NotificationModel(
      title: 'Reminder',
      message:
          'Your assignment for [Name] is due tomorrow at 11:59 PM. Don\'t forget to submit on time!',
      time: DateTime.now().subtract(const Duration(hours: 4, minutes: 38)),
      icon: '🕒',
      isToday: true,
    ),
    NotificationModel(
      title: 'Great job!',
      message:
          'You\'ve completed 50% of the [Course Name]. Keep up the excellent work!',
      time: DateTime.now().subtract(const Duration(hours: 5, minutes: 8)),
      icon: '✓',
      isToday: true,
    ),
    NotificationModel(
      title: 'Course Completed!',
      message:
          'Done your class UI/UX Designer, give any feedback or rationg for course',
      time: DateTime.now()
          .subtract(const Duration(days: 1, hours: 9, minutes: 38)),
      icon: '✓',
      isToday: false,
    ),
    NotificationModel(
      title: 'Promo 10% All Course',
      message: 'Get 20% promo All Course don\'t miss it',
      time: DateTime.now()
          .subtract(const Duration(days: 1, hours: 10, minutes: 38)),
      icon: '%',
      isToday: false,
    ),
    NotificationModel(
      title: 'Course Completed!',
      message:
          'Done your class UI/UX Designer, give any feedback or rationg for course',
      time: DateTime.now()
          .subtract(const Duration(days: 1, hours: 10, minutes: 38)),
      icon: '✓',
      isToday: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          ...notifications.where((n) => n.isToday).map(_buildNotificationItem),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Yesterday',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          ...notifications.where((n) => !n.isToday).map(_buildNotificationItem),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    IconData getNotificationIcon() {
      switch (notification.icon) {
        case '🕒':
          return Icons.access_time_rounded;
        case '✓':
          return Icons.check_circle_outline_rounded;
        case '%':
          return Icons.percent_rounded;
        default:
          return Icons.notifications_outlined;
      }
    }

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {},
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.grey.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 171, 45).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    getNotificationIcon(),
                    color: const Color.fromARGB(255, 255, 191, 95),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(notification.time),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
