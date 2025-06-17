import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:math';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> iniNotifications() async {
  // Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_notification');

  // iOS y macOS
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  // Windows
  const WindowsInitializationSettings initializationSettingsWindows =
      WindowsInitializationSettings(
    appName: 'JCRG',
    appUserModelId: 'com.example.jcrg',
    guid: '{12345678-1234-1234-1234-1234567890ab}',
  );

  // Unifica la configuración para todas las plataformas
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsIOS,
    windows: initializationSettingsWindows,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Solicitar permisos en iOS
  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}

Future<void> showSimpleNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'task_channel', // id
    'Tareas', // name
    channelDescription: 'Notificaciones de tareas',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    // sound: 'default', // Puedes personalizar el sonido si lo deseas
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    1,
    title,
    body,
    platformChannelSpecifics,
  );
}
