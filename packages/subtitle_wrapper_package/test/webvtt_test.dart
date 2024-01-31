import 'package:flutter_test/flutter_test.dart';
import 'package:subtitle_wrapper_package/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package/data/repository/subtitle_repository.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';

void main() {
  const subtitleUtf8Url = 'https://pastebin.com/raw/ZWWAL7fK';
  const subtitleLatin1Url =
      'https://run.mocky.io/v3/eed857c2-4d26-4c12-8951-f84fb2ac0a1a';

  const subtitleContentString = 'WEBVTT\r\n'
      '\r\n'
      '1\r\n'
      '00:00:00.420 --> 00:00:03.510\r\n'
      '<v ->Löksås ipsum själv vi ännu därmed trevnadens kom, häst kanske dimma</v>\r\n'
      '\r\n'
      '2\r\n'
      '00:00:03.510 --> 00:00:07.531\r\n'
      'annat bäckasiner därmed redan gamla, dimmhöljd miljoner groda hela\r\n'
      '\r\n'
      '3\r\n'
      '00:00:07.531 --> 00:00:11.440\r\n'
      'mjuka nu. Smultron icke tre ännu varit denna enligt kan häst, del bäckasiner\r\n'
      '\r\n'
      '4\r\n'
      '00:00:11.440 --> 00:00:14.930\r\n'
      'som tre rot så rot därmed ingalunda, hela ser genom smultron lax flera\r\n'
      '\r\n'
      '5\r\n'
      '00:00:14.930 --> 00:00:16.570\r\n'
      'ordningens. Vi olika del vi samma nya samtidigt vidsträckt dag omfångsrik';

  const latin1SubtitleContentString = 'WEBVTT\r\n'
      '\r\n'
      '1\r\n'
      '00:00:00.420 --> 00:00:03.510\r\n'
      '<v ->LÃ¶ksÃ¥s ipsum sjÃ¤lv vi Ã¤nnu dÃ¤rmed trevnadens kom, hÃ¤st kanske dimma</v>\r\n'
      '\r\n'
      '2\r\n'
      '00:00:03.510 --> 00:00:07.531\r\n'
      'annat bÃ¤ckasiner dÃ¤rmed redan gamla, dimmhÃ¶ljd miljoner groda hela\r\n'
      '\r\n'
      '3\r\n'
      '00:00:07.531 --> 00:00:11.440\r\n'
      'mjuka nu. Smultron icke tre Ã¤nnu varit denna enligt kan hÃ¤st, del bÃ¤ckasiner\r\n'
      '\r\n'
      '4\r\n'
      '00:00:11.440 --> 00:00:14.930\r\n'
      'som tre rot sÃ¥ rot dÃ¤rmed ingalunda, hela ser genom smultron lax flera\r\n'
      '\r\n'
      '5\r\n'
      '00:00:14.930 --> 00:00:16.570\r\n'
      'ordningens. Vi olika del vi samma nya samtidigt vidstrÃ¤ckt dag omfÃ¥ngsrik';

  final utf8SubtitleItems = [
    const Subtitle(
      startTime: Duration(
        milliseconds: 420,
      ),
      endTime: Duration(
        seconds: 3,
        milliseconds: 510,
      ),
      text:
          'Löksås ipsum själv vi ännu därmed trevnadens kom, häst kanske dimma',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 3,
        milliseconds: 510,
      ),
      endTime: Duration(
        seconds: 7,
        milliseconds: 531,
      ),
      text:
          'annat bäckasiner därmed redan gamla, dimmhöljd miljoner groda hela',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 7,
        milliseconds: 531,
      ),
      endTime: Duration(
        seconds: 11,
        milliseconds: 440,
      ),
      text:
          'mjuka nu. Smultron icke tre ännu varit denna enligt kan häst, del bäckasiner',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 11,
        milliseconds: 440,
      ),
      endTime: Duration(
        seconds: 14,
        milliseconds: 930,
      ),
      text:
          'som tre rot så rot därmed ingalunda, hela ser genom smultron lax flera',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 14,
        milliseconds: 930,
      ),
      endTime: Duration(
        seconds: 16,
        milliseconds: 570,
      ),
      text:
          'ordningens. Vi olika del vi samma nya samtidigt vidsträckt dag omfångsrik',
    ),
  ];

  final latin1SubtitleItems = [
    const Subtitle(
      startTime: Duration(
        milliseconds: 420,
      ),
      endTime: Duration(
        seconds: 3,
        milliseconds: 510,
      ),
      text:
          'LÃ¶ksÃ¥s ipsum sjÃ¤lv vi Ã¤nnu dÃ¤rmed trevnadens kom, hÃ¤st kanske dimma',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 3,
        milliseconds: 510,
      ),
      endTime: Duration(
        seconds: 7,
        milliseconds: 531,
      ),
      text:
          'annat bÃ¤ckasiner dÃ¤rmed redan gamla, dimmhÃ¶ljd miljoner groda hela',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 7,
        milliseconds: 531,
      ),
      endTime: Duration(
        seconds: 11,
        milliseconds: 440,
      ),
      text:
          'mjuka nu. Smultron icke tre Ã¤nnu varit denna enligt kan hÃ¤st, del bÃ¤ckasiner',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 11,
        milliseconds: 440,
      ),
      endTime: Duration(
        seconds: 14,
        milliseconds: 930,
      ),
      text:
          'som tre rot sÃ¥ rot dÃ¤rmed ingalunda, hela ser genom smultron lax flera',
    ),
    const Subtitle(
      startTime: Duration(
        seconds: 14,
        milliseconds: 930,
      ),
      endTime: Duration(
        seconds: 16,
        milliseconds: 570,
      ),
      text:
          'ordningens. Vi olika del vi samma nya samtidigt vidstrÃ¤ckt dag omfÃ¥ngsrik',
    ),
  ];

  test('Loading remote of WebVtt subtitle file', () async {
    final subtitleController = SubtitleController(
      subtitleUrl: subtitleUtf8Url,
    );
    final subtitleDataRepository = SubtitleDataRepository(
      subtitleController: subtitleController,
    );
    final subtitleContent =
        await subtitleDataRepository.loadRemoteSubtitleContent(
      subtitleUrl: subtitleController.subtitleUrl!,
    );
    expect(
      subtitleContent,
      subtitleContentString,
    );
  });

  test('Loading remote of WebVtt subtitle file with latin1 codec', () async {
    final subtitleController = SubtitleController(
      subtitleUrl: subtitleUtf8Url,
      subtitleDecoder: SubtitleDecoder.latin1,
    );
    final subtitleDataRepository = SubtitleDataRepository(
      subtitleController: subtitleController,
    );
    final subtitleContent =
        await subtitleDataRepository.loadRemoteSubtitleContent(
      subtitleUrl: subtitleController.subtitleUrl!,
    );
    expect(
      subtitleContent,
      latin1SubtitleContentString,
    );
  });

  test('Loading remote of WebVtt subtitle file with utf8 codec', () async {
    final subtitleController = SubtitleController(
      subtitleUrl: subtitleUtf8Url,
      subtitleDecoder: SubtitleDecoder.utf8,
    );
    final subtitleDataRepository = SubtitleDataRepository(
      subtitleController: subtitleController,
    );
    final subtitleContent =
        await subtitleDataRepository.loadRemoteSubtitleContent(
      subtitleUrl: subtitleController.subtitleUrl!,
    );
    expect(
      subtitleContent,
      subtitleContentString,
    );
  });
  test(
    'Parsing remote of WebVtt with latin1 encoding',
    () async {
      final subtitleController = SubtitleController(
        subtitleUrl: subtitleUtf8Url,
        subtitleDecoder: SubtitleDecoder.latin1,
      );
      final subtitleDataRepository = SubtitleDataRepository(
        subtitleController: subtitleController,
      );
      final subtitles = await subtitleDataRepository.getSubtitles();
      expect(
        subtitles.subtitles,
        latin1SubtitleItems,
      );
    },
  );

  test(
    'Parsing remote of WebVtt with automatic latin1 encoding',
    () async {
      final subtitleController = SubtitleController(
        subtitleUrl: subtitleLatin1Url,
      );
      final subtitleDataRepository = SubtitleDataRepository(
        subtitleController: subtitleController,
      );
      final subtitles = await subtitleDataRepository.getSubtitles();
      expect(
        subtitles.subtitles.sublist(
          0,
          3,
        ),
        latin1SubtitleItems.sublist(
          0,
          3,
        ),
      );
    },
  );

  test(
    'Parsing remote of WebVtt subtitle file with utf8 encoding',
    () async {
      final subtitleController = SubtitleController(
        subtitleUrl: subtitleUtf8Url,
        subtitleDecoder: SubtitleDecoder.utf8,
      );
      final subtitleDataRepository = SubtitleDataRepository(
        subtitleController: subtitleController,
      );
      final subtitles = await subtitleDataRepository.getSubtitles();
      expect(
        subtitles.subtitles,
        utf8SubtitleItems,
      );
    },
  );
}
