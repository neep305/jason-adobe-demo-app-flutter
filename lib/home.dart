import 'dart:developer';
import 'dart:io';
import 'package:advertising_id/advertising_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_id/android_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

// Firebase
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<HomePage> {
  static const _channel = MethodChannel('com.jason.adobe_demo_app/push');

  String _token = 'FCM Token Loading...';
  String _apnsToken = 'No APNs Token...';
  String _message = 'No message';
  String _getConsentResult = '';
  String _sdkIdentities = '';
  String _privacyStatus = '';
  String _experienceCloudId = 'Unknown';
  String _permissionStatus = 'Checking Permission...';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Image.asset('images/adobe.png', width: 50.0, height: 50.0),
                  Text(
                    "Welcome to\n Adobe AEP Demo App",
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "This app demonstrates AEP features.",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView(shrinkWrap: true, children: <Widget>[
                getRichText('✅ PermissionStatus: ', _permissionStatus),
                getRichText('✅ FCM Token: ', _token),
                getRichText('✅ APNs Token: ', _apnsToken),
                getRichText('✅ Push Message: ', _message),
                getRichText('✅ Consent: ', _getConsentResult),
                getRichText('✅ ECID: ', _experienceCloudId),
                getRichText('✅ SDK Identities: ', _sdkIdentities),
                getRichText('✅ Privacy status: ', _privacyStatus),
                SizedBox(height: 16.0),
                getRichButton(
                    'Send trackNotificationReceive',
                        () async {
                      await _sendTrackNotificationReceive();
                      Fluttertoast.showToast(
                        msg: "️✅ trackNotificationReceive called",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                ),
                getRichButton(
                    'Send trackNotificationClick',
                        () async {
                      await _sendTrackNotificationClick();
                      Fluttertoast.showToast(
                        msg: "️✅ trackNotificationClick called",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                ),
                getRichButton(
                  'Get ECID',
                  () async {
                    _getExperienceCloudId();
                  }
                ),
                getRichButton(
                    'Get SDK Identities',
                        () async {
                      _getSDKIdentities();
                    }
                ),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 알림 권한 상태 확인
  Future<void> _checkPermissionStatus() async {
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _permissionStatus = 'Permission: ${settings.authorizationStatus}';
    });
  }
  
  // FCM 토큰 수신
  Future<void> _getFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      setState(() {
        _token = token ?? 'No FCM Token';
        _apnsToken = apnsToken ?? 'No APNs Token';
      });
    } catch(e) {
      setState(() {
        _token = 'Failed to receive FCM token: $e';
      });
      log("❌ Failed to get fcm token");
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await _checkPermissionStatus();
    await _getFcmToken();
    // _setupFcmListeners(); // PushManager 별도 클래스 처리

    if (!mounted) {
      log("❌ Failed to setState, widget is not mounted");
      return;
    }

    setState(() {

    });
  }

  // SDK Identities
  Future<void> _getSDKIdentities() async {
    String result = '';
    try {
      result = await _channel.invokeMethod('getSDKIdentities');
    } on PlatformException catch (e) {
      log("❌ Failed to get SDK Identities: ${e.message}");
      result = "Failed to get SDK Identities";
    }

    if (!mounted) return;

    setState(() {
      _sdkIdentities = result;
    });
  }

  // Privacy Status
  Future<void> getPrivacyStatus() async {
    // Not implemented
  }

  Future<void> _sendTrackNotificationReceive() async {
    // Open test dummy
    final result = await _channel.invokeMethod('trackNotificationReceive', {
      "data": {
        "_dId" : "168fb",
        "source" : "source",
        "_mId" : "f9697e4d-b55a-4f10-bd71-2e8b25a0af85",
        "deepLinkUri" : "deepLinkUri",
        "aps" : {
          "relevance-score" : 0,
          "alert" : {
            "title" : "test",
            "body" : "test"
          },
          "interruption-level" : "active"
        }
      },
    });
    log('✅ [home.dart] TrackNotificationReceive result: $result');
  }

  Future<void> _sendTrackNotificationClick() async {
    // Click test dummy
    final result = await _channel.invokeMethod('trackNotificationClick', {
      "data": {
        "_dId" : "168fb",
        "source" : "source",
        "_mId" : "f9697e4d-b55a-4f10-bd71-2e8b25a0af85",
        "deepLinkUri" : "deepLinkUri",
        "aps" : {
          "relevance-score" : 0,
          "alert" : {
            "title" : "test",
            "body" : "test"
          },
          "interruption-level" : "active"
        }
      },
    });
    log('✅ [home.dart] TrackNotificationClick result: $result');
  }

  Future<void> _getExperienceCloudId() async {
    String result = '';
    try {
      result = await _channel.invokeMethod('getECID');
    } on PlatformException catch (e) {
      log("❌ Failed to get ECID: ${e.message}");
      result = "Failed to get ECID";
    }

    if (!mounted) return;

    setState(() {
      _experienceCloudId = result;
    });
  }

  // Set Advertising Identifier
  Future<void> setAdvertisingIdentifier() async {
    String? advertisingId;

    if (Platform.isAndroid) {
      // Android GAID
      final androidIdPlugin = AndroidId();
      advertisingId = await androidIdPlugin.getId();
      log("✅ Android ID: $advertisingId");
    } else if (Platform.isIOS) {
      // iOS IDFA/IDFV
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.authorized) {
        advertisingId = await AdvertisingId.id(true);
        updateConsent(true);
      } else {
        log("❌ iOS App Tracking Transparency 권한 없음");
      }
    }
  }

  Future<void> setDefaultConsent(bool allowed) async {
    // Map<String, Object> collectConsents = allowed
    //     ? {
    //   "collect": {"val": "y"}
    // }
    //     : {
    //   "collect": {"val": "n"}
    // };
    // Map<String, Object> currentConsents = {"consents": collectConsents};
    // Map<String, Object> defaultConsents = {"consents.default": currentConsents};
    //
    // MobileCore.updateConfiguration(defaultConsents);
  }

  Future<void> updateConsent(bool allowed) async {
    // Map<String, dynamic> collectConsents = allowed
    //     ? {
    //   "collect": {"val": "y"}
    // }
    //     : {
    //   "collect": {"val": "n"}
    // };
    // Map<String, dynamic> currentConsents = {"consents": collectConsents};
    //
    // Consent.update(currentConsents);
  }

  Future<void> getConsent() async {
    // Map<String, dynamic> result = {};
    //
    // try {
    //
    //   result = await Consent.consents;
    //   if (result.isNotEmpty) {
    //     final collectConsent = result["consents"]?["collect"]?["val"];
    //     if (collectConsent == "y") {
    //       log("✅ Consent: $collectConsent");
    //     } else {
    //       log("❌ Consent: $collectConsent");
    //     }
    //   }
    //   log("✅ Consent: $result");
    // } on PlatformException {
    //   log("Failed to get consent");
    // }
    //
    // if (!mounted) {
    //   log("Failed to setState, widget is not mounted");
    //   return;
    // }
    //
    // setState(() {
    //   _getConsentResult = result.toString();
    // });
  }
}