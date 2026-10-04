package io.wisetrack.wisetrack

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.wisetrack.sdk.core.WiseTrack
import io.wisetrack.sdk.core.models.WTParam
import io.wisetrack.sdk.core.models.RevenueCurrency
import io.wisetrack.sdk.core.models.WTEvent
import io.wisetrack.sdk.core.models.WTEventType
import io.wisetrack.sdk.core.models.WTInitialConfig
import io.wisetrack.sdk.core.models.WTLogLevel
import io.wisetrack.sdk.core.models.WTScreen
import io.wisetrack.sdk.core.models.WTScreenType
import io.wisetrack.sdk.core.models.WTStoreName
import io.wisetrack.sdk.core.models.WTUserEnvironment
import io.wisetrack.sdk.core.screen.WTScreenAutoTrackingConfig
import io.wisetrack.sdk.core.utils.wrapper.ResourceWrapper


/** WiseTrackPlugin */
class WiseTrackPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    companion object {
        // The native logger is process-wide; register the broadcasting output once.
        @Volatile
        private var loggerRegistered = false

        @Synchronized
        private fun registerLoggerOnce() {
            if (loggerRegistered) return
            WiseTrack.addLoggerOutput(FlutterChannelOutputLogger)
            loggerRegistered = true
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "io.wisetrack.flutter")
        channel.setMethodCallHandler(this)
        FlutterChannels.add(channel)

        WiseTrack.ensureInitialized(context)
        registerLoggerOnce()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            handleMethodCall(call, result)
        } catch (e: Exception) {
            result.error("WISETRACK_ERROR", "${call.method} failed: ${e.message}", null)
        }
    }

    private fun handleMethodCall(call: MethodCall, result: Result) {
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

            MethodNames.TRACK_EVENT -> {
                trackEvent(call)
                result.success(null)
            }

            MethodNames.TRACK_SCREEN -> {
                trackScreen(call)
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

        val appToken = requireNotNull(call.argument<String>("app_token")) { "app_token is required" }
        val clientSecret =
            requireNotNull(call.argument<String>("client_secret")) { "client_secret is required" }

        val resourceWrapper = ResourceWrapper(context)
        resourceWrapper.setFramework("flutter")
        call.argument<String>("sdk_version")?.let { resourceWrapper.setVersion(it) }

        val environment = runCatching {
            WTUserEnvironment.valueOf(call.argument<String>("user_environment")!!.uppercase())
        }.getOrDefault(WTUserEnvironment.PRODUCTION)

        val initialConfig = WTInitialConfig(
            appToken = appToken,
            clientSecret = clientSecret,
            environment = environment,
            storeName = WTStoreName.fromString(call.argument<String>("android_store_name") ?: "other"),
            trackingWaitingTime = call.argument<Int>("tracking_waiting_time") ?: 0,
            startTrackerAutomatically = call.argument<Boolean>("start_tracker_automatically") != false,
            customDeviceId = call.argument<String?>("custom_device_id"),
            defaultTracker = call.argument<String?>("default_tracker"),
            deeplinkEnabled = call.argument<Boolean?>("deeplink_enabled") != false,
            logLevel = call.argument<Int>("log_level")?.let { WTLogLevel.fromPriority(it) }
                ?: WTLogLevel.WARNING,
            oaidEnabled = call.argument<Boolean>("oaid_enabled") == true,
            screenTrackingConfig = WTScreenAutoTrackingConfig(enabled = false),
        )

        WiseTrack.initialize(context, initialConfig)

        // Set deeplink listener after initialization
        WiseTrack.setOnDeeplinkListener { intent, isDeferred ->
            FlutterChannels.broadcast(
                MethodNames.DEEPLINK_LISTENER,
                mapOf(
                    "url" to intent.dataString,
                    "is_deferred" to isDeferred
                ),
            )
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

    private fun trackEvent(call: MethodCall) {
        val eventType = WTEventType.valueOf(call.argument<String>("type")!!.uppercase())
        val eventName = call.argument<String>("name")!!
        val eventParam = toParams(call.argument<Map<String, Any?>>("params"))

        val event = when (eventType) {
            WTEventType.DEFAULT -> {
                WTEvent.defaultEvent(eventName, params = eventParam)
            }

            WTEventType.REVENUE -> {
                WTEvent.revenueEvent(
                    eventName,
                    amount = call.argument<Number>("revenue")!!.toDouble(),
                    currency = RevenueCurrency.valueOf(
                        call.argument<String>("currency")!!.uppercase()
                    ),
                    params = eventParam
                )
            }
        }
        WiseTrack.trackEvent(event)
    }

    private fun trackScreen(call: MethodCall) {
        var screenType: WTScreenType
        try {
            screenType = WTScreenType.valueOf(call.argument<String>("type")!!.uppercase())
        } catch (e: Throwable) {
            screenType = WTScreenType.OTHER
        }
        val screenName = call.argument<String>("name")!!
        val screenTrigger = call.argument<String?>("trigger")
        val screenDisplayName = call.argument<String?>("display_name")
        val screenParam = toParams(call.argument<Map<String, Any?>>("params"))

        val screen = WTScreen(
            name = screenName,
            displayName = screenDisplayName,
            type = screenType,
            params = screenParam,
            trigger = screenTrigger,
        )
        screen.isAuto = call.argument<Boolean?>("is_auto") == true
        WiseTrack.trackScreen(screen)
    }

    private fun toParams(raw: Map<String, Any?>?): Map<String, WTParam>? =
        raw?.filterValues { it != null }?.mapValues { (_, value) ->
            when (value) {
                // Dart ints arrive as Int or, beyond 32 bits, as Long.
                is Number -> WTParam(value.toDouble())
                is Boolean -> WTParam(value)
                else -> WTParam(value.toString())
            }
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
        FlutterChannels.remove(channel)
    }
}


