import Flutter
import UIKit

public class SwiftFlutterblepluginPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutterbleplugin", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterblepluginPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method=="openPage"){
        let args = call.arguments as? String
        if(args=="SETTING){
            UIApplication.shared.openURL(URL(string: "App-Prefs:root=General"))
        }
        result(true)
    } else{
        result(false)
    }
  }
}
