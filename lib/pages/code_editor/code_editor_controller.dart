import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/pages/homepage/homepage_controller.dart';

class CodeEditorController extends GetxController {
  final link = ''.obs;
  final isLoading = true.obs; // 是否正在加载

  PluginEntity? plugin;
  late CodeController codeController;
  final FocusNode focusNode = FocusNode();
  final pluginDao = DatabaseService.to.database.pluginDao;

  // Get arguments
  final String pluginId =
      Get.arguments != null ? Get.arguments['pluginId'] ?? '' : '';

  @override
  void onInit() async {
    plugin = await pluginDao.findPluginById(pluginId);
    link.value = plugin?.link ?? ''; // 初始化关联链接
    if (plugin == null) focusNode.requestFocus();

    // 初始化代码编辑器
    codeController = CodeController(
      text: plugin?.script ?? '',
      language: javascript,
    );

    isLoading.value = false;
    super.onInit();
  }

  /// 保存插件
  void save() async {
    try {
      final _now = DateTime.now().millisecondsSinceEpoch;
      final (config, inputs) =
          await getPluginConfigAndInputs(codeController.text);

      plugin == null
          ? pluginDao.insertPlugin(PluginEntity(
              id: CommonUtils.generateUuid(),
              createdAt: _now,
              updatedAt: _now,
              config: config,
              inputs: inputs,
              link: link.value,
              script: codeController.text,
            ))
          : pluginDao.updatePlugin(PluginEntity(
              id: plugin!.id,
              createdAt: plugin!.createdAt,
              updatedAt: _now,
              config: config,
              inputs: inputs,
              link: link.value,
              script: codeController.text,
            ));

      SmartDialog.showToast('保存成功');

      // 更新插件列表
      Get.find<HomepageController>().getPluginList();
      Get.back();
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  /// 获取插件配置信息
  ///
  /// [script] 插件脚本
  Future<(String, String)> getPluginConfigAndInputs(String script) async {
    await PluginRuntimeService.to.initialize(script);
    final config = await PluginRuntimeService.to.config;
    final inputs = await PluginRuntimeService.to.inputs;
    return (json.encode(config), json.encode(inputs));
  }

  /// 更新关联的链接
  Future<void> updateLink() async {
    final data = await showTextInputDialog(
      context: Get.context!,
      title: '关联地址',
      message: '点击更新会从远端下载内容并更新到本地',
      okLabel: '更新',
      cancelLabel: '取消',
      textFields: [
        DialogTextField(hintText: '请输入关联地址', initialText: link.value),
      ],
    );
    if (data == null) return;
    if (data.isEmpty) return;

    link.value = data.first;
    try {
      SmartDialog.showLoading(msg: '更新中...');
      final response = await DioService.to.dio.get(link.value);
      if (response.statusCode == 200) {
        codeController.text = ''; // 清空代码
        codeController.text = response.data;
      }
      SmartDialog.dismiss();
      SmartDialog.showToast('更新成功');
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('更新失败');
    }
  }
}
