// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:moosyl/src/widgets/icons.dart';

class AppTextInput extends StatelessWidget {
  final String? hint;
  final String? initialValue;
  final int? maxLength;
  final int? minLines;
  final String? errorText;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsDirectional margin;
  final AppIcon? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final TextEditingController? controller;
  final bool filled;

  const AppTextInput({
    super.key,
    this.hint,
    this.initialValue,
    this.maxLength,
    this.keyboardType,
    this.onTap,
    this.validator,
    this.margin = EdgeInsetsDirectional.zero,
    this.prefixIcon,
    this.suffixIcon,
    TextInputAction? textInputAction,
    this.readOnly = false,
    this.controller,
    this.minLines,
    this.errorText,
    this.filled = true,
  });
  @override
  Widget build(BuildContext context) {
    final suffixIcon = this.suffixIcon;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 2.0,
          ),
        ),
        filled: filled,
        fillColor: Theme.of(context).colorScheme.surface,
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(),
        suffixIcon: suffixIcon is AppIcon
            ? suffixIcon.resizeForInputField()
            : suffixIcon,
        prefixIcon: prefixIcon?.resizeForInputField().apply(size: 20),
        errorMaxLines: 2,
        counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
            ),
      ),
      initialValue: initialValue,
      onTap: onTap,
      validator: validator,
      minLines: minLines,
      maxLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
    );
  }
}

class InputLabel extends StatelessWidget {
  const InputLabel({
    super.key,
    required this.label,
    this.style,
  });

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsetsDirectional.symmetric(horizontal: 16);

    return Padding(
      padding: horizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
