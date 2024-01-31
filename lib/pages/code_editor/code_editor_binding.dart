import 'package:get/get.dart';
import 'package:deup/pages/code_editor/code_editor_controller.dart';

class CodeEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CodeEditorController>(() => CodeEditorController());
  }
}
