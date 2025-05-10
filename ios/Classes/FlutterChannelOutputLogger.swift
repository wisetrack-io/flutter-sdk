import Flutter
import WiseTrackLib

class FlutterChannelOutputLogger: WTLoggerOutput {
    private let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    func log(level: WiseTrackLib.WTLogLevel, message: String, error: (any Error)?) {
        DispatchQueue.main.async {
            self.channel.invokeMethod(WisetrackMethodChannel.log.rawValue, arguments: [
                "level": level.rawValue, "message": message
            ])
        }
    }
}
