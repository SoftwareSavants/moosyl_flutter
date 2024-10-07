// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

import 'package:software_pay/src/widgets/container.dart';

class AppIcon extends StatelessWidget {
  final String? path;
  final IconData? iconData;
  final double size;

  final Color? color;
  final EdgeInsetsGeometry margin;
  final bool square, useOriginalColor, isNetwork, reversIfRtl;
  final int? rotation;
  final BorderRadius? borderRadius;

  const AppIcon({
    super.key,
    this.path,
    this.iconData,
    this.size = 22,
    this.color,
    this.margin = EdgeInsets.zero,
    this.square = true,
    this.useOriginalColor = false,
    this.reversIfRtl = false,
    this.rotation,
    this.isNetwork = false,
    this.borderRadius,
  }) : assert((path != null) ^ (iconData != null));

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final iconColor = color ??
        (useOriginalColor
            ? null
            : IconTheme.of(context).color ??
                Theme.of(context).colorScheme.onSurface);

    final icon = iconData != null
        ? Icon(iconData, size: size, color: iconColor)
        : AppContainer(
            borderRadius: borderRadius,
            constraints: BoxConstraints.tightFor(
              height: square ? size : null,
              width: size,
            ),
            child: isNetwork
                ? Image.network(path!, width: size, color: iconColor)
                : Image.asset(path!, color: iconColor),
          );

    return Padding(
      padding: margin,
      child: rotation != null || reversIfRtl && isRtl
          ? RotatedBox(
              quarterTurns: rotation ?? 2,
              child: icon,
            )
          : icon,
    );
  }

  AppIcon apply({
    double? size,
    Color? color,
    EdgeInsetsGeometry? margin,
    int? rotation,
    BorderRadius? borderRadius,
    bool? isNetwork,
  }) =>
      AppIcon(
        path: path,
        iconData: iconData,
        size: size ?? this.size,
        color: color ?? this.color,
        margin: margin ?? this.margin,
        isNetwork: isNetwork ?? this.isNetwork,
        square: square,
        rotation: rotation ?? this.rotation,
        useOriginalColor: useOriginalColor,
        reversIfRtl: reversIfRtl,
        borderRadius: borderRadius ?? this.borderRadius,
      );

  AppIcon resizeForInputField({bool horizontalOnly = false}) => apply(
        margin: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: horizontalOnly ? 0 : 12,
        ),
      );
}

class AppIcons {
  //payment methods
  static const bankily = AppIcon(
    path: 'packages/software_pay/assets/icons/bankily.png',
    useOriginalColor: true,
  );
  //masrivi
  static const masrivi = AppIcon(
    path: 'packages/software_pay/assets/icons/masrivi.png',
    useOriginalColor: true,
  );
  //sedad
  static const sedad = AppIcon(
    path: 'packages/software_pay/assets/icons/sedad.png',
    useOriginalColor: true,
  );
  //bimBank
  static const bimBank = AppIcon(
    path: 'packages/software_pay/assets/icons/bim_bank.png',
    useOriginalColor: true,
  );
  //amanty
  static const amanty = AppIcon(
    path: 'packages/software_pay/assets/icons/amanty.png',
    useOriginalColor: true,
  );

  //bCIpay
  static const bCIpay = AppIcon(
    path: 'packages/software_pay/assets/icons/bci_pay.png',
    useOriginalColor: true,
  );
  //error
  static const error =
      AppIcon(path: 'packages/software_pay/assets/icons/error.png');

  //closeError ,doneError
  static const done = AppIcon(iconData: Icons.done);

  static const copy = AppIcon(iconData: Icons.copy);

  static const close = AppIcon(iconData: Icons.close);
}
