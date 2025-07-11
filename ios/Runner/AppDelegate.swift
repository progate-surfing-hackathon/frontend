import UIKit
import Flutter
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("iOS: AppDelegate didFinishLaunchingWithOptions called")
    // Platform Channelのセットアップ
    if let controller = window?.rootViewController as? FlutterViewController {
      let counterChannel = FlutterMethodChannel(
        name: "com.example.progateSurfingHackathon/counter",
        binaryMessenger: controller.binaryMessenger
      )
      counterChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "saveCounter" {
          // 存在確認
          if let args = call.arguments as? [String: Any],
            let value = args["value"] as? Int {
              // UserDefaultsに値を保存
              print("iOS: saveCounter called with value: \(value)")
              let userDefaults = UserDefaults(suiteName: "group.com.example.progateSurfingHackathon")
              userDefaults?.set(value, forKey: "counter")
              let savedValue = userDefaults?.integer(forKey: "counter") ?? -1
              userDefaults?.synchronize()
              WidgetCenter.shared.reloadAllTimelines()
              result(true)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
          }
        } else if call.method == "getCounter" {
          let userDefaults = UserDefaults(suiteName: "group.com.example.progateSurfingHackathon")
          let value = userDefaults?.integer(forKey: "counter") ?? 0
          result(value)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    } else {
    }

    GeneratedPluginRegistrant.register(with: self)
    print("iOS: GeneratedPluginRegistrant.register完了")
    WidgetCenter.shared.reloadAllTimelines()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
} 