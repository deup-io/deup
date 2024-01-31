import 'package:get/get.dart';
import 'package:deup/pages/plugin/plugin_controller.dart';

class PluginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PluginController>(() => PluginController());
  }
}
