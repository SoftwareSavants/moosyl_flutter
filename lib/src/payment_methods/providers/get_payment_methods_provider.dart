import 'package:flutter/material.dart';
import 'package:software_pay/src/helpers/exception_handling/error_handlers.dart';
import 'package:software_pay/src/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/src/payment_methods/services/get_payment_methods_service.dart';

class GetPaymentMethodsProvider extends ChangeNotifier {
  final String apiKey;

  final Map<PaymentMethodTypes, void Function()>? customHandlers;
  final void Function(PaymentMethod) onSelected;

  GetPaymentMethodsProvider(
    this.apiKey,
    this.customHandlers,
    this.onSelected,
  ) {
    getMethods();
  }

  String? error;
  bool isLoading = false;

  final List<PaymentMethod> methods = [];

  List<PaymentMethodTypes> get validMethods => [
        ...methods.map((e) => e.method),
        if (customHandlers != null) ...customHandlers!.keys
      ];

  void getMethods() async {
    error = null;
    isLoading = true;

    final result = await ErrorHandlers.catchErrors(
      () => GetPaymentMethodsService(apiKey).get(),
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

  void onTap(PaymentMethodTypes type, BuildContext context) {
    {
      if (customHandlers?[type] != null) {
        customHandlers![type]!();
        return Navigator.pop(context);
      }

      onSelected(methods.firstWhere((element) => element.method == type));
    }
  }
}
