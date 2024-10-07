import 'dart:async';

import 'package:flutter/material.dart';
import 'package:software_pay/src/helpers/exception_handling/error_handlers.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/services/get_payment_methods_service.dart';

/// A provider class for managing and retrieving payment methods.
///
/// This class extends [ChangeNotifier] to notify listeners about changes
/// in the payment methods' loading state and results.
class GetPaymentMethodsProvider extends ChangeNotifier {
  /// The API key used for authentication with the payment methods service.
  final String apiKey;

  /// The context used for displaying error messages.
  final BuildContext context;

  /// A map of custom handlers for specific payment method types.
  final Map<PaymentMethodTypes, FutureOr<void> Function()>? customHandlers;

  /// A callback function that gets called when a payment method is selected.
  final void Function(PaymentMethod) onSelected;

  /// Constructs a [GetPaymentMethodsProvider].
  ///
  /// Initiates fetching payment methods upon creation.
  GetPaymentMethodsProvider(
    this.apiKey,
    this.customHandlers,
    this.onSelected,
    this.context,
  ) {
    getMethods();
  }

  /// Holds any error messages that occur during method retrieval.
  String? error;

  /// Indicates whether the provider is currently loading data.
  bool isLoading = false;

  /// List of available payment methods.
  final List<PaymentMethod> methods = [];

  /// Retrieves the list of valid payment method types, including custom handlers.
  List<PaymentMethodTypes> get validMethods => [
        ...methods.map((e) => e.method),
        if (customHandlers != null) ...customHandlers!.keys
      ];

  /// Asynchronously fetches available payment methods from the service.
  ///
  /// Updates the loading state and handles any errors that occur during
  /// the fetching process. Notifies listeners when the data changes.
  void getMethods() async {
    error = null;
    isLoading = true;
    notifyListeners();

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentMethodsService(apiKey).get(),
      showFlashBar: false,
      context: context,
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
    if (customHandlers?[type] != null) {
      await customHandlers![type]!(); // Call the custom handler if available.

      if (context.mounted) {
        return Navigator.pop(context); // Close the context (e.g., dialog).
      }
    }

    // Find and select the payment method from the list.
    onSelected(methods.firstWhere((element) => element.method == type));
  }
}
