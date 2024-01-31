import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';

// ignore: prefer-match-file-name, this has a different name because of the deprecation.
class SubTitleWrapper extends SubtitleWrapper {
  @Deprecated('Renamed to SubtitleWrapper')
  const SubTitleWrapper({
    required super.videoChild,
    required super.subtitleController,
    required super.videoPlayerController,
    super.key,
    super.subtitleStyle,
    super.backgroundColor,
  });
}
