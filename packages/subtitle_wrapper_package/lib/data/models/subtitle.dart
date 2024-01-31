import 'package:equatable/equatable.dart';

class Subtitle extends Equatable {
  const Subtitle({
    required this.startTime,
    required this.endTime,
    required this.text,
  });
  final Duration startTime;
  final Duration endTime;
  final String text;

  @override
  List<Object?> get props => [startTime, endTime, text];
}
