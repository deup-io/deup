import 'package:get/get.dart';

import 'package:deup/pages/file/file_view.dart';
import 'package:deup/pages/splash/splash_view.dart';
import 'package:deup/pages/plugin/plugin_view.dart';
import 'package:deup/pages/detail/detail_view.dart';
import 'package:deup/pages/webview/webview_view.dart';
import 'package:deup/pages/setting/setting_view.dart';
import 'package:deup/pages/homepage/homepage_view.dart';
import 'package:deup/pages/notfound/notfound_view.dart';
import 'package:deup/pages/document/document_view.dart';
import 'package:deup/pages/setting/about/about_view.dart';
import 'package:deup/pages/code_editor/code_editor_view.dart';
import 'package:deup/pages/setting/download/download_view.dart';
import 'package:deup/pages/audio_player/audio_player_view.dart';
import 'package:deup/pages/video_player/video_player_view.dart';
import 'package:deup/pages/image_preview/image_preview_view.dart';

import 'package:deup/pages/file/file_binding.dart';
import 'package:deup/pages/plugin/plugin_binding.dart';
import 'package:deup/pages/detail/detail_binding.dart';
import 'package:deup/pages/webview/webview_binding.dart';
import 'package:deup/pages/setting/setting_binding.dart';
import 'package:deup/pages/homepage/homepage_binding.dart';
import 'package:deup/pages/document/document_binding.dart';
import 'package:deup/pages/setting/about/about_binding.dart';
import 'package:deup/pages/code_editor/code_editor_binding.dart';
import 'package:deup/pages/setting/download/download_binding.dart';
import 'package:deup/pages/audio_player/audio_player_binding.dart';
import 'package:deup/pages/video_player/video_player_binding.dart';
import 'package:deup/pages/image_preview/image_preview_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = _Paths.SPLASH;

  static final routes = [
    unknownRoute,
    GetPage(name: _Paths.SPLASH, page: () => SplashPage()),
    GetPage(
      name: _Paths.HOMEPAGE,
      page: () => Homepage(),
      binding: HomepageBinding(),
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: _Paths.PLUGIN,
      page: () => PluginPage(),
      binding: PluginBinding(),
    ),
    GetPage(
      name: _Paths.CODE_EDITOR,
      page: () => CodeEditorPage(),
      binding: CodeEditorBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL,
      page: () => DetailPage(),
      binding: DetailBinding(),
    ),
    GetPage(
      name: _Paths.DOCUMENT,
      page: () => DocumentPage(),
      binding: DocumentBinding(),
    ),
    GetPage(
      name: _Paths.FILE,
      page: () => FilePage(),
      binding: FileBinding(),
    ),
    GetPage(
      name: _Paths.WEBVIEW,
      page: () => WebviewPage(),
      binding: WebviewBinding(),
    ),
    GetPage(
      name: _Paths.IMAGE_PREVIEW,
      page: () => ImagePreviewPage(),
      binding: ImagePreviewBinding(),
      opaque: false,
      showCupertinoParallax: false,
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.AUDIO_PLAYER,
      page: () => AudioPlayerPage(),
      binding: AudioPlayerBinding(),
      showCupertinoParallax: false,
      transition: Transition.downToUp,
    ),
    GetPage(
      name: _Paths.VIDEO_PLAYER,
      page: () => VideoPlayerPage(),
      binding: VideoPlayerBinding(),
    ),
    GetPage(
      name: _Paths.SETTING,
      page: () => SettingPage(),
      binding: SettingBinding(),
      children: [
        GetPage(
          name: _Paths.ABOUT,
          page: () => AboutPage(),
          binding: AboutBinding(),
        ),
        GetPage(
          name: _Paths.DOWNLOAD,
          page: () => DownloadPage(),
          binding: DownloadBinding(),
        ),
      ],
    ),
  ];

  static final unknownRoute = GetPage(
    name: _Paths.NOTFOUND,
    page: () => NotfoundPage(),
  );
}
