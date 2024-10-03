import 'package:flutter/material.dart';
import 'package:software_pay/helpers/exception_handling/error_handlers.dart';
import 'package:software_pay/payment_methods/models/operation_model.dart';
import 'package:software_pay/payment_methods/models/payment_method_model.dart';
import 'package:software_pay/payment_methods/services/get_operation_service.dart';
import 'package:software_pay/payment_methods/services/pay_service.dart';

class PayProvider extends ChangeNotifier {
  final String apiKey;
  final String operationId;
  final PaymentMethod method;
  final VoidCallback? onPaymentSuccess;

  PayProvider({
    required this.apiKey,
    required this.method,
    required this.operationId,
    this.onPaymentSuccess,
  }) {
    getOperation();
  }

  final passCodeTextController = TextEditingController();
  final phoneNumberTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  OperationModel? operation;

  String? error;
  bool isLoading = false;

  void getOperation() async {
    error = null;
    isLoading = true;

    final result = await ErrorHandlers.catchErrors(
      () => GetOperationService(apiKey).get(operationId),
      showFlashBar: false,
    );

    isLoading = false;

    if (result.isError) {
      error = result.error;

      return notifyListeners();
    }

    operation = result.result;

    notifyListeners();
  }

  void pay(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    error = null;
    isLoading = true;
    notifyListeners();

    await ErrorHandlers.catchErrors(
      () => PayService(apiKey).pay(
        operationId: operationId,
        paymentMethodId: method.id,
        passCode: passCodeTextController.text,
        phoneNumber: phoneNumberTextController.text,
      ),
      context: context,
    );

    isLoading = false;
  }
}
