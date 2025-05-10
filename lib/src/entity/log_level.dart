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
  debug(3),

  /// Info level log, used for general information.
  info(4),

  /// Warning level log, used for potential issues or minor errors.
  warning(5),

  /// Error level log, used for critical errors or failures.
  error(6);

  /// The integer value associated with the log level.
  final int level;

  /// Private constructor for initializing a log level with an integer value.
  const WTLogLevel(this.level);
}
