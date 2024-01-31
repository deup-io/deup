import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/models/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/pages/detail/detail_view.dart';

class HomepageController extends GetxController {
  final pluginList = <PluginEntity>[].obs; // 插件列表
  final isFirstLoading = true.obs; // 是否正在加载
  final keyword = ''.obs; // 搜索关键词

  // ScrollController
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();

    // 初始化 Deeplink
    Timer(
      const Duration(milliseconds: 300),
      () async => await DeeplinkService.to.getAppWakeLink(),
    );

    await getPluginList(); // 加载插件列表
    isFirstLoading.value = false;
  }

  /// 获取插件列表
  Future<void> getPluginList() async {
    final _pluginList =
        await DatabaseService.to.database.pluginDao.findAllPlugin();

    // 搜索关键词
    List<PluginEntity> _searchList = [];
    if (keyword.isNotEmpty) {
      _searchList = _pluginList.where((plugin) {
        final _config = PluginConfigModel.fromJson(json.decode(plugin.config));
        final _name = _config.name?.toLowerCase() ?? '';
        return _name.contains(keyword.toLowerCase());
      }).toList();
    }

    pluginList.value = _searchList.isEmpty ? _pluginList : _searchList;
    pluginList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// 插件点击事件
  ///
  /// [plugin] 插件
  void onPluginTap(PluginEntity plugin) async {
    final config = PluginConfigModel.fromJson(json.decode(plugin.config));

    // 如果定义了插件的输入，跳转到插件页面新建服务列表
    if (config.hasInput == null || config.hasInput == true) {
      Get.toNamed(Routes.PLUGIN, arguments: {'plugin': plugin});
      return;
    }

    // 获取所有的服务列表
    final _serverList = await DatabaseService.to.database.serverDao
        .findServerByPluginId(plugin.id);
    if (_serverList.isNotEmpty) {
      goDetailPage(plugin, server: _serverList.first);
      return;
    }

    // 如果没有服务需要新建服务
    final _server = ServerEntity(
      id: CommonUtils.generateUuid(),
      name: config.name ?? 'Untitled',
      pluginId: plugin.id,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await DatabaseService.to.database.serverDao.insertServer(_server);
    goDetailPage(plugin, server: _server);
  }

  /// 跳转到详情页
  ///
  /// [plugin] 插件
  /// [server] 服务
  void goDetailPage(PluginEntity plugin, {ServerEntity? server}) async {
    try {
      SmartDialog.showLoading(msg: '初始化中...');
      await PluginRuntimeService.to.initialize(plugin.script, server: server);
      SmartDialog.dismiss();
      Get.to(() => DetailPage(), routeName: '${Routes.DETAIL}');
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('初始化失败, 请重试');
    }
  }

  /// 显示更多操作
  ///
  /// [pluginId] 插件ID
  void moreActionSheet(String pluginId) async {
    final _plugin = pluginList.firstWhere((plugin) => plugin.id == pluginId);
    final _config = PluginConfigModel.fromJson(json.decode(_plugin.config));

    // 显示底部弹窗
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      title: _config.name ?? '',
      actions: [
        SheetAction(label: '编辑', key: 'edit'),
        if (_plugin.link != null && _plugin.link!.isNotEmpty)
          SheetAction(label: '更新', key: 'update'),
        if (_config.hasInput != null && _config.hasInput == false)
          SheetAction(label: '清空历史记录', key: 'clear', isDestructiveAction: true),
        SheetAction(label: '删除', key: 'delete', isDestructiveAction: true),
      ],
      cancelLabel: '取消',
    );
    if (value == null) return;

    switch (value) {
      case 'edit':
        Get.toNamed(Routes.CODE_EDITOR, arguments: {
          'pluginId': pluginId,
        });
        break;
      case 'update':
        await updatePlugin(_plugin);
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

        // 获取所有的服务列表
        final _serverList = await DatabaseService.to.database.serverDao
            .findServerByPluginId(_plugin.id);
        if (_serverList.isNotEmpty) {
          final _serverId = _serverList.first.id;
          final _database = DatabaseService.to.database;
          await _database.progressDao.deleteProgressByServerId(_serverId);
          await _database.historyDao.deleteHistoryByServerId(_serverId);
          SmartDialog.showToast('清空成功');
        }
        break;
      case 'delete':
        await deletePlugin(pluginId);
        break;
    }
  }

  /// 更新插件
  ///
  /// [plugin] 插件
  Future<void> updatePlugin(PluginEntity plugin) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.context!,
      title: '提示',
      message: '确认要更新该插件吗？',
      okLabel: '确认',
      cancelLabel: '取消',
    );
    if (ok != OkCancelResult.ok) return;

    try {
      SmartDialog.showLoading(msg: '更新中...');
      final response = await DioService.to.dio.get(plugin.link!);
      await PluginRuntimeService.to.initialize(response.data);
      final config = await PluginRuntimeService.to.config;
      final inputs = await PluginRuntimeService.to.inputs;

      final _now = DateTime.now().millisecondsSinceEpoch;
      await DatabaseService.to.database.pluginDao.updatePlugin(PluginEntity(
        id: plugin.id,
        createdAt: plugin.createdAt,
        updatedAt: _now,
        config: json.encode(config),
        inputs: json.encode(inputs),
        link: plugin.link,
        script: response.data,
      ));

      // 更新插件列表
      await getPluginList();
      SmartDialog.dismiss();
      SmartDialog.showToast('更新成功');
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('更新失败');
    }
  }

  /// 删除插件
  ///
  /// [pluginId] 插件ID
  Future<void> deletePlugin(String pluginId) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.overlayContext!,
      title: '提示',
      message: '确定要删除该插件吗？',
      okLabel: '删除',
      cancelLabel: '取消',
    );
    if (ok != OkCancelResult.ok) return;
    await DatabaseService.to.database.pluginDao.deletePluginById(pluginId);
    await getPluginList();
  }
}
