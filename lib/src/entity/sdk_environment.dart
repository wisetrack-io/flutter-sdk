/// Internal enumeration representing different SDK environments.
///
/// This is used internally and should not be used directly.
enum WTSDKEnvironment {
  debug, // Debugging environment
  stage, // Staging environment (default)
  production, // Production environment
}

extension WTSDKEnvironmentLabel on WTSDKEnvironment {
  /// Returns the string representation of the SDK environment.
  String get label => {
        WTSDKEnvironment.debug: 'debug',
        WTSDKEnvironment.stage: 'stage',
        WTSDKEnvironment.production: 'production',
      }[this]!;
}
