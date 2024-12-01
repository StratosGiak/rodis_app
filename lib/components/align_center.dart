import 'package:flutter/material.dart';

class AlignCenter extends StatelessWidget {
  const AlignCenter({super.key, required this.alignment, required this.child});

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionalTranslation(
        translation: Offset(alignment.x / 2, alignment.y / 2),
        child: child,
      ),
    );
  }
}
