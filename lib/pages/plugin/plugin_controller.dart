import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/common/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/pages/plugin/components/add_server_component.dart';

class PluginController extends GetxController {
  final serverList = <ServerEntity>[].obs; // 服务器列表
  final isFirstLoading = true.obs; // 是否正在加载
  final keyword = ''.obs; // 搜索关键词

  // Get arguments
  final PluginEntity plugin =
      Get.arguments != null ? Get.arguments['plugin'] ?? '' : '';

  Map<String, PluginInputModel> inputs = {};
  PluginConfigModel config = PluginConfigModel();
  final ScrollController scrollController = ScrollController();
  final pluginDao = DatabaseService.to.database.pluginDao;
  final serverDao = DatabaseService.to.database.serverDao;

  @override
  void onInit() async {
    try {
      config = PluginConfigModel.fromJson(json.decode(plugin.config));
      inputs = (json.decode(plugin.inputs) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, PluginInputModel.fromJson(value)));
    } catch (e) {
      CommonUtils.logger.e(e);
    }

    await getServerList(); // 加载服务器列表
    isFirstLoading.value = false;
    super.onInit();
  }

  /// 获取服务器列表
  Future<void> getServerList() async {
    final _serverList = await serverDao.findServerByPluginId(plugin.id);

    // 搜索关键词
    List<ServerEntity> _searchList = [];
    if (keyword.isNotEmpty) {
      _searchList = _serverList.where((server) {
        return server.name.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    }

    serverList.value = _searchList.isEmpty ? _serverList : _searchList;
    serverList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// 添加服务器
  void addServerBottomSheet() async {
    await BottomSheetHelper.showBottomSheet(
        AddServerComponent(plugin: plugin, config: config, inputs: inputs));

    // 延迟执行, 避免出现服务未被删除的情况
    await Future.delayed(Duration(milliseconds: 500), () => getServerList());
  }

  /// 显示更多操作
  ///
  /// [serverId] 服务器ID
  void moreActionSheet(String serverId) async {
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      actions: [
        SheetAction(label: '编辑', key: 'edit'),
        SheetAction(label: '清空历史记录', key: 'clear', isDestructiveAction: true),
        SheetAction(label: '删除', key: 'delete', isDestructiveAction: true),
      ],
      cancelLabel: '取消',
    );
    if (value == null) return;

    switch (value) {
      case 'edit':
        BottomSheetHelper.showBottomSheet(
          AddServerComponent(
            plugin: plugin,
            config: config,
            inputs: inputs,
            server: await serverDao.findServerById(serverId),
          ),
        ).then((value) => getServerList());
        break;
      case 'clear':
        final ok = await showOkCancelAlertDialog(
          context: Get.overlayContext!,
          title: '提示',
          message: '确定要清空历史记录吗？',
          okLabel: '清空',
          cancelLabel: '取消',
        );
        if (ok != OkCancelResult.ok) return;
        final _database = DatabaseService.to.database;
        await _database.progressDao.deleteProgressByServerId(serverId);
        await _database.historyDao.deleteHistoryByServerId(serverId);
        SmartDialog.showToast('清空成功');
        break;
      case 'delete':
        await deleteServer(serverId);
        break;
    }
  }

  /// 查看服务弹窗
  ///
  /// [serverId] 服务器ID
  Future<void> viewServerPopup(String serverId) async {
    final server = await serverDao.findServerById(serverId);
    final _inputs = json.decode(
            await ServerStorage(serverId).get('__DEUP_INPUTS__') ?? '{}')
        as Map<String, dynamic>;

    await showOkAlertDialog(
      context: Get.overlayContext!,
      title: server?.name,
      message: _inputs
          .map((key, value) => MapEntry(key, '$key: $value'))
          .values
          .join('\n'),
    );
  }

  /// 删除服务
  ///
  /// [serverId] 服务器ID
  Future<void> deleteServer(String serverId) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.overlayContext!,
      title: '提示',
      message: '确定要删除该服务吗？',
      okLabel: '删除',
      cancelLabel: '取消',
    );
    if (ok != OkCancelResult.ok) return;
    await serverDao.deleteServerById(serverId);
    final _database = DatabaseService.to.database;
    await _database.progressDao.deleteProgressByServerId(serverId);
    await _database.historyDao.deleteHistoryByServerId(serverId);
    await getServerList();
  }
}
