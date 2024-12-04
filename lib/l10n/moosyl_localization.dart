import 'package:flutter/material.dart';

import 'generated/moosyl_localization.dart' as ml;

/// A class that provides localization support for the Moosyl package.
///
/// This class contains a static constant [delegate] which is used to load
/// the localized resources for the application.
///
/// Example usage:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [MoosylLocalization.delegate],
///   // other properties...
/// )
/// ```
class MoosylLocalization {
  /// A delegate that provides localization support for the Moosyl package.
  static const LocalizationsDelegate<ml.MoosylLocalization> delegate =
      ml.MoosylLocalization.delegate;

  /// A list of delegates that provide localization support for the Moosyl package, Material, and Cupertino.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      ml.MoosylLocalization.localizationsDelegates;

  /// A list of supported locales for the Moosyl package.
  static const List<Locale> supportedLocales =
      ml.MoosylLocalization.supportedLocales;

  /// Retrieves the [MoosylLocalization] instance from the given [context].
  static ml.MoosylLocalization? of(BuildContext context) {
    return ml.MoosylLocalization.of(context);
  }
}
