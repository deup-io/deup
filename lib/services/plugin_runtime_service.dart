import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/common/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/database/entity/index.dart';

class PluginRuntimeService extends GetxService {
  static PluginRuntimeService get to => Get.find();

  JavascriptRuntime _runtime = getJavascriptRuntime();
  JavascriptRuntime get runtime => _runtime;

  PluginEntity? _plugin;
  PluginEntity? get plugin => _plugin;
  PluginConfigModel get pluginConfig =>
      PluginConfigModel.fromJson(json.decode(_plugin?.config ?? '{}'));

  ServerEntity? _server;
  ServerEntity? get server => _server;

  /// Init JavascriptRuntime
  ///
  /// [plugin] is the plugin that is using the runtime
  Future<void> initialize(String script, {ServerEntity? server}) async {
    _server = server;
    _plugin = await DatabaseService.to.database.pluginDao
        .findPluginById(server?.pluginId ?? '');

    // Init runtime
    _runtime = getJavascriptRuntime();
    _runtime.evaluate("""
      var window = global = globalThis;

      // window.crypto.getRandomValues
      if (typeof window.crypto !== 'object') {
        window.crypto = {
          getRandomValues: (array) => array.map(() => Math.floor(Math.random() * 256)),
        };
      }
    """);

    _runtime.evaluate(await rootBundle.loadString('assets/js/deup.min.js'));
    _runtime.evaluate("""
      var Deup = global.Deup;
      var __NATIVE__ = Deup.__NATIVE__;

      // Global variables
      var \$alert = __NATIVE__.alert;
      var \$axios = __NATIVE__.axios;
      var \$iconv = __NATIVE__.iconv;
      var \$cookie = __NATIVE__.cookie;
      var \$crypto = __NATIVE__.crypto;
      var \$cheerio = __NATIVE__.cheerio;
      var \$storage = __NATIVE__.storage;

      // Lodash
      var _ = __NATIVE__.lodash;
      var \$lodash = __NATIVE__.lodash;

      // Completion of non-existent methods
      var URL = __NATIVE__.URLParse.default;

      // Base64
      var Base64 = __NATIVE__.Base64;
      if (typeof window.btoa !== 'function') window.btoa = Base64.btoa;
      if (typeof window.atob !== 'function') window.atob = Base64.atob;
    """);

    // Alert
    _runtime.onMessage('Deup.alert', (args) {
      Future.delayed(Duration(milliseconds: 200), () {
        _showAlertDialog(args['message'].toString());
      });
    });

    _evaluate(script);
    _runtime.evaluate("""
      var __DEUP_JS_CALLBACK_LIST__ = __NATIVE__.__DEUP_JS_CALLBACK_LIST__;
      var __DEUP_JS_PLUGIN_INSTANCE__ = __NATIVE__.__DEUP_JS_PLUGIN_INSTANCE__;
    """);

    _initStorageCallbacks();
    _initCookieCallbacks();
  }

  /// Get config
  Future<PluginConfigModel> get config async {
    try {
      final config = await _return("""__DEUP_JS_PLUGIN_INSTANCE__.config""");
      return PluginConfigModel.fromJson(json.decode(config.stringResult));
    } catch (e) {
      _showToast(e.toString());
      throw '无法获取插件配置信息';
    }
  }

  /// Get inputs
  Future<Map<String, PluginInputModel>> get inputs async {
    try {
      final inputs = await _return("""__DEUP_JS_PLUGIN_INSTANCE__.inputs""");
      return (json.decode(inputs.stringResult) as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, PluginInputModel.fromJson(value)));
    } catch (e) {
      _showToast(e.toString());
      throw '无法获取插件信息';
    }
  }

  /// Check if the plugin is running
  Future<bool> check() async {
    try {
      final result = await _evaluate("""
        return __DEUP_JS_PLUGIN_INSTANCE__.check();
      """);

      return result.stringResult == 'true';
    } catch (e) {
      _showToast(e.toString());
    }

    return false;
  }

  /// Get object
  ///
  /// [object] is the path of the file
  Future<ObjectModel?> get(ObjectModel? object) async {
    try {
      final result = await _return("""
        await __DEUP_JS_PLUGIN_INSTANCE__.get(
          ${object == null ? 'null' : json.encode(object.toJson())}
        )
      """);

      if (_isNull(result.stringResult)) return null;
      return ObjectModel.fromJson(json.decode(result.stringResult));
    } catch (e) {
      _showToast(e.toString());
    }

    return null;
  }

  /// Get object list
  ///
  /// [object] is the path of the directory
  /// [offset] is the offset of the result
  /// [limit] is the limit of the result
  Future<List<ObjectModel>> list(ObjectModel? object,
      {int offset = 0, int limit = 20}) async {
    try {
      final objects = await _return("""
        await __DEUP_JS_PLUGIN_INSTANCE__.list(
          ${object == null ? 'null' : json.encode(object.toJson())}, ${offset}, ${limit}
        )
      """);

      if (_isNull(objects.stringResult)) return [];
      return (json.decode(objects.stringResult) as List<dynamic>)
          .map((e) => ObjectModel.fromJson(e))
          .toList();
    } catch (e) {
      _showToast(e.toString());
    }

    return [];
  }

  /// Search object
  ///
  /// [object] is the path of the directory
  /// [keyword] is the keyword to search
  /// [offset] is the offset of the result
  /// [limit] is the limit of the result
  Future<List<ObjectModel>> search(ObjectModel? object, String keyword,
      {int offset = 0, int limit = 20}) async {
    try {
      final objects = await _return("""
        await __DEUP_JS_PLUGIN_INSTANCE__.search(
          ${object == null ? 'null' : json.encode(object.toJson())}, `${keyword}`, ${offset}, ${limit}
        )
      """);

      if (_isNull(objects.stringResult)) return [];
      return (json.decode(objects.stringResult) as List<dynamic>)
          .map((e) => ObjectModel.fromJson(e))
          .toList();
    } catch (e) {
      _showToast(e.toString());
    }

    return [];
  }

  /// Storage callbacks
  void _initStorageCallbacks() {
    _runtime.onMessage('Storage.get', (args) {
      final key = args['key'];
      final resolveId = args['resolveId'];
      final rejectId = args['rejectId'];

      if (!_verifyStorageData(key, rejectId)) return;
      ServerStorage(_server!.id)
          .get(key)
          .then((value) => _runtimeCallback(resolveId, args: [value]))
          .catchError((e) => _runtimeCallback(rejectId, args: [e.toString()]));
    });

    _runtime.onMessage('Storage.set', (args) {
      final key = args['key'];
      final value = args['value'];
      final resolveId = args['resolveId'];
      final rejectId = args['rejectId'];

      if (!_verifyStorageData(key, rejectId)) return;
      ServerStorage(_server!.id)
          .set(key, value)
          .then((value) => _runtimeCallback(resolveId, args: [true]))
          .catchError((e) => _runtimeCallback(rejectId, args: [e.toString()]));
    });

    _runtime.onMessage('Storage.remove', (args) {
      final key = args['key'];
      final resolveId = args['resolveId'];
      final rejectId = args['rejectId'];

      if (!_verifyStorageData(key, rejectId)) return;
      ServerStorage(_server!.id)
          .remove(key)
          .then((value) => _runtimeCallback(resolveId, args: [true]))
          .catchError((e) => _runtimeCallback(rejectId, args: [e.toString()]));
    });

    _runtime.onMessage('Storage.clear', (args) {
      final resolveId = args['resolveId'];
      final rejectId = args['rejectId'];

      // No server selected
      if (_server == null) {
        return _runtimeCallback(rejectId, args: ['Server is not selected']);
      }

      ServerStorage(_server!.id)
          .clear()
          .then((value) => _runtimeCallback(resolveId, args: [true]))
          .catchError((e) => _runtimeCallback(rejectId, args: [e.toString()]));
    });
  }

  /// Cookie callbacks
  void _initCookieCallbacks() {
    _runtime.onMessage('Cookie.get', (args) {
      final url = args['url'];
      final name = args['name'];
      final resolveId = args['resolveId'];
      final rejectId = args['rejectId'];

      Cookie()
          .get(url, name)
          .then((value) => _runtimeCallback(resolveId, args: [value]))
          .catchError((e) => _runtimeCallback(rejectId, args: [e.toString()]));
    });

    _runtime.onMessage('Cookie.set', (args) {
      final url = args['url'];
      final name = args['name'];
      final value = args['value'];
      final options = CookieOptionsModel.fromJson(args['options']);
      final resolveId = args['resolveId'];
      final rejectId = args['rejectId'];

      Cookie()
          .set(url, name, value, options)
          .then((value) => _runtimeCallback(resolveId, args: [value]))
          .catchError((e) => _runtimeCallback(rejectId, args: [e.toString()]));
    });
  }

  /// Verifying Storage Data
  ///
  /// [key] is the key of the data
  /// [rejectId] is the id of the reject callback
  bool _verifyStorageData(dynamic key, dynamic rejectId) {
    // Determine if key is a string
    if (key is! String) {
      _runtimeCallback(rejectId, args: ['Key must be a string']);
      return false;
    }

    // No server selected
    if (_server == null) {
      _runtimeCallback(rejectId, args: ['Server is not selected']);
      return false;
    }

    return true;
  }

  /// Adaptation of return values for Android and ios
  ///
  /// [script] is the script to be evaluated
  Future<JsEvalResult> _return(String script) async {
    return GetPlatform.isAndroid
        ? _evaluate("""return JSON.stringify($script);""")
        : _evaluate("""return $script;""");
  }

  /// Evaluate Javascript
  ///
  /// [script] is the script to be evaluated
  Future<JsEvalResult> _evaluate(String script) {
    try {
      return _runtime.handlePromise(_runtime.evaluate("""
        (async () => {
          try {
            ${script}
          } catch(error) {
            let message = '出错啦!';
            if (typeof error == 'string') {
              message = error;
            } else if (typeof error.message == 'string') {
              message = error.message;
            }
  
            sendMessage('Deup.alert', JSON.stringify({ message }));
          }
        })();
      """), timeout: Duration(milliseconds: pluginConfig.timeout ?? 5000));
    } catch (e) {
      _showToast(e.toString());
      throw '无法执行插件脚本';
    }
  }

  /// Runtime callback
  ///
  /// [callbackId] is the id of the callback function
  /// [args] is the arguments of the callback function
  Future<void> _runtimeCallback(int callbackId, {List<dynamic>? args}) async {
    try {
      String parameters = '__DEUP_JS_PLUGIN_INSTANCE__';
      args?.forEach((element) => parameters +=
          ', ${element is num ? element : (element is String ? '`${element}`' : json.encode(element))}');

      await _evaluate("""
        __DEUP_JS_CALLBACK_LIST__[$callbackId].call($parameters);
      """);
    } catch (e) {
      _showAlertDialog(e.toString(), title: '错误');
    }
  }

  /// 检测返回值是否为空
  bool _isNull(dynamic value) {
    return value == null || value == 'null' || value == 'undefined';
  }

  /// Prompt message
  ///
  /// [message] 消息
  /// [title] 标题
  Future<void> _showAlertDialog(String message, {String? title}) async {
    showOkAlertDialog(
      context: Get.context!,
      title: title ?? '提示',
      message: message,
      okLabel: '确定',
    );
  }

  /// Toast message
  ///
  /// [message] 消息
  void _showToast(String message) {
    if (message.isEmpty) return;

    // Remove double quotes and single quotes
    if (message.startsWith(RegExp('"|\''))) {
      message = message.substring(1, message.length - 1);
    }

    // Print error message
    CommonUtils.logger.e(message);

    // TimeoutException is not displayed
    if (message.startsWith('TimeoutException')) return;
    SmartDialog.showToast(message);
  }
}
