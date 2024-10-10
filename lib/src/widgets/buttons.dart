// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String labelText;
  final Widget? leading;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry margin;
  final bool disabled;

  final BorderRadius? borderRadius;
  final Color? background;
  final Color? textColor;
  final double? minWidth;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.labelText,
    this.onPressed,
    this.leading,
    this.margin = const EdgeInsets.only(top: 16),
    this.disabled = false,
    this.borderRadius,
    this.background,
    this.textColor,
    this.minWidth = 132,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      backgroundColor: background ?? Theme.of(context).colorScheme.primary,
      foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
      textStyle: Theme.of(context).textTheme.titleSmall,
      elevation: 0,
      minimumSize: const Size(0, 40),
      padding: padding,
    );

    final button = ElevatedButton(
      onPressed: disabled ? () {} : onPressed ?? () {},
      style: buttonStyle,
      child: Text(labelText),
    );

    return Padding(
      padding: margin,
      child: minWidth != null
          ? ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth!,
                minHeight: 80,
              ),
              child: button,
            )
          : button,
    );
  }
}
