import 'package:flutter/material.dart';
import 'package:software_pay/widgets/icons.dart';

class AppErrorWidget extends StatelessWidget {
  final String? message;
  final String? description;
  final void Function()? onRetry;
  final double bottomPadding;
  final bool horizontalAxis;
  final bool withScaffold;
  final EdgeInsetsDirectional buttonMargin;

  const AppErrorWidget({
    super.key,
    this.message,
    this.description,
    this.onRetry,
    this.horizontalAxis = false,
    this.bottomPadding = 0,
    this.withScaffold = false,
    this.buttonMargin = const EdgeInsetsDirectional.only(top: 16),
  });

  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (horizontalAxis) {
      child = InkWell(
        onTap: onRetry,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.error.apply(size: 24.0),
            const SizedBox(height: 16, width: 8),
            //TODO: Add a localized text
            const Text("context.l10n.retry"),
          ],
        ),
      );
    } else {
      child = Padding(
        padding: const EdgeInsets.all(20).add(
          EdgeInsets.only(bottom: bottomPadding),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcons.error.apply(size: 56.0),
            const SizedBox(height: 16),
            if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.titleLarge!,
                textAlign: TextAlign.center,
              ),
            if (description != null) ...[
              const SizedBox(
                height: 4,
                width: 4,
              ),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              ElevatedButton(
                onPressed: onRetry,
                //TODO: Add a localized text
                child: const Text("retry"),
              ),
            ]
          ],
        ),
      );
    }

    return Center(
      child: withScaffold ? Scaffold(body: child) : child,
    );
  }
}
