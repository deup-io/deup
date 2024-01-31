import 'package:chewie/chewie.dart';
import 'package:example/data/sw_constants.dart';
import 'package:flutter/material.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final String link = SwConstants.videoUrl;
  late ChewieController _chewieController;
  final SubtitleController subtitleController = SubtitleController(
    subtitleUrl: SwConstants.enSubtitle,
    subtitleDecoder: SubtitleDecoder.utf8,
  );

  @override
  void initState() {
    _chewieController = chewieController;
    super.initState();
  }

  VideoPlayerController get videoPlayerController {
    return VideoPlayerController.network(link);
  }

  ChewieController get chewieController {
    return ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 3 / 2,
      autoPlay: true,
      autoInitialize: true,
      allowFullScreen: false,
    );
  }

  void updateSubtitleUrl({
    required ExampleSubtitleLanguage subtitleLanguage,
  }) {
    String? subtitleUrl;
    switch (subtitleLanguage) {
      case ExampleSubtitleLanguage.english:
        subtitleUrl = SwConstants.enSubtitle;
        break;
      case ExampleSubtitleLanguage.spanish:
        subtitleUrl = SwConstants.esSubtitle;
        break;
      case ExampleSubtitleLanguage.dutch:
        subtitleUrl = SwConstants.nlSubtitle;
        break;
    }
    subtitleController.updateSubtitleUrl(
      url: subtitleUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b090a),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: SizedBox(
              height: 270,
              child: SubtitleWrapper(
                videoPlayerController: _chewieController.videoPlayerController,
                subtitleController: subtitleController,
                subtitleStyle: const SubtitleStyle(
                  textColor: Colors.white,
                  hasBorder: true,
                ),
                videoChild: Chewie(
                  controller: _chewieController,
                ),
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(
                0xff161a1d,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flutter subtitle wrapper package',
                            style: TextStyle(
                              fontSize: 28.0,
                              color: Colors.white.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                            ),
                            child: Text(
                              'This package can display SRT and WebVtt subtitles. With a lot of customizable options and dynamic updating support.',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Options.',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  elevation:
                                      MaterialStateProperty.all<double>(8.0),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () => updateSubtitleUrl(
                                  subtitleLanguage:
                                      ExampleSubtitleLanguage.english,
                                ),
                                child: const Text('Switch to 🇬🇧'),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  elevation:
                                      MaterialStateProperty.all<double>(8.0),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () => updateSubtitleUrl(
                                  subtitleLanguage:
                                      ExampleSubtitleLanguage.spanish,
                                ),
                                child: const Text('Switch to 🇪🇸'),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  elevation:
                                      MaterialStateProperty.all<double>(8.0),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () => updateSubtitleUrl(
                                  subtitleLanguage:
                                      ExampleSubtitleLanguage.dutch,
                                ),
                                child: const Text('Switch to 🇳🇱'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
  }
}

enum ExampleSubtitleLanguage {
  english,
  spanish,
  dutch,
}
