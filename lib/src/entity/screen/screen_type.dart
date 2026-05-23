part of 'screen.dart';

/// The visual presentation style of a tracked screen.
enum WTScreenType {
  /// A standard full-page route pushed onto the navigation stack.
  page,

  /// A dialog or popup presented over existing content (e.g. via [showDialog]).
  dialog,

  /// A modal bottom sheet (e.g. via [showModalBottomSheet]).
  bottomSheet,

  /// Any other presentation style not covered by the above values.
  other,
}

extension WTScreenTypeLabel on WTScreenType {
  /// Returns the string representation of the screen type.
  String get label => {
        WTScreenType.page: 'page',
        WTScreenType.dialog: 'dialog',
        WTScreenType.bottomSheet: 'bottom_sheet',
        WTScreenType.other: 'other',
      }[this]!;
}
