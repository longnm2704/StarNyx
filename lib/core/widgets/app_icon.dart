import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Shared wrapper around Hugeicons stroke-rounded glyphs to keep icon rendering
// consistent. Icon data is passed in by callers, who import only
// `package:hugeicons/styles/stroke_rounded.dart` so unused styles are
// tree-shaken. The renderer is self-contained to avoid pulling in
// `package:hugeicons/hugeicons.dart`.
class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.icon,
    super.key,
    this.color,
    this.size = 24,
    this.strokeWidth,
    this.semanticsLabel,
  });

  final List<List<dynamic>> icon;
  final Color? color;
  final double size;
  final double? strokeWidth;
  final String? semanticsLabel;

  // Below this size the default 1.5 stroke is hard to read, so bump it.
  static const double smallSizeThreshold = 14;
  static const double smallStrokeWidth = 2.0;

  static final RegExp _upperCase = RegExp(r'[A-Z]');

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveColor =
        color ??
        iconTheme.color ??
        DefaultTextStyle.of(context).style.color ??
        Theme.of(context).colorScheme.onSurface;
    final effectiveStrokeWidth =
        strokeWidth ?? (size < smallSizeThreshold ? smallStrokeWidth : null);

    final iconWidget = SvgPicture.string(
      buildSvg(icon, effectiveColor, effectiveStrokeWidth),
      width: size,
      height: size,
    );
    if (semanticsLabel == null) {
      return iconWidget;
    }
    return Semantics(label: semanticsLabel, image: true, child: iconWidget);
  }

  static String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

  @visibleForTesting
  static String buildSvg(
    List<List<dynamic>> iconData,
    Color primaryColor,
    double? strokeWidthOverride,
  ) {
    final buffer = StringBuffer()
      ..write(
        '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" '
        'xmlns="http://www.w3.org/2000/svg">',
      );

    for (final element in iconData) {
      final tagName = element[0] as String;
      final attributes = element[1] as Map<String, dynamic>;

      buffer.write('<$tagName');

      bool hasStrokeColor = false;
      bool hasFillColor = false;

      for (final entry in attributes.entries) {
        final key = entry.key;
        final value = entry.value;

        if (key == 'key') {
          continue;
        }

        String finalValue = value.toString();
        if (key == 'stroke' && value == 'currentColor') {
          finalValue = _hex(primaryColor);
          hasStrokeColor = true;
        } else if (key == 'fill' && value == 'currentColor') {
          finalValue = _hex(primaryColor);
          hasFillColor = true;
        } else if (key == 'strokeWidth' && strokeWidthOverride != null) {
          finalValue = strokeWidthOverride.toString();
        }

        final svgAttrName = key.replaceAllMapped(
          _upperCase,
          (m) => '-${m[0]!.toLowerCase()}',
        );

        buffer.write(' $svgAttrName="$finalValue"');
      }

      final alpha = primaryColor.a;
      if (hasStrokeColor && alpha < 1.0) {
        buffer.write(' stroke-opacity="$alpha"');
      }
      if (hasFillColor && alpha < 1.0) {
        buffer.write(' fill-opacity="$alpha"');
      }

      buffer.write('/>');
    }

    buffer.write('</svg>');
    return buffer.toString();
  }
}
