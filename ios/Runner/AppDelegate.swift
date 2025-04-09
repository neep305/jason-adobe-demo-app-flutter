import Flutter
import UIKit

// Adobe Dependencies
import AEPCore
import AEPCampaignClassic
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var environmentFileId = "1a2e5738b89a/37491cf23176/launch-6c40c5052086-development"
    private var currentDeviceToken = "No Token"
    var flutterChannel: FlutterMethodChannel?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      let controller = window?.rootViewController as! FlutterViewController
      let channel = FlutterMethodChannel(name: "com.jason.adobe_demo_app/push", binaryMessenger: controller.binaryMessenger)
      
      channel.setMethodCallHandler { call, result in
          switch call.method {
          case "getPushToken":
              result(self.currentDeviceToken)

          case "registerPushToken":
              guard let args = call.arguments as? [String: Any] else {
                  result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing arguments", details: nil))
                  return
              }

              guard let apnsTokenHex = args["apnsToken"] as? String,
                    let apnsTokenData = Data(hex: apnsTokenHex) else {
                  result(FlutterError(code: "INVALID_TOKEN", message: "APNs token is missing or invalid", details: nil))
                  return
              }

              let userKey = args["guid"] as? String
              let additionalParams = args["additionalParameters"] as? [String: Any]

              CampaignClassic.registerDevice(
                  token: apnsTokenData,
                  userKey: userKey,
                  additionalParameters: additionalParams
              )
              print("✅ CampaignClassic.registerDevice 호출됨")
              let apnsTokenString = apnsTokenData.map { String(format: "%02.2hhx", $0) }.joined()

              let resultMap: [String: Any] = [
                "status": "success",
                "message": "CampaignClassic.registerDevice called with \(userKey ?? "nil")",
                "token": apnsTokenString // ✅ 문자열로 전달
              ]
              result(resultMap)

          case "trackNotificationReceive", "trackNotificationClick":
              let type: TrackType = (call.method == "trackNotificationReceive") ? .receive : .click
              if let trackingInfo = handleTrackNotification(call: call, type: type) {
                  result(["status": "success", "type": call.method.replacingOccurrences(of: "trackNotification", with: "").lowercased(), "trackInfo": trackingInfo])
              } else {
                  result(FlutterError(code: "TRACKING_ERROR", message: "Tracking failed", details: nil))
              }

          default:
              result(FlutterMethodNotImplemented)
          }
      }
      
      MobileCore.setLogLevel(.trace)
      MobileCore.registerExtensions([
        CampaignClassic.self
      ]) {
          print("✅ Current environmentFileId: \(self.environmentFileId)")
          MobileCore.configureWith(appId: self.environmentFileId)
          MobileCore.registerEventListener(type: EventType.campaign, source: EventSource.responseContent, listener: { event in
              print("✅ ACCRegistrationStatus: \(event.data?["registrationstatus"] ?? "unknown")")
          })
          
      }
      UNUserNotificationCenter.current().delegate = self
      // self.requestNotificationPermission()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    // MARK: Notification Settings (NOT IN USE)
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { granted, error in
            if let error = error {
                print("Error retrieving notification permission \(error.localizedDescription)")
                return
            }
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
              UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: Register Device Token
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        CampaignClassic.registerDevice(token: deviceToken, userKey: "deadpool@swim.com", additionalParameters: nil)
        let token = deviceToken.reduce("") {$0 + String(format: "%02x", $1)}
        print("✅ APNs Device Token: \(token)")
        self.currentDeviceToken = token
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to Register for Remote Notification with Error \(error.localizedDescription)")
    }
    
    // MARK: Receive Notification in the Background state
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("✅ userNotificationCenter didReceiveRemoteNotification called. userInfo: \(userInfo)")
        CampaignClassic.trackNotificationReceive(withUserInfo: userInfo)
    }
    
    // MARK: Receive Notification in the Foreground state
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.badge, .list, .banner, .sound])
        } else {
            completionHandler([.badge, .alert, .sound]) // iOS 10~13 fallback
        }
        let userInfo = notification.request.content.userInfo
        print("✅ userNotificationCenter willPresent called - trackNotificationReceive. userInfo: \(userInfo)")
        CampaignClassic.trackNotificationReceive(withUserInfo: userInfo)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("✅ userNotificationCenter didReceive called - trackNotificationClick")
        CampaignClassic.trackNotificationClick(withUserInfo: response.notification.request.content.userInfo)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        // handle user clicking on App's Notification Setting from Settings->TestApp->Notifications->TestApp Notification Settings
    }
}

extension Data {
    /// hex 문자열을 Data로 변환하는 생성자
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        var index = hex.startIndex

        for _ in 0..<len {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard nextIndex <= hex.endIndex else { return nil }
            let byteString = hex[index..<nextIndex]
            guard let num = UInt8(byteString, radix: 16) else { return nil }
            data.append(num)
            index = nextIndex
        }

        self = data
    }
}
