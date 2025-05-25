import Flutter
import UIKit
import WiseTrackLib

public class WisetrackPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "io.wisetrack.flutter", binaryMessenger: registrar.messenger())
        let instance = WisetrackPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        WTLogger.shared.addOutput(output: FlutterChannelOutputLogger(channel: channel))
    }
    
    private func args(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> [String: Any]?{
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for \(call.method)", details: nil))
            return nil
        }
        return args
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case WisetrackMethodChannel.initSDK.rawValue:
            guard let args = args(call, result: result) else { return }
            
            self.initSDK(args: args)
            result(nil)
            
        case WisetrackMethodChannel.enableTestMode.rawValue:
            self.enableTestMode()
            result(nil)
            
        case WisetrackMethodChannel.setLogLevel.rawValue:
            guard let args = args(call, result: result) else { return }
            
            self.setLogLevel(level: args["level"] as! Int)
            result(nil)
            
        case WisetrackMethodChannel.setEnabled.rawValue:
            guard let args = args(call, result: result) else { return }
            
            self.setEnabled(enabled: args["enabled"] as! Bool)
            result(nil)
            
        case WisetrackMethodChannel.isEnabled.rawValue:
            let isEnable = self.isEnabled()
            result(isEnable)
            
        case WisetrackMethodChannel.iOSRequestForATT.rawValue:
            guard let _ = Bundle.main.object(forInfoDictionaryKey: "NSUserTrackingUsageDescription") as? String else {
                result(FlutterError(code: "MISSING_INFO_PLIST_KEY",
                                    message: "NSUserTrackingUsageDescription key is missing in Info.plist",
                                    details: "Please add NSUserTrackingUsageDescription to your Info.plist"))
                return
            }
            
            self.iOSRequestForATT(completion: { isAuthorized in
                result(isAuthorized)
            })
            
        case WisetrackMethodChannel.getADID.rawValue:
            result(nil)
        
        case WisetrackMethodChannel.getIDFA.rawValue:
            let res = self.getIDFA()
            result(res)
            
        case WisetrackMethodChannel.startTracking.rawValue:
            self.startTracking()
            result(nil)
            
        case WisetrackMethodChannel.stopTracking.rawValue:
            self.stopTracking()
            result(nil)
            
        case WisetrackMethodChannel.setAPNSToken.rawValue:
            guard let args = args(call, result: result) else { return }
            
            self.setAPNSToken(apnsToken: args["token"] as! String)
            result(nil)
            
        case WisetrackMethodChannel.setFCMToken.rawValue:
            guard let args = args(call, result: result) else { return }
            
            self.setFCMToken(fcmToken: args["token"] as! String)
            result(nil)
            
        case WisetrackMethodChannel.logEvent.rawValue:
            guard let args = args(call, result: result) else { return }
            
            self.logEvent(args: args)
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension WisetrackPlugin {
    
    private func initSDK(args: [String: Any]) {
        ResourceWrapper.setSdkHash(hash: "22f7117372028b36e658c96515399afaa7107f76")
        ResourceWrapper.setSdkEnvironment(env: args["sdk_env"] as! String)
        ResourceWrapper.setSdkFramework(framework: "flutter")
        ResourceWrapper.setSdkVersion(version: args["sdk_version"] as! String)
        
        WiseTrack.shared.initialize(with: WTInitialConfig(
            appToken: args["app_token"] as! String,
            storeName: WTStoreName(rawValue: args["ios_store_name"] as! String),
            environment: WTUserEnvironment(rawValue: args["user_environment"] as! String) ?? .production,
            logLevel: WTLogLevel(rawValue: args["log_level"] as! Int),
            trackingWaitingTime: args["tracking_waiting_time"] as! Int,
            startTrackerAutomatically: args["start_tracker_automatically"] as! Bool,
            customDeviceId: args["custom_device_id"] as? String,
            defaultTracker: args["default_tracker"] as? String,
            appSecret: args["app_secret"] as? String,
            secretId: args["secret_id"] as? String,
            attributionDeeplink: args["attribution_deeplink"] as? Bool,
            eventBuffering: args["event_buffering_enabled"] as? Bool
        ))
    }
    
    private func enableTestMode() {
        WiseTrack.shared.enableTestMode()
    }
    
    private func setLogLevel(level: Int) {
        WiseTrack.shared.setLogLevel(WTLogLevel(rawValue: level) ?? WTLogLevel.warning)
    }
    
    private func setEnabled(enabled: Bool) {
        WiseTrack.shared.setEnabled(enabled: enabled)
    }
    
    private func isEnabled() -> Bool {
        return WiseTrack.shared.isEnabled
    }
    
    private func iOSRequestForATT(completion: @escaping (_ isAuthorized: Bool) -> Void) {
        WiseTrack.shared.requestAppTrackingAuthorization(completion: completion)
    }
    
    private func startTracking() {
        WiseTrack.shared.startTracking()
    }
    
    private func stopTracking() {
        WiseTrack.shared.stopTracking()
    }
    
    private func setAPNSToken(apnsToken: String) {
        WiseTrack.shared.setAPNSToken(token: apnsToken)
    }
    
    private func setFCMToken(fcmToken: String) {
        WiseTrack.shared.setFCMToken(token: fcmToken)
    }
    
    private func getIDFA() -> String? {
        return WiseTrack.shared.getIDFA()
    }
    
    private func logEvent(args: [String: Any]) {
        let params: [String: JSONValue]? = (args["params"] as? [String: Any])?.mapValues({ JSONValue.convert(value: $0)})
        
        switch args["type"] as! String {
        case WTEventType.default.name:
            WiseTrack.shared.logEvent(WTEvent.default(for: args["name"] as! String,
                                                      params: params))
        case WTEventType.revenue(currency: RevenueCurrency.USD, amount: 0).name:
            WiseTrack.shared.logEvent(WTEvent.revenue(for: args["name"] as! String,
                                                      currency: RevenueCurrency(rawValue: args["currency"] as! String)!,
                                                      amount: args["revenue"] as! Double,
                                                      params: params))
        default:
            return
        }
    }
}

extension Encodable {
    
    /// Converting object to postable dictionary
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        if let json = object as? [String: Any]  { return json }
        
        let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
        throw DecodingError.typeMismatch(type(of: object), context)
    }
}
