// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String labelText;
  final Widget? leading;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry margin;
  final bool disabled, loading;

  final BorderRadius? borderRadius;
  final Color? background;
  final Color? textColor;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.labelText,
    this.onPressed,
    this.leading,
    this.margin = const EdgeInsets.only(top: 16),
    this.disabled = false,
    this.loading = false,
    this.borderRadius,
    this.background,
    this.textColor,
    this.minWidth = 132,
    this.padding,
    this.minHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    final background = loading || disabled
        ? Theme.of(context).colorScheme.surface
        : (this.background ?? Theme.of(context).colorScheme.primary);

    final foregroundColor = loading || disabled
        ? Theme.of(context).colorScheme.onSurface
        : textColor ?? Theme.of(context).colorScheme.onPrimary;

    final buttonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      backgroundColor: background,
      foregroundColor: foregroundColor,
      textStyle: Theme.of(context).textTheme.titleSmall,
      elevation: 0,
      minimumSize: const Size(0, 40),
      padding: padding,
    );

    final button = loading || leading != null
        ? ElevatedButton.icon(
            onPressed: disabled || loading ? () {} : onPressed ?? () {},
            icon: loading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: foregroundColor),
                  )
                : leading,
            style: buttonStyle,
            label: Text(labelText),
          )
        : ElevatedButton(
            onPressed: disabled || loading ? () {} : onPressed ?? () {},
            style: buttonStyle,
            child: Text(labelText),
          );

    return Padding(
      padding: margin,
      child: minWidth != null
          ? ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth!,
                minHeight: minHeight!,
              ),
              child: button,
            )
          : button,
    );
  }
}
