import 'dart:io';
import 'dart:convert';

import 'package:get/get.dart';

import 'package:deup/common/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/helper/preview_helper.dart';
import 'package:deup/pages/detail/detail_view.dart';

/// 文件操作类
class ObjectHelper {
  /// 获取头信息
  ///
  /// [object] 对象信息
  static Map<String, String>? getHeaders(ObjectModel? object) {
    final plugin = PluginRuntimeService.to.plugin;
    if (plugin == null) return object?.headers;
    final config = PluginConfigModel.fromJson(json.decode(plugin.config));
    return Map.from(config.headers ??
        {
          HttpHeaders.userAgentHeader:
              'Deup/1.0 (${Platform.isAndroid ? 'Android' : 'Iphone'}; Deup.io)',
        })
      ..addAll(object?.headers ?? {});
  }

  /// 点击对象
  ///
  /// [path] 对象路径
  /// [type] 对象类型
  /// [object] 对象名称
  /// [objects] 对象列表
  static Future<void> click({
    required ObjectModel object,
    List<ObjectModel>? objects,
    String type = ObjectType.UNKNOWN,
  }) async {
    final String id = object.id ?? '';
    final String name = object.name ?? '';

    // 添加历史记录
    CommonUtils.addHistoryRecord(object);

    // 文件夹
    if (type == ObjectType.FOLDER) {
      final String tag = id.startsWith('/') ? id.substring(1) : id;
      Get.to(
        () => DetailPage(tag: '/$tag'),
        routeName: '${Routes.DETAIL}/${tag}',
        arguments: {'id': id, 'object': object},
      );
      return;
    }

    // 预览图片
    if (PreviewHelper.isImage(name) || type == ObjectType.IMAGE) {
      Get.toNamed(Routes.IMAGE_PREVIEW, arguments: {
        'id': id,
        'object': object,
        'objects': objects,
      });
      return;
    }

    // 预览音频
    if (PreviewHelper.isAudio(name) || type == ObjectType.AUDIO) {
      Get.toNamed(Routes.AUDIO_PLAYER, arguments: {
        'id': id,
        'object': object,
        'objects': objects,
      });
      return;
    }

    // 预览视频
    if (PreviewHelper.isVideo(name) || type == ObjectType.VIDEO) {
      Get.toNamed(Routes.VIDEO_PLAYER, arguments: {
        'id': id,
        'object': object,
        'objects': objects,
      });
      return;
    }

    // Webview
    // 预览文档 & 小于 10M
    if (type == ObjectType.WEBVIEW ||
        (PreviewHelper.isDocument(name) &&
            (object.size ?? 0) < 20 * 1024 * 1024)) {
      Get.toNamed(Routes.DOCUMENT, arguments: {
        'id': id,
        'object': object,
        'objects': objects,
      });
      return;
    }

    // 其他文件
    Get.toNamed(Routes.FILE, arguments: {'id': id, 'object': object});
  }
}
