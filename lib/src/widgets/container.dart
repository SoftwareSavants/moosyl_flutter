// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding, margin;
  final Color? color;
  final double? height, width;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Border? border;
  final BorderDirectional? borderDirectional;
  final List<BoxShadow>? shadows;
  final BoxConstraints? constraints;
  final BoxShape shape;

  const AppContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.height,
    this.width,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.border,
    this.constraints,
    this.shadows,
    this.borderDirectional,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          padding: padding,
          constraints: constraints,
          decoration: BoxDecoration(
            shape: shape,
            color: color,
            borderRadius: shape == BoxShape.circle ? null : borderRadius,
            border: borderDirectional ?? border,
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
