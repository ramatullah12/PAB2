import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/note_list_screen.dart';
import 'services/fcm_service.dart';
import 'l10n/app_localizations.dart';

final FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'Handling background message: ${message.messageId}',
  );

  if (message.notification == null &&
      message.data.isNotEmpty) {
    final title =
        message.data['title'] ??
        'New Notification';

    final body =
        message.data['body'] ??
        'Tap to view details';

    await flutterLocalNotificationsPlugin
        .show(
      DateTime.now()
          .millisecondsSinceEpoch,
      title,
      body,
      const NotificationDetails(
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform,
    );

    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings =
        InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin
        .initialize(
      initSettings,
    );

    final token =
        await FirebaseMessaging.instance
            .getToken();

    debugPrint(
      'FCM TOKEN: $token',
    );

    final settings =
        await FirebaseMessaging.instance
            .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Permission status: ${settings.authorizationStatus}',
    );

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    await FcmService().initialize();

    FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      debugPrint(
        'Foreground message: ${message.notification?.title}',
      );

      if (message.notification != null) {
        await flutterLocalNotificationsPlugin
            .show(
          DateTime.now()
              .millisecondsSinceEpoch,
          message.notification?.title ??
              'Notification',
          message.notification?.body ??
              '',
          const NotificationDetails(
            android:
                AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance:
                  Importance.max,
              priority:
                  Priority.high,
              icon:
                  '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  } catch (e) {
    debugPrint(
      'Firebase init error: $e',
    );
  }

  final prefs =
      await SharedPreferences.getInstance();

  final savedLocale =
      prefs.getString(
        'app_locale',
      ) ??
      'id';

  runApp(
    MainApp(
      initialLocale: Locale(
        savedLocale,
      ),
    ),
  );
}

class MainApp extends StatefulWidget {
  final Locale initialLocale;

  const MainApp({
    super.key,
    required this.initialLocale,
  });

  static _MainAppState? _instance;

  static Future<void> setLocale(
    Locale locale,
  ) async {
    await _instance?._setLocale(
      locale,
    );
  }

  @override
  State<MainApp> createState() =>
      _MainAppState();
}

class _MainAppState
    extends State<MainApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();

    _locale = widget.initialLocale;

    MainApp._instance = this;
  }

  Future<void> _setLocale(
    Locale locale,
  ) async {
    setState(() {
      _locale = locale;
    });

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'app_locale',
      locale.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorSchemeSeed:
            Colors.deepPurple,
        useMaterial3: true,
      ),

      locale: _locale,

      localizationsDelegates:
          AppLocalizations
              .localizationsDelegates,

      supportedLocales:
          AppLocalizations
              .supportedLocales,

      localeResolutionCallback: (
        locale,
        supportedLocales,
      ) {
        for (final supportedLocale
            in supportedLocales) {
          if (supportedLocale
                  .languageCode ==
              locale?.languageCode) {
            return supportedLocale;
          }
        }

        return supportedLocales.first;
      },

      home: const NoteListScreen(),
    );
  }
}