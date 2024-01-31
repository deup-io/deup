import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/pages/homepage/homepage_controller.dart';

class DeeplinkService extends GetxService {
  static DeeplinkService get to => Get.find();

  // Init - App running
  Future<DeeplinkService> init() async {
    try {
      uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          Timer(
            const Duration(milliseconds: 200),
            () async {
              // https://deup.io/plugins/add?url=https%3A%2F%2Fcdn.jsdelivr.net%2Fgh%2Fdeup-io%2Fdeup%2Fmovies-tv.js
              if (uri.path == '/plugins/add') {
                final String? url = uri.queryParameters['url'];
                if (url != null) addPlugin(url);
              }
            },
          );
        }
      });
    } on PlatformException {
    } on FormatException {}

    return this;
  }

  /// App wake
  Future<void> getAppWakeLink() async {
    try {
      final String? initialLink = await getInitialLink();
      if (initialLink != null) {
        final Uri uri = Uri.parse(initialLink);
        if (uri.path == '/plugins/add') {
          final String? url = uri.queryParameters['url'];
          if (url != null) addPlugin(url);
        }
      }
    } on PlatformException {
    } on FormatException {}
  }

  /// Add plugin
  ///
  /// [url] - Plugin url
  Future<void> addPlugin(String url) async {
    final ok = await showOkCancelAlertDialog(
      context: Get.context!,
      title: '提示',
      message: '您有新的插件, 确认添加吗？',
      okLabel: '确认',
      cancelLabel: '取消',
    );
    if (ok != OkCancelResult.ok) return;

    // 获取当前插件信息
    final _server = PluginRuntimeService.to.server;
    final _plugin = PluginRuntimeService.to.plugin;

    // 获取插件信息
    try {
      SmartDialog.showLoading(msg: '加载中...');
      final response = await DioService.to.dio.get(url);
      await PluginRuntimeService.to.initialize(response.data);
      final config = await PluginRuntimeService.to.config;
      final inputs = await PluginRuntimeService.to.inputs;

      // 提示用户是否添加插件
      SmartDialog.dismiss();
      final ok = await showOkCancelAlertDialog(
        context: Get.context!,
        title: '提示',
        message: '确定要添加 <${config.name}> 插件吗？',
        okLabel: '确认',
        cancelLabel: '取消',
      );
      if (ok != OkCancelResult.ok) return;

      final _now = DateTime.now().millisecondsSinceEpoch;
      await DatabaseService.to.database.pluginDao.insertPlugin(
        PluginEntity(
          id: CommonUtils.generateUuid(),
          createdAt: _now,
          updatedAt: _now,
          config: json.encode(config),
          inputs: json.encode(inputs),
          link: url,
          script: response.data,
        ),
      );

      // 更新插件列表
      Get.find<HomepageController>().getPluginList();
      SmartDialog.showToast('添加成功'); // 提示用户添加成功
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('添加失败');
    }

    // 重置插件
    if (_plugin != null && _server != null) {
      await PluginRuntimeService.to.initialize(_plugin.script, server: _server);
    }
  }
}
