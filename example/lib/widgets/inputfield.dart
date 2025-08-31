import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String title;
  final String? initialValue;
  final Function(String)? onChanged;
  final String? hint;
  final TextInputType? inputType;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String?>? validator;
  const CustomInputField({
    required this.title,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.inputType,
    this.maxLines,
    this.textInputAction,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: inputType,
          decoration: InputDecoration(hintText: hint),
          maxLines: maxLines,
          textInputAction: textInputAction,
          validator: validator,
        ),
      ],
    );
  }
}
