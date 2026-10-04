import Flutter
import WiseTrackLib

/// Channels of every Flutter engine the plugin is attached to (main UI engine,
/// background isolates, add-to-app engines).
enum FlutterChannels {
    private static var channels: [FlutterMethodChannel] = []

    static func add(_ channel: FlutterMethodChannel) {
        onMain { channels.append(channel) }
    }

    static func remove(_ channel: FlutterMethodChannel) {
        onMain { channels.removeAll { $0 === channel } }
    }

    static func broadcast(_ method: String, arguments: Any?) {
        DispatchQueue.main.async {
            channels.forEach { $0.invokeMethod(method, arguments: arguments) }
        }
    }

    private static func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
}

class FlutterChannelOutputLogger: WTLoggerOutput {
    private static var registered = false

    /// The native logger is process-wide; add the broadcasting output only once.
    static func registerOnce() {
        guard !registered else { return }
        registered = true
        WTLogger.shared.addOutput(output: FlutterChannelOutputLogger())
    }

    func log(level: WiseTrackLib.WTLogLevel, message: String, error: (any Error)?) {
        FlutterChannels.broadcast(WisetrackMethodChannel.log.rawValue, arguments: [
            "level": level.rawValue, "message": message
        ])
    }
}
