import 'package:flutter/material.dart';
import 'package:software_pay/helpers/exception_handling/error_handlers.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/payment_methods/services/get_payment_methods_service.dart';

class GetPaymentMethodsProvider extends ChangeNotifier {
  final String apiKey;
  final BuildContext context;

  GetPaymentMethodsProvider(this.apiKey, this.context) {
    getMethods();
  }

  String? error;
  bool isLoading = false;

  final List<PaymentMethod> methods = [];

  void getMethods() async {
    error = null;
    isLoading = true;

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentMethodsService(apiKey).get(),
      context,
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;

      return notifyListeners();
    }

    methods.addAll(result.result!);

    notifyListeners();
  }
}
