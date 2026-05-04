// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

/// Visual style variants for [AppButton].
enum AppButtonStyle {
  /// Filled button with primary background.
  primary,

  /// Outlined button with transparent background and border.
  outline,

  /// Disabled/grayed-out appearance.
  disabled,
}

class AppButton extends StatelessWidget {
  final String labelText;
  final String? suffixLabelText;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry margin;
  final bool disabled, loading;

  final AppButtonStyle style;
  final BorderRadius? borderRadius;
  final Color? background;
  final Color? textColor;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final BorderSide border;

  const AppButton({
    super.key,
    required this.labelText,
    this.suffixLabelText,
    this.onPressed,
    this.leading,
    this.trailing,
    this.margin = const EdgeInsets.only(top: 16),
    this.disabled = false,
    this.loading = false,
    this.style = AppButtonStyle.primary,
    this.borderRadius,
    this.background,
    this.textColor,
    this.minWidth = 132,
    this.padding,
    this.minHeight = 60,
    this.border = BorderSide.none,
  });

  bool get _isDisabled =>
      disabled || loading || style == AppButtonStyle.disabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final onPrimary = colorScheme.onPrimary;
    final surface = colorScheme.surface;
    final onSurface = colorScheme.onSurface;
    final outlineColor = colorScheme.outline;

    Color bg;
    Color fg;
    BorderSide side;

    if (_isDisabled) {
      bg = surface;
      fg = onSurface.withValues(alpha: 0.6);
      side = BorderSide(color: outlineColor.withValues(alpha: 0.5));
    } else if (style == AppButtonStyle.outline) {
      bg = Colors.transparent;
      fg = textColor ?? primary;
      side = border == BorderSide.none ? BorderSide(color: primary) : border;
    } else {
      // primary
      bg = background ?? primary;
      fg = textColor ?? onPrimary;
      side = border;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        side: side,
      ),
      backgroundColor: bg,
      foregroundColor: fg,
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 16,
          ),
      elevation: 0,
      minimumSize: const Size(0, 40),
      padding: padding,
    );

    final labelStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 16,
          color: fg,
        );
    final suffix = trailing ??
        (suffixLabelText == null
            ? null
            : Text(
                suffixLabelText!,
                style: labelStyle.copyWith(fontWeight: FontWeight.w600),
              ));

    final button = suffix != null
        ? ElevatedButton(
            onPressed: _isDisabled ? () {} : onPressed ?? () {},
            style: buttonStyle,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loading || leading != null) ...[
                        loading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: fg),
                              )
                            : leading!,
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          labelText,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                suffix,
              ],
            ),
          )
        : loading || leading != null
            ? ElevatedButton.icon(
                onPressed: _isDisabled ? () {} : onPressed ?? () {},
                icon: loading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: fg),
                      )
                    : leading,
                style: buttonStyle,
                label: Text(labelText, style: labelStyle),
              )
            : ElevatedButton(
                onPressed: _isDisabled ? () {} : onPressed ?? () {},
                style: buttonStyle,
                child: Text(labelText, style: labelStyle),
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
