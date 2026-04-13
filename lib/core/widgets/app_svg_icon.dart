import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Small wrapper around SvgPicture to keep icon rendering consistent.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon({
    required this.assetPath,
    super.key,
    this.size = 24,
    this.color,
    this.semanticsLabel,
  });

  final String assetPath;
  final double size;
  final Color? color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      semanticsLabel: semanticsLabel,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
