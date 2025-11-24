import 'package:fashion_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final data = message.data;
  final type = data['type'];

  final notification = message.notification;
  final tenVoucher = data['tenVoucher'] ?? 'Voucher mới';

  if (notification != null) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(notificationChannel);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ?? " Thông báo ",
      type == 'voucher'
          ? 'Bạn đã nhận được voucher: $tenVoucher'
          : (notification.body ?? ''),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: type == 'voucher' ? data['voucherId'] : null,
    );
  }
}
Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Foreground hiển thị
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Subscribe topic
  await messaging.subscribeToTopic("allUsers");

  // Init Local notifications
  const initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings =
      InitializationSettings(android: initSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

  
  // HANDLE FOREGROUND
  
  FirebaseMessaging.onMessage.listen((message) {
    final data = message.data;
    final type = data['type'];

    final notification = message.notification;

    final tenVoucher = data['tenVoucher'] ?? 'Voucher mới';

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? 'Thông báo',
        type == 'voucher' ? tenVoucher : notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: type == 'voucher' ? data['voucherId'] : null,
      );
    }
  });

  
  // Open app from background
  
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    final data = msg.data;
    final type = data['type'];

    if (type == 'voucher') {
      print("📱 OPEN APP (background) → voucherId = ${data['voucherId']}");
    }
  });

  
  //Open app from terminated
  FirebaseMessaging.instance.getInitialMessage().then((msg) {
    if (msg != null) {
      final type = msg.data['type'];
      if (type == 'voucher') {
        print("📱 OPEN APP (terminated) → voucherId = ${msg.data['voucherId']}");
      }
    }
  });

  // Global background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
