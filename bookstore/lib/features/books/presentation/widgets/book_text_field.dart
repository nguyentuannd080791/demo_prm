import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thành phần input text field chuẩn hóa của phân hệ Book
class BookTextField extends StatelessWidget {
  const BookTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.suffixText,
    this.maxLines = 1,
    this.alignLabelWithHint,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final int maxLines;
  final bool? alignLabelWithHint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixText: suffixText,
        alignLabelWithHint: alignLabelWithHint,
        prefixIcon: maxLines > 1
            ? Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Icon(prefixIcon),
              )
            : Icon(prefixIcon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
