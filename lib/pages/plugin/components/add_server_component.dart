import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:deup/models/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/database/entity/index.dart';

class AddServerComponent extends StatefulWidget {
  final PluginEntity plugin;
  final PluginConfigModel config;
  final Map<String, PluginInputModel> inputs;
  final ServerEntity? server;

  const AddServerComponent({
    Key? key,
    required this.plugin,
    required this.config,
    required this.inputs,
    this.server,
  }) : super(key: key);

  @override
  _AddServerComponentState createState() => _AddServerComponentState();
}

class _AddServerComponentState extends State<AddServerComponent> {
  bool _isServerValid = false;
  final Map<String, dynamic> _inputData = {};
  final Map<String, dynamic> _oldInputData = {};
  TextEditingController _nameController = TextEditingController();

  // 获取服务信息
  final _serverId = CommonUtils.generateUuid();
  ServerEntity get _server =>
      widget.server ??
      ServerEntity(
        id: _serverId,
        name: 'Untitled',
        pluginId: widget.plugin.id,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  /// 初始化
  void _initialize() async {
    if (widget.server == null)
      await DatabaseService.to.database.serverDao.insertServer(_server);

    // 初始化插件运行时
    await PluginRuntimeService.to
        .initialize(widget.plugin.script, server: _server);

    // 获取原来的输入数据
    try {
      _oldInputData.addAll(
        json.decode(await ServerStorage(_server.id).get('__DEUP_INPUTS__')),
      );
      _inputData.addAll(_oldInputData);
      _nameController.text = _server.name;
    } catch (e) {}

    setState(() {});
  }

  @override
  void dispose() {
    if (!_isServerValid && widget.server == null) {
      DatabaseService.to.database.serverDao.deleteServerById(_server.id);
      DatabaseService.to.database.storageDao
          .deleteStorageByServerId(_server.id);
    }

    super.dispose();
  }

  /// 保存
  void _save() async {
    if (!_checkInputs()) return;

    // 校验服务是否可用
    bool _checked = false;
    SmartDialog.showLoading(msg: '加载中...');
    final _data = await ServerStorage(_server.id).get(null);
    try {
      await ServerStorage(_server.id).clear();
      await ServerStorage(_server.id)
          .set('__DEUP_INPUTS__', json.encode(_inputData));

      _checked = await PluginRuntimeService.to.check();
    } catch (e) {}
    SmartDialog.dismiss();

    if (!_checked) {
      await ServerStorage(_server.id).set(null, _data);
      SmartDialog.showToast('服务验证失败');
      return;
    }

    // 更新服务器名称
    if (_nameController.text.isNotEmpty) {
      await DatabaseService.to.database.serverDao.updateServer(
        ServerEntity(
          id: _server.id,
          name: _nameController.text,
          pluginId: widget.plugin.id,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    _isServerValid = true;
    SmartDialog.showToast('保存成功');
    Get.back();
  }

  /// 校验输入项是否为空
  bool _checkInputs() {
    for (final key in widget.inputs.keys) {
      final _input = widget.inputs[key]!;
      if (_input.required != null &&
          _input.required! &&
          (_inputData[key] == null || _inputData[key]!.isEmpty)) {
        SmartDialog.showToast('${widget.inputs[key]!.label}不允许为空');
        return false;
      }
    }
    return true;
  }

  /// 构建导航栏
  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: CommonUtils.backgroundColor,
      transitionBetweenRoutes: false,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: Text('关闭'),
        onPressed: () => Get.back(),
      ),
      middle: Text('${widget.server == null ? '添加' : '编辑'}服务',
          style: Get.textTheme.titleMedium),
    );
  }

  /// 构建列表项
  ///
  /// [input] 输入项
  Widget _buildListTile(String key, PluginInputModel input) {
    final _value = _oldInputData[key];
    return CupertinoListTile(
      title: Text(input.label ?? '未命名', style: Get.textTheme.titleMedium),
      trailing: Container(
        width: CommonUtils.isPad ? 780.w : 600.w,
        child: CupertinoTextField(
          placeholder: input.placeholder ?? '请输入',
          controller: TextEditingController(text: _value),
          decoration: BoxDecoration(
            border: Border.all(width: 0, color: Colors.transparent),
          ),
          onChanged: (value) {
            _inputData[key] = value;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: CupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        backgroundColor: CommonUtils.backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CupertinoListSection.insetGrouped(
                backgroundColor: CommonUtils.backgroundColor,
                dividerMargin: 20.w,
                additionalDividerMargin: 30.w,
                children: [
                  CupertinoListTile(
                    title: Text('名称'),
                    trailing: Container(
                      width: CommonUtils.isPad ? 780.w : 600.w,
                      child: CupertinoTextField(
                        controller: _nameController,
                        placeholder: 'Untitled',
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...widget.inputs.entries
                      .map((entry) => _buildListTile(entry.key, entry.value))
                      .toList(),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 100.r,
                  vertical: 30.r,
                ),
                child: ButtonHelper.createElevatedButton(
                  '保存',
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
