import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class PushManager {
  static const MethodChannel _channel = MethodChannel('com.jason.adobe_demo_app/push');

  static Future<void> initialize() async {
    // Firebase Messaging 권한 요청은 main.dart에서 완료됐다고 가정

    // FCM 토큰 가져오기
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    log('[PushManager] 📲 FCM: $fcmToken');
    log('[PushManager] 📲 APNs: $apnsToken');

    // OS 분기 처리
    if (Platform.isIOS && apnsToken != null) {
      final result = await _channel.invokeMethod('registerPushToken', {
        "apnsToken": apnsToken,
        "guid": "jasonnam1234",
        "additionalParameters": {
          "email": "test@adobe.com",
          "age": "30"
        }
      });
      log('[PushManager] 📲 iOS Method Channel registerDevice result: $result');
    } else if (Platform.isAndroid && fcmToken != null) {
      final result = await _channel.invokeMethod('registerPushToken', {
        "token": fcmToken,
        "guid": "jasonnam1234",
        "additionalParameters": {
          "email": "test@adobe.com",
          "age": "30"
        }
      });
      log('[PushManager] 📲 AOS Method Channel registerDevice result: $result');
    }

    // Foreground state
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('[PushManager] 📩 Foreground message: ${message.data}');
      final result = await _channel.invokeMethod('trackNotificationReceive', {
        "data": message.data,
      });
      log('[PushManager] 📩 trackNotificationReceive result: $result');

      if (message.data.isNotEmpty) {
        await _showNotification(message.data);
      }
    });

    // Push notification click: background state to foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log('[PushManager] 📬 Notification clicked: ${message.data}');
      final result = await _channel.invokeMethod('trackNotificationClick', {
        "data": message.data,
      });
      log('[PushManager] 📬 trackNotificationClick result: $result');
    });
  }

  static Future<void> _showNotification(Map<String, dynamic> data) async {
    final title = data['title'] ?? 'Hello title';
    final body = data['body'] ?? 'No body';

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'Channel for displaying foreground notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,    // Alert 표시
      presentBadge: true,    // 앱 아이콘 뱃지 표시
      presentSound: true,    // 소리 재생
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  static Future<void> trackClickFromMap(Map<String, dynamic> data) async {
    log('[PushManager] 📬 Notification clicked (from local notification): $data');

    final result = await _channel.invokeMethod('trackNotificationClick', {
      "data": data,
    });
    log('[PushManager] 📬 trackNotificationClick result: $result');
  }

  static Future<void> handleMessage(RemoteMessage message) async {
    log('[PushManager] 🔁 handleMessage called in background/foreground');

    // Notification Type
    if (message.notification != null) {
      log('[PushManager] 🔔 Title: ${message.notification!.title}');
      log('[PushManager] 🔔 Body: ${message.notification!.body}');
    }

    // Data Type
    if (message.data.isNotEmpty) {
      log('[PushManager] 📦 Received Push Data: ${message.data}');

      if (message.data.containsKey('_mId')) {
        try {
          var jsonString = jsonEncode({ "data": message.data }) ;

          final result = await _channel.invokeMethod('trackNotificationReceive', jsonString);
          log('[PushManager] 📩 trackNotificationReceive result: $result');
        } catch (e) {
          log('[PushManager] ❌ trackNotificationReceive error: $e');
        }
      }
    }
  }
}