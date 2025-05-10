package io.wisetrack.wisetrack

import io.flutter.plugin.common.MethodChannel
import io.wisetrack.sdk.core.models.WTLogLevel
import io.wisetrack.sdk.core.utils.WTLoggerOutput
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class FlutterChannelOutputLogger(private val channel: MethodChannel) : WTLoggerOutput {

    override fun log(level: WTLogLevel, tag: String, message: String, throwable: Throwable?) {
        MainScope().launch(Dispatchers.Main) {
            channel.invokeMethod(
                MethodNames.LOG, mapOf(
                    "level" to level.priority, "message" to message
                )
            )
        }
    }

}