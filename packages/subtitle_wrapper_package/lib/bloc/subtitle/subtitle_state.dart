part of 'subtitle_bloc.dart';

abstract class SubtitleState extends Equatable {
  const SubtitleState();
}

class SubtitleInitial extends SubtitleState {
  @override
  List<Object> get props => [];
}

class SubtitleInitializing extends SubtitleState {
  @override
  List<Object> get props => [];
}

class SubtitleInitialized extends SubtitleState {
  @override
  List<Object> get props => [];
}

class LoadingSubtitle extends SubtitleState {
  @override
  List<Object> get props => [];
}

class LoadedSubtitle extends SubtitleState {
  const LoadedSubtitle(this.subtitle);
  final Subtitle? subtitle;

  @override
  List<Object?> get props => [subtitle];
}

class CompletedSubtitle extends SubtitleState {
  @override
  List<Object> get props => [];
}
