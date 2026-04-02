package io.wisetrack.wisetrack

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.wisetrack.sdk.core.WiseTrack
import io.wisetrack.sdk.core.models.DeeplinkCallback
import io.wisetrack.sdk.core.models.EventParam
import io.wisetrack.sdk.core.models.RevenueCurrency
import io.wisetrack.sdk.core.models.WTEvent
import io.wisetrack.sdk.core.models.WTEventType
import io.wisetrack.sdk.core.models.WTInitialConfig
import io.wisetrack.sdk.core.models.WTLogLevel
import io.wisetrack.sdk.core.models.WTStoreName
import io.wisetrack.sdk.core.models.WTUserEnvironment
import io.wisetrack.sdk.core.utils.wrapper.ResourceWrapper


/** WiseTrackPlugin */
class WiseTrackPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "io.wisetrack.flutter")
        channel.setMethodCallHandler(this)

        WiseTrack.ensureInitialized(context)
        WiseTrack.addLoggerOutput(FlutterChannelOutputLogger(channel))

//        application = flutterPluginBinding.applicationContext as Application
//        application?.registerActivityLifecycleCallbacks(lifecycleHandler)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        WiseTrack.ensureInitialized(context)

        when (call.method) {
            MethodNames.INIT -> {
                initSDK(call)
                result.success(null)
            }

            MethodNames.CLEAR_AND_STOP -> {
                clearDataAndStop()
                result.success(null)
            }

            MethodNames.SET_LOG_LEVEL -> {
                val level = call.argument<Int>("level") ?: 0
                setLogLevel(level)
                result.success(null)
            }

            MethodNames.SET_ENABLED -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                setEnabled(enabled)
                result.success(null)
            }

            MethodNames.IS_ENABLED -> {
                val enabled = isEnabled()
                result.success(enabled)
            }

            MethodNames.IOS_REQUEST_FOR_ATT -> {
                // Not for android platform
                result.success(false)
            }

            MethodNames.START_TRACKING -> {
                startTracking()
                result.success(null)
            }

            MethodNames.STOP_TRACKING -> {
                stopTracking()
                result.success(null)
            }

            MethodNames.SET_APNS_TOKEN -> {
                // APNS is not used in Android!
                result.success(null)
            }

            MethodNames.SET_FCM_TOKEN -> {
                val token = call.argument<String>("token")
                setFCMToken(token)
                result.success(null)
            }

            MethodNames.SET_PACKAGES_INFO -> {
                setPackagesInfo()
                result.success(null)
            }

            MethodNames.LOG_EVENT -> {
                logEvent(call)
                result.success(null)
            }

            MethodNames.GET_ADID -> {
                // Not for android platform
                val adid = getAdId()
                result.success(adid)
            }

            MethodNames.GET_IDFA -> {
                // Not for android platform
                result.success(null)
            }

            MethodNames.GET_REFERRER -> {
                val referrer = getReferrer()
                result.success(referrer)
            }

            MethodNames.GET_LAST_DEEPLINK -> {
                val link = getLastDeeplink()
                result.success(link)
            }

            MethodNames.GET_DEFERRED_LINK -> {
                val link = getDeferredDeeplink()
                result.success(link)
            }

            MethodNames.IS_WISETRACK_NOTIFICATION -> {
                val isWiseTrackNotification = isWiseTrackNotification(call)
                result.success(isWiseTrackNotification)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initSDK(call: MethodCall) {

        val resourceWrapper = ResourceWrapper(context)
        resourceWrapper.setFramework("flutter")
        resourceWrapper.setEnvironment(call.argument<String>("sdk_env")!!)
        resourceWrapper.setVersion(call.argument<String>("sdk_version")!!)

        val initialConfig = WTInitialConfig(
            appToken = call.argument<String>("app_token")!!,
            clientSecret = call.argument<String>("client_secret")!!,
            environment = WTUserEnvironment.valueOf(
                call.argument<String>("user_environment")!!.uppercase()
            ),
            storeName = WTStoreName.fromString(call.argument<String>("android_store_name")!!),
            trackingWaitingTime = call.argument<Int>("tracking_waiting_time")!!,
            startTrackerAutomatically = call.argument<Boolean>("start_tracker_automatically")!!,
            customDeviceId = call.argument<String?>("custom_device_id"),
            defaultTracker = call.argument<String?>("default_tracker"),
            deeplinkEnabled = call.argument<Boolean?>("deeplink_enabled") ?: true,
            logLevel = WTLogLevel.fromPriority(call.argument<Int>("log_level")!!),
            oaidEnabled = call.argument<Boolean>("oaid_enabled") ?: false,
        )

        WiseTrack.initialize(context, initialConfig)

        // Set deeplink listener after initialization
        WiseTrack.setOnDeeplinkListener { intent, isDeferred ->
            Handler(Looper.getMainLooper()).post {
                channel.invokeMethod(
                    MethodNames.DEEPLINK_LISTENER,
                    mapOf(
                        "url" to intent.dataString,
                        "is_deferred" to isDeferred
                    ),
                )
            }
        }
    }

    private fun clearDataAndStop() {
        /// Clear all caches and data
        WiseTrack.clearDataAndStop()
    }

    private fun setLogLevel(level: Int) {
        WiseTrack.setLogLevel(WTLogLevel.fromPriority(level))
    }

    private fun setEnabled(enabled: Boolean) {
        WiseTrack.setEnabled(enabled)
    }

    private fun isEnabled(): Boolean {
        return WiseTrack.isEnabled
    }

    private fun startTracking() {
        WiseTrack.startTracking()
    }

    private fun stopTracking() {
        WiseTrack.stopTracking()
    }

    private fun setFCMToken(token: String?) {
        if (token != null)
            WiseTrack.setFCMToken(token)
    }

    private fun setPackagesInfo() {
        WiseTrack.setPackagesInfo()
    }

    private fun logEvent(call: MethodCall) {
        val eventType = WTEventType.valueOf(call.argument<String>("type")!!.uppercase())
        val eventName = call.argument<String>("name")!!
        val eventParam = call.argument<Map<String, Any>>("params")?.mapValues {
            when (it.value) {
                is Int -> EventParam((it.value as Int).toDouble())
                is Double -> EventParam(it.value as Double)
                is Boolean -> EventParam(it.value as Boolean)
                else -> EventParam(it.value.toString())
            }
        }

        val event = when (eventType) {
            WTEventType.DEFAULT -> {
                WTEvent.defaultEvent(eventName, params = eventParam)
            }

            WTEventType.REVENUE -> {
                WTEvent.revenueEvent(
                    eventName,
                    amount = call.argument<Double>("revenue")!!,
                    currency = RevenueCurrency.valueOf(
                        call.argument<String>("currency")!!.uppercase()
                    ),
                    params = eventParam
                )
            }
        }
        WiseTrack.logEvent(event)
    }

    private fun getAdId(): String? {
        return WiseTrack.getADID()
    }

    private fun getReferrer(): String? {
        return WiseTrack.getReferrer()
    }

    private fun getLastDeeplink(): String? {
        return WiseTrack.getLastDeeplink()
    }

    private fun getDeferredDeeplink(): String? {
        return WiseTrack.getDeferredDeeplink()
    }

    private fun isWiseTrackNotification(call: MethodCall): Boolean? {
        try {
            if (call.arguments !is Map<*, *>) return false
            val payload = (call.arguments as Map<*, *>)
                .mapKeys { (key, _) -> key.toString() }
                .mapValues { (_, value) -> value.toString() }
            return WiseTrack.isWiseTrackNotificationPayload(payload)

        } catch (_: Exception) {
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}


