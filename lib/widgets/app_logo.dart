import 'package:flutter/material.dart';

/// The flame mark. White by default; pass [color] to tint it.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/flame_white.png',
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
    );
  }
}
