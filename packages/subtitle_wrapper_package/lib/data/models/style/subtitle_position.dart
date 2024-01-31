const _defaultSubtitleBottomPosition = 50.0;

class SubtitlePosition {
  const SubtitlePosition({
    this.left = 0.0,
    this.right = 0.0,
    this.top,
    this.bottom = _defaultSubtitleBottomPosition,
  });
  final double left;
  final double right;
  final double? top;
  final double bottom;
}
