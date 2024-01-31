part of 'subtitle_bloc.dart';

abstract class SubtitleEvent {
  const SubtitleEvent();
}

class InitSubtitles extends SubtitleEvent {
  InitSubtitles({required this.subtitleController});
  final SubtitleController subtitleController;
}

class LoadSubtitle extends SubtitleEvent {}

class UpdateLoadedSubtitle extends SubtitleEvent {
  UpdateLoadedSubtitle({this.subtitle});
  final Subtitle? subtitle;
}

class CompletedShowingSubtitles extends SubtitleEvent {}
