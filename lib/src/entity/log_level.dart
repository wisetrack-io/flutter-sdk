import 'package:wisetrack/src/resources/resources.dart';

/// Represents the log levels used for logging events within the application.
///
/// This enum defines different log levels for categorizing logs with varying severity:
/// - **debug**: Logs used for debugging purposes (lowest severity).
/// - **info**: Informational logs for general application state.
/// - **warning**: Logs indicating potential issues that are not critical.
/// - **error**: Logs indicating an error or critical issue in the application (highest severity).
///
/// Each log level is associated with a specific integer value for easy comparison and filtering.
enum WTLogLevel {
  /// Debug level log, used for detailed information during debugging.
  debug,

  /// Info level log, used for general information.
  info,

  /// Warning level log, used for potential issues or minor errors.
  warning,

  /// Error level log, used for critical errors or failures.
  error
}

extension WTLogLevelPriority on WTLogLevel {
  /// Returns the log level priority.
  int get level => {
        WTLogLevel.debug: 3,
        WTLogLevel.info: 4,
        WTLogLevel.warning: 5,
        WTLogLevel.error: 6,
      }[this]!;

  /// Returns the string representation of the log level.
  String get label => {
        WTLogLevel.debug: 'debug',
        WTLogLevel.info: 'info',
        WTLogLevel.warning: 'warning',
        WTLogLevel.error: 'error',
      }[this]!;

  static WTLogLevel fromString(String level) {
    return WTLogLevel.values.firstWhere(
      (v) => v.label.toLowerCase() == level.toLowerCase(),
      orElse: () => WTResources.defaultLogLevel,
    );
  }
}
