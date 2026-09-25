import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// The generated client also exports a `GimtelInstructions` model; only the
// method's configuration type is needed here.
import 'package:moosyl/moosyl.dart' show ConfigurationListDataInner;
import 'package:moosyl_flutter/l10n/generated/moosyl_localization.dart';
import 'package:moosyl_flutter/src/models/payment_method_model.dart';
import 'package:provider/provider.dart';

import 'gimtel_api.dart';
import 'gimtel_controller.dart';
import 'gimtel_models.dart';
import 'gimtel_phone.dart';
import 'gimtel_rich_text.dart';
import 'gimtel_walkthrough.dart';
import 'gimtel_walkthrough_data.dart';

part 'gimtel_sheet_copy_tile.dart';
part 'gimtel_sheet_parts.dart';
part 'gimtel_sheet_pay.dart';
part 'gimtel_sheet_phone.dart';

const Color _ink = Color(0xFF111827);
const Color _muted = Color(0xFF6B7280);
const Color _line = Color(0xFFE5E7EB);
const Color _danger = Color(0xFFDC2626);

/// Pays [amount] with a Gimtel transfer from the payer's [methodLabel] app
/// (e.g. "Bankily"): asks which number they pay from, shows where to send the
/// money (with the bank app's walkthrough) and waits until Moosyl sees the
/// transfer.
///
/// Resolves `true` once the payment is completed and `false` when the payer
/// leaves ("Use another method", or dismissing the phone step). Once payment
/// instructions are showing the sheet can only be left through its buttons,
/// so a stray swipe cannot abandon a transfer in progress.
Future<bool> showGimtelSheet(
  BuildContext context, {
  required GimtelApi api,
  required ConfigurationListDataInner method,
  required String methodLabel,
  required String transactionId,
  required num amount,
  required String initialPhone,
  required Color accent,
}) async {
  final completed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => GimtelController(
        api: api,
        configurationId: method.id,
        transactionId: transactionId,
        initialPhone: initialPhone,
      ),
      child: _GimtelSheet(
        key: const ValueKey('gimtel-sheet'),
        method: method,
        methodLabel: methodLabel,
        amount: amount,
        accent: accent,
      ),
    ),
  );
  return completed ?? false;
}

/// `100` -> "100 MRU", `1234.5` -> "1,234.5 MRU".
String formatMru(num amount) {
  final parts = _plainAmount(amount).split('.');
  final grouped =
      parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '${parts.length > 1 ? '$grouped.${parts[1]}' : grouped} MRU';
}

/// `100.0` -> "100": the amount as the payer types it.
String _plainAmount(num amount) => amount == amount.truncateToDouble()
    ? amount.toInt().toString()
    : amount.toString();

class _GimtelSheet extends StatefulWidget {
  const _GimtelSheet({
    super.key,
    required this.method,
    required this.methodLabel,
    required this.amount,
    required this.accent,
  });

  final ConfigurationListDataInner method;
  final String methodLabel;
  final num amount;
  final Color accent;

  @override
  State<_GimtelSheet> createState() => _GimtelSheetState();
}

class _GimtelSheetState extends State<_GimtelSheet> {
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    context.read<GimtelController>().onCompleted(() => _close(true));
  }

  /// Closes the sheet once. A completion that lands while the sheet is
  /// already on its way out (or gone) must not pop the page underneath.
  void _close(bool result) {
    if (_closed || !mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    _closed = true;
    final navigator = Navigator.of(context);
    if (route.isCurrent) {
      navigator.pop(result);
    } else {
      navigator.removeRoute(route, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MoosylLocalization.of(context)!;
    final controller = context.watch<GimtelController>();
    final instructions = controller.instructions;
    final onPhoneStep =
        controller.step == GimtelStep.phone || instructions == null;
    final error = controller.error == 'invalidPhone'
        ? l10n.gimtelInvalidPhone
        : controller.error;

    Widget body = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 32 + MediaQuery.viewInsetsOf(context).bottom),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            method: widget.method,
            title: onPhoneStep
                ? Semantics(
                    header: true,
                    hint: formatMru(widget.amount),
                    child: Text(l10n.gimtelPhoneTitle, style: _titleStyle),
                  )
                : Semantics(
                    header: true,
                    child: Text.rich(TextSpan(
                      children: gimtelRichSpans(
                        l10n.gimtelPayTitle(widget.methodLabel),
                        base: _titleStyle,
                        bold: _titleStyle.copyWith(fontWeight: FontWeight.w700),
                        gimtelBadge: (text) =>
                            GimtelBadge(text, style: _titleStyle),
                      ),
                    )),
                  ),
          ),
          const SizedBox(height: 20),
          if (onPhoneStep)
            _PhoneStep(
              methodLabel: widget.methodLabel,
              accent: widget.accent,
              error: error,
              onClose: () => _close(false),
            )
          else
            _PayStep(
              instructions: instructions,
              method: widget.method,
              methodLabel: widget.methodLabel,
              accent: widget.accent,
              error: error,
              onClose: () => _close(false),
            ),
        ],
      ),
    );

    if (!onPhoneStep) {
      // Claims vertical drags before the bottom sheet does, so the pay step
      // cannot be swiped away (scrollable content still scrolls: it sits
      // deeper and wins first).
      body = GestureDetector(
        onVerticalDragStart: (_) {},
        onVerticalDragUpdate: (_) {},
        onVerticalDragEnd: (_) {},
        child: body,
      );
    }

    // Barrier taps and back go through `maybePop`, which this blocks once
    // payment instructions are showing.
    return PopScope(canPop: onPhoneStep, child: body);
  }
}

const TextStyle _titleStyle = TextStyle(
  fontSize: 16,
  height: 1.375,
  fontWeight: FontWeight.w600,
  color: _ink,
);

class _Header extends StatelessWidget {
  const _Header({required this.method, required this.title});

  final ConfigurationListDataInner method;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    PaymentMethodTypes? type;
    try {
      type = PaymentMethodTypes.fromString(method.type);
    } on UnimplementedError {
      type = null;
    }
    return Row(
      children: [
        if (type != null) ...[
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: _line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: type.icon.apply(size: 26)),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(child: title),
      ],
    );
  }
}
