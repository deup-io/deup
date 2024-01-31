part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  // notfound
  static const NOTFOUND = _Paths.NOTFOUND;

  static const SPLASH = _Paths.SPLASH;
  static const HOMEPAGE = _Paths.HOMEPAGE;
  static const PLUGIN = _Paths.PLUGIN;
  static const DETAIL = _Paths.DETAIL;
  static const DOCUMENT = _Paths.DOCUMENT;
  static const FILE = _Paths.FILE;
  static const WEBVIEW = _Paths.WEBVIEW;
  static const CODE_EDITOR = _Paths.CODE_EDITOR;
  static const IMAGE_PREVIEW = _Paths.IMAGE_PREVIEW;
  static const AUDIO_PLAYER = _Paths.AUDIO_PLAYER;
  static const VIDEO_PLAYER = _Paths.VIDEO_PLAYER;

  // Settings
  static const SETTING = _Paths.SETTING;
  static const SETTING_ABOUT = _Paths.SETTING + _Paths.ABOUT;
  static const SETTING_DOWNLOAD = _Paths.SETTING + _Paths.DOWNLOAD;
}

abstract class _Paths {
  static const SPLASH = '/';
  static const NOTFOUND = '/notfound';
  static const HOMEPAGE = '/homepage';
  static const PLUGIN = '/plugin';
  static const DETAIL = '/detail';
  static const DOCUMENT = '/document';
  static const FILE = '/file';
  static const WEBVIEW = '/webview';
  static const CODE_EDITOR = '/code/editor';
  static const IMAGE_PREVIEW = '/image/preview';
  static const AUDIO_PLAYER = '/player/audio';
  static const VIDEO_PLAYER = '/player/video';

  // Settings
  static const SETTING = '/setting';
  static const ABOUT = '/about';
  static const DOWNLOAD = '/download';
}
