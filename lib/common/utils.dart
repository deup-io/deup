import 'dart:math';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:vivysub_utils/vivysub_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';

import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/database/entity/index.dart';

// 公共工具类
class CommonUtils {
  /// HexColor
  /// [color] is a hex color string, like '#ffffff'
  static Color getHexColor(String? color) {
    if (color == null || color.isEmpty) {
      return Colors.transparent;
    }

    try {
      return HexColor(color);
    } catch (e) {
      return Colors.transparent;
    }
  }

  static Logger get logger => Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );

  /// 生成 UUID
  static generateUuid() {
    return Uuid().v4();
  }

  /// 格式化文件大小
  /// [size] 文件大小
  static String formatFileSize(int? size) {
    if (size == null) return '0B';
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)}KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).toStringAsFixed(2)}MB';
    } else {
      return '${(size / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
    }
  }

  /// 是否为文件夹
  /// [object] 对象
  static bool isFolder(ObjectModel object) {
    return object.type == ObjectType.FOLDER;
  }

  /// 格式化文件名
  /// [name] 文件名
  static String formatFileNme(String name) {
    return p.basenameWithoutExtension(name);
  }

  /// 获取背景颜色
  static Color get backgroundColor => Get.isDarkMode
      ? Color.fromARGB(255, 18, 18, 18)
      : Color.fromARGB(255, 242, 242, 247);

  /// 获取导航栏 icon 大小
  static double get navIconSize => isPad ? 25 : 70.sp;

  /// 是否为平板
  static bool get isPad =>
      DeviceInfoService.to.isIpad ||
      MediaQuery.of(Get.context!).size.shortestSide >= 600;

  /// 获取导航栏返回按钮
  static Widget get backButton => CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Icon(CupertinoIcons.chevron_back, size: isPad ? 30 : 80.sp),
        onPressed: () => Get.back(),
      );

  /// 获取随机数
  ///
  /// [min] 最小值
  /// [max] 最大值
  static randomInt(int min, int max) {
    return min + (max - min) * (Random().nextDouble());
  }

  /// 格式化 ijk track 信息
  ///
  /// [track] track 信息
  static String formatIjkTrack(String track) {
    return capitalize(track == 'und' ? '未知' : track);
  }

  /// 首字母大写
  ///
  /// [str] 字符串
  static String capitalize(String str) {
    return str.substring(0, 1).toUpperCase() + str.substring(1);
  }

  /// ass to srt
  /// [content] 字幕内容
  static Future<List<Subtitle>> ass2srt(String content) async {
    final assParser = AssParser(content: content); // 解析 ass

    // 字幕
    List<Subtitle> subtitles = [];
    List<Section> sections = assParser.getSections();

    // 循环处理字幕数据
    for (var section in sections) {
      if (section.name != '[Events]') continue;

      for (var entity in section.body.sublist(1)) {
        final value = entity.value['value'];
        if (value['Start'] == null || value['End'] == null) continue;

        // 正则表达式 匹配时间
        final regExp =
            RegExp(r'(\d{1,2}):(\d{2}):(\d{2})\.(\d+)', caseSensitive: false);

        // 开始时间
        final startTimeMatch = regExp.allMatches(value['Start']).toList().first;
        final startTimeHours = int.parse(startTimeMatch.group(1)!);
        final startTimeMinutes = int.parse(startTimeMatch.group(2)!);
        final startTimeSeconds = int.parse(startTimeMatch.group(3)!);
        final startTimeMilliseconds =
            int.parse(startTimeMatch.group(4)!.padRight(3, '0'));

        // 结束时间
        final endTimeMatch = regExp.allMatches(value['End']).toList().first;
        final endTimeHours = int.parse(endTimeMatch.group(1)!);
        final endTimeMinutes = int.parse(endTimeMatch.group(2)!);
        final endTimeSeconds = int.parse(endTimeMatch.group(3)!);
        final endTimeMilliseconds =
            int.parse(endTimeMatch.group(4)!.padRight(3, '0'));

        final startTime = Duration(
          hours: startTimeHours,
          minutes: startTimeMinutes,
          seconds: startTimeSeconds,
          milliseconds: startTimeMilliseconds,
        );

        final endTime = Duration(
          hours: endTimeHours,
          minutes: endTimeMinutes,
          seconds: endTimeSeconds,
          milliseconds: endTimeMilliseconds,
        );

        subtitles.add(
          Subtitle(
            startTime: startTime,
            endTime: endTime,
            text: value['Text']
                .toString()
                .replaceAll(RegExp(r'({.+?})'), '')
                .replaceAll('\\N', '\n')
                .trim(),
          ),
        );
      }
    }

    return subtitles;
  }

  /// 加入历史记录
  ///
  /// [object] 对象
  static Future<void> addHistoryRecord(ObjectModel object) async {
    final serverId = PluginRuntimeService.to.server?.id;
    if (serverId == null) return;

    // 查询是否存在
    final record = await DatabaseService.to.database.historyDao
        .findHistoryByServerIdAndObjectId(serverId, object.id!);

    // 更新 or 创建
    if (record != null) {
      await DatabaseService.to.database.historyDao.updateHistory(
        HistoryEntity(
          id: record.id,
          serverId: serverId,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          objectId: object.id!,
          data: json.encode(object.toJson()),
        ),
      );
    } else {
      await DatabaseService.to.database.historyDao.insertHistory(
        HistoryEntity(
          serverId: serverId,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          objectId: object.id!,
          data: json.encode(object.toJson()),
        ),
      );
    }
  }

  // blob://base64/xxxxxx
  // blob://text/xxxxxx
  static List<int>? getBlobData(String? url) {
    if (url == null) return null;
    final _url = Uri.parse(url);
    if (_url.scheme == 'blob') {
      final _function = _url.host;
      if (_function == 'base64') {
        return base64.decode(url.replaceFirst('blob://base64/', ''));
      }

      return utf8.encode(url.replaceFirst('blob://text/', ''));
    }

    return null;
  }
}
