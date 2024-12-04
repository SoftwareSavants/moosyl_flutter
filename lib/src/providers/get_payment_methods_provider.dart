import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moosyl/src/helpers/exception_handling/error_handlers.dart';
import 'package:moosyl/src/models/payment_method_model.dart';
import 'package:moosyl/src/services/get_payment_methods_service.dart';

/// A provider class for managing and retrieving payment methods.
///
/// This class extends [ChangeNotifier] to notify listeners about changes
/// in the payment methods' loading state and results.
class GetPaymentMethodsProvider extends ChangeNotifier {
  /// The API key used for authentication with the payment methods service.
  final String publishableApiKey;

  /// A map of custom handlers for specific payment method types.
  final Map<PaymentMethodTypes, FutureOr<void> Function()> customHandlers;

  /// A map of custom icons for specific payment method types.
  final Map<PaymentMethodTypes, String>? customIcons;

  /// A callback function that gets called when a payment method is selected.
  PaymentMethod? selected;

  /// The payment method selected for the payment process.
  final bool isTestingMode;

  /// Constructs a [GetPaymentMethodsProvider].

  /// Initiates fetching payment methods upon creation.
  GetPaymentMethodsProvider({
    required this.customHandlers,
    required this.publishableApiKey,
    required this.isTestingMode,
    required this.customIcons,
  }) {
    getMethods();
  }

  /// Holds any error messages that occur during method retrieval.
  Object? error;

  /// Indicates whether the provider is currently loading data.
  bool isLoading = false;

  /// List of available payment methods.
  final List<PaymentMethod> methods = [];

  /// Retrieves the list of supported payment method types.
  List<PaymentMethodTypes> get supportedTypes {
    return [...methods.map((method) => method.method), ...customHandlers.keys];
  }

  /// Retrieves the list of valid payment method types, including custom handlers.
  List<PaymentMethodTypes> get validMethods =>
      [...methods.map((e) => e.method), ...customHandlers.keys];

  /// Asynchronously fetches available payment methods from the service.
  ///
  /// Updates the loading state and handles any errors that occur during
  /// the fetching process. Notifies listeners when the data changes.
  void getMethods() async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentMethodsService(publishableApiKey).get(isTestingMode),
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;

      return notifyListeners();
    }

    // Add the retrieved methods to the methods list.
    methods.addAll(result.result!);

    // Notify listeners of the change in payment methods.
    notifyListeners();
  }

  /// Handles tap events for selecting a payment method type.
  ///
  /// If a custom handler is defined for the tapped payment method,
  /// it invokes the handler. Otherwise, it selects the corresponding
  /// payment method from the list and calls the [onSelected] callback.
  void onTap(PaymentMethodTypes type, BuildContext context) async {
    if (customHandlers[type] != null) {
      await customHandlers[type]!(); // Call the custom handler if available.

      if (context.mounted) {
        return Navigator.pop(context); // Close the context (e.g., dialog).
      }
    }

    // Find and select the payment method from the list.
    final selected = methods.firstWhere((element) => element.method == type);

    setPaymentMethod(selected);
  }

  /// Sets the selected payment method.
  void setPaymentMethod(PaymentMethod? method) {
    selected = method;
    notifyListeners();
  }
}
