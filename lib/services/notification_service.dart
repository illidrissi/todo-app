import '../model/todo.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // 1. Define the notifications plugin as a static property
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 2. Initialization method
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Initialize notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin.initialize(initializationSettings);
  }

  // 3. Updated schedule method
  static Future<void> scheduleNotification(ToDo todo) async {
    if (todo.dueDate == null) return;

    final scheduledDate = tz.TZDateTime.from(todo.dueDate!, tz.local);
    
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await notificationsPlugin.zonedSchedule(
        int.parse(todo.id!),
        'Task Reminder',
        todo.todoText!,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Channel',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}