import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:deup/helper/index.dart';

/// Logo image url
const String kDefaultLogoImageUrl =
    'https://s2.loli.net/2023/09/01/yw3jnsEWLft5ZUG.png';

/// 播放模式
class PlayMode {
  static const LIST_LOOP = 0;
  static const SINGLE_LOOP = 1;
  static const PLAY_PAUSE = 2;
  static const SHUFFLE = 3;

  static const playModeIcons = {
    PlayMode.LIST_LOOP: CupertinoIcons.repeat,
    PlayMode.SINGLE_LOOP: CupertinoIcons.repeat_1,
    PlayMode.PLAY_PAUSE: CupertinoIcons.stop_circle,
    PlayMode.SHUFFLE: CupertinoIcons.shuffle
  };

  static getIcon(int mode) {
    return playModeIcons[mode];
  }
}

/// 布局方式
class LayoutType {
  static const LIST = 'list';
  static const GRID = 'grid';
  static const IMAGE = 'image';
  static const COVER = 'cover';
  static const POSTER = 'poster';

  /// 文件类型图标
  static const mapper = {
    LayoutType.LIST: '列表',
    LayoutType.GRID: '网格',
    LayoutType.IMAGE: '图片',
    LayoutType.COVER: '封面',
    LayoutType.POSTER: '海报',
  };

  static getText(String type) {
    return mapper[type];
  }
}

/// 文件类型
class ObjectType {
  static const UNKNOWN = 'unknown';
  static const FOLDER = 'folder';
  static const IMAGE = 'image';
  static const VIDEO = 'video';
  static const AUDIO = 'audio';
  static const WEBVIEW = 'webview';
  static const DOCUMENT = 'document';

  /// 文件类型图标
  static const fileTypeIcons = {
    ObjectType.UNKNOWN: FontAwesomeIcons.solidFile,
    ObjectType.FOLDER: FontAwesomeIcons.solidFolder,
    ObjectType.VIDEO: FontAwesomeIcons.solidFileVideo,
    ObjectType.AUDIO: FontAwesomeIcons.solidFileAudio,
    ObjectType.DOCUMENT: FontAwesomeIcons.solidFileLines,
    ObjectType.IMAGE: FontAwesomeIcons.solidFileImage,
    ObjectType.WEBVIEW: FontAwesomeIcons.solidFileCode,
  };

  /// 获取文件类型图标
  /// [type] 文件类型
  static getIcon(String type, String name) {
    if (type == ObjectType.FOLDER) return FontAwesomeIcons.solidFolder;
    if (PreviewHelper.isImage(name)) return FontAwesomeIcons.solidFileImage;
    if (PreviewHelper.isVideo(name)) return FontAwesomeIcons.solidFileVideo;
    if (PreviewHelper.isAudio(name)) return FontAwesomeIcons.solidFileAudio;
    if (PreviewHelper.isDocument(name)) return FontAwesomeIcons.solidFileLines;

    return fileTypeIcons[type] ?? FontAwesomeIcons.solidFile;
  }
}

class IjkPlayerTrackType {
  static const int VIDEO = 1;
  static const int AUDIO = 2;
  static const int TIMEDTEXT = 3;
}

const ThemeModeMap = {
  'system': ThemeMode.system,
  'light': ThemeMode.light,
  'dark': ThemeMode.dark,
};

const ThemeModeTextMap = {
  'system': '跟随系统',
  'light': '明亮',
  'dark': '深邃',
};
