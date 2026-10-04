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
        registerSceneDelegateIfAvailable(instance, registrar: registrar)

        FlutterChannels.add(channel)
        WiseTrack.shared.prepareInitialization()
        FlutterChannelOutputLogger.registerOnce()
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        if let channel = channel {
            FlutterChannels.remove(channel)
        }
        channel = nil
    }

    private func args(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> [String: Any]? {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for \(call.method)", details: nil))
            return nil
        }
        return args
    }

    private func invalidArgument(_ name: String, _ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "Missing or invalid '\(name)' for \(call.method)",
                            details: nil))
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case WisetrackMethodChannel.initSDK.rawValue:
            guard let args = args(call, result: result) else { return }
            guard let appToken = args["app_token"] as? String else {
                return invalidArgument("app_token", call, result)
            }
            guard let clientSecret = args["client_secret"] as? String else {
                return invalidArgument("client_secret", call, result)
            }

            self.initSDK(appToken: appToken, clientSecret: clientSecret, args: args)
            result(nil)

        case WisetrackMethodChannel.clearAndStop.rawValue:
            self.clearAndStop()
            result(nil)

        case WisetrackMethodChannel.setLogLevel.rawValue:
            guard let args = args(call, result: result) else { return }
            guard let level = args["level"] as? Int else {
                return invalidArgument("level", call, result)
            }

            self.setLogLevel(level: level)
            result(nil)

        case WisetrackMethodChannel.setEnabled.rawValue:
            guard let args = args(call, result: result) else { return }
            guard let enabled = args["enabled"] as? Bool else {
                return invalidArgument("enabled", call, result)
            }

            self.setEnabled(enabled: enabled)
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
            guard let token = args["token"] as? String else {
                return invalidArgument("token", call, result)
            }

            self.setAPNSToken(apnsToken: token)
            result(nil)

        case WisetrackMethodChannel.setFCMToken.rawValue:
            guard let args = args(call, result: result) else { return }
            guard let token = args["token"] as? String else {
                return invalidArgument("token", call, result)
            }

            self.setFCMToken(fcmToken: token)
            result(nil)

        case WisetrackMethodChannel.trackEvent.rawValue:
            guard let args = args(call, result: result) else { return }

            if let error = self.trackEvent(args: args) {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: error, details: nil))
            } else {
                result(nil)
            }

        case WisetrackMethodChannel.trackScreen.rawValue:
            guard let args = args(call, result: result) else { return }
            guard let name = args["name"] as? String else {
                return invalidArgument("name", call, result)
            }

            self.trackScreen(name: name, args: args)
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

    private func initSDK(appToken: String, clientSecret: String, args: [String: Any]) {
        ResourceWrapper.setSdkFramework(framework: "flutter")
        if let sdkVersion = args["sdk_version"] as? String {
            ResourceWrapper.setSdkVersion(version: sdkVersion)
        }

        let storeName = (args["ios_store_name"] as? String).map { WTStoreName(rawValue: $0) } ?? .other
        let environment = (args["user_environment"] as? String).flatMap { WTUserEnvironment(rawValue: $0) } ?? .production
        let logLevel = (args["log_level"] as? Int).flatMap { WTLogLevel(rawValue: $0) }
        let trackingWaitingTime = (args["tracking_waiting_time"] as? NSNumber)?.doubleValue ?? 0

        WiseTrack.shared.initialize(with: WTInitialConfig(
            appToken: appToken,
            clientSecret: clientSecret,
            storeName: storeName,
            environment: environment,
            logLevel: logLevel,
            trackingWaitingTime: trackingWaitingTime,
            startTrackerAutomatically: (args["start_tracker_automatically"] as? Bool) ?? true,
            customDeviceId: args["custom_device_id"] as? String,
            defaultTracker: args["default_tracker"] as? String,
            // `deeplinkEnabled` is nullable in Dart; null means enabled.
            deeplinkEnabled: (args["deeplink_enabled"] as? Bool) ?? true,
            attWaitingInterval: (args["att_waiting_interval"] as? NSNumber)?.doubleValue,
            requestATTAutomatically: (args["request_att_automatically"] as? Bool) ?? true,
            screenTrackingConfig: WTScreenAutoTrackingConfig(enabled: false)
        ))

        // Set deeplink listener after initialization
        WiseTrack.shared.onDeeplinkReceived { url, isDeferred in
            FlutterChannels.broadcast(WisetrackMethodChannel.deeplinkListener.rawValue, arguments: [
                "url": url.absoluteString, "is_deferred": isDeferred
            ])
        }
    }

    private func isWiseTrackNotification(args: [String: Any]) -> Bool {
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

    private func params(_ raw: Any?) -> [String: WTParam]? {
        return (raw as? [String: Any])?
            .filter { !($0.value is NSNull) }
            .mapValues { WTParam.convert(value: $0) }
    }

    /// Returns an error message when the arguments are invalid.
    private func trackEvent(args: [String: Any]) -> String? {
        guard let name = args["name"] as? String else { return "Missing event name" }
        let params = self.params(args["params"])

        switch args["type"] as? String {
        case WTEventType.default.name:
            WiseTrack.shared.trackEvent(WTEvent.default(for: name, params: params))
        case WTEventType.revenue(currency: RevenueCurrency.USD, amount: 0).name:
            guard let code = args["currency"] as? String,
                  let currency = RevenueCurrency(rawValue: code) else {
                return "Unsupported revenue currency: \(args["currency"] ?? "nil")"
            }
            guard let amount = (args["revenue"] as? NSNumber)?.doubleValue else {
                return "Missing revenue amount"
            }
            WiseTrack.shared.trackEvent(WTEvent.revenue(for: name,
                                                      currency: currency,
                                                      amount: amount,
                                                      params: params))
        default:
            return "Unsupported event type: \(args["type"] ?? "nil")"
        }
        return nil
    }

    /// Maps the Dart `WTScreenType.label` (e.g. `bottom_sheet`) to the native type.
    private func screenType(_ label: String?) -> WTScreenType {
        switch label {
        case "page": return .page
        case "dialog": return .dialog
        case "bottom_sheet", "bottomSheet": return .bottomSheet
        case "web_view", "webView": return .webView
        default: return label.flatMap { WTScreenType(rawValue: $0) } ?? .other
        }
    }

    private func trackScreen(name: String, args: [String: Any]) {
        let screen = WTScreen(
            name: name,
            type: screenType(args["type"] as? String),
            displayName: args["display_name"] as? String,
            trigger: args["trigger"] as? String,
            isAuto: (args["is_auto"] as? Bool) == true,
            params: self.params(args["params"])
        )
        WiseTrack.shared.trackScreen(screen)
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

    private static var lastDeepLink: (url: URL, time: Date)?

    /// Forwards a link to the SDK once, even if both the app and the scene
    /// delegate callbacks deliver it.
    private static func handleDeepLink(_ url: URL) {
        if let last = lastDeepLink, last.url == url, Date().timeIntervalSince(last.time) < 1 {
            return
        }
        lastDeepLink = (url, Date())
        WiseTrack.shared.handleDeepLink(with: url)
    }

    private static func handleUserActivity(_ userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleDeepLink(url)
        }
    }

    // Handle Universal Links (AppDelegate)
    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]) -> Void
    ) -> Bool {
        WisetrackPlugin.handleUserActivity(userActivity)
        return false
    }

    // Handle Custom URL Schemes (AppDelegate)
    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        WisetrackPlugin.handleDeepLink(url)
        return false
    }
}

// MARK: - UIScene lifecycle
extension WisetrackPlugin {

    static func registerSceneDelegateIfAvailable(_ instance: WisetrackPlugin, registrar: FlutterPluginRegistrar) {
        let selector = NSSelectorFromString("addSceneDelegate:")
        guard let registrarObject = registrar as? NSObject,
              registrarObject.responds(to: selector),
              let sceneProtocol = NSProtocolFromString("FlutterSceneLifeCycleDelegate") else {
            return
        }
        class_addProtocol(WisetrackPlugin.self, sceneProtocol)
        _ = registrarObject.perform(selector, with: instance)
    }

    // Cold start: the launch link is delivered with the connection options.
    @objc(scene:willConnectToSession:options:)
    public func scene(_ scene: UIScene,
                      willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions?) -> Bool {
        guard let connectionOptions = connectionOptions else { return false }
        connectionOptions.urlContexts.forEach { WisetrackPlugin.handleDeepLink($0.url) }
        connectionOptions.userActivities.forEach { WisetrackPlugin.handleUserActivity($0) }
        return false
    }

    // Custom URL schemes while running.
    @objc(scene:openURLContexts:)
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        URLContexts.forEach { WisetrackPlugin.handleDeepLink($0.url) }
        return false
    }

    // Universal links while running.
    @objc(scene:continueUserActivity:)
    public func scene(_ scene: UIScene, continueUserActivity userActivity: NSUserActivity) -> Bool {
        WisetrackPlugin.handleUserActivity(userActivity)
        return false
    }
}
