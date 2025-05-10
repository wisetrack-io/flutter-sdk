//package io.wisetrack.wisetrack
//
//import android.app.Activity
//import android.app.Application
//import android.os.Bundle
//import com.wisetrack.sdk.WiseTrack
//
//internal class AppLifecycleHandler : Application.ActivityLifecycleCallbacks {
//    override fun onActivityResumed(activity: Activity) {
//        WiseTrack.Companion.onResume()
//    }
//
//    override fun onActivityPaused(activity: Activity) {
//        WiseTrack.Companion.onPause()
//    }
//
//    override fun onActivityStopped(activity: Activity) {}
//
//    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
//
//    override fun onActivityDestroyed(activity: Activity) {}
//
//    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
//
//    override fun onActivityStarted(activity: Activity) {}
//}