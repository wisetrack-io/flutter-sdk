import Flutter
import UIKit
import WiseTrackLib

public class WisetrackPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = WisetrackPlugin()
        let channel = FlutterMethodChannel(name: "io.wisetrack.flutter", binaryMessenger: registrar.messenger())
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        
        WiseTrack.shared.prepareInitialization()
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
            
        case WisetrackMethodChannel.clearAndStop.rawValue:
            self.clearAndStop()
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
            
        case WisetrackMethodChannel.isWiseTrackNotification.rawValue:
            guard let args = args(call, result: result) else { return }
            result(self.isWiseTrackNotification(args: args))
            
        case WisetrackMethodChannel.getLastDeeplink.rawValue:
            let res = self.getLastDeeplink()
            result(res)
            
        case WisetrackMethodChannel.getDeferredLink.rawValue:
            let res = self.getDeferredLink()
            result(res)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension WisetrackPlugin {
    
    private func initSDK(args: [String: Any]) {
        ResourceWrapper.setSdkEnvironment(env: args["sdk_env"] as! String)
        ResourceWrapper.setSdkFramework(framework: "flutter")
        ResourceWrapper.setSdkVersion(version: args["sdk_version"] as! String)
        
        WiseTrack.shared.initialize(with: WTInitialConfig(
            appToken: args["app_token"] as! String,
            clientSecret: args["client_secret"] as! String,
            storeName: WTStoreName(rawValue: args["ios_store_name"] as! String),
            environment: WTUserEnvironment(rawValue: args["user_environment"] as! String) ?? .production,
            logLevel: WTLogLevel(rawValue: args["log_level"] as! Int),
            trackingWaitingTime: TimeInterval(args["tracking_waiting_time"] as! Int),
            startTrackerAutomatically: args["start_tracker_automatically"] as! Bool,
            customDeviceId: args["custom_device_id"] as? String,
            defaultTracker: args["default_tracker"] as? String,
            deeplinkEnabled: args["deeplink_enabled"] as! Bool,
            attWaitingInterval: args["att_waiting_interval"] as? TimeInterval,
            requestATTAutomatically: args["request_att_automatically"] as! Bool,
        ))

        // Set deeplink listener after initialization
        WiseTrack.shared.onDeeplinkReceived { url, isDeferred in
            DispatchQueue.main.async {
                self.channel?.invokeMethod(WisetrackMethodChannel.deeplinkListener.rawValue, arguments: [
                    "url": url.absoluteString, "is_deferred": isDeferred
                ])
            }
        }
    }
    
    private func isWiseTrackNotification(args: [String: Any]) -> Bool{
        return WiseTrack.shared.isWiseTrackNotificationPayload(userInfo: args)
    }
    
    private func clearAndStop() {
        WiseTrack.shared.clearDataAndStop()
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
    
    private func getLastDeeplink() -> String? {
        return WiseTrack.shared.getLastDeeplink()
    }
    
    private func getDeferredLink() -> String? {
        return WiseTrack.shared.getDeferredDeeplink()
    }
}

// MARK: - Deep Link Handling
extension WisetrackPlugin {

    // Handle Universal Links (AppDelegate)
    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        WiseTrack.shared.handleDeepLink(with: url)
        return true
    }

    // Handle Custom URL Schemes (AppDelegate)
    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        WiseTrack.shared.handleDeepLink(with: url)
        return true
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
