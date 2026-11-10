package io.wisetrack.wisetrack

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import io.wisetrack.sdk.core.models.WTLogLevel
import io.wisetrack.sdk.core.resources.WTLoggerOutput
import java.util.concurrent.CopyOnWriteArraySet

/**
 * Channels of every Flutter engine the plugin is attached to (main UI engine,
 * background isolates such as FCM handlers, add-to-app engines).
 *
 * Native SDK callbacks are process-wide, so they are registered once and
 * broadcast to all attached engines; each engine forwards them to Dart only if
 * it registered a listener there.
 */
object FlutterChannels {
    private val channels = CopyOnWriteArraySet<MethodChannel>()
    private val mainHandler = Handler(Looper.getMainLooper())

    fun add(channel: MethodChannel) {
        channels.add(channel)
    }

    fun remove(channel: MethodChannel) {
        channels.remove(channel)
    }

    fun broadcast(method: String, arguments: Any?) {
        mainHandler.post {
            channels.forEach { it.invokeMethod(method, arguments) }
        }
    }
}

object FlutterChannelOutputLogger : WTLoggerOutput {

    override fun log(level: WTLogLevel, tag: String, message: String, throwable: Throwable?) {
        FlutterChannels.broadcast(
            MethodNames.LOG, mapOf(
                "level" to level.priority,
                "message" to message
            )
        )
    }
}
