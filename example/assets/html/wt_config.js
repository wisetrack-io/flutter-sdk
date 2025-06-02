// Enums
const WTUserEnvironment = Object.freeze({
  SANDBOX: 'SANDBOX',
  PRODUCTION: 'PRODUCTION'
});

const WTLogLevel = Object.freeze({
  DEBUG: 'DEBUG',
  INFO: 'INFO',
  WARNING: 'WARNING',
  ERROR: 'ERROR'
});

// Android StoreName Enum
const WTAndroidStoreName = {
  PLAYSTORE: Object.freeze({ value: 'playstore' }),
  CAFEBAZAAR: Object.freeze({ value: 'cafebazaar' }),
  MYKET: Object.freeze({ value: 'myket' }),
  OTHER: Object.freeze({ value: 'other' }),

  Custom(name) {
    if (typeof name !== 'string' || !name.trim()) {
      throw new Error('[WiseTrack]: Custom store name must be a non-empty string');
    }
    return Object.freeze({ value: name.trim() });
  },

  fromString(value) {
    if (typeof value !== 'string') value = String(value);

    switch (value.toLowerCase()) {
      case 'playstore': return this.PLAYSTORE;
      case 'cafebazaar': return this.CAFEBAZAAR;
      case 'myket': return this.MYKET;
      case 'other': return this.OTHER;
      default: return this.Custom(value);
    }
  }
};

// iOS StoreName Enum
const WTIOSStoreName = {
  APPSTORE: Object.freeze({ value: 'appstore' }),
  SIBCHE: Object.freeze({ value: 'sibche' }),
  SIBAPP: Object.freeze({ value: 'sibapp' }),
  ANARDONI: Object.freeze({ value: 'anardoni' }),
  SIBIRANI: Object.freeze({ value: 'sibirani' }),
  SIBJO: Object.freeze({ value: 'sibjo' }),
  OTHER: Object.freeze({ value: 'other' }),

  Custom(name) {
    if (typeof name !== 'string' || !name.trim()) {
      throw new Error('[WiseTrack]: Custom store name must be a non-empty string');
    }
    return Object.freeze({ value: name.trim() });
  },

  fromString(value) {
    if (typeof value !== 'string') value = String(value);

    switch (value.toLowerCase()) {
      case 'appstore': return this.APPSTORE;
      case 'sibche': return this.SIBCHE;
      case 'sibapp': return this.SIBAPP;
      case 'anardoni': return this.ANARDONI;
      case 'sibirani': return this.SIBIRANI;
      case 'sibjo': return this.SIBJO;
      case 'other': return this.OTHER;
      default: return this.Custom(value);
    }
  }
};

// Config Class
class WTInitConfig {
  constructor(appToken) {
    if (typeof appToken !== 'string' || !appToken.trim()) {
      throw new Error('[WiseTrack]: appToken must be a non-empty string');
    }

    this.appToken = appToken;
    this.androidStoreName = WTAndroidStoreName.OTHER;
    this.iOSStoreName = WTIOSStoreName.OTHER;
    this.userEnvironment = WTUserEnvironment.PRODUCTION;
    this.trackingWaitingTime = 0;
    this.startTrackerAutomatically = true;
    this.customDeviceId = null;
    this.defaultTracker = null;
    this.appSecret = null;
    this.secretId = null;
    this.attributionDeeplink = null;
    this.eventBuffering = null;
    this.logLevel = WTLogLevel.WARNING;
    this.oaidEnabled = false;
    this.referrerEnabled = true;
  }

  setUserEnvironment(environment) {
    if (Object.values(WTUserEnvironment).includes(environment)) {
      this.userEnvironment = environment;
    }
    return this;
  }

  setAndroidStoreName(store) {
    if (Object.values(WTAndroidStoreName).includes(storeName)) {
      this.androidStoreName = store;
    } else {
      this.androidStoreName = WTAndroidStoreName.Custom(store)
    }
    return this;
  }

  setIOSStoreName(store) {
    if (Object.values(WTIOSStoreName).includes(storeName)) {
      this.iOSStoreName = store;
    } else {
      this.iOSStoreName = WTIOSStoreName.Custom(store)
    }
    return this;
  }

  setLogLevel(level) {
    if (Object.values(WTLogLevel).includes(level)) {
      this.logLevel = level;
    }
    return this;
  }

  setTrackingWaitingTime(time) {
    if (typeof time === 'number' && time >= 0) {
      this.trackingWaitingTime = time;
    }
    return this;
  }

  setStartTrackerAutomatically(flag) {
    if (typeof flag === 'boolean') {
      this.startTrackerAutomatically = flag;
    }
    return this;
  }

  setOaidEnabled(flag) {
    if (typeof flag === 'boolean') {
      this.oaidEnabled = flag;
    }
    return this;
  }

  setCustomDeviceId(deviceId) {
    if (typeof deviceId === 'string' || deviceId === null) {
      this.customDeviceId = deviceId;
    }
    return this;
  }

  setDefaultTracker(tracker) {
    if (typeof tracker === 'string' || tracker === null) {
      this.defaultTracker = tracker;
    }
    return this;
  }

  setAppSecret(secret) {
    if (typeof secret === 'string' || secret === null) {
      this.appSecret = secret;
    }
    return this;
  }

  setSecretId(secretId) {
    if (typeof secretId === 'string' || secretId === null) {
      this.secretId = secretId;
    }
    return this;
  }

  setAttributionDeeplink(enabled) {
    if (typeof enabled === 'boolean' || enabled === null) {
      this.attributionDeeplink = enabled;
    }
    return this;
  }

  setEventBuffering(enabled) {
    if (typeof enabled === 'boolean' || enabled === null) {
      this.eventBuffering = enabled;
    }
    return this;
  }

  setReferrerEnabled(enabled) {
    if (typeof enabled === 'boolean') {
      this.referrerEnabled = enabled;
    }
    return this;
  }

  toJSON() {
    return {
      app_token: this.appToken,
      user_environment: this.userEnvironment,
      android_store_name: this.androidStoreName.value,
      ios_store_name: this.iOSStoreName.value,
      tracking_waiting_time: this.trackingWaitingTime,
      start_tracker_automatically: this.startTrackerAutomatically,
      oaid_enabled: this.oaidEnabled,
      custom_device_id: this.customDeviceId,
      default_tracker: this.defaultTracker,
      app_secret: this.appSecret,
      secret_id: this.secretId,
      attribution_deeplink: this.attributionDeeplink,
      event_buffering_enabled: this.eventBuffering,
      log_level: this.logLevel,
      referrer_enabled: this.referrerEnabled
    };
  }
}