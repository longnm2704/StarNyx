import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starnyx/core/constants/core_constants.dart';

class StarnyxFormPillTextField extends StatefulWidget {
  const StarnyxFormPillTextField({
    required this.initialValue,
    required this.hintText,
    required this.maxLines,
    required this.onChanged,
    super.key,
    this.hasError = false,
    this.height = AppSize.inputMinHeight,
    this.inputFormatters,
  });

  final String initialValue;
  final String hintText;
  final int maxLines;
  final bool hasError;
  final double height;
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

  @override
  Widget build(BuildContext context) {
    final isMultiLine = widget.maxLines > 1;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
      height: 1,
    );
    final hintStyle = textStyle?.copyWith(color: AppColors.textMuted);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: widget.hasError
              ? AppColors.accentPink
              : AppColors.outline.withValues(alpha: 0.58),
        ),
      ),
      child: isMultiLine
          ? TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              inputFormatters: widget.inputFormatters,
              minLines: widget.maxLines,
              maxLines: widget.maxLines,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              textAlignVertical: TextAlignVertical.top,
              style: textStyle,
              cursorColor: AppColors.textPrimary,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hintText,
                hintStyle: hintStyle,
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onChanged,
                    inputFormatters: widget.inputFormatters,
                    maxLines: 1,
                    minLines: 1,
                    onTapOutside: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    textAlignVertical: TextAlignVertical.center,
                    style: textStyle,
                    cursorColor: AppColors.textPrimary,
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      hintText: widget.hintText,
                      hintStyle: hintStyle,
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
