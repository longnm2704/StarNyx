import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starnyx/core/constants/core_constants.dart';

/// Rounded `#121215` text field; grows with text scale instead of a fixed
/// height. Border turns coral on error.
class StarnyxFormPillTextField extends StatefulWidget {
  const StarnyxFormPillTextField({
    required this.initialValue,
    required this.hintText,
    required this.onChanged,
    super.key,
    this.minLines = 1,
    this.maxLines = 1,
    this.hasError = false,
    this.inputFormatters,
  });

  final String initialValue;
  final String hintText;
  final int minLines;
  final int maxLines;
  final bool hasError;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  @override
  State<StarnyxFormPillTextField> createState() =>
      _StarnyxFormPillTextFieldState();
}

class _StarnyxFormPillTextFieldState extends State<StarnyxFormPillTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant StarnyxFormPillTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontFamily: AppFonts.body,
      color: AppColors.textPrimary,
      height: 1.4,
    );
    final idle = widget.hasError ? AppColors.error : AppColors.borderSubtle;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      inputFormatters: widget.inputFormatters,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: textStyle,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: textStyle?.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.surfaceLevel2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: _border(idle),
        enabledBorder: _border(idle),
        focusedBorder: _border(
          widget.hasError ? AppColors.error : AppColors.borderFocus,
        ),
      ),
    );
  }
}
