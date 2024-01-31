import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package/data/repository/subtitle_repository.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:video_player/video_player.dart';

class MockVideoPlayerController extends Mock implements VideoPlayerController {}

void main() {
  final subtitleController = SubtitleController(
    subtitleUrl: 'https://pastebin.com/raw/ZWWAL7fK',
    subtitleDecoder: SubtitleDecoder.utf8,
  );

  group(
    'Subtitle controller',
    () {
      test('attach', () async {
        subtitleController.attach(
          SubtitleBloc(
            subtitleController: subtitleController,
            subtitleRepository: SubtitleDataRepository(
              subtitleController: subtitleController,
            ),
            videoPlayerController: MockVideoPlayerController(),
          ),
        );
      });
      test('detach', () async {
        subtitleController.detach();
      });

      test('update subtitle url', () async {
        subtitleController
          ..attach(
            SubtitleBloc(
              subtitleController: subtitleController,
              subtitleRepository: SubtitleDataRepository(
                subtitleController: subtitleController,
              ),
              videoPlayerController: MockVideoPlayerController(),
            ),
          )
          ..updateSubtitleUrl(
            url: 'https://pastebin.com/raw/ZWWAL7fK',
          );
      });

      test('update subtitle content', () async {
        subtitleController
          ..attach(
            SubtitleBloc(
              subtitleController: subtitleController,
              subtitleRepository: SubtitleDataRepository(
                subtitleController: subtitleController,
              ),
              videoPlayerController: MockVideoPlayerController(),
            ),
          )
          ..updateSubtitleContent(
            content: '',
          );
      });

      test(
        'update subtitle content without attach',
        () {
          expect(
            () {
              subtitleController
                ..detach()
                ..updateSubtitleContent(
                  content: '',
                );
            },
            throwsException,
          );
        },
      );

      test('update subtitle url without attach', () {
        expect(
          () {
            subtitleController
              ..detach()
              ..updateSubtitleUrl(
                url: 'https://pastebin.com/raw/ZWWAL7fK',
              );
          },
          throwsException,
        );
      });
    },
  );
}
