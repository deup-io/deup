import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:deup/constants/index.dart';

class PreviewHelper {
  /// 图片类型是否支持预览
  /// [name] 文件名称
  static bool isImage(String name) {
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return kSupportPreviewImageTypes.contains(ext);
  }

  /// 视频类型是否支持预览
  /// [name] 文件名称
  static bool isVideo(String name) {
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return kSupportPreviewVideoTypes.contains(ext);
  }

  /// 音频类型是否支持预览
  /// [name] 文件名称
  static bool isAudio(String name) {
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return kSupportPreviewAudioTypes.contains(ext);
  }

  /// 文档类型是否支持预览
  /// [name] 文件名称
  static bool isDocument(String name) {
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();

    // Android 只支持代码和 pdf 预览
    if (GetPlatform.isAndroid) return isCode(name) || ext == 'pdf';
    return kSupportPreviewDocumentTypes.contains(ext);
  }

  /// 代码类型是否支持预览
  /// [name] 文件名称
  static bool isCode(String name) {
    // 两个数组的交集 kSupportPreviewCodeTypes
    final intersection = kSupportPreviewDocumentTypes
        .toSet()
        .intersection(kSupportPreviewCodeTypes.toSet());

    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return intersection.contains(ext);
  }

  /// 是否是 HTML
  /// [name] 文件名称
  static bool isHtml(String name) {
    final ext = p.extension(name).replaceAll('.', '').toLowerCase();
    return ext == 'html' || ext == 'htm';
  }
}
