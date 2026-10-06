import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? inputType;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChange;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.inputType,
    this.onTap,
    this.onChange,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.focusNode,
    this.autofillHints,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.07,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFC8C7D4),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            enabled: enabled,
            readOnly: readOnly,
            maxLines: obscureText ? 1 : maxLines,
            minLines: minLines,
            obscuringCharacter: '•',
            keyboardType: inputType,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintStyle: const TextStyle(
                color: Color(0xFF9894BE),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              hintText: hint,
            ),
            onTap: onTap,
            onChanged: onChange,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            inputFormatters: [
              if (inputType == TextInputType.phone)
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
            ],
            textInputAction: textInputAction,
            autofillHints: autofillHints,
          ),
        ),
      ],
    );
  }
}
