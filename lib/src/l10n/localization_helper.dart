import 'package:flutter/material.dart';
import 'package:software_pay/src/l10n/app_localizations.dart';

/// A helper class that provides access to localized messages through [AppLocalizations].
///
/// The class uses the provided [BuildContext] to access the localization messages
/// via [AppLocalizations.of]. It ensures that only one instance of [LocalizationsHelper] is created.
class LocalizationsHelper {
  /// A singleton instance of [LocalizationsHelper].
  static LocalizationsHelper? _instance;

  /// The [BuildContext] used to access localization resources.
  final BuildContext context;

  /// Factory constructor that either returns an existing [LocalizationsHelper] instance
  /// or creates a new one if none exists.
  ///
  /// The [context] parameter must not be null when creating the instance for the first time.
  /// Subsequent calls can omit the context if the instance already exists.
  factory LocalizationsHelper({BuildContext? context}) {
    assert(context != null || _instance != null, 'context must not be null');

    _instance ??= LocalizationsHelper._(context!);

    return _instance!;
  }

  /// Private named constructor to initialize the class with a [BuildContext].
  LocalizationsHelper._(this.context);

  /// Returns the localized messages from [AppLocalizations] using the [context].
  ///
  /// This getter provides convenient access to the localization messages.
  AppLocalizations get msgs => AppLocalizations.of(context);

  /// Returns an instance of [AppLocalizations] for a given [context].
  ///
  /// This method can be used to retrieve localization messages in different parts
  /// of the widget tree.
  AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context);
  }
}
