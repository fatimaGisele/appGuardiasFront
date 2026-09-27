import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:guardias_front/core/constants/api_constants.dart';
import 'package:guardias_front/core/services/api_client.dart';
import 'package:guardias_front/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'guardias_channel',
    'Guardias App',
    description: 'Notificaciones de turnos y guardias',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> initialize() async {
    if (kIsWeb) return;
    // Pedir permisos
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    //init notificaciones locales
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);

    // crea canal Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Guardar FCM token en el backend
    final token = await messaging.getToken();
    if (token != null) {
      await _guardarToken(token);
    }

    // Escuchar token refresh
    messaging.onTokenRefresh.listen(_guardarToken);

    // Notificaciones en foreground
    FirebaseMessaging.onMessage.listen(_mostrarNotificacionLocal);

    // app estaba en background y el user la abre
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notificación abierta: ${message.data}');
    });
  }

  static Future<void> _guardarToken(String token) async {
    final storage = const FlutterSecureStorage();
    await storage.write(key: 'fcm_token', value: token);
    
    final accessToken = await StorageService.getAccessToken();
    if(accessToken==null) return;

    await ApiCliente.post(
      '${ApiConstants.baseUrl}/usuarios/fcm-token/',
      {'token':token},
      );
  }

  static Future<void> _mostrarNotificacionLocal(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}