// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moosyl/l10n/generated/moosyl_localization.dart';

import 'package:moosyl/src/widgets/icons.dart';

class Feedbacks {
  static void flushBar({
    required String message,
    required BuildContext context,
    bool error = true,
  }) {
    double margin;

    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      margin = 24;
    } else {
      margin = (width - 600) / 2;
    }

    final snackBar = SnackBar(
      closeIconColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.onSurface,
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
      elevation: 0.0,
      margin: EdgeInsets.symmetric(
        horizontal: margin,
      ).copyWith(bottom: 24),
      content: Row(
        children: [
          (error ? AppIcons.error : AppIcons.done).apply(
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.onSurface,
              size: 24,
              margin: const EdgeInsets.symmetric(horizontal: 8)),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static copy(String description, BuildContext context) {
    Clipboard.setData(ClipboardData(text: description));
    Feedbacks.flushBar(
      context: context,
      message: MoosylLocalization.of(context)!.copiedThisText,
      error: false,
    );
  }
}
