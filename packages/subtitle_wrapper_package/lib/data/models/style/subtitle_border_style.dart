import 'package:flutter/material.dart';

const _defaultStrokeWidth = 2.0;

class SubtitleBorderStyle {
  const SubtitleBorderStyle({
    this.strokeWidth = _defaultStrokeWidth,
    this.style = PaintingStyle.stroke,
    this.color = Colors.black,
  });
  final double strokeWidth;
  final PaintingStyle style;
  final Color color;
}
