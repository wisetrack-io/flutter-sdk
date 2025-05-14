/// Public enumeration representing different User environments.
enum WTUserEnvironment { sandbox, production }

extension WTUserEnvironmentLabel on WTUserEnvironment {
  /// Returns the string representation of the user environment.
  String get label => {
        WTUserEnvironment.sandbox: 'sandbox',
        WTUserEnvironment.production: 'production',
      }[this]!;
}
