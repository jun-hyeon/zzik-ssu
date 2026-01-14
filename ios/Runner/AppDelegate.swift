import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let imagePickerManager = ImagePickerManager()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      let pickerChannel = FlutterMethodChannel(
        name: "com.example.zzik_ssu/pickImage",
        binaryMessenger: controller.binaryMessenger)
      
      pickerChannel.setMethodCallHandler{[weak self](call: FlutterMethodCall, result: @escaping FlutterResult) in
          if call.method == "pickImage" {
              self?.imagePickerManager.pickImage(viewController: controller, result: result)
          } else if call.method == "pickImageFromCamera" {
              self?.imagePickerManager.pickImageFromCamera(viewController: controller, result: result)
          } else {
              result(FlutterMethodNotImplemented)
          }
      }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
