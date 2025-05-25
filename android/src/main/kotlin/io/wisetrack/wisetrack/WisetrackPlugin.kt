package io.wisetrack.wisetrack

import android.content.Context
import android.webkit.WebView
import io.wisetrack.sdk.core.WiseTrack

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.wisetrack.sdk.core.models.EventParam
import io.wisetrack.sdk.core.models.RevenueCurrency
import io.wisetrack.sdk.core.models.WTEvent
import io.wisetrack.sdk.core.models.WTEventType
import io.wisetrack.sdk.core.models.WTStoreName
import io.wisetrack.sdk.core.core.WTUserEnvironment
import io.wisetrack.sdk.core.models.WTInitialConfig
import io.wisetrack.sdk.core.utils.wrapper.ResourceWrapper
import io.wisetrack.sdk.core.models.WTLogLevel
import io.wisetrack.sdk.webbridge.WiseTrackBridge


/** WisetrackPlugin */
class WisetrackPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    //    private var activity: Activity? = null
    private lateinit var context: Context

    //    private var application: Application? = null
//    private val lifecycleHandler = AppLifecycleHandler()
    private lateinit var wiseTrack: WiseTrack

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "io.wisetrack.flutter")
        channel.setMethodCallHandler(this)

        wiseTrack = WiseTrack.getInstance(context)
        wiseTrack.addLoggerOutput(FlutterChannelOutputLogger(channel))

//        application = flutterPluginBinding.applicationContext as Application
//        application?.registerActivityLifecycleCallbacks(lifecycleHandler)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            MethodNames.INIT -> {
                initSDK(call)
                result.success(null)
            }

            MethodNames.ENABLE_TEST_MODE -> {
                enableTestMode()
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

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initSDK(call: MethodCall) {

        ResourceWrapper.setFramework("flutter")
        ResourceWrapper.setSdkHash("a90fcb36e71cecea76becc20c625e06fc30dfa00")
        ResourceWrapper.setEnvironment(call.argument<String>("sdk_env")!!)
        ResourceWrapper.setVersion(call.argument<String>("sdk_version")!!)

        val initialConfig = WTInitialConfig(
            appToken = call.argument<String>("app_token")!!,
            environment = WTUserEnvironment.valueOf(
                call.argument<String>("user_environment")!!.uppercase()
            ),
            storeName = WTStoreName.fromString(call.argument<String>("android_store_name")!!),
            trackingWaitingTime = call.argument<Int>("tracking_waiting_time")!!,
            startTrackerAutomatically = call.argument<Boolean>("start_tracker_automatically")!!,
            customDeviceId = call.argument<String?>("custom_device_id"),
            defaultTracker = call.argument<String?>("default_tracker"),
            appSecret = call.argument<String?>("app_secret"),
            secretId = call.argument<String?>("secret_id"),
            attributionDeeplink = call.argument<Boolean?>("attribution_deeplink"),
            eventBuffering = call.argument<Boolean?>("event_buffering_enabled"),
            logLevel = WTLogLevel.fromPriority(call.argument<Int>("log_level")!!),
            oaidEnabled = call.argument<Boolean>("oaid_enabled") ?: false,
            referrerEnabled = call.argument<Boolean>("referrer_enabled") ?: false,
        )

        wiseTrack.initialize(initialConfig)
        WiseTrackBridge.getInstance(context, WebView())
    }

    private fun enableTestMode() {
        /// Clear all caches and data
        wiseTrack.clearDataAndStop()
    }

    private fun setLogLevel(level: Int) {
        wiseTrack.setLogLevel(WTLogLevel.fromPriority(level))
    }

    private fun setEnabled(enabled: Boolean) {
        wiseTrack.setEnabled(enabled)
    }

    private fun isEnabled(): Boolean {
        return wiseTrack.isEnabled
    }

    private fun startTracking() {
        wiseTrack.startTracking()
    }

    private fun stopTracking() {
        wiseTrack.stopTracking()
    }

    private fun setFCMToken(token: String?) {
        if (token != null)
            wiseTrack.setFCMToken(token)
    }

    private fun setPackagesInfo() {
        wiseTrack.setPackagesInfo()
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
        wiseTrack.logEvent(event)
    }

    private fun getAdId(): String? {
        return wiseTrack.getADID()
    }


//    // ** Activity Lifecycle Methods **
//    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//        activity = binding.activity
//    }
//
//    override fun onDetachedFromActivityForConfigChanges() {
//        activity = null
//    }
//
//    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//        activity = binding.activity
//    }
//
//    override fun onDetachedFromActivity() {
//        activity = null
//    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        application?.unregisterActivityLifecycleCallbacks(lifecycleHandler)
        channel.setMethodCallHandler(null)
    }
}


