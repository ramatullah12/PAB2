import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/note_list_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/fcm_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'Handling a background message: ${message.messageId}',
  );

  // Jika data-only message
  if (message.notification == null &&
      message.data.isNotEmpty) {
    final title =
        message.data['title'] ?? 'Notifikasi Baru';

    final body =
        message.data['body'] ??
        'Klik untuk melihat detail';

    final flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
    );

    await flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Ambil token FCM
    String? token =
        await FirebaseMessaging.instance.getToken();

    debugPrint("FCM TOKEN: $token");

    // Request permission notifikasi
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

    debugPrint(
      'User granted permission: ${settings.authorizationStatus}',
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // Inisialisasi service FCM
    await FcmService().initialize();

    // Listener saat app terbuka
    FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      debugPrint(
        'Foreground message received: ${message.notification?.title}',
      );
    });
  } catch (e) {
    debugPrint(
      'Error during Firebase initialization: $e',
    );
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const NoteListScreen(),
    );
  }
}