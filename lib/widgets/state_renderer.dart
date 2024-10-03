import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_pay/helpers/exception_handling/exception_mapper.dart';
import 'package:software_pay/widgets/error_widget.dart';

class AsyncValueRenderer<T> extends StatelessWidget {
  final AsyncValue<T> state;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget? Function(String, VoidCallback)? errorWidgetBuilder;
  final bool withScaffold, horizontalAxis;
  final VoidCallback onRetry;

  const AsyncValueRenderer({
    super.key,
    required this.state,
    required this.builder,
    required this.onRetry,
    this.loadingWidget,
    this.withScaffold = false,
    this.horizontalAxis = false,
    this.errorWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AsyncData() => builder(state.value as T),
      AsyncError() => errorWidgetBuilder?.call(
            ExceptionMapper.mapException(state.error),
            onRetry,
          ) ??
          AppErrorWidget(
            withScaffold: withScaffold,
            message: ExceptionMapper.mapException(state.error),
            horizontalAxis: horizontalAxis,
            onRetry: onRetry,
          ),
      AsyncLoading() when loadingWidget != null => loadingWidget!,
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
