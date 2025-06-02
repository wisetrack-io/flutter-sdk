var WiseTrack = (function () {
    const _bridgeName = "FlutterWiseTrackBridge";
    const _callbacks = {};

    function getCallbackId() {
        return `cb_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
    }

    function isAndroidBridgeAvailable() {
        return typeof WiseTrackBridge !== "undefined" && WiseTrackBridge !== null;
    }

    function isIOSBridgeAvailable() {
        return typeof window.webkit !== "undefined" &&
            typeof window.webkit.messageHandlers !== "undefined";
    }

    function callBridge(method, args = {}) {
        const message = { method, args };

        if (isAndroidBridgeAvailable() && typeof WiseTrackBridge[method] === "function") {
            if (args && Object.keys(args).length > 0) {
                WiseTrackBridge[method](JSON.stringify(args));
            } else {
                WiseTrackBridge[method]();
            }
        }
        else if (isIOSBridgeAvailable() && window.webkit.messageHandlers[method]) {
            window.webkit.messageHandlers[method].postMessage(args);
        }
        else if (typeof window.flutter_inappwebview !== 'undefined') {
            window.flutter_inappwebview.callHandler("FlutterWiseTrackBridge", JSON.stringify(message));
        }
        else if (typeof window.FlutterWiseTrackBridge !== 'undefined' &&
                 typeof window.FlutterWiseTrackBridge.postMessage === 'function') {
            window.FlutterWiseTrackBridge.postMessage(JSON.stringify(message));
        }
        else {
            console.error("[WiseTrack]: No bridge available");
        }
    }

    return {
        initialize(config) {
            if (!(config instanceof WTInitConfig)) {
                console.error('[WiseTrack]: Config must be an instance of WTInitConfig');
                return;
            }
            callBridge("initialize", config.toJSON());
        },

        clearDataAndStop() {
            callBridge("clearDataAndStop");
        },

        setLogLevel(level) {
            callBridge("setLogLevel", { level });
        },

        setEnabled(enabled) {
            callBridge("setEnabled", { enabled });
        },

        startTracking() {
            callBridge("startTracking");
        },

        stopTracking() {
            callBridge("stopTracking");
        },

        destroy() {
            callBridge("destroy");
        },

        setPackagesInfo() {
            callBridge("setPackagesInfo");
        },

        setFCMToken(token) {
            callBridge("setFCMToken", { token });
        },

        setAPNSToken(token) {
            callBridge("setAPNSToken", { token });
        },

        logEvent(event) {
            if (!(event instanceof WTEvent)) {
                console.warn('[WiseTrack]: Event must be an instance of WTEvent');
                return;
            }
            callBridge("logEvent", event.toJSON());
        },

        isEnabled() {
            const callbackId = getCallbackId();
            return new Promise((resolve) => {
                _callbacks[callbackId] = resolve;
                callBridge("isEnabled", { callbackId });
            });
        },

        requestForATT() {
            const callbackId = getCallbackId();
            return new Promise((resolve) => {
                _callbacks[callbackId] = resolve;
                callBridge("requestForATT", { callbackId });
            });
        },

        getIDFA() {
            const callbackId = getCallbackId();
            return new Promise((resolve) => {
                _callbacks[callbackId] = resolve;
                callBridge("getIDFA", { callbackId });
            });
        },

        getADID() {
            const callbackId = getCallbackId();
            return new Promise((resolve) => {
                _callbacks[callbackId] = resolve;
                callBridge("getADID", { callbackId });
            });
        },

        getReferrer() {
            const callbackId = getCallbackId();
            return new Promise((resolve) => {
                _callbacks[callbackId] = resolve;
                callBridge("getReferrer", { callbackId });
            });
        },

        onNativeResponse(response) {
            console.log("[WiseTrack] Native response:", response);
            if (!response || !response.callbackId) return;
            const cb = _callbacks[response.callbackId];
            if (cb) {
                cb(response.data);
                delete _callbacks[response.callbackId];
            }
        }
    };
})();
