
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';


class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    initialize();
  }

  Future<void> initialize() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initializationSettings);
  }

  void showSoundModeChangeNotification(bool isMuted) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "sound-mode-notifications",
      "Sound Mode Notifications",
      priority: Priority.max,
      importance: Importance.max,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notiDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String title = isMuted ? "Phone Muted" : "Phone Unmuted";
    String message = isMuted
        ? "Your phone entered in silent zone."
        : "You left the silent zone or have no saved locations.";

    await notificationsPlugin.show(
      0,
      title,
      message,
      notiDetails,
    );
  }


 
}



