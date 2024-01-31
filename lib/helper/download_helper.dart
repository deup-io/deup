import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/helper/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/database/entity/index.dart';

class DownloadHelper {
  /// 保存文件
  /// [object] 文件对象
  static file(ObjectModel object) async {
    final id = object.id ?? '';
    final type = object.type ?? '';
    final size = object.size ?? 0;

    // 检查存储权限
    bool isStorage = await checkPermissionStorage();
    if (!isStorage) {
      SmartDialog.showToast('没有存储权限');
      return;
    }

    // 当前服务器 id
    final serverId = PluginRuntimeService.to.server?.id;
    if (serverId == null) {
      SmartDialog.showToast('下载失败, 服务已被删除');
      return;
    }

    // 检查是否已经在下载列表中
    final download = await DatabaseService.to.database.downloadDao
        .findDownloadByServerIdAndObjectId(serverId, id);
    if (download != null) {
      SmartDialog.showToast('已经在下载列表中');
      return;
    }

    // 获取下载地址
    try {
      SmartDialog.showLoading();
      final _object = await getDownloadUrl(object);

      // 校验下载地址
      if (_object == null || _object.url == null || _object.url!.isEmpty) {
        SmartDialog.dismiss();
        SmartDialog.showToast('获取下载地址失败');
        return;
      }

      // 添加到下载列表
      final taskId = await FlutterDownloader.enqueue(
        url: _object.url ?? '',
        headers: ObjectHelper.getHeaders(_object) ?? {},
        savedDir: await getDownloadPath('/$serverId/$id'),
        showNotification: false,
      );

      // 添加到数据库
      await DatabaseService.to.database.downloadDao.insertDownload(
        DownloadEntity(
          serverId: serverId,
          objectId: id,
          taskId: taskId!,
          type: type,
          name: _object.name ?? '',
          size: size,
        ),
      );

      SmartDialog.showToast('已添加到下载列表');
      SmartDialog.dismiss();
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('文件下载失败');
      return;
    }
  }

  /// 获取下载地址
  static Future<ObjectModel?> getDownloadUrl(ObjectModel? object) async {
    return await PluginRuntimeService.to.get(object);
  }

  /// 检查存储权限
  static Future<bool> checkPermissionStorage() async {
    // Android 12 以上不需要申请存储权限
    if (GetPlatform.isAndroid &&
        DeviceInfoService.to.androidInfo.version.sdkInt >= 33) {
      return true;
    }

    // 检查存储权限
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  /// 获取下载目录
  static Future<String> getDownloadPath(String path) async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String p = directory!.path + '/Downloads' + path;

    // 如果目录不存在则创建
    final savedDir = Directory(p);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) await savedDir.create(recursive: true);
    return p;
  }
}
