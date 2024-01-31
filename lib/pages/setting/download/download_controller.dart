import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/helper/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/database/entity/index.dart';

class DownloadController extends GetxController {
  final entities = <DownloadEntity>[].obs; // 下载列表
  final tasks = <DownloadTask>[].obs; // 任务列表
  final isFirstLoading = true.obs; // 是否是第一次加载
  final totalSize = 0.obs; // 总大小

  // ScrollController
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();

    // 加载完成
    isFirstLoading.value = false;

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {
      updateDownloadStatus(id, DownloadTaskStatus.fromInt(status), progress);
    });

    // 监听下载状态
    await FlutterDownloader.registerCallback(downloadCallback);

    // 获取任务列表 & 翻转
    final taskList = await FlutterDownloader.loadTasks() ?? [];
    tasks.value = taskList.reversed.toList();

    // 获取下载列表
    entities.value =
        await DatabaseService.to.database.downloadDao.findAllDownload();

    // 总大小
    resetTotalSize();
  }

  /// 重新获取总大小
  void resetTotalSize() {
    totalSize.value = entities.fold<int>(0, (sum, e) => sum + e.size);
  }

  /// 更新下载状态
  /// [id] 任务 id
  /// [status] 下载状态
  /// [progress] 下载进度
  void updateDownloadStatus(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final index = tasks.indexWhere((t) => t.taskId == id);
    final task = tasks[index];
    tasks[index] = DownloadTask(
      taskId: id,
      status: status,
      progress: progress,
      url: task.url,
      filename: task.filename,
      savedDir: task.savedDir,
      timeCreated: task.timeCreated,
      allowCellular: task.allowCellular,
    );

    // 刷新数据
    tasks.refresh();
  }

  /// 打开文件
  /// [task] 任务
  /// [entity] 下载实体
  void open(DownloadTask task, DownloadEntity entity) async {
    if (task.status != DownloadTaskStatus.complete) {
      SmartDialog.showToast('下载未完成');
      return;
    }

    // 初始化插件
    try {
      SmartDialog.showLoading();
      final _database = DatabaseService.to.database;
      final _server = await _database.serverDao.findServerById(entity.serverId);
      final _plugin =
          await _database.pluginDao.findPluginById(_server?.pluginId ?? '');
      await PluginRuntimeService.to
          .initialize(_plugin?.script ?? '', server: _server);
      SmartDialog.dismiss();
    } catch (e) {
      SmartDialog.dismiss();
    }

    // 允许播放的视频 & 音频
    final _arguments = {
      'name': entity.name,
      'downloadId': entity.id,
      'file': '${task.savedDir}/${entity.name}',
      'objects': [
        ObjectModel.fromJson({
          'name': entity.name,
          'type': entity.type,
          'isDirectory': false,
          'size': entity.size,
        }),
      ],
    };

    if (PreviewHelper.isVideo(entity.name) || entity.type == ObjectType.VIDEO) {
      Get.toNamed(Routes.VIDEO_PLAYER, arguments: _arguments);
      return;
    }

    if (PreviewHelper.isAudio(entity.name) || entity.type == ObjectType.AUDIO) {
      Get.toNamed(Routes.AUDIO_PLAYER, arguments: _arguments);
      return;
    }

    // 打开文件
    if (!await FlutterDownloader.open(taskId: task.taskId)) {
      Share.shareXFiles([XFile('${task.savedDir}/${entity.name}')]);
    }
  }

  /// 恢复下载
  /// [id] 下载 id
  /// [taskId] 任务 id
  void resume(int id, String taskId) async {
    final newTaskId = await FlutterDownloader.resume(taskId: taskId);

    // 更新任务
    final index = tasks.indexWhere((t) => t.taskId == taskId);
    final task = tasks[index];
    tasks[index] = DownloadTask(
      taskId: newTaskId!,
      status: task.status,
      progress: task.progress,
      url: task.url,
      filename: task.filename,
      savedDir: task.savedDir,
      timeCreated: task.timeCreated,
      allowCellular: task.allowCellular,
    );

    // 更新数据库
    final downloadIndex = entities.indexWhere((e) => e.id == id);
    final entity = entities[downloadIndex];
    entities[downloadIndex] = DownloadEntity(
      id: id,
      taskId: newTaskId,
      objectId: entity.objectId,
      serverId: entity.serverId,
      type: entity.type,
      name: entity.name,
      size: entity.size,
    );
    await DatabaseService.to.database.downloadDao.updateDownload(
      entities[downloadIndex],
    );
  }

  /// 删除下载
  /// [id] 下载 id
  /// [taskId] 任务 id
  void delete(int id, String taskId) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.context!,
      title: '提示',
      message: '确定要删除吗？',
      okLabel: '确认',
      cancelLabel: '取消',
    );
    if (ok != OkCancelResult.ok) return;

    SmartDialog.showLoading();
    await FlutterDownloader.cancel(taskId: taskId);
    await DatabaseService.to.database.downloadDao.deleteDownloadById(id);
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
    entities.removeWhere((element) => element.id == id);
    tasks.removeWhere((element) => element.taskId == taskId);
    resetTotalSize();

    SmartDialog.dismiss();
    SmartDialog.showToast('删除成功');
  }

  @override
  void onClose() {
    DownloadService.to.unbindBackgroundIsolate();
    super.onClose();
  }
}
